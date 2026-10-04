-- V005__create_indexes.sql
-- Indexes for the queries the API will run.

-- Appointments by patient (only active ones)
CREATE INDEX idx_appointments_patient
    ON appointment_scheduling.appointments (patient_id)
    WHERE deleted_at IS NULL;

-- Appointments by professional (only active ones)
CREATE INDEX idx_appointments_professional
    ON appointment_scheduling.appointments (professional_id)
    WHERE deleted_at IS NULL;

-- Conflict detection: professional + time range
CREATE INDEX idx_appointments_professional_time
    ON appointment_scheduling.appointments (professional_id, start_time, end_time)
    WHERE deleted_at IS NULL AND status IN ('CONFIRMED', 'RESCHEDULED');

-- Filter by status
CREATE INDEX idx_appointments_status
    ON appointment_scheduling.appointments (status)
    WHERE deleted_at IS NULL;

-- Availability per professional
CREATE INDEX idx_professional_availability_professional
    ON appointment_scheduling.professional_availability (professional_id)
    WHERE active = true;
