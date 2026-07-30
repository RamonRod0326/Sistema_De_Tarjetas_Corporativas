package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.*;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO para la tabla {@code MOVIMIENTOS}.
 * <p>
 * Registra asignaciones de fondos y transferencias entre cuentas.
 * Los triggers Oracle actualizan los saldos de {@code CUENTAS} y {@code CUENTA_GLOBAL}
 * automáticamente tras cada INSERT; este DAO solo emite los inserts.
 * </p>
 * <p>
 * Todas las operaciones reciben una {@link Connection} externa; el commit y rollback
 * son responsabilidad del servicio llamante.
 * </p>
 */
public interface MovimientoDAO {

    /**
     * Inserta un movimiento de asignación de fondos globales a una cuenta de empleado.
     * El trigger Oracle descuenta el monto de {@code CUENTA_GLOBAL} y lo acredita en {@code CUENTAS}.
     *
     * @param con             conexión activa
     * @param cuentaDestinoId ID de la cuenta destino del empleado
     * @param monto           monto a asignar
     * @param adminId         ID del administrador que autoriza
     * @return ID generado del registro {@code MOVIMIENTOS} (para enlazar con {@code CG_MOVIMIENTOS})
     */
    long insertAsignacion(Connection con, long cuentaDestinoId,
                          BigDecimal monto, long adminId) throws SQLException;

    /**
     * Inserta un movimiento de transferencia entre dos cuentas de empleados.
     * El trigger Oracle actualiza los saldos de origen y destino.
     *
     * @param con          conexión activa
     * @param origenId     ID de la cuenta origen
     * @param destinoId    ID de la cuenta destino
     * @param monto        monto a transferir
     * @param concepto     descripción de la transferencia
     * @param realizadoPor ID del usuario que realiza la operación
     */
    void insertTransferencia(Connection con, long origenId, long destinoId,
                             BigDecimal monto, String concepto, long realizadoPor) throws SQLException;

    /**
     * Retorna los últimos movimientos de un usuario para el widget de actividad reciente del dashboard.
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     * @param limit     número máximo de registros
     * @return lista de {@link MovimientoDashboardDTO}
     */
    List<MovimientoDashboardDTO> findDashboardByUsuarioId(Connection con,
                                                          long usuarioId, int limit) throws SQLException;

    /**
     * Retorna movimientos detallados de un usuario con indicación de dirección (entrada/salida).
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     * @param limit     número máximo de registros
     * @return lista de {@link MovimientoDetalleDTO}
     */
    List<MovimientoDetalleDTO> findDetalleByUsuarioId(Connection con,
                                                      long usuarioId, int limit) throws SQLException;

    /**
     * Calcula las estadísticas de transferencias del mes actual para un usuario.
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     * @return {@link TransferenciaStatsDTO} con totales enviado, recibido y neto
     */
    TransferenciaStatsDTO getMonthlyStats(Connection con, long usuarioId) throws SQLException;

    /**
     * Retorna el historial de transferencias de un usuario (enviadas y recibidas).
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     * @param limit     número máximo de registros
     * @return lista de {@link TransferenciaHistorialDTO} ordenada por fecha descendente
     */
    List<TransferenciaHistorialDTO> findHistorialByUsuarioId(Connection con,
                                                             long usuarioId, int limit) throws SQLException;

    List<TransferenciaHistorialDTO> findHistorialPaged(Connection con, long usuarioId,
                                                       String tipo, int offset, int limit) throws SQLException;
    long countHistorial(Connection con, long usuarioId, String tipo) throws SQLException;
}
