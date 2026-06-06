using Microsoft.Data.Sqlite;
using StudentManagement.Models;
using System.Data;

namespace StudentManagement.Database;

public class DatabaseHelper : IDisposable
{
    private readonly string _connectionString;

    public DatabaseHelper(string dbPath)
    {
        _connectionString = $"Data Source={dbPath}";
        InitializeDatabase();
    }

    private void InitializeDatabase()
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            CREATE TABLE IF NOT EXISTS Students (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                StudentNo VARCHAR(20) UNIQUE NOT NULL,
                Name NVARCHAR(50) NOT NULL,
                Gender NVARCHAR(10) NOT NULL,
                ClassName NVARCHAR(30) NOT NULL,
                Score INTEGER NOT NULL,
                CreateTime DATETIME NOT NULL DEFAULT (datetime('now','localtime'))
            )";
        cmd.ExecuteNonQuery();
    }

    public void AddStudent(Student s)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            INSERT INTO Students (StudentNo, Name, Gender, ClassName, Score, CreateTime)
            VALUES (@StudentNo, @Name, @Gender, @ClassName, @Score, @CreateTime)";
        cmd.Parameters.AddWithValue("@StudentNo", s.StudentNo);
        cmd.Parameters.AddWithValue("@Name", s.Name);
        cmd.Parameters.AddWithValue("@Gender", s.Gender);
        cmd.Parameters.AddWithValue("@ClassName", s.ClassName);
        cmd.Parameters.AddWithValue("@Score", s.Score);
        cmd.Parameters.AddWithValue("@CreateTime", s.CreateTime == default ? DateTime.Now : s.CreateTime);
        cmd.ExecuteNonQuery();
    }

    public void DeleteStudent(int id)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "DELETE FROM Students WHERE Id = @Id";
        cmd.Parameters.AddWithValue("@Id", id);
        cmd.ExecuteNonQuery();
    }

    public void UpdateStudent(Student s)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            UPDATE Students
            SET StudentNo = @StudentNo, Name = @Name, Gender = @Gender,
                ClassName = @ClassName, Score = @Score
            WHERE Id = @Id";
        cmd.Parameters.AddWithValue("@Id", s.Id);
        cmd.Parameters.AddWithValue("@StudentNo", s.StudentNo);
        cmd.Parameters.AddWithValue("@Name", s.Name);
        cmd.Parameters.AddWithValue("@Gender", s.Gender);
        cmd.Parameters.AddWithValue("@ClassName", s.ClassName);
        cmd.Parameters.AddWithValue("@Score", s.Score);
        cmd.ExecuteNonQuery();
    }

    public List<Student> GetAllStudents()
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT * FROM Students ORDER BY Id DESC";
        return ReadStudents(cmd);
    }

    public List<Student> SearchStudents(string keyword)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            SELECT * FROM Students
            WHERE StudentNo LIKE @Keyword OR Name LIKE @Keyword
            ORDER BY Id DESC";
        cmd.Parameters.AddWithValue("@Keyword", $"%{keyword}%");
        return ReadStudents(cmd);
    }

    public List<Student> GetStudentsSortedByScore()
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT * FROM Students ORDER BY Score DESC";
        return ReadStudents(cmd);
    }

    public bool StudentNoExists(string studentNo)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT COUNT(*) FROM Students WHERE StudentNo = @StudentNo";
        cmd.Parameters.AddWithValue("@StudentNo", studentNo);
        return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
    }

    public bool StudentNoExistsExceptId(string studentNo, int excludeId)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT COUNT(*) FROM Students WHERE StudentNo = @StudentNo AND Id != @Id";
        cmd.Parameters.AddWithValue("@StudentNo", studentNo);
        cmd.Parameters.AddWithValue("@Id", excludeId);
        return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
    }

    public void BulkInsert(List<Student> students)
    {
        using var connection = new SqliteConnection(_connectionString);
        connection.Open();
        using var transaction = connection.BeginTransaction();
        using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            INSERT OR IGNORE INTO Students (StudentNo, Name, Gender, ClassName, Score, CreateTime)
            VALUES (@StudentNo, @Name, @Gender, @ClassName, @Score, @CreateTime)";
        var pNo = cmd.CreateParameter();
        pNo.ParameterName = "@StudentNo";
        cmd.Parameters.Add(pNo);
        var pName = cmd.CreateParameter();
        pName.ParameterName = "@Name";
        cmd.Parameters.Add(pName);
        var pGender = cmd.CreateParameter();
        pGender.ParameterName = "@Gender";
        cmd.Parameters.Add(pGender);
        var pClass = cmd.CreateParameter();
        pClass.ParameterName = "@ClassName";
        cmd.Parameters.Add(pClass);
        var pScore = cmd.CreateParameter();
        pScore.ParameterName = "@Score";
        cmd.Parameters.Add(pScore);
        var pTime = cmd.CreateParameter();
        pTime.ParameterName = "@CreateTime";
        cmd.Parameters.Add(pTime);

        foreach (var s in students)
        {
            pNo.Value = s.StudentNo;
            pName.Value = s.Name;
            pGender.Value = s.Gender;
            pClass.Value = s.ClassName;
            pScore.Value = s.Score;
            pTime.Value = s.CreateTime == default ? DateTime.Now : s.CreateTime;
            cmd.ExecuteNonQuery();
        }
        transaction.Commit();
    }

    private List<Student> ReadStudents(SqliteCommand cmd)
    {
        var list = new List<Student>();
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            list.Add(new Student
            {
                Id = reader.GetInt32(0),
                StudentNo = reader.GetString(1),
                Name = reader.GetString(2),
                Gender = reader.GetString(3),
                ClassName = reader.GetString(4),
                Score = reader.GetInt32(5),
                CreateTime = reader.GetDateTime(6)
            });
        }
        return list;
    }

    public void Dispose()
    {
        SqliteConnection.ClearAllPools();
    }
}
