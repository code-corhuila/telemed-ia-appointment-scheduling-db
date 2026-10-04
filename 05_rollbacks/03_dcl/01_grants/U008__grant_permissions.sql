REVOKE ALL ON ALL TABLES IN SCHEMA appointment_scheduling
    FROM appointment_scheduling_reader, appointment_scheduling_writer;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA appointment_scheduling
    FROM appointment_scheduling_writer;
REVOKE ALL ON SCHEMA appointment_scheduling
    FROM appointment_scheduling_reader, appointment_scheduling_writer;
