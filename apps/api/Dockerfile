# syntax=docker/dockerfile:1.7
FROM node:24.18-bookworm-slim AS base
ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH \
    NEXT_TELEMETRY_DISABLED=1
RUN corepack enable && corepack prepare pnpm@11.18.0 --activate
WORKDIR /workspace

FROM base AS dependencies
COPY package.json pnpm-workspace.yaml turbo.json tsconfig.json .npmrc ./
COPY packages/typescript-config/package.json packages/typescript-config/package.json
COPY packages/contracts/package.json packages/contracts/package.json
COPY packages/database/package.json packages/database/package.json
COPY apps/api/package.json apps/api/package.json
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --no-frozen-lockfile

FROM dependencies AS builder
COPY packages/typescript-config packages/typescript-config
COPY packages/contracts packages/contracts
COPY packages/database packages/database
COPY apps/api apps/api
RUN pnpm --filter @mmg/database prisma:generate \
    && pnpm --filter @mmg/contracts build \
    && pnpm --filter @mmg/database build \
    && pnpm --filter @mmg/api build \
    && pnpm --filter @mmg/api deploy --prod /opt/api

FROM node:24.18-bookworm-slim AS runtime
ENV NODE_ENV=production \
    PORT=3001
RUN groupadd --system --gid 10001 mmg \
    && useradd --system --uid 10001 --gid mmg --home-dir /app --shell /usr/sbin/nologin mmg
WORKDIR /app
COPY --from=builder --chown=mmg:mmg /opt/api ./
USER mmg
EXPOSE 3001
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3001/api/v1/health/live').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"
CMD ["node", "dist/main.js"]

FROM builder AS migrate
ENV NODE_ENV=production
CMD ["pnpm", "--filter", "@mmg/database", "prisma:migrate:deploy"]
