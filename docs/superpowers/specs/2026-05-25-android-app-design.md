# Android App Design — UniPark

**Date:** 2026-05-25
**Branch:** `kotlin-branch`
**Approach:** UI-First, Screen-by-Screen
**Design Source:** Stitch project "Swift Campus Parking" (ID: 18131960925766994418)

---

## 1. Architecture

Clean Architecture + MVVM as specified in `docs/02-tech-stack.md`.

```
presentation/   → Screens + ViewModels (Compose UI, fake data initially)
domain/         → UseCases + domain models (pure Kotlin)
data/           → Repositories + DataSources (remote: Retrofit, local: Room, prefs: DataStore)
core/           → Theme, shared components, navigation, DI, auth, crypto
```

### Navigation Graph

```
AuthGate (OIDC PKCE login)
  └── MainScaffold (BottomNavBar: 4 tabs)
        ├── Status   → DashboardScreen
        ├── Map      → MapScreen
        ├── Permits  → PermitsScreen
        └── Access   → AccessGateScreen
```

---

## 2. Design System (extracted from Stitch)

### Colors

| Token | Hex | Usage |
|---|---|---|
| `background` | `#111317` | App background |
| `surface_container` | `#1e2024` | Card surfaces |
| `primary_fixed_dim` | `#00dbe9` | Headlines, active states |
| `primary_container` | `#00f0ff` | Primary fills |
| `secondary_fixed` | `#36ffc4` | Accent, glow, valid status |
| `on_background` | `#e2e2e8` | Body text |
| `on_surface_variant` | `#b9cacb` | Subtle text |
| `error` | `#ffb4ab` | Errors, full lots |
| `outline` | `#849495` | Borders |

### Typography

- **Display LG:** Sora 48/56 Bold — hero numbers
- **Headline LG:** Sora 32/40 SemiBold — page titles
- **Headline MD:** Sora 24/32 SemiBold — section headers
- **Body LG:** Inter 18/28 Regular — card titles
- **Body MD:** Inter 16/24 Regular — default text
- **Label MD:** Inter 14/20 Medium — buttons, tabs
- **Label SM:** Inter 12/16 SemiBold — overlines, badges
- **Mono Data:** Inter 14/20 Bold — plate numbers, timestamps

### Visual Language

- **Glassmorphism:** `backdrop-blur: 16px`, `rgba(30,32,36,0.6)` background, semi-transparent white/black borders
- **Liquid Glass** (Map screen only): `blur: 24px`, `saturate(180%)`, `rgba(30,32,36,0.45)`, inner glow shadow
- **Glow Active:** `box-shadow: 0 0 24px rgba(54,255,196,0.25)` on valid/active cards
- **Border Radius:** 8px default, 12px for cards, 16px for map chips
- **Icons:** Material Symbols Outlined with FILL variation for active/inactive states
- **Animations:** slideUpFade (entrance), shimmer (status), scan-pulse (NFC), btn-shine (purchase), pulse-ring (map pins)

---

## 3. Screen Inventory

### Screen 1: Dashboard (Status Tab)

Reusable components: GlassPanel, GlowActivePanel, StatusPill, OccupancyBar, AlertItem, StaggeredEntrance.

- `TopAppBar` — avatar + "UniPark" logo + notification bell with green dot
- `ActivePermitCard` (hero, glow-active) — verified badge, permit name, StatusPill with shimmer
- `CurrentLocationCard` — location icon, lot name + spot number, Find My Car button
- `CampusTrendsCard` — section header, OccupancyBar per lot (color-coded)
- `SystemAlertsCard` — AlertItem list (icon circle + title + body + mono timestamp)

### Screen 2: Map (Availability Tab)

Reusable components: LiquidGlassPanel, FilterChip, LotPin, LotDetailSheet, PulseRing.

- Full-bleed map canvas with campus image overlay (low opacity, blend-screen)
- `SearchBar` — LiquidGlass, text input + tune button
- `FilterChipRow` — horizontal scroll: EV Charging, ADA Spots, Faculty Only, Visitor
- `LotPin` x3 — positioned absolutely: boundary zone (rotated), PinDot (pulse-ring), GlassBubble label
- `LotDetailSheet` — slide-up from bottom: color accent bar, lot name, occupancy meter, Navigate + Bookmark

### Screen 3: Permits Tab

Reusable components: VehicleCard, PricingCard, ShineButton, EntranceAnimation.

- "Active Permits" section — ActivePermitCard (reused), expanded with valid-until date + manage link
- "Registered Vehicles" section — Add Guest button, VehicleCard list (plate + make/model + delete; guest variant with dashed border + temp badge)
- "Purchase New Permit" section — PricingCard grid: Semester ($150), Monthly ($45/mo), Daily ($25/5-pack) with ShineButton CTAs

