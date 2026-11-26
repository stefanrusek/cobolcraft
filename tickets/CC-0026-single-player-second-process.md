---
spile: ticket
id: CC-0026
type: feature
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0002]
  supersedes: []
implementation:
  branch: 004-perf-frame
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

### As a Player, I want single-player to feel the same whichever way the world is hosted

- Given the same world opened once in the in-process host and once in process mode, when I create or open it, play,
  pause, open it to others, save and quit, then I notice no difference: the same screens in the same order, no extra
  window, terminal line or system prompt, the same world content and saved files, and no added wait or input delay that
  I can notice.

## Functional Requirements

- FR-001: The design of docs/design/singleplayer-process.md holds: spawn glue in the shim (cc_wk_proc_*), server
  --hosted with a handshake and control channel on its pipes, client SPP-* programs.

- FR-002 (operator, 2026-11-26): process mode is no noticeable change for the Player. Checked by the same acceptance
  scenarios run in both modes with the same expected results, by measured numbers set side by side for both modes (time
  from choosing the world to the first world frame, frame statistics while chunks load and once settled, time to quit),
  and by the operator playing it. A difference that a Player can notice is a defect of this ticket.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-spproc (tip ef9798f3, five commits, none on origin; lane ids T60200-T60399): 9b08072b the
  design note and the call inventory; 0289bb95 spawn glue, the hosted server role, client SPP-*, convergence test;
  7ecff061 and 28b02dff control, failure and unit tests, a hosted tick cap and a process-mode frame bench
  (tests/convergence/bench_spproc_frame.cob); ef9798f3 lane file. An uncommitted edit of client/tests/test_sp_proc.cob
  is in /Users/stefanrusek/Code/cobolcraft-spproc.
- Left: merge, re-gate (shim, contract and ABI gates apply), read the frame bench numbers and have the operator decide
  whether process mode should become the default; nothing here changes the default.

## 2026-11-26

- Taken up on the operator's word while measuring CC-0054: the core tick is 2.9 to 5.3 ms of the client's frame on an M1
  Air once settled and 6.4 to 12.8 ms while chunks load (CC-0054 notes). Branch 002-lane-spproc is merged into
  004-perf-frame for this; the default stays the in-process host until the operator decides.
