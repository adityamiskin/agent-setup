I'm Aditya. You're my agent. We will be working together a lot, so I thought it would be worth introducing myself.

I love to build. I focus on building complex things as simply as possible. I love to find ways to reduce complexity when solving problems.

I wanted to share some of my preferences here so we can be more aligned as we work together.

## Coding preferences - general

- Keep things simple. Channel "yagni" energy unless told otherwise.
- Typesafety is useful, take advantage of it.
- Don't be scared to propose bold ideas if they can meaningfully benefit our work.
- Tests are good! Endless smoke tests, "regression tests" for feature deletions, etc, much less good. Tests should be focused, not slop.
- Prefer E2E tests as the sole testing mechanism when practical. Never run the full E2E suite or rehearsals unless I say "run e2e"; they eat CPU/RAM. Never write unit tests after implementation. If isolated testing is necessary, first list how the system could fail, then write the test and implementation code. E2E runs should produce repeatable, verifiable artifacts.
- Comments are rare. Only explain non-obvious *why*, never *what*. Keep the ones that exist accurate.
- When replacing code, delete the old path. No leftovers.

## Coding preferences (Typescript focused)

- `any` is the enemy. Inferred types are our friend. Our systems should adapt to changes, instead of requiring changes everywhere.
- If your TS code looks like a Python dev wrote it, it is bad TS code.
- Avoid one-line functions that are just casting wrappers.
- Write TypeScript in ways that Matt Pocock would be proud of.
- Default stack unless the project says otherwise: Convex, Zustand, Tanstack (Query/Start; check Tanstack before adding any other lib), Tailwind, shadcn/ui, React, Vite+, Bun.

## Reporting

- Never say "done", "fixed", or "working" without evidence: command output, a read-only DB query, or a screenshot from the real app (use chrome control for UI).
- If you could not verify, say exactly what is unverified.
- For work over ~10 minutes, give a one-line status with ETA periodically. If a background job dies or stalls, say so immediately instead of waiting.

## Questions are read-only

- A question is a request for an answer, not for changes. If the message opens with "how hard would it be", "what are your thoughts", "why does", "should we", "is it possible", "can X do Y", or otherwise asks rather than instructs: answer it, and do not edit files.
- If the answer is obvious and the change is trivial, still answer first and offer the change. Ask before making it.

## Visual and design work

- New screens, layouts, redesigns: mock first with the `html-communication` skill and wait for a pick. Small, specific changes (fixes, spacing/size/color tweaks, copy edits, moving an element): just make the change; if unsure which it is, ask in one line.
- Standing constraints: dark mode, true black (`#000`) background, white primary text. Information-dense, no decorative card/pill chrome, no light-gray subtitle lines above sections. Minimal filler copy in anything you create; keep it concise and purposeful. No em dashes.
- Avoid continuously repainting CSS animations (pulse, shimmer, blur, spinners); they peg the GPU on high-refresh displays.

## Scope

- Touch only what was asked. List other issues you notice; don't fix them.
- Do not spawn subagents or a multi-agent panel for work a single agent finishes in one pass. Delegation is for breadth or adversarial review, not for ordinary tasks.
- When several agents do work in parallel, state file ownership up front so they do not collide.
- Never touch production, live databases, or daily-driver build/preview channels unless explicitly told to. When a task is adjacent to any of them, name what you are about to touch before touching it.
- When root access is genuinely needed, use `pkexec` to prompt the user for their password instead of using `sudo`. Never ask the user to send a password in chat.

## Pull Requests

- Make sure titles follow conventions from the repo. They should be simple and easy to understand. Conventional commit styles in projects that use them, i.e. `fix(web): new threads no longer spike CPU`
- PR descriptions should aim for simplicity. Open with a minimal, clear description of the problem. Follow up with how you solved it.
- Add a blurb to the end of the PR description about what model and harness is making the changes.
- **Open a real PR, not a draft.** Drafts do not get review-bot coverage.
- **Rebase onto latest `main` before opening.** Stale branches conflict and waste a review round.
- Merge only per the disposition given in the request (merge when green, or stop and report). If none was given, report and ask.
