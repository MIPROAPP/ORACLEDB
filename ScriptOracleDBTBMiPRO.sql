-- =============================================================================
-- SCRIPT DE CREACION DE ESTRUCTURA DE BASE DE DATOS
-- Package  : SKMI
-- Modulo   : MI
-- Version  : 1.1
-- Creado por: Andres Garcia
-- Fecha    : 2026-04-22
-- Descripcion: Script de creacion de tablas para el modulo de gestion de
--              solicitudes de servicio, usuarios, tecnicos, citas y notificaciones.
-- =============================================================================

CREATE SEQUENCE cz_mi.SQMIUS
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de usuario existente.

-- =============================================================================
-- TABLA: armius - USUARIO
-- Descripcion: Tabla principal de usuarios del sistema.
-- =============================================================================
CREATE TABLE cz_mi.armius (
  id                    NUMBER          NOT NULL,
  correo                VARCHAR2(255)   NOT NULL,
  nombre                VARCHAR2(80)    NOT NULL,
  apellido              VARCHAR2(80)    NOT NULL,
  tipo                 VARCHAR2(1)    NOT NULL,
  identificacion         VARCHAR2(30)    NOT NULL,
  activo                 VARCHAR2(1)     DEFAULT 'S' NOT NULL,
  fecha_crea      DATE            NOT NULL,
  fecha_modifica  DATE,
  usuario_crea    VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armius IS 'Tabla principal de usuarios registrados en la app MiPRO.';
COMMENT ON COLUMN cz_mi.armius.id IS 'Identificador numerico del usuario (asignado en armius_br con SQMIUS.NEXTVAL).';
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

ALTER TABLE cz_mi.armius
  ADD CONSTRAINT armius_activo_ck CHECK (activo IN ('S', 'N'));

CREATE OR REPLACE
TRIGGER cz_mi.armius_br
BEFORE INSERT OR UPDATE
ON cz_mi.armius
REFERENCING NEW AS NEW
      OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id := cz_mi.SQMIUS.NEXTVAL;
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



-- =============================================================================
-- TABLA: armitti - TELEFONO_TIPO
-- Descripcion: Catalogo de tipos de telefono (movil, fijo, trabajo, etc.).
-- =============================================================================
CREATE TABLE cz_mi.armitti (
  id                 VARCHAR2(1)     NOT NULL,
  tipo               VARCHAR2(100)   NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armitti IS 'Catalogo de tipos de telefono; armiust.telefono_tipo referencia armitti.id.';
COMMENT ON COLUMN cz_mi.armitti.id IS 'Codigo de catalogo (1 caracter). Clave del tipo de telefono.';
COMMENT ON COLUMN cz_mi.armitti.tipo IS 'Nombre o descripcion del tipo de telefono.';
COMMENT ON COLUMN cz_mi.armitti.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armitti.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armitti.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armitti.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armitti
  ADD CONSTRAINT armitti_pk PRIMARY KEY (id) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armitti_br
BEFORE INSERT OR UPDATE
ON cz_mi.armitti
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




CREATE SEQUENCE cz_mi.SQMIUST
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de telefono existente.

-- =============================================================================
-- TABLA: armiust - TELEFONO (satelite de USUARIO)
-- Descripcion: Telefonos asociados a los usuarios del sistema.
-- =============================================================================
CREATE TABLE cz_mi.armiust (
  id                   NUMBER          NOT NULL,
  usuario              NUMBER          NOT NULL,
  telefono_tipo        VARCHAR2(1)     NOT NULL,
  codigo_pais          NUMBER(5)       NOT NULL,
  telefono             VARCHAR2(15)      NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armiust IS 'Telefonos de contacto asociados a cada usuario. Un usuario puede tener multiples telefonos.';
COMMENT ON COLUMN cz_mi.armiust.id IS 'Identificador numerico del telefono (asignado en armiust_br con SQMIUST.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armiust.usuario IS 'FK a armius: propietario del telefono.';
COMMENT ON COLUMN cz_mi.armiust.telefono_tipo IS 'FK a armitti: tipo de telefono registrado (movil, fijo, etc.).';
COMMENT ON COLUMN cz_mi.armiust.codigo_pais IS 'Codigo de pais del telefono (ej: 507 para Panama, 1 para USA).';
COMMENT ON COLUMN cz_mi.armiust.telefono IS 'Numero de telefono (sin signos; incluir codigo de pais con codigo_pais).';
COMMENT ON COLUMN cz_mi.armiust.fecha_crea IS 'Fecha y hora de creacion del registro. (auditoria)';
COMMENT ON COLUMN cz_mi.armiust.fecha_modifica IS 'Fecha y hora de la ultima modificacion. (auditoria)';
COMMENT ON COLUMN cz_mi.armiust.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armiust.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armiust_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armius_armiust_fk FOREIGN KEY (usuario)
  REFERENCES cz_mi.armius (id);

ALTER TABLE cz_mi.armiust
  ADD CONSTRAINT armitti_armiust_fk FOREIGN KEY (telefono_tipo)
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
    :NEW.id := cz_mi.SQMIUST.NEXTVAL;
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




CREATE SEQUENCE cz_mi.SQMIDI
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de direccion existente.

-- =============================================================================
-- TABLA: armidi - DIRECCION
-- Descripcion: Direcciones fisicas asociadas a usuarios y solicitudes.
-- =============================================================================
CREATE TABLE cz_mi.armidi (
  id                   NUMBER          NOT NULL,
  usuario              NUMBER          NOT NULL,
  nombre               VARCHAR2(100)   NOT NULL,
  detalle              VARCHAR2(4000)   NOT NULL,
  latitud              VARCHAR2(50),
  longitud             VARCHAR2(50),
  corregimiento        VARCHAR2(100),
  distrito             VARCHAR2(100),
  provincia            VARCHAR2(100),
  calle                VARCHAR2(100),
  piso                 VARCHAR2(5),
  numero_casa          VARCHAR2(20),
  barrio               VARCHAR2(100),
  tiene_ascensor       VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  es_predeterminada    VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  es_edificio          VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armidi IS 'Direcciones fisicas de los usuarios. Se utiliza para indicar donde se realizara el servicio.';
COMMENT ON COLUMN cz_mi.armidi.id IS 'Identificador numerico de la direccion (asignado en armidi_br con SQMIDI.NEXTVAL).';
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
  ADD CONSTRAINT armius_armidi_fk FOREIGN KEY (usuario)
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
    :NEW.id := cz_mi.SQMIDI.NEXTVAL;
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



-- =============================================================================
-- TABLA: armisot - SOLICITUD_TIPO (satelite de SOLICITUD)
-- Descripcion: Tipos de solicitud disponibles en el sistema.
-- =============================================================================
CREATE TABLE cz_mi.armisot (
  id                   VARCHAR2(1)    NOT NULL,
  nombre               VARCHAR2(100)   NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisot IS 'Catalogo de tipos de solicitud. Define la naturaleza de cada solicitud registrada.';
COMMENT ON COLUMN cz_mi.armisot.id IS 'Codigo de catalogo (1 caracter). Clave del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.nombre IS 'Nombre o descripcion legible del tipo de solicitud.';
COMMENT ON COLUMN cz_mi.armisot.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisot.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisot.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisot.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisot
  ADD CONSTRAINT armisot_pk PRIMARY KEY (id) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armisot_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisot
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




-- =============================================================================
-- TABLA: armisoe - SOLICITUD_ESTADO (satelite de SOLICITUD)
-- Descripcion: Estados posibles de una solicitud.
-- =============================================================================
CREATE TABLE cz_mi.armisoe (
  id                   VARCHAR2(1)    NOT NULL,
  nombre               VARCHAR2(100)   NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisoe IS 'Catalogo de estados de solicitud (ej: pendiente, en proceso, completada, cancelada).';
COMMENT ON COLUMN cz_mi.armisoe.id IS 'Codigo de catalogo (1 caracter). Clave del estado de solicitud.';
COMMENT ON COLUMN cz_mi.armisoe.nombre IS 'Nombre o descripcion del estado (para pantallas e informes).';
COMMENT ON COLUMN cz_mi.armisoe.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisoe.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisoe.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisoe.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisoe
  ADD CONSTRAINT armisoe_pk PRIMARY KEY (id) USING INDEX;


CREATE OR REPLACE
TRIGGER cz_mi.armisoe_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisoe
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




CREATE SEQUENCE cz_mi.SQMIISO
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max SOL-<n> existente.


-- =============================================================================
-- TABLA: armiso - SOLICITUD
-- Descripcion: Tabla principal de solicitudes de servicio realizadas por usuarios.
-- =============================================================================
CREATE TABLE cz_mi.armiso (
  id                    VARCHAR2(40)    NOT NULL,
  usuario               NUMBER          NOT NULL,
  direccion             NUMBER          NOT NULL,
  fecha                 DATE            NOT NULL,
  tipo               VARCHAR2(36)    NOT NULL,
  estado             VARCHAR2(36)    NOT NULL,
  descripcion          VARCHAR2(2000)  NOT NULL,
  factura               VARCHAR2(100),
  empresa               VARCHAR2(200),
  subtotal              NUMBER           NOT NULL,
  descuento             NUMBER           DEFAULT 0 NOT NULL,
  impuesto              NUMBER           DEFAULT 0 NOT NULL,
  total                 NUMBER           NOT NULL,
  cotizacion_servicio   VARCHAR2(50),
  factura_servicio      VARCHAR2(50),
  fecha_crea        DATE            NOT NULL,
  fecha_modifica    DATE,
  usuario_crea      VARCHAR2(30)   NOT NULL,
  usuario_modifica  VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armiso IS 'Tabla principal de solicitudes de servicio. Registra cada pedido realizado por un usuario para uno o varios servicios.';
COMMENT ON COLUMN cz_mi.armiso.id IS 'Identificador de solicitud: prefijo SOL- y numero generado por SQMIISO (ej. SOL-123).';
COMMENT ON COLUMN cz_mi.armiso.usuario IS 'FK a armius: usuario que realiza la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.direccion IS 'FK a armidi: direccion donde se prestara el servicio.';
COMMENT ON COLUMN cz_mi.armiso.fecha IS 'Fecha relevante de la solicitud (ej. de pedido o registro segun reglas de negocio).';
COMMENT ON COLUMN cz_mi.armiso.tipo IS 'FK a armisot: tipo de la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.estado IS 'FK a armisoe: estado actual de la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.descripcion IS 'Texto con el detalle o requerimiento de la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.factura IS 'Numero o identificador de factura, si aplica.';
COMMENT ON COLUMN cz_mi.armiso.empresa IS 'Nombre o detalle de empresa o cliente facturado, si aplica.';
COMMENT ON COLUMN cz_mi.armiso.subtotal IS 'Suma de lineas antes de descuento e impuestos, segun reglas de negocio.';
COMMENT ON COLUMN cz_mi.armiso.descuento IS 'Monto de descuento aplicado a la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.impuesto IS 'Monto de impuestos de la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.total IS 'Importe total de la solicitud (subtotal, descuento, impuestos: segun regla de negocio).';
COMMENT ON COLUMN cz_mi.armiso.cotizacion_servicio IS 'Referencia o URL del documento de cotizacion de servicio para la solicitud.';
COMMENT ON COLUMN cz_mi.armiso.factura_servicio IS 'Referencia o identificador de factura asociada al servicio cotizado, si aplica.';
COMMENT ON COLUMN cz_mi.armiso.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armiso.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armiso.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armiso.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armiso_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armius_armiso_fk FOREIGN KEY (usuario)
  REFERENCES cz_mi.armius (id);

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armidi_armiso_fk FOREIGN KEY (direccion)
  REFERENCES cz_mi.armidi (id);

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armisot_armiso_fk FOREIGN KEY (tipo)
  REFERENCES cz_mi.armisot (id);

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armisoe_armiso_fk FOREIGN KEY (estado)
  REFERENCES cz_mi.armisoe (id);


CREATE OR REPLACE
TRIGGER cz_mi.armiso_br
BEFORE INSERT OR UPDATE
ON cz_mi.armiso
REFERENCING NEW AS NEW
      OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.id := 'SOL-' || TO_CHAR(cz_mi.SQMIISO.NEXTVAL);
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


CREATE SEQUENCE cz_mi.SQMISOS
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de linea de servicio existente.


-- =============================================================================
-- TABLA: armisos - SOLICITUD_SERVICIO (satelite de SOLICITUD)
-- Descripcion: Detalle de servicios incluidos en cada solicitud.
-- =============================================================================
CREATE TABLE cz_mi.armisos (
  id                    NUMBER          NOT NULL,
  solicitud          VARCHAR2(40)    NOT NULL,
  categoria          VARCHAR2(36)    NOT NULL,
  no_arti            VARCHAR2(15)    NOT NULL,
  precio                NUMBER           NOT NULL,
  cantidad              NUMBER,
  fecha_crea        DATE            NOT NULL,
  fecha_modifica    DATE,
  usuario_crea      VARCHAR2(30)   NOT NULL,
  usuario_modifica  VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisos IS 'Detalle de servicios solicitados dentro de una solicitud. Permite que una solicitud incluya multiples servicios.';
COMMENT ON COLUMN cz_mi.armisos.id IS 'Identificador numerico de la linea de servicio (asignado en armisos_br con SQMISOS.NEXTVAL).';
COMMENT ON COLUMN cz_mi.armisos.solicitud IS 'FK a armiso: solicitud padre.';
COMMENT ON COLUMN cz_mi.armisos.categoria IS 'Codigo o clave de categoria de servicio (sin FK a catalogo; negocio/app).';
COMMENT ON COLUMN cz_mi.armisos.no_arti IS 'Numero o codigo de articulo para la linea de solicitud (hasta 15 caracteres).';
COMMENT ON COLUMN cz_mi.armisos.precio IS 'Precio del servicio al momento de ser incluido en la solicitud (precio historico).';
COMMENT ON COLUMN cz_mi.armisos.cantidad IS 'Cantidad de unidades del servicio en la linea de solicitud.';
COMMENT ON COLUMN cz_mi.armisos.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisos.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisos.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisos.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armisos_pk PRIMARY KEY (id) USING INDEX;

ALTER TABLE cz_mi.armisos
  ADD CONSTRAINT armiso_armisos_fk FOREIGN KEY (solicitud)
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
    :NEW.id := cz_mi.SQMISOS.NEXTVAL;
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




-- =============================================================================
-- TABLA: armicie - CITA_ESTADO (satelite de CITA)
-- Descripcion: Estados posibles de una cita.
-- =============================================================================
CREATE TABLE cz_mi.armicie (
  id                   VARCHAR2(1)    NOT NULL,
  nombre               VARCHAR2(100)   NOT NULL,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
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




-- =============================================================================
-- TABLA: armitc - TECNICO
-- Descripcion: Tecnicos disponibles para la ejecucion de servicios en citas.
-- Requiere: cz_in.arinmp para FK de no_prove.
-- =============================================================================
CREATE TABLE cz_mi.armitc (
  no_prove               NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
  identificacion         VARCHAR2(30)    NOT NULL,
  tipo_identificacion    VARCHAR2(1)     NOT NULL,
  nombre                 VARCHAR2(100)   NOT NULL,
  apellido               VARCHAR2(100)   NOT NULL,
  fecha_crea             DATE            NOT NULL,
  fecha_modifica         DATE,
  usuario_crea           VARCHAR2(30)    NOT NULL,
  usuario_modifica       VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armitc IS 'Tecnicos registrados en el sistema.';
COMMENT ON COLUMN cz_mi.armitc.no_prove IS 'Numero de proveedor (parte de PK compuesta; FK a cz_in.arinmp).';
COMMENT ON COLUMN cz_mi.armitc.identificacion IS 'Numero de documento de identidad (parte de PK local del tecnico).';
COMMENT ON COLUMN cz_mi.armitc.tipo_identificacion IS 'Tipo de documento (parte de PK local del tecnico).';
COMMENT ON COLUMN cz_mi.armitc.nombre IS 'Nombre o nombres del tecnico.';
COMMENT ON COLUMN cz_mi.armitc.apellido IS 'Apellido o apellidos del tecnico.';
COMMENT ON COLUMN cz_mi.armitc.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armitc.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armitc.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armitc.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armitc
  ADD CONSTRAINT armitc_pk PRIMARY KEY (no_prove, identificacion, tipo_identificacion) USING INDEX;

ALTER TABLE cz_mi.armitc
  ADD CONSTRAINT arinmp_armitc_fk FOREIGN KEY (no_prove)
  REFERENCES cz_in.arinmp (no_prove);


CREATE OR REPLACE
TRIGGER cz_mi.armitc_br
BEFORE INSERT OR UPDATE
ON cz_mi.armitc
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




CREATE SEQUENCE cz_mi.SQMICI
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de cita existente.


-- =============================================================================
-- TABLA: armici - CITA
-- Descripcion: Tabla principal de citas programadas para la ejecucion de servicios.
-- =============================================================================
CREATE TABLE cz_mi.armici (
  id                       NUMBER          NOT NULL,
  solicitud                VARCHAR2(40)    NOT NULL,
  servicio                 NUMBER          NOT NULL,
  estado                   VARCHAR2(1)     NOT NULL,
  no_prove                 NUMBER          NOT NULL,
  identificacion           VARCHAR2(30)    NOT NULL,
  tipo_identificacion      VARCHAR2(1)     NOT NULL,
  fecha_programada_inicio DATE            NOT NULL,
  fecha_programada_fin    DATE            NOT NULL,
  fecha_crea               DATE            NOT NULL,
  fecha_modifica           DATE,
  usuario_crea             VARCHAR2(30)    NOT NULL,
  usuario_modifica         VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armici IS 'Citas programadas para la ejecucion de un servicio especifico dentro de una solicitud. Vincula solicitud, servicio, tecnico y estado.';
COMMENT ON COLUMN cz_mi.armici.id IS 'Identificador numerico de la cita (asignado en trigger armici_br con SQMICI.NEXTVAL si viene nulo).';
COMMENT ON COLUMN cz_mi.armici.solicitud IS 'FK a armiso: solicitud asociada.';
COMMENT ON COLUMN cz_mi.armici.servicio IS 'FK a armisos (id numerico): linea de servicio concreta a ejecutar en la cita.';
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


CREATE OR REPLACE
TRIGGER cz_mi.armici_br
BEFORE INSERT OR UPDATE
ON cz_mi.armici
REFERENCING NEW AS NEW
      OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := cz_mi.SQMICI.NEXTVAL;
    END IF;
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


CREATE SEQUENCE cz_mi.SQMINO
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;
-- En migracion: ajustar START WITH al siguiente entero tras el max id de notificacion existente.


-- =============================================================================
-- TABLA: armino - NOTIFICACION
-- Descripcion: Notificaciones generadas y enviadas asociadas a solicitudes.
-- =============================================================================
CREATE TABLE cz_mi.armino (
  id                   NUMBER          NOT NULL,
  solicitud            VARCHAR2(40)    NOT NULL,
  asunto               VARCHAR2(500)   NOT NULL,
  cuerpo               VARCHAR2(4000)  NOT NULL,
  fecha_emision        DATE            NOT NULL,
  enviado              VARCHAR2(1)     DEFAULT 'N' NOT NULL,
  fecha_envio          DATE,
  fecha_crea       DATE            NOT NULL,
  fecha_modifica   DATE,
  usuario_crea     VARCHAR2(30)   NOT NULL,
  usuario_modifica VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armino IS 'Notificaciones generadas para los usuarios en relacion a sus solicitudes (email, push, etc.).';
COMMENT ON COLUMN cz_mi.armino.id IS 'Identificador numerico de la notificacion (asignado en armino_br con SQMINO.NEXTVAL).';
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
  ADD CONSTRAINT armiso_armino_fk FOREIGN KEY (solicitud)
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
    :NEW.id := cz_mi.SQMINO.NEXTVAL;
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




-- =============================================================================
-- FIN DEL SCRIPT
-- Pendiente de definicion:
--   - Scripts de datos iniciales para tablas de catalogos:
--       armitti (tipos de telefono)
--       armisot (tipos de solicitud)
--       armisoe (estados de solicitud)
--       armicie (estados de cita)
-- =============================================================================
