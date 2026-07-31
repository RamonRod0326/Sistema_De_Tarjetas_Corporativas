package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.TarjetaUserDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.TarjetaService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;

@WebServlet(name = "userTarjetasServlet", urlPatterns = {"/user/tarjetas"})
public class UserTarjetasServlet extends HttpServlet {

    private static final int PAGE_SIZE = PageUtil.PAGE_SIZE;

    private final TarjetaService tarjetaService = new TarjetaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String estado = PageUtil.blankToNull(request.getParameter("estado"));
        int    page   = PageUtil.parsePage(request);

        try {
            PageResult<TarjetaUserDTO> pageResult =
                tarjetaService.getTarjetasUsuarioPaged(usuarioId, estado, page, PAGE_SIZE);

            request.setAttribute("pageResult",   pageResult);
            request.setAttribute("estadoFiltro", estado != null ? estado : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/user/tarjetas.jsp").forward(request, response);
    }
}
