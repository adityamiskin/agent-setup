# CLIProxyAPI hub

Local [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) instance that
pools the Claude subscription accounts behind one Anthropic-compatible endpoint
on `127.0.0.1:8317`.

Claude Code (terminal), T3 Code, and any other Anthropic client point at the
hub, so every client shares the same account pool and the same usage limits.

## What runs

| Unit | Purpose |
| --- | --- |
| `cliproxyapi.service` | The hub, bound to loopback only. Starts at boot via user linger. |
| `cliproxy-pool-tuner.timer` | Runs `cliproxy-pool-tuner` every 10 minutes. |

`cliproxy-pool-tuner` sets each Claude account's weighted-round-robin weight:

- base share: Zapsight 4, Gmail 1 (Zapsight reports no weekly window)
- weight 0 while a session or weekly window is exhausted
- weight 64 when a weekly window is behind the pace needed to spend it before
  its reset, or when any window is close to resetting with quota left; unused
  quota is lost at reset
- 64 against a base of 1-4 makes the burning account take almost all new
  sessions, so the expiring quota is what gets spent

## Install

The setup is installed by `omarchy/apply.sh`, which copies the units and the
tuner from `omarchy/home/` and then runs `cliproxyapi/install.sh`. Run
`install.sh` on its own to install or re-run only this part.

`install.sh` is idempotent:

- downloads the pinned release to `~/cliproxyapi` when the binary is missing
- generates `~/cliproxyapi/.keys` (mode 600) when it is missing
- renders `~/cliproxyapi/config.yaml` (mode 600) from `config.yaml.tpl` when it
  is missing, so hand edits are never overwritten
- points `~/.claude/settings.json` at the hub, keeping the rest of the file
- enables the hub service and the tuner timer

## Add an account

```bash
~/cliproxyapi/cli-proxy-api --claude-login
```

Auth files land in `~/.cli-proxy-api/` and hot-reload, so the hub does not need
a restart. Keep them at mode 600.

## Point a client at the hub

The access key lives in `~/cliproxyapi/.keys` (`ACCESS_KEY=...`).

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:8317",
    "ANTHROPIC_AUTH_TOKEN": "<access key>",
    "ANTHROPIC_API_KEY": ""
  },
  "promptCacheTtl": "1h"
}
```

The 1h prompt cache TTL matches the 1h session-affinity TTL, so a thread keeps
its account for the life of its cache.

## T3 Code usage limits

Add a usage source under Settings → Providers, or directly in
`~/.t3/userdata/settings.json`:

```json
{
  "usageLimitSources": {
    "home-hub": {
      "kind": "cliproxy",
      "label": "Home Hub",
      "url": "http://127.0.0.1:8317",
      "managementKey": "<management key>",
      "enabled": true
    }
  }
}
```

Both keys are in `~/cliproxyapi/.keys`.

## Troubleshooting

```bash
journalctl --user -u cliproxyapi -f
systemctl --user restart cliproxyapi
systemctl --user list-timers cliproxy-pool-tuner.timer
journalctl --user -u cliproxy-pool-tuner
```

The hub logs a `session-affinity: new binding` line per new thread, which shows
which account a request landed on.
