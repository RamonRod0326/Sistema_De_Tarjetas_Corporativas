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
 * API REST JSON para CRUD de cargos con entidades enlazadas (empleados).
 * GET    /api/cargos              → lista cargos con conteo de empleados
 * GET    /api/cargos?id=X        → empleados vinculados al cargo X
 * POST   /api/cargos             → crea un cargo
 * PUT    /api/cargos             → actualiza nombre de un cargo
 * DELETE /api/cargos?id=X        → elimina (baja) el cargo X
 */
@WebServlet(name = "apiCargosServlet", urlPatterns = {"/api/cargos"})
public class ApiCargosServlet extends HttpServlet {

    private final CatalogoService catalogoService = new CatalogoService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");

        try {
            if (idParam != null && !idParam.isBlank()) {
                // Empleados vinculados al cargo (entidad enlazada)
                long cargoId = Long.parseLong(idParam.trim());
                List<Object[]> empleados = catalogoService.getEmpleadosByCargo(cargoId);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < empleados.size(); i++) {
                    Object[] row = empleados.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(row[0]).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape((String) row[1])).append("\",")
                      .append("\"email\":\"").append(JsonUtil.escape((String) row[2])).append("\",")
                      .append("\"departamento\":\"").append(JsonUtil.escape((String) row[3])).append("\"")
                      .append("}");
                }
                sb.append("]");
                JsonUtil.writeJson(res, sb.toString());

            } else {
                // Lista de cargos con conteo de empleados enlazados
                List<Object[]> cargos = catalogoService.getCargosConCount();
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < cargos.size(); i++) {
                    Object[] row = cargos.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(row[0]).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape((String) row[1])).append("\",")
                      .append("\"totalEmpleados\":").append(row[2])
                      .append("}");
                }
                sb.append("]");
                JsonUtil.writeJson(res, sb.toString());
            }
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    // ── POST (crear) ──────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        try {
            String body   = JsonUtil.readBody(req);
            String nombre = JsonUtil.getString(body, "nombre");

            if (nombre == null || nombre.isBlank()) {
                JsonUtil.writeError(res, 400, "El nombre del cargo es requerido"); return;
            }
            catalogoService.insertarCargo(nombre.trim());
            JsonUtil.writeOk(res, "Cargo creado correctamente");

        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    // ── PUT (actualizar) ──────────────────────────────────────────────────────
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        try {
            String body   = JsonUtil.readBody(req);
            long   id     = JsonUtil.getLong(body, "id");
            String nombre = JsonUtil.getString(body, "nombre");

            if (id <= 0 || nombre == null || nombre.isBlank()) {
                JsonUtil.writeError(res, 400, "ID y nombre son requeridos"); return;
            }
            catalogoService.actualizarCargo(id, nombre.trim());
            JsonUtil.writeOk(res, "Cargo actualizado correctamente");

        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    // ── DELETE ────────────────────────────────────────────────────────────────
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            JsonUtil.writeError(res, 400, "ID requerido"); return;
        }

        try {
            long id = Long.parseLong(idParam.trim());
            catalogoService.eliminarCargo(id);
            JsonUtil.writeOk(res, "Cargo eliminado correctamente");
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            String msg = e.getMessage();
            int status = msg != null && msg.contains("asignado") ? 409 : 500;
            JsonUtil.writeError(res, status, msg);
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        Object rol = req.getSession(false) != null ? req.getSession(false).getAttribute("rol") : null;
        return "admin".equals(rol);
    }
}
