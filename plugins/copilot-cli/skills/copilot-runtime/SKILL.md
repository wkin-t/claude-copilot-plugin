---
name: copilot-runtime
description: Internal helper for invoking Copilot CLI from Claude Code subagents — covers invocation template, model routing, context injection, and self-containment rules. Not user-invocable.
user-invocable: false
---

# Copilot CLI Runtime

Use this skill only inside `copilot-cli:copilot-task` and `copilot-cli:copilot-review` subagents.

## Invocation Template

Always use a temporary file to pass the prompt — this avoids shell injection when file contents are embedded:

```bash
_prompt_file=$(mktemp /tmp/copilot-prompt-XXXXXX.txt)
cat > "$_prompt_file" << 'PROMPT_EOF'
<task_prompt>
PROMPT_EOF
copilot -p "$(cat "$_prompt_file")" \
  --model <model> \
  [--effort <effort>] \
  -s \
  --allow-all \
  [--add-dir <working_dir>]
rm -f "$_prompt_file"
```

## Required Flags

| Flag | Purpose |
|------|---------|
| `-s` / `--silent` | Only output model response, suppress stats |
| `--allow-all` | Grant all permissions for non-interactive mode. Grants Copilot CLI full tool access — do not use in untrusted environments |

## Model Routing

| Model | When | Strengths |
|-------|------|-----------|
| `gpt-5.4` | **Default for all real tasks** | Edge cases, boundary conditions, error handling |
| `claude-opus-4.6` | Caller requests design/architecture work | System design, architecture decisions |
| `gpt-5-mini` | **Debug only** — never for real tasks | Plugin testing |

Default `--effort high` for all real tasks.

## Context Injection

> ⚠️ **Privacy notice**: Copilot CLI auto-loads `./CLAUDE.md` and `./.claude/CLAUDE.md` from the working directory and sends them to GitHub Copilot (Microsoft/OpenAI servers). If your CLAUDE.md contains internal system prompts, proprietary constraints, or sensitive business context, run from a clean directory or ensure your CLAUDE.md is safe to share externally.

For additional context (memory, file contents): embed directly in the prompt inside `<context>` tags.

## Self-Containment Checklist

Before invoking, verify the prompt:
- [ ] Has clear completion criteria
- [ ] Contains all necessary file contents inline
- [ ] Has no ambiguity that would trigger clarifying questions
- [ ] Specifies output format explicitly
- [ ] Can be completed in a single invocation

## Timeout Guidelines

| Task Type | Timeout |
|-----------|---------|
| Quick lookup | 60000ms |
| File scanning / exploration | 180000ms |
| Code review / analysis | 180000ms |
| Large batch / architecture | 300000ms |
