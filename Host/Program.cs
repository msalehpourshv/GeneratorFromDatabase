using Generator;
using SchemaReader;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddSingleton<ISchemaReader, SchemaReaderService>();
builder.Services.AddTransient<GeneratorService>();

var app = builder.Build();

app.MapControllers();

app.Run();
