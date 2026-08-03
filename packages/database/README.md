# Database package

Owns the PostgreSQL schema, committed migrations, Prisma client and NestJS database module.

## Rules

- Production schema changes are applied only through committed migrations.
- Published places are retained for historical trip integrity; lifecycle status replaces destructive deletion.
- Monetary values use integer minor units or fixed-precision database values.
- Tenant identifiers must be part of host-scoped access paths and indexed query plans.
- Raw SQL requires explicit review and tests.
