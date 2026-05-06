-- =============================================================================
-- TABLA: armius - USUARIO
-- Descripcion: Tabla principal de usuarios del sistema.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmius
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armius (
  id                      NUMBER          NOT NULL,
  correo                  VARCHAR2(255)   NOT NULL,
  nombre                  VARCHAR2(80)    NOT NULL,
  apellido                VARCHAR2(80)    NOT NULL,
  tipo                    VARCHAR2(1)     NOT NULL,
  identificacion          VARCHAR2(30)    NOT NULL,
  activo                  VARCHAR2(1)     DEFAULT 'S' NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armius IS 'Tabla principal de usuarios registrados en la app MiPRO.';
COMMENT ON COLUMN cz_mi.armius.id IS 'Identificador numerico del usuario (asignado en armius_br con sqmius.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armius.correo IS 'Direccion de correo electronico de contacto.';
COMMENT ON COLUMN cz_mi.armius.nombre IS 'Nombre del usuario.';
COMMENT ON COLUMN cz_mi.armius.apellido IS 'Apellido del usuario.';
COMMENT ON COLUMN cz_mi.armius.tipo IS 'Tipo de documento (cedula, pasaporte, etc.).';
COMMENT ON COLUMN cz_mi.armius.identificacion IS 'Numero de documento de identidad segun el tipo indicado.';
COMMENT ON COLUMN cz_mi.armius.activo IS 'Indica si el usuario esta activo: S si, N no.';
COMMENT ON COLUMN cz_mi.armius.fecha_crea IS 'Fecha y hora de creacion del registro. (auditoria)';
COMMENT ON COLUMN cz_mi.armius.fecha_modifica IS 'Fecha y hora de la ultima modificacion. (auditoria)';
COMMENT ON COLUMN cz_mi.armius.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armius.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armius
  ADD CONSTRAINT armius_pk PRIMARY KEY (id) USING INDEX;

CREATE OR REPLACE
TRIGGER cz_mi.armius_br
BEFORE INSERT OR UPDATE
ON cz_mi.armius
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmius.NEXTVAL;
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
