-- V003__create_professional_availability.sql
-- Recurring weekly availability for professionals.
-- Availability is computed by the API from this + existing appointments.

CREATE TABLE appointment_scheduling.professional_availability (
    id              bigserial   PRIMARY KEY,
    professional_id bigint      NOT NULL,
    day_of_week     smallint    NOT NULL,
    start_time      time        NOT NULL,
    end_time        time        NOT NULL,
    active          boolean     NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT NOW(),
    updated_at      timestamptz NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_availability_day_of_week
        CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT chk_availability_time
        CHECK (end_time > start_time)
);
