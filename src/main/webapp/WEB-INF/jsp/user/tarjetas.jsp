<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Tarjetas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .tarjetas-layout { display:grid;grid-template-columns:1fr 340px;gap:1.25rem;align-items:start; }
        .tarjeta-grid { display:flex;flex-direction:column;gap:0.6rem; }
        .tarjeta-row { display:flex;align-items:center;gap:1rem;background:#111827;border:1px solid rgba(255,255,255,0.07);border-radius:10px;padding:0.75rem 1rem;cursor:pointer;transition:border-color 0.15s,background 0.15s; }
        .tarjeta-row:hover { border-color:rgba(0,255,209,0.3);background:#151d2e; }
        .tarjeta-row.selected { border-color:var(--accent);background:rgba(0,255,209,0.05); }
        .tarjeta-color-square { width:44px;height:44px;border-radius:8px;flex-shrink:0;display:flex;align-items:center;justify-content:center; }
        .tarjeta-row-info { flex:1;min-width:0; }
        .tarjeta-row-top { display:flex;align-items:center;gap:0.5rem;margin-bottom:0.2rem; }
        .tarjeta-dots { color:#6B7084;font-size:0.75rem;letter-spacing:2px; }
        .tarjeta-last4 { color:#fff;font-weight:600;font-size:0.85rem; }
        .tarjeta-nombre { color:#6B7084;font-size:0.75rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
        .tarjeta-saldo { color:#fff;font-weight:600;font-size:0.9rem;text-align:right;white-space:nowrap; }
        .detalles-panel { background:#111827;border:1px solid rgba(255,255,255,0.07);border-radius:12px;padding:1.5rem;position:sticky;top:1rem; }
        .detalle-card-preview { border-radius:12px;padding:1.25rem;margin-bottom:1.25rem;min-height:130px;display:flex;flex-direction:column;justify-content:space-between; }
        .detalle-row { display:flex;justify-content:space-between;align-items:center;padding:0.6rem 0;border-bottom:1px solid rgba(255,255,255,0.05);font-size:0.8rem; }
        .detalle-row:last-child { border-bottom:none; }
        .detalle-label { color:#6B7084; }
        .detalle-value { color:#fff;font-weight:500;text-align:right; }
        .search-row { display:flex;gap:0.75rem;align-items:center;margin-bottom:1.25rem; }
        .search-input-wrap { flex:1;display:flex;align-items:center;background:#111827;border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:0.5rem 0.75rem; }
        .search-input-wrap input { background:transparent;border:none;outline:none;color:#8892a4;font-size:0.82rem;width:100%; }
        .estado-select { background:#111827;border:1px solid rgba(255,255,255,0.08);border-radius:8px;color:#8892a4;font-size:0.8rem;padding:0.5rem 0.75rem;outline:none; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "tarjetas"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <div style="margin-bottom:1.5rem;">
                <h1 class="page-title" style="margin-bottom:0.25rem;">Mis Tarjetas</h1>
                <p class="page-subtitle" style="margin:0;">Visualiza y gestiona tus tarjetas corporativas.</p>
            </div>

            <c:choose>
                <c:when test="${empty pageResult.items}">
                    <div style="text-align:center;padding:3rem;color:#8892a4;">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="1.5" style="margin-bottom:1rem;"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                        <p>No tienes tarjetas emitidas todavía.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <script>var tarjetaData = {};</script>
                    <!-- Filter (server-side) -->
                    <form method="GET" action="${pageContext.request.contextPath}/user/tarjetas" class="search-row">
                        <div class="search-input-wrap">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6B7084" stroke-width="2" style="margin-right:0.5rem;flex-shrink:0;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                            <input type="text" name="q" placeholder="Buscar por categoría..." style="background:transparent;border:none;outline:none;color:#8892a4;font-size:0.82rem;width:100%;">
                        </div>
                        <select name="estado" class="estado-select">
                            <option value="" ${empty estadoFiltro ? 'selected' : ''}>Todos los estados</option>
                            <option value="ACTIVA" ${'ACTIVA' eq estadoFiltro ? 'selected' : ''}>Activa</option>
                            <option value="BLOQUEADA" ${'BLOQUEADA' eq estadoFiltro ? 'selected' : ''}>Bloqueada</option>
                        </select>
                        <button type="submit" class="btn btn-primary" style="padding:0.5rem 1rem;font-size:0.82rem;">Filtrar</button>
                    </form>

                    <div class="tarjetas-layout">
                        <!-- Lista de tarjetas -->
                        <div class="tarjeta-grid" id="tarjetaGrid">
                            <c:set var="colores" value="linear-gradient(135deg,#00C9A7,#00927A),linear-gradient(135deg,#6347FB,#4020D0),linear-gradient(135deg,#2563EB,#1040B0),linear-gradient(135deg,#0E9488,#065F55),linear-gradient(135deg,#D97706,#92400E)"/>
                            <c:forEach var="t" items="${pageResult.items}" varStatus="vs">
                                <c:set var="colorIdx" value="${vs.index % 5}"/>
                                <div class="tarjeta-row ${vs.first ? 'selected' : ''}"
                                     data-alias="${fn:toLowerCase(t.categoria)}"
                                     data-estado="${t.estado}"
                                     data-idx="${vs.index}"
                                     onclick="selectTarjeta(this)">
                                    <div class="tarjeta-color-square" style="background:#00C9A7;">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="rgba(0,0,0,0.5)" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                                    </div>
                                    <div class="tarjeta-row-info">
                                        <div class="tarjeta-row-top">
                                            <span class="tarjeta-dots">●●●●</span>
                                            <span class="tarjeta-last4">${fn:substring(t.numeroTarjeta,12,16)}</span>
                                            <c:choose>
                                                <c:when test="${t.estado eq 'ACTIVA'}">
                                                    <span class="badge badge-success" style="font-size:0.65rem;padding:0.15rem 0.5rem;">ACTIVA</span>
                                                </c:when>
                                                <c:when test="${t.estado eq 'BLOQUEADA'}">
                                                    <span class="badge" style="background:rgba(255,77,106,0.15);color:#FF4D6A;font-size:0.65rem;padding:0.15rem 0.5rem;">BLOQUEADA</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background:rgba(107,112,132,0.2);color:#6B7084;font-size:0.65rem;padding:0.15rem 0.5rem;">${t.estado}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="tarjeta-nombre">${t.categoria} — ${sessionScope.usuario}</div>
                                    </div>
                                    <div class="tarjeta-saldo">
                                        $<fmt:formatNumber value="${t.saldo}" pattern="#,##0.00"/>
                                    </div>
                                    <script>
                                    tarjetaData[${vs.index}] = {
                                        last4:    '${fn:substring(t.numeroTarjeta,12,16)}',
                                        modalidad:'${t.modalidad}',
                                        estado:   '${t.estado}',
                                        categoria:'${fn:replace(t.categoria,"'","\\'")}',
                                        cuenta:   '●●●● ${fn:substring(t.numeroCuenta,12,16)}',
                                        saldo:    '$<fmt:formatNumber value="${t.saldo}" pattern="#,##0.00"/>',
                                        titular:  '${sessionScope.usuario}'
                                    };
                                    </script>
                                </div>
                            </c:forEach>
                            <!-- Paginación -->
                        <c:if test="${pageResult.totalCount > 0}">
                        <div class="pg-bar-outer">
                            <span class="pg-count">${pageResult.fromRecord}–${pageResult.toRecord} de ${pageResult.totalCount} tarjetas</span>
                            <div class="pg-bar">
                                <c:choose>
                                    <c:when test="${!pageResult.first}">
                                        <a href="?page=${pageResult.prevPage}&amp;estado=${estadoFiltro}" class="pg-arrow">&#8592;</a>
                                    </c:when>
                                    <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8592;</span></c:otherwise>
                                </c:choose>
                                <span class="pg-info">Página ${pageResult.page} de ${pageResult.totalPages}</span>
                                <c:choose>
                                    <c:when test="${!pageResult.last}">
                                        <a href="?page=${pageResult.nextPage}&amp;estado=${estadoFiltro}" class="pg-arrow">&#8594;</a>
                                    </c:when>
                                    <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8594;</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        </c:if>
                        </div>

                        <!-- Panel de detalles -->
                        <div class="detalles-panel">
                            <h3 style="color:#fff;font-size:0.95rem;margin:0 0 1.25rem;">Detalles de la tarjeta</h3>
                            <div class="detalle-card-preview" id="detallesPreview" style="background:linear-gradient(135deg,#00C9A7,#00927A);">
                                <div style="font-size:0.65rem;letter-spacing:2px;color:rgba(255,255,255,0.7);text-transform:uppercase;" id="d-tipo-label">CORPORATIVA · VIRTUAL</div>
                                <div>
                                    <div style="color:#fff;font-size:0.9rem;letter-spacing:3px;font-weight:600;" id="d-number">●●●● ●●●● ●●●● ----</div>
                                    <div style="color:rgba(255,255,255,0.8);font-size:0.72rem;text-transform:uppercase;letter-spacing:1px;margin-top:0.4rem;" id="d-holder">${sessionScope.usuario}</div>
                                </div>
                            </div>
                            <div>
                                <div class="detalle-row"><span class="detalle-label">Categoría</span><span class="detalle-value" id="d-alias">—</span></div>
                                <div class="detalle-row"><span class="detalle-label">Estado</span><span class="detalle-value"><span id="d-estado" class="badge badge-success">—</span></span></div>
                                <div class="detalle-row"><span class="detalle-label">Titular</span><span class="detalle-value" id="d-titular">${sessionScope.usuario}</span></div>
                                <div class="detalle-row"><span class="detalle-label">Cuenta asociada</span><span class="detalle-value" id="d-cuenta">—</span></div>
                                <div class="detalle-row"><span class="detalle-label">Modalidad</span><span class="detalle-value" id="d-modal">—</span></div>
                                <div class="detalle-row"><span class="detalle-label">Saldo disponible</span><span class="detalle-value" id="d-saldo">—</span></div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>


function selectTarjeta(el) {
    document.querySelectorAll('.tarjeta-row').forEach(function(r){ r.classList.remove('selected'); });
    el.classList.add('selected');
    var idx = el.dataset.idx;
    var d = tarjetaData[idx];
    if (!d) return;
    document.getElementById('d-number').textContent = '●●●● ●●●● ●●●● ' + d.last4;
    document.getElementById('d-tipo-label').textContent = d.categoria.toUpperCase() + ' · ' + d.modalidad;
    document.getElementById('d-alias').textContent = d.categoria;
    var badge = document.getElementById('d-estado');
    badge.textContent = d.estado;
    badge.className = 'badge';
    if (d.estado === 'ACTIVA') badge.classList.add('badge-success');
    else if (d.estado === 'BLOQUEADA') { badge.style.background='rgba(255,77,106,0.15)'; badge.style.color='#FF4D6A'; }
    else { badge.style.background='rgba(107,112,132,0.2)'; badge.style.color='#6B7084'; }
    document.getElementById('d-titular').textContent = d.titular;
    document.getElementById('d-cuenta').textContent  = d.cuenta;
    document.getElementById('d-modal').textContent   = d.modalidad;
    document.getElementById('d-saldo').textContent   = d.saldo;
}

// Seleccionar la primera tarjeta al cargar
window.addEventListener('DOMContentLoaded', function() {
    var first = document.querySelector('#tarjetaGrid .tarjeta-row');
    if (first) selectTarjeta(first);
});
</script>
</body>
</html>
