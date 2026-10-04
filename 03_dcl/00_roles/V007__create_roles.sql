-- V007__create_roles.sql
-- Roles of the domain. Users are created by the infrastructure (Anexo J.7).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'appointment_scheduling_reader') THEN
        CREATE ROLE appointment_scheduling_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'appointment_scheduling_writer') THEN
        CREATE ROLE appointment_scheduling_writer NOLOGIN;
    END IF;
END$$;
