# UniPark — Estado del proyecto (29 mayo 2026)

## ✅ Qué está funcionando

### Autenticación — Auth0 (migrado desde Keycloak)
- **Keycloak eliminado** del stack. Ya no corre en Docker.
- Auth0 tenant: `dev-5ndrp8gm0rm3r0mw.us.auth0.com`
- iOS, Android y Backend apuntan todos al mismo tenant.
- **iOS login funciona** en iPhone físico: PKCE S256 con `ASWebAuthenticationSession`.
- Tokens (access + refresh + id) se almacenan en `UserDefaults` (TODO: migrar a Keychain).

### Backend
- Spring Boot corriendo en puerto `8081`.
- JWT resource server validando tokens Auth0 (`issuer-uri` configurado en `application.properties`).
- Docker Compose: solo PostgreSQL (5433) + Redis (6379).
- Todos los endpoints de scans, passes y lots verificados con curl.

### Android
- SDK Auth0 Android integrado.
- `OIDCConfig.kt` apunta al dominio y client ID correcto.

---

## ⚠️ Acción requerida — Auth0 Action (CRÍTICO)

El Auth0 Action actual emite claims **sin namespace**, pero Auth0 los descarta silenciosamente del access token. Esto hace que el backend no pueda encontrar el usuario (recibe `sub` en vez de `email`) y devuelve **500**.

### Acción: ir a Auth0 Dashboard → Actions → Library → [tu action] → Edit

Reemplazar el código completo con esto y hacer **Deploy**:

```javascript
exports.onExecutePostLogin = async (event, api) => {
  const NS = 'https://unipark.edu.sv';
  const roles = event.authorization?.roles ?? [];

  // Access token: namespace requerido por Auth0 para JWTs con audience
  api.accessToken.setCustomClaim(`${NS}/email`, event.user.email);
  api.accessToken.setCustomClaim(`${NS}/realm_access`, { roles });

  // ID token
  api.idToken.setCustomClaim(`${NS}/realm_access`, { roles });
};
```

Esto permite que el backend resuelva el usuario por email (`authentication.name = email`).

---

## ⚠️ Acción requerida — Usuarios de prueba en la BD

Los usuarios de Auth0 no existen automáticamente en la base de datos local.
Hay que insertarlos manualmente (o implementar auto-provisioning).

### Usuarios ya insertados (válidos para el demo):

| Email | Contraseña Auth0 | Rol | Vehículo |
|-------|-----------------|-----|----------|
| `driver@unipark.test` | `UniPark2024!` | driver | Toyota Corolla 2020 (placa `ABC123`) |
| `guard@unipark.test` | `UniPark2024!` | guard | — |

Si resetean la base de datos, re-insertar con:

```sql
-- Driver
INSERT INTO users (id, email, full_name, role, driver_category, university_id, active)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567890','driver@unipark.test','Driver Demo','driver','student','driver@unipark.test',true)
ON CONFLICT (email) DO NOTHING;

INSERT INTO vehicles (id, owner_id, plate_hash, plate_last4, make_model, active)
VALUES ('b2c3d4e5-f6a7-8901-bcde-f12345678901','a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  decode(encode(sha256('ABC123'::bytea),'hex'),'hex'),'123','Toyota Corolla 2020',true)
ON CONFLICT DO NOTHING;

-- Guard
INSERT INTO users (id, email, full_name, role, driver_category, university_id, active)
VALUES ('c3d4e5f6-a7b8-9012-cdef-234567890123','guard@unipark.test','Guard Demo','guard',NULL,'guard@unipark.test',true)
ON CONFLICT (email) DO NOTHING;
```

---

## 📱 iOS — Configuración de red

El backend se conecta por **IP local** (mismo WiFi).  
Cambiar en `ios/UniPark/UniPark/core/FeatureFlags.swift` si la IP cambia:

```swift
public static let backendBaseURL: String = "http://10.74.10.251:8081/v1"
```

Para probar fuera de la red: `ngrok http 8081` y actualizar esa línea.

---

## 🗂 Archivos clave modificados esta sesión

| Archivo | Qué cambió |
|---------|-----------|
| `backend/src/main/resources/application.properties` | `issuer-uri` apunta a Auth0 real |
| `backend/src/main/kotlin/.../config/SecurityConfig.kt` | Extrae email y roles de claims con namespace Auth0 |
| `ios/.../core/auth/AppAuthService.swift` | Reescrito para Auth0 PKCE, devuelve `id_token` |
| `ios/.../core/auth/OIDCAuthManager.swift` | Lee profile de id_token, roles de access_token (con namespace) |
| `ios/.../core/FeatureFlags.swift` | URL backend = IP local |
| `ios/.../Info.plist` | Permite HTTP a `localhost` y `10.74.10.251` |
| `docker-compose.yml` | Keycloak eliminado |
| `keycloak/` | Directorio eliminado |

---

## 🔜 Pendientes para la siguiente sesión

1. **Implementar auto-provisioning**: cuando un usuario se loguea por primera vez con Auth0 y no existe en la BD, crearlo automáticamente (backend interceptor o endpoint `/auth/sync`).
2. **Migrar tokens a Keychain** en iOS (actualmente en UserDefaults).
3. **Probar flujo completo**: iPhone como Driver (QR) + Simulador como Guard (scanner).
4. **Guard UI**: tabs Scanner / Lotes / Violación (plan en `.claude/plans/`).
5. **Roles reales en Auth0**: asignar roles `driver`/`guard` a usuarios reales del equipo.
