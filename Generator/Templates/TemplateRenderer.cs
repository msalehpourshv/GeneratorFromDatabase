using System.Linq;
using System.Text;
using Generator.Metadata;
using System;

namespace Generator.Templates;

internal sealed class TemplateRenderer
{
    private readonly string _projectName;

    public TemplateRenderer(string projectName)
    {
        _projectName = projectName;
    }

    public async Task RenderAsync(TemplateMetadata metadata, string projectRoot, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(metadata);

        Directory.CreateDirectory(projectRoot);

        await WriteProjectFileAsync(projectRoot, cancellationToken).ConfigureAwait(false);
        await WriteDomainSharedAsync(projectRoot, cancellationToken).ConfigureAwait(false);
        await WriteApplicationSharedAsync(projectRoot, cancellationToken).ConfigureAwait(false);
        await WriteEntityFrameworkBaseAsync(projectRoot, metadata, cancellationToken).ConfigureAwait(false);
        await WriteStoredProcedureBaseAsync(projectRoot, cancellationToken).ConfigureAwait(false);
        await WriteApplicationDependencyInjectionAsync(projectRoot, metadata, cancellationToken).ConfigureAwait(false);
        await WriteInfrastructureDependencyInjectionAsync(projectRoot, metadata, cancellationToken).ConfigureAwait(false);

        foreach (var entity in metadata.Entities)
        {
            await WriteDomainEntityAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteRepositoryInterfaceAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteKeyRecordAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteDtoAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteServiceInterfaceAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteServiceImplementationAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
            await WriteEfRepositoryAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
        }

        await WriteStoredProcedureRepositoriesAsync(projectRoot, metadata, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteProjectFileAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var content = $$"""
            <Project Sdk="Microsoft.NET.Sdk">
              <PropertyGroup>
                <TargetFramework>net6.0</TargetFramework>
                <Nullable>enable</Nullable>
                <ImplicitUsings>enable</ImplicitUsings>
              </PropertyGroup>
              <ItemGroup>
                <PackageReference Include="Dapper" Version="2.1.24" />
                <PackageReference Include="Microsoft.Data.SqlClient" Version="5.2.1" />
                <PackageReference Include="Microsoft.EntityFrameworkCore" Version="6.0.27" />
                <PackageReference Include="Microsoft.EntityFrameworkCore.Relational" Version="6.0.27" />
                <PackageReference Include="Microsoft.Extensions.DependencyInjection.Abstractions" Version="6.0.0" />
                <PackageReference Include="Microsoft.Extensions.Logging.Abstractions" Version="6.0.0" />
              </ItemGroup>
            </Project>
            """;

        await WriteFileAsync(Path.Combine(projectRoot, $"{_projectName}.csproj"), content, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteDomainSharedAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var contractsDirectory = Path.Combine(projectRoot, "DomainShared", "Contracts");
        Directory.CreateDirectory(contractsDirectory);

        var baseEntityContent = $$"""
            using System.ComponentModel.DataAnnotations.Schema;

            namespace {{_projectName}}.DomainShared.Abstractions;

            [NotMapped]
            public abstract class EntityBase { }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "DomainShared", "Abstractions", "EntityBase.cs"), baseEntityContent, cancellationToken).ConfigureAwait(false);

        var repositoryContent = $$"""
            using System.Linq.Expressions;
            using {{_projectName}}.ApplicationShared.Models;

            namespace {{_projectName}}.DomainShared.Contracts;

            public interface IRepository<TEntity> where TEntity : class
            {
                Task<IEnumerable<TEntity>> GetAllAsync();

                Task<TEntity?> GetByKeysAsync(object filters);

                Task<IEnumerable<TEntity>> QueryAsync(object? filters);

                Task<PagedResult<TEntity>> QueryPagedAsync(object? filters, int page = 1, int pageSize = 50);

                Task<IEnumerable<TEntity>> SearchAsync(string text);

                Task<IEnumerable<TEntity>> FilterRangeAsync(string field, object from, object to);

                Task<IEnumerable<dynamic>> GroupByAsync(string field, object? filters = null);

                Task<dynamic?> AggregateAsync(string field, string function, object? filters = null);

                Task<IEnumerable<TEntity>> TopAsync(string orderBy, int count, object? filters = null);

                Task<bool> ExistsAsync(object filters);

                Task<IEnumerable<dynamic>> RawAsync(string sql, object? parameters = null);

                Task<IEnumerable<dynamic>> ExecuteStoredProcedureAsync(string spName, object? parameters = null);

                IQueryable<TEntity> Query();

                Task<TEntity?> FindAsync(object[] keyValues, CancellationToken cancellationToken = default);

                Task<TEntity?> FirstOrDefaultAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);

                Task AddAsync(TEntity entity, CancellationToken cancellationToken = default);

                Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default);

                Task RemoveAsync(TEntity entity, CancellationToken cancellationToken = default);

                Task SaveChangesAsync(CancellationToken cancellationToken = default);
            }
            """;

        await WriteFileAsync(Path.Combine(contractsDirectory, "IRepository.cs"), repositoryContent, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteApplicationSharedAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var content = $$"""
            namespace {{_projectName}}.ApplicationShared.Models;

            public sealed class PagedResult<T>
            {
                public IReadOnlyList<T> Items { get; init; } = Array.Empty<T>();

                public int TotalCount { get; init; }

                public int PageNumber { get; init; }

                public int PageSize { get; init; }
            }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "ApplicationShared", "Models", "PagedResult.cs"), content, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteEntityFrameworkBaseAsync(string projectRoot, TemplateMetadata metadata, CancellationToken cancellationToken)
    {
        var dbContextContent = BuildDbContext(metadata);
        await WriteFileAsync(Path.Combine(projectRoot, "EntityFramework", "Data", "AppDbContext.cs"), dbContextContent, cancellationToken).ConfigureAwait(false);

        var repositoryBaseContent = $$"""
            using System.Data;
            using System.Diagnostics;
            using System.Linq.Expressions;
            using System.Reflection;
            using Dapper;
            using Microsoft.Data.SqlClient;
            using Microsoft.EntityFrameworkCore;
            using Microsoft.EntityFrameworkCore.Infrastructure;
            using Microsoft.EntityFrameworkCore.Metadata;
            using Microsoft.Extensions.Logging;
            using Microsoft.Extensions.Logging.Abstractions;
            using {{_projectName}}.ApplicationShared.Models;
            using {{_projectName}}.DomainShared.Contracts;

            namespace {{_projectName}}.EntityFramework.Repositories;

            public class EfRepository<TEntity> : IRepository<TEntity> where TEntity : class
            {
                private readonly string? _connectionString;
                private readonly string _tableName;
                private readonly ILogger<EfRepository<TEntity>> _logger;
                private readonly DbSet<TEntity> _set;
                protected readonly DbContext Context;

                public EfRepository(DbContext context)
                {
                    Context = context;
                    _set = Context.Set<TEntity>();
                    _connectionString = Context.Database.GetConnectionString();
                    _tableName = ResolveTableName();
                    _logger = Context.GetService<ILoggerFactory>()?.CreateLogger<EfRepository<TEntity>>()
                              ?? NullLogger<EfRepository<TEntity>>.Instance;
                }

                public async Task<IEnumerable<TEntity>> GetAllAsync()
                {
                    return await ExecuteSafe("GetAll", async () =>
                    {
                        var sql = $"SELECT * FROM {_tableName}";
                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql}", sql);
                        return await connection.QueryAsync<TEntity>(sql).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<TEntity?> GetByKeysAsync(object filters)
                {
                    return await ExecuteSafe("GetByKeys", async () =>
                    {
                        var (whereSql, parameters) = BuildWhereClause(filters, allowEmpty: false);
                        var sql = $"SELECT * FROM {_tableName}{whereSql}";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryFirstOrDefaultAsync<TEntity>(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<TEntity>> QueryAsync(object? filters)
                {
                    return await ExecuteSafe("Query", async () =>
                    {
                        var (whereSql, parameters) = BuildWhereClause(filters);
                        var sql = $"SELECT * FROM {_tableName}{whereSql}";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync<TEntity>(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<PagedResult<TEntity>> QueryPagedAsync(object? filters, int page = 1, int pageSize = 50)
                {
                    return await ExecuteSafe("QueryPaged", async () =>
                    {
                        var (whereSql, parameters) = BuildWhereClause(filters);
                        var defaultOrder = ResolveDefaultOrderBy();

                        var sqlCount = $"SELECT COUNT(1) FROM {_tableName}{whereSql}";
                        var sqlPage =
                            $"SELECT * FROM {_tableName}{whereSql} ORDER BY {defaultOrder} OFFSET {(page - 1) * pageSize} ROWS FETCH NEXT {pageSize} ROWS ONLY";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);

                        var total = await connection.ExecuteScalarAsync<int>(sqlCount, parameters).ConfigureAwait(false);
                        var items = (await connection.QueryAsync<TEntity>(sqlPage, parameters).ConfigureAwait(false)).ToList();

                        return new PagedResult<TEntity>
                        {
                            Items = items,
                            TotalCount = total,
                            PageNumber = page,
                            PageSize = pageSize
                        };
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<TEntity>> SearchAsync(string text)
                {
                    return await ExecuteSafe("Search", async () =>
                    {
                        var (_, stringProps, _, _) = InspectEntity();
                        if (!stringProps.Any())
                        {
                            return Enumerable.Empty<TEntity>();
                        }

                        var like = $"%{text}%";
                        var whereParts = stringProps.Select(p => $"[{p.Name}] LIKE @{p.Name}").ToArray();
                        var sql = $"SELECT * FROM {_tableName} WHERE " + string.Join(" OR ", whereParts);

                        var parameters = new DynamicParameters();
                        foreach (var prop in stringProps)
                        {
                            parameters.Add($"@{prop.Name}", like);
                        }

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync<TEntity>(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<TEntity>> FilterRangeAsync(string field, object from, object to)
                {
                    return await ExecuteSafe("FilterRange", async () =>
                    {
                        var (_, _, numericProps, dateProps) = InspectEntity();
                        var allowed = numericProps.Select(p => p.Name)
                            .Concat(dateProps.Select(p => p.Name))
                            .ToHashSet(StringComparer.OrdinalIgnoreCase);

                        if (!allowed.Contains(field))
                        {
                            throw new ArgumentException($"Field '{field}' is not numeric/date for range filtering.");
                        }

                        var sql = $"SELECT * FROM {_tableName} WHERE [{field}] BETWEEN @from AND @to";
                        var parameters = new DynamicParameters();
                        parameters.Add("@from", from);
                        parameters.Add("@to", to);

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync<TEntity>(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<dynamic>> GroupByAsync(string field, object? filters = null)
                {
                    return await ExecuteSafe("GroupBy", async () =>
                    {
                        ValidateField(field);

                        var (_, _, numericProps, _) = InspectEntity();
                        var numericNames = numericProps.Select(p => p.Name).ToList();

                        var aggSelect = "COUNT(1) AS Count";
                        if (numericNames.Any())
                        {
                            aggSelect += ", " + string.Join(", ", numericNames.Select(n => $"SUM([{n}]) AS Sum_{n}"));
                        }

                        var (whereSql, parameters) = BuildWhereClause(filters);
                        var sql = $"SELECT [{field}], {aggSelect} FROM {_tableName}{whereSql} GROUP BY [{field}]";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<dynamic?> AggregateAsync(string field, string function, object? filters = null)
                {
                    return await ExecuteSafe("Aggregate", async () =>
                    {
                        var (_, _, numericProps, _) = InspectEntity();
                        var allowed = numericProps.Select(p => p.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
                        var func = function.ToUpperInvariant();

                        if (func != "SUM" && func != "COUNT" && func != "AVG")
                        {
                            throw new ArgumentException("Unsupported aggregate function. Use SUM, COUNT or AVG.");
                        }

                        if (!string.Equals(func, "COUNT", StringComparison.OrdinalIgnoreCase) && !allowed.Contains(field))
                        {
                            throw new ArgumentException($"Field '{field}' is not numeric for aggregate {function}.");
                        }

                        var (whereSql, parameters) = BuildWhereClause(filters);
                        var sql = func == "COUNT"
                            ? $"SELECT COUNT(1) AS Count FROM {_tableName}{whereSql}"
                            : $"SELECT {func}([{field}]) AS Value FROM {_tableName}{whereSql}";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return (await connection.QueryAsync(sql, parameters).ConfigureAwait(false)).FirstOrDefault();
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<TEntity>> TopAsync(string orderBy, int count, object? filters = null)
                {
                    return await ExecuteSafe("Top", async () =>
                    {
                        var validatedOrderBy = ValidateOrderBy(orderBy);
                        var (whereSql, parameters) = BuildWhereClause(filters);
                        var sql = $"SELECT TOP({count}) * FROM {_tableName}{whereSql} ORDER BY {validatedOrderBy}";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync<TEntity>(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<bool> ExistsAsync(object filters)
                {
                    return await ExecuteSafe("Exists", async () =>
                    {
                        var (whereSql, parameters) = BuildWhereClause(filters, allowEmpty: true);
                        if (string.IsNullOrWhiteSpace(whereSql))
                        {
                            whereSql = " WHERE 1=1";
                        }
                        var sql = $"SELECT CASE WHEN EXISTS(SELECT 1 FROM {_tableName}{whereSql}) THEN 1 ELSE 0 END as ExistsFlag";

                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        var result = await connection.ExecuteScalarAsync<int>(sql, parameters).ConfigureAwait(false);
                        return result == 1;
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<dynamic>> RawAsync(string sql, object? parameters = null)
                {
                    return await ExecuteSafe("Raw", async () =>
                    {
                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("Raw SQL: {Sql} | Params: {Params}", sql, parameters);
                        return await connection.QueryAsync(sql, parameters).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public async Task<IEnumerable<dynamic>> ExecuteStoredProcedureAsync(string spName, object? parameters = null)
                {
                    return await ExecuteSafe($"SP:{spName}", async () =>
                    {
                        await using var connection = CreateConnection();
                        await connection.OpenAsync().ConfigureAwait(false);
                        _logger.LogDebug("Calling SP: {SP} | Params: {Params}", spName, parameters);
                        return await connection.QueryAsync(spName, parameters, commandType: CommandType.StoredProcedure).ConfigureAwait(false);
                    }).ConfigureAwait(false);
                }

                public IQueryable<TEntity> Query() => _set.AsQueryable();

                public async Task<TEntity?> FindAsync(object[] keyValues, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(keyValues);
                    return await _set.FindAsync(keyValues, cancellationToken).ConfigureAwait(false);
                }

                public async Task<TEntity?> FirstOrDefaultAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(predicate);
                    return await _set.FirstOrDefaultAsync(predicate, cancellationToken).ConfigureAwait(false);
                }

                public async Task AddAsync(TEntity entity, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(entity);
                    await _set.AddAsync(entity, cancellationToken).ConfigureAwait(false);
                }

                public Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(entity);
                    _set.Update(entity);
                    return Task.CompletedTask;
                }

                public Task RemoveAsync(TEntity entity, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(entity);
                    _set.Remove(entity);
                    return Task.CompletedTask;
                }

                public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
                {
                    await Context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
                }

                private SqlConnection CreateConnection()
                {
                    if (string.IsNullOrWhiteSpace(_connectionString))
                    {
                        throw new InvalidOperationException("Database connection string is not configured.");
                    }

                    return new SqlConnection(_connectionString);
                }

                private string ResolveTableName()
                {
                    IEntityType? entityType = Context.Model.FindEntityType(typeof(TEntity));
                    if (entityType == null)
                    {
                        return $"[{typeof(TEntity).Name}]";
                    }

                    var schema = entityType.GetSchema();
                    var tableName = entityType.GetTableName() ?? typeof(TEntity).Name;

                    return string.IsNullOrWhiteSpace(schema) ? $"[{tableName}]" : $"[{schema}].[{tableName}]";
                }

                private async Task<T> ExecuteSafe<T>(string operation, Func<Task<T>> action)
                {
                    var sw = Stopwatch.StartNew();
                    _logger.LogInformation("Starting DB operation {Operation} on {Table}", operation, _tableName);
                    try
                    {
                        var result = await action().ConfigureAwait(false);
                        sw.Stop();
                        _logger.LogInformation("Completed {Operation} on {Table} in {Elapsed}ms", operation, _tableName, sw.ElapsedMilliseconds);
                        return result;
                    }
                    catch (SqlException ex)
                    {
                        sw.Stop();
                        _logger.LogError(ex, "SQL error during {Operation} on {Table}", operation, _tableName);
                        throw new Exception($"Database error in {operation} for {_tableName}: {ex.Message}", ex);
                    }
                    catch (TimeoutException ex)
                    {
                        sw.Stop();
                        _logger.LogError(ex, "Timeout during {Operation} on {Table}", operation, _tableName);
                        throw new Exception($"Timeout in {operation} for {_tableName}: {ex.Message}", ex);
                    }
                    catch (Exception ex)
                    {
                        sw.Stop();
                        _logger.LogError(ex, "Unexpected error during {Operation} on {Table}", operation, _tableName);
                        throw new Exception($"Unexpected error in {operation} for {_tableName}: {ex.Message}", ex);
                    }
                }

                private (PropertyInfo[] all, PropertyInfo[] stringProps, PropertyInfo[] numericProps, PropertyInfo[] dateProps) InspectEntity()
                {
                    var type = typeof(TEntity);
                    var props = type.GetProperties(BindingFlags.Public | BindingFlags.Instance);
                    var stringProps = props.Where(p => p.PropertyType == typeof(string)).ToArray();
                    var numericProps = props.Where(p =>
                        p.PropertyType == typeof(int) ||
                        p.PropertyType == typeof(long) ||
                        p.PropertyType == typeof(decimal) ||
                        p.PropertyType == typeof(double) ||
                        p.PropertyType == typeof(float) ||
                        p.PropertyType == typeof(short) ||
                        p.PropertyType == typeof(int?) ||
                        p.PropertyType == typeof(long?) ||
                        p.PropertyType == typeof(decimal?) ||
                        p.PropertyType == typeof(double?) ||
                        p.PropertyType == typeof(float?) ||
                        p.PropertyType == typeof(short?)
                    ).ToArray();
                    var dateProps = props.Where(p => p.PropertyType == typeof(DateTime) || p.PropertyType == typeof(DateTime?)).ToArray();
                    return (props, stringProps, numericProps, dateProps);
                }

                private (string whereSql, DynamicParameters parameters) BuildWhereClause(object? filters, bool allowEmpty = true)
                {
                    var where = new List<string>();
                    var parameters = new DynamicParameters();
                    var validProps = InspectEntity().all.Select(p => p.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);

                    if (filters != null)
                    {
                        if (filters is IDictionary<string, object?> dict)
                        {
                            foreach (var kv in dict)
                            {
                                if (kv.Value == null) continue;
                                if (!validProps.Contains(kv.Key))
                                {
                                    throw new ArgumentException($"Property '{kv.Key}' is not valid for filtering.");
                                }
                                where.Add($"[{kv.Key}] = @{kv.Key}");
                                parameters.Add($"@{kv.Key}", kv.Value);
                            }
                        }
                        else
                        {
                            foreach (var prop in filters.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
                            {
                                var value = prop.GetValue(filters);
                                if (value == null) continue;
                                if (!validProps.Contains(prop.Name))
                                {
                                    throw new ArgumentException($"Property '{prop.Name}' is not valid for filtering.");
                                }
                                where.Add($"[{prop.Name}] = @{prop.Name}");
                                parameters.Add($"@{prop.Name}", value);
                            }
                        }
                    }

                    if (!where.Any() && !allowEmpty)
                    {
                        throw new ArgumentException("At least one filter value must be provided.");
                    }

                    var whereSql = where.Count == 0 ? string.Empty : " WHERE " + string.Join(" AND ", where);

                    return (whereSql, parameters);
                }

                private string ResolveDefaultOrderBy()
                {
                    var entityType = Context.Model.FindEntityType(typeof(TEntity));
                    var keyProps = entityType?.FindPrimaryKey()?.Properties;

                    if (keyProps != null && keyProps.Any())
                    {
                        return string.Join(", ", keyProps.Select(p => $"[{p.Name}] DESC"));
                    }

                    var (allProps, _, _, _) = InspectEntity();
                    return allProps.Length > 0 ? $"[{allProps[0].Name}] DESC" : "[Id] DESC";
                }

                private void ValidateField(string field)
                {
                    var validProps = InspectEntity().all.Select(p => p.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
                    if (!validProps.Contains(field))
                    {
                        throw new ArgumentException($"Field '{field}' is not valid for this entity.");
                    }
                }

                private string ValidateOrderBy(string orderBy)
                {
                    var parts = orderBy.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (parts.Length == 0)
                    {
                        throw new ArgumentException("Order by clause cannot be empty.");
                    }

                    var field = parts[0];
                    ValidateField(field);

                    var direction = parts.Length > 1 ? parts[1] : "ASC";
                    if (!direction.Equals("ASC", StringComparison.OrdinalIgnoreCase) &&
                        !direction.Equals("DESC", StringComparison.OrdinalIgnoreCase))
                    {
                        throw new ArgumentException("Order by direction must be either ASC or DESC.");
                    }

                    return $"[{field}] {direction.ToUpperInvariant()}";
                }
            }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "EntityFramework", "Repositories", "EfRepository.cs"), repositoryBaseContent, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteStoredProcedureBaseAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var content = $$"""
            using System;
            using System.Collections.Generic;
            using System.Data;
            using System.Data.Common;
            using Microsoft.Data.SqlClient;
            using Microsoft.EntityFrameworkCore;
            using Microsoft.EntityFrameworkCore.Infrastructure;

            namespace {{_projectName}}.StoredProcedure;

            public sealed record StoredProcedureResult<TOutput>(int RowsAffected, TOutput Output);

            public abstract class StoredProcedureRepository
            {
                protected readonly DbContext Context;

                protected StoredProcedureRepository(DbContext context)
                {
                    Context = context;
                }

                protected DbConnection Connection => Context.Database.GetService<DbConnection>();

                protected async Task<int> ExecuteAsync(string storedProcedureName, IEnumerable<DbParameter> parameters, CancellationToken cancellationToken = default)
                {
                    if (string.IsNullOrWhiteSpace(storedProcedureName))
                    {
                        throw new ArgumentException("Stored procedure name must be provided.", nameof(storedProcedureName));
                    }

                    await using var command = Connection.CreateCommand();
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = storedProcedureName;

                    foreach (var parameter in parameters)
                    {
                        command.Parameters.Add(parameter);
                    }

                    if (Connection.State != ConnectionState.Open)
                    {
                        await Connection.OpenAsync(cancellationToken).ConfigureAwait(false);
                    }

                    return await command.ExecuteNonQueryAsync(cancellationToken).ConfigureAwait(false);
                }

                protected static DbParameter CreateParameter(
                    string name,
                    object? value,
                    SqlDbType sqlDbType,
                    bool isOutput,
                    bool isNullable,
                    int? size,
                    byte? precision,
                    int? scale)
                {
                    var parameter = new SqlParameter(name, sqlDbType)
                    {
                        Direction = isOutput ? ParameterDirection.Output : ParameterDirection.Input,
                        IsNullable = isNullable
                    };

                    if (!isOutput)
                    {
                        parameter.Value = value ?? DBNull.Value;
                    }

                    if (size.HasValue)
                    {
                        parameter.Size = size.Value;
                    }

                    if (precision.HasValue)
                    {
                        parameter.Precision = precision.Value;
                    }

                    if (scale.HasValue)
                    {
                        parameter.Scale = (byte)scale.Value;
                    }

                    return parameter;
                }

                protected static T? ConvertFromDbValue<T>(object? value)
                {
                    if (value is null || value == DBNull.Value)
                    {
                        return default;
                    }

                    return (T?)Convert.ChangeType(value, typeof(T));
                }
            }

            public abstract class StoredProcedureRepositoryBase<TInput, TOutput> : StoredProcedureRepository
                where TInput : class
                where TOutput : class, new()
            {
                protected StoredProcedureRepositoryBase(DbContext context) : base(context)
                {
                }

                protected abstract string StoredProcedureName { get; }

                protected abstract IReadOnlyList<DbParameter> BuildParameters(TInput input);

                protected abstract TOutput MapOutput(IReadOnlyList<DbParameter> parameters);

                public async Task<StoredProcedureResult<TOutput>> ExecuteAsync(TInput input, CancellationToken cancellationToken = default)
                {
                    ArgumentNullException.ThrowIfNull(input);

                    var parameters = BuildParameters(input);
                    var rowsAffected = await base.ExecuteAsync(StoredProcedureName, parameters, cancellationToken).ConfigureAwait(false);
                    var output = MapOutput(parameters);
                    return new StoredProcedureResult<TOutput>(rowsAffected, output);
                }
            }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "StoredProcedure", "StoredProcedureRepository.cs"), content, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteApplicationDependencyInjectionAsync(string projectRoot, TemplateMetadata metadata, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using Microsoft.Extensions.DependencyInjection;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.Application;");
        builder.AppendLine();
        builder.AppendLine("public static class ApplicationDependencyInjection");
        builder.AppendLine("{");
        builder.AppendLine("    public static IServiceCollection AddApplicationLayer(this IServiceCollection services)");
        builder.AppendLine("    {");
        foreach (var entity in metadata.Entities)
        {
            builder.AppendLine($"        services.AddScoped<{_projectName}.Application.Contracts.I{entity.EntityName}Service, {_projectName}.Application.Services.{entity.EntityName}Service>();");
        }
        builder.AppendLine();
        builder.AppendLine("        return services;");
        builder.AppendLine("    }");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Application", "DependencyInjection.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteInfrastructureDependencyInjectionAsync(string projectRoot, TemplateMetadata metadata, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using Microsoft.EntityFrameworkCore;");
        builder.AppendLine("using Microsoft.Extensions.DependencyInjection;");
        builder.AppendLine("using Microsoft.Extensions.DependencyInjection.Extensions;");
        builder.AppendLine($"using {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine($"using {_projectName}.DomainShared.Contracts;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Data;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.EntityFramework;");
        builder.AppendLine();
        builder.AppendLine("public static class EntityFrameworkDependencyInjection");
        builder.AppendLine("{");
        builder.AppendLine("    public static IServiceCollection AddDataAccess(this IServiceCollection services, Action<DbContextOptionsBuilder> optionsBuilder)");
        builder.AppendLine("    {");
        builder.AppendLine("        services.AddDbContext<AppDbContext>(optionsBuilder);");
        builder.AppendLine("        services.TryAddScoped(typeof(IRepository<>), typeof(EfRepository<>));");

        foreach (var entity in metadata.Entities)
        {
            builder.AppendLine($"        services.AddScoped<I{entity.EntityName}Repository, {entity.EntityName}Repository>();");
        }

        foreach (var storedProcedure in metadata.StoredProcedures)
        {
            var className = NameHelper.ToPascalCase(storedProcedure.Name);
            builder.AppendLine($"        services.AddScoped<{_projectName}.StoredProcedure.{className}.Repositories.{className}StoredProcedureRepository>();");
        }

        builder.AppendLine();
        builder.AppendLine("        return services;");
        builder.AppendLine("    }");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "EntityFramework", "DependencyInjection.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteDomainEntityAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using System.ComponentModel.DataAnnotations;");
        builder.AppendLine("using System.ComponentModel.DataAnnotations.Schema;");
        builder.AppendLine("using Microsoft.EntityFrameworkCore;");
        builder.AppendLine($"using {_projectName}.DomainShared.Abstractions;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.Domain.Entities;");
        builder.AppendLine();

        builder.AppendLine($"[Table(\"{entity.TableName}\", Schema = \"{entity.SchemaName}\")]");
        builder.AppendLine($"public sealed class {entity.EntityName} : EntityBase");
        builder.AppendLine("{");

        foreach (var property in entity.Properties)
        {
            if (property.IsPrimaryKey && entity.KeyProperties.Count == 1)
            {
                builder.AppendLine("    [Key]");
            }

            builder.AppendLine($"    [Column(\"{property.ColumnName}\")]");
            var initializer = GetInitializer(property);
            builder.AppendLine($"    public {property.ClrTypeName} {property.PropertyName} {{ get; set; }}{initializer}");
            builder.AppendLine();
        }

        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Domain", "Entities", $"{entity.EntityName}.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteRepositoryInterfaceAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"using {_projectName}.Domain.Entities;");
        builder.AppendLine($"using {_projectName}.DomainShared.Contracts;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"public interface I{entity.EntityName}Repository : IRepository<{entity.EntityName}>");
        builder.AppendLine("{");

        if (entity.KeyProperties.Count == 1)
        {
            builder.AppendLine($"    Task<{entity.EntityName}?> FindAsync({entity.KeyProperties[0].ClrTypeNameWithoutNullability} id, CancellationToken cancellationToken = default);");
        }
        else if (entity.KeyProperties.Count > 1)
        {
            builder.AppendLine($"    Task<{entity.EntityName}?> FindAsync({entity.EntityName}Key key, CancellationToken cancellationToken = default);");
        }

        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Domain", "Contracts", "Repositories", $"I{entity.EntityName}Repository.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteKeyRecordAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        if (entity.KeyProperties.Count <= 1)
        {
            return;
        }

        var builder = new StringBuilder();
        builder.AppendLine($"namespace {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"public sealed record {entity.EntityName}Key({string.Join(", ", entity.KeyProperties.Select(p => $"{p.ClrTypeNameWithoutNullability} {p.PropertyName}"))})");
        builder.AppendLine("{");
        builder.AppendLine($"    public object[] ToObjectArray() => new object[] {{ {string.Join(", ", entity.KeyProperties.Select(p => p.PropertyName))} }};");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Domain", "Contracts", "Repositories", $"{entity.EntityName}Key.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteDtoAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"namespace {_projectName}.Application.Dtos;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {entity.EntityName}Dto");
        builder.AppendLine("{");

        foreach (var property in entity.Properties)
        {
            var initializer = GetInitializer(property);
            builder.AppendLine($"    public {property.ClrTypeName} {property.PropertyName} {{ get; set; }}{initializer}");
        }

        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Application", "Dtos", $"{entity.EntityName}Dto.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteServiceInterfaceAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"using {_projectName}.Application.Dtos;");
        builder.AppendLine($"using {_projectName}.ApplicationShared.Models;");
        builder.AppendLine($"using {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.Application.Contracts;");
        builder.AppendLine();
        builder.AppendLine($"public interface I{entity.EntityName}Service");
        builder.AppendLine("{");
        builder.AppendLine($"    Task<IEnumerable<{entity.EntityName}Dto>> GetAllAsync(CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<{entity.EntityName}Dto?> GetByKeysAsync(object filters, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<{entity.EntityName}Dto>> QueryAsync(object? filters, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<PagedResult<{entity.EntityName}Dto>> QueryPagedAsync(object? filters, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<{entity.EntityName}Dto>> SearchAsync(string text, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<{entity.EntityName}Dto>> FilterRangeAsync(string field, object from, object to, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<dynamic>> GroupByAsync(string field, object? filters = null, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<dynamic?> AggregateAsync(string field, string function, object? filters = null, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<{entity.EntityName}Dto>> TopAsync(string orderBy, int count, object? filters = null, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<bool> ExistsAsync(object filters, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<dynamic>> RawAsync(string sql, object? parameters = null, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<IEnumerable<dynamic>> ExecuteStoredProcedureAsync(string spName, object? parameters = null, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task<PagedResult<{entity.EntityName}Dto>> GetAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);");

        if (entity.KeyProperties.Count == 1)
        {
            builder.AppendLine($"    Task<{entity.EntityName}Dto?> FindAsync({entity.KeyProperties[0].ClrTypeNameWithoutNullability} id, CancellationToken cancellationToken = default);");
            builder.AppendLine($"    Task RemoveAsync({entity.KeyProperties[0].ClrTypeNameWithoutNullability} id, CancellationToken cancellationToken = default);");
        }
        else if (entity.KeyProperties.Count > 1)
        {
            builder.AppendLine($"    Task<{entity.EntityName}Dto?> FindAsync({entity.EntityName}Key key, CancellationToken cancellationToken = default);");
            builder.AppendLine($"    Task RemoveAsync({entity.EntityName}Key key, CancellationToken cancellationToken = default);");
        }
        else
        {
            builder.AppendLine($"    Task<{entity.EntityName}Dto?> FindAsync(object[] keyValues, CancellationToken cancellationToken = default);");
            builder.AppendLine($"    Task RemoveAsync(object[] keyValues, CancellationToken cancellationToken = default);");
        }

        builder.AppendLine($"    Task<{entity.EntityName}Dto> CreateAsync({entity.EntityName}Dto dto, CancellationToken cancellationToken = default);");
        builder.AppendLine($"    Task UpdateAsync({entity.EntityName}Dto dto, CancellationToken cancellationToken = default);");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Application", "Contracts", $"I{entity.EntityName}Service.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteServiceImplementationAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"using {_projectName}.Application.Contracts;");
        builder.AppendLine($"using {_projectName}.Application.Dtos;");
        builder.AppendLine($"using {_projectName}.ApplicationShared.Models;");
        builder.AppendLine($"using {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine($"using {_projectName}.Domain.Entities;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.Application.Services;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {entity.EntityName}Service : I{entity.EntityName}Service");
        builder.AppendLine("{");
        builder.AppendLine($"    private readonly I{entity.EntityName}Repository _repository;");
        builder.AppendLine();
        builder.AppendLine($"    public {entity.EntityName}Service(I{entity.EntityName}Repository repository)");
        builder.AppendLine("    {");
        builder.AppendLine("        _repository = repository;");
        builder.AppendLine("    }");
        builder.AppendLine();
        builder.AppendLine($"    public async Task<IEnumerable<{entity.EntityName}Dto>> GetAllAsync(CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entities = await _repository.GetAllAsync().ConfigureAwait(false);");
        builder.AppendLine("        return entities.Select(MapToDto).ToList();");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<{entity.EntityName}Dto?> GetByKeysAsync(object filters, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entity = await _repository.GetByKeysAsync(filters).ConfigureAwait(false);");
        builder.AppendLine("        return entity is null ? null : MapToDto(entity);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<{entity.EntityName}Dto>> QueryAsync(object? filters, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entities = await _repository.QueryAsync(filters).ConfigureAwait(false);");
        builder.AppendLine("        return entities.Select(MapToDto).ToList();");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<PagedResult<{entity.EntityName}Dto>> QueryPagedAsync(object? filters, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var result = await _repository.QueryPagedAsync(filters, pageNumber, pageSize).ConfigureAwait(false);");
        builder.AppendLine("        var items = result.Items.Select(MapToDto).ToList();");
        builder.AppendLine();
        builder.AppendLine($"        return new PagedResult<{entity.EntityName}Dto>");
        builder.AppendLine("        {");
        builder.AppendLine("            Items = items,");
        builder.AppendLine("            TotalCount = result.TotalCount,");
        builder.AppendLine("            PageNumber = result.PageNumber,");
        builder.AppendLine("            PageSize = result.PageSize");
        builder.AppendLine("        };");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<{entity.EntityName}Dto>> SearchAsync(string text, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entities = await _repository.SearchAsync(text).ConfigureAwait(false);");
        builder.AppendLine("        return entities.Select(MapToDto).ToList();");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<{entity.EntityName}Dto>> FilterRangeAsync(string field, object from, object to, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entities = await _repository.FilterRangeAsync(field, from, to).ConfigureAwait(false);");
        builder.AppendLine("        return entities.Select(MapToDto).ToList();");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<dynamic>> GroupByAsync(string field, object? filters = null, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await _repository.GroupByAsync(field, filters).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<dynamic?> AggregateAsync(string field, string function, object? filters = null, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await _repository.AggregateAsync(field, function, filters).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<{entity.EntityName}Dto>> TopAsync(string orderBy, int count, object? filters = null, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var entities = await _repository.TopAsync(orderBy, count, filters).ConfigureAwait(false);");
        builder.AppendLine("        return entities.Select(MapToDto).ToList();");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<bool> ExistsAsync(object filters, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await _repository.ExistsAsync(filters).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<dynamic>> RawAsync(string sql, object? parameters = null, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await _repository.RawAsync(sql, parameters).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<IEnumerable<dynamic>> ExecuteStoredProcedureAsync(string spName, object? parameters = null, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await _repository.ExecuteStoredProcedureAsync(spName, parameters).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<PagedResult<{entity.EntityName}Dto>> GetAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return await QueryPagedAsync(null, pageNumber, pageSize, cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        var keySignature = entity.KeyProperties.Count switch
        {
            0 => "object[] keyValues",
            1 => $"{entity.KeyProperties[0].ClrTypeNameWithoutNullability} id",
            _ => $"{entity.EntityName}Key key"
        };

        var keyArgument = entity.KeyProperties.Count switch
        {
            0 => "keyValues",
            1 => "new object[] { id }",
            _ => "key.ToObjectArray()"
        };

        builder.AppendLine($"    public async Task<{entity.EntityName}Dto?> FindAsync({keySignature}, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine($"        var entity = await _repository.FindAsync({keyArgument}, cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        return entity is null ? null : MapToDto(entity);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task<{entity.EntityName}Dto> CreateAsync({entity.EntityName}Dto dto, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine($"        var entity = MapToEntity(dto);");
        builder.AppendLine("        await _repository.AddAsync(entity, cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        await _repository.SaveChangesAsync(cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        return MapToDto(entity);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task UpdateAsync({entity.EntityName}Dto dto, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        if (entity.KeyProperties.Count == 0)
        {
            builder.AppendLine("        throw new InvalidOperationException(\"Cannot update an entity without a primary key definition.\");");
        }
        else
        {
            var updateKeyArgument = entity.KeyProperties.Count == 1
                ? "new object[] { dto." + entity.KeyProperties[0].PropertyName + " }"
                : $"new object[] {{ {string.Join(", ", entity.KeyProperties.Select(p => $"dto.{p.PropertyName}"))} }}";

            builder.AppendLine($"        var entity = await _repository.FindAsync({updateKeyArgument}, cancellationToken).ConfigureAwait(false);");
            builder.AppendLine("        if (entity is null)");
            builder.AppendLine("        {");
            builder.AppendLine("            throw new InvalidOperationException(\"Entity not found for update.\");");
            builder.AppendLine("        }");
            builder.AppendLine();
            builder.AppendLine("        ApplyChanges(dto, entity);");
            builder.AppendLine("        await _repository.UpdateAsync(entity, cancellationToken).ConfigureAwait(false);");
            builder.AppendLine("        await _repository.SaveChangesAsync(cancellationToken).ConfigureAwait(false);");
        }
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    public async Task RemoveAsync({keySignature}, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine($"        var entity = await _repository.FindAsync({keyArgument}, cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        if (entity is null)");
        builder.AppendLine("        {");
        builder.AppendLine("            return;");
        builder.AppendLine("        }");

        builder.AppendLine("        await _repository.RemoveAsync(entity, cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        await _repository.SaveChangesAsync(cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    private static {entity.EntityName}Dto MapToDto({entity.EntityName} entity)");
        builder.AppendLine("    {");
        builder.AppendLine($"        return new {entity.EntityName}Dto");
        builder.AppendLine("        {");
        foreach (var property in entity.Properties)
        {
            builder.AppendLine($"            {property.PropertyName} = entity.{property.PropertyName},");
        }
        builder.AppendLine("        };");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    private static {entity.EntityName} MapToEntity({entity.EntityName}Dto dto)");
        builder.AppendLine("    {");
        builder.AppendLine($"        var entity = new {entity.EntityName}();");
        builder.AppendLine("        ApplyChanges(dto, entity);");
        builder.AppendLine("        return entity;");
        builder.AppendLine("    }");
        builder.AppendLine();

        builder.AppendLine($"    private static void ApplyChanges({entity.EntityName}Dto dto, {entity.EntityName} entity)");
        builder.AppendLine("    {");
        foreach (var property in entity.Properties)
        {
            if (property.IsIdentity)
            {
                continue;
            }

            builder.AppendLine($"        entity.{property.PropertyName} = dto.{property.PropertyName};");
        }
        builder.AppendLine("    }");

        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "Application", "Services", $"{entity.EntityName}Service.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteEfRepositoryAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"using {_projectName}.Domain.Contracts.Repositories;");
        builder.AppendLine($"using {_projectName}.Domain.Entities;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Data;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.EntityFramework.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {entity.EntityName}Repository : EfRepository<{entity.EntityName}>, I{entity.EntityName}Repository");
        builder.AppendLine("{");
        builder.AppendLine($"    public {entity.EntityName}Repository(AppDbContext context) : base(context)");
        builder.AppendLine("    {");
        builder.AppendLine("    }");
        builder.AppendLine();

        if (entity.KeyProperties.Count == 1)
        {
            builder.AppendLine($"    public async Task<{entity.EntityName}?> FindAsync({entity.KeyProperties[0].ClrTypeNameWithoutNullability} id, CancellationToken cancellationToken = default)");
            builder.AppendLine("    {");
            builder.AppendLine("        return await base.FindAsync(new object[] { id }, cancellationToken).ConfigureAwait(false);");
            builder.AppendLine("    }");
        }
        else if (entity.KeyProperties.Count > 1)
        {
            builder.AppendLine($"    public async Task<{entity.EntityName}?> FindAsync({entity.EntityName}Key key, CancellationToken cancellationToken = default)");
            builder.AppendLine("    {");
            builder.AppendLine("        ArgumentNullException.ThrowIfNull(key);");
            builder.AppendLine("        return await base.FindAsync(key.ToObjectArray(), cancellationToken).ConfigureAwait(false);");
            builder.AppendLine("    }");
        }

        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "EntityFramework", "Repositories", $"{entity.EntityName}Repository.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteStoredProcedureRepositoriesAsync(string projectRoot, TemplateMetadata metadata, CancellationToken cancellationToken)
    {
        foreach (var storedProcedure in metadata.StoredProcedures)
        {
            var className = NameHelper.ToPascalCase(storedProcedure.Name);
            var storedProcedureFolder = Path.Combine(projectRoot, "StoredProcedure", className);
            var dtoFolder = Path.Combine(storedProcedureFolder, "Dtos");
            var sqlFolder = Path.Combine(storedProcedureFolder, "Sql");
            var repositoryFolder = Path.Combine(storedProcedureFolder, "Repositories");

            Directory.CreateDirectory(dtoFolder);
            Directory.CreateDirectory(sqlFolder);
            Directory.CreateDirectory(repositoryFolder);

            await WriteStoredProcedureDtosAsync(dtoFolder, className, storedProcedure, cancellationToken).ConfigureAwait(false);
            await WriteStoredProcedureSqlAsync(sqlFolder, storedProcedure, cancellationToken).ConfigureAwait(false);
            await WriteStoredProcedureRepositoryAsync(repositoryFolder, className, storedProcedure, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task WriteStoredProcedureDtosAsync(string dtoFolder, string className, StoredProcedureMetadata storedProcedure, CancellationToken cancellationToken)
    {
        var inputDto = BuildStoredProcedureDto(className, storedProcedure, isOutputDto: false);
        var outputDto = BuildStoredProcedureDto(className, storedProcedure, isOutputDto: true);

        await WriteFileAsync(Path.Combine(dtoFolder, $"{className}InputDto.cs"), inputDto, cancellationToken).ConfigureAwait(false);
        await WriteFileAsync(Path.Combine(dtoFolder, $"{className}OutputDto.cs"), outputDto, cancellationToken).ConfigureAwait(false);
    }

    private string BuildStoredProcedureDto(string className, StoredProcedureMetadata storedProcedure, bool isOutputDto)
    {
        var builder = new StringBuilder();
        builder.AppendLine($"namespace {_projectName}.StoredProcedure.{className}.Dtos;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {className}{(isOutputDto ? "Output" : "Input")}Dto");
        builder.AppendLine("{");

        var parameters = storedProcedure.Properties.Where(p => p.IsOutput == isOutputDto).ToList();
        if (parameters.Count == 0)
        {
            builder.AppendLine("}");
            return builder.ToString();
        }

        foreach (var parameter in parameters)
        {
            builder.AppendLine($"    public {parameter.ClrTypeName} {parameter.PropertyName} {{ get; set; }}");
        }

        builder.AppendLine("}");
        return builder.ToString();
    }

    private async Task WriteStoredProcedureSqlAsync(string sqlFolder, StoredProcedureMetadata storedProcedure, CancellationToken cancellationToken)
    {
        var fileName = $"{storedProcedure.Name}.sql";
        await File.WriteAllTextAsync(Path.Combine(sqlFolder, fileName), storedProcedure.Code, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteStoredProcedureRepositoryAsync(string repositoryFolder, string className, StoredProcedureMetadata storedProcedure, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using System;");
        builder.AppendLine("using System.Collections.Generic;");
        builder.AppendLine("using System.Data;");
        builder.AppendLine("using System.Data.Common;");
        builder.AppendLine("using System.Linq;");
        builder.AppendLine("using Microsoft.Data.SqlClient;");
        builder.AppendLine("using Microsoft.EntityFrameworkCore;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Data;");
        builder.AppendLine($"using {_projectName}.StoredProcedure;");
        builder.AppendLine($"using {_projectName}.StoredProcedure.{className}.Dtos;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.StoredProcedure.{className}.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {className}StoredProcedureRepository : StoredProcedureRepositoryBase<{className}InputDto, {className}OutputDto>");
        builder.AppendLine("{");
        builder.AppendLine($"    private const string StoredProcedureFullName = \"{storedProcedure.SchemaName}.{storedProcedure.Name}\";");
        builder.AppendLine();
        builder.AppendLine($"    public {className}StoredProcedureRepository(AppDbContext context) : base(context)");
        builder.AppendLine("    {");
        builder.AppendLine("    }");
        builder.AppendLine();
        builder.AppendLine("    protected override string StoredProcedureName => StoredProcedureFullName;");
        builder.AppendLine();
        builder.AppendLine($"    protected override IReadOnlyList<DbParameter> BuildParameters({className}InputDto input)");
        builder.AppendLine("    {");
        builder.AppendLine("        var parameters = new List<DbParameter>();");

        foreach (var parameter in storedProcedure.Properties)
        {
            var parameterName = GetParameterName(parameter.Name);
            var sqlDbType = GetSqlDbType(parameter.SqlTypeName);
            var inputValue = parameter.IsOutput ? "null" : $"input.{parameter.PropertyName}";
            var sizeValue = parameter.MaxLength.HasValue ? parameter.MaxLength.Value.ToString() : "null";
            var precisionValue = parameter.Precision.HasValue ? parameter.Precision.Value.ToString() : "null";
            var scaleValue = parameter.Scale.HasValue ? parameter.Scale.Value.ToString() : "null";

            builder.AppendLine($"        parameters.Add(CreateParameter(\"{parameterName}\", {inputValue}, {sqlDbType}, {parameter.IsOutput.ToString().ToLowerInvariant()}, {parameter.IsNullable.ToString().ToLowerInvariant()}, {sizeValue}, {precisionValue}, {scaleValue}));");
        }

        builder.AppendLine();
        builder.AppendLine("        return parameters;");
        builder.AppendLine("    }");
        builder.AppendLine();
        builder.AppendLine($"    protected override {className}OutputDto MapOutput(IReadOnlyList<DbParameter> parameters)");
        builder.AppendLine("    {");
        builder.AppendLine($"        var output = new {className}OutputDto();");

        var outputParameters = storedProcedure.Properties.Where(p => p.IsOutput).ToList();
        foreach (var parameter in outputParameters)
        {
            var parameterName = GetParameterName(parameter.Name);
            var clrType = parameter.ClrTypeNameWithoutNullability;
            builder.AppendLine($"        var {parameter.PropertyName}Parameter = parameters.First(p => string.Equals(p.ParameterName, \"{parameterName}\", StringComparison.OrdinalIgnoreCase));");
            builder.AppendLine($"        output.{parameter.PropertyName} = ConvertFromDbValue<{clrType}>({parameter.PropertyName}Parameter.Value);");
        }

        builder.AppendLine();
        builder.AppendLine("        return output;");
        builder.AppendLine("    }");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(repositoryFolder, $"{className}StoredProcedureRepository.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
    }

    private string BuildDbContext(TemplateMetadata metadata)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using Microsoft.EntityFrameworkCore;");
        builder.AppendLine($"using {_projectName}.Domain.Entities;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.EntityFramework.Data;");
        builder.AppendLine();
        builder.AppendLine("public class AppDbContext : DbContext");
        builder.AppendLine("{");
        builder.AppendLine("    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)");
        builder.AppendLine("    {");
        builder.AppendLine("    }");
        builder.AppendLine();

        foreach (var entity in metadata.Entities)
        {
            builder.AppendLine($"    public DbSet<{entity.EntityName}> {entity.EntityName}Set => Set<{entity.EntityName}>();");
        }

        var compositeKeyEntities = metadata.Entities.Where(e => e.KeyProperties.Count > 1).ToList();
        if (compositeKeyEntities.Count > 0)
        {
            builder.AppendLine();
            builder.AppendLine("    protected override void OnModelCreating(ModelBuilder modelBuilder)");
            builder.AppendLine("    {");
            builder.AppendLine("        base.OnModelCreating(modelBuilder);");
            builder.AppendLine();

            foreach (var entity in compositeKeyEntities)
            {
                builder.AppendLine($"        modelBuilder.Entity<{entity.EntityName}>().HasKey(e => new {{ {string.Join(", ", entity.KeyProperties.Select(p => $"e.{p.PropertyName}"))} }});");
            }

            builder.AppendLine("    }");
        }

        builder.AppendLine("}");
        return builder.ToString();
    }

    private static string GetInitializer(PropertyMetadata property)
    {
        if (property.IsNullable)
        {
            return string.Empty;
        }

        if (property.IsReferenceType)
        {
            return property.ClrTypeNameWithoutNullability switch
            {
                "string" => " = string.Empty;",
                "byte[]" => " = Array.Empty<byte>();",
                _ => " = new();"
            };
        }

        return string.Empty;
    }

    private static string GetSqlDbType(string sqlTypeName)
    {
        return (sqlTypeName ?? string.Empty).ToLowerInvariant() switch
        {
            "bigint" => "SqlDbType.BigInt",
            "binary" => "SqlDbType.Binary",
            "bit" => "SqlDbType.Bit",
            "char" => "SqlDbType.Char",
            "date" => "SqlDbType.Date",
            "datetime" => "SqlDbType.DateTime",
            "datetime2" => "SqlDbType.DateTime2",
            "datetimeoffset" => "SqlDbType.DateTimeOffset",
            "decimal" => "SqlDbType.Decimal",
            "float" => "SqlDbType.Float",
            "image" => "SqlDbType.Image",
            "int" => "SqlDbType.Int",
            "money" => "SqlDbType.Money",
            "nchar" => "SqlDbType.NChar",
            "ntext" => "SqlDbType.NText",
            "numeric" => "SqlDbType.Decimal",
            "nvarchar" => "SqlDbType.NVarChar",
            "real" => "SqlDbType.Real",
            "smalldatetime" => "SqlDbType.SmallDateTime",
            "smallint" => "SqlDbType.SmallInt",
            "smallmoney" => "SqlDbType.SmallMoney",
            "structured" => "SqlDbType.Structured",
            "text" => "SqlDbType.Text",
            "time" => "SqlDbType.Time",
            "timestamp" => "SqlDbType.Timestamp",
            "tinyint" => "SqlDbType.TinyInt",
            "udt" => "SqlDbType.Udt",
            "uniqueidentifier" => "SqlDbType.UniqueIdentifier",
            "varbinary" => "SqlDbType.VarBinary",
            "varchar" => "SqlDbType.VarChar",
            "variant" => "SqlDbType.Variant",
            "xml" => "SqlDbType.Xml",
            "table" => "SqlDbType.Structured",
            _ => "SqlDbType.Variant"
        };
    }

    private static string GetParameterName(string rawName)
    {
        if (string.IsNullOrWhiteSpace(rawName))
        {
            return string.Empty;
        }

        return rawName.StartsWith("@", StringComparison.Ordinal) ? rawName : $"@{rawName}";
    }

    private static async Task WriteFileAsync(string path, string content, CancellationToken cancellationToken)
    {
        var directory = Path.GetDirectoryName(path);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        await File.WriteAllTextAsync(path, content, cancellationToken).ConfigureAwait(false);
    }
}
