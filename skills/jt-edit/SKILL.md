---
name: jt-edit
description: Research and improve existing Jira issues through the connected Atlassian MCP. Use for clarifying summaries, expanding implementation detail, correcting acceptance criteria, adding tests and source evidence, and editing a selected issue graph.
---

# JT Edit

Improve existing Jira issues after verifying their claims against source. The requested host alias is `/jt:edit`; the native skill identifier is `$jt-edit`.

## Rules

- Require at least one Jira issue key.
- Treat existing Jira text as a hypothesis, not as verified requirements.
- Research before proposing edits and interview when the edit goal is under-specified.
- Show a field-level preview and require explicit confirmation before every update batch.
- Never modify Filetree artifacts.
- Never change fields the writer did not approve.
- On partial failure, report completed and failed updates without automatic rollback.

## Load the issue and repository context

1. Resolve the Atlassian cloud and fetch each named issue with `getJiraIssue`, including summary, description, project, issue type, status, labels, components, links, and relevant custom fields.
2. Use `getJiraIssueTypeMetaWithFields` before proposing non-standard fields.
3. Resolve the repository or repositories referenced by the issue. If a required repository is inaccessible, ask for its path.
4. For each repository, read `.filetree.json` when present, resolve its manifest path, and run the installed Filetree linter if available.
5. Use `FILETREE.md` first only when validated. For stale, missing, or unavailable Filetree, disclose the status and use targeted `rg --files` and `rg` discovery.
6. Verify current behavior, affected code, tests, interfaces, data contracts, and dependencies from source.

## Choose edit scope

Ask on every invocation whether to edit:

- named issues only; or
- the named issue plus its linked issue graph.

For graph scope, show directly linked issues and relationship types, then ask which linked issues are actually in scope. Never update a linked issue implicitly.

## Interview the ticket writer

Interview when the edit goal is ambiguous, the issue conflicts with current source, or delegation-critical detail is missing:

1. Ask exactly one question per turn.
2. Prioritize product outcome, scope, repository ownership, interfaces, data, dependencies, and sequencing.
3. Then resolve behavior, edge cases, failure modes, compatibility, rollout, acceptance criteria, and tests.
4. Provide context, two or three choices, and a recommendation for each question.
5. Accept “you decide” as an explicit assumption.
6. Checkpoint decisions after every three answers and flag contradictions.

Use this embedded workflow as the portable equivalent of the supplied finding-unknowns interview skills.

## Draft the edit

Produce a field-level diff preview with:

- current and proposed summary;
- current and proposed description;
- rationale for each changed section;
- source evidence and affected files;
- proposed acceptance criteria and test plan;
- proposed standard or custom field changes;
- linked issues in scope and their individual edits;
- explicitly unchanged fields;
- Filetree grounding status and assumptions.

The improved description should contain relevant context, desired outcome, non-goals, implementation scope, affected interfaces or data, failure modes, observable acceptance criteria, tests, dependencies, risks, rollout, and assumptions. Do not add irrelevant boilerplate.

## Apply approved edits

By default, edit only `summary` and `description` using `editJiraIssue`. Change assignee, priority, labels, components, versions, parent, issue type, status, resolution, or custom fields only when explicitly requested and validated against metadata.

Do not transition, resolve, comment on, unlink, or create issues from this skill unless the writer explicitly requests that separate operation.

After explicit confirmation of the complete preview, apply updates one issue at a time. Return the resulting issue keys, URLs, changed fields, and any failed updates.

## Validation

Run the standard skill validator. Test preview-only behavior for a single issue needing stronger acceptance criteria, an ambiguous edit requiring interview, named-only scope, linked-graph scope with a selected subset, stale Filetree fallback, unavailable custom fields, and simulated partial update failure. Do not update live Jira issues during validation without explicit user approval.
