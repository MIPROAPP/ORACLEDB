-- =============================================================================
-- TABLA: armisos - SOLICITUD_SERVICIO (satelite de SOLICITUD)
-- Descripcion: Detalle de servicios incluidos en cada solicitud.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmisos
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armisos (
  id                      NUMBER          NOT NULL,
  no_arti                 VARCHAR2(15)    NOT NULL, --id de servicio
  solicitud               VARCHAR2(36)    NOT NULL, --id de solicitud(armiso)
  categoria               VARCHAR2(36)    NOT NULL,
  precio                  NUMBER          NOT NULL,
  cantidad                NUMBER,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisos IS 'Detalle de servicios solicitados dentro de una solicitud. Permite que una solicitud incluya multiples servicios.';
COMMENT ON COLUMN cz_mi.armisos.id IS 'Identificador numerico de la linea de servicio (asignado en armisos_br con sqmisos.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armisos.solicitud IS 'FK a armiso: solicitud padre.';
COMMENT ON COLUMN cz_mi.armisos.categoria IS 'Codigo o clave de categoria de servicio';
COMMENT ON COLUMN cz_mi.armisos.no_arti IS 'Codigo id del servicio.';
COMMENT ON COLUMN cz_mi.armisos.precio IS 'Precio del servicio al momento de ser incluido en la solicitud (precio historico).';
COMMENT ON COLUMN cz_mi.armisos.cantidad IS 'Cantidad de unidades del servicio en la linea de solicitud.';
COMMENT ON COLUMN cz_mi.armisos.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisos.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisos.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisos.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_armiso_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (id);

CREATE OR REPLACE
TRIGGER cz_mi.armisos_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisos
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmisos.NEXTVAL;
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
