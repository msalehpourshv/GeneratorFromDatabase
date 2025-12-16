using System.Text;
using Generator.Metadata;

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
            await WriteStoredProcedureRepositoryAsync(projectRoot, entity, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task WriteProjectFileAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var content = $$"""
            <Project Sdk="Microsoft.NET.Sdk">
              <PropertyGroup>
                <TargetFramework>net10.0</TargetFramework>
                <Nullable>enable</Nullable>
                <ImplicitUsings>enable</ImplicitUsings>
              </PropertyGroup>
              <ItemGroup>
                <PackageReference Include="Microsoft.EntityFrameworkCore" Version="10.0.0" />
                <PackageReference Include="Microsoft.EntityFrameworkCore.Relational" Version="10.0.0" />
                <PackageReference Include="Microsoft.Extensions.DependencyInjection.Abstractions" Version="10.0.0" />
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
            public abstract class EntityBase
            {
                public Guid CorrelationId { get; set; } = Guid.NewGuid();

                public DateTime CreatedOnUtc { get; set; } = DateTime.UtcNow;

                public DateTime? ModifiedOnUtc { get; set; }
            }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "DomainShared", "Abstractions", "EntityBase.cs"), baseEntityContent, cancellationToken).ConfigureAwait(false);

        var repositoryContent = $$"""
            using System.Linq.Expressions;

            namespace {{_projectName}}.DomainShared.Contracts;

            public interface IRepository<TEntity> where TEntity : class
            {
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
                public required IReadOnlyList<T> Items { get; init; }

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
            using System.Linq.Expressions;
            using {{_projectName}}.DomainShared.Contracts;
            using Microsoft.EntityFrameworkCore;

            namespace {{_projectName}}.EntityFramework.Repositories;

            public class EfRepository<TEntity> : IRepository<TEntity> where TEntity : class
            {
                private readonly DbSet<TEntity> _set;
                protected readonly DbContext Context;

                public EfRepository(DbContext context)
                {
                    Context = context;
                    _set = Context.Set<TEntity>();
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
            }
            """;

        await WriteFileAsync(Path.Combine(projectRoot, "EntityFramework", "Repositories", "EfRepository.cs"), repositoryBaseContent, cancellationToken).ConfigureAwait(false);
    }

    private async Task WriteStoredProcedureBaseAsync(string projectRoot, CancellationToken cancellationToken)
    {
        var content = $$"""
            using System.Data;
            using System.Data.Common;
            using Microsoft.EntityFrameworkCore;
            using Microsoft.EntityFrameworkCore.Infrastructure;

            namespace {{_projectName}}.StoredProcedure;

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
                    ArgumentException.ThrowIfNullOrWhiteSpace(storedProcedureName);

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
        builder.AppendLine($"using {_projectName}.StoredProcedure.Repositories;");
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
            builder.AppendLine($"        services.AddScoped<{entity.EntityName}StoredProcedureRepository>();");
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

        if (entity.KeyProperties.Count > 1)
        {
            builder.AppendLine($"[PrimaryKey({string.Join(", ", entity.KeyProperties.Select(p => $"nameof({p.PropertyName})"))})]");
        }

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
        builder.AppendLine("using Microsoft.EntityFrameworkCore;");
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
        builder.AppendLine($"    public async Task<PagedResult<{entity.EntityName}Dto>> GetAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        var query = _repository.Query();");
        builder.AppendLine("        var total = await query.CountAsync(cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        var entities = await query.AsNoTracking().Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync(cancellationToken).ConfigureAwait(false);");
        builder.AppendLine("        var items = entities.Select(MapToDto).ToList();");
        builder.AppendLine();
        builder.AppendLine($"        return new PagedResult<{entity.EntityName}Dto>");
        builder.AppendLine("        {");
        builder.AppendLine("            Items = items,");
        builder.AppendLine("            TotalCount = total,");
        builder.AppendLine("            PageNumber = pageNumber,");
        builder.AppendLine("            PageSize = pageSize");
        builder.AppendLine("        };");
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

    private async Task WriteStoredProcedureRepositoryAsync(string projectRoot, EntityMetadata entity, CancellationToken cancellationToken)
    {
        var builder = new StringBuilder();
        builder.AppendLine("using System.Data.Common;");
        builder.AppendLine($"using {_projectName}.EntityFramework.Data;");
        builder.AppendLine($"using {_projectName}.StoredProcedure;");
        builder.AppendLine();
        builder.AppendLine($"namespace {_projectName}.StoredProcedure.Repositories;");
        builder.AppendLine();
        builder.AppendLine($"public sealed class {entity.EntityName}StoredProcedureRepository : StoredProcedureRepository");
        builder.AppendLine("{");
        builder.AppendLine($"    public {entity.EntityName}StoredProcedureRepository(AppDbContext context) : base(context)");
        builder.AppendLine("    {");
        builder.AppendLine("    }");
        builder.AppendLine();
        builder.AppendLine("    public Task<int> ExecuteAsync(string storedProcedureName, IEnumerable<DbParameter> parameters, CancellationToken cancellationToken = default)");
        builder.AppendLine("    {");
        builder.AppendLine("        return base.ExecuteAsync(storedProcedureName, parameters, cancellationToken);");
        builder.AppendLine("    }");
        builder.AppendLine("}");

        await WriteFileAsync(Path.Combine(projectRoot, "StoredProcedure", "Repositories", $"{entity.EntityName}StoredProcedureRepository.cs"), builder.ToString(), cancellationToken).ConfigureAwait(false);
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
