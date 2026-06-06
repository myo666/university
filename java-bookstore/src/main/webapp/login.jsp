<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>
    <div class="form-container">
        <h2>👤 用户登录</h2>
        <c:if test="${not empty error}"><div class="error-msg">${error}</div></c:if>
        <c:if test="${not empty msg}"><div class="success-msg">${msg}</div></c:if>
        <form action="${pageContext.request.contextPath}/user/login" method="post">
            <div class="form-group">
                <label for="username">用户名</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn-submit">登 录</button>
            <div class="alt-link">还没有账号？<a href="${pageContext.request.contextPath}/user/register">立即注册</a></div>
        </form>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>
