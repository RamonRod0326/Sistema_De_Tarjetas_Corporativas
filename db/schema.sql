-- ============================================================
--  SISTEMA DE TARJETAS CORPORATIVAS - FINTECH CORP
--  Oracle Autonomous Database Schema  (v2 — corregido)
--  Ejecutar en orden, en una sola sesión (SQL Worksheet / SQL Developer)
-- ============================================================


-- ============================================================
-- 0. LIMPIEZA (ejecutar solo si necesitas recrear desde cero)
-- ============================================================
BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
    'AUDITORIA','MOVIMIENTOS','TARJETAS','CUENTAS','CG_MOVIMIENTOS',
    'CUENTA_GLOBAL','USUARIOS','CATEGORIAS_CUENTA','CARGOS','DEPARTAMENTOS'
  )) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN (
    'SEQ_AUDITORIA','SEQ_USUARIOS','SEQ_EMP_NUM','SEQ_DEPARTAMENTOS','SEQ_CARGOS',
    'SEQ_CATEGORIAS','SEQ_CUENTAS','SEQ_TARJETAS','SEQ_MOVIMIENTOS','SEQ_CG_MOV'
  )) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/


-- ============================================================
-- 1. SECUENCIAS
-- ============================================================
CREATE SEQUENCE SEQ_USUARIOS      START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EMP_NUM       START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DEPARTAMENTOS START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CARGOS        START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CATEGORIAS    START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CUENTAS       START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TARJETAS      START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_MOVIMIENTOS   START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CG_MOV        START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_AUDITORIA     START WITH 1    INCREMENT BY 1 NOCACHE NOCYCLE;


-- ============================================================
-- 2. CATÁLOGOS
-- ============================================================

-- 2a. Departamentos
CREATE TABLE DEPARTAMENTOS (
    id               NUMBER        CONSTRAINT pk_departamentos PRIMARY KEY,
    nombre           VARCHAR2(100) NOT NULL,
    activo           NUMBER(1)     DEFAULT 1 NOT NULL,
    fecha_creacion   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_dept_nombre  UNIQUE (nombre),
    CONSTRAINT ck_dept_activo  CHECK (activo IN (0,1))
);

CREATE OR REPLACE TRIGGER TRG_DEPARTAMENTOS_BI
    BEFORE INSERT ON DEPARTAMENTOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_DEPARTAMENTOS.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_DEPARTAMENTOS_BU
    BEFORE UPDATE ON DEPARTAMENTOS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- 2b. Cargos
CREATE TABLE CARGOS (
    id               NUMBER        CONSTRAINT pk_cargos PRIMARY KEY,
    nombre           VARCHAR2(150) NOT NULL,
    activo           NUMBER(1)     DEFAULT 1 NOT NULL,
    fecha_creacion   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_cargo_nombre  UNIQUE (nombre),
    CONSTRAINT ck_cargo_activo  CHECK (activo IN (0,1))
);

CREATE OR REPLACE TRIGGER TRG_CARGOS_BI
    BEFORE INSERT ON CARGOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_CARGOS.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CARGOS_BU
    BEFORE UPDATE ON CARGOS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- 2c. Categorías de cuenta (Viáticos, Gasolina, Bonos, etc.)
CREATE TABLE CATEGORIAS_CUENTA (
    id               NUMBER        CONSTRAINT pk_categorias PRIMARY KEY,
    nombre           VARCHAR2(100) NOT NULL,
    descripcion      VARCHAR2(255),
    limite_mensual   NUMBER(15,2),           -- NULL = sin límite de asignación mensual
    activo           NUMBER(1)     DEFAULT 1 NOT NULL,
    fecha_creacion   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_cat_nombre   UNIQUE (nombre),
    CONSTRAINT ck_cat_activo   CHECK (activo IN (0,1)),
    CONSTRAINT ck_cat_limite   CHECK (limite_mensual IS NULL OR limite_mensual > 0)
);

CREATE OR REPLACE TRIGGER TRG_CATEGORIAS_BI
    BEFORE INSERT ON CATEGORIAS_CUENTA FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_CATEGORIAS.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CATEGORIAS_BU
    BEFORE UPDATE ON CATEGORIAS_CUENTA FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 3. USUARIOS (admins Y empleados, rol diferenciador)
