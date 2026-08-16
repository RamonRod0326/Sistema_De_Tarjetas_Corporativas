# Documentación Técnica — Sistema de Tarjetas Corporativas

## 1. Descripción general

El Sistema de Tarjetas Corporativas es una aplicación web Java EE que permite a una
empresa gestionar cuentas bancarias corporativas, tarjetas de acceso y transferencias
entre empleados. Existen dos roles: **administrador** (gestión completa) y **empleado**
(consulta y operaciones propias).

---

## 2. Stack tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Lenguaje | Java | 21 |
| API Servlet | Jakarta Servlet | 6.1 |
| Servidor de aplicaciones | Apache Tomcat | 10.1.55 |
| Base de datos | Oracle Autonomous Transaction Processing (ATP) | — |
| Pool de conexiones | Apache Commons DBCP2 | 2.12.0 |
| Hash de contraseñas | at.favre.lib:bcrypt | 0.10.2 |
| Build | Apache Maven | 3.9+ |
| Vistas | JSP + JSTL | 3.0 |
| Driver JDBC | ojdbc11 | 21.13.0.0 |
| PKI / Wallet | oraclepki, osdt_cert, osdt_core | 21.13.0.0 |
| Email | Jakarta Mail (com.sun.mail) | 2.0.1 |

---

## 3. Arquitectura

El proyecto implementa el patrón **MVC** con capas adicionales de servicio y DAO:

```
Navegador (HTML/JSP)
    │  HTTP GET / POST
    ▼
AuthFilter                        ← intercepta /admin/* y /user/*, verifica sesión y rol
    │
    ▼
Servlet (Controller)              ← recibe la petición, valida params, redirige
    │
    ▼
Service (Business Logic)          ← abre conexión, orquesta transacción, lanza ServiceException
    │
    ▼
DAO Interface → DAOImpl (SQL)     ← PreparedStatement, ResultSet → DTOs
    │
    ▼
Oracle ATP (Base de datos)
```

### Arranque de la aplicación

`AppStartupListener` (`@WebListener`) se ejecuta antes que cualquier servlet:

1. Si `DB_WALLET_PATH` no está definida como variable de entorno, detecta automáticamente
   la carpeta `WEB-INF/wallet/` dentro del WAR desplegado y la registra como
   `System.setProperty("app.wallet.path", ...)`.
2. Fuerza la inicialización del pool de conexiones al arranque, para detectar errores de
   configuración inmediatamente en lugar de en la primera petición.

### Flujo de transacción (escrituras)

1. El Service obtiene una conexión del pool (`DataSourceProvider.getConnection()`).
2. El pool entrega la conexión con `autoCommit = false`.
3. El Service llama a uno o varios DAOs dentro del mismo `try`.
4. Si todo termina sin excepción, ejecuta `con.commit()`.
5. Si ocurre cualquier error, lanza `ServiceException`; el pool hace `rollback` automático
   al devolver la conexión (`rollbackOnReturn = true`).

---

## 4. Estructura de paquetes

