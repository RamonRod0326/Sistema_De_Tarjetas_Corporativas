<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "dashboard"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title">Resumen General</h1>

            <div class="dashboard-grid" style="display:grid;grid-template-columns:2fr 1fr;gap:1.5rem;margin-top:1.5rem;">
                <!-- Left Column -->
                <div>
                    <div class="card balance-card" style="background:linear-gradient(135deg,#0a1628,#162a4a);padding:2rem;border-radius:12px;border:1px solid rgba(0,255,255,0.15);">
                        <p style="color:#8892a4;font-size:0.75rem;letter-spacing:2px;text-transform:uppercase;margin-bottom:0.5rem;">BALANCE TOTAL CORPORATIVO</p>
                        <h2 style="color:#fff;font-size:2.5rem;font-weight:700;margin:0;">$4,280,550.00 <span style="font-size:1rem;color:#8892a4;font-weight:400;">USD</span></h2>
                        <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-top:1.5rem;padding-top:1.5rem;border-top:1px solid rgba(255,255,255,0.1);">
                            <div>
                                <p style="color:#8892a4;font-size:0.75rem;">Cuentas Activas</p>
                                <p style="color:#0ff;font-size:1.25rem;font-weight:600;">12</p>
                            </div>
                            <div>
                                <p style="color:#8892a4;font-size:0.75rem;">Tarjetas Emitidas</p>
                                <p style="color:#0ff;font-size:1.25rem;font-weight:600;">48</p>
                            </div>
                            <div>
                                <p style="color:#8892a4;font-size:0.75rem;">Valor en Tránsito</p>
                                <p style="color:#0ff;font-size:1.25rem;font-weight:600;">$142,000</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div style="display:flex;flex-direction:column;gap:1.5rem;">
                    <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;">
                        <h3 style="color:#fff;font-size:0.9rem;margin-bottom:1rem;">Usuarios Activos</h3>
                        <div style="display:flex;flex-direction:column;gap:0.75rem;">
                            <div style="display:flex;align-items:center;gap:0.75rem;">
                                <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">JD</div>
                                <div style="flex:1;">
                                    <p style="color:#fff;font-size:0.85rem;margin:0;">Jane Doe</p>
                                    <p style="color:#8892a4;font-size:0.7rem;margin:0;">Finanzas Globales</p>
                                </div>
                                <span style="width:8px;height:8px;border-radius:50%;background:#00e676;"></span>
                            </div>
                            <div style="display:flex;align-items:center;gap:0.75rem;">
                                <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">MS</div>
                                <div style="flex:1;">
                                    <p style="color:#fff;font-size:0.85rem;margin:0;">Marco Solis</p>
                                    <p style="color:#8892a4;font-size:0.7rem;margin:0;">Operaciones</p>
                                </div>
                                <span style="width:8px;height:8px;border-radius:50%;background:#00e676;"></span>
                            </div>
                            <div style="display:flex;align-items:center;gap:0.75rem;">
                                <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">AL</div>
                                <div style="flex:1;">
                                    <p style="color:#fff;font-size:0.85rem;margin:0;">Ana Lopez</p>
                                    <p style="color:#8892a4;font-size:0.7rem;margin:0;">IT Security</p>
                                </div>
                                <span style="width:8px;height:8px;border-radius:50%;background:#ff5252;"></span>
                            </div>
                        </div>
                    </div>
                    <div class="card" style="background:linear-gradient(135deg,#0a2a2a,#0d3535);border:1px solid rgba(0,255,255,0.2);border-radius:12px;padding:1.25rem;">
                        <p style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;">LÍMITE DE CRÉDITO</p>
                        <p style="color:#fff;font-size:1.1rem;font-weight:600;margin:0.5rem 0;">95% Utilizado</p>
                        <div style="width:100%;height:6px;background:rgba(255,255,255,0.1);border-radius:3px;margin:0.75rem 0;">
                            <div style="width:95%;height:100%;background:linear-gradient(90deg,#0ff,#00e676);border-radius:3px;"></div>
                        </div>
                        <p style="color:#8892a4;font-size:0.75rem;">Próximo corte: 15 de Octubre</p>
                    </div>
                </div>
            </div>

            <!-- Transactions -->
            <div style="margin-top:2rem;">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                    <h2 style="color:#fff;font-size:1.1rem;">Últimas transacciones</h2>
                    <div class="filter-bar" style="display:flex;gap:0.5rem;">
                        <button class="btn btn-sm btn-outline" style="font-size:0.75rem;padding:0.4rem 0.8rem;">Todas</button>
                        <button class="btn btn-sm btn-outline" style="font-size:0.75rem;padding:0.4rem 0.8rem;">Ingresos</button>
                        <button class="btn btn-sm btn-outline" style="font-size:0.75rem;padding:0.4rem 0.8rem;">Gastos</button>
                    </div>
                </div>
                <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                    <table class="data-table" style="width:100%;border-collapse:collapse;">
                        <thead>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Descripción</th>
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Detalle</th>
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Fecha</th>
                                <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Estado</th>
                                <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Monto</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                <td style="padding:1rem;color:#fff;font-size:0.85rem;">Transferencia a AWS Global</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">Gasolina &bull; Tarjeta 4321</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">12 Oct, 2026</td>
                                <td style="padding:1rem;"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">Completado</span></td>
                                <td style="padding:1rem;text-align:right;color:#ff5252;font-weight:600;font-size:0.85rem;">-$12,450.00</td>
                            </tr>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                <td style="padding:1rem;color:#fff;font-size:0.85rem;">Transferencia a Operativa</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">Retorno de dividendos &bull; Tarjeta 3452</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">11 Oct, 2026</td>
                                <td style="padding:1rem;"><span style="background:rgba(255,193,7,0.15);color:#ffc107;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">Pendiente</span></td>
                                <td style="padding:1rem;text-align:right;color:#00e676;font-weight:600;font-size:0.85rem;">+$45,000.00</td>
                            </tr>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                <td style="padding:1rem;color:#fff;font-size:0.85rem;">Aeropuerto Internacional-Murcia</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">Viajes de negocios &bull; Tarjeta 4421</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">10 Oct, 2026</td>
                                <td style="padding:1rem;"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">Completado</span></td>
                                <td style="padding:1rem;text-align:right;color:#ff5252;font-weight:600;font-size:0.85rem;">-$2,120.45</td>
                            </tr>
                            <tr>
                                <td style="padding:1rem;color:#fff;font-size:0.85rem;">Cena Ejecutiva: The Grill</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">Representación &bull; Tarjeta 4421</td>
                                <td style="padding:1rem;color:#8892a4;font-size:0.8rem;">09 Oct, 2026</td>
                                <td style="padding:1rem;"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">Completado</span></td>
                                <td style="padding:1rem;text-align:right;color:#ff5252;font-weight:600;font-size:0.85rem;">-$850.00</td>
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
