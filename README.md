# Agent setup

Personal agent instructions, skills, and Pi extensions, organized by scope.

- `AGENTS.md`: shared agent instructions
- `universal/skills/`: shared skills
- `claude/skills/`: Claude skills (also discoverable by OpenCode in this setup)
- `pi/skills/`: Pi-only skills
- `pi/extensions/`: personal Pi extension source

Run `./setup.sh` to link these resources into user-level agent directories and install Pi extension dependencies. It refuses to replace existing files or skill/extension directories. Use `./setup.sh --skip-deps` to create links without running `npm ci`.
