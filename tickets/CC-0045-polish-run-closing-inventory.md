---
spile: ticket
id: CC-0045
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

# CC-0045: The open task lines of the polish run are decided: build, cut or keep as tickets

## Summary

At the end of the second SDD run, 257 task lines of specs/002-client-polish stay open. This ticket holds the
classification of what they are, so the operator can decide to cut or to build, and so that the run's terminal gate is
not mistaken for completion of every line.

## User Stories

### As a Contributor, I want to know what the polish run left undone

- Given the task files of the feature, when I list the open lines, then each is either named by a ticket (CC-0010 to
  CC-0044, CC-0046), listed below as cut or procedural, or waiting for an operator decision.

## Functional Requirements

- FR-001: Open task lines are not deleted by this ticket; the operator decides which are cut.
- FR-002: The terminal gate (T3614: make gate with its real output) is recorded on its own task line.

## State at the end of the polish run (2026-11-23)

- Count at origin 804aa12f after T3612 and T3613 were ticked (python3 tools/tasks.py status specs/002-client-polish
  --open): 257 open task lines. Earlier the same day, when the count was 261: 95 in tasks/core, 12 in tasks/client,
  134 in tasks/lanes, 3 in tasks/server, 4 in tasks/shared and 13 in the top-level phase files.
- Classification of the 253 lane lines that were open on 2026-11-19 (scratchpad/wrap-lane-analysis.md, git-only
  evidence): 84 open, 53 cut, 55 done, 37 superseded, 24 procedural; many of the open ones have since been built or
  ticked. The 53 CUT lines are lighting and sky items outside this run (FR-043), sounds, cosmetic leftovers and rare
  edge cases, each with a reason in that file.
- Decisions waiting for the operator (from the 2026-11-19 audit, scratchpad/wrap-audit.md): cut or implement the 53
  CUT lane lines, and the 116 phase lines with no acceptance case anywhere (about 58 doc sections, mostly the mob docs
  of phases 49d to 49j, structures 45c, 45d and 45g and the Nether 46a and 46b), which are per-section templates whose
  features shipped under lane tasks.
- Lines that are procedural (gate runs, review greps, coverage lists, doc-erratum notes) belong to the terminal gate
  (T3614) and to the integrator.
- Lanes with unmerged saved work are recorded in CC-0017 to CC-0026.
