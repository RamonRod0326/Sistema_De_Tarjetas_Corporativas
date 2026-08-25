<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Categorías de Cuenta - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "categorias"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">

            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem;">
                <div>
                    <h1 class="page-title" style="margin:0;">Categorías de Cuenta</h1>
                    <p style="color:#8892a4;font-size:0.85rem;margin-top:0.25rem;">CRUD con entidades enlazadas — categorías y sus cuentas asignadas.</p>
                </div>
                <button class="btn btn-primary" onclick="abrirModalNuevo()" style="display:inline-flex;align-items:center;gap:0.5rem;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Nueva Categoría
                </button>
            </div>

            <div id="toast" style="display:none;position:fixed;bottom:1.5rem;right:1.5rem;background:#1e2d3d;border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:0.9rem 1.25rem;color:#fff;font-size:0.875rem;z-index:9999;min-width:260px;box-shadow:0 8px 32px rgba(0,0,0,0.4);"></div>

            <div class="two-col-layout">

                <!-- Tabla de categorías -->
                <div>
                    <div style="margin-bottom:0.75rem;">
                        <input type="text" id="catsBuscar" placeholder="Buscar categoría…" oninput="filtrarCats()"
                            style="width:100%;padding:0.7rem 1rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;outline:none;box-sizing:border-box;">
                    </div>
                    <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                        <table class="data-table" style="width:100%;border-collapse:collapse;">
                            <thead>
                                <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                    <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Categoría</th>
                                    <th style="text-align:center;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Cuentas</th>
                                    <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="catsTbody">
                                <tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">Cargando...</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- Paginación tabla izquierda -->
                    <div id="catsPager" style="display:none;flex;align-items:center;justify-content:space-between;margin-top:0.75rem;">
                        <span id="catsInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <button id="catsPrev" onclick="catsPage(-1)" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>
                            <span id="catsPagInfo" style="color:#6B7084;font-size:0.78rem;"></span>
                            <button id="catsNext" onclick="catsPage(1)"  style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>
                        </div>
                    </div>
                </div>

                <!-- Panel de cuentas enlazadas -->
                <div id="cuentasPanel" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;min-height:200px;">
                    <p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona una categoría para ver sus cuentas</p>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- Modal crear / editar -->
<div id="modalOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.12);border-radius:16px;padding:2rem;width:100%;max-width:420px;box-shadow:0 24px 64px rgba(0,0,0,0.5);">
        <h2 id="modalTitle" style="color:#fff;margin:0 0 1.5rem;font-size:1.1rem;">Nueva Categoría</h2>
        <input type="hidden" id="catId">
        <div style="margin-bottom:1.25rem;">
            <label style="display:block;color:#8892a4;font-size:0.8rem;margin-bottom:0.5rem;">Nombre de la categoría *</label>
            <input type="text" id="catNombre" placeholder="Ej. Viáticos"
                style="width:100%;padding:0.85rem;background:#060c14;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.9rem;outline:none;box-sizing:border-box;">
        </div>
        <div style="display:flex;gap:0.75rem;justify-content:flex-end;">
            <button type="button" onclick="cerrarModal()" class="btn" style="background:rgba(255,255,255,0.06);color:#8892a4;border:none;">Cancelar</button>
            <button type="button" id="btnGuardar" onclick="guardarCat()" class="btn btn-primary">Guardar</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
const CTX = '${pageContext.request.contextPath}';
var _allCats = [];
var _filteredCats = [];
var _catsCur = 0;
var CATS_SIZE = 6;

function filtrarCats() {
    var q = document.getElementById('catsBuscar').value.trim().toLowerCase();
    _filteredCats = q ? _allCats.filter(function(c){ return c.nombre.toLowerCase().includes(q); }) : _allCats.slice();
    _catsCur = 0;
    renderCats();
}

function catsPage(delta) {
    var pages = Math.ceil(_filteredCats.length / CATS_SIZE) || 1;
    _catsCur = Math.max(0, Math.min(_catsCur + delta, pages - 1));
    renderCats();
}

