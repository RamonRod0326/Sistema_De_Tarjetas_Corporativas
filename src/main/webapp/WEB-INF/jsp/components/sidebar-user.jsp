<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-logo">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none"><rect width="32" height="32" rx="8" fill="#0ff"/><rect x="5" y="10" width="22" height="14" rx="2" stroke="#0a0e17" stroke-width="2.5"/><line x1="5" y1="16" x2="27" y2="16" stroke="#0a0e17" stroke-width="2.5"/><line x1="9" y1="20" x2="14" y2="20" stroke="#0a0e17" stroke-width="2" stroke-linecap="round"/></svg>
        </div>
        <div class="brand-text">
            <span class="brand-name" style="color:#0ff;font-weight:700;font-size:1.1rem;">FinTech Corp</span>
            <span class="brand-subtitle" style="font-size:0.65rem;color:#6B7084;text-transform:uppercase;letter-spacing:1.5px;">Banca Institucional</span>
        </div>
    </div>
    <nav class="sidebar-nav">
        <ul class="nav-list">
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/user/dashboard" class="nav-link ${activePage == 'dashboard' ? 'active' : ''}" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                    <span>Panel principal</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/user/cuentas" class="nav-link ${activePage == 'cuentas' ? 'active' : ''}" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"/></svg>
                    <span>Cuentas</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/user/tarjetas" class="nav-link ${activePage == 'tarjetas' ? 'active' : ''}" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                    <span>Tarjetas</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/user/transferencias" class="nav-link ${activePage == 'transferencias' ? 'active' : ''}" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                    <span>Transferencias</span>
                </a>
            </li>
        </ul>
    </nav>
    <div class="sidebar-bottom">
        <ul class="nav-list">
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/user/configuracion" class="nav-link ${activePage == 'configuracion' ? 'active' : ''}" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    <span>Configuración</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-link-logout" onclick="closeSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    <span>Cerrar Sesión</span>
                </a>
            </li>
        </ul>
    </div>
</aside>
