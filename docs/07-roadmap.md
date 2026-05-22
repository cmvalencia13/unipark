# 07 — Roadmap por Fases

Duración objetivo: **1 semestre académico (~16 semanas)**. Fases solapadas donde tiene sentido.

## Fase 0 — Bootstrapping (Sem 1)
**Todos.**
- Crear monorepo, ramas protegidas, plantillas PR/Issue.
- Setup `docker compose` con Postgres, Redis, Keycloak, MinIO.
- Definir conventional commits + linters.
- Diagrama C4 y aprobado por equipo.

**Done when:** `docker compose up` arranca todo + un endpoint `/health` responde.

## Fase 1 — Identidad y RBAC (Sem 2-3)
- **Security:** Keycloak realm, restricción de dominio, roles.
- **Backend:** Resource Server JWT, `@PreAuthorize`, `/v1/me`.
- **Android/iOS:** Login OIDC PKCE, almacenamiento seguro de tokens.

**Done when:** un driver con email universitario hace login en ambas apps, y un no-universitario es rechazado.

## Fase 2 — Modelo de datos y core API (Sem 3-5)
- **Data&DevOps + Backend:** schemas (`users`, `vehicles`, `parking_lots`, `passes`, `scans`, `violations`, `audit_log`).
- **Backend:** CRUD lots, `/v1/passes`, `/v1/scans`, idempotency, optimistic locking.
- **Security:** rate limiting con Bucket4j+Redis.

**Done when:** OpenAPI publicado en staging, smoke tests pasan.

## Fase 3 — Driver experience (Sem 5-8)
- **Android/iOS:** dashboard, generación QR rotando 60s, wallet stub, ocupación en vivo (WS).
- **Android:** HCE NFC.
- **iOS:** QR como método primario (limitación Apple).
- **Backend:** WebSocket de ocupación.

**Done when:** driver puede ver su QR, refrescar cada 60s, y ver ocupación en vivo.

## Fase 4 — Guard tooling (Sem 8-11)
- **Android/iOS:** scanner CameraX/AVFoundation, log entrada/salida, queue offline, violation flow.
- **Backend:** validación scans, eventos, violations endpoint.

**Done when:** un guard escanea QR de driver, capacidad del lote sube/baja, evento llega al admin.

## Fase 5 — Admin & Superadmin (Sem 11-13)
- **Backend:** endpoints admin, audit log API.
- (Opcional) Web dashboard en Next.js si hay capacidad — si no, pantallas iPad SwiftUI.

**Done when:** admin gestiona lotes y revisa violaciones; superadmin ve audit log.

## Fase 6 — Hardening y release (Sem 13-16)
- **Security:** pentest, threat model finalizado, OWASP ZAP en CI, cert pinning verificado.
- **Data&DevOps:** observabilidad completa, dashboards, alertas, backups probados.
- **Todos:** performance (k6), accesibilidad, beta cerrado con usuarios reales del campus.

**Done when:** apps en TestFlight + Play Internal, API en producción con SLO cumplido por 2 semanas.
