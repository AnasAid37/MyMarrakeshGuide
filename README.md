# MyMarrakeshGuide

Production monorepo for an AI-assisted Marrakesh travel concierge and hospitality SaaS platform.

## Included in Sprint 1

- Next.js App Router traveler web foundation.
- NestJS REST API under `/api/v1`.
- Prisma ORM with PostgreSQL and a complete initial domain schema.
- Redis integration and readiness checks.
- Tailwind CSS v4 and a shared shadcn/ui-compatible design package.
- Docker images for the web and API applications.
- Docker Compose stacks for infrastructure and full local deployment.
- Nginx reverse proxy with security headers, compression, and API rate limits.
- Strict environment validation, structured logging, request IDs, CSRF protection, CORS, Helmet, throttling, and RFC 9457-style problem responses.
- Unit-test, E2E-test, formatting, linting, type-checking, and CI foundations.

## Requirements

- Node.js 24.18.1
- pnpm 11.18.0
- Docker Engine with Docker Compose v2

## Local setup

```bash
corepack enable
pnpm install
pnpm bootstrap:env
pnpm infra:up
pnpm db:generate
pnpm db:migrate
pnpm db:seed
pnpm dev
```

Services:

- Web: `http://localhost:3000`
- API: `http://localhost:3001/api/v1`
- API documentation: `http://localhost:3001/api/docs`
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

## Full Docker stack

```bash
pnpm bootstrap:env
pnpm compose:up
```

Open `http://localhost:8080`. Nginx routes browser traffic to the web service and `/api/*` traffic to the API service.

## Repository layout

```text
apps/
  api/                 NestJS API
  web/                 Next.js App Router application
packages/
  contracts/           Runtime-validated cross-application contracts
  database/            Prisma schema, migrations, seed, and Nest database module
  typescript-config/   Shared strict TypeScript configurations
  ui/                  Shared Tailwind and shadcn/ui component system
infra/
  nginx/               Reverse-proxy image and configuration
scripts/               Deterministic repository utilities
```

## Architectural rules

- The AI layer may receive only validated internal place identifiers.
- No client-controlled value grants permissions or subscription entitlements.
- Every host-scoped query must include a verified tenant boundary.
- Framework code depends on application and domain contracts, not the reverse.
- External providers are integrated behind application-owned interfaces.
- Logs must never contain tokens, cookies, passwords, raw payment details, or sensitive traveler data.

## Database changes

Create migrations from the database package:

```bash
pnpm --filter @mmg/database prisma:migrate -- --name descriptive_change
```

Production applies committed migrations only:

```bash
pnpm db:migrate:deploy
```

## Quality gates

```bash
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```
