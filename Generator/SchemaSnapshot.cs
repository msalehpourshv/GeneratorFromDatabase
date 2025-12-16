using SchemaReader;

namespace Generator;

public sealed class SchemaSnapshot
{
    public string Status { get; init; } = string.Empty;

    public DatabaseSchema? Schema { get; init; }
}
