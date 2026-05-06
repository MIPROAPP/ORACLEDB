-- =============================================================================
-- TABLA: armiso - SOLICITUD
-- Descripcion: Tabla principal de solicitudes de servicio realizadas por usuarios.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmiiso
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armiso (
  id                      VARCHAR2(36)    NOT NULL,
  usuario                 VARCHAR2(36)    NOT NULL,
  direccion               VARCHAR2(36)    NOT NULL,
  fecha                   DATE            NOT NULL,
  tipo                    VARCHAR2(36)    NOT NULL,
  estado                  VARCHAR2(36)    NOT NULL,
  descripcion             VARCHAR2(2000)  NOT NULL,
  factura                 VARCHAR2(100),
  empresa                 VARCHAR2(200),
  subtotal                NUMBER          NOT NULL,
  descuento               NUMBER          DEFAULT 0 NOT NULL,
  impuesto                NUMBER          DEFAULT 0 NOT NULL,
  total                   NUMBER          NOT NULL,
  cotizacion_servicio     VARCHAR2(50),
  factura_servicio        VARCHAR2(50),
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armiso IS 'Tabla principal de solicitudes de servicio. Registra cada pedido realizado por un usuario para uno o varios servicios.';
COMMENT ON COLUMN cz_mi.armiso.id IS 'Identificador de solicitud: prefijo SOL- y numero generado por sqmiiso (ej. SOL-123).';
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
  ADD CONSTRAINT armiso_armisot_fk FOREIGN KEY (tipo)
  REFERENCES cz_mi.armisot (id);

ALTER TABLE cz_mi.armiso
  ADD CONSTRAINT armiso_armisoe_fk FOREIGN KEY (estado)
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
    :NEW.id               := 'SOL-' || TO_CHAR(cz_mi.sqmiiso.NEXTVAL);
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


