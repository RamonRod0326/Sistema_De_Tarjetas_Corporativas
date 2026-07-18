package org.example.tarjetas_corporativas.dao.impl;

import org.example.tarjetas_corporativas.dao.CuentaDAO;
import org.example.tarjetas_corporativas.dto.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class CuentaDAOImpl implements CuentaDAO {

    private static final String SQL_CUENTAS_USER =
        "SELECT c.id, c.numero_cuenta, NVL(c.saldo,0) AS saldo, c.estado, " +
        "       NVL(cat.nombre,'Sin categoría') AS categoria, c.categoria_id " +
        "FROM CUENTAS c LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
        "WHERE c.usuario_id = ? AND c.activo = 1 ORDER BY c.fecha_creacion";

    @Override
    public List<CuentaUserDTO> findByUsuarioId(Connection con, long usuarioId) throws SQLException {
        List<CuentaUserDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SQL_CUENTAS_USER)) {
            ps.setLong(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CuentaUserDTO(
                        rs.getLong("id"),
                        rs.getString("numero_cuenta"),
                        rs.getBigDecimal("saldo"),
                        rs.getString("estado"),
                        rs.getString("categoria"),
                        rs.getObject("categoria_id", Long.class)
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public List<CuentaDestinoDTO> findDestinos(Connection con, long excludeUsuarioId) throws SQLException {
        String sql =
            "SELECT c.id, c.numero_cuenta, u.nombre AS titular, " +
            "       NVL(cat.nombre,'Sin categoría') AS categoria, c.categoria_id " +
            "FROM CUENTAS c " +
            "JOIN USUARIOS u ON c.usuario_id = u.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "WHERE c.usuario_id <> ? AND c.activo = 1 AND c.estado = 'ACTIVA' " +
            "ORDER BY u.nombre, cat.nombre";
        List<CuentaDestinoDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, excludeUsuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CuentaDestinoDTO(
                        rs.getLong("id"),
                        rs.getString("numero_cuenta"),
                        rs.getString("titular"),
                        rs.getString("categoria"),
                        rs.getObject("categoria_id", Long.class)
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public List<CuentaDestinoDTO> searchDestinos(Connection con, long excludeUsuarioId,
                                                  String q, Long categoriaId, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.numero_cuenta, u.nombre AS titular, " +
            "       NVL(cat.nombre,'Sin categoría') AS categoria, c.categoria_id " +
            "FROM CUENTAS c " +
            "JOIN USUARIOS u ON c.usuario_id = u.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "WHERE c.usuario_id <> ? AND c.activo = 1 AND c.estado = 'ACTIVA'");
        if (q != null) sql.append(" AND (UPPER(u.nombre) LIKE UPPER(?) OR c.numero_cuenta LIKE ?)");
        if (categoriaId != null) sql.append(" AND c.categoria_id = ?");
        sql.append(" ORDER BY u.nombre FETCH FIRST ? ROWS ONLY");

        List<CuentaDestinoDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, excludeUsuarioId);
            if (q != null) {
                String like = "%" + q.toUpperCase() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, "%" + q + "%");
            }
            if (categoriaId != null) ps.setLong(idx++, categoriaId);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CuentaDestinoDTO(
                        rs.getLong("id"),
                        rs.getString("numero_cuenta"),
                        rs.getString("titular"),
                        rs.getString("categoria"),
                        rs.getObject("categoria_id", Long.class)
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public AdminCuentasStatsDTO getAdminStats(Connection con) throws SQLException {
        String sql =
            "SELECT " +
            "  (SELECT COUNT(*) FROM CUENTAS WHERE activo=1 AND estado='ACTIVA') AS cuentas_activas, " +
            "  (SELECT COUNT(DISTINCT usuario_id) FROM CUENTAS WHERE activo=1) AS emp_con_cuenta, " +
            "  (SELECT NVL(saldo,0) FROM CUENTA_GLOBAL WHERE id=1) AS total_circulacion, " +
            "  (SELECT COUNT(*) FROM CUENTAS WHERE activo=1 AND estado='CONGELADA') AS congeladas " +
            "FROM DUAL";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new AdminCuentasStatsDTO(
                rs.getLong("cuentas_activas"),
                rs.getLong("emp_con_cuenta"),
                rs.getBigDecimal("total_circulacion"),
                rs.getLong("congeladas")
            );
        }
    }

    @Override
    public Map<Long, List<CuentaDetalleDTO>> findCuentasPorEmpleados(Connection con,
                                                                      List<Long> ids) throws SQLException {
        Map<Long, List<CuentaDetalleDTO>> map = new LinkedHashMap<>();
        if (ids.isEmpty()) return map;

        StringBuilder ph = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) { if (i > 0) ph.append(','); ph.append('?'); }

        String sql =
            "SELECT c.usuario_id, c.id AS cuenta_id, c.numero_cuenta, " +
            "       NVL(c.saldo,0) AS saldo, c.estado, " +
            "       NVL(cat.nombre,'Sin categoría') AS categoria, COUNT(t.id) AS num_tarjetas " +
            "FROM CUENTAS c " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "LEFT JOIN TARJETAS t ON t.cuenta_id = c.id AND t.activo = 1 " +
            "WHERE c.usuario_id IN (" + ph + ") AND c.activo = 1 " +
            "GROUP BY c.usuario_id, c.id, c.numero_cuenta, c.saldo, c.estado, " +
            "         cat.nombre, c.fecha_creacion " +
            "ORDER BY c.usuario_id, c.fecha_creacion";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < ids.size(); i++) ps.setLong(i + 1, ids.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long uid = rs.getLong("usuario_id");
                    map.computeIfAbsent(uid, k -> new ArrayList<>()).add(new CuentaDetalleDTO(
                        rs.getLong("cuenta_id"),
                        rs.getString("numero_cuenta"),
                        rs.getBigDecimal("saldo"),
                        rs.getString("estado"),
                        rs.getString("categoria"),
                        rs.getLong("num_tarjetas")
                    ));
                }
            }
        }
        return map;
    }

    @Override
    public Object[] findForTransferLock(Connection con, long cuentaId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT categoria_id, NVL(saldo,0) AS saldo, estado, usuario_id " +
                "FROM CUENTAS WHERE id = ? AND activo = 1 FOR UPDATE")) {
            ps.setLong(1, cuentaId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new Object[]{
                    rs.getObject("categoria_id", Long.class),
                    rs.getBigDecimal("saldo"),
                    rs.getString("estado"),
                    rs.getLong("usuario_id")
                };
            }
        }
    }

    @Override
    public Object[] findDestinoInfo(Connection con, long cuentaId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT categoria_id, estado, usuario_id FROM CUENTAS WHERE id = ? AND activo = 1")) {
            ps.setLong(1, cuentaId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new Object[]{
                    rs.getObject("categoria_id", Long.class),
                    rs.getString("estado"),
                    rs.getLong("usuario_id")
                };
            }
        }
    }

    @Override
    public Long resolveCuentaId(Connection con, String raw) throws SQLException {
        if (raw == null || raw.isBlank()) return null;
        String v = raw.trim();
        if (v.matches("\\d{1,15}")) return Long.parseLong(v);
        if (v.matches("\\d{16}")) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM CUENTAS WHERE numero_cuenta = ?")) {
                ps.setString(1, v);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getLong("id") : null;
                }
            }
        }
        return null;
    }

    @Override
    public String findNumeroCuenta(Connection con, long cuentaId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT numero_cuenta FROM CUENTAS WHERE id = ?")) {
            ps.setLong(1, cuentaId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("numero_cuenta") : null;
            }
        }
    }

    @Override
    public void insert(Connection con, long usuarioId, Long categoriaId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO CUENTAS (usuario_id, categoria_id, estado, activo) VALUES (?, ?, 'ACTIVA', 1)")) {
            ps.setLong(1, usuarioId);
            if (categoriaId != null) ps.setLong(2, categoriaId); else ps.setNull(2, Types.NUMERIC);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateEstado(Connection con, long cuentaId, String estado) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTAS SET estado = ? WHERE id = ?")) {
            ps.setString(1, estado);
            ps.setLong(2, cuentaId);
            ps.executeUpdate();
        }
    }

    @Override
    public void deactivate(Connection con, long cuentaId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTAS SET activo = 0, estado = 'CONGELADA' WHERE id = ?")) {
            ps.setLong(1, cuentaId);
            ps.executeUpdate();
        }
    }

    @Override
    public void deactivateByUsuarioId(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTAS SET saldo = 0, activo = 0, estado = 'CONGELADA' " +
                "WHERE usuario_id = ? AND activo = 1")) {
            ps.setLong(1, usuarioId);
            ps.executeUpdate();
        }
    }

    @Override
    public void reactivateByUsuarioId(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTAS SET activo = 1, estado = 'ACTIVA' " +
                "WHERE usuario_id = ? AND activo = 0 AND estado = 'CONGELADA'")) {
            ps.setLong(1, usuarioId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<CatalogoItemDTO> findCategoriasActivas(Connection con) throws SQLException {
        List<CatalogoItemDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, nombre FROM CATEGORIAS_CUENTA WHERE activo = 1 ORDER BY nombre");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(new CatalogoItemDTO(rs.getLong("id"), rs.getString("nombre")));
        }
        return list;
    }

    @Override
    public Long resolveCategoriaId(Connection con, String raw) throws SQLException {
        if (raw == null || raw.isBlank()) return null;
        if (raw.trim().matches("\\d+")) return Long.parseLong(raw.trim());
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id FROM CATEGORIAS_CUENTA WHERE LOWER(nombre) = ? AND activo = 1")) {
            ps.setString(1, raw.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong("id") : null;
            }
        }
    }
}
