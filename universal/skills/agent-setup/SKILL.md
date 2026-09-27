---
name: agent-setup
description: Use when creating, importing, organizing, or updating personal agent skills, AGENTS.md instructions, or Pi extensions in the agent-setup repository. Helps choose the right scope and keep the repository as the source of truth.
---

# Agent Setup Repository

This repository is the source of truth for personal agent instructions, skills, and Pi extensions. Make changes here, not directly in the installed directories under the home folder.

## Choose a scope

- `universal/skills/<skill-name>/`: skills intended to be available across agents.
- `claude/skills/<skill-name>/`: Claude-specific skills. OpenCode also discovers skills from this location in this setup; Pi does not.
- `pi/skills/<skill-name>/`: Pi-only instruction skills.
- `pi/extensions/<extension-name>/`: executable Pi extension code. Keep this separate from instruction skills.
- `AGENTS.md`: the single shared instruction source. Do not create a separate set of Claude instructions.

If the user asks for a skill without specifying a scope, put it in `universal/skills/` when its instructions apply across agents. Ask or choose a narrower scope only when the skill depends on one agent's runtime or the user limits its audience.

The directory determines scope. Do not add a custom `scope` field to skill frontmatter.

## Create a skill

1. Create `SKILL.md` inside a descriptive, lowercase, hyphenated skill directory in the chosen scope.
2. Include frontmatter with `name` and a concise `description` that clearly states when the skill should activate.
3. Write direct, actionable instructions. Add supporting files only when they materially help, and reference them with paths relative to the skill directory.
4. Keep credentials, machine-specific state, and unrelated tool configuration out of the repository.
5. Check that the skill name is unique, links resolve, and the files contain no secrets or machine-specific absolute paths.

## Import a skill with the Skills CLI

The Skills CLI installs into its own agent-specific paths and does not accept an arbitrary destination directory. Do not run it globally or install straight into a live home-directory skill path.

Instead, use a temporary directory, select one skill and one staging agent, and pass `--copy --yes`. For a universal skill, stage with `--agent opencode`; for a Claude skill, stage with `--agent claude-code`. Then copy the complete skill directory into the matching directory in this repository. Remove only the temporary staging directory after verifying the imported files. Preserve upstream license and attribution files; do not bring temporary lockfiles or installer metadata into this repository.

If the user supplies the skill contents directly, create it in the repository without using the CLI.

## Pi extensions

Use `pi/extensions/<extension-name>/` for executable extensions, including their source, tests, documentation, `package.json`, and lockfile. Do not commit `node_modules`. Pi discovers user extensions under `~/.pi/agent/extensions/`.

## Verify and install

- Review the diff and confirm only the intended scope changed.
- For a newly added skill, run `./setup.sh --skip-deps` only after this repository has already been installed on the machine. The script links resources and refuses to overwrite existing paths.
- For extension dependency changes, use the extension's lockfile and run its focused checks.
- Ensure new files are included in Git. Do not commit or publish publicly without the user's approval; review licensing and attribution before publishing.