--    CORRECCIÓN ERR-001: eliminado BLOB foto → sin campo de imagen.
--    El avatar se genera con iniciales en el frontend (sin archivos).
-- ============================================================
CREATE TABLE USUARIOS (
    id                 NUMBER        CONSTRAINT pk_usuarios PRIMARY KEY,
    empleado_id        VARCHAR2(10),               -- 'LLL-NNNN', NULL para admins
    nombre             VARCHAR2(200) NOT NULL,
    email              VARCHAR2(255) NOT NULL,
    password_hash      VARCHAR2(255) NOT NULL,      -- BCrypt hash (60 chars; 255 deja margen futuro)
    rol                VARCHAR2(20)  NOT NULL,       -- 'admin' | 'empleado'
    departamento_id    NUMBER,
    cargo_id           NUMBER,
    activo             NUMBER(1)     DEFAULT 1 NOT NULL,
    fecha_creacion     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_usuario_email  UNIQUE (email),
    CONSTRAINT uq_usuario_empid  UNIQUE (empleado_id),
    CONSTRAINT ck_usuario_rol    CHECK (rol IN ('admin','empleado')),
    CONSTRAINT ck_usuario_activo CHECK (activo IN (0,1)),
    CONSTRAINT fk_usuario_dept   FOREIGN KEY (departamento_id) REFERENCES DEPARTAMENTOS(id),
    CONSTRAINT fk_usuario_cargo  FOREIGN KEY (cargo_id)        REFERENCES CARGOS(id)
);

CREATE OR REPLACE TRIGGER TRG_USUARIOS_BI
    BEFORE INSERT ON USUARIOS FOR EACH ROW
DECLARE
    v_letras        VARCHAR2(3);
    v_num_str       VARCHAR2(4);
    v_nombre_limpio VARCHAR2(200);
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SEQ_USUARIOS.NEXTVAL;
    END IF;

    IF :NEW.rol = 'empleado' AND :NEW.empleado_id IS NULL THEN
        v_nombre_limpio := REGEXP_REPLACE(UPPER(:NEW.nombre), '[^A-Z]', '');
        v_letras  := SUBSTR(v_nombre_limpio, 1, 3);
        v_letras  := RPAD(NVL(NULLIF(TRIM(v_letras), ''), 'EMP'), 3, 'X');
        v_num_str := LPAD(SEQ_EMP_NUM.NEXTVAL, 4, '0');
        :NEW.empleado_id := v_letras || '-' || v_num_str;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_USUARIOS_BU
    BEFORE UPDATE ON USUARIOS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 4. CUENTA GLOBAL CORPORATIVA (tesorería de la empresa)
--    CORRECCIÓN ERR-008: constraint singleton para garantizar 1 sola fila.
-- ============================================================
CREATE TABLE CUENTA_GLOBAL (
    id        NUMBER       CONSTRAINT pk_cuenta_global PRIMARY KEY,
    saldo     NUMBER(15,2) DEFAULT 0 NOT NULL,
    fecha_act TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT ck_cg_saldo     CHECK (saldo >= 0),
    CONSTRAINT ck_cg_singleton CHECK (id = 1)    -- solo puede existir la fila id=1
);

INSERT INTO CUENTA_GLOBAL (id, saldo) VALUES (1, 0);

-- ============================================================
-- 4b. MOVIMIENTOS de la cuenta global
--    CORRECCIÓN ERR-002: movimiento_id FK a MOVIMIENTOS (se añade la FK después de crear MOVIMIENTOS)
--    CORRECCIÓN ERR-010: tipo incluye 'reversion'
-- ============================================================
CREATE TABLE CG_MOVIMIENTOS (
    id             NUMBER       CONSTRAINT pk_cg_mov PRIMARY KEY,
    tipo           VARCHAR2(20) NOT NULL,    -- 'deposito' | 'asignacion' | 'reversion'
    monto          NUMBER(15,2) NOT NULL,
    concepto       VARCHAR2(500),
    saldo_anterior NUMBER(15,2) NOT NULL,
    saldo_nuevo    NUMBER(15,2) NOT NULL,
    admin_id       NUMBER       NOT NULL,
    movimiento_id  NUMBER,                   -- FK a MOVIMIENTOS (asignaciones/reversiones)
    fecha          TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_cgmov_admin FOREIGN KEY (admin_id) REFERENCES USUARIOS(id),
    CONSTRAINT ck_cgmov_tipo  CHECK (tipo IN ('deposito','asignacion','reversion')),
    CONSTRAINT ck_cgmov_monto CHECK (monto > 0)
);