```
org.example.tarjetas_corporativas/
├── config/
│   ├── DataSourceProvider.java        # Pool DBCP2; wallet auto-detectado si no hay env var
│   └── AppStartupListener.java        # Listener de arranque: detecta wallet, precalienta pool
├── controller/
│   ├── LoginServlet.java              # POST /login — autenticación
│   ├── LogoutServlet.java             # GET /logout — cierre de sesión
│   ├── RecuperarServlet.java          # Recuperación de contraseña (3 pasos por email)
│   ├── InicioExitosoServlet.java      # Redirige al dashboard según rol tras login
│   ├── InicioFallidoServlet.java      # Maneja intentos de login fallidos
│   │
│   ├── AdminDashboardServlet.java     # GET /admin/dashboard
│   ├── AdminEmpleadosServlet.java     # GET /admin/empleados — lista y baja
│   ├── EmpleadoFormServlet.java       # GET/POST /admin/empleados/form — crear/editar
│   ├── AdminCuentasServlet.java       # GET /admin/cuentas — lista y acciones
│   ├── CuentaFormServlet.java         # GET/POST /admin/cuentas/nueva — crear cuenta
│   ├── AdminTarjetasServlet.java      # GET /admin/tarjetas — lista y acciones
│   ├── TarjetaFormServlet.java        # GET/POST /admin/tarjetas/nueva — emitir tarjeta
│   ├── AdminFondosServlet.java        # GET/POST /admin/fondos — depositar y asignar
│   ├── AdminConfigServlet.java        # GET/POST /admin/config — catálogos y perfil admin
│   │
│   ├── ApiCargosServlet.java          # GET /api/cargos — JSON para selects dinámicos
│   ├── ApiCategoriasServlet.java      # GET /api/categorias — JSON para selects dinámicos
│   ├── ApiDepartamentosServlet.java   # GET /api/departamentos — JSON para selects dinámicos
│   ├── ApiEmpleadosServlet.java       # GET /api/empleados — JSON para selects dinámicos
│   ├── ApiDestinosServlet.java        # GET /api/destinos — JSON cuentas destino para transferencia
│   │
│   ├── UserDashboardServlet.java      # GET /user/dashboard
│   ├── UserCuentasServlet.java        # GET /user/cuentas — cuentas del empleado
│   ├── UserTarjetasServlet.java       # GET /user/tarjetas — tarjetas del empleado
│   ├── UserTransferenciasServlet.java # GET/POST /user/transferencias — historial y envío
│   └── UserConfigServlet.java         # GET/POST /user/config — perfil y cambio de contraseña
├── dao/
│   ├── CatalogoDAO.java               # Interface: departamentos, cargos, categorías
│   ├── CuentaDAO.java                 # Interface: cuentas corporativas
│   ├── CuentaGlobalDAO.java           # Interface: cuenta corporativa central
│   ├── MovimientoDAO.java             # Interface: transferencias y movimientos
│   ├── TarjetaDAO.java                # Interface: tarjetas
│   ├── UsuarioDAO.java                # Interface: usuarios y empleados
│   └── impl/                          # Implementaciones SQL Oracle (PreparedStatement)
├── dto/
│   ├── PageResult.java                # Wrapper genérico para paginación server-side
│   ├── AdminDashboardStatsDTO.java
│   ├── AdminCuentasStatsDTO.java
│   ├── CatalogoItemDTO.java
│   ├── CuentaDestinoDTO.java
│   ├── CuentaDetalleDTO.java
│   ├── CuentaUserDTO.java
│   ├── EmpleadoCuentaRowDTO.java
│   ├── EmpleadoFormDTO.java
│   ├── EmpleadoRecenteDTO.java
│   ├── EmpleadoRowDTO.java
│   ├── EmpleadoStatsDTO.java
│   ├── MovimientoDashboardDTO.java
│   ├── MovimientoDetalleDTO.java
│   ├── MovimientoGlobalDTO.java
│   ├── PerfilDTO.java
│   ├── TarjetaAdminDTO.java
│   ├── TarjetaUserDTO.java
│   ├── TransferenciaHistorialDTO.java
│   └── TransferenciaStatsDTO.java
├── exception/
│   └── ServiceException.java          # Excepción de negocio con toastKey opcional
├── filter/
│   └── AuthFilter.java                # Interceptor de autenticación y autorización por rol
├── service/
│   ├── AuthService.java               # Login, logout, recuperación de contraseña
│   ├── EmailService.java              # Envío de correos SMTP (código de recuperación)
│   ├── EmpleadoService.java           # Alta, edición, baja de empleados
│   ├── CuentaService.java             # Gestión de cuentas corporativas
│   ├── TarjetaService.java            # Gestión de tarjetas
│   ├── FondosService.java             # Depósitos y asignación de fondos
│   ├── TransferenciaService.java      # Transferencias entre cuentas de empleados
│   ├── CatalogoService.java           # CRUD catálogos (dept, cargos, categorías)
│   ├── ConfigService.java             # Perfil y cambio de contraseña
│   ├── DashboardAdminService.java     # Estadísticas del dashboard administrador
│   └── DashboardUserService.java      # Estadísticas del dashboard empleado
└── util/
    ├── PasswordUtil.java              # Wrapper BCrypt: hash() y verify()
    └── PageUtil.java                  # Parseo y validación de parámetros de paginación
```

---

## 5. Base de datos

