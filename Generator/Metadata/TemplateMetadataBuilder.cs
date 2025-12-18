using System.Text.Json;
using SchemaReader;

namespace Generator.Metadata;

internal sealed class TemplateMetadataBuilder
{
    public TemplateMetadata Build(DatabaseSchema schema, string projectName, IReadOnlyCollection<string> excludedTables)
    {
        ArgumentNullException.ThrowIfNull(schema);
        excludedTables ??= Array.Empty<string>();

        var entities = new List<EntityMetadata>();
        var storedProcedures = new List<StoredProcedureMetadata>();
        var functions = new List<FunctionMetadata>();

        foreach (var schemaInfo in schema.Schemas)
        {
            foreach (var table in schemaInfo.Tables)
            {
                if (excludedTables.Contains(table.Name, StringComparer.OrdinalIgnoreCase))
                {
                    continue;
                }

                var properties = BuildProperties(table);
                var keyColumns = (table.PrimaryKey?.Columns ?? Array.Empty<string>())
                    .Select(name => properties.FirstOrDefault(p => string.Equals(p.ColumnName, name, StringComparison.OrdinalIgnoreCase)))
                    .Where(p => p is not null)
                    .Cast<PropertyMetadata>()
                    .ToArray();

                entities.Add(new EntityMetadata
                {
                    SchemaName = schemaInfo.Name,
                    TableName = table.Name,
                    EntityName = NameHelper.ToPascalCase(table.Name),
                    Properties = properties,
                    KeyProperties = keyColumns
                });
            }

            foreach (var storedProcedure in schemaInfo.StoredProcedures)
            {
                var properties = BuildParameters(storedProcedure.Parameters);

                storedProcedures.Add(new StoredProcedureMetadata
                {
                    SchemaName = schemaInfo.Name,
                    Name = storedProcedure.Name,
                    Code = storedProcedure.Definition,
                    Properties = properties
                });
            }

            foreach (var function in schemaInfo.Functions)
            {
                var properties = BuildParameters(function.Parameters);
                var (returnClrType, isReferenceType) = ColumnTypeMapper.MapToClrType(function.ReturnType);

                functions.Add(new FunctionMetadata
                {
                    SchemaName = schemaInfo.Name,
                    Name = function.Name,
                    Code = function.Definition,
                    ReturnType = function.ReturnType,
                    ReturnClrTypeName = BuildClrTypeName(returnClrType, isNullable: false, isReferenceType),
                    ReturnClrTypeNameWithoutNullability = returnClrType,
                    IsReturnTypeReferenceType = isReferenceType,
                    IsTableValued = string.Equals(function.ReturnType, "table", StringComparison.OrdinalIgnoreCase),
                    Properties = properties
                });
            }
        }

        return new TemplateMetadata
        {
            ProjectName = projectName,
            GeneratedOnUtc = DateTime.UtcNow,
            Entities = entities.OrderBy(e => e.EntityName, StringComparer.Ordinal).ToArray(),
            StoredProcedures = storedProcedures
                .OrderBy(p => p.SchemaName, StringComparer.Ordinal)
                .ThenBy(p => p.Name, StringComparer.Ordinal)
                .ToArray(),
            Functions = functions
                .OrderBy(f => f.SchemaName, StringComparer.Ordinal)
                .ThenBy(f => f.Name, StringComparer.Ordinal)
                .ToArray()
        };
    }

    public async Task WriteMetadataAsync(TemplateMetadata metadata, string outputPath, CancellationToken cancellationToken)
    {
        var directory = Path.GetDirectoryName(outputPath);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        var json = JsonSerializer.Serialize(metadata, new JsonSerializerOptions(JsonSerializerDefaults.General)
        {
            WriteIndented = true
        });

        await File.WriteAllTextAsync(outputPath, json, cancellationToken).ConfigureAwait(false);
    }

    private static PropertyMetadata[] BuildProperties(TableInfo table)
    {
        var properties = new List<PropertyMetadata>();
        var nameCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        foreach (var column in table.Columns)
        {
            if (NameHelper.ContainsNonEnglishLetters(column.Name))
            {
                continue;
            }

            var (typeName, isReferenceType) = ColumnTypeMapper.MapToClrType(column);
            var nullableType = BuildClrTypeName(typeName, column.IsNullable, isReferenceType);

            var propertyName = EnsureUniqueName(NameHelper.ToPascalCase(column.Name), nameCounts);

            properties.Add(new PropertyMetadata
            {
                ColumnName = column.Name,
                PropertyName = propertyName,
                ClrTypeName = nullableType,
                ClrTypeNameWithoutNullability = typeName,
                IsNullable = column.IsNullable,
                IsIdentity = column.IsIdentity,
                IsPrimaryKey = table.PrimaryKey?.Columns?.Any(c => string.Equals(c, column.Name, StringComparison.OrdinalIgnoreCase)) == true,
                IsReferenceType = isReferenceType
            });
        }

        return properties.ToArray();
    }

    private static ParameterMetadata[] BuildParameters(IReadOnlyList<ParameterInfo> parameters)
    {
        var properties = new List<ParameterMetadata>();
        var nameCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        foreach (var parameter in parameters)
        {
            if (NameHelper.ContainsNonEnglishLetters(parameter.Name))
            {
                continue;
            }

            var (typeName, isReferenceType) = ColumnTypeMapper.MapToClrType(parameter.DataType);
            var nullableType = BuildClrTypeName(typeName, parameter.IsNullable, isReferenceType);

            var formattedName = parameter.Name.StartsWith("@", StringComparison.Ordinal) ? parameter.Name[1..] : parameter.Name;
            var propertyName = EnsureUniqueName(NameHelper.ToPascalCase(formattedName), nameCounts);

            properties.Add(new ParameterMetadata
            {
                Name = parameter.Name,
                PropertyName = propertyName,
                SqlTypeName = parameter.DataType,
                ClrTypeName = nullableType,
                ClrTypeNameWithoutNullability = typeName,
                IsNullable = parameter.IsNullable,
                IsOutput = parameter.IsOutput,
                IsReferenceType = isReferenceType,
                DefaultValue = parameter.DefaultValue,
                MaxLength = parameter.MaxLength,
                Precision = parameter.Precision,
                Scale = parameter.Scale
            });
        }

        return properties.ToArray();
    }

    private static string BuildClrTypeName(string typeName, bool isNullable, bool isReferenceType)
    {
        if (isNullable && !string.Equals(typeName, "string", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(typeName, "byte[]", StringComparison.OrdinalIgnoreCase))
        {
            return $"{typeName}?";
        }

        return typeName + (isNullable && isReferenceType ? "?" : string.Empty);
    }

    private static string EnsureUniqueName(string candidate, IDictionary<string, int> nameCounts)
    {
        if (!nameCounts.TryGetValue(candidate, out var count))
        {
            nameCounts[candidate] = 1;
            return candidate;
        }

        count++;
        nameCounts[candidate] = count;
        return $"{candidate}{count}";
    }
}
