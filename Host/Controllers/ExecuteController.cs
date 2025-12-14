using Generator;
using Microsoft.AspNetCore.Mvc;

namespace Host.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ExecuteController : ControllerBase
{
    private readonly GeneratorService _generator;

    public ExecuteController(GeneratorService generator)
    {
        _generator = generator;
    }

    [HttpPost]
    public async Task<ActionResult<GeneratorResult>> Execute([FromBody] GenerationRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.ConnectionString))
        {
            return BadRequest("A connection string is required.");
        }

        var result = await _generator.ExecuteAsync(request.ConnectionString, HttpContext.RequestAborted);
        return Ok(result);
    }
}

public sealed class GenerationRequest
{
    public string ConnectionString { get; init; } = string.Empty;
}
