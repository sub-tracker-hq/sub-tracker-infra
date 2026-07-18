FROM node:20-slim AS build
WORKDIR /src
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM node:20-slim
WORKDIR /app
RUN corepack enable
COPY --from=build /src/.next ./.next
COPY --from=build /src/public ./public
COPY --from=build /src/package.json ./package.json
COPY --from=build /src/node_modules ./node_modules
EXPOSE 3000
CMD ["pnpm", "start"]
