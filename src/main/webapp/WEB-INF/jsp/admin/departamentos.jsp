<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Departamentos - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .page-header-row { display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem;gap:1rem; }
        .table-scroll { overflow-x:auto; }
        .table-scroll .data-table { min-width:360px; }
        @media(max-width:600px){
            .page-header-row { flex-direction:column; }
            .page-header-row .btn { width:100%;justify-content:center; }
        }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "departamentos"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">

            <div class="page-header-row">
                <div>
                    <h1 class="page-title" style="margin:0;">Gestión de Departamentos</h1>
                    <p style="color:#8892a4;font-size:0.85rem;margin-top:0.25rem;">CRUD con entidades enlazadas — departamentos y sus empleados asignados.</p>
                </div>
                <button class="btn btn-primary" onclick="abrirModalNuevo()" style="display:inline-flex;align-items:center;gap:0.5rem;flex-shrink:0;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Nuevo Departamento
                </button>
            </div>

            <div id="toast" style="display:none;position:fixed;bottom:1.5rem;right:1.5rem;background:#1e2d3d;border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:0.9rem 1.25rem;color:#fff;font-size:0.875rem;z-index:9999;min-width:260px;box-shadow:0 8px 32px rgba(0,0,0,0.4);"></div>

            <div class="two-col-layout">

                <!-- Tabla de departamentos -->
                <div>
                    <div style="margin-bottom:0.75rem;">
                        <input type="text" id="deptosBuscar" placeholder="Buscar departamento…" oninput="filtrarDeptos()"
                            style="width:100%;padding:0.7rem 1rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;outline:none;box-sizing:border-box;">
                    </div>
                    <div class="table-container table-scroll" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                        <table class="data-table" style="width:100%;border-collapse:collapse;">
                            <thead>
                                <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                    <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Departamento</th>
                                    <th style="text-align:center;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Empleados</th>
                                    <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="deptosTbody">
                                <tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">Cargando...</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- Paginación tabla izquierda -->
                    <div id="deptosPager" style="display:none;flex;align-items:center;justify-content:space-between;margin-top:0.75rem;">
                        <span id="deptosInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <button id="deptosPrev" onclick="deptosPage(-1)" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>
                            <span id="deptosPagInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                            <button id="deptosNext" onclick="deptosPage(1)"  style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>
                        </div>
                    </div>
                </div>

                <!-- Panel de empleados enlazados -->
                <div id="empleadosPanel" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;min-height:200px;">
                    <p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona un departamento para ver sus empleados</p>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- Modal crear / editar -->
<div id="modalOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.12);border-radius:16px;padding:2rem;width:100%;max-width:420px;box-shadow:0 24px 64px rgba(0,0,0,0.5);">
        <h2 id="modalTitle" style="color:#fff;margin:0 0 1.5rem;font-size:1.1rem;">Nuevo Departamento</h2>
        <input type="hidden" id="deptoId">
        <div style="margin-bottom:1.25rem;">
            <label style="display:block;color:#8892a4;font-size:0.8rem;margin-bottom:0.5rem;">Nombre del departamento *</label>
            <input type="text" id="deptoNombre" placeholder="Ej. Recursos Humanos"
                style="width:100%;padding:0.85rem;background:#060c14;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.9rem;outline:none;box-sizing:border-box;">
        </div>
        <div style="display:flex;gap:0.75rem;justify-content:flex-end;">
            <button type="button" onclick="cerrarModal()" class="btn" style="background:rgba(255,255,255,0.06);color:#8892a4;border:none;">Cancelar</button>
            <button type="button" id="btnGuardar" onclick="guardarDepto()" class="btn btn-primary">Guardar</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
const CTX = '${pageContext.request.contextPath}';
var _allDeptos = [];
var _filteredDeptos = [];
var _deptosCur = 0;
var DEPTOS_SIZE = 6;

function filtrarDeptos() {
    var q = document.getElementById('deptosBuscar').value.trim().toLowerCase();
    _filteredDeptos = q ? _allDeptos.filter(function(d){ return d.nombre.toLowerCase().includes(q); }) : _allDeptos.slice();
    _deptosCur = 0;
    renderDeptos();
}

function deptosPage(delta) {
    var total = _filteredDeptos.length;
    var pages = Math.ceil(total / DEPTOS_SIZE) || 1;
    _deptosCur = Math.max(0, Math.min(_deptosCur + delta, pages - 1));
    renderDeptos();
}

