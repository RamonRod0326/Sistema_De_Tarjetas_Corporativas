<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setTimeZone value="America/Mexico_City"/>
<header class="content-header">
    <button class="hamburger-btn" onclick="toggleSidebar()" aria-label="Menú">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
    </button>
    <div class="user-avatar">
        <c:choose>
            <c:when test="${not empty sessionScope.usuario}">
                <%= ((String)session.getAttribute("usuario")).substring(0, 1) %>
            </c:when>
            <c:otherwise>A</c:otherwise>
        </c:choose>
    </div>
</header>
