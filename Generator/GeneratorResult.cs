using SchemaReader;

namespace Generator;

public sealed class GeneratorResult
{

    public string Connection { get; init; } = "";

    public string? SchemaPath { get; init; }

    public string? MetadataPath { get; init; }

    public string? ProjectPath { get; init; }

    public int EntityCount { get; init; }
}
