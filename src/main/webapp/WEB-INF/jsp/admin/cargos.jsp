<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cargos - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "cargos"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">

            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem;">
                <div>
                    <h1 class="page-title" style="margin:0;">Gestión de Cargos</h1>
                    <p style="color:#8892a4;font-size:0.85rem;margin-top:0.25rem;">CRUD con entidades enlazadas — cargos y sus empleados asignados.</p>
                </div>
                <button class="btn btn-primary" onclick="abrirModalNuevo()" style="display:inline-flex;align-items:center;gap:0.5rem;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Nuevo Cargo
                </button>
            </div>

            <!-- Toast -->
            <div id="toast" style="display:none;position:fixed;bottom:1.5rem;right:1.5rem;background:#1e2d3d;border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:0.9rem 1.25rem;color:#fff;font-size:0.875rem;z-index:9999;min-width:260px;box-shadow:0 8px 32px rgba(0,0,0,0.4);"></div>

            <div style="display:grid;grid-template-columns:1fr 1.4fr;gap:1.5rem;align-items:start;">

                <!-- ── Tabla de cargos ─────────────────────────────────────── -->
                <div>
                    <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                        <table class="data-table" style="width:100%;border-collapse:collapse;">
                            <thead>
                                <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                    <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Cargo</th>
                                    <th style="text-align:center;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Empleados</th>
                                    <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="cargosTbody">
                                <tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">Cargando...</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- Paginación tabla izquierda -->
                    <div id="cargosPager" style="display:none;align-items:center;justify-content:space-between;margin-top:0.75rem;">
                        <span id="cargosInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <button id="cargosPrev" onclick="cargosPage(-1)" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>
                            <span id="cargosPagInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                            <button id="cargosNext" onclick="cargosPage(1)"  style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>
                        </div>
                    </div>
                </div>

                <!-- ── Panel de empleados enlazados ───────────────────────── -->
                <div id="empleadosPanel" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;min-height:200px;">
                    <p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona un cargo para ver sus empleados</p>
                </div>

            </div>

        </div><!-- /content-area -->
    </div><!-- /main-content -->
</div><!-- /app-layout -->

<!-- ── Modal crear / editar cargo ─────────────────────────────────────────── -->
<div id="modalOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.12);border-radius:16px;padding:2rem;width:100%;max-width:420px;box-shadow:0 24px 64px rgba(0,0,0,0.5);">
        <h2 id="modalTitle" style="color:#fff;margin:0 0 1.5rem;font-size:1.1rem;">Nuevo Cargo</h2>
        <input type="hidden" id="cargoId">
        <div style="margin-bottom:1.25rem;">
            <label style="display:block;color:#8892a4;font-size:0.8rem;margin-bottom:0.5rem;">Nombre del cargo *</label>
            <input type="text" id="cargoNombre" placeholder="Ej. Analista Financiero"
                style="width:100%;padding:0.85rem;background:#060c14;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.9rem;outline:none;box-sizing:border-box;">
        </div>
        <div style="display:flex;gap:0.75rem;justify-content:flex-end;">
            <button type="button" onclick="cerrarModal()" class="btn" style="background:rgba(255,255,255,0.06);color:#8892a4;border:none;">Cancelar</button>
            <button type="button" id="btnGuardar" onclick="guardarCargo()" class="btn btn-primary">Guardar</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
const CTX = '${pageContext.request.contextPath}';

/* ── Paginación tabla izquierda (cargos) ─────────────────────────── */
var _allCargos = [];
var _cargosCur = 0;
var CARGOS_SIZE = 6;

function cargosPage(delta) {
    var pages = Math.ceil(_allCargos.length / CARGOS_SIZE) || 1;
    _cargosCur = Math.max(0, Math.min(_cargosCur + delta, pages - 1));
    renderCargos();
}

