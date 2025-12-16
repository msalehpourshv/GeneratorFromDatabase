using Generator;
using SchemaReader;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379";
    options.InstanceName = "schema:";
});
builder.Services.Configure<GeneratorOptions>(builder.Configuration.GetSection("Generator"));
builder.Services.AddSingleton<ISchemaReader, SchemaReaderService>();
builder.Services.AddTransient<GeneratorService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/", () => Results.Redirect("/swagger"));
app.MapControllers();

app.Run();
