#!/usr/bin/env bash
# Removes the "autoMode" block from the *staged* claude/.claude/settings.json so it
# never lands in a commit. The working-tree file is left alone, so the block stays
# in place locally (nothing to restore, even if the commit later aborts).
set -euo pipefail

FILE="claude/.claude/settings.json"

git cat-file -e ":$FILE" 2>/dev/null || exit 0
git show ":$FILE" | grep -q '"autoMode"' || exit 0

stripped=$(git show ":$FILE" | python3 -c '
import json, sys
s = json.load(sys.stdin)
s.pop("autoMode", None)
sys.stdout.write(json.dumps(s, indent=2, ensure_ascii=False) + "\n")
' | git hash-object -w --stdin)

mode=$(git ls-files -s -- "$FILE" | cut -d" " -f1)
git update-index --cacheinfo "$mode,$stripped,$FILE"
echo "pre-commit: stripped autoMode from staged $FILE (still present in your working tree)"
