<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Tarjetas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "tarjetas"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title">Mis Tarjetas</h1>
            <p class="page-subtitle">Consulta y gestiona tus tarjetas corporativas asignadas.</p>

            <div class="cards-carousel">
                <div class="credit-card-ui">
                    <div class="card-status"><span class="badge badge-success">Activa</span></div>
                    <div class="card-type">PLATINUM CORPORATE</div>
                    <div class="card-chip"></div>
                    <div class="card-number">&bull;&bull;&bull;&bull; &nbsp; &bull;&bull;&bull;&bull; &nbsp; &bull;&bull;&bull;&bull; &nbsp; 8 8 2 4</div>
                    <div style="color: var(--accent); font-size: 12px; font-weight: 600;">Viáticos</div>
                    <div class="card-bottom">
                        <div>
                            <div class="card-label">TITULAR</div>
                            <div class="card-value">${sessionScope.usuario != null ? sessionScope.usuario : 'ELENA RODRIGUEZ'}</div>
                        </div>
                        <div>
                            <div class="card-label">VENCE</div>
                            <div class="card-value">12/28</div>
                        </div>
                    </div>
                </div>
                <div class="credit-card-ui">
                    <div class="card-status"><span class="badge badge-success">Activa</span></div>
                    <div class="card-type">PLATINUM CORPORATE</div>
                    <div class="card-chip"></div>
                    <div class="card-number">&bull;&bull;&bull;&bull; &nbsp; &bull;&bull;&bull;&bull; &nbsp; &bull;&bull;&bull;&bull; &nbsp; 6 2 7 1</div>
                    <div style="color: var(--text-secondary); font-size: 12px; font-weight: 600;">Gasolina</div>
                    <div class="card-bottom">
                        <div>
                            <div class="card-label">TITULAR</div>
                            <div class="card-value">${sessionScope.usuario != null ? sessionScope.usuario : 'ELENA RODRIGUEZ'}</div>
                        </div>
                        <div>
                            <div class="card-label">VENCE</div>
                            <div class="card-value">06/27</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Actividad Reciente</h3>
                    <select class="filter-select">
                        <option>Todas las tarjetas</option>
                        <option>Tarjeta 8824</option>
                        <option>Tarjeta 6271</option>
                    </select>
                </div>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Descripción</th>
                                <th>Detalle</th>
                                <th>Fecha</th>
                                <th style="text-align:right">Monto</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="table-cell-main">GM Oil</td>
                                <td class="table-cell-sub">Gasolina • Tarjeta 6271</td>
                                <td>24 Oct, 2026</td>
                                <td class="amount-negative text-right">-$85.00</td>
                            </tr>
                            <tr>
                                <td class="table-cell-main">Urban Bistro</td>
                                <td class="table-cell-sub">Viáticos • Tarjeta 8824</td>
                                <td>23 Oct, 2026</td>
                                <td class="amount-negative text-right">-$124.50</td>
                            </tr>
                            <tr>
                                <td class="table-cell-main">Air Europa Perks</td>
                                <td class="table-cell-sub">Viáticos • Tarjeta 8824</td>
                                <td>20 Oct, 2026</td>
                                <td class="amount-negative text-right">-$450.20</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
