# Estándares de Programación Oracle — CAYD
> Versión 1.0 | Creado por: @Hernan Caballero | May 22, 2025

---

## ESTRUCTURAS (ORACLE)

> **Regla global:** Todos los scripts de estructura deben llevar el owner
> obligatoriamente en cada sentencia.

---

### Packages

1. No se deben crear Procedures o Functions sueltos. Todo debe ir en Packages.
2. Nombre del package: `SK<módulo>_<función>`
   - `<módulo>`: FA, IN, CC, CP, IT, CG, CO, IM, etc.
   - `<función>`: palabra que indica la funcionalidad del módulo.
   - Hay packages que no necesitan función: SKWM, SKIT, SKCK.
3. Los comentarios de cada función/procedimiento van en el encabezado del package.
4. Los nombres de funciones y procedimientos deben ser sencillos y representativos.
5. Todo procedimiento debe tener una variable `P_ERROR` de salida que retorne el error.
6. En lo posible el procedimiento debe hacer ROLLBACK de los cambios que originó,
   con excepción de los llamados desde triggers.

---

### Tablas

**Nomenclatura:** `<tipo><módulo><función>`

| Segmento    | Valores posibles                                       |
|-------------|--------------------------------------------------------|
| `<tipo>`    | AR (normal), HI (histórica), TM (temporal)             |
| `<módulo>`  | FA, IN, CC, CP, IT, CG, CO, IM, BEE, CI, MS, SX, TL  |
| `<función>` | 2 letras = tabla principal, 3 letras = tabla satélite  |

Ejemplo: `ARITSO` = solicitud de soporte IT (principal), `ARITSOT` = tipo de solicitud (satélite).

**Reglas:**

1. Minimizar campos con valores nulos. Nunca NULL en: campos llave, referencias,
   tipo, estado, descripción, monto, precio, costo.
2. No agregar cláusulas STORAGE.
3. Los constraints van en sentencias SEPARADAS del CREATE TABLE.
   Nomenclatura de foreign key: `<tabla><tablaReferenciada>`.
4. Crear sinónimo para la tabla.
5. Primary key: `<tabla>_pk`, siempre con `USING INDEX`.
6. Comentario obligatorio en la tabla. Comentario obligatorio en columnas con funcionalidad específica.
   Excepciones sin comentario de columna: NO_CIA, CENTRO, ESTADO.
7. Tabla con múltiples estados/tipos → tabla satélite obligatoria con la descripción.
8. El script puede incluir INSERT de registros iniciales.
9. Campos de auditoría mínimos en TODA tabla:
    - `FECHA_CREA`
    - `USUARIO_CREA`
    - `FECHA_MODIFICA`
    - `USUARIO_MODIFICA`
10. Índices adicionales (performance/búsqueda): `<tabla>_<campoPrincipal>_idx`
11. Nomenclatura de triggers: `<tabla>_<momento><accion><fila>`
    - `<momento>`: B (Before), A (After)
    - `<accion>`: I (Insert), U (Update), D (Delete) — omitir si aplica a más de una
    - `<fila>`: R (EACH ROW) — omitir si no es row-level
12. Minimizar la cantidad de triggers sobre una tabla.
13. Trigger de auditoría mínimo obligatorio en toda tabla nueva:

```sql
CREATE OR REPLACE
TRIGGER owner.tabla_br
BEFORE INSERT OR UPDATE
ON owner.tabla
REFERENCING NEW AS NEW
            OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.usuario_crea     := USER;
    :NEW.fecha_crea       := SYSDATE;
  ELSIF UPDATING THEN
    :NEW.usuario_modifica := USER;
    :NEW.fecha_modifica   := SYSDATE;
  END IF;
END;
/
```

---

### Vistas

- Nombre: `VW<módulo><función>`
- Crear sinónimo y GRANT SELECT TO PUBLIC.

### Secuencias

- Nombre: `SQ<módulo><función>`
- Crear sinónimo y GRANT SELECT TO PUBLIC.

---

## PL/SQL (ORACLE)

1. **La indentación es obligatoria.** Evitar tabulaciones (usar espacios).
2. Usar `v_step` para manejo de errores (evita traps por anidamiento).
3. Todo procedimiento debe llevar SAVEPOINT y ROLLBACK donde sea posible.
   Excepción: procedimientos llamados desde triggers.
4. Comentarios concisos. Comentarios extensos van en el encabezado del package.
5. No abusar de BEGIN/END. Solo usar con DECLARE (variables) o EXCEPTION (manejo especial).
6. Evitar WHEN OTHERS sin emitir mensaje de error. Nunca enmascarar errores silenciosamente.
7. Cursores definidos en línea (no usar FETCH, no definir en DECLARE).

---

## Catálogo de módulos

| Código | Descripción           |
|--------|-----------------------|
| BEE    | Beetrack              |
| CI     | Maestro de Clientes   |
| FA     | Facturación           |
| HI     | Históricos            |
| IN     | Maestro de Artículos  |
| IT     | IT                    |
| MS     | Integraciones         |
| SX     | Sincronizaciones      |
| TL     | ETLs                  |
