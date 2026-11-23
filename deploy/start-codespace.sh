#!/usr/bin/env bash
set -euo pipefail

echo "Preparing DeepSeek Harness (the first run can take several minutes)..."
corepack enable
corepack prepare pnpm@11.28.5 --activate
if [[ ! -d node_modules ]]; then
  echo "Installing dependencies..."
  pnpm install --frozen-lockfile
fi
if [[ ! -f apps/cli/lib/bin.js ]]; then
  echo "Building the Harness..."
  pnpm run build:official
fi

port="${PORT:-3080}"
host="$(hostname -i | awk '{print $1}')"
name="${CODESPACE_NAME:-}"
args=(web --no-open --host "$host" --port "$port")

# GitHub's forwarded HTTPS URL is https://CODESPACE_NAME-PORT.app.github.dev.
# Supplying both values keeps Harness's Host/Origin fence compatible with the
# browser URL while retaining its launch-token authentication.
if [[ -n "$name" ]]; then
  public_url="https://${name}-${port}.app.github.dev/"
  args+=(--public-url "$public_url" --trusted-host "${name}-${port}.app.github.dev")
fi

exec node apps/cli/lib/bin.js "${args[@]}"
