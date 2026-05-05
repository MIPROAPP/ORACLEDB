-- =============================================================================
-- Datos iniciales: CZ_MI.ARMISOE (estados de solicitud)
-- Origen: catalogos/Catalogo_armisoe.md
-- Auditoria (FECHA_CREA, USUARIO_CREA, etc.) la completa el trigger ARMISOE_BR.
-- =============================================================================

INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('A', 'Nuevo');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('B', 'Levantamiento');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('C', 'Cotización');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('D', 'Aprobación y pago');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('E', 'Programado');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('F', 'En ejecución');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('G', 'En pausa');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('H', 'Finalizado');
INSERT INTO CZ_MI.ARMISOE (ID, NOMBRE) VALUES ('I', 'Cancelado');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM CZ_MI.ARMISOE
 WHERE ID IN ('A','B','C','D','E','F','G','H','I');
COMMIT;
*/
