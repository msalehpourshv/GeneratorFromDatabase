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

    public ExecuteController(GeneratorService generator, IConfiguration config, ISchemaReader schemaReader)
    {
        _schemaReader = schemaReader;
        _generator = generator;
        _config = config;
    }

    [HttpPost]
    public async Task<ActionResult<GeneratorResult>> ExecuteGen()
    {
        var result = await _generator.ExecuteGenAsync();
        return Ok(result);
    }

    public async Task<ActionResult<DatabaseSchema>> ExecuteReadSchema()
    {
        string conn = _config.GetConnectionString("DefaultConnection") ?? "";
        string output = Path.Combine(Directory.GetCurrentDirectory(), "Generated");
        CancellationToken cancellationToken = HttpContext.RequestAborted;

        DatabaseSchema schema = await _schemaReader.ReadSchemaAsync(conn, cancellationToken).ConfigureAwait(false);

        return schema;
    }
}

public sealed class GenerationRequest
{
    public string ConnectionString { get; init; } = string.Empty;
}
