-- V001__create_schema_appointment_scheduling.sql
-- Creates the dedicated schema for the appointment-scheduling domain.
-- Per Anexo J.3.2, this domain writes only to its own schema.

CREATE SCHEMA IF NOT EXISTS appointment_scheduling;
