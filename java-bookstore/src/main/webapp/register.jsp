<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>
    <div class="form-container">
        <h2>📝 用户注册</h2>
        <c:if test="${not empty error}"><div class="error-msg">${error}</div></c:if>
        <form action="${pageContext.request.contextPath}/user/register" method="post" onsubmit="return validateRegister()">
            <div class="form-group">
                <label for="username">用户名</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" id="password" name="password" required minlength="6">
            </div>
            <div class="form-group">
                <label for="confirm">确认密码</label>
                <input type="password" id="confirm" required>
            </div>
            <div class="form-group">
                <label for="email">邮箱</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="phone">手机号</label>
                <input type="text" id="phone" name="phone">
            </div>
            <button type="submit" class="btn-submit">注 册</button>
            <div class="alt-link">已有账号？<a href="${pageContext.request.contextPath}/user/login">立即登录</a></div>
        </form>
    </div>
    <jsp:include page="footer.jsp"/>
    <script>
        function validateRegister() {
            var pwd = document.getElementById('password').value;
            var confirm = document.getElementById('confirm').value;
            if (pwd !== confirm) { alert('两次输入的密码不一致'); return false; }
            if (pwd.length < 6) { alert('密码长度至少6位'); return false; }
            return true;
        }
    </script>
</body>
</html>
