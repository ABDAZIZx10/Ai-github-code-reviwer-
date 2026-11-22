# Manual n8n reconstruction guide

Use this when `n8n/workflow.reconstructed.json` cannot be imported as-is (version skew) or when you prefer to rebuild by hand.

## Confirmed vs assumed

| Item | Status |
|---|---|
| Failure-triggered GitHub Actions job | **Confirmed** (`.github/workflows/main.yml`) |
| `POST` JSON webhook with `x-webhook-secret` | **Confirmed** |
| Payload fields `run_id`, `repo`, `branch`, `commit`, `actor`, `owner` | **Confirmed** |
| n8n fetched changed files from GitHub | **Strongly evidenced** (commit messages) |
| GitHub App auth (JWT → installation token) | **Confirmed** (scripts + prior App install) |
| App permissions include PR/issue write + contents read | **Confirmed** (prior install token response) |
| Exact LLM provider | **Missing / unverified** |
| Exact system prompt | **Missing** |
| Exact feedback channel (commit comment vs PR review vs issue) | **Unverified** (permissions allow several) |
| Original webhook path string | **Missing** (example uses `ci-failure-review`) |

## Suggested node sequence

1. **Webhook** — Method `POST`, path of your choice, response mode “using Respond to Webhook node”.
2. **IF / Code** — Compare `headers['x-webhook-secret']` to your shared secret; reject on mismatch.
3. **GitHub auth**
   - Generate App JWT (`iss` = Client ID, RS256, ≤10 min), then  
   - `POST /app/installations/{installation_id}/access_tokens`  
   - Helper scripts: `scripts/generate_github_app_jwt.py`, `scripts/mint_installation_token.sh`
4. **HTTP Request** — `GET /repos/{owner}/{repo}/commits/{sha}` (file list + patches).
5. **HTTP Request** — `GET /repos/{owner}/{repo}/actions/runs/{run_id}/jobs` (and optionally job logs).
6. **Code** — Build a review prompt from commit files + job outcomes.
7. **LLM node** — Official provider credential (do **not** use `experiments/gemini_unofficial.py` in production).
8. **HTTP Request** — Post markdown feedback (`POST .../commits/{sha}/comments` or PR review/issue comment).
9. **Respond to Webhook** — Return `{ ok: true }`.

## GitHub Actions secrets

| Secret | Purpose |
|---|---|
| `N8N_WEBHOOK_URL` | Full production webhook URL from n8n |
| `N8N_WEBHOOK_SECRET` | Value sent as `x-webhook-secret` |

## Local smoke test (without waiting for CI)

```bash
curl -X POST "http://localhost:5678/webhook/ci-failure-review" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $N8N_WEBHOOK_SECRET" \
  -d @docs/payloads/webhook-request.example.json
```

Replace host/path with your n8n instance. For n8n Cloud test URLs, use the Test webhook while the editor is open listening, then switch to Production after activation.
