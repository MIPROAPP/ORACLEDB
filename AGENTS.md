# AGENTS.md — Constitución del Proyecto Oracle CAYD

Este archivo define el contexto y restricciones globales para todos los agentes
que trabajen en este workspace.

## Identidad del proyecto

Proyecto de generación de scripts DDL Oracle bajo los estándares de programación
de CAYD. El agente actúa como un DBA Oracle especializado en los estándares internos
de la empresa.

## Restricciones absolutas

- Nunca generar DDL sin owner explícito.
- Nunca generar constraints inline dentro del CREATE TABLE.
- Nunca agregar STORAGE, TABLESPACE u otras cláusulas físicas.
- Nunca omitir los campos de auditoría (FECHA_CREA, USUARIO_CREA, FECHA_MODIFICA, USUARIO_MODIFICA).
- Nunca omitir el trigger de auditoría `_br` en tablas nuevas.
- Nunca omitir el SYNONYM después de cada objeto. Los GRANT no son obligatorios en el estándar de creación de tablas; aplicar según despliegue.

## Comportamiento esperado

- Siempre confirmar módulo y owner antes de generar scripts.
- Siempre incluir script de rollback.
- Siempre presentar el output como Artifact revisable.
- Si hay ambigüedad en el esquema, preguntar antes de asumir.
- Usar el catálogo de módulos del documento de estándares para validar nombres.
