<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${book.title} - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container" style="margin-top:24px;">
        <c:if test="${not empty book}">
            <div class="book-detail">
                <c:choose>
                <c:when test="${not empty book.cover}">
                    <div class="cover-lg"><img src="${pageContext.request.contextPath}/${book.cover}" alt="${book.title}"></div>
                </c:when>
                <c:otherwise>
                    <div class="cover-lg c${book.id % 12}">${fn:substring(book.title, 0, 1)}</div>
                </c:otherwise>
            </c:choose>
                <div class="info-lg">
                    <h1>${book.title}</h1>
                    <div class="meta">作者：${book.author} &nbsp;|&nbsp; 出版社：${book.publisher} &nbsp;|&nbsp; 分类：${book.category}</div>
                    <div class="price-lg">¥${book.price}</div>
                    <div class="stock">
                        <c:choose>
                            <c:when test="${book.stock > 0}">库存：${book.stock} 件</c:when>
                            <c:otherwise>暂时缺货</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${book.stock > 0}">
                        <button class="btn-add" onclick="addToCart(${book.id})">加入购物车</button>
                    </c:if>
                    <div class="desc">
                        <h3 style="margin-bottom:8px;color:#333;">内容简介</h3>
                        <p>${book.description}</p>
                    </div>
                </div>
            </div>
        </c:if>
        <c:if test="${empty book}">
            <div class="empty"><div class="icon">📭</div><p>图书不存在</p></div>
        </c:if>
    </div>

    <div id="toast" class="toast"></div>
    <jsp:include page="footer.jsp"/>
    <script src="${pageContext.request.contextPath}/js/cart.js"></script>
</body>
</html>
