# 10 — Guía para colaboradores y sus AIs

Esta guía es para que cualquier miembro del equipo (y su asistente IA) pueda **arrancar en frío** y entender el proyecto en menos de 15 min.

## Lectura mínima obligatoria
1. `README.md`
2. `docs/01-vision-scope.md`
3. `docs/02-tech-stack.md`
4. Tu sección en `docs/06-team-assignments.md`
5. `docs/08-api-contract.md` (si tocas algo que cruza red).

## Si trabajas con un asistente IA (Claude/Gemini/Cursor)

Pega este **prompt base** al inicio de la sesión:

```
Estoy trabajando en UniPark, un sistema de gestión de parqueaderos universitarios.

Stack:
- Android: Kotlin + Jetpack Compose + Hilt + Retrofit + Room
- iOS: Swift + SwiftUI + Swift Concurrency + SwiftData
- Backend: Kotlin + Spring Boot 3 + PostgreSQL 16 + Redis 7
- Auth: Keycloak (OIDC + PKCE) restringido a dominio universitario
- Infra: Docker + Kubernetes + Terraform + GitHub Actions

Reglas inquebrantables:
1. NO sugerir React Native, Flutter, ni soluciones híbridas.
2. NO sugerir Firebase Auth, Clerk, ni LocalStorage como BD real.
3. Apps móviles SIEMPRE nativas (Kotlin/Swift).
4. Apps SIEMPRE deben usar OIDC PKCE con AppAuth, tokens en Keystore/Keychain.
5. Endpoints sensibles requieren Idempotency-Key + rate limiting.
6. Contrato OpenAPI es la fuente única de verdad para tipos.

Mi rol es: <Android Lead | iOS Lead | Backend Lead | Data&DevOps Lead | Security&QA Lead>.
Mi tarea actual es: <...>
```

## Convenciones de código

- **Kotlin:** ktlint + detekt. `val` por defecto, `data class` para DTOs, sealed classes para estados UI.
- **Swift:** SwiftLint + swift-format. `let` por defecto, `@MainActor` en VMs, `Sendable` donde aplique.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`).
- **PRs:** descripción con problema, solución, tests, screenshots si es UI, checklist de Definition of Done.

## Definition of Done

- [ ] Código revisado por 2 personas (1 del área, 1 cross).
- [ ] Tests unit + integración pasan en CI.
- [ ] Linter/formatter sin warnings.
- [ ] OpenAPI actualizado si cambió la API.
- [ ] Documento de arquitectura actualizado si aplica.
- [ ] Sin secretos en código.
- [ ] Accesibilidad verificada (móvil).
- [ ] Sin nuevos CVE críticos en deps.

## Cosas que NO debes hacer

- ❌ Tocar el código de otra plataforma sin coordinación con su lead.
- ❌ Romper el contrato OpenAPI sin bump de versión + aviso.
- ❌ Mergear directo a `main`.
- ❌ Mockear endpoints en lugar de consumir staging.
- ❌ Commitear `.env`, llaves, dumps de BD, builds.

## Canales de coordinación

- **Issues GitHub:** tareas atómicas con labels por área (`area/android`, `area/ios`, `area/backend`, `area/devops`, `area/security`).
- **Discussions GitHub:** decisiones de arquitectura (ADRs).
- **Slack/Discord:** sincronización rápida, pero decisiones se confirman por escrito en GitHub.

## ADRs (Architecture Decision Records)

Cada decisión grande va en `/docs/adr/NNNN-titulo.md` con plantilla:

```
# ADR NNNN — Título
Status: Proposed | Accepted | Superseded
Date: YYYY-MM-DD
Context: ...
Decision: ...
Consequences: ...
```
