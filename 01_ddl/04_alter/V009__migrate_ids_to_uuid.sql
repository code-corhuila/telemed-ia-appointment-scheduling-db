-- V009__migrate_ids_to_uuid.sql
-- Migración de los identificadores de appointment-scheduling a UUID.
--
-- Motivo:
--   - identity-and-access emite UUID (sub del JWT).
--   - intelligent-agent-db exige UUID en appointmentId y patientId.
--   - Norma del curso: "camelCase JSON and UUID ids".
--
-- Alcance:
--   - appointments.id, patient_id, professional_id,
--     preconsultation_summary_id, post_summary_id  -> uuid
--   - professional_availability.id, professional_id -> uuid
--
-- Preservación de datos:
--   - appointments no tiene seed en este repo: los uuid se generan.
--   - professional_availability tiene seed 5001: se traduce a un uuid
--     determinista para que los tests y el portal sigan encontrándolo.
--
-- Orden por columna:
--   bigserial = bigint + DEFAULT nextval(...). PostgreSQL no puede castear
--   ese DEFAULT a uuid, así que primero se elimina el DEFAULT, luego se
--   cambia el tipo y luego se pone el nuevo DEFAULT gen_random_uuid().

-- ---------------------------------------------------------------------------
-- 1. appointments
-- ---------------------------------------------------------------------------

ALTER TABLE appointment_scheduling.appointments
    ALTER COLUMN id DROP DEFAULT;

ALTER TABLE appointment_scheduling.appointments
    ALTER COLUMN id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN patient_id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN professional_id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN preconsultation_summary_id TYPE uuid
        USING NULL,
    ALTER COLUMN post_summary_id TYPE uuid
        USING NULL;

ALTER TABLE appointment_scheduling.appointments
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 2. professional_availability
--    Preserva el seed 5001 como uuid fijo para que los tests sigan
--    encontrándolo.
-- ---------------------------------------------------------------------------

ALTER TABLE appointment_scheduling.professional_availability
    ALTER COLUMN id DROP DEFAULT;

ALTER TABLE appointment_scheduling.professional_availability
    ALTER COLUMN id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN professional_id TYPE uuid
        USING (
            CASE
                WHEN professional_id = 5001
                THEN '00000000-0000-0000-0000-000000005001'::uuid
                ELSE gen_random_uuid()
            END
        );

ALTER TABLE appointment_scheduling.professional_availability
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 3. Índices adicionales para ownership lookup
--    GET /api/appointments/{id} necesita validar patient_id o
--    professional_id contra el sub del JWT. Un índice compuesto acelera
--    esa comprobación y complementa los índices existentes de V005.
-- ---------------------------------------------------------------------------

CREATE INDEX idx_appointments_id_patient
    ON appointment_scheduling.appointments (id, patient_id)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_appointments_id_professional
    ON appointment_scheduling.appointments (id, professional_id)
    WHERE deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- Nota sobre V008:
--   El GRANT ... ON ALL SEQUENCES deja de aplicar porque ya no hay
--   secuencias en appointment_scheduling. No se revoca: es inofensivo y
--   revocarlo requeriría otro changeset.
-- ---------------------------------------------------------------------------