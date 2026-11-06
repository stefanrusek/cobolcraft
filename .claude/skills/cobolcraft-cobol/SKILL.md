---
name: cobolcraft-cobol
description: CobolCraft's GnuCOBOL conventions and known compiler/coverage pitfalls. Use whenever writing, editing, reviewing or debugging COBOL (.cob, .cpy) or package Makefiles in this repository — proto, core, server, client, tools/testlib or contract/copy — including speckit-implement phases, test programs and coverage fixes.
---

# CobolCraft COBOL conventions

Apply these to every COBOL source and test in this repo. They come from the constitution (v1.2.0),
`specs/001-cobolcraft-complete/tasks.md` "Conventions every task inherits", and pitfalls found while
implementing. If this file and tasks.md disagree, tasks.md and the constitution win; fix this file.

## Language and build

- GnuCOBOL 3.2, **free format**. Every build uses `-free -debug -std=default -fstatic-call`
  (`tools/package.mk`). Comments are `*>`.
- `-fstatic-call` is required: without it a `CALL "X"` does not pull program X out of a package `.a`.
- Calls to C use `CALL STATIC` (research R2). COBOL may call any C library directly; C glue
  (`shim/`) exists only where a call can't be expressed cleanly (callbacks, struct layouts, variadics),
  and contains no game or protocol logic (constitution Principle I).
- Shared record shapes come only from `contract/copy/*.cpy` (`PROTO`, `COREAPI`, `CCSHIM`, …). Never
  redefine them locally. Package-private copybooks live in `<pkg>/copy/`.
- Package Makefiles only set `PKG`, `LIBNAME`, `SRC`, `TESTS`, `INCLUDES`, `DEPLIBS`, `LDLIBS` and include
  `tools/package.mk`. `src/main.cob` is a single `CALL` into a library entry point and is kept out of the
  library.
- Any package that links proto frame or NBT-file code must link `-lz`.

## Program structure (coverage-driven)

- 100 % line coverage is a gate (constitution 4.2). Generated code and test infrastructure are the only
  exclusions.
- **Keep production logic inline.** Trailing performed paragraphs make gcov report the `END PROGRAM`
  line as uncovered. Prefer several small programs (one `PROGRAM-ID` each) to paragraphs.
- Write a failure branch on its own line(s), so coverage actually shows whether it ran.
- Several programs may share one source file (`END PROGRAM` after each). Under `-Wall`, calls between
  programs in one file are size-checked: the argument sizes must match.

## GnuCOBOL pitfalls

- **LINKAGE size under `-debug`:** a LINKAGE item longer than the caller's argument aborts at run time.
  For caller areas of variable size, declare a one-byte `PIC X` LINKAGE item and read it through a
  `BASED` view (see `proto/src/buffer.cob`).
- **64-bit literal arithmetic:** constant expressions overflow silently (`2 ** 64` is 0). Put large
  constants in `VALUE` clauses.
- **High-byte hex literals:** `X"…"` with bytes ≥ 0x80 makes clang warn; build such bytes another way
  (e.g. `FUNCTION CHAR`, or a `VALUE` in a binary field).
- **BY REFERENCE aliasing:** a caller may pass a field the callee itself changes (for example
  `PLAYER-LEAVE USING CN-PLAYER(id)`, which zeroes `CN-PLAYER`). Copy such LINKAGE arguments into
  WORKING-STORAGE before changing shared state.
- **`-Wall` size checks between programs of one file** only see programs defined *earlier* in the
  file; put a program that takes a one-byte `PIC X` area after its callers.
- **`FUNCTION SIN`/`COS` are slow** (about 90 µs a call): remember results that repeat (worldgen).
- **Shifting a large buffer byte by byte is quadratic**: keep a read offset (`PB-POS`) instead of
  moving the rest to the front after every partial read.
- **Core state** is the EXTERNAL records of `core/copy/CORESTATE.cpy`; PB-BUFFERs are kept there as
  their raw 21 bytes and moved into a local `PB-BUFFER` to use them.
- **No `C$LIST-DIRECTORY`** in GnuCOBOL 3.2: use `cc_fs_list` (contracts/shim-abi.md §7).
- **Reserved words as paragraph names** (`MOVE`, `SEPARATE`, `REPORT`, …) fail with "unexpected PERFORM"
  far from the cause: give test paragraphs verb-noun names (`DO-MOVE`, `ADD-SPACE`).
