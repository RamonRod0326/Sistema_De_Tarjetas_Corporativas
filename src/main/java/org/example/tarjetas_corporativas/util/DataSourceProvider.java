package org.example.tarjetas_corporativas.util;

import org.apache.commons.dbcp2.BasicDataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DataSourceProvider {

    private static final BasicDataSource ds;

    static {
        // Credenciales tomadas de variables de entorno configuradas en Tomcat
        // (Run/Debug Configuration → Startup/Connection → Environment Variables)
        // Nombres: DB_WALLET_PATH, DB_ALIAS, DB_USER, DB_PASSWORD
        String walletPath = requireEnv("DB_WALLET_PATH");
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
        ds.setDefaultAutoCommit(false);   // todas las conexiones arrancan con autoCommit=false
        ds.setRollbackOnReturn(true);      // al devolver al pool, deshace cualquier tx pendiente
        ds.setValidationQuery("SELECT 1 FROM DUAL");
        ds.setTestOnBorrow(true);
    }

    public static Connection getConnection() throws SQLException {
        return ds.getConnection();
    }

    private static String requireEnv(String name) {
        String v = System.getenv(name);
        if (v == null || v.isBlank())
            throw new ExceptionInInitializerError(
                "Variable de entorno requerida no encontrada: " + name);
        return v.trim();
    }
}
