using SchemaReader;

namespace Generator;

public sealed class GeneratorService
{
    private readonly ISchemaReader _schemaReader;

    public GeneratorService(ISchemaReader schemaReader)
    {
        _schemaReader = schemaReader;
    }

    public async Task<GeneratorResult> ExecuteAsync(string connectionString, CancellationToken cancellationToken = default)
    {
        var schemaJson = await _schemaReader.ReadSchemaAsync(connectionString, cancellationToken).ConfigureAwait(false);

        return new GeneratorResult
        {
            Status = "Completed",
            SchemaJson = schemaJson
        };
    }
}
