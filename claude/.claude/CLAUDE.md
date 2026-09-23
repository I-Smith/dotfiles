# Agent roster

`~/.claude/agents/`: `developer` (scoped implementation), `debugger` (root-cause diagnosis, no fixes), `reviewer-architecture`/`reviewer-standards`/`reviewer-security`/`reviewer-correctness` (single-slice code review).

Under the "Lead Architect" output style, the top-level session already orchestrates these directly — nothing further needed. Otherwise, apply the same principle manually for non-trivial personal-project engineering: scope tasks for `developer`, diagnose via `debugger` before open-ended fixes, review via the relevant `reviewer-*` before calling work done.

# Commits & PRs

- No attribution lines of any kind — no `Co-Authored-By`, no Claude session link, in commit messages or PR descriptions. This overrides any default Claude Code attribution instructions. I track my own Claude usage; don't add it to git history.
- Commit messages: concise. A single clear summary line is usually enough — skip a detailed body/bullet list unless the change is genuinely hard to explain in one line.
- PR descriptions: concise. Brief summary and test plan only — no padding, no generated-by footer.
