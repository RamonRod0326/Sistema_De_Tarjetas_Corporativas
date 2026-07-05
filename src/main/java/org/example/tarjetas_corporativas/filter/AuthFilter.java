package org.example.tarjetas_corporativas.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filtro de autenticación y autorización para las rutas protegidas.
 * <p>
 * Intercepta todas las peticiones bajo {@code /admin/*} y {@code /user/*}:
 * <ul>
 *   <li>Si no hay sesión activa con atributo {@code usuario}, redirige a {@code /login}.</li>
 *   <li>Si un empleado intenta acceder a {@code /admin/*}, redirige a {@code /user/dashboard}.</li>
 *   <li>Si un administrador intenta acceder a {@code /user/*}, redirige a {@code /admin/dashboard}.</li>
 * </ul>
 * </p>
 */
@WebFilter(filterName = "authFilter", urlPatterns = {"/admin/*", "/user/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession         session  = request.getSession(false);
        String              ctx      = request.getContextPath();
        String              uri      = request.getRequestURI();

        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        String  rol       = (String) session.getAttribute("rol");
        boolean adminPath = uri.startsWith(ctx + "/admin/");
        boolean userPath  = uri.startsWith(ctx + "/user/");

        if (adminPath && !"admin".equals(rol)) {
            response.sendRedirect(ctx + "/user/dashboard");
            return;
        }
        if (userPath && "admin".equals(rol)) {
            response.sendRedirect(ctx + "/admin/dashboard");
            return;
        }

        chain.doFilter(req, res);
    }
}
