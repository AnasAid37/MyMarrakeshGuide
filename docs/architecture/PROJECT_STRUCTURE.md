# Project structure

```text
MyMarrakeshGuide/
├── apps/
│   ├── api/                     NestJS HTTP application and composition root
│   │   ├── src/common/          Cross-cutting delivery concerns
│   │   ├── src/config/          Runtime configuration validation
│   │   ├── src/health/          Liveness and readiness feature
│   │   ├── src/infrastructure/  Provider adapters shared by active modules
│   │   ├── src/security/        HTTP security primitives
│   │   └── src/system/          Service metadata feature
│   └── web/                     Next.js App Router application
│       ├── public/              Deployable static assets
│       ├── src/app/             Routes, metadata and route boundaries
│       ├── src/components/      Product-level composed components
│       ├── src/config/          Browser/server environment contract
│       ├── src/lib/             Application-owned browser adapters
│       └── src/providers/       Deliberate client-side provider boundary
├── packages/
│   ├── contracts/               Runtime-validated shared API contracts
│   ├── database/                Prisma schema, migration, seed and Nest adapter
│   ├── typescript-config/       Strict compiler baselines
│   └── ui/                      Tailwind v4 tokens and shadcn-compatible primitives
├── infra/nginx/                 Edge reverse-proxy image and configuration
├── docs/                        Architecture and approved visual direction
├── scripts/                     Deterministic repository utilities
└── .github/                     CI, security analysis and dependency automation
```

## Feature module convention

A business module is added only when its sprint begins. It owns four explicit layers:

```text
modules/<feature>/
├── domain/          Entities, value objects, policies and repository ports
├── application/     Commands, queries, use cases and transaction boundaries
├── infrastructure/  Prisma repositories and external-provider adapters
└── presentation/    Versioned controllers, request schemas and response mapping
```

No empty future-module directories are committed. This prevents dead architecture, ambiguous ownership and generic scaffolding from becoming permanent code.

## Dependency direction

- Presentation depends on application contracts.
- Infrastructure implements ports owned by the application or domain layer.
- Domain code imports no NestJS, Prisma, Stripe, Google or OpenAI SDK.
- Cross-application contracts contain data shapes only and never business orchestration.
- The web application consumes the API through an application-owned client rather than provider SDKs in components.
