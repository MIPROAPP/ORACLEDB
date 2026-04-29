-- =============================================================================
-- TABLA: armisot - SOLICITUD_TIPO (satelite de SOLICITUD)
-- Descripcion: Tipos de solicitud disponibles en el sistema.
-- =============================================================================
CREATE TABLE cz_mi.armisot (
  id                      VARCHAR2(1)     NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisot IS 'Catalogo de tipos de solicitud. Define la naturaleza de cada solicitud registrada.';
COMMENT ON COLUMN cz_mi.armisot.id IS 'Codigo de catalogo (1 caracter). Clave del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.nombre IS 'Nombre o descripcion legible del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisot.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisot.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisot.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisot
  ADD CONSTRAINT armisot_pk PRIMARY KEY (id) USING INDEX;


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
    :NEW.fecha_modifica   := SYSDATE;
  END IF;
END;
/
