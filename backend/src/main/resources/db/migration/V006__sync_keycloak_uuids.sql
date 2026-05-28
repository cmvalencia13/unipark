-- V006: Synchronise user UUIDs with Keycloak subject (sub) claims.
-- Uses deferred constraints to allow updating PKs and FKs in one transaction.

SET CONSTRAINTS ALL DEFERRED;

-- Update user PKs to match Keycloak sub values
UPDATE users SET id = 'e757da7c-7d2a-4d16-940d-50ab5dcec1fd'
WHERE email = 'maria.garcia@universidad.edu.sv';

UPDATE users SET id = 'ba2409f6-0d21-4e75-b143-339d7967f798'
WHERE email = 'guardia.demo@universidad.edu.sv';

UPDATE users SET id = 'd73cef40-18ee-4ed2-9ca3-c2b9d1f4b0c4'
WHERE email = 'admin@universidad.edu.sv';

-- Update FK references in passes
UPDATE passes SET user_id = 'e757da7c-7d2a-4d16-940d-50ab5dcec1fd'
WHERE user_id = 'c3d4e5f6-a7b8-9012-cdef-123456789012';

-- Update FK references in vehicles
UPDATE vehicles SET owner_id = 'e757da7c-7d2a-4d16-940d-50ab5dcec1fd'
WHERE owner_id = 'c3d4e5f6-a7b8-9012-cdef-123456789012';

UPDATE vehicles SET owner_id = 'ba2409f6-0d21-4e75-b143-339d7967f798'
WHERE owner_id = 'd4e5f6a7-b8c9-0123-def0-234567890123';

SET CONSTRAINTS ALL IMMEDIATE;
