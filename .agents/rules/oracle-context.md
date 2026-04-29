# Reglas del Proyecto — Agente Oracle CAYD

## Contexto del proyecto

Este workspace contiene scripts DDL para base de datos Oracle siguiendo
los estándares de programación de CAYD (versión 1.0, May 2025).

## Stack tecnológico

- Motor de base de datos: Oracle
- Estándar de codificación: CAYD v1.0
- Documento de referencia: `.agents/skills/oracle-ddl/references/politicas-estandares.md`

## Principios no negociables

1. **Owner obligatorio** en cada sentencia DDL (nunca omitirlo).
2. **Constraints siempre separados** del CREATE TABLE.
3. **Toda tabla nueva** debe incluir campos de auditoría: FECHA_CREA, USUARIO_CREA,
   FECHA_MODIFICA, USUARIO_MODIFICA.
4. **Toda tabla nueva** debe incluir trigger de auditoría `_br`.
5. **Siempre** crear sinónimo después de cada objeto. Los **GRANT** se aplican según política de despliegue, no forman parte del estándar obligatorio de creación de tabla.
6. **Nunca** agregar cláusulas STORAGE.
7. Los scripts deben ser ejecutables en orden de arriba hacia abajo sin errores.
8. **Siempre** incluir script de rollback al final.

## Convención de respuesta

- Presentar el script completo como un Artifact revisable.
- Agregar comentarios de sección en el script: `-- ===== TABLA =====`
- Indicar explícitamente qué módulo y owner se están usando antes de generar.
- Si el esquema Mermaid no está actualizado, preguntar antes de asumir.

## Modelo recomendado por tarea

- Diseño de esquema complejo / múltiples tablas relacionadas → Claude Opus 4.6
- Generación de boilerplate / tablas simples → Gemini 3 Flash
- Revisión de estándares y naming → cualquier modelo
