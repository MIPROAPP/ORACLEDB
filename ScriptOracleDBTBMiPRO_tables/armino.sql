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
  id                      NUMBER          NOT NULL,
  solicitud               VARCHAR2(36)    NOT NULL,
  asunto                  VARCHAR2(500)   NOT NULL,
  cuerpo                  VARCHAR2(4000)  NOT NULL,
  fecha_emision           DATE            NOT NULL,
  enviado                 VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  fecha_envio             DATE,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armino IS 'Notificaciones generadas para los usuarios en relacion a sus solicitudes (email, push, etc.).';
COMMENT ON COLUMN cz_mi.armino.id IS 'Identificador numerico de la notificacion (asignado en armino_br con sqmino.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armino.solicitud IS 'FK a armiso: solicitud a la que pertenece la notificacion.';
COMMENT ON COLUMN cz_mi.armino.asunto IS 'Titulo o asunto (ej. de correo o de alerta en pantalla).';
COMMENT ON COLUMN cz_mi.armino.cuerpo IS 'Contenido completo del mensaje o notificacion (texto plano o enriquecido a convenir).';
COMMENT ON COLUMN cz_mi.armino.fecha_emision IS 'Fecha en que se genero la notificacion en el sistema.';
COMMENT ON COLUMN cz_mi.armino.enviado IS 'S si la notificacion fue enviada correctamente; N si esta pendiente o con fallo.';
COMMENT ON COLUMN cz_mi.armino.fecha_envio IS 'Fecha en que la notificacion fue efectivamente enviada al destinatario.';
COMMENT ON COLUMN cz_mi.armino.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armino.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armino.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armino.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armino
  ADD CONSTRAINT armino_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armino
  ADD CONSTRAINT armino_armiso_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (id);

CREATE OR REPLACE
TRIGGER cz_mi.armino_br
BEFORE INSERT OR UPDATE
ON cz_mi.armino
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmino.NEXTVAL;
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
