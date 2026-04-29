# /generar-ddl

Generá el script DDL completo para Oracle siguiendo los estándares CAYD.

## Pasos del agente

1. **Leer** `references/politicas-estandares.md` y `references/esquema-mermaid.md`.
2. **Identificar** el módulo, owner y las entidades del esquema.
3. **Listar** todas las tablas a crear con su nombre según nomenclatura CAYD.
4. **Confirmar** la lista con el usuario antes de generar el script completo.
5. **Generar** el script en el siguiente orden para cada tabla:
   - CREATE TABLE (con campos de auditoría)
   - ALTER TABLE PRIMARY KEY (con USING INDEX)
   - ALTER TABLE FOREIGN KEYS
   - CREATE INDEX (según criterio DBA/performance; el estándar de tablas no exige GRANT a PUBLIC ni un índice por cada FK)
   - CREATE SYNONYM
   - COMMENT ON TABLE / COLUMN
   - CREATE SEQUENCE (si aplica)
   - CREATE TRIGGER de auditoría (_br)
   - INSERT registros iniciales (si aplica)
   - COMMIT
6. **Agregar** script de ROLLBACK al final.
7. **Presentar** como Artifact para revisión.

## Información que necesito para comenzar

- ¿Cuál es el módulo? (IT, FA, IN, CC, etc.)
- ¿Cuál es el owner del esquema? (ej: it53, fa01)
- ¿Hay esquema Mermaid actualizado en references/?
