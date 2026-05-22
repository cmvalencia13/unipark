# 08 — Contrato de API (resumen)

El contrato canónico vive en `/docs/api/openapi.yaml` (lo genera Backend Lead con springdoc). Este documento resume los endpoints clave.

> **Base:** `https://api.unipark.<universidad>.edu/v1`
> **Auth:** `Authorization: Bearer <JWT>`

## Endpoints

### Auth & Me
- `GET /me` → perfil + rol + vehículos.

### Passes (Driver)
- `POST /passes` → genera pase QR firmado. Response:
  ```json
  {
    "passId": "uuid",
    "payload": "base64url(...)",
    "signature": "base64url(hmac)",
    "expiresAt": "2026-05-22T14:00:00Z"
  }
  ```
  Cliente regenera cada 60s.

### Scans (Guard)
- `POST /scans` con header `Idempotency-Key`:
  ```json
  {
    "passPayload": "...",
    "passSignature": "...",
    "direction": "ENTRY|EXIT",
    "lotId": "uuid",
    "scannedAt": "ISO-8601"
  }
  ```
  Response: `201` con `scanId` + `lotCapacity{used, total}`.

### Lots
- `GET /lots` → lista con ocupación.
- `GET /lots/{id}` → detalle.
- `POST /lots` (admin) → crear.
- `PATCH /lots/{id}` (admin) → modificar capacidad.

### Violations
- `POST /violations` (guard) → registrar.
- `GET /violations?status=PENDING` (admin).
- `PATCH /violations/{id}` (admin) → aprobar/descartar.

### Audit (superadmin)
- `GET /audit?from=...&to=...&actor=...`.

## WebSocket

- Endpoint: `wss://api.../ws`
- Tópicos STOMP:
  - `/topic/lots/{lotId}/occupancy` → eventos `{used, total, ts}`.
  - `/topic/violations` (admin) → nuevas violaciones.

## Convenciones

- IDs: UUID v7.
- Timestamps: ISO-8601 UTC.
- Errores: RFC 7807 (`application/problem+json`).
- Paginación: `?page=&size=&sort=`.
- Headers de rate limit en responses: `X-RateLimit-Remaining`, `Retry-After`.
