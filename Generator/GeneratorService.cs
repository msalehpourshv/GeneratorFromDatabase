using System.Net.Http;

namespace Generator;

public sealed class GeneratorService
{

    public GeneratorService()
    {
    }

    public async Task<GeneratorResult> ExecuteGenAsync()
    {
        return new GeneratorResult
        {
            Status = "Completed"
        };
    }
}
