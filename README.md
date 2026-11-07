# The Big Five for AI

[![Version 0.1.0](https://img.shields.io/badge/version-0.1.0-1d1d1f)](.claude-plugin/plugin.json)
[![License: MIT](https://img.shields.io/badge/license-MIT-1d1d1f)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude_Code-plugin-1d1d1f)](#install)
[![Codex skill](https://img.shields.io/badge/Codex-skill-1d1d1f)](#install)

Five principles that make AI agents work the way I work. One install, and every Claude Code and Codex session follows them.

> Do work the best in the field would sign off on, and never waste anyone's time getting there.

## Why I made this

I work with AI agents every day, mostly on AI models and sometimes on websites. The same five things kept going wrong. Agents said "done" without running anything. They made tests pass by cheating. They guessed APIs that do not exist. They left debug code and test runs behind. And they burned hours on work that could take minutes, or rushed work that needed hours.

I want perfection. I would rather an agent work for three days and get it right than finish in an hour with something broken. I also hate wasted time. So the goal has to be defined, measured and proven, and the agent has to take the shortest path to it.

The name comes from John Strelecky's book "The Big Five for Life". The idea of shipping working rules as a skill comes from the [Karpathy-inspired CLAUDE.md](https://github.com/multica-ai/andrej-karpathy-skills). Mine are the five rules I kept repeating to every agent I worked with.

## The five

1. **Perfect is the target.** A result is perfect when it is correct and proven by tests or by math, no simpler design solves the same problem, and it is at least as good as the best existing work. A faster method is fine only if it reaches the same decision at the same quality.
2. **Prove it before you show it.** Run it, read the full output, look at the page. Never claim something works without evidence from this session. If 100 lines can do what 1000 lines do, rewrite it.
3. **Tell the truth, find the way.** Report what failed. Never fake a result. Push back on a worse idea with evidence. Never give up: stop only after proving the goal impossible, then propose the closest possible goal.
4. **Research what you can't prove.** Check docs, papers and source code before relying on memory. Skip research when the answer can be proven.
5. **Clean up after yourself.** Remove every leftover you created, name things for what they are, and ask before touching a mess you did not make.

The full text is in [SKILL.md](skills/big-five-for-ai/SKILL.md), with 18 worked examples in [EXAMPLES.md](skills/big-five-for-ai/EXAMPLES.md). A project's own `CLAUDE.md` or `AGENTS.md` always wins. That is where you decide per project how much an agent may do on its own, such as committing or pushing.

## Install

Paste this into Claude Code or Codex. The agent installs everything itself:

```
Install the Big Five for AI for me, globally. Follow the instructions at https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/INSTALL.md
```

Or install it yourself.

**Claude Code** in the terminal, the Desktop app or an IDE (version 2.1.292 or later):

```bash
claude plugin install big-five-for-ai --marketplace Nikityyy/big-five-for-ai
```

**Codex** on macOS, Linux or Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/install.sh | bash
```

**Codex** on Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/install.ps1 | iex
```

**Claude Code cloud sessions** (claude.ai/code) do not load plugins. Add this line to your cloud environment's setup script:

```bash
mkdir -p ~/.claude/big-five-for-ai && curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/SKILL.md -o ~/.claude/big-five-for-ai/SKILL.md && curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai/EXAMPLES.md -o ~/.claude/big-five-for-ai/EXAMPLES.md && { grep -qxF '@~/.claude/big-five-for-ai/SKILL.md' ~/.claude/CLAUDE.md 2>/dev/null || printf '\n@~/.claude/big-five-for-ai/SKILL.md\n' >> ~/.claude/CLAUDE.md; } || true
```

## Update

- In Claude Code, run `claude plugin marketplace update nikitaberger`, then `claude plugin update big-five-for-ai@nikitaberger`. Marketplaces outside Anthropic's own do not update automatically.
- In Codex, run the install command again. It replaces its block in place.
- Cloud sessions need nothing. The cloud caches the setup script, so changes arrive within about seven days.

## Uninstall

Paste this into Claude Code or Codex:

```
Uninstall the Big Five for AI completely. Follow the uninstall instructions at https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/INSTALL.md
```

Or do it yourself.

**Claude Code**

```bash
claude plugin marketplace remove nikitaberger
```

This also uninstalls the plugin. Claude Code keeps a copy in `~/.claude/plugins/cache/nikitaberger`, which you can delete.

**Codex** on macOS, Linux or Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/uninstall.sh | bash
```

**Codex** on Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/codex/uninstall.ps1 | iex
```

The Codex uninstall restores your `AGENTS.md` byte for byte.

For cloud sessions, delete the line from your setup script.

## How it works

- In Claude Code, a plugin adds the skill and a SessionStart hook. The hook loads [SKILL.md](skills/big-five-for-ai/SKILL.md) at the start of every session, after `/clear` and after compaction. It costs about 1,300 tokens per session.
- In Codex, the scripts put the skill in `~/.agents/skills/` and the principles between two marker lines in your global `AGENTS.md`, which Codex loads in every session. Nothing outside the markers changes.
- In cloud sessions, the setup script line downloads the files and imports them from `~/.claude/CLAUDE.md`.

## Evidence

Each principle answers a failure that research has measured:

| Principle | Failure it targets |
|---|---|
| 1. Perfect is the target | Agents lose reliability when goals are vague. Performance drops 39% when instructions arrive in pieces ([Laban et al.](https://arxiv.org/abs/2505.06120)). |
| 2. Prove it before you show it | Models rarely fix their own reasoning by rereading it ([Huang et al.](https://arxiv.org/abs/2310.01798)). Running the code and feeding back the result raises accuracy by up to 12% ([Chen et al.](https://arxiv.org/abs/2304.05128)). |
| 3. Tell the truth, find the way | Frontier models edit tests and special-case inputs to look successful ([ImpossibleBench](https://arxiv.org/abs/2510.20270)). Overthinking lowers success on real coding tasks ([Cuadron et al.](https://arxiv.org/abs/2502.08235)). |
| 4. Research what you can't prove | Code models invent packages that do not exist, at least 5.2% of the time for commercial models ([Spracklen et al.](https://arxiv.org/abs/2406.10279)). |
| 5. Clean up after yourself | Duplicated code and code rewritten soon after it was written both rose as AI assistants spread, across 211 million changed lines ([GitClear](https://www.gitclear.com/ai_assistant_code_quality_2025_research)). |

Context files work best for rules an agent would not follow by default, and agents follow them well ([Gloaguen et al.](https://arxiv.org/abs/2602.11988)). That is why these five are short and specific.

I also ran four small tasks with and without the principles. Without them, Codex made a failing test pass by hard-coding `add(2, 2)` to return 5. With them, it refused and explained why. Claude Code passed most of these tasks either way, and with the principles it also removed the caches it had created. One run per case, so take this as a signal, not a benchmark.

## Status

Version 0.1.0.

What I tested on Windows:
- The Claude Code plugin, installed from GitHub and uninstalled again. The hook works in Git Bash and in PowerShell.
- The Codex scripts in bash and Windows PowerShell 5.1, in 134 file checks.
- The agent install and uninstall prompts in Claude Code.

What I have not tested yet:
- Codex following the principles in a live session.
- A real cloud session.
- PowerShell 7, macOS and Linux.

## Credits

- John Strelecky, "The Big Five for Life", for the idea of naming the five things that matter most.
- The [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) project, for showing that a short set of rules changes how agents work.

This project is not affiliated with John Strelecky, Andrej Karpathy or either project.

## License

[MIT](LICENSE)