function renderCats() {
    var total = _filteredCats.length;
    var pages = Math.ceil(total / CATS_SIZE) || 1;
    var slice = _filteredCats.slice(_catsCur * CATS_SIZE, (_catsCur + 1) * CATS_SIZE);
    var tbody = document.getElementById('catsTbody');

    if (total === 0) {
        var q = document.getElementById('catsBuscar') && document.getElementById('catsBuscar').value.trim();
        tbody.innerHTML = '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#8892a4;">' + (q ? 'Sin resultados para "' + esc(q) + '"' : 'Sin categorías registradas') + '</td></tr>';
        document.getElementById('catsPager').style.display = 'none';
        return;
    }

    tbody.innerHTML = slice.map(function(c) {
        return '<tr style="border-bottom:1px solid rgba(255,255,255,0.05);cursor:pointer;transition:background 0.15s;" id="row-' + c.id + '"'
            + ' onclick="verCuentas(' + c.id + ', \'' + esc(c.nombre) + '\')"'
            + ' onmouseenter="this.style.background=\'rgba(255,255,255,0.03)\'" onmouseleave="this.style.background=\'\'">'
            + '<td style="padding:0.9rem 1rem;color:#fff;font-size:0.875rem;">' + esc(c.nombre) + '</td>'
            + '<td style="padding:0.9rem 1rem;text-align:center;">'
            + '<span style="background:rgba(0,255,255,0.1);color:#0ff;padding:0.2rem 0.6rem;border-radius:20px;font-size:0.75rem;">'
            + c.totalCuentas + ' cta(s).</span></td>'
            + '<td style="padding:0.9rem 1rem;text-align:right;" onclick="event.stopPropagation()">'
            + '<button onclick="abrirModalEditar(' + c.id + ',\'' + esc(c.nombre) + '\')" title="Editar"'
            + ' style="background:none;border:none;cursor:pointer;color:#8892a4;margin-right:0.5rem;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>'
            + '<button onclick="eliminarCat(' + c.id + ', ' + c.totalCuentas + ')" title="Eliminar"'
            + ' style="background:none;border:none;cursor:pointer;color:#ff5252;">'
            + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></button>'
            + '</td></tr>';
    }).join('');

    var from = _catsCur * CATS_SIZE + 1;
    var to   = Math.min((_catsCur + 1) * CATS_SIZE, total);
    document.getElementById('catsInfo').textContent    = from + '-' + to + ' de ' + total;
    document.getElementById('catsPagInfo').textContent = 'Pág. ' + (_catsCur + 1) + ' / ' + pages;
    document.getElementById('catsPrev').disabled = _catsCur === 0;
    document.getElementById('catsNext').disabled = _catsCur >= pages - 1;
    document.getElementById('catsPager').style.display = total > CATS_SIZE ? 'flex' : 'none';
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

async function cargarCats() {
    const tbody = document.getElementById('catsTbody');
    try {
        const data = await api('GET', '/api/categorias');
        _allCats = Array.isArray(data) ? data : [];
        _filteredCats = _allCats.slice();
        _catsCur = 0;
        renderCats();
    } catch(e) {
        tbody.innerHTML = '<tr><td colspan="3" style="padding:2rem;text-align:center;color:#ff5252;">Error al cargar categorías</td></tr>';
    }
}

var _catData = [];
var _catPage = 0;
var CAT_PANEL_SIZE = 6;

function renderCatPanel() {
    var data = _catData;
    var total = data.length;
    var pages = Math.ceil(total / CAT_PANEL_SIZE) || 1;
    _catPage = Math.max(0, Math.min(_catPage, pages - 1));
    var slice = data.slice(_catPage * CAT_PANEL_SIZE, (_catPage + 1) * CAT_PANEL_SIZE);

    var tbody = document.getElementById('catPanelTbody');
    if (!tbody) return;
    if (total === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="padding:1.5rem;text-align:center;color:#8892a4;">Sin cuentas en esta categoría</td></tr>';
    } else {
        tbody.innerHTML = slice.map(function(c) {
            var estadoColor = c.estado === 'ACTIVA' ? '#00e676' : '#ffc107';
            return '<tr style="border-bottom:1px solid rgba(255,255,255,0.04);">'
                + '<td style="padding:0.65rem 0.75rem;color:#fff;font-size:0.82rem;">' + esc(c.titular) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#8892a4;font-size:0.78rem;font-family:monospace;">●●●● ' + esc(c.numeroCuenta).slice(-4) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;color:#0ff;font-size:0.82rem;text-align:right;font-weight:600;">$' + parseFloat(c.saldo).toLocaleString('es-MX',{minimumFractionDigits:2}) + '</td>'
                + '<td style="padding:0.65rem 0.75rem;text-align:center;"><span style="color:' + estadoColor + ';font-size:0.72rem;">' + esc(c.estado) + '</span></td>'
                + '</tr>';
        }).join('');
    }

    var infoEl = document.getElementById('catPanelInfo');
    var prevEl = document.getElementById('catPanelPrev');
    var nextEl = document.getElementById('catPanelNext');
    if (infoEl) {
        var from = total === 0 ? 0 : _catPage * CAT_PANEL_SIZE + 1;
        var to   = Math.min((_catPage + 1) * CAT_PANEL_SIZE, total);
        infoEl.textContent = total === 0 ? '0 registros' : (from + '-' + to + ' de ' + total);
    }
    if (prevEl) prevEl.disabled = _catPage === 0;
    if (nextEl) nextEl.disabled = _catPage >= pages - 1;
}

async function verCuentas(catId, catNombre) {
    var panel = document.getElementById('cuentasPanel');
    panel.innerHTML = '<p style="color:#8892a4;text-align:center;padding:2rem;">Cargando...</p>';
    document.querySelectorAll('#catsTbody tr').forEach(function(r) { r.style.outline='none'; });
    var sel = document.getElementById('row-' + catId);
    if (sel) sel.style.outline = '1px solid rgba(0,255,255,0.25)';

    try {
        const data = await api('GET', '/api/categorias?id=' + catId);
        _catData = Array.isArray(data) ? data : [];
        _catPage = 0;

        panel.innerHTML =
            '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">'
            + '<h3 style="color:#fff;margin:0;font-size:0.95rem;">Cuentas: <span style="color:#0ff;">' + esc(catNombre) + '</span></h3>'
            + '<span style="color:#6B7084;font-size:0.78rem;" id="catPanelInfo"></span>'
            + '</div>'
            + '<div style="overflow-x:auto;">'
            + '<table style="width:100%;border-collapse:collapse;">'
            + '<thead><tr style="border-bottom:1px solid rgba(255,255,255,0.08);">'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Titular</th>'
            + '<th style="text-align:left;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Número</th>'
            + '<th style="text-align:right;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Saldo</th>'
            + '<th style="text-align:center;padding:0.65rem 0.75rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Estado</th>'
            + '</tr></thead>'
            + '<tbody id="catPanelTbody"></tbody>'
            + '</table></div>'
            + '<div style="display:flex;align-items:center;justify-content:space-between;margin-top:0.75rem;padding-top:0.75rem;border-top:1px solid rgba(255,255,255,0.06);">'
            + '<button id="catPanelPrev" onclick="_catPage--;renderCatPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>'
            + '<button id="catPanelNext" onclick="_catPage++;renderCatPanel()" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>'
            + '</div>';

        renderCatPanel();
    } catch(e) {
        panel.innerHTML = '<p style="color:#ff5252;text-align:center;padding:2rem;">Error al cargar cuentas</p>';
    }
}

function abrirModalNuevo() {
    document.getElementById('modalTitle').textContent = 'Nueva Categoría';
    document.getElementById('catId').value = '';
    document.getElementById('catNombre').value = '';
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('catNombre').focus();
}

function abrirModalEditar(id, nombre) {
    document.getElementById('modalTitle').textContent = 'Editar Categoría';
    document.getElementById('catId').value = id;
    document.getElementById('catNombre').value = nombre;
    document.getElementById('modalOverlay').style.display = 'flex';
    document.getElementById('catNombre').focus();
}

function cerrarModal() {
    document.getElementById('modalOverlay').style.display = 'none';
}

async function guardarCat() {
    const id     = document.getElementById('catId').value;
    const nombre = document.getElementById('catNombre').value.trim();
    if (!nombre) { toast('El nombre de la categoría es requerido', false); return; }

    const btn = document.getElementById('btnGuardar');
    btn.disabled = true;
    try {
        let res;
        if (id) {
            res = await api('PUT', '/api/categorias', { id: parseInt(id), nombre });
        } else {
            res = await api('POST', '/api/categorias', { nombre });
        }
        cerrarModal();
        toast(res.msg || (id ? 'Categoría actualizada' : 'Categoría creada'), res.ok);
        if (res.ok) cargarCats();
    } catch(e) {
        toast('Error de conexión', false);
    } finally {
        btn.disabled = false;
    }
}

async function eliminarCat(id, totalCuentas) {
    if (totalCuentas > 0) {
        toast('No se puede eliminar: la categoría tiene ' + totalCuentas + ' cuenta(s) activa(s)', false);
        return;
    }
    showConfirm('Esta acción eliminará la categoría permanentemente.', async function() {
        try {
            const res = await api('DELETE', '/api/categorias?id=' + id);
            toast(res.msg || 'Operación completada', res.ok);
            if (res.ok) {
                document.getElementById('cuentasPanel').innerHTML =
                    '<p style="color:#8892a4;text-align:center;margin-top:3rem;">Selecciona una categoría para ver sus cuentas</p>';
                cargarCats();
            }
        } catch(e) { toast('Error de conexión', false); }
    }, { title: '¿Eliminar categoría?', confirmText: 'Sí, eliminar', danger: true });
}

document.getElementById('modalOverlay').addEventListener('click', function(e) {
    if (e.target === this) cerrarModal();
});

document.getElementById('catNombre').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') guardarCat();
});

function esc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

cargarCats();
</script>
</body>
</html>
