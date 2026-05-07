-- =============================================================================
-- TABLA: arminot - NOTIFICACION_TIPO
-- Descripcion: Catalogo de tipos de notificacion (ej: Email, SMS, Push).
-- =============================================================================
CREATE TABLE cz_mi.arminot (
  tipo                    VARCHAR2(1)    NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.arminot IS 'Catalogo de tipos de notificacion configurados en el sistema.';
COMMENT ON COLUMN cz_mi.arminot.tipo IS 'Codigo identificador del tipo de notificacion.';
COMMENT ON COLUMN cz_mi.arminot.nombre IS 'Nombre descriptivo del tipo.';
COMMENT ON COLUMN cz_mi.arminot.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.arminot.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.arminot.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.arminot.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.arminot
  ADD CONSTRAINT arminot_pk PRIMARY KEY (tipo) USING INDEX;

CREATE OR REPLACE
TRIGGER cz_mi.arminot_br
BEFORE INSERT OR UPDATE
ON cz_mi.arminot
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
