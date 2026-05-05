-- =============================================================================
-- Datos iniciales: CZ_MI.ARMICIE (estados de cita)
-- Origen: catalogos/Catalogo_armicie.md
-- Auditoria (FECHA_CREA, USUARIO_CREA, etc.) la completa el trigger ARMICIE_BR.
-- =============================================================================

INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('A', 'Nuevo');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('B', 'Coordinado');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('C', 'Programado');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('D', 'Reprogramado');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('E', 'En camino');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('F', 'En progreso');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('G', 'En pausa');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('H', 'En cotización');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('I', 'Finalizado');
INSERT INTO CZ_MI.ARMICIE (ID, NOMBRE) VALUES ('J', 'Cancelado');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM CZ_MI.ARMICIE
 WHERE ID IN ('A','B','C','D','E','F','G','H','I','J');
COMMIT;
*/
