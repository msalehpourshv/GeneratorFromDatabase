namespace Generator;

internal static class SolutionPathResolver
{
    public static string FindSolutionRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);

        while (current is not null)
        {
            var hasSolution = current.GetFiles("*.sln").Any();
            if (hasSolution)
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        throw new InvalidOperationException("Unable to locate the solution root. Ensure a .sln file exists above the running directory.");
    }
}
