## Phase bugfps (lane bugfps, play-test bug of try19: "the debug info shows 0 for the fps but the game is SO SMOOTH"; T62300-T62399)

Root cause (client, not core or shim): lane bugsmooth made the frame clock (CL-CLOCK) the Unix epoch in milliseconds (about 1.7e12). DEBUG-OVERLAY-INPUT measured the second into `WS-ELAPSED`, a `BINARY-LONG`; CL-FPS-AT is 0 until the first measurement, so the first elapsed time is the whole epoch clock, which does not fit 32 bits, and the frame rate stayed 0. The game itself ran at 60 fps.

Audit of every user of the clock (CL-NOW-MS, CL-NEXT-TICK, CL-FPS-AT, L-NOW): all stored clock values are BINARY-DOUBLE (CL-NOW-MS, CL-NEXT-TICK, CL-FPS-AT, CL-FPS-FRAMES, CL-SWING-AT, CL-HAND-TICK-MS, SP-NEXT-TICK, CX-PREV-MS, PL-WAIT-START, PL-READY-AT, PL-TAP-MS, PL-HURT-UNTIL, PL-EAT-START, PL-SPACE-MS, CT-BREAK-START, CT-BREAK-LAST, CT-DONE-MS, BDS-AT-MS, EN-SWELL-MS, CH-TIME, RK-TOAST-UNTIL, SM-LOAD-TICK-MS, SM-LOAD-GRID-MS, HB-LAST-TIME, AN-START-MS, WS-TIME of CHAT-SEND, glint WS-T); derived values are either differences of two clock values (small) or FLOAT-LONG (ages /50). The only narrow field was WS-ELAPSED. recipe-book WS-CELL (clock / 1500, BINARY-LONG) holds 1.1e9 now and fits 32 bits until 2072.

- [x] T62300 [bugfps] Red test first: `client/tests/test_fps_clock.cob` (130 frames of 17, 17, 16 ms on an epoch millisecond clock: CL-FPS reads 58 to 61, the last measurement is under a second old, the tick scheduler keeps its 50 ms schedule); failed before: CL-FPS 0
- [x] T62301 [bugfps] `client/src/debug-overlay.cob` DEBUG-OVERLAY-INPUT: WS-ELAPSED is BINARY-DOUBLE
- [x] T62302 [bugfps] Audit of every clock user and its field width (listed above): no other narrow field
