#!/usr/bin/env python3
"""
Generate a short-lived GitHub App JWT (RS256, max 10 minutes).

Confirmed usage in this project:
  Authorization: Bearer <jwt>
  GET  https://api.github.com/app
  GET  https://api.github.com/app/installations
  POST https://api.github.com/app/installations/{installation_id}/access_tokens

Requires: pip install PyJWT cryptography

Environment (preferred):
  GITHUB_APP_CLIENT_ID          Client ID used as JWT `iss`
  GITHUB_APP_PRIVATE_KEY_PATH   Path to the App private key (.pem)

CLI:
  python scripts/generate_github_app_jwt.py [pem_path] [client_id]
"""

from __future__ import annotations

import os
import sys
import time

try:
    import jwt
except ImportError:
    sys.stderr.write(
        "Missing dependency: PyJWT. Install with:\n"
        "  pip install PyJWT cryptography\n"
    )
    sys.exit(1)


def main() -> int:
    pem_path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else os.environ.get("GITHUB_APP_PRIVATE_KEY_PATH", "")
    )
    client_id = (
        sys.argv[2]
        if len(sys.argv) > 2
        else os.environ.get("GITHUB_APP_CLIENT_ID", "")
    )

    if not pem_path or not client_id:
        sys.stderr.write(
            "Usage: python scripts/generate_github_app_jwt.py <pem_path> <client_id>\n"
            "   or set GITHUB_APP_PRIVATE_KEY_PATH and GITHUB_APP_CLIENT_ID\n"
        )
        return 1

    if not os.path.isfile(pem_path):
        sys.stderr.write(f"Private key not found: {pem_path}\n")
        return 1

    with open(pem_path, "rb") as pem_file:
        signing_key = pem_file.read()

    now = int(time.time())
    payload = {
        "iat": now - 60,  # clock skew allowance
        "exp": now + 600,  # GitHub max JWT lifetime
        "iss": client_id,
    }

    encoded_jwt = jwt.encode(payload, signing_key, algorithm="RS256")
    # PyJWT may return bytes on older versions
    if isinstance(encoded_jwt, bytes):
        encoded_jwt = encoded_jwt.decode("utf-8")

    print(encoded_jwt)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
