using SchemaReader;

namespace Generator.Metadata;

internal static class ColumnTypeMapper
{
    public static (string TypeName, bool IsReferenceType) MapToClrType(ColumnInfo column)
    {
        var dataType = column.DataType.ToLowerInvariant();

        return dataType switch
        {
            "bigint" => ("long", false),
            "binary" or "varbinary" or "image" => ("byte[]", true),
            "bit" => ("bool", false),
            "char" or "nchar" or "ntext" or "text" or "varchar" or "nvarchar" => ("string", true),
            "date" or "datetime" or "datetime2" or "smalldatetime" => ("DateTime", false),
            "datetimeoffset" => ("DateTimeOffset", false),
            "decimal" or "numeric" or "money" or "smallmoney" => ("decimal", false),
            "float" => ("double", false),
            "int" => ("int", false),
            "real" => ("float", false),
            "smallint" => ("short", false),
            "time" => ("TimeSpan", false),
            "tinyint" => ("byte", false),
            "uniqueidentifier" => ("Guid", false),
            "xml" => ("string", true),
            _ => ("string", true)
        };
    }
}
