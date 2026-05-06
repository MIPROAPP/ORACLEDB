-- =============================================================================
-- TABLA: armidi - DIRECCION
-- Descripcion: Direcciones fisicas asociadas a usuarios y solicitudes.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmidi
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armidi (
  id                      NUMBER          NOT NULL,
  usuario                 VARCHAR2(36)    NOT NULL,
  nombre                  VARCHAR2(100)   NOT NULL,
  detalle                 VARCHAR2(4000)  NOT NULL,
  latitud                 VARCHAR2(50),
  longitud                VARCHAR2(50),
  corregimiento           VARCHAR2(100),
  distrito                VARCHAR2(100),
  provincia               VARCHAR2(100),
  calle                   VARCHAR2(100),
  piso                    VARCHAR2(5),
  numero_casa             VARCHAR2(20),
  barrio                  VARCHAR2(100),
  tiene_ascensor          VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  es_predeterminada       VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  es_edificio             VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armidi IS 'Direcciones fisicas de los usuarios. Se utiliza para indicar donde se realizara el servicio.';
COMMENT ON COLUMN cz_mi.armidi.id IS 'Identificador numerico de la direccion (asignado en armidi_br con sqmidi.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armidi.usuario IS 'FK a armius: propietario de la direccion.';
COMMENT ON COLUMN cz_mi.armidi.nombre IS 'Alias o rotulo de la direccion (ej. Casa, Trabajo).';
COMMENT ON COLUMN cz_mi.armidi.detalle IS 'Direccion escrita: referencia completa o texto libre.';
COMMENT ON COLUMN cz_mi.armidi.latitud IS 'Latitud en formato de texto, si aplica (mapas).';
COMMENT ON COLUMN cz_mi.armidi.longitud IS 'Longitud en formato de texto, si aplica (mapas).';
COMMENT ON COLUMN cz_mi.armidi.corregimiento IS 'Corregimiento o equivalente local.';
COMMENT ON COLUMN cz_mi.armidi.distrito IS 'Distrito o equivalente local.';
COMMENT ON COLUMN cz_mi.armidi.provincia IS 'Provincia, estado o region.';
COMMENT ON COLUMN cz_mi.armidi.calle IS 'Calle, avenida o vial principal.';
COMMENT ON COLUMN cz_mi.armidi.piso IS 'Piso o nivel dentro del edificio.';
COMMENT ON COLUMN cz_mi.armidi.numero_casa IS 'Numero de puerta, apartamento o casa.';
COMMENT ON COLUMN cz_mi.armidi.barrio IS 'Barrio, urbanizacion o sector.';
COMMENT ON COLUMN cz_mi.armidi.tiene_ascensor IS 'S si el edificio o lugar tiene ascensor, N si no.';
COMMENT ON COLUMN cz_mi.armidi.es_predeterminada IS 'S si es la direccion predeterminada del usuario, N si no.';
COMMENT ON COLUMN cz_mi.armidi.es_edificio IS 'S si la direccion corresponde a un edificio, N si es casa u otro.';
COMMENT ON COLUMN cz_mi.armidi.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armidi.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armidi.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armidi.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armidi
  ADD CONSTRAINT armidi_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armidi
  ADD CONSTRAINT armidi_armius_fk FOREIGN KEY (usuario)
  REFERENCES cz_mi.armius (id);

CREATE OR REPLACE
TRIGGER cz_mi.armidi_br
BEFORE INSERT OR UPDATE
ON cz_mi.armidi
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id               := cz_mi.sqmidi.NEXTVAL;
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
