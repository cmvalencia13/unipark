# 06 — Asignación de Equipo (5 personas)

Cada persona es **dueña** de su área (decisiones técnicas, code review, calidad) pero todos contribuyen en code review cruzado.

---

## 👤 1. Android Lead — Kotlin

**Misión:** entregar la app Android nativa con paridad funcional con iOS.

**Responsable de:**
- Proyecto Android en `/android` (Gradle Kotlin DSL, Version Catalogs).
- Arquitectura Clean Architecture + MVVM con Hilt.
- UI completa en **Jetpack Compose** (Material 3, tema corporativo universidad).
- Implementación QR dinámico (`ZXing`/`ML Kit` para generar, `ML Kit Barcode` para escanear).
- **HCE (Host Card Emulation)** para drivers que tap-to-enter.
- **CameraX** scanner para guards.
- Integración OIDC con **AppAuth-Android** + Android Keystore para tokens.
- Cliente Retrofit generado a partir del OpenAPI del backend.
- Persistencia offline con Room (queue de scans).
- Testing: unit (JUnit5 + MockK + Turbine), UI (Compose Test).
- CI workflow Android (lint, ktlint, detekt, tests, APK debug).

**Entregables clave:**
- `android/app` listo en Play Console Internal Testing.
- 70%+ cobertura en `domain` y `data`.
- Documento `android/ARCHITECTURE.md`.

**No es responsable de:** la app iOS, ni el backend.

---

## 👤 2. iOS Lead — Swift

**Misión:** entregar la app iOS nativa con paridad funcional con Android.

**Responsable de:**
- Proyecto iOS en `/ios` (Xcode + SPM, sin CocoaPods).
- Arquitectura Clean Architecture + MVVM (paridad con Android).
- UI completa en **SwiftUI** (iOS 17+, soporte Dynamic Type, Dark Mode).
- Generación QR (CoreImage `CIQRCodeGenerator`) y escaneo (`AVCaptureMetadataOutput`).
- **Core NFC** para guards (lectura NDEF). Para drivers iOS, QR es el método primario (Apple no permite HCE arbitraria).
- Integración OIDC con **AppAuth-iOS** + Keychain (con biometric protection).
- Cliente generado con **Swift OpenAPI Generator** desde el contrato.
- Persistencia offline con SwiftData.
- Testing: XCTest, snapshot tests, ViewInspector.
- CI workflow iOS (SwiftLint, SwiftFormat, xcodebuild test, TestFlight).

**Entregables clave:**
- `ios/UniPark.xcodeproj` listo en TestFlight.
- 70%+ cobertura en domain/data.
- Documento `ios/ARCHITECTURE.md`.

**No es responsable de:** la app Android ni el backend.

---

## 👤 3. Backend Lead — Kotlin / Spring Boot

**Misión:** entregar la API, lógica de negocio y contrato OpenAPI que consumen ambas apps.

**Responsable de:**
- Proyecto backend en `/backend` (Gradle Kotlin DSL, JVM 21).
- Arquitectura hexagonal: controller / service / repository / domain.
- Endpoints REST documentados con **springdoc-openapi** → `openapi.yaml` versionado en `/docs/api/`.
- WebSocket/STOMP para ocupación en vivo.
- Implementación QR firmado (HMAC-SHA256), validación de nonces en Redis.
- Idempotency keys en `/scans` y `/payments`.
- Optimistic locking en `ParkingLot`.
- Outbox pattern para auditoría.
- Testing: JUnit5 + MockK + Testcontainers (Postgres + Redis reales en tests).
- CI workflow backend (ktlint, detekt, tests, build, container push).
- Versionado de API (`/v1`).

**Entregables clave:**
- API en staging con OpenAPI publicado.
- 80%+ cobertura en `service`.
- Carga: 200 RPS sostenidos en `/scans` con p95 < 200 ms.
- Documento `backend/ARCHITECTURE.md`.

**No es responsable de:** UI móvil, infraestructura cloud (colabora con Data&DevOps).

---

## 👤 4. Data & DevOps Lead

**Misión:** datos confiables, infraestructura reproducible, despliegue automatizado.

**Responsable de:**
- **Modelo de datos** PostgreSQL (junto con Backend Lead).
- Migraciones **Flyway** versionadas en `/backend/src/main/resources/db/migration`.
- Índices, particionamiento de `audit_log` por mes, tuning de queries críticas.
- Setup **Redis** (Sentinel en prod, single en dev).
- **Docker Compose** para dev local (Postgres + Redis + Keycloak + MinIO + backend).
- **Dockerfiles** multi-stage para backend (distroless o `eclipse-temurin:21-jre-alpine`).
- **Kubernetes manifests** o Helm chart en `/infra/k8s`.
- **Terraform** para infra cloud en `/infra/terraform` (VPC, RDS opcional, GKE/EKS).
- **GitHub Actions**: pipelines de build, test, security scan, deploy.
- **Observabilidad**: Prometheus scrape configs, Grafana dashboards JSON, alertas, Loki.
- Backups Postgres (pgBackRest), DR plan.
- Gestión de secretos (Vault o Sealed Secrets).

**Entregables clave:**
- `docker compose up` levanta el stack completo en dev.
- `make deploy-staging` deploya en staging vía GH Actions.
- Dashboards Grafana de API, DB, Redis.
- RTO < 1h, RPO < 15 min para prod.

**No es responsable de:** lógica de negocio del backend ni UI.

---

## 👤 5. Security & QA Lead

**Misión:** garantizar que el sistema sea seguro, accesible y de alta calidad.

**Responsable de:**
- Configuración **Keycloak** (realm, clients, roles, domain restriction flow).
- Implementación rate limiting (Bucket4j + Redis) — coordina con Backend Lead.
- Audit log spec y validación end-to-end.
- TLS, cert pinning specs para móvil.
- **Pentest interno**: OWASP MASVS (móvil), OWASP ASVS (backend).
- **DAST en CI**: OWASP ZAP automatizado contra staging.
- **SAST**: Snyk / SonarCloud / GitHub CodeQL.
- **Plan de testing E2E**: Maestro (móvil) + Cypress (admin web futuro) + RestAssured (API).
- **Pruebas de carga**: k6 contra staging.
- Accesibilidad (a11y): auditoría con TalkBack/VoiceOver, contraste WCAG AA.
- Definir y custodiar **Definition of Done** y checklist de PR.
- Threat model documentado (STRIDE).

**Entregables clave:**
- Reporte de pentest pre-release.
- Suite E2E ejecutándose en CI.
- Threat model en `/docs/security/threat-model.md`.
- Cero CVE críticos sin mitigar.

**No es responsable de:** implementación de features (revisa, no construye).

---

## Colaboración cruzada

| Tema | Owners primarios | Colaboran |
|---|---|---|
| Contrato OpenAPI | Backend | Android, iOS |
| Modelo de datos | Data&DevOps | Backend |
| Keycloak | Security | Backend |
| Rate limiting | Security | Backend |
| Cert pinning | Security | Android, iOS |
| Observabilidad | Data&DevOps | Backend |

## Ritmos

- **Daily** 15 min async (Slack/Discord).
- **Weekly planning** lunes 30 min.
- **Demo** viernes 30 min, cada lead muestra avance.
- **Retro** cada 2 semanas.

## Branching

- `main` protegida, requiere 2 reviewers + CI verde.
- Feature branches: `feat/<area>-<short-desc>`, ej. `feat/android-qr-scanner`.
- Conventional commits obligatorios.
