#!/usr/bin/env bash
# Mint a GitHub App installation access token from a JWT.
#
# Usage:
#   export GITHUB_APP_CLIENT_ID=...
#   export GITHUB_APP_PRIVATE_KEY_PATH=./secrets/github-app-private-key.pem
#   export GITHUB_APP_INSTALLATION_ID=...
#   ./scripts/mint_installation_token.sh
#
# Confirmed app permissions observed during prior development:
#   contents:read, metadata:read, issues:write, pull_requests:write, statuses:write

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

: "${GITHUB_APP_INSTALLATION_ID:?Set GITHUB_APP_INSTALLATION_ID}"
: "${GITHUB_APP_CLIENT_ID:?Set GITHUB_APP_CLIENT_ID}"
: "${GITHUB_APP_PRIVATE_KEY_PATH:?Set GITHUB_APP_PRIVATE_KEY_PATH}"

JWT="$(python3 scripts/generate_github_app_jwt.py)"

curl -sS -X POST \
  -H "Authorization: Bearer ${JWT}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/app/installations/${GITHUB_APP_INSTALLATION_ID}/access_tokens"
echo
