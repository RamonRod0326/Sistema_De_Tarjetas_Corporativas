package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.EmpleadoService;
import java.io.IOException;

@WebServlet(name = "empleadoFormServlet", urlPatterns = {"/admin/empleados/form"})
public class EmpleadoFormServlet extends HttpServlet {

    private final EmpleadoService empleadoService = new EmpleadoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        Long id = (idStr != null && !idStr.isBlank()) ? Long.parseLong(idStr.trim()) : null;
        try {
            Object[] data = empleadoService.getFormData(id);
            request.setAttribute("departamentos", data[0]);
            request.setAttribute("cargos",        data[1]);
            if (data[2] != null) request.setAttribute("empForm", data[2]);
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/empleado-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr          = request.getParameter("id");
        String nombre         = request.getParameter("nombre");
        String apellidoPat    = request.getParameter("apellidoPaterno");
        String apellidoMat    = request.getParameter("apellidoMaterno");
        String email          = request.getParameter("email");
        String password       = request.getParameter("password");
        String rol            = request.getParameter("rol");
        String depIdStr       = request.getParameter("departamentoId");
        String cargoIdStr     = request.getParameter("cargoId");

        if (nombre == null || nombre.isBlank() || email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=empleado_error"); return;
        }

        Long depId   = parseLong(depIdStr);
        Long cargoId = parseLong(cargoIdStr);
        String rolFinal = (rol != null && !rol.isBlank()) ? rol.trim() : "empleado";

        try {
            if (idStr != null && !idStr.isBlank()) {
                empleadoService.actualizar(Long.parseLong(idStr.trim()),
                        nombre.trim(), apellidoPat, apellidoMat,
                        email.trim().toLowerCase(), password, rolFinal, depId, cargoId);
                response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=empleado_editado");
            } else {
                if (password == null || password.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=empleado_error"); return;
                }
                empleadoService.crear(nombre.trim(), apellidoPat, apellidoMat,
                        email.trim().toLowerCase(), password, rolFinal, depId, cargoId);
                response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=empleado_creado");
            }
        } catch (ServiceException e) {
            response.sendRedirect(request.getContextPath() + "/admin/empleados?toast=" + e.getToastKey());
        }
    }

    private Long parseLong(String s) {
        return (s != null && !s.isBlank()) ? Long.parseLong(s.trim()) : null;
    }
}
