<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transferencias - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "transferencias"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.25rem;">
                <h1 class="page-title" style="margin:0;">Historial de Transferencias</h1>
                <a href="${pageContext.request.contextPath}/user/cuentas" class="btn btn-primary" style="font-size:0.8rem;padding:0.5rem 1.1rem;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:5px;"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    Nueva transferencia
                </a>
            </div>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:1.5rem;">Para realizar una transferencia, selecciona una cuenta desde <a href="${pageContext.request.contextPath}/user/cuentas" style="color:#0ff;text-decoration:none;">Mis Cuentas</a>.</p>

            <!-- Stats del mes desde DB -->
            <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:1rem;margin-bottom:2rem;">
                <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.1rem;">
                    <p style="color:#8892a4;font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 0.3rem;">Este mes</p>
                    <p style="color:#fff;font-size:1.3rem;font-weight:700;margin:0;">${totalMes}</p>
                    <p style="color:#8892a4;font-size:0.72rem;margin:0.15rem 0 0;">Transferencias</p>
                </div>
                <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.1rem;">
                    <p style="color:#8892a4;font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 0.3rem;">Enviado</p>
                    <p style="color:#ff5252;font-size:1.3rem;font-weight:700;margin:0;">$<fmt:formatNumber value="${enviado}" pattern="#,##0.00"/></p>
                    <p style="color:#8892a4;font-size:0.72rem;margin:0.15rem 0 0;">MXN</p>
                </div>
                <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.1rem;">
                    <p style="color:#8892a4;font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 0.3rem;">Recibido</p>
                    <p style="color:#00e676;font-size:1.3rem;font-weight:700;margin:0;">$<fmt:formatNumber value="${recibido}" pattern="#,##0.00"/></p>
                    <p style="color:#8892a4;font-size:0.72rem;margin:0.15rem 0 0;">MXN</p>
                </div>
                <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.1rem;">
                    <p style="color:#8892a4;font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 0.3rem;">Neto</p>
                    <p style="color:#0ff;font-size:1.3rem;font-weight:700;margin:0;">
                        <c:choose>
                            <c:when test="${neto >= 0}">+</c:when>
                            <c:otherwise></c:otherwise>
                        </c:choose>$<fmt:formatNumber value="${neto < 0 ? -neto : neto}" pattern="#,##0.00"/>
                    </p>
                    <p style="color:#8892a4;font-size:0.72rem;margin:0.15rem 0 0;">MXN</p>
                </div>
            </div>

            <!-- Filtros (server-side) -->
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:0.75rem;">
                <div style="display:flex;gap:0.5rem;">
                    <a href="?tipo=" class="hfil" style="background:${empty tipoFiltro ? '#0ff' : '#0d1520'};color:${empty tipoFiltro ? '#0a0e17' : '#8892a4'};border:${empty tipoFiltro ? 'none' : '1px solid rgba(255,255,255,0.1)'};border-radius:20px;padding:0.35rem 0.9rem;font-size:0.75rem;font-weight:${empty tipoFiltro ? '600' : 'normal'};text-decoration:none;cursor:pointer;">Todas</a>
                    <a href="?tipo=enviada" class="hfil" style="background:${'enviada' eq tipoFiltro ? '#0ff' : '#0d1520'};color:${'enviada' eq tipoFiltro ? '#0a0e17' : '#8892a4'};border:${'enviada' eq tipoFiltro ? 'none' : '1px solid rgba(255,255,255,0.1)'};border-radius:20px;padding:0.35rem 0.9rem;font-size:0.75rem;font-weight:${'enviada' eq tipoFiltro ? '600' : 'normal'};text-decoration:none;cursor:pointer;">Enviadas</a>
                    <a href="?tipo=recibida" class="hfil" style="background:${'recibida' eq tipoFiltro ? '#0ff' : '#0d1520'};color:${'recibida' eq tipoFiltro ? '#0a0e17' : '#8892a4'};border:${'recibida' eq tipoFiltro ? 'none' : '1px solid rgba(255,255,255,0.1)'};border-radius:20px;padding:0.35rem 0.9rem;font-size:0.75rem;font-weight:${'recibida' eq tipoFiltro ? '600' : 'normal'};text-decoration:none;cursor:pointer;">Recibidas</a>
                </div>
            </div>

            <!-- Historial desde DB -->
            <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                <table style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Referencia</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Concepto</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Contraparte</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Fecha</th>
                            <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.72rem;font-weight:500;">Monto</th>
                        </tr>
                    </thead>
                    <tbody id="histTbody">
                        <c:choose>
                            <c:when test="${empty pageResult.items}">
                                <tr><td colspan="5" style="padding:2rem;text-align:center;color:#8892a4;">Sin transferencias registradas</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="h" items="${pageResult.items}">
                                    <c:set var="esEnviada" value="${h.tipo eq 'enviada'}"/>
                                    <c:set var="contraparte" value="${esEnviada ? h.destinoTitular : h.origenTitular}"/>
                                    <c:set var="contraparteIni" value="${fn:substring(contraparte,0,1)}"/>
                                    <tr data-tipo="${h.tipo}" style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                        <td style="padding:0.9rem 1rem;color:#8892a4;font-size:0.75rem;font-family:monospace;">${h.referencia}</td>
                                        <td style="padding:0.9rem 1rem;color:#fff;font-size:0.82rem;">${h.concepto}</td>
                                        <td style="padding:0.9rem 1rem;">
                                            <div style="display:flex;align-items:center;gap:0.5rem;">
                                                <div style="width:26px;height:26px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.65rem;font-weight:700;">${contraparteIni}</div>
                                                <span style="color:#8892a4;font-size:0.8rem;">${contraparte}</span>
                                            </div>
                                        </td>
                                        <td style="padding:0.9rem 1rem;color:#8892a4;font-size:0.78rem;"><fmt:formatDate value="${h.fecha}" pattern="dd MMM, yyyy · hh:mm aa"/></td>
                                        <td style="padding:0.9rem 1rem;text-align:right;font-weight:600;font-size:0.85rem;">
                                            <c:choose>
                                                <c:when test="${esEnviada}"><span style="color:#ff5252;">-$<fmt:formatNumber value="${h.monto}" pattern="#,##0.00"/></span></c:when>
                                                <c:otherwise><span style="color:#00e676;">+$<fmt:formatNumber value="${h.monto}" pattern="#,##0.00"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

            <!-- Paginación -->
            <c:if test="${pageResult.totalCount > 0}">
            <div class="pg-bar-outer">
                <span class="pg-count">${pageResult.fromRecord}–${pageResult.toRecord} de ${pageResult.totalCount} transferencias</span>
                <div class="pg-bar">
                    <c:choose>
                        <c:when test="${!pageResult.first}">
                            <a href="?page=${pageResult.prevPage}&amp;tipo=${tipoFiltro}" class="pg-arrow">&#8592;</a>
                        </c:when>
                        <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8592;</span></c:otherwise>
                    </c:choose>
                    <span class="pg-info">Página ${pageResult.page} de ${pageResult.totalPages}</span>
                    <c:choose>
                        <c:when test="${!pageResult.last}">
                            <a href="?page=${pageResult.nextPage}&amp;tipo=${tipoFiltro}" class="pg-arrow">&#8594;</a>
                        </c:when>
                        <c:otherwise><span class="pg-arrow pg-arrow--dis">&#8594;</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
            </c:if>

        </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script></script>
</body>
</html>
