namespace Generator.Metadata;

public sealed class TemplateMetadata
{
    public string ProjectName { get; init; } = string.Empty;

    public DateTime GeneratedOnUtc { get; init; } = DateTime.UtcNow;

    public IReadOnlyList<EntityMetadata> Entities { get; init; } = Array.Empty<EntityMetadata>();
}

public sealed class EntityMetadata
{
    public string SchemaName { get; init; } = string.Empty;

    public string TableName { get; init; } = string.Empty;

    public string EntityName { get; init; } = string.Empty;

    public bool HasPrimaryKey => KeyProperties.Count > 0;

    public bool HasCompositeKey => KeyProperties.Count > 1;

    public IReadOnlyList<PropertyMetadata> Properties { get; init; } = Array.Empty<PropertyMetadata>();

    public IReadOnlyList<PropertyMetadata> KeyProperties { get; init; } = Array.Empty<PropertyMetadata>();
}

public sealed class PropertyMetadata
{
    public string ColumnName { get; init; } = string.Empty;

    public string PropertyName { get; init; } = string.Empty;

    public string ClrTypeName { get; init; } = string.Empty;

    public string ClrTypeNameWithoutNullability { get; init; } = string.Empty;

    public bool IsNullable { get; init; }

    public bool IsPrimaryKey { get; init; }

    public bool IsIdentity { get; init; }

    public bool IsReferenceType { get; init; }
}
