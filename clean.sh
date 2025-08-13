#!/usr/bin/env bash
set -euo pipefail

DIRS=(
  "prometheus/data"
  "grafana/data"
  "lighthouse/beacon/run"
  "nethermind/run"
)

# optional: avoid file locks
# docker compose down || true

for d in "${DIRS[@]}"; do
  if [ -d "$d" ]; then
    find "$d" -mindepth 1 \
      \( -name '.gitignore' -o -name 'execute.sh' \) -prune -o -delete
    echo "cleared $d"
  fi
done

echo "Done."

