# ADR 0101: Introduce Dio Factory + Shared Interceptors

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/services/` (`api_service.dart` and new factory file)

## Context

`ApiService` currently builds multiple `Dio` instances with duplicated BaseOptions, interceptors, timeouts, and logging.

Problems:
- drift risk: per-client headers/timeouts/logging diverge over time
- harder to add cross-cutting behavior (retry/backoff, consistent error mapping)

## Decision

Introduce a single Dio factory module to create service clients:

- `DioFactory.create(baseUrl, tokenProvider, options...)`
- Attach shared interceptors:
  - auth injection
  - optional request/response logging (tied to log level)
  - consistent error mapping

`ApiService` becomes responsible only for endpoint calls and payload shaping.

## Options Considered

### Option A: DioFactory + interceptors (recommended)

Pros:
- Central control of auth/logging/timeouts.
- Easier to add retry/backoff and metrics.
- Reduces code size and duplication.

Cons:
- Requires careful migration to avoid behavior change.

### Option B: Keep current approach, just refactor locally

Pros:
- Minimal structural change.

Cons:
- Still leaves duplication; hard to enforce consistency.

## Consequences

- Enables future improvements (rate limit handling, tracing) without touching every client.
- Requires a migration plan (one client at a time) to minimize risk.

## Acceptance Criteria

- `ApiService` no longer manually configures interceptors per-service.
- Behavior parity: same headers/timeouts as before.
- A single place to change logging/retry.
