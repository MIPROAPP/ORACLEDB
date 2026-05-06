-- =============================================================================
-- TABLA: armiust - TELEFONO (satelite de USUARIO)
-- Descripcion: Telefonos asociados a los usuarios del sistema.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmiust
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armiust (
  id                      NUMBER          NOT NULL,
  usuario                 VARCHAR2(36)    NOT NULL,
  tipo                    VARCHAR2(1)     NOT NULL,
  codigo_pais             NUMBER(5)       NOT NULL,
  telefono                VARCHAR2(15)    NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armiust IS 'Telefonos de contacto asociados a cada usuario. Un usuario puede tener multiples telefonos.';
COMMENT ON COLUMN cz_mi.armiust.id IS 'Identificador numerico del telefono (asignado en armiust_br con sqmiust.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armiust.usuario IS 'FK a armius: propietario del telefono.';
COMMENT ON COLUMN cz_mi.armiust.tipo IS 'FK a armitti: tipo de telefono registrado (movil, fijo, etc.).';
COMMENT ON COLUMN cz_mi.armiust.codigo_pais IS 'Codigo de pais del telefono (ej: 507 para Panama, 1 para USA).';
COMMENT ON COLUMN cz_mi.armiust.telefono IS 'Numero de telefono (sin signos; incluir codigo de pais con codigo_pais).';
COMMENT ON COLUMN cz_mi.armiust.fecha_crea IS 'Fecha y hora de creacion del registro. (auditoria)';
COMMENT ON COLUMN cz_mi.armiust.fecha_modifica IS 'Fecha y hora de la ultima modificacion. (auditoria)';
COMMENT ON COLUMN cz_mi.armiust.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armiust.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armiust_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armiust_armius_fk FOREIGN KEY (usuario)
  REFERENCES cz_mi.armius (id);

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armiust_armitti_fk FOREIGN KEY (tipo)
  REFERENCES cz_mi.armitti (id);

CREATE OR REPLACE
TRIGGER cz_mi.armiust_br
BEFORE INSERT OR UPDATE
ON cz_mi.armiust
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmiust.NEXTVAL;
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
