# Sistema de Tarjetas Corporativas

Aplicación web Java EE para la gestión de tarjetas corporativas, cuentas bancarias
y transferencias entre empleados de una empresa.

## Tecnologías

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Lenguaje | Java | 21 |
| Servidor | Apache Tomcat | 10.1.55 |
| Servlet API | Jakarta Servlet | 6.1 |
| Base de datos | Oracle Autonomous Transaction Processing (ATP) | — |
| Pool de conexiones | Apache Commons DBCP2 | 2.12.0 |
| Seguridad | BCrypt | 0.10.2 (cost 12) |
| Build | Apache Maven | 3.9+ |
| Vistas | JSP + JSTL | 3.0 |
| Email | Jakarta Mail | 2.0.1 |

## Arquitectura

El proyecto sigue el patrón **MVC** con capas adicionales:

```
Servlet (Controller)
    └── Service (Business Logic)
            └── DAO Interface
                    └── DAOImpl (SQL / Oracle)
```

- **Controllers** (`controller/`): Servlets anotados con `@WebServlet`.
- **Filter** (`filter/AuthFilter`): Intercepta `/admin/*` y `/user/*` para autenticación y autorización por rol.
- **Services** (`service/`): Propietarios del ciclo de vida de la conexión y las transacciones.
- **DAOs** (`dao/` + `dao/impl/`): Las interfaces definen el contrato; las implementaciones contienen el SQL Oracle.
- **DTOs** (`dto/`): Objetos de transferencia tipados para las vistas.
- **Config** (`config/`): `DataSourceProvider` (pool DBCP2) y `AppStartupListener` (arranque).

## Estructura de directorios

```
src/
├── main/
│   ├── java/org/example/tarjetas_corporativas/
│   │   ├── config/          # DataSourceProvider (pool Oracle) + AppStartupListener
│   │   ├── controller/      # Servlets HTTP (admin y user)
│   │   ├── dao/             # Interfaces DAO
│   │   │   └── impl/        # Implementaciones SQL Oracle
│   │   ├── dto/             # Objetos de transferencia de datos
│   │   ├── exception/       # ServiceException con toastKey
│   │   ├── filter/          # AuthFilter (autenticación y autorización)
│   │   ├── service/         # Lógica de negocio
│   │   └── util/            # PasswordUtil (BCrypt), PageUtil (paginación)
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── jsp/         # Vistas JSP
│       │   │   ├── admin/   # Vistas del administrador
│       │   │   ├── user/    # Vistas del empleado
│       │   │   ├── components/ # Header, sidebars, modales
│       │   │   └── error/   # Páginas 404 y 500
│       │   ├── wallet/      # Oracle Wallet (tnsnames.ora, cwallet.sso, etc.)
│       │   └── web.xml
│       ├── css/styles.css
│       └── js/app.js
db/
├── schema.sql               # DDL completo: tablas, secuencias, triggers
├── migration_v3.sql         # Datos iniciales + tabla RESET_CODIGOS
├── migration_v4_indices.sql # Índices de rendimiento
└── migration_v5_tarjetas_fix.sql  # Elimina restricción única de modalidad
docs/
├── DOCUMENTACION_TECNICA.md
├── GUIA_INSTALACION.md
└── MANUAL_USUARIO.md
```

## Variables de entorno

### Base de datos (requeridas)

| Variable | Descripción |
|----------|-------------|
| `DB_ALIAS` | Alias de conexión TNS (ej. `mibd_high`) |
| `DB_USER` | Usuario de la base de datos |
| `DB_PASSWORD` | Contraseña del usuario |
| `DB_WALLET_PATH` | Ruta al Oracle Wallet — **opcional** si el wallet está en `WEB-INF/wallet/` |

> Si `DB_WALLET_PATH` no está definida, `AppStartupListener` detecta automáticamente la carpeta
> `WEB-INF/wallet/` dentro del WAR desplegado y la registra como TNS_ADMIN.

### Correo electrónico (opcionales — para recuperación de contraseña)

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `MAIL_HOST` | Servidor SMTP | `smtp.gmail.com` |
| `MAIL_PORT` | Puerto SMTP | `587` |
| `MAIL_USER` | Usuario SMTP | `correo@empresa.com` |
| `MAIL_PASSWORD` | Contraseña SMTP | — |
| `MAIL_FROM` | Remitente (opcional, por defecto = `MAIL_USER`) | `noreply@empresa.com` |

> Si las variables de correo no están configuradas, el flujo de recuperación de contraseña
> registra el código en el log de Tomcat pero no envía email.

## Compilar y desplegar

```bash
# 1. Compilar y empaquetar
mvn clean package

# 2. Copiar el WAR al directorio webapps de Tomcat
cp target/Tarjetas_Corporativas-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/ROOT.war

# 3. Arrancar Tomcat (con las variables de entorno ya configuradas)
$CATALINA_HOME/bin/startup.sh
```

## Roles del sistema

| Rol | Acceso |
|-----|--------|
| `admin` | `/admin/*` — gestión completa de empleados, cuentas, tarjetas, fondos y catálogos |
| `empleado` | `/user/*` — consulta de cuentas propias, transferencias y tarjetas |

## Seguridad

- Contraseñas hasheadas con **BCrypt cost 12** — nunca se almacena texto plano.
- Recuperación de contraseña mediante código de 6 dígitos enviado por email (expira en 15 min, máximo 3 intentos).
- `AuthFilter` redirige a `/login` si no hay sesión activa, y evita que empleados accedan a rutas de administrador y viceversa.
- Credenciales de BD exclusivamente por variables de entorno — sin hardcoding.
- JSTL `fn:escapeXml` en todas las vistas para prevenir XSS.
- Oracle ATP con `autoCommit=false` y `rollbackOnReturn=true`; cada escritura requiere `con.commit()` explícito.

## Base de datos

El schema DDL completo se encuentra en [`db/schema.sql`](db/schema.sql).
Los triggers Oracle gestionan automáticamente las actualizaciones de saldo tras cada
movimiento. Los scripts de migración deben ejecutarse en orden numérico.

## Documentación adicional

- [Documentación Técnica](docs/DOCUMENTACION_TECNICA.md)
- [Manual de Usuario](docs/MANUAL_USUARIO.docx) *(documento Word con capturas reales del sistema)*
- [Guía de Instalación](docs/GUIA_INSTALACION.md)
