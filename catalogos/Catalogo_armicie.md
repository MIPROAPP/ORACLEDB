# INSERT SPEC: `CZ_MI.ARMICIE`

## Instrucciones para el agente

- Generar un script SQL de INSERT para Oracle a partir de esta especificación.
- Respetar los tipos de dato indicados: usar `TO_DATE`, `NULL`, etc. según corresponda.
- Si el valor es `<<NULL>>`, usar `NULL`.
- Si el valor tiene el prefijo `<<EXPR>>`, insertarlo como expresión SQL literal sin comillas.
- Los valores de tipo `VARCHAR2` / `CHAR` deben ir entre comillas simples.
- Los valores de tipo `NUMBER` van sin comillas.
- Formato de fecha: `TO_DATE('YYYY-MM-DD', 'YYYY-MM-DD')` cuando se inserte explícitamente una fecha.
- La tabla tiene trigger `CZ_MI.ARMICIE_BR`: en **INSERT** asigna `USUARIO_CREA`, `FECHA_CREA`, `USUARIO_MODIFICA` y `FECHA_MODIFICA`; en **UPDATE** actualiza `USUARIO_MODIFICA` y `FECHA_MODIFICA`. Para cargas iniciales, incluir en el INSERT solo las columnas de negocio (`ID`, `NOMBRE`) y dejar que el trigger complete auditoría.
- Al final del script agregar `COMMIT;`.

---

## Tabla destino

| Atributo | Valor        |
| -------- | ------------ |
| Esquema  | `CZ_MI`      |
| Tabla    | `ARMICIE`    |
| Sequence | No aplica (PK `ID` es `VARCHAR2(1)`) |

**Descripción:** Catálogo de estados de cita según el flujo operativo acordado.

---

## Definición de columnas

| Columna            | Tipo Oracle   | Nulable | Notas                                                                 |
| ------------------ | ------------- | ------- | --------------------------------------------------------------------- |
| `ID`               | VARCHAR2(1)   | No      | PK. Código de catálogo de un carácter; clave del estado de cita.    |
| `NOMBRE`           | VARCHAR2(100) | No      | Nombre o descripción del estado de cita (pantallas e informes).       |
| `FECHA_CREA`       | DATE          | No      | Auditoría; el trigger la asigna en INSERT (`SYSDATE`).              |
| `FECHA_MODIFICA`   | DATE          | Sí      | Auditoría; el trigger la asigna en INSERT y UPDATE.                   |
| `USUARIO_CREA`     | VARCHAR2(30)  | No      | Auditoría; el trigger usa `USER` en INSERT.                         |
| `USUARIO_MODIFICA` | VARCHAR2(30)  | Sí      | Auditoría; el trigger usa `USER` en INSERT y UPDATE.                  |

**Constraint:** `ARMICIE_PK` PRIMARY KEY (`ID`).

---

## Filas a insertar

Los códigos `ID` son un solo carácter (`VARCHAR2(1)`): secuencia **`A` … `J`** (abecedario en orden alfabético), asignada en el orden del flujo operativo de la tabla siguiente.

Solo se especifican datos de negocio; auditoría la completa el trigger `ARMICIE_BR`.

| ID | NOMBRE          |
| -- | --------------- |
| A  | Nuevo           |
| B  | Coordinado      |
| C  | Programado      |
| D  | Reprogramado    |
| E  | En camino       |
| F  | En progreso     |
| G  | En pausa        |
| H  | En cotización   |
| I  | Finalizado      |
| J  | Cancelado       |

> **Nota:** No incluir en la tabla de filas `FECHA_CREA`, `FECHA_MODIFICA`, `USUARIO_CREA` ni `USUARIO_MODIFICA`: sus valores los establece el trigger al insertar.

---

## Valores fijos / comportamiento (trigger)

| Aspecto              | Comportamiento                                                          |
| -------------------- | ----------------------------------------------------------------------- |
| `FECHA_CREA`         | Asignada por trigger (`SYSDATE` en INSERT).                             |
| `USUARIO_CREA`       | Asignada por trigger (`USER` en INSERT).                                |
| `FECHA_MODIFICA`     | Asignada por trigger (`SYSDATE` en INSERT y UPDATE).                    |
| `USUARIO_MODIFICA`   | Asignada por trigger (`USER` en INSERT y UPDATE).                       |

---

## Output esperado (referencia)

```sql
INSERT INTO CZ_MI.ARMICIE (
    ID,
    NOMBRE
) VALUES (
    'A',
    'Nuevo'
);
-- Repetir para ID 'B'..'J' y los nombres de la tabla anterior; luego:
COMMIT;
```