- **Nested subscripts with arithmetic inside an intrinsic's arguments** can be miscompiled:
  `FUNCTION MIN(C(R, F), MX(I(R, T) + 1) - C(R, T))` yields a wrong value with no warning. Move the
  inner subscript or the difference into a field first, then call the function.
- **Reference modification by a subscripted item** is miscompiled in comparisons and DISPLAY:
  `IF CD-NAME(I)(1:CD-NAME-LENGTH(I)) = X(1:CD-NAME-LENGTH(I))` compares the length's digits, and
  `CQ-LINE(CQ-WORD-START(T):N)` reads the wrong bytes, with no warning. Move every refmod offset
  and length that is a table element into a plain field first.
- **`PERFORM VARYING … FROM a - b`** is a syntax error: compute the start into a field first.
- **Division inside an intrinsic is not truncated**: `FUNCTION MOD(R / 1681, 8)` takes the MOD of a
  fraction. Compute the integer quotient into a binary field first (`COMPUTE Q = R / 1681`), then MOD.
- **`IF … ELSE IF … END-IF`** with one END-IF leaves the outer IF open until the next period, so the
  statements after it (even GOBACK) belong to the ELSE branch. Use EVALUATE.
- **The same item twice in one `CALL … USING`** warns under `-Wall` (`-Werror` in lint): pass
  distinct fields (e.g. three zero fields for a zero vector).
- **Float edges**: `x + 0.35` is not exact; compare cell faces with a small tolerance (movement.cob
  uses 1e-7) so that touching faces do not count as overlaps.
- **MOVE of a float to a numeric-edited item truncates** (100.215 shows as 100.21499): use
  `COMPUTE edited ROUNDED = float` when a test prints a float.
- **OCCURS is not allowed at level 01**: wrap a table in a 01 group (`01 WS-ORDERS. 05 WS-ORDER
  ... OCCURS n TIMES.`).
- **Fixed format breaks past column 72**, which is why the project is free format. Don't switch.
- **A z-string from a shorter field**: `MOVE LOW-VALUES TO Z` then `MOVE A(1:N) TO Z` pads Z with
  spaces again, so there is no NUL; move into `Z(1:N)` instead.
- **Reference-modified arguments with a computed offset** (`CALL … USING HDR(I * 4 + 1:4)`) warn
  "does not conform to the parameter definition" under `-Wall`: copy the slice into a fixed-size
  field, call, copy it back.
- **Free-format literals cannot use `-` continuation lines**: build long text with `MOVE "a" & "b"`.
- **`BINARY-SHORT`/`BINARY-LONG` are native byte order** (little-endian on arm64), unlike `PIC 9 BINARY`:
  read a network-order field of a C struct (`sin_port`) from `PIC X(2)` bytes.
- **`PB-FRAME-DECODE` with a threshold ≥ 0** leaves the Data length 0 of an uncompressed packet in
  front of the id in the packet buffer (`PK-POS` is past both); strip it before comparing the packet
  with a fixture (server `SVT-NEXT-PACKET` does).
- **Reading NBT compounds**: `MOVE SPACES TO WN` before each `NBT-READ-COMPOUND-NEXT` and compare
  the whole field (`WN = "Pos"`); the wrapper name `""` of a mixed list (07 §1.1) leaves it spaces.
  Never reference-modify a name by a length that can be 0.
- **A run that ends inside a program skews gcov**: when a test ends through `cc_fatal` (C `exit`)
  in the middle of a program, gcov's derived line counts of that program come out wrong (lines
  run by other tests can drop to `#####`). Keep each fatal call in a small check program
  (`IF outcome NOT = 0 ... CALL STATIC "cc_fatal"`, e.g. `GAME-DATA-CHECK` in `client/src/game-dir.cob`).
- **Numeric literals passed BY REFERENCE** arrive as binary items (`CALL "X" USING 01` hands over a
  2-byte binary 1), so a `PIC 99` LINKAGE item reads garbage. Pass a WORKING-STORAGE field, or an
  alphanumeric literal (`"01 05 02"`) that the callee splits.
- **`FUNCTION CHAR(n)`** is the character of ordinal n, i.e. code n - 1: the digit d is
  `FUNCTION CHAR(d + 49)`.
- **`COMPUTE x = a / 4 + b / 4`** truncates only the final result (3/4 + 1/4 = 1); integer
  division needs `DIVIDE ... GIVING` first (texture recipes with `x div 4`).
- **REPLACING LEADING ==PB-== BY ==IN-==** in a client program redefines `IN-TEXT` of CLSTATE.cpy:
  choose prefixes that do not collide with the client state (`RX-`, `OUT-`, `FR-`).
