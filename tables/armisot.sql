-- =============================================================================
-- TABLA: armisot - SOLICITUD_TIPO (catalogo de los tipos de solicitud)
-- Descripcion: Tipos de solicitud disponibles.
-- =============================================================================
CREATE TABLE cz_mi.armisot (
  tipo                     VARCHAR2(1)     NOT NULL,
  nombre                   VARCHAR2(100)   NOT NULL,
  fecha_crea               DATE            NOT NULL,
  fecha_modifica           DATE,
  usuario_crea             VARCHAR2(30)    NOT NULL,
  usuario_modifica         VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisot IS 'Catalogo de tipos de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.tipo IS 'Codigo del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.nombre IS 'Nombre del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisot.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisot.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisot.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisot
  ADD CONSTRAINT armisot_pk PRIMARY KEY (tipo) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armisot_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisot
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
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
