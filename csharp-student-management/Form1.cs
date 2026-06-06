using StudentManagement.Database;
using StudentManagement.Models;
using StudentManagement.Utils;

namespace StudentManagement;

public partial class Form1 : Form
{
    private DatabaseHelper _db = null!;
    private bool _isSortedByScore = false;

    private TextBox txtSearch = null!;
    private Button btnSearch = null!;
    private Button btnRefresh = null!;
    private DataGridView dgvStudents = null!;
    private TextBox txtStudentNo = null!;
    private TextBox txtName = null!;
    private ComboBox cmbGender = null!;
    private TextBox txtClass = null!;
    private TextBox txtScore = null!;
    private Button btnAdd = null!;
    private Button btnUpdate = null!;
    private Button btnDelete = null!;
    private Button btnSort = null!;
    private Button btnImport = null!;
    private Button btnExport = null!;
    private Label lblId = null!;
    private StatusStrip statusStrip = null!;
    private ToolStripStatusLabel toolStatus = null!;

    public Form1()
    {
        InitializeComponent();
        InitializeDatabase();
        WireEvents();
        LoadData();
    }

    private void InitializeDatabase()
    {
        var dbPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "StudentDB.sqlite");
        _db = new DatabaseHelper(dbPath);
    }

    private void WireEvents()
    {
        btnSearch.Click += BtnSearch_Click;
        btnRefresh.Click += BtnRefresh_Click;
        btnAdd.Click += BtnAdd_Click;
        btnUpdate.Click += BtnUpdate_Click;
        btnDelete.Click += BtnDelete_Click;
        btnSort.Click += BtnSort_Click;
        btnImport.Click += BtnImport_Click;
        btnExport.Click += BtnExport_Click;
        dgvStudents.SelectionChanged += DgvStudents_SelectionChanged;
    }

    private void LoadData()
    {
        var students = _isSortedByScore ? _db.GetStudentsSortedByScore() : _db.GetAllStudents();
        BindGrid(students);
        btnSort.Text = _isSortedByScore ? "取消排序" : "成绩排序";
    }

    private void BindGrid(List<Student> students)
    {
        dgvStudents.DataSource = null;
        dgvStudents.DataSource = students;
        if (dgvStudents.Columns["Id"] != null)
            dgvStudents.Columns["Id"].Visible = false;
        if (dgvStudents.Columns["CreateTime"] != null)
            dgvStudents.Columns["CreateTime"].Visible = false;
    }

    private void SetStatus(string msg)
    {
        toolStatus.Text = msg;
    }

    private void ClearInputs()
    {
        txtStudentNo.Clear();
        txtName.Clear();
        cmbGender.SelectedIndex = 0;
        txtClass.Clear();
        txtScore.Clear();
        lblId.Text = "0";
    }

    private void DgvStudents_SelectionChanged(object? sender, EventArgs e)
    {
        if (dgvStudents.SelectedRows.Count == 0) return;
        var row = dgvStudents.SelectedRows[0];
        if (row.DataBoundItem is not Student s) return;

        lblId.Text = s.Id.ToString();
        txtStudentNo.Text = s.StudentNo;
        txtName.Text = s.Name;
        cmbGender.Text = s.Gender;
        txtClass.Text = s.ClassName;
        txtScore.Text = s.Score.ToString();
    }

    private void BtnSearch_Click(object? sender, EventArgs e)
    {
        var keyword = txtSearch.Text.Trim();
        List<Student> result;
        if (string.IsNullOrEmpty(keyword))
        {
            result = _isSortedByScore ? _db.GetStudentsSortedByScore() : _db.GetAllStudents();
        }
        else
        {
            result = _db.SearchStudents(keyword);
        }
        BindGrid(result);
        ClearInputs();
        SetStatus($"查询完成，共 {result.Count} 条记录");
    }

    private void BtnRefresh_Click(object? sender, EventArgs e)
    {
        _isSortedByScore = false;
        txtSearch.Clear();
        LoadData();
        ClearInputs();
        SetStatus("已刷新");
    }

    private bool ValidateInput(out Student s)
    {
        s = new Student();
        s.StudentNo = txtStudentNo.Text.Trim();
        s.Name = txtName.Text.Trim();
        s.Gender = cmbGender.Text;
        s.ClassName = txtClass.Text.Trim();
        var scoreText = txtScore.Text.Trim();

        if (string.IsNullOrEmpty(s.StudentNo))
        { MessageBox.Show("请输入学号！", "提示"); return false; }
        if (string.IsNullOrEmpty(s.Name))
        { MessageBox.Show("请输入姓名！", "提示"); return false; }
        if (string.IsNullOrEmpty(s.ClassName))
        { MessageBox.Show("请输入班级！", "提示"); return false; }
        if (!int.TryParse(scoreText, out var score))
        { MessageBox.Show("成绩必须为整数！", "提示"); return false; }
        s.Score = score;

        return true;
    }

    private void BtnAdd_Click(object? sender, EventArgs e)
    {
        if (!ValidateInput(out var s)) return;
        if (_db.StudentNoExists(s.StudentNo))
        {
            MessageBox.Show("该学号已存在！", "提示");
            return;
        }
        _db.AddStudent(s);
        LoadData();
        ClearInputs();
        SetStatus($"已添加学生：{s.Name}");
    }

    private void BtnUpdate_Click(object? sender, EventArgs e)
    {
        if (!int.TryParse(lblId.Text, out var id) || id == 0)
        {
            MessageBox.Show("请先在表格中选择要修改的学生！", "提示");
            return;
        }
        if (!ValidateInput(out var s)) return;
        s.Id = id;

        if (_db.StudentNoExistsExceptId(s.StudentNo, id))
        {
            MessageBox.Show("该学号已被其他学生使用！", "提示");
            return;
        }
        _db.UpdateStudent(s);
        LoadData();
        ClearInputs();
        SetStatus($"已修改学生：{s.Name}");
    }

    private void BtnDelete_Click(object? sender, EventArgs e)
    {
        if (!int.TryParse(lblId.Text, out var id) || id == 0)
        {
            MessageBox.Show("请先在表格中选择要删除的学生！", "提示");
            return;
        }
        var name = txtName.Text.Trim();
        var result = MessageBox.Show($"确定要删除学生 \"{name}\" 吗？", "确认删除",
            MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
        if (result == DialogResult.Yes)
        {
            _db.DeleteStudent(id);
            LoadData();
            ClearInputs();
            SetStatus($"已删除学生：{name}");
        }
    }

    private void BtnSort_Click(object? sender, EventArgs e)
    {
        _isSortedByScore = !_isSortedByScore;
        LoadData();
        SetStatus(_isSortedByScore ? "已按成绩降序排列" : "恢复默认排序");
    }

    private void BtnImport_Click(object? sender, EventArgs e)
    {
        using var ofd = new OpenFileDialog
        {
            Filter = "CSV文件|*.csv",
            Title = "选择要导入的CSV文件"
        };
        if (ofd.ShowDialog() != DialogResult.OK) return;

        try
        {
            var imported = CsvHelper.ImportFromCsv(ofd.FileName);
            if (imported.Count == 0)
            {
                MessageBox.Show("CSV文件中没有有效数据！", "提示");
                return;
            }
            _db.BulkInsert(imported);
            LoadData();
            SetStatus($"成功从文件导入 {imported.Count} 条记录（重复学号已跳过）");
        }
        catch (Exception ex)
        {
            MessageBox.Show($"导入失败：{ex.Message}", "错误");
        }
    }

    private void BtnExport_Click(object? sender, EventArgs e)
    {
        using var sfd = new SaveFileDialog
        {
            Filter = "CSV文件|*.csv",
            Title = "导出学生信息",
            FileName = "students_export.csv"
        };
        if (sfd.ShowDialog() != DialogResult.OK) return;

        try
        {
            var students = _db.GetAllStudents();
            CsvHelper.ExportToCsv(sfd.FileName, students);
            SetStatus($"已导出 {students.Count} 条记录到 {sfd.FileName}");
            MessageBox.Show($"成功导出 {students.Count} 条记录！", "提示");
        }
        catch (Exception ex)
        {
            MessageBox.Show($"导出失败：{ex.Message}", "错误");
        }
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        _db.Dispose();
        base.OnFormClosing(e);
    }
}
