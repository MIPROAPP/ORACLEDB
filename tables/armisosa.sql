-- =============================================================================
-- TABLA: armisosa - SOLICITUD_SERVICIO_ATRIBUTO
-- Descripcion: Atributos o caracteristicas adicionales de un servicio en la solicitud.
-- =============================================================================
CREATE TABLE cz_mi.armisosa (
  solicitud               VARCHAR2(14)    NOT NULL,
  linea                   NUMBER(3)       NOT NULL,
  atributo                VARCHAR2(50)    NOT NULL,
  no_arti                 VARCHAR2(15)    NOT NULL,
  valor                   VARCHAR2(4000)  NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisosa IS 'Detalle de atributos dinamicos para cada linea de servicio.';
COMMENT ON COLUMN cz_mi.armisosa.atributo IS 'Codigo del atributo (FK a ARINCA).';
COMMENT ON COLUMN cz_mi.armisosa.solicitud IS 'FK a armiso: solicitud padre.';
COMMENT ON COLUMN cz_mi.armisosa.linea IS 'FK a armisos: linea de servicio padre.';
COMMENT ON COLUMN cz_mi.armisosa.valor IS 'Valor asignado al atributo.';
COMMENT ON COLUMN cz_mi.armisosa.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisosa.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisosa.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisosa.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisosa
  ADD CONSTRAINT armisosa_pk PRIMARY KEY (solicitud, linea, atributo, no_arti) USING INDEX;

ALTER TABLE cz_mi.armisosa
  ADD CONSTRAINT armisosa_armisos FOREIGN KEY (solicitud,linea,no_arti)
  REFERENCES cz_mi.armisos (solicitud,linea,no_arti);

ALTER TABLE cz_mi.armisosa
  ADD CONSTRAINT armisosa_arinca FOREIGN KEY (atributo,no_arti)
  REFERENCES cz_in.arinca (atributo,no_arti);

CREATE INDEX cz_mi.armisosa_armisos_fk ON cz_mi.armisosa (solicitud, linea, no_arti);
CREATE INDEX cz_mi.armisosa_arinca_fk ON cz_mi.armisosa (atributo, no_arti);

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
