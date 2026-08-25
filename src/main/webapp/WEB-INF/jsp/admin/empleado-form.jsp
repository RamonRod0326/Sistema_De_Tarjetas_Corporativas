<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Empleado - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "empleados"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <c:set var="isEdit" value="${not empty param.id}"/>

            <c:choose>
                <c:when test="${isEdit}">
                    <h1 class="page-title">Editar Empleado</h1>
                    <!-- Employee header con datos reales -->
                    <div style="display:flex;align-items:center;gap:1.5rem;margin-bottom:2rem;background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                        <div style="width:64px;height:64px;border-radius:50%;background:linear-gradient(135deg,#0ff,#0080ff);display:flex;align-items:center;justify-content:center;color:#0a0e17;font-size:1.3rem;font-weight:700;">${empForm.iniciales}</div>
                        <div style="flex:1;">
                            <h3 style="color:#fff;margin:0;font-size:1.1rem;">${empForm.nombre}${not empty empForm.apellidoPaterno ? ' '.concat(empForm.apellidoPaterno) : ''}${not empty empForm.apellidoMaterno ? ' '.concat(empForm.apellidoMaterno) : ''}</h3>
                            <p style="color:#8892a4;margin:0.25rem 0 0;font-size:0.85rem;">${empForm.cargoNombre} &bull; ${empForm.depNombre}</p>
                        </div>
                        <div style="display:flex;gap:0.75rem;">
                            <span style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.4rem 0.8rem;border-radius:6px;font-size:0.7rem;letter-spacing:1px;">ID: ${empForm.id}</span>
                            <span style="background:rgba(0,230,118,0.1);color:#00e676;padding:0.4rem 0.8rem;border-radius:6px;font-size:0.7rem;letter-spacing:1px;">ACTIVO</span>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <h1 class="page-title">Registrar Nuevo Empleado</h1>
                </c:otherwise>
            </c:choose>

            <form action="${pageContext.request.contextPath}/admin/empleados/form" method="post" style="max-width:720px;margin:0 auto;">
                <c:if test="${isEdit}"><input type="hidden" name="id" value="${param.id}"></c:if>

                <!-- Avatar con iniciales (sin carga de imágenes) -->
                <div style="text-align:center;margin-bottom:2rem;">
                    <div style="width:96px;height:96px;border-radius:50%;background:linear-gradient(135deg,#00FFD1,#0080ff);margin:0 auto;display:flex;align-items:center;justify-content:center;color:#0a0e17;font-size:1.6rem;font-weight:700;letter-spacing:-1px;" id="avatarPreview">?</div>
                    <p style="color:#8892a4;font-size:0.75rem;margin-top:0.75rem;">El avatar se genera automáticamente con las iniciales del nombre.</p>
                </div>

                <!-- Form fields -->
                <div class="two-col-equal" style="gap:1.25rem;">
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Nombre(s) *</label>
                        <input type="text" name="nombre" id="fieldNombre" value="${isEdit ? empForm.nombre : ''}" placeholder="Primer nombre" required
                            style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Apellido Paterno *</label>
                        <input type="text" name="apellidoPaterno" id="fieldApellidoPat" value="${isEdit ? empForm.apellidoPaterno : ''}" placeholder="Apellido paterno" required
                            style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Apellido Materno</label>
                        <input type="text" name="apellidoMaterno" id="fieldApellidoMat" value="${isEdit ? empForm.apellidoMaterno : ''}" placeholder="Apellido materno (opcional)"
                            style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Correo Electrónico *</label>
                        <input type="email" name="email" value="${isEdit ? empForm.email : ''}" placeholder="correo@fintechcorp.com" required
                            style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Departamento *</label>
                        <select name="departamentoId" required style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                            <option value="">Seleccionar departamento</option>
                            <c:forEach var="dep" items="${departamentos}">
                                <option value="${dep.id}" ${isEdit && dep.id == empForm.departamentoId ? 'selected' : ''}>${dep.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Cargo *</label>
                        <select name="cargoId" required style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                            <option value="">Seleccionar cargo</option>
                            <c:forEach var="cargo" items="${cargos}">
                                <option value="${cargo.id}" ${isEdit && cargo.id == empForm.cargoId ? 'selected' : ''}>${cargo.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <c:if test="${!isEdit}">
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Contraseña inicial *</label>
                        <div style="position:relative;">
                            <input type="password" name="password" id="passInput" placeholder="Mínimo 8 caracteres con al menos un número" required minlength="8"
                                style="width:100%;padding:0.75rem 2.5rem 0.75rem 0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                            <button type="button" onclick="var i=document.getElementById('passInput');i.type=i.type==='password'?'text':'password';"
                                style="position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:#6B7084;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>
                    <div class="input-group">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Confirmar contraseña *</label>
                        <input type="password" name="passwordConfirm" id="passConfirm" placeholder="Repite la contraseña" required minlength="8"
                            style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;box-sizing:border-box;">
                    </div>
                    </c:if>
                </div>

                <!-- Info box -->
                <div style="background:rgba(0,255,255,0.05);border:1px solid rgba(0,255,255,0.2);border-radius:8px;padding:1rem;margin-top:1.5rem;">
                    <p style="color:#0ff;font-size:0.8rem;margin:0;line-height:1.6;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2" style="vertical-align:middle;margin-right:6px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        El sistema generará automáticamente el número de identificación del empleado. La contraseña establecida aquí será la que use el empleado para iniciar sesión.
                    </p>
                </div>

                <!-- Buttons -->
                <div style="display:flex;justify-content:flex-end;gap:1rem;margin-top:2rem;">
                    <a href="${pageContext.request.contextPath}/admin/empleados" class="btn btn-outline">Cancelar</a>
                    <button type="submit" class="btn btn-primary" onclick="return validarFormEmpleado()">
                        ${isEdit ? 'Editar Empleado' : 'Guardar Empleado'}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
(function() {
    var fNombre = document.getElementById('fieldNombre');
    var fPat    = document.getElementById('fieldApellidoPat');
    var avatar  = document.getElementById('avatarPreview');
    if (!fNombre || !avatar) return;
    function actualizarAvatar() {
        var i1 = fNombre.value.trim().charAt(0).toUpperCase() || '';
        var i2 = fPat && fPat.value.trim() ? fPat.value.trim().charAt(0).toUpperCase() : '';
        avatar.textContent = (i1 + i2) || '?';
    }
    [fNombre, fPat].forEach(function(el) { if (el) el.addEventListener('input', actualizarAvatar); });
    actualizarAvatar();
})();
function validarFormEmpleado() {
    var passInput   = document.getElementById('passInput');
    var passConfirm = document.getElementById('passConfirm');
    if (!passInput) return true; // modo edición, sin campo de contraseña
    var pass = passInput.value;
    if (pass.length < 8 || !/\d/.test(pass)) {
        alert('La contraseña debe tener al menos 8 caracteres y contener al menos un número.');
        passInput.focus();
        return false;
    }
    if (passConfirm && pass !== passConfirm.value) {
        alert('Las contraseñas no coinciden.');
        passConfirm.focus();
        return false;
    }
    return true;
}
</script>
</body>
</html>
