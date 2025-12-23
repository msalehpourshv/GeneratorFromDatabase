using Generator;
using Microsoft.AspNetCore.Mvc;
using SchemaReader;

namespace Host.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ExecuteController : ControllerBase
{
    private readonly GeneratorService _generator;
    private readonly IConfiguration _config;
    private readonly ISchemaReader _schemaReader;
    private readonly ILogger<ExecuteController> _logger;

    public ExecuteController(GeneratorService generator, IConfiguration config, ISchemaReader schemaReader, ILogger<ExecuteController> logger)
    {
        _schemaReader = schemaReader;
        _generator = generator;
        _config = config;
        _logger = logger;
    }

    [HttpPost("generate")]
    public async Task<ActionResult<GeneratorResult>> ExecuteGen(CancellationToken cancellationToken)
    {
        var result = await _generator.ExecuteGenAsync(cancellationToken);
        return Ok(result);
    }

    [HttpGet("schema")]
    public async Task<IActionResult> ExecuteReadSchema(CancellationToken cancellationToken)
    {
        var conn = _config.GetConnectionString("DefaultConnection") ?? string.Empty;

        try
        {
            await _schemaReader.ReadSchemaAsync(conn, cancellationToken).ConfigureAwait(false);
            var message = $"انجام شد. خروجی در مسیر {SchemaReaderService.SchemaResultFilePath} ذخیره شد.";
            return Ok(new { status = "success", message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to read schema");
            var message = $"انجام نشد: {ex.Message}";
            return StatusCode(StatusCodes.Status500InternalServerError, new { status = "error", message });
        }

    }
}

public sealed class GenerationRequest
{
    public string ConnectionString { get; init; } = string.Empty;
}
