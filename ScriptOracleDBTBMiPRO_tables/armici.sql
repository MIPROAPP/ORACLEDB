-- =============================================================================
-- TABLA: armici - CITA
-- Descripcion: Tabla principal de citas programadas para la ejecucion de servicios.
-- =============================================================================
CREATE TABLE cz_mi.armici (
  id                       NUMBER          NOT NULL,
  solicitud                VARCHAR2(40)    NOT NULL,
  servicio                 VARCHAR2(36)    NOT NULL,
  estado                   VARCHAR2(1)     NOT NULL,
  no_prove                 NUMBER          NOT NULL,
  identificacion           VARCHAR2(30)    NOT NULL,
  tipo_identificacion      VARCHAR2(1)     NOT NULL,
  fecha_programada_inicio  DATE            NOT NULL,
  fecha_programada_fin     DATE            NOT NULL,
  fecha_crea               DATE            NOT NULL,
  fecha_modifica           DATE,
  usuario_crea             VARCHAR2(30)    NOT NULL,
  usuario_modifica         VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armici IS 'Citas programadas para la ejecucion de un servicio especifico dentro de una solicitud. Vincula solicitud, servicio, tecnico y estado.';
COMMENT ON COLUMN cz_mi.armici.id IS 'Identificador numerico de la cita (asignado en trigger armici_br con SQMICI.NEXTVAL si viene nulo).';
COMMENT ON COLUMN cz_mi.armici.solicitud IS 'FK a armiso: solicitud asociada.';
COMMENT ON COLUMN cz_mi.armici.servicio IS 'FK a armisos: linea de servicio concreta a ejecutar en la cita.';
COMMENT ON COLUMN cz_mi.armici.estado IS 'FK a armicie: estado de la cita.';
COMMENT ON COLUMN cz_mi.armici.no_prove IS 'FK a armitc (compuesto): numero de proveedor del tecnico asignado.';
COMMENT ON COLUMN cz_mi.armici.identificacion IS 'FK a armitc (compuesto): identificacion del tecnico.';
COMMENT ON COLUMN cz_mi.armici.tipo_identificacion IS 'FK a armitc (compuesto): tipo de identificacion del tecnico.';
COMMENT ON COLUMN cz_mi.armici.fecha_programada_inicio IS 'Fecha y hora de inicio programada para la cita.';
COMMENT ON COLUMN cz_mi.armici.fecha_programada_fin IS 'Fecha y hora de fin programada para la cita.';
COMMENT ON COLUMN cz_mi.armici.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armici.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armici.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armici.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armiso_armici_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armisos_armici_fk FOREIGN KEY (servicio)
  REFERENCES cz_mi.armisos (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armicie_armici_fk FOREIGN KEY (estado)
  REFERENCES cz_mi.armicie (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armitc_armici_fk FOREIGN KEY (no_prove, identificacion, tipo_identificacion)
  REFERENCES cz_mi.armitc (no_prove, identificacion, tipo_identificacion);

CREATE SEQUENCE cz_mi.SQMICI
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE OR REPLACE
TRIGGER cz_mi.armici_br
BEFORE INSERT OR UPDATE
ON cz_mi.armici
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.SQMICI.NEXTVAL;
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
