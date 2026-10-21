#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
platform_dir="$(cd -- "$script_dir/../../.." && pwd)"
cert_dir="$platform_dir/local/config/certs"

if ! command -v mkcert >/dev/null 2>&1; then
  printf 'mkcert is required. Install mkcert, then rerun this script.\n' >&2
  exit 1
fi

mkdir -p "$cert_dir"
mkcert -install
mkcert \
  -cert-file "$cert_dir/wealthops-ai.local.pem" \
  -key-file "$cert_dir/wealthops-ai.local-key.pem" \
  wealthops-ai.local
chmod 600 "$cert_dir/wealthops-ai.local-key.pem"

printf 'Created a locally trusted certificate for wealthops-ai.local in %s\n' "$cert_dir"
