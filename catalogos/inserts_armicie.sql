-- =============================================================================
-- Datos iniciales: cz_mi.armicie (estados de cita)
-- Origen: catalogos/Catalogo_armicie.md
-- Auditoria (fecha_crea, usuario_crea, etc.) la completa el trigger armicie_br.
-- =============================================================================

INSERT INTO cz_mi.armicie (id, nombre) VALUES ('A', 'Nuevo');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('B', 'Coordinado');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('C', 'Programado');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('D', 'Reprogramado');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('E', 'En camino');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('F', 'En progreso');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('G', 'En pausa');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('H', 'En cotización');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('I', 'Finalizado');
INSERT INTO cz_mi.armicie (id, nombre) VALUES ('J', 'Cancelado');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM cz_mi.armicie
 WHERE id IN ('A','B','C','D','E','F','G','H','I','J');
COMMIT;
*/
