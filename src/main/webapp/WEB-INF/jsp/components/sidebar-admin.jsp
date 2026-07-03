<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-logo">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none"><rect width="32" height="32" rx="8" fill="#0ff"/><path d="M8 16h16M16 8v16" stroke="#0a0e17" stroke-width="3" stroke-linecap="round"/></svg>
        </div>
        <div class="brand-text">
            <span class="brand-name" style="color:#0ff;font-weight:700;font-size:1.1rem;">FinTech Corp</span>
            <span class="brand-subtitle" style="font-size:0.7rem;color:#8892a4;text-transform:uppercase;letter-spacing:2px;">Banca Institucional</span>
        </div>
    </div>
    <nav class="sidebar-nav">
        <ul class="nav-list">
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link ${activePage == 'dashboard' ? 'active' : ''}">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                    <span>Panel principal</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/cuentas" class="nav-link ${activePage == 'cuentas' ? 'active' : ''}">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"/></svg>
                    <span>Cuentas</span>
                </a>
            </li>
        </ul>
    </nav>
    <div class="sidebar-bottom">
        <ul class="nav-list">
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-link-logout">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    <span>Cerrar Sesión</span>
                </a>
            </li>
        </ul>
    </div>
</aside>
