using SchemaReader;

namespace Generator;

public sealed class GeneratorService
{
    private readonly ISchemaReader _schemaReader;

    public GeneratorService(ISchemaReader schemaReader)
    {
        _schemaReader = schemaReader;
    }

    public async Task<GeneratorResult> ExecuteAsync(string connectionString, string outputDirectory, CancellationToken cancellationToken = default)
    {
        var schema = await _schemaReader.ReadSchemaAsync(connectionString, cancellationToken).ConfigureAwait(false);

        return new GeneratorResult
        {
            Status = "Completed",
            Schema = schema
        };
    }
}
