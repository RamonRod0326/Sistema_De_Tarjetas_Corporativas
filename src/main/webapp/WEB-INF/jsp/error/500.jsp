<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error del servidor</title>
    <style>
        body{margin:0;font-family:system-ui,sans-serif;background:#0a0e17;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;text-align:center;}
        h1{font-size:5rem;margin:0;color:#ff5252;font-weight:800;}
        p{color:#8892a4;margin:0.5rem 0 1.5rem;}
        a{color:#0ff;text-decoration:none;border:1px solid rgba(0,255,255,0.3);padding:0.5rem 1.25rem;border-radius:8px;font-size:0.85rem;}
        a:hover{background:rgba(0,255,255,0.07);}
        pre{background:#111827;border:1px solid rgba(255,82,82,0.2);border-radius:8px;padding:1rem;color:#ff5252;font-size:0.75rem;text-align:left;max-width:600px;overflow:auto;}
    </style>
</head>
<body>
    <div>
        <h1>500</h1>
        <p style="font-size:1.1rem;color:#ccc;margin-bottom:0.5rem;">Error interno del servidor</p>
        <p>Ocurrió un error inesperado. Revisa los logs de Tomcat para más detalles.</p>
        <% if (exception != null) { %>
        <pre><%= exception.getClass().getName() + ": " + exception.getMessage() %></pre>
        <% } %>
        <a href="${pageContext.request.contextPath}/">Volver al inicio</a>
    </div>
</body>
</html>
