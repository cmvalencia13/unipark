# 05 — Especificaciones de Seguridad

## 1. Autenticación (OIDC + PKCE)
- Apps móviles usan **AppAuth** con PKCE (sin client secret).
- Tokens: access (15 min) + refresh (7 días, rotating).
- Access guardado en **Android Keystore** / **iOS Keychain** (nunca en SharedPrefs/UserDefaults plano).
- Refresh token cifrado con key derivada de biometría cuando esté disponible.

## 2. Autorización (RBAC)
- JWT con claims `role`, `university_id`.
- Spring Security `@PreAuthorize("hasRole('GUARD')")` por endpoint.
- En móvil, navegación condicionada por rol leído del JWT decodificado.

## 3. Restricción de dominio universitario
- Doble validación: Auth0 post-login Action + backend `JwtAuthenticationConverter`.
- Lista blanca de dominios en config (`security.allowed-domains`).

## 4. Rate Limiting
- **Bucket4j + Redis** en filtro Spring.
- Default: **5 req / 10s por subject** del JWT.
- Endpoints sensibles (`/scans`, `/payments`): bucket separado más estricto.
- Response: `429 Too Many Requests` con header `Retry-After`.

## 5. QR firmado
- Payload: `{userId, vehicleId, exp, nonce}` (exp = now + 60s).
- Firma HMAC-SHA256 con secret rotado por backend, distribuido por endpoint autenticado `/v1/passes`.
- Móvil **no** firma localmente; pide al backend un pase ya firmado y solo lo renderiza.
- Backend valida: firma, exp, nonce no reusado (Redis SET con TTL).

## 6. NFC
- **Android HCE:** AID propio, payload firmado idéntico al QR.
- **iOS Core NFC:** modo lectura/escritura NDEF para guardias; los iPhones de drivers usan QR como fallback (Apple no permite HCE arbitraria).

## 7. Headers de seguridad (backend)
- `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- `Content-Security-Policy` estricta (en admin web).
- `X-Content-Type-Options: nosniff`
- CORS lista blanca explícita.

## 8. TLS
- TLS 1.3 obligatorio.
- **Certificate pinning** en Android (OkHttp `CertificatePinner`) e iOS (`URLSessionDelegate`).

## 9. Auditoría
- Tabla `audit_log` append-only.
- Outbox pattern: cualquier acción sensible genera evento → consumer escribe a Loki/SIEM.
- Campos: `actor_id, action, target_id, ip, user_agent, timestamp, payload_hash`.

## 10. Datos sensibles
- Sin PII innecesaria; placas almacenadas hasheadas para búsqueda con índice parcial.
- Cifrado en reposo (Postgres TDE / volúmenes cifrados).
- Backups cifrados con KMS.

## 11. Defensa en profundidad
- WAF (ModSecurity OWASP CRS) frente a NGINX.
- Dependabot + Snyk en CI.
- Pentest interno antes de cada release mayor.
- DAST con OWASP ZAP en pipeline.

## 12. Pagos stub (seguro aunque sea simulado)
- No persistir PAN ni CVV jamás, incluso simulados.
- UI usa máscara `**** **** **** 1234`.
- Fraud-check simulator del 5% como en el plan original.
