-- V008__grant_permissions.sql
-- The domain grants its own users access to its own schema.

GRANT USAGE ON SCHEMA appointment_scheduling
    TO appointment_scheduling_reader, appointment_scheduling_writer;

GRANT SELECT ON ALL TABLES IN SCHEMA appointment_scheduling
    TO appointment_scheduling_reader;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA appointment_scheduling
    TO appointment_scheduling_writer;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA appointment_scheduling
    TO appointment_scheduling_writer;
