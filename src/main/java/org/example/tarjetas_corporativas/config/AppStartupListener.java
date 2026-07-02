package org.example.tarjetas_corporativas.config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Se ejecuta al arrancar la app, antes de cualquier servlet.
 * Si DB_WALLET_PATH no está definida como variable de entorno, detecta
 * automáticamente la carpeta WEB-INF/wallet dentro del WAR desplegado
 * y la registra como propiedad del sistema para que DataSourceProvider la use.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String walletEnv = System.getenv("DB_WALLET_PATH");
        if (walletEnv == null || walletEnv.isBlank()) {
            String walletPath = sce.getServletContext().getRealPath("/WEB-INF/wallet");
            if (walletPath != null) {
                System.setProperty("app.wallet.path", walletPath);
            }
        }
        // Forzar inicialización del pool aquí para detectar errores de conexión en arranque
        try {
            DataSourceProvider.getConnection().close();
        } catch (Exception e) {
            sce.getServletContext().log("ERROR: No se pudo conectar a la BD: " + e.getMessage(), e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) { }
}
