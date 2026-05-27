# UniPark Dashboard Admin

Dashboard administrativo moderno para el sistema de gestión de parqueaderos universitarios UniPark.

## 🚀 Stack Tecnológico

- **Next.js 14+** - Full-stack React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Estilos modernos
- **NextAuth.js** - Autenticación con Keycloak (OIDC)
- **Recharts** - Gráficos en tiempo real
- **StompJS** - WebSocket para actualizaciones en vivo
- **Axios** - Cliente HTTP

## 📋 Requisitos Previos

- Node.js 18+
- npm o yarn
- Backend UniPark corriendo en `http://localhost:8081`
- Keycloak configurado

## 🔧 Instalación y Configuración

### 1. Copiar variables de entorno

```bash
cp .env.local.example .env.local
```

### 2. Editar `.env.local` con tus valores

### 3. Generar NEXTAUTH_SECRET

```bash
openssl rand -base64 32
```

### 4. Instalar dependencias

```bash
npm install
```

### 5. Ejecutar en desarrollo

```bash
npm run dev
```

Accede a `http://localhost:3000`

## 🔐 Configuración de Keycloak

Cliente OIDC:
- **Client ID:** `unipark-dashboard`
- **Valid Redirect URIs:** `http://localhost:3000/api/auth/callback/keycloak`
- **Scope:** `openid profile email roles`

## 📊 Funcionalidades

- **Stats en tiempo real** - Ocupancia, capacidad, violaciones
- **Gráficos interactivos** - Ocupancia por lote
- **Alertas del sistema** - Mantenimiento, eventos
- **Violaciones** - Gestión de violaciones con WebSocket

## 📁 Estructura

```
dashboard-admin/
├── app/
├── components/       # Componentes reutilizables
├── hooks/           # Custom hooks (WebSocket, API)
├── lib/             # Configuración (Auth, API, STOMP)
├── types/           # TypeScript types
└── middleware.ts    # Protección de rutas
```

## 🚀 Desarrollo

```bash
# Dev
npm run dev

# Build
npm run build

# Start
npm start
```

## 📝 Notas

- Actualizaciones en tiempo real vía WebSocket
- Autenticación OIDC con Keycloak
- Renovación automática de tokens JWT
- Responsive design con Tailwind
