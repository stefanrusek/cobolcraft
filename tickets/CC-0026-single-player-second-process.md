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
- Merged 002-lane-spproc into 004-perf-frame (one conflict, client/src/sp-host.cob). Adapted to main: the stop command is
  no command of a hosted world, so `@stop-requested` is removed and acc_spproc_control SPC-6 expects the world to run on;
  the pause screens of main (book, command block, form) pause the child too.
- Gates on 004-perf-frame (debug, JOBS=6, FPFAST=1): the lane's tests pass (83 cases). `make gate`, first run: 143242
  passed, 41 failed, the real jar and Faithful zip missing from the worktree (tmp/). Second run with tmp/ linked: 143439
  passed, 1 failed, acc_f2us2_world_type (in-process host; the crash of CC-0048, `DM-MIN-Y` subscript 0 in the mob tick),
  which passes 3 of 3 alone in the plain debug build and 1 of 4 in the instrumented one. Coverage: 0 uncovered lines of
  1105 objects; lint and the tools tests pass.
- bench_spproc_frame (debug build, village, view 4, 300 frames), client CPU per frame in microseconds: in process mean
  14922, median 14025, p99 20442; child process mean 5726, median 5348, p99 6690.

## Measurements 2026-11-26: both modes side by side (FR-002)

- Build: release (`make build RELEASE=1 JOBS=6`), commit b47e077d, branch 004-perf-frame. Machine: Mac mini, Apple M4 Pro, 48 GB,
  macOS 26.5, window on a 60 Hz display. The machine was not idle: load average before the runs 5.2 to 7.3 (statistics runs) and 8.3 to
  10.0 (quit runs); other programs of the desktop were using processor time.
- Server program in process mode: `build/release/bin/cobolcraft-server --hosted`, seen in `ps` as the client's child
  (`CC_SERVER_BIN` unset: the directory of the running executable, `cc_wk_self_dir`).
- Method: the standard world of `gatefast-logs/perfround/ka-server-saves` copied into a fresh game directory for every run, opened
  with `--world world`, no camera option (the spawn view; the settled screenshots of both modes show the same view), view distance of the
  defaults, `CC_GPU_STATS=1`, every output line stamped with the time. Three runs per mode and present mode, modes alternating, 200 s
  each, then the window's close button pressed through System Events. Times count from the start of the client process. The first world
  frame is bracketed by two statistics lines one second apart (the last with one draw a frame and the first with more); a finer value
  needs a line printed at the first world frame, which does not exist. "Settled" starts after the last second with more than 9 mesh
  uploads a frame (7 a frame is the floor). Values are the three runs in order. Scripts and logs: `gatefast-logs/perfround/t2/`
  (`run.sh`, `an.py`, `tab.py`).

