// ===== CONFIRM DIALOG =====
function showConfirm(message, onConfirm, opts) {
    opts = opts || {};
    var title       = opts.title       || '¿Confirmar acción?';
    var confirmText = opts.confirmText || 'Confirmar';
    var danger      = opts.danger !== false; // default true

    var existing = document.getElementById('_confirmOverlay');
    if (existing) existing.remove();

    var overlay = document.createElement('div');
    overlay.id = '_confirmOverlay';
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:9999;display:flex;align-items:center;justify-content:center;backdrop-filter:blur(4px);';

    var iconColor = danger ? '#FF4D6A' : '#0ff';
    var btnBg     = danger ? 'background:#FF4D6A;color:#fff;' : 'background:#0ff;color:#080A12;';
    var iconSvg   = danger
        ? '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="'+iconColor+'" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>'
        : '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="'+iconColor+'" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>';

    overlay.innerHTML =
        '<div style="background:#0d1520;border:1px solid rgba(255,255,255,0.1);border-radius:16px;padding:2rem;width:90%;max-width:400px;box-shadow:0 24px 64px rgba(0,0,0,0.6);text-align:center;">' +
            '<div style="width:56px;height:56px;border-radius:50%;background:rgba('+( danger?'255,77,106':'0,255,255')+',0.1);display:flex;align-items:center;justify-content:center;margin:0 auto 1.25rem;">' + iconSvg + '</div>' +
            '<h3 style="color:#fff;font-size:1rem;font-weight:700;margin:0 0 0.6rem;">' + title + '</h3>' +
            '<p style="color:#8892a4;font-size:0.875rem;line-height:1.6;margin:0 0 1.75rem;">' + message + '</p>' +
            '<div style="display:flex;gap:0.75rem;justify-content:center;">' +
                '<button id="_confirmCancel" style="flex:1;padding:0.75rem;border-radius:8px;border:1px solid rgba(255,255,255,0.12);background:transparent;color:#8892a4;font-size:0.875rem;font-weight:600;cursor:pointer;">Cancelar</button>' +
                '<button id="_confirmOk"     style="flex:1;padding:0.75rem;border-radius:8px;border:none;'+btnBg+'font-size:0.875rem;font-weight:700;cursor:pointer;">' + confirmText + '</button>' +
            '</div>' +
        '</div>';

    document.body.appendChild(overlay);

    function close() { overlay.remove(); }
    document.getElementById('_confirmCancel').addEventListener('click', close);
    document.getElementById('_confirmOk').addEventListener('click', function() { close(); onConfirm(); });
    overlay.addEventListener('click', function(e) { if (e.target === overlay) close(); });
}

// ===== SIDEBAR MOBILE =====
function toggleSidebar() {
    var sidebar = document.querySelector('.sidebar');
    var overlay = document.querySelector('.sidebar-overlay');
    if (!sidebar) return;
    var isOpen = sidebar.classList.toggle('open');
    if (overlay) overlay.classList.toggle('visible', isOpen);
}
function closeSidebar() {
    var sidebar = document.querySelector('.sidebar');
    var overlay = document.querySelector('.sidebar-overlay');
    if (sidebar) sidebar.classList.remove('open');
    if (overlay) overlay.classList.remove('visible');
}
// Close sidebar with Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeSidebar(); }
});

// ===== TOAST SYSTEM =====
function showToast(type, title, msg, duration) {
    duration = duration || 4000;
    var container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
    var icons = {
        success: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#00FFD1" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="9 12 11 14 15 10"/></svg>',
        error:   '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FF4D6A" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
        info:    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6347FB" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>',
        warning: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFB800" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>'
    };
    var toast = document.createElement('div');
    toast.className = 'toast toast-' + type;
    toast.innerHTML =
        '<span class="toast-icon">' + (icons[type] || icons.info) + '</span>' +
        '<div class="toast-body"><p class="toast-title">' + title + '</p>' +
        (msg ? '<p class="toast-msg">' + msg + '</p>' : '') + '</div>' +
        '<button class="toast-close" onclick="this.parentNode.remove()">&#x2715;</button>';
    container.appendChild(toast);
    setTimeout(function() {
        if (toast.parentNode) {
            toast.style.animation = 'toast-out 0.3s ease forwards';
            setTimeout(function() { if (toast.parentNode) toast.remove(); }, 300);
        }
    }, duration);
}

