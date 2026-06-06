<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${not empty category}">${category} - </c:when>
            <c:when test="${not empty keyword}">搜索"${keyword}" - </c:when>
        </c:choose>
        图书列表 - 知阅书城
    </title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="categories">
        <a href="${pageContext.request.contextPath}/book/list" class="<c:if test='${empty category}'>active</c:if>">全部</a>
        <a href="${pageContext.request.contextPath}/book/list?category=文学" class="<c:if test='${category eq \"文学\"}'>active</c:if>">文学</a>
        <a href="${pageContext.request.contextPath}/book/list?category=科技" class="<c:if test='${category eq \"科技\"}'>active</c:if>">科技</a>
        <a href="${pageContext.request.contextPath}/book/list?category=历史" class="<c:if test='${category eq \"历史\"}'>active</c:if>">历史</a>
        <a href="${pageContext.request.contextPath}/book/list?category=哲学" class="<c:if test='${category eq \"哲学\"}'>active</c:if>">哲学</a>
        <a href="${pageContext.request.contextPath}/book/list?category=经济" class="<c:if test='${category eq \"经济\"}'>active</c:if>">经济</a>
    </div>

    <div class="container">
        <c:if test="${not empty keyword}">
            <p style="margin-bottom:16px;color:#888;">搜索 "<strong>${keyword}</strong>" 的结果：找到 ${books.size()} 本图书</p>
        </c:if>
        <div class="book-grid">
            <c:forEach var="book" items="${books}">
                <div class="book-card">
                    <a href="${pageContext.request.contextPath}/book/detail?id=${book.id}">
                        <c:choose>
                            <c:when test="${not empty book.cover}">
                                <div class="cover"><img src="${pageContext.request.contextPath}/${book.cover}" alt="${book.title}"></div>
                            </c:when>
                            <c:otherwise>
                                <div class="cover c${book.id % 12}">${fn:substring(book.title, 0, 1)}</div>
                            </c:otherwise>
                        </c:choose>
                        <div class="info">
                            <div class="title">${book.title}</div>
                            <div class="author">${book.author} / ${book.publisher}</div>
                            <div class="bottom">
                                <span class="price"><span class="price-symbol">¥</span>${book.price}</span>
                                <button class="add-cart" onclick="addToCart(${book.id}); return false;">加入购物车</button>
                            </div>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
        <c:if test="${empty books}">
            <div class="empty"><div class="icon">📭</div><p>没有找到相关图书</p></div>
        </c:if>
    </div>

    <div id="toast" class="toast"></div>
    <jsp:include page="footer.jsp"/>
    <script src="${pageContext.request.contextPath}/js/cart.js"></script>
</body>
</html>
