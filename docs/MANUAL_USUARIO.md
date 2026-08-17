# Manual de Usuario — Sistema de Tarjetas Corporativas

## ¿Qué es este sistema?

El Sistema de Tarjetas Corporativas permite a los empleados de la empresa consultar
sus cuentas bancarias corporativas, realizar transferencias entre compañeros y
visualizar el estado de sus tarjetas de empresa. Los administradores, además,
gestionan a los empleados, distribuyen fondos y configuran los catálogos del sistema.

---

## Acceso al sistema

### Iniciar sesión

1. Abre el navegador y ve a la dirección del sistema.
2. Ingresa tu **correo electrónico** y **contraseña**.
3. Haz clic en **Iniciar sesión**.

> Si olvidas tu contraseña, usa el enlace **¿Olvidaste tu contraseña?** en la
> pantalla de inicio de sesión.

### Recuperar contraseña

1. En la pantalla de inicio de sesión, haz clic en **¿Olvidaste tu contraseña?**
2. **Paso 1 — Verificar correo:** ingresa el correo registrado en el sistema y
   haz clic en **Enviar código**. Si el correo existe, recibirás un código de 6 dígitos
   por correo electrónico y avanzarás al paso 2.
3. **Paso 2 — Verificar código:** ingresa el código de 6 dígitos que recibiste.
   El código expira en 15 minutos. Si no lo recibiste, usa el enlace **Reenviar código**.
4. **Paso 3 — Nueva contraseña:** ingresa tu nueva contraseña (mínimo 8 caracteres),
   confírmala y haz clic en **Establecer nueva contraseña**.
5. Serás redirigido al inicio de sesión. Usa tu nueva contraseña para entrar.

---

## Para empleados

### Panel principal (Dashboard)

Al ingresar verás un resumen con:

- **Saldo total consolidado** de todas tus cuentas activas.
- **Tus cuentas** con número, categoría y saldo individual.
- **Últimos movimientos** con monto, fecha y tipo (transferencia enviada/recibida).

### Mis cuentas

En el menú lateral, haz clic en **Cuentas** para ver el detalle de cada cuenta:

- Número de cuenta, categoría y saldo.
- Historial de movimientos con dirección (entrada/salida), monto y fecha.

### Transferencias

1. En el menú lateral, haz clic en **Transferencias**.
2. Selecciona la **cuenta origen** (tuya) y la **cuenta destino** (de otro empleado).
3. Ingresa el **monto** y un **concepto**.
4. Haz clic en **Enviar transferencia**.

> **Condiciones para transferir:**
> - La cuenta origen debe estar **activa** y tener saldo suficiente.
> - La cuenta destino debe estar **activa** y ser de la misma categoría que la origen.
> - No puedes transferirte a ti mismo.

La sección también muestra las **estadísticas del mes**: total enviado, total recibido y neto.

### Mis tarjetas

En **Tarjetas** verás todas tus tarjetas corporativas activas con:

- Número enmascarado de tarjeta.
- Modalidad (virtual o física).
- Estado (activa o bloqueada).
- Límite mensual y categoría de la cuenta asociada.

### Configuración de perfil

En **Configuración** puedes:

- Ver tu nombre, correo, cargo y departamento.
- Cambiar tu nombre visible.
- Cambiar tu contraseña (debes ingresar la contraseña actual para confirmar).

---

## Para administradores

### Dashboard administrativo

Muestra los indicadores globales del sistema:

- **Saldo global corporativo** disponible para distribuir.
- Número total de empleados, cuentas y tarjetas activas.
- Movimientos corporativos recientes.
- Empleados registrados recientemente.

### Gestión de empleados

En **Empleados** puedes:

| Acción | Cómo hacerlo |
|--------|-------------|
| Ver la lista de empleados | Se muestra automáticamente al entrar |
| Agregar un empleado | Botón **Nuevo empleado** — completa nombre, correo, contraseña, rol, departamento y cargo |
| Editar un empleado | Haz clic en el ícono de edición en la fila del empleado |
| Dar de baja un empleado | Haz clic en **Eliminar** — esto devuelve los fondos de sus cuentas a la cuenta global, bloquea sus tarjetas y congela sus cuentas |

> **Atención:** La baja de un empleado es permanente. Sus fondos se devuelven
> automáticamente a la cuenta corporativa global.

### Gestión de cuentas

En **Cuentas** ves a todos los empleados con sus cuentas asignadas:

| Acción | Cómo hacerlo |
|--------|-------------|
| Crear cuenta para un empleado | Botón **Nueva cuenta** — selecciona empleado y categoría |
| Congelar / Descongelar una cuenta | Usa los botones en la tarjeta de la cuenta |
| Eliminar una cuenta | Botón **Eliminar** en la cuenta — congela y pone el saldo a cero |

### Gestión de tarjetas

En **Tarjetas** ves todas las tarjetas activas del sistema:

| Acción | Cómo hacerlo |
|--------|-------------|
| Ver detalle de una tarjeta | Clic en la tarjeta |
| Bloquear una tarjeta activa | En el detalle, botón **Bloquear tarjeta** |
| Desbloquear una tarjeta bloqueada | En el detalle, botón **Desbloquear tarjeta** |
| Cancelar una tarjeta (baja definitiva) | En el detalle, botón **Cancelar tarjeta** — se pedirá confirmación |

### Gestión de fondos

En **Fondos** administras el dinero corporativo:

**Depositar a cuenta global:**
1. Ingresa el monto y un concepto.
2. Haz clic en **Depositar**.

**Asignar fondos a un empleado:**
1. Selecciona la cuenta del empleado destino.
2. Ingresa el monto a asignar.
3. Haz clic en **Asignar fondos**.

> El monto se descuenta de la cuenta global corporativa y se acredita
> en la cuenta del empleado.

### Configuración del sistema

En **Configuración** gestionas los catálogos del sistema:

- **Departamentos:** agregar, editar o dar de baja departamentos.
- **Cargos:** agregar, editar o dar de baja cargos.
- **Categorías de cuenta:** agregar, editar o dar de baja categorías (con límite mensual).

---

## Notificaciones

El sistema muestra notificaciones emergentes (toasts) en la esquina de la pantalla
confirmando el resultado de cada operación:

- **Verde:** operación exitosa.
- **Rojo:** error — revisa los datos e intenta de nuevo.
- **Amarillo:** advertencia (ej. saldo insuficiente, cuenta congelada).

---

## Preguntas frecuentes

**¿Por qué no puedo transferir a otra cuenta?**
Verifica que: la cuenta origen esté activa, tengas saldo suficiente, la cuenta destino
sea de la misma categoría y pertenezca a otro empleado.

**¿Por qué mi tarjeta no aparece?**
Las tarjetas canceladas o bloqueadas no aparecen en la vista de empleado. Contacta al
administrador para reactivarla.

**¿Puedo cambiar mi correo electrónico?**
No. El correo es un identificador único asignado por el administrador. Si necesitas
cambiarlo, solicítalo al administrador.

**¿Qué pasa con mis fondos si me dan de baja?**
El saldo de tus cuentas activas es devuelto automáticamente a la cuenta corporativa
global y tus cuentas y tarjetas quedan desactivadas.
