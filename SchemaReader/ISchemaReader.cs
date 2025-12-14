using System.Threading;
using System.Threading.Tasks;

namespace SchemaReader;

public interface ISchemaReader
{
    Task<string> ReadSchemaAsync(string connectionString, CancellationToken cancellationToken = default);
}
