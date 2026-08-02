<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuración - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "configuracion"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title" style="margin-bottom:0.25rem;">Configuración</h1>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:2rem;">Administra tu identidad digital y protocolos de seguridad institucional.</p>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:2rem;">
                <!-- Left: Profile -->
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <div style="display:flex;align-items:center;gap:1rem;margin-bottom:1.5rem;padding-bottom:1.5rem;border-bottom:1px solid rgba(255,255,255,0.08);">
                        <div style="width:64px;height:64px;border-radius:50%;background:linear-gradient(135deg,#0ff,#0080ff);display:flex;align-items:center;justify-content:center;color:#0a0e17;font-size:1.3rem;font-weight:700;">${confIniciales}</div>
                        <div>
                            <h3 style="color:#fff;margin:0;font-size:1.1rem;">${confNombre}</h3>
                            <p style="color:#8892a4;margin:0.25rem 0 0;font-size:0.8rem;">${confCargo} · ${confDepartamento}</p>
                        </div>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/configuracion/perfil" method="POST">
                        <div class="input-group" style="margin-bottom:1.25rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Nombre Completo</label>
                            <input type="text" name="nombre" value="${confNombre}" style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                        </div>
                        <div class="input-group" style="margin-bottom:1.25rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Correo Electrónico</label>
                            <input type="email" value="${confEmail}" readonly style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.06);border-radius:8px;color:#555;font-size:0.85rem;cursor:not-allowed;">
                        </div>
                        <c:if test="${not empty confEmpleadoId}">
                        <div class="input-group" style="margin-bottom:1.5rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Número de Empleado</label>
                            <div style="position:relative;">
                                <input type="text" value="${confEmpleadoId}" readonly style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.06);border-radius:8px;color:#555;font-size:0.85rem;cursor:not-allowed;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#555" stroke-width="2" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            </div>
                        </div>
                        </c:if>
                        <button type="submit" class="btn btn-primary btn-block">Guardar Cambios</button>
                    </form>
                </div>

                <!-- Right: Password -->
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <h3 style="color:#fff;font-size:1rem;margin:0 0 1.5rem;">Cambiar Contraseña</h3>
                    <form action="${pageContext.request.contextPath}/admin/configuracion/password" method="POST">
                        <div class="input-group" style="margin-bottom:1.25rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Contraseña actual</label>
                            <div style="position:relative;">
                                <input type="password" id="currentPass" name="passwordActual" placeholder="••••••••" style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                                <button type="button" onclick="togglePass('currentPass')" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </button>
                            </div>
                        </div>
                        <div class="input-group" style="margin-bottom:1.25rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Nueva contraseña</label>
                            <div style="position:relative;">
                                <input type="password" id="passNueva" name="passwordNueva" placeholder="••••••••" style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                                <button type="button" onclick="togglePass('passNueva')" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </button>
                            </div>
                        </div>
                        <div class="input-group" style="margin-bottom:1.5rem;">
                            <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Confirmar nueva contraseña</label>
                            <div style="position:relative;">
                                <input type="password" id="passConfirma" name="passwordConfirma" placeholder="••••••••" style="width:100%;padding:0.75rem;background:#0a0e17;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                                <button type="button" onclick="togglePass('passConfirma')" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </button>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Actualizar Credenciales</button>
                    </form>
                    <div style="background:rgba(0,255,255,0.05);border:1px solid rgba(0,255,255,0.2);border-radius:8px;padding:1rem;margin-top:1.25rem;">
                        <p style="color:#0ff;font-size:0.75rem;margin:0;line-height:1.6;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                            La contraseña debe tener al menos 8 caracteres.
                        </p>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
function togglePass(id) {
    var inp = document.getElementById(id);
    inp.type = inp.type === 'password' ? 'text' : 'password';
}
</script>
</body>
</html>
