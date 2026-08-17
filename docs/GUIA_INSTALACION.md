# Guía de Instalación — Sistema de Tarjetas Corporativas

Esta guía está dirigida a quien necesita poner en marcha el sistema por primera vez
en un entorno local o de servidor.

---

## Requisitos previos

| Herramienta | Versión mínima | Cómo verificar |
|-------------|----------------|----------------|
| Java JDK | 21 | `java -version` |
| Apache Maven | 3.9 | `mvn -version` |
| Apache Tomcat | 10.1 | — |

> **Java 21 es obligatorio.** Java 8, 11 o 17 no son compatibles con el nivel de compilación del proyecto.

---

## Paso 1 — Obtener el código fuente

Clona o descarga el repositorio del proyecto:

```bash
git clone <URL-del-repositorio>
cd Sistema_De_Tarjetas_Corporativas
```

Si recibiste un archivo ZIP, descomprímelo y abre una terminal dentro de la carpeta.

---

## Paso 2 — Configurar la base de datos Oracle

### 2.1 Oracle Wallet

El proyecto ya incluye el wallet de Oracle en `src/main/webapp/WEB-INF/wallet/`.
El sistema lo detecta automáticamente al arrancar **sin necesidad de configurar
`DB_WALLET_PATH`**, siempre que los archivos del wallet estén en esa carpeta.

Si necesitas usar un wallet externo (por ejemplo, en producción), define la variable
de entorno `DB_WALLET_PATH` apuntando a la carpeta que lo contiene y el sistema
la usará con prioridad sobre el wallet incluido.

### 2.2 Crear el schema

Conéctate a la base de datos con SQL Developer, SQL*Plus u otra herramienta y
ejecuta los scripts DDL **en este orden exacto**:

```sql
-- 1. Schema base: tablas, secuencias, triggers y restricciones
@db/schema.sql

-- 2. Datos iniciales + tabla RESET_CODIGOS para recuperación de contraseña
@db/migration_v3.sql

-- 3. Índices de rendimiento (búsqueda y paginación)
@db/migration_v4_indices.sql

-- 4. Permitir múltiples tarjetas del mismo tipo por cuenta
@db/migration_v5_tarjetas_fix.sql
```

### 2.3 Crear el usuario administrador inicial

Después de ejecutar los scripts, inserta el primer usuario administrador:

```sql
INSERT INTO USUARIOS (nombre, apellido_paterno, email, password_hash, rol, activo)
VALUES (
    'Nombre',
    'Apellido',
    'admin@empresa.com',
    '<hash BCrypt cost 12>',
    'admin',
    1
);
COMMIT;
```

Para generar el hash BCrypt puedes usar cualquier herramienta online de BCrypt con cost 12,
o la clase `PasswordUtil` del proyecto desde tu IDE.

---

## Paso 3 — Compilar el proyecto

Desde la raíz del proyecto:

```bash
mvn clean package
```

Si todo está bien, verás `BUILD SUCCESS` y se generará:

```
target/Tarjetas_Corporativas-1.0-SNAPSHOT.war
```

Si ves errores de compilación, verifica que `JAVA_HOME` apunte al JDK 21:

```bash
# Linux / Mac
export JAVA_HOME=/ruta/al/jdk-21

# Windows (cmd)
set JAVA_HOME=C:\Program Files\Java\jdk-21
```

---

## Paso 4 — Configurar las variables de entorno

Crea o edita el archivo de arranque de Tomcat con las credenciales de la base de datos.
**No pongas credenciales en archivos de código fuente.**

### Windows — `%CATALINA_HOME%\bin\setenv.bat`

```bat
set DB_ALIAS=mibasededatos_high
set DB_USER=ADMIN
set DB_PASSWORD=TuPasswordSegura123

rem Solo necesario si el wallet NO está en WEB-INF/wallet/
rem set DB_WALLET_PATH=C:\oracle\wallet
```

### Linux / Mac — `$CATALINA_HOME/bin/setenv.sh`

```bash
export DB_ALIAS=mibasededatos_high
export DB_USER=ADMIN
export DB_PASSWORD=TuPasswordSegura123

# Solo necesario si el wallet NO está en WEB-INF/wallet/
# export DB_WALLET_PATH=/opt/oracle/wallet
```

> **`DB_ALIAS`** debe coincidir con una entrada en el `tnsnames.ora` del wallet.

### Configuración de correo electrónico (opcional)

Para habilitar el envío de códigos de recuperación de contraseña por email,
agrega también estas variables:

