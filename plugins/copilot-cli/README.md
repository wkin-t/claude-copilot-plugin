# copilot-cli

Delegate tasks and adversarial code reviews to GitHub Copilot CLI (GPT-5) as Claude Code subagents.

## Agents

### `copilot-task`

Dispatches self-contained tasks to GPT-5. The agent reads required files, embeds their content into a prompt, and invokes Copilot CLI once. Returns raw output without modification.

**Use when:**
- Task requires scanning many files (saves Claude's context window)
- You want a second opinion from a different model
- Batch exploration or edge-case analysis

**Invoked by:** main agent via `Agent` tool with `subagent_type: "copilot-cli:copilot-task"`

### `copilot-review`

Adversarial code reviewer. GPT-5's default stance is skeptical — it looks for reasons the change should NOT ship.

**Use when:**
- Completing a feature before committing
- Reviewing high-risk code paths (auth, payments, data mutations)
- Workflow boundary checks

**Invoked by:** main agent via `Agent` tool with `subagent_type: "copilot-cli:copilot-review"`

## Skills

### `copilot-runtime` *(internal)*

Not user-invocable. Loaded automatically inside `copilot-task` and `copilot-review` agents. Defines:
- Invocation template (variable-based, no shell injection)
- Model routing table (`gpt-5.4` default, `claude-opus-4.6` for architecture, `gpt-5-mini` for debug only)
- Timeout guidelines

## Dependencies

- **GitHub Copilot CLI** — must be installed and authenticated (`copilot auth`)
- Agents perform a preflight check and return a structured error if `copilot` is not found in PATH

## Security

See root [README.md](../../README.md#安全说明) for `--allow-all` and CLAUDE.md privacy notes.
