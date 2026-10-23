---
name: codebase-review
description: Whole-codebase audit to bring a project back on track — simplification, organization, bugs, clean code, requirements, security, tests, idioms. Fans out reviewer-* subagents, verifies findings, writes a prioritized report and remediation plan. Review-only.
disable-model-invocation: true
argument-hint: "[path] [--requirements <file|url>] [--focus <dims>]"
---

Audit the whole project (not a diff) at `$ARGUMENTS` (default cwd). **Review-only**: write nothing but the report; no commits.

Args: `path`; `--requirements <file|url>` (repeatable); `--focus` subset of `architecture,simplicity,standards,correctness,security,testing,requirements` (default all).

**Token budget.** Prefer `git ls-files`, `wc -l`, `grep`/`rg` and targeted line ranges over whole-file reads. Cap tool output (`| head`, `| tail`, quiet/summary flags). Never re-read code a reviewer already covered except to verify a finding.

## 1. Map
Small repo: map it yourself. Large repo (>~100 source files): delegate to one `Explore` agent and ask for a ≤40-line summary. Capture: stack and versions, layout and what each module owns, entry points, linter/formatter/type/test config, CLAUDE.md/CONTRIBUTING, key conventions (errors, naming, layering, async) and where they're inconsistent. Exclude vendored/generated/build/dependency dirs.

Baseline: if cheap, run the existing linter, type-checker and tests with summarized output. Failures are findings.

## 2. Requirements
Use `--requirements`, else check README, `docs/`, specs, ADRs. If none, skip that dimension and note it — don't ask.

## 3. Partition
Slice by module, ~3–5k LOC each, coupled files together. Small repo = one slice. If slices × dimensions exceeds ~20 agents, merge slices or cover the highest-risk ones (core logic, entry points, data handling) and record what was skipped.

## 4. Fan out
One parallel batch:

| Dimension | Agent | Scope |
|---|---|---|
| architecture | `reviewer-architecture` | once, whole repo |
| simplicity, correctness, security | `reviewer-<dim>` | per slice |
| standards | `reviewer-standards`, `model: sonnet` | per slice |
| testing | `reviewer-testing` | per slice; skip if no tests exist and record "no test suite" as a finding |
| requirements | `reviewer-requirements` | once, if requirements exist |

Each prompt (keep it short; pass the map summary, not file contents):
- Whole-codebase mode: review the listed paths, not a diff; grep the wider repo when needed (callers, duplicates).
- Slice paths, map summary, conventions, relevant baseline output (don't re-report linter findings).
- Conventions are evidence, not law: a convention that makes code harder to read, change or get right is itself a finding (better pattern + migration note). Two patterns for one thing is a finding; say which to keep.
- Output: at most 15 findings, most severe first, one line each: `severity(C/H/M/L) | file:line | issue | fix | effort(S/M/L)`. Collapse repeats into one line with a count and example locations. No preamble or summary. No findings is fine.

## 5. Verify
Merge duplicates across agents. For each Critical/High, read only the cited lines (± context) and drop or downgrade anything the code doesn't support. Group repeats into themes; drop linter-covered churn and preferences.

## 6. Report
Write `.claude/reviews/codebase-review-<YYYY-MM-DD>.md` under the root, tersely:
1. Health summary (≤5 sentences)
2. Baseline results
3. Top themes: pattern, representative locations, target pattern
4. Findings table by severity, then dimension
5. Requirements coverage table (if run)
6. Remediation plan: ordered batches from quick wins to structural; scope, findings, effort, dependencies. Test fixes come before risky refactors.
7. Skipped slices/dimensions

In chat: 2–3 sentence summary, top themes, counts by severity, report path.
