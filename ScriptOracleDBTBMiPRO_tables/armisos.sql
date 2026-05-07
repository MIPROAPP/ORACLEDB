-- =============================================================================
-- TABLA: armisos - SOLICITUD_SERVICIO
-- Descripcion: Detalle de servicios incluidos en cada solicitud.
-- =============================================================================

CREATE TABLE cz_mi.armisos (
  solicitud               VARCHAR2(14)    NOT NULL,
  linea                   NUMBER(3)       NOT NULL,
  no_arti                 VARCHAR2(15)    NOT NULL,
  precio                  NUMBER(20,2)    NOT NULL,
  cantidad                NUMBER(4)       DEFAULT 1 NOT NULL,
  subtotal                NUMBER(20,2)    NOT NULL,
  descuento               NUMBER(20,2)    NOT NULL,
  impuesto                NUMBER(20,2)    NOT NULL,
  total                   NUMBER(20,2)    NOT NULL,
  tecnico                 NUMBER,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisos IS 'Detalle de servicios dentro de una solicitud.';
COMMENT ON COLUMN cz_mi.armisos.solicitud IS 'FK a armiso: solicitud padre.';
COMMENT ON COLUMN cz_mi.armisos.linea IS 'Identificador de la linea de servicio dentro de la solicitud.';
COMMENT ON COLUMN cz_mi.armisos.no_arti IS 'Codigo id del articulo (FK a ARINDA).';
COMMENT ON COLUMN cz_mi.armisos.precio IS 'Precio unitario del servicio.';
COMMENT ON COLUMN cz_mi.armisos.cantidad IS 'Cantidad de servicios por linea.';
COMMENT ON COLUMN cz_mi.armisos.subtotal IS 'Subtotal de la linea.';
COMMENT ON COLUMN cz_mi.armisos.descuento IS 'Descuento aplicado a la linea.';
COMMENT ON COLUMN cz_mi.armisos.impuesto IS 'Impuesto aplicado a la linea.';
COMMENT ON COLUMN cz_mi.armisos.total IS 'Total de la linea.';
COMMENT ON COLUMN cz_mi.armisos.tecnico IS 'Tecnico asignado a esta linea de servicio.';
COMMENT ON COLUMN cz_mi.armisos.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisos.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisos.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisos.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_pk PRIMARY KEY (solicitud,linea,no_arti) USING INDEX;

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_armiso FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (solicitud);

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_arinda FOREIGN KEY (no_arti)
  REFERENCES cz_in.arinda (no_arti);

CREATE OR REPLACE
TRIGGER cz_mi.armisos_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisos
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
