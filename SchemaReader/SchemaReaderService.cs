using System.Data;
using System.Text.Json;
using Microsoft.Data.SqlClient;

namespace SchemaReader;

public sealed class SchemaReaderService : ISchemaReader
{
    public async Task<string> ReadSchemaAsync(string connectionString, CancellationToken cancellationToken = default)
    {
        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync(cancellationToken).ConfigureAwait(false);

        var schema = await LoadDatabaseSchemaAsync(connection, cancellationToken).ConfigureAwait(false);
        return JsonSerializer.Serialize(schema, new JsonSerializerOptions { WriteIndented = true });
    }

    private static async Task<DatabaseSchema> LoadDatabaseSchemaAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        var schemas = await LoadSchemasAsync(connection, cancellationToken).ConfigureAwait(false);
        return new DatabaseSchema
        {
            Connection = connection.ConnectionString,
            Schemas = schemas
        };
    }

    private static async Task<IReadOnlyList<SchemaInfo>> LoadSchemasAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string schemaSql = "SELECT schema_id, name FROM sys.schemas WHERE schema_id < 16384 ORDER BY name";
        var schemaNames = await ReadSchemasAsync(connection, schemaSql, cancellationToken).ConfigureAwait(false);

        var tableLookup = await LoadTablesAsync(connection, cancellationToken).ConfigureAwait(false);
        var viewLookup = await LoadViewsAsync(connection, cancellationToken).ConfigureAwait(false);
        var storedProcedures = await LoadStoredProceduresAsync(connection, cancellationToken).ConfigureAwait(false);
        var functions = await LoadFunctionsAsync(connection, cancellationToken).ConfigureAwait(false);

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

    private static async Task<Dictionary<int, IReadOnlyList<TableInfo>>> LoadTablesAsync(SqlConnection connection, CancellationToken cancellationToken)
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

        var columns = await LoadColumnsAsync(connection, cancellationToken).ConfigureAwait(false);
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
        const string columnSql = @"SELECT c.object_id, c.name, t.name AS data_type, c.is_nullable, OBJECT_DEFINITION(c.default_object_id) AS default_value, c.is_identity, c.is_computed, c.max_length, c.precision, c.scale FROM sys.columns AS c JOIN sys.types AS t ON c.user_type_id = t.user_type_id WHERE c.is_hidden = 0 ORDER BY c.column_id";

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
                Scale = reader.IsDBNull(9) ? null : reader.GetInt32(9)
            });
        }

        return lookup.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<ColumnInfo>)kvp.Value.ToArray());
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

    private static async Task<Dictionary<int, IReadOnlyList<ViewInfo>>> LoadViewsAsync(SqlConnection connection, CancellationToken cancellationToken)
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

        var columns = await LoadColumnsAsync(connection, cancellationToken).ConfigureAwait(false);

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
                Scale = reader.IsDBNull(9) ? null : reader.GetInt32(9)
            });
        }

        return lookup.ToDictionary(kvp => kvp.Key, kvp => (IReadOnlyList<ParameterInfo>)kvp.Value.ToArray());
    }

    private static async Task<Dictionary<(int ObjectId, int ColumnId), string>> LoadColumnNamesByIdAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        const string columnSql = "SELECT object_id, column_id, name FROM sys.columns WHERE is_hidden = 0";
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
}
