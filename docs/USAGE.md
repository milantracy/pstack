# Using pstack in Claude Code

## Setup

```sh
claude plugin marketplace add ~/workspace/pstack
claude plugin install pstack@pstack
```

Restart Claude Code, then run `/pstack:setup-pstack` once to pick models.

## Models

Models are set in `~/.claude/rules/pstack-models.md`. Claude Code loads that file into every session automatically, and the skills read it when they start subagents. Plugin updates don't touch it, so you set it once. After you edit it, start a new session.

```text
feature, refactoring: opus
bug-fix: opus
perf-issue: opus
hillclimb: opus
```

Values are `opus`, `sonnet`, `haiku`, or `inherit-parent`. A role with no line uses the skill default: `sonnet` for code and fan-out, `opus` for judgment.

## poteto-mode

```text
/pstack:poteto-mode users get two notifications after a retry. repro first, then fix and verify.
```

It picks a playbook, delegates code to subagents, and verifies the result before reporting. It stays on for the rest of the session. Say "new task" to switch tasks. Turn it off with `/pstack:poteto-mode off` or by saying "exit poteto mode".

## Other skills

Each of these works on its own. Type `/pstack:<name>`.

| Skill | For |
|---|---|
| `how`, `why`, `teach`, `recall` | Understand code, its history, or your past sessions |
| `architect`, `arena`, `figure-it-out` | Design before coding |
| `tdd`, `blast-radius`, `swarm`, `interrogate`, `no-comments` | Build, check, review |
| `unslop`, `technical-writing` | Prose |
| `reflect`, `automate-me`, `show-me-your-work` | Improve the skills, keep a decision log |
| `create-verification-skill` | Run once per app repo so agents can drive the real app |

## Tips

- Cut down on permission prompts: add `"Read(~/.claude/plugins/cache/pstack/**)"` to `permissions.allow` in `~/.claude/settings.json`.
- The PR playbooks need `gh`, the sticky hook needs `jq`, and the `watch-pr`/`orch` helpers need `bun`.
- After editing `~/workspace/pstack`, bump `version` in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then run `claude plugin marketplace update pstack && claude plugin update pstack@pstack` and restart.
