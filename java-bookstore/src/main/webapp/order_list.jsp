<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 知阅书城</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container">
        <h2 style="margin-bottom:20px;">📋 我的订单</h2>
        <c:if test="${not empty msg}"><div class="success-msg">${msg}</div></c:if>
        <c:if test="${not empty error}"><div class="error-msg">${error}</div></c:if>

        <c:choose>
            <c:when test="${not empty orders}">
                <c:forEach var="order" items="${orders}">
                    <div class="order-card">
                        <div class="order-header">
                            <a href="${pageContext.request.contextPath}/order/detail?id=${order.id}" style="color:#3498db;text-decoration:none;">
                                订单号：#${order.id}
                            </a>
                            <span>${order.createdAt}</span>
                            <span class="order-status ${order.status == 'paid' ? 'status-paid' : 'status-cancelled'}">
                                ${order.status == 'paid' ? '已支付' : '已取消'}
                            </span>
                        </div>
                        <div class="order-total">¥${order.totalAmount}</div>
                        <c:if test="${order.status == 'paid'}">
                            <form action="${pageContext.request.contextPath}/order/cancel" method="post" style="margin-top:12px;">
                                <input type="hidden" name="id" value="${order.id}">
                                <button type="submit" class="btn-cancel" onclick="return confirm('确认取消订单 #${order.id}？')">取消订单</button>
                            </form>
                        </c:if>
                        <c:if test="${order.status == 'cancelled'}">
                            <form action="${pageContext.request.contextPath}/order/delete" method="post" style="margin-top:12px;">
                                <input type="hidden" name="id" value="${order.id}">
                                <button type="submit" class="btn-delete" onclick="return confirm('删除后不可恢复，确认删除订单 #${order.id}？')">删除订单</button>
                            </form>
                        </c:if>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty"><div class="icon">📋</div><p>暂无订单记录</p></div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="footer.jsp"/>
</body>
</html>