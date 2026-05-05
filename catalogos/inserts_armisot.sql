-- =============================================================================
-- Datos iniciales: CZ_MI.ARMISOT (tipos de solicitud)
-- Origen: catalogos/Catalogo_armisot.md
-- Auditoria (FECHA_CREA, USUARIO_CREA, etc.) la completa el trigger ARMISOT_BR.
-- =============================================================================

INSERT INTO CZ_MI.ARMISOT (ID, NOMBRE) VALUES ('A', 'Inspección');
INSERT INTO CZ_MI.ARMISOT (ID, NOMBRE) VALUES ('B', 'Instalación');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM CZ_MI.ARMISOT
 WHERE ID IN ('A','B');
COMMIT;
*/
