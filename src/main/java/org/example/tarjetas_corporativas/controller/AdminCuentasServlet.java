package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.EmpleadoCuentaRowDTO;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CuentaService;
import org.example.tarjetas_corporativas.service.FondosService;
import org.example.tarjetas_corporativas.service.TarjetaService;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "adminCuentasServlet", urlPatterns = {
    "/admin/cuentas",
    "/admin/cuentas/fondos",
    "/admin/cuentas/tarjeta",
    "/admin/cuentas/editar",
    "/admin/cuentas/eliminar"
})
public class AdminCuentasServlet extends HttpServlet {

    private final CuentaService   cuentaService   = new CuentaService();
    private final FondosService   fondosService   = new FondosService();
    private final TarjetaService  tarjetaService  = new TarjetaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long adminId = (Long) request.getSession().getAttribute("usuarioId");
        if (adminId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String search = PageUtil.blankToNull(request.getParameter("q"));
        int    page   = PageUtil.parsePage(request);

        try {
            PageResult<EmpleadoCuentaRowDTO> pageResult =
                cuentaService.getEmpleadosConCuentasPaged(search, page, PageUtil.PAGE_SIZE);
            List<Long> ids = pageResult.getItems().stream()
                .map(EmpleadoCuentaRowDTO::getId).collect(Collectors.toList());

            request.setAttribute("stats",              cuentaService.getAdminStats());
            request.setAttribute("pageResult",         pageResult);
            request.setAttribute("cuentasPorEmpleado", cuentaService.getCuentasPorEmpleados(ids));
            request.setAttribute("q",                  search != null ? search : "");
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/cuentas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long adminId = (Long) request.getSession().getAttribute("usuarioId");
        if (adminId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String path = request.getServletPath();
        switch (path) {
            case "/admin/cuentas/fondos"   -> handleFondos(request, response, adminId);
            case "/admin/cuentas/tarjeta"  -> handleTarjeta(request, response);
            case "/admin/cuentas/editar"   -> handleEditar(request, response);
            case "/admin/cuentas/eliminar" -> handleEliminar(request, response);
            default -> response.sendRedirect(request.getContextPath() + "/admin/cuentas");
        }
    }

    private void handleFondos(HttpServletRequest req, HttpServletResponse res, Long adminId)
            throws IOException {
        String cuentaIdStr = req.getParameter("cuentaId");
        String montoStr    = req.getParameter("monto");

        if (cuentaIdStr == null || montoStr == null || montoStr.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=fondos_err"); return;
        }

        BigDecimal monto;
        try {
            monto = new BigDecimal(montoStr.trim().replace(",", ""));
            if (monto.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=fondos_err"); return;
        }

        try {
            fondosService.asignarFondos(cuentaIdStr, monto, adminId);
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=fondos_empleado_ok");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=" + e.getToastKey());
        }
    }

    private void handleTarjeta(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String cuentaIdStr = req.getParameter("cuentaId");
        String modalidad   = req.getParameter("modalidad");

        if (cuentaIdStr == null) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=tarjeta_error"); return;
        }

        try {
            tarjetaService.emitir(cuentaIdStr, modalidad);
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=tarjeta_creada");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=" + e.getToastKey());
        }
    }

    private void handleEditar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String cuentaIdStr = req.getParameter("cuentaId");
        String estado      = req.getParameter("estado");

        if (cuentaIdStr == null || estado == null) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=cuenta_error"); return;
        }

        try {
            cuentaService.actualizarEstado(cuentaIdStr, estado);
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=cuenta_editada");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=" + e.getToastKey());
        }
    }

    private void handleEliminar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String cuentaIdStr = req.getParameter("cuentaId");
        if (cuentaIdStr == null) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=cuenta_error"); return;
        }

        try {
            cuentaService.eliminar(cuentaIdStr);
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=cuenta_eliminada");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/cuentas?toast=" + e.getToastKey());
        }
    }
}