function renderDeptos() {
    var total = _filteredDeptos.length;
    var pages = Math.ceil(total / DEPTOS_SIZE) || 1;
    var slice = _filteredDeptos.slice(_deptosCur * DEPTOS_SIZE, (_deptosCur + 1) * DEPTOS_SIZE);
    var tbody = document.getElementById('deptosTbody');

    if (total === 0) {
        var q = document.getElementById('deptosBuscar') && document.getElementById('deptosBuscar').value.trim();
        tbody.innerHTML = '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">' + (q ? 'Sin resultados para "' + esc(q) + '"' : 'Sin departamentos registrados') + '</td></tr>';
        document.getElementById('deptosPager').style.display = 'none';
        return;
    }

    tbody.innerHTML = slice.map(function(d) {
        return '<tr style="border-bottom:1px solid rgba(255,255,255,0.05);cursor:pointer;transition:background 0.15s;" id="row-' + d.id + '"'
            + ' onclick="verEmpleados(' + d.id + ', \'' + esc(d.nombre) + '\')"'
            + ' onmouseenter="this.style.background=\'rgba(255,255,255,0.03)\'" onmouseleave="this.style.background=\'\'">'
            + '<td style="padding:0.9rem 1rem;color:#fff;font-size:0.875rem;">' + esc(d.nombre) + '</td>'
            + '<td style="padding:0.9rem 1rem;text-align:center;">'
            + '<span style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.2rem 0.6rem;border-radius:20px;font-size:0.75rem;">'
            + d.totalEmpleados + ' emp.</span></td>'
            + '<td style="padding:0.9rem 1rem;text-align:right;" onclick="event.stopPropagation()">'
            + '<button onclick="abrirModalEditar(' + d.id + ',\'' + esc(d.nombre) + '\')" title="Editar"'
            + ' style="background:none;border:none;cursor:pointer;color:#8892a4;margin-right:0.5rem;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>'
            + '<button onclick="eliminarDepto(' + d.id + ', ' + d.totalEmpleados + ')" title="Eliminar"'
            + ' style="background:none;border:none;cursor:pointer;color:#ff5252;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></button>'
            + '</td></tr>';
    }).join('');

    var from = _deptosCur * DEPTOS_SIZE + 1;
    var to   = Math.min((_deptosCur + 1) * DEPTOS_SIZE, total);
    // pager uses _filteredDeptos.length already via total
    document.getElementById('deptosInfo').textContent    = from + '-' + to + ' de ' + total;
    document.getElementById('deptosPagInfo').textContent = 'Pág. ' + (_deptosCur + 1) + ' / ' + pages;
    document.getElementById('deptosPrev').disabled = _deptosCur === 0;
    document.getElementById('deptosNext').disabled = _deptosCur >= pages - 1;
    document.getElementById('deptosPager').style.display = total > DEPTOS_SIZE ? 'flex' : 'none';
}

function toast(msg, ok) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.style.borderColor = ok ? 'rgba(0,230,118,0.3)' : 'rgba(255,82,82,0.3)';
    t.style.display = 'block';
    setTimeout(function() { t.style.display = 'none'; }, 3500);
}

async function api(method, url, body) {
    const opts = { method, headers: {'Content-Type':'application/json'} };
    if (body) opts.body = JSON.stringify(body);
    const res = await fetch(CTX + url, opts);
    return res.json();
}

async function cargarDeptos() {
    const tbody = document.getElementById('deptosTbody');
    try {
        const data = await api('GET', '/api/departamentos');
        _allDeptos = Array.isArray(data) ? data : [];
        _filteredDeptos = _allDeptos.slice();
        _deptosCur = 0;
        renderDeptos();
    } catch(e) {
        tbody.innerHTML = '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#ff5252;">Error al cargar departamentos</td></tr>';
    }
}

var _panelData = [];
var _panelPage = 0;
var PANEL_SIZE = 6;

function renderPanel() {
    var data = _panelData;
    var total = data.length;
    var pages = Math.ceil(total / PANEL_SIZE) || 1;
    _panelPage = Math.max(0, Math.min(_panelPage, pages - 1));
    var slice = data.slice(_panelPage * PANEL_SIZE, (_panelPage + 1) * PANEL_SIZE);

    var tbody = document.getElementById('panelTbody');
    if (!tbody) return;
    if (total === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="padding:1.5rem;text-align:center;color:#8892a4;">Sin empleados en este departamento</td></tr>';
    } else {
        tbody.innerHTML = slice.map(function(e) {
            return '<tr style="border-bottom:1px solid rgba(255,255,255,0.04);">'
                + '<td style="padding:0.65rem 0.75rem;color:#fff;font-size:0.82rem;">' + esc(e.nombre) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#8892a4;font-size:0.78rem;">' + esc(e.email) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#8892a4;font-size:0.78rem;">' + esc(e.cargo) + '</td>'
                + '</tr>';
        }).join('');
    }

    var infoEl = document.getElementById('panelInfo');
    var prevEl = document.getElementById('panelPrev');
    var nextEl = document.getElementById('panelNext');
    if (infoEl) {
        var from = total === 0 ? 0 : _panelPage * PANEL_SIZE + 1;
        var to   = Math.min((_panelPage + 1) * PANEL_SIZE, total);
        infoEl.textContent = total === 0 ? '0 registros' : (from + '-' + to + ' de ' + total);
    }
    if (prevEl) prevEl.disabled = _panelPage === 0;
    if (nextEl) nextEl.disabled = _panelPage >= pages - 1;
}

