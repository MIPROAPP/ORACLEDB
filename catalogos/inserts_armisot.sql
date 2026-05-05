-- =============================================================================
-- Datos iniciales: cz_mi.armisot (tipos de solicitud)
-- Origen: catalogos/Catalogo_armisot.md
-- Auditoria (fecha_crea, usuario_crea, etc.) la completa el trigger armisot_br.
-- =============================================================================

INSERT INTO cz_mi.armisot (id, nombre) VALUES ('A', 'Inspección');
INSERT INTO cz_mi.armisot (id, nombre) VALUES ('B', 'Instalación');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM cz_mi.armisot
 WHERE id IN ('A','B');
COMMIT;
*/