CREATE OR REPLACE TRIGGER TRG_CG_MOV_BI
    BEFORE INSERT ON CG_MOVIMIENTOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_CG_MOV.NEXTVAL; END IF;
END;
/


-- ============================================================
-- 5. CUENTAS (de empleados, una por categoría por empleado)
--    CORRECCIÓN ERR-007: constraint cruzado activo/estado
--    CORRECCIÓN ERR-009: fecha_modificacion + trigger BU
-- ============================================================
CREATE TABLE CUENTAS (
    id                 NUMBER        CONSTRAINT pk_cuentas PRIMARY KEY,
    numero_cuenta      VARCHAR2(16)  NOT NULL,
    usuario_id         NUMBER        NOT NULL,
    categoria_id       NUMBER        NOT NULL,
    saldo              NUMBER(15,2)  DEFAULT 0 NOT NULL,
    estado             VARCHAR2(15)  DEFAULT 'ACTIVA' NOT NULL,   -- 'ACTIVA' | 'CONGELADA'
    activo             NUMBER(1)     DEFAULT 1 NOT NULL,
    fecha_creacion     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_numero_cuenta      UNIQUE (numero_cuenta),
    CONSTRAINT uq_cuenta_user_cat    UNIQUE (usuario_id, categoria_id),
    CONSTRAINT ck_cuenta_saldo       CHECK (saldo >= 0),
    CONSTRAINT ck_cuenta_estado      CHECK (estado IN ('ACTIVA','CONGELADA')),
    CONSTRAINT ck_cuenta_activo      CHECK (activo IN (0,1)),
    CONSTRAINT ck_cuenta_estado_actv CHECK (activo = 1 OR estado = 'CONGELADA'),
    CONSTRAINT fk_cuenta_usuario     FOREIGN KEY (usuario_id)   REFERENCES USUARIOS(id),
    CONSTRAINT fk_cuenta_categoria   FOREIGN KEY (categoria_id) REFERENCES CATEGORIAS_CUENTA(id)
);

CREATE OR REPLACE TRIGGER TRG_CUENTAS_BI
    BEFORE INSERT ON CUENTAS FOR EACH ROW
DECLARE
    v_num   VARCHAR2(16);
    v_count NUMBER;
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SEQ_CUENTAS.NEXTVAL;
    END IF;

    IF :NEW.numero_cuenta IS NULL THEN
        LOOP
            -- Primer bloque 4xxx para evitar cero inicial; las demás posiciones son libres
            v_num := LPAD(TRUNC(DBMS_RANDOM.VALUE(4000, 4999)), 4, '0')
                  || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 9999)),    4, '0')
                  || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 9999)),    4, '0')
                  || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 9999)),    4, '0');
            SELECT COUNT(*) INTO v_count FROM CUENTAS WHERE numero_cuenta = v_num;
            EXIT WHEN v_count = 0;
        END LOOP;
        :NEW.numero_cuenta := v_num;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CUENTAS_BU
    BEFORE UPDATE ON CUENTAS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 6. TARJETAS (decorativas, asociadas a cuentas)
--    CORRECCIÓN ERR-005: UNIQUE(cuenta_id, modalidad) + numero_tarjeta
--    CORRECCIÓN ERR-007: constraint cruzado activo/estado
--    CORRECCIÓN ERR-009: fecha_modificacion + trigger BU
-- ============================================================
CREATE TABLE TARJETAS (
    id                 NUMBER       CONSTRAINT pk_tarjetas PRIMARY KEY,
    cuenta_id          NUMBER       NOT NULL,
    modalidad          VARCHAR2(10) NOT NULL,                       -- 'VIRTUAL' | 'FISICA'
    estado             VARCHAR2(15) DEFAULT 'ACTIVA' NOT NULL,     -- 'ACTIVA' | 'INACTIVA' | 'BLOQUEADA'
    numero_tarjeta     VARCHAR2(4),                                 -- últimos 4 dígitos (decorativo)
    fecha_emision      TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    activo             NUMBER(1)    DEFAULT 1 NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uq_tarjeta_cuenta_modal UNIQUE (cuenta_id, modalidad),
    CONSTRAINT fk_tarjeta_cuenta FOREIGN KEY (cuenta_id) REFERENCES CUENTAS(id),
    CONSTRAINT ck_tarjeta_modal  CHECK (modalidad IN ('VIRTUAL','FISICA')),
    CONSTRAINT ck_tarjeta_estado CHECK (estado IN ('ACTIVA','INACTIVA','BLOQUEADA')),
    CONSTRAINT ck_tarjeta_activo CHECK (activo IN (0,1)),
    CONSTRAINT ck_tarjeta_estado_actv CHECK (activo = 1 OR estado = 'BLOQUEADA')
);

