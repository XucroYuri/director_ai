# ADR 0105: Formalize Conversation Metadata Schema + Compatibility

- Status: Proposed
- Date: 2026-01-26
- Scope: conversation persistence/caching

## Context

Media URLs and task context are stored in a flexible `metadata` map.
Without schema, it is easy to introduce mismatches (already occurred).

## Decision

Define and document a schema:

- `imageUrl` (string)
- `videoUrl` (string)
- `taskId` (string)
- `sceneId` (int)
- `provider` (string: zhipu/canghe/doubao)

Implement read-compat for legacy keys for at least one major version.

## Options Considered

### Option A: Minimal schema + compat window (recommended)

Pros:
- Pragmatic.
- Prevents immediate breakage.

Cons:
- Requires discipline to enforce.

### Option B: Migrate Hive data with explicit versioning

Pros:
- Clean data.

Cons:
- Risky and can brick user data if migration fails.

## Consequences

- Clear contract for future features (resume jobs, export).

## Acceptance Criteria

- Schema is referenced in docs.
- New writes follow schema.
- Reads handle legacy keys.
