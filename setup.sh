#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
skip_deps=false

if [[ "${1:-}" == "--skip-deps" ]]; then
  skip_deps=true
  shift
fi
if [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--skip-deps]" >&2
  exit 2
fi

fail() {
  echo "setup: $*" >&2
  exit 1
}

canonical_path() {
  local path="$1"
  local parent target

  while [[ -L "$path" ]]; do
    parent=$(cd -P "$(dirname "$path")" 2>/dev/null && pwd) || return 1
    target=$(readlink "$path") || return 1
    if [[ "$target" = /* ]]; then
      path="$target"
    else
      path="$parent/$target"
    fi
  done

  parent=$(cd -P "$(dirname "$path")" 2>/dev/null && pwd) || return 1
  printf '%s/%s\n' "$parent" "$(basename "$path")"
}

link_path() {
  local source="$1"
  local destination="$2"
  local existing_target source_target

  [[ -e "$source" ]] || fail "source does not exist: $source"
  mkdir -p "$(dirname "$destination")"

  if [[ -L "$destination" ]]; then
    existing_target=$(canonical_path "$destination") || fail "cannot resolve existing link: $destination"
    source_target=$(canonical_path "$source") || fail "cannot resolve source: $source"
    if [[ "$existing_target" == "$source_target" ]]; then
      return
    fi
    fail "refusing to replace existing symlink: $destination -> $(readlink "$destination")"
  fi

  if [[ -e "$destination" ]]; then
    fail "refusing to replace existing path: $destination (back it up or remove it, then rerun)"
  fi

  ln -s "$source" "$destination"
  echo "Linked $destination"
}

prepare_claude_skills_dir() {
  local claude_skills="$HOME/.claude/skills"
  local agents_skills="$HOME/.agents/skills"
  local backup="$HOME/.claude/skills.shared-agents"
  local claude_target agents_target

  mkdir -p "$HOME/.claude" "$agents_skills"

  if [[ -L "$claude_skills" ]]; then
    claude_target=$(canonical_path "$claude_skills") || fail "cannot resolve $claude_skills"
    agents_target=$(canonical_path "$agents_skills") || fail "cannot resolve $agents_skills"
    [[ "$claude_target" == "$agents_target" ]] || fail "$claude_skills is a symlink to a different location; refusing to change it"
    [[ ! -e "$backup" && ! -L "$backup" ]] || fail "cannot preserve the existing skills symlink; backup path already exists: $backup"
    mv "$claude_skills" "$backup"
    mkdir -p "$claude_skills"
    echo "Separated Claude skills from shared skills; preserved the old symlink at $backup"
  elif [[ -e "$claude_skills" && ! -d "$claude_skills" ]]; then
    fail "$claude_skills exists but is not a directory"
  else
    mkdir -p "$claude_skills"
  fi
}

for required in \
  "$repo_dir/AGENTS.md" \
  "$repo_dir/universal/skills" \
  "$repo_dir/claude/skills" \
  "$repo_dir/pi/skills" \
  "$repo_dir/pi/extensions"; do
  [[ -e "$required" ]] || fail "expected repository path is missing: $required"
done

mkdir -p "$HOME/.agents/skills" "$HOME/.codex" "$HOME/.pi/agent/skills" "$HOME/.pi/agent/extensions"
prepare_claude_skills_dir

# Keep one instruction source, exposed under each harness's expected global filename.
link_path "$repo_dir/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_path "$repo_dir/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
link_path "$repo_dir/AGENTS.md" "$HOME/.claude/CLAUDE.md"

for skill in "$repo_dir"/universal/skills/*; do
  [[ -d "$skill" ]] || continue
  name=${skill##*/}
  link_path "$skill" "$HOME/.agents/skills/$name"
  link_path "$skill" "$HOME/.claude/skills/$name"
done

for skill in "$repo_dir"/pi/skills/*; do
  [[ -d "$skill" ]] || continue
  name=${skill##*/}
  link_path "$skill" "$HOME/.pi/agent/skills/$name"
done

for skill in "$repo_dir"/claude/skills/*; do
  [[ -d "$skill" ]] || continue
  name=${skill##*/}
  link_path "$skill" "$HOME/.claude/skills/$name"
done

for extension in "$repo_dir"/pi/extensions/*; do
  [[ -d "$extension" ]] || continue
  [[ -f "$extension/index.ts" || -f "$extension/index.js" ]] || continue
  name=${extension##*/}
  link_path "$extension" "$HOME/.pi/agent/extensions/$name"
done

if [[ "$skip_deps" == false ]]; then
  command -v npm >/dev/null 2>&1 || fail "npm is required to install Pi extension dependencies (or rerun with --skip-deps)"
  for lockfile in "$repo_dir"/pi/extensions/*/package-lock.json; do
    [[ -f "$lockfile" ]] || continue
    extension_dir=$(dirname "$lockfile")
    echo "Installing dependencies in ${extension_dir#"$repo_dir"/}"
    (cd "$extension_dir" && npm ci)
  done
fi

echo "Agent setup links are ready. Restart or reload the tools to discover the resources."
