#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): hard-block floor for catastrophic/unrecoverable
# commands. Modeled on ~/.pi/agent/extensions/bash-guard's HEADLESS_BLOCKED list,
# adapted for Claude Code (no interactive TUI hook, so there is no "prompt to
# override" tier here — matched patterns are always denied).
#
# Verified: PreToolUse hooks fire and can block regardless of permission mode,
# including bypassPermissions, and regardless of whether the caller is the main
# session or a subagent. This is intentionally the floor you keep even when
# running with bypassPermissions for convenience.
#
# Supersedes block-destructive-git.sh (folded in below).
set -euo pipefail

input="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$input")"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"

[ "$tool" = "Bash" ] || exit 0
[ -n "$cmd" ] || exit 0

reason=""

# --- Recursive deletion ---
# Flag must be preceded by whitespace so path segments like "web-vendor" (ends in
# "r") aren't mistaken for a -r/-rf flag.
if grep -qE '(^|[^a-zA-Z])rm\b[^|;&]*[[:space:]](-[a-zA-Z]*[rR]|--recursive)' <<<"$cmd"; then
  reason="Recursive delete (rm -r/-rf/-Rf) is blocked."

# --- Privilege escalation ---
elif grep -qE '(^|[^a-zA-Z])sudo\b' <<<"$cmd"; then
  reason="Elevated privileges (sudo) are blocked."

# --- Pipe to shell (remote code execution) ---
elif grep -qE '(curl|wget)\b[^|;&]*\|\s*(ba?sh|zsh|fish|dash|sh)\b' <<<"$cmd"; then
  reason="Pipe to shell (curl|sh / wget|sh) is blocked."

# --- Disk / filesystem destruction ---
elif grep -qE '(^|[^a-zA-Z])mkfs' <<<"$cmd"; then
  reason="Filesystem formatting (mkfs) is blocked."
elif grep -qE '(^|[^a-zA-Z])newfs_[a-zA-Z]+' <<<"$cmd"; then
  reason="Filesystem formatting (newfs_*) is blocked."
elif grep -qE '(^|[^a-zA-Z])wipefs\b' <<<"$cmd"; then
  reason="Disk signature wipe (wipefs) is blocked."
elif grep -qiE 'diskutil\s+(erase|zeroDisk|secureErase|reformat)' <<<"$cmd"; then
  reason="Destructive disk operation (diskutil erase/reformat) is blocked."
elif grep -qE 'dd\b[^|;&]*of=/dev/' <<<"$cmd"; then
  reason="Raw disk write (dd of=/dev/...) is blocked."
elif grep -qE '(^|[^a-zA-Z])(parted|fdisk|gdisk|sgdisk)\b' <<<"$cmd"; then
  reason="Partition table management is blocked."
elif grep -qE '(^|[^a-zA-Z])cryptsetup\b' <<<"$cmd"; then
  reason="Disk encryption management (cryptsetup) is blocked."
elif grep -qE '(^|[^a-zA-Z])zpool\b' <<<"$cmd"; then
  reason="ZFS pool management (zpool) is blocked."

# --- System power ---
elif grep -qE '(^|[^a-zA-Z])(shutdown|reboot|halt|poweroff)\b' <<<"$cmd"; then
  reason="System power operation is blocked."

# --- Infrastructure teardown ---
elif grep -qE 'terraform\s+destroy\b' <<<"$cmd"; then
  reason="Infrastructure teardown (terraform destroy) is blocked."
elif grep -qE 'kubectl\s+delete\b' <<<"$cmd"; then
  reason="Kubernetes resource deletion (kubectl delete) is blocked."
elif grep -qE 'aws\s+s3\s+rm\b[^|;&]*--recursive' <<<"$cmd"; then
  reason="Bulk S3 deletion (aws s3 rm --recursive) is blocked."
elif grep -qE 'gcloud\b[^|;&]*\bdelete\b' <<<"$cmd"; then
  reason="gcloud delete is blocked."

# --- Destructive git operations (per ~/.config/agents/AGENTS.md) ---
elif grep -qE 'git[[:space:]]+push[^|;&]*[[:space:]](--force([^-]|$)|--force-with-lease|-f\b)' <<<"$cmd"; then
  reason="Forced push (git push --force/-f) is blocked."
elif grep -qE 'git[[:space:]]+reset[^|;&]*--hard' <<<"$cmd"; then
  reason="Destructive reset (git reset --hard) is blocked."
elif grep -qE 'git[[:space:]]+checkout[[:space:]]+\.([[:space:]]|$)' <<<"$cmd"; then
  reason="Discarding working tree changes (git checkout .) is blocked."
elif grep -qE 'git[[:space:]]+clean[^|;&]*[[:space:]](-[a-zA-Z]*f|--force)' <<<"$cmd"; then
  reason="Deleting untracked files (git clean -f) is blocked."
elif grep -qE 'git[[:space:]]+stash\b' <<<"$cmd"; then
  reason="git stash is blocked per policy."
elif grep -qE 'git[[:space:]]+commit[^|;&]*--no-verify' <<<"$cmd"; then
  reason="Bypassing commit hooks (--no-verify) is blocked."
elif grep -qE 'git[[:space:]]+reflog\s+expire' <<<"$cmd"; then
  reason="Expiring reflog (removes recovery history) is blocked."
elif grep -qE 'git[[:space:]]+gc\b[^|;&]*--prune' <<<"$cmd"; then
  reason="Pruning unreachable objects (git gc --prune) is blocked."
fi

if [ -n "$reason" ]; then
  jq -n --arg reason "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ($reason + " This is a hard-block floor that applies even in bypassPermissions mode.")}}'
  exit 2
fi

exit 0
