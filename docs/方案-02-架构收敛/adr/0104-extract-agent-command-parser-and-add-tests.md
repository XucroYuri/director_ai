# ADR 0104: Extract AgentCommand Parser + Add Tests

- Status: Proposed
- Date: 2026-01-26
- Scope: `director_ai/lib/controllers/agent_controller.dart`

## Context

`AgentController` currently mixes:
- streaming
- UI message management
- JSON extraction heuristics

The JSON extraction is critical and brittle (LLM output variability).

## Decision

Extract parsing logic into a dedicated service:

- `lib/services/agent_command_parser.dart`
- include a test suite with representative model outputs:
  - thinking + final JSON
  - markdown code fences
  - multiple JSON objects (choose last valid)
  - invalid JSON (error)

`AgentController` remains responsible for orchestration and state.

## Options Considered

### Option A: Dedicated parser service with tests (recommended)

Pros:
- Testable, faster iteration.
- Reduced controller complexity.

Cons:
- Requires setting up test harness.

### Option B: Keep inline heuristics

Pros:
- No new files.

Cons:
- Hard to reason about and regressions will slip.

## Consequences

- Improves reliability of tool-calling loop.

## Acceptance Criteria

- Parser test suite covers known tricky outputs.
- AgentController becomes simpler and delegates parse.
