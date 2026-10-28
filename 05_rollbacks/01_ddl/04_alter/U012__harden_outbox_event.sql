-- U012__harden_outbox_event.sql
-- Rollback de V012.
--
-- Simetrico salvo el backfill de correlation_id NULL: las filas que
-- tenian NULL antes de V012 ahora tienen un UUID generado. Es aceptable
-- porque no habia datos productivos.
--
-- No se revierte el DEFAULT de correlation_id (se puede quitar antes
-- del DROP, pero es irrelevante si se elimina la columna completa).

DROP INDEX IF EXISTS appointment_scheduling.idx_outbox_event_event_type;
DROP INDEX IF EXISTS appointment_scheduling.idx_outbox_event_failed;

ALTER TABLE appointment_scheduling.outbox_event
    DROP CONSTRAINT IF EXISTS ck_outbox_event_attempts_non_negative;

ALTER TABLE appointment_scheduling.outbox_event
    DROP COLUMN IF EXISTS updated_at;

ALTER TABLE appointment_scheduling.outbox_event
    DROP COLUMN IF EXISTS last_error;

ALTER TABLE appointment_scheduling.outbox_event
    DROP COLUMN IF EXISTS attempts;

ALTER TABLE appointment_scheduling.outbox_event
    ALTER COLUMN correlation_id DROP NOT NULL;

ALTER TABLE appointment_scheduling.outbox_event
    ALTER COLUMN correlation_id DROP DEFAULT;

ALTER TABLE appointment_scheduling.outbox_event
    DROP CONSTRAINT IF EXISTS uq_outbox_event_event_id;

ALTER TABLE appointment_scheduling.outbox_event
    DROP COLUMN IF EXISTS event_id;
