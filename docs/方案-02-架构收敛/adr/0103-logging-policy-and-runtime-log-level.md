# ADR 0103: Logging Policy + Runtime Log Level

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/utils/app_logger.dart` + call sites

## Context

Logging is currently mixed: `print/debugPrint` and `AppLogger`.
Also logs may include sensitive user inputs and partial keys.

We need logging that is:
- safe to share
- adjustable at runtime
- consistent across layers

## Decision

- Enforce `AppLogger` usage for non-UI logging.
- Add runtime log level setting (e.g. error/warn/info/debug) controllable from Settings.
- Add a rule: never log secrets; treat prompts/media URLs as sensitive in production.

## Options Considered

### Option A: Runtime log level + unified logger (recommended)

Pros:
- Supports debugging without rebuilding.
- Consistent formatting and file persistence.

Cons:
- Requires touching many call sites.

### Option B: Compile-time only

Pros:
- Less complexity.

Cons:
- Harder to debug user devices.

## Consequences

- Logs become an intentional product surface (and safer).

## Acceptance Criteria

- No `print/debugPrint` in services/controllers (except truly local debug guarded by log level).
- Setting changes effective immediately.
