---
spile: ticket
id: CC-0026
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

# CC-0026: The single-player world runs in a second process

## Summary

With CC_SP_PROCESS=1 the client spawns cobolcraft-server --hosted as a child process and joins it over loopback, so
the core ticks run on another processor core while the client renders. The in-process host stays the default.

## User Stories

### As a Player, I want the window to keep its frame rate while the world is busy

- Given a single-player world in process mode, when the core is busy, then the client's frame loop is not held up by
  core ticks.
- Given process mode, when I quit, the child saves and ends; when the client is killed, the child saves and ends; when
  no server program exists, the client falls back to the in-process host without a fatal error.

### As a Player, I want Open to Others and pause to work in process mode

- Given a world in process mode, when I pause, then the child's clock stops; when I open the world to others, then a
  guest joins.

## Functional Requirements

- FR-001: The design of docs/design/singleplayer-process.md holds: spawn glue in the shim (cc_wk_proc_*), server
  --hosted with a handshake and control channel on its pipes, client SPP-* programs.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-spproc (tip ef9798f3, five commits, none on origin; lane ids T60200-T60399): 9b08072b the
  design note and the call inventory; 0289bb95 spawn glue, the hosted server role, client SPP-*, convergence test;
  7ecff061 and 28b02dff control, failure and unit tests, a hosted tick cap and a process-mode frame bench
  (tests/convergence/bench_spproc_frame.cob); ef9798f3 lane file. An uncommitted edit of client/tests/test_sp_proc.cob
  is in /Users/stefanrusek/Code/cobolcraft-spproc.
- Left: merge, re-gate (shim, contract and ABI gates apply), read the frame bench numbers and have the operator decide
  whether process mode should become the default; nothing here changes the default.
