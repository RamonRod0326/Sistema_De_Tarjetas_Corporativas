package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.*;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * DAO para la tabla {@code CUENTAS}.
 * <p>
 * Todas las operaciones reciben una {@link Connection} externa: el ciclo de vida
 * de la conexión y el commit/rollback son responsabilidad del servicio llamante.
 * </p>
 */
public interface CuentaDAO {

    /**
     * Retorna las cuentas activas de un usuario para las páginas del empleado.
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     * @return lista de {@link CuentaUserDTO}
     */
    List<CuentaUserDTO> findByUsuarioId(Connection con, long usuarioId) throws SQLException;

    /**
     * Retorna las cuentas activas de otros usuarios disponibles como destino de transferencia.
     *
     * @param con               conexión activa
     * @param excludeUsuarioId  ID del usuario cuyas cuentas se excluyen
     * @return lista de {@link CuentaDestinoDTO}
     */
    List<CuentaDestinoDTO> findDestinos(Connection con, long excludeUsuarioId) throws SQLException;

    /**
     * Busca cuentas destino de otros usuarios con filtros opcionales por texto y categoría.
     *
     * @param con               conexión activa
     * @param excludeUsuarioId  ID del usuario origen (excluido)
     * @param q                 texto libre para filtrar por titular o número (puede ser null)
     * @param categoriaId       filtro por categoría (puede ser null)
     * @param limit             máximo de resultados
     * @return lista de {@link CuentaDestinoDTO}
     */
    List<CuentaDestinoDTO> searchDestinos(Connection con, long excludeUsuarioId,
                                          String q, Long categoriaId, int limit) throws SQLException;

    /**
     * Retorna estadísticas agregadas de cuentas para el administrador.
     *
     * @param con conexión activa
     * @return {@link AdminCuentasStatsDTO}
     */
    AdminCuentasStatsDTO getAdminStats(Connection con) throws SQLException;

    /**
     * Retorna las cuentas de los empleados indicados agrupadas por ID de usuario.
     *
     * @param con conexión activa
     * @param ids lista de IDs de usuarios
     * @return mapa {@code usuarioId → lista de CuentaDetalleDTO}
     */
    Map<Long, List<CuentaDetalleDTO>> findCuentasPorEmpleados(Connection con,
                                                               List<Long> ids) throws SQLException;

    /**
     * Bloquea la cuenta con {@code SELECT ... FOR UPDATE} y retorna sus datos de validación.
     * Resultado: {@code [0]=categoriaId(Long), [1]=saldo(BigDecimal), [2]=estado, [3]=usuarioId(Long)}.
     *
     * @param con      conexión activa (debe estar en una transacción abierta)
     * @param cuentaId ID de la cuenta a bloquear
     * @return array de 4 elementos, o {@code null} si la cuenta no existe o está inactiva
     */
    Object[] findForTransferLock(Connection con, long cuentaId) throws SQLException;

    /**
     * Retorna información básica de una cuenta destino para validar una transferencia.
     * Resultado: {@code [0]=categoriaId(Long), [1]=estado, [2]=usuarioId(Long)}.
     *
     * @param con      conexión activa
     * @param cuentaId ID de la cuenta destino
     * @return array de 3 elementos, o {@code null} si la cuenta no existe
     */
    Object[] findDestinoInfo(Connection con, long cuentaId) throws SQLException;

    /**
     * Resuelve el ID numérico de una cuenta a partir de un valor raw (número o ID como texto).
     *
     * @param con conexión activa
     * @param raw número de cuenta o ID en formato texto
     * @return ID de la cuenta, o {@code null} si no se encuentra
     */
    Long resolveCuentaId(Connection con, String raw) throws SQLException;

    /**
     * Retorna el número de cuenta formateado para una ID dada.
     *
     * @param con      conexión activa
     * @param cuentaId ID de la cuenta
     * @return número de cuenta, o {@code null} si no existe
     */
    String findNumeroCuenta(Connection con, long cuentaId) throws SQLException;

    /**
     * Inserta una nueva cuenta activa con saldo cero para el usuario indicado.
     *
     * @param con         conexión activa
     * @param usuarioId   ID del propietario
     * @param categoriaId ID de la categoría de cuenta
     */
    void insert(Connection con, long usuarioId, Long categoriaId) throws SQLException;

    /**
     * Actualiza el estado de una cuenta.
     *
     * @param con      conexión activa
     * @param cuentaId ID de la cuenta
     * @param estado   nuevo estado ({@code "ACTIVA"} o {@code "CONGELADA"})
     */
    void updateEstado(Connection con, long cuentaId, String estado) throws SQLException;

    /**
     * Da de baja lógica una cuenta: la congela y pone su saldo a cero.
     *
     * @param con      conexión activa
     * @param cuentaId ID de la cuenta
     */
    void deactivate(Connection con, long cuentaId) throws SQLException;

    /**
     * Da de baja lógica todas las cuentas activas de un usuario (usado al eliminar empleado).
     *
     * @param con       conexión activa
     * @param usuarioId ID del usuario
     */
    void deactivateByUsuarioId(Connection con, long usuarioId) throws SQLException;
    void reactivateByUsuarioId(Connection con, long usuarioId) throws SQLException;

    /**
     * Retorna las categorías de cuenta activas para el formulario de creación.
     *
     * @param con conexión activa
     * @return lista de {@link CatalogoItemDTO}
     */
    List<CatalogoItemDTO> findCategoriasActivas(Connection con) throws SQLException;

    /**
     * Resuelve el ID de una categoría a partir de un valor raw (nombre o ID como texto).
     *
     * @param con conexión activa
     * @param raw nombre o ID en formato texto
     * @return ID de la categoría, o {@code null} si no se encuentra
     */
    Long resolveCategoriaId(Connection con, String raw) throws SQLException;
}
