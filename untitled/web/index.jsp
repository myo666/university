<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登录</title>
    <style>
        body { font-family: 'Microsoft YaHei', sans-serif; display: flex;
               justify-content: center; align-items: center; height: 100vh;
               margin: 0; background: #f0f2f5; }
        .box { background: #fff; padding: 40px; border-radius: 8px;
               box-shadow: 0 2px 12px rgba(0,0,0,.1); width: 320px; }
        h2  { text-align: center; margin-bottom: 24px; color: #333; }
        input[type=text], input[type=password] {
            width: 100%; padding: 10px; margin-bottom: 16px;
            border: 1px solid #d9d9d9; border-radius: 4px; box-sizing: border-box; }
        input[type=submit] {
            width: 100%; padding: 10px; background: #1677ff; color: #fff;
            border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        input[type=submit]:hover { background: #4096ff; }
    </style>
</head>
<body>
    <div class="box">
        <h2>用户登录</h2>
        <form action="login" method="post">
            <input type="text"     name="username" placeholder="用户名" required>
            <input type="password" name="password" placeholder="密  码" required>
            <input type="submit"   value="登 录">
        </form>
    </div>
</body>
</html>
