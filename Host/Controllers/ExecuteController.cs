using Generator;
using Microsoft.AspNetCore.Mvc;

namespace Host.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ExecuteController : ControllerBase
{
    private readonly GeneratorService _generator;
    private readonly IConfiguration _config;

    public ExecuteController(GeneratorService generator, IConfiguration config)
    {
        _generator = generator;
        _config = config;
    }

    [HttpPost]
    public async Task<ActionResult<GeneratorResult>> Execute()
    {
        string conn = _config.GetConnectionString("DefaultConnection") ?? "";
        string output = Path.Combine(Directory.GetCurrentDirectory(), "Generated");

        var result = await _generator.ExecuteAsync(conn, output, HttpContext.RequestAborted);
        return Ok(result);
    }
}

public sealed class GenerationRequest
{
    public string ConnectionString { get; init; } = string.Empty;
}
