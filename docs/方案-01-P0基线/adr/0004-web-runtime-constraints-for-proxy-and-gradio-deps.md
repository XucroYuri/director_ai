# ADR 0004: Web Runtime Constraints For Proxy + Gradio Dependency Fragility

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/web/`

## Context

The `web/` tool is a Python/Gradio application.

Observed on this machine:

- Environment proxies are set (`all_proxy`, `http_proxy`, `https_proxy`).
- Importing Gradio initially failed due to missing socks support.
- Gradio import also failed due to `huggingface_hub` API mismatch (`HfFolder` expected).

This is a reproducibility issue: contributors will get different failures depending on environment.

## Decision

Define a minimal, explicit runtime constraint set for `web/`:

- require `httpx[socks]` when running under SOCKS proxy
- pin `huggingface_hub` to a compatible range (e.g. `<1.0`) until the codebase upgrades Gradio/Hub usage

Document proxy behavior clearly:

- either unset proxy vars when running
- or ensure socks support is installed

## Options Considered

### Option A: Pin deps + document proxy behavior (recommended for P0)

Pros:
- Fast and low-risk.
- Makes local dev work reliably.

Cons:
- Still not fully reproducible without lockfile.

### Option B: Add lockfile / Dockerfile immediately

Pros:
- Fully reproducible.

Cons:
- More work; touches build/distribution strategy.
- Better suited for 方案 02/03.

## Consequences

- Contributors can run `web/` without chasing transient dependency breaks.
- Establishes groundwork for a later lockfile/Docker hardening.

## Acceptance Criteria

- `python -c "import app"` succeeds in a typical proxy environment.
- `./start.sh` can reach a running server on configured port.

## Notes

This ADR does not decide whether `web/` is a backend for Flutter. That decision belongs in 方案 03.
