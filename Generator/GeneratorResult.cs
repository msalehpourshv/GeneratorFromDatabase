using SchemaReader;

namespace Generator;

public sealed class GeneratorResult
{

    public string Status { get; init; } = "Pending";

    public string? SchemaPath { get; init; }

    public string? MetadataPath { get; init; }

    public string? ProjectPath { get; init; }

    public int EntityCount { get; init; }
}
