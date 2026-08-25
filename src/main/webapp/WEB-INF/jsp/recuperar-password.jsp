<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recuperar Contraseña - FinTech Corp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .step-bar { display:flex;align-items:center;gap:0.5rem;margin-bottom:2rem; }
        .step-dot { width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700;flex-shrink:0; }
        .step-dot.done  { background:rgba(0,255,209,0.15);color:var(--accent); }
        .step-dot.active{ background:var(--accent);color:#080A12; }
        .step-dot.todo  { background:var(--border);color:var(--text-muted); }
        .step-line { flex:1;height:2px; }
        .step-line.done   { background:var(--accent); }
        .step-line.pending{ background:var(--border); }
        .strength-bar { height:4px;border-radius:2px;background:var(--border);overflow:hidden;margin-top:0.5rem; }
        .strength-bar-fill { height:100%;border-radius:2px;width:0;transition:width .3s,background .3s; }
    </style>
</head>
<body>
<div class="login-page">

    <!-- Panel de marca (izquierdo) — igual que login.jsp -->
    <div class="login-brand">
        <div class="brand-icon">
            <svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect width="32" height="32" rx="8" fill="var(--accent)"/>
                <rect x="5" y="10" width="22" height="14" rx="2" stroke="#080A12" stroke-width="2.5"/>
                <line x1="5" y1="16" x2="27" y2="16" stroke="#080A12" stroke-width="2.5"/>
                <line x1="9" y1="20" x2="14" y2="20" stroke="#080A12" stroke-width="2" stroke-linecap="round"/>
            </svg>
        </div>
        <h1>FinTech Corp</h1>
        <p>Recupera el acceso a tu portal institucional de forma segura en tres pasos.</p>
        <div class="brand-features">
            <div class="brand-feature">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                <span>Código por correo</span>
            </div>
            <div class="brand-feature">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                <span>Verificado</span>
            </div>
            <div class="brand-feature">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span>Seguro</span>
            </div>
        </div>
    </div>

    <!-- Panel del formulario (derecho) -->
    <div class="login-form-section">

        <!-- ========== PASO 1 ========== -->
        <c:if test="${paso eq '1' or empty paso}">
            <div class="step-bar">
                <div class="step-dot active">1</div>
                <div class="step-line pending"></div>
                <div class="step-dot todo">2</div>
                <div class="step-line pending"></div>
                <div class="step-dot todo">3</div>
            </div>
            <h2>Recuperar contraseña</h2>
            <p class="subtitle">Ingresa tu correo institucional y te enviaremos un código de 6 dígitos.</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <div>${error}</div>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/recuperar-password">
                <input type="hidden" name="paso" value="1">
                <div class="form-group">
                    <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">Correo Electrónico</label>
                    <div class="input-wrapper">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
                        </span>
                        <input type="email" name="email" placeholder="nombre@fintechcorp.com" required autofocus>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block btn-lg">Enviar código &rarr;</button>
            </form>
            <p style="text-align:center;margin-top:1.5rem;color:var(--text-secondary);font-size:0.85rem;">
                <a href="${pageContext.request.contextPath}/login">← Volver al inicio de sesión</a>
            </p>
        </c:if>

        <!-- ========== PASO 2 ========== -->
        <c:if test="${paso eq '2'}">
            <div class="step-bar">
                <div class="step-dot done">✓</div>
                <div class="step-line done"></div>
                <div class="step-dot active">2</div>
                <div class="step-line pending"></div>
                <div class="step-dot todo">3</div>
            </div>
            <h2>Verifica tu código</h2>
            <p class="subtitle">Ingresa el código de 6 dígitos que enviamos a tu correo. Válido por 15 minutos.</p>

            <c:if test="${reenviadoOk}">
                <div class="alert" style="background:var(--success-bg);border:1px solid rgba(0,255,209,0.3);border-radius:8px;padding:1rem;display:flex;align-items:center;gap:0.75rem;margin-bottom:1.25rem;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                    <span style="color:var(--accent);font-size:0.85rem;">Código reenviado. Revisa tu correo.</span>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <div>${error}</div>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/recuperar-password">
                <input type="hidden" name="paso" value="2">
                <div class="form-group">
                    <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">Código de verificación</label>
                    <div class="input-wrapper">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input type="text" name="codigo" placeholder="123456" maxlength="6" pattern="[0-9]{6}"
                               inputmode="numeric" autocomplete="one-time-code" required autofocus
                               style="letter-spacing:6px;font-size:1.1rem;text-align:center;padding-left:16px;">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block btn-lg">Verificar código &rarr;</button>
            </form>

            <!-- Reenviar con countdown -->
            <p id="timerMsg" style="text-align:center;margin-top:1.25rem;color:var(--text-secondary);font-size:0.83rem;">
                ¿No recibiste el código? Reenviar en <span id="timerCount" style="color:var(--accent);font-weight:600;">60</span>s
            </p>
            <form id="formReenviar" method="post" action="${pageContext.request.contextPath}/recuperar-password" style="text-align:center;display:none;">
                <input type="hidden" name="paso" value="2">
                <input type="hidden" name="codigo" value="000000">
                <input type="hidden" name="accion" value="reenviar">
                <button type="submit" style="background:none;border:none;cursor:pointer;font-size:0.83rem;color:var(--accent);text-decoration:underline;">Reenviar código</button>
            </form>
            <p style="text-align:center;margin-top:0.75rem;color:var(--text-secondary);font-size:0.83rem;">
                <a href="${pageContext.request.contextPath}/recuperar-password">← Usar otro correo</a>
            </p>
        </c:if>

        <!-- ========== PASO 3 ========== -->
        <c:if test="${paso eq '3'}">
            <div class="step-bar">
                <div class="step-dot done">✓</div>
                <div class="step-line done"></div>
                <div class="step-dot done">✓</div>
                <div class="step-line done"></div>
                <div class="step-dot active">3</div>
            </div>
            <h2>Nueva contraseña</h2>
            <p class="subtitle">Elige una contraseña segura de al menos 8 caracteres.</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <div>${error}</div>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/recuperar-password" onsubmit="return validarReset()">
                <input type="hidden" name="paso" value="3">
                <div class="form-group">
                    <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">Nueva Contraseña</label>
                    <div class="input-wrapper">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input type="password" id="passwordNueva" name="passwordNueva" placeholder="Mínimo 8 caracteres con al menos un número" required minlength="8" autofocus oninput="actualizarFuerza()">
                        <button type="button" class="toggle-password">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="strength-bar"><div class="strength-bar-fill" id="strengthFill"></div></div>
                    <p id="strengthLabel" style="font-size:0.72rem;color:var(--text-muted);margin-top:0.3rem;min-height:1rem;"></p>
                </div>
                <div class="form-group">
                    <label class="form-label" style="text-transform:uppercase;letter-spacing:1px;font-size:0.72rem;">Confirmar Contraseña</label>
                    <div class="input-wrapper">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input type="password" id="passwordConfirma" name="passwordConfirma" placeholder="Repite la contraseña" required minlength="8">
                        <button type="button" class="toggle-password">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <p id="matchErr" style="color:var(--danger);font-size:0.75rem;margin-top:0.3rem;display:none;">Las contraseñas no coinciden.</p>
                </div>
                <button type="submit" class="btn btn-primary btn-block btn-lg">Establecer contraseña &rarr;</button>
            </form>
        </c:if>

    </div><!-- /login-form-section -->
</div>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
function validarReset() {
    var p1  = document.getElementById('passwordNueva').value;
    var p2  = document.getElementById('passwordConfirma').value;
    var err = document.getElementById('matchErr');
    if (p1.length < 8 || !/\d/.test(p1)) {
        err.textContent = 'La contraseña debe tener al menos 8 caracteres y contener al menos un número.';
        err.style.display = 'block'; return false;
    }
    if (p1 !== p2) {
        err.textContent = 'Las contraseñas no coinciden.';
        err.style.display = 'block'; return false;
    }
    err.style.display = 'none'; return true;
}
function actualizarFuerza() {
    var p = document.getElementById('passwordNueva').value;
    var fill = document.getElementById('strengthFill');
    var lbl  = document.getElementById('strengthLabel');
    if (!fill) return;
    var sc = 0;
    if (p.length >= 8)  sc++;
    if (p.length >= 12) sc++;
    if (/[A-Z]/.test(p)) sc++;
    if (/[0-9]/.test(p)) sc++;
    if (/[^A-Za-z0-9]/.test(p)) sc++;
    var lvls = [
        {w:'20%',c:'#FF4D6A',t:'Muy débil'},
        {w:'40%',c:'#FF8C00',t:'Débil'},
        {w:'60%',c:'#FFB800',t:'Regular'},
        {w:'80%',c:'#00b0ff',t:'Buena'},
        {w:'100%',c:'#00FFD1',t:'Muy fuerte'}
    ];
    var l = p.length === 0 ? null : lvls[Math.max(0, sc - 1)];
    fill.style.width      = l ? l.w : '0';
    fill.style.background = l ? l.c : '';
    lbl.textContent       = l ? l.t : '';
    lbl.style.color       = l ? l.c : '';
}
(function startTimer() {
    var cnt  = document.getElementById('timerCount');
    var msg  = document.getElementById('timerMsg');
    var form = document.getElementById('formReenviar');
    if (!cnt) return;
    var s = 60;
    var iv = setInterval(function() {
        s--;
        if (s <= 0) {
            clearInterval(iv);
            if (msg)  msg.style.display  = 'none';
            if (form) form.style.display = 'block';
        } else { cnt.textContent = s; }
    }, 1000);
})();
</script>
</body>
</html>
