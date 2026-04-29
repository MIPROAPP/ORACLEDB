# Oracle DDL Generator — CAYD Standards

## Description
Genera scripts DDL completos para Oracle siguiendo los estándares de programación
de CAYD. Se activa cuando el usuario solicita: crear tablas, estructuras de base de
datos, scripts SQL Oracle, DDL, constraints, índices, secuencias, vistas, sinónimos,
triggers de auditoría, o cualquier objeto de base de datos Oracle.

---

## Instructions

### ANTES de generar cualquier script

1. Leer `references/politicas-estandares.md` completo.
2. Identificar el módulo al que pertenece el objeto (FA, IN, CC, CP, IT, CG, CO, IM,
   BEE, CI, MS, SX, TL, etc.) y el owner correspondiente.
3. Si hay un esquema Mermaid disponible en `references/esquema-mermaid.md`, parsearlo
   para extraer entidades, atributos y relaciones antes de generar cualquier sentencia.

---

### Reglas obligatorias al generar DDL

#### TABLAS
- Nombre: `<tipo><módulo><función>`
  - `<tipo>`: AR (normal) | HI (histórica) | TM (temporal)
  - `<módulo>`: FA, IN, CC, CP, IT, CG, CO, IM, BEE, CI, MS, SX, TL, etc.
  - `<función>`: 2-3 letras. 2 letras = tabla principal, 3 letras = tabla satélite
  - Ejemplos: `ARITSO` (tabla principal), `ARITSOT` (tabla satélite)

- **Siempre incluir el owner** en cada sentencia (ej: `it53.aritafm`)
- **NO agregar cláusulas STORAGE**
- Campos de auditoría **obligatorios** en toda tabla:
  ```sql
  FECHA_CREA      DATE,
  USUARIO_CREA    VARCHAR2(30),
  FECHA_MODIFICA  DATE,
  USUARIO_MODIFICA VARCHAR2(30)
  ```
- Minimizar campos NULL. Nunca NULL en: campos llave, referencias, tipo, estado,
  descripcion, monto, precio, costo.
- Si la tabla tiene múltiples estados/tipos → crear tabla satélite obligatoria.
- Puede incluir INSERTs de registros iniciales al final del script.

#### CONSTRAINTS (en sentencias SEPARADAS del CREATE TABLE)
- **Primary Key**: `<tabla>_pk`, siempre con `USING INDEX`
  ```sql
  ALTER TABLE owner.tabla ADD CONSTRAINT tabla_pk PRIMARY KEY (campo)
  USING INDEX;
  ```
- **Foreign Key**: nombre `<tabla><tablareferenciada>`
  ```sql
  ALTER TABLE owner.tabla ADD CONSTRAINT tablaTablaRef
  FOREIGN KEY (campo) REFERENCES owner.tablaRef(campo);
  ```
- Índice por FK: opcional; si aplica, usar `<tabla><tablareferenciada>_fk` (criterio de DBA/performance)

#### ÍNDICES
- Si se crea índice de soporte a una FK, nombre sugerido: `<tabla><tablareferenciada>_fk` (no exigido por el estándar)
- Índices de performance/búsqueda: `<tabla>_<campoprincipal>_idx`

#### SINÓNIMO (obligatorio para tablas, vistas y secuencias)
```sql
CREATE OR REPLACE SYNONYM tabla FOR owner.tabla;
```

#### GRANTS (creación de tabla: no exigido por el estándar; aplicar según despliegue/seguridad)
```sql
-- Solo si el proyecto o el DBA lo requieren, por ejemplo:
-- GRANT SELECT, INSERT, UPDATE, DELETE ON owner.tabla TO PUBLIC;
-- Vistas y secuencias, si aplica:
-- GRANT SELECT ON owner.objeto TO PUBLIC;
```

#### COMENTARIOS (obligatorio en tablas)
```sql
COMMENT ON TABLE owner.tabla IS 'Descripción clara del uso de la tabla';
COMMENT ON COLUMN owner.tabla.campo IS 'Descripción del campo';
-- Excepciones sin comentario: NO_CIA, CENTRO, ESTADO
```

#### TRIGGER DE AUDITORÍA (obligatorio en toda tabla nueva)
Nomenclatura: `<tabla>_<momento><accion><fila>`
- `<momento>`: B (Before) | A (After)
- `<accion>`: I (Insert) | U (Update) | D (Delete) — omitir si aplica a más de una
- `<fila>`: R (EACH ROW) | omitir si no es row-level

```sql
CREATE OR REPLACE
TRIGGER owner.tabla_br
BEFORE INSERT OR UPDATE
ON owner.tabla
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.usuario_crea    := USER;
    :NEW.fecha_crea      := SYSDATE;
  ELSIF UPDATING THEN
    :NEW.usuario_modifica := USER;
    :NEW.fecha_modifica   := SYSDATE;
  END IF;
END;
/
```

#### SECUENCIAS
- Nombre: `SQ<módulo><función>`
- Crear sinónimo y GRANT SELECT TO PUBLIC.

#### VISTAS
- Nombre: `VW<módulo><función>`
- Crear sinónimo y GRANT SELECT TO PUBLIC.

---

### Orden de generación del script completo

1. `CREATE TABLE owner.tabla (...)`
2. `ALTER TABLE` — PRIMARY KEY
3. `ALTER TABLE` — FOREIGN KEYS
4. `CREATE INDEX` — según criterio de DBA/performance (FK, búsqueda, etc.)
5. `CREATE SYNONYM`
6. `COMMENT ON TABLE / COLUMN`
7. `CREATE SEQUENCE` (si aplica)
8. `CREATE OR REPLACE TRIGGER` (auditoría)
9. `INSERT` registros iniciales (si aplica)
10. `GRANT` (si aplica política de despliegue; no requerido por estándar de tablas)
11. `COMMIT;`

---

### Script de rollback (siempre al final)
```sql
-- ============================================================
-- ROLLBACK SCRIPT
-- ============================================================
DROP TRIGGER owner.tabla_br;
DROP TABLE owner.tabla CASCADE CONSTRAINTS;
DROP SYNONYM tabla;
DROP SEQUENCE owner.sqmodulofun; -- si aplica
```

---

### Catálogo de módulos

| Código | Descripción              |
|--------|--------------------------|
| BEE    | Beetrack                 |
| CI     | Maestro de Clientes      |
| FA     | Facturación              |
| HI     | Históricos               |
| IN     | Maestro de Artículos     |
| IT     | IT                       |
| MS     | Integraciones            |
| SX     | Sincronizaciones         |
| TL     | ETLs                     |

---

## References
- `references/politicas-estandares.md`   ← Documento oficial de estándares CAYD
- `references/esquema-mermaid.md`        ← Esquema de entidades del proyecto actual
