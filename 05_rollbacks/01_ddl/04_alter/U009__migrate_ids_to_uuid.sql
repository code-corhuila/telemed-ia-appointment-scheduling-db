-- U009__migrate_ids_to_uuid.sql
-- Rollback de V009.
--
-- IMPORTANTE: la reversión de tipo uuid -> bigint no es simétrica.
-- uuid no se puede convertir a bigint sin perder información.
-- Este script solo revierte lo que sí es reversible:
--   - elimina los índices añadidos en V009;
--   - deja las columnas en uuid (no las devuelve a bigint).
--
-- Para reconstruir el esquema original en dev, ejecutar manualmente:
--   psql -c "DROP SCHEMA appointment_scheduling CASCADE;"
-- y volver a aplicar todas las V desde V001.
--
-- flyway.cleanDisabled=true impide usar flyway clean.

DROP INDEX IF EXISTS appointment_scheduling.idx_appointments_id_professional;
DROP INDEX IF EXISTS appointment_scheduling.idx_appointments_id_patient;

-- No se revierte el tipo de columna:
--   ALTER COLUMN ... TYPE bigint USING ... no existe sin pérdida.
-- Documentar en el PR que la reversión de datos requiere procedimiento
-- manual y que, en este corte, no hay datos productivos.