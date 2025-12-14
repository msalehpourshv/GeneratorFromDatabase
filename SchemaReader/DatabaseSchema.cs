namespace SchemaReader;

public sealed class DatabaseSchema
{
    public string Connection { get; init; } = string.Empty;

    public IReadOnlyList<SchemaInfo> Schemas { get; init; } = Array.Empty<SchemaInfo>();
}

public sealed class SchemaInfo
{
    public string Name { get; init; } = string.Empty;

    public IReadOnlyList<TableInfo> Tables { get; init; } = Array.Empty<TableInfo>();
}

public sealed class TableInfo
{
    public string Name { get; init; } = string.Empty;

    public IReadOnlyList<ColumnInfo> Columns { get; init; } = Array.Empty<ColumnInfo>();
}

public sealed class ColumnInfo
{
    public string Name { get; init; } = string.Empty;

    public string DataType { get; init; } = string.Empty;

    public bool IsNullable { get; init; }

    public string? DefaultValue { get; init; }
}
