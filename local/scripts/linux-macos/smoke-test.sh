#!/usr/bin/env bash
set -euo pipefail

base_url="${WEALTHOPS_BASE_URL:-https://wealthops-ai.local}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

http_status="$(curl --silent --show-error --output /dev/null \
  --write-out '%{http_code}' --max-redirs 0 "http://wealthops-ai.local/")"
if [[ "$http_status" != "308" ]]; then
  printf 'Expected HTTP to redirect to HTTPS with status 308; received HTTP %s.\n' "$http_status" >&2
  exit 1
fi

curl --silent --show-error --fail "$base_url/" --output /dev/null

unauth_status="$(curl --silent --show-error --output "$tmp_dir/unauthenticated.json" \
  --write-out '%{http_code}' "$base_url/api/v1/accounts")"
if [[ "$unauth_status" != "401" ]]; then
  printf 'Expected an unauthenticated API request to return HTTP 401; received HTTP %s.\n' "$unauth_status" >&2
  cat "$tmp_dir/unauthenticated.json" >&2
  exit 1
fi

token_status="$(curl --silent --show-error --output "$tmp_dir/token.json" \
  --write-out '%{http_code}' \
  --request POST \
  --header 'Content-Type: application/json' \
  --data '{"role":"OperationsAnalyst"}' \
  "$base_url/api/v1/auth/dev-token")"
if [[ "$token_status" != "200" ]]; then
  printf 'Development token request failed with HTTP %s.\n' "$token_status" >&2
  cat "$tmp_dir/token.json" >&2
  exit 1
fi

token="$(sed -nE 's/.*"token"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$tmp_dir/token.json")"
if [[ -z "$token" ]]; then
  printf 'The Development token endpoint returned no token.\n' >&2
  cat "$tmp_dir/token.json" >&2
  exit 1
fi

accounts_status="$(curl --silent --show-error --output "$tmp_dir/accounts.json" \
  --write-out '%{http_code}' \
  --header "Authorization: Bearer $token" \
  "$base_url/api/v1/accounts")"
if [[ "$accounts_status" != "200" ]]; then
  printf 'Authenticated accounts request failed with HTTP %s.\n' "$accounts_status" >&2
  cat "$tmp_dir/accounts.json" >&2
  exit 1
fi

if ! grep -Eq '"items"[[:space:]]*:' "$tmp_dir/accounts.json" ||
   ! grep -Eq '"total"[[:space:]]*:[[:space:]]*[0-9]+' "$tmp_dir/accounts.json"; then
  printf 'The authenticated accounts endpoint did not return the expected page response.\n' >&2
  cat "$tmp_dir/accounts.json" >&2
  exit 1
fi

total="$(sed -nE 's/.*"total"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$tmp_dir/accounts.json")"
printf 'Smoke test passed: HTTPS is trusted, HTTP redirects to HTTPS, unauthenticated API access is rejected, and authenticated API access returned %s seeded accounts.\n' "$total"
