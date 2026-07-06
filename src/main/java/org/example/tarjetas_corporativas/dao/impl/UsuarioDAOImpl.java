package org.example.tarjetas_corporativas.dao.impl;

import org.example.tarjetas_corporativas.dao.UsuarioDAO;
import org.example.tarjetas_corporativas.dto.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAOImpl implements UsuarioDAO {

    // Expresión reutilizable: nombre completo concatenado en Oracle
    private static final String NOMBRE_COMPLETO =
        "TRIM(u.nombre || NVL2(u.apellido_paterno, ' ' || u.apellido_paterno, '') " +
        "               || NVL2(u.apellido_materno, ' ' || u.apellido_materno, ''))";

    private static final String SQL_PERFIL =
        "SELECT " + NOMBRE_COMPLETO + " AS nombre_completo, u.email, e.empleado_id, " +
        "NVL(c.nombre,'—') AS cargo, NVL(d.nombre,'—') AS departamento " +
        "FROM USUARIOS u " +
        "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
        "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
        "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
        "WHERE u.id = ?";

    private static final String SQL_AUTH =
        "SELECT u.id, " + NOMBRE_COMPLETO + " AS nombre_completo, u.password_hash, u.rol, " +
        "NVL(c.nombre,'') AS cargo, NVL(d.nombre,'') AS departamento " +
        "FROM USUARIOS u " +
        "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
        "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
        "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
        "WHERE u.email = ? AND u.activo = 1";

    @Override
    public Object[] findByEmailForAuth(Connection con, String email) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_AUTH)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new Object[]{
                    rs.getLong("id"),
                    rs.getString("nombre_completo"),
                    rs.getString("password_hash"),
                    rs.getString("rol"),
                    rs.getString("cargo"),
                    rs.getString("departamento")
                };
            }
        }
    }

    @Override
    public PerfilDTO findPerfil(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_PERFIL)) {
            ps.setLong(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                String nombre = rs.getString("nombre_completo");
                return new PerfilDTO(
                    nombre,
                    rs.getString("email"),
                    rs.getString("empleado_id"),
                    rs.getString("cargo"),
                    rs.getString("departamento"),
                    computeIniciales(nombre)
                );
            }
        }
    }

    @Override
    public EmpleadoStatsDTO getEmpleadoStats(Connection con) throws SQLException {
        String sql =
            "SELECT " +
            "  (SELECT COUNT(*) FROM USUARIOS WHERE rol='empleado') AS total, " +
            "  (SELECT COUNT(*) FROM USUARIOS WHERE rol='empleado' AND activo=1) AS activos, " +
            "  (SELECT COUNT(*) FROM DEPARTAMENTOS WHERE activo=1) AS departamentos, " +
            "  (SELECT COUNT(*) FROM USUARIOS WHERE rol='empleado' AND activo=1 " +
            "     AND TRUNC(fecha_creacion,'MM')=TRUNC(SYSDATE,'MM')) AS nuevos_mes " +
            "FROM DUAL";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new EmpleadoStatsDTO(
                rs.getLong("total"),
                rs.getLong("activos"),
                rs.getLong("departamentos"),
                rs.getLong("nuevos_mes")
            );
        }
    }

    @Override
    public List<EmpleadoRowDTO> findAllEmpleados(Connection con) throws SQLException {
        String sql =
            "SELECT u.id, " + NOMBRE_COMPLETO + " AS nombre, u.email, u.activo, " +
            "       NVL(d.nombre,'—') AS departamento, NVL(c.nombre,'—') AS cargo " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
            "WHERE u.rol = 'empleado' " +
            "ORDER BY u.activo DESC, u.nombre ASC";
        List<EmpleadoRowDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EmpleadoRowDTO(
                    rs.getLong("id"),
                    rs.getString("nombre"),
                    rs.getString("email"),
                    rs.getInt("activo"),
                    rs.getString("departamento"),
                    rs.getString("cargo")
                ));
            }
        }
        return list;
    }

    @Override
    public List<EmpleadoRowDTO> findEmpleadosPaged(Connection con, String search, Boolean activo,
                                                   int offset, int limit) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT u.id, " + NOMBRE_COMPLETO + " AS nombre, u.email, u.activo, " +
            "NVL(d.nombre,'—') AS departamento, NVL(c.nombre,'—') AS cargo " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
            "WHERE u.rol = 'empleado' ");
        if (activo != null) sb.append("AND u.activo = ").append(activo ? 1 : 0).append(" ");
        boolean hasSearch = search != null && !search.isBlank();
        if (hasSearch) sb.append(
            "AND (LOWER(u.nombre) LIKE ? OR LOWER(NVL(u.apellido_paterno,'')) LIKE ? " +
            "OR LOWER(u.email) LIKE ? OR LOWER(NVL(d.nombre,'')) LIKE ?) ");
        sb.append("ORDER BY u.activo DESC, u.nombre ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<EmpleadoRowDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            if (hasSearch) {
                String like = "%" + search.toLowerCase().trim() + "%";
                ps.setString(idx++, like); ps.setString(idx++, like);
                ps.setString(idx++, like); ps.setString(idx++, like);
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new EmpleadoRowDTO(rs.getLong("id"), rs.getString("nombre"),
                        rs.getString("email"), rs.getInt("activo"),
                        rs.getString("departamento"), rs.getString("cargo")));
                }
            }
        }
        return list;
    }

    @Override
    public long countEmpleados(Connection con, String search, Boolean activo) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(*) FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "WHERE u.rol = 'empleado' ");
        if (activo != null) sb.append("AND u.activo = ").append(activo ? 1 : 0).append(" ");
        boolean hasSearch = search != null && !search.isBlank();
        if (hasSearch) sb.append(
            "AND (LOWER(u.nombre) LIKE ? OR LOWER(NVL(u.apellido_paterno,'')) LIKE ? " +
            "OR LOWER(u.email) LIKE ? OR LOWER(NVL(d.nombre,'')) LIKE ?) ");
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            if (hasSearch) {
                String like = "%" + search.toLowerCase().trim() + "%";
                ps.setString(1, like); ps.setString(2, like);
                ps.setString(3, like); ps.setString(4, like);
            }
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    @Override
    public List<EmpleadoCuentaRowDTO> findEmpleadosConCuentasPaged(Connection con, String search,
                                                                    int offset, int limit) throws SQLException {
        boolean hasSearch = search != null && !search.isBlank();
        StringBuilder sb = new StringBuilder(
            "SELECT u.id, u.activo, " + NOMBRE_COMPLETO + " AS nombre, " +
            "NVL(car.nombre,'Sin cargo') AS cargo, NVL(dep.nombre,'Sin depto') AS departamento, " +
            "NVL(cagg.num_cuentas,0) AS num_cuentas, " +
            "NVL(tagg.num_tarjetas,0) AS num_tarjetas, " +
            "NVL(cagg.saldo_total,0) AS saldo_total, " +
            "CASE WHEN NVL(cagg.num_cuentas,0)=0 THEN 'ACTIVO' " +
            "     WHEN NVL(cagg.cuentas_activas,0)=0 THEN 'CONGELADO' " +
            "     ELSE 'ACTIVO' END AS estado_emp " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN CARGOS car ON e.cargo_id = car.id " +
            "LEFT JOIN DEPARTAMENTOS dep ON e.departamento_id = dep.id " +
            "LEFT JOIN (SELECT c.usuario_id, COUNT(*) AS num_cuentas, " +
            "                  SUM(c.saldo) AS saldo_total, " +
            "                  SUM(CASE WHEN c.estado='ACTIVA' THEN 1 ELSE 0 END) AS cuentas_activas " +
            "           FROM CUENTAS c WHERE c.activo=1 GROUP BY c.usuario_id) cagg " +
            "  ON cagg.usuario_id = u.id " +
            "LEFT JOIN (SELECT c2.usuario_id, COUNT(t.id) AS num_tarjetas " +
            "           FROM CUENTAS c2 JOIN TARJETAS t ON t.cuenta_id=c2.id AND t.activo=1 " +
            "           WHERE c2.activo=1 GROUP BY c2.usuario_id) tagg " +
            "  ON tagg.usuario_id = u.id " +
            "WHERE u.rol = 'empleado' ");
        if (hasSearch) sb.append(
            "AND (LOWER(u.nombre) LIKE ? OR LOWER(NVL(u.apellido_paterno,'')) LIKE ? " +
            "OR LOWER(NVL(dep.nombre,'')) LIKE ?) ");
        sb.append("ORDER BY u.activo DESC, u.nombre OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<EmpleadoCuentaRowDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int idx = 1;
            if (hasSearch) {
                String like = "%" + search.toLowerCase().trim() + "%";
                ps.setString(idx++, like); ps.setString(idx++, like); ps.setString(idx++, like);
            }
            ps.setInt(idx++, offset); ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new EmpleadoCuentaRowDTO(
                        rs.getLong("id"), rs.getString("nombre"), rs.getString("cargo"),
                        rs.getString("departamento"), rs.getLong("num_cuentas"),
                        rs.getLong("num_tarjetas"), rs.getBigDecimal("saldo_total"),
                        rs.getString("estado_emp"), rs.getInt("activo")));
                }
            }
        }
        return list;
    }

    @Override
    public long countEmpleadosConCuentas(Connection con, String search) throws SQLException {
        boolean hasSearch = search != null && !search.isBlank();
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(DISTINCT u.id) FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS dep ON e.departamento_id = dep.id " +
            "WHERE u.rol = 'empleado' ");
        if (hasSearch) sb.append(
            "AND (LOWER(u.nombre) LIKE ? OR LOWER(NVL(u.apellido_paterno,'')) LIKE ? " +
            "OR LOWER(NVL(dep.nombre,'')) LIKE ?) ");
        try (PreparedStatement ps = con.prepareStatement(sb.toString())) {
            if (hasSearch) {
                String like = "%" + search.toLowerCase().trim() + "%";
                ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
            }
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    @Override
    public List<EmpleadoRecenteDTO> findRecientes(Connection con, int limit) throws SQLException {
        String sql =
            "SELECT u.id, " + NOMBRE_COMPLETO + " AS nombre, u.email, NVL(d.nombre,'—') AS departamento " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "WHERE u.activo = 1 AND u.rol = 'empleado' " +
            "ORDER BY u.fecha_creacion DESC FETCH FIRST ? ROWS ONLY";
        List<EmpleadoRecenteDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new EmpleadoRecenteDTO(
                        rs.getLong("id"),
                        rs.getString("nombre"),
                        rs.getString("email"),
                        rs.getString("departamento")
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public List<EmpleadoCuentaRowDTO> findEmpleadosConCuentas(Connection con) throws SQLException {
        String sql =
            "SELECT u.id, u.activo, " + NOMBRE_COMPLETO + " AS nombre, " +
            "       NVL(car.nombre,'Sin cargo') AS cargo, " +
            "       NVL(dep.nombre,'Sin depto') AS departamento, " +
            "       NVL(cagg.num_cuentas,0) AS num_cuentas, " +
            "       NVL(tagg.num_tarjetas,0) AS num_tarjetas, " +
            "       NVL(cagg.saldo_total,0) AS saldo_total, " +
            "       CASE WHEN NVL(cagg.num_cuentas,0)=0 THEN 'ACTIVO' " +
            "            WHEN NVL(cagg.cuentas_activas,0)=0 THEN 'CONGELADO' " +
            "            ELSE 'ACTIVO' END AS estado_emp " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN CARGOS car ON e.cargo_id = car.id " +
            "LEFT JOIN DEPARTAMENTOS dep ON e.departamento_id = dep.id " +
            "LEFT JOIN (SELECT c.usuario_id, COUNT(*) AS num_cuentas, " +
            "                  SUM(c.saldo) AS saldo_total, " +
            "                  SUM(CASE WHEN c.estado='ACTIVA' THEN 1 ELSE 0 END) AS cuentas_activas " +
            "           FROM CUENTAS c WHERE c.activo=1 GROUP BY c.usuario_id) cagg " +
            "  ON cagg.usuario_id = u.id " +
            "LEFT JOIN (SELECT c2.usuario_id, COUNT(t.id) AS num_tarjetas " +
            "           FROM CUENTAS c2 JOIN TARJETAS t ON t.cuenta_id=c2.id AND t.activo=1 " +
            "           WHERE c2.activo=1 GROUP BY c2.usuario_id) tagg " +
            "  ON tagg.usuario_id = u.id " +
            "WHERE u.rol = 'empleado' " +
            "ORDER BY u.activo DESC, u.nombre";
        List<EmpleadoCuentaRowDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EmpleadoCuentaRowDTO(
                    rs.getLong("id"),
                    rs.getString("nombre"),
                    rs.getString("cargo"),
                    rs.getString("departamento"),
                    rs.getLong("num_cuentas"),
                    rs.getLong("num_tarjetas"),
                    rs.getBigDecimal("saldo_total"),
                    rs.getString("estado_emp"),
                    rs.getInt("activo")
                ));
            }
        }
        return list;
    }

    @Override
    public EmpleadoFormDTO findForEdit(Connection con, long id) throws SQLException {
        String sql =
            "SELECT u.id, u.nombre, u.apellido_paterno, u.apellido_materno, u.email, u.rol, " +
            "       e.departamento_id, e.cargo_id, " +
            "       NVL(c.nombre,'Sin cargo') AS cargo_nombre, " +
            "       NVL(d.nombre,'Sin depto') AS dep_nombre " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "WHERE u.id = ? AND u.activo = 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                String nombre          = rs.getString("nombre");
                String apellidoPaterno = rs.getString("apellido_paterno");
                String apellidoMaterno = rs.getString("apellido_materno");
                return new EmpleadoFormDTO(
                    rs.getLong("id"), nombre, apellidoPaterno, apellidoMaterno,
                    rs.getString("email"), rs.getString("rol"),
                    rs.getLong("departamento_id"), rs.getLong("cargo_id"),
                    rs.getString("cargo_nombre"), rs.getString("dep_nombre"),
                    computeIniciales(nombre, apellidoPaterno)
                );
            }
        }
    }

    @Override
    public List<EmpleadoRowDTO> findEmpleadosActivosParaForm(Connection con) throws SQLException {
        String sql =
            "SELECT u.id, " + NOMBRE_COMPLETO + " AS nombre, " +
            "       NVL(c.nombre,'Sin cargo') AS cargo, " +
            "       NVL(d.nombre,'Sin depto') AS departamento " +
            "FROM USUARIOS u " +
            "LEFT JOIN EMPLEADOS e ON u.id = e.usuario_id " +
            "LEFT JOIN CARGOS c ON e.cargo_id = c.id " +
            "LEFT JOIN DEPARTAMENTOS d ON e.departamento_id = d.id " +
            "WHERE u.activo = 1 AND u.rol = 'empleado' ORDER BY u.nombre";
        List<EmpleadoRowDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EmpleadoRowDTO(
                    rs.getLong("id"), rs.getString("nombre"), null,
                    1, rs.getString("departamento"), rs.getString("cargo")
                ));
            }
        }
        return list;
    }

    @Override
    public void insertEmpleado(Connection con, String nombre, String apellidoPaterno, String apellidoMaterno,
                               String email, String hash,
                               String rol, Long depId, Long cargoId) throws SQLException {
        long newId;
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO USUARIOS (nombre, apellido_paterno, apellido_materno, email, password_hash, rol) " +
                "VALUES (?, ?, ?, ?, ?, ?)",
                new String[]{"ID"})) {
            ps.setString(1, nombre);
            setNullableString(ps, 2, apellidoPaterno);
            setNullableString(ps, 3, apellidoMaterno);
            ps.setString(4, email);
            ps.setString(5, hash);
            ps.setString(6, rol);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("No se generó ID para USUARIOS");
                newId = keys.getLong(1);
            }
        }
        if ("empleado".equals(rol)) {
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO EMPLEADOS (usuario_id, departamento_id, cargo_id) VALUES (?, ?, ?)")) {
                ps2.setLong(1, newId);
                setNullableLong(ps2, 2, depId);
                setNullableLong(ps2, 3, cargoId);
                ps2.executeUpdate();
            }
        }
    }

    @Override
    public void updateEmpleado(Connection con, long id, String nombre, String apellidoPaterno, String apellidoMaterno,
                               String email, String rol, Long depId, Long cargoId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET nombre=?, apellido_paterno=?, apellido_materno=?, email=?, rol=? WHERE id=?")) {
            ps.setString(1, nombre);
            setNullableString(ps, 2, apellidoPaterno);
            setNullableString(ps, 3, apellidoMaterno);
            ps.setString(4, email);
            ps.setString(5, rol);
            ps.setLong(6, id);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE EMPLEADOS SET departamento_id=?, cargo_id=? WHERE usuario_id=?")) {
            setNullableLong(ps, 1, depId);
            setNullableLong(ps, 2, cargoId);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateEmpleadoConHash(Connection con, long id, String nombre, String apellidoPaterno, String apellidoMaterno,
                                      String email, String rol, Long depId, Long cargoId, String hash) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET nombre=?, apellido_paterno=?, apellido_materno=?, email=?, rol=?, password_hash=? WHERE id=?")) {
            ps.setString(1, nombre);
            setNullableString(ps, 2, apellidoPaterno);
            setNullableString(ps, 3, apellidoMaterno);
            ps.setString(4, email);
            ps.setString(5, rol);
            ps.setString(6, hash);
            ps.setLong(7, id);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE EMPLEADOS SET departamento_id=?, cargo_id=? WHERE usuario_id=?")) {
            setNullableLong(ps, 1, depId);
            setNullableLong(ps, 2, cargoId);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateNombre(Connection con, long id, String nombre) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET nombre = ? WHERE id = ?")) {
            ps.setString(1, nombre);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void updatePasswordHash(Connection con, long id, String hash) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET password_hash = ? WHERE id = ?")) {
            ps.setString(1, hash);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    @Override
    public String findPasswordHash(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT password_hash FROM USUARIOS WHERE id = ?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("password_hash") : null;
            }
        }
    }

    @Override
    public BigDecimal sumSaldoCuentasActivas(Connection con, long usuarioId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT NVL(SUM(saldo),0) AS total FROM CUENTAS WHERE usuario_id = ? AND activo = 1")) {
            ps.setLong(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal("total") : BigDecimal.ZERO;
            }
        }
    }

    @Override
    public void deactivate(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET activo = 0 WHERE id = ? AND rol = 'empleado'")) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public void reactivate(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE USUARIOS SET activo = 1 WHERE id = ? AND rol = 'empleado'")) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public String findNombreById(Connection con, long id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT nombre FROM USUARIOS WHERE id = ?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("nombre") : "Empleado";
            }
        }
    }

    private static String computeIniciales(String nombre, String apellidoPaterno) {
        String i1 = (nombre != null && !nombre.isBlank())
            ? String.valueOf(nombre.trim().charAt(0)).toUpperCase() : "";
        String i2 = (apellidoPaterno != null && !apellidoPaterno.isBlank())
            ? String.valueOf(apellidoPaterno.trim().charAt(0)).toUpperCase() : "";
        if (!i1.isEmpty() && !i2.isEmpty()) return i1 + i2;
        String base = nombre != null ? nombre.trim() : "";
        return base.length() >= 2 ? base.substring(0, 2).toUpperCase() : base.toUpperCase();
    }

    // Overload for callers that only have the full concatenated name
    private static String computeIniciales(String nombreCompleto) {
        if (nombreCompleto == null || nombreCompleto.isBlank()) return "?";
        String[] parts = nombreCompleto.trim().split("\\s+");
        return parts.length >= 2
            ? (String.valueOf(parts[0].charAt(0)) + parts[parts.length - 1].charAt(0)).toUpperCase()
            : (nombreCompleto.length() >= 2 ? nombreCompleto.substring(0, 2).toUpperCase() : nombreCompleto.toUpperCase());
    }

    private static void setNullableLong(PreparedStatement ps, int i, Long v) throws SQLException {
        if (v != null) ps.setLong(i, v); else ps.setNull(i, Types.NUMERIC);
    }

    private static void setNullableString(PreparedStatement ps, int i, String v) throws SQLException {
        if (v != null && !v.isBlank()) ps.setString(i, v.trim()); else ps.setNull(i, Types.VARCHAR);
    }
}
