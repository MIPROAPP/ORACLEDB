-- =============================================================================
-- TABLA: armitc - TECNICO
-- Descripcion: Tecnicos disponibles para la ejecucion de servicios en citas.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmitc
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armitc (
  tecnico                 NUMBER          NOT NULL,
  no_prove                NUMBER          NOT NULL,
  identificacion          VARCHAR2(30)    NOT NULL,
  tipo_identificacion     VARCHAR2(1)     NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  apellido                VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armitc IS 'Tecnicos registrados en el sistema.';
COMMENT ON COLUMN cz_mi.armitc.tecnico IS 'Identificador numerico del tecnico (asignado en armitc_br con sqmitc.NEXTVAL). Referencia preferida para FK.';
COMMENT ON COLUMN cz_mi.armitc.no_prove IS 'Numero de proveedor (FK a cz_in.arinmp; parte de unicidad compuesta).';
COMMENT ON COLUMN cz_mi.armitc.identificacion IS 'Numero de documento de identidad (parte de unicidad compuesta).';
COMMENT ON COLUMN cz_mi.armitc.tipo_identificacion IS 'Tipo de documento (parte de unicidad compuesta).';
COMMENT ON COLUMN cz_mi.armitc.nombre IS 'Nombre o nombres del tecnico.';
COMMENT ON COLUMN cz_mi.armitc.apellido IS 'Apellido o apellidos del tecnico.';
COMMENT ON COLUMN cz_mi.armitc.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armitc.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armitc.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armitc.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armitc
  ADD CONSTRAINT armitc_pk PRIMARY KEY (no_prove, identificacion, tipo_identificacion) USING INDEX;

ALTER TABLE cz_mi.armitc
  ADD CONSTRAINT armitc_tecnico_uq UNIQUE (tecnico) USING INDEX; -- Oracle me lo pide para poder referenciarlo desde armiso con solo el campo tecnico.

ALTER TABLE cz_mi.armitc
  ADD CONSTRAINT armitc_arinmp_fk FOREIGN KEY (no_prove)
  REFERENCES cz_in.arinmp (no_prove);

CREATE OR REPLACE
TRIGGER cz_mi.armitc_br
BEFORE INSERT OR UPDATE
ON cz_mi.armitc
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.tecnico          := cz_mi.sqmitc.NEXTVAL;
    :NEW.usuario_crea     := USER;
    :NEW.fecha_crea       := SYSDATE;
    :NEW.usuario_modifica := USER;
    :NEW.fecha_modifica   := SYSDATE;
  ELSIF UPDATING THEN
    :NEW.usuario_modifica := USER;
    :NEW.usuario_crea     := :OLD.usuario_crea;
    :NEW.fecha_modifica   := SYSDATE;
    :NEW.fecha_crea       := :OLD.fecha_crea;
  END IF;
END;
/
