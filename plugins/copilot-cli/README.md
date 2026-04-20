# copilot-cli

Delegate tasks and adversarial code reviews to GitHub Copilot CLI as Claude Code subagents, running either Claude Opus 4.6 or GPT-5.4 under the hood.

## Agents

### `copilot-task` *(Claude Opus 4.6)*

Dispatches self-contained tasks to Copilot CLI backed by `claude-opus-4.6`. The agent preflights the CLI, builds a fully self-contained prompt, invokes `copilot -p` once, and returns the raw stdout unchanged.

**Use when:**
- Task requires scanning many files (saves the main agent's context window)
- You want a second opinion from an isolated Copilot session
- Batch exploration or edge-case analysis

**Invoked by:** main agent via `Agent` tool with `subagent_type: "copilot-cli:copilot-task"`

### `copilot-review` *(GPT-5.4)*

Adversarial code reviewer backed by `gpt-5.4`. Default stance is skeptical — it looks for reasons the change should NOT ship.

**Use when:**
- Completing a feature before committing
- Reviewing high-risk code paths (auth, payments, data mutations)
- Workflow boundary checks

**Invoked by:** main agent via `Agent` tool with `subagent_type: "copilot-cli:copilot-review"`

## Skills

### `copilot-runtime` *(internal)*

Not user-invocable. Loaded automatically inside `copilot-task` and `copilot-review` agents. Defines:
- Invocation template (variable-based, no shell injection)
- Model routing defaults (`claude-opus-4.6` for task delegation, `gpt-5.4` for adversarial review, `gpt-5-mini` for debug only)
- Timeout guidelines

## Dependencies

- **GitHub Copilot CLI** — must be installed and authenticated (`copilot auth`)
- Agents perform a preflight check and return a structured error if `copilot` is not found in PATH

## Security

See root [README.md](../../README.md#安全说明) for `--allow-all` and CLAUDE.md privacy notes.
