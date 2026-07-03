<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="content-header">
    <div></div>
    <div class="user-avatar">
        <c:choose>
            <c:when test="${not empty sessionScope.usuario}">
                <%= ((String)session.getAttribute("usuario")).substring(0, 1) %>
            </c:when>
            <c:otherwise>A</c:otherwise>
        </c:choose>
    </div>
</header>
