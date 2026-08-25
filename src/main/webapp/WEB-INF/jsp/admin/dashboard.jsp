<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .modal-overlay-funds { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:300;align-items:center;justify-content:center; }
        .modal-overlay-funds.open { display:flex; }
        .modal-funds { background:#0d1520;border:1px solid rgba(0,255,255,0.2);border-radius:16px;padding:2rem;width:420px;max-width:95vw; }
        .funds-input { width:100%;padding:0.75rem;background:#111827;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:1rem;outline:none;box-sizing:border-box; }
        .funds-input:focus { border-color:#0ff; }

        .kpi-grid { display:grid;grid-template-columns:repeat(4,1fr);gap:1rem;margin-bottom:1.5rem; }
        .kpi-card { background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem 1.5rem; }
        .kpi-label { color:#8892a4;font-size:0.72rem;letter-spacing:1px;text-transform:uppercase;margin:0 0 0.4rem; }
        .kpi-value { color:#fff;font-size:1.6rem;font-weight:700;margin:0;line-height:1.1; }
        .kpi-accent { color:#0ff; }
        .kpi-sub { color:#6B7084;font-size:0.72rem;margin:0.3rem 0 0; }
        .dash-row { display:grid;grid-template-columns:3fr 2fr;gap:1.5rem;align-items:start; }
        .dash-header { display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem;gap:1rem; }
        .table-scroll { overflow-x:auto; }
        .filter-links { display:flex;gap:0.5rem;flex-wrap:wrap; }
        @media(max-width:1024px){
            .kpi-grid { grid-template-columns:repeat(2,1fr); }
            .dash-row  { grid-template-columns:1fr; }
        }
        @media(max-width:600px){
            .kpi-grid { grid-template-columns:1fr 1fr; }
            .dash-header { flex-direction:column; }
            .dash-header .btn { width:100%; justify-content:center; }
        }
        @media(max-width:400px){
            .kpi-grid { grid-template-columns:1fr; }
        }

        .emp-row-dash { display:flex;align-items:center;gap:0.75rem;padding:0.6rem 0;border-bottom:1px solid rgba(255,255,255,0.04); }
        .emp-row-dash:last-child { border-bottom:none; }

        .filter-link { display:inline-block;font-size:0.75rem;padding:0.4rem 0.9rem;border-radius:6px;border:1px solid rgba(255,255,255,0.12);color:#8892a4;text-decoration:none;transition:all 0.15s; }
        .filter-link:hover { border-color:#0ff;color:#0ff; }
        .filter-link.active { background:#0ff;color:#080A12;border-color:#0ff; }
    </style>
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "dashboard"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">

            <div class="dash-header">
                <div>
                    <h1 class="page-title" style="margin-bottom:0.25rem;">Resumen General</h1>
                    <p class="page-subtitle" style="margin:0;">Panel de control administrativo · FinTech Corp.</p>
                </div>
                <button onclick="document.getElementById('modalFondos').classList.add('open')"
                        class="btn btn-primary" style="display:inline-flex;align-items:center;gap:0.5rem;white-space:nowrap;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Agregar Fondos
                </button>
            </div>

            <!-- KPI cards -->
            <div class="kpi-grid">
                <div class="kpi-card" style="border-color:rgba(0,255,255,0.15);background:linear-gradient(135deg,#0a1628,#0d2040);">
                    <p class="kpi-label">Saldo Corporativo</p>
                    <p class="kpi-value kpi-accent">$<fmt:formatNumber value="${stats.saldoGlobal}" pattern="#,##0.00"/></p>
                    <p class="kpi-sub">MXN disponible</p>
                </div>
                <div class="kpi-card">
                    <p class="kpi-label">Empleados Activos</p>
                    <p class="kpi-value">${stats.empleadosActivos}</p>
                    <p class="kpi-sub">con acceso al sistema</p>
                </div>
                <div class="kpi-card">
                    <p class="kpi-label">Cuentas Activas</p>
                    <p class="kpi-value">${stats.cuentasActivas}</p>
                    <p class="kpi-sub">cuentas corporativas</p>
                </div>
                <div class="kpi-card">
                    <p class="kpi-label">Asignado este mes</p>
                    <p class="kpi-value" style="color:#00e676;">$<fmt:formatNumber value="${stats.transferidoMes}" pattern="#,##0"/></p>
                    <p class="kpi-sub">${stats.tarjetasEmitidas} tarjetas emitidas</p>
                </div>
            </div>

            <!-- Main row: transactions + employees -->
            <div class="dash-row">

                <!-- Transacciones -->
                <div>
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                        <div>
                            <h2 style="color:#fff;font-size:1rem;margin:0;">Últimas transacciones</h2>
                            <p style="color:#8892a4;font-size:0.72rem;margin:0.2rem 0 0;">Ingresos y fondos enviados a empleados</p>
                        </div>
                        <div class="filter-links">
                            <a href="?tipo=&page=1" class="filter-link ${empty tipoFiltro ? 'active' : ''}">Todas</a>
                            <a href="?tipo=deposito&page=1" class="filter-link ${'deposito' eq tipoFiltro ? 'active' : ''}">Ingresos</a>
                            <a href="?tipo=asignacion&page=1" class="filter-link ${'asignacion' eq tipoFiltro ? 'active' : ''}">Fondos</a>
                            <a href="?tipo=reversion&page=1" class="filter-link ${'reversion' eq tipoFiltro ? 'active' : ''}">Devoluciones</a>
                        </div>
                    </div>

                    <div class="table-scroll" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;">
                        <table style="width:100%;border-collapse:collapse;min-width:480px;">
                            <thead>
                                <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                    <th style="text-align:left;padding:0.9rem 1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Descripción</th>
                                    <th style="text-align:left;padding:0.9rem 1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Titular / Cuenta</th>
                                    <th style="text-align:left;padding:0.9rem 1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Fecha</th>
                                    <th style="text-align:right;padding:0.9rem 1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Monto</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty txPage.items}">
                                        <tr><td colspan="4" style="padding:2.5rem;text-align:center;color:#8892a4;font-size:0.85rem;">Sin movimientos registrados</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="m" items="${txPage.items}">
                                            <c:set var="esDeposito"   value="${m.tipo eq 'deposito'}"/>
                                            <c:set var="esReversion" value="${m.tipo eq 'reversion'}"/>
                                            <tr style="border-bottom:1px solid rgba(255,255,255,0.04);">
                                                <td style="padding:0.85rem 1rem;">
                                                    <p style="color:#fff;font-size:0.83rem;margin:0;">
                                                        <c:choose>
                                                            <c:when test="${esDeposito}">Depósito corporativo</c:when>
                                                            <c:when test="${esReversion}">Devolución por baja</c:when>
                                                            <c:otherwise>Fondos a empleado</c:otherwise>
                                                        </c:choose>
                                                    </p>
                                                    <p style="color:#6B7084;font-size:0.7rem;margin:0.1rem 0 0;">${m.concepto}</p>
                                                </td>
                                                <td style="padding:0.85rem 1rem;color:#8892a4;font-size:0.78rem;">
                                                    <c:choose>
                                                        <c:when test="${esDeposito}">Cuenta Global</c:when>
                                                        <c:when test="${esReversion}">Cuenta Global</c:when>
                                                        <c:otherwise>${m.titularDestino}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding:0.85rem 1rem;color:#6B7084;font-size:0.78rem;">
                                                    <fmt:formatDate value="${m.fecha}" pattern="dd MMM yyyy"/>
                                                </td>
                                                <td style="padding:0.85rem 1rem;text-align:right;font-weight:600;font-size:0.85rem;">
                                                    <c:choose>
                                                        <c:when test="${esDeposito}"><span style="color:#00e676;">+$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span></c:when>
                                                        <c:when test="${esReversion}"><span style="color:#00e676;">+$<fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/></span></c:when>
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

                    <!-- Paginación -->
                    <c:if test="${txPage.totalPages > 1}">
                    <div style="display:flex;align-items:center;justify-content:space-between;margin-top:0.9rem;">
                        <span style="color:#6B7084;font-size:0.78rem;">${txPage.fromRecord}–${txPage.toRecord} de ${txPage.totalCount}</span>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <c:choose>
                                <c:when test="${!txPage.first}"><a href="?page=${txPage.prevPage}&amp;tipo=${tipoFiltro}" class="pg-arrow">&#8592;</a></c:when>
                                <c:otherwise><span class="pg-arrow" style="opacity:0.3;">&#8592;</span></c:otherwise>
                            </c:choose>
                            <span style="color:#6B7084;font-size:0.78rem;">Página ${txPage.page} / ${txPage.totalPages}</span>
                            <c:choose>
                                <c:when test="${!txPage.last}"><a href="?page=${txPage.nextPage}&amp;tipo=${tipoFiltro}" class="pg-arrow">&#8594;</a></c:when>
                                <c:otherwise><span class="pg-arrow" style="opacity:0.3;">&#8594;</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    </c:if>
                </div>

                <!-- Empleados activos -->
                <div>
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                        <h2 style="color:#fff;font-size:1rem;margin:0;">Empleados Activos</h2>
                        <span style="background:rgba(0,230,118,0.12);color:#00e676;padding:0.2rem 0.65rem;border-radius:20px;font-size:0.7rem;">${stats.empleadosActivos} activos</span>
                    </div>
                    <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1rem 1.25rem;">
                        <div id="empList">
                            <c:choose>
                                <c:when test="${empty empleadosPanel}">
                                    <p style="color:#8892a4;font-size:0.8rem;text-align:center;padding:2rem 0;">Sin empleados</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="emp" items="${empleadosPanel}" varStatus="vs">
                                        <div class="emp-row-dash" data-idx="${vs.index}">
                                            <div style="width:34px;height:34px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.78rem;font-weight:600;flex-shrink:0;">
                                                ${fn:substring(emp.nombre,0,1)}
                                            </div>
                                            <div style="flex:1;min-width:0;">
                                                <p style="color:#fff;font-size:0.83rem;margin:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${emp.nombre}</p>
                                                <p style="color:#6B7084;font-size:0.7rem;margin:0;">${emp.departamento}</p>
                                            </div>
                                            <span style="width:7px;height:7px;border-radius:50%;background:#00e676;flex-shrink:0;"></span>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-top:0.75rem;padding-top:0.75rem;border-top:1px solid rgba(255,255,255,0.06);">
                            <button id="empPrev" onclick="empPage(-1)" style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8592;</button>
                            <span id="empInfo" style="color:#6B7084;font-size:0.72rem;"></span>
                            <button id="empNext" onclick="empPage(1)"  style="background:none;border:1px solid rgba(255,255,255,0.1);border-radius:5px;color:#8892a4;font-size:0.72rem;padding:0.3rem 0.65rem;cursor:pointer;">&#8594;</button>
                        </div>
                    </div>
                </div>

            </div><!-- /dash-row -->

        </div>
    </div>
</div>

<!-- Modal Agregar Fondos -->
<div class="modal-overlay-funds" id="modalFondos" onclick="if(event.target===this)cerrarModal()">
    <div class="modal-funds">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
            <div>
                <h3 style="color:#fff;font-size:1.1rem;margin:0;">Ingresar Fondos</h3>
                <p style="color:#6B7084;font-size:0.78rem;margin:0.2rem 0 0;">Depositar a la cuenta corporativa global</p>
            </div>
            <button onclick="cerrarModal()" style="background:none;border:none;color:#6B7084;cursor:pointer;font-size:1.2rem;">&#x2715;</button>
        </div>
        <form id="fondosForm" action="${pageContext.request.contextPath}/admin/fondos" method="POST">
            <div style="margin-bottom:1.5rem;">
                <label style="color:#8892a4;font-size:0.7rem;letter-spacing:1.5px;text-transform:uppercase;display:block;margin-bottom:0.5rem;">MONTO (MXN)</label>
                <input type="number" class="funds-input" name="monto" id="fondoMonto" placeholder="$0.00" min="1" step="0.01" required>
            </div>
            <div style="margin-bottom:1.5rem;">
                <label style="color:#8892a4;font-size:0.7rem;letter-spacing:1.5px;text-transform:uppercase;display:block;margin-bottom:0.5rem;">CONCEPTO</label>
                <input type="text" class="funds-input" name="concepto" id="fondoConcepto" placeholder="Ej. Aportación mensual" required>
            </div>
            <div style="display:flex;gap:0.75rem;">
                <button type="submit" class="btn btn-primary" style="flex:1;padding:0.8rem;">Confirmar Depósito</button>
                <button type="button" onclick="cerrarModal()" class="btn btn-outline" style="padding:0.8rem 1.2rem;">Cancelar</button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
function cerrarModal() {
    document.getElementById('modalFondos').classList.remove('open');
    document.getElementById('fondoMonto').value = '';
    document.getElementById('fondoConcepto').value = '';
}

var empCurrent = 0;
var EMP_PAGE = 6;
function empPage(delta) {
    var rows = document.querySelectorAll('.emp-row-dash');
    var total = rows.length;
    if (total === 0) return;
    var pages = Math.ceil(total / EMP_PAGE);
    empCurrent = Math.max(0, Math.min(empCurrent + delta, pages - 1));
    rows.forEach(function(r) {
        var idx = parseInt(r.dataset.idx, 10);
        r.style.display = (idx >= empCurrent * EMP_PAGE && idx < (empCurrent + 1) * EMP_PAGE) ? '' : 'none';
    });
    var from = empCurrent * EMP_PAGE + 1;
    var to   = Math.min((empCurrent + 1) * EMP_PAGE, total);
    document.getElementById('empInfo').textContent = from + '-' + to + ' de ' + total;
    document.getElementById('empPrev').disabled = empCurrent === 0;
    document.getElementById('empNext').disabled = empCurrent >= pages - 1;
}
empPage(0);
</script>
</body>
</html>
