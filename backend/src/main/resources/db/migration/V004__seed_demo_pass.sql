-- V004: Demo pass para pruebas end-to-end sin Keycloak
-- Nonce:     demo-nonce-unipark-2024
-- Signature: HMAC-SHA256("demo-nonce-unipark-2024", "default-secret-key-change-me") en Base64
-- Payload iOS: "demo-nonce-unipark-2024:c1g/f+9vlffqM6biUXEUHEqH87X7NBUz2wFoNa2L15I="

INSERT INTO passes (id, user_id, vehicle_id, issued_at, expires_at, nonce)
VALUES (
    'a0b1c2d3-e4f5-6789-abcd-ef0123456789',
    'c3d4e5f6-a7b8-9012-cdef-123456789012',   -- María García (driver)
    'f6a7b8c9-d0e1-2345-f012-456789012345',   -- Toyota Corolla 2020
    now() - interval '1 hour',
    now() + interval '12 hours',
    'demo-nonce-unipark-2024'
)
ON CONFLICT (nonce) DO NOTHING;
