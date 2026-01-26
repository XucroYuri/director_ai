# ADR 0003: Stop Logging API Keys (Even Prefixes)

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/services/api_config_service.dart`, `director_ai/lib/utils/app_logger.dart`

## Context

`ApiConfigService.set*ApiKey()` logs key prefixes via `substring(0, 8)`.

Even partial secrets can leak in:

- device logs
- crash reports
- shared screenshots
- exported log files (`AppLogger` persists logs)

We want a policy that is safe-by-default.

## Decision

Never log any part of an API key.

- Replace any logging that prints key content with a constant message, e.g.:
  - "updated ZHIPU key (configured: true)"

## Options Considered

### Option A: Do not log key at all (recommended)

Pros:
- Safe.
- No chance of accidental leak.

Cons:
- Less convenient for debugging misconfiguration.

### Option B: Log prefix only

Pros:
- Helps verify user entered something.

Cons:
- Still sensitive; can help attackers correlate keys.

## Consequences

- Debugging relies on explicit status checks (`isXxxConfigured`) rather than key text.
- Logs become safe to share.

## Acceptance Criteria

- Grep for `substring(0, 8)` and similar patterns yields none in key-setting code paths.
- Logs do not contain any user-provided secrets.
