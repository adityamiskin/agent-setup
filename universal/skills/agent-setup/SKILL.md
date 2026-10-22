---
name: agent-setup
description: Use when creating, importing, organizing, or updating personal agent skills, AGENTS.md instructions, or Pi extensions in the agent-setup repository. Also use after any change to this machine's setup (Omarchy shell/bar config, shell plugins, Hyprland, terminal or app configs, installed packages) so the change is synced and pushed to agent-setup. Helps choose the right scope and keep the repository as the source of truth.
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

## Sync system changes

`omarchy/` captures this machine's desktop setup: `omarchy/home/` mirrors files under `~`, and `omarchy/apply.sh` layers everything onto a stock Omarchy install. Whenever you change the system, mirror the change here in the same task, then commit and push to `main`. The user has approved pushing these syncs.

- Config edits (`~/.config/omarchy/shell.json`, `~/.config/hypr/`, terminals, app configs): copy the changed file to the same relative path under `omarchy/home/`. Run `diff` first and confirm only your change differs; if the repo copy has drifted otherwise, report it instead of overwriting.
- New config files: add them under `omarchy/home/`. Never add secrets, tokens, or machine-generated state such as caches or `*.bak.*` backups.
- Plugins installed from a repo (`omarchy plugin add <url>`): add the id and URL to `PLUGINS` in `omarchy/apply.sh`, and copy the updated `shell.json`.
- Local or cloned plugins under `~/.config/omarchy/plugins/<id>/`: copy the whole plugin directory under `omarchy/home/`.
- Packages: add to `PKG_ADD`, `AUR_ADD`, or `PKG_DROP` in `omarchy/apply.sh`. Commands that change state outside `~` belong in the matching `apply.sh` step and must stay safe to re-run.
- Commit with a conventional message such as `feat(omarchy): show battery percentage in bar`, push, and report the commit hash.

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
