# 02 — Tech Stack Definitivo

Stack elegido para **rigor académico, escalabilidad y empleabilidad**. Cada elección está justificada.

## 📱 Android — Kotlin Nativo

| Capa | Tecnología | Por qué |
|---|---|---|
| Lenguaje | **Kotlin 2.0** | Estándar oficial Android. |
| UI | **Jetpack Compose** | Declarativa, moderna, reemplazo de XML. |
| Arquitectura | **MVVM + Clean Architecture** (data/domain/presentation) | Testeable, escalable. |
| DI | **Hilt** | DI estándar de Google sobre Dagger. |
| Async | **Coroutines + Flow** | Concurrencia estructurada. |
| Network | **Retrofit + OkHttp + Moshi** | Standard de facto. |
| Persistencia local | **Room** + DataStore | SQL tipado + key-value tipado. |
| NFC | **HCE (Host Card Emulation)** | El teléfono actúa como tarjeta. |
| Cámara/QR | **CameraX + ML Kit Barcode Scanning** | Oficial Google. |
| Auth | **AppAuth-Android** (OIDC PKCE) | Estándar OAuth2 móvil. |
| Crypto | **Android Keystore + Tink** | Firma y storage seguro de tokens. |
| Testing | JUnit5, MockK, Turbine, Compose UI Test | Cobertura unit + UI. |
| Build | Gradle (Kotlin DSL) + Version Catalogs | Reproducible. |

## 🍎 iOS — Swift Nativo

| Capa | Tecnología | Por qué |
|---|---|---|
| Lenguaje | **Swift 5.10+** | Estándar iOS. |
| UI | **SwiftUI** (iOS 17+) | Declarativa, moderna. |
| Arquitectura | **MVVM + Clean Architecture** | Paridad con Android. |
| DI | **Factory** o swift-dependencies | DI ligera idiomática. |
| Async | **Swift Concurrency (async/await, Actors)** | Nativo. |
| Network | **URLSession + Swift OpenAPI Generator** | Tipos generados del contrato. |
| Persistencia | **SwiftData** (fallback Core Data) | Moderno, idiomático. |
| NFC | **Core NFC (NDEF + ISO7816 read)** | Limitaciones de Apple respetadas. |
| Cámara/QR | **AVFoundation (AVCaptureMetadataOutput)** | Nativo, sin terceros. |
| Auth | **AppAuth-iOS** (OIDC PKCE) + ASWebAuthenticationSession | Estándar. |
| Crypto | **Keychain + CryptoKit** | Storage seguro nativo. |
| Testing | XCTest, ViewInspector, Snapshot testing | Cobertura completa. |
| Build | Xcode + Swift Package Manager | Sin CocoaPods. |

## ⚙️ Backend — Kotlin + Spring Boot

| Capa | Tecnología | Por qué |
|---|---|---|
| Lenguaje | **Kotlin 2.0 (JVM 21 LTS)** | Mismo lenguaje que Android → reuso de modelos vía Kotlin Multiplatform opcional. |
| Framework | **Spring Boot 3.3** | Maduro, enterprise, masivamente documentado. |
| Web | **Spring WebFlux** (reactive) o **Spring Web MVC** | WebFlux para realtime/WS, MVC si el equipo prefiere bloqueante. |
| Realtime | **Spring WebSocket + STOMP** | Ocupación en vivo. |
| Seguridad | **Spring Security + OAuth2 Resource Server (JWT)** | Estándar industrial. |
| Persistencia | **Spring Data JPA + Hibernate** | Productivo. |
| Migraciones | **Flyway** | Versionado de schema. |
| Validación | Jakarta Validation | Anotaciones declarativas. |
| API Docs | **springdoc-openapi** → OpenAPI 3.1 | Contrato fuente única. |
| Observabilidad | Micrometer + Prometheus + OpenTelemetry | Métricas + tracing distribuido. |
| Testing | JUnit5, Testcontainers, MockK, RestAssured | Integration tests contra Postgres real. |

## 🗄️ Datos e Infraestructura

| Componente | Tecnología | Uso |
|---|---|---|
| **DB primaria** | **PostgreSQL 16** | Transacciones ACID, JSONB para flexibilidad. |
| **Cache/Rate-limit** | **Redis 7** | Token buckets para rate limiting, cache de sesiones. |
| **Mensajería** *(futuro)* | RabbitMQ o Kafka | Eventos de entrada/salida desacoplados. |
| **Storage** | S3-compatible (MinIO en dev) | Evidencias de violaciones (fotos). |
| **Contenedores** | Docker + Docker Compose | Local + CI. |
| **Orquestación** | Kubernetes (k3s/GKE) | Producción. |
| **IaC** | Terraform | Provisionamiento reproducible. |
| **Secrets** | HashiCorp Vault o cloud-native KMS | Sin secretos en git. |
| **CI/CD** | **GitHub Actions** | Matrices Android/iOS/Backend. |
| **Observabilidad** | Prometheus + Grafana + Loki | Logs + métricas + alertas. |
| **APM** | OpenTelemetry → Jaeger/Tempo | Tracing. |
| **Errores móviles** | Sentry | Crash reporting Android+iOS. |

## 🔐 Identidad

- **Keycloak 25** auto-hosteado (o Auth0 si presupuesto lo permite).
- OIDC con PKCE para apps móviles.
- Restricción de dominio `@universidad.edu` vía Authentication Flow.
- Claims custom: `role`, `university_id`, `vehicle_ids`.
- JWT firmado RS256, rotación de claves.

## 🚫 Explícitamente NO usar

- ❌ React Native, Flutter, Ionic, Capacitor, Xamarin.
- ❌ Firebase Auth (no cumple requisito de restricción de dominio enterprise).
- ❌ LocalStorage / mocks en producción.
- ❌ Clerk (es web-first, no es la mejor opción para mobile nativo enterprise).
- ❌ MongoDB para datos transaccionales (relacional es la elección correcta aquí).

## Justificación académica

Este stack es defensible ante un comité universitario porque:
1. **Kotlin/Swift nativos** = máxima calidad de UX y acceso completo a hardware (NFC, cámara).
2. **Spring Boot Kotlin** = estándar enterprise con literatura abundante.
3. **PostgreSQL + Redis** = combinación canónica de OLTP + cache.
4. **OIDC/OAuth2** = estándares IETF, no propietarios.
5. **OpenAPI 3.1** = contrato verificable, fuente única de verdad.
6. **Kubernetes + Terraform** = prácticas SRE reales.
