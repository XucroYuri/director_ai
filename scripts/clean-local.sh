#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_DATA=0
WITH_DOCKER=0

for arg in "$@"; do
  case "$arg" in
    --with-data)
      WITH_DATA=1
      ;;
    --with-docker)
      WITH_DOCKER=1
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: scripts/clean-local.sh [--with-data] [--with-docker]"
      exit 1
      ;;
  esac
done

echo "[1/4] Removing local caches..."
rm -rf "$ROOT_DIR/.dart_tool" "$ROOT_DIR/build" "$ROOT_DIR/web/.venv"
find "$ROOT_DIR" -name "__pycache__" -type d -prune -exec rm -rf {} +
find "$ROOT_DIR" -name "*.pyc" -type f -delete
find "$ROOT_DIR" -name ".DS_Store" -type f -delete

echo "[2/4] Ensuring runtime directories exist..."
mkdir -p \
  "$ROOT_DIR/web/assets" \
  "$ROOT_DIR/web/projects" \
  "$ROOT_DIR/web/outputs" \
  "$ROOT_DIR/web/exports" \
  "$ROOT_DIR/web/uploads"

if [[ "$WITH_DATA" -eq 1 ]]; then
  echo "[3/4] Purging web runtime data..."
  rm -rf \
    "$ROOT_DIR/web/projects/"* \
    "$ROOT_DIR/web/outputs/"* \
    "$ROOT_DIR/web/exports/"* \
    "$ROOT_DIR/web/uploads/"*
else
  echo "[3/4] Keeping web runtime data (use --with-data to purge)."
fi

if [[ "$WITH_DOCKER" -eq 1 ]]; then
  echo "[4/4] Pruning unused Docker resources..."
  docker system prune -af --volumes
else
  echo "[4/4] Docker prune skipped (use --with-docker)."
fi

echo "Local cleanup finished."
