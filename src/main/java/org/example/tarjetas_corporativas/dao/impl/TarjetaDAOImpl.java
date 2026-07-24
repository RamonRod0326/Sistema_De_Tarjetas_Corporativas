package org.example.tarjetas_corporativas.dao.impl;

import org.example.tarjetas_corporativas.dao.TarjetaDAO;
import org.example.tarjetas_corporativas.dto.TarjetaAdminDTO;
import org.example.tarjetas_corporativas.dto.TarjetaUserDTO;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

public class TarjetaDAOImpl implements TarjetaDAO {

    private static final Calendar UTC = Calendar.getInstance(TimeZone.getTimeZone("UTC"));

    @Override
    public List<TarjetaAdminDTO> findAllActive(Connection con) throws SQLException {
        String sql =
            "SELECT t.id, t.numero_tarjeta, t.modalidad, t.estado, t.activo, t.fecha_emision, " +
            "       c.id AS cuenta_id, c.numero_cuenta, NVL(c.saldo,0) AS saldo, " +
            "       NVL(cat.nombre,'Sin categoría') AS categoria, " +
            "       u.nombre AS titular, " +
            "       NVL(dep.nombre,'Sin depto') AS departamento " +
            "FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "LEFT JOIN USUARIOS u ON c.usuario_id = u.id " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS dep ON e.departamento_id = dep.id " +
            "WHERE t.activo = 1 AND u.activo = 1 " +
            "ORDER BY t.fecha_emision DESC";

        List<TarjetaAdminDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new TarjetaAdminDTO(
                    rs.getLong("id"),
                    rs.getString("numero_tarjeta"),
                    rs.getString("modalidad"),
                    rs.getString("estado"),
                    rs.getInt("activo"),
                    rs.getTimestamp("fecha_emision", UTC),
                    rs.getLong("cuenta_id"),
                    rs.getString("numero_cuenta"),
                    nvl(rs.getBigDecimal("saldo")),
                    rs.getString("categoria"),
                    rs.getString("titular"),
                    rs.getString("departamento")
                ));
            }
        }
        return list;
    }

    @Override
    public List<TarjetaAdminDTO> findAdminPaged(Connection con, String estado, String modalidad,
                                                int offset, int limit) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT t.id, t.numero_tarjeta, t.modalidad, t.estado, t.activo, t.fecha_emision, " +
            "c.id AS cuenta_id, c.numero_cuenta, NVL(c.saldo,0) AS saldo, " +
            "NVL(cat.nombre,'Sin categoría') AS categoria, u.nombre AS titular, " +
            "NVL(dep.nombre,'Sin depto') AS departamento " +
            "FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "LEFT JOIN USUARIOS u ON c.usuario_id = u.id " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS dep ON e.departamento_id = dep.id " +
            "WHERE t.activo = 1 AND u.activo = 1 ");
        boolean hasEstado = estado != null && !estado.isBlank();
        boolean hasModal  = modalidad != null && !modalidad.isBlank();
        if (hasEstado) sb.append("AND t.estado = ? ");
        if (hasModal)  sb.append("AND t.modalidad = ? ");
        sb.append("ORDER BY t.fecha_emision DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<TarjetaAdminDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            if (hasEstado) ps.setString(idx++, estado);
            if (hasModal)  ps.setString(idx++, modalidad);
            ps.setInt(idx++, offset); ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TarjetaAdminDTO(
                        rs.getLong("id"), rs.getString("numero_tarjeta"), rs.getString("modalidad"),
                        rs.getString("estado"), rs.getInt("activo"),
                        rs.getTimestamp("fecha_emision", UTC),
                        rs.getLong("cuenta_id"), rs.getString("numero_cuenta"),
                        nvl(rs.getBigDecimal("saldo")), rs.getString("categoria"),
                        rs.getString("titular"), rs.getString("departamento")));
                }
            }
        }
        return list;
    }

    @Override
    public long countAdmin(Connection con, String estado, String modalidad) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(*) FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "LEFT JOIN USUARIOS u ON c.usuario_id = u.id " +
            "WHERE t.activo = 1 AND u.activo = 1 ");
        boolean hasEstado = estado != null && !estado.isBlank();
        boolean hasModal  = modalidad != null && !modalidad.isBlank();
        if (hasEstado) sb.append("AND t.estado = ? ");
        if (hasModal)  sb.append("AND t.modalidad = ? ");
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            if (hasEstado) ps.setString(idx++, estado);
            if (hasModal)  ps.setString(idx++, modalidad);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    @Override
    public List<TarjetaUserDTO> findByUsuarioId(Connection con, long usuarioId) throws SQLException {
        String sql =
            "SELECT t.id, t.numero_tarjeta, t.modalidad, t.estado, t.activo, t.fecha_emision, " +
            "       c.id AS cuenta_id, c.numero_cuenta, NVL(c.saldo,0) AS saldo, " +
            "       NVL(cat.nombre,'Sin categoría') AS categoria " +
            "FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "WHERE t.activo = 1 AND c.usuario_id = ? " +
            "ORDER BY t.fecha_emision DESC";

        List<TarjetaUserDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TarjetaUserDTO(
                        rs.getLong("id"),
                        rs.getString("numero_tarjeta"),
                        rs.getString("modalidad"),
                        rs.getString("estado"),
                        rs.getInt("activo"),
                        rs.getTimestamp("fecha_emision", UTC),
                        rs.getLong("cuenta_id"),
                        rs.getString("numero_cuenta"),
                        nvl(rs.getBigDecimal("saldo")),
                        rs.getString("categoria")
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public List<TarjetaUserDTO> findByUsuarioIdPaged(Connection con, long usuarioId, String estado,
                                                     int offset, int limit) throws SQLException {
        boolean hasEstado = estado != null && !estado.isBlank();
        StringBuilder sb = new StringBuilder(
            "SELECT t.id, t.numero_tarjeta, t.modalidad, t.estado, t.activo, t.fecha_emision, " +
            "c.id AS cuenta_id, c.numero_cuenta, NVL(c.saldo,0) AS saldo, " +
            "NVL(cat.nombre,'Sin categoría') AS categoria " +
            "FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "LEFT JOIN CATEGORIAS_CUENTA cat ON c.categoria_id = cat.id " +
            "WHERE t.activo = 1 AND c.usuario_id = ? ");
        if (hasEstado) sb.append("AND t.estado = ? ");
        sb.append("ORDER BY t.fecha_emision DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<TarjetaUserDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setLong(idx++, usuarioId);
            if (hasEstado) ps.setString(idx++, estado);
            ps.setInt(idx++, offset); ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TarjetaUserDTO(
                        rs.getLong("id"), rs.getString("numero_tarjeta"), rs.getString("modalidad"),
                        rs.getString("estado"), rs.getInt("activo"),
                        rs.getTimestamp("fecha_emision", UTC),
                        rs.getLong("cuenta_id"), rs.getString("numero_cuenta"),
                        nvl(rs.getBigDecimal("saldo")), rs.getString("categoria")));
                }
            }
        }
        return list;
    }

    @Override
    public long countByUsuarioId(Connection con, long usuarioId, String estado) throws SQLException {
        boolean hasEstado = estado != null && !estado.isBlank();
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(*) FROM TARJETAS t " +
            "JOIN CUENTAS c ON t.cuenta_id = c.id " +
            "WHERE t.activo = 1 AND c.usuario_id = ? ");
        if (hasEstado) sb.append("AND t.estado = ? ");
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setLong(idx++, usuarioId);
            if (hasEstado) ps.setString(idx++, estado);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    @Override
    public void insert(Connection con, long cuentaId, String modalidad) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO TARJETAS (cuenta_id, modalidad) VALUES (?, ?)")) {
            ps.setLong(1, cuentaId);
            ps.setString(2, modalidad);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateEstado(Connection con, long id, String estado) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE TARJETAS SET estado = ? WHERE id = ? AND activo = 1")) {
            ps.setString(1, estado);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void deactivate(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE TARJETAS SET estado = 'BLOQUEADA', activo = 0 WHERE id = ?")) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void deactivateByUsuarioId(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE TARJETAS SET activo = 0, estado = 'BLOQUEADA' " +
                "WHERE cuenta_id IN (SELECT id FROM CUENTAS WHERE usuario_id = ?) AND activo = 1")) {
            ps.setLong(1, usuarioId);
            ps.executeUpdate();
        }
    }

    @Override
    public void reactivateByUsuarioId(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE TARJETAS SET activo = 1, estado = 'ACTIVA' " +
                "WHERE cuenta_id IN (SELECT id FROM CUENTAS WHERE usuario_id = ?) " +
                "AND activo = 0 AND estado = 'BLOQUEADA'")) {
            ps.setLong(1, usuarioId);
            ps.executeUpdate();
        }
    }

    private static BigDecimal nvl(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }
}
