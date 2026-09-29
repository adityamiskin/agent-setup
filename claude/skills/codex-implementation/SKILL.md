---
name: codex-implementation
description: Delegate bulk implementation, clear-spec coding, data migrations, or mechanical tasks to Codex CLI (gpt-6.1-sol).
---

# Codex Implementation Guidelines

- Bulk/mechanical work (clear-spec implementation, data analysis, migrations): gpt-6.1-sol — it's effectively free on subscription limits.
- Mechanics: gpt-6.1-sol is only reachable through the Codex CLI — `codex exec` / `codex review` (configured in `~/.codex/config.toml`).
- Give it substantial, multi-step work when it is a good fit; do not artificially split a coherent task merely to make it shorter.
- The quality of the result depends on the quality of the prompt. Give it a detailed, self-contained brief:
  - The core objective.
  - Relevant context, invariants, and constraints.
  - Expected outputs and files or systems in scope.
  - Acceptance criteria and the verification required.
- For complex work, ask it to inspect the current state, implement the full solution, run proportionate verification, and report concrete results and remaining risks.
- Prefer one well-scoped, detailed prompt over a vague prompt followed by many corrective iterations.

## Claude Workflow & Subagent Integration

Claude Code's `model` parameter only accepts Claude models, so invoke Codex via a thin Claude wrapper:
- Wrapper agent setup: `model: 'sonnet', effort: 'low'`.
- Labeling: Always label with a `gpt-6.1-sol:` prefix, e.g. `{label: 'gpt-6.1-sol:task-name'}` so the UI indicates Codex is running.
- Timeout: Pass an explicit timeout on the Bash tool call because Codex runs can exceed Bash's default 10-minute timeout.
- Isolation: Parallel gpt-6.1-sol implementation agents must use `isolation: 'worktree'` so edits do not collide in the shared checkout.
- Accounting: Token budgets only track Claude tokens; Codex work is free and invisible to `budget.spent()`.
