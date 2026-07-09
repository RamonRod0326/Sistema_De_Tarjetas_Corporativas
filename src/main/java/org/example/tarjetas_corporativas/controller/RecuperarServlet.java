package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.AuthService;
import java.io.IOException;

/**
 * Servlet que gestiona el flujo de recuperación de contraseña en tres pasos:
 * <ol>
 *   <li>Ingreso del correo electrónico → envío de código de 6 dígitos por email.</li>
 *   <li>Verificación del código (máx. 3 intentos, expiración de 15 min).</li>
 *   <li>Ingreso y confirmación de la nueva contraseña.</li>
 * </ol>
 */
@WebServlet(name = "recuperarServlet", urlPatterns = {"/recuperar-password"})
public class RecuperarServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String paso = req.getParameter("paso");
        HttpSession session = req.getSession(false);

        if ("3".equals(paso)) {
            if (session == null || session.getAttribute("_resetVerificado") == null) {
                res.sendRedirect(req.getContextPath() + "/recuperar-password");
                return;
            }
            req.setAttribute("paso", "3");
        } else if ("2".equals(paso)) {
            if (session == null || session.getAttribute("_resetEmail") == null) {
                res.sendRedirect(req.getContextPath() + "/recuperar-password");
                return;
            }
            req.setAttribute("paso", "2");
        } else {
            req.setAttribute("paso", "1");
        }
        req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String paso = req.getParameter("paso");
        switch (paso != null ? paso : "1") {
            case "2" -> handleVerificarCodigo(req, res);
            case "3" -> handleNuevaPassword(req, res);
            default  -> handleEnviarCodigo(req, res);
        }
    }

    /** Paso 1: valida correo y envía código por email. */
    private void handleEnviarCodigo(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "El correo electrónico es requerido.");
            req.setAttribute("paso", "1");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }
        try {
            authService.generarCodigoReset(email.trim().toLowerCase());
        } catch (ServiceException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("paso", "1");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("_resetEmail", email.trim().toLowerCase());
        session.removeAttribute("_resetVerificado");
        res.sendRedirect(req.getContextPath() + "/recuperar-password?paso=2");
    }

    /** Paso 2: valida el código de 6 dígitos. */
    private void handleVerificarCodigo(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("_resetEmail") == null) {
            res.sendRedirect(req.getContextPath() + "/recuperar-password");
            return;
        }
        String email  = (String) session.getAttribute("_resetEmail");
        String codigo = req.getParameter("codigo");

        if (codigo == null || codigo.trim().length() != 6) {
            req.setAttribute("error", "Ingresa el código de 6 dígitos.");
            req.setAttribute("paso", "2");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        // Acción reenviar
        if ("reenviar".equals(req.getParameter("accion"))) {
            try {
                authService.generarCodigoReset(email);
            } catch (ServiceException e) {
                req.setAttribute("error", e.getMessage());
            }
            req.setAttribute("paso", "2");
            req.setAttribute("reenviadoOk", true);
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        boolean valido;
        try {
            valido = authService.verificarCodigo(email, codigo.trim());
        } catch (ServiceException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("paso", "2");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        if (!valido) {
            req.setAttribute("error", "Código incorrecto. Verifica e intenta de nuevo.");
            req.setAttribute("paso", "2");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        session.setAttribute("_resetVerificado", true);
        res.sendRedirect(req.getContextPath() + "/recuperar-password?paso=3");
    }

    /** Paso 3: valida y aplica la nueva contraseña. */
    private void handleNuevaPassword(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("_resetVerificado") == null) {
            res.sendRedirect(req.getContextPath() + "/recuperar-password");
            return;
        }
        String email    = (String) session.getAttribute("_resetEmail");
        String nueva    = req.getParameter("passwordNueva");
        String confirma = req.getParameter("passwordConfirma");

        if (nueva == null || nueva.length() < 8) {
            req.setAttribute("error", "La contraseña debe tener al menos 8 caracteres.");
            req.setAttribute("paso", "3");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }
        if (!nueva.equals(confirma)) {
            req.setAttribute("error", "Las contraseñas no coinciden.");
            req.setAttribute("paso", "3");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        try {
            authService.resetPassword(email, nueva);
        } catch (ServiceException e) {
            req.setAttribute("error", "No se pudo actualizar la contraseña. Inténtalo de nuevo.");
            req.setAttribute("paso", "3");
            req.getRequestDispatcher("/WEB-INF/jsp/recuperar-password.jsp").forward(req, res);
            return;
        }

        session.removeAttribute("_resetEmail");
        session.removeAttribute("_resetVerificado");
        res.sendRedirect(req.getContextPath() + "/login?toast=recuperar_ok");
    }
}
