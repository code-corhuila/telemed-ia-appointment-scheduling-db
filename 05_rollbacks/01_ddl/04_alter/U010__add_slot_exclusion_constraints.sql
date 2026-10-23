-- U010__add_slot_exclusion_constraints.sql
-- Rollback de V010.
--
-- Se eliminan las dos exclusion constraints. No se dropea btree_gist:
-- la extension es compartida por la instancia y puede estar en uso por
-- otra migracion o servicio.

ALTER TABLE appointment_scheduling.appointments
    DROP CONSTRAINT IF EXISTS ex_appointments_patient_slot;

ALTER TABLE appointment_scheduling.appointments
    DROP CONSTRAINT IF EXISTS ex_appointments_professional_slot;
