package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.CuentaGlobalDAO;
import org.example.tarjetas_corporativas.dao.UsuarioDAO;
import org.example.tarjetas_corporativas.dao.impl.CuentaGlobalDAOImpl;
import org.example.tarjetas_corporativas.dao.impl.UsuarioDAOImpl;
import org.example.tarjetas_corporativas.dto.AdminDashboardStatsDTO;
import org.example.tarjetas_corporativas.dto.EmpleadoRecenteDTO;
import org.example.tarjetas_corporativas.dto.MovimientoGlobalDTO;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Servicio de negocio para los datos del dashboard de administrador.
 * <p>
 * Agrega en una sola consulta (via {@link CuentaGlobalDAO}) los KPIs del sistema:
 * saldo global, número de empleados activos, cuentas y tarjetas vigentes, y los
 * movimientos corporativos más recientes.
 * </p>
 */
public class DashboardAdminService {

    private final CuentaGlobalDAO cuentaGlobalDAO;
    private final UsuarioDAO      usuarioDAO;

    /** Construye el servicio inicializando las implementaciones DAO. */
    public DashboardAdminService() {
        this.cuentaGlobalDAO = new CuentaGlobalDAOImpl();
        this.usuarioDAO      = new UsuarioDAOImpl();
    }

    /**
     * Retorna los KPIs principales del sistema para el panel de administrador.
     *
     * @return {@link AdminDashboardStatsDTO} con saldo global, contadores y variaciones
     * @throws ServiceException si ocurre un error de base de datos
     */
    public AdminDashboardStatsDTO getStats() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaGlobalDAO.getAdminDashboardStats(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar estadísticas del dashboard", e);
        }
    }

    /**
     * Retorna los últimos movimientos de la cuenta corporativa global.
     *
     * @param limit número máximo de registros
     * @return lista de {@link MovimientoGlobalDTO} ordenada por fecha descendente
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<MovimientoGlobalDTO> getMovimientosRecientes(int limit) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaGlobalDAO.findMovimientosRecientes(con, limit);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar movimientos globales", e);
        }
    }

    /**
     * Retorna los empleados registrados más recientemente.
     *
     * @param limit número máximo de registros
     * @return lista de {@link EmpleadoRecenteDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public PageResult<MovimientoGlobalDTO> getMovimientosPaged(String tipo, int page, int pageSize) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long total  = cuentaGlobalDAO.countMovimientos(con, tipo);
            int  offset = PageUtil.offset(page, pageSize);
            List<MovimientoGlobalDTO> items = cuentaGlobalDAO.findMovimientosPaged(con, tipo, offset, pageSize);
            return new PageResult<>(items, page, pageSize, total);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar movimientos globales", e);
        }
    }

    public List<EmpleadoRecenteDTO> getEmpleadosRecientes(int limit) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return usuarioDAO.findRecientes(con, limit);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar empleados recientes", e);
        }
    }
}