function renderCargos() {
    var total = _allCargos.length;
    var pages = Math.ceil(total / CARGOS_SIZE) || 1;
    var slice = _allCargos.slice(_cargosCur * CARGOS_SIZE, (_cargosCur + 1) * CARGOS_SIZE);
    var tbody = document.getElementById('cargosTbody');

    if (total === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">Sin cargos registrados</td></tr>';
        document.getElementById('cargosPager').style.display = 'none';
        return;
    }

    tbody.innerHTML = slice.map(function(c) {
        return '<tr style="border-bottom:1px solid rgba(255,255,255,0.05);cursor:pointer;transition:background 0.15s;" id="row-' + c.id + '"'
            + ' onclick="verEmpleados(' + c.id + ', \'' + esc(c.nombre) + '\')"'
            + ' onmouseenter="this.style.background=\'rgba(255,255,255,0.03)\'" onmouseleave="this.style.background=\'\'">'
            + '<td style="padding:0.9rem 1rem;color:#fff;font-size:0.875rem;">' + esc(c.nombre) + '</td>'
            + '<td style="padding:0.9rem 1rem;text-align:center;">'
            + '<span style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.2rem 0.6rem;border-radius:20px;font-size:0.75rem;">'
            + c.totalEmpleados + ' emp.</span></td>'
            + '<td style="padding:0.9rem 1rem;text-align:right;" onclick="event.stopPropagation()">'
            + '<button onclick="abrirModalEditar(' + c.id + ',\'' + esc(c.nombre) + '\')" title="Editar"'
            + ' style="background:none;border:none;cursor:pointer;color:#8892a4;margin-right:0.5rem;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>'
            + '<button onclick="eliminarCargo(' + c.id + ', ' + c.totalEmpleados + ')" title="Eliminar"'
            + ' style="background:none;border:none;cursor:pointer;color:#ff5252;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></button>'
            + '</td></tr>';
    }).join('');

    var from = _cargosCur * CARGOS_SIZE + 1;
    var to   = Math.min((_cargosCur + 1) * CARGOS_SIZE, total);
    document.getElementById('cargosInfo').textContent    = from + '-' + to + ' de ' + total;
    document.getElementById('cargosPagInfo').textContent = 'Pág. ' + (_cargosCur + 1) + ' / ' + pages;
    document.getElementById('cargosPrev').disabled = _cargosCur === 0;
    document.getElementById('cargosNext').disabled = _cargosCur >= pages - 1;
    document.getElementById('cargosPager').style.display = total > CARGOS_SIZE ? 'flex' : 'none';
}

/* ── Paginación panel derecho (empleados por cargo) ─────────────── */
var _cargoEmpData = [];
var _cargoEmpPage = 0;
var CARGO_PANEL_SIZE = 6;

function renderCargoPanel() {
    var data = _cargoEmpData;
    var total = data.length;
    var pages = Math.ceil(total / CARGO_PANEL_SIZE) || 1;
    _cargoEmpPage = Math.max(0, Math.min(_cargoEmpPage, pages - 1));
    var slice = data.slice(_cargoEmpPage * CARGO_PANEL_SIZE, (_cargoEmpPage + 1) * CARGO_PANEL_SIZE);

    var tbody = document.getElementById('cargoPanelTbody');
    if (!tbody) return;
    if (total === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="padding:1.5rem;text-align:center;color:#8892a4;">Sin empleados asignados a este cargo</td></tr>';
    } else {
        tbody.innerHTML = slice.map(function(e) {
            return '<tr style="border-bottom:1px solid rgba(255,255,255,0.04);">'
                + '<td style="padding:0.65rem 0.75rem;color:#fff;font-size:0.82rem;">' + esc(e.nombre) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#8892a4;font-size:0.78rem;">' + esc(e.email) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#8892a4;font-size:0.78rem;">' + esc(e.departamento) + '</td>'
                + '</tr>';
        }).join('');
    }
    var infoEl = document.getElementById('cargoPanelInfo');
    var prevEl = document.getElementById('cargoPanelPrev');
    var nextEl = document.getElementById('cargoPanelNext');
    if (infoEl) {
        var from = total === 0 ? 0 : _cargoEmpPage * CARGO_PANEL_SIZE + 1;
        var to   = Math.min((_cargoEmpPage + 1) * CARGO_PANEL_SIZE, total);
        infoEl.textContent = total === 0 ? '0 registros' : (from + '-' + to + ' de ' + total);
    }
    if (prevEl) prevEl.disabled = _cargoEmpPage === 0;
    if (nextEl) nextEl.disabled = _cargoEmpPage >= pages - 1;
}

/* ── Utilidades ─────────────────────────────────────────────────── */
function toast(msg, ok) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.style.borderColor = ok ? 'rgba(0,230,118,0.3)' : 'rgba(255,82,82,0.3)';
    t.style.display = 'block';
    setTimeout(() => t.style.display = 'none', 3500);
}

async function api(method, url, body) {
    const opts = { method, headers: {'Content-Type':'application/json'} };
    if (body) opts.body = JSON.stringify(body);
    const res = await fetch(CTX + url, opts);
    return res.json();
}

/* ── Cargar lista de cargos ─────────────────────────────────────── */
async function cargarCargos() {
    try {
        const data = await api('GET', '/api/cargos');
        _allCargos = Array.isArray(data) ? data : [];
        _cargosCur = 0;
        renderCargos();
    } catch(e) {
        document.getElementById('cargosTbody').innerHTML =
            '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#ff5252;">Error al cargar cargos</td></tr>';
    }
}

