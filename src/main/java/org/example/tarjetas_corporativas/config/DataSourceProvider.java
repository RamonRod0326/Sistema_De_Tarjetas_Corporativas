package org.example.tarjetas_corporativas.config;

import org.apache.commons.dbcp2.BasicDataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Proveedor del pool de conexiones a Oracle ATP.
 * <p>
 * Inicializa un {@link BasicDataSource} (Apache Commons DBCP2) leyendo las
 * credenciales exclusivamente de variables de entorno para evitar hardcodear
 * secretos en el código fuente. Las variables requeridas son:
 * <ul>
 *   <li>{@code DB_WALLET_PATH} — ruta a la carpeta del Oracle Wallet (TNS_ADMIN)</li>
 *   <li>{@code DB_ALIAS}       — alias de TNS de la base de datos</li>
 *   <li>{@code DB_USER}        — usuario de la base de datos</li>
 *   <li>{@code DB_PASSWORD}    — contraseña de la base de datos</li>
 * </ul>
 * La falta de cualquier variable provoca {@link ExceptionInInitializerError} en el
 * arranque de la aplicación, fallando rápido antes de aceptar tráfico.
 * </p>
 * <p>
 * El pool está configurado con {@code autoCommit=false} y {@code rollbackOnReturn=true},
 * por lo que toda conexión devuelta sin commit explícito revierte automáticamente.
 * </p>
 */
public class DataSourceProvider {

    private static final BasicDataSource ds;

    static {
        String walletPath = resolveWalletPath();
        String alias      = requireEnv("DB_ALIAS");
        String user       = requireEnv("DB_USER");
        String password   = requireEnv("DB_PASSWORD");

        System.setProperty("oracle.net.tns_admin", walletPath);

        ds = new BasicDataSource();
        ds.setDriverClassName("oracle.jdbc.OracleDriver");
        ds.setUrl("jdbc:oracle:thin:@" + alias);
        ds.setUsername(user);
        ds.setPassword(password);
        ds.setInitialSize(2);
        ds.setMaxTotal(10);
        ds.setMinIdle(1);
        ds.setMaxIdle(5);
        ds.setDefaultAutoCommit(false);
        ds.setRollbackOnReturn(true);
        ds.setValidationQuery("SELECT 1 FROM DUAL");
        ds.setTestOnBorrow(true);
    }

    /**
     * Obtiene una conexión del pool.
     *
     * @return conexión activa con {@code autoCommit=false}
     * @throws SQLException si el pool está agotado o la base de datos no responde
     */
    public static Connection getConnection() throws SQLException {
        return ds.getConnection();
    }

    /**
     * Resuelve la ruta del wallet con la siguiente prioridad:
     * 1. Variable de entorno DB_WALLET_PATH (override explícito, ideal para nube/producción)
     * 2. Propiedad del sistema app.wallet.path (establecida por AppStartupListener
     *    apuntando a WEB-INF/wallet dentro del WAR desplegado)
     */
    private static String resolveWalletPath() {
        String v = System.getenv("DB_WALLET_PATH");
        if (v != null && !v.isBlank()) return v.trim();
        v = System.getProperty("app.wallet.path");
        if (v != null && !v.isBlank()) return v.trim();
        throw new ExceptionInInitializerError(
            "No se encontró el wallet de Oracle. " +
            "Define la variable de entorno DB_WALLET_PATH " +
            "o coloca los archivos del wallet en src/main/resources/wallet/");
    }

    private static String requireEnv(String name) {
        String v = System.getenv(name);
        if (v == null || v.isBlank())
            throw new ExceptionInInitializerError("Variable de entorno requerida no encontrada: " + name);
        return v.trim();
    }
}
