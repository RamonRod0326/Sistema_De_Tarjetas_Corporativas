<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="login-page">
    <div class="login-brand">
        <div class="brand-icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 21h18"/>
                <path d="M3 10h18"/>
                <path d="M5 6l7-3 7 3"/>
                <path d="M4 10v11"/>
                <path d="M20 10v11"/>
                <path d="M8 14v3"/>
                <path d="M12 14v3"/>
                <path d="M16 14v3"/>
            </svg>
        </div>
        <h1>FinTech Corp</h1>
        <p>Sistema de gestión de tarjetas corporativas empresariales.</p>
        <div class="brand-features">
            <div class="brand-feature">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    <path d="M9 12l2 2 4-4"/>
                </svg>
                <span>Seguridad</span>
            </div>
            <div class="brand-feature">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
                </svg>
                <span>Velocidad</span>
            </div>
            <div class="brand-feature">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="2" y1="12" x2="22" y2="12"/>
                    <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                </svg>
                <span>Global</span>
            </div>
        </div>
    </div>
    <div class="login-form-section">
        <h2>Bienvenido</h2>
        <p class="subtitle">Ingrese sus credenciales para acceder a su portal institucional.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                <div>
                    <strong>Credenciales incorrectas.</strong> Por favor, inténtalo de nuevo.
                    Asegúrese de colocar la contraseña correcta o el usuario correcto.
                </div>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <div class="form-group">
                <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">Correo Electrónico</label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="2" y="4" width="20" height="16" rx="2"/>
                            <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>
                        </svg>
                    </span>
                    <input type="email" name="email" placeholder="nombre@fintechcorp.com" required>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">
                    Contraseña
                </label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </span>
                    <input type="password" name="password" placeholder="••••••••" required>
                    <button type="button" class="toggle-password">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
                <a href="${pageContext.request.contextPath}/recuperar-password" style="display:block;margin-top:0.5rem;font-size:0.75rem;color:#0ff;text-decoration:none;">Olvidé mi contraseña</a>
            </div>
            <button type="submit" class="btn btn-primary btn-block btn-lg">
                Iniciar Sesión &rarr;
            </button>
        </form>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
