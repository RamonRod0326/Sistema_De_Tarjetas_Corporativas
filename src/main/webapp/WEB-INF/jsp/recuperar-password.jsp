<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recuperar Contraseña - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="login-container">
    <div class="login-brand-panel">
        <div class="brand-content">
            <div class="brand-logo-large">
                <svg width="48" height="48" viewBox="0 0 32 32" fill="none"><rect width="32" height="32" rx="8" fill="#0ff"/><path d="M8 16h16M16 8v16" stroke="#0a0e17" stroke-width="3" stroke-linecap="round"/></svg>
            </div>
            <h1 class="brand-title">FinTech Corp</h1>
            <p class="brand-tagline">Plataforma de gestión financiera institucional con seguridad avanzada y control total de activos corporativos.</p>
        </div>
    </div>
    <div class="login-form-panel">
        <div class="form-container">
            <h2 class="form-title">Recuperar contraseña</h2>
            <p class="form-subtitle">Ingresa tu correo electrónico para recibir un enlace de recuperación.</p>
            <form class="login-form" action="${pageContext.request.contextPath}/recuperar-password" method="post">
                <div class="input-group">
                    <label for="email">Correo Electrónico</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="email" id="email" name="email" placeholder="correo@fintechcorp.com" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Enviar Enlace
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </button>
            </form>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline btn-block" style="margin-top:1rem;text-align:center;">Volver al Inicio</a>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
