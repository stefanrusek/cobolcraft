# Contract: game core host API (`core` ↔ `server`, `client`)

**Status**: frozen at plan time (constitution 3.3). **Materialized** in the Foundational phase as
`contract/copy/COREAPI.cpy` (parameter records and constants). Both host programs (the server program and the
client's single-player/open-to-others host) drive the core only through the entry points below.

**What the core is** (research R7): the world, every game rule, persistence, the command set, and the server
side of the protocol (handshake, status, login, configuration, play) operating on **byte streams**. It owns
no sockets and no window: a host moves bytes between transports and the core, calls the tick, and prints
console lines. One process hosts at most one open world.

## 1. Records (`COREAPI.cpy`)

```cobol
*> Settings: FR-009 plus the single-player/open-to-others extras (FR-007, FR-016, FR-017)
01 CORE-SETTINGS.
   05 CS-DEFAULT-MODE        PIC 9.            *> 0 survival, 1 creative
   05 CS-DESCRIPTION         PIC X(256).       *> server-list description (US2-2)
   05 CS-VIEW-DISTANCE       BINARY-LONG.      *> 2..32
   05 CS-PLAYER-COMBAT       PIC 9.            *> 1 enabled
   05 CS-HOSTILE-MOBS        PIC 9.
   05 CS-WEATHER-CHANGES     PIC 9.
   05 CS-EXTRA-DIMENSIONS    PIC 9.
   05 CS-ALLOW-LIST-ENFORCED PIC 9.
   05 CS-PACK-OFFERED        PIC 9.
   05 CS-PACK-URL            PIC X(1024).
   05 CS-PACK-SHA1           PIC X(40).
   05 CS-PACK-ID             PIC X(36).        *> UUID text
   05 CS-PACK-REQUIRED       PIC 9.
   05 CS-PACK-PROMPT         PIC X(256).       *> empty = none
   05 CS-HOST-KIND           PIC 9.            *> 0 dedicated server, 1 single-player, 2 opened to others
   05 CS-HOST-NAME           PIC X(16).        *> kinds 1-2: the host player's offline name (holds operator status)
   05 CS-GUEST-MODE          PIC 9.            *> kind 2: game mode for joining players
   05 CS-GUEST-OPERATOR      PIC 9.            *> kind 2: 1 = guests may use operator commands
   05 CS-NEW-WORLD-NAME      PIC X(64).        *> name stored in level.dat when a world is created

01 CORE-BUFFER.                                *> a caller-owned byte buffer
   05 CB-ADDR                USAGE POINTER.
   05 CB-CAPACITY            BINARY-LONG.
   05 CB-LENGTH              BINARY-LONG.

01 CORE-STATUS.
   05 CST-RUN-STATE          PIC 9.            *> 0 running, 1 stop requested (stop command), 2 stopped
   05 CST-PLAYERS-ONLINE     BINARY-LONG.
```

Connection kinds: `CORE-CONN-NETWORK = 0` (compression enabled per 01 §3 and `wire-profile.md` §2),
`CORE-CONN-MEMORY = 1` (no compression, no encryption, 02 Offline mode).

## 2. Entry points

| Program (`CALL STATIC`) | Parameters | Behaviour |
|---|---|---|
| `CORE-WORLD-OPEN` | world folder path (z-string), `CORE-SETTINGS`, OUT created-flag | Opens the world folder, creating a new world (standin-content §5 and the FR-015 dimensions) if it has no `level.dat` (US13-1). Applies settings; settings never overwrite the world (US13 edge case). Fatal on unreadable world files (research R14). |
| `CORE-CONN-OPEN` | kind, OUT connection id | Registers a new connection in the handshake phase. |
| `CORE-CONN-INPUT` | connection id, `CORE-BUFFER` | Consumes received bytes (frames may be split or joined arbitrarily). |
| `CORE-CONN-OUTPUT` | connection id, `CORE-BUFFER`, OUT close-flag | Moves pending outbound bytes into the buffer (up to capacity). close-flag = 1 when the core has finished with the connection (after a disconnect packet) and the host must close the transport once the buffer is sent. |
| `CORE-CONN-CLOSED` | connection id | The transport closed (peer or error). The player, if any, leaves (US13-3 console line). |
| `CORE-TICK` | — | Runs exactly one 50 ms game tick (R6): connection timeouts and keep-alives (01 §7.5), movement, block breaking timers, entities, health, hunger, weather, time of day, chunk streaming. The host calls it once per elapsed 50 ms (and not while a single-player pause is in effect, US16-4). |
| `CORE-CONSOLE` | line (z-string) | Runs a console command with operator permission (US15, FR-016). |
| `CORE-CONSOLE-DRAIN` | `CORE-BUFFER` | Moves pending console lines (`\n`-separated, UTF-8) into the buffer; the host prints them with `DISPLAY` (server console; client: its terminal). Covers join/leave/death/dimension/chat lines (US13-3), command results (US15-1), ready line (US13-1, produced by the host itself), and non-fatal failure lines (FR-012). |
| `CORE-STATUS-GET` | OUT `CORE-STATUS` | Run state and online count. The server host exits after `CST-RUN-STATE` = 2. |
| `CORE-SAVE` | — | Writes the whole world (FR-014) to its folder. |
| `CORE-STOP` | reason (z-string) | Saves the world, queues a disconnect with `reason` to every connection, sets run state 2. Used by the stop command (via run state 1, which the host turns into `CORE-STOP` with the "server is stopping" text, US15-2) and by the single-player host on quit (US16-5, US17-4 with the "host closed the world" text). |
| `CORE-OPEN-TO-OTHERS` | guest mode, guest-operator flag | Switches a single-player world to host kind 2 for the rest of the session (FR-017). |

## 3. Guarantees

- The core never blocks and never calls `cc_net_*`, `cc_win_*` or `cc_vk_*`. Its only C calls are the
  glue functions `cc_deflate`, `cc_inflate` and `cc_fatal`, OpenSSL's `EVP_md5`/`EVP_Digest` called
  directly (offline UUID), and COBOL file routines for the world folder.
- Bytes produced for a connection are exactly the protocol of `docs/protocol/` 00 to 07 and
  `docs/protocol/09-cobolcraft-profile.md` (from `wire-profile.md`).
- Connection ids are reused only after `CORE-CONN-CLOSED` or a close-flag hand-back.

## 4. Contract tests

- `core/tests/contract_coreapi_provider.cob`: each entry point with the record layouts above (open a new
  world in a temp folder, open a memory connection, feed the handshake/login fixture bytes, observe Login
  Finished bytes in the output, close, console command, drain, status, save, stop).
- `server/tests/contract_coreapi_consumer.cob` and `client/tests/contract_coreapi_consumer.cob`: the host's
  use of each record and entry point matches this document (record lengths and constant values from
  `COREAPI.cpy`; the host's call sequence on start, per-connection pump, tick cadence and stop handling).
