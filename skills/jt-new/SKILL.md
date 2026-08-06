---
name: jt-new
description: Research, interview, and create delegation-ready Jira tickets through the connected Atlassian MCP. Use for new single-repository work, multi-repository changes requiring linked issues, duplicate checks, and project or issue-type discovery.
---

# JT New

Create a new Jira issue or linked cross-repository issue graph. The requested host alias is `/jt:new`; the native skill identifier is `$jt-new`.

## Rules

- Research before writing Jira content.
- Treat Jira issue creation and issue linking as external writes.
- Show the complete preview and require explicit confirmation immediately before creation.
- Never modify Filetree artifacts.
- Never invent Jira projects, issue types, link types, custom fields, labels, priorities, assignees, or components.
- On partial failure, report completed operations and stop. Do not delete or recreate issues automatically.

## Ground each repository

Run this process independently for every repository in scope.

1. Resolve the Git root and read applicable `AGENTS.md`, `CLAUDE.md`, and repository documentation.
2. Read `.filetree.json` when present and resolve its `manifest_path`; otherwise check `FILETREE.md`.
3. If the Filetree linter is installed, run its read-only lint command. Classify the result as `filetree-validated`, `filetree-stale`, `filetree-missing`, or `filetree-unavailable`.
4. Read `FILETREE.md` first only when it is validated. Otherwise report the reason and use targeted `rg --files` and `rg` discovery.
5. Inspect relevant source, API contracts, types, data changes, configuration, tests, and documentation. Record repository-relative evidence paths.

Filetree is an index, not proof. Verify important behavior from source and tests.

## Interview unresolved requirements

Before drafting, determine whether the request establishes outcome, scope, affected repositories, dependencies, acceptance criteria, and tests. If an implementation-changing unknown remains, interview the ticket writer:

1. Ask exactly one question per turn.
2. Ask architecture, repository, interface, data, permission, and sequencing questions first.
3. Ask behavior, failure-mode, compatibility, rollout, and acceptance questions next.
4. Ask polish questions last.
5. Explain why each question matters, provide two or three choices, and recommend one.
6. Accept “you decide” and record the decision as an assumption.
7. Checkpoint decisions after every three answers and flag contradictions.

Use this embedded workflow as the portable equivalent of the supplied finding-unknowns interview skills.

## Resolve Jira metadata

1. Call `getAccessibleAtlassianResources` to identify the cloud.
2. Call `getVisibleJiraProjects` with create access.
3. Call `getJiraProjectIssueTypesMetadata` for selected projects.
4. Call `getIssueLinkTypes` before planning links.
5. Honor an explicit repository-to-project mapping. If none is supplied and exactly one create-capable project exists, use it. Ask for a mapping when multiple projects are possible.
6. Infer `Bug`, `Story`, or `Task` only when that type exists. Use `Task` for an umbrella when available.
7. Search likely duplicates with `searchJiraIssuesUsingJql`. Ask whether to create new, reuse an existing issue, or stop.

## Draft the issue set

For one repository, draft one implementation issue. For multiple repositories, draft one umbrella coordination issue and one implementation issue per repository that requires changes.

Every issue description must include relevant sections for:

- context and source evidence;
- problem and desired outcome;
- non-goals and bounded scope;
- affected files, modules, APIs, or data contracts;
- behavior and failure modes;
- observable acceptance criteria;
- test plan;
- dependencies, risks, rollout, and assumptions.

The umbrella must also include the repository map, shared contracts, delivery sequence, cross-repository acceptance criteria, and dependency graph. Keep child issues independently actionable without duplicating the full umbrella description.

## Link and preview

- Link each implementation issue to the umbrella with `Relates` when available.
- Add `Blocks` only for real sequencing dependencies. For `createIssueLink`, pass the blocker as `inwardIssue` and the blocked issue as `outwardIssue`.
- If no suitable umbrella relationship exists, stop and ask how to represent it.

Show one preview containing Filetree status, interview decisions, assumptions, duplicate candidates, project and type per issue, complete descriptions, and every planned link.

After explicit approval:

1. Create the umbrella with `createJiraIssue`.
2. Create every repository issue.
3. Create links after all issue keys exist.
4. Return keys, URLs, repository mapping, and links.

## Validation

Run the standard skill validator. Test preview-only behavior for a confirmed single-repository request, an unresolved request requiring interview, a stale Filetree fallback, a two-repository graph, duplicate candidates, multiple Jira projects, missing link types, and partial creation failure. Do not create live Jira issues during validation without explicit user approval.
