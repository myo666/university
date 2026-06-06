namespace StudentManagement.Models;

public class Student
{
    public int Id { get; set; }
    public string StudentNo { get; set; } = "";
    public string Name { get; set; } = "";
    public string Gender { get; set; } = "";
    public string ClassName { get; set; } = "";
    public int Score { get; set; }
    public DateTime CreateTime { get; set; }
}
