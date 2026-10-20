---
name: codex-use
description: Hand implementation or Chrome browser checks to Codex. Triggers: "use codex", "implement this", "test it", "check it in the browser", "verify the UI", "screenshot it".
---

# Codex

Codex (`codex`, `~/.codex/config.toml`) does two jobs: implementing from a spec and driving Chrome to verify. Claude does the thinking; Codex does the typing and the clicking.

## Requires and budget

- Codex is on a $20 Plus plan, so every run costs scarce budget. Browser runs cost the most (screenshots).
- `codex` on PATH and logged in. If it is missing or rate-limited, implement the task yourself, say Codex was unavailable, and list the browser checks still owed. Don't run the browser checks yourself, and don't retry in a loop.
- One-shot `codex exec` with medium effort (the config default). Interactive sessions accumulate context and cost more.
- Put everything in one prompt. Don't resend the same instruction; if a run went wrong, fix the prompt and run once more.
- Pass an explicit Bash timeout; runs can exceed the 10-minute default.

## Implement

Write the spec before calling Codex. A vague prompt costs exploration tokens plus correction runs.

- Objective in one or two sentences.
- Files to edit and files to read, by path. Codex should not have to search for them.
- Invariants and constraints, including the relevant AGENTS.md rules (no `any`, delete old paths, no new tests unless asked).
- For UI: the exact design (picked mock, classes, spacing). gpt-6.1-sol is weak at UI and should not invent it.
- One acceptance command that proves it works (typecheck, a targeted test, a query).
- Stop point: "Run the acceptance command, report the diff summary and its output, and stop. Do not start dev servers or the E2E suite."

Bad: `codex exec 'add pagination to the threads list'`
Good: `codex exec 'In apps/web/src/threads/List.tsx, page the threads query with usePaginatedQuery (convex/threads.ts:listPage already exists). 50 per page, load more on scroll end. Delete the old useQuery call. Run bun run typecheck, report output, stop.'`

- Reviewing a diff is cheap compared to implementing. If budget is low, implement it yourself and have Codex review: `codex review --base main` (or `--uncommitted`) for a plain review. It rejects a custom prompt alongside `--base`/`--uncommitted`, so for a focused review use `codex exec -s read-only 'Review git diff main...HEAD for <focus>. Report findings only, edit nothing.'`
- Parallel Codex runs need separate worktrees and stated file ownership.
- Read the diff yourself before reporting. Deslop it (comments, leftovers, Python-flavored TS) in Claude, not with another Codex run.
- When the feature is done and has UI, verify it once using the section below.

## Verify in Chrome

Chrome control is the only way Codex drives the machine here. It works through the `control-chrome` skill (the bundled `chrome@openai-bundled` plugin); there is no native-app computer use or simulator. gpt-6.1-sol is better at this than Claude.

- Use it by default when UI needs verifying; no need to ask permission.
- Verify once per feature, after implementation is finished. Batch checks into one run instead of one run per change.
- If Codex reports Chrome control or `node_repl` is unavailable, or times out connecting, stop and report that. Do not fall back to T3 preview, Playwright, or another browser, and do not retry.

```sh
codex exec 'Use Chrome control (control-chrome skill). Open http://localhost:5173/threads.
1. The list shows 50 rows.
2. Scroll to the bottom; more rows load.
3. Toggle dark mode; background is #000.
Prefer reading page text and DOM for each check. Take one screenshot at the end to /tmp/verify-threads.png.
Report pass/fail per numbered check and stop. Do not submit forms, send messages, log in, or change settings.'
```

- Give the URL, numbered checks with expected results, and the stop point. "Test the flow" lets it wander.
- Read page text and DOM for checks; screenshot only for the final proof.
- Never let it submit, send, buy, delete, log in, or upload unless the user explicitly asked for that step.

## Reporting

- Implementation: the acceptance command output.
- Verification: pass/fail per check with the screenshot path.
- If Codex couldn't reach something, say what it was looking at. Don't blind-retry.
