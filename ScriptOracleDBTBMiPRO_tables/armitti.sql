-- =============================================================================
-- TABLA: armitti - TELEFONO_TIPO
-- Descripcion: Catalogo de tipos de telefono (movil, fijo, trabajo, etc.).
-- =============================================================================
CREATE TABLE cz_mi.armitti (
  id                      VARCHAR2(1)     NOT NULL,
  tipo                    VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armitti IS 'Catalogo de tipos de telefono; armiust.telefono_tipo referencia armitti.id.';
COMMENT ON COLUMN cz_mi.armitti.id IS 'Codigo de catalogo (1 caracter). Clave del tipo de telefono.';
COMMENT ON COLUMN cz_mi.armitti.tipo IS 'Nombre o descripcion del tipo de telefono.';
COMMENT ON COLUMN cz_mi.armitti.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armitti.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armitti.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armitti.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armitti
  ADD CONSTRAINT armitti_pk PRIMARY KEY (id) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armitti_br
BEFORE INSERT OR UPDATE
ON cz_mi.armitti
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
