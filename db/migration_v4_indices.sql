-- ============================================================
-- Migration v4 - Scalability Indices
-- Run on Oracle ATP after v3 migration
-- ============================================================

-- Employees: filter by role + active, order by name
CREATE INDEX IDX_USR_ROL_ACTIVO ON USUARIOS(rol, activo);
CREATE INDEX IDX_USR_NOMBRE     ON USUARIOS(LOWER(nombre));

-- Cards: filter by active + estado + modalidad (admin list, user list)
CREATE INDEX IDX_TAR_ACTIVO_ESTADO ON TARJETAS(activo, estado, modalidad);

-- Movements: order by fecha DESC (historial query)
CREATE INDEX IDX_MOV_FECHA   ON MOVIMIENTOS(fecha DESC);
-- Movements: join/filter by cuenta_origen_id and cuenta_destino_id
CREATE INDEX IDX_MOV_ORIGEN  ON MOVIMIENTOS(cuenta_origen_id);
CREATE INDEX IDX_MOV_DESTINO ON MOVIMIENTOS(cuenta_destino_id);

-- Accounts: filter by usuario_id (user account lookups)
CREATE INDEX IDX_CTA_USUARIO ON CUENTAS(usuario_id, activo);
