-- V004__create_updated_at_triggers.sql
-- Keeps updated_at in sync on every UPDATE.

CREATE OR REPLACE FUNCTION appointment_scheduling.set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_appointments_updated_at
    BEFORE UPDATE ON appointment_scheduling.appointments
    FOR EACH ROW EXECUTE FUNCTION appointment_scheduling.set_updated_at();

CREATE TRIGGER trg_professional_availability_updated_at
    BEFORE UPDATE ON appointment_scheduling.professional_availability
    FOR EACH ROW EXECUTE FUNCTION appointment_scheduling.set_updated_at();
