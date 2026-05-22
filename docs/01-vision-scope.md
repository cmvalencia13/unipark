# 01 — Visión y Alcance

## Visión
UniPark es una plataforma de gestión de parqueaderos universitarios que combina apps móviles nativas con un backend robusto para ofrecer **acceso sin contacto (QR/NFC)**, **monitoreo de ocupación en tiempo real**, y **gobierno operativo** para administradores.

## Problema
- Filas en entrada/salida por validación manual.
- Falta de visibilidad de ocupación por zona.
- Violaciones (parqueo indebido, pase prestado) sin trazabilidad.
- Sin restricción real a la comunidad universitaria.

## Usuarios objetivo
- **Drivers:** estudiantes, profesores y staff con vehículo registrado.
- **Guards:** personal de seguridad en puntos de control.
- **Admins:** coordinadores de movilidad del campus.
- **Superadmins:** TI / administración central.

## Alcance del MVP (Semestre)
- ✅ Autenticación restringida a dominio `@<universidad>.edu`.
- ✅ Apps nativas Android e iOS para Drivers y Guards.
- ✅ Web admin dashboard (Next.js, *opcional* — el foco es móvil).
- ✅ QR firmado con expiración 60s + HCE/Core NFC.
- ✅ Lectura de QR en cámara y logging entrada/salida.
- ✅ Ocupación en vivo por lote (WebSocket).
- ✅ Pagos **stub** (sin gateway real) con UI realista.
- ✅ RBAC, rate limiting (5 req / 10s por usuario), audit logs.

## Fuera de alcance (v1)
- Integración con gateway de pagos real (Stripe/PayU).
- Reconocimiento de placas (LPR).
- Reservas anticipadas de cupo.
- Multi-tenant cross-universidad.

## Métricas de éxito
- p95 latencia API < 200 ms.
- Tiempo entrada/salida promedio < 8 s.
- 99.5% uptime mensual.
- 0 incidentes de seguridad críticos.
