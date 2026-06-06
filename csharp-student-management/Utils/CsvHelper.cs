using StudentManagement.Models;
using System.Text;

namespace StudentManagement.Utils;

public static class CsvHelper
{
    public const string Header = "StudentNo,Name,Gender,ClassName,Score";

    public static List<Student> ImportFromCsv(string filePath)
    {
        var students = new List<Student>();
        var lines = File.ReadAllLines(filePath, Encoding.UTF8);

        for (int i = 0; i < lines.Length; i++)
        {
            var line = lines[i].Trim();
            if (string.IsNullOrEmpty(line)) continue;

            // Skip header row
            if (i == 0 && line.StartsWith("StudentNo", StringComparison.OrdinalIgnoreCase))
                continue;

            var parts = line.Split(',');
            if (parts.Length < 5) continue;

            if (!int.TryParse(parts[4].Trim(), out var score)) continue;

            students.Add(new Student
            {
                StudentNo = parts[0].Trim(),
                Name = parts[1].Trim(),
                Gender = parts[2].Trim(),
                ClassName = parts[3].Trim(),
                Score = score,
                CreateTime = DateTime.Now
            });
        }

        return students;
    }

    public static void ExportToCsv(string filePath, List<Student> students)
    {
        var sb = new StringBuilder();
        sb.AppendLine(Header);
        foreach (var s in students)
        {
            sb.AppendLine($"{s.StudentNo},{s.Name},{s.Gender},{s.ClassName},{s.Score}");
        }
        File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
    }
}
