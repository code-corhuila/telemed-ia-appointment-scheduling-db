-- V010__add_slot_exclusion_constraints.sql
-- Defense in depth against double-booking.
--
-- Motivo:
--   - create/reschedule ya validan solapamiento en la API, pero la
--     validacion es a nivel de aplicacion y no protege contra dos
--     requests concurrentes.
--   - PostgreSQL EXCLUDE USING gist garantiza la regla incluso bajo
--     concurrencia.
--   - El analisis del equipo detecto ademas que faltaba la regla por
--     paciente (solo se validaba professional_id).
--
-- Requiere btree_gist. Se instala en
-- telemed-ia-infra-postgres/postgres/init/01-instance.sh como
-- superusuario. El CREATE EXTENSION IF NOT EXISTS de aqui es
-- defensivo: si ya existe (caso normal), es no-op; si falta y el rol
-- no puede crearla, la migracion falla con un mensaje claro y el
-- operador sabe que debe correr 01-instance.sh primero.
--
-- Rango: tstzrange(start_time, end_time) usa [start, end) por defecto,
-- asi que 10:00-10:30 y 10:30-11:00 no colisionan (back-to-back
-- permitido).
--
-- Predicado: solo CONFIRMED y RESCHEDULED, y solo filas activas
-- (deleted_at IS NULL). CANCELLED, COMPLETED y NO_SHOW no bloquean.
--
-- Riesgo: si el entorno ya tiene datos que violan la regla, el
-- ALTER ... ADD CONSTRAINT falla y hay que limpiar antes. En este
-- corte no hay datos productivos.

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE appointment_scheduling.appointments
    ADD CONSTRAINT ex_appointments_professional_slot
    EXCLUDE USING gist (
        professional_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    )
    WHERE (status IN ('CONFIRMED', 'RESCHEDULED') AND deleted_at IS NULL);

ALTER TABLE appointment_scheduling.appointments
    ADD CONSTRAINT ex_appointments_patient_slot
    EXCLUDE USING gist (
        patient_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    )
    WHERE (status IN ('CONFIRMED', 'RESCHEDULED') AND deleted_at IS NULL);
