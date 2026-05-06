-- =============================================================================
-- TABLA: armisr - SOLICITUD_RELACIONADA
-- Descripcion: Relaciones entre solicitudes (ej: re-trabajos, seguimientos).
-- =============================================================================
CREATE TABLE cz_mi.armisr (
  solicitud               VARCHAR2(36)    NOT NULL,
  solicitud_ref           VARCHAR2(36)    NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisr IS 'Registra relaciones de dependencia o referencia entre dos solicitudes.';
COMMENT ON COLUMN cz_mi.armisr.solicitud IS 'FK a armiso: solicitud origen.';
COMMENT ON COLUMN cz_mi.armisr.solicitud_ref IS 'FK a armiso: solicitud referenciada.';
COMMENT ON COLUMN cz_mi.armisr.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisr.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisr.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisr.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisr
  ADD CONSTRAINT armisr_pk PRIMARY KEY (solicitud, solicitud_ref) USING INDEX;

ALTER TABLE cz_mi.armisr
  ADD CONSTRAINT armisr_armiso_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (solicitud);

ALTER TABLE cz_mi.armisr --verificar esta relacion con armiso.
  ADD CONSTRAINT armisr_armiso_ref_fk FOREIGN KEY (solicitud_ref)
  REFERENCES cz_mi.armiso (solicitud);

CREATE OR REPLACE
TRIGGER cz_mi.armisr_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisr
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
