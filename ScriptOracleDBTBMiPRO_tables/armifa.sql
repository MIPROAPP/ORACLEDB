-- =============================================================================
-- TABLA: armifa - SOLICITUD_FACTURA
-- Descripcion: Facturas asociadas a las solicitudes de servicio.
-- =============================================================================
CREATE TABLE cz_mi.armifa (
  key_docu                VARCHAR2(50)    NOT NULL,
  solicitud               VARCHAR2(36)    NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armifa IS 'Relacion de facturas generadas o asociadas a una solicitud.';
COMMENT ON COLUMN cz_mi.armifa.key_docu IS 'Clave unica del documento de factura (referencia a ARFAFE).';
COMMENT ON COLUMN cz_mi.armifa.solicitud IS 'FK a armiso: solicitud a la que pertenece la factura.';
COMMENT ON COLUMN cz_mi.armifa.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armifa.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armifa.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armifa.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armifa
  ADD CONSTRAINT armifa_pk PRIMARY KEY (key_docu) USING INDEX;

ALTER TABLE cz_mi.armifa
  ADD CONSTRAINT armifa_armiso_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (solicitud);

CREATE OR REPLACE
TRIGGER cz_mi.armifa_br
BEFORE INSERT OR UPDATE
ON cz_mi.armifa
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
