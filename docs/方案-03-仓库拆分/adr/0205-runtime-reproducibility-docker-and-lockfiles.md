# ADR 0205: Runtime Reproducibility — Docker and Lockfiles

- Status: Proposed
- Date: 2026-01-26

## Context

`web/` runtime is sensitive to:
- proxy settings
- Python SSL build
- rapidly changing Gradio dependencies

## Decision

Adopt reproducibility layers:

- Short-term: lock constraints (`requirements.lock` or constraints file)
- Medium-term: Dockerfile for deterministic builds

## Options

- Only lockfile: easier, but still depends on system libs.
- Docker + lockfile: best reproducibility, extra maintenance.

## Acceptance Criteria

- A new developer can run `web/` without manual dependency archaeology.
