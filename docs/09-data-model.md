# 09 — Modelo de Datos (PostgreSQL)

```sql
-- Usuarios sincronizados desde Keycloak (subject = id)
CREATE TABLE users (
  id            UUID PRIMARY KEY,             -- = JWT subject
  email         CITEXT NOT NULL UNIQUE,
  full_name     TEXT NOT NULL,
  role          TEXT NOT NULL CHECK (role IN ('driver','guard','admin','superadmin')),
  university_id TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now(),
  active        BOOLEAN DEFAULT TRUE
);

CREATE TABLE vehicles (
  id          UUID PRIMARY KEY,
  owner_id    UUID NOT NULL REFERENCES users(id),
  plate_hash  BYTEA NOT NULL,                  -- SHA256(plate||salt)
  plate_last4 TEXT NOT NULL,                   -- para UI
  make_model  TEXT,
  active      BOOLEAN DEFAULT TRUE,
  UNIQUE (owner_id, plate_hash)
);

CREATE TABLE parking_lots (
  id              UUID PRIMARY KEY,
  name            TEXT NOT NULL,
  capacity_total  INT  NOT NULL CHECK (capacity_total > 0),
  capacity_used   INT  NOT NULL DEFAULT 0,
  version         BIGINT NOT NULL DEFAULT 0,   -- optimistic locking
  geo             GEOGRAPHY(POINT, 4326),
  active          BOOLEAN DEFAULT TRUE
);

CREATE TABLE passes (
  id          UUID PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES users(id),
  vehicle_id  UUID NOT NULL REFERENCES vehicles(id),
  issued_at   TIMESTAMPTZ NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  nonce       TEXT NOT NULL UNIQUE             -- garantiza single-use
);
CREATE INDEX idx_passes_user ON passes(user_id, issued_at DESC);

CREATE TABLE scans (
  id             UUID PRIMARY KEY,
  pass_id        UUID NOT NULL REFERENCES passes(id),
  guard_id       UUID NOT NULL REFERENCES users(id),
  lot_id         UUID NOT NULL REFERENCES parking_lots(id),
  direction      TEXT NOT NULL CHECK (direction IN ('ENTRY','EXIT')),
  scanned_at     TIMESTAMPTZ NOT NULL,
  idempotency_key TEXT NOT NULL,
  UNIQUE (guard_id, idempotency_key)
);
CREATE INDEX idx_scans_lot_time ON scans(lot_id, scanned_at DESC);

CREATE TABLE violations (
  id          UUID PRIMARY KEY,
  vehicle_id  UUID REFERENCES vehicles(id),
  guard_id    UUID NOT NULL REFERENCES users(id),
  lot_id      UUID REFERENCES parking_lots(id),
  reason      TEXT NOT NULL,
  evidence_url TEXT,                            -- S3/MinIO
  status      TEXT NOT NULL CHECK (status IN ('PENDING','APPROVED','DISMISSED')) DEFAULT 'PENDING',
  created_at  TIMESTAMPTZ DEFAULT now(),
  resolved_by UUID REFERENCES users(id),
  resolved_at TIMESTAMPTZ
);

-- Audit log append-only, particionado por mes
CREATE TABLE audit_log (
  id          BIGSERIAL,
  actor_id    UUID,
  action      TEXT NOT NULL,
  target_id   UUID,
  payload     JSONB,
  ip          INET,
  user_agent  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

-- Outbox para eventos
CREATE TABLE outbox_events (
  id           UUID PRIMARY KEY,
  aggregate    TEXT NOT NULL,
  event_type   TEXT NOT NULL,
  payload      JSONB NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  published_at TIMESTAMPTZ
);
```

## Notas

- Migraciones gestionadas por **Flyway** (`V001__init.sql`, etc.).
- `audit_log` particionado por mes con job de creación automática.
- `plate_hash` permite búsqueda por placa sin almacenar el valor plano (defense-in-depth).
- `passes.nonce` con UNIQUE + check en Redis para single-use.
