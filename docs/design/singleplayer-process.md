# Single-player world in a second process

Status: operator request (PR #2 lane spproc). The in-process host (`client/src/sp-host.cob`) stays the default; this
mode is chosen with `CC_SP_PROCESS=1` until measurements and the operator say otherwise.

## Why

The core tick, the client tick and the HUD run on one main thread. A thread cannot run COBOL here
(docs/design/generation-worker.md, Evidence), but a process can. The server program (`cobolcraft-server`) is already the
core plus a TCP host, and the client already joins TCP servers and hosts TCP guests. So the single-player core can run
in a child process that the client spawns and joins over loopback, and its ticks then run on another processor core while
the client renders.

## Pieces

### Which binary

`cobolcraft-server` of the same build. Both programs are built into one `bin` directory (`build/<mode>/bin/cobolcraft` and
`cobolcraft-server`; the convergence tests build both into `build/convergence/bin`), so no new target is needed. The
client finds it as: `CC_SERVER_BIN` (explicit path; when set it is the only candidate), else `<directory of the running executable>/cobolcraft-server`, else
`<directory>/../bin/cobolcraft-server` (a test program in `build/convergence/tests`). `cc_wk_self_dir` returns the
executable's directory. When none exists, or the spawn fails, the client prints one `ERROR` line and opens the world in
process as before (fallback, never fatal).

### Spawn glue (shim section 15, in `cc_wk.c`)

`posix_spawn` with an argument vector and pipes cannot be written in COBOL, so a small glue joins the worker section:
`cc_wk_proc_spawn(exe, args, *slot)` starts the program with a pipe on its standard input and one on its standard output
(`POSIX_SPAWN_CLOEXEC_DEFAULT`: nothing else leaks: not the window, the GPU, the sockets). `cc_wk_proc_write` writes to the
child's input, `cc_wk_proc_read` reads its output without blocking (`CC_AGAIN`, or `CC_CLOSED` at end of output),
`cc_wk_proc_wait(slot, timeout_ms)` reaps it (exit status, or still running), `cc_wk_proc_kill` kills and reaps,
`cc_wk_self_dir` gives the executable's directory. The standard error is inherited, so a `FATAL` line of the child shows
on the client's terminal. No game logic.

### The child: `cobolcraft-server --hosted`

`SV-MAIN` looks at the command line: `--hosted` runs the server loop in the single-player role (no conf file, no
`./world`). Everything arrives over the two pipes, so there is nothing to clean up on disk:

1. **Handshake** (parent to child, raw bytes on standard input, read with `read(0)` until complete): the
   `CORE-SETTINGS` record exactly as `SP-OPEN` built it (3829 bytes: game mode, world name, host name `CL-NAME`, host kind 1,
   seed text, world type, game directory, generated directory, rules), the world path as a z-string (1200 bytes) and the
   superflat preset (40 bytes, spaces = none). The child then does what `SP-OPEN` did: `GEN-WORKERS-AUTO` (so the
   generation workers fork from the server process), `FLAT-PRESET-SET`, `CORE-WORLD-OPEN`, `CORE-SAVE` of a created world.
2. **Reply** (child to parent, standard output, one line each): `@ready <port> <created> <pid>` once the world is open and the
   loopback listener (`127.0.0.1`, system-chosen port, a new `cc_net_listen_loopback`) is up; or `@refused <n>` and exit
   status 10 when the core refuses the world (flag minus `CORE-WORLD-OPEN`'s status).
3. **Join**: the client opens a TCP connection to `127.0.0.1:<port>` and logs in as the Player (offline mode: the same
   offline UUID as a memory join, so a world opened in one mode loads in the other). The core sees a network connection
   of host kind 1; host identity there depends on the name (`CS-HOST-NAME`), not on the connection kind.
4. **Loading**: while the spawn search and the spawn area run, the child prints `@load <state> <ready> <total> <permille>
   <fx> <fz> <grid>` at most every 100 ms (the `GEN-LOAD-PROGRESS` values and the 35 x 35 `GEN-LOAD-GRID`, one letter
   `A` plus the cell code per cell) and a final one with state 0. The connecting screen shows the loading screen from
   the first frame, so the child's 2.5 to 2.9 s of content load is no longer a frozen window.
5. **Control channel** (parent to child, lines on standard input, after the handshake; an unknown `@` line is ignored,
   any other line is a console command like the server's console, `CORE-CONSOLE`):

   | line | meaning |
   |---|---|
   | `@pause` / `@resume` | stop / resume the tick loop (the clock is held, so resuming does not catch up), US16-4 |
   | `@open <mode> <operator>` | `CORE-OPEN-TO-OTHERS`; the loopback listener is replaced by one on every interface (port 0); reply `@opened <port>` |
   | `@stop` | `CORE-STOP` with `cobolcraft.disconnect.host_closed`, save, disconnects, exit status 0 |
   | `<command>` | console command with operator permission (the screenshot start-up commands) |

   End of standard input (the client ended or was killed: the OS closes the pipe) is the same as `@stop`: the child saves and
   exits. That is the no-orphan guarantee, the same trick as the generation workers (end of input ends the worker).
6. **Child to parent, other lines**: `@stop-requested` (the `/stop` command ran: run state 1; the child does not stop on its
   own, the client answers with its quit-world path, as the in-process `SP-PUMP` does, so the Disconnect text the player sees
   is the same), every other line is a console line (`CORE-CONSOLE-DRAIN`, printed on the client's terminal without the
   server's time stamp).

The child's loop is the server's (`SV-ITERATE`) with the in-process host's pacing: at most 3 ticks an iteration and a debt of more than 250 ms
dropped, so a slow tick never keeps the program from its input (the control lines and the end of input). Without that a world whose ticks cost more
than 50 ms (a new standard world's spawn area in a debug build) falls behind for good and never sees the client leave.

### The client: `client/src/sp-proc.cob`

`SP-OPEN` checks `SP-PROCESS-PREF` (set from `CC_SP_PROCESS` by `SP-DEFAULTS`; tests set the field). In process mode it
builds the same settings, spawns, writes the handshake and shows the connecting screen (`SP-PROCESS` 1). `SP-PUMP` in this mode
runs `SPP-PUMP` instead of ticking a core: it reads the child's lines (partial lines kept in `SP-LINE-BUF`), on `@ready`
opens `CONN-GAME` with `NET-OPEN` to the loopback port, sends `@pause` or `@resume` when `SP-PAUSED` changes, detects a dead child
(`cc_wk_proc_wait`) and turns it into the disconnect screen (`connecting.lost` text, no orphan: the slot is reaped), and
handles `@stop-requested` with `SP-QUIT`. `SP-STOP` (also the quit-world control and the window closing) sends `@stop`, closes the
game connection, waits for the child (15 s, then kill) so the saved world is on disk before the world list reads it.

## Inventory of what the client calls in the core

Every call of the core's host API (`core-host-api.md` section 2) and of other core programs by `client/src`, and what it
becomes in process mode:

| Call | Where | Verdict in process mode |
|---|---|---|
| `CORE-WORLD-OPEN` | `SP-OPEN` | child, from the handshake |
| `CORE-SAVE` | `SP-OPEN` (created world) | child |
| `CORE-CONN-OPEN`, `-INPUT`, `-OUTPUT`, `-CLOSED` | `NET-OPEN-MEMORY`, `NET-PUMP`, `NET-MEMORY-IN`, `NET-CLOSE` | replaced by protocol: the game connection is a TCP connection (`cc_net_*`), compression per 01 section 3 |
| `CORE-CONN-*` of guests | `GUEST-ACCEPT`, `GUEST-PUMP-IN/OUT`, `GUEST-RELEASE` | replaced by protocol: the child's own TCP host accepts guests |
| `CORE-TICK` | `SP-PUMP` | child's loop; pause by control channel |
| `CORE-CONSOLE` | `STARTUP-COMMANDS` (screenshot runs) | control channel: a console line on the child's input |
| `CORE-CONSOLE-DRAIN` | `SP-CONSOLE` | child prints, the client forwards the lines |
| `CORE-STATUS-GET` | `SP-PUMP` (run state 1 = `/stop`; the online count is not read) | control channel: `@stop-requested`; end of the child's output and its exit status replace state 2 |
| `CORE-STOP` | `SP-STOP`, `SP-QUIT`, window close | control channel: `@stop` |
| `CORE-OPEN-TO-OTHERS` | `SP-OPEN-OTHERS` | control channel: `@open`; listener and port are the child's (`@opened`), addresses stay `cc_net_local_addresses` in the client |
| `CORE-PACKS-STATUS` | `PACKS-STATUS-CHECK` | in-process only: reads the generated directory, no world state |
| `FLAT-PRESET-SET` | `SP-OPEN` | handshake |
| `GEN-WORKERS-AUTO` | `SP-OPEN` | child at start (generation workers fork from the child) |
| `GEN-LOAD-PROGRESS`, `GEN-LOAD-GRID` | `CONNECTING-BUILD` | control channel: `@load` lines |
| `BE3-DYE-ID`, `BE4-BELL-ANIM`, `BREAK-RATE`, `FM-CORNERS`, `FM-TOP-UV`, `JRAND-*`, `MN4-STONE-ROWS`, `TOOL-ELYTRA-STEP`, `TOOL-RULE-EVAL` | rendering and prediction | in-process only: pure functions of their arguments, they read no world state |
| game content set (`CT-*`, EXTERNAL) | everywhere | in memory mode the client uses the core's set; in process mode the client builds its own from Registry Data and Update Tags like for any server (`WT16-ADD`, `CL-SET-OWNED`) |

No client program reads the core's EXTERNAL world state (`CW-*`, `PL-*` of CORESTATE): screenshots, the debug overlay and
the HUD use the client's own replica built from the protocol, in both modes.

## Hard parts

- **Pause**: explicit `@pause` / `@resume`, never signals. The client computes `SP-PAUSED` from the screen as before
  and sends the message on each change; the child holds its clock while paused and still moves bytes, so a command or a
  disconnect is handled. Open to others turns the pause off, as before.
- **Quit and crash**: `@stop` then wait (timeout, then kill); a child that dies shows the disconnect screen and is reaped; a
  client that dies leaves the child with end of input, which saves and exits.
- **Open to others**: the child already listens; `@open` switches the world to host kind 2 and moves the listener to all
  interfaces. The host's own connection was logged in before and stays; a guest with the host's name is refused
  (`name_is_host`) as before.
- **Generation workers** fork from the child; the child's end of input ends them as it does now.
- **Startup**: the child's content load happens in its process; the client draws the loading screen meanwhile.
- **Cost**: the loopback connection compresses and decompresses chunk packets (the memory connection does not). Stage D
  measures it.
