<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单详情 - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container" style="margin-top:24px;">
        <h2 style="margin-bottom:20px;">📋 订单详情</h2>

        <c:choose>
            <c:when test="${not empty orderItems}">
                <table class="cart-table">
                    <thead>
                        <tr><th>图书</th><th>单价</th><th>数量</th><th>小计</th></tr>
                    </thead>
                    <tbody>
                        <c:set var="total" value="0"/>
                        <c:forEach var="item" items="${orderItems}">
                            <c:set var="subtotal" value="${item.price * item.quantity}"/>
                            <c:set var="total" value="${total + subtotal}"/>
                            <tr>
                                <td>
                                    <a href="${pageContext.request.contextPath}/book/detail?id=${item.bookId}">
                                        <strong>${item.title}</strong>
                                    </a>
                                </td>
                                <td>¥${item.price}</td>
                                <td>${item.quantity}</td>
                                <td style="color:#e74c3c;font-weight:600;">¥${subtotal}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <div class="cart-total">
                    <span>订单合计：</span>
                    <span class="total-amount">¥${total}</span>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty"><div class="icon">📋</div><p>未找到订单明细</p></div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="footer.jsp"/>
</body>
</html>