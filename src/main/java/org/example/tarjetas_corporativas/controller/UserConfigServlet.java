package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.tarjetas_corporativas.dto.PerfilDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.ConfigService;
import java.io.IOException;

@WebServlet(name = "userConfigServlet", urlPatterns = {
    "/user/configuracion",
    "/user/configuracion/perfil",
    "/user/configuracion/password"
})
public class UserConfigServlet extends HttpServlet {

    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            PerfilDTO perfil = configService.getPerfil(usuarioId);
            request.setAttribute("confNombre",       perfil.getNombre());
            request.setAttribute("confEmail",        perfil.getEmail());
            request.setAttribute("confEmpleadoId",   perfil.getEmpleadoId());
            request.setAttribute("confCargo",        perfil.getCargo());
            request.setAttribute("confDepartamento", perfil.getDepartamento());
            request.setAttribute("confIniciales",    perfil.getIniciales());
        } catch (ServiceException e) {
            throw new ServletException(e.getMessage(), e);
        }
        request.getRequestDispatcher("/WEB-INF/jsp/user/configuracion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        Long usuarioId = (Long) request.getSession().getAttribute("usuarioId");
        if (usuarioId == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        switch (path) {
            case "/user/configuracion/perfil"   -> handlePerfil(request, response, usuarioId);
            case "/user/configuracion/password" -> handlePassword(request, response, usuarioId);
            default -> response.sendRedirect(request.getContextPath() + "/user/configuracion");
        }
    }

    private void handlePerfil(HttpServletRequest req, HttpServletResponse res, Long userId)
            throws IOException {
        String nombre = req.getParameter("nombre");
        if (nombre == null || nombre.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=error"); return;
        }
        try {
            configService.actualizarNombre(userId, nombre);
            HttpSession session = req.getSession(false);
            if (session != null) session.setAttribute("usuario", nombre.trim());
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=perfil_ok");
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=error");
        }
    }

    private void handlePassword(HttpServletRequest req, HttpServletResponse res, Long userId)
            throws IOException {
        String actual   = req.getParameter("passwordActual");
        String nueva    = req.getParameter("passwordNueva");
        String confirma = req.getParameter("passwordConfirma");

        if (actual == null || nueva == null || confirma == null
                || nueva.isBlank() || !nueva.equals(confirma) || nueva.length() < 8) {
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=pass_err"); return;
        }

        try {
            boolean ok = configService.cambiarPassword(userId, actual, nueva);
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=" + (ok ? "pass_ok" : "pass_err"));
        } catch (ServiceException e) {
            res.sendRedirect(req.getContextPath() + "/user/configuracion?toast=pass_err");
        }
    }
}
