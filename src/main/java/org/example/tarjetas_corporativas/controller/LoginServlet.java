package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "loginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            String rol = (String) session.getAttribute("rol");
            if ("admin".equals(rol)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/user/dashboard");
            }
            return;
        }
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null && password != null && !password.isEmpty()) {
            HttpSession session = request.getSession();

            if (email.contains("admin")) {
                session.setAttribute("usuario", "Alejandro Vance");
                session.setAttribute("email", email);
                session.setAttribute("rol", "admin");
                session.setAttribute("cargo", "Director de Operaciones Globales");
                session.setAttribute("departamento", "Operaciones");
                response.sendRedirect(request.getContextPath() + "/inicio-exitoso?rol=admin");
            } else {
                session.setAttribute("usuario", "Elena Rodriguez");
                session.setAttribute("email", email);
                session.setAttribute("rol", "empleado");
                session.setAttribute("cargo", "Analista Senior de Finanzas");
                session.setAttribute("departamento", "Finanzas");
                response.sendRedirect(request.getContextPath() + "/inicio-exitoso?rol=empleado");
            }
        } else {
            request.setAttribute("error", "Credenciales incorrectas. Por favor, inténtalo de nuevo.");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
        }
    }
}
