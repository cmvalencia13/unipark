# Contribuir a UniPark

1. Lee `docs/10-ai-collaboration-guide.md`.
2. Encuentra/crea un issue con label de tu área.
3. Crea rama `feat/<area>-<desc>`, `fix/...`, etc.
4. Sigue Conventional Commits.
5. Abre PR contra `main`, completa la checklist.
6. Espera 2 reviews + CI verde.

## Setup local
```bash
# Backend + servicios
docker compose -f infra/docker-compose.yml up -d
cd backend && ./gradlew bootRun

# Android
cd android && ./gradlew installDebug

# iOS
cd ios && open UniPark.xcodeproj
```
