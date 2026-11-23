#!/usr/bin/env bash
set -euo pipefail

port="${PORT:-3080}"
# dsh deliberately rejects 0.0.0.0. The first container IP is reachable by the
# cloud ingress while retaining the Harness host/origin security fence.
host="${DSH_BIND_HOST:-$(hostname -i | awk '{print $1}')}"
if [[ -z "$host" ]]; then
  echo "Unable to determine the container bind address; set DSH_BIND_HOST." >&2
  exit 1
fi

args=(web --no-open --host "$host" --port "$port")
if [[ -n "${PUBLIC_URL:-}" ]]; then
  args+=(--public-url "$PUBLIC_URL")
fi
if [[ -n "${TRUSTED_HOSTS:-}" ]]; then
  while IFS= read -r trusted; do
    [[ -n "$trusted" ]] && args+=(--trusted-host "$trusted")
  done < <(printf '%s' "$TRUSTED_HOSTS" | tr ', ' '\n\n' | sed '/^$/d')
fi

exec node /app/apps/cli/lib/bin.js "${args[@]}"
