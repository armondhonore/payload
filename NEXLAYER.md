# Nexlayer — payload

<!-- nexlayer:meta version=1 analyzed=2026-06-28T08:12:05Z repo=https://github.com/armondhonore/payload branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Payload is a Next.js native headless CMS that provides a flexible administrative UI, a powerful API, and multiple database adapter options for content management.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Next.js | framework | 15.x | README.md, package.json |
| Node.js | language | 24.15.0 | .nvmrc, .node-version |
| MongoDB | database | latest | .env.example |
| PostgreSQL | database | latest | .env.example |
| pnpm | tool | 10.27.0 | Dockerfile |
| TurboRepo | build | latest | turbo.json |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- app/ — Main Next.js application logic
- packages/payload — Core CMS engine
- packages/db-*/ — Database adapters (mongodb, postgres, sqlite)
- packages/plugin-*/ — CMS functional plugins
- packages/storage-*/ — Cloud storage adapters (s3, azure, gcs)
- public/ — Static assets
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- OpenAI API (OPENAI_KEY)
- Sentry (plugin-sentry)
- Stripe API (plugin-stripe)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Node.js v24.15.0
- pnpm v10.27.0

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
PAYLOAD_DATABASE=mongodb
MONGODB_URL=mongodb://localhost:27017/payload
POSTGRES_URL=postgres://localhost:5432/payload
OPENAI_KEY=your-key-here
```

### Steps

1. `pnpm install` — Install monorepo dependencies
2. `pnpm run build:core` — Build core packages using Turbo
3. `pnpm dev` — Start the Next.js development server

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `PAYLOAD_SECRET` | _(set via Nexlayer dashboard)_ | secret |
| `app` | `DATABASE_URL` | `"mongodb://payload-mongo.pod:27017/payload"` | plain |
| `app` | `NEXT_PUBLIC_SERVER_URL` | `"https://relaxed-weasel-payload.cloud.nexlayer.ai"` | plain |
| `payload-uploads` | `mountPath` | `/app/public/media` | plain |
| `payload-uploads` | `size` | `5Gi` | plain |
| `payload-mongo` | `mountPath` | `/data/db` | plain |
| `payload-mongo` | `size` | `5Gi` | plain |

### Secrets Required

Set these in the Nexlayer dashboard before deploying:

- `PAYLOAD_SECRET` (`app` pod)

### nexlayer.yaml

```yaml
application:
  name: payload
  pods:
  - name: app
    path: /
    image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/payload:19f0d48b613"
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
    image: mirror.gcr.io/library/mongo:6
    servicePorts:
    - 27017
    volumes:
    - name: payload-mongo
      mountPath: /data/db
      size: 5Gi
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| payload-app | mirror.gcr.io/library/node:22-alpine | 3000 | web |
| mongodb | mirror.gcr.io/library/mongodb:latest | 27017 | database |

### Deployment notes

- The application pod communicates with the database via mongodb.pod:27017
- All official images are mirrored through gcr.io to comply with Nexlayer cluster rules
- Single-container-per-pod rule is enforced; DB is strictly isolated from the app

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-28T08:14:12Z  
**Live URL:** https://relaxed-weasel-payload.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: payload
  pods:
  - name: app
    path: /
    image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/payload:19f0d48b613"
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
    image: mirror.gcr.io/library/mongo:6
    servicePorts:
    - 27017
    volumes:
    - name: payload-mongo
      mountPath: /data/db
      size: 5Gi
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-28T08:12:05Z | analyzed | initial repo analysis |
| 2026-06-28T08:14:12Z | success | deployed https://relaxed-weasel-payload.cloud.nexlayer.ai |
<!-- nexlayer:end -->
