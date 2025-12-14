using System.Text.Json;

namespace SchemaReader;

public sealed class SchemaReaderService : ISchemaReader
{
    public Task<string> ReadSchemaAsync(string connectionString, CancellationToken cancellationToken = default)
    {
        var schema = BuildMockSchema(connectionString);
        var json = JsonSerializer.Serialize(schema, new JsonSerializerOptions { WriteIndented = true });
        return Task.FromResult(json);
    }

    private static DatabaseSchema BuildMockSchema(string connectionString)
    {
        return new DatabaseSchema
        {
            Connection = connectionString,
            Schemas = new[]
            {
                new SchemaInfo
                {
                    Name = "dbo",
                    Tables = new[]
                    {
                        new TableInfo
                        {
                            Name = "SampleTable",
                            Columns = new[]
                            {
                                new ColumnInfo
                                {
                                    Name = "Id",
                                    DataType = "int",
                                    IsNullable = false,
                                    DefaultValue = "IDENTITY(1,1)"
                                },
                                new ColumnInfo
                                {
                                    Name = "Name",
                                    DataType = "nvarchar(200)",
                                    IsNullable = false
                                }
                            }
                        }
                    }
                }
            }
        };
    }
}
