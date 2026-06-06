namespace StudentManagement;

partial class Form1
{
    private System.ComponentModel.IContainer components = null;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        this.components = new System.ComponentModel.Container();
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.ClientSize = new System.Drawing.Size(960, 620);
        this.Text = "学生信息管理系统";
        this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
        this.Font = new System.Drawing.Font("Microsoft YaHei UI", 10F, System.Drawing.FontStyle.Regular,
            System.Drawing.GraphicsUnit.Point, ((byte)(134)));

        // Status strip
        this.statusStrip = new StatusStrip();
        this.toolStatus = new ToolStripStatusLabel
        {
            Text = "就绪",
            Spring = true
        };
        this.statusStrip.Items.Add(this.toolStatus);
        this.Controls.Add(this.statusStrip);

        // Top panel
        var topPanel = new Panel
        {
            Location = new Point(12, 12),
            Size = new Size(920, 36),
            Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
        };

        var lblSearch = new Label
        {
            Text = "查询：",
            Location = new Point(0, 8),
            AutoSize = true
        };
        this.txtSearch = new TextBox
        {
            Location = new Point(52, 5),
            Width = 200,
            PlaceholderText = "输入学号或姓名..."
        };
        this.btnSearch = new Button
        {
            Text = "查询",
            Location = new Point(260, 4),
            Width = 70
        };
        this.btnRefresh = new Button
        {
            Text = "刷新",
            Location = new Point(340, 4),
            Width = 70
        };
        topPanel.Controls.AddRange(new Control[] { lblSearch, this.txtSearch, this.btnSearch, this.btnRefresh });

        // DataGridView
        this.dgvStudents = new DataGridView
        {
            Location = new Point(12, 58),
            Size = new Size(920, 320),
            Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Bottom,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            MultiSelect = false,
            ReadOnly = true,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false
        };

        // Bottom panel - input area
        var inputPanel = new Panel
        {
            Location = new Point(12, 388),
            Size = new Size(920, 185),
            Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right,
            BorderStyle = BorderStyle.FixedSingle
        };

        var lblTitle = new Label
        {
            Text = "学生信息编辑",
            Location = new Point(12, 8),
            Font = new System.Drawing.Font("Microsoft YaHei UI", 11F, System.Drawing.FontStyle.Bold),
            AutoSize = true
        };

        int rowY = 40;
        int gapX = 130;
        int startX = 12;
        int lblW = 60;
        int ctrlW = 140;

        // Row 1
        AddControlToPanel(inputPanel, "学号：", startX, rowY, lblW);
        this.txtStudentNo = new TextBox { Location = new Point(startX + lblW, rowY), Width = ctrlW, MaxLength = 20 };
        inputPanel.Controls.Add(this.txtStudentNo);

        AddControlToPanel(inputPanel, "姓名：", startX + gapX * 2, rowY, lblW);
        this.txtName = new TextBox { Location = new Point(startX + gapX * 2 + lblW, rowY), Width = ctrlW, MaxLength = 50 };
        inputPanel.Controls.Add(this.txtName);

        AddControlToPanel(inputPanel, "性别：", startX + gapX * 4, rowY, lblW);
        this.cmbGender = new ComboBox
        {
            Location = new Point(startX + gapX * 4 + lblW, rowY),
            Width = ctrlW,
            DropDownStyle = ComboBoxStyle.DropDownList
        };
        this.cmbGender.Items.AddRange(new object[] { "男", "女" });
        this.cmbGender.SelectedIndex = 0;
        inputPanel.Controls.Add(this.cmbGender);

        // Row 2
        int rowY2 = rowY + 36;
        AddControlToPanel(inputPanel, "班级：", startX, rowY2, lblW);
        this.txtClass = new TextBox { Location = new Point(startX + lblW, rowY2), Width = ctrlW, MaxLength = 30 };
        inputPanel.Controls.Add(this.txtClass);

        AddControlToPanel(inputPanel, "成绩：", startX + gapX * 2, rowY2, lblW);
        this.txtScore = new TextBox { Location = new Point(startX + gapX * 2 + lblW, rowY2), Width = ctrlW, MaxLength = 3 };
        inputPanel.Controls.Add(this.txtScore);

        // Row 3 - buttons
        int btnY = rowY2 + 42;
        int btnW = 90;
        int btnGap = 10;

        int btnStartX = startX;
        this.btnAdd = new Button { Text = "添加", Location = new Point(btnStartX, btnY), Width = btnW };
        this.btnUpdate = new Button { Text = "修改", Location = new Point(btnStartX + btnW + btnGap, btnY), Width = btnW };
        this.btnDelete = new Button { Text = "删除", Location = new Point(btnStartX + (btnW + btnGap) * 2, btnY), Width = btnW };
        this.btnSort = new Button { Text = "成绩排序", Location = new Point(btnStartX + (btnW + btnGap) * 3, btnY), Width = btnW };
        this.btnImport = new Button { Text = "导入CSV", Location = new Point(btnStartX + (btnW + btnGap) * 4, btnY), Width = btnW };
        this.btnExport = new Button { Text = "导出CSV", Location = new Point(btnStartX + (btnW + btnGap) * 5, btnY), Width = btnW, BackColor = System.Drawing.Color.DarkGreen, ForeColor = System.Drawing.Color.White, UseVisualStyleBackColor = false };

        this.lblId = new Label { Text = "0", Location = new Point(900, 170), Visible = false, AutoSize = true };
        inputPanel.Controls.Add(this.lblId);

        inputPanel.Controls.AddRange(new Control[] { lblTitle, this.btnAdd, this.btnUpdate, this.btnDelete, this.btnSort, this.btnImport, this.btnExport });

        this.Controls.AddRange(new Control[] { topPanel, this.dgvStudents, inputPanel });
        this.MinimumSize = new System.Drawing.Size(980, 660);
    }

    private void AddControlToPanel(Panel parent, string text, int x, int y, int width)
    {
        var lbl = new Label
        {
            Text = text,
            Location = new Point(x, y + 2),
            AutoSize = true
        };
        parent.Controls.Add(lbl);
    }
}
