-- V002__create_appointments.sql
-- Root aggregate: a scheduled medical appointment.
-- No foreign keys here; they are added in V004.

CREATE TABLE appointment_scheduling.appointments (
    id                          bigserial   PRIMARY KEY,
    patient_id                  bigint      NOT NULL,
    professional_id             bigint      NOT NULL,
    preconsultation_summary_id  bigint,
    post_summary_id             bigint,
    start_time                  timestamptz NOT NULL,
    end_time                    timestamptz NOT NULL,
    status                      text        NOT NULL DEFAULT 'CONFIRMED',
    cancellation_reason         text,
    created_at                  timestamptz NOT NULL DEFAULT NOW(),
    updated_at                  timestamptz NOT NULL DEFAULT NOW(),
    deleted_at                  timestamptz,
    CONSTRAINT chk_appointments_status
        CHECK (status IN ('CONFIRMED', 'RESCHEDULED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    CONSTRAINT chk_appointments_time
        CHECK (end_time > start_time)
);
