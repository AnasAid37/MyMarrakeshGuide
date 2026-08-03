# Web application

Next.js App Router application for travelers and public hospitality entry points.

## Boundaries

- Server Components are the default.
- Client Components are limited to interactive islands and providers.
- Browser API calls use the same-origin `/api/v1` path.
- Shared primitives come from `@mmg/ui`; cross-service payloads come from `@mmg/contracts`.
- Private traveler, host and administrative routes must remain non-indexable.

## Commands

```bash
pnpm --filter @mmg/web dev
pnpm --filter @mmg/web typecheck
pnpm --filter @mmg/web test
pnpm --filter @mmg/web test:e2e
pnpm --filter @mmg/web build
```
