# ADR 0002: Normalize ConversationMessage.metadata For Media Cache

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/providers/conversation_provider.dart`

## Context

`ConversationProvider.saveMessage()` writes `metadata` with `mediaUrl`, while `_cacheMessageMedia()` only checks `imageUrl` and `videoUrl`.

Result: caching/prefetch likely never triggers, and cache stats may be misleading.

We need a stable metadata schema that:

- supports image and video URLs
- supports future expansion (taskId/sceneId)
- is backward compatible with existing stored messages

## Decision

Adopt a canonical schema:

- `imageUrl`: string (if message is an image result)
- `videoUrl`: string (if message is a video result)
- optional `mediaUrl` can be kept only for backward compatibility

Update write-path to emit canonical keys based on message type, and update read-path to also accept legacy keys.

## Options Considered

### Option A: Canonical `imageUrl`/`videoUrl` + legacy fallback (recommended)

Pros:
- Clear typing and intent.
- Works with existing cache logic.
- Backward compatible when reading old messages.

Cons:
- Requires a small migration in code paths.

### Option B: Only use `mediaUrl` everywhere

Pros:
- Minimal fields.

Cons:
- Loses type information unless inferred.
- Future extensions (multi-media) get harder.

## Consequences

- Cache prefetch becomes functional.
- Enables later observability (cache hit ratio) and richer conversation export.

## Acceptance Criteria

- New persisted messages contain the correct key for their media type.
- `_cacheMessageMedia()` caches both new and historical messages (via fallback).
- No crash when reading existing Hive data.

## Notes

This ADR is intentionally P0-sized. A fuller schema doc can be part of 方案 02.
