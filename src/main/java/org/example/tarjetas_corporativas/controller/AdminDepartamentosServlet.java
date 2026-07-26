package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "adminDepartamentosServlet", urlPatterns = {"/admin/departamentos"})
public class AdminDepartamentosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession(false) == null || !"admin".equals(request.getSession(false).getAttribute("rol"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/departamentos.jsp").forward(request, response);
    }
}
