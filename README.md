# UniPark — University Parking Management System

Sistema de gestión de parqueaderos universitarios con apps **nativas** para Android (Kotlin) e iOS (Swift), backend en **Kotlin/Spring Boot**, y arquitectura preparada para escalar a nivel de universidad de alto nivel.

> **Stack obligatorio:** Kotlin nativo (Android) + Swift nativo (iOS). **No React Native, no Flutter, no híbridos.**

---

## 📚 Documentación

- [**01 — Visión y Alcance**](docs/01-vision-scope.md)
- [**02 — Tech Stack Definitivo**](docs/02-tech-stack.md)
- [**03 — Arquitectura del Sistema**](docs/03-architecture.md)
- [**04 — Roles y Permisos (RBAC)**](docs/04-roles-rbac.md)
- [**05 — Especificaciones de Seguridad**](docs/05-security.md)
- [**06 — Asignación de Equipo (5 personas)**](docs/06-team-assignments.md)
- [**07 — Roadmap por Fases**](docs/07-roadmap.md)
- [**08 — Contrato de API**](docs/08-api-contract.md)
- [**09 — Modelo de Datos**](docs/09-data-model.md)
- [**10 — Guía para colaboradores y sus AIs**](docs/10-ai-collaboration-guide.md)

## 🚀 Resumen ejecutivo

UniPark resuelve el caos del parqueadero universitario con:

- **QR dinámicos** firmados que rotan cada 60s (Driver app).
- **NFC** (HCE en Android, Core NFC en iOS) para tap-to-enter.
- **Scanner móvil** para guardias con log de entrada/salida en tiempo real.
- **Dashboard de admin** con ocupación, violaciones y analíticas.
- **RBAC estricto** restringido al dominio universitario vía OIDC.

## 🏛️ Estructura del monorepo

```
unipark/
├── android/          # Kotlin + Jetpack Compose
├── ios/              # Swift + SwiftUI
├── backend/          # Kotlin + Spring Boot 3
├── infra/            # Docker, K8s, Terraform
├── docs/             # Esta carpeta
└── .github/workflows # CI/CD
```

## 👥 Equipo (5)

| # | Rol | Responsable de |
|---|---|---|
| 1 | **Android Lead** | App Kotlin/Compose, HCE NFC, CameraX scanner |
| 2 | **iOS Lead** | App Swift/SwiftUI, Core NFC, AVFoundation scanner |
| 3 | **Backend Lead** | API Spring Boot, RBAC, lógica de negocio |
| 4 | **Data & DevOps Lead** | PostgreSQL, Redis, Docker, K8s, CI/CD |
| 5 | **Security & QA Lead** | Auth/OIDC, rate limiting, pentest, testing |

Ver detalle completo en [docs/06-team-assignments.md](docs/06-team-assignments.md).
