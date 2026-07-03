<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="modal-exito" class="modal-overlay" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:1000;align-items:center;justify-content:center;">
    <div class="modal-card" style="background:#0d1520;border:1px solid rgba(0,255,255,0.2);border-radius:16px;padding:2.5rem;text-align:center;max-width:420px;width:90%;">
        <div style="margin-bottom:1.5rem;">
            <svg width="56" height="56" viewBox="0 0 56 56" fill="none">
                <circle cx="28" cy="28" r="26" stroke="#00e676" stroke-width="2.5" fill="rgba(0,230,118,0.1)"/>
                <polyline points="18,30 24,36 38,22" fill="none" stroke="#00e676" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
        </div>
        <h3 id="modal-exito-titulo" style="color:#fff;font-size:1.2rem;margin:0 0 0.5rem;">Operación exitosa</h3>
        <p id="modal-exito-mensaje" style="color:#8892a4;font-size:0.85rem;line-height:1.6;margin:0 0 1.5rem;">La operación se ha completado correctamente.</p>
        <button onclick="document.getElementById('modal-exito').style.display='none'" class="btn btn-primary" style="min-width:160px;">Aceptar</button>
    </div>
</div>
