package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.CuentaDAO;
import org.example.tarjetas_corporativas.dao.TarjetaDAO;
import org.example.tarjetas_corporativas.dao.impl.CuentaDAOImpl;
import org.example.tarjetas_corporativas.dao.impl.TarjetaDAOImpl;
import org.example.tarjetas_corporativas.dto.PageResult;
import org.example.tarjetas_corporativas.dto.TarjetaAdminDTO;
import org.example.tarjetas_corporativas.dto.TarjetaUserDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PageUtil;
import java.sql.*;
import java.util.List;

/**
 * Servicio de negocio para la gestión de tarjetas corporativas.
 * <p>
 * Encapsula las operaciones de emisión, consulta, actualización de estado
 * y cancelación de tarjetas. Gestiona el ciclo de vida de la conexión
 * a base de datos y la atomicidad de cada operación.
 * </p>
 */
public class TarjetaService {

    private final TarjetaDAO tarjetaDAO;
    private final CuentaDAO  cuentaDAO;

    /** Construye el servicio inicializando las implementaciones DAO. */
    public TarjetaService() {
        this.tarjetaDAO = new TarjetaDAOImpl();
        this.cuentaDAO  = new CuentaDAOImpl();
    }

    /**
     * Retorna todas las tarjetas activas del sistema para la vista de administrador.
     *
     * @return lista de {@link TarjetaAdminDTO} con datos del titular, cuenta y saldo
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<TarjetaAdminDTO> getTarjetasAdmin() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return tarjetaDAO.findAllActive(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar tarjetas", e);
        }
    }

    public PageResult<TarjetaAdminDTO> getTarjetasAdminPaged(String estado, String modalidad,
                                                              int page, int pageSize) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long total  = tarjetaDAO.countAdmin(con, estado, modalidad);
            int  offset = PageUtil.offset(page, pageSize);
            List<TarjetaAdminDTO> items = tarjetaDAO.findAdminPaged(con, estado, modalidad, offset, pageSize);
            return new PageResult<>(items, page, pageSize, total);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar tarjetas", e);
        }
    }

    /**
     * Retorna las tarjetas activas de un usuario específico.
     *
     * @param usuarioId identificador del usuario
     * @return lista de {@link TarjetaUserDTO}
     * @throws ServiceException si ocurre un error de base de datos
     */
    public List<TarjetaUserDTO> getTarjetasUsuario(long usuarioId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return tarjetaDAO.findByUsuarioId(con, usuarioId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar tarjetas del usuario", e);
        }
    }

    public PageResult<TarjetaUserDTO> getTarjetasUsuarioPaged(long usuarioId, String estado,
                                                               int page, int pageSize) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long total  = tarjetaDAO.countByUsuarioId(con, usuarioId, estado);
            int  offset = PageUtil.offset(page, pageSize);
            List<TarjetaUserDTO> items = tarjetaDAO.findByUsuarioIdPaged(con, usuarioId, estado, offset, pageSize);
            return new PageResult<>(items, page, pageSize, total);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar tarjetas del usuario", e);
        }
    }

    /**
     * Actualiza el estado de una tarjeta (bloquear o desbloquear).
     *
     * @param idRaw  identificador de la tarjeta como cadena de texto
     * @param estado nuevo estado: {@code "ACTIVA"} o {@code "BLOQUEADA"}
     * @throws ServiceException si el estado es inválido, el ID es incorrecto o hay error de BD
     */
    public void actualizarEstado(String idRaw, String estado) {
        if (!"ACTIVA".equals(estado) && !"BLOQUEADA".equals(estado)) {
            throw new ServiceException("Estado de tarjeta inválido", "tarjeta_estado_error");
        }
        try (Connection con = DataSourceProvider.getConnection()) {
            long id = Long.parseLong(idRaw.trim());
            tarjetaDAO.updateEstado(con, id, estado);
            con.commit();
        } catch (NumberFormatException e) {
            throw new ServiceException("ID de tarjeta inválido", "tarjeta_estado_error");
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar estado de tarjeta", e);
        }
    }

    /**
     * Cancela permanentemente una tarjeta (baja lógica).
     * Establece {@code estado='BLOQUEADA'} y {@code activo=0},
     * respetando la restricción Oracle {@code ck_tarjeta_estado_actv}.
     *
     * @param idRaw identificador de la tarjeta como cadena de texto
     * @throws ServiceException si el ID es incorrecto o hay error de BD
     */
    public void cancelar(String idRaw) {
        try (Connection con = DataSourceProvider.getConnection()) {
            long id = Long.parseLong(idRaw.trim());
            tarjetaDAO.deactivate(con, id);
            con.commit();
        } catch (NumberFormatException e) {
            throw new ServiceException("ID de tarjeta inválido", "tarjeta_estado_error");
        } catch (SQLException e) {
            throw new ServiceException("Error al cancelar tarjeta", e);
        }
    }

    /**
     * Emite una nueva tarjeta para la cuenta indicada.
     *
     * @param cuentaIdRaw identificador de la cuenta como cadena de texto
     * @param modalidad   modalidad solicitada ({@code "VIRTUAL"} o {@code "FISICA"})
     * @throws ServiceException si la cuenta no existe o hay error de BD
     */
    public void emitir(String cuentaIdRaw, String modalidad) {
        String modalidadDB = (modalidad != null && modalidad.toUpperCase().contains("SICA"))
            ? "FISICA" : "VIRTUAL";
        try (Connection con = DataSourceProvider.getConnection()) {
            Long cuentaId = cuentaDAO.resolveCuentaId(con, cuentaIdRaw);
            if (cuentaId == null) throw new ServiceException("Cuenta no encontrada", "tarjeta_error");

            tarjetaDAO.insert(con, cuentaId, modalidadDB);
            con.commit();
        } catch (ServiceException e) {
            throw e;
        } catch (SQLIntegrityConstraintViolationException e) {
            throw new ServiceException("Restricción al emitir tarjeta", "tarjeta_error", e);
        } catch (SQLException e) {
            throw new ServiceException("Error al emitir tarjeta", e);
        }
    }
}
