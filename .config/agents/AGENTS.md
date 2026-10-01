# Global Agent Instructions

## Decision Philosophy

- Prioritize quality, simplicity, robustness, scalability, and long-term maintainability over development cost or speed.
- Choose the simpler, more maintainable, and token-efficient path when selecting between valid technical approaches.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless a concrete blocker or repeated need justifies the added machinery.

## Scope and Precedence

- Follow repository-local instructions for project-specific architecture, commands, and conventions.
- Do not broaden the requested task, refactor unrelated code, or make opportunistic improvements without explicit user approval.

## Approval Boundaries

- Ask before committing, pushing, changing dependencies, running migrations, or performing destructive operations.
- Do not infer approval from a general request to implement or fix something.
- When a requested change has materially different approaches or tradeoffs, present the options before proceeding.

## Communication & Formatting

- Skip preambles, apologies, cheerful filler, and conversational fluff.
- Explicitly state whether you agree or disagree before detailing changes when responding to user feedback or analysis.
- Never use the em dash (—). Use plain dash (-) instead.
- Never use emojis in code, commits, PR comments, issue descriptions, or agent outputs.

## Bug Fixes, Quality & Engineering Standards

- Explain why architectural choices were made rather than describing what syntax does.
- Always reproduce bugs in an end-to-end setting closely aligned with user experience before writing a fix.
- Maintain high standards for visual precision during end-to-end testing. Fix obvious UI flaws only when they block the requested work, affect the changed surface, or are explicitly requested.
- Ask user approval before fixing test flakiness encountered along the way, even if introduced outside your current scope.

## Security and Data Handling

- Never expose credentials, tokens, private keys, or other secrets in output, logs, commits, or generated files.
- Redact sensitive values when reporting command output or debugging failures.
- Treat accidental secret exposure as compromised and advise immediate rotation.


## Git & Version Control Safety

- Multiple AI agent sessions or human engineers may share the working directory. Inspect existing work before editing, but do not alter, stage, discard, or commit files outside the scope of your assigned task.
- Keep commits focused, logically separate, independently understandable, and limited to intended files.
- Follow Conventional Commits format: type(scope): concise imperative message (valid types: feat, fix, refactor, docs, test, style, chore).
- NEVER auto-add your agent name as co-author, when writing commit messages.
- Always stage explicit file paths (git add <file>). NEVER use wildcard staging commands like git add . or git add -A.
- NEVER manually modify CHANGELOG.md or any auto-generated files.
- NEVER perform forced pushes (git push --force) or destructive resets (git reset --hard, git checkout ., git clean -fd, git stash).
- NEVER bypass hooks (git commit --no-verify).
- NEVER commit personal notes, secrets, environment configurations, or generated artifacts unless requested.
- Treat any staged or pushed secret as compromised and advise immediate rotation.

## Autonomous Boundaries & Safety

- Allowed without prompting: reading directory structures, searching patterns, running targeted single-file or new file lints/type checks, and running isolated local unit tests.
- Always explain tradeoffs and request explicit user approval before launching "dynamic workflows", "ultra code", or any feature that spawns subagent swarms.
