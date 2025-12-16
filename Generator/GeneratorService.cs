using System.Text.Json;
using Generator.Metadata;
using Generator.Templates;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Generator;

public sealed class GeneratorService
{
    private readonly ILogger<GeneratorService> _logger;
    private readonly GeneratorOptions _options;

    public GeneratorService(ILogger<GeneratorService> logger, IOptions<GeneratorOptions> options)
    {
        _logger = logger;
        _options = options.Value;
    }

    public async Task<GeneratorResult> ExecuteGenAsync(CancellationToken cancellationToken = default)
    {
        var solutionRoot = SolutionPathResolver.FindSolutionRoot();
        var schemaPath = ResolveSchemaPath(_options.SchemaResultPath, solutionRoot);

        _logger.LogInformation("Using schema snapshot at {SchemaPath}", schemaPath);

        var snapshot = await LoadSchemaSnapshotAsync(schemaPath, cancellationToken).ConfigureAwait(false);
        if (snapshot.Schema is null)
        {
            throw new InvalidOperationException("Schema snapshot is missing the schema payload.");
        }

        var metadataBuilder = new TemplateMetadataBuilder();
        var metadata = metadataBuilder.Build(snapshot.Schema, _options.CustomLibraryName, _options.ExcludedTables);

        var outputDirectory = Path.Combine(solutionRoot, _options.OutputDirectoryName);
        Directory.CreateDirectory(outputDirectory);
        var metadataPath = Path.Combine(outputDirectory, "template-metadata.json");

        await metadataBuilder.WriteMetadataAsync(metadata, metadataPath, cancellationToken).ConfigureAwait(false);
        _logger.LogInformation("Metadata written to {MetadataPath}", metadataPath);

        var projectRoot = ResolveProjectRoot(solutionRoot, _options.CustomLibraryPath, _options.CustomLibraryName);
        var renderer = new TemplateRenderer(_options.CustomLibraryName);
        await renderer.RenderAsync(metadata, projectRoot, cancellationToken).ConfigureAwait(false);

        _logger.LogInformation("Generated class library scaffold at {ProjectRoot}", projectRoot);

        return new GeneratorResult
        {
            Status = string.IsNullOrWhiteSpace(snapshot.Status) ? "Completed" : snapshot.Status,
            SchemaPath = schemaPath,
            MetadataPath = metadataPath,
            ProjectPath = projectRoot,
            EntityCount = metadata.Entities.Count
        };
    }

    private static string ResolveSchemaPath(string configuredPath, string solutionRoot)
    {
        if (Path.IsPathRooted(configuredPath))
        {
            return configuredPath;
        }

        return Path.Combine(solutionRoot, configuredPath);
    }

    private static string ResolveProjectRoot(string solutionRoot, string? configuredPath, string libraryName)
    {
        if (!string.IsNullOrWhiteSpace(configuredPath))
        {
            return Path.IsPathRooted(configuredPath)
                ? configuredPath
                : Path.Combine(solutionRoot, configuredPath);
        }

        return Path.Combine(solutionRoot, libraryName);
    }

    private static async Task<SchemaSnapshot> LoadSchemaSnapshotAsync(string path, CancellationToken cancellationToken)
    {
        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Schema snapshot not found at {path}");
        }

        await using var stream = File.OpenRead(path);
        var snapshot = await JsonSerializer.DeserializeAsync<SchemaSnapshot>(stream, new JsonSerializerOptions(JsonSerializerDefaults.General)
        {
            PropertyNameCaseInsensitive = true
        }, cancellationToken).ConfigureAwait(false);

        if (snapshot is null)
        {
            throw new InvalidOperationException("Unable to deserialize schema snapshot.");
        }

        return snapshot;
    }
}