async function verEmpleados(deptId, deptNombre) {
    var panel = document.getElementById('empleadosPanel');
    panel.innerHTML = '<p style="color:#8892a4;text-align:center;padding:2rem;">Cargando...</p>';
    // highlight selected row
    document.querySelectorAll('#deptosTbody tr').forEach(function(r) { r.style.outline='none'; });
    var sel = document.getElementById('row-' + deptId);
    if (sel) sel.style.outline = '1px solid rgba(0,255,255,0.25)';

    try {
        const data = await api('GET', '/api/departamentos?id=' + deptId);
        _panelData = Array.isArray(data) ? data : [];
        _panelPage = 0;

        panel.innerHTML =
            '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">'
            + '<h3 style="color:#fff;margin:0;font-size:0.95rem;">Empleados: <span style="color:#0ff;">' + esc(deptNombre) + '</span></h3>'
            + '<span style="color:#6B7084;font-size:0.78rem;" id="panelInfo"></span>'
            + '</div>'
            + '<div style="overflow-x:auto;">'
            + '<table style="width:100%;border-collapse:collapse;">'
            + '<thead><tr style="border-bottom:1px solid rgba(255,255,255,0.08);">'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Nombre</th>'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Email</th>'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Cargo</th>'
            + '</tr></thead>'
            + '<tbody id="panelTbody"></tbody>'
            + '</table></div>'
            + '<div style="display:flex;align-items:center;justify-content:space-between;margin-top:0.75rem;padding-top:0.75rem;border-top:1px solid rgba(255,255,255,0.06);">'
            + '<button id="panelPrev" onclick="_panelPage--;renderPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>'
            + '<button id="panelNext" onclick="_panelPage++;renderPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>'
            + '</div>';

        renderPanel();
    } catch(e) {
        panel.innerHTML = '<p style="color:#ff5252;text-align:center;padding:2rem;">Error al cargar empleados</p>';
    }
}

function abrirModalNuevo() {
    document.getElementById('modalTitle').textContent = 'Nuevo Departamento';
    document.getElementById('deptoId').value = '';
    document.getElementById('deptoNombre').value = '';
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('deptoNombre').focus();
}

function abrirModalEditar(id, nombre) {
    document.getElementById('modalTitle').textContent = 'Editar Departamento';
    document.getElementById('deptoId').value = id;
    document.getElementById('deptoNombre').value = nombre;
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('deptoNombre').focus();
}

function cerrarModal() {
    document.getElementById('modalOverlay').style.display = 'none';
}

async function guardarDepto() {
    const id     = document.getElementById('deptoId').value;
    const nombre = document.getElementById('deptoNombre').value.trim();
    if (!nombre) { toast('El nombre del departamento es requerido', false); return; }

    const btn = document.getElementById('btnGuardar');
    btn.disabled = true;
    try {
        let res;
        if (id) {
            res = await api('PUT', '/api/departamentos', { id: parseInt(id), nombre });
        } else {
            res = await api('POST', '/api/departamentos', { nombre });
        }
        cerrarModal();
        toast(res.msg || (id ? 'Departamento actualizado' : 'Departamento creado'), res.ok);
        if (res.ok) cargarDeptos();
    } catch(e) {
        toast('Error de conexión', false);
    } finally {
        btn.disabled = false;
    }
}

async function eliminarDepto(id, totalEmp) {
    if (totalEmp > 0) {
        toast('No se puede eliminar: el departamento tiene ' + totalEmp + ' empleado(s) asignado(s)', false);
        return;
    }
    showConfirm('Esta acción eliminará el departamento permanentemente.', async function() {
        try {
            const res = await api('DELETE', '/api/departamentos?id=' + id);
            toast(res.msg || 'Operación completada', res.ok);
            if (res.ok) {
                document.getElementById('empleadosPanel').innerHTML =
                    '<p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona un departamento para ver sus empleados</p>';
                cargarDeptos();
            }
        } catch(e) { toast('Error de conexión', false); }
    }, { title: '¿Eliminar departamento?', confirmText: 'Sí, eliminar', danger: true });
}

document.getElementById('modalOverlay').addEventListener('click', function(e) {
    if (e.target === this) cerrarModal();
});

document.getElementById('deptoNombre').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') guardarDepto();
});

function esc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

cargarDeptos();
</script>
</body>
</html>
