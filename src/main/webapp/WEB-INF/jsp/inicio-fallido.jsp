<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio Fallido - FinTech Corp</title>
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
            <p class="brand-tagline">Gestión institucional avanzada con seguridad de grado militar y análisis en tiempo real.</p>
        </div>
    </div>
    <div class="login-form-panel">
        <div class="form-container">
            <h2 class="form-title">Iniciar Sesión</h2>
            <p class="form-subtitle">Banca Institucional y Gestión de Activos</p>

            <div class="alert alert-error" style="background:rgba(255,82,82,0.1);border:1px solid rgba(255,82,82,0.3);border-radius:8px;padding:1rem;margin-bottom:1.5rem;display:flex;align-items:flex-start;gap:0.75rem;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ff5252" stroke-width="2" style="flex-shrink:0;margin-top:2px;"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <p style="color:#ff5252;font-size:0.85rem;margin:0;">Credenciales incorrectas. Por favor, inténtalo de nuevo. Asegúrese de colocar la contraseña correcta o el usuario correcto.</p>
            </div>

            <form class="login-form" action="${pageContext.request.contextPath}/login" method="post">
                <div class="input-group">
                    <label for="email">Correo Electrónico</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="email" id="email" name="email" placeholder="correo@fintechcorp.com" required>
                    </div>
                </div>
                <div class="input-group">
                    <label for="password">Contraseña</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="password" name="password" placeholder="••••••••" required>
                        <button type="button" class="toggle-password" onclick="togglePassword()">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>
                <div class="form-options" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
                    <label class="checkbox-label" style="display:flex;align-items:center;gap:0.5rem;color:#8892a4;font-size:0.85rem;">
                        <input type="checkbox" name="remember"> Recordar dispositivo
                    </label>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Iniciar Sesión
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </button>
            </form>

            <p style="text-align:center;margin-top:1.5rem;color:#8892a4;font-size:0.85rem;">
                ¿Nuevo en FinTech Corp? <a href="#" style="color:#0ff;">Contacte con su gestor</a>
            </p>

            <div class="security-badges" style="display:flex;gap:1rem;justify-content:center;margin-top:2rem;">
                <span class="badge" style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.4rem 0.8rem;border-radius:6px;font-size:0.7rem;letter-spacing:1px;">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    MFA HABILITADO
                </span>
                <span class="badge" style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.4rem 0.8rem;border-radius:6px;font-size:0.7rem;letter-spacing:1px;">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    SSO CORPORATIVO
                </span>
            </div>

            <p style="text-align:center;margin-top:2rem;color:#555;font-size:0.65rem;text-transform:uppercase;letter-spacing:1px;">
                SISTEMA DE SEGURIDAD FINTECH CORP &copy; 2024. TODOS LOS DERECHOS RESERVADOS.
            </p>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
    function togglePassword() {
        const input = document.getElementById('password');
        input.type = input.type === 'password' ? 'text' : 'password';
    }
</script>
</body>
</html>
