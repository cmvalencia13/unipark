# 03 — Arquitectura del Sistema

## Diagrama lógico

```
┌─────────────────┐     ┌─────────────────┐
│  Android App    │     │   iOS App       │
│ Kotlin/Compose  │     │ Swift/SwiftUI   │
└────────┬────────┘     └────────┬────────┘
         │ HTTPS + WSS (TLS 1.3) │
         └───────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   NGINX     │  ← Ingress, mTLS opcional
              │  (Ingress)  │
              └──────┬──────┘
                     │
       ┌─────────────┼─────────────┐
       │             │             │
┌──────▼────┐ ┌──────▼─────┐ ┌─────▼──────┐
│ Keycloak  │ │  API       │ │  WebSocket │
│  (OIDC)   │ │ Spring Boot│ │  Gateway   │
└──────┬────┘ └──────┬─────┘ └─────┬──────┘
       │             │             │
       │      ┌──────┼─────────────┘
       │      │      │
       │ ┌────▼──────▼────┐    ┌───────────┐
       │ │  PostgreSQL 16 │    │  Redis 7  │
       │ │  (datos OLTP)  │    │ (cache+RL)│
       │ └────────────────┘    └───────────┘
       │
       └──── audit log → Loki / SIEM
```

## Capas (Clean Architecture)

### Apps móviles (Android + iOS)
```
presentation/   → ViewModels + UI (Compose / SwiftUI)
domain/         → UseCases + entidades de dominio (puras)
data/           → Repositories + DataSources (remote + local)
core/           → Utils, DI, redes, crypto
```

### Backend
```
controller/     → REST + WS endpoints
service/        → lógica de negocio
repository/     → Spring Data JPA
domain/         → entidades + value objects
security/       → filters, JWT, RBAC, rate limiting
config/         → beans, OpenAPI, observabilidad
```

## Comunicación

- **REST/JSON** sobre HTTP/2 para CRUD.
- **WebSocket + STOMP** para ocupación en vivo y eventos de scanner.
- **Server-Sent Events** como alternativa simple para feeds unidireccionales.

## Patrones clave

- **CQRS ligero**: separar `QueryService` (lectura) de `CommandService` (escritura) en operaciones críticas.
- **Outbox pattern** para eventos de auditoría (consistencia con DB).
- **Idempotency keys** en endpoints de scan/pago (header `Idempotency-Key`).
- **Optimistic locking** (`@Version`) en `ParkingLot.capacityUsed` para evitar race conditions.

## Flujo crítico: Driver entra al parqueadero

1. Driver abre app → genera QR firmado HMAC-SHA256 con `userId|lotId|exp|nonce`.
2. QR rota cada 60s vía Coroutine/Combine timer.
3. Guard escanea con CameraX / AVFoundation.
4. Guard app llama `POST /v1/scans` con payload del QR + `Idempotency-Key`.
5. Backend valida firma, expiración, RBAC del guard, y rate limit.
6. Servicio incrementa `lot.capacityUsed` con lock optimista.
7. Evento publicado por WebSocket → Admin dashboard actualiza.
8. Audit log persistido (outbox).

## Modos offline (móvil)

- Drivers: el último QR firmado se guarda en Keystore/Keychain con TTL extendido para emergencias.
- Guards: scans se encolan en Room/SwiftData y se reenvían cuando hay red. Idempotency key garantiza no-duplicación.

## Ambientes

- `dev` → docker-compose local.
- `staging` → K8s cluster pequeño, datos sintéticos.
- `prod` → K8s cluster con HA Postgres (Patroni) + Redis Sentinel.
