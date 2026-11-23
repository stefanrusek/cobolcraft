---
spile: ticket
id: CC-0020
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0020: Continuous integration builds and tests the packages that need no client jar

## Summary

A GitHub Actions workflow builds and tests the packages that do not need jar-derived data. The repository is public,
so nothing derived from the vanilla jar can run on CI.

## User Stories

### As a Contributor, I want a pull request to be checked automatically

- Given a pull request, when it is opened or updated, then CI builds and runs the lint and tests of the jar-free
  packages and shows the result on the pull request.

## Functional Requirements

- FR-001: The workflow lives in .github/workflows/ci.yml and runs only packages and tests that need no jar-derived
  data and no game window.
- FR-002: The tests and their results use the same commands as the local gates (make gate-<pkg>).

## State at the end of the polish run (2026-11-23)

- Lane ciworkflow: no commits. The worktree /Users/stefanrusek/Code/cobolcraft-ciworkflow holds untracked .github/ and
  ci-logs/ from the stopped lane (not reviewed by this ticket). The operator said yes to the lane. Left: everything;
  start from those files after reading them.
