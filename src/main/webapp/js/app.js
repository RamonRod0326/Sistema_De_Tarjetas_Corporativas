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

    // Mobile sidebar toggle
    var menuToggle = document.getElementById('menuToggle');
    var sidebar = document.querySelector('.sidebar');
    if (menuToggle && sidebar) {
        menuToggle.addEventListener('click', function() {
            sidebar.classList.toggle('open');
        });
    }

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
});
