# 04 — Roles y Permisos (RBAC)

Los roles se emiten como claim namespaced `https://unipark.edu.sv/realm_access.roles` en el access token de Auth0 (vía un post-login Action). El backend los mapea a autoridades `ROLE_*`.

| Rol | Plataformas | Vistas | Permisos clave |
|---|---|---|---|
| **driver** | Android, iOS | Dashboard móvil, Digital Pass, Wallet | Generar QR dinámico, emitir NFC, ver ocupación, gestionar pagos stub, ver violaciones propias. |
| **guard** | Android, iOS | Scanner, Lot Capacity Grid | Escanear QR, registrar entrada/salida, marcar violaciones, ver capacidad. |
| **admin** | Web (futuro) / iPad | Dashboard, Lot Mgmt, Violations Console | Crear/editar lotes, ajustar capacidades, revisar/aprobar violaciones, reportes. |
| **superadmin** | Web | Settings, Audit, User Mgmt | Override total, audit logs, gestión de admins, ajustar thresholds globales. |

## Matriz de endpoints

| Endpoint | driver | guard | admin | superadmin |
|---|:-:|:-:|:-:|:-:|
| `GET /v1/me` | ✅ | ✅ | ✅ | ✅ |
| `POST /v1/passes` | ✅ | ❌ | ❌ | ❌ |
| `POST /v1/scans` | ❌ | ✅ | ❌ | ❌ |
| `GET /v1/lots` | ✅ | ✅ | ✅ | ✅ |
| `POST /v1/lots` | ❌ | ❌ | ✅ | ✅ |
| `PATCH /v1/lots/{id}` | ❌ | ❌ | ✅ | ✅ |
| `POST /v1/violations` | ❌ | ✅ | ❌ | ❌ |
| `PATCH /v1/violations/{id}` | ❌ | ❌ | ✅ | ✅ |
| `GET /v1/audit` | ❌ | ❌ | ❌ | ✅ |
| `PATCH /v1/settings` | ❌ | ❌ | ❌ | ✅ |

## Restricción de dominio

Auth0 post-login Action: rechaza el login si el email no coincide con `*@<universidad>.edu` (devuelve `access_denied`).

Backend además valida en `JwtAuthenticationConverter` que `email_verified=true` y dominio coincide; doble defensa.
