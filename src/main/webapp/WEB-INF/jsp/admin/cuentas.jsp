<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cuentas - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "cuentas"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title" style="margin-bottom:0.25rem;">Gestión de Cuentas</h1>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:1.5rem;">Resumen de fondos operativos y beneficios institucionales.</p>

            <!-- Top cards -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-bottom:2rem;">
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <h3 style="color:#fff;font-size:1rem;margin:0 0 0.5rem;">Añadir Nuevo Talento</h3>
                    <p style="color:#8892a4;font-size:0.8rem;line-height:1.6;margin-bottom:1rem;">Crea cuentas corporativas para nuevos empleados y asigna fondos operativos iniciales.</p>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="color:#8892a4;font-size:0.8rem;">Cuentas Activas: <strong style="color:#0ff;">142</strong></span>
                        <a href="${pageContext.request.contextPath}/admin/cuentas/form" class="btn btn-primary" style="font-size:0.8rem;padding:0.5rem 1rem;">Crear Cuenta</a>
                    </div>
                </div>
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <h3 style="color:#fff;font-size:1rem;margin:0 0 0.75rem;">Solicitudes de Fondos</h3>
                    <div style="display:flex;flex-direction:column;gap:0.5rem;margin-bottom:1rem;">
                        <div style="display:flex;justify-content:space-between;color:#8892a4;font-size:0.8rem;">
                            <span>Elena Rodriguez - Viáticos</span><span style="color:#0ff;">$2,500.00</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;color:#8892a4;font-size:0.8rem;">
                            <span>Marc Vidal - Gasolina</span><span style="color:#0ff;">$1,200.00</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;color:#8892a4;font-size:0.8rem;">
                            <span>Sonia Blanco - Operaciones</span><span style="color:#0ff;">$5,000.00</span>
                        </div>
                    </div>
                    <button class="btn btn-outline" style="font-size:0.8rem;padding:0.5rem 1rem;width:100%;">Visualizar Solicitudes</button>
                </div>
            </div>

            <!-- Filter bar -->
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                <a href="#" style="color:#0ff;font-size:0.8rem;text-decoration:none;">MÁS FILTROS</a>
                <div style="display:flex;gap:0.5rem;">
                    <button class="btn btn-sm" style="background:#0ff;color:#0a0e17;font-size:0.75rem;padding:0.4rem 0.8rem;border-radius:20px;border:none;">Todas</button>
                    <button class="btn btn-sm btn-outline" style="font-size:0.75rem;padding:0.4rem 0.8rem;border-radius:20px;">Activas</button>
                    <button class="btn btn-sm btn-outline" style="font-size:0.75rem;padding:0.4rem 0.8rem;border-radius:20px;">Inactivas</button>
                </div>
            </div>

            <h2 style="color:#fff;font-size:1rem;margin-bottom:1rem;">Directorio de Cuentas</h2>

            <!-- Table -->
            <div class="table-container" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;overflow:hidden;">
                <table class="data-table" style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.08);">
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Empleado</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Cta #</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Saldo Actual</th>
                            <th style="text-align:left;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Estado</th>
                            <th style="text-align:right;padding:1rem;color:#8892a4;font-size:0.75rem;font-weight:500;">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                            <td style="padding:1rem;">
                                <div style="display:flex;align-items:center;gap:0.75rem;">
                                    <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">ER</div>
                                    <div>
                                        <p style="color:#fff;font-size:0.85rem;margin:0;">Elena Rodriguez</p>
                                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Ingeniera de Software</p>
                                    </div>
                                </div>
                            </td>
                            <td style="padding:1rem;color:#8892a4;font-size:0.85rem;font-family:monospace;">1263 1234 9926 12</td>
                            <td style="padding:1rem;color:#fff;font-size:0.85rem;font-weight:600;">&euro;4,250.00</td>
                            <td style="padding:1rem;"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">ACTIVE</span></td>
                            <td style="padding:1rem;text-align:right;">
                                <a href="#" style="color:#8892a4;margin-right:0.5rem;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></a>
                                <a href="#" style="color:#8892a4;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></a>
                            </td>
                        </tr>
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                            <td style="padding:1rem;">
                                <div style="display:flex;align-items:center;gap:0.75rem;">
                                    <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">MV</div>
                                    <div>
                                        <p style="color:#fff;font-size:0.85rem;margin:0;">Marc Vidal</p>
                                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Director de Proyecto</p>
                                    </div>
                                </div>
                            </td>
                            <td style="padding:1rem;color:#8892a4;font-size:0.85rem;font-family:monospace;">1362 1256 9926 34</td>
                            <td style="padding:1rem;color:#fff;font-size:0.85rem;font-weight:600;">&euro;2,890.15</td>
                            <td style="padding:1rem;"><span style="background:rgba(0,230,118,0.15);color:#00e676;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">ACTIVE</span></td>
                            <td style="padding:1rem;text-align:right;">
                                <a href="#" style="color:#8892a4;margin-right:0.5rem;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></a>
                                <a href="#" style="color:#8892a4;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></a>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding:1rem;">
                                <div style="display:flex;align-items:center;gap:0.75rem;">
                                    <div style="width:36px;height:36px;border-radius:50%;background:#1a2a3a;display:flex;align-items:center;justify-content:center;color:#0ff;font-size:0.8rem;font-weight:600;">SB</div>
                                    <div>
                                        <p style="color:#fff;font-size:0.85rem;margin:0;">Sonia Blanco</p>
                                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Operaciones</p>
                                    </div>
                                </div>
                            </td>
                            <td style="padding:1rem;color:#8892a4;font-size:0.85rem;font-family:monospace;">1583 1336 9926 11</td>
                            <td style="padding:1rem;color:#fff;font-size:0.85rem;font-weight:600;">&euro;12,400.00</td>
                            <td style="padding:1rem;"><span style="background:rgba(255,193,7,0.15);color:#ffc107;padding:0.25rem 0.6rem;border-radius:20px;font-size:0.7rem;">CONGELADO</span></td>
                            <td style="padding:1rem;text-align:right;">
                                <a href="#" style="color:#8892a4;margin-right:0.5rem;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></a>
                                <a href="#" style="color:#8892a4;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div style="text-align:center;margin-top:1rem;">
                <a href="#" style="color:#0ff;font-size:0.85rem;text-decoration:none;">Ver más</a>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
