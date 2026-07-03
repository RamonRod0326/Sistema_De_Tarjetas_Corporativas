<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="modal-error" class="modal-overlay" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;">
    <div class="modal-card" style="background:#0d1520;border:1px solid rgba(255,82,82,0.3);border-radius:16px;padding:2.5rem;text-align:center;max-width:420px;width:90%;">
        <div style="margin-bottom:1.5rem;">
            <svg width="56" height="56" viewBox="0 0 56 56" fill="none">
                <circle cx="28" cy="28" r="26" stroke="#ff5252" stroke-width="2.5" fill="rgba(255,82,82,0.1)"/>
                <line x1="20" y1="20" x2="36" y2="36" stroke="#ff5252" stroke-width="2.5" stroke-linecap="round"/>
                <line x1="36" y1="20" x2="20" y2="36" stroke="#ff5252" stroke-width="2.5" stroke-linecap="round"/>
            </svg>
        </div>
        <h3 id="modal-error-titulo" style="color:#fff;font-size:1.2rem;margin:0 0 0.5rem;">Error en la operación</h3>
        <p id="modal-error-mensaje" style="color:#8892a4;font-size:0.85rem;line-height:1.6;margin:0 0 1.5rem;">Ha ocurrido un error. Por favor, inténtalo de nuevo.</p>
        <button onclick="document.getElementById('modal-error').style.display='none'" class="btn btn-outline" style="min-width:160px;border-color:rgba(255,82,82,0.5);color:#ff5252;">Cerrar</button>
    </div>
</div>
