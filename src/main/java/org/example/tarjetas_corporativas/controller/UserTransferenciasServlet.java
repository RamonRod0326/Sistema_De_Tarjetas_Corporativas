package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.TransferenciaHistorialDTO;
import org.example.tarjetas_corporativas.dto.TransferenciaStatsDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.TransferenciaService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "userTransferenciasServlet", urlPatterns = {"/user/transferencias"})
public class UserTransferenciasServlet extends HttpServlet {

    private final TransferenciaService transferenciaService = new TransferenciaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String tipo = PageUtil.blankToNull(request.getParameter("tipo"));
        int    page = PageUtil.parsePage(request);

        try {
            TransferenciaStatsDTO stats = transferenciaService.getStats(usuarioId);
            PageResult<TransferenciaHistorialDTO> pageResult =
                transferenciaService.getHistorialPaged(usuarioId, tipo, page, PageUtil.PAGE_SIZE);

            request.setAttribute("totalMes",   stats.getTotalMes());
            request.setAttribute("enviado",    stats.getEnviado());
            request.setAttribute("recibido",   stats.getRecibido());
            request.setAttribute("neto",       stats.getNeto());
            request.setAttribute("pageResult", pageResult);
            request.setAttribute("tipoFiltro", tipo != null ? tipo : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/user/transferencias.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String origenStr  = request.getParameter("cuentaOrigenId");
        String destinoStr = request.getParameter("cuentaDestinoId");
        String montoStr   = request.getParameter("monto");
        String concepto   = request.getParameter("concepto");

        if (origenStr == null || destinoStr == null || montoStr == null || montoStr.isBlank()
                || concepto == null || concepto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/user/transferencias?toast=transferencia_err"); return;
        }

        BigDecimal monto;
        try {
            monto = new BigDecimal(montoStr.trim().replace(",", ""));
            if (monto.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user/transferencias?toast=transferencia_err"); return;
        }

        long origenId  = Long.parseLong(origenStr.trim());
        long destinoId = Long.parseLong(destinoStr.trim());

        try {
            transferenciaService.transferirLigero(usuarioId, origenId, destinoId, monto, concepto.trim());
            response.sendRedirect(request.getContextPath() + "/user/transferencias?toast=transferencia_ok");
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/user/transferencias?toast=" + e.getToastKey());
        }
    }
}