- **A program whose output parameter may be its input** (`JSON-MEMBER USING doc node key len node`)
  must copy the input to WORKING-STORAGE before it clears the output.

## Interfaces

- C layer: `specs/001-cobolcraft-complete/contracts/shim-abi.md`, including recorded edge behaviour of
  `cc_con_readline`, `cc_fs_list` and `cc_net_local_addresses`.
- Protocol codec: `contracts/proto-api.md`, with entry-point parameters and conventions in **§5**:
  - A failed read leaves `PB-POS` unchanged, and `PB-ERROR` stays set until `PB-RESET`.
  - NBT writer name length: ≥ 0 named tag, −1 list element, −2 network root.
- Protocol facts come only from `docs/protocol/` (Principle II), plus `09-cobolcraft-profile.md`. Never
  read the shipped jar. Content values (ids, numbers, names, texts) are transcribed from
  `docs/design/standin-content.md`, never invented in code.

## Tests

- Test files follow these patterns:
  - `acc_<story>_<topic>` for acceptance tests. Case names contain `acceptance US<n>-<scenario>` and Given/When/Then.
  - `contract_<seam>_<side>` for contract tests.
  - `test_<unit>` for implementation tests.
- Tests are written before the code they test (constitution 4.1), and use no test doubles: real sockets, GPU, window and zlib.
- **Red, then green, every time.** Write the test task, build and run it, and see its new cases FAIL (or fail to
  link because the entry point doesn't exist yet) before writing the implementation task. Writing tests and code in
  the same pass, even if they all pass first time, violates 4.1. Report the observed failing run in the phase
  summary.
- Use `tools/testlib/` (`COPY TESTLIB.`, set `TL-CASE`, `TL-EXPECTED`/`TL-OBSERVED` or the `-N`
  numeric forms with `TL-MODE "N"`, then `CALL "TEST-ASSERT" USING TESTLIB-ASSERT`). One output line per
  case: `TEST <case> PASS` / `TEST <case> FAIL expected=<x> observed=<y>`.
- Tests run from the repository root, so open fixtures as `contract/fixtures/wire/<name>.hex`.
- `<test>.stdin` feeds standard input. `<test>.expect` holds the expected exit status on line 1, and
  optionally on line 2 text that stderr must contain.
- Core test helpers live in `core/tests/CORETEST.cpy` (COPY it after the test program):
  `TEST-JOIN` (a memory connection that logs in, configures and loads), `TEST-MOVE`,
  `TEST-JOIN-NETWORK` (the same join over a network connection: Set Compression, then compressed
  frames, so drain it with threshold 256 and drop the leading Data length 0 of small packets),
  `TEST-ACCEPT-TELEPORT`, `TEST-DRAIN-IDS` (packet ids as `<id>x<n>` runs), `TEST-USE-ON`,
  `TEST-ACTION`, `TEST-HELD`, `TEST-CLICK`, `TEST-TICKS`, `TEST-DRAIN-BLOCKS` (block, ack, slot and
  light packets with their fields; Set Time left out), `TEST-BLOCK-AT`, `TEST-CHAT` (feeds unsigned
  Chat), `TEST-DRAIN-CHAT` (System Chat texts, `|`-separated), `TEST-ATTACK`, `TEST-CLIENT-COMMAND`,
  `TEST-DRAIN-HEALTH` (Set Health, Damage Event, Hurt Animation, Player Combat Kill, System Chat,
  Respawn and Player Position, `|`-separated), `TEST-USE-ITEM`, `TEST-PLAYER-COMMAND`,
  `TEST-DRAIN-HUNGER` (Set Health, Entity Event and Container Set Slot, `|`-separated), `TEST-PLACE-RECIPE`,
  `TEST-DRAIN-CRAFT` (Recipe Book Add as `book <n> craftable <ids> replace <r>` and Container Set Slot,
  `|`-separated), `TEST-DRAIN-WEATHER` (weather Game Events 1, 2, 7, 8 as `<event> <value>`,
  `|`-separated), fixture loading and comparison. Test copybooks are not make dependencies: touch the test or delete
  `build/coverage/core` after changing one.
- Coverage fixtures are named `*.gcov.txt` (`*.gcov` is gitignored).
- **Recipe Book Add follows every inventory change** (standin §13; `CRAFT-REFRESH-ALL` runs after each
  play packet and each tick). `TEST-DRAIN-BLOCKS` and `TEST-DRAIN-ENTITIES` leave it out (like Set Time);
  `TEST-DRAIN-IDS` lists it (id 75). A test that edits `PL-SLOT` directly gets a book on the next packet
  or tick; call `CRAFT-REFRESH-ALL` and drain first when that matters.
- **The join sequence carries the weather pair** (standin §14.4: Game Events 2, 7, 8 for a clear
  world, after Set Time and before Game Event 13), so `TEST-DRAIN-IDS` shows `39x4` there. A new world
  is clear with 6000 ticks left; tests that need a kind set `CW-WEATHER-KIND(dim)` and
  `CW-WEATHER-LEFT(dim)` directly. Hail (§14.6) strikes exposed survival players and mobs on ticks with
  Time mod 80 = 0 only during a hailstorm, so it never acts in a test that does not set one.
- **Extra dimensions** (standin §15): `TEST-SETTINGS` leaves `CS-EXTRA-DIMENSIONS` 0, so a test world
  has only cobolcraft:main; set it to 1 before opening the world to get cobolcraft:subroutine
  (`DIM-SUBROUTINE`, row 2: generator `WORLDGEN-SUB-CHUNK`, no sky light, ash_flats, no weather). Tests
  travel for real: place a goto_pad (`TRAVEL-PAD-STATE`) with `WORLD-SET-BLOCK` and `TEST-USE-ON` it;
  a player who travelled is ignored for 20 ticks (`TEST-TICKS` 20 between trips). Travel sends Respawn,
  abilities, held slot, inventory, then `PLAY-ARRIVE` (`TEST-DRAIN-IDS`: `84 65 107 18 106 99 115 39x4 96
  12 46x25 11 73` at view distance 2). Expected Subroutine heights come from the §15.2 formula
  (32 + round(5 sin(x/11) cos(z/13))), computed independently.
- **Rejoin restores the place left** (US12-3): `PLAYER-LEAVE` stores dimension, position and facing in
  `CORE-KNOWN` (`KN-PLACED`, `KN-DIM`, `KN-X`...), and the next join of that UUID starts there while the
  dimension is enabled (else at the world spawn). A test that expects a rejoin at the spawn point must
  not move the player first.
- **Persistence** (US13; `core/src/persistence.cob`, `region.cob`): `TEST-OPEN-WORLD` deletes
  `build/core-test-world` first, because saves and chunk unloading (`CHUNKS-UNLOAD` after every
  `CHUNKS-FOLLOW`: changed chunks outside every view are written to their region file and
  released) now write there. A test that opens another folder removes it itself (`CALL "SYSTEM"`).
  `CORE-SAVE` writes 07 §9; `CORE-WORLD-OPEN` of a folder with `level.dat` loads it (entities at
  once, chunks on first use, player files on join). A rejoin restores game mode, health, food, held
  slot and inventory too (`PLAYER-REMEMBER` / `KN-STORED`), not only the place. `TEST-NBT-GET`
  (render any tag by path), `TEST-NBT-FILE`, `TEST-WORLD-SNAPSHOT` and `TEST-PLAYER-SNAPSHOT` help
  assert saved and reloaded state.
- **Console lines**: joining, leaving, dying, changing dimension and chatting each queue a console
  line (`CORE-LOG`, `CONSOLE-TEXT` renders `translate` texts through `CONSOLELANG.cpy`); a test that
  drains the console sees them.
- **Commands** (US14; `core/src/commands.cob`, `COMMANDS.cpy`, `CMDPARSE.cpy`, `MESSAGES.cpy` MK-*):
  the join sequence now sends Commands (0x10) right after Login (`TEST-DRAIN-IDS`: `50 16 75 ...`).
  `TEST-COMMAND` / `TEST-CHAT-COMMAND` feed Chat Command (no leading `/`), `TEST-SUGGEST` and
  `TEST-DRAIN-SUGGESTIONS` drive Command Suggestion, `TEST-DRAIN-CHAT` shows replies as
  `key(arg,arg)`. The console is sender 0: `CALL "CMD-RUN" USING sender line length` and drain
  `CORE-CONSOLE-DRAIN` (drain it first: joins queue console lines). A test player gets operator
  status by putting its offline UUID on the operator list (`ACCESS-ADD` with `ACCESS-OPERATORS`)
  before it joins. `TEST-HELLO` stops after Hello (for Login Disconnect refusals); the name
  `TEST-LOGIN` is taken by `test_login.cob`.
- **Console commands and stopping** (US15): `CORE-CONSOLE` takes a z-string line (sender 0, replies
  drained with `CORE-CONSOLE-DRAIN`). `CORE-STOP` takes a z-string §17 translate key, saves, sends each
  connection not already closing the disconnect of its phase and sets run state 2. Draining a
  closed connection with `TEST-DRAIN` releases it, so the player leaves after the save.
- **Opening to others** (US17): a test world is host kind 0; set `CS-HOST-KIND` 1 and `CS-HOST-NAME`
  before opening it, join the host with `TEST-JOIN` (memory), then `CORE-OPEN-TO-OTHERS` (guest mode,
  guest-operator flag; only kind 1 becomes kind 2) and join guests with `TEST-JOIN-NETWORK`. A network
  login with the host's name gets Login Disconnect `name_is_host` [name]; the memory host is never refused.
- **Client hosting guests** (US17-client; `client/src/sp-host.cob`): `SP-OPEN-OTHERS` (the
  open-to-others screen's choices in `SP-GUEST-MODE`/`SP-GUEST-OPERATOR`) calls `CORE-OPEN-TO-OTHERS`,
  listens on port 0 (`SP-LISTENER`, `SP-PORT`) and keeps the local addresses; `SP-PUMP` then accepts,
  receives from and flushes the `GH-GUEST` slots like the server's TCP host. Client tests drive guests
  as raw loopback sockets with the wire fixtures (`test_host_network`: `TEST-SERVE` for framing, a
  hand-built Hello for a name other than the host's Alice, its own copy of the buffer-shrinking helper).
  The pause menu of a hosted world lists Open to Others before Save and Leave the World.
- **Server pack offer** (US18; `config-phase.cob`): with `CS-PACK-OFFERED` 1 the configuration
  sequence sends Resource Pack Push after Update Tags (`TEST-DRAIN-IDS`: `2 1 13 15 7x18 14 9`) and
  waits (CF-STEP 3) for a terminal Resource Pack Response of that pack id before Finish
  Configuration; declining a required pack gets the configuration Disconnect `pack_required`.
  `TEST-CONFIGURE` stops after the client's Select Known Packs; `TEST-PACK-RESPONSE` feeds the
  response fixture of an action (pack id `00112233-4455-6677-8899-aabbccddeeff`).
  `CONFIG-PACK-PUSH-BUILD` takes the settings record, so contract tests need no open world.
- **Resource packs** (US18; `client/src/packs/`, `zip.cob`, `png.cob`, `http.cob`, `regex.cob`): the
  stack is `PK-PACK` (kind 0 built-in, 1 folder, 2 zip; `PK-META` a `CLMCMETA.cpy` record, `PK-FILES`
  the file table after overlays and filters). `PACKS-RELOAD` rebuilds the stack from `OP-ENABLED`
  (options.dat, top first) and the active server packs (`RP-PACK`), then reloads everything drawn
  from it. Client tests use `client/tests/PACKTEST.cpy` (COPY after CLTEST): `TEST-PACK-START`
  copies fixture packs of `tests/fixtures/packs` (gen_packs.py, gitignored, made by `make fixtures`)
  into `resourcepacks/`, `TEST-PACK-ENABLE`, `TEST-PIXEL` (a sprite's top-left pixel; a missing
  sprite is the stripes), `TEST-DIGEST`/`-DIFF` (what changed), `TEST-PUSH`/`TEST-POP`. Downloads
  run against `tools/testsrv/testsrv.py` (`TEST-TESTSRV-START`/`-STOP` in CLTEST.cpy); use
  `127.0.0.1` URLs. The UI atlas has an icon band (`UA-ICON-Y`) between the font and the swatch
  row, so UI tests' V coordinates depend on `CL-MAX-ICONS`.
- **Moving a table entry's bytes into a `BINARY-LONG`** with `MOVE area(pos:4) TO n` converts it as
  display digits: move the whole entry into a group with the same layout and read the field.
- **Server console input** (`server/src/console.cob`): `TCP-POLL` asks `cc_net_poll` about standard input
  only while `SV-CONSOLE-OPEN` is 1 (set by `SV-START`, 0 at end of input). Server tests without a
  `.stdin` get an empty input, so the console closes on the first poll. A test that needs a player in
  play before its `.stdin` command runs sets `SV-CONSOLE-OPEN` to 0 while joining, then 1. A test that
  must see the run end (`SV-RUN`/`SV-MAIN` never return) forks with `SVT-FORK` and runs `SV-RUN` in the
  child, after `SV-SHUTDOWN` in the parent drops the parent's copies of the sockets
  (`acc_us15_stop`), or uses a `.expect` file (`test_sv_main`). EXTERNAL `SVSTATE` fields that tests
  may read before `SV-START` are `BINARY-LONG`, never `PIC 9` (all-zero bytes are not numeric
  `DISPLAY` data).
- **Client dimension change** (US12-client): Login keeps the dimension names (`PL-LEVEL-COUNT`,
  `PL-LEVEL`); Respawn empties the replica (`WORLD-CLEAR`), and a row taken by another chunk before
  the next frame drops its meshes in `WORLD-ROW-NEW`. No fixture holds a Subroutine chunk: client
  tests build one with the proto encoders (`TEST-SUB-CHUNK` in `acc_us12_dimension_change.cob`).
- An entity changing dimension goes through `ENTITY-CHANGE-DIM` (Remove to the old viewers, Add at the
  new position to the new ones), never `ENTITY-MOVE`.
- **Mobs spawn in every test world** (standin §12.4: a sodgrazer near each alive player on ticks with Time
  mod 100 = 0 by day). A test that runs many ticks and does not test mobs keeps them out with
  `MOVE 0 TO CS-HOSTILE-MOBS` before opening the world and `MOVE 16001 TO CW-TIME` after it (night, when
  the only cobolcraft:main candidate is the abend, refused while hostile mobs are off). Mob tests set the
  Time just before the tick they test and place mobs with `MOB-SPAWN`. Expected spawn columns and wander
  decisions come from the §1.4.1 hash (`core/src/rng.cob`), computed independently from the doc.

- **Server tests** (`server/tests/SVTEST.cpy`, COPY after the test program) drive the host with a real
  loopback client: `SVT-CONNECT`, `SVT-SEND-FIXTURE` (threshold -1, or 256 after Set Compression),
  `SVT-CONFIGURE`, `SVT-RECV`, `SVT-NEXT-PACKET`, `SVT-SAME-AS-FIXTURE`. `SVT-SCRATCH` makes
  `build/<dir>` the current directory (the server works in `.`; fixtures then resolve through
  `SVT-ROOT` "../../"). `SVT-CAPTURE-START`/`-STOP` redirect standard output to a file to assert
  console lines (no TEST line in between). macOS grows loopback socket buffers to megabytes:
  `SVT-SHRINK-BUFFERS` (4096-byte buffers) makes a partial send happen. The host state is
  `server/copy/SVSTATE.cpy` (slots, pending output, tick clock, `SV-TICKS`).
  Every console line `SV-PRINT` displays starts with `[HH:MM:SS] `: pass captured text through
  `SVT-UNSTAMP` before comparing it. `SV-START` reads `./cobolcraft-server.conf` (`SV-CONFIG-LOAD`,
  written with the defaults when absent): `SVT-WRITE-CONF` writes one ("|" separates lines) and
  `SVT-HOME` returns to the repository root before the next `SVT-SCRATCH`. Several fatal paths in
  one test program: `SVT-FORK` (child's stderr to `./stderr.txt`; the child ends with `STOP RUN`)
  and `SVT-WAIT` (exit status and stderr text); the last fatal sub-case runs in the program itself
  for its `.expect`.
- **Client text widgets**: `WIDGET-ADD` keeps 256 bytes of text, and `UI-RENDER` appends the caret
  `_` to a focused field (state 1), so a focused field's text must be at most 255 bytes (the chat
  line shows its last 255 bytes from a character boundary). At most 32 text events count per frame
  (`IN-TEXT`): tests type long lines over several frames.
- **Client entity drawing** (`client/src/entities-render.cob`): the entity atlas (texture 1) stacks
  operator (66 x 28), sodgrazer (80 x 23) and abend (72 x 12) from the top, 80 x 63 with the
  built-in pack, so a face's u is texel x / 80 and v is (image top + strip row) / 63. Model boxes
  are a table in `ENTITIES-MESH`. `TEST-FIGURE-FACE` and `TEST-ENTITY-DRAWS` (CLTEST.cpy) read
  the entity mesh. Adding a built-in pack file shifts the `BI-*` indexes in `CLBUILTIN.cpy` and
  the file counts in `test_builtin_files` and `test_pack_stack`.
- **Client commands** (US14; `client/src/screens/chat.cob` CHAT-SUGGEST, `protocol-client.cob`
  COMMANDS-READ / SUGGESTIONS-READ): `/` on the world screen opens chat with `/` typed. The tree is
  `CM-*` in CLSTATE (node index i is row i + 1, children in `CM-LINK`); suggestions are `CS-*`
  (names, then the answers to the last Command Suggestion, `CS-TRANSACTION`). Queued packets reach
  the loopback server only on the next CL-STEP: `TEST-STEP` before `TEST-SERVER-READ-HEX` when a
  test calls a sender directly. Game Event 3 sets `PL-ABILITIES` (creative 0x0D, survival 0 and
  flying ends).
- **Single-player host** (US16; `client/src/sp-host.cob`): the client links the core and joins it
  over a memory connection (`NET-OPEN-MEMORY`, `CN-MEMORY`/`CN-CORE-ID`; `CN-CORE-ID` 0 once the
  core hands the id back with the close flag). `SP-SETTINGS` (a whole `CORE-SETTINGS`) is set by
  `SP-DEFAULTS` in `CL-INIT`; `SP-PUMP` runs the core ticks per elapsed 50 ms of the frame clock.
  Client tests: `TEST-SP-START` (view distance 2, no hostile mobs), `TEST-SP-JOIN` (steps until in
  play and loaded), `TEST-NBT-TAG` (a top-level tag of a gzip NBT file). A join through the real
  core sends Player Position after the only chunk batch, so the client sends Player Loaded on the
  first position after a finished batch too.
- **Program names are global across linked packages**: now that the client pulls core objects in,
  a client program named like a core program is a duplicate symbol at link time (the client's
  `WORLD-CHUNK-LOAD` became `REPLICA-CHUNK-LOAD`). Check `nm` of both archives when adding one.
- **`STRING … DELIMITED BY SPACE`** applies to every source before it that has no own `DELIMITED`
  phrase, literals included: `STRING "a b|" X DELIMITED BY SPACE` yields `a`. Give the literal its
  own `DELIMITED BY SIZE`.

- **Client tests** (client/tests/CLTEST.cpy, COPY it after the test program; touch the tests
  after changing it): `TEST-LOAD-HEX`, `TEST-SAME-AS-FIXTURE`, `TEST-HEX-OF`, `TEST-FEED` (a fixture
  packet into `PROTO-PACKET` on a connection), `TEST-SENT` / `TEST-SENT-IDS` / `TEST-CLEAR-SENT`
  (what the client queued in `CN-OUT`; strips the uncompressed Data length byte until T1073),
  `TEST-LOOPBACK` (a real loopback connection for a client connection), `TEST-SERVE`,
  `TEST-SERVE-BYTES`, `TEST-SERVER-READ` (the server side of it), `TEST-STEP`, `TEST-EVENTS`,
  `TEST-CLICK` (clicks a widget of the screen model by action through `CL-STEP`), `TEST-TYPE`,
  `TEST-KEY`, `TEST-SCREEN-TEXTS`, `TEST-MESH-FACE` (a quad of a section mesh by its centre),
  `TEST-READ-FILE`, `TEST-SLEEP` and `TEST-CLOSE-REQUEST` (queues the window's close-requested event
  by calling the close callback the shim registered, found with `dlsym` of `cc_win_window`).
  US3 added `TEST-PLAY` (a started client in play over loopback on a flat greystone floor, player
  at (0.5, 10, 0.5) facing +Z, loaded and captured), `TEST-SET-BLOCK`, `TEST-TICKS` and
  `TEST-KEY-TICK` (50 ms steps, one client tick each), `TEST-EVENTS-MS` (every stepping helper
  shares its clock), `TEST-POSITION`, `TEST-ANGLES` and `TEST-ENTITY`. CLTEST.cpy calls production
  entry points (`ENTITY-FIND`), so until they exist every client test fails to link. US4 added
  `TEST-SERVER-READ-HEX` (each packet the server side received as hex of id + body, Client Tick End
  and Move Player left out), the way to assert what a control sent.
- **Client US4 state**: the world screen's HUD holds the crosshair and nine hotbar slot widgets
  (`WK-SLOT`, argument the slot, 36 = the cursor stack), so world-screen widget and UI vertex counts
  include them. `CL-STEP` runs `RAYCAST` (world screen) and `CONTROLS-INPUT` (in play) after the tick;
  every Player Action and Use Item On takes the next `CT-SEQUENCE`. A test that sets `PL-SLOT` and
  `PL-HELD` directly controls what the controls see as held. Item icons (`IT-SPRITE`) need
  `ATLAS-BUILD` before `ITEMDEFS-LOAD` (`CL-START` does both). `UI-QUAD` writes to the layer
  `RL-UI-LAYER` names (0 UI, 1 over the icons, 2 the icons): reset it to 0 after use.
- **Client US7 state**: in survival (`PL-MODE` 0) the HUD adds a `Health <h>/30` label after the
  hotbar slots (`TEST-PLAY` sets health 30, as Login does); the hurt indication is a `WK-OVERLAY`
  first widget while `CL-NOW-MS < PL-HURT-UNTIL`. `CL-NOW-MS` is 0 until the first `CL-STEP` and the
  stepping helpers' clock starts far later, so `TEST-STEP` once before feeding a packet whose effect
  is timed from the clock. `RAYCAST` also finds the entity target (`TG-ENTITY-HIT`, `TG-ENTITY`),
  which clears `TG-HIT` when it is nearer than the block. Respawn (`PLAY-RESPAWN-READ`) and Login
  share `DIMENSION-ENTER`; Respawn keeps the player list (`ENTITIES-FORGET`).
- **Client US8 state**: the survival HUD adds `Food <f>/24` after the health label (`TEST-PLAY`
  sets food 24; `TEST-SET-HEALTH` in `CLTEST.cpy` feeds Set Health). `CONTROLS-SPRINT` runs every
  frame in play before the client tick (`PL-SPRINTING`; Left Control + W, no S, world screen), so
  the tick that starts sprinting already moves at 0.28. Eating (`PL-EATING`, `PL-EAT-START`) starts
  on a right press with a food item (`CL-IT-FOOD` > 0) that uses no block; `DIMENSION-ENTER` clears
  both. Item-level Player Actions (drop 5/4, release use 6) go through `CLP-ITEM-ACTION`.
- **Client US11 state**: Game Events 2, 7 and 8 set `PL-RAIN`/`PL-THUNDER` and the kind
  `PL-WEATHER` (`WX-*`); `TEST-GAME-EVENT` (CLTEST.cpy) feeds one. Weather quads need the biome's
  `RG-BIOME-PRECIP` (filled only by `REGISTRY-READ` from the biome registry, so `TEST-PLAY` worlds
  draw none) and the replica biome `RC-BIOME` (CLCELLS.cpy; `TEST-SET-BIOME`). The environment
  atlas (texture 3) repeats each image 25 times downward because the shim samples clamp-to-edge.
  The built-in pack has 94 files.
- **Calls with a refmod or an oversized area into a one-byte `PIC X` LINKAGE item of the same
  file** can still fail `-Werror=repository-checks` ("does not conform"); inline the work or pass a
  field of the callee's exact shape.
- **Client tick order** (`CL-STEP`): input, the client tick (physics, Move Player, Client Tick End),
  then `NET-PUMP`, so what a tick queues goes out in the same frame and a server reply read after
  one step sees it. `NET-PUMP` keeps its own `PB-BUFFER` for received packets and views `CN-OUT`
  through `TX-BUFFER`: never `MOVE CN-OUT TO` a buffer that also receives (it overwrote queued bytes).
- **TL-CASE is PIC X(240)**: lint (`-Werror=truncate`) rejects a longer case literal; keep case names
  short.
- **Client state** is one `CLIENT-STATE` record (client/copy/CLSTATE.cpy) passed BY REFERENCE to
  every client program (two clients can share a process); a program that needs `CL-ARGS` or
  `LANG-ARGS` in WORKING-STORAGE copies client/copy/CLARGS.cpy. `CL-START` prepares a client without
  a window; tests drive it with `CL-STEP` and assert on the screen model and the render list.
- **Texture references** come from `client/tests/fixtures/gen_textures.py` (independent stdlib
  Python, checked against the standin-content §1.5 SHA-256 values), written by the client Makefile's
  `fixtures` target before the tests.
- **Programs that never return in a test**: a test runs itself again with arguments through
  `CALL "SYSTEM"` (`FUNCTION MODULE-PATH`; the status is `RETURN-CODE / 256`), and a SIGALRM handler
  (`SET proc-pointer TO ENTRY "..."`, `signal`, `alarm`) can end a window run (`test_cl_main_run`).

## Failure handling (FR-012)

- A non-fatal failure prints one `ERROR <what>: <detail>` console line and processing continues.
- A fatal failure does `CALL STATIC "cc_fatal"` with `"<what>: <detail>"`, which prints `FATAL <what>: <detail>` and exits.
- Nothing else: no retries, dialogs or extra recovery (constitution 5.5, 5.6).

## Gates

- Each package has a gate: `make gate-<pkg>` (shim, proto, core, server, client), `make gate-contract` and
  `make gate-tools`, plus `make gate` for everything. A gate runs lint, the tests and coverage.
- Check a command's exit status directly, not through a pipe.
