package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.FondosService;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "adminFondosServlet", urlPatterns = {"/admin/fondos"})
public class AdminFondosServlet extends HttpServlet {

    private final FondosService fondosService = new FondosService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String montoStr = request.getParameter("monto");
        String concepto = request.getParameter("concepto");
        Long adminId = (Long) request.getSession().getAttribute("usuarioId");

        if (adminId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        if (montoStr == null || montoStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?toast=fondos_err"); return;
        }

        BigDecimal monto;
        try {
            monto = new BigDecimal(montoStr.trim().replace(",", ""));
            if (monto.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?toast=fondos_err"); return;
        }

        String conceptoFinal = (concepto != null && !concepto.isBlank()) ? concepto.trim() : "Depósito corporativo";

        try {
            fondosService.depositarGlobal(monto, conceptoFinal, adminId);
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?toast=fondos_ok");
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?toast=fondos_err");
        }
    }
}
