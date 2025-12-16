namespace Generator;

public sealed class GeneratorOptions
{
    /// <summary>
    /// The relative or absolute path of the schema snapshot produced by the schema reader.
    /// </summary>
    public string SchemaResultPath { get; init; } = Path.Combine("SchemaReader", "SchemaReaderResult.json");

    /// <summary>
    /// Directory name used to emit helper files such as the normalized metadata document.
    /// </summary>
    public string OutputDirectoryName { get; init; } = "Generated";

    /// <summary>
    /// The name of the generated class library that will hold the scaffolded code.
    /// </summary>
    public string CustomLibraryName { get; init; } = "CustomGeneratedLibrary";
}
