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
# nexlayer-app ships no public/ dir; Next standalone won't create one. The runner
# stage COPYs /app/public and the nexlayer.yaml mounts uploads at /app/public/media,
# so guarantee the dir exists or the runner-stage COPY fails ("no such file").
RUN mkdir -p public

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
