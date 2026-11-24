---
spile: ticket
id: CC-0027
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0002]
  supersedes: []
implementation: []
---

# CC-0027: A jigsaw structure start is not assembled again after an unrelated start

## Summary

The trial chambers start (about 3.4 to 3.7 seconds to assemble in one generation worker) is assembled again after an
unrelated jigsaw start, because the jigsaw reset empties the element table that the start memo points into. The memo
keeps its meaning across such resets, so a worker pays the assembly once per start, not once per unrelated start.

## User Stories

### As a Player, I want world generation to avoid multi-second repeats

- Given a world that generates a trial chambers start and then an unrelated jigsaw start (a pillager outpost), when
  the trial chambers start is needed again, then its assembly is taken from the memo, not assembled again.

## Functional Requirements

- FR-001: The memo identifies a piece's element by element identity instead of its table row, or the reset happens
  only near capacity with headroom for the largest assembly (129 templates), so JIG-RESET no longer invalidates memo
  entries that are still valid.
- FR-002: The assembled result stays byte-equal to the one of the current code for every start.

## State at the end of the polish run (2026-11-23)

- Measured and characterised, not fixed (lane p45j, wrap agent I1, commit bc7fe18c;
  core/tests/test_struct_jigreset.cob, 8 cases, seed 3): after the trial chambers start of chunk (-135,-60) the
  template cache holds 129 rows (limit 100) and JIG-GEN goes from 1 to 2 on one unrelated jigsaw start; the first
  assembly took 3660 ms, the memo 0 ms, and the assembly after the unrelated start 3430 ms. A memo piece keeps its
  element row (MP-EL = SP-F1) and JIG-RESET empties the element table, so the wipe is required today.
- Evidence: scratchpad/handoffs/wrapI1-r5.md (the 12-slot jigsaw memo, the start list cache and the template state
  memo were already in the code, commit 0b773a90) and wrapI1-r6.md; the p45j line "trial_chambers cost". The fix is
  not local to one program.
