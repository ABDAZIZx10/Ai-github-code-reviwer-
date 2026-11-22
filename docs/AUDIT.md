# Repository audit (salvage baseline)

Date of salvage documentation: 2026-11-22.

## What exists in the repository

| Asset | Role | Status |
|---|---|---|
| `.github/workflows/main.yml` | CI + failure webhook | **Implemented** (salvaged/improved) |
| `index.js` / `test.js` | Intentionally failing CI fixtures | **Implemented** (cleaned + labeled) |
| `package.json` | Node fixture deps (`express`) | **Implemented** |
| `scripts/generate_github_app_jwt.*` | GitHub App JWT helpers | **Implemented** (secrets removed) |
| `scripts/mint_installation_token.sh` | Installation token helper | **Implemented** |
| `n8n/workflow.reconstructed.json` | Importable reconstructed flow | **Reconstructed** (not original) |
| `docker-compose.yml` | Local n8n | **Added** |
| `experiments/gemini_unofficial.py` | Unofficial Gemini scrape | **Experimental only** |
| Original n8n workflow export | Orchestration + LLM prompt | **Missing** |
| Original LLM credentials / prompt | Model config | **Missing** |
| Verified end-to-end run after salvage | Full pipeline proof | **Not verified** |

## Confirmed execution flow (from source)

1. Push to `main` runs `build-and-test` (Node 20, `npm install`, `npm test`, `npm run build`).
2. On failure, `notify-n8n-on-failure` `POST`s JSON to `secrets.N8N_WEBHOOK_URL` with header `x-webhook-secret`.
3. Payload carries GitHub metadata only — **not** log text or file diffs.
4. n8n (lost) was responsible for GitHub API enrichment, LLM analysis, and posting feedback.

## Broken / risky items found during audit

- Hardcoded GitHub App Client ID in old token scripts → removed; now env-driven.
- `generate_token.sh` was Python with a `.sh` extension → replaced with wrapper + real Python script.
- `test.js` had accidental garbage (`react-icons` import, undefined `app`) mixed with intentional failures → cleaned.
- Secrets/notes/PEM present locally and gitignored — rotate any historically exposed tokens.
- Large unrelated images (`pfp.jpg`, `pfp.png`) remain tracked but are not part of the pipeline.
