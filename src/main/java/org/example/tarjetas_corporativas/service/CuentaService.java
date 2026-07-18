package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.*;
import org.example.tarjetas_corporativas.dao.impl.*;
import org.example.tarjetas_corporativas.dto.*;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.List;
import java.util.Map;

/**
 * Servicio de negocio para la gestión de cuentas corporativas.
 * <p>
 * Cubre las operaciones de consulta, creación, cambio de estado y baja lógica
 * de cuentas, tanto para la vista de administrador como para las páginas del usuario.
 * </p>
 */
public class CuentaService {

    private final CuentaDAO   cuentaDAO;
    private final UsuarioDAO  usuarioDAO;

    /** Construye el servicio inicializando las implementaciones DAO. */
    public CuentaService() {
        this.cuentaDAO  = new CuentaDAOImpl();
        this.usuarioDAO = new UsuarioDAOImpl();
    }

    /**
     * Retorna estadísticas agregadas de cuentas para el panel de administrador.
     *
     * @return {@link AdminCuentasStatsDTO} con totales y saldos
     * @throws ServiceException si ocurre un error de base de datos
     */
    public AdminCuentasStatsDTO getAdminStats() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaDAO.getAdminStats(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar estadísticas de cuentas", e);
        }
    }

    /**
     * Retorna todos los empleados junto con el número de cuentas que tienen.
     *
     * @return lista de {@link EmpleadoCuentaRowDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<EmpleadoCuentaRowDTO> getEmpleadosConCuentas() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return usuarioDAO.findEmpleadosConCuentas(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar empleados con cuentas", e);
        }
    }

    public PageResult<EmpleadoCuentaRowDTO> getEmpleadosConCuentasPaged(String search, int page, int pageSize) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long total  = usuarioDAO.countEmpleadosConCuentas(con, search);
            int  offset = PageUtil.offset(page, pageSize);
            List<EmpleadoCuentaRowDTO> items = usuarioDAO.findEmpleadosConCuentasPaged(con, search, offset, pageSize);
            return new PageResult<>(items, page, pageSize, total);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar empleados con cuentas", e);
        }
    }

    /**
     * Retorna las cuentas de los empleados indicados, agrupadas por ID de usuario.
     *
     * @param ids lista de IDs de usuarios
     * @return mapa {@code usuarioId → lista de CuentaDetalleDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public Map<Long, List<CuentaDetalleDTO>> getCuentasPorEmpleados(List<Long> ids) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaDAO.findCuentasPorEmpleados(con, ids);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cuentas por empleado", e);
        }
    }

    /**
     * Retorna los datos necesarios para el formulario de creación de cuenta.
     *
     * @return array {@code Object[2]}: {@code [empleadosActivos, categoriasActivas]}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public Object[] getFormData() {
        try (Connection con = DataSourceProvider.getConnection()) {
            List<EmpleadoRowDTO>    emps  = usuarioDAO.findEmpleadosActivosParaForm(con);
            List<CatalogoItemDTO>   cats  = cuentaDAO.findCategoriasActivas(con);
            return new Object[]{ emps, cats };
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar formulario de cuenta", e);
        }
    }

    /**
     * Crea una nueva cuenta corporativa para el empleado indicado.
     *
     * @param usuarioId    ID del empleado propietario
     * @param categoriaRaw ID o nombre de la categoría de cuenta
     * @throws ServiceException con clave {@code "cuenta_error"} ante violación de integridad
     */
    public void crear(long usuarioId, String categoriaRaw) {
        try (Connection con = DataSourceProvider.getConnection()) {
            Long catId = cuentaDAO.resolveCategoriaId(con, categoriaRaw);
            cuentaDAO.insert(con, usuarioId, catId);
            con.commit();
        } catch (SQLIntegrityConstraintViolationException e) {
            throw new ServiceException("Restricción de integridad al crear cuenta", "cuenta_error", e);
        } catch (SQLException e) {
            throw new ServiceException("Error al crear cuenta", e);
        }
    }

    /**
     * Cambia el estado de una cuenta entre {@code ACTIVA} y {@code CONGELADA}.
     *
     * @param cuentaIdRaw ID de la cuenta como cadena de texto
     * @param estado      nuevo estado: {@code "ACTIVA"} o {@code "CONGELADA"}
     * @throws ServiceException con clave {@code "cuenta_error"} si el estado es inválido o la cuenta no existe
     */
    public void actualizarEstado(String cuentaIdRaw, String estado) {
        if (!estado.equals("ACTIVA") && !estado.equals("CONGELADA"))
            throw new ServiceException("Estado inválido", "cuenta_error");
        try (Connection con = DataSourceProvider.getConnection()) {
            Long cuentaId = cuentaDAO.resolveCuentaId(con, cuentaIdRaw);
            if (cuentaId == null) throw new ServiceException("Cuenta no encontrada", "cuenta_error");
            cuentaDAO.updateEstado(con, cuentaId, estado);
            con.commit();
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar estado de cuenta", e);
        }
    }

    /**
     * Da de baja lógica una cuenta (la congela y pone saldo en cero).
     *
     * @param cuentaIdRaw ID de la cuenta como cadena de texto
     * @throws ServiceException con clave {@code "cuenta_error"} si la cuenta no existe
     */
    public void eliminar(String cuentaIdRaw) {
        try (Connection con = DataSourceProvider.getConnection()) {
            Long cuentaId = cuentaDAO.resolveCuentaId(con, cuentaIdRaw);
            if (cuentaId == null) throw new ServiceException("Cuenta no encontrada", "cuenta_error");
            cuentaDAO.deactivate(con, cuentaId);
            con.commit();
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error al eliminar cuenta", e);
        }
    }

    /**
     * Retorna las cuentas activas de un usuario para las páginas del empleado.
     *
     * @param usuarioId ID del usuario
     * @return lista de {@link CuentaUserDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<CuentaUserDTO> getCuentasUsuario(long usuarioId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaDAO.findByUsuarioId(con, usuarioId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cuentas del usuario", e);
        }
    }

    /**
     * Retorna las cuentas activas de otros usuarios disponibles como destino de transferencia.
     *
     * @param usuarioId ID del usuario que origina la transferencia (sus cuentas quedan excluidas)
     * @return lista de {@link CuentaDestinoDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<CuentaDestinoDTO> getDestinos(long usuarioId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaDAO.findDestinos(con, usuarioId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cuentas destino", e);
        }
    }

    public List<CuentaDestinoDTO> buscarDestinos(long usuarioId, String q, Long categoriaId, int limit) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return cuentaDAO.searchDestinos(con, usuarioId, q, categoriaId, limit);
        } catch (SQLException e) {
            throw new ServiceException("Error al buscar cuentas destino", e);
        }
    }
}
