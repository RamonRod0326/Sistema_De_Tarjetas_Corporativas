<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tarjetas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .card-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:1.25rem; }
        .tarjeta-visual { border-radius:14px;padding:1.5rem;position:relative;overflow:hidden;cursor:pointer;transition:transform 0.15s; }
        .tarjeta-visual:hover { transform:translateY(-3px); }
        .tarjeta-num { color:#fff;font-size:1.1rem;letter-spacing:3px;font-family:monospace;margin:0.75rem 0; }
        .detail-overlay { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:200; }
        .detail-overlay.open { display:block; }
        .detail-panel { position:fixed;top:0;right:-500px;width:460px;height:100%;background:#0d1520;border-left:1px solid rgba(255,255,255,0.08);z-index:201;overflow-y:auto;transition:right 0.28s cubic-bezier(.4,0,.2,1); }
        .detail-panel.open { right:0; }
        .detail-header { padding:1.5rem;border-bottom:1px solid rgba(255,255,255,0.07);display:flex;justify-content:space-between;align-items:center; }
        .detail-body { padding:1.5rem; }
        .info-field { margin-bottom:1rem; }
        .info-label { color:#6B7084;font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 0.2rem; }
        .info-value { color:#fff;font-size:0.88rem; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "tarjetas"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem;">
                <div>
                    <h1 class="page-title" style="margin:0;">Gestión de Tarjetas</h1>
                    <p style="color:#8892a4;font-size:0.85rem;margin-top:0.25rem;">Consulta el estado de todas las tarjetas corporativas emitidas.</p>
                </div>
            </div>

            <!-- Filtros (server-side) -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/tarjetas" style="display:flex;gap:0.75rem;align-items:center;margin-bottom:1.5rem;">
                <select name="estado" style="background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;padding:0.65rem 0.8rem;font-size:0.82rem;outline:none;">
                    <option value="" ${empty estadoFiltro ? 'selected' : ''}>Todos los estados</option>
                    <option value="ACTIVA" ${'ACTIVA' eq estadoFiltro ? 'selected' : ''}>Activa</option>
                    <option value="INACTIVA" ${'INACTIVA' eq estadoFiltro ? 'selected' : ''}>Inactiva</option>
                    <option value="BLOQUEADA" ${'BLOQUEADA' eq estadoFiltro ? 'selected' : ''}>Bloqueada</option>
                </select>
                <select name="modalidad" style="background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;padding:0.65rem 0.8rem;font-size:0.82rem;outline:none;">
                    <option value="" ${empty modalidadFiltro ? 'selected' : ''}>Todas las modalidades</option>
                    <option value="VIRTUAL" ${'VIRTUAL' eq modalidadFiltro ? 'selected' : ''}>Virtual</option>
                    <option value="FISICA" ${'FISICA' eq modalidadFiltro ? 'selected' : ''}>Física</option>
                </select>
                <button type="submit" class="btn btn-primary" style="padding:0.65rem 1.1rem;font-size:0.82rem;">Filtrar</button>
            </form>

            <c:choose>
                <c:when test="${empty pageResult.items}">
                    <div style="text-align:center;padding:3rem;color:#8892a4;">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="1.5" style="margin-bottom:1rem;"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                        <p>No hay tarjetas emitidas.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <script>var tarjetasData = {};</script>
                    <div class="card-grid" id="tarjetasGrid">
                        <c:forEach var="t" items="${pageResult.items}" varStatus="vs">
                            <c:set var="esActiva"    value="${t.estado eq 'ACTIVA'}"/>
                            <c:set var="esBloqueada" value="${t.estado eq 'BLOQUEADA'}"/>
                            <div class="tarjeta-item"
                                 data-titular="${fn:toLowerCase(t.titular)}"
                                 data-cat="${fn:toLowerCase(t.categoria)}"
                                 data-estado="${t.estado}"
                                 data-modal="${t.modalidad}"
                                 data-num="${t.numeroTarjeta}"
                                 onclick="verDetalle(${vs.index})">
                                <div class="tarjeta-visual" style="background:${esActiva ? 'linear-gradient(135deg,#0a1628,#162a4a);border:1px solid rgba(0,255,255,0.2)' : esBloqueada ? 'linear-gradient(135deg,#1a0a0a,#2a1010);border:1px solid rgba(255,82,82,0.2)' : 'linear-gradient(135deg,#1a1a1a,#2a2a2a);border:1px solid rgba(255,255,255,0.08)'};">
                                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                                        <p style="color:#8892a4;font-size:0.68rem;letter-spacing:2px;margin:0;">${t.modalidad}</p>
                                        <c:choose>
                                            <c:when test="${esActiva}"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.15rem 0.5rem;border-radius:20px;font-size:0.65rem;">ACTIVA</span></c:when>
                                            <c:when test="${esBloqueada}"><span style="background:rgba(255,82,82,0.15);color:#ff5252;padding:0.15rem 0.5rem;border-radius:20px;font-size:0.65rem;">BLOQUEADA</span></c:when>
                                            <c:otherwise><span style="background:rgba(255,82,82,0.15);color:#ff5252;padding:0.15rem 0.5rem;border-radius:20px;font-size:0.65rem;">${t.estado}</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <p class="tarjeta-num">&#x25CF;&#x25CF;&#x25CF;&#x25CF; &#x25CF;&#x25CF;&#x25CF;&#x25CF; &#x25CF;&#x25CF;&#x25CF;&#x25CF; ${fn:substring(t.numeroTarjeta,12,16)}</p>
                                    <p style="color:${esActiva ? '#0ff' : esBloqueada ? '#ff5252' : '#8892a4'};font-size:0.72rem;margin:0;">${t.categoria}</p>
                                    <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-top:1rem;">
                                        <p style="color:#fff;font-size:0.82rem;font-weight:600;margin:0;">${fn:toUpperCase(t.titular)}</p>
                                        <p style="color:#0ff;font-size:0.75rem;font-weight:600;margin:0;">$<fmt:formatNumber value="${t.saldo}" pattern="#,##0.00"/></p>
                                    </div>
                                </div>
                            </div>
                            <script>
                            tarjetasData[${vs.index}] = {
                                id:       ${t.id},
                                titular:  '${fn:replace(fn:toUpperCase(t.titular),"'","\\'")}',
                                num:      '●●●● ●●●● ●●●● ${fn:substring(t.numeroTarjeta,12,16)}',
                                cat:      '${fn:replace(t.categoria,"'","\\'")}',
                                modal:    '${t.modalidad}',
                                cuenta:   '●●●● ${fn:substring(t.numeroCuenta,12,16)}',
                                saldo:    ${t.saldo},
                                estado:   '${t.estado}',
                                empleado: '${fn:replace(t.titular,"'","\\'")} · ${fn:replace(t.departamento,"'","\\'")}',
                                esActiva: ${esActiva},
                                esBloqueada: ${esBloqueada}
                            };
                            </script>
                        </c:forEach>
                    </div>
                    <!-- Paginación -->
                    <c:if test="${pageResult.totalPages > 1}">
                    <div class="pg-bar-outer">
                        <span class="pg-count">${pageResult.fromRecord}–${pageResult.toRecord} de ${pageResult.totalCount} tarjetas</span>
                        <div class="pg-bar">
                            <c:choose>
                                <c:when test="${!pageResult.first}">
                                    <a href="?page=${pageResult.prevPage}&amp;estado=${estadoFiltro}&amp;modalidad=${modalidadFiltro}" class="pg-arrow">&#8592;</a>
                                </c:when>
                                <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8592;</span></c:otherwise>
                            </c:choose>
                            <span class="pg-info">Página ${pageResult.page} de ${pageResult.totalPages}</span>
                            <c:choose>
                                <c:when test="${!pageResult.last}">
                                    <a href="?page=${pageResult.nextPage}&amp;estado=${estadoFiltro}&amp;modalidad=${modalidadFiltro}" class="pg-arrow">&#8594;</a>
                                </c:when>
                                <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8594;</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Detail overlay -->
<div class="detail-overlay" id="detailOverlay" onclick="cerrarDetalle()"></div>
<div class="detail-panel" id="detailPanel">
    <div class="detail-header">
        <h3 style="color:#fff;font-size:1rem;margin:0;">Detalle de Tarjeta</h3>
        <button onclick="cerrarDetalle()" style="background:none;border:none;color:#6B7084;cursor:pointer;font-size:1.2rem;">&#x2715;</button>
    </div>
    <div class="detail-body">
        <div id="panelCardVisual" style="border-radius:12px;padding:1.25rem;margin-bottom:1.5rem;"></div>
        <div class="info-field"><p class="info-label">Titular</p><p class="info-value" id="dTitular"></p></div>
        <div class="info-field"><p class="info-label">Número</p><p class="info-value" style="font-family:monospace;letter-spacing:2px;" id="dNumero"></p></div>
        <div class="info-field"><p class="info-label">Categoría de cuenta</p><p class="info-value" id="dCategoria"></p></div>
        <div class="info-field"><p class="info-label">Modalidad</p><p class="info-value" id="dModalidad"></p></div>
        <div class="info-field"><p class="info-label">Cuenta asociada</p><p class="info-value" id="dCuenta"></p></div>
        <div class="info-field"><p class="info-label">Saldo disponible</p><p class="info-value" style="color:#0ff;font-size:1.1rem;font-weight:700;" id="dSaldo"></p></div>
        <div class="info-field"><p class="info-label">Estado</p><p class="info-value" id="dEstado"></p></div>
        <div class="info-field"><p class="info-label">Empleado</p><p class="info-value" id="dEmpleado"></p></div>

        <!-- Acciones -->
        <div style="margin-top:1.5rem;padding-top:1.25rem;border-top:1px solid rgba(255,255,255,0.07);display:flex;flex-direction:column;gap:0.6rem;">
            <p class="info-label" style="margin-bottom:0.4rem;">Acciones</p>
            <form id="formEstado" action="${pageContext.request.contextPath}/admin/tarjetas/estado" method="POST">
                <input type="hidden" name="id"     id="fEstadoId">
                <input type="hidden" name="estado" id="fEstadoVal">
                <button type="button" id="btnToggleEstado" onclick="confirmarEstado()"
                    style="width:100%;padding:0.65rem;border-radius:8px;border:none;font-size:0.82rem;font-weight:600;cursor:pointer;">
                </button>
            </form>
            <form id="formCancelar" action="${pageContext.request.contextPath}/admin/tarjetas/cancelar" method="POST"
                  onsubmit="return confirm('¿Cancelar esta tarjeta definitivamente? Esta acción no se puede deshacer.')">
                <input type="hidden" name="id" id="fCancelarId">
                <button type="submit"
                    style="width:100%;padding:0.65rem;border-radius:8px;border:1px solid rgba(255,77,106,0.4);background:rgba(255,77,106,0.08);color:#FF4D6A;font-size:0.82rem;font-weight:600;cursor:pointer;">
                    ✕ Cancelar tarjeta
                </button>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>

function verDetalle(idx) {
    var t = tarjetasData[idx];
    if (!t) return;
    document.getElementById('dTitular').textContent   = t.titular;
    document.getElementById('dNumero').textContent    = t.num;
    document.getElementById('dCategoria').textContent = t.cat;
    document.getElementById('dModalidad').textContent = t.modal;
    document.getElementById('dCuenta').textContent    = t.cuenta;
    document.getElementById('dSaldo').textContent     = '$' + t.saldo.toLocaleString('es-MX',{minimumFractionDigits:2}) + ' MXN';
    document.getElementById('dEmpleado').textContent  = t.empleado;

    var color = t.esActiva ? '#00e676' : '#ff5252';
    var bg    = t.esActiva ? 'rgba(0,230,118,0.15)' : 'rgba(255,82,82,0.15)';
    document.getElementById('dEstado').innerHTML = '<span style="background:' + bg + ';color:' + color + ';padding:0.2rem 0.6rem;border-radius:20px;font-size:0.78rem;">' + t.estado + '</span>';

    var grad = t.esActiva ? 'linear-gradient(135deg,#0a1628,#162a4a)' : t.esBloqueada ? 'linear-gradient(135deg,#1a0a0a,#2a1010)' : 'linear-gradient(135deg,#1a1a1a,#2a2a2a)';
    var acento = t.esActiva ? '#0ff' : '#ff5252';
    document.getElementById('panelCardVisual').style.background = grad;
    document.getElementById('panelCardVisual').innerHTML =
        '<p style="color:#8892a4;font-size:0.65rem;letter-spacing:2px;margin:0 0 0.5rem;">' + t.modal + '</p>' +
        '<p style="color:#fff;font-size:1rem;letter-spacing:3px;font-family:monospace;margin:0.4rem 0;">' + t.num + '</p>' +
        '<p style="color:' + acento + ';font-size:0.72rem;margin:0 0 0.5rem;">' + t.cat + '</p>' +
        '<p style="color:#fff;font-size:0.82rem;font-weight:600;margin:0;">' + t.titular + '</p>';

    // Acciones: botón toggle bloquear/desbloquear
    var btn = document.getElementById('btnToggleEstado');
    document.getElementById('fEstadoId').value   = t.id;
    document.getElementById('fCancelarId').value = t.id;
    if (t.esActiva) {
        btn.textContent = '🔒 Bloquear tarjeta';
        btn.style.background = 'rgba(255,193,7,0.12)';
        btn.style.border     = '1px solid rgba(255,193,7,0.35)';
        btn.style.color      = '#ffc107';
        document.getElementById('fEstadoVal').value = 'BLOQUEADA';
    } else {
        btn.textContent = '🔓 Desbloquear tarjeta';
        btn.style.background = 'rgba(0,230,118,0.12)';
        btn.style.border     = '1px solid rgba(0,230,118,0.35)';
        btn.style.color      = '#00e676';
        document.getElementById('fEstadoVal').value = 'ACTIVA';
    }

    document.getElementById('detailOverlay').classList.add('open');
    document.getElementById('detailPanel').classList.add('open');
}

function confirmarEstado() {
    var est = document.getElementById('fEstadoVal').value;
    var msg = est === 'BLOQUEADA'
        ? '¿Bloquear esta tarjeta? El titular no podrá utilizarla.'
        : '¿Desbloquear esta tarjeta? El titular podrá volver a utilizarla.';
    if (confirm(msg)) document.getElementById('formEstado').submit();
}

function cerrarDetalle() {
    document.getElementById('detailOverlay').classList.remove('open');
    document.getElementById('detailPanel').classList.remove('open');
}

</script>
</body>
</html>
