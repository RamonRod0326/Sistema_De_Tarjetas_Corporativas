package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CatalogoService;
import org.example.tarjetas_corporativas.util.JsonUtil;
import java.io.IOException;
import java.util.List;

/**
 * API REST JSON para CRUD de departamentos.
 * GET    /api/departamentos           → lista todos con conteo de empleados
 * GET    /api/departamentos?id=X      → empleados del departamento X
 * POST   /api/departamentos           → crea departamento
 * PUT    /api/departamentos           → actualiza nombre
 * DELETE /api/departamentos?id=X      → elimina departamento
 */
@WebServlet(name = "apiDepartamentosServlet", urlPatterns = {"/api/departamentos"})
public class ApiDepartamentosServlet extends HttpServlet {

    private final CatalogoService catalogoService = new CatalogoService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");
        try {
            if (idParam != null && !idParam.isBlank()) {
                long deptId = Long.parseLong(idParam.trim());
                List<Object[]> empleados = catalogoService.getEmpleadosByDepartamento(deptId);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < empleados.size(); i++) {
                    Object[] e = empleados.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(e[0]).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape(String.valueOf(e[1]))).append("\",")
                      .append("\"email\":\"").append(JsonUtil.escape(String.valueOf(e[2]))).append("\",")
                      .append("\"cargo\":\"").append(JsonUtil.escape(String.valueOf(e[3]))).append("\"")
                      .append("}");
                }
                JsonUtil.writeJson(res, sb.append("]").toString());
            } else {
                List<Object[]> deptos = catalogoService.getDepartamentosConCount();
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < deptos.size(); i++) {
                    Object[] d = deptos.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(d[0]).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape(String.valueOf(d[1]))).append("\",")
                      .append("\"totalEmpleados\":").append(d[2])
                      .append("}");
                }
                JsonUtil.writeJson(res, sb.append("]").toString());
            }
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }
        try {
            String body   = JsonUtil.readBody(req);
            String nombre = JsonUtil.getString(body, "nombre");
            if (nombre == null || nombre.isBlank()) {
                JsonUtil.writeError(res, 400, "Nombre requerido"); return;
            }
            catalogoService.insertarDepartamento(nombre.trim());
            JsonUtil.writeOk(res, "Departamento creado correctamente");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }
        try {
            String body   = JsonUtil.readBody(req);
            long   id     = JsonUtil.getLong(body, "id");
            String nombre = JsonUtil.getString(body, "nombre");
            if (id <= 0 || nombre == null || nombre.isBlank()) {
                JsonUtil.writeError(res, 400, "ID y nombre requeridos"); return;
            }
            catalogoService.actualizarDepartamento(id, nombre.trim());
            JsonUtil.writeOk(res, "Departamento actualizado correctamente");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            JsonUtil.writeError(res, 400, "ID requerido"); return;
        }
        try {
            catalogoService.eliminarDepartamento(Long.parseLong(idParam.trim()));
            JsonUtil.writeOk(res, "Departamento eliminado correctamente");
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            int status = "catalogo_en_uso".equals(e.getToastKey()) ? 409 : 500;
            JsonUtil.writeError(res, status, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        Object rol = req.getSession(false) != null ? req.getSession(false).getAttribute("rol") : null;
        return "admin".equals(rol);
    }
}