var TOAST_MAP = {
    'login_ok':          ['success', '¡Bienvenido!',            'Sesión iniciada correctamente.'],
    'empleado_creado':   ['success', 'Empleado registrado',     'El empleado ha sido guardado correctamente.'],
    'empleado_editado':  ['success', 'Empleado actualizado',    'Los cambios han sido guardados.'],
    'empleado_error':    ['error',   'Error al guardar',        'No se pudo registrar el empleado.'],
    'tarjeta_creada':    ['success', 'Tarjeta emitida',         'La tarjeta ha sido creada exitosamente.'],
    'tarjeta_error':     ['error',   'Error al emitir',         'No se pudo emitir la tarjeta.'],
    'cuenta_creada':     ['success', 'Cuenta creada',           'La cuenta ha sido asignada correctamente.'],
    'cuenta_error':      ['error',   'Error al crear',          'No se pudo crear la cuenta.'],
    'config_ok':         ['success', 'Cambios guardados',       'Tu configuración ha sido actualizada.'],
    'transferencia_ok':     ['success', 'Transferencia ejecutada',  'Los fondos han sido enviados correctamente.'],
    'transferencia_err':    ['error',   'Error en transferencia',   'No se pudo completar la transferencia.'],
    'transferencia_saldo':  ['error',   'Saldo insuficiente',       'El monto solicitado supera el saldo disponible en la cuenta.'],
    'transferencia_frozen': ['error',   'Cuenta congelada',         'Una de las cuentas está suspendida y no permite operaciones.'],
    'transferencia_cat':    ['error',   'Categorías incompatibles', 'Solo puedes transferir entre cuentas del mismo tipo.'],
    'fondos_ok':           ['success', 'Fondos ingresados',        'El depósito a la cuenta corporativa fue exitoso.'],
    'fondos_err':          ['error',   'Error al ingresar fondos', 'Verifica el monto e intenta de nuevo.'],
    'fondos_empleado_ok':  ['success', 'Fondos agregados',         'Los fondos han sido asignados a la cuenta del empleado.'],
    'cuenta_editada':      ['success', 'Cuenta actualizada',       'Los cambios de la cuenta han sido guardados.'],
    'cuenta_eliminada':    ['success', 'Cuenta eliminada',         'La cuenta ha sido desactivada del sistema.'],
    'cuenta_error':        ['error',   'Error en cuenta',          'No se pudo completar la operación. Intenta de nuevo.'],
    'catalogo_creado':     ['success', 'Elemento agregado',        'El nuevo elemento ha sido añadido al catálogo.'],
    'catalogo_editado':    ['success', 'Elemento actualizado',     'Los cambios han sido guardados en el catálogo.'],
    'catalogo_eliminado':  ['success', 'Elemento eliminado',       'El elemento ha sido eliminado del catálogo.'],
    'catalogo_en_uso':     ['error',   'No se puede eliminar',      'Este elemento está asignado a registros activos y no puede eliminarse.'],
    'config_error':        ['error',   'Error de configuración',   'Verifica los datos e intenta de nuevo.'],
    'tarjeta_bloqueada':   ['success', 'Tarjeta bloqueada',        'La tarjeta ha sido bloqueada exitosamente.'],
    'tarjeta_desbloqueada':['success', 'Tarjeta desbloqueada',     'La tarjeta ha sido activada nuevamente.'],
    'tarjeta_cancelada':   ['success', 'Tarjeta cancelada',        'La tarjeta ha sido cancelada y dada de baja.'],
    'tarjeta_estado_error':['error',   'Error en tarjeta',         'No se pudo actualizar el estado de la tarjeta.'],
    'recuperar_ok':        ['success', 'Contraseña actualizada',   'Tu contraseña fue cambiada exitosamente. Inicia sesión con tus nuevas credenciales.'],
    'empleado_desactivado':['success', 'Empleado desactivado',     'El empleado y sus recursos han sido dados de baja.'],
    'empleado_dup':        ['error',   'Correo duplicado',         'Ya existe un empleado registrado con ese correo electrónico.'],
    'pass_policy':         ['error',   'Contraseña inválida',      'Debe tener al menos 8 caracteres y contener al menos un número.'],
    'pass_err':            ['error',   'Error al cambiar contraseña', 'Verifica que la contraseña actual sea correcta e intenta de nuevo.']
};

document.addEventListener('DOMContentLoaded', function() {

    // Toggle password visibility
    document.querySelectorAll('.toggle-password').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var input = this.parentElement.querySelector('input');
            if (input.type === 'password') {
                input.type = 'text';
                this.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>';
            } else {
                input.type = 'password';
                this.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
            }
        });
    });

    // Mobile sidebar overlay
    var overlay = document.createElement('div');
    overlay.className = 'sidebar-overlay';
    overlay.addEventListener('click', function() { closeSidebar(); });
    document.body.appendChild(overlay);

    // Modal show/hide
    document.querySelectorAll('[data-modal]').forEach(function(trigger) {
        trigger.addEventListener('click', function() {
            var modalId = this.getAttribute('data-modal');
            var modal = document.getElementById(modalId);
            if (modal) {
                modal.classList.remove('hidden');
            }
        });
    });

    document.querySelectorAll('.modal-close').forEach(function(btn) {
        btn.addEventListener('click', function() {
            this.closest('.modal-overlay').classList.add('hidden');
        });
    });

    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                this.classList.add('hidden');
            }
        });
    });

    // Chart tabs
    document.querySelectorAll('.chart-tab').forEach(function(tab) {
        tab.addEventListener('click', function() {
            this.parentElement.querySelectorAll('.chart-tab').forEach(function(t) {
                t.classList.remove('active');
            });
            this.classList.add('active');
        });
    });

    // Modality selector (tarjeta virtual/fisica)
    document.querySelectorAll('.modality-option').forEach(function(option) {
        option.addEventListener('click', function() {
            this.parentElement.querySelectorAll('.modality-option').forEach(function(o) {
                o.classList.remove('active');
            });
            this.classList.add('active');
        });
    });

    // Toggle switches
    document.querySelectorAll('.toggle').forEach(function(toggle) {
        toggle.addEventListener('click', function() {
            this.classList.toggle('active');
        });
    });

    // Auto-show toast from ?toast= URL param
    var params = new URLSearchParams(window.location.search);
    var toastKey = params.get('toast');
    if (toastKey && TOAST_MAP[toastKey]) {
        var t = TOAST_MAP[toastKey];
        setTimeout(function() { showToast(t[0], t[1], t[2]); }, 300);
        var url = new URL(window.location.href);
        url.searchParams.delete('toast');
        window.history.replaceState({}, '', url.toString());
    }
});
