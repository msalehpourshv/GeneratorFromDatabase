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

    public IReadOnlyList<ViewInfo> Views { get; init; } = Array.Empty<ViewInfo>();

    public IReadOnlyList<StoredProcedureInfo> StoredProcedures { get; init; } = Array.Empty<StoredProcedureInfo>();

    public IReadOnlyList<FunctionInfo> Functions { get; init; } = Array.Empty<FunctionInfo>();
}

public sealed class TableInfo
{
    public string Name { get; init; } = string.Empty;

    public IReadOnlyList<ColumnInfo> Columns { get; init; } = Array.Empty<ColumnInfo>();

    public PrimaryKeyInfo? PrimaryKey { get; init; }

    public IReadOnlyList<ForeignKeyInfo> ForeignKeys { get; init; } = Array.Empty<ForeignKeyInfo>();

    public IReadOnlyList<IndexInfo> Indexes { get; init; } = Array.Empty<IndexInfo>();
}

public sealed class ColumnInfo
{
    public string Name { get; init; } = string.Empty;

    public string DataType { get; init; } = string.Empty;

    public bool IsNullable { get; init; }

    public string? DefaultValue { get; init; }

    public bool IsIdentity { get; init; }

    public bool IsComputed { get; init; }

    public int? MaxLength { get; init; }

    public byte? Precision { get; init; }

    public int? Scale { get; init; }
}

public sealed class PrimaryKeyInfo
{
    public string Name { get; init; } = string.Empty;

    public IReadOnlyList<string> Columns { get; init; } = Array.Empty<string>();
}

public sealed class ForeignKeyInfo
{
    public string Name { get; init; } = string.Empty;

    public string ReferencedTable { get; init; } = string.Empty;

    public IReadOnlyList<ForeignKeyColumn> Columns { get; init; } = Array.Empty<ForeignKeyColumn>();
}

public sealed class ForeignKeyColumn
{
    public string Column { get; init; } = string.Empty;

    public string ReferencedColumn { get; init; } = string.Empty;
}

public sealed class IndexInfo
{
    public string Name { get; init; } = string.Empty;

    public bool IsUnique { get; init; }

    public bool IsPrimaryKey { get; init; }

    public IReadOnlyList<string> Columns { get; init; } = Array.Empty<string>();

    public IReadOnlyList<string> IncludedColumns { get; init; } = Array.Empty<string>();

    public string? FilterDefinition { get; init; }
}

public sealed class ViewInfo
{
    public string Name { get; init; } = string.Empty;

    public string Definition { get; init; } = string.Empty;

    public IReadOnlyList<ColumnInfo> Columns { get; init; } = Array.Empty<ColumnInfo>();
}

public sealed class StoredProcedureInfo
{
    public string Name { get; init; } = string.Empty;

    public string Definition { get; init; } = string.Empty;

    public IReadOnlyList<ParameterInfo> Parameters { get; init; } = Array.Empty<ParameterInfo>();
}

public sealed class FunctionInfo
{
    public string Name { get; init; } = string.Empty;

    public string Definition { get; init; } = string.Empty;

    public string ReturnType { get; init; } = string.Empty;

    public IReadOnlyList<ParameterInfo> Parameters { get; init; } = Array.Empty<ParameterInfo>();
}

public sealed class ParameterInfo
{
    public string Name { get; init; } = string.Empty;

    public string DataType { get; init; } = string.Empty;

    public bool IsOutput { get; init; }

    public bool IsNullable { get; init; }

    public int? MaxLength { get; init; }

    public byte? Precision { get; init; }

    public int? Scale { get; init; }

    public string? DefaultValue { get; init; }
}
