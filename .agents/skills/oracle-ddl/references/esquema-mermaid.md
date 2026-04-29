# Esquema de Base de Datos — [Nombre del Proyecto]

> **INSTRUCCIÓN:** Reemplazá este archivo con tu esquema Mermaid real.
> El agente leerá este archivo para identificar entidades, atributos y relaciones
> antes de generar cualquier script DDL.

## Esquema Entidad-Relación

```mermaid
erDiagram
    %% Reemplazá este bloque con tu esquema real
    %% Ejemplo:

    ARITSO {
        NUMBER  no_cia          PK
        NUMBER  no_solicitud    PK
        VARCHAR2 descripcion
        VARCHAR2 estado
        VARCHAR2 tipo
        DATE    fecha_crea
        VARCHAR2 usuario_crea
        DATE    fecha_modifica
        VARCHAR2 usuario_modifica
    }

    ARITSOT {
        NUMBER  no_cia      PK
        VARCHAR2 tipo       PK
        VARCHAR2 descripcion
    }

    ARITSO ||--o{ ARITSOT : "tipo"
```

## Notas del esquema

- Owner del esquema: `[it53 / fa01 / etc.]`
- Módulo: `[IT / FA / IN / etc.]`
- Descripción del proyecto: [descripción breve]
