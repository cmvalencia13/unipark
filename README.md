# UniPark — Sistema de Gestión de Parqueaderos Universitarios

UniPark digitaliza el acceso y control de parqueaderos universitarios mediante apps nativas para **Android** e **iOS**, un **backend Spring Boot** y un **dashboard web** de administración. Los conductores entran con un QR dinámico o NFC; los guardias escanean desde su teléfono; los admins monitorean ocupación y violaciones en tiempo real.

> **Stack nativo obligatorio:** Kotlin (Android) + Swift (iOS). No React Native, no Flutter.

---

## 📋 Resumen ejecutivo

| | |
|---|---|
| **Problema** | Validación manual de acceso, sin visibilidad de ocupación, violaciones sin trazabilidad |
| **Solución** | QR firmados que rotan cada 60s, NFC tap-to-enter, scanner para guardias, dashboard en vivo |
| **Autenticación** | Auth0 (OIDC + PKCE) — restringido a dominio `@universidad.edu` |
| **Plataformas** | Android (Kotlin/Compose) · iOS (Swift/SwiftUI) · Web (Next.js) · Backend (Spring Boot) |
| **Roles** | `driver` · `guard` · `admin` · `superadmin` |

---

## 🏛️ Estructura del monorepo

```
unipark/
├── android/          # App Android — Kotlin + Jetpack Compose + Hilt
├── ios/              # App iOS — Swift + SwiftUI
├── backend/          # API REST — Kotlin + Spring Boot 3 + PostgreSQL
├── web/              # Dashboard admin — Next.js 14 + NextAuth v5
├── dashboard-admin/  # Dashboard secundario (demo, Credentials provider)
├── infra/            # Scripts SQL de inicialización
├── docs/             # Documentación técnica del proyecto
└── docker-compose.yml
```

---

## 🚀 Cómo iniciar el proyecto

### Prerequisitos

| Herramienta | Versión mínima |
|---|---|
| Docker Desktop | 4.x |
| JDK 17 | Incluido en Android Studio JBR |
| Android Studio | Hedgehog o superior |
| Xcode | 15+ (solo macOS) |
| Node.js | 18+ |

---

### 1. Levantar la infraestructura (Docker)

```bash
# Desde la raíz del repo
docker compose up -d postgres redis
```

| Servicio | Puerto | Credenciales |
|---|---|---|
| PostgreSQL | `5433` | `unipark / unipark` |
| Redis | `6379` | — |

---

### 2. Backend (Spring Boot)

```bash
cd backend
```

**Windows PowerShell:**
```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:AUTH0_ISSUER_URI = "https://dev-5ndrp8gm0rm3r0mw.us.auth0.com/"
.\gradlew.bat bootRun
```

**macOS / Linux:**
```bash
AUTH0_ISSUER_URI="https://dev-5ndrp8gm0rm3r0mw.us.auth0.com/" ./gradlew bootRun
```

El backend arranca en **http://localhost:8081**. Flyway aplica las migraciones automáticamente al iniciar.

---

### 3. App Android

1. Abre la carpeta `android/` en Android Studio.
2. Selecciona un emulador (API 26+) o dispositivo físico.
3. **Run → app**.

Auth0 ya está configurado con el Client ID de Android — no se requiere configuración adicional.

---

### 4. App iOS *(solo macOS)*

1. Abre `ios/UniPark/UniPark.xcodeproj` en Xcode.
2. Agrega el paquete **Auth0.swift** via SPM:
   - **File → Add Package Dependencies**
   - URL: `https://github.com/auth0/Auth0.swift`
   - Version: Up to Next Major desde `2.0.0`
   - Target: `UniPark` ✓
3. Verifica que `Auth0.plist` esté en el target con estos valores:
   ```xml
   <key>ClientId</key>
   <string>mEzhjEcOibjtfwUoxKRRlykEebqlgYHT</string>
   <key>Domain</key>
   <string>dev-5ndrp8gm0rm3r0mw.us.auth0.com</string>
   ```
4. Selecciona simulador o iPhone físico → **Run**.

---

### 5. Dashboard Web (Next.js)

```bash
cd web
npm install
cp .env.example .env.local   # luego edita con tus valores
npm run dev                  # http://localhost:3000
```

Contenido mínimo de `.env.local`:

```env
AUTH_SECRET=<genera con: openssl rand -base64 32>
NEXTAUTH_URL=http://localhost:3000

AUTH0_ISSUER=https://dev-5ndrp8gm0rm3r0mw.us.auth0.com
AUTH0_CLIENT_ID=lv21sa2ipuVXuaToMpAiCAfAnmt9U6T0
AUTH0_CLIENT_SECRET=<pide al responsable del tenant Auth0>
AUTH0_AUDIENCE=https://api.unipark.edu.sv

NEXT_PUBLIC_AUTH0_ISSUER=https://dev-5ndrp8gm0rm3r0mw.us.auth0.com
NEXT_PUBLIC_AUTH0_CLIENT_ID=lv21sa2ipuVXuaToMpAiCAfAnmt9U6T0
```

