namespace Generator;

public sealed class GeneratorResult
{
    public string Status { get; init; } = "Pending";

    public string SchemaJson { get; init; } = string.Empty;
}
