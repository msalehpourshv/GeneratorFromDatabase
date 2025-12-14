using System.Threading;
using System.Threading.Tasks;

namespace SchemaReader;

public interface ISchemaReader
{
    Task<DatabaseSchema> ReadSchemaAsync(string connectionString, CancellationToken cancellationToken = default);
}
