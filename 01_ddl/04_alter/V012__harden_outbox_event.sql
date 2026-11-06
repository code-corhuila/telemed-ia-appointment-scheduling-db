-- V012__harden_outbox_event.sql
-- Endurece appointment_scheduling.outbox_event tras V011.
--
-- Motivo:
--   - V011 dejó correlation_id nullable; el poller de Go en Consultation
--     ha demostrado que un NULL/string vacío rompe la trazabilidad.
--   - V011 no tiene event_id; el envelope ADR-011 exige un UUID publico
--     para idempotencia downstream (distinto del id interno de la fila).
--   - V011 no tiene attempts ni last_error; el OutboxPoller no puede
--     hacer backoff ni marcar FAILED tras N intentos.
--   - V011 no tiene updated_at; no se puede saber cuando cambio el status.
--
-- Alcance:
--   - ALTER TABLE appointment_scheduling.outbox_event
--       ADD COLUMN event_id uuid NOT NULL DEFAULT gen_random_uuid()
--       ADD CONSTRAINT uq_outbox_event_event_id UNIQUE (event_id)
--       ALTER COLUMN correlation_id SET DEFAULT gen_random_uuid()::text
--       ALTER COLUMN correlation_id SET NOT NULL
--       ADD COLUMN attempts int NOT NULL DEFAULT 0
--       ADD COLUMN last_error text
--       ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now()
--   - Backfill: si existen filas con correlation_id NULL, se genera uno.
--   - Índices: idx_outbox_event_failed (status='FAILED') e
--     idx_outbox_event_event_type.
--
-- Compatibilidad:
--   - Las filas existentes reciben event_id aleatorio, correlation_id si
--     eran NULL, attempts=0 y updated_at=now().
--   - El codigo Python que inserta en outbox_event debe actualizarse en
--     el PR de API para escribir event_id y correlation_id. Mientras no
--     se actualice, el INSERT usa el DEFAULT para ambas columnas.
--
-- Reversion: ver U012. La reversion es simetrica (DROP de columnas y
-- constraints), salvo que se hayan perdido los valores originales de
-- correlation_id NULL (que ya no importan).

-- ---------------------------------------------------------------------------
-- 1. Backfill de correlation_id NULL (previo al SET NOT NULL)
-- ---------------------------------------------------------------------------
UPDATE appointment_scheduling.outbox_event
SET correlation_id = gen_random_uuid()::text
WHERE correlation_id IS NULL;

-- ---------------------------------------------------------------------------
-- 2. event_id (UUID publico, unico, para idempotencia downstream)
-- ---------------------------------------------------------------------------
ALTER TABLE appointment_scheduling.outbox_event
    ADD COLUMN event_id uuid NOT NULL DEFAULT gen_random_uuid();

ALTER TABLE appointment_scheduling.outbox_event
    ADD CONSTRAINT uq_outbox_event_event_id UNIQUE (event_id);

-- ---------------------------------------------------------------------------
-- 3. correlation_id NOT NULL + DEFAULT
-- ---------------------------------------------------------------------------
ALTER TABLE appointment_scheduling.outbox_event
    ALTER COLUMN correlation_id SET DEFAULT gen_random_uuid()::text;

ALTER TABLE appointment_scheduling.outbox_event
    ALTER COLUMN correlation_id SET NOT NULL;

-- ---------------------------------------------------------------------------
-- 4. attempts, last_error, updated_at
-- ---------------------------------------------------------------------------
ALTER TABLE appointment_scheduling.outbox_event
    ADD COLUMN attempts int NOT NULL DEFAULT 0;

ALTER TABLE appointment_scheduling.outbox_event
    ADD COLUMN last_error text;

ALTER TABLE appointment_scheduling.outbox_event
    ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();

ALTER TABLE appointment_scheduling.outbox_event
    ADD CONSTRAINT ck_outbox_event_attempts_non_negative CHECK (attempts >= 0);

-- ---------------------------------------------------------------------------
-- 5. Índices adicionales
-- ---------------------------------------------------------------------------
CREATE INDEX idx_outbox_event_failed
    ON appointment_scheduling.outbox_event (created_at)
    WHERE status = 'FAILED';

CREATE INDEX idx_outbox_event_event_type
    ON appointment_scheduling.outbox_event (event_type);
