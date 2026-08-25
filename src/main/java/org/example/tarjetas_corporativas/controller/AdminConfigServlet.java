package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.tarjetas_corporativas.dto.PerfilDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CatalogoService;
import org.example.tarjetas_corporativas.service.ConfigService;
import org.example.tarjetas_corporativas.util.PasswordUtil;
import java.io.IOException;

@WebServlet(name = "adminConfigServlet", urlPatterns = {
    "/admin/configuracion",
    "/admin/configuracion/catalogo",
    "/admin/configuracion/perfil",
    "/admin/configuracion/password",
    "/admin/config/catalogo",
    "/admin/config/catalogo/editar",
    "/admin/config/catalogo/eliminar"
})
public class AdminConfigServlet extends HttpServlet {

    private final ConfigService   configService   = new ConfigService();
    private final CatalogoService catalogoService = new CatalogoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long adminId = (Long) request.getSession().getAttribute("usuarioId");
        if (adminId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            PerfilDTO perfil = configService.getPerfil(adminId);
            request.setAttribute("confNombre",       perfil.getNombre());
            request.setAttribute("confEmail",        perfil.getEmail());
            request.setAttribute("confEmpleadoId",   perfil.getEmpleadoId());
            request.setAttribute("confCargo",        perfil.getCargo());
            request.setAttribute("confDepartamento", perfil.getDepartamento());
            request.setAttribute("confIniciales",    perfil.getIniciales());

        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/configuracion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        Long adminId = (Long) request.getSession().getAttribute("usuarioId");
        if (adminId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        switch (path) {
            case "/admin/configuracion/catalogo",
                 "/admin/config/catalogo"          -> handleCatalogoCrear(request, response);
            case "/admin/config/catalogo/editar"   -> handleCatalogoEditar(request, response);
            case "/admin/config/catalogo/eliminar" -> handleCatalogoEliminar(request, response);
            case "/admin/configuracion/perfil"     -> handlePerfil(request, response, adminId);
            case "/admin/configuracion/password"   -> handlePassword(request, response, adminId);
            default -> response.sendRedirect(request.getContextPath() + "/admin/configuracion");
        }
    }

    private void handleCatalogoCrear(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String tipo   = req.getParameter("tipo");
        String nombre = req.getParameter("nombre");
        if (nombre == null || nombre.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return;
        }
        try {
            switch (tipo != null ? tipo : "") {
                case "categoria"    -> catalogoService.insertarCategoria(nombre);
                case "departamento" -> catalogoService.insertarDepartamento(nombre);
                case "cargo"        -> catalogoService.insertarCargo(nombre);
                default -> { res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return; }
            }
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=catalogo_creado");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error");
        }
    }

    private void handleCatalogoEditar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String tipo   = req.getParameter("tipo");
        String idStr  = req.getParameter("id");
        String nombre = req.getParameter("nombre");
        if (idStr == null || nombre == null || nombre.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return;
        }
        long id = Long.parseLong(idStr.trim());
        try {
            switch (tipo != null ? tipo : "") {
                case "categoria"    -> catalogoService.actualizarCategoria(id, nombre);
                case "departamento" -> catalogoService.actualizarDepartamento(id, nombre);
                case "cargo"        -> catalogoService.actualizarCargo(id, nombre);
                default -> { res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return; }
            }
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=catalogo_editado");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error");
        }
    }

    private void handleCatalogoEliminar(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String tipo  = req.getParameter("tipo");
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return;
        }
        long id;
        try { id = Long.parseLong(idStr.trim()); }
        catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return;
        }
        try {
            switch (tipo != null ? tipo : "") {
                case "categoria"    -> catalogoService.eliminarCategoria(id);
                case "departamento" -> catalogoService.eliminarDepartamento(id);
                case "cargo"        -> catalogoService.eliminarCargo(id);
                default -> { res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return; }
            }
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=catalogo_eliminado");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=" + e.getToastKey());
        }
    }

    private void handlePerfil(HttpServletRequest req, HttpServletResponse res, Long adminId)
            throws IOException {
        String nombre = req.getParameter("nombre");
        if (nombre == null || nombre.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error"); return;
        }
        try {
            configService.actualizarNombre(adminId, nombre);
            HttpSession session = req.getSession(false);
            if (session != null) session.setAttribute("usuario", nombre.trim());
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=perfil_ok");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=error");
        }
    }

    private void handlePassword(HttpServletRequest req, HttpServletResponse res, Long adminId)
            throws IOException {
        String actual   = req.getParameter("passwordActual");
        String nueva    = req.getParameter("passwordNueva");
        String confirma = req.getParameter("passwordConfirma");

        if (actual == null || nueva == null || confirma == null
                || !nueva.equals(confirma) || !PasswordUtil.isValid(nueva)) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=pass_policy"); return;
        }

        try {
            boolean ok = configService.cambiarPassword(adminId, actual, nueva);
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=" + (ok ? "pass_ok" : "pass_err"));
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/admin/configuracion?toast=pass_err");
        }
    }

}
