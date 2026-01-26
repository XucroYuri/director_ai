# ADR 0203: History Migration Strategy

- Status: Proposed
- Date: 2026-01-26

## Context

When splitting code, we can:
- copy directories (fast, lose history)
- use `git filter-repo` (preserve history, more effort)

## Decision

Start with **copy-based split** unless you have strict requirements for:
- auditing/blame accuracy
- long-term archaeology

If history matters, do `git filter-repo` once structure is stable.

## Consequences

- Copy-based split reduces time-to-clarity.
- History-preserving split reduces future forensics cost.

## Acceptance Criteria

- New repo(s) build/run independently.
- Old repo archived or converted to umbrella docs.
