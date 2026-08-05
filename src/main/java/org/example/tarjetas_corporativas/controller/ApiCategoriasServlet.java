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
import java.math.BigDecimal;
import java.util.List;

/**
 * API REST JSON para CRUD de categorías de cuenta.
 * GET    /api/categorias           → lista todas con conteo de cuentas
 * GET    /api/categorias?id=X      → cuentas de la categoría X
 * POST   /api/categorias           → crea categoría
 * PUT    /api/categorias           → actualiza nombre
 * DELETE /api/categorias?id=X      → elimina categoría
 */
@WebServlet(name = "apiCategoriasServlet", urlPatterns = {"/api/categorias"})
public class ApiCategoriasServlet extends HttpServlet {

    private final CatalogoService catalogoService = new CatalogoService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { JsonUtil.writeError(res, 403, "Acceso denegado"); return; }

        String idParam = req.getParameter("id");
        try {
            if (idParam != null && !idParam.isBlank()) {
                long catId = Long.parseLong(idParam.trim());
                List<Object[]> cuentas = catalogoService.getCuentasByCategoria(catId);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < cuentas.size(); i++) {
                    Object[] c = cuentas.get(i);
                    if (i > 0) sb.append(",");
                    BigDecimal saldo = c[3] != null ? (BigDecimal) c[3] : BigDecimal.ZERO;
                    sb.append("{")
                      .append("\"id\":").append(c[0]).append(",")
                      .append("\"numeroCuenta\":\"").append(JsonUtil.escape(String.valueOf(c[1]))).append("\",")
                      .append("\"titular\":\"").append(JsonUtil.escape(String.valueOf(c[2]))).append("\",")
                      .append("\"saldo\":").append(saldo).append(",")
                      .append("\"estado\":\"").append(JsonUtil.escape(String.valueOf(c[4]))).append("\"")
                      .append("}");
                }
                JsonUtil.writeJson(res, sb.append("]").toString());
            } else {
                List<Object[]> cats = catalogoService.getCategoriasConCount();
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < cats.size(); i++) {
                    Object[] c = cats.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(c[0]).append(",")
                      .append("\"nombre\":\"").append(JsonUtil.escape(String.valueOf(c[1]))).append("\",")
                      .append("\"totalCuentas\":").append(c[2])
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
            catalogoService.insertarCategoria(nombre.trim());
            JsonUtil.writeOk(res, "Categoría creada correctamente");
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
            catalogoService.actualizarCategoria(id, nombre.trim());
            JsonUtil.writeOk(res, "Categoría actualizada correctamente");
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
            catalogoService.eliminarCategoria(Long.parseLong(idParam.trim()));
            JsonUtil.writeOk(res, "Categoría eliminada correctamente");
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
