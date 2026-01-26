# ADR 0102: Use Domain Error Types Instead of String Exceptions

- Status: Proposed
- Date: 2026-01-26
- Scope: Flutter app (services/controllers/UI surfaces)

## Context

Current code often throws `Exception('...')` or bubbles `e.toString()`.

This makes it hard to:
- present consistent UX (retry vs user action vs config)
- instrument error categories
- avoid leaking internal details

## Decision

Define a small set of domain error types and use them across services/controllers.

Suggested taxonomy:
- `ConfigError` (missing API key / invalid settings)
- `NetworkError` (timeout, bad status, rate limit)
- `ParseError` (LLM JSON parse / screenplay parse)
- `UserCancelled`

UI maps error types to user-facing messages and actions.

## Options Considered

### Option A: Domain error classes (recommended)

Pros:
- Cleaner UX and easier debugging.
- Enables consistent retry/backoff.

Cons:
- Requires changes across call sites.

### Option B: Keep string exceptions

Pros:
- No refactor.

Cons:
- UX becomes increasingly inconsistent.

## Consequences

- Simplifies product decisions like “auto-retry only for rate limit/5xx”.
- Helps build analytics (error distribution).

## Acceptance Criteria

- Key flows (screenplay generation, image generation, video generation) throw typed errors.
- UI shows consistent messages and suggests correct actions.
