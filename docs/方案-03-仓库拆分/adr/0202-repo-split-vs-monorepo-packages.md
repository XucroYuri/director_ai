# ADR 0202: Repo Split vs Monorepo Packages

- Status: Proposed
- Date: 2026-01-26

## Context

We need to reduce confusion and isolate runtimes.

Two viable shapes:

- Two repos: `director-ai-mobile` and `ai-storyboard-pro-web`
- One monorepo with `/packages/mobile` and `/packages/web`

## Decision

Prefer **two repos** if:
- different release cadences
- different owners
- different CI stacks

Prefer **monorepo** if:
- shared contracts and frequent cross-changes
- single owner team
- desire for atomic changes

## Trade-offs

Two repos:
- Pros: clean isolation, simpler per-repo tooling.
- Cons: cross-repo coordination, versioning of shared contracts.

Monorepo:
- Pros: atomic changes, shared tooling.
- Cons: heavier CI, more rules needed to avoid cross-contamination.

## Acceptance Criteria

- A chosen structure and a minimal contributor guide.
