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
COPY packages/ui/package.json packages/ui/package.json
COPY apps/web/package.json apps/web/package.json
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --no-frozen-lockfile

FROM dependencies AS builder
ARG NEXT_PUBLIC_APP_URL=http://localhost:8080
ARG NEXT_PUBLIC_API_URL=/api/v1
ARG INTERNAL_API_ORIGIN=http://api:3001
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    INTERNAL_API_ORIGIN=$INTERNAL_API_ORIGIN
COPY packages/typescript-config packages/typescript-config
COPY packages/contracts packages/contracts
COPY packages/ui packages/ui
COPY apps/web apps/web
RUN pnpm --filter @mmg/contracts build \
    && pnpm --filter @mmg/web build

FROM node:24.18-bookworm-slim AS runtime
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    HOSTNAME=0.0.0.0 \
    PORT=3000
RUN groupadd --system --gid 10001 mmg \
    && useradd --system --uid 10001 --gid mmg --home-dir /app --shell /usr/sbin/nologin mmg
WORKDIR /app
COPY --from=builder --chown=mmg:mmg /workspace/apps/web/.next/standalone ./
COPY --from=builder --chown=mmg:mmg /workspace/apps/web/.next/static ./apps/web/.next/static
COPY --from=builder --chown=mmg:mmg /workspace/apps/web/public ./apps/web/public
USER mmg
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/api/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"
CMD ["node", "apps/web/server.js"]