CREATE OR REPLACE TRIGGER TRG_TARJETAS_BI
    BEFORE INSERT ON TARJETAS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_TARJETAS.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_TARJETAS_BU
    BEFORE UPDATE ON TARJETAS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/


-- ============================================================
-- 7. MOVIMIENTOS (transferencias entre cuentas + asignaciones de la cuenta global)
--    CORRECCIÓN ERR-003: realizado_por + estado + movimiento_rev_id
--    CORRECCIÓN ERR-014: referencia determinística usando :NEW.id (sin DBMS_RANDOM loop)
-- ============================================================
CREATE TABLE MOVIMIENTOS (
    id                NUMBER        CONSTRAINT pk_movimientos PRIMARY KEY,
    tipo              VARCHAR2(20)  NOT NULL,   -- 'transferencia' | 'asignacion_fondos'
    cuenta_origen_id  NUMBER,                   -- NULL cuando es asignacion_fondos
    cuenta_destino_id NUMBER        NOT NULL,
    monto             NUMBER(15,2)  NOT NULL,
    concepto          VARCHAR2(500),
    referencia        VARCHAR2(30)  NOT NULL,   -- 'REF-YYYYMMDD-NNNNNNNN', único
    realizado_por     NUMBER        NOT NULL,   -- usuario que inició el movimiento
    estado            VARCHAR2(15)  DEFAULT 'PROCESADO' NOT NULL,  -- 'PROCESADO' | 'REVERTIDO'
    movimiento_rev_id NUMBER,                   -- FK al movimiento compensatorio si fue revertido
    fecha             TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT uq_mov_referencia   UNIQUE (referencia),
    CONSTRAINT ck_mov_monto        CHECK (monto > 0),
    CONSTRAINT ck_mov_tipo         CHECK (tipo IN ('transferencia','asignacion_fondos')),
    CONSTRAINT ck_mov_estado       CHECK (estado IN ('PROCESADO','REVERTIDO')),
    CONSTRAINT fk_mov_origen       FOREIGN KEY (cuenta_origen_id)  REFERENCES CUENTAS(id),
    CONSTRAINT fk_mov_destino      FOREIGN KEY (cuenta_destino_id) REFERENCES CUENTAS(id),
    CONSTRAINT fk_mov_realizado    FOREIGN KEY (realizado_por)     REFERENCES USUARIOS(id),
    CONSTRAINT fk_mov_reversion    FOREIGN KEY (movimiento_rev_id) REFERENCES MOVIMIENTOS(id)
);

-- Ahora que MOVIMIENTOS existe, añadir la FK de CG_MOVIMIENTOS
ALTER TABLE CG_MOVIMIENTOS
    ADD CONSTRAINT fk_cgmov_movimiento
        FOREIGN KEY (movimiento_id) REFERENCES MOVIMIENTOS(id);

-- Trigger 1: PK + referencia determinística (sin DBMS_RANDOM, sin loop de colisión)
CREATE OR REPLACE TRIGGER TRG_MOVIMIENTOS_BI
    BEFORE INSERT ON MOVIMIENTOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := SEQ_MOVIMIENTOS.NEXTVAL;
    END IF;

    IF :NEW.referencia IS NULL THEN
        :NEW.referencia := 'REF-'
            || TO_CHAR(SYSDATE, 'YYYYMMDD')
            || '-'
            || LPAD(:NEW.id, 8, '0');
    END IF;
END;
/

-- Trigger 2: validaciones de negocio ANTES de insertar
CREATE OR REPLACE TRIGGER TRG_MOV_VALIDAR
    BEFORE INSERT ON MOVIMIENTOS FOR EACH ROW
DECLARE
    v_cat_orig   NUMBER;
    v_cat_dest   NUMBER;
    v_saldo_orig NUMBER(15,2);
    v_saldo_cg   NUMBER(15,2);
    v_est_orig   VARCHAR2(15);
    v_est_dest   VARCHAR2(15);
