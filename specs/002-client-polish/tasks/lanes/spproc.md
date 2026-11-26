## Lane 002-lane-spproc (T60200-T60399): single-player core in a child process

Design: docs/design/singleplayer-process.md. Mode switch: CC_SP_PROCESS=1 (SP-PROCESS-PREF); in-process stays the default, the test path and the fallback.

### Stage A: study

- [X] T60200 [spproc] List every core call the client makes with a verdict (replaced by protocol, control channel, in-process only): the inventory table of docs/design/singleplayer-process.md
- [X] T60201 [spproc] Design note docs/design/singleplayer-process.md (spawn, handshake, control channel, pause, quit, crash, open to others, loading, cost)

### Stage B: spawn, handshake, join over loopback, quit and save, parent death

- [X] T60210 [spproc] shim: cc_net_listen_loopback and cc_wk_proc_* (spawn with pipes, write, read, wait, stop, self_dir) with shim/tests/test_cc_wk_proc.c (43 cases), contract/include/ccshim.h
- [X] T60211 [spproc] server: `cobolcraft-server --hosted` (server/src/hosted.cob; SV-SLOTS-INIT, SV-HOSTED-START with the handshake, @ready/@refused, loopback listener, end of input = stop, console lines without time stamp, SV-STOP with host_closed)
- [X] T60212 [spproc] client: client/src/sp-proc.cob (SPP-FIND, SPP-START, SPP-PUMP, SPP-STOP, SPP-LINE/READ, SPP-LOST), hooks in SP-OPEN, SP-PUMP, SP-STOP, SP-DEFAULTS (CC_SP_PROCESS), fallback to the in-process host when no server program
- [X] T60213 [spproc] tests/convergence/acc_spproc_process.cob: spawn, loopback join, walk, place a block, quit (child saved and gone), reopen (block there), killed client (child saves and ends), fallback (9 cases)

### Stage C: pause control, open to others, failures

- [X] T60220 [spproc] pause by @pause/@resume (explicit messages, no signals); the child holds its clock; tests/convergence/acc_spproc_control.cob (game time standing still while paused, running on after resume without catching up)
- [X] T60221 [spproc] open to others in process mode: @open moves the child's listener to every interface (@opened <port>), a second client joins as a guest in the chosen mode, the pause no longer holds; the stop command goes through @stop-requested and the client's quit path
- [X] T60222 [spproc] failures: child killed (disconnect screen, reaped), child dying at start, refused world (@refused returns to the screen the world was opened from), packs refusal, lost connection, hosted program without handshake, loading progress (@load) of a new standard world: tests/convergence/acc_spproc_failure.cob
- [X] T60223 [spproc] the child paces its ticks as the in-process host does (3 an iteration, a debt over 250 ms dropped), so a slow tick never keeps it from its input: server/tests/test_sv_hosted_control.cob
- [X] T60224 [spproc] client/tests/test_sp_proc.cob: @load decode, @opened, @stop-requested, partial lines, pause rules, CC_SERVER_BIN
- [X] T60225 [spproc] merged onto 004-perf-frame (CC-0026): the stop command is no command of a hosted world (57-client-closures-4 section 3.4), so @stop-requested, SV-HOSTED-ASK and SP-STOP-ASKED are removed as the run state 1 branch of SP-PUMP was; acc_spproc_control SPC-6 expects the world to run on after /stop and to end through the quit-world control; SP-PAUSE-UPDATE pauses on the book, command block and form screens as SP-PUMP did on main

### Stage D: measurements

- [X] T60230 [spproc] tests/convergence/bench_spproc_frame.cob: client frame CPU in a village, in-process against child process (numbers in the report)

### Call inventory (T60200)

See the table "Inventory of what the client calls in the core" in docs/design/singleplayer-process.md.
