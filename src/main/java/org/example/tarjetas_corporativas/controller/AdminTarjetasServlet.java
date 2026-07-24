package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.TarjetaAdminDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.TarjetaService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;

@WebServlet(name = "adminTarjetasServlet",
            urlPatterns = {"/admin/tarjetas", "/admin/tarjetas/estado", "/admin/tarjetas/cancelar"})
public class AdminTarjetasServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;

    private final TarjetaService tarjetaService = new TarjetaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String estado    = PageUtil.blankToNull(request.getParameter("estado"));
        String modalidad = PageUtil.blankToNull(request.getParameter("modalidad"));
        int    page      = PageUtil.parsePage(request);

        try {
            PageResult<TarjetaAdminDTO> pageResult =
                tarjetaService.getTarjetasAdminPaged(estado, modalidad, page, PAGE_SIZE);

            request.setAttribute("pageResult", pageResult);
            request.setAttribute("estadoFiltro",    estado    != null ? estado    : "");
            request.setAttribute("modalidadFiltro", modalidad != null ? modalidad : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/tarjetas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        try {
            if ("/admin/tarjetas/estado".equals(path)) {
                String id     = request.getParameter("id");
                String estado = request.getParameter("estado");
                tarjetaService.actualizarEstado(id, estado);
                String toast = "BLOQUEADA".equals(estado) ? "tarjeta_bloqueada" : "tarjeta_desbloqueada";
                response.sendRedirect(request.getContextPath() + "/admin/tarjetas?toast=" + toast);

            } else if ("/admin/tarjetas/cancelar".equals(path)) {
                String id = request.getParameter("id");
                tarjetaService.cancelar(id);
                response.sendRedirect(request.getContextPath() + "/admin/tarjetas?toast=tarjeta_cancelada");
            }
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/admin/tarjetas?toast=" + e.getToastKey());
        }
    }
}