BEGIN
    IF :NEW.tipo = 'transferencia' THEN
        SELECT categoria_id, estado INTO v_cat_orig, v_est_orig
          FROM CUENTAS WHERE id = :NEW.cuenta_origen_id AND activo = 1;
        SELECT categoria_id, estado INTO v_cat_dest, v_est_dest
          FROM CUENTAS WHERE id = :NEW.cuenta_destino_id AND activo = 1;

        IF v_est_orig != 'ACTIVA' THEN
            RAISE_APPLICATION_ERROR(-20001, 'La cuenta origen está congelada.');
        END IF;
        IF v_est_dest != 'ACTIVA' THEN
            RAISE_APPLICATION_ERROR(-20002, 'La cuenta destino está congelada.');
        END IF;
        IF v_cat_orig != v_cat_dest THEN
            RAISE_APPLICATION_ERROR(-20003, 'Solo se permiten transferencias entre cuentas de la misma categoría.');
        END IF;

        SELECT saldo INTO v_saldo_orig FROM CUENTAS WHERE id = :NEW.cuenta_origen_id;
        IF v_saldo_orig < :NEW.monto THEN
            RAISE_APPLICATION_ERROR(-20004, 'Saldo insuficiente en la cuenta origen.');
        END IF;

    ELSIF :NEW.tipo = 'asignacion_fondos' THEN
        SELECT saldo INTO v_saldo_cg FROM CUENTA_GLOBAL WHERE id = 1;
        IF v_saldo_cg < :NEW.monto THEN
            RAISE_APPLICATION_ERROR(-20005, 'Saldo insuficiente en la cuenta corporativa global.');
        END IF;
    END IF;
END;
/

-- Trigger 3: actualizar saldos DESPUÉS de insertar
CREATE OR REPLACE TRIGGER TRG_MOV_ACTUALIZAR_SALDOS
    AFTER INSERT ON MOVIMIENTOS FOR EACH ROW
BEGIN
    IF :NEW.tipo = 'transferencia' THEN
        UPDATE CUENTAS SET saldo = saldo - :NEW.monto WHERE id = :NEW.cuenta_origen_id;
        UPDATE CUENTAS SET saldo = saldo + :NEW.monto WHERE id = :NEW.cuenta_destino_id;

    ELSIF :NEW.tipo = 'asignacion_fondos' THEN
        UPDATE CUENTA_GLOBAL
           SET saldo     = saldo - :NEW.monto,
               fecha_act = SYSTIMESTAMP
         WHERE id = 1;
        UPDATE CUENTAS SET saldo = saldo + :NEW.monto WHERE id = :NEW.cuenta_destino_id;
    END IF;
END;
/


-- ============================================================
-- 8. AUDITORÍA GENERAL
--    CORRECCIÓN ERR-006: tabla nueva para trazabilidad de cambios de estado
-- ============================================================
CREATE TABLE AUDITORIA (
    id              NUMBER        CONSTRAINT pk_auditoria PRIMARY KEY,
    tabla_afectada  VARCHAR2(50)  NOT NULL,
    registro_id     NUMBER        NOT NULL,
    operacion       VARCHAR2(10)  NOT NULL,   -- 'INSERT' | 'UPDATE' | 'DELETE'
    campo           VARCHAR2(100),
    valor_anterior  VARCHAR2(4000),
    valor_nuevo     VARCHAR2(4000),
    usuario_id      NUMBER        REFERENCES USUARIOS(id),
    ip_origen       VARCHAR2(45),
    fecha           TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT ck_aud_operacion CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
);

CREATE OR REPLACE TRIGGER TRG_AUDITORIA_BI
    BEFORE INSERT ON AUDITORIA FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_AUDITORIA.NEXTVAL; END IF;
END;
/


-- ============================================================
-- 9. ÍNDICES
--    CORRECCIÓN ERR-004: eliminado IDX_USUARIO_EMAIL (duplicaba el índice del UNIQUE)
--    CORRECCIÓN ERR-013: añadido IDX_CUENTAS_ESTADO
--    NUEVO: IDX_MOV_REALIZADO_POR, IDX_AUD_*
-- ============================================================

-- USUARIOS
CREATE INDEX IDX_USUARIO_ROL        ON USUARIOS(rol, activo);
-- Nota: NO se crea IDX_USUARIO_EMAIL — Oracle ya genera uno para CONSTRAINT uq_usuario_email

-- CUENTAS
CREATE INDEX IDX_CUENTA_USUARIO     ON CUENTAS(usuario_id);
CREATE INDEX IDX_CUENTA_CATEGORIA   ON CUENTAS(categoria_id);
CREATE INDEX IDX_CUENTAS_ESTADO     ON CUENTAS(estado, activo);

