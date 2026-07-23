package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.TarjetaAdminDTO;
import org.example.tarjetas_corporativas.dto.TarjetaUserDTO;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Contrato de acceso a datos para la entidad {@code TARJETAS}.
 */
public interface TarjetaDAO {

    List<TarjetaAdminDTO> findAllActive(Connection con) throws SQLException;

    List<TarjetaAdminDTO> findAdminPaged(Connection con, String estado, String modalidad,
                                         int offset, int limit) throws SQLException;
    long countAdmin(Connection con, String estado, String modalidad) throws SQLException;

    List<TarjetaUserDTO> findByUsuarioId(Connection con, long usuarioId) throws SQLException;

    List<TarjetaUserDTO> findByUsuarioIdPaged(Connection con, long usuarioId, String estado,
                                              int offset, int limit) throws SQLException;
    long countByUsuarioId(Connection con, long usuarioId, String estado) throws SQLException;

    /**
     * Inserta una nueva tarjeta. El número de 16 dígitos es generado automáticamente
     * por el trigger {@code TRG_TARJETAS_BI} en la base de datos.
     */
    void insert(Connection con, long cuentaId, String modalidad) throws SQLException;

    void updateEstado(Connection con, long id, String estado) throws SQLException;

    void deactivate(Connection con, long id) throws SQLException;

    void deactivateByUsuarioId(Connection con, long usuarioId) throws SQLException;
    void reactivateByUsuarioId(Connection con, long usuarioId) throws SQLException;
}