### 5.1 Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `USUARIOS` | Todos los usuarios del sistema. Campos: `nombre`, `apellido_paterno`, `apellido_materno`, `email`, `password_hash` (BCrypt), `rol` ('admin'/'empleado'), `activo`. |
| `EMPLEADOS` | Datos laborales: departamento, cargo, número de empleado. Enlazada 1:1 con USUARIOS. |
| `DEPARTAMENTOS` | Catálogo de departamentos (soft delete con campo `activo`). |
| `CARGOS` | Catálogo de cargos (soft delete). |
| `CATEGORIAS_CUENTA` | Tipos de cuenta con nombre y límite mensual. Soft delete. |
| `CUENTAS` | Cuentas corporativas de los empleados. Tiene `saldo` propio. Enlazada a USUARIOS y CATEGORIAS_CUENTA. Estados: activa / congelada. |
| `TARJETAS` | Instrumentos de acceso asociados a una CUENTA. Modalidad: VIRTUAL o FISICA. **No tienen saldo propio.** Estados: activa / bloqueada / cancelada. |
| `MOVIMIENTOS` | Transferencias entre cuentas. Enlaza cuenta origen y cuenta destino con monto y concepto. |
| `CUENTA_GLOBAL` | Cuenta corporativa central (una sola fila, id=1). Fuente de los fondos asignados a empleados. |
| `CG_MOVIMIENTOS` | Historial de depósitos y asignaciones de la cuenta global. |
| `RESET_CODIGOS` | Códigos de recuperación de contraseña. Campos: `email`, `codigo` (6 dígitos), `expira_en` (15 min), `usado`, `intentos` (máx 3). |
| `AUDITORIA` | Registro de auditoría de operaciones relevantes del sistema. |

### 5.2 Regla fundamental de saldo

> **El saldo pertenece exclusivamente a CUENTAS.** Las tarjetas son instrumentos de acceso,
> no tienen saldo. Una cuenta puede tener múltiples tarjetas (FISICA y/o VIRTUAL).

El trigger `TRG_MOV_ACTUALIZAR_SALDOS` actualiza automáticamente `CUENTAS.saldo` tras
cada `INSERT` en `MOVIMIENTOS`, descontando de la cuenta origen y acreditando en la destino.

### 5.3 Scripts DDL

Deben ejecutarse en el siguiente orden:

| Archivo | Contenido |
|---------|-----------|
| `db/schema.sql` | DDL completo: tablas, secuencias, triggers, restricciones |
| `db/migration_v3.sql` | Datos iniciales de catálogos, cuenta global y tabla `RESET_CODIGOS` |
| `db/migration_v4_indices.sql` | Índices de rendimiento para búsqueda y paginación |
| `db/migration_v5_tarjetas_fix.sql` | Elimina restricción `UNIQUE(cuenta_id, modalidad)` para permitir múltiples tarjetas del mismo tipo |

---

## 6. Seguridad

| Mecanismo | Implementación |
|-----------|---------------|
| Hash de contraseñas | BCrypt cost 12 (`PasswordUtil.hash()`, `PasswordUtil.verify()`) |
| Autenticación por sesión | `HttpSession` con atributos `usuarioId`, `usuario`, `rol` |
| Autorización por rol | `AuthFilter` — redirige a `/login` si no hay sesión; redirige al dashboard propio si el rol no coincide con la ruta |
| Recuperación de contraseña | Código de 6 dígitos enviado por email, expira 15 min, máx 3 intentos; almacenado en `RESET_CODIGOS` |
| Prevención XSS | `fn:escapeXml()` en todas las vistas JSP |
| Credenciales de BD | Exclusivamente por variables de entorno — sin hardcoding |
| Credenciales SMTP | Variables de entorno opcionales; si no están definidas, el código se registra solo en el log |
| Transacciones | `autoCommit=false`, `rollbackOnReturn=true` en DBCP2 |

---

## 7. Módulos CRUD implementados

### 7.1 Catálogos (Configuración)

**Departamentos, Cargos, Categorías de cuenta**

- Servlet: `AdminConfigServlet` (`/admin/config`)
- Vista: `admin/configuracion.jsp`
- Operaciones: Crear, Listar (paginado), Editar nombre (modal JS inline), Dar de baja (soft delete)
- Los modales de edición se abren con JS sin recargar la página; al confirmar hacen `form.submit()` y la respuesta es un redirect con `?toast=` para la notificación.

### 7.2 Empleados

**USUARIOS + EMPLEADOS + DEPARTAMENTOS + CARGOS**

- Servlets: `AdminEmpleadosServlet` (lista/baja), `EmpleadoFormServlet` (crear/editar)
- Vistas: `admin/empleados.jsp`, `admin/empleado-form.jsp`
- Al dar de baja: devuelve fondos a cuenta global, bloquea todas las tarjetas activas del empleado y congela sus cuentas.

### 7.3 Cuentas

**CUENTAS + USUARIOS + CATEGORIAS_CUENTA**

