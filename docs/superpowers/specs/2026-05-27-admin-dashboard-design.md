# Admin Dashboard — Design Spec

**Date:** 2026-05-27
**Status:** Approved
**Project:** UniPark — University Parking Management System

## Overview

A web admin dashboard for the **admin** and **superadmin** roles. Built with Next.js 14 (App Router) + TypeScript + Tailwind CSS, backed by new Spring Boot admin API endpoints under `/v1/admin/`. Single unified dashboard with role-gated navigation — admins see 3 pages, superadmins see all 6.

## Architecture

```
Browser → Next.js 14 App Router → Spring Boot 3.3 API → PostgreSQL 16
                 ↕
            Keycloak 25 (OIDC)
```

- **Auth:** NextAuth.js v5 with Keycloak provider. OIDC PKCE. JWT stored in httpOnly session cookie. Role claims extracted and validated on both Next.js middleware and Spring Boot `@PreAuthorize`.
- **Data fetching:** Server Components with `fetch` for read-heavy pages (Dashboard, Lots, Audit). Client Components with SWR for interactive pages (Users, Violations, Settings).
- **Design system:** Same "cyber-academic" dark theme as the Android app — glassmorphism panels, Sora headings, Material Symbols icons, neon green (#36ffc4) and cyan (#00dbe9) accents.

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript 5.x |
| Styling | Tailwind CSS 3.4 + Unipark design tokens |
| Auth | NextAuth.js v5 + Keycloak OIDC |
| Icons | Material Symbols |
| Charts | Recharts |
| Client fetching | SWR |

## API Endpoints (new, Spring Boot)

All under `/v1/admin/`, secured with `@PreAuthorize`.

### User Management (superadmin)

- `GET /v1/admin/users?page=&size=&role=&search=` — paginated user list, filterable by role and text search
- `GET /v1/admin/users/{id}` — user detail with vehicles, violations, scan history
- `PATCH /v1/admin/users/{id}` — update `role`, `active`, or `driverCategory`

### Dashboard Stats (admin+)

- `GET /v1/admin/stats` — `{ lots: [{name, capacityTotal, capacityUsed}], todayScans: N, pendingViolations: N, totalUsers: N }`

### Violations Console (admin+)

- `GET /v1/admin/violations?status=&lotId=&page=&size=&sort=` — paginated violations with filters
- `PATCH /v1/admin/violations/{id}` — `{ status: "APPROVED"|"DISMISSED", resolutionNote: "..." }`

### Audit Log (superadmin)

- `GET /v1/admin/audit?from=&to=&actor=&action=&page=&size=` — paginated audit trail

### Settings (superadmin)

- `GET /v1/admin/settings` — current global configuration
- `PATCH /v1/admin/settings` — update thresholds, rate limits, toggles

## Pages

### 1. Dashboard (`/admin/dashboard`) — admin+

- Occupancy cards per lot with progress bars (green < 80%, red > 90%)
- Today's scan count, pending violations count, total users
- Server Component, revalidated every 30s

### 2. Lots (`/admin/lots`) — admin+

- Table: name, capacity total, capacity used, occupancy bar, status badge, actions
- "New Lot" button opens modal with name + capacity fields
- Row click navigates to detail or inline edit
- Server Component

### 3. Violations (`/admin/violations`) — admin+

- Filter bar: status tabs (All, Pending, Approved, Dismissed), lot dropdown, date range
- Table: vehicle plate, guard, lot, reason preview, status badge, date
- Click row → slide-out drawer with full detail, evidence image, resolution history
- Approve/Dismiss buttons with required resolution note textarea
- Client Component + SWR

### 4. Users & Roles (`/admin/users`) — superadmin

- Search bar (name, email, university ID) + role filter dropdown
- Table: avatar + name, email, role badge (color-coded), status dot, actions menu
- Click role badge → dropdown to change role (driver/guard/admin/superadmin) with ConfirmDialog
- Active/Inactive toggle switch
- Client Component + SWR, optimistic updates with rollback on error

### 5. Audit Log (`/admin/audit`) — superadmin

- Filters: date range picker, actor search, action dropdown
- Table: timestamp, actor, action, target ID, IP
- Expandable row showing full JSON payload
- "Export CSV" button
- Server Component with client-side filter controls

### 6. Settings (`/admin/settings`) — superadmin

- Sections: Occupancy thresholds (warning %, critical %), Rate limiting (requests per window, window seconds), QR pass expiry (seconds), Maintenance mode toggle
- Each section has its own Save button
- Client Component + SWR

## Navigation & Layout

- **Sidebar** (240px, fixed): Logo at top, "Main" section (Dashboard, Lots, Violations), "Administration" section (Users & Roles, Audit, Settings — superadmin only), "Account" section (Sign Out)
- **Header** (56px, sticky): User avatar + name + role badge, right-aligned
- **Main content**: padded area, responsive (sidebar collapses to hamburger on mobile)
- Active nav item: green highlight background + glow text

## Component Tree

```
components/
├── ui/          GlassPanel, OccupancyBar, StatusPill, StatusDot, DataTable, Skeleton
├── layout/      Sidebar, Header, RoleGate
└── shared/      SearchInput, FilterDropdown, ConfirmDialog, Toast
```

## Auth Flow

1. User visits `/admin` → Next.js middleware checks session
2. Unauthenticated → redirect to Keycloak login
3. Keycloak validates `@universidad.edu` domain restriction
4. Auth code returned → NextAuth exchanges for JWT
5. JWT stored in httpOnly session cookie, role extracted
6. Middleware reads role: admin routes gated to `admin` + `superadmin`, superadmin routes gated to `superadmin` only
7. Backend double-defends with `@PreAuthorize` on every admin endpoint

## Error & Edge States

| State | Behavior |
|---|---|
| **Loading** | Shimmer skeleton cards matching content shape |
| **Empty** | Centered illustration + descriptive message + clear-filters CTA |
| **Error** | Toast notification with message + retry button. Inline error for individual row failures |
| **403 Forbidden** | "You don't have permission to access this page" banner |
| **Optimistic failure** | Rollback UI change + error toast |

## Route Structure

```
app/
├── layout.tsx              RootLayout (theme + auth provider)
├── (auth)/
│   └── login/page.tsx      Keycloak redirect
├── (admin)/                Layout: Sidebar + Header shell
│   ├── dashboard/page.tsx
│   ├── lots/page.tsx
│   ├── violations/page.tsx
│   ├── (superadmin)/       Route group, gated by middleware
│   │   ├── users/page.tsx
│   │   ├── audit/page.tsx
│   │   └── settings/page.tsx
│   └── components/
```

## Implementation Order

1. **Admin API endpoints** — Spring Boot controllers + security config for `/v1/admin/**`
2. **Next.js scaffold** — project setup, Tailwind config with Unipark tokens, layout shell
3. **Auth integration** — NextAuth.js + Keycloak provider + middleware role gating
4. **Dashboard page** — stats cards + occupancy bars (Server Component)
5. **Users & Roles page** — table, search, role change, confirm dialog (Client + SWR)
6. **Lots page** — table + create modal
7. **Violations page** — filterable table + detail drawer + approve/dismiss
8. **Audit Log page** — filterable table + expandable rows + CSV export
9. **Settings page** — grouped form with per-section save
10. **Shared components** — GlassPanel, OccupancyBar, StatusPill, DataTable, ConfirmDialog, Toast
