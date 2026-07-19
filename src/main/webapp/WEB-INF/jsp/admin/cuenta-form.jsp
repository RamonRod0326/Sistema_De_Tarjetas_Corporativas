<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Cuenta - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .search-select-wrapper { position: relative; }
        .search-select-input {
            width: 100%; padding: 0.75rem 0.75rem 0.75rem 2.5rem;
            background: #0d1520; border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px; color: #fff; font-size: 0.85rem;
            outline: none; box-sizing: border-box;
        }
        .search-select-input:focus { border-color: #0ff; }
        .search-select-icon {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%); pointer-events: none;
        }
        .search-dropdown {
            display: none; position: absolute; top: calc(100% + 4px); left: 0; right: 0;
            background: #111827; border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px; z-index: 100; max-height: 200px; overflow-y: auto;
        }
        .search-dropdown.open { display: block; }
        .search-option {
            padding: 0.75rem 1rem; cursor: pointer;
            display: flex; align-items: center; gap: 0.75rem;
        }
        .search-option:hover { background: rgba(0,255,255,0.06); }
        .search-option .opt-avatar {
            width: 30px; height: 30px; border-radius: 50%;
            background: #1a2a3a; display: flex; align-items: center;
            justify-content: center; color: #0ff; font-size: 0.7rem; font-weight: 700;
            flex-shrink: 0;
        }
        .search-option .opt-name { color: #fff; font-size: 0.82rem; }
        .search-option .opt-sub  { color: #6B7084; font-size: 0.7rem; }

        .cat-chip {
            padding: 0.5rem 1rem; border-radius: 20px; cursor: pointer;
            background: #111827; border: 1px solid rgba(255,255,255,0.1);
            color: #8892a4; font-size: 0.82rem; transition: all 0.15s;
        }
        .cat-chip.selected {
            background: rgba(0,255,255,0.12); border-color: #0ff; color: #0ff;
        }
        .pager-bar {
            display: flex; align-items: center; gap: 0.5rem;
            margin-top: 0.75rem; flex-wrap: wrap;
        }
        .btn-pg {
            padding: 0.3rem 0.75rem; border-radius: 6px; font-size: 0.78rem;
            background: #111827; border: 1px solid rgba(255,255,255,0.1);
            color: #8892a4; cursor: pointer; transition: all 0.15s;
        }
        .btn-pg:hover:not(:disabled) { border-color: #0ff; color: #0ff; }
        .btn-pg:disabled { opacity: 0.35; cursor: default; }
        .pg-info { color: #8892a4; font-size: 0.78rem; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "cuentas"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <div style="max-width:640px;margin:0 auto;">
                <h1 class="page-title" style="margin-bottom:0.25rem;">Configurar Nueva Cuenta</h1>
                <p style="color:#8892a4;font-size:0.85rem;margin-bottom:2rem;">Asigna una nueva cuenta corporativa a un empleado registrado.</p>

                <form action="${pageContext.request.contextPath}/admin/cuentas/form" method="POST">

                    <!-- Search select empleado -->
                    <div style="margin-bottom:1.5rem;">
                        <label style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;display:block;margin-bottom:0.75rem;">EMPLEADO RESPONSABLE</label>
                        <div class="search-select-wrapper">
                            <svg class="search-select-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6B7084" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                            <input type="text" class="search-select-input" id="empSearch"
                                   placeholder="Buscar empleado por nombre o departamento..."
                                   autocomplete="off" onkeyup="filtrarEmpleados()" onfocus="abrirDropdown()">
                            <input type="hidden" name="usuarioId" id="empleadoIdHidden">
                            <div class="search-dropdown" id="empDropdown">
                                <c:forEach var="emp" items="${empleados}">
                                    <c:set var="ini" value="${fn:toUpperCase(fn:substring(emp.nombre,0,1))}"/>
                                    <div class="search-option"
                                         data-id="${emp.id}"
                                         data-nombre="${emp.nombre}"
                                         data-sub="${emp.cargo} · ${emp.departamento}"
                                         onclick="seleccionarEmpleado(this.dataset.id,this.dataset.nombre,this.dataset.sub)">
                                        <div class="opt-avatar">${ini}</div>
                                        <div><p class="opt-name">${emp.nombre}</p><p class="opt-sub">${emp.cargo} &bull; ${emp.departamento}</p></div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty empleados}">
                                    <div style="padding:0.75rem 1rem;color:#6B7084;font-size:0.8rem;">No hay empleados registrados</div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- Selected employee preview -->
                    <div id="empPreview" style="display:none;background:#0d1520;border:1px solid rgba(0,255,255,0.3);border-radius:12px;padding:1.25rem;margin-bottom:1.5rem;">
                        <div style="display:flex;align-items:center;gap:1rem;">
                            <div id="prevAvatar" style="width:48px;height:48px;border-radius:50%;background:linear-gradient(135deg,#0ff,#0080ff);display:flex;align-items:center;justify-content:center;color:#0a0e17;font-size:1rem;font-weight:700;"></div>
                            <div style="flex:1;">
                                <p id="prevNombre" style="color:#fff;font-size:0.95rem;font-weight:600;margin:0;"></p>
                                <p id="prevSub" style="color:#8892a4;font-size:0.8rem;margin:0.15rem 0 0;"></p>
                            </div>
                            <span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.2rem 0.5rem;border-radius:20px;font-size:0.7rem;">ACTIVO</span>
                        </div>
                    </div>

                    <!-- Categoría de la cuenta -->
                    <div style="margin-bottom:1.5rem;">
                        <label style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;display:block;margin-bottom:0.75rem;">CATEGORÍA DE LA CUENTA</label>
                        <input type="hidden" name="categoria" id="categoriaHidden">
                        <div style="display:flex;flex-wrap:wrap;gap:0.5rem;" id="catChips">
                            <c:forEach var="cat" items="${categorias}" varStatus="vs">
                                <button type="button" class="cat-chip" id="chip${vs.index}" data-catid="${cat.id}" onclick="seleccionarCat(this)">${cat.nombre}</button>
                            </c:forEach>
                            <c:if test="${empty categorias}">
                                <span style="color:#6B7084;font-size:0.8rem;">No hay categorías disponibles</span>
                            </c:if>
                        </div>
                        <div class="pager-bar" id="catChipPager">
                            <button class="btn-pg" id="catPgPrev" onclick="catChipPage(-1)">&#8592; Anterior</button>
                            <span class="pg-info" id="catPgInfo"></span>
                            <button class="btn-pg" id="catPgNext" onclick="catChipPage(1)">Siguiente &#8594;</button>
                        </div>
                        <p style="color:#6B7084;font-size:0.7rem;margin-top:0.5rem;">El empleado solo puede tener una cuenta por categoría.</p>
                    </div>

                    <!-- Buttons -->
                    <div style="display:flex;gap:1rem;margin-top:2rem;">
                        <button type="submit" class="btn btn-primary" style="flex:1;">
                            Crear y Asignar Cuenta
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/cuentas" class="btn btn-outline">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
document.addEventListener('click', function(e) {
    if (!e.target.closest('.search-select-wrapper')) {
        document.getElementById('empDropdown').classList.remove('open');
    }
});

function abrirDropdown() {
    document.getElementById('empDropdown').classList.add('open');
}

function filtrarEmpleados() {
    var q = document.getElementById('empSearch').value.toLowerCase();
    document.querySelectorAll('#empDropdown .search-option').forEach(function(opt) {
        opt.style.display = opt.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
    document.getElementById('empDropdown').classList.add('open');
}

function seleccionarEmpleado(id, nombre, sub) {
    document.getElementById('empSearch').value = nombre;
    document.getElementById('empleadoIdHidden').value = id;
    document.getElementById('empDropdown').classList.remove('open');

    var initials = nombre.split(' ').map(function(w){return w[0];}).join('').substring(0,2).toUpperCase();
    document.getElementById('prevAvatar').textContent = initials;
    document.getElementById('prevNombre').textContent = nombre;
    document.getElementById('prevSub').textContent = sub;
    document.getElementById('empPreview').style.display = 'block';
}

function seleccionarCat(btn) {
    document.querySelectorAll('.cat-chip').forEach(function(c){ c.classList.remove('selected'); });
    btn.classList.add('selected');
    document.getElementById('categoriaHidden').value = btn.dataset.catid;
}

// ── Paginación de chips de categoría ──────────────────────────────────────
var _catPage = 0;
var _CAT_SIZE = 6;
var _catTotal = ${fn:length(categorias)};

function renderCatChips() {
    var pager = document.getElementById('catChipPager');
    if (!pager || _catTotal === 0) return;
    pager.style.display = 'flex';
    var pages = Math.ceil(_catTotal / _CAT_SIZE);
    var from  = _catPage * _CAT_SIZE;
    var to    = Math.min(from + _CAT_SIZE, _catTotal);
    for (var i = 0; i < _catTotal; i++) {
        var el = document.getElementById('chip' + i);
        if (el) el.style.display = (i >= from && i < to) ? '' : 'none';
    }
    document.getElementById('catPgInfo').textContent = 'Pág. ' + (_catPage + 1) + ' / ' + pages;
    document.getElementById('catPgPrev').disabled = (_catPage === 0);
    document.getElementById('catPgNext').disabled = (_catPage >= pages - 1);
}

function catChipPage(dir) {
    var pages = Math.ceil(_catTotal / _CAT_SIZE);
    _catPage = Math.max(0, Math.min(_catPage + dir, pages - 1));
    renderCatChips();
}

renderCatChips();
</script>
</body>
</html>
