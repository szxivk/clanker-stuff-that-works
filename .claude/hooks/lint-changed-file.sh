#!/usr/bin/env bash
# PostToolUse hook (Edit|Write matcher): lints/analyzes the file just edited,
# scoped to this repo's actual lint setup (mirrors
# .pi/extensions/changed-file-checks/index.ts's WEB_SOURCE/BACKEND_SOURCE mapping):
#   - apps/{web-vendor,web-admin}/{app,server}/**/*.{vue,js,ts,jsx,tsx,cjs,mjs,cts,mts} -> eslint
#   - apps/backend/{app,routes,config,database,tests}/**/*.php                       -> pint --test + phpstan analyse
#
# PostToolUse can't block an edit that already happened; instead we exit 2 so
# Claude Code adds our stderr to the transcript as a warning Claude sees and
# can act on (fix the file) in its next turn. Exit 0 (silent) when clean or
# when the file isn't in a checked path - do not add checks for other apps
# without first inspecting their own lint/type-check setup.
set -uo pipefail

input="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$input")"
file="$(jq -r '.tool_input.file_path // empty' <<<"$input")"

[[ "$tool" == "Edit" || "$tool" == "Write" ]] || exit 0
[ -n "$file" ] || exit 0

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
rel="${file#"$root"/}"
[ -f "$file" ] || exit 0

failures=""

if [[ "$rel" =~ ^apps/(web-vendor|web-admin)/(app|server)/.*\.(vue|[cm]?[jt]sx?)$ ]]; then
  app_dir="${BASH_REMATCH[1]}"
  web_rel="${rel#apps/"$app_dir"/}"
  out="$(cd "$root/apps/$app_dir" && bun x eslint "$web_rel" 2>&1)"
  if [ $? -ne 0 ]; then
    failures+=$'\n'"ESLint failed for $rel:"$'\n'"$(tail -c 6000 <<<"$out")"
  fi

elif echo "$rel" | grep -qE '^apps/backend/(app|routes|config|database|tests)/.*\.php$'; then
  backend_rel="${rel#apps/backend/}"
  out="$(cd "$root/apps/backend" && ./vendor/bin/pint --test "$backend_rel" 2>&1)"
  if [ $? -ne 0 ]; then
    failures+=$'\n'"Pint failed for $rel:"$'\n'"$(tail -c 6000 <<<"$out")"
  fi
  out="$(cd "$root/apps/backend" && ./vendor/bin/phpstan analyse --memory-limit=2G "$backend_rel" 2>&1)"
  if [ $? -ne 0 ]; then
    failures+=$'\n'"PHPStan failed for $rel:"$'\n'"$(tail -c 6000 <<<"$out")"
  fi
fi

[ -n "$failures" ] || exit 0

echo "Changed-file checks failed.${failures}"$'\n'"Repair only this file, then re-run its edit. Changed-file checks must pass before continuing." >&2
exit 2
