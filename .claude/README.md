# Claude Code project setup

This folder holds project-level Claude Code hooks and subagent definitions.

## Hooks

`.claude/settings.example.json` shows two hooks. The local `settings.local.json` is not included.

- `PreToolUse` runs `hooks/bash-guard.sh` before Bash commands. It blocks selected destructive or high-risk commands, including in bypass-permissions mode.
- `PostToolUse` runs `hooks/lint-changed-file.sh` after `Edit` or `Write`. It reports lint failures to Claude after the edit. It does not block the edit itself.

To use the hooks in another project:

1. Copy the needed scripts from `hooks/` into that project's `.claude/hooks/` directory.
2. Copy only the top-level `hooks` object from `settings.example.json` into that project's `.claude/settings.json` or `.claude/settings.local.json`. Keep the project's other settings.
3. Check the hook command paths and required tools in the target project.

The lint hook is project-specific. It checks selected Laravel and web-app paths with its repo's ESLint, Pint, and PHPStan setup. Do not copy it unchanged into another repo. Ask Claude to inspect that repo's lint and type-check commands, then tune the hook paths and commands.

## Subagents

`.claude/agents/` contains project subagent definitions:

- `researcher.md` searches external sources and returns a sourced summary.
- `scout.md` searches this repo and maps relevant files without editing them.
- `worker.md` implements scoped tasks and follows this repo's workflow and test instructions.

Claude Code loads project subagents from `.claude/agents/`. Copy a definition into another project's `.claude/agents/` to adapt it there. Review its tools, model, permissions, and project-specific instructions first. In particular, `worker.md` refers to its repo's `AGENTS.md` and documentation paths.
