# ADR 0001: Fix Duplicate ApiConfig.createDio

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/services/api_service.dart`

## Context

`ApiConfig` currently contains two `static Dio createDio()` methods (same signature). This is either:

- a merge artifact that should not exist, or
- a real build blocker (Dart does not allow duplicate methods), or
- a sign the file has drifted and is not compiled as-is.

`ApiService` depends on `ApiConfig.createDio()` for Zhipu requests.

## Decision

Keep a single `ApiConfig.createDio()` implementation that:

- sets `baseUrl` to `ApiConfig.zhipuBaseUrl`
- injects `Authorization: Bearer <token>` dynamically via interceptor on every request (so token updates take effect without recreating the client)
- keeps timeouts and `LogInterceptor` behavior consistent with other clients

Rename or remove the other implementation.

## Options Considered

### Option A: Keep interceptor-based token injection (recommended)

Pros:
- Always uses latest token from `ApiConfigService`.
- Avoids stale headers if keys are updated at runtime.
- Consistent with how `_tuziDio/_imageDio/_doubaoDio` inject auth.

Cons:
- Slightly more indirection when debugging headers.

### Option B: Set Authorization in BaseOptions.headers

Pros:
- Simpler mental model.

Cons:
- Requires recreating Dio when token changes.
- Easy to end up with stale auth if code forgets refresh.

## Consequences

- Removes ambiguity and prevents compile-time failure.
- Makes token handling consistent across all services.
- Future refactor (方案 02) can move this into a factory without changing semantics.

## Acceptance Criteria

- `grep -n "static Dio createDio"` returns exactly one occurrence in `director_ai/lib/services/api_service.dart`.
- `flutter analyze` passes.
- A manual Zhipu request succeeds after updating token in Settings (no restart required).

## Notes

Related code review item: `docs/code-review.md`.
