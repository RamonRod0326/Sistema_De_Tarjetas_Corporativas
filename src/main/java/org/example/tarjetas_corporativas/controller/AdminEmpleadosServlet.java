package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.EmpleadoRowDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.EmpleadoService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;

@WebServlet(name = "adminEmpleadosServlet", urlPatterns = {"/admin/empleados", "/admin/empleados/eliminar"})
public class AdminEmpleadosServlet extends HttpServlet {

    private static final int PAGE_SIZE = PageUtil.PAGE_SIZE;

    private final EmpleadoService empleadoService = new EmpleadoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search   = PageUtil.blankToNull(request.getParameter("q"));
        String activoP  = request.getParameter("activo");
        Boolean activo  = "1".equals(activoP) ? Boolean.TRUE : "0".equals(activoP) ? Boolean.FALSE : null;
        int page        = PageUtil.parsePage(request);

        try {
            PageResult<EmpleadoRowDTO> pageResult =
                empleadoService.getEmpleadosPaged(search, activo, page, PAGE_SIZE);

            request.setAttribute("stats",      empleadoService.getStats());
            request.setAttribute("pageResult", pageResult);
            request.setAttribute("q",          search != null ? search : "");
            request.setAttribute("activoFiltro", activoP != null ? activoP : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/empleados.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            try {
                empleadoService.eliminar(Long.parseLong(idStr.trim()));
            } catch (ServiceException e) {
                response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=error");
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=empleado_eliminado");
    }
}
