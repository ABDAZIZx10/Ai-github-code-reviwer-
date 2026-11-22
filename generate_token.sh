#!/usr/bin/env bash
# Compatibility wrapper — prefer scripts/generate_github_app_jwt.py
# This file used to be a misnamed Python script with hardcoded credentials.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$ROOT_DIR/scripts/generate_github_app_jwt.py" "$@"
