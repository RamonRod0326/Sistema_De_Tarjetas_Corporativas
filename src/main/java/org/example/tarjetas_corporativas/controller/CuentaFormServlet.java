package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CuentaService;
import java.io.IOException;

@WebServlet(name = "cuentaFormServlet", urlPatterns = {"/admin/cuentas/form"})
public class CuentaFormServlet extends HttpServlet {

    private final CuentaService cuentaService = new CuentaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Object[] data = cuentaService.getFormData();
            request.setAttribute("empleados",  data[0]);
            request.setAttribute("categorias", data[1]);
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/cuenta-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String usuarioIdStr = request.getParameter("usuarioId");
        String categoriaStr = request.getParameter("categoria");

        if (usuarioIdStr == null || usuarioIdStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/cuentas?toast=cuenta_error"); return;
        }

        try {
            cuentaService.crear(Long.parseLong(usuarioIdStr.trim()), categoriaStr);
            response.sendRedirect(request.getContextPath() + "/admin/cuentas?toast=cuenta_creada");
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/admin/cuentas?toast=" + e.getToastKey());
        }
    }
}
