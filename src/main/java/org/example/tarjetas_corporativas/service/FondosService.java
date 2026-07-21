package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.CuentaDAO;
import org.example.tarjetas_corporativas.dao.CuentaGlobalDAO;
import org.example.tarjetas_corporativas.dao.MovimientoDAO;
import org.example.tarjetas_corporativas.dao.impl.CuentaDAOImpl;
import org.example.tarjetas_corporativas.dao.impl.CuentaGlobalDAOImpl;
import org.example.tarjetas_corporativas.dao.impl.MovimientoDAOImpl;
import org.example.tarjetas_corporativas.exception.ServiceException;
import java.math.BigDecimal;
import java.sql.*;

/**
 * Servicio de negocio para la gestión de fondos corporativos.
 * <p>
 * Maneja dos flujos distintos: el depósito directo a la cuenta global corporativa
 * (ingreso de dinero externo al sistema) y la asignación de fondos desde dicha
 * cuenta global hacia la cuenta de un empleado.
 * Ambas operaciones usan transacciones con rollback ante cualquier error.
 * </p>
 */
public class FondosService {

    private final CuentaGlobalDAO cuentaGlobalDAO;
    private final CuentaDAO       cuentaDAO;
    private final MovimientoDAO   movimientoDAO;

    /** Construye el servicio inicializando las implementaciones DAO. */
    public FondosService() {
        this.cuentaGlobalDAO = new CuentaGlobalDAOImpl();
        this.cuentaDAO       = new CuentaDAOImpl();
        this.movimientoDAO   = new MovimientoDAOImpl();
    }

    /**
     * Deposita dinero directamente en la cuenta corporativa global.
     *
     * @param monto    monto a depositar (debe ser positivo)
     * @param concepto descripción del depósito
     * @param adminId  ID del administrador que realiza el depósito
     * @throws ServiceException si ocurre un error de base de datos
     */
    public void depositarGlobal(BigDecimal monto, String concepto, long adminId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            try {
                cuentaGlobalDAO.depositar(con, monto, concepto, adminId);
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new ServiceException("Error al depositar fondos globales", e);
        }
    }

    /**
     * Asigna fondos desde la cuenta global a la cuenta de un empleado.
     * <p>
     * El trigger Oracle descuenta el monto de {@code CUENTA_GLOBAL} y lo acredita
     * en {@code CUENTAS}; este método solo coordina la llamada y registra el
     * movimiento en {@code CG_MOVIMIENTOS}. El error Oracle 20005 indica saldo
     * global insuficiente.
     * </p>
     *
     * @param cuentaIdRaw ID o número de la cuenta destino como cadena de texto
     * @param monto       monto a asignar
     * @param adminId     ID del administrador que autoriza la asignación
     * @throws ServiceException con clave {@code "fondos_err"} si la cuenta no existe
     *                          o el saldo global es insuficiente
     */
    public void asignarFondos(String cuentaIdRaw, BigDecimal monto, long adminId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            try {
                Long cuentaId = cuentaDAO.resolveCuentaId(con, cuentaIdRaw);
                if (cuentaId == null)
                    throw new ServiceException("Cuenta no encontrada", "fondos_err");

                // Read current global balance (before the movement trigger changes it)
                // The MOVIMIENTOS trigger will deduct from CUENTA_GLOBAL and credit CUENTAS
                // We only need to record the CG_MOVIMIENTOS entry
                BigDecimal saldoAnterior = getSaldoGlobal(con);

                long movId = movimientoDAO.insertAsignacion(con, cuentaId, monto, adminId);

                BigDecimal saldoNuevo = getSaldoGlobal(con);

                cuentaGlobalDAO.logAsignacion(con, monto, saldoAnterior, saldoNuevo, adminId, movId);

                con.commit();
            } catch (ServiceException e) {
                con.rollback();
                throw e;
            } catch (SQLException e) {
                con.rollback();
                if (e.getErrorCode() == 20005) {
                    throw new ServiceException("Saldo global insuficiente", "fondos_err", e);
                }
                throw new ServiceException("Error al asignar fondos", e);
            }
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error de conexión al asignar fondos", e);
        }
    }

    private BigDecimal getSaldoGlobal(Connection con) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT saldo FROM CUENTA_GLOBAL WHERE id = 1");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getBigDecimal("saldo");
        }
    }
}
