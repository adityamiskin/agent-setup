---
name: codex-computer-use
description: Ask the Codex CLI (gpt-6-sol) to run local app verification that needs computer use — browser automation, simulators, screenshots, app launching, or independent runtime inspection. Use when the user asks Claude to test a flow, verify UI behavior, inspect a running app, capture screenshots, or report confirmation/feedback about implemented behavior that benefits from driving the actual machine.
---

# CLI Computer Use (gpt-6-sol drives the Mac)

Codex Computer Use lets gpt-6-sol operate the Mac in full — launch and navigate native apps, drive simulators/Xcode, click through real UI, take screenshots, and report back. It's stronger than Claude's computer use today and effectively free on OpenAI subscription limits, so it's the default for anything that means actually driving the machine.

## Invoking it

Codex Computer Use uses the bundled skill name `$computer-use`. Use single quotes so the shell doesn't expand `$computer-use`:

Interactive / Verification pass:
```sh
codex -m gpt-6-sol 'use $computer-use to open the iOS simulator, launch the app, and screenshot the login screen. do not tap anything else.'
```

Non-interactive check:
```sh
codex exec -m gpt-6-sol 'use $computer-use to look at the frontmost app and report what is visible. do not click anything.'
```

Codex does exactly what you ask, so scope the task and state where to stop ("screenshot the result, don't submit"). No Claude-style framing.

## Safety

- Prefer interactive `codex ...` over `codex exec ...` for anything that may submit, delete, buy, send messages, change settings, log in, upload files, or transmit sensitive data — interactive lets codex stop and ask before the risky step.
- Use `codex exec` only for read/observe/screenshot flows that can't do damage.
- Ask permission before doing computer use or spinning up browsers if not explicitly requested by the user.

## Result handling

- If codex reports it couldn't find or reach something, relay that clearly with what it was looking at — don't blind-retry.
- Verify any claim that gates a merge against the actual app.
