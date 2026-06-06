<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>购物车 - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container">
        <h2 style="margin-bottom:20px;">🛒 我的购物车</h2>
        <c:choose>
            <c:when test="${not empty cart and cart.size() > 0}">
                <table class="cart-table">
                    <thead>
                        <tr><th>图书</th><th>单价</th><th>数量</th><th>小计</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:set var="total" value="0"/>
                        <c:forEach var="entry" items="${cart}">
                            <c:set var="item" value="${entry.value}"/>
                            <c:set var="subtotal" value="${item.price * item.quantity}"/>
                            <c:set var="total" value="${total + subtotal}"/>
                            <tr>
                                <td><strong>${item.title}</strong></td>
                                <td>¥${item.price}</td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/cart/update" method="post" style="display:inline;">
                                        <input type="hidden" name="bookId" value="${item.bookId}">
                                        <button type="button" class="qty-btn" onclick="changeQty(this, -1)">−</button>
                                        <input type="text" name="quantity" value="${item.quantity}" class="qty-input" readonly>
                                        <button type="button" class="qty-btn" onclick="changeQty(this, 1)">+</button>
                                    </form>
                                </td>
                                <td style="color:#e74c3c;font-weight:600;">¥${subtotal}</td>
                                <td><a href="${pageContext.request.contextPath}/cart/remove?bookId=${item.bookId}" class="remove">删除</a></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <div class="cart-total">
                    <span>合计：</span>
                    <span class="total-amount">¥${total}</span>
                    <form action="${pageContext.request.contextPath}/order/" method="post" style="display:inline;">
                        <button type="submit" class="btn-checkout">提交订单</button>
                    </form>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty"><div class="icon">🛒</div><p>购物车是空的，快去逛逛吧~</p></div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="footer.jsp"/>
    <script>
        function changeQty(btn, delta) {
            var form = btn.parentElement;
            var input = form.querySelector('.qty-input');
            var newVal = parseInt(input.value) + delta;
            if (newVal >= 0) { input.value = newVal; form.submit(); }
        }
    </script>
</body>
</html>
