package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.UsuarioDAO;
import org.example.tarjetas_corporativas.dao.impl.UsuarioDAOImpl;
import org.example.tarjetas_corporativas.dto.PerfilDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PasswordUtil;
import java.sql.*;

/**
 * Servicio de negocio para la configuración del perfil de usuario.
 * <p>
 * Permite a los empleados consultar sus datos de perfil, actualizar su nombre
 * y cambiar su contraseña con verificación del hash BCrypt actual.
 * </p>
 */
public class ConfigService {

    private final UsuarioDAO usuarioDAO;

    /** Construye el servicio inicializando la implementación DAO. */
    public ConfigService() {
        this.usuarioDAO = new UsuarioDAOImpl();
    }

    /**
     * Retorna los datos de perfil del usuario (nombre, email, cargo, departamento).
     *
     * @param usuarioId ID del usuario
     * @return {@link PerfilDTO} con la información del perfil
     * @throws ServiceException si ocurre un error de base de datos
     */
    public PerfilDTO getPerfil(long usuarioId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return usuarioDAO.findPerfil(con, usuarioId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar perfil", e);
        }
    }

    /**
     * Actualiza el nombre visible del usuario.
     *
     * @param usuarioId ID del usuario
     * @param nombre    nuevo nombre (se aplica trim antes de persistir)
     * @throws ServiceException si ocurre un error de base de datos
     */
    public void actualizarNombre(long usuarioId, String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            usuarioDAO.updateNombre(con, usuarioId, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar nombre", e);
        }
    }

    /**
     * Cambia la contraseña del usuario previa verificación del hash BCrypt.
     *
     * @param usuarioId ID del usuario
     * @param actual    contraseña actual en texto plano para verificación
     * @param nueva     nueva contraseña en texto plano (se hashea antes de persistir)
     * @return {@code true} si el cambio fue exitoso; {@code false} si la contraseña actual no coincide
     * @throws ServiceException si ocurre un error de base de datos
     */
    public boolean cambiarPassword(long usuarioId, String actual, String nueva) {
        try (Connection con = DataSourceProvider.getConnection()) {
            String hash = usuarioDAO.findPasswordHash(con, usuarioId);
            if (hash == null || !PasswordUtil.verify(actual, hash)) return false;
            usuarioDAO.updatePasswordHash(con, usuarioId, PasswordUtil.hash(nueva));
            con.commit();
            return true;
        } catch (SQLException e) {
            throw new ServiceException("Error al cambiar contraseña", e);
        }
    }
}
