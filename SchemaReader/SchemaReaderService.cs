using System.Collections.Concurrent;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace SchemaReader;

public sealed class SchemaReaderService : ISchemaReader
{
    private const string CachePrefix = "schema";
    private static readonly MemoryCache MemoryCache = new(new MemoryCacheOptions());
    private static readonly ConcurrentDictionary<string, Lazy<Task<SchemaWithSignature>>> InflightLoads = new();
    private static readonly string[] LoadSteps =
    [
        "Read schemas",
        "Read columns",
        "Read tables",
        "Read views",
        "Read stored procedures",
        "Read functions"
    ];

    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.General)
    {
        PropertyNameCaseInsensitive = true,
        WriteIndented = false
    };

    private readonly IDistributedCache _cache;
    private readonly ILogger<SchemaReaderService> _logger;

    public SchemaReaderService(IDistributedCache cache, ILogger<SchemaReaderService> logger)
    {
        _cache = cache;
        _logger = logger;
    }

    public async Task<DatabaseSchema> ReadSchemaAsync(string connectionString, CancellationToken cancellationToken = default)
    {
        var connectionBuilder = new SqlConnectionStringBuilder(connectionString);
        var cacheKey = BuildCacheKey(connectionBuilder);

        var databaseName = string.IsNullOrWhiteSpace(connectionBuilder.InitialCatalog)
            ? "<default>"
            : connectionBuilder.InitialCatalog;

        var dataSource = string.IsNullOrWhiteSpace(connectionBuilder.DataSource)
            ? "<unknown>"
            : connectionBuilder.DataSource;

        _logger.LogInformation(
            "Reading schema for database {Database} on {DataSource} with cache key {CacheKey}",
            databaseName,
            dataSource,
            cacheKey);

        var readStopwatch = Stopwatch.StartNew();
        var databaseDirectory = ResolveDatabaseDirectory(connectionBuilder.InitialCatalog);
        var signature = ComputeDatabaseDirectorySignature(databaseDirectory);

        try
        {
            var memoryCached = TryReadFromMemoryCache(cacheKey, signature);
            if (memoryCached is not null)
            {
                _logger.LogInformation("Schema memory cache hit for {Database}; returning cached value", databaseName);
                return memoryCached;
            }

            var cached = await TryReadFromCacheAsync(cacheKey, signature, cancellationToken).ConfigureAwait(false);
            if (cached is not null)
            {
                _logger.LogInformation("Schema cache hit for {Database}; returning cached value", databaseName);
                return cached;
            }

            _logger.LogInformation("Schema cache miss for {Database}; loading from database", databaseName);

            var inflightKey = BuildMemoryCacheKey(cacheKey, signature);
            var loader = InflightLoads.GetOrAdd(
                inflightKey,
                _ => new Lazy<Task<SchemaWithSignature>>(
                    () => LoadAndCacheSchemaAsync(
                        connectionBuilder,
                        cacheKey,
                        signature,
                        databaseDirectory,
                        dataSource,
                        cancellationToken),
                    LazyThreadSafetyMode.ExecutionAndPublication));

            try
            {
                var loaded = await loader.Value.ConfigureAwait(false);
                AddToMemoryCache(cacheKey, loaded.Signature, loaded.Schema);
                return loaded.Schema;
            }
            finally
            {
                InflightLoads.TryRemove(inflightKey, out _);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to read schema for {Database} on {DataSource}", databaseName, dataSource);
            throw;
        }
        finally
        {
            _logger.LogInformation("Schema read completed for {Database} in {Elapsed}", databaseName, readStopwatch.Elapsed);
        }
    }

    private static readonly string SolutionRoot = ResolveSolutionRoot();

    public static string SchemaResultFilePath => Path.Combine(SolutionRoot, "SchemaReader", "SchemaReaderResult.json");

    private static string BuildCacheKey(SqlConnectionStringBuilder builder)
    {
        var dataSource = string.IsNullOrWhiteSpace(builder.DataSource)
            ? "unknown"
            : builder.DataSource.Replace(':', '_').Replace('\\', '_').Replace('/', '_');

        var database = string.IsNullOrWhiteSpace(builder.InitialCatalog)
            ? "default"
            : builder.InitialCatalog;

        return $"{CachePrefix}:{dataSource}:{database}";
    }

    private DatabaseSchema? TryReadFromMemoryCache(string cacheKey, string signature)
    {
        if (MemoryCache.TryGetValue(BuildMemoryCacheKey(cacheKey, signature), out DatabaseSchema? schema))
        {
            _logger.LogDebug("Memory cache hit for key {CacheKey} with signature {Signature}", cacheKey, signature);
            return schema;
        }

        _logger.LogDebug("No memory cache entry for key {CacheKey} with signature {Signature}", cacheKey, signature);
        return null;
    }

    private async Task<DatabaseSchema?> TryReadFromCacheAsync(string cacheKey, string signature, CancellationToken cancellationToken)
    {
        try
        {
            var cached = await _cache.GetStringAsync(cacheKey, cancellationToken).ConfigureAwait(false);
            if (string.IsNullOrWhiteSpace(cached))
            {
                _logger.LogDebug("No cached schema found for key {CacheKey}", cacheKey);
                return null;
            }

            try
            {
                var envelope = JsonSerializer.Deserialize<CachedSchemaEnvelope>(cached, SerializerOptions);
                if (envelope is null)
                {
                    _logger.LogDebug("Cached schema could not be deserialized for key {CacheKey}", cacheKey);
                    return TryPromoteLegacyCache(cached, cacheKey, signature);
                }

                if (!string.Equals(envelope.Signature, signature, StringComparison.Ordinal))
                {
                    _logger.LogInformation(
                        "Cached schema signature mismatch for key {CacheKey}. Cached: {CachedSignature}, Current: {Signature}",
                        cacheKey,
                        envelope.Signature,
                        signature);
                    return null;
                }

                _logger.LogDebug("Cached schema retrieved for key {CacheKey} with signature {Signature}", cacheKey, signature);
                AddToMemoryCache(cacheKey, signature, envelope.Schema);
                return envelope.Schema;
            }
            catch (JsonException)
            {
                return TryPromoteLegacyCache(cached, cacheKey, signature);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Unable to read schema cache for key {CacheKey}", cacheKey);
            return null;
        }
    }

    private async Task WriteToCacheAsync(string cacheKey, DatabaseSchema schema, string signature, CancellationToken cancellationToken)
    {
        try
        {
            var serialized = JsonSerializer.Serialize(
                new CachedSchemaEnvelope { Schema = schema, Signature = signature },
                SerializerOptions);
            var options = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(12)
            };

            await _cache.SetStringAsync(cacheKey, serialized, options, cancellationToken).ConfigureAwait(false);
            _logger.LogInformation("Cached schema under key {CacheKey}", cacheKey);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Unable to write schema cache for key {CacheKey}", cacheKey);
        }
    }

    private static string BuildMemoryCacheKey(string cacheKey, string signature) => $"{cacheKey}|{signature}";

    private static void AddToMemoryCache(string cacheKey, string signature, DatabaseSchema schema)
    {
        MemoryCache.Set(BuildMemoryCacheKey(cacheKey, signature), schema, TimeSpan.FromHours(6));
    }

    private async Task<SchemaWithSignature> LoadAndCacheSchemaAsync(
        SqlConnectionStringBuilder connectionBuilder,
        string cacheKey,
        string signature,
        string? databaseDirectory,
        string dataSource,
        CancellationToken cancellationToken)
    {
        await using var connection = new SqlConnection(connectionBuilder.ConnectionString);
        await connection.OpenAsync(cancellationToken).ConfigureAwait(false);
        _logger.LogInformation("Opened connection to {Database} on {DataSource}", connection.Database, dataSource);

        var loadStopwatch = Stopwatch.StartNew();
        var schema = await LoadDatabaseSchemaAsync(connection, cancellationToken).ConfigureAwait(false);
        _logger.LogInformation("Loaded schema metadata from database in {Elapsed}", loadStopwatch.Elapsed);

        if (databaseDirectory is not null)
        {
            schema = await ApplyDatabaseFilesAsync(schema, databaseDirectory, cancellationToken).ConfigureAwait(false);
        }
        else
        {
            _logger.LogInformation("No local database folder found for {Database}; skipping file overrides", connection.Database);
        }

        await SaveSchemaResultAsync(schema, cancellationToken).ConfigureAwait(false);
        await WriteToCacheAsync(cacheKey, schema, signature, cancellationToken).ConfigureAwait(false);

        return new SchemaWithSignature(schema, signature);
    }

    private static string ComputeDatabaseDirectorySignature(string? databaseDirectory)
    {
        if (string.IsNullOrWhiteSpace(databaseDirectory) || !Directory.Exists(databaseDirectory))
        {
            return "none";
        }

        var builder = new StringBuilder();
        foreach (var file in Directory.EnumerateFiles(databaseDirectory, "*.sql", SearchOption.TopDirectoryOnly).OrderBy(f => f))
        {
            var info = new FileInfo(file);
            builder.Append(info.Name)
                .Append('|')
                .Append(info.Length)
                .Append('|')
                .Append(info.LastWriteTimeUtc.Ticks)
                .Append(';');
        }

        var bytes = Encoding.UTF8.GetBytes(builder.ToString());
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash);
    }

    private async Task<DatabaseSchema> LoadDatabaseSchemaAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        var schemas = await LoadSchemasAsync(connection, cancellationToken).ConfigureAwait(false);
        return new DatabaseSchema
        {
            Connection = connection.ConnectionString,
            Schemas = schemas
        };
    }

    private async Task<IReadOnlyList<SchemaInfo>> LoadSchemasAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string schemaSql = "SELECT schema_id, name FROM sys.schemas WHERE schema_id < 16384 ORDER BY name";
        var schemaNames = await ReadSchemasAsync(connection, schemaSql, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 1);

        var columns = await LoadColumnsAsync(connection, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 2);

        var tableLookup = await LoadTablesAsync(connection, columns, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 3);

        var viewLookup = await LoadViewsAsync(connection, columns, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 4);

        var storedProcedures = await LoadStoredProceduresAsync(connection, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 5);

        var functions = await LoadFunctionsAsync(connection, cancellationToken).ConfigureAwait(false);
        LogProgress(connection, 6);

        return schemaNames
            .Select(schema => new SchemaInfo
            {
                Name = schema.Name,
                Tables = tableLookup.GetValueOrDefault(schema.Id, Array.Empty<TableInfo>()),
                Views = viewLookup.GetValueOrDefault(schema.Id, Array.Empty<ViewInfo>()),
                StoredProcedures = storedProcedures.GetValueOrDefault(schema.Id, Array.Empty<StoredProcedureInfo>()),
                Functions = functions.GetValueOrDefault(schema.Id, Array.Empty<FunctionInfo>())
            })
            .ToArray();
    }

    private static async Task<List<(int Id, string Name)>> ReadSchemasAsync(SqlConnection connection, string sql, CancellationToken cancellationToken)
    {
        var schemaNames = new List<(int Id, string Name)>();

        await using var command = CreateCommand(connection, sql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            schemaNames.Add((reader.GetInt32(0), reader.GetString(1)));
        }

        return schemaNames;
    }

    private static async Task<Dictionary<int, IReadOnlyList<TableInfo>>> LoadTablesAsync(
        SqlConnection connection,
        IReadOnlyDictionary<int, IReadOnlyList<ColumnInfo>> columns,
        CancellationToken cancellationToken)
    {
        const string tableSql = "SELECT t.object_id, t.schema_id, t.name FROM sys.tables AS t WHERE t.is_ms_shipped = 0 ORDER BY t.name";
        var tables = new List<(int ObjectId, int SchemaId, string Name)>();

        await using (var command = CreateCommand(connection, tableSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                tables.Add((reader.GetInt32(0), reader.GetInt32(1), reader.GetString(2)));
            }
        }

        var primaryKeys = await LoadPrimaryKeysAsync(connection, cancellationToken).ConfigureAwait(false);
        var foreignKeys = await LoadForeignKeysAsync(connection, cancellationToken).ConfigureAwait(false);
        var indexes = await LoadIndexesAsync(connection, cancellationToken).ConfigureAwait(false);

        return tables
            .GroupBy(t => t.SchemaId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<TableInfo>)g
                    .Select(t => new TableInfo
                    {
                        Name = t.Name,
                        Columns = columns.GetValueOrDefault(t.ObjectId, Array.Empty<ColumnInfo>()),
                        PrimaryKey = primaryKeys.GetValueOrDefault(t.ObjectId),
                        ForeignKeys = foreignKeys.GetValueOrDefault(t.ObjectId, Array.Empty<ForeignKeyInfo>()),
                        Indexes = indexes.GetValueOrDefault(t.ObjectId, Array.Empty<IndexInfo>())
                    })
                    .ToArray());
    }

    private static async Task<Dictionary<int, IReadOnlyList<ColumnInfo>>> LoadColumnsAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string columnSql = @"SELECT c.object_id, c.name, t.name AS data_type, c.is_nullable, OBJECT_DEFINITION(c.default_object_id) AS default_value, c.is_identity, c.is_computed, c.max_length, c.precision, c.scale FROM sys.columns AS c JOIN sys.types AS t ON c.user_type_id = t.user_type_id WHERE ISNULL(COLUMNPROPERTY(c.object_id, c.name, 'IsHidden'), 0) = 0 ORDER BY c.column_id";

        var lookup = new Dictionary<int, List<ColumnInfo>>();
        await using var command = CreateCommand(connection, columnSql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            var objectId = reader.GetInt32(0);
            if (!lookup.TryGetValue(objectId, out var list))
            {
                list = new List<ColumnInfo>();
                lookup[objectId] = list;
            }

            list.Add(new ColumnInfo
            {
                Name = reader.GetString(1),
                DataType = reader.GetString(2),
                IsNullable = reader.GetBoolean(3),
                DefaultValue = reader.IsDBNull(4) ? null : reader.GetString(4),
                IsIdentity = reader.GetBoolean(5),
                IsComputed = reader.GetBoolean(6),
                MaxLength = reader.IsDBNull(7) ? null : Convert.ToInt32(reader.GetInt16(7)),
                Precision = reader.IsDBNull(8) ? null : reader.GetByte(8),
                Scale = reader.IsDBNull(9) ? null : Convert.ToInt32(reader.GetByte(9))
            });
        }

        return lookup.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<ColumnInfo>)kvp.Value.ToArray());
    }

    private DatabaseSchema? TryPromoteLegacyCache(string cached, string cacheKey, string signature)
    {
        try
        {
            var legacy = JsonSerializer.Deserialize<DatabaseSchema>(cached, SerializerOptions);
            if (legacy is null)
            {
                _logger.LogInformation("Legacy cache entry for {CacheKey} could not be read; ignoring", cacheKey);
                return null;
            }

            _logger.LogInformation("Promoting legacy cached schema for {CacheKey} to signed envelope", cacheKey);
            AddToMemoryCache(cacheKey, signature, legacy);

            // Fire and forget upgrade; callers already received the schema from memory.
            _ = WriteToCacheAsync(cacheKey, legacy, signature, CancellationToken.None);

            return legacy;
        }
        catch (Exception ex)
        {
            _logger.LogInformation(ex, "Legacy cache entry for {CacheKey} is invalid; ignoring", cacheKey);
            return null;
        }
    }

    private static async Task<Dictionary<int, PrimaryKeyInfo>> LoadPrimaryKeysAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string primaryKeySql = @"SELECT i.object_id, i.name, c.name AS column_name FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id WHERE i.is_primary_key = 1 ORDER BY ic.key_ordinal";

        var lookup = new Dictionary<int, PrimaryKeyInfoBuilder>();
        await using var command = CreateCommand(connection, primaryKeySql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            var objectId = reader.GetInt32(0);
            var name = reader.GetString(1);
            var column = reader.GetString(2);

            if (!lookup.TryGetValue(objectId, out var builder))
            {
                builder = new PrimaryKeyInfoBuilder(name);
                lookup[objectId] = builder;
            }

            builder.Columns.Add(column);
        }

        return lookup.ToDictionary(kvp => kvp.Key, kvp => kvp.Value.Build());
    }

    private sealed class PrimaryKeyInfoBuilder
    {
        public PrimaryKeyInfoBuilder(string name) => Name = name;

        public string Name { get; }

        public List<string> Columns { get; } = [];

        public PrimaryKeyInfo Build() => new() { Name = Name, Columns = Columns.ToArray() };
    }

    private static async Task<Dictionary<int, IReadOnlyList<ForeignKeyInfo>>> LoadForeignKeysAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string foreignKeySql = @"SELECT fk.object_id, fk.name, fk.parent_object_id, fk.referenced_object_id, fkc.parent_column_id, fkc.referenced_column_id FROM sys.foreign_keys AS fk INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id ORDER BY fkc.constraint_column_id";
        var tableNames = await LoadFullTableNamesAsync(connection, cancellationToken).ConfigureAwait(false);

        var grouped = new Dictionary<int, ForeignKeyBuilder>();
        await using var command = CreateCommand(connection, foreignKeySql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            var fkObjectId = reader.GetInt32(0);
            var name = reader.GetString(1);
            var parentObjectId = reader.GetInt32(2);
            var referencedObjectId = reader.GetInt32(3);
            var parentColumnId = reader.GetInt32(4);
            var referencedColumnId = reader.GetInt32(5);

            if (!grouped.TryGetValue(fkObjectId, out var builder))
            {
                builder = new ForeignKeyBuilder(name, parentObjectId, referencedObjectId);
                grouped[fkObjectId] = builder;
            }

            builder.ColumnPairs.Add((parentColumnId, referencedColumnId));
        }

        var columnLookup = await LoadColumnNamesByIdAsync(connection, cancellationToken).ConfigureAwait(false);

        var result = new Dictionary<int, List<ForeignKeyInfo>>();
        foreach (var fk in grouped.Values)
        {
            var parentTableId = fk.ParentObjectId;
            if (!result.TryGetValue(parentTableId, out var list))
            {
                list = new List<ForeignKeyInfo>();
                result[parentTableId] = list;
            }

            list.Add(new ForeignKeyInfo
            {
                Name = fk.Name,
                ReferencedTable = tableNames.GetValueOrDefault(fk.ReferencedObjectId, string.Empty),
                Columns = fk.ColumnPairs
                    .Select(pair => new ForeignKeyColumn
                    {
                        Column = columnLookup.GetValueOrDefault((fk.ParentObjectId, pair.ParentColumnId), string.Empty),
                        ReferencedColumn = columnLookup.GetValueOrDefault((fk.ReferencedObjectId, pair.ReferencedColumnId), string.Empty)
                    })
                    .ToArray()
            });
        }

        return result.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<ForeignKeyInfo>)kvp.Value.ToArray());
    }

    private sealed class ForeignKeyBuilder
    {
        public ForeignKeyBuilder(string name, int parentObjectId, int referencedObjectId)
        {
            Name = name;
            ParentObjectId = parentObjectId;
            ReferencedObjectId = referencedObjectId;
        }

        public string Name { get; }

        public int ParentObjectId { get; }

        public int ReferencedObjectId { get; }

        public List<(int ParentColumnId, int ReferencedColumnId)> ColumnPairs { get; } = [];
    }

    private static async Task<Dictionary<int, IReadOnlyList<IndexInfo>>> LoadIndexesAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string indexSql = @"SELECT i.object_id, i.index_id, i.name, i.is_unique, i.is_primary_key, ic.is_included_column, c.name AS column_name, ic.key_ordinal, i.filter_definition FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id WHERE i.is_hypothetical = 0 AND i.is_disabled = 0 ORDER BY i.object_id, i.index_id, ic.key_ordinal";

        var builders = new Dictionary<(int ObjectId, int IndexId), IndexBuilder>();
        await using var command = CreateCommand(connection, indexSql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            var objectId = reader.GetInt32(0);
            var indexId = reader.GetInt32(1);
            var name = reader.GetString(2);
            var isUnique = reader.GetBoolean(3);
            var isPrimaryKey = reader.GetBoolean(4);
            var isIncluded = reader.GetBoolean(5);
            var columnName = reader.GetString(6);
            var filter = reader.IsDBNull(8) ? null : reader.GetString(8);

            var key = (objectId, indexId);
            if (!builders.TryGetValue(key, out var builder))
            {
                builder = new IndexBuilder(name, isUnique, isPrimaryKey, filter);
                builders[key] = builder;
            }

            if (isIncluded)
            {
                builder.IncludedColumns.Add(columnName);
            }
            else
            {
                builder.Columns.Add(columnName);
            }
        }

        var groupedByTable = new Dictionary<int, List<IndexInfo>>();
        foreach (var kvp in builders)
        {
            if (!groupedByTable.TryGetValue(kvp.Key.ObjectId, out var list))
            {
                list = new List<IndexInfo>();
                groupedByTable[kvp.Key.ObjectId] = list;
            }

            list.Add(kvp.Value.Build());
        }

        return groupedByTable.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<IndexInfo>)kvp.Value.ToArray());
    }

    private sealed class IndexBuilder
    {
        public IndexBuilder(string name, bool isUnique, bool isPrimaryKey, string? filter)
        {
            Name = name;
            IsUnique = isUnique;
            IsPrimaryKey = isPrimaryKey;
            Filter = filter;
        }

        public string Name { get; }

        public bool IsUnique { get; }

        public bool IsPrimaryKey { get; }

        public List<string> Columns { get; } = [];

        public List<string> IncludedColumns { get; } = [];

        public string? Filter { get; }

        public IndexInfo Build() => new()
        {
            Name = Name,
            IsUnique = IsUnique,
            IsPrimaryKey = IsPrimaryKey,
            Columns = Columns.ToArray(),
            IncludedColumns = IncludedColumns.ToArray(),
            FilterDefinition = Filter
        };
    }

    private static async Task<Dictionary<int, IReadOnlyList<ViewInfo>>> LoadViewsAsync(
        SqlConnection connection,
        IReadOnlyDictionary<int, IReadOnlyList<ColumnInfo>> columns,
        CancellationToken cancellationToken)
    {
        const string viewSql = "SELECT v.object_id, v.schema_id, v.name, OBJECT_DEFINITION(v.object_id) AS definition FROM sys.views AS v WHERE v.is_ms_shipped = 0";
        var views = new List<(int ObjectId, int SchemaId, string Name, string Definition)>();

        await using (var command = CreateCommand(connection, viewSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                views.Add((reader.GetInt32(0), reader.GetInt32(1), reader.GetString(2), reader.IsDBNull(3) ? string.Empty : reader.GetString(3)));
            }
        }

        return views
            .GroupBy(v => v.SchemaId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<ViewInfo>)g
                    .Select(v => new ViewInfo
                    {
                        Name = v.Name,
                        Definition = v.Definition,
                        Columns = columns.GetValueOrDefault(v.ObjectId, Array.Empty<ColumnInfo>())
                    })
                    .ToArray());
    }

    private static async Task<Dictionary<int, IReadOnlyList<StoredProcedureInfo>>> LoadStoredProceduresAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string procedureSql = "SELECT p.object_id, p.schema_id, p.name, OBJECT_DEFINITION(p.object_id) AS definition FROM sys.procedures AS p WHERE p.is_ms_shipped = 0";
        var procedures = new List<(int ObjectId, int SchemaId, string Name, string Definition)>();

        await using (var command = CreateCommand(connection, procedureSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                procedures.Add((reader.GetInt32(0), reader.GetInt32(1), reader.GetString(2), reader.IsDBNull(3) ? string.Empty : reader.GetString(3)));
            }
        }

        var parameters = await LoadParametersAsync(connection, cancellationToken).ConfigureAwait(false);

        return procedures
            .GroupBy(p => p.SchemaId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<StoredProcedureInfo>)g
                    .Select(p => new StoredProcedureInfo
                    {
                        Name = p.Name,
                        Definition = p.Definition,
                        Parameters = parameters.GetValueOrDefault(p.ObjectId, Array.Empty<ParameterInfo>())
                    })
                    .ToArray());
    }

    private static async Task<Dictionary<int, IReadOnlyList<FunctionInfo>>> LoadFunctionsAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string functionSql = "SELECT o.object_id, o.schema_id, o.name, OBJECT_DEFINITION(o.object_id) AS definition FROM sys.objects AS o WHERE o.type IN ('FN','IF','TF','FS','FT') AND o.is_ms_shipped = 0";
        var functions = new List<(int ObjectId, int SchemaId, string Name, string Definition)>();

        await using (var command = CreateCommand(connection, functionSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                functions.Add((reader.GetInt32(0), reader.GetInt32(1), reader.GetString(2), reader.IsDBNull(3) ? string.Empty : reader.GetString(3)));
            }
        }

        var parameters = await LoadParametersAsync(connection, cancellationToken).ConfigureAwait(false);
        var returnTypes = await LoadFunctionReturnTypesAsync(connection, cancellationToken).ConfigureAwait(false);

        return functions
            .GroupBy(f => f.SchemaId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<FunctionInfo>)g
                    .Select(f => new FunctionInfo
                    {
                        Name = f.Name,
                        Definition = f.Definition,
                        ReturnType = returnTypes.GetValueOrDefault(f.ObjectId, string.Empty),
                        Parameters = parameters.GetValueOrDefault(f.ObjectId, Array.Empty<ParameterInfo>())
                    })
                    .ToArray());
    }

    private static async Task<Dictionary<int, string>> LoadFunctionReturnTypesAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string returnTypeSql = @"SELECT p.object_id, t.name AS return_type FROM sys.parameters AS p INNER JOIN sys.types AS t ON p.user_type_id = t.user_type_id WHERE p.parameter_id = 0";
        var map = new Dictionary<int, string>();

        await using (var command = CreateCommand(connection, returnTypeSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                map[reader.GetInt32(0)] = reader.IsDBNull(1) ? string.Empty : reader.GetString(1);
            }
        }

        return map;
    }

    private static async Task<Dictionary<int, IReadOnlyList<ParameterInfo>>> LoadParametersAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string parameterSql = "SELECT p.object_id, p.parameter_id, p.name, t.name AS data_type, p.is_output, p.has_default_value, p.is_nullable, p.max_length, p.precision, p.scale FROM sys.parameters AS p INNER JOIN sys.types AS t ON p.user_type_id = t.user_type_id WHERE p.parameter_id > 0 ORDER BY p.parameter_id";

        var lookup = new Dictionary<int, List<ParameterInfo>>();
        await using var command = CreateCommand(connection, parameterSql);
        await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false);

        while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            var objectId = reader.GetInt32(0);
            if (!lookup.TryGetValue(objectId, out var list))
            {
                list = new List<ParameterInfo>();
                lookup[objectId] = list;
            }

            list.Add(new ParameterInfo
            {
                Name = reader.GetString(2),
                DataType = reader.GetString(3),
                IsOutput = reader.GetBoolean(4),
                DefaultValue = reader.GetBoolean(5) ? "DEFAULT" : null,
                IsNullable = reader.GetBoolean(6),
                MaxLength = reader.IsDBNull(7) ? null : Convert.ToInt32(reader.GetInt16(7)),
                Precision = reader.IsDBNull(8) ? null : reader.GetByte(8),
                Scale = reader.IsDBNull(9) ? null : Convert.ToInt32(reader.GetByte(9))
            });
        }

        return lookup.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<ParameterInfo>)kvp.Value.ToArray());
    }

    private static async Task<Dictionary<(int ObjectId, int ColumnId), string>> LoadColumnNamesByIdAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string columnSql = "SELECT object_id, column_id, name FROM sys.columns WHERE ISNULL(COLUMNPROPERTY(object_id, name, 'IsHidden'), 0) = 0";
        var map = new Dictionary<(int, int), string>();

        await using (var command = CreateCommand(connection, columnSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                map[(reader.GetInt32(0), reader.GetInt32(1))] = reader.GetString(2);
            }
        }

        return map;
    }

    private static async Task<Dictionary<int, string>> LoadFullTableNamesAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string tableSql = "SELECT t.object_id, s.name + '.' + t.name FROM sys.tables AS t INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id";
        var map = new Dictionary<int, string>();

        await using (var command = CreateCommand(connection, tableSql))
        await using (var reader = await command.ExecuteReaderAsync(CommandBehavior.SequentialAccess, cancellationToken).ConfigureAwait(false))
        {
            while (await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
            {
                map[reader.GetInt32(0)] = reader.GetString(1);
            }
        }

        return map;
    }

    private static SqlCommand CreateCommand(SqlConnection connection, string sql)
    {
        return new SqlCommand(sql, connection)
        {
            CommandTimeout = 60
        };
    }

    private static string ResolveSolutionRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        const string solutionFile = "GeneratorFromDatabase.sln";

        while (current is not null && current.Exists)
        {
            var candidate = Path.Combine(current.FullName, solutionFile);
            if (File.Exists(candidate))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return AppContext.BaseDirectory;
    }

    private static string? ResolveDatabaseDirectory(string databaseName)
    {
        if (string.IsNullOrWhiteSpace(databaseName))
        {
            return null;
        }

        var folder = Path.Combine(AppContext.BaseDirectory, "databases", databaseName);
        return Directory.Exists(folder) ? folder : null;
    }

    private async Task<DatabaseSchema> ApplyDatabaseFilesAsync(DatabaseSchema schema, string databaseDirectory, CancellationToken cancellationToken)
    {
        var definitions = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var file in Directory.EnumerateFiles(databaseDirectory, "*.sql", SearchOption.TopDirectoryOnly))
        {
            var name = Path.GetFileNameWithoutExtension(file);
            var content = await File.ReadAllTextAsync(file, cancellationToken).ConfigureAwait(false);
            definitions[name] = content;
        }

        _logger.LogInformation(
            "Applying {Count} local definition files from {Directory} to schema for {Database}",
            definitions.Count,
            databaseDirectory,
            schema.Connection);

        var schemas = schema.Schemas
            .Select(s => UpdateSchemaFromFiles(s, definitions))
            .ToArray();

        return new DatabaseSchema
        {
            Connection = schema.Connection,
            Schemas = schemas
        };
    }

    private static SchemaInfo UpdateSchemaFromFiles(SchemaInfo schema, IReadOnlyDictionary<string, string> definitions)
    {
        var views = schema.Views
            .Select(v => UpdateView(v, schema.Name, definitions))
            .ToArray();

        var storedProcedures = schema.StoredProcedures
            .Select(p => UpdateStoredProcedure(p, schema.Name, definitions))
            .ToArray();

        var functions = schema.Functions
            .Select(f => UpdateFunction(f, schema.Name, definitions))
            .ToArray();

        return new SchemaInfo
        {
            Name = schema.Name,
            Tables = schema.Tables,
            Views = views,
            StoredProcedures = storedProcedures,
            Functions = functions
        };
    }

    private static ViewInfo UpdateView(ViewInfo view, string schemaName, IReadOnlyDictionary<string, string> definitions)
    {
        var key = $"{schemaName}.{view.Name}";
        if (!definitions.TryGetValue(key, out var definition))
        {
            return view;
        }

        return new ViewInfo
        {
            Name = view.Name,
            Definition = definition,
            Columns = view.Columns
        };
    }

    private static StoredProcedureInfo UpdateStoredProcedure(StoredProcedureInfo procedure, string schemaName, IReadOnlyDictionary<string, string> definitions)
    {
        var key = $"{schemaName}.{procedure.Name}";
        if (!definitions.TryGetValue(key, out var definition))
        {
            return procedure;
        }

        var parameters = ParseParameters(definition, procedure.Parameters, isFunction: false);

        return new StoredProcedureInfo
        {
            Name = procedure.Name,
            Definition = definition,
            Parameters = parameters
        };
    }

    private static FunctionInfo UpdateFunction(FunctionInfo function, string schemaName, IReadOnlyDictionary<string, string> definitions)
    {
        var key = $"{schemaName}.{function.Name}";
        if (!definitions.TryGetValue(key, out var definition))
        {
            return function;
        }

        var parameters = ParseParameters(definition, function.Parameters, isFunction: true);

        return new FunctionInfo
        {
            Name = function.Name,
            Definition = definition,
            ReturnType = function.ReturnType,
            Parameters = parameters
        };
    }

    private static IReadOnlyList<ParameterInfo> ParseParameters(string definition, IReadOnlyList<ParameterInfo> existingParameters, bool isFunction)
    {
        var parsed = ParameterParser.Parse(definition, isFunction);
        if (parsed.Count == 0)
        {
            return existingParameters;
        }

        var existingLookup = existingParameters.ToDictionary(p => NormalizeParameterName(p.Name), p => p, StringComparer.OrdinalIgnoreCase);

        var merged = new List<ParameterInfo>();
        foreach (var param in parsed)
        {
            existingLookup.TryGetValue(NormalizeParameterName(param.Name), out var existing);
            merged.Add(param.Merge(existing));
        }

        return merged;
    }

    private static string NormalizeParameterName(string name)
    {
        var normalized = name.Trim();
        if (normalized.StartsWith("@", StringComparison.Ordinal))
        {
            normalized = normalized[1..];
        }

        return normalized.Trim('[', ']');
    }

    private sealed record ParsedParameter(
        string Name,
        string? DataType,
        bool? IsOutput,
        bool? IsNullable,
        int? MaxLength,
        byte? Precision,
        int? Scale,
        string? DefaultValue)
    {
        public ParameterInfo Merge(ParameterInfo? existing)
        {
            return new ParameterInfo
            {
                Name = FormatName(Name),
                DataType = DataType ?? existing?.DataType ?? string.Empty,
                IsOutput = IsOutput ?? existing?.IsOutput ?? false,
                IsNullable = IsNullable ?? existing?.IsNullable ?? false,
                MaxLength = MaxLength ?? existing?.MaxLength,
                Precision = Precision ?? existing?.Precision,
                Scale = Scale ?? existing?.Scale,
                DefaultValue = DefaultValue ?? existing?.DefaultValue
            };
        }

        private static string FormatName(string name)
        {
            var formatted = name.Trim();
            if (!formatted.StartsWith("@", StringComparison.Ordinal))
            {
                formatted = "@" + formatted;
            }

            return formatted.Trim('[', ']');
        }
    }

    private static class ParameterParser
    {
        public static List<ParsedParameter> Parse(string definition, bool isFunction)
        {
            var cleanedDefinition = RemoveSqlComments(definition);

            var header = isFunction
                ? ExtractFunctionHeader(cleanedDefinition)
                : ExtractProcedureHeader(cleanedDefinition);

            if (header is null)
            {
                return [];
            }

            var parametersText = CleanupHeader(header);
            var segments = SplitParameters(parametersText);

            return segments
                .Select(ParseSegment)
                .Where(p => p is not null)
                .Select(p => p!)
                .ToList();
        }

        private static string? ExtractProcedureHeader(string definition)
        {
            var match = Regex.Match(definition, "(?is)\\b(?:create|alter)\\s+proc(?:edure)?\\s+[\\w\\.\\[\\]]+\\s*(?<params>.*?)(?=^\\s*as\\b)", RegexOptions.Multiline);
            return match.Success ? match.Groups["params"].Value : null;
        }

        private static string? ExtractFunctionHeader(string definition)
        {
            var match = Regex.Match(definition, "(?is)\\b(?:create|alter)\\s+function\\s+[\\w\\.\\[\\]]+\\s*(?<params>\\(.*?\\))\\s*(?=returns)");
            return match.Success ? match.Groups["params"].Value : null;
        }

        private static string CleanupHeader(string header)
        {
            var cleaned = header.Trim();

            if (cleaned.StartsWith("(", StringComparison.Ordinal))
            {
                var depth = 0;
                for (var i = 0; i < cleaned.Length; i++)
                {
                    var ch = cleaned[i];
                    if (ch == '(')
                    {
                        depth++;
                    }
                    else if (ch == ')')
                    {
                        depth = Math.Max(0, depth - 1);
                        if (depth == 0)
                        {
                            return cleaned[1..i].Trim();
                        }
                    }
                }
            }

            return cleaned.Trim('(', ')');
        }

        private static string RemoveSqlComments(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return text;
            }

            var withoutBlockComments = Regex.Replace(text, "/\\*.*?\\*/", string.Empty, RegexOptions.Singleline);
            return Regex.Replace(withoutBlockComments, "--.*?$", string.Empty, RegexOptions.Multiline);
        }

        private static List<string> SplitParameters(string header)
        {
            var parameters = new List<string>();
            var builder = new StringBuilder();
            var depth = 0;

            foreach (var ch in header)
            {
                if (ch == '(')
                {
                    depth++;
                }
                else if (ch == ')')
                {
                    depth = Math.Max(0, depth - 1);
                }

                if (ch == ',' && depth == 0)
                {
                    parameters.Add(builder.ToString());
                    builder.Clear();
                    continue;
                }

                builder.Append(ch);
            }

            if (builder.Length > 0)
            {
                parameters.Add(builder.ToString());
            }

            return parameters
                .Select(p => p.Trim())
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .ToList();
        }

        private static ParsedParameter? ParseSegment(string segment)
        {
            var trimmed = segment.Trim();
            if (!trimmed.Contains('@'))
            {
                return null;
            }

            var isOutput = Regex.IsMatch(trimmed, "\\b(out|output)\\b", RegexOptions.IgnoreCase);

            var defaultIndex = FindAssignmentIndex(trimmed);
            string? defaultValue = null;
            if (defaultIndex >= 0)
            {
                defaultValue = trimmed[(defaultIndex + 1)..].Trim();
                defaultValue = Regex.Replace(defaultValue, "\\b(out|output)\\b", string.Empty, RegexOptions.IgnoreCase).Trim();
            }

            var withoutDefault = defaultIndex >= 0 ? trimmed[..defaultIndex] : trimmed;
            var withoutOutput = Regex.Replace(withoutDefault, "\\b(out|output)\\b", string.Empty, RegexOptions.IgnoreCase).Trim();

            var nameEnd = withoutOutput.IndexOfAny([' ', '\t', '\r', '\n']);
            var name = nameEnd >= 0 ? withoutOutput[..nameEnd] : withoutOutput;
            var typeAndModifiers = nameEnd >= 0 ? withoutOutput[nameEnd..].Trim() : string.Empty;

            var (dataType, maxLength, precision, scale, isNullable) = ParseType(typeAndModifiers, defaultValue);

            return new ParsedParameter(name, dataType, isOutput, isNullable, maxLength, precision, scale, defaultValue);
        }

        private static int FindAssignmentIndex(string segment)
        {
            var depth = 0;
            for (var i = 0; i < segment.Length; i++)
            {
                var ch = segment[i];
                if (ch == '(')
                {
                    depth++;
                }
                else if (ch == ')')
                {
                    depth = Math.Max(0, depth - 1);
                }
                else if (ch == '=' && depth == 0)
                {
                    return i;
                }
            }

            return -1;
        }

        private static (string? DataType, int? MaxLength, byte? Precision, int? Scale, bool? IsNullable) ParseType(string typeAndModifiers, string? defaultValue)
        {
            if (string.IsNullOrWhiteSpace(typeAndModifiers))
            {
                return (null, null, null, null, null);
            }

            var nullable = default(bool?);
            if (Regex.IsMatch(typeAndModifiers, "\\bNOT\\s+NULL\\b", RegexOptions.IgnoreCase))
            {
                nullable = false;
            }
            else if (Regex.IsMatch(typeAndModifiers, "\\bNULL\\b", RegexOptions.IgnoreCase) || string.Equals(defaultValue, "NULL", StringComparison.OrdinalIgnoreCase))
            {
                nullable = true;
            }

            var cleanedType = Regex.Replace(typeAndModifiers, "\\bNOT\\s+NULL\\b|\\bNULL\\b|\\bREADONLY\\b", string.Empty, RegexOptions.IgnoreCase).Trim();

            int? maxLength = null;
            byte? precision = null;
            int? scale = null;
            string? dataType = cleanedType;

            var openParenIndex = cleanedType.IndexOf('(');
            if (openParenIndex >= 0)
            {
                var closeParenIndex = cleanedType.IndexOf(')', openParenIndex + 1);
                if (closeParenIndex > openParenIndex)
                {
                    var typeName = cleanedType[..openParenIndex].Trim();
                    var inner = cleanedType[(openParenIndex + 1)..closeParenIndex];
                    var parts = inner.Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);

                    if (parts.Length == 1)
                    {
                        if (int.TryParse(parts[0], out var len))
                        {
                            maxLength = len;
                        }
                    }
                    else if (parts.Length >= 2)
                    {
                        if (byte.TryParse(parts[0], out var prec))
                        {
                            precision = prec;
                        }

                        if (int.TryParse(parts[1], out var sc))
                        {
                            scale = sc;
                        }
                    }

                    dataType = typeName;
                }
            }

            return (dataType, maxLength, precision, scale, nullable);
        }
    }

    private sealed record SchemaWithSignature(DatabaseSchema Schema, string Signature);

    private sealed class CachedSchemaEnvelope
    {
        public required DatabaseSchema Schema { get; init; }

        public required string Signature { get; init; }
    }

    private void LogProgress(SqlConnection connection, int stepIndex)
    {
        var total = LoadSteps.Length;
        var name = stepIndex > 0 && stepIndex <= total ? LoadSteps[stepIndex - 1] : $"Step {stepIndex}";
        var percent = (int)Math.Round(stepIndex / (double)total * 100, MidpointRounding.AwayFromZero);

        _logger.LogInformation(
            "Schema load progress for {Database}: step {Step}/{Total} ({Percent}%) - {Name}",
            connection.Database,
            stepIndex,
            total,
            percent,
            name);
    }

    private async Task SaveSchemaResultAsync(DatabaseSchema schema, CancellationToken cancellationToken)
    {
        try
        {
            var directory = Path.GetDirectoryName(SchemaResultFilePath);
            if (!string.IsNullOrWhiteSpace(directory))
            {
                Directory.CreateDirectory(directory);
            }

            var serialized = JsonSerializer.Serialize(schema, SerializerOptions);
            await File.WriteAllTextAsync(SchemaResultFilePath, serialized, cancellationToken).ConfigureAwait(false);
            _logger.LogInformation("Schema written to {Path}", SchemaResultFilePath);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to write schema result to file {Path}", SchemaResultFilePath);
        }
    }
}
