# pstack for Claude Code

A Claude Code port of [pstack](https://github.com/cursor/plugins/tree/main/pstack), Lauren Tan's (poteto) Cursor plugin. It packages poteto-mode, 23 playbooks, 23 single-rule principles, and multi-agent workflow skills. It favors less code of higher quality, with enough rigor per agent that running many in parallel stays safe.

Ported from upstream `0.15.5`. MIT, same as upstream (see `LICENSE`). Usage: [`docs/USAGE.md`](docs/USAGE.md). Upstream docs: [pstack guide](https://github.com/cursor/plugins/tree/main/pstack/docs/guide) (describes Cursor).

## Install

```sh
claude plugin marketplace add ~/workspace/pstack
claude plugin install pstack@pstack
```

Or from inside Claude Code: `/plugin marketplace add ~/workspace/pstack`, then `/plugin install pstack@pstack`. Restart Claude Code after installing.

See [`docs/USAGE.md`](docs/USAGE.md) for the full usage guide.

Then run `/pstack:setup-pstack` once to pick models, and `/pstack:poteto-mode <task>` for anything that needs rigor. The bare names (`/poteto-mode`, `/how`) also work when no other skill has the same name.

## Skills

All skills are user-invoked (slash commands). Claude does not auto-trigger them; poteto-mode and the other skills read each other by file path.

| Skill | What it does |
|---|---|
| `/poteto-mode` | Main entry. Matches the task to a playbook, copies its steps into a todo list, routes to other skills. Sticky, see below. |
| `/how`, `/why`, `/teach`, `/recall` | Explain a subsystem, dig up why it was built this way, teach by diagrams, rebuild recent context from transcripts. |
| `/architect`, `/blast-radius`, `/tdd` | Settle shape before coding, prove a small change is safe, test first. |
| `/arena`, `/swarm`, `/interrogate` | N parallel attempts merged, N workers over slices, a multi-model panel that tries to break a diff. |
| `/unslop`, `/technical-writing`, `/no-comments`, `/bro` | Prose and comment discipline. |
| `/reflect`, `/automate-me`, `/figure-it-out`, `/show-me-your-work` | Encode lessons, draft your own `-mode` skill, design a bespoke playbook, keep a decision log. |
| `/create-verification-skill`, `/maintain-verification-skill` | Generate and maintain a project-local `verify-<app>` skill in `.claude/skills/`. |
| `/typescript-best-practices`, `/setup-pstack` | TS type discipline; per-role model config. |
| `principle-*` | 23 principles, read by poteto-mode on demand. |

Agents: `pstack:poteto-agent` (reads poteto-mode before working) and `pstack:comment-sicko` (comment-deleting reviewer behind `/no-comments`).

## What changed from the Cursor plugin

- **Sticky mode.** Cursor keeps `mode: true` skills on across turns. Here a `UserPromptSubmit` hook (`hooks/poteto-mode-sticky.sh`) turns poteto-mode on when you type `/poteto-mode` and re-injects its reminder on every later prompt in that session. Turn it off with `/poteto-mode off` or "exit poteto mode". State lives in `~/.claude/pstack/state/`.
- **Models.** Claude Code subagents only run Claude models, so Grok and GPT are gone. Defaults are `sonnet` for code, `opus` for judgment and prose, and `opus, opus, sonnet` for review panels. Unavailable aliases fall back down `opus` → `sonnet` → `haiku`. `/setup-pstack` writes `~/.claude/rules/pstack-models.md`. Budgets pick model tiers, since the Agent tool has no reasoning-effort setting.
- **Tools.** `Task`/`generalPurpose` → `Agent`/`general-purpose`. `readonly` → "don't edit" in the prompt. Cursor cloud agents → `isolation: "worktree"` (or `"remote"` where available). `AskQuestion` → `AskUserQuestion`. `/loop` is Claude Code's built-in.
- **Transcripts.** `/recall`, `/reflect`, `/automate-me`, `/show-me-your-work`, session pickup, worktree cleanup, and evals read `~/.claude/projects/<slug>/*.jsonl` (slug is the workspace path with every non-alphanumeric character turned into `-`).
- **Cursor-only dependencies, substituted.** `/deslop` (cursor-team-kit) → built-in `/simplify`. `control-ui`/`control-cli` → a project `verify-*` skill, the built-in `run` skill, or a browser MCP. `create-skill` → the official `skill-creator` plugin (`claude plugin install skill-creator@claude-plugins-official`) when installed.
- **Dropped.** `/make-bot-ui` and the `benny` automations pack depend on Cursor's webhook and automation service.

## Requirements

- `jq` for the sticky-mode hook.
- `gh` for the PR playbooks (babysit, shipping, autopilot).
- `bun` for `skills/poteto-mode/scripts/watch-pr` and `orch` (installs its own deps on first run).
