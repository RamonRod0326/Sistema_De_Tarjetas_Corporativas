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

@WebServlet(name = "loginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            String rol = (String) session.getAttribute("rol");
            response.sendRedirect(request.getContextPath() +
                    ("admin".equals(rol) ? "/admin/dashboard" : "/user/dashboard"));
            return;
        }
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Ingresa tu correo y contraseña.");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
            return;
        }

        try {
            Object[] row = authService.login(email, password);
            if (row != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("usuarioId",    row[0]);
                session.setAttribute("usuario",      row[1]);
                session.setAttribute("email",        email.trim().toLowerCase());
                session.setAttribute("rol",          row[3]);
                session.setAttribute("cargo",        nvl((String) row[4]));
                session.setAttribute("departamento", nvl((String) row[5]));
                String destino = "admin".equals(row[3]) ? "/admin/dashboard" : "/user/dashboard";
                response.sendRedirect(request.getContextPath() + destino + "?toast=login_ok");
                return;
            }
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }

        request.setAttribute("error", "Correo o contraseña incorrectos.");
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }

    private String nvl(String s) { return s != null ? s : ""; }
}
