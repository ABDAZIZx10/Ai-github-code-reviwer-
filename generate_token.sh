#!/usr/bin/env python3
import sys
import time

import jwt

# Credentials
DEFAULT_PEM = "./ci-cd-reviewer.2026-06-25.private-key.pem"
DEFAULT_CLIENT_ID = "Iv23lijnk5sYiJa5BpJo"

# Get PEM file path
if len(sys.argv) > 1:
    pem = sys.argv[1]
else:
    pem = DEFAULT_PEM

# Get the Client ID
if len(sys.argv) > 2:
    client_id = sys.argv[2]
else:
    client_id = DEFAULT_CLIENT_ID

# Open PEM
with open(pem, 'rb') as pem_file:
    signing_key = pem_file.read()

payload = {
    # Issued at time
    'iat': int(time.time()),
    # JWT expiration time (10 minutes maximum)
    'exp': int(time.time()) + 600,
    
    # GitHub App's client ID
    'iss': client_id

}

# Create JWT
encoded_jwt = jwt.encode(payload, signing_key, algorithm='RS256')

print(f"JWT: {encoded_jwt}")
