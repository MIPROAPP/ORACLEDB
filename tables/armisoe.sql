-- =============================================================================
-- TABLA: armisoe - SOLICITUD_ESTADO (catalogo de los estados de solicitud)
-- Descripcion: Estados posibles de una solicitud.
-- =============================================================================
CREATE TABLE cz_mi.armisoe (
  estado                  VARCHAR2(1)     NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisoe IS 'Catalogo de estados de solicitud';
COMMENT ON COLUMN cz_mi.armisoe.estado IS 'Codigo del estado de solicitud.';
COMMENT ON COLUMN cz_mi.armisoe.nombre IS 'Nombre del estado.';
COMMENT ON COLUMN cz_mi.armisoe.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisoe.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisoe.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisoe.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisoe
  ADD CONSTRAINT armisoe_pk PRIMARY KEY (estado) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armisoe_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisoe
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