---

## 🔐 Autenticación — Auth0

El proyecto usa **Auth0** como Identity Provider (OIDC). Keycloak fue eliminado.

| Plataforma | Tipo de app en Auth0 | Client ID |
|---|---|---|
| iOS | Native | `mEzhjEcOibjtfwUoxKRRlykEebqlgYHT` |
| Android | Native | `cs3CdYX3JKCmIUnCuLbY9S43qAvGDWQI` |
| Web | Regular Web App | `lv21sa2ipuVXuaToMpAiCAfAnmt9U6T0` |
| Backend | API (audience) | `https://api.unipark.edu.sv` |

**Tenant:** `dev-5ndrp8gm0rm3r0mw.us.auth0.com`

Los roles se asignan en el dashboard de Auth0 y se emiten en el access token mediante un **post-login Action** como claim namespaced `https://unipark.edu.sv/realm_access.roles`.

---

## 🗺️ Arquitectura

```
  [ Android ]    [ iOS ]    [ Web Dashboard ]
       │              │              │
       └──────────────┴──────────────┘
                      │  HTTPS + JWT (Auth0)
            ┌─────────▼──────────┐
            │  Spring Boot API   │  :8081
            │      /v1/...       │
            └──────┬─────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
┌───────▼───────┐    ┌────────▼──────┐
│  PostgreSQL   │    │    Redis      │
│    :5433      │    │    :6379      │
└───────────────┘    └───────────────┘
```

---

## 📡 Endpoints principales

| Método | Endpoint | Rol requerido |
|---|---|---|
| `GET` | `/v1/me` | Cualquier autenticado |
| `GET` | `/v1/lots` | Cualquier autenticado |
| `POST` | `/v1/passes` | `driver` |
| `POST` | `/v1/scans` | `guard` |
| `POST` | `/v1/lots` | `admin`, `superadmin` |
| `PATCH` | `/v1/lots/{id}` | `admin`, `superadmin` |
| `POST` | `/v1/violations` | `guard` |
| `GET` | `/v1/audit` | `superadmin` |

Documentación completa: [`docs/08-api-contract.md`](docs/08-api-contract.md)

---

## 👥 Equipo

| Rol | Responsabilidad |
|---|---|
| **Android Lead** | App Kotlin/Compose, QR dinámico, HCE NFC, CameraX scanner |
| **iOS Lead** | App Swift/SwiftUI, QR dinámico, Core NFC, AVFoundation scanner |
| **Backend Lead** | API Spring Boot, RBAC, lógica de negocio, WebSocket ocupación |
| **Data & DevOps Lead** | PostgreSQL, Redis, Docker, CI/CD |
| **Security & QA Lead** | Auth/OIDC, rate limiting, tests, pentest |

---

## 📚 Documentación técnica

| Documento | Contenido |
|---|---|
| [01 — Visión y Alcance](docs/01-vision-scope.md) | Problema, usuarios, MVP, métricas de éxito |
| [02 — Tech Stack](docs/02-tech-stack.md) | Todas las tecnologías y justificación |
| [03 — Arquitectura](docs/03-architecture.md) | Diagrama del sistema completo |
| [04 — Roles y RBAC](docs/04-roles-rbac.md) | Matriz de permisos por rol y endpoint |
| [05 — Seguridad](docs/05-security.md) | JWT, rate limiting, auditoría |
| [06 — Equipo](docs/06-team-assignments.md) | Responsabilidades detalladas por persona |
| [07 — Roadmap](docs/07-roadmap.md) | Fases del semestre (16 semanas) |
| [08 — API Contract](docs/08-api-contract.md) | Contratos OpenAPI de endpoints |
| [09 — Modelo de datos](docs/09-data-model.md) | Esquema PostgreSQL completo |

---

## 🐛 Problemas comunes

| Error | Causa | Solución |
|---|---|---|
| `Connection to localhost:5433 refused` | PostgreSQL no está corriendo | `docker compose up -d postgres` |
| `JAVA_HOME is not set` | Variable de entorno faltante | Setear al JDK 17 de Android Studio |
| `Failed to clean up stale outputs` | OneDrive bloquea archivos de build | `./gradlew --stop` → borrar carpeta `build/` manualmente |
| `issuer-uri must not be null` | `AUTH0_ISSUER_URI` no seteada | Exportar la variable antes de `bootRun` |
| `401 Unauthorized` en el backend | Token sin `audience` | La app debe pedir `audience=https://api.unipark.edu.sv` |
