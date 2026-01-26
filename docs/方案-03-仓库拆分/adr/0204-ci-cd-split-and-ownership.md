# ADR 0204: CI/CD Split and Ownership

- Status: Proposed
- Date: 2026-01-26

## Context

Current mixed repo makes CI unclear.

We want:
- mobile CI: analyze/test/build
- web CI: lint/typecheck/test/docker build (optional)

## Decision

Split CI pipelines by product boundary:
- Mobile: Flutter pipeline
- Web: Python pipeline

Define ownership:
- who reviews mobile changes
- who reviews web changes

## Acceptance Criteria

- CI runs only relevant checks per product.
- Contributors know who approves what.