```bat
rem Windows
set MAIL_HOST=smtp.gmail.com
set MAIL_PORT=587
set MAIL_USER=noreply@empresa.com
set MAIL_PASSWORD=contraseñaSMTP
```

```bash
# Linux / Mac
export MAIL_HOST=smtp.gmail.com
export MAIL_PORT=587
export MAIL_USER=noreply@empresa.com
export MAIL_PASSWORD=contraseñaSMTP
```

> Si las variables de correo no están configuradas, el sistema igual genera el código
> pero lo registra solo en el log de Tomcat (`catalina.out`). La funcionalidad principal
> del sistema no se ve afectada.

---

## Paso 5 — Desplegar en Tomcat

### Opción A — Despliegue manual

```bash
# Copiar el WAR
cp target/Tarjetas_Corporativas-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/ROOT.war

# Eliminar despliegue anterior si existe
rm -rf $CATALINA_HOME/webapps/ROOT

# Arrancar Tomcat
$CATALINA_HOME/bin/startup.sh        # Linux/Mac
%CATALINA_HOME%\bin\startup.bat      # Windows
```

### Opción B — Desde IntelliJ IDEA

1. Ve a **Run → Edit Configurations**.
2. Agrega una configuración de tipo **Tomcat Server → Local**.
3. En la pestaña **Deployment**, agrega el artefacto `Tarjetas_Corporativas:war exploded`.
4. En la pestaña **Startup/Connection → Environment Variables**, define `DB_ALIAS`, `DB_USER`, `DB_PASSWORD` (y las demás que correspondan).
5. Haz clic en **Run** o **Debug**.

---

## Paso 6 — Verificar la instalación

1. Abre el navegador en `http://localhost:8080` (o el puerto configurado).
2. Debes ver la pantalla de inicio de sesión.
3. Ingresa con el correo y contraseña del administrador creado en el Paso 2.3.
4. Si ves el dashboard de administrador, la instalación fue exitosa.

---

## Solución de problemas comunes

### `ExceptionInInitializerError` al arrancar

**Causa:** Falta `DB_ALIAS`, `DB_USER` o `DB_PASSWORD`, o el wallet no se encontró.

**Solución:**
- Verifica las variables de entorno en `setenv.bat` / `setenv.sh`.
- Si no defines `DB_WALLET_PATH`, confirma que los archivos del wallet estén en `src/main/webapp/WEB-INF/wallet/` (`cwallet.sso`, `tnsnames.ora`, `ojdbc.properties`).
- Reinicia Tomcat después de editar `setenv.bat` / `setenv.sh`.

### `IO Error: The Network Adapter could not establish the connection`

**Causa:** El alias TNS no existe o el wallet está incompleto.

**Solución:**
- Verifica que `DB_ALIAS` coincida exactamente con una entrada en `tnsnames.ora`.
- Confirma que el archivo `tnsnames.ora` tenga la cadena de conexión correcta de tu instancia ATP.

### Pantalla en blanco o error 404

**Causa:** El WAR no se desplegó correctamente o hay un conflicto con un despliegue anterior.

**Solución:** Revisa `$CATALINA_HOME/logs/catalina.out` y busca errores durante el despliegue.
Elimina la carpeta `ROOT` en `webapps/` antes de copiar el nuevo WAR.

### `incompatible Java version` al compilar

**Causa:** Maven está usando una versión de Java distinta a la 21.

**Solución:** Define `JAVA_HOME` explícitamente antes de ejecutar `mvn clean package`.

---

## Resumen de tablas de la base de datos

| Tabla | Descripción |
|-------|-------------|
| `USUARIOS` | Empleados y administradores |
| `EMPLEADOS` | Datos laborales (departamento, cargo) |
| `DEPARTAMENTOS` | Catálogo de departamentos |
| `CARGOS` | Catálogo de cargos |
| `CATEGORIAS_CUENTA` | Categorías de cuenta con límite mensual |
| `CUENTAS` | Cuentas bancarias corporativas de los empleados |
| `TARJETAS` | Tarjetas corporativas asociadas a cuentas |
| `MOVIMIENTOS` | Registro de transferencias entre cuentas |
| `CUENTA_GLOBAL` | Cuenta corporativa central (saldo global) |
| `CG_MOVIMIENTOS` | Historial de la cuenta global |
| `RESET_CODIGOS` | Códigos de recuperación de contraseña |
| `AUDITORIA` | Registro de auditoría del sistema |

El DDL completo está en [`db/schema.sql`](../db/schema.sql).