-- MOVIMIENTOS
CREATE INDEX IDX_MOV_ORIGEN         ON MOVIMIENTOS(cuenta_origen_id);
CREATE INDEX IDX_MOV_DESTINO        ON MOVIMIENTOS(cuenta_destino_id);
CREATE INDEX IDX_MOV_FECHA          ON MOVIMIENTOS(fecha);
CREATE INDEX IDX_MOV_REALIZADO_POR  ON MOVIMIENTOS(realizado_por);

-- TARJETAS
CREATE INDEX IDX_TARJETA_CUENTA     ON TARJETAS(cuenta_id);

-- AUDITORÍA
CREATE INDEX IDX_AUD_TABLA_REG      ON AUDITORIA(tabla_afectada, registro_id);
CREATE INDEX IDX_AUD_USUARIO        ON AUDITORIA(usuario_id);
CREATE INDEX IDX_AUD_FECHA          ON AUDITORIA(fecha);


-- ============================================================
-- 10. DATOS SEMILLA - CATÁLOGOS
-- ============================================================

INSERT INTO DEPARTAMENTOS (nombre) VALUES ('Operaciones');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('Finanzas');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('Ciberseguridad');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('IT');

INSERT INTO CARGOS (nombre) VALUES ('Director');
INSERT INTO CARGOS (nombre) VALUES ('Gerente');
INSERT INTO CARGOS (nombre) VALUES ('Analista');
INSERT INTO CARGOS (nombre) VALUES ('Ingeniero de Software');
INSERT INTO CARGOS (nombre) VALUES ('Ingeniero de Seguridad');
INSERT INTO CARGOS (nombre) VALUES ('Analista de Riesgos');

INSERT INTO CATEGORIAS_CUENTA (nombre, descripcion) VALUES ('Viáticos',      'Gastos de viaje y representación');
INSERT INTO CATEGORIAS_CUENTA (nombre, descripcion) VALUES ('Gasolina',       'Combustible y transporte');
INSERT INTO CATEGORIAS_CUENTA (nombre, descripcion) VALUES ('Bonos',          'Premios y bonos por desempeño');
INSERT INTO CATEGORIAS_CUENTA (nombre, descripcion) VALUES ('Operaciones',    'Gastos operativos generales');
INSERT INTO CATEGORIAS_CUENTA (nombre, descripcion) VALUES ('Representación', 'Gastos de representación corporativa');


-- ============================================================
-- 11. USUARIO ADMINISTRADOR INICIAL
--     Contraseña inicial: Admin1234!
--     Hash BCrypt generado con at.favre.lib:bcrypt:0.10.2 (factor 10)
-- ============================================================
INSERT INTO USUARIOS (nombre, email, password_hash, rol)
VALUES (
    'Alejandro Vance',
    'a.vance@fintechcorp.com',
    '$2a$10$TNzhC1rEJO5QI5aQOO0wVOYaPL01S4g7V5MG5f/2.s2RLIHLa0mBq',
    'admin'
);

COMMIT;


-- ============================================================
-- VERIFICACIÓN RÁPIDA
-- ============================================================
SELECT 'DEPARTAMENTOS'    AS tabla, COUNT(*) AS filas FROM DEPARTAMENTOS    UNION ALL
SELECT 'CARGOS'           AS tabla, COUNT(*) AS filas FROM CARGOS           UNION ALL
SELECT 'CATEGORIAS'       AS tabla, COUNT(*) AS filas FROM CATEGORIAS_CUENTA UNION ALL
SELECT 'USUARIOS'         AS tabla, COUNT(*) AS filas FROM USUARIOS          UNION ALL
SELECT 'CUENTA_GLOBAL'    AS tabla, COUNT(*) AS filas FROM CUENTA_GLOBAL     UNION ALL
SELECT 'CG_MOVIMIENTOS'   AS tabla, COUNT(*) AS filas FROM CG_MOVIMIENTOS    UNION ALL
SELECT 'CUENTAS'          AS tabla, COUNT(*) AS filas FROM CUENTAS           UNION ALL
SELECT 'TARJETAS'         AS tabla, COUNT(*) AS filas FROM TARJETAS          UNION ALL
SELECT 'MOVIMIENTOS'      AS tabla, COUNT(*) AS filas FROM MOVIMIENTOS        UNION ALL
SELECT 'AUDITORIA'        AS tabla, COUNT(*) AS filas FROM AUDITORIA;
