---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available Claude models and writes a user-level rule file that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

*pstack sibling skills named in this file (**how**, `/how`, **principle-…**, and so on) live at `../<name>/SKILL.md` relative to this skill's base directory. They are not model-invocable, so "run `/x`" means Read `../x/SKILL.md` and follow it.*

Write `~/.claude/rules/pstack-models.md`, a user-level rule file that sets pstack's model per role.

## Steps

### 1. Detect available models

Claude Code's `Agent` tool takes a `model` alias: `opus`, `sonnet`, or `haiku`. Omitting `model` runs the subagent on the parent chat model. Some providers (Vertex, Bedrock, gateways) do not serve every alias. Probe each alias you plan to write with one tiny `Agent` call (`subagent_type: general-purpose`, prompt "reply OK", the alias as `model`) in a single message, and keep only the aliases that answer. Wait for every probe to report before continuing; count a spawn error as unavailable. If the user states which models they have, trust that instead of probing. The alias `inherit-parent` is always valid.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below. If `~/.claude/rules/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Use AskUserQuestion over free text. Offer these four options with these exact labels, and name the current budget when the rule records one.

- `unlimited — opus everywhere`
- `large — skill defaults`
- `medium — sonnet for judgment`
- `small — haiku for code`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role the user changed by hand or set to `inherit-parent`. `large` leaves the table as-is. `unlimited` sets every role, panel entries included, to `opus`. `medium` turns every `opus` value, panel entries included, into `sonnet`; `sonnet` values stay. `small` does the same and also turns the code roles (`feature, refactoring`, `bug-fix`, `perf-issue`, `hillclimb`, `how explorer`, `why investigators`, `swarm workers`) into `haiku`. Any alias that step 1 found unavailable falls back to the nearest available tier (`opus` → `sonnet` → `haiku`), and the role is marked as a fallback.

**(c) Show the roles and confirm.** Show every role with its model, marking fallbacks. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the available aliases plus `inherit-parent` (this role runs on the parent chat model) as the options. Use AskUserQuestion. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. Claude Code only spawns Claude models, so panel diversity comes from different tiers, different prompts, and fresh context rather than different vendors. `arena cross-judge pool` is also a list, but Arena selects one value from it that differs from the parent's model when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every alias written must be available per step 1. `inherit-parent` always passes. If a chosen alias is not available, stop and ask again.

### 5. Write the rule

Create `~/.claude/rules/` if needed, then write `~/.claude/rules/pstack-models.md` with a `# budget` line with the chosen label, and one line per role, using the same labels poteto-mode uses. Claude Code loads `~/.claude/rules/*.md` as always-on user memory, and every pstack skill also reads this file directly before spawning, so it works either way. Overwrite the whole file so re-runs stay idempotent. Shape:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# Values are Claude Code Agent-tool model aliases: opus, sonnet, haiku.
# `inherit-parent` (or legacy `auto`) as a value: the role runs on the parent chat model (omit the Agent `model` parameter). Alias entries in a panel list still count toward its fan-out.
# budget: large (skill defaults)
feature, refactoring: sonnet
bug-fix: sonnet
perf-issue: sonnet
hillclimb: sonnet
judgment and prose: opus
hardest tasks: opus
how explorer: sonnet
how explainer: opus
why investigators: sonnet
why synthesizer: opus
reflect tooling: sonnet
reflect judgment, divergent, synthesizer: opus
arena runners: opus, opus, sonnet
arena cross-judge pool: opus, sonnet
swarm workers: sonnet
architect runners: opus, opus, sonnet
interrogate reviewers: opus, opus, sonnet
```

### 6. Confirm

Tell the user the rule was written. Skills read it on every spawn, so it applies immediately. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /pstack:create-verification-skill." On yes, read `../create-verification-skill/SKILL.md` (relative to this skill's base directory) and follow it. On no, move on without pushing.
