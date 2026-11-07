# Installing the Big Five for AI

These instructions are written for the AI agent that does the work. Find out which agent and surface you are, then follow that section only. Tell the user each command before you run it, and report what changed at the end.

## Install

### Claude Code on this computer (terminal, Desktop app, IDE)

1. Run:
   ```
   claude plugin marketplace add Nikityyy/big-five-for-ai
   claude plugin install big-five-for-ai@nikitaberger
   ```
2. Check: `claude plugin list` shows `big-five-for-ai@nikitaberger` as enabled.
3. Tell the user the principles load in every new session, and after `/clear` in an open one. Print the principles now with `curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/SKILL.md` and follow them for the rest of this session. Use curl, because a web fetch tool may return only a summary.

### Claude Code cloud session (claude.ai/code, cloud sessions from the Desktop or mobile app)

A cloud session does not load plugins, and you cannot edit the cloud environment. The user has to add one line to the environment's setup script.

1. Give the user this line and tell them where it goes: claude.ai/code, the environment's settings, **Setup script**. They add it on its own line.
   ```
   mkdir -p ~/.claude/big-five-for-ai && curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/SKILL.md -o ~/.claude/big-five-for-ai/SKILL.md && curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/EXAMPLES.md -o ~/.claude/big-five-for-ai/EXAMPLES.md && { grep -qxF '@~/.claude/big-five-for-ai/SKILL.md' ~/.claude/CLAUDE.md 2>/dev/null || printf '\n@~/.claude/big-five-for-ai/SKILL.md\n' >> ~/.claude/CLAUDE.md; } || true
   ```
2. Tell the user that new sessions in that environment load the principles, and that the cloud caches the setup for about seven days, so later changes to the principles can take that long to arrive.
3. Print the principles now with `curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/SKILL.md` and follow them for the rest of this session. Use curl, because a web fetch tool may return only a summary.

### Codex (CLI, IDE extension or app)

The script writes to `~/.agents/skills/` and to Codex's global `AGENTS.md`, both outside the workspace. If your sandbox blocks that, ask the user to approve the command.

- macOS, Linux, or Git Bash on Windows:
  ```
  curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/install.sh | bash
  ```
- Windows PowerShell:
  ```
  irm https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/install.ps1 | iex
  ```

Check: the instructions file the script printed contains `<!-- big-five-for-ai:start`. Tell the user the principles load in every new Codex session.

## Update

- Claude Code on this computer: `claude plugin marketplace update nikitaberger`, then `claude plugin update big-five-for-ai@nikitaberger`. The update loads in the next session.
- Claude Code cloud: nothing to do. The environment picks up changes when its cache is rebuilt, within about seven days.
- Codex: run the install command again. It replaces the block in place.

## Uninstall

### Claude Code on this computer

1. Run:
   ```
   claude plugin marketplace remove nikitaberger
   ```
   This uninstalls the plugin too.
2. Claude Code keeps a cached copy after uninstalling. Delete `~/.claude/plugins/cache/nikitaberger` and `~/.claude/plugins/marketplaces/nikitaberger` if they exist.
3. Check: `claude plugin list` no longer shows `big-five-for-ai`. Tell the user that open sessions keep the principles until `/clear` or a restart.

### Claude Code cloud session

1. Tell the user to delete the setup script line that contains `big-five-for-ai`. Changing the script rebuilds the cloud cache without the principles.
2. In this session, delete `~/.claude/big-five-for-ai/` and remove the line `@~/.claude/big-five-for-ai/SKILL.md` from `~/.claude/CLAUDE.md`. If that line was the file's only content, delete the file.

### Codex

- macOS, Linux, or Git Bash on Windows:
  ```
  curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/uninstall.sh | bash
  ```
- Windows PowerShell:
  ```
  irm https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/uninstall.ps1 | iex
  ```

The script restores Codex's instructions file to exactly what it was before the install. Check: no file in `~/.codex` contains `big-five-for-ai`.
