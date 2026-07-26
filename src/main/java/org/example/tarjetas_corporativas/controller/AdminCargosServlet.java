package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet de página para /admin/cargos.
 * Solo sirve la vista JSP; el CRUD real lo hace ApiCargosServlet via AJAX.
 */
@WebServlet(name = "adminCargosServlet", urlPatterns = {"/admin/cargos"})
public class AdminCargosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Object rol = req.getSession(false) != null ? req.getSession(false).getAttribute("rol") : null;
        if (!"admin".equals(rol)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/jsp/admin/cargos.jsp").forward(req, res);
    }
}
