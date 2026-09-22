#!/bin/bash
# check-undefined-functions.sh - catch calls to shell functions that are never
# defined. bash -n and shellcheck both miss these (they are only runtime
# "command not found" errors), which is how a build can pass every static
# check and still die mid-stage.
#
# Method: let bash itself parse the script and report the function names it
# defines, then find every snake_case word used in COMMAND position (start of
# a simple command) that is neither a defined function, a shell keyword/builtin,
# nor an executable on a normal PATH. Words inside heredocs, comments, quotes
# and assignments are excluded by construction.
#
#   ./scripts/check-undefined-functions.sh build.sh [more scripts...]
set -uo pipefail
rc=0
for script in "$@"; do
    # 1. functions bash actually parses out of the file (no execution)
    # (sourcing the script to use `declare -F` would execute it, so read the
    #  definitions from the text; the pattern matches how our scripts define them)
    defined=$(grep -oE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{' "$script" \
              | sed -E 's/[[:space:]]*\(\).*//; s/^[[:space:]]*//' | sort -u)

    # 2. strip comments, heredoc bodies and quoted strings, then take the first
    #    word of every simple command
    stripped=$(python3 - "$script" <<'PY'
import re,sys
src=open(sys.argv[1]).read()
# join backslash-continued lines so a multi-line argument list (e.g. a
# grub-mkimage module list) is one command, not many "commands"
src=re.sub(r'\\\n[ \t]*', ' ', src)
out=[]; i=0; lines=src.split('\n'); skip_until=None
for ln in lines:
    if skip_until is not None:
        if ln.strip()==skip_until: skip_until=None
        continue
    m=re.search(r"<<-?\s*['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?", ln)
    if m: skip_until=m.group(1); out.append(ln[:m.start()]); continue
    ln=re.sub(r"'[^']*'", "''", ln)
    ln=re.sub(r'"(?:\\.|[^"\\])*"', '""', ln)
    ln=re.sub(r'#.*$', '', ln)
    out.append(ln)
print('\n'.join(out))
PY
)
    # split into simple commands on ; && || | newline ( ) { } and take word 1
    called=$(printf '%s\n' "$stripped" \
        | sed -E 's/\|\||&&|;|\(|\)|\{|\}|\|/\n/g' \
        | sed -E 's/^[[:space:]]*(if|then|elif|else|do|while|until|!|time|exec|command|sudo|env)[[:space:]]+//; s/^[[:space:]]*//' \
        | awk '{print $1}' \
        | grep -E '^[a-z_][a-z0-9_]*$' | grep '_' | sort -u)

    for w in $called; do
        # defined function?  shell builtin/keyword?  external executable?
        if printf '%s\n' "$defined" | grep -qx "$w"; then continue; fi
        case "$w" in local|export|readonly|declare|typeset|unset|shift|return|exit|read|source|trap|eval|set|mapfile|readarray) continue;; esac
        if command -v "$w" >/dev/null 2>&1; then continue; fi
        # a bare word that is an assignment target elsewhere (VAR=...) is a variable, not a call
        if grep -qE "(^|[[:space:]])${w}=" "$script"; then continue; fi
        printf '  UNDEFINED function called in %s: %s\n' "$script" "$w"
        rc=1
    done
done
[ "$rc" -eq 0 ] && echo "no undefined function calls"
exit $rc
