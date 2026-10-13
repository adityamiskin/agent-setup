---
name: html-communication
description: Use only when the user requests an HTML plan, report, summary, comparison, or visual UI mock. Never use it to implement, modify, or deliver product work.
---

# HTML Communication

## Scope and Boundary

Use this skill only when the requested deliverable is an HTML plan, spec, write-up, findings, summary, report, comparison, or visual UI mock. HTML created under this skill is for communication and review, not implementation.

Do not activate this skill just because a request mentions HTML. In particular, do not use it to fulfill coding, implementation, integration, or other product-work requests. For those requests, work in the relevant project files using the normal development workflow. Do not substitute a demo or mock HTML file for requested product changes, and do not treat a mock as completed implementation. If a request explicitly asks for both a plan/mock and implementation, keep those as distinct deliverables and follow the project's normal implementation process for the latter.

Do not use this skill for HTML that ships as part of a product.

## Document

- Create one self-contained HTML file, capped at 512 KB.
- Write it like a spec, not a landing page: dense, scannable, no hero, decorative chrome, marketing voice, or em dashes.
- Default to true black (`#000`), white primary text, and dark gray only for secondary surfaces or accents.
- Make it mobile-readable with a responsive viewport and no fixed-width layout.
- Use semantic HTML, inline CSS, inline SVG, and HTTPS or data-URL images.
- Use an inline classic script only when interactivity materially helps. Keep scripted pages useful without JavaScript; the sandbox blocks storage, fetch, workers, frames, forms, and popups.
- In script-free files, give external links `target="_blank"` and `rel="noopener noreferrer"`. If any script exists, omit `target="_blank"`.
- Never include external or module scripts, inline event handlers, `javascript:` URLs, forms, frames, embeds, objects, applets, meta refresh, linked stylesheets, secrets, private URLs, or local filesystem paths.

## UI Mocks

Mocks are visual proposals for review only. Do not connect them to product code or present them as implemented work. When the user asks for variants:

- Render real styled variants, not descriptions.
- Label them 'A', 'B', 'C'... for easy selection.
- Lay them out for direct comparison.
- Keep one file across iterations so its local path stays stable.
