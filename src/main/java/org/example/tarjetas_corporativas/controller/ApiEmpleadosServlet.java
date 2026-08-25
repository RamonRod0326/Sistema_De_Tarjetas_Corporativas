package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.CatalogoItemDTO;
import org.example.tarjetas_corporativas.dto.EmpleadoFormDTO;
import org.example.tarjetas_corporativas.dto.EmpleadoRowDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.EmpleadoService;
import org.example.tarjetas_corporativas.util.JsonUtil;
import org.example.tarjetas_corporativas.util.PasswordUtil;
import java.io.IOException;
import java.util.List;

/**
 * API REST JSON para CRUD simple de empleados.
 * GET    /api/empleados           → lista todos los empleados activos
 * GET    /api/empleados?id=X      → datos del empleado + catálogos para el modal de edición
 * POST   /api/empleados           → crea un empleado
 * PUT    /api/empleados           → actualiza un empleado
 * DELETE /api/empleados?id=X      → baja lógica del empleado
 */
@WebServlet(name = "apiEmpleadosServlet", urlPatterns = {"/api/empleados"})
public class ApiEmpleadosServlet extends HttpServlet {

    private final EmpleadoService empleadoService = new EmpleadoService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");

        try {
            if ("catalogos".equals(idParam)) {
                // Solo catálogos (departamentos y cargos) para el modal de nuevo empleado
                Object[] formData = empleadoService.getFormData(null);
                @SuppressWarnings("unchecked")
                List<CatalogoItemDTO> deps   = (List<CatalogoItemDTO>) formData[0];
                @SuppressWarnings("unchecked")
                List<CatalogoItemDTO> cargos = (List<CatalogoItemDTO>) formData[1];
                JsonUtil.writeJson(res, "{\"departamentos\":" + listToJson(deps) + ",\"cargos\":" + listToJson(cargos) + "}");
                return;
            }
            if (idParam != null && !idParam.isBlank()) {
                // Datos de un empleado + listas de catálogos para el modal de edición
                long id = Long.parseLong(idParam.trim());
                Object[] formData = empleadoService.getFormData(id);
                @SuppressWarnings("unchecked")
                List<CatalogoItemDTO> deps   = (List<CatalogoItemDTO>) formData[0];
                @SuppressWarnings("unchecked")
                List<CatalogoItemDTO> cargos = (List<CatalogoItemDTO>) formData[1];
                EmpleadoFormDTO emp          = (EmpleadoFormDTO) formData[2];

                if (emp == null) { JsonUtil.writeError(res, 404, "Empleado no encontrado"); return; }

                StringBuilder sb = new StringBuilder("{");
                sb.append("\"id\":").append(emp.getId()).append(",");
                sb.append("\"nombre\":\"").append(JsonUtil.escape(emp.getNombre())).append("\",");
                sb.append("\"apellidoPaterno\":\"").append(JsonUtil.escape(emp.getApellidoPaterno())).append("\",");
                sb.append("\"apellidoMaterno\":\"").append(JsonUtil.escape(emp.getApellidoMaterno())).append("\",");
                sb.append("\"email\":\"").append(JsonUtil.escape(emp.getEmail())).append("\",");
                sb.append("\"rol\":\"").append(JsonUtil.escape(emp.getRol())).append("\",");
                sb.append("\"departamentoId\":").append(emp.getDepartamentoId()).append(",");
                sb.append("\"cargoId\":").append(emp.getCargoId()).append(",");
                sb.append("\"departamentos\":").append(listToJson(deps)).append(",");
                sb.append("\"cargos\":").append(listToJson(cargos));
                sb.append("}");
                JsonUtil.writeJson(res, sb.toString());

            } else {
                // Lista completa de empleados
                List<EmpleadoRowDTO> empleados = empleadoService.getEmpleados();
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < empleados.size(); i++) {
                    EmpleadoRowDTO e = empleados.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(e.getId()).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape(e.getNombre())).append("\",")
                      .append("\"email\":\"").append(JsonUtil.escape(e.getEmail())).append("\",")
                      .append("\"cargo\":\"").append(JsonUtil.escape(e.getCargo())).append("\",")
                      .append("\"departamento\":\"").append(JsonUtil.escape(e.getDepartamento())).append("\",")
                      .append("\"activo\":").append(e.getActivo())
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
            String body          = JsonUtil.readBody(req);
            String nombre        = JsonUtil.getString(body, "nombre");
            String apellidoPat   = JsonUtil.getString(body, "apellidoPaterno");
            String apellidoMat   = JsonUtil.getString(body, "apellidoMaterno");
            String email         = JsonUtil.getString(body, "email");
            String password      = JsonUtil.getString(body, "password");
            String rol           = JsonUtil.getString(body, "rol");
            long   depId         = JsonUtil.getLong(body, "departamentoId");
            long   cargoId       = JsonUtil.getLong(body, "cargoId");

            if (nombre == null || nombre.isBlank() || email == null || email.isBlank()
                    || password == null || password.isBlank()) {
                JsonUtil.writeError(res, 400, "Nombre, email y contraseña son requeridos");
                return;
            }
            if (!nombre.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El nombre solo puede contener letras");
                return;
            }
            if (apellidoPat != null && !apellidoPat.isBlank()
                    && !apellidoPat.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El apellido paterno solo puede contener letras");
                return;
            }
            if (apellidoMat != null && !apellidoMat.isBlank()
                    && !apellidoMat.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El apellido materno solo puede contener letras");
                return;
            }
            if (!email.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                JsonUtil.writeError(res, 400, "El correo electrónico no tiene un formato válido");
                return;
            }
            if (!PasswordUtil.isValid(password)) {
                JsonUtil.writeError(res, 400, PasswordUtil.POLICY_MSG);
                return;
            }

            empleadoService.crear(nombre.trim(), apellidoPat, apellidoMat, email.trim(),
                                  password, rol != null ? rol : "empleado",
                                  depId > 0 ? depId : null, cargoId > 0 ? cargoId : null);
            JsonUtil.writeOk(res, "Empleado registrado correctamente");

        } catch (ServiceException e) {
            int status = "empleado_dup".equals(e.getToastKey()) ? 409 : 500;
            JsonUtil.writeError(res, status, e.getMessage());
        }
    }

    // ── PUT (actualizar) ──────────────────────────────────────────────────────
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        try {
            String body        = JsonUtil.readBody(req);
            long   id          = JsonUtil.getLong(body, "id");
            String nombre      = JsonUtil.getString(body, "nombre");
            String apellidoPat = JsonUtil.getString(body, "apellidoPaterno");
            String apellidoMat = JsonUtil.getString(body, "apellidoMaterno");
            String email       = JsonUtil.getString(body, "email");
            String password    = JsonUtil.getString(body, "password");
            String rol         = JsonUtil.getString(body, "rol");
            long   depId       = JsonUtil.getLong(body, "departamentoId");
            long   cargoId     = JsonUtil.getLong(body, "cargoId");

            if (id <= 0 || nombre == null || nombre.isBlank() || email == null || email.isBlank()) {
                JsonUtil.writeError(res, 400, "ID, nombre y email son requeridos");
                return;
            }
            if (!nombre.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El nombre solo puede contener letras");
                return;
            }
            if (apellidoPat != null && !apellidoPat.isBlank()
                    && !apellidoPat.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El apellido paterno solo puede contener letras");
                return;
            }
            if (apellidoMat != null && !apellidoMat.isBlank()
                    && !apellidoMat.trim().matches("[A-Za-záéíóúÁÉÍÓÚüÜñÑ\\s'\\-]+")) {
                JsonUtil.writeError(res, 400, "El apellido materno solo puede contener letras");
                return;
            }
            if (!email.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                JsonUtil.writeError(res, 400, "El correo electrónico no tiene un formato válido");
                return;
            }
            if (password != null && !password.isBlank() && !PasswordUtil.isValid(password)) {
                JsonUtil.writeError(res, 400, PasswordUtil.POLICY_MSG);
                return;
            }

            empleadoService.actualizar(id, nombre.trim(), apellidoPat, apellidoMat, email.trim(),
                                       password, rol != null ? rol : "empleado",
                                       depId > 0 ? depId : null, cargoId > 0 ? cargoId : null);
            JsonUtil.writeOk(res, "Empleado actualizado correctamente");

        } catch (ServiceException e) {
            int status = "empleado_dup".equals(e.getToastKey()) ? 409 : 500;
            JsonUtil.writeError(res, status, e.getMessage());
        }
    }

    // ── DELETE (baja lógica) ──────────────────────────────────────────────────
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
            empleadoService.eliminar(id);
            JsonUtil.writeOk(res, "Empleado dado de baja correctamente");
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    // ── PATCH (reactivar empleado) ────────────────────────────────────────────
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if ("PATCH".equalsIgnoreCase(req.getMethod())) {
            doPatch(req, res);
        } else {
            super.service(req, res);
        }
    }

    protected void doPatch(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            JsonUtil.writeError(res, 400, "ID requerido"); return;
        }

        try {
            long id = Long.parseLong(idParam.trim());
            empleadoService.reactivar(id);
            JsonUtil.writeOk(res, "Empleado reactivado correctamente");
        } catch (NumberFormatException e) {
            JsonUtil.writeError(res, 400, "ID inválido");
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private boolean isAdmin(HttpServletRequest req) {
        Object rol = req.getSession(false) != null ? req.getSession(false).getAttribute("rol") : null;
        return "admin".equals(rol);
    }

    private String listToJson(List<CatalogoItemDTO> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            CatalogoItemDTO item = list.get(i);
            sb.append("{\"id\":").append(item.getId())
              .append(",\"nombre\":\"").append(JsonUtil.escape(item.getNombre())).append("\"}");
        }
        return sb.append("]").toString();
    }
}
