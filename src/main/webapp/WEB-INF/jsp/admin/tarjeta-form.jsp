<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Tarjeta - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "tarjetas"); %>
    <jsp:include page="../components/sidebar-admin.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <p style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;margin-bottom:0.5rem;">GESTIÓN DE TARJETAS</p>
            <h1 class="page-title" style="margin-bottom:0.25rem;">Configura la nueva credencial</h1>
            <p style="color:#8892a4;font-size:0.85rem;margin-bottom:2rem;">Define los parámetros de la nueva tarjeta corporativa.</p>

            <div class="two-col-equal" style="gap:2rem;">
                <!-- Left column -->
                <div>
                    <h3 style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;margin-bottom:1rem;">IDENTIFICACIÓN</h3>
                    <div class="input-group" style="margin-bottom:1.25rem;">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">ID del empleado</label>
                        <input type="text" placeholder="Ingrese el ID" style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                    </div>
                    <div class="input-group" style="margin-bottom:1.25rem;">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Tipo de Cuenta</label>
                        <select style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                            <option>Operativa Global</option>
                            <option>Viáticos</option>
                            <option>Gasolina</option>
                        </select>
                    </div>
                    <div class="input-group" style="margin-bottom:1.5rem;">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Moneda</label>
                        <select style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                            <option>USD - Dólares</option>
                            <option>EUR - Euros</option>
                            <option>MXN - Pesos</option>
                        </select>
                    </div>

                    <h3 style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;margin-bottom:1rem;">DEPÓSITO</h3>
                    <div class="input-group" style="margin-bottom:1.25rem;">
                        <label style="color:#8892a4;font-size:0.8rem;display:block;margin-bottom:0.5rem;">Monto a depositar</label>
                        <input type="text" value="5,000.00" style="width:100%;padding:0.75rem;background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:0.85rem;">
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:1rem;">
                        <div>
                            <p style="color:#fff;font-size:0.85rem;margin:0;">Aprobación instantánea</p>
                            <p style="color:#8892a4;font-size:0.75rem;margin:0.25rem 0 0;">Activar fondos inmediatos sin revisión</p>
                        </div>
                        <div style="width:44px;height:24px;background:#0ff;border-radius:12px;position:relative;cursor:pointer;">
                            <div style="width:20px;height:20px;background:#fff;border-radius:50%;position:absolute;top:2px;right:2px;"></div>
                        </div>
                    </div>
                </div>

                <!-- Right column -->
                <div>
                    <h3 style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;margin-bottom:1rem;">MODALIDAD DE TARJETA</h3>
                    <div class="two-col-equal" style="gap:1rem;margin-bottom:1.5rem;">
                        <div style="background:rgba(0,255,255,0.05);border:2px solid #0ff;border-radius:12px;padding:1rem;text-align:center;cursor:pointer;">
                            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="1.5" style="margin-bottom:0.5rem;"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                            <p style="color:#0ff;font-size:0.85rem;font-weight:600;margin:0;">Virtual</p>
                        </div>
                        <div style="background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:12px;padding:1rem;text-align:center;cursor:pointer;">
                            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#8892a4" stroke-width="1.5" style="margin-bottom:0.5rem;"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                            <p style="color:#8892a4;font-size:0.85rem;font-weight:600;margin:0;">Física</p>
                        </div>
                    </div>

                    <!-- Card preview -->
                    <div style="background:linear-gradient(135deg,#0a1628,#162a4a);border:1px solid rgba(0,255,255,0.2);border-radius:16px;padding:1.5rem;position:relative;overflow:hidden;">
                        <div style="position:absolute;top:0;right:0;width:150px;height:150px;background:radial-gradient(circle,rgba(0,255,255,0.08),transparent);"></div>
                        <p style="color:#8892a4;font-size:0.65rem;letter-spacing:2px;margin:0 0 1rem;">FINTECH CORP</p>
                        <div style="margin-bottom:1rem;">
                            <svg width="40" height="30" viewBox="0 0 40 30"><rect width="40" height="30" rx="4" fill="#c9a84c"/><rect x="4" y="8" width="12" height="14" rx="2" fill="#b8963e" stroke="#d4b85a"/></svg>
                        </div>
                        <p style="color:#fff;font-size:1.1rem;letter-spacing:4px;font-family:monospace;margin:0.75rem 0;">&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;</p>
                        <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-top:1rem;">
                            <p style="color:#8892a4;font-size:0.8rem;margin:0;">nombre del empleado</p>
                            <span style="background:rgba(0,255,255,0.15);color:#0ff;padding:0.2rem 0.5rem;border-radius:20px;font-size:0.65rem;">NUEVA</span>
                        </div>
                    </div>

                    <p style="color:#8892a4;font-size:0.75rem;line-height:1.6;margin-top:1rem;">Las tarjetas virtuales se generan instantáneamente y pueden usarse en compras en línea de forma inmediata.</p>
                </div>
            </div>

            <!-- Submit -->
            <button class="btn btn-primary btn-block" style="margin-top:2rem;padding:1rem;font-size:1rem;">
                EMITIR NUEVA TARJETA
            </button>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
