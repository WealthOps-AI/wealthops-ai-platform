#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
platform_dir="$(cd -- "$script_dir/../../.." && pwd)"
env_file="$platform_dir/local/config/.env"
compose_file="$platform_dir/local/compose/compose.yml"
cert_file="$platform_dir/local/config/certs/wealthops-ai.local.pem"
key_file="$platform_dir/local/config/certs/wealthops-ai.local-key.pem"

if [[ ! -f "$env_file" ]]; then
  printf 'Local environment file not found: %s\nCopy local/config/.env.example to local/config/.env first.\n' "$env_file" >&2
  exit 1
fi

if [[ ! -f "$cert_file" || ! -f "$key_file" ]]; then
  printf 'Local TLS certificate not found.\nRun bash "%s/generate-local-certificate.sh" first.\n' "$script_dir" >&2
  exit 1
fi

compose_args=(--env-file "$env_file" -f "$compose_file")
case "${1:-}" in
  "")
    ;;
  --full)
    compose_args+=(--profile full)
    ;;
  *)
    printf 'Usage: %s [--full]\n' "$0" >&2
    exit 2
    ;;
esac

docker compose "${compose_args[@]}" up --build -d

printf 'WealthOps local services are starting. Check readiness with %s/smoke-test.sh.\n' "$script_dir"
printf 'Application: https://wealthops-ai.local\n'
if [[ "${1:-}" == "--full" ]]; then
  printf 'Airflow: http://localhost:8080 | Kafka bootstrap: localhost:29092\n'
fi
