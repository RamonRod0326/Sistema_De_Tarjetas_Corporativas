package org.example.tarjetas_corporativas.dao.impl;

import org.example.tarjetas_corporativas.dao.CuentaGlobalDAO;
import org.example.tarjetas_corporativas.dto.AdminDashboardStatsDTO;
import org.example.tarjetas_corporativas.dto.MovimientoGlobalDTO;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

public class CuentaGlobalDAOImpl implements CuentaGlobalDAO {

    private static final Calendar UTC = Calendar.getInstance(TimeZone.getTimeZone("UTC"));

    @Override
    public AdminDashboardStatsDTO getAdminDashboardStats(Connection con) throws SQLException {
        // Single round-trip for all dashboard KPIs
        String sql =
            "SELECT " +
            "  NVL((SELECT saldo FROM CUENTA_GLOBAL WHERE id=1),0) AS saldo_global, " +
            "  (SELECT COUNT(*) FROM CUENTAS  WHERE activo=1) AS cuentas_activas, " +
            "  (SELECT COUNT(*) FROM TARJETAS WHERE activo=1) AS tarjetas_emitidas, " +
            "  (SELECT COUNT(*) FROM USUARIOS WHERE activo=1 AND rol='empleado') AS empleados_activos, " +
            "  NVL((SELECT SUM(monto) FROM CG_MOVIMIENTOS WHERE tipo='asignacion' " +
            "        AND TRUNC(fecha,'MM')=TRUNC(SYSDATE,'MM')),0) AS transferido_mes " +
            "FROM DUAL";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new AdminDashboardStatsDTO(
                rs.getBigDecimal("saldo_global"),
                rs.getLong("cuentas_activas"),
                rs.getLong("tarjetas_emitidas"),
                rs.getLong("empleados_activos"),
                rs.getBigDecimal("transferido_mes")
            );
        }
    }

    @Override
    public List<MovimientoGlobalDTO> findMovimientosRecientes(Connection con, int limit) throws SQLException {
        String sql =
            "SELECT cgm.tipo, cgm.monto, cgm.concepto, cgm.saldo_anterior, cgm.saldo_nuevo, " +
            "       cgm.fecha, u.nombre AS admin_nombre, " +
            "       uc.numero_cuenta AS cuenta_destino_num, " +
            "       ud.nombre AS titular_destino " +
            "FROM CG_MOVIMIENTOS cgm " +
            "LEFT JOIN USUARIOS u  ON cgm.admin_id       = u.id " +
            "LEFT JOIN MOVIMIENTOS m ON cgm.movimiento_id = m.id " +
            "LEFT JOIN CUENTAS uc  ON m.cuenta_destino_id = uc.id " +
            "LEFT JOIN USUARIOS ud ON uc.usuario_id       = ud.id " +
            "ORDER BY cgm.fecha DESC FETCH FIRST ? ROWS ONLY";
        List<MovimientoGlobalDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MovimientoGlobalDTO(
                        rs.getString("tipo"),
                        rs.getBigDecimal("monto"),
                        rs.getString("concepto"),
                        rs.getTimestamp("fecha", UTC),
                        rs.getString("admin_nombre"),
                        rs.getString("cuenta_destino_num"),
                        rs.getString("titular_destino")
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public List<MovimientoGlobalDTO> findMovimientosPaged(Connection con, String tipo, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT cgm.tipo, cgm.monto, cgm.concepto, cgm.saldo_anterior, cgm.saldo_nuevo, " +
            "       cgm.fecha, u.nombre AS admin_nombre, " +
            "       uc.numero_cuenta AS cuenta_destino_num, " +
            "       ud.nombre AS titular_destino " +
            "FROM CG_MOVIMIENTOS cgm " +
            "LEFT JOIN USUARIOS u  ON cgm.admin_id       = u.id " +
            "LEFT JOIN MOVIMIENTOS m ON cgm.movimiento_id = m.id " +
            "LEFT JOIN CUENTAS uc  ON m.cuenta_destino_id = uc.id " +
            "LEFT JOIN USUARIOS ud ON uc.usuario_id       = ud.id");
        if (tipo != null) sql.append(" WHERE cgm.tipo = ?");
        sql.append(" ORDER BY cgm.fecha DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<MovimientoGlobalDTO> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (tipo != null) ps.setString(idx++, tipo);
            ps.setInt(idx++, offset);
            ps.setInt(idx,   limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MovimientoGlobalDTO(
                        rs.getString("tipo"),
                        rs.getBigDecimal("monto"),
                        rs.getString("concepto"),
                        rs.getTimestamp("fecha", UTC),
                        rs.getString("admin_nombre"),
                        rs.getString("cuenta_destino_num"),
                        rs.getString("titular_destino")
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public long countMovimientos(Connection con, String tipo) throws SQLException {
        String sql = tipo != null
            ? "SELECT COUNT(*) FROM CG_MOVIMIENTOS WHERE tipo = ?"
            : "SELECT COUNT(*) FROM CG_MOVIMIENTOS";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (tipo != null) ps.setString(1, tipo);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    @Override
    public void depositar(Connection con, BigDecimal monto, String concepto, long adminId) throws SQLException {
        // FOR UPDATE to prevent race condition
        BigDecimal saldoAnterior;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT saldo FROM CUENTA_GLOBAL WHERE id = 1 FOR UPDATE");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            saldoAnterior = rs.getBigDecimal("saldo");
        }

        BigDecimal saldoNuevo = saldoAnterior.add(monto);

        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTA_GLOBAL SET saldo = ?, fecha_act = SYSTIMESTAMP WHERE id = 1")) {
            ps.setBigDecimal(1, saldoNuevo);
            ps.executeUpdate();
        }

        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO CG_MOVIMIENTOS (tipo, monto, concepto, saldo_anterior, saldo_nuevo, admin_id) " +
                "VALUES ('deposito', ?, ?, ?, ?, ?)")) {
            ps.setBigDecimal(1, monto);
            ps.setString(2, concepto);
            ps.setBigDecimal(3, saldoAnterior);
            ps.setBigDecimal(4, saldoNuevo);
            ps.setLong(5, adminId);
            ps.executeUpdate();
        }
    }

    @Override
    public void logAsignacion(Connection con, BigDecimal monto, BigDecimal saldoAnterior,
                              BigDecimal saldoNuevo, long adminId, long movimientoId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO CG_MOVIMIENTOS " +
                "(tipo, monto, concepto, saldo_anterior, saldo_nuevo, admin_id, movimiento_id) " +
                "VALUES ('asignacion', ?, 'Asignación a cuenta de empleado', ?, ?, ?, ?)")) {
            ps.setBigDecimal(1, monto);
            ps.setBigDecimal(2, saldoAnterior);
            ps.setBigDecimal(3, saldoNuevo);
            ps.setLong(4, adminId);
            ps.setLong(5, movimientoId);
            ps.executeUpdate();
        }
    }

    @Override
    public void addSaldo(Connection con, BigDecimal monto) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE CUENTA_GLOBAL SET saldo = saldo + ? WHERE id = 1")) {
            ps.setBigDecimal(1, monto);
            ps.executeUpdate();
        }
    }

    @Override
    public void logDevolucion(Connection con, BigDecimal monto, BigDecimal saldoAnterior,
                              BigDecimal saldoNuevo, String concepto, long adminId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO CG_MOVIMIENTOS (tipo, monto, concepto, saldo_anterior, saldo_nuevo, admin_id) " +
                "VALUES ('reversion', ?, ?, ?, ?, ?)")) {
            ps.setBigDecimal(1, monto);
            ps.setString(2, concepto);
            ps.setBigDecimal(3, saldoAnterior);
            ps.setBigDecimal(4, saldoNuevo);
            ps.setLong(5, adminId);
            ps.executeUpdate();
        }
    }
}
