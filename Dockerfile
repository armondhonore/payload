FROM mirror.gcr.io/library/node:22-alpine
# build-time env seeded from .env.example
ENV OPENAI_KEY=nexlayer-placeholder
ENV PAYLOAD_DATABASE=mongodb
WORKDIR /app
COPY . .
RUN npm install -g pnpm@10.27.0 && pnpm install --no-frozen-lockfile
RUN cd packages/admin-bar && NODE_OPTIONS="--max-old-space-size=4096" pnpm run build
WORKDIR /app/packages/admin-bar
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "./src/index.ts"]
