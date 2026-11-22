# n8n workflow (reconstructed)

The **original** n8n workflow was lost when the container / cloud instance was not persisted. What lives here is a **reconstruction** derived from surviving evidence in this repository and prior development notes — **not** an export of the original workflow.

## Evidence used

| Evidence | Source | Implication |
|---|---|---|
| `POST` + JSON body + `x-webhook-secret` | `.github/workflows/main.yml` | Webhook trigger + shared-secret header check |
| Payload: `run_id`, `repo`, `branch`, `commit`, `actor`, `owner` | Same workflow (confirmed) | GitHub context only — **no logs/files in the POST** |
| Commit messages about “multiple file changes detection in n8n” | Git history | n8n fetched changed files via GitHub API |
| GitHub App JWT scripts + App permissions | `scripts/`, prior App install | n8n authenticated as a GitHub App (`contents:read`, `pull_requests:write`, `issues:write`, …) |
| LLM report with scores / issues / fixes | Project intent (user description) | An LLM step existed; **provider + prompt are unverified** |
| `experiments/gemini_unofficial.py` | Repo | Experimental unofficial Gemini scrape — **not** confirmed as the production LLM path |

## What you must configure manually

1. Webhook path / production URL (cloud or self-hosted).
2. Shared secret matching GitHub Actions `N8N_WEBHOOK_SECRET`.
3. GitHub App credentials (Client ID, Installation ID, private key) **or** a PAT with equivalent scopes.
4. LLM provider credential + system prompt (original prompt is **missing**).
5. Whether feedback is posted as a commit comment, PR review, or issue comment (permissions support PR/issue write; exact node is unverified).

## Import

1. Start n8n (`docker compose up -d` from repo root, or use [n8n Cloud](https://n8n.io)).
2. Open the editor → **Workflows** → **Import from File**.
3. Select `workflow.reconstructed.json`.
4. Open each node marked **CONFIGURE** and fill credentials.
5. Activate the workflow and copy the **Production** webhook URL into GitHub secret `N8N_WEBHOOK_URL`.

## Webhook contract

- **Method:** `POST`
- **Header:** `x-webhook-secret: <shared secret>`
- **Content-Type:** `application/json`
- **Body:** see `docs/payloads/webhook-request.example.json`

See also `docs/reconstruction-guide.md` for a manual rebuild if import fails on your n8n version.
