-- =============================================================================
-- Datos iniciales: cz_mi.armisoe (estados de solicitud)
-- Origen: catalogos/Catalogo_armisoe.md
-- Auditoria (fecha_crea, usuario_crea, etc.) la completa el trigger armisoe_br.
-- =============================================================================

INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('A', 'Nuevo');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('B', 'Levantamiento');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('C', 'Cotización');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('D', 'Aprobación y pago');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('E', 'Programado');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('F', 'En ejecución');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('G', 'En pausa');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('H', 'Finalizado');
INSERT INTO cz_mi.armisoe (estado, nombre) VALUES ('I', 'Cancelado');

COMMIT;

-- -----------------------------------------------------------------------------
-- Rollback de la carga inicial (ejecutar solo si se debe revertir este script)
-- -----------------------------------------------------------------------------
/*
DELETE FROM cz_mi.armisoe
 WHERE estado IN ('A','B','C','D','E','F','G','H','I');
COMMIT;
*/
