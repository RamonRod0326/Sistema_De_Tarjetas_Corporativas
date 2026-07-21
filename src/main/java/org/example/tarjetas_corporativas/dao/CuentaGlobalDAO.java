package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.AdminDashboardStatsDTO;
import org.example.tarjetas_corporativas.dto.MovimientoGlobalDTO;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO para la tabla {@code CUENTA_GLOBAL} y su historial {@code CG_MOVIMIENTOS}.
 * <p>
 * La cuenta global corporativa es única (ID = 1) y actúa como reserva central de
 * fondos que el administrador distribuye a los empleados. Todas las operaciones
 * reciben una {@link Connection} externa.
 * </p>
 */
public interface CuentaGlobalDAO {

    /**
     * Retorna los KPIs del dashboard de administrador en una sola consulta agregada.
     *
     * @param con conexión activa
     * @return {@link AdminDashboardStatsDTO} con saldo global, contadores y variaciones
     */
    AdminDashboardStatsDTO getAdminDashboardStats(Connection con) throws SQLException;

    /**
     * Retorna los movimientos corporativos globales más recientes.
     *
     * @param con   conexión activa
     * @param limit número máximo de registros
     * @return lista de {@link MovimientoGlobalDTO} ordenada por fecha descendente
     */
    List<MovimientoGlobalDTO> findMovimientosRecientes(Connection con, int limit) throws SQLException;

    List<MovimientoGlobalDTO> findMovimientosPaged(Connection con, String tipo, int offset, int limit) throws SQLException;

    long countMovimientos(Connection con, String tipo) throws SQLException;

    /**
     * Registra un depósito directo en la cuenta global e incrementa su saldo.
     *
     * @param con      conexión activa
     * @param monto    monto a depositar
     * @param concepto descripción del depósito
     * @param adminId  ID del administrador que realiza el depósito
     */
    void depositar(Connection con, BigDecimal monto, String concepto, long adminId) throws SQLException;

    /**
     * Registra en {@code CG_MOVIMIENTOS} una asignación de fondos ya procesada.
     * Debe llamarse después de {@link org.example.tarjetas_corporativas.dao.MovimientoDAO#insertAsignacion}
     * para tener el ID del movimiento generado.
     *
     * @param con           conexión activa
     * @param monto         monto asignado
     * @param saldoAnterior saldo de la cuenta global antes de la asignación
     * @param saldoNuevo    saldo de la cuenta global después de la asignación
     * @param adminId       ID del administrador que autoriza
     * @param movimientoId  ID del registro {@code MOVIMIENTOS} relacionado
     */
    void logAsignacion(Connection con, BigDecimal monto, BigDecimal saldoAnterior,
                       BigDecimal saldoNuevo, long adminId, long movimientoId) throws SQLException;

    /**
     * Incrementa directamente el saldo de la cuenta global, sin registrar movimiento.
     * Usado al dar de baja un empleado para devolver los fondos de sus cuentas.
     *
     * @param con   conexión activa
     * @param monto monto a agregar al saldo global
     */
    void addSaldo(Connection con, BigDecimal monto) throws SQLException;

    /**
     * Registra en {@code CG_MOVIMIENTOS} la devolución de fondos producida al dar
     * de baja a un empleado. El saldo ya fue incrementado por {@link #addSaldo}.
     *
     * @param con           conexión activa
     * @param monto         monto devuelto
     * @param saldoAnterior saldo global antes de la devolución
     * @param saldoNuevo    saldo global después de la devolución
     * @param concepto      descripción (nombre del empleado dado de baja)
     * @param adminId       ID del administrador que realizó la baja
     */
    void logDevolucion(Connection con, BigDecimal monto, BigDecimal saldoAnterior,
                       BigDecimal saldoNuevo, String concepto, long adminId) throws SQLException;
}
