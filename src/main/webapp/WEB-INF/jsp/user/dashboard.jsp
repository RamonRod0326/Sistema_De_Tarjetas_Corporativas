<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="app-layout">
    <% request.setAttribute("activePage", "dashboard"); %>
    <jsp:include page="../components/sidebar-user.jsp"/>
    <div class="main-content">
        <jsp:include page="../components/header.jsp"/>
        <div class="content-area">
            <h1 class="page-title">Panel Principal</h1>

            <!-- Balance -->
            <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:1rem;margin-top:1.5rem;">
                <div class="card" style="background:linear-gradient(135deg,#0a1628,#162a4a);border:1px solid rgba(0,255,255,0.15);border-radius:12px;padding:1.5rem;grid-column:span 1;">
                    <p style="color:#8892a4;font-size:0.7rem;letter-spacing:2px;text-transform:uppercase;margin:0;">SALDO TOTAL</p>
                    <h2 style="color:#fff;font-size:2rem;font-weight:700;margin:0.5rem 0 0;">$42,500.80</h2>
                </div>
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;display:flex;align-items:center;gap:1rem;">
                    <div style="width:40px;height:40px;border-radius:10px;background:rgba(0,255,255,0.1);display:flex;align-items:center;justify-content:center;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 0 0 0 4h4v-4h-4z"/></svg>
                    </div>
                    <div style="flex:1;">
                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Viáticos</p>
                        <p style="color:#fff;font-size:1.1rem;font-weight:600;margin:0;">$12,400.00</p>
                        <p style="color:#8892a4;font-size:0.65rem;margin:0;">Crédito Institucional</p>
                    </div>
                </div>
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;display:flex;align-items:center;gap:1rem;">
                    <div style="width:40px;height:40px;border-radius:10px;background:rgba(255,193,7,0.1);display:flex;align-items:center;justify-content:center;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ffc107" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    </div>
                    <div style="flex:1;">
                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Gasolina</p>
                        <p style="color:#fff;font-size:1.1rem;font-weight:600;margin:0;">$4,250.00</p>
                        <p style="color:#8892a4;font-size:0.65rem;margin:0;">Asignación mensual</p>
                    </div>
                </div>
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.25rem;display:flex;align-items:center;gap:1rem;">
                    <div style="width:40px;height:40px;border-radius:10px;background:rgba(0,230,118,0.1);display:flex;align-items:center;justify-content:center;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#00e676" stroke-width="2"><polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/><line x1="12" y1="22" x2="12" y2="7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/></svg>
                    </div>
                    <div style="flex:1;">
                        <p style="color:#8892a4;font-size:0.7rem;margin:0;">Bonos</p>
                        <p style="color:#fff;font-size:1.1rem;font-weight:600;margin:0;">$25,850.80</p>
                        <p style="color:#8892a4;font-size:0.65rem;margin:0;">Premios por desempeño</p>
                    </div>
                    <a href="#" style="color:#0ff;text-decoration:none;font-size:1.2rem;">&rarr;</a>
                </div>
            </div>

            <!-- Two column grid -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-top:1.5rem;">
                <!-- Weekly chart -->
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
                        <h3 style="color:#fff;font-size:0.95rem;margin:0;">Gasto semanal</h3>
                        <div style="display:flex;gap:0.5rem;">
                            <button style="background:transparent;border:1px solid rgba(255,255,255,0.1);color:#8892a4;padding:0.3rem 0.6rem;border-radius:6px;font-size:0.7rem;cursor:pointer;">Diario</button>
                            <button style="background:#0ff;border:none;color:#0a0e17;padding:0.3rem 0.6rem;border-radius:6px;font-size:0.7rem;cursor:pointer;font-weight:600;">Semanal</button>
                        </div>
                    </div>
                    <div style="display:flex;align-items:flex-end;justify-content:space-between;height:160px;gap:0.75rem;padding:0 0.5rem;">
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:40%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">LUN</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:50%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">MAR</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:60%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">MIÉ</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:85%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">JUE</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:55%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">VIE</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:45%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">SÁB</span>
                        </div>
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:0.5rem;">
                            <div style="width:100%;height:35%;background:linear-gradient(180deg,#0ff,rgba(0,255,255,0.3));border-radius:4px 4px 0 0;"></div>
                            <span style="color:#8892a4;font-size:0.65rem;">DOM</span>
                        </div>
                    </div>
                </div>

                <!-- Recent transactions -->
                <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                        <h3 style="color:#fff;font-size:0.95rem;margin:0;">Transacciones recientes</h3>
                        <a href="#" style="color:#0ff;font-size:0.8rem;text-decoration:none;">Ver todo</a>
                    </div>
                    <div style="display:flex;flex-direction:column;gap:1rem;">
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(255,193,7,0.1);display:flex;align-items:center;justify-content:center;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ffc107" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                            </div>
                            <div style="flex:1;">
                                <p style="color:#fff;font-size:0.85rem;margin:0;">GM Oil</p>
                                <p style="color:#8892a4;font-size:0.7rem;margin:0;">Gasolina &bull; 24 Oct, 2026</p>
                            </div>
                            <span style="color:#ff5252;font-weight:600;font-size:0.85rem;">-$85.00</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(0,255,255,0.1);display:flex;align-items:center;justify-content:center;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/></svg>
                            </div>
                            <div style="flex:1;">
                                <p style="color:#fff;font-size:0.85rem;margin:0;">Urban Bistro</p>
                                <p style="color:#8892a4;font-size:0.7rem;margin:0;">Viáticos &bull; 23 Oct, 2026</p>
                            </div>
                            <span style="color:#ff5252;font-weight:600;font-size:0.85rem;">-$124.50</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(0,230,118,0.1);display:flex;align-items:center;justify-content:center;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00e676" stroke-width="2"><polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/></svg>
                            </div>
                            <div style="flex:1;">
                                <p style="color:#fff;font-size:0.85rem;margin:0;">Bono de desempeño</p>
                                <p style="color:#8892a4;font-size:0.7rem;margin:0;">Bonos &bull; 21 Oct, 2026</p>
                            </div>
                            <span style="color:#00e676;font-weight:600;font-size:0.85rem;">+$2,500.00</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(0,255,255,0.1);display:flex;align-items:center;justify-content:center;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/></svg>
                            </div>
                            <div style="flex:1;">
                                <p style="color:#fff;font-size:0.85rem;margin:0;">Air Europa Perks</p>
                                <p style="color:#8892a4;font-size:0.7rem;margin:0;">Viáticos &bull; 20 Oct, 2026</p>
                            </div>
                            <span style="color:#ff5252;font-weight:600;font-size:0.85rem;">-$450.20</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Account history -->
            <div class="card" style="background:#0d1520;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:1.5rem;margin-top:1.5rem;display:flex;align-items:center;gap:1rem;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0ff" stroke-width="2"><path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"/></svg>
                <div style="flex:1;">
                    <h3 style="color:#fff;font-size:0.95rem;margin:0;">Historial de cuenta</h3>
                    <p style="color:#8892a4;font-size:0.8rem;margin:0.25rem 0 0;">Descargar estados mensuales</p>
                </div>
                <a href="#" class="btn btn-outline" style="font-size:0.8rem;">Descargar</a>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