| | in process, vsync | child process, vsync | in process, immediate | child process, immediate |
|---|---|---|---|---|
| first statistics line (first second of frames ends), s | 7.08 / 7.56 / 7.45 | 4.99 / 5.02 / 4.96 | 7.46 / 7.42 / 7.59 | 4.94 / 5.04 / 5.03 |
| console line "Perf joined", s | 19.71 / 20.00 / 19.82 | 21.28 / 21.46 / 20.75 | 19.95 / 19.16 / 20.11 | 20.58 / 21.02 / 21.27 |
| first world frame between, s | 19.18-20.48 / 19.77-20.82 / 19.61-20.73 | 21.28-22.29 / 21.46-22.46 / 20.75-21.76 | 19.51-20.64 / 19.63-20.65 / 19.66-20.82 | 20.58-21.59 / 21.13-22.15 / 21.27-22.28 |
| fps of the three seconds around the join, slowest | 12.3 / 4.8 / 5.4 | 12.3 / 19.5 / 29.2 | 15.0 / 24.4 / 14.7 | 49.4 / 14.0 / 20.4 |
| load-in, first world frame to settled, s | 114.9 / 117.5 / 113.6 | 115.1 / 112.1 / 113.3 | 106.4 / 109.7 / 107.3 | 101.7 / 104.8 / 104.9 |
| load-in fps after the join, minimum | 30.6 / 27.3 / 30.0 | 52.9 / 49.5 / 51.3 | 27.9 / 37.9 / 28.4 | 57.8 / 60.4 / 60.7 |
| load-in fps after the join, median | 54.0 / 54.1 / 54.0 | 59.9 / 60.0 / 60.0 | 68.7 / 74.6 / 75.7 | 98.6 / 94.6 / 97.7 |
| load-in seconds below 50 fps | 28 / 25 / 33 | 0 / 1 / 0 | 7 / 6 / 5 | 0 / 0 / 0 |
| load-in client ms a frame (app), median | 13.83 / 13.42 / 14.53 | 10.27 / 10.12 / 9.99 | 13.76 / 12.33 / 12.11 | 8.88 / 9.60 / 9.03 |
| load-in phases, median ms a frame: coretick | 3.33 / 3.33 / 3.95 | none | 3.20 / 2.67 / 2.29 | none |
| load-in phases: world / rlist / net | 6.46 2.41 0.51 / 6.49 2.17 0.50 / 6.51 2.65 0.52 | 6.41 2.45 0.48 / 6.38 2.20 0.49 / 6.40 2.14 0.47 | 6.45 2.63 0.47 / 6.33 2.29 0.38 / 6.34 2.45 0.40 | 6.07 1.91 0.29 / 6.10 2.45 0.31 / 6.10 2.01 0.30 |
| settled fps, minimum | 59.0 / 59.0 / 58.0 | 58.9 / 59.0 / 58.9 | 99.1 / 104.6 / 103.7 | 108.2 / 107.5 / 109.8 |
| settled fps, median | 60.0 / 60.0 / 60.0 | 60.0 / 60.0 / 60.0 | 119.5 / 119.5 / 119.0 | 119.5 / 119.7 / 119.5 |
| settled client ms a frame (app), median | 5.46 / 4.77 / 5.75 | 3.93 / 3.44 / 3.76 | 4.67 / 4.00 / 3.87 | 3.11 / 3.43 / 3.17 |
| settled phases, median ms a frame: coretick | 1.62 / 1.42 / 2.00 | none | 1.06 / 0.77 / 0.65 | none |
| settled phases: rlist / submit / ui / world | 2.53 0.53 0.17 0.15 / 2.25 0.50 0.17 0.15 / 2.62 0.52 0.17 0.15 | 2.73 0.54 0.17 0.15 / 2.29 0.51 0.17 0.16 / 2.52 0.52 0.17 0.16 | 2.71 0.34 0.16 0.13 / 2.41 0.33 0.16 0.13 / 2.40 0.34 0.16 0.13 | 2.29 0.33 0.17 0.13 / 2.57 0.35 0.16 0.13 / 2.32 0.33 0.17 0.13 |
| settled GPU ms a frame, median | 5.34 / 5.01 / 4.77 | 5.94 / 5.03 / 4.67 | 3.30 / 3.44 / 3.48 | 3.46 / 3.39 / 3.56 |
| resident memory settled, MB: client | 1652 / 1667 / 1658 | 1446 / 1439 / 1450 | 1637 / 1632 / 1636 | 1416 / 1417 / 1416 |
| resident memory: server child | none | 239 / 239 / 238 | none | 235 / 240 / 236 |
| resident memory: 4 generation workers | 191 / 185 / 186 | 179 / 179 / 184 | 191 / 188 / 186 | 180 / 178 / 186 |
| resident memory: all processes | 1843 / 1853 / 1844 | 1863 / 1857 / 1871 | 1828 / 1820 / 1822 | 1832 / 1834 / 1838 |
| CPU settled (`top`, 1 s sample), %: client | 24.2 / 22.9 / 24.9 | 18.5 / 17.4 / 18.4 | 40.8 / 36.5 / 35.8 | 31.4 / 32.8 / 32.2 |
| CPU settled: server child (workers 0.0 in every run) | none | 5.2 / 5.9 / 6.6 | none | 6.3 / 6.1 / 4.5 |
| close button pressed to all processes gone, ms | 2228 / 2171 / 2076 | 2068 / 2062 / 2064 | 2144 / 2241 / 2133 | 2066 / 2065 / 2034 |

- Quit, exact (vsync, `--screenshot-after-frames 8400 --screenshot-then-exit`, the same `CL-QUIT` path as the close button; from the
  "screenshot: Saved" line to the client, the child and the workers gone): in process 2052 / 2046 / 2056 ms, child process 2068 / 2046 /
  2031 ms. Frame 8400 was reached 160.4 / 158.6 / 160.1 s after the start in process and 145.8 / 146.2 / 146.1 s with the child process.
- Quit while the world still loads (one run each, the same option at an early frame; time of the screenshot after the start, then quit
  to all gone): frame 2: in process 6.9 s, 66 ms; child process 4.0 s, 1990 ms. Frame 30: 6.7 s, 55 ms; 4.4 s, 1618 ms. Frame 200:
  9.7 s, 47 ms; 7.5 s, 54 ms. Frame 600: 16.6 s, 108 ms; 14.1 s, 54 ms.
- Screens: both modes show the same "Loading terrain..." screen with the bar and the grid from their first frame and the same world
  view once settled. At frame 2 the bar is at about 6 % in process and empty with the child process (frame 2 comes 2.9 s sooner there);
  at frame 200 and 600 the bar is further along in process (the frames come later).
- Terminal: both modes print "language: 2 lang files, no problem" and "Perf joined". Only the child process mode prints 30 lines
  `ERROR registry: minecraft:<registry>: an entry does not decode, or has no Data` at the join (6.6 s after the start) and, at quit,
  "Stopping: saving world and disconnecting players", "Perf left" and "Stopped". In process prints none of these when the window
  closes.
- The 30 registry lines: `REGISTRY-PACKET-BUILD` (core/src/registries.cob) sends a standard world's entries with Data present, and
  writes network NBT only for `minecraft:worldgen/biome` and `minecraft:dimension_type`; the Data of the other 30 synchronised
  registries is the JSON text of the vanilla-data pack. A raw client with an empty Select Known Packs reply against the release
  dedicated server on the same world received the same bytes (`t2/regprobe.py`, `t2/ded/probe.txt`: 30 registries whose first entry
  starts with `{` or `[`). The client's content set (`CONTENT-CLIENT-REGISTRY-ADD`, called by `WT16-ADD` on a network game connection
  only) rejects each such packet and prints the line; a memory connection never calls it, which is why in process is silent. No client
  program reads those 30 registries from the content set. `REGISTRY-READ` (the client's own reader, both modes) reads
  `minecraft:painting_variant` as NBT from the same packet, so by the code it gets no painting sizes from a standard world in either mode (read in the code, not observed in a run). No code
  was changed for this.
