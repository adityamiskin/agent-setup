# Slack theme

Vendored from [GruperTal/omarchy-slack-theme](https://github.com/GruperTal/omarchy-slack-theme)
(MIT, see `LICENSE`), pinned at commit `0f8a59f`. Keep these files byte-identical to upstream;
update them by re-fetching that commit's `slack-asar-patch` and `omarchy-slack-theme`.

Slack paints its UI from `--dt_color-*` and `--sk_*` custom properties, so the generator maps the
active Omarchy palette onto them and nudges anything unreadable to 4.5:1 contrast.

- `slack-asar-patch` (here) appends a CSS loader to `dist/boot.bundle.cjs` inside
  `/usr/lib/slack/resources/app.asar`, installs as `/usr/local/bin/omarchy-slack-asar-patch`, and is
  re-run by `omarchy-slack-theme.hook` after Slack upgrades.
- `../home/.local/bin/omarchy-slack-theme` writes `~/.local/state/omarchy-slack-theme/slack.css`,
  which the loader injects and re-injects on change.
- `../home/.config/omarchy/hooks/theme-set.d/omarchy-slack-theme` regenerates it on every theme switch.

`apply.sh` installs the root pieces and runs the generator once. Undo with
`sudo cp /usr/lib/slack/resources/app.asar.orig /usr/lib/slack/resources/app.asar`.
