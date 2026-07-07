package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.UsuarioDAO;
import org.example.tarjetas_corporativas.dao.impl.UsuarioDAOImpl;
import org.example.tarjetas_corporativas.exception.ServiceException;
import org.example.tarjetas_corporativas.util.PasswordUtil;
import java.sql.*;
import java.util.Random;
import java.util.logging.Logger;

/**
 * Servicio de autenticación y recuperación de contraseña.
 * <p>
 * Gestiona el inicio de sesión y el flujo de 3 pasos para restablecer contraseñas:
 * solicitud de código por email → verificación → nueva contraseña.
 * </p>
 */
public class AuthService {

    private static final Logger LOG = Logger.getLogger(AuthService.class.getName());

    private final UsuarioDAO  usuarioDAO;
    private final EmailService emailService;

    public AuthService() {
        this.usuarioDAO   = new UsuarioDAOImpl();
        this.emailService = new EmailService();
    }

    /**
     * Autentica a un usuario con su correo y contraseña.
     *
     * @return arreglo {@code [id, nombre, passwordHash, rol, cargo, departamento]} o {@code null}
     */
    public Object[] login(String email, String password) {
        try (Connection con = DataSourceProvider.getConnection()) {
            Object[] row = usuarioDAO.findByEmailForAuth(con, email.trim().toLowerCase());
            if (row == null) return null;
            if (!PasswordUtil.verify(password, (String) row[2])) return null;
            return row;
        } catch (SQLException e) {
            throw new ServiceException("Error de base de datos durante el login", e);
        }
    }

    /**
     * Verifica si existe una cuenta activa para el correo indicado.
     */
    public boolean existeEmail(String email) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return usuarioDAO.findByEmailForAuth(con, email.trim().toLowerCase()) != null;
        } catch (SQLException e) {
            throw new ServiceException("Error al verificar correo", e);
        }
    }

    /**
     * Genera un código de 6 dígitos, lo persiste en {@code RESET_CODIGOS} con expiración
     * de 15 minutos y lo envía al correo del usuario.
     *
     * @param email correo del usuario
     * @throws ServiceException si el correo no existe o el envío falla
     */
    public void generarCodigoReset(String email) {
        String emailNorm = email.trim().toLowerCase();
        try (Connection con = DataSourceProvider.getConnection()) {
            // Validar que el email existe
            if (usuarioDAO.findByEmailForAuth(con, emailNorm) == null) {
                throw new ServiceException("Correo no registrado", "recuperar_email_error");
            }
            // Oracle ATP tiene parallel DML habilitado por defecto; deshabilitarlo
            // para esta sesión evita ORA-12838 al hacer UPDATE + INSERT en la misma transacción
            try (Statement st = con.createStatement()) {
                st.execute("ALTER SESSION DISABLE PARALLEL DML");
            }
            // Invalidar códigos previos activos para ese email
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE RESET_CODIGOS SET usado = 1 WHERE email = ? AND usado = 0")) {
                ps.setString(1, emailNorm);
                ps.executeUpdate();
            }
            // Generar código
            String codigo = String.format("%06d", new Random().nextInt(1_000_000));
            // Persistir — se usa NEXTVAL directamente para no depender del trigger
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO RESET_CODIGOS (id, email, codigo, expira_en) " +
                    "VALUES (SEQ_RESET_CODIGOS.NEXTVAL, ?, ?, SYSTIMESTAMP + INTERVAL '15' MINUTE)")) {
                ps.setString(1, emailNorm);
                ps.setString(2, codigo);
                ps.executeUpdate();
            }
            con.commit();
            // Enviar por email
            try {
                emailService.enviarCodigoReset(emailNorm, codigo);
            } catch (Exception e) {
                // Error de envío no revierte la operación (código ya guardado)
                throw new ServiceException("No se pudo enviar el correo. Verifica tu dirección.", "mail_error");
            }
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("[generarCodigoReset] SQLException — código: " + e.getErrorCode() +
                       " | estado: " + e.getSQLState() + " | mensaje: " + e.getMessage());
            throw new ServiceException("Error al generar código de recuperación", e);
        }
    }

    /**
     * Verifica si el código ingresado es válido para el email dado.
     * Incrementa el contador de intentos fallidos; bloquea tras 3 intentos.
     *
     * @return {@code true} si el código es correcto y no ha expirado
     * @throws ServiceException con clave de toast si el código expiró, ya fue usado o se superaron los intentos
     */
    public boolean verificarCodigo(String email, String codigo) {
        String emailNorm = email.trim().toLowerCase();
        try (Connection con = DataSourceProvider.getConnection()) {
            try (Statement st = con.createStatement()) {
                st.execute("ALTER SESSION DISABLE PARALLEL DML");
            }
            // Buscar código activo más reciente
            long codigoId = -1;
            int  intentos = 0;
            boolean correcto = false;
            String sql =
                "SELECT id, codigo, intentos FROM RESET_CODIGOS " +
                "WHERE email = ? AND usado = 0 AND expira_en > SYSTIMESTAMP " +
                "ORDER BY fecha DESC FETCH FIRST 1 ROWS ONLY";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, emailNorm);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new ServiceException("El código expiró. Solicita uno nuevo.", "codigo_expirado");
                    }
                    codigoId = rs.getLong("id");
                    intentos = rs.getInt("intentos");
                    correcto = codigo.equals(rs.getString("codigo"));
                }
            }
            if (intentos >= 3) {
                // Marcar como usado para forzar reenvío
                invalida(con, codigoId);
                con.commit();
                throw new ServiceException("Demasiados intentos. Solicita un nuevo código.", "codigo_max_intentos");
            }
            if (!correcto) {
                // Incrementar intentos
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE RESET_CODIGOS SET intentos = intentos + 1 WHERE id = ?")) {
                    ps.setLong(1, codigoId);
                    ps.executeUpdate();
                }
                con.commit();
                return false;
            }
            // Código correcto — no lo marcamos usado aún (se hará al cambiar contraseña)
            return true;
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error al verificar código", e);
        }
    }

    /**
     * Restablece la contraseña y marca el código de reset como usado.
     *
     * @param email       correo del usuario
     * @param newPassword nueva contraseña en texto plano (mínimo 8 caracteres)
     */
    public void resetPassword(String email, String newPassword) {
        String emailNorm = email.trim().toLowerCase();
        try (Connection con = DataSourceProvider.getConnection()) {
            try (Statement st = con.createStatement()) {
                st.execute("ALTER SESSION DISABLE PARALLEL DML");
            }
            Object[] row = usuarioDAO.findByEmailForAuth(con, emailNorm);
            if (row == null) throw new ServiceException("Correo no encontrado", "recuperar_email_error");
            long id = (Long) row[0];
            usuarioDAO.updatePasswordHash(con, id, PasswordUtil.hash(newPassword));
            // Marcar todos los códigos activos como usados
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE RESET_CODIGOS SET usado = 1 WHERE email = ? AND usado = 0")) {
                ps.setString(1, emailNorm);
                ps.executeUpdate();
            }
            con.commit();
        } catch (ServiceException e) {
            throw e;
        } catch (SQLException e) {
            throw new ServiceException("Error al restablecer contraseña", e);
        }
    }

    private void invalida(Connection con, long codigoId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE RESET_CODIGOS SET usado = 1 WHERE id = ?")) {
            ps.setLong(1, codigoId);
            ps.executeUpdate();
        }
    }
}
