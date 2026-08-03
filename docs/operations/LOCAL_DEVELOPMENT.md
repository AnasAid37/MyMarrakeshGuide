# Local development

## One-time bootstrap

```bash
corepack enable
corepack prepare pnpm@11.18.0 --activate
pnpm install
pnpm bootstrap:env
pnpm infra:up
pnpm db:generate
pnpm db:migrate
pnpm db:seed
```

`bootstrap:env` refuses to overwrite an existing `.env` and creates cryptographically random local database, Redis, CSRF and JWT secrets.

## Run the applications

```bash
pnpm dev
```

- Web: `http://localhost:3000`
- API: `http://localhost:3001/api/v1`
- OpenAPI UI in local development: `http://localhost:3001/api/docs`

## Full container topology

```bash
pnpm compose:up
```

The edge endpoint is `http://localhost:8080`. The composition runs built production applications, applies committed migrations before API startup and keeps PostgreSQL and Redis on an internal network. Production deployments must terminate TLS before Nginx and use deployment-managed secrets rather than `.env` files.

## Reset local infrastructure

```bash
pnpm infra:down
docker volume rm my-marrakesh-guide-infrastructure_postgres_data
docker volume rm my-marrakesh-guide-infrastructure_redis_data
```

Deleting volumes permanently removes local data.
