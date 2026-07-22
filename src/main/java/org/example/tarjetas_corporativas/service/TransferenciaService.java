package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.CuentaDAO;
import org.example.tarjetas_corporativas.dao.MovimientoDAO;
import org.example.tarjetas_corporativas.dao.impl.CuentaDAOImpl;
import org.example.tarjetas_corporativas.dao.impl.MovimientoDAOImpl;
import org.example.tarjetas_corporativas.dto.MovimientoDetalleDTO;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.TransferenciaHistorialDTO;
import org.example.tarjetas_corporativas.dto.TransferenciaStatsDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.List;

/**
 * Servicio de negocio para la ejecución y consulta de transferencias entre cuentas.
 * <p>
 * Provee dos variantes de transferencia: {@link #transferir} con validación completa
 * en Java (bloqueo FOR UPDATE, verificación de titularidad, estado y saldo), y
 * {@link #transferirLigero} que delega la mayoría de las validaciones a los triggers
 * Oracle (errores 20001–20004). Ambas usan rollback ante cualquier fallo.
 * </p>
 */
public class TransferenciaService {

    private final CuentaDAO    cuentaDAO;
    private final MovimientoDAO movimientoDAO;

    /** Construye el servicio inicializando las implementaciones DAO. */
    public TransferenciaService() {
        this.cuentaDAO    = new CuentaDAOImpl();
        this.movimientoDAO = new MovimientoDAOImpl();
    }

    /**
     * Executes a transfer with full pre-flight validation and FOR UPDATE locking.
     * Oracle trigger handles balance updates after INSERT.
     */
    public void transferir(long usuarioId, long origenId, long destinoId,
                           BigDecimal monto, String concepto) {
        if (origenId == destinoId)
            throw new ServiceException("Origen y destino iguales", "transferencia_err");

        try (Connection con = DataSourceProvider.getConnection()) {
            try {
                // 1. Lock origin account, validate ownership, state, and balance
                Object[] origen = cuentaDAO.findForTransferLock(con, origenId);
                if (origen == null)
                    throw new ServiceException("Cuenta origen no encontrada", "transferencia_err");

                long    origenUsuario = (long)   origen[3];
                String  origenEstado  = (String) origen[2];
                BigDecimal saldo      = (BigDecimal) origen[1];

                if (origenUsuario != usuarioId)
                    throw new ServiceException("Cuenta origen no pertenece al usuario", "transferencia_err");
                if (!"ACTIVA".equals(origenEstado))
                    throw new ServiceException("Cuenta origen congelada", "transferencia_frozen");
                if (saldo.compareTo(monto) < 0)
                    throw new ServiceException("Saldo insuficiente", "transferencia_saldo");

                Long catOrigen = (Long) origen[0];

                // 2. Validate destination account
                Object[] destino = cuentaDAO.findDestinoInfo(con, destinoId);
                if (destino == null)
                    throw new ServiceException("Cuenta destino no encontrada", "transferencia_err");

                long   destinoUsuario = (long)   destino[2];
                String destinoEstado  = (String) destino[1];
                Long   catDestino     = (Long)   destino[0];

                if (destinoUsuario == usuarioId)
                    throw new ServiceException("No puedes transferirte a ti mismo", "transferencia_err");
                if (!"ACTIVA".equals(destinoEstado))
                    throw new ServiceException("Cuenta destino congelada", "transferencia_frozen");
                if (catOrigen == null || catDestino == null || !catOrigen.equals(catDestino))
                    throw new ServiceException("Categorías incompatibles", "transferencia_cat");

                // 3. Insert movement — Oracle trigger updates balances
                movimientoDAO.insertTransferencia(con, origenId, destinoId, monto, concepto, usuarioId);
                con.commit();

            } catch (ServiceException e) {
                con.rollback();
                throw e;
            } catch (SQLException e) {
                con.rollback();
                String toast = switch (e.getErrorCode()) {
                    case 20001, 20002 -> "transferencia_frozen";
                    case 20003        -> "transferencia_cat";
                    case 20004        -> "transferencia_saldo";
                    default           -> "transferencia_err";
                };
                throw new ServiceException("Error de base de datos en transferencia", toast, e);
            }
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error de conexión en transferencia", e);
        }
    }

    /**
     * Lightweight transfer from the /user/transferencias page (relies on Oracle triggers for validation).
     */
    public void transferirLigero(long usuarioId, long origenId, long destinoId,
                                 BigDecimal monto, String concepto) {
        try (Connection con = DataSourceProvider.getConnection()) {
            try {
                // Minimal validation: confirm origin belongs to this user
                Object[] origen = cuentaDAO.findForTransferLock(con, origenId);
                if (origen == null || (long) origen[3] != usuarioId) {
                    con.rollback();
                    throw new ServiceException("Cuenta origen inválida", "transferencia_err");
                }

                movimientoDAO.insertTransferencia(con, origenId, destinoId, monto, concepto, usuarioId);
                con.commit();

            } catch (ServiceException e) {
                con.rollback();
                throw e;
            } catch (SQLException e) {
                con.rollback();
                String toast = switch (e.getErrorCode()) {
                    case 20001, 20002 -> "transferencia_frozen";
                    case 20003        -> "transferencia_cat";
                    case 20004        -> "transferencia_saldo";
                    default           -> "transferencia_err";
                };
                throw new ServiceException("Error de base de datos en transferencia", toast, e);
            }
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error de conexión en transferencia", e);
        }
    }

    /**
     * Retorna estadísticas de transferencias del mes actual para un usuario.
     *
     * @param usuarioId ID del usuario
     * @return {@link TransferenciaStatsDTO} con totales enviado/recibido/neto
     * @throws ServiceException si ocurre un error de base de datos
     */
    public TransferenciaStatsDTO getStats(long usuarioId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return movimientoDAO.getMonthlyStats(con, usuarioId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar estadísticas de transferencias", e);
        }
    }

    /**
     * Retorna el historial de transferencias de un usuario.
     *
     * @param usuarioId ID del usuario
     * @param limit     número máximo de registros a retornar
     * @return lista de {@link TransferenciaHistorialDTO} ordenada por fecha descendente
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<TransferenciaHistorialDTO> getHistorial(long usuarioId, int limit) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return movimientoDAO.findHistorialByUsuarioId(con, usuarioId, limit);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar historial de transferencias", e);
        }
    }

    public PageResult<TransferenciaHistorialDTO> getHistorialPaged(long usuarioId, String tipo,
                                                                    int page, int pageSize) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long total  = movimientoDAO.countHistorial(con, usuarioId, tipo);
            int  offset = PageUtil.offset(page, pageSize);
            List<TransferenciaHistorialDTO> items = movimientoDAO.findHistorialPaged(con, usuarioId, tipo, offset, pageSize);
            return new PageResult<>(items, page, pageSize, total);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar historial de transferencias", e);
        }
    }

    /**
     * Retorna movimientos detallados de un usuario (usados en la vista de cuentas).
     *
     * @param usuarioId ID del usuario
     * @param limit     número máximo de registros
     * @return lista de {@link MovimientoDetalleDTO} con dirección (entrada/salida)
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<MovimientoDetalleDTO> getMovimientosDetalle(long usuarioId, int limit) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return movimientoDAO.findDetalleByUsuarioId(con, usuarioId, limit);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar movimientos", e);
        }
    }
}
