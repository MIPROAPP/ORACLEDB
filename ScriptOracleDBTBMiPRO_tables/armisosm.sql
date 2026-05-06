-- =============================================================================
-- TABLA: armisosm - SOLICITUD_SERVICIO_MEDIA
-- Descripcion: Imagenes o archivos adjuntos a las lineas de servicio.
-- =============================================================================
CREATE SEQUENCE cz_mi.sqmisosm
MINVALUE 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
START WITH 1;

CREATE TABLE cz_mi.armisosm (
  media                   VARCHAR2(36)    NOT NULL,
  solicitud               VARCHAR2(36)    NOT NULL,
  linea                   NUMBER          NOT NULL,
  descripcion             VARCHAR2(1000),
  url                     VARCHAR2(2000)  NOT NULL,
  fecha_crea              DATE            NOT NULL,
  fecha_modifica          DATE,
  usuario_crea            VARCHAR2(30)    NOT NULL,
  usuario_modifica        VARCHAR2(30)
);

COMMENT ON TABLE cz_mi.armisosm IS 'Almacena referencias a archivos multimedia asociados a un servicio de una solicitud.';
COMMENT ON COLUMN cz_mi.armisosm.media IS 'Identificador unico del recurso multimedia.';
COMMENT ON COLUMN cz_mi.armisosm.solicitud IS 'solicitud padre';
COMMENT ON COLUMN cz_mi.armisosm.linea IS 'FK a armisos: linea de servicio padre.';
COMMENT ON COLUMN cz_mi.armisosm.descripcion IS 'Breve detalle del contenido de la imagen o archivo.';
COMMENT ON COLUMN cz_mi.armisosm.url IS 'Ruta de acceso o URL del archivo.';
COMMENT ON COLUMN cz_mi.armisosm.fecha_crea IS 'Fecha y hora de creacion del registro.';
COMMENT ON COLUMN cz_mi.armisosm.fecha_modifica IS 'Fecha y hora de la ultima modificacion.';
COMMENT ON COLUMN cz_mi.armisosm.usuario_crea IS 'Usuario que creo el registro (auditoria).';
COMMENT ON COLUMN cz_mi.armisosm.usuario_modifica IS 'Usuario de la ultima modificacion (auditoria).';

ALTER TABLE cz_mi.armisosm
  ADD CONSTRAINT armisosm_pk PRIMARY KEY (media) USING INDEX;

ALTER TABLE cz_mi.armisosm
  ADD CONSTRAINT armisosm_armisos_fk FOREIGN KEY (linea)
  REFERENCES cz_mi.armisos (linea);

CREATE OR REPLACE
TRIGGER cz_mi.armisosm_br
BEFORE INSERT OR UPDATE
ON cz_mi.armisosm
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.media            := cz_mi.sqmisosm.NEXTVAL;
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
