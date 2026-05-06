-- =============================================================================
-- TABLA: armici - CITA
-- Descripcion: Tabla principal de citas programadas para la ejecucion de servicios.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmici
MINVALUE 1
MAXVALUE 9999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armici (
  id                       NUMBER(10)      NOT NULL,
  solicitud                VARCHAR2(40)    NOT NULL,
  servicio                 VARCHAR2(36)    NOT NULL,
  estado                   VARCHAR2(1)     NOT NULL,
  tecnico                  NUMBER(6)       NOT NULL,
  inicio                   DATE            NOT NULL,
  fin                      DATE            NOT NULL,
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
COMMENT ON COLUMN cz_mi.armici.tecnico IS 'FK a armitc: tecnico asignado.';
COMMENT ON COLUMN cz_mi.armici.inicio IS 'Fecha y hora de inicio de la cita.';
COMMENT ON COLUMN cz_mi.armici.fin IS 'Fecha y hora de fin de la cita.';
COMMENT ON COLUMN cz_mi.armici.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armici.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armici.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armici.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_armiso_fk FOREIGN KEY (solicitud)
  REFERENCES cz_mi.armiso (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_armisos_fk FOREIGN KEY (servicio)
  REFERENCES cz_mi.armisos (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_armicie_fk FOREIGN KEY (estado)
  REFERENCES cz_mi.armicie (id);

ALTER TABLE cz_mi.armici
  ADD CONSTRAINT armici_armitc_fk FOREIGN KEY (tecnico)
  REFERENCES cz_mi.armitc (id);

CREATE OR REPLACE
TRIGGER cz_mi.armici_br
BEFORE INSERT OR UPDATE
ON cz_mi.armici
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmici.NEXTVAL;
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
