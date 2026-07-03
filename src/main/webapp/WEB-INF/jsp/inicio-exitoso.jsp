<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio Exitoso - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .overlay {
            position: fixed;
            inset: 0;
            background: rgba(4, 6, 14, 0.92);
            backdrop-filter: blur(8px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }
        .overlay-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-xl);
            padding: 48px 40px;
            max-width: 440px;
            width: 90%;
            text-align: center;
        }
        .overlay-card .logo-text {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
        }
        .overlay-card .logo-sub {
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--text-secondary);
            margin-top: 4px;
        }
        .overlay-card .check-icon {
            width: 64px;
            height: 64px;
            margin: 28px auto 24px;
        }
        .overlay-card h2 {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .overlay-card .msg {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 28px;
        }
        .overlay-card .msg strong {
            color: var(--text-primary);
        }
        .overlay-card .divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 24px 0 16px;
        }
        .overlay-card .footer-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
            color: var(--text-muted);
        }
        .overlay-card .footer-info svg {
            vertical-align: middle;
            margin-right: 4px;
        }
        .overlay-card .redirect-msg {
            margin-top: 12px;
            font-size: 13px;
            color: var(--accent);
        }
    </style>
</head>
<body>
<div class="overlay">
    <div class="overlay-card">
        <div class="logo-text">FinTech Corp</div>
        <div class="logo-sub">Banca Institucional</div>

        <div class="check-icon">
            <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                <circle cx="32" cy="32" r="30" stroke="#00FFD1" stroke-width="2.5" fill="rgba(0,255,209,0.08)"/>
                <polyline points="20,34 28,42 44,24" fill="none" stroke="#00FFD1" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
        </div>

        <h2>¡Inicio de sesión exitoso!</h2>
        <p class="msg">
            Bienvenido de nuevo, <strong>${sessionScope.usuario}</strong>. Tus credenciales
            institucionales han sido verificadas correctamente.
        </p>

        <c:choose>
            <c:when test="${param.rol == 'admin'}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary btn-block btn-lg">
                    IR AL PANEL PRINCIPAL &nbsp;&rarr;
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-primary btn-block btn-lg">
                    IR AL PANEL PRINCIPAL &nbsp;&rarr;
                </a>
            </c:otherwise>
        </c:choose>

        <hr class="divider">
        <div class="footer-info">
            <span>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
                Acceso Seguro
            </span>
            <span>ID: #FTC-17956</span>
        </div>
        <div class="redirect-msg">Redirigiendo automáticamente en 5 segundos...</div>
    </div>
</div>
<script>
    setTimeout(function() {
        var rol = new URLSearchParams(window.location.search).get('rol');
        if (rol === 'admin') {
            window.location.href = '${pageContext.request.contextPath}/admin/dashboard';
        } else {
            window.location.href = '${pageContext.request.contextPath}/user/dashboard';
        }
    }, 5000);
</script>
</body>
</html>
