---
spile: ticket
id: CC-0033
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

# CC-0033: A depth-only pipeline gives the boat water patch and the painting back depth bias

## Summary

The shim offers a depth-only draw (writes depth, no colour) and a depth-biased pass, so a boat keeps water out of its
hull (the water patch of docs/protocol 34-8 section 7.4 step 7) and a painting's back sprite is drawn with the depth
bias of entitySolidZOffsetForward.

## User Stories

### As a Player, I want boats to be dry inside and paintings to draw cleanly

- Given a boat in water, when I look into it, then no water is drawn inside the hull.
- Given a painting, when I look at it from the front, then its back sprite does not fight the front face.

## Functional Requirements

- FR-001: A new pipeline id exists in shim/src/cc_vk.c, contract/copy/CCSHIM.cpy and the shim ABI doc, and the shim
  and contract gates pass.
- FR-002: EF8-BOAT-PATCH-DRAWN (library only today) is drawn through it.

## State at the end of the polish run (2026-11-23)

- Not built. T9906 (lanes/models5.md): the boat water patch needs a new pipeline (today CC-PIPE-* are opaque,
  translucent, ui, crumbling, glint and translucent-cull), which cannot be proved without the game window. The
  painting depth bias is recorded on the p70i.md line of T51207 (the painting drawing itself was built).
- Mesh slots in use end at MESH-SLOT-PREVIEW 65023 and the shim maximum is 65535 (wrap agent A, D).
