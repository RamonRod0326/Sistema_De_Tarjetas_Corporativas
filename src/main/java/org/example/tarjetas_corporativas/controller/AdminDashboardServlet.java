package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.DashboardAdminService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;

@WebServlet(name = "adminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final DashboardAdminService dashboardService = new DashboardAdminService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String tipo = PageUtil.blankToNull(request.getParameter("tipo"));
        int    page = PageUtil.parsePage(request);
        try {
            request.setAttribute("stats",          dashboardService.getStats());
            request.setAttribute("txPage",         dashboardService.getMovimientosPaged(tipo, page, PageUtil.PAGE_SIZE));
            request.setAttribute("empleadosPanel", dashboardService.getEmpleadosRecientes(30));
            request.setAttribute("tipoFiltro",     tipo != null ? tipo : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(request, response);
    }
}
