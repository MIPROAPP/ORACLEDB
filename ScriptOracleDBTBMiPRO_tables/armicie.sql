-- =============================================================================
-- TABLA: armicie - CITA_ESTADO (satelite de CITA)
-- Descripcion: Estados posibles de una cita.
-- =============================================================================
CREATE TABLE cz_mi.armicie (
  id                      VARCHAR2(1)     NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armicie IS 'Catalogo de estados de cita (ej: programada, en curso, completada, cancelada).';
COMMENT ON COLUMN cz_mi.armicie.id IS 'Codigo de catalogo (1 caracter). Clave del estado de cita.';
COMMENT ON COLUMN cz_mi.armicie.nombre IS 'Nombre o descripcion del estado de cita (para pantallas e informes).';
COMMENT ON COLUMN cz_mi.armicie.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armicie.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armicie.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armicie.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armicie
  ADD CONSTRAINT armicie_pk PRIMARY KEY (id) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armicie_br
BEFORE INSERT OR UPDATE
ON cz_mi.armicie
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
