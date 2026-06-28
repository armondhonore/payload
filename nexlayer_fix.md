# Nexlayer build override (authoritative)

This repo is the Payload CMS monorepo (pnpm workspaces, not deployable at root).
The deployable app is a self-contained Payload 3.x app in `./nexlayer-app`, pinned
to published npm packages with its own lockfile and Next.js `output: 'standalone'`.

The Kaniko build context is the repo root, so the Dockerfile below copies and builds
ONLY `nexlayer-app/`. Do NOT regenerate this Dockerfile or build the monorepo root
(`pnpm install` at root yields `ERR_PNPM_NO_SCRIPT_OR_SERVER`; building
`packages/admin-bar` is also wrong — it is a framework package, not the app).

## Fixed Dockerfile

```
# Self-contained Payload 3.x app lives in ./nexlayer-app (the repo root is the
# Payload monorepo and is not directly deployable). Build only that subfolder.
FROM node:22.17.0-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY nexlayer-app/package.json nexlayer-app/package-lock.json ./
RUN npm ci --no-audit --no-fund

FROM node:22.17.0-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY nexlayer-app/ ./
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS="--no-deprecation --max-old-space-size=8000"
# Build-time placeholders; real values come from the pod env at runtime.
ENV PAYLOAD_SECRET=build-time-placeholder
ENV DATABASE_URL=mongodb://localhost:27017/payload
RUN npm run build

FROM node:22.17.0-alpine AS runner
RUN apk add --no-cache libc6-compat
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
```

## Fixed nexlayer.yaml

```
application:
  name: payload
  pods:
  - name: app
    path: /
    servicePorts:
    - 3000
    vars:
      PAYLOAD_SECRET: "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
      DATABASE_URL: "mongodb://payload-mongo.pod:27017/payload"
      NEXT_PUBLIC_SERVER_URL: "https://relaxed-weasel-payload.cloud.nexlayer.ai"
    volumes:
    - name: payload-uploads
      mountPath: /app/public/media
      size: 5Gi
  - name: payload-mongo
    image: mirror.gcr.io/library/mongo:5
    servicePorts:
    - 27017
    volumes:
    - name: payload-mongo
      mountPath: /data/db
      size: 5Gi
```
