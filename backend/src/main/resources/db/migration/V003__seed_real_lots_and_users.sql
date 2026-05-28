-- V003: Replace fake NYC seed data with real UniPark campus data (El Salvador)
-- Parking lot coordinates: Universidad campus, San Salvador

-- Remove fake NYC lots from V002
DELETE FROM parking_lots WHERE name IN ('Main Campus Garage', 'West Lot', 'South Deck');

-- ─────────────────────────────────────────────
-- PARKING LOTS (coordenadas reales del campus)
-- ─────────────────────────────────────────────

INSERT INTO parking_lots (id, name, capacity_total, capacity_used, version, geo, active) VALUES
(
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Parqueo Key',
    200,
    0,
    0,
    ST_GeographyFromText('SRID=4326;POINT(-89.253714 13.680524)'),
    true
),
(
    'b2c3d4e5-f6a7-8901-bcde-f12345678901',
    'Parqueo Matías',
    120,
    0,
    0,
    ST_GeographyFromText('SRID=4326;POINT(-89.254309 13.680100)'),
    true
);

-- ─────────────────────────────────────────────
-- DEMO USERS
-- ─────────────────────────────────────────────

-- Conductor demo (driver)
INSERT INTO users (id, email, full_name, role, driver_category, university_id, active) VALUES
(
    'c3d4e5f6-a7b8-9012-cdef-123456789012',
    'maria.garcia@universidad.edu.sv',
    'María García',
    'driver',
    'student',
    'STU-2024-001',
    true
);

-- Guardia demo (guard)
INSERT INTO users (id, email, full_name, role, driver_category, university_id, active) VALUES
(
    'd4e5f6a7-b8c9-0123-def0-234567890123',
    'guardia.demo@universidad.edu.sv',
    'Carlos Guardián',
    'guard',
    NULL,
    'GRD-2024-001',
    true
);

-- Admin demo
INSERT INTO users (id, email, full_name, role, driver_category, university_id, active) VALUES
(
    'e5f6a7b8-c9d0-1234-ef01-345678901234',
    'admin@universidad.edu.sv',
    'Admin UniPark',
    'admin',
    NULL,
    'ADM-2024-001',
    true
);

-- ─────────────────────────────────────────────
-- DEMO VEHICLE (para el conductor)
-- plate_hash: SHA256 de "P-123-456" en bytes (placeholder — backend debe hashear)
-- plate_last4: "3456"
-- ─────────────────────────────────────────────

INSERT INTO vehicles (id, owner_id, plate_hash, plate_last4, make_model, active) VALUES
(
    'f6a7b8c9-d0e1-2345-f012-456789012345',
    'c3d4e5f6-a7b8-9012-cdef-123456789012',
    decode('a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'hex'),
    '3456',
    'Toyota Corolla 2020',
    true
);
