-- ============================================================
--  MIGRACIÓN v3 — Sistema de Tarjetas Corporativas
--  Ejecutar en orden completo en una sola sesión SQL.
--  ¡HACER BACKUP antes de ejecutar en producción!
-- ============================================================


-- ============================================================
-- 1. ELIMINAR límite_mensual de CATEGORIAS_CUENTA
-- ============================================================
ALTER TABLE CATEGORIAS_CUENTA DROP CONSTRAINT ck_cat_limite;
ALTER TABLE CATEGORIAS_CUENTA DROP COLUMN limite_mensual;


-- ============================================================
-- 2. ELIMINAR movimiento_rev_id de MOVIMIENTOS (campo sin uso)
-- ============================================================
ALTER TABLE MOVIMIENTOS DROP CONSTRAINT fk_mov_reversion;
ALTER TABLE MOVIMIENTOS DROP COLUMN movimiento_rev_id;


-- ============================================================
-- 3. TARJETAS — número de 16 dígitos independiente de la cuenta
-- ============================================================
-- Ampliar columna a 16 caracteres
ALTER TABLE TARJETAS MODIFY numero_tarjeta VARCHAR2(16);

-- Restricción de unicidad sobre el número de tarjeta
ALTER TABLE TARJETAS ADD CONSTRAINT uk_tarjeta_numero UNIQUE (numero_tarjeta);

-- Actualizar trigger para auto-generar número de 16 dígitos (estilo Visa: inicia con 4)
CREATE OR REPLACE TRIGGER TRG_TARJETAS_BI
    BEFORE INSERT ON TARJETAS FOR EACH ROW
DECLARE
    v_num VARCHAR2(16);
    v_cnt NUMBER;
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_TARJETAS.NEXTVAL; END IF;

    IF :NEW.numero_tarjeta IS NULL THEN
        LOOP
            -- 16 dígitos: '4' fijo + 15 dígitos aleatorios
            v_num := '4' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 1000000000000000)), 15, '0');
            SELECT COUNT(*) INTO v_cnt FROM TARJETAS WHERE numero_tarjeta = v_num;
            EXIT WHEN v_cnt = 0;
        END LOOP;
        :NEW.numero_tarjeta := v_num;
    END IF;
END;
/


-- ============================================================
-- 4. NORMALIZACIÓN USUARIOS → tabla EMPLEADOS separada
-- ============================================================

-- 4a. Secuencia para EMPLEADOS
CREATE SEQUENCE SEQ_EMPLEADOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 4b. Tabla EMPLEADOS
CREATE TABLE EMPLEADOS (
    id                 NUMBER        CONSTRAINT pk_empleados  PRIMARY KEY,
    usuario_id         NUMBER        NOT NULL,
    empleado_id        VARCHAR2(20),
    departamento_id    NUMBER,
    cargo_id           NUMBER,
    fecha_creacion     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_modificacion TIMESTAMP,
    CONSTRAINT uk_emp_usuario UNIQUE (usuario_id),
    CONSTRAINT uk_emp_empid   UNIQUE (empleado_id),
    CONSTRAINT fk_emp_usuario FOREIGN KEY (usuario_id)      REFERENCES USUARIOS(id),
    CONSTRAINT fk_emp_depto   FOREIGN KEY (departamento_id) REFERENCES DEPARTAMENTOS(id),
    CONSTRAINT fk_emp_cargo   FOREIGN KEY (cargo_id)        REFERENCES CARGOS(id)
);

-- 4c. Trigger para EMPLEADOS (PK + empleado_id)
CREATE OR REPLACE TRIGGER TRG_EMPLEADOS_BI
    BEFORE INSERT ON EMPLEADOS FOR EACH ROW
DECLARE
    v_nombre        VARCHAR2(200);
    v_nombre_limpio VARCHAR2(200);
    v_letras        VARCHAR2(3);
    v_num_str       VARCHAR2(4);
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_EMPLEADOS.NEXTVAL; END IF;

    IF :NEW.empleado_id IS NULL THEN
        SELECT nombre INTO v_nombre FROM USUARIOS WHERE id = :NEW.usuario_id;
        v_nombre_limpio := REGEXP_REPLACE(UPPER(v_nombre), '[^A-Z]', '');
        v_letras  := SUBSTR(v_nombre_limpio, 1, 3);
        v_letras  := RPAD(NVL(NULLIF(TRIM(v_letras), ''), 'EMP'), 3, 'X');
        v_num_str := LPAD(SEQ_EMP_NUM.NEXTVAL, 4, '0');
        :NEW.empleado_id := v_letras || '-' || v_num_str;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_EMPLEADOS_BU
    BEFORE UPDATE ON EMPLEADOS FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSTIMESTAMP;
END;
/

-- 4d. Migrar datos existentes de empleados
INSERT INTO EMPLEADOS (usuario_id, empleado_id, departamento_id, cargo_id)
SELECT id, empleado_id, departamento_id, cargo_id
FROM USUARIOS
WHERE rol = 'empleado';

COMMIT;

-- 4e. Actualizar trigger USUARIOS_BI (eliminar lógica de empleado_id)
CREATE OR REPLACE TRIGGER TRG_USUARIOS_BI
    BEFORE INSERT ON USUARIOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_USUARIOS.NEXTVAL; END IF;
END;
/

-- 4f. Eliminar columnas migradas de USUARIOS (primero constraints)
ALTER TABLE USUARIOS DROP CONSTRAINT fk_usuario_dept;
ALTER TABLE USUARIOS DROP CONSTRAINT fk_usuario_cargo;
ALTER TABLE USUARIOS DROP CONSTRAINT uq_usuario_empid;

ALTER TABLE USUARIOS DROP COLUMN empleado_id;
ALTER TABLE USUARIOS DROP COLUMN departamento_id;
ALTER TABLE USUARIOS DROP COLUMN cargo_id;


-- ============================================================
-- 5. RESET_CODIGOS — tabla para recuperación de contraseña por email
-- ============================================================
CREATE SEQUENCE SEQ_RESET_CODIGOS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE RESET_CODIGOS (
    id        NUMBER        CONSTRAINT pk_reset_codigos PRIMARY KEY,
    email     VARCHAR2(255) NOT NULL,
    codigo    VARCHAR2(6)   NOT NULL,
    expira_en TIMESTAMP     NOT NULL,
    usado     NUMBER(1)     DEFAULT 0 NOT NULL,
    intentos  NUMBER        DEFAULT 0 NOT NULL,
    fecha     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT ck_reset_usado CHECK (usado IN (0,1)),
    CONSTRAINT ck_reset_int   CHECK (intentos >= 0)
);

CREATE INDEX idx_reset_email ON RESET_CODIGOS (email, usado, expira_en);

CREATE OR REPLACE TRIGGER TRG_RESET_CODIGOS_BI
    BEFORE INSERT ON RESET_CODIGOS FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN :NEW.id := SEQ_RESET_CODIGOS.NEXTVAL; END IF;
END;
/

-- ============================================================
-- FIN MIGRACIÓN v3
-- ============================================================
