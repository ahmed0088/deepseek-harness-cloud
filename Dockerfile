# Cloud runtime for the DeepSeek Harness web application.
FROM node:24-bookworm AS build

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH \
    CI=true

RUN corepack enable && corepack prepare pnpm@11.28.5 --activate \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN pnpm install --frozen-lockfile \
    && pnpm run build:official

FROM node:24-bookworm AS runtime
ENV NODE_ENV=production \
    DSH_TELEMETRY_DISABLED=1 \
    HOME=/data
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl bubblewrap \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /data --shell /usr/sbin/nologin dsh

COPY --from=build --chown=dsh:dsh /app /app
COPY --chown=dsh:dsh deploy/start-web.sh /usr/local/bin/start-dsh-web
RUN chmod 0755 /usr/local/bin/start-dsh-web \
    && mkdir -p /data \
    && chown -R dsh:dsh /data

USER dsh
EXPOSE 3080
ENTRYPOINT ["/usr/local/bin/start-dsh-web"]
