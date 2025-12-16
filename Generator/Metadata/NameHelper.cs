using System.Text;
using System.Text.RegularExpressions;

namespace Generator.Metadata;

internal static partial class NameHelper
{
    private static readonly Regex Separator = GetSeparatorRegex();

    private static readonly Regex NonEnglishRegex = GetNonEnglishRegex();

    public static string ToPascalCase(string rawName)
    {
        if (string.IsNullOrWhiteSpace(rawName))
        {
            return string.Empty;
        }

        var cleaned = rawName.Replace("`", "");
        var tokens = Separator.Split(cleaned)
            .Where(token => !string.IsNullOrWhiteSpace(token))
            .ToArray();

        if (tokens.Length == 0)
        {
            return char.IsLetter(cleaned[0]) ? cleaned : $"T{cleaned}";
        }

        var builder = new StringBuilder();
        foreach (var token in tokens)
        {
            builder.Append(char.ToUpperInvariant(token[0]));
            if (token.Length > 1)
            {
                builder.Append(token[1..]);
            }
        }

        var candidate = builder.ToString();
        return char.IsLetter(candidate[0]) ? candidate : $"T{candidate}";
    }

    public static bool ContainsNonEnglishLetters(string rawName)
    {
        return NonEnglishRegex.IsMatch(rawName);
    }

    [GeneratedRegex("[^a-zA-Z0-9]+")]
    private static partial Regex GetSeparatorRegex();

    [GeneratedRegex("[^\\p{IsBasicLatin}]")]
    private static partial Regex GetNonEnglishRegex();
}
