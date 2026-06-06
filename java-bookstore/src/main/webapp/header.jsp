<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<header class="header">
    <a href="${pageContext.request.contextPath}/" class="logo">知阅<span>书城</span></a>
    <nav>
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/book/list">全部图书</a>
        <a href="${pageContext.request.contextPath}/about.html">关于</a>
        <a href="${pageContext.request.contextPath}/cart/">
            购物车
            <c:if test="${not empty cart}">
                <span class="cart-count">${cart.size()}</span>
            </c:if>
        </a>
        <c:choose>
            <c:when test="${not empty user}">
                <a href="${pageContext.request.contextPath}/order/">我的订单</a>
                <span class="user-info">👤 ${user.username}</span>
                <a href="${pageContext.request.contextPath}/user/logout">退出</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/user/login">登录</a>
                <a href="${pageContext.request.contextPath}/user/register">注册</a>
            </c:otherwise>
        </c:choose>
    </nav>
</header>
<div class="search-bar">
    <form action="${pageContext.request.contextPath}/book/search" method="get" style="display:flex;width:100%;gap:8px;">
        <input type="text" name="keyword" id="searchInput" placeholder="搜索书名或作者..." value="${keyword}">
        <button type="submit">搜索</button>
    </form>
</div>
<script>
// 搜索支持回车
document.getElementById('searchInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') this.form.submit();
});
// 购物车角标实时更新
fetch(contextPath + '/cart/count')
    .then(res => res.json())
    .then(data => {
        if (data.count > 0) {
            var existing = document.querySelector('.cart-count');
            if (existing) { existing.textContent = data.count; }
            else {
                var cartLink = document.querySelector('.header nav a[href*=\"/cart/\"]');
                if (cartLink) {
                    var span = document.createElement('span');
                    span.className = 'cart-count';
                    span.textContent = data.count;
                    cartLink.appendChild(span);
                }
            }
        }
    });
</script>