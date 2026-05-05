# INSERT SPEC: `CZ_MI.ARMISOT`

## Instrucciones para el agente

- Generar un script SQL de INSERT para Oracle a partir de esta especificación.
- Respetar los tipos de dato indicados: usar `TO_DATE`, `NULL`, etc. según corresponda.
- Si el valor es `<<NULL>>`, usar `NULL`.
- Si el valor tiene el prefijo `<<EXPR>>`, insertarlo como expresión SQL literal sin comillas.
- Los valores de tipo `VARCHAR2` / `CHAR` deben ir entre comillas simples.
- Los valores de tipo `NUMBER` van sin comillas.
- Formato de fecha: `TO_DATE('YYYY-MM-DD', 'YYYY-MM-DD')` cuando se inserte explícitamente una fecha.
- La tabla tiene trigger `CZ_MI.ARMISOT_BR`: en **INSERT** asigna `USUARIO_CREA`, `FECHA_CREA`, `USUARIO_MODIFICA` y `FECHA_MODIFICA`; en **UPDATE** actualiza `USUARIO_MODIFICA` y `FECHA_MODIFICA`. Para cargas iniciales, incluir en el INSERT solo las columnas de negocio (`ID`, `NOMBRE`) y dejar que el trigger complete auditoría.
- Al final del script agregar `COMMIT;`.

---

## Tabla destino

| Atributo | Valor        |
| -------- | ------------ |
| Esquema  | `CZ_MI`      |
| Tabla    | `ARMISOT`    |
| Sequence | No aplica (PK `ID` es `VARCHAR2(1)`) |

**Descripción:** Catálogo de tipos de solicitud; define la naturaleza de cada solicitud registrada.

---

## Definición de columnas

| Columna            | Tipo Oracle   | Nulable | Notas                                                                 |
| ------------------ | ------------- | ------- | --------------------------------------------------------------------- |
| `ID`               | VARCHAR2(1)   | No      | PK. Código de catálogo de un carácter; clave del tipo de solicitud.   |
| `NOMBRE`           | VARCHAR2(100) | No      | Nombre o descripción legible del tipo de solicitud.                   |
| `FECHA_CREA`       | DATE          | No      | Auditoría; el trigger la asigna en INSERT (`SYSDATE`).                |
| `FECHA_MODIFICA`   | DATE          | Sí      | Auditoría; el trigger la asigna en INSERT y UPDATE.                     |
| `USUARIO_CREA`     | VARCHAR2(30)  | No      | Auditoría; el trigger usa `USER` en INSERT.                           |
| `USUARIO_MODIFICA` | VARCHAR2(30)  | Sí      | Auditoría; el trigger usa `USER` en INSERT y UPDATE.                   |

**Constraint:** `ARMISOT_PK` PRIMARY KEY (`ID`).

---

## Filas a insertar

Los códigos `ID` son un solo carácter (`VARCHAR2(1)`): secuencia **`A` … `B`** (abecedario en orden alfabético). Los tipos siguen el orden alfabético del nombre (`Inspección` antes que `Instalación`).

Solo se especifican datos de negocio; auditoría la completa el trigger `ARMISOT_BR`.

| ID | NOMBRE      |
| -- | ----------- |
| A  | Inspección  |
| B  | Instalación |

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
INSERT INTO CZ_MI.ARMISOT (
    ID,
    NOMBRE
) VALUES (
    'A',
    'Inspección'
);
INSERT INTO CZ_MI.ARMISOT (
    ID,
    NOMBRE
) VALUES (
    'B',
    'Instalación'
);
COMMIT;
```
