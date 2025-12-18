namespace Generator.Metadata;

public sealed class TemplateMetadata
{
    public string ProjectName { get; init; } = string.Empty;

    public DateTime GeneratedOnUtc { get; init; } = DateTime.UtcNow;

    public IReadOnlyList<EntityMetadata> Entities { get; init; } = Array.Empty<EntityMetadata>();

    public IReadOnlyList<StoredProcedureMetadata> StoredProcedures { get; init; } = Array.Empty<StoredProcedureMetadata>();

    public IReadOnlyList<FunctionMetadata> Functions { get; init; } = Array.Empty<FunctionMetadata>();
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

public sealed class StoredProcedureMetadata
{
    public string SchemaName { get; init; } = string.Empty;

    public string Name { get; init; } = string.Empty;

    public string Code { get; init; } = string.Empty;

    public IReadOnlyList<ParameterMetadata> Properties { get; init; } = Array.Empty<ParameterMetadata>();
}

public sealed class FunctionMetadata
{
    public string SchemaName { get; init; } = string.Empty;

    public string Name { get; init; } = string.Empty;

    public string Code { get; init; } = string.Empty;

    public string ReturnType { get; init; } = string.Empty;

    public string ReturnClrTypeName { get; init; } = string.Empty;

    public string ReturnClrTypeNameWithoutNullability { get; init; } = string.Empty;

    public bool IsReturnTypeReferenceType { get; init; }

    public bool IsTableValued { get; init; }

    public IReadOnlyList<ParameterMetadata> Properties { get; init; } = Array.Empty<ParameterMetadata>();
}

public sealed class ParameterMetadata
{
    public string Name { get; init; } = string.Empty;

    public string PropertyName { get; init; } = string.Empty;

    public string SqlTypeName { get; init; } = string.Empty;

    public string ClrTypeName { get; init; } = string.Empty;

    public string ClrTypeNameWithoutNullability { get; init; } = string.Empty;

    public bool IsNullable { get; init; }

    public bool IsOutput { get; init; }

    public bool IsReferenceType { get; init; }

    public string? DefaultValue { get; init; }

    public int? MaxLength { get; init; }

    public byte? Precision { get; init; }

    public int? Scale { get; init; }
}