### Screen 4: Access Gate (Access Tab)

Reusable components: ScannerCore, ConcentricRings, ScanLaser, HUDGrid, StatusDot.

- HUD grid background + ambient radial glow
- `AuthorizedVehicleCard` — glass panel: destination lot, car icon, divider, plate number
- `ScannerCore` — concentric animated rings (staggered), scanning laser line, NFC icon + "Tap to Enter"
- System Ready indicator + Need Assistance button (error-tinted)

---

## 4. Shared Component Inventory

### Design System (core/ui/)

| Component | Description |
|---|---|
| `UniParkTheme` | Material3 dark + Stitch color scheme |
| `UniParkTypography` | Sora headings + Inter body |
| `GlassPanel` | blur(16px) + semi-transparent bg + white/black borders |
| `LiquidGlassPanel` | Stronger variant: blur(24px), saturate(180%), inner glow |
| `GlowActivePanel` | GlassPanel + neon green box-shadow |
| `StatusPill` | Pulse dot + label text (Valid, Active, Ready) |
| `OccupancyBar` | Label + percentage + gradient progress bar with glow |
| `StatusDot` | Tiny pulsing colored dot |
| `ShineButton` | Button with gradient shine sweep on press |
| `EntranceAnimation` | Modifier: slideUpFade with indexed delay |
| `PulseRing` | Modifier: expanding ring animation |

### Navigation (core/navigation/)

| Component | Description |
|---|---|
| `TopAppBar` | Avatar + centered logo + notification bell |
| `BottomNavBar` | 4 tabs with glow indicator on active tab |
| `AuthGate` | OIDC login wrapper screen |

---

## 5. Project Structure

```
com.unipark.android/
├── core/
│   ├── ui/theme/          UniParkTheme, Color, Type, GlassPanel modifiers
│   ├── ui/components/     GlassPanel, StatusPill, OccupancyBar, ShineButton, etc.
│   ├── navigation/        TopAppBar, BottomNavBar, NavGraph, AuthGate
│   ├── network/           Retrofit client, OkHttp interceptors, Moshi, cert pinning
│   ├── auth/              AppAuth OIDC, TokenStore in Android Keystore
│   ├── crypto/            Tink, HMAC verification
│   ├── di/                Hilt modules
│   └── util/              Extensions, constants
├── domain/
│   ├── model/             User, Vehicle, ParkingLot, Pass, Scan, Violation
│   └── usecase/           GetPasses, SubmitScan, GetOccupancy, etc.
├── data/
│   ├── repository/        PassRepository, LotRepository, ScanRepository, etc.
│   ├── remote/            ApiService, DTOs, WebSocket client
│   └── local/             Room DAOs, DataStore preferences, offline queue
└── presentation/
    ├── dashboard/         DashboardScreen, DashboardViewModel
    ├── map/               MapScreen, MapViewModel
    ├── permits/           PermitsScreen, PermitsViewModel
    ├── access/            AccessGateScreen, ScannerViewModel
    └── auth/              LoginScreen, AuthViewModel
```

---

## 6. Implementation Phases (UI-First)

### Phase 1 — Project Skeleton + Design System
- Gradle setup: Kotlin DSL, Version Catalogs, Hilt, Compose BOM, dependencies
- UniParkTheme (Material3 dark + Stitch colors), Typography (Sora + Inter)
- Core UI components: GlassPanel, LiquidGlassPanel, GlowActivePanel, StatusPill, OccupancyBar, ShineButton, StatusDot, PulseRing, EntranceAnimation
- TopAppBar + BottomNavBar shell with placeholder screens and fake navigation
- Empty MainActivity wired with Hilt

### Phase 2 — Dashboard Screen
- ActivePermitCard, CurrentLocationCard, CampusTrendsCard, SystemAlertsCard
- Staggered entrance animations on all cards
- Fake ViewModel data, functional Tab 1

### Phase 3 — Permits Screen
- ActivePermitCard (reused), VehicleCard list, PricingCard grid
- Entrance animations, functional Tab 3

### Phase 4 — Map Screen
- MapCanvas with overlay, SearchBar, FilterChipRow, LotPin components, LotDetailSheet
- Pin pulse animations, slide-up sheet, functional Tab 2

### Phase 5 — Access Gate + Auth
- ScannerCore with animations, AuthorizedVehicleCard, HUD grid, AuthGate OIDC flow
- Token storage in Keystore, functional Tab 4, full nav flow

### Phase 6 — Real Data Layer + Polish
- Retrofit/Moshi API client, Room persistence, WebSocket client, DataStore
- Replace fake ViewModels with real repositories
- Offline scan queue, error/loading/empty states
- ktlint + detekt, unit tests for domain/data