/* ── Ver empleados enlazados a un cargo ─────────────────────────── */
async function verEmpleados(cargoId, cargoNombre) {
    const panel = document.getElementById('empleadosPanel');
    panel.innerHTML = '<p style="color:#8892a4;text-align:center;padding:2rem;">Cargando...</p>';
    document.querySelectorAll('#cargosTbody tr').forEach(function(r){ r.style.outline='none'; });
    var sel = document.getElementById('row-' + cargoId);
    if (sel) sel.style.outline = '1px solid rgba(0,255,255,0.25)';

    try {
        const data = await api('GET', '/api/cargos?id=' + cargoId);
        _cargoEmpData = Array.isArray(data) ? data : [];
        _cargoEmpPage = 0;

        panel.innerHTML =
            '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">'
            + '<h3 style="color:#fff;margin:0;font-size:0.95rem;">Empleados: <span style="color:#0ff;">' + esc(cargoNombre) + '</span></h3>'
            + '<span style="color:#6B7084;font-size:0.78rem;" id="cargoPanelInfo"></span>'
            + '</div>'
            + '<div style="overflow-x:auto;">'
            + '<table style="width:100%;border-collapse:collapse;">'
            + '<thead><tr style="border-bottom:1px solid rgba(255,255,255,0.08);">'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Nombre</th>'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Email</th>'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Departamento</th>'
            + '</tr></thead>'
            + '<tbody id="cargoPanelTbody"></tbody>'
            + '</table></div>'
            + '<div style="display:flex;align-items:center;justify-content:space-between;margin-top:0.75rem;padding-top:0.75rem;border-top:1px solid rgba(255,255,255,0.06);">'
            + '<button id="cargoPanelPrev" onclick="_cargoEmpPage--;renderCargoPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>'
            + '<button id="cargoPanelNext" onclick="_cargoEmpPage++;renderCargoPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>'
            + '</div>';

        renderCargoPanel();
    } catch(e) {
        panel.innerHTML = '<p style="color:#ff5252;text-align:center;padding:2rem;">Error al cargar empleados</p>';
    }
}

/* ── Modal nuevo ────────────────────────────────────────────────── */
function abrirModalNuevo() {
    document.getElementById('modalTitle').textContent = 'Nuevo Cargo';
    document.getElementById('cargoId').value = '';
    document.getElementById('cargoNombre').value = '';
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('cargoNombre').focus();
}

function abrirModalEditar(id, nombre) {
    document.getElementById('modalTitle').textContent = 'Editar Cargo';
    document.getElementById('cargoId').value = id;
    document.getElementById('cargoNombre').value = nombre;
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('cargoNombre').focus();
}

function cerrarModal() {
    document.getElementById('modalOverlay').style.display = 'none';
}

/* ── Guardar (crear o editar) ───────────────────────────────────── */
async function guardarCargo() {
    const id     = document.getElementById('cargoId').value;
    const nombre = document.getElementById('cargoNombre').value.trim();
    if (!nombre) { toast('El nombre del cargo es requerido', false); return; }

    const btn = document.getElementById('btnGuardar');
    btn.disabled = true;
    try {
        let res;
        if (id) {
            res = await api('PUT', '/api/cargos', { id: parseInt(id), nombre });
        } else {
            res = await api('POST', '/api/cargos', { nombre });
        }
        cerrarModal();
        toast(res.msg || (id ? 'Cargo actualizado' : 'Cargo creado'), res.ok);
        if (res.ok) cargarCargos();
    } catch(e) {
        toast('Error de conexión', false);
    } finally {
        btn.disabled = false;
    }
}

/* ── Eliminar ────────────────────────────────────────────────────── */
async function eliminarCargo(id, totalEmp) {
    if (totalEmp > 0) {
        toast('No se puede eliminar: el cargo tiene ' + totalEmp + ' empleado(s) asignado(s)', false);
        return;
    }
    if (!confirm('¿Eliminar este cargo?')) return;
    try {
        const res = await api('DELETE', '/api/cargos?id=' + id);
        toast(res.msg || 'Operación completada', res.ok);
        if (res.ok) {
            document.getElementById('empleadosPanel').innerHTML =
                '<p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona un cargo para ver sus empleados</p>';
            cargarCargos();
        }
    } catch(e) {
        toast('Error de conexión', false);
    }
}

/* ── Cerrar modal al click fuera ─────────────────────────────────── */
document.getElementById('modalOverlay').addEventListener('click', function(e) {
    if (e.target === this) cerrarModal();
});

/* ── Escape HTML ─────────────────────────────────────────────────── */
function esc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ── Enter en el input del modal ─────────────────────────────────── */
document.getElementById('cargoNombre').addEventListener('keydown', e => {
    if (e.key === 'Enter') guardarCargo();
});

/* ── Init ────────────────────────────────────────────────────────── */
cargarCargos();
</script>
</body>
</html>
