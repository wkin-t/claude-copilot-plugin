---
name: copilot-runtime
description: Internal helper for invoking Copilot CLI from Claude Code subagents — covers invocation template, model routing, context injection, and self-containment rules. Not user-invocable.
user-invocable: false
---

# Copilot CLI Runtime

Use this skill only inside `copilot-cli:copilot-task` and `copilot-cli:copilot-review` subagents.

## Invocation Template

```bash
copilot -p "<task_prompt>" \
  --model <model> \
  [--effort <effort>] \
  -s \
  --allow-all \
  [--add-dir <working_dir>]
```

## Required Flags

| Flag | Purpose |
|------|---------|
| `-s` / `--silent` | Only output model response, suppress stats |
| `--allow-all` | Grant all permissions for non-interactive mode |

## Model Routing

| Model | When | Strengths |
|-------|------|-----------|
| `gpt-5.4` | **Default for all real tasks** | Edge cases, boundary conditions, error handling |
| `claude-opus-4.6` | Caller requests design/architecture work | System design, architecture decisions |
| `gpt-5-mini` | **Debug only** — never for real tasks | Plugin testing |

Default `--effort high` for all real tasks.

## Context Injection

Copilot auto-loads from the working directory:
- `./CLAUDE.md` and `./.claude/CLAUDE.md`
- `./AGENTS.md`

For additional context (memory, file contents): embed directly in the `-p` prompt inside `<context>` tags.

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
