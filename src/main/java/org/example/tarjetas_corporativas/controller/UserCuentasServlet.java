package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CuentaService;
import org.example.tarjetas_corporativas.service.TransferenciaService;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "userCuentasServlet", urlPatterns = {"/user/cuentas"})
public class UserCuentasServlet extends HttpServlet {

    private final CuentaService        cuentaService        = new CuentaService();
    private final TransferenciaService transferenciaService = new TransferenciaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            request.setAttribute("cuentas",     cuentaService.getCuentasUsuario(usuarioId));
            request.setAttribute("movimientos", transferenciaService.getMovimientosDetalle(usuarioId, 10));
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/user/cuentas.jsp").forward(request, response);
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
            response.sendRedirect(request.getContextPath() + "/user/cuentas?toast=transferencia_err"); return;
        }

        BigDecimal monto;
        try {
            monto = new BigDecimal(montoStr.trim().replace(",", ""));
            if (monto.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user/cuentas?toast=transferencia_err"); return;
        }

        long origenId  = Long.parseLong(origenStr.trim());
        long destinoId = Long.parseLong(destinoStr.trim());

        try {
            transferenciaService.transferir(usuarioId, origenId, destinoId, monto, concepto.trim());
            response.sendRedirect(request.getContextPath() + "/user/cuentas?toast=transferencia_ok");
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/user/cuentas?toast=" + e.getToastKey());
        }
    }
}
