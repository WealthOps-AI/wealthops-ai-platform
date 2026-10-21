#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
platform_dir="$(cd -- "$script_dir/../../.." && pwd)"
env_file="$platform_dir/local/config/.env"
compose_file="$platform_dir/local/compose/compose.yml"

if [[ ! -f "$env_file" ]]; then
  printf 'Local environment file not found: %s\nCopy local/config/.env.example to local/config/.env first.\n' "$env_file" >&2
  exit 1
fi

docker compose --env-file "$env_file" -f "$compose_file" run --rm migrator --seed
