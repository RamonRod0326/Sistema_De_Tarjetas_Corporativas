<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cuentas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .emp-drawer-overlay { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:200; }
        .emp-drawer-overlay.open { display:block; }
        .emp-drawer { position:fixed;top:0;right:-480px;width:460px;height:100%;background:#0d1520;border-left:1px solid rgba(255,255,255,0.08);z-index:201;display:flex;flex-direction:column;transition:right 0.28s cubic-bezier(.4,0,.2,1);overflow-y:auto; }
        .emp-drawer.open { right:0; }
        .drawer-header { padding:1.5rem;border-bottom:1px solid rgba(255,255,255,0.07);display:flex;align-items:center;gap:1rem; }
        .drawer-avatar { width:52px;height:52px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:1rem;font-weight:700;flex-shrink:0; }
        .drawer-close { margin-left:auto;background:none;border:none;color:#6B7084;cursor:pointer;font-size:1.25rem;line-height:1; }
        .drawer-body { padding:1.25rem 1.5rem;flex:1; }
        .drawer-stats { display:grid;grid-template-columns:1fr 1fr 1fr;gap:0.75rem;margin-bottom:1.5rem; }
        .drawer-stat { background:#111827;border:1px solid rgba(255,255,255,0.06);border-radius:10px;padding:0.75rem;text-align:center; }
        .drawer-stat .val { color:#fff;font-size:1.1rem;font-weight:700; }
        .drawer-stat .lbl { color:#6B7084;font-size:0.7rem;margin-top:0.15rem; }
        .cuenta-card { background:#111827;border:1px solid rgba(255,255,255,0.06);border-radius:10px;padding:1rem;margin-bottom:0.75rem; }
        .cuenta-card-header { display:flex;justify-content:space-between;align-items:center;margin-bottom:0.6rem; }
        .cuenta-nombre { color:#fff;font-size:0.88rem;font-weight:600; }
        .cuenta-num { color:#6B7084;font-size:0.7rem;font-family:monospace;margin-top:0.1rem; }
        .cuenta-saldo { color:#0ff;font-size:1rem;font-weight:700; }
        .add-funds-row { display:flex;gap:0.5rem;margin-top:0.75rem;align-items:center; }
        .add-funds-input { flex:1;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:6px;color:#fff;padding:0.4rem 0.6rem;font-size:0.82rem;outline:none; }
        .add-funds-input:focus { border-color:#0ff; }
        .add-funds-btn { background:#0ff;color:#080A12;border:none;border-radius:6px;padding:0.4rem 0.9rem;font-size:0.78rem;font-weight:700;cursor:pointer;white-space:nowrap; }
        .total-bar { display:flex;justify-content:space-between;align-items:center;background:#111827;border:1px solid rgba(0,255,255,0.15);border-radius:10px;padding:0.85rem 1rem;margin-top:0.5rem; }
        .emp-row { cursor:pointer;transition:background 0.15s; }
        .emp-row:hover { background:rgba(255,255,255,0.03); }
        .modal-chip { padding:0.3rem 0.8rem;border-radius:20px;cursor:pointer;background:#0d1520;border:1px solid rgba(255,255,255,0.1);color:#8892a4;font-size:0.78rem;transition:all 0.15s; }
        .modal-chip.selected { background:rgba(0,255,255,0.12);border-color:#0ff;color:#0ff; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "cuentas"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title" style="margin-bottom:0.25rem;">Gestión de Cuentas</h1>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:1.5rem;">Haz clic en un empleado para ver el detalle de sus cuentas y administrar fondos.</p>

            <!-- Top cards -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-bottom:2rem;">
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <h3 style="color:#fff;font-size:1rem;margin:0 0 0.5rem;">Añadir Nuevo Talento</h3>
                    <p style="color:#8892a4;font-size:0.8rem;line-height:1.6;margin-bottom:1rem;">Crea cuentas corporativas para nuevos empleados y asigna fondos operativos iniciales.</p>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="color:#8892a4;font-size:0.8rem;">Cuentas Activas: <strong style="color:#0ff;">${stats.cuentasActivas}</strong></span>
                        <a href="${pageContext.request.contextPath}/admin/cuentas/form" class="btn btn-primary" style="font-size:0.8rem;padding:0.5rem 1rem;">Crear Cuenta</a>
                    </div>
                </div>
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <h3 style="color:#fff;font-size:1rem;margin:0 0 0.75rem;">Resumen General</h3>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.75rem;">
                        <div style="background:#111827;border-radius:8px;padding:0.75rem;">
                            <p style="color:#0ff;font-size:1.2rem;font-weight:700;margin:0;">${stats.cuentasActivas}</p>
                            <p style="color:#6B7084;font-size:0.72rem;margin:0.1rem 0 0;">Cuentas activas</p>
                        </div>
                        <div style="background:#111827;border-radius:8px;padding:0.75rem;">
                            <p style="color:#0ff;font-size:1.2rem;font-weight:700;margin:0;">${stats.empConCuenta}</p>
                            <p style="color:#6B7084;font-size:0.72rem;margin:0.1rem 0 0;">Empleados con cuenta</p>
                        </div>
                        <div style="background:#111827;border-radius:8px;padding:0.75rem;">
                            <p style="color:#0ff;font-size:1.2rem;font-weight:700;margin:0;">$<fmt:formatNumber value="${stats.totalCirculacion}" pattern="#,##0"/></p>
                            <p style="color:#6B7084;font-size:0.72rem;margin:0.1rem 0 0;">Total en circulación</p>
                        </div>
                        <div style="background:#111827;border-radius:8px;padding:0.75rem;">
                            <p style="color:#ffc107;font-size:1.2rem;font-weight:700;margin:0;">${stats.congeladas}</p>
                            <p style="color:#6B7084;font-size:0.72rem;margin:0.1rem 0 0;">Cuentas congeladas</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter & search (server-side) -->
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.75rem;">
                <h2 style="color:#fff;font-size:1rem;margin:0;">Directorio de Empleados</h2>
            </div>
            <form method="GET" action="${pageContext.request.contextPath}/admin/cuentas" style="display:flex;gap:0.75rem;align-items:center;margin-bottom:1rem;">
                <div style="flex:1;display:flex;align-items:center;background:#111827;border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:0.5rem 0.75rem;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6B7084" stroke-width="2" style="margin-right:0.5rem;flex-shrink:0;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" name="q" value="${q}" placeholder="Buscar empleado o departamento..." style="background:transparent;border:none;outline:none;color:#8892a4;font-size:0.82rem;width:100%;">
                </div>
                <button type="submit" class="btn btn-primary" style="padding:0.5rem 1rem;font-size:0.82rem;">Buscar</button>
            </form>

            <!-- Table -->
            <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                <table class="data-table" style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Empleado</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Departamento</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Cuentas</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Saldo Total</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Estado</th>
                            <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Ver detalle</th>
                        </tr>
                    </thead>
                    <tbody id="cuentasTbody">
                        <c:choose>
                            <c:when test="${empty pageResult.items}">
                                <tr><td colspan="6" style="padding:2rem;text-align:center;color:#8892a4;">Sin empleados con cuentas registradas</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="emp" items="${pageResult.items}">
                                    <c:set var="esCongelado" value="${emp.estadoEmp eq 'CONGELADO'}"/>
                                    <c:set var="esInactivo"  value="${emp.activo == 0}"/>
                                    <tr class="emp-row"
                                        style="border-bottom:1px solid rgba(255,255,255,0.05);${esInactivo ? 'opacity:0.6;' : ''}"
                                        onclick="openDrawer(${emp.id})">
                                        <td style="padding:1rem;">
                                            <div style="display:flex;align-items:center;gap:0.75rem;">
                                                <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">${fn:substring(emp.nombre,0,1)}</div>
                                                <div>
                                                    <p style="color:#fff;font-size:0.85rem;margin:0;">${emp.nombre}</p>
                                                    <p style="color:#8892a4;font-size:0.7rem;margin:0;">${emp.cargo}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td style="padding:1rem;color:#8892a4;font-size:0.82rem;">${emp.departamento}</td>
                                        <td style="padding:1rem;color:#0ff;font-size:0.85rem;font-weight:600;">${emp.numCuentas} cuenta<c:if test="${emp.numCuentas != 1}">s</c:if></td>
                                        <td style="padding:1rem;color:#fff;font-size:0.85rem;font-weight:600;">$<fmt:formatNumber value="${emp.saldoTotal}" pattern="#,##0.00"/> MXN</td>
                                        <td style="padding:1rem;">
                                            <c:choose>
                                                <c:when test="${esInactivo}">
                                                    <span style="background:rgba(255,82,82,0.15);color:#ff5252;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">INACTIVO</span>
                                                </c:when>
                                                <c:when test="${esCongelado}">
                                                    <span style="background:rgba(255,193,7,0.15);color:#ffc107;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">CONGELADO</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">ACTIVO</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding:1rem;text-align:right;"><span style="color:#0ff;font-size:0.75rem;">Ver cuentas →</span></td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Paginación -->
            <c:if test="${pageResult.totalPages > 1}">
            <div class="pg-bar-outer">
                <span class="pg-count">${pageResult.fromRecord}–${pageResult.toRecord} de ${pageResult.totalCount} empleados</span>
                <div class="pg-bar">
                    <c:choose>
                        <c:when test="${!pageResult.first}">
                            <a href="?page=${pageResult.prevPage}&amp;q=${q}" class="pg-arrow">&#8592;</a>
                        </c:when>
                        <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8592;</span></c:otherwise>
                    </c:choose>
                    <span class="pg-info">Página ${pageResult.page} de ${pageResult.totalPages}</span>
                    <c:choose>
                        <c:when test="${!pageResult.last}">
                            <a href="?page=${pageResult.nextPage}&amp;q=${q}" class="pg-arrow">&#8594;</a>
                        </c:when>
                        <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8594;</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
            </c:if>

        </div>
    </div>
</div>

<!-- DRAWER OVERLAY -->
<div class="emp-drawer-overlay" id="drawerOverlay" onclick="closeDrawer()"></div>

<!-- DRAWER PANEL -->
<div class="emp-drawer" id="empDrawer">
    <div class="drawer-header">
        <div class="drawer-avatar" id="drawerAvatar">?</div>
        <div>
            <p style="color:#fff;font-size:1rem;font-weight:600;margin:0;" id="drawerName">—</p>
            <p style="color:#6B7084;font-size:0.78rem;margin:0.15rem 0 0;" id="drawerCargo">—</p>
        </div>
        <button class="drawer-close" onclick="closeDrawer()">&#x2715;</button>
    </div>
    <div class="drawer-body">
        <div class="drawer-stats">
            <div class="drawer-stat"><div class="val" id="drawerNumCuentas">—</div><div class="lbl">Cuentas</div></div>
            <div class="drawer-stat"><div class="val" id="drawerNumTarjetas">—</div><div class="lbl">Tarjetas</div></div>
            <div class="drawer-stat"><div class="val" id="drawerEstado" style="font-size:0.78rem;">—</div><div class="lbl">Estado</div></div>
        </div>
        <div id="drawerBtnReactivar" style="display:none;margin-bottom:1rem;">
            <button style="width:100%;background:rgba(0,230,118,0.12);border:1px solid rgba(0,230,118,0.35);border-radius:8px;color:#00e676;padding:0.6rem;font-size:0.82rem;font-weight:600;cursor:pointer;">
                ↺ Reactivar empleado
            </button>
        </div>
        <p style="color:#6B7084;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.5px;margin:0 0 0.75rem;">Cuentas y fondos</p>
        <div id="drawerCuentas"></div>
        <div class="total-bar">
            <span style="color:#6B7084;font-size:0.8rem;">Saldo total del empleado</span>
            <span style="color:#0ff;font-size:1rem;font-weight:700;" id="drawerTotal">—</span>
        </div>
        <!-- Nueva tarjeta -->
        <div style="margin-top:1.25rem;">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.75rem;">
                <p style="color:#6B7084;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.5px;margin:0;">Tarjetas</p>
                <button onclick="toggleNuevaTarjeta()" style="background:rgba(0,255,255,0.1);border:1px solid rgba(0,255,255,0.3);border-radius:6px;color:#0ff;padding:0.3rem 0.7rem;font-size:0.72rem;cursor:pointer;">Nueva Tarjeta</button>
            </div>
            <div id="nuevaTarjetaForm" style="display:none;background:#111827;border:1px solid rgba(0,255,255,0.15);border-radius:10px;padding:1rem;margin-bottom:0.75rem;">
                <p style="color:#fff;font-size:0.82rem;font-weight:600;margin:0 0 0.75rem;">Emitir nueva tarjeta</p>
                <div style="margin-bottom:0.75rem;">
                    <label style="color:#6B7084;font-size:0.68rem;text-transform:uppercase;letter-spacing:1px;display:block;margin-bottom:0.4rem;">Cuenta asociada</label>
                    <select id="tarjetaCuenta" style="width:100%;padding:0.6rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:6px;color:#fff;font-size:0.8rem;outline:none;">
                        <option value="">-- Seleccionar cuenta --</option>
                    </select>
                </div>
                <div style="margin-bottom:0.75rem;">
                    <label style="color:#6B7084;font-size:0.68rem;text-transform:uppercase;letter-spacing:1px;display:block;margin-bottom:0.4rem;">Modalidad</label>
                    <div style="display:flex;gap:0.5rem;">
                        <button type="button" class="modal-chip selected" onclick="selModalidad(this,'Virtual')" id="chipVirtual">Virtual</button>
                        <button type="button" class="modal-chip" onclick="selModalidad(this,'Física')" id="chipFisica">Física</button>
                    </div>
                </div>
                <form id="tarjetaDrawerForm" action="${pageContext.request.contextPath}/admin/cuentas/tarjeta" method="POST">
                    <input type="hidden" name="cuentaId"  id="tarjetaCuentaHidden">
                    <input type="hidden" name="modalidad" id="tarjetaModalidadHidden" value="Virtual">
                    <div style="display:flex;gap:0.5rem;margin-top:0.75rem;">
                        <button type="submit" onclick="return prepararEmision()" style="flex:1;background:#0ff;color:#0a0e17;border:none;border-radius:6px;padding:0.55rem;font-size:0.78rem;font-weight:700;cursor:pointer;">Emitir Tarjeta</button>
                        <button type="button" onclick="toggleNuevaTarjeta()" style="background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:6px;color:#8892a4;padding:0.55rem 0.8rem;font-size:0.78rem;cursor:pointer;">Cancelar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
var saldoGlobal = ${stats.totalCirculacion};
var empleadosData = {};
var cuentasPorEmpleado = {};

<c:forEach var="emp" items="${pageResult.items}">
empleadosData[${emp.id}] = {
    nombre:    '${fn:replace(emp.nombre,"'","\\'")}',
    cargo:     '${fn:replace(emp.cargo,"'","\\'")} · ${fn:replace(emp.departamento,"'","\\'")}',
    cuentas:   ${emp.numCuentas},
    tarjetas:  ${emp.numTarjetas},
    saldo:     ${emp.saldoTotal},
    estado:    '${emp.estadoEmp}',
    activo:    ${emp.activo}
};
</c:forEach>

<c:forEach var="entry" items="${cuentasPorEmpleado}">
cuentasPorEmpleado[${entry.key}] = [
    <c:forEach var="c" items="${entry.value}">
    {
        cuentaId:  ${c.cuentaId},
        num:       '●●●● ${fn:substring(c.numeroCuenta,12,16)}',
        saldo:     ${c.saldo},
        estado:    '${c.estado}',
        categoria: '${fn:replace(c.categoria,"'","\\'")}',
        tarjetas:  ${c.tarjetas}
    },
    </c:forEach>
];
</c:forEach>

function openDrawer(uid) {
    var e = empleadosData[uid];
    if (!e) return;

    document.getElementById('drawerAvatar').textContent     = e.nombre.charAt(0);
    document.getElementById('drawerName').textContent       = e.nombre;
    document.getElementById('drawerCargo').textContent      = e.cargo;
    document.getElementById('drawerNumCuentas').textContent = e.cuentas;
    document.getElementById('drawerNumTarjetas').textContent= e.tarjetas;
    document.getElementById('drawerTotal').textContent      = '$' + e.saldo.toLocaleString('es-MX',{minimumFractionDigits:2}) + ' MXN';

    var estadoEl = document.getElementById('drawerEstado');
    if (e.activo === 0) {
        estadoEl.textContent = 'INACTIVO';
        estadoEl.style.color = '#ff5252';
    } else {
        estadoEl.textContent = e.estado;
        estadoEl.style.color = e.estado === 'ACTIVO' ? '#00e676' : '#ffc107';
    }

    var btnReactivar = document.getElementById('drawerBtnReactivar');
    btnReactivar.style.display = e.activo === 0 ? 'block' : 'none';
    btnReactivar.onclick = function() { reactivarEmpleado(uid); };

    var cuentas = cuentasPorEmpleado[uid] || [];
    var html = '';
    if (cuentas.length === 0) {
        html = '<p style="color:#6B7084;font-size:0.8rem;text-align:center;padding:1rem 0;">Sin cuentas activas</p>';
    }
    cuentas.forEach(function(c, i) {
        var badge = c.estado === 'ACTIVA'
            ? '<span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.15rem 0.5rem;border-radius:20px;font-size:0.65rem;">ACTIVA</span>'
            : '<span style="background:rgba(255,193,7,0.15);color:#ffc107;padding:0.15rem 0.5rem;border-radius:20px;font-size:0.65rem;">CONGELADA</span>';
        html += '<div class="cuenta-card" id="cuentaCard' + i + '">' +
            '<div class="cuenta-card-header">' +
                '<div>' +
                    '<p class="cuenta-nombre">' + c.categoria + ' ' + badge + '</p>' +
                    '<p class="cuenta-num">' + c.num + ' &bull; ' + c.tarjetas + ' tarjeta' + (c.tarjetas !== 1 ? 's' : '') + '</p>' +
                '</div>' +
                '<div style="display:flex;align-items:center;gap:0.5rem;">' +
                    '<span class="cuenta-saldo">$' + c.saldo.toLocaleString('es-MX',{minimumFractionDigits:2}) + '</span>' +
                    (c.estado === 'ACTIVA'
                        ? '<form action="${pageContext.request.contextPath}/admin/cuentas/editar" method="POST" style="display:inline;">' +
                              '<input type="hidden" name="cuentaId" value="' + c.cuentaId + '">' +
                              '<input type="hidden" name="estado" value="CONGELADA">' +
                              '<button type="submit" title="Congelar cuenta" style="background:rgba(33,150,243,0.12);border:1px solid rgba(33,150,243,0.35);border-radius:6px;color:#42a5f5;padding:0.25rem 0.55rem;cursor:pointer;font-size:0.7rem;font-weight:600;">❄ Congelar</button>' +
                          '</form>'
                        : '<form action="${pageContext.request.contextPath}/admin/cuentas/editar" method="POST" style="display:inline;">' +
                              '<input type="hidden" name="cuentaId" value="' + c.cuentaId + '">' +
                              '<input type="hidden" name="estado" value="ACTIVA">' +
                              '<button type="submit" title="Activar cuenta" style="background:rgba(0,230,118,0.12);border:1px solid rgba(0,230,118,0.35);border-radius:6px;color:#00e676;padding:0.25rem 0.55rem;cursor:pointer;font-size:0.7rem;font-weight:600;">▶ Activar</button>' +
                          '</form>') +
                    '<button type="button" onclick="confirmarEliminar(' + c.cuentaId + ')" style="background:rgba(255,77,106,0.08);border:1px solid rgba(255,77,106,0.2);border-radius:6px;color:#FF4D6A;padding:0.25rem 0.45rem;cursor:pointer;">' +
                        '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></svg>' +
                    '</button>' +
                '</div>' +
            '</div>' +
            '<form action="${pageContext.request.contextPath}/admin/cuentas/fondos" method="POST" style="margin-top:0.75rem;">' +
                '<input type="hidden" name="cuentaId" value="' + c.cuentaId + '">' +
                '<div class="add-funds-row">' +
                    '<input type="number" class="add-funds-input" name="monto" placeholder="Monto a agregar (MXN)" min="1" step="0.01" id="fondoInput' + i + '">' +
                    '<button type="submit" class="add-funds-btn" onclick="return validarFondo(' + i + ')">Agregar</button>' +
                '</div>' +
            '</form>' +
        '</div>';
    });
    document.getElementById('drawerCuentas').innerHTML = html;

    _currentUid = uid;
    document.getElementById('nuevaTarjetaForm').style.display = 'none';
    document.getElementById('drawerOverlay').classList.add('open');
    document.getElementById('empDrawer').classList.add('open');
}

function closeDrawer() {
    document.getElementById('drawerOverlay').classList.remove('open');
    document.getElementById('empDrawer').classList.remove('open');
}

var _currentUid = null;

function toggleNuevaTarjeta() {
    var f = document.getElementById('nuevaTarjetaForm');
    var visible = f.style.display !== 'none';
    f.style.display = visible ? 'none' : 'block';
    if (!visible) {
        var cuentas = cuentasPorEmpleado[_currentUid] || [];
        var sel = document.getElementById('tarjetaCuenta');
        sel.innerHTML = '<option value="">-- Seleccionar cuenta --</option>';
        cuentas.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = c.cuentaId;
            opt.textContent = c.categoria + ' · ' + c.num;
            sel.appendChild(opt);
        });
        selModalidad(document.getElementById('chipVirtual'), 'Virtual');
    }
}

function selModalidad(btn, val) {
    document.querySelectorAll('.modal-chip').forEach(function(c){ c.classList.remove('selected'); });
    btn.classList.add('selected');
    document.getElementById('tarjetaModalidadHidden').value = val;
}

function prepararEmision() {
    var cuentaId = document.getElementById('tarjetaCuenta').value;
    if (!cuentaId) {
        showToast('error','Cuenta requerida','Selecciona la cuenta a la que pertenece la tarjeta.');
        return false;
    }
    document.getElementById('tarjetaCuentaHidden').value = cuentaId;
    return true;
}

function confirmarEliminar(cuentaId) {
    if (!confirm('¿Eliminar esta cuenta? Se marcará como inactiva.')) return;
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/admin/cuentas/eliminar';
    var inp = document.createElement('input');
    inp.type='hidden'; inp.name='cuentaId'; inp.value=cuentaId;
    form.appendChild(inp);
    document.body.appendChild(form);
    form.submit();
}

async function reactivarEmpleado(id) {
    if (!confirm('¿Reactivar a este empleado? Se descongelarán sus cuentas y tarjetas.')) return;
    try {
        const res = await fetch('${pageContext.request.contextPath}/api/empleados?id=' + id, { method: 'PATCH' });
        const data = await res.json();
        if (data.ok) { closeDrawer(); location.reload(); }
        else showToast('error', 'Error', data.msg || 'No se pudo reactivar');
    } catch(e) {
        showToast('error', 'Error', 'Error de conexión');
    }
}

function validarFondo(idx) {
    var input = document.getElementById('fondoInput' + idx);
    var monto = parseFloat(input.value);
    if (!monto || monto <= 0) { input.style.borderColor='#FF4D6A'; setTimeout(function(){input.style.borderColor='';},1500); return false; }
    if (monto > saldoGlobal) {
        var disponible = saldoGlobal.toLocaleString('es-MX',{minimumFractionDigits:2});
        showToast('error','Saldo global insuficiente','Solo hay $' + disponible + ' MXN disponibles en la cuenta corporativa.');
        input.style.borderColor='#FF4D6A'; setTimeout(function(){input.style.borderColor='';},1500);
        return false;
    }
    var montoFmt = monto.toLocaleString('es-MX',{minimumFractionDigits:2,maximumFractionDigits:2});
    return confirm('¿Confirmar envío de $' + montoFmt + ' MXN a la cuenta del empleado?');
}

</script>
</body>
</html>
