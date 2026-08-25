-- ============================================================
--  LIMPIEZA DE DATOS - SISTEMA DE TARJETAS CORPORATIVAS
--  Elimina: empleados, cuentas, tarjetas, movimientos, fondos
--  Conserva: departamentos, cargos, categorias, admin
--  Ejecutar en Oracle SQL Worksheet / SQL Developer
-- ============================================================

-- 1. Auditoría (referencias a usuarios y movimientos)
DELETE FROM AUDITORIA;

-- 2. Movimientos de cuenta global
DELETE FROM CG_MOVIMIENTOS;

-- 3. Movimientos entre cuentas
DELETE FROM MOVIMIENTOS;

-- 4. Tarjetas
DELETE FROM TARJETAS;

-- 5. Cuentas de empleados
DELETE FROM CUENTAS;

-- 6. Resetear saldo de la cuenta corporativa global a cero
UPDATE CUENTA_GLOBAL SET saldo = 0, fecha_act = SYSTIMESTAMP WHERE id = 1;

-- 7. Eliminar tabla EMPLEADOS (FK que apunta a USUARIOS)
DELETE FROM EMPLEADOS;

-- 8. Eliminar empleados de USUARIOS (mantiene al admin)
DELETE FROM USUARIOS WHERE rol = 'empleado';

-- 9. Actualizar email del administrador
UPDATE USUARIOS
SET    email = '20253ds086@utez.edu.mx',
       nombre = 'Administrador'
WHERE  rol = 'admin';

COMMIT;

-- Verificación
SELECT rol, email, nombre, activo FROM USUARIOS;
SELECT 'CUENTAS'       AS tabla, COUNT(*) AS filas FROM CUENTAS       UNION ALL
SELECT 'TARJETAS'      AS tabla, COUNT(*) AS filas FROM TARJETAS       UNION ALL
SELECT 'MOVIMIENTOS'   AS tabla, COUNT(*) AS filas FROM MOVIMIENTOS    UNION ALL
SELECT 'CG_MOVIMIENTOS'AS tabla, COUNT(*) AS filas FROM CG_MOVIMIENTOS UNION ALL
SELECT 'CUENTA_GLOBAL' AS tabla, saldo               FROM CUENTA_GLOBAL WHERE id = 1;