- Servlets: `AdminCuentasServlet` (lista/acciones), `CuentaFormServlet` (crear)
- Vistas: `admin/cuentas.jsp` (con drawer JS lateral), `admin/cuenta-form.jsp`
- Acciones: congelar, descongelar, eliminar (congela y pone saldo a cero con devolución a cuenta global).
- La vista de cuentas muestra la tabla de empleados; al hacer clic en uno, JS construye un panel lateral con sus cuentas usando datos pre-inyectados desde el JSP.

### 7.4 Tarjetas

**TARJETAS + CUENTAS + USUARIOS**

- Servlets: `AdminTarjetasServlet`, `TarjetaFormServlet`
- Vistas: `admin/tarjetas.jsp`, `admin/tarjeta-form.jsp`
- Modalidades: VIRTUAL, FISICA. Estados: activa, bloqueada, cancelada.
- Acciones: bloquear, desbloquear, cancelar (baja definitiva con confirmación).

### 7.5 Fondos

**CUENTA_GLOBAL + CG_MOVIMIENTOS**

- Servlet: `AdminFondosServlet` (`/admin/fondos`)
- Vista: `admin/fondos.jsp` (en construcción en la vista, lógica implementada)
- Operaciones: depositar monto a la cuenta global corporativa; asignar fondos de la cuenta global a la cuenta de un empleado.

### 7.6 Panel del empleado

- **Dashboard** (`/user/dashboard`): saldo total consolidado, resumen de cuentas, últimos movimientos.
- **Cuentas** (`/user/cuentas`): detalle de cada cuenta con historial de movimientos paginado.
- **Transferencias** (`/user/transferencias`): envío de transferencias y estadísticas mensuales (enviado/recibido/neto).
- **Tarjetas** (`/user/tarjetas`): tarjetas activas con número enmascarado, modalidad, estado y límite.
- **Configuración** (`/user/config`): editar nombre y cambiar contraseña.

---

## 8. APIs internas (JSON)

Los servlets de API responden en JSON y son consumidos por el frontend JavaScript:

| Ruta | Servlet | Descripción |
|------|---------|-------------|
| `/api/departamentos` | `ApiDepartamentosServlet` | Lista de departamentos activos |
| `/api/cargos` | `ApiCargosServlet` | Lista de cargos activos |
| `/api/categorias` | `ApiCategoriasServlet` | Lista de categorías de cuenta activas |
| `/api/empleados` | `ApiEmpleadosServlet` | Lista de empleados para selects |
| `/api/destinos` | `ApiDestinosServlet` | Cuentas destino disponibles para transferencia |

---

## 9. Paginación

Todos los módulos de lista usan paginación server-side con Oracle:

```sql
ORDER BY columna OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
```

- `PageResult<T>` — DTO genérico que envuelve la lista de items y los metadatos
  (página actual, total de registros, total de páginas, helpers `isFirst()`, `isLast()`).
- `PageUtil` — parsea y valida los parámetros `page` y `pageSize` de la petición HTTP.

---

## 10. Manejo de errores

- `ServiceException` — excepción de negocio con un campo `toastKey` opcional (ej. `"saldo_insuficiente"`)
  que los servlets usan para redirigir con `?toast=<key>` y mostrar el mensaje correcto.
- `AuthFilter` — cualquier ruta protegida sin sesión válida redirige a `/login`.
- Páginas de error personalizadas: `WEB-INF/jsp/error/404.jsp`, `WEB-INF/jsp/error/500.jsp`.
- Los toasts (notificaciones emergentes) se muestran en esquina superior derecha:
  verde = éxito, rojo = error, amarillo = advertencia.

---

## 11. Variables de entorno requeridas

### Base de datos

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `DB_ALIAS` | Alias TNS de la base de datos | `mibasededatos_high` |
| `DB_USER` | Usuario Oracle | `ADMIN` |
| `DB_PASSWORD` | Contraseña Oracle | — |
| `DB_WALLET_PATH` | Ruta al Oracle Wallet (**opcional** si el wallet está en `WEB-INF/wallet/`) | `C:\oracle\wallet` |

### Correo electrónico (opcionales)

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `MAIL_HOST` | Servidor SMTP | `smtp.gmail.com` |
| `MAIL_PORT` | Puerto SMTP | `587` |
| `MAIL_USER` | Cuenta de correo | `noreply@empresa.com` |
| `MAIL_PASSWORD` | Contraseña de la cuenta | — |
| `MAIL_FROM` | Remitente mostrado (opcional) | `Sistema Corporativo <noreply@empresa.com>` |

Se configuran en `%CATALINA_HOME%\bin\setenv.bat` (Windows) o
`$CATALINA_HOME/bin/setenv.sh` (Linux/Mac) antes de iniciar Tomcat.
