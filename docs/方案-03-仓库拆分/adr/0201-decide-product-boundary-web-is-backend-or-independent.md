# ADR 0201: Decide Product Boundary — Is `web/` a Backend or an Independent Tool?

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/web` and Flutter integration strategy

## Context

This codebase currently contains two largely independent runtimes:

- Flutter mobile app (directly calls third-party AI APIs; stores API keys locally via `SharedPreferences`).
- `web/` Python/Gradio app (separate UI + its own runtime dependencies; appears to have a REST API story but is not currently used by the Flutter app).

Because these two live in the same repo, contributors assume there is a single “system”. In practice, we must decide the product boundary explicitly.

## Decision Drivers (Why this matters)

- Security posture: where do API keys/secrets live (device vs server).
- Reliability: handling long-running generation jobs (queueing, retries, resume).
- Cost control: centralized rate limiting/budgeting vs per-device uncontrolled usage.
- Collaboration: shared projects/history, multi-user access.
- Operational burden: do we want to own deployment, uptime, observability.
- Developer experience: “clone → run” clarity; CI isolation.

## Options Considered

### Option A: `web/` is an independent tool (baseline)

Definition:
- Flutter app continues calling third-party APIs directly.
- `web/` is a separate, standalone product/tool.

Pros:
- Lowest coupling; easier to ship the mobile app.
- No backend ops required.
- Each product can evolve independently.

Cons / risks:
- Secrets remain on-device (even with secure storage, they exist client-side).
- Harder to enforce global rate limiting and cost controls.
- Harder to build collaboration / shared state across devices.

### Option B: `web/` becomes the backend for the Flutter app

Definition:
- Flutter calls our API (hosted), and the backend calls third-party providers.
- Backend owns auth, policies, persistence, and job orchestration.

Pros:
- Secrets stay server-side.
- Can implement job queues, caching, retries, resume, and policy enforcement.
- Centralized observability and analytics.

Cons / risks:
- Significant engineering and ops: auth, deployment, uptime, storage, incident response.
- Introduces server costs and on-call burden.
- Requires a stable API contract and versioning strategy.

### Option C: Hybrid (thin backend gateway)

Definition:
- Backend only provides a minimal gateway for the most sensitive/expensive calls.
- Some low-risk features may remain client-direct.

Pros:
- Incremental path; reduces secrets exposure for the riskiest calls.
- Lower ops burden than full backend.

Cons / risks:
- Two network paths increase complexity.
- Easy to end up with inconsistent behavior unless boundaries are crisp.

## Decision

Default to **Option A (Independent tool)** unless there is an explicit product requirement for at least one of:

- server-side secret management (compliance / partner requirements)
- global rate limiting / cost budgets
- long-running job orchestration with resume (queue + persistence)
- collaboration / shared project storage

If any of those requirements are real in the next 1–2 iterations, choose **Option B** (or Option C as an incremental stepping stone).

## Consequences

If Option A:
- Repo split (方案 03) is straightforward.
- Flutter remains “client-first”; invest in secure storage + telemetry.

If Option B:
- Must define API contract (OpenAPI) + auth (token/session) + storage.
- Web runtime becomes a deployable service; CI/CD and ops become first-class.

If Option C:
- Must document boundaries precisely (which calls go through backend, why).

## Decision Checklist (Quick evaluation)

Answer these to pick A/B/C:

- Do we need to revoke/rotate keys without updating clients? (Yes → B/C)
- Do we need cost control across all users/devices? (Yes → B/C)
- Do we need multi-device shared projects? (Yes → B)
- Are long-running jobs failing due to mobile backgrounding? (Yes → B)
- Do we have an ops owner/team for deployment? (No → A)

## Follow-ups

- Update docs to state the truth explicitly: “Flutter calls X; `web/` is/ isn’t used by Flutter”.
- If choosing B/C: create ADRs for auth, storage, job model, and API versioning.

## Acceptance Criteria

- A top-level statement of truth exists (README or docs) describing how components interact.
- If B/C: an API contract exists (OpenAPI) and a basic deployment path is defined.
