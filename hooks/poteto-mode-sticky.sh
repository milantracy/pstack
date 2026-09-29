#!/usr/bin/env bash
# Cursor's `mode: true` skills stay on across turns. Claude Code has no such
# flag, so track on/off per session and re-inject the mode reminder each prompt.
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
session=$(jq -r '.session_id // empty' <<<"$input")
prompt=$(jq -r '.prompt // empty' <<<"$input")
[ -n "$session" ] || exit 0

root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
state_dir="${PSTACK_STATE_DIR:-$HOME/.claude/pstack/state}"
flag="$state_dir/poteto-mode-${session//[^A-Za-z0-9_-]/_}"
mkdir -p "$state_dir"

invocation='^[[:space:]]*/(pstack:)?poteto-mode([[:space:]]|$)'
off_arg='^[[:space:]]*/(pstack:)?poteto-mode[[:space:]]+(off|stop|exit|disable)[[:space:]]*$'
off_words='(^|[^[:alnum:]])(exit|stop|disable|turn off|leave|quit|drop|no more)[^[:alnum:]].{0,12}poteto[- ]?mode|poteto[- ]?mode[^[:alnum:]]{1,6}off([^[:alnum:]]|$)'

if [[ "$prompt" =~ $off_arg ]]; then
	rm -f "$flag"
	exit 0
fi

if [[ "$prompt" =~ $invocation ]]; then
	touch "$flag"
	exit 0
fi

if [ -f "$flag" ] && grep -qiE "$off_words" <<<"$prompt" && ! grep -qiE "(don'?t|do not|never)[[:space:]]+(exit|stop|disable|turn off|leave|quit|drop)" <<<"$prompt"; then
	rm -f "$flag"
	echo "poteto-mode is now OFF for this session. Stop applying it."
	exit 0
fi

[ -f "$flag" ] || exit 0

cat <<MSG
poteto-mode is active for this session (pstack skills: $root/skills).
New task? Playbook match or rigor needed -> apply /poteto-mode: re-read $root/skills/poteto-mode/SKILL.md if it is no longer in context, and follow it. Casual turn or user opts out -> don't. The user can turn it off with "/poteto-mode off".
MSG
