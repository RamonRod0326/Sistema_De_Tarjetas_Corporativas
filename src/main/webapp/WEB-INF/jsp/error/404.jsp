<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Página no encontrada</title>
    <style>
        body{margin:0;font-family:system-ui,sans-serif;background:#0a0e17;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;text-align:center;}
        h1{font-size:5rem;margin:0;color:#0ff;font-weight:800;}
        p{color:#8892a4;margin:0.5rem 0 1.5rem;}
        a{color:#0ff;text-decoration:none;border:1px solid rgba(0,255,255,0.3);padding:0.5rem 1.25rem;border-radius:8px;font-size:0.85rem;}
        a:hover{background:rgba(0,255,255,0.07);}
    </style>
</head>
<body>
    <div>
        <h1>404</h1>
        <p style="font-size:1.1rem;color:#ccc;margin-bottom:0.5rem;">Página no encontrada</p>
        <p>El recurso que buscas no existe o fue movido.</p>
        <a href="${pageContext.request.contextPath}/">Volver al inicio</a>
    </div>
</body>
</html>
