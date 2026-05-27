# Backend Issues Diagnostic: Lots & User Management

**Date:** 2026-05-27
**Symptom:** Cannot add parking lots, cannot manage users from the admin dashboard.

---

## Issue 1: No POST endpoint to create lots

**Severity:** Critical — feature is completely missing from the backend.

The frontend `LotsPage` at `web/src/app/admin/lots/page.tsx:30` calls:

```ts
await clientFetch("/v1/lots", {
  method: "POST",
  body: JSON.stringify({ name: newName, capacityTotal: parseInt(newCapacity) }),
});
```

But the backend `LotController` at `backend/src/main/kotlin/com/unipark/backend/controller/LotController.kt` only has a single GET endpoint:

```kotlin
@RestController
@RequestMapping("/v1/lots")
class LotController(
  private val parkingLotRepository: ParkingLotRepository
) {
  @GetMapping
  fun getAllLots(): List<ParkingLot> {
    return parkingLotRepository.findAll()
  }
}
```

**There is no POST handler.** The request will get a 405 Method Not Allowed (or 403 if Spring Security blocks it first).

### Fix required

Add a POST endpoint to `LotController.kt` that accepts a create-lot DTO and saves via the repository. Example:

```kotlin
@PostMapping
@PreAuthorize("hasRole('ADMIN') or hasRole('SUPERADMIN')")
fun createLot(@RequestBody request: CreateLotRequest): ResponseEntity<ParkingLot> {
    val lot = ParkingLot(
        name = request.name,
        capacityTotal = request.capacityTotal
    )
    val saved = parkingLotRepository.save(lot)
    return ResponseEntity.status(201).body(saved)
}
```

Also add a DTO in `Dtos.kt`:

```kotlin
data class CreateLotRequest(
    val name: String,
    val capacityTotal: Int
)
```

And move `LotController` under `/v1/admin/lots` (or add a security rule for `/v1/lots` POST) so that only admins can create lots. Currently, `SecurityConfig` only requires authentication for `/v1/**`, and the admin-only rule only covers `/v1/admin/**`. Creating a lot should NOT be open to any authenticated user.

---

## Issue 2: Frontend not sending auth token on API calls

**Severity:** Critical — all write operations and admin-scoped reads will fail with 401/403.

The `clientFetch` function at `web/src/lib/api.ts:35-49` does **not** send an `Authorization` header:

```ts
export async function clientFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,  // <-- no Authorization header
    },
    credentials: "include",
  });
  // ...
}
```

The backend uses `oauth2ResourceServer` (JWT bearer tokens). It expects an `Authorization: Bearer <token>` header on every request. Without it:
- All `/v1/admin/**` endpoints return 401 Unauthorized
- All `/v1/**` endpoints return 401 Unauthorized

The `serverFetch` function (used in server components) does read the session and send the token — but `clientFetch` is used by the client-side pages (lots, users, violations, etc.) and it sends nothing.

This is the root cause for **both** "can't add lots" and "can't manage users."

### Fix required

The NextAuth session needs to expose the access token, and `clientFetch` needs to include it. Two changes:

**1. Store the access token in the NextAuth JWT and session.**

In `web/src/lib/auth.config.ts`, the `jwt` callback already runs when `account` is present. Add:

```ts
(token as any).accessToken = account.access_token;
```

In the `session` callback, add:

```ts
(session as any).accessToken = (token as any).accessToken;
```

**2. Pass the token from the client component to `clientFetch`.**

Since `useSession()` provides the session client-side, the simplest pattern is to have each page grab the token and pass it:

```ts
const { data: session } = useSession();
const token = (session as any)?.accessToken;
```

Then modify `clientFetch` to accept an optional token:

```ts
export async function clientFetch<T>(path: string, options?: RequestInit & { token?: string }): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options?.token ? { Authorization: `Bearer ${options.token}` } : {}),
      ...options?.headers,
    },
    credentials: "include",
  });
  // ...
}
```

Or alternatively, create a wrapper hook that injects the token automatically.

---

## Issue 3: CORS not configured on the backend

**Severity:** High — without CORS config, the browser will block all cross-origin requests from `localhost:3001` to `localhost:8080`.

The frontend runs on `localhost:3001` and the backend on `localhost:8080`. The backend `SecurityConfig.kt` has no CORS configuration. Browser requests will be blocked by CORS policy before they even reach the controller.

### Fix required

Add a CORS bean in `SecurityConfig.kt`:

```kotlin
@Bean
fun corsConfigurationSource(): CorsConfigurationSource {
    val config = CorsConfiguration().apply {
        allowedOrigins = listOf("http://localhost:3001")
        allowedMethods = listOf("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
        allowedHeaders = listOf("Authorization", "Content-Type")
        allowCredentials = true
    }
    return UrlBasedCorsConfigurationSource().apply {
        registerCorsConfiguration("/**", config)
    }
}
```

And in the security chain, add `.cors { }` before `.csrf`:

```kotlin
http
    .cors { }
    .csrf { it.disable() }
    // ...
```

---

## Issue 4: Audit log table partition missing

**Severity:** Medium — the migration creates `audit_log` as a partitioned table but doesn't create any partitions. Any insert into `audit_log` will fail with:

```
no partition of relation "audit_log" found for row
```

This will cause the `AdminUserController` to crash when it tries to write audit entries (if audit logging is wired in).

### Fix required

Add a default partition in the Flyway migration:

```sql
CREATE TABLE audit_log_default PARTITION OF audit_log DEFAULT;
```

Or create yearly/monthly partitions as needed.

---

## Issue 5: No CORS or proxy config in Next.js

**Severity:** Medium — alternative to backend CORS.

If you prefer not to configure CORS on the backend, you can proxy API calls through Next.js. In `web/next.config.js`, add:

```js
async rewrites() {
  return [
    { source: "/api/v1/:path*", destination: "http://localhost:8080/v1/:path*" },
  ];
}
```

Then change `NEXT_PUBLIC_API_URL` to empty string or `/api` so requests go to the same origin. This avoids CORS entirely but still requires the auth token fix (Issue 2).

---

## Summary: Priority Order

| # | Issue | Impact | Effort |
|---|-------|--------|--------|
| 2 | No auth token in clientFetch | All admin API calls fail (401/403) | Small |
| 3 | No CORS on backend | Browser blocks cross-origin requests | Small |
| 1 | No POST /v1/lots endpoint | Cannot create lots (405) | Small |
| 4 | Audit log partition missing | Inserts into audit_log will fail | Small |

**Issues 2 and 3 must be fixed first** — nothing works without them. After that, Issue 1 (the missing POST endpoint) will unblock lot creation. Issue 4 prevents audit logging from working.

---

## Quick Smoke Test (for the backend dev)

After fixes, verify each endpoint:

```bash
# 1. Get a token from Keycloak
TOKEN=$(curl -s -X POST http://localhost:8090/realms/unipark/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=unipark-admin" \
  -d "client_secret=tlLEFXn5Igts1pCOxrpdcp5uRHmrb9TC" \
  -d "username=<admin-user>" \
  -d "password=<admin-pass>" | jq -r .access_token)

# 2. List lots (should return 200, empty array)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/v1/lots

# 3. Create a lot (should return 201)
curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Lot A","capacityTotal":100}' \
  http://localhost:8080/v1/lots

# 4. List users as superadmin (should return 200, paginated)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/v1/admin/users

# 5. Check CORS preflight
curl -X OPTIONS -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Authorization, Content-Type" \
  -i http://localhost:8080/v1/lots
```
