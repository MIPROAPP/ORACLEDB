# /revisar-estandares

Revisá un script DDL existente y verificá que cumple con todos los estándares CAYD.

## Pasos del agente

1. Leer `references/politicas-estandares.md`.
2. Analizar el script proporcionado por el usuario.
3. Generar un reporte con:
   - ✅ Estándares cumplidos
   - ❌ Violaciones encontradas (con número de línea y corrección sugerida)
   - ⚠️  Recomendaciones (mejoras opcionales)
4. Si hay violaciones, preguntar si se desea generar la versión corregida.
