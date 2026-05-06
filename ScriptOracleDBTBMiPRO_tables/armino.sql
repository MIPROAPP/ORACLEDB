-- =============================================================================
-- TABLA: armino - NOTIFICACION
-- Descripcion: Notificaciones generadas y enviadas asociadas a solicitudes.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmino
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armino (
  notificacion            NUMBER          NOT NULL,
  solicitud               VARCHAR2(36)    NOT NULL,
  titulo                  VARCHAR2(500)   NOT NULL,
  mensaje                 VARCHAR2(4000)  NOT NULL,
  tipo                    VARCHAR2(1)     NOT NULL,
  fecha_emision           DATE            NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armino IS 'Notificaciones generadas para los usuarios en relacion a sus solicitudes.';
COMMENT ON COLUMN cz_mi.armino.notificacion IS 'Identificador numerico de la notificacion.';
COMMENT ON COLUMN cz_mi.armino.solicitud IS 'FK a armiso: solicitud a la que pertenece la notificacion.';
COMMENT ON COLUMN cz_mi.armino.titulo IS 'Titulo o asunto de la notificacion.';
COMMENT ON COLUMN cz_mi.armino.mensaje IS 'Contenido del mensaje.';
COMMENT ON COLUMN cz_mi.armino.tipo IS 'FK a arminot: tipo de notificacion.';
COMMENT ON COLUMN cz_mi.armino.fecha_emision IS 'Fecha en que se genero la notificacion.';
COMMENT ON COLUMN cz_mi.armino.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armino.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armino.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armino.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armino
  ADD CONSTRAINT armino_pk PRIMARY KEY (notificacion) USING INDEX;

ALTER TABLE cz_mi.armino
  ADD CONSTRAINT armino_arminot_fk FOREIGN KEY (tipo)
  REFERENCES cz_mi.arminot (tipo);

CREATE OR REPLACE
TRIGGER cz_mi.armino_br
BEFORE INSERT OR UPDATE
ON cz_mi.armino
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.notificacion     := cz_mi.sqmino.NEXTVAL;
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
