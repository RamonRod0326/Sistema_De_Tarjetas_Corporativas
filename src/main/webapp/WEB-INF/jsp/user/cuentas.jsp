<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Cuentas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .cuenta-card-sel { background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;cursor:pointer;transition:border-color 0.15s,transform 0.15s; }
        .cuenta-card-sel:hover { border-color:rgba(0,255,255,0.4);transform:translateY(-2px); }
        .cuenta-card-sel.active { border-color:#0ff;background:rgba(0,255,255,0.04); }
        .pager-bar { display:none;align-items:center;justify-content:space-between;padding-top:0.6rem;margin-top:0.75rem;border-top:1px solid rgba(255,255,255,0.05); }
        .btn-pg { background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);color:#6B7084;cursor:pointer;padding:0.25rem 0.65rem;border-radius:6px;font-size:0.72rem; }
        .btn-pg:hover:not(:disabled) { background:rgba(0,255,255,0.1);color:#0ff;border-color:rgba(0,255,255,0.3); }
        .btn-pg:disabled { opacity:0.3;cursor:not-allowed; }
        .transfer-panel { background:#0d1520;border:1px solid rgba(0,255,255,0.2);border-radius:12px;padding:1.5rem;margin-top:1.5rem;display:none; }
        .transfer-panel.open { display:block; }
        .tf-input { width:100%;padding:0.75rem;background:#111827;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;outline:none;box-sizing:border-box; }
        .tf-input:focus { border-color:#0ff; }
        .tf-label { color:#6B7084;font-size:0.68rem;text-transform:uppercase;letter-spacing:1.5px;display:block;margin-bottom:0.4rem; }
        .dest-wrapper { position:relative; }
        .dest-dropdown { display:none;position:absolute;top:calc(100% + 4px);left:0;right:0;background:#111827;border:1px solid rgba(255,255,255,0.1);border-radius:8px;z-index:50;max-height:180px;overflow-y:auto; }
        .dest-dropdown.open { display:block; }
        .dest-opt { padding:0.7rem 1rem;cursor:pointer;color:#fff;font-size:0.82rem; }
        .dest-opt:hover { background:rgba(0,255,255,0.06); }
        .dest-opt span { color:#6B7084;font-size:0.72rem;display:block; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "cuentas"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title" style="margin-bottom:0.25rem;">Mis Cuentas</h1>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:1.5rem;">Selecciona una cuenta para realizar una transferencia.</p>

            <!-- Tarjetas de cuentas desde DB -->
            <c:choose>
                <c:when test="${empty cuentas}">
                    <div style="text-align:center;padding:3rem;color:#8892a4;">
                        <p>No tienes cuentas activas asignadas.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <script>var cuentasJS = {};</script>
                    <div id="ctaGrid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:1rem;">
                        <c:forEach var="c" items="${cuentas}" varStatus="vs">
                            <c:set var="congelada" value="${c.estado ne 'ACTIVA'}"/>
                            <div class="cuenta-card-sel" id="cta-${vs.index}"
                                 onclick="seleccionarCuenta(${vs.index})"
                                 style="${congelada ? 'opacity:0.65;cursor:not-allowed;border-color:rgba(255,193,7,0.25);' : ''}">
                                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.75rem;">
                                    <h4 style="color:#fff;font-size:0.9rem;margin:0;">${c.categoria}</h4>
                                    <c:choose>
                                        <c:when test="${not congelada}">
                                            <span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.2rem 0.5rem;border-radius:20px;font-size:0.65rem;">Activa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="background:rgba(255,193,7,0.15);color:#ffc107;padding:0.2rem 0.5rem;border-radius:20px;font-size:0.65rem;">❄ Congelada</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <p style="color:#8892a4;font-size:0.7rem;font-family:monospace;margin:0;">●●●● ${fn:substring(c.numeroCuenta,12,16)}</p>
                                <p style="color:#fff;font-size:1.5rem;font-weight:700;margin:0.5rem 0;">$<fmt:formatNumber value="${c.saldo}" pattern="#,##0.00"/> <span style="font-size:0.75rem;color:#8892a4;font-weight:400;">MXN</span></p>
                                <c:choose>
                                    <c:when test="${not congelada}">
                                        <p style="color:#0ff;font-size:0.72rem;margin:0.5rem 0 0;">Haz clic para transferir →</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color:#ffc107;font-size:0.72rem;margin:0.5rem 0 0;">Cuenta suspendida temporalmente</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <script>
                            cuentasJS[${vs.index}] = {
                                id:          ${c.id},
                                nombre:      '${fn:replace(c.categoria,"'","\\'")}',
                                acct:        '●●●● ${fn:substring(c.numeroCuenta,12,16)}',
                                saldo:       ${c.saldo},
                                estado:      '${c.estado}',
                                categoria:   '${fn:replace(c.categoria,"'","\\'")}',
                                categoriaId: ${not empty c.categoriaId ? c.categoriaId : 'null'},
                                numCompleto: '${c.numeroCuenta}'
                            };
                            </script>
                        </c:forEach>
                    </div>
                    <div class="pager-bar" id="ctaCardPager">
                        <button class="btn-pg" id="ctaCardPrev" onclick="ctaCardPage(-1)">&#8249; Ant.</button>
                        <span id="ctaCardInfo" style="color:#6B7084;font-size:0.72rem;"></span>
                        <button class="btn-pg" id="ctaCardNext" onclick="ctaCardPage(1)">Sig. &#8250;</button>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Panel de transferencia -->
            <div class="transfer-panel" id="transferPanel">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.25rem;">
                    <div>
                        <h3 style="color:#fff;font-size:1rem;margin:0;">Nueva transferencia</h3>
                        <p style="color:#6B7084;font-size:0.78rem;margin:0.2rem 0 0;">Desde: <strong id="origenLabel" style="color:#0ff;"></strong></p>
                    </div>
                    <button onclick="cerrarTransfer()" style="background:none;border:none;color:#6B7084;cursor:pointer;font-size:1rem;">&#x2715; Cancelar</button>
                </div>
                <form id="transferForm" action="${pageContext.request.contextPath}/user/cuentas" method="POST">
                    <input type="hidden" name="cuentaOrigenId"  id="cuentaOrigenHidden">
                    <input type="hidden" name="cuentaDestinoId" id="destHidden">
                    <div class="two-col-equal" style="gap:1.25rem;margin-bottom:1.25rem;">
                        <div>
                            <label class="tf-label">CUENTA DESTINO</label>
                            <div class="dest-wrapper">
                                <input type="text" class="tf-input" id="destSearch" placeholder="Buscar empleado..." autocomplete="off" onfocus="abrirDest()" oninput="filtrarDest()">
                                <div class="dest-dropdown" id="destDropdown"></div>
                            </div>
                        </div>
                        <div>
                            <label class="tf-label">IMPORTE (MXN)</label>
                            <input type="number" class="tf-input" name="monto" id="tfMonto" placeholder="$0.00" min="1" step="0.01">
                        </div>
                    </div>
                    <div style="margin-bottom:1.25rem;">
                        <label class="tf-label">CONCEPTO</label>
                        <input type="text" class="tf-input" name="concepto" id="tfConcepto" placeholder="Ej: Viáticos octubre, Apoyo gasolina...">
                    </div>
                    <button type="button" onclick="confirmarTransferencia()" class="btn btn-primary" style="padding:0.8rem 2rem;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:6px;"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        Ejecutar Transferencia
                    </button>
                </form>
            </div>

            <!-- Movimientos recientes -->
            <div style="margin-top:2rem;">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                    <h2 style="color:#fff;font-size:1rem;margin:0;">Movimientos recientes</h2>
                </div>
                <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                    <table class="data-table" style="width:100%;border-collapse:collapse;">
                        <thead>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Descripción</th>
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Referencia</th>
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Fecha</th>
                                <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Monto</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty movimientos}">
                                    <tr><td colspan="4" style="padding:2rem;text-align:center;color:#8892a4;">Sin movimientos recientes</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="m" items="${movimientos}" varStatus="vs">
                                        <c:set var="esIngreso" value="${m.tipo eq 'asignacion_fondos' or m.direccion eq 'entrada'}"/>
                                        <tr id="ctaMov${vs.index}" style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                            <td style="padding:1rem;">
                                                <p style="color:#fff;font-size:0.85rem;margin:0;">${m.concepto}</p>
                                                <p style="color:#8892a4;font-size:0.7rem;margin:0.1rem 0 0;">
                                                    <c:choose>
                                                        <c:when test="${m.tipo eq 'asignacion_fondos'}">Admin → ●●●● ${fn:substring(m.destinoNum,12,16)}</c:when>
                                                        <c:otherwise>●●●● ${fn:substring(m.origenNum,12,16)} → ●●●● ${fn:substring(m.destinoNum,12,16)}</c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </td>
                                            <td style="padding:1rem;color:#8892a4;font-size:0.78rem;font-family:monospace;">${m.referencia}</td>
                                            <td style="padding:1rem;color:#8892a4;font-size:0.78rem;"><fmt:formatDate value="${m.fecha}" pattern="dd MMM, yyyy"/></td>
                                            <td style="padding:1rem;text-align:right;font-weight:600;font-size:0.85rem;">
                                                <c:choose>
                                                    <c:when test="${esIngreso}"><span style="color:#00e676;">+$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span></c:when>
                                                    <c:otherwise><span style="color:#ff5252;">-$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span></c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="pager-bar" id="ctaMovPager">
                    <button class="btn-pg" id="ctaMovPrev" onclick="ctaMovPage(-1)">&#8249; Ant.</button>
                    <span id="ctaMovInfo" style="color:#6B7084;font-size:0.72rem;"></span>
                    <button class="btn-pg" id="ctaMovNext" onclick="ctaMovPage(1)">Sig. &#8250;</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
const CTX = '${pageContext.request.contextPath}';

var ctaSeleccionada = null;
var _destTimer = null;

function seleccionarCuenta(idx) {
    ctaSeleccionada = cuentasJS[idx];
    if (!ctaSeleccionada) return;
    if (ctaSeleccionada.estado !== 'ACTIVA') {
        showToast('error', 'Cuenta congelada', 'Esta cuenta está suspendida y no permite operaciones. Contacta a tu administrador.');
        return;
    }
    document.getElementById('cuentaOrigenHidden').value = ctaSeleccionada.id;
    document.querySelectorAll('.cuenta-card-sel').forEach(function(c, i) { c.classList.toggle('active', i === idx); });
    document.getElementById('origenLabel').textContent =
        ctaSeleccionada.nombre + ' (' + ctaSeleccionada.acct + ') · $' +
        parseFloat(ctaSeleccionada.saldo).toLocaleString('es-MX',{minimumFractionDigits:2}) + ' MXN';
    document.getElementById('destSearch').value = '';
    document.getElementById('destHidden').value = '';
    document.getElementById('tfMonto').value = '';
    document.getElementById('tfConcepto').value = '';
    document.getElementById('destDropdown').classList.remove('open');
    document.getElementById('transferPanel').classList.add('open');
    document.getElementById('transferPanel').scrollIntoView({behavior:'smooth',block:'start'});
}

function cerrarTransfer() {
    ctaSeleccionada = null;
    document.querySelectorAll('.cuenta-card-sel').forEach(function(c){ c.classList.remove('active'); });
    document.getElementById('transferPanel').classList.remove('open');
}

function abrirDest() {
    if (!ctaSeleccionada) return;
    buscarDestinos(document.getElementById('destSearch').value);
    document.getElementById('destDropdown').classList.add('open');
}

function filtrarDest() {
    clearTimeout(_destTimer);
    _destTimer = setTimeout(function() {
        buscarDestinos(document.getElementById('destSearch').value);
        document.getElementById('destDropdown').classList.add('open');
    }, 280);
}

function buscarDestinos(q) {
    var catId = ctaSeleccionada ? ctaSeleccionada.categoriaId : null;
    if (!catId) {
        document.getElementById('destDropdown').innerHTML =
            '<div class="dest-opt" style="color:#6B7084;cursor:default;">Selecciona primero una cuenta origen</div>';
        return;
    }
    var dd = document.getElementById('destDropdown');
    dd.innerHTML = '<div class="dest-opt" style="color:#6B7084;cursor:default;">Buscando...</div>';
    var url = CTX + '/api/destinos?categoriaId=' + catId + (q ? '&q=' + encodeURIComponent(q) : '');
    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            dd.innerHTML = '';
            if (!Array.isArray(data) || data.length === 0) {
                dd.innerHTML = '<div class="dest-opt" style="color:#6B7084;cursor:default;">Sin resultados</div>';
                return;
            }
            data.forEach(function(o) {
                var acct = '●●●● ' + o.numeroCuenta.slice(-4);
                var div = document.createElement('div');
                div.className = 'dest-opt';
                div.innerHTML = esc(o.titular) + '<span>' + acct + ' · ' + esc(o.categoria) + '</span>';
                div.onclick = function() {
                    document.getElementById('destSearch').value = o.titular + ' — ' + acct;
                    document.getElementById('destHidden').value = o.id;
                    document.getElementById('destDropdown').classList.remove('open');
                };
                dd.appendChild(div);
            });
        })
        .catch(function() {
            dd.innerHTML = '<div class="dest-opt" style="color:#ff5252;cursor:default;">Error al buscar</div>';
        });
}

function esc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

document.addEventListener('click', function(e) {
    if (!e.target.closest('.dest-wrapper')) document.getElementById('destDropdown').classList.remove('open');
});

// ---- Paginación tarjetas cuentas (max 5, una fila) ----
var _ctaCardPage = 1, CTA_CARD_SIZE = 6;
function renderCtaCards() {
    var total = Object.keys(cuentasJS).length;
    var pages = Math.ceil(total / CTA_CARD_SIZE) || 1;
    var start = (_ctaCardPage - 1) * CTA_CARD_SIZE, end = Math.min(start + CTA_CARD_SIZE, total);
    for (var i = 0; i < total; i++) {
        var el = document.getElementById('cta-' + i);
        if (el) el.style.display = (i >= start && i < end) ? '' : 'none';
    }
    var pager = document.getElementById('ctaCardPager');
    if (!pager || total === 0) return;
    pager.style.display = 'flex';
    document.getElementById('ctaCardInfo').textContent = (start+1) + '–' + end + ' de ' + total;
    document.getElementById('ctaCardPrev').disabled = (_ctaCardPage <= 1);
    document.getElementById('ctaCardNext').disabled = (_ctaCardPage >= pages);
}
function ctaCardPage(d) {
    var total = Object.keys(cuentasJS).length;
    var pages = Math.ceil(total / CTA_CARD_SIZE) || 1;
    _ctaCardPage = Math.max(1, Math.min(pages, _ctaCardPage + d));
    renderCtaCards();
}

// ---- Paginación movimientos ----
var _ctaMovPage = 1, CTA_MOV_SIZE = 6, _ctaMovTotal = ${fn:length(movimientos)};
function renderCtaMov() {
    var pages = Math.ceil(_ctaMovTotal / CTA_MOV_SIZE) || 1;
    var start = (_ctaMovPage - 1) * CTA_MOV_SIZE, end = Math.min(start + CTA_MOV_SIZE, _ctaMovTotal);
    for (var i = 0; i < _ctaMovTotal; i++) {
        var el = document.getElementById('ctaMov' + i);
        if (el) el.style.display = (i >= start && i < end) ? '' : 'none';
    }
    var pager = document.getElementById('ctaMovPager');
    if (!pager || _ctaMovTotal === 0) return;
    pager.style.display = 'flex';
    document.getElementById('ctaMovInfo').textContent = (start+1) + '–' + end + ' de ' + _ctaMovTotal;
    document.getElementById('ctaMovPrev').disabled = (_ctaMovPage <= 1);
    document.getElementById('ctaMovNext').disabled = (_ctaMovPage >= pages);
}
function ctaMovPage(d) {
    var pages = Math.ceil(_ctaMovTotal / CTA_MOV_SIZE) || 1;
    _ctaMovPage = Math.max(1, Math.min(pages, _ctaMovPage + d));
    renderCtaMov();
}

document.addEventListener('DOMContentLoaded', function() {
    if (typeof cuentasJS !== 'undefined') renderCtaCards();
    renderCtaMov();
});

function confirmarTransferencia() {
    var destino   = document.getElementById('destHidden').value;
    var monto     = parseFloat(document.getElementById('tfMonto').value);
    var concepto  = document.getElementById('tfConcepto').value.trim();
    var destLabel = document.getElementById('destSearch').value;

    if (!destino)  { showToast('error','Cuenta destino requerida','Selecciona una cuenta de destino.'); return; }
    if (!monto||monto<=0) { showToast('error','Monto inválido','Ingresa un monto mayor a $0.'); return; }
    if (ctaSeleccionada && monto > parseFloat(ctaSeleccionada.saldo)) {
        var disponible = parseFloat(ctaSeleccionada.saldo).toLocaleString('es-MX',{minimumFractionDigits:2});
        showToast('error','Saldo insuficiente','El monto supera el saldo disponible ($' + disponible + ' MXN).');
        return;
    }
    if (!concepto) { showToast('error','Concepto requerido','Escribe el concepto de la transferencia.'); return; }

    var montoFmt = monto.toLocaleString('es-MX',{minimumFractionDigits:2,maximumFractionDigits:2});
    var msg = 'Enviarás <strong>$' + montoFmt + ' MXN</strong> a <strong>' + esc(destLabel) + '</strong>.<br>'
            + '<span style="color:#6B7084;font-size:0.8rem;">Concepto: ' + esc(concepto) + '</span>';

    showConfirm(msg, function() {
        document.getElementById('transferForm').submit();
    }, { title: '¿Confirmar transferencia?', confirmText: 'Sí, transferir', danger: false });
}
</script>
</body>
</html>
