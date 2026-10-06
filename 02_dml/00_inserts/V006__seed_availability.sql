-- V006__seed_availability.sql
-- Development seed: one professional with weekday morning availability.

INSERT INTO appointment_scheduling.professional_availability
    (professional_id, day_of_week, start_time, end_time)
VALUES
    (5001, 1, '08:00', '12:00'),
    (5001, 2, '08:00', '12:00'),
    (5001, 3, '08:00', '12:00'),
    (5001, 4, '08:00', '12:00'),
    (5001, 5, '08:00', '12:00')
ON CONFLICT DO NOTHING;
