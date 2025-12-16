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
        }

        return new TemplateMetadata
        {
            ProjectName = projectName,
            GeneratedOnUtc = DateTime.UtcNow,
            Entities = entities.OrderBy(e => e.EntityName, StringComparer.Ordinal).ToArray()
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
            var nullableType = column.IsNullable && !string.Equals(typeName, "string", StringComparison.OrdinalIgnoreCase)
                && !string.Equals(typeName, "byte[]", StringComparison.OrdinalIgnoreCase)
                ? $"{typeName}?"
                : typeName + (column.IsNullable && isReferenceType ? "?" : string.Empty);

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
