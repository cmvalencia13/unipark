# Plan Técnico de Integración: Fase 6 (Android Data Layer)

Este documento detalla la planificación y arquitectura para la integración de datos reales en la aplicación móvil nativa de **UniPark**, conectándola al Backend a través de una capa robusta de red con Retrofit, OkHttp, y Moshi, aplicando estrictamente las reglas inquebrantables de seguridad (OIDC PKCE, AppAuth, Keystore y cabeceras de idempotencia).

---

## 1. Análisis de Estado Actual y Brechas

### 1.1 Estructura del Cliente Móvil
* **MainActivity & UniParkApplication**: Configurados con Hilt para inyección de dependencias.
* **core/di/AppModule**: Vacío, con anotación indicando la futura provisión de dependencias reales.
* **domain/model/**:
  - `MapModels.kt`: `LotInfo` contiene coordenadas relativas de renderizado (`xFraction`, `yFraction`) y un porcentaje de `occupancy`.
  - `PermitModels.kt` / `DashboardModels.kt`: `PermitInfo` y `VehicleInfo` contienen datos simples de texto que actualmente son mockeados en `PermitsViewModel`.
* **ViewModels**:
  - `MapViewModel.kt`: Utiliza `fakeLots` y `fakeFilters` definidos estáticamente en su `companion object`.
  - `PermitsViewModel.kt`: Utiliza `fakePermits`, `fakeVehicles` y `fakePricing` definidos en su `companion object`.

### 1.2 Comparativa: Mocks vs. Contrato OpenAPI (`08-api-contract.md`)

| Concepto / Pantalla | Modelo Mock Actual (Android) | Estructura en OpenAPI Contract | Plan de Mapeo (DTO → Domain) |
| :--- | :--- | :--- | :--- |
| **Estacionamientos (Mapa)** | `LotInfo(id, name, occupancy: Int, xFraction, yFraction)` | `GET /lots` → `[{ lotId, name, capacityTotal, capacityUsed, geo }]` | `LotDto` contendrá `capacityUsed` y `capacityTotal`. `occupancy` se calculará dinámicamente: `(used * 100) / total`. `xFraction` y `yFraction` se obtendrán de un mapeo local basado en el `lotId` o metadatos de mapa. |
| **Pases y Permisos** | `PermitInfo(permitName, status, validUntil, vehiclePlate)` | `GET /me` (vehículos) + `POST /passes` → `{ passId, payload, signature, expiresAt }` | `PassDto` y `UserDto` mapearán a `PermitInfo`. El pase QR firmado se regenerará localmente cada 60s haciendo POST a `/passes`. |
| **Vehículos** | `VehicleInfo(plate, makeModel, isGuest, validUntil)` | `GET /me` → `UserDto` con lista de `vehicles: [{ id, plateLast4, makeModel, active }]` | Mapeo directo de los vehículos del usuario autenticado devueltos por `/me`. |

---

## 2. Plan de Implementación

```mermaid
graph TD
    subgraph Capa de Datos (Data Layer)
        AuthToken[Encrypted Storage / Keystore] -->|Inyecta Token| AuthInt[AuthInterceptor]
        IdemInt[IdempotencyInterceptor] --> OkHttp[OkHttpClient]
        AuthInt --> OkHttp
        OkHttp --> Retrofit[Retrofit Instance]
        Moshi[Moshi Converter] --> Retrofit
        Retrofit --> LotApi[LotApi]
        Retrofit --> PassApi[PassApi]
        Retrofit --> UserApi[UserApi]
    end

    subgraph Capa de Dominio (Domain Layer)
        LotApi --> LotRepoImpl[LotRepositoryImpl]
        PassApi --> PassRepoImpl[PassRepositoryImpl]
        UserApi --> UserRepoImpl[UserRepositoryImpl]
    end

    subgraph Capa de Presentación (Presentation)
        LotRepoImpl -->|Flow| MapViewModel[MapViewModel]
        PassRepoImpl -->|Flow| PermitsViewModel[PermitsViewModel]
        UserRepoImpl -->|Flow| PermitsViewModel
    end
```

---

## 3. Propuesta Técnica Detallada

### 3.1 Infraestructura de Red & Seguridad (OkHttp + Retrofit)

#### A. Dependencias a Habilitar (`build.gradle.kts`)
Activaremos las dependencias declaradas en el catálogo de versiones `libs.versions.toml`:
* `retrofit` y `retrofit-moshi` (Moshi Converter).
* `moshi` y `moshi-codegen` (Generación de código KSP para serialización JSON).
* `okhttp` y `okhttp-logging` (Intercepción y logging en Debug).
* `appauth` (OIDC PKCE para autenticación segura).
* `tink-android` o `EncryptedSharedPreferences` (Seguridad de tokens en Keystore).

#### B. Gestión Segura de Tokens (`TokenManager`)
Crearemos un `TokenManager` con `EncryptedSharedPreferences` (respaldado por la API de **Android Keystore**) para persistir y recuperar los tokens de OAuth2 (Access Token, Refresh Token) obtenidos a través de **AppAuth con PKCE**.
> [!IMPORTANT]
> Cumpliendo estrictamente con la regla 4, **nunca** se guardarán tokens en texto plano ni en SharedPreferences estándar.

#### C. OkHttpClient & Interceptores
Configuraremos un `OkHttpClient` común provisto por Hilt con los siguientes interceptores:
1. **`AuthInterceptor`**: Recuperará dinámicamente el JWT del `TokenManager` y lo inyectará en la cabecera `Authorization: Bearer <JWT>` en cada petición saliente.
2. **`IdempotencyInterceptor`**: Interceptará peticiones `POST` a endpoints sensibles (ej. `/passes`, `/scans`, `/violations`) y les inyectará una cabecera `Idempotency-Key` con un valor UUID v7 generado en tiempo real.
3. **`HttpLoggingInterceptor`**: Habilitado únicamente en compilaciones `DEBUG` para depurar payloads de red.

---

### 3.2 Definición de Contratos Retrofit (API Interfaces)

Se construirán las siguientes interfaces mapeadas con el contrato de API resumido:

```kotlin
interface UserApi {
    @GET("me")
    suspend fun getProfile(): Response<UserDto>
}

interface LotApi {
    @GET("lots")
    suspend fun getLots(): Response<List<LotDto>>

    @GET("lots/{id}")
    suspend fun getLotDetails(@Path("id") lotId: String): Response<LotDto>
}

interface PassApi {
    @POST("passes")
    suspend fun generatePass(): Response<PassResponseDto>
}
```

---

### 3.3 Reemplazo de Mocks en Capa de Presentación

Adoptaremos un enfoque progresivo y no intrusivo utilizando patrones de **Clean Architecture**:

#### A. Definición de Repositorios en Dominio
Definiremos interfaces limpias de repositorio que expongan los datos a través de Kotlin `Flow`:
* `LotRepository`: `fun getLots(): Flow<Resource<List<LotInfo>>>`
* `PassRepository`: `fun getActivePasses(): Flow<Resource<PassInfo>>`
* `UserRepository`: `fun getUserVehicles(): Flow<Resource<List<VehicleInfo>>>`

#### B. Implementación de Repositorios (`data/repository`)
Realizarán las llamadas de red usando Retrofit, manejarán las excepciones y mapearán los DTOs (Data Transfer Objects) a entidades de Dominio (`LotInfo`, `VehicleInfo`, etc.). Los errores se formatearán conforme a RFC 7807 (`application/problem+json`).

#### C. Refactorización de ViewModels
Inyectaremos los nuevos repositorios mediante Hilt y eliminaremos los objetos `fakeLots`, `fakeVehicles`, y `fakePricing`.
Los ViewModels expondrán el estado UI de manera reactiva usando `StateFlow`:
```kotlin
// MapViewModel Refactored (Preview)
@HiltViewModel
class MapViewModel @Inject constructor(
    private val lotRepository: LotRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<MapUiState>(MapUiState.Loading)
    val uiState: StateFlow<MapUiState> = _uiState.asStateFlow()

    init {
        fetchLots()
    }

    fun fetchLots() {
        viewModelScope.launch {
            lotRepository.getLots().collect { result ->
                // Actualizar uiState con Real Data o Error State
            }
        }
    }
}
```

---

## 4. Plan de Verificación

1. **Pruebas Unitarias con MockWebServer**:
   - Crearemos pruebas para `LotRepositoryImpl` y `PassRepositoryImpl` utilizando `MockWebServer` para simular respuestas exitosas de API, respuestas de error RFC 7807, y verificar la correcta inserción de cabeceras (`Authorization`, `Idempotency-Key`).
2. **Inspección de Tráfico (Fiddler / Charles / Android Studio Inspector)**:
   - Validar que el token de autenticación se inyecta en cada cabecera de petición REST de manera transparente.
   - Validar la generación y envío de la cabecera `Idempotency-Key` en las solicitudes de generación de pases (`POST /passes`).
