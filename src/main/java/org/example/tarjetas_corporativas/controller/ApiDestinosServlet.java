package org.example.tarjetas_corporativas.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.tarjetas_corporativas.dto.CuentaDestinoDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.service.CuentaService;
import org.example.tarjetas_corporativas.util.JsonUtil;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.io.IOException;
import java.util.List;

/**
 * API de búsqueda de cuentas destino para el panel de transferencias.
 * GET /api/destinos?q=texto&categoriaId=X  → devuelve hasta PAGE_SIZE cuentas
 */
@WebServlet(name = "apiDestinosServlet", urlPatterns = {"/api/destinos"})
public class ApiDestinosServlet extends HttpServlet {

    private final CuentaService cuentaService = new CuentaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Long usuarioId = (Long) (req.getSession(false) != null
                ? req.getSession(false).getAttribute("usuarioId") : null);
        if (usuarioId == null) { JsonUtil.writeError(res, 401, "No autenticado"); return; }

        String q           = PageUtil.blankToNull(req.getParameter("q"));
        String catIdParam  = req.getParameter("categoriaId");
        Long   categoriaId = null;
        if (catIdParam != null && !catIdParam.isBlank()) {
            try { categoriaId = Long.parseLong(catIdParam.trim()); } catch (NumberFormatException ignored) {}
        }

        try {
            List<CuentaDestinoDTO> destinos =
                cuentaService.buscarDestinos(usuarioId, q, categoriaId, PageUtil.PAGE_SIZE);

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < destinos.size(); i++) {
                CuentaDestinoDTO d = destinos.get(i);
                if (i > 0) sb.append(",");
                sb.append("{")
                  .append("\"id\":").append(d.getId()).append(",")
                  .append("\"numeroCuenta\":\"").append(JsonUtil.escape(d.getNumeroCuenta())).append("\",")
                  .append("\"titular\":\"").append(JsonUtil.escape(d.getTitular())).append("\",")
                  .append("\"categoria\":\"").append(JsonUtil.escape(d.getCategoria())).append("\",")
                  .append("\"categoriaId\":").append(d.getCategoriaId() != null ? d.getCategoriaId() : "null")
                  .append("}");
            }
            sb.append("]");
            JsonUtil.writeJson(res, sb.toString());
        } catch (ServiceException e) {
            JsonUtil.writeError(res, 500, e.getMessage());
        }
    }
}
