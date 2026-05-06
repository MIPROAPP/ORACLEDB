-- =============================================================================
-- TABLA: armisosa - SOLICITUD_SERVICIO_ATRIBUTO
-- Descripcion: Atributos o caracteristicas adicionales de un servicio en la solicitud.
-- =============================================================================
CREATE TABLE cz_mi.armisosa (
  atributo                VARCHAR2(36)    NOT NULL,
  solicitud               VARCHAR2(36)    NOT NULL,
  linea                   NUMBER          NOT NULL,
  valor                   VARCHAR2(4000)  NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisosa IS 'Detalle de atributos dinamicos para cada linea de servicio.';
COMMENT ON COLUMN cz_mi.armisosa.atributo IS 'Codigo del atributo (referencia a ARINCA).';
COMMENT ON COLUMN cz_mi.armisosa.solicitud IS 'solicitud padre';
COMMENT ON COLUMN cz_mi.armisosa.linea IS 'FK a armisos: linea de servicio padre.';
COMMENT ON COLUMN cz_mi.armisosa.valor IS 'Valor asignado al atributo.';
COMMENT ON COLUMN cz_mi.armisosa.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisosa.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisosa.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisosa.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisosa
  ADD CONSTRAINT armisosa_pk PRIMARY KEY (atributo) USING INDEX;

ALTER TABLE cz_mi.armisosa
  ADD CONSTRAINT armisosa_armisos_fk FOREIGN KEY (linea)
  REFERENCES cz_mi.armisos (linea);

CREATE OR REPLACE
TRIGGER cz_mi.armisosa_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisosa
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
