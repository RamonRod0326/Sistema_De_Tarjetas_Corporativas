<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        /* ---- Hero Banner ---- */
        .hero-banner {
            background: linear-gradient(135deg, #0a1628 0%, #0d1f3c 50%, #0a1628 100%);
            border: 1px solid rgba(0,255,209,0.12);
            border-radius: 16px;
            padding: 2rem 2rem 1.75rem;
            margin-bottom: 1.5rem;
            position: relative;
            overflow: hidden;
        }
        .hero-banner::before {
            content: '';
            position: absolute;
            top: -40%;
            right: -10%;
            width: 320px;
            height: 320px;
            background: radial-gradient(circle, rgba(0,255,209,0.06) 0%, transparent 70%);
            pointer-events: none;
        }
        .hero-greeting { color: var(--text-secondary); font-size: 0.82rem; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 0.35rem; }
        .hero-name { color: #fff; font-size: 1.75rem; font-weight: 700; margin-bottom: 0.25rem; }
        .hero-sub { color: var(--text-secondary); font-size: 0.83rem; }
        .hero-saldo-label { color: var(--text-secondary); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 0.2rem; }
        .hero-saldo-val { color: var(--accent); font-size: 2.2rem; font-weight: 800; line-height: 1; }
        .hero-saldo-currency { color: var(--text-secondary); font-size: 0.8rem; font-weight: 500; margin-top: 0.2rem; }

        /* ---- Stat cards ---- */
        .stat-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-bottom: 1.5rem; }
        .stat-card { background: #0d1520; border: 1px solid rgba(255,255,255,0.07); border-radius: 12px; padding: 1.25rem; display: flex; align-items: center; gap: 1rem; }
        .stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-label { color: var(--text-secondary); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 0.2rem; }
        .stat-value { color: #fff; font-size: 1.3rem; font-weight: 700; line-height: 1.1; }

        /* ---- Cuenta card ---- */
        .cuenta-list { display: flex; flex-direction: column; gap: 0.6rem; }
        .cuenta-item { display: flex; align-items: center; gap: 0.9rem; background: #111827; border: 1px solid rgba(255,255,255,0.05); border-radius: 10px; padding: 0.85rem 1rem; }
        .cuenta-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .cuenta-info { flex: 1; min-width: 0; }
        .cuenta-nombre { color: #fff; font-size: 0.85rem; font-weight: 600; }
        .cuenta-num { color: var(--text-secondary); font-size: 0.7rem; font-family: monospace; }
        .cuenta-saldo { color: var(--accent); font-weight: 700; font-size: 0.9rem; white-space: nowrap; }
        .estado-badge { font-size: 0.62rem; padding: 0.15rem 0.45rem; border-radius: 20px; font-weight: 600; }

        /* ---- Movimiento item ---- */
        .mov-list { display: flex; flex-direction: column; gap: 0.85rem; }
        .mov-item { display: flex; align-items: center; gap: 0.85rem; }

        /* ---- Pager ---- */
        .pager-bar { display:none;align-items:center;justify-content:space-between;padding-top:0.6rem;margin-top:0.5rem;border-top:1px solid rgba(255,255,255,0.05); }
        .btn-pg { background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);color:#6B7084;cursor:pointer;padding:0.25rem 0.65rem;border-radius:6px;font-size:0.72rem; }
        .btn-pg:hover:not(:disabled) { background:rgba(0,255,255,0.1);color:#0ff;border-color:rgba(0,255,255,0.3); }
        .btn-pg:disabled { opacity:0.3;cursor:not-allowed; }
        .mov-icon { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .mov-concepto { color: #fff; font-size: 0.84rem; font-weight: 500; }
        .mov-meta { color: var(--text-secondary); font-size: 0.7rem; margin-top: 0.1rem; }
        .mov-monto { font-weight: 700; font-size: 0.88rem; white-space: nowrap; }

        /* ---- Mini tarjeta visual ---- */
        .mini-card { border-radius: 14px; padding: 1.5rem; background: linear-gradient(135deg,#0a1628,#1a2f50); border: 1px solid rgba(0,255,209,0.18); position: relative; overflow: hidden; }
        .mini-card::after { content:''; position:absolute; bottom:-30px; right:-30px; width:120px; height:120px; border-radius:50%; background:rgba(0,255,209,0.05); }
        .mini-card-num { color: #fff; font-size: 1rem; letter-spacing: 3px; font-family: monospace; margin: 0.75rem 0 0.5rem; }
        .mini-card-label { color: rgba(255,255,255,0.5); font-size: 0.62rem; text-transform: uppercase; letter-spacing: 1px; }
        .mini-card-name { color: #fff; font-size: 0.85rem; font-weight: 600; margin-top: 0.3rem; }
        .mini-card-chip { width: 28px; height: 22px; background: linear-gradient(135deg,#d4b85a,#e8c96e); border-radius: 4px; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "dashboard"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">

            <!-- ===== HERO BANNER ===== -->
            <div class="hero-banner">
                <div style="display:flex;justify-content:space-between;align-items:flex-end;flex-wrap:wrap;gap:1.5rem;">
                    <div>
                        <p class="hero-greeting">Bienvenido de nuevo</p>
                        <h1 class="hero-name">${sessionScope.usuario}</h1>
                        <p class="hero-sub">${sessionScope.cargo} &bull; ${sessionScope.departamento}</p>
                    </div>
                    <div style="text-align:right;">
                        <p class="hero-saldo-label">Saldo total</p>
                        <p class="hero-saldo-val">$<fmt:formatNumber value="${saldoTotal}" pattern="#,##0.00"/></p>
                        <p class="hero-saldo-currency">MXN</p>
                    </div>
                </div>
            </div>

            <!-- ===== STATS ===== -->
            <div class="stat-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(0,255,209,0.1);">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="2"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 0 0 0 4h4v-4h-4z"/></svg>
                    </div>
                    <div>
                        <p class="stat-label">Cuentas activas</p>
                        <p class="stat-value">${fn:length(cuentas)}</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(99,71,251,0.15);">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#7c63fc" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                    </div>
                    <div>
                        <p class="stat-label">Saldo promedio</p>
                        <c:set var="numCuentas" value="${fn:length(cuentas)}"/>
                        <p class="stat-value">$<fmt:formatNumber value="${numCuentas gt 0 ? saldoTotal / numCuentas : 0}" pattern="#,##0"/></p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(255,184,0,0.1);">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--warning)" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                    </div>
                    <div>
                        <p class="stat-label">Movimientos</p>
                        <p class="stat-value">${fn:length(movimientos)}</p>
                    </div>
                </div>
            </div>

            <!-- ===== CONTENIDO PRINCIPAL ===== -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;">

                <!-- Col 1: Mis cuentas -->
                <div style="display:flex;flex-direction:column;gap:1.5rem;">
                    <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.07);border-radius:12px;padding:1.5rem;">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.1rem;">
                            <h3 style="color:#fff;font-size:0.95rem;margin:0;">Mis Cuentas</h3>
                            <a href="${pageContext.request.contextPath}/user/tarjetas" style="font-size:0.78rem;color:var(--accent);">Ver tarjetas →</a>
                        </div>
                        <c:choose>
                            <c:when test="${empty cuentas}">
                                <div style="text-align:center;padding:2rem 0;color:var(--text-secondary);">
                                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:0.75rem;display:block;margin-inline:auto;"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/></svg>
                                    <p style="font-size:0.82rem;">Sin cuentas asignadas</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="cuenta-list" id="dashCtaList">
                                    <c:forEach var="cuenta" items="${cuentas}" varStatus="vs">
                                        <c:set var="activa" value="${cuenta.estado eq 'ACTIVA'}"/>
                                        <div class="cuenta-item" id="dashCta${vs.index}">
                                            <div class="cuenta-dot" style="background:${activa ? 'var(--accent)' : 'var(--warning)'};"></div>
                                            <div class="cuenta-info">
                                                <div class="cuenta-nombre">${cuenta.categoria}</div>
                                                <div class="cuenta-num">●●●● ${fn:substring(cuenta.numeroCuenta,12,16)}</div>
                                            </div>
                                            <c:choose>
                                                <c:when test="${activa}">
                                                    <span class="estado-badge" style="background:rgba(0,255,209,0.1);color:var(--accent);">ACTIVA</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="estado-badge" style="background:var(--warning-bg);color:var(--warning);">CONGELADA</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="cuenta-saldo">$<fmt:formatNumber value="${cuenta.saldo}" pattern="#,##0.00"/></span>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="pager-bar" id="dashCtaPager">
                                    <button class="btn-pg" id="dashCtaPrev" onclick="dashCtaPage(-1)">&#8249; Ant.</button>
                                    <span id="dashCtaInfo" style="color:#6B7084;font-size:0.72rem;"></span>
                                    <button class="btn-pg" id="dashCtaNext" onclick="dashCtaPage(1)">Sig. &#8250;</button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Mini tarjeta visual (primera cuenta) -->
                    <c:if test="${not empty cuentas}">
                        <div class="mini-card">
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                                <div>
                                    <p style="color:rgba(255,255,255,0.5);font-size:0.62rem;text-transform:uppercase;letter-spacing:2px;margin:0;">FinTech Corp</p>
                                    <p style="color:var(--accent);font-size:0.72rem;margin:0.15rem 0 0;">${cuentas[0].categoria}</p>
                                </div>
                                <div class="mini-card-chip"></div>
                            </div>
                            <p class="mini-card-num">●●●● ●●●● ●●●● ${fn:substring(cuentas[0].numeroCuenta,12,16)}</p>
                            <div style="display:flex;justify-content:space-between;align-items:flex-end;">
                                <div>
                                    <p class="mini-card-label">Titular</p>
                                    <p class="mini-card-name">${fn:toUpperCase(sessionScope.usuario)}</p>
                                </div>
                                <div style="text-align:right;">
                                    <p class="mini-card-label">Saldo</p>
                                    <p style="color:var(--accent);font-weight:700;font-size:0.95rem;">$<fmt:formatNumber value="${cuentas[0].saldo}" pattern="#,##0.00"/></p>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Col 2: Transacciones recientes -->
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.07);border-radius:12px;padding:1.5rem;">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.25rem;">
                        <h3 style="color:#fff;font-size:0.95rem;margin:0;">Transacciones recientes</h3>
                        <a href="${pageContext.request.contextPath}/user/transferencias" style="font-size:0.78rem;color:var(--accent);">Ver todo →</a>
                    </div>
                    <c:choose>
                        <c:when test="${empty movimientos}">
                            <div style="text-align:center;padding:3rem 0;color:var(--text-secondary);">
                                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="display:block;margin:0 auto 0.75rem;"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                                <p style="font-size:0.82rem;">Sin movimientos registrados</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mov-list" id="dashMovList">
                                <c:forEach var="m" items="${movimientos}" varStatus="vs">
                                    <div id="dashMov${vs.index}">
                                    <c:set var="esIngreso" value="${m.tipo eq 'asignacion_fondos'}"/>
                                    <div class="mov-item">
                                        <div class="mov-icon" style="background:${esIngreso ? 'rgba(0,230,118,0.1)' : 'rgba(255,82,82,0.1)'};">
                                            <c:choose>
                                                <c:when test="${esIngreso}">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00e676" stroke-width="2.5"><line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/></svg>
                                                </c:when>
                                                <c:otherwise>
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ff5252" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><polyline points="19 12 12 19 5 12"/></svg>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div style="flex:1;min-width:0;">
                                            <p class="mov-concepto">${m.concepto}</p>
                                            <p class="mov-meta">${m.catDestino} &bull; <fmt:formatDate value="${m.fecha}" pattern="dd MMM yyyy"/></p>
                                        </div>
                                        <c:choose>
                                            <c:when test="${esIngreso}">
                                                <span class="mov-monto" style="color:#00e676;">+$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="mov-monto" style="color:#ff5252;">-$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${!vs.last}">
                                        <div id="dashMovSep${vs.index}" style="height:1px;background:rgba(255,255,255,0.05);"></div>
                                    </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="pager-bar" id="dashMovPager">
                                <button class="btn-pg" id="dashMovPrev" onclick="dashMovPage(-1)">&#8249; Ant.</button>
                                <span id="dashMovInfo" style="color:#6B7084;font-size:0.72rem;"></span>
                                <button class="btn-pg" id="dashMovNext" onclick="dashMovPage(1)">Sig. &#8250;</button>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div><!-- /grid -->
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
var _dashCtaPage = 1, DASH_CTA_SIZE = 4, _dashCtaTotal = ${fn:length(cuentas)};
function renderDashCta() {
    var pages = Math.ceil(_dashCtaTotal / DASH_CTA_SIZE) || 1;
    var start = (_dashCtaPage - 1) * DASH_CTA_SIZE, end = Math.min(start + DASH_CTA_SIZE, _dashCtaTotal);
    for (var i = 0; i < _dashCtaTotal; i++) {
        var el = document.getElementById('dashCta' + i);
        if (el) el.style.display = (i >= start && i < end) ? '' : 'none';
    }
    var pager = document.getElementById('dashCtaPager');
    if (!pager || _dashCtaTotal === 0) return;
    pager.style.display = 'flex';
    document.getElementById('dashCtaInfo').textContent = (start+1) + '–' + end + ' de ' + _dashCtaTotal;
    document.getElementById('dashCtaPrev').disabled = (_dashCtaPage <= 1);
    document.getElementById('dashCtaNext').disabled = (_dashCtaPage >= pages);
}
function dashCtaPage(d) {
    var pages = Math.ceil(_dashCtaTotal / DASH_CTA_SIZE) || 1;
    _dashCtaPage = Math.max(1, Math.min(pages, _dashCtaPage + d));
    renderDashCta();
}

var _dashMovPage = 1, DASH_MOV_SIZE = 5, _dashMovTotal = ${fn:length(movimientos)};
function renderDashMov() {
    var pages = Math.ceil(_dashMovTotal / DASH_MOV_SIZE) || 1;
    var start = (_dashMovPage - 1) * DASH_MOV_SIZE, end = Math.min(start + DASH_MOV_SIZE, _dashMovTotal);
    for (var i = 0; i < _dashMovTotal; i++) {
        var el = document.getElementById('dashMov' + i);
        var sep = document.getElementById('dashMovSep' + i);
        var show = (i >= start && i < end);
        if (el) el.style.display = show ? '' : 'none';
        if (sep) sep.style.display = show ? '' : 'none';
    }
    var pager = document.getElementById('dashMovPager');
    if (!pager || _dashMovTotal === 0) return;
    pager.style.display = 'flex';
    document.getElementById('dashMovInfo').textContent = (start+1) + '–' + end + ' de ' + _dashMovTotal;
    document.getElementById('dashMovPrev').disabled = (_dashMovPage <= 1);
    document.getElementById('dashMovNext').disabled = (_dashMovPage >= pages);
}
function dashMovPage(d) {
    var pages = Math.ceil(_dashMovTotal / DASH_MOV_SIZE) || 1;
    _dashMovPage = Math.max(1, Math.min(pages, _dashMovPage + d));
    renderDashMov();
}

document.addEventListener('DOMContentLoaded', function() { renderDashCta(); renderDashMov(); });
</script>
</body>
</html>
