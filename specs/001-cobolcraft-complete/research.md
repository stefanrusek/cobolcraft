# Research: CobolCraft, complete

**Feature**: `001-cobolcraft-complete` | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

Phase 0 output. Every decision below is binding on the tasks and implement phases unless plan.md marks it
`[NEEDS CLARIFICATION]`. Probe code and its captured output live in [spikes/](spikes/); `spikes/spike_run.sh`
re-runs every probe and rewrites the `*.out.txt` evidence files. Spikes are excluded from coverage and from
the build.

Probe environment (all spikes): macOS 26.5 (build 25F71), Apple M4 Pro, arm64, Homebrew, Xcode command line
tools (Apple clang), run 2026-11-05.

---

## R1. Toolchain and pinned dependencies

**Decision**: The repository builds with the following, installed through Homebrew on macOS arm64. Every
other dependency is part of macOS itself.

| Dependency | Version probed | Used for | Install |
|---|---|---|---|
| GnuCOBOL (`cobc`, `libcob`) | 3.2.0 | All game logic (constitution Principle I) | `brew install gnucobol` |
| Apple clang (Xcode CLT) | system | The C shim, and the C compiler `cobc` drives | `xcode-select --install` |
| GLFW | 3.5.1 (3.4 or later required, R3) | Window, input, Vulkan surface (Q1 in plan.md) | `brew install glfw` |
| Vulkan loader + headers | 1.4.363 | Vulkan API entry points | `brew install vulkan-loader vulkan-headers` |
| MoltenVK | 1.4.2 | Vulkan driver (ICD) over Metal | `brew install molten-vk` |
| glslang (`glslangValidator`), SPIRV-Tools (`spirv-val`) | 16.6.0 / 1.4.363 | Build-time GLSL to SPIR-V; shader validation in lint | `brew install glslang` |
| zlib | 1.2.12 (macOS SDK `libz`) | Compression (01 §3, 07 §5, 08 §1.1 zip) | system |
| OpenSSL | 3.6.4 (`openssl@3`, **pinned**, see below) | SHA-1, MD5, TLS for HTTPS pack downloads | `brew install openssl@3` |
| Python 3 | 3.14 (stdlib only) | Test runner, coverage and lint drivers (test infrastructure) | system/pyenv |
| gcov (llvm-cov gcov) | system | Line coverage of COBOL and C | system |
| vulkan-tools (`vulkaninfo`) | 1.4.363 | Contributor diagnostics only | `brew install vulkan-tools` |

**Rationale**: every row was probed (R2 to R10). Homebrew is the de-facto package manager on macOS and
carries every library; the same libraries exist on Linux, Windows and Android (FR-011 portability).

**Pin**: `pkg-config openssl` resolves to `openssl@4` when both are installed (observed on the probe
machine: `spike_libs.c` built against 4.1.0 headers and warned that `SSL_set1_host` is deprecated since 4.0).
The build MUST set `PKG_CONFIG_PATH=$(brew --prefix openssl@3)/lib/pkgconfig` for OpenSSL. OpenSSL 3 is
the LTS line.

**Alternatives considered**: LunarG Vulkan SDK installer (larger, manual, not scriptable through one package
manager); macOS CommonCrypto and Network.framework instead of OpenSSL (not portable to Linux/Windows/Android,
FR-011); system `libz` is kept because it is ABI-stable and present everywhere.

---

## R2. COBOL dialect, source format and COBOL-to-C calls

**Decision**:
- GnuCOBOL 3.2, `-std=default`, **free format** (`-free`, comments `*>`). Fixed format was rejected after
  `spike_fileio.cob` failed to compile because a statement ran past column 72 (fixed format silently ends
  the line at column 72; the error surfaced as "unexpected MOVE" two lines later).
- COBOL calls C with `CALL STATIC "<c_name>" USING BY VALUE <BINARY-LONG/BINARY-DOUBLE/POINTER> ...
  BY REFERENCE <buffer> RETURNING <BINARY-LONG>`. Integers are `BINARY-LONG` (C `int32_t`),
  `BINARY-DOUBLE` (C `int64_t`), floating point is `FLOAT-LONG` (C `double`) / `FLOAT-SHORT` (C `float`),
  addresses are `USAGE POINTER`.
- Wire floats and doubles are converted by `REDEFINES` of the `FLOAT-SHORT`/`FLOAT-LONG` item over `PIC X(4)`/
  `PIC X(8)` and byte reversal (arm64 is little-endian; the wire is big-endian, 00).
- Sleeping uses `CALL "CBL_GC_NANOSLEEP"`; time uses `FUNCTION CURRENT-DATE` (1/100 s resolution).
- Trigonometry uses `FUNCTION SIN/COS` (the generator of standin-content §5.2 needs `sin`/`cos`).
- Region files and every other binary file use the byte-stream routines `CBL_OPEN_FILE`, `CBL_CREATE_FILE`,
  `CBL_READ_FILE`, `CBL_WRITE_FILE` (64-bit offsets; flag 128 returns the file size), `CBL_CLOSE_FILE`,
  and `CBL_CREATE_DIR`, `CBL_DELETE_FILE`, `CBL_DELETE_DIR`, `CBL_RENAME_FILE`.
- Every COBOL build (production and test) passes `-debug` so subscript, reference-modification and other
  runtime exceptions stop the program with a message instead of corrupting memory (constitution 5.6 loud
  failure; FR-012 fatal error). There are no performance targets (spec Assumptions).

**Evidence**:
- `spikes/spike_interop.out.txt`: `ADD=+0000000042` (BY VALUE ints), `FILL-RET=+0000000008 BYTE8=000000009`
  (BY REFERENCE buffer written by C), `DOUBLE-SEEN-BY-C=1.500000` (FLOAT-LONG by reference),
  `BE-HEX=3FF8000000000000` (big-endian wire form of 1.5 by REDEFINES and reversal), `SIN1=0.84147...`,
  `CBL_GC_NANOSLEEP` returned.
- `spikes/spike_fileio.out.txt`: write of 8 bytes at offset 8192 then read back `0102030405060708`;
  unwritten region reads as zeros; size query `8200`; directory create/delete return 0.
  **`C$LIST-DIRECTORY NOT AVAILABLE`**: GnuCOBOL 3.2 has no directory enumeration (feeds Q1 in plan.md).
- `spikes/spike_modules.out.txt`: two COBOL modules linked statically into one executable with a 98,304-entry
  `BINARY-SHORT UNSIGNED` table passed through `LINKAGE`; 100 passes in about 0.07 s user time
  (informational only; no performance target exists).

**Alternatives considered**: fixed format (rejected above); calling GLFW and libc directly from COBOL
without C (rejected in R5); COBOL `ACCEPT` for console input (blocks the whole single-threaded server; R6).

---

## R3. Vulkan on macOS arm64: loader, MoltenVK and GLFW

**Decision**:
- The shim links the Vulkan loader (`libvulkan.1.dylib`) and MoltenVK is found by the loader as its ICD.
- Instance creation enables `VK_KHR_portability_enumeration` and sets
  `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`; device creation enables `VK_KHR_portability_subset`
  when the device reports it, plus `VK_KHR_swapchain`. Target API version 1.2.
- **Before `glfwInit`, the shim calls `glfwInitVulkanLoader(vkGetInstanceProcAddr)`.** GLFW otherwise
  dlopens `libvulkan` from the default dyld search path only, which does not include Homebrew's
  `/opt/homebrew/lib`, and then reports Vulkan as unsupported. Requires GLFW 3.4 or later.
- Swapchain extent comes from the surface capabilities (framebuffer pixels), not the window size: on a
  Retina display a 320 x 240 window had a 640 x 480 surface. Mouse coordinates from GLFW are in window
  units; the shim reports both sizes.
- Present mode FIFO (always available). Format: the surface's first reported format (44 =
  `VK_FORMAT_B8G8R8A8_UNORM` on the probe machine).

**Evidence**:
- `spikes/spike_vulkan_glfw.out.txt` (with handoff): `vulkanSupported=1`, required instance extensions
  `VK_KHR_surface`, `VK_EXT_metal_surface`; instance creation **without** the portability flag returned
  `-9` (`VK_ERROR_INCOMPATIBLE_DRIVER`); device "Apple M4 Pro api 1.2.357" reports
  `VK_KHR_portability_subset`; surface, device, 2-image swapchain created; one frame cleared and presented
  (`present -> 0`).
- Same file, "without handoff": `vulkanSupported=0` and `glfwCreateWindowSurface -> -3`.
- `vulkaninfo --summary` lists MoltenVK's instance extensions including `VK_EXT_metal_surface` and
  `VK_KHR_portability_enumeration`.

**Portability (FR-011)**: on Linux/Windows/Android the same code path works without the portability flag
being required; GLFW (or the platform window on Android) supplies the surface. All of it is inside the shim.

**Alternatives considered**: LunarG SDK `vulkan.framework` with rpath (manual install); linking MoltenVK
directly without the loader (loses validation layers and portability to other ICDs); SDL3 instead of GLFW
(SDL3 is installed on the probe machine and would also work; GLFW is smaller, single-purpose and its
callback API maps directly onto the event queue of contract `shim-abi.md`).

---

## R4. Renderer architecture (COBOL builds geometry, the shim only submits)

**Decision**:
- All rendering decisions are COBOL: resource-pack loading, JSON and PNG decoding, atlas stitching, model
  baking, chunk-section meshing with face culling (standin-content §1.1 lucite rule), per-face shading and
  light baked into vertex colour, entity and ground-item geometry, sky colour, weather overlay geometry, the
  2-D user interface (text from the pack font, hotbar, bars, menus).
- The shim's Vulkan module is a fixed-function submitter (contract `shim-abi.md`, `cc_vk_*`): upload an RGBA
  atlas, upload/replace/free a vertex buffer in a numbered slot, begin a frame with a clear colour, draw a
  slot in one of three fixed pipelines (`opaque`, `translucent`, `ui`) with a 4 x 4 matrix as a push
  constant, end the frame. Two fixed shader pairs (world, ui) are written in GLSL and compiled to SPIR-V at
  build time (build scripts may use any language; the shaders contain no game logic).
- Vertex layout (28 bytes): position `float32 x3`, texture coordinate `float32 x2`, brightness `float32`,
  alpha multiplier `float32`.
- Textures sampled with NEAREST filtering, clamp-to-edge; depth `D32_SFLOAT`, compare LESS; translucent
  pipeline uses alpha blending with depth write off and is drawn after opaque, back to front by section.
- Missing-texture stripes (standin-content §1.4) are generated by COBOL and stitched into the atlas like any
  sprite; they are not a pack file (FR-003).

**Evidence**: `spikes/spike_pipeline.out.txt`: pipeline created from build-time SPIR-V with vertex input
(pos3 + uv2), a 64-byte push-constant mat4 (`maxPushConstantsSize=4096`), a combined image sampler (16 x 16
RGBA, NEAREST), depth D32_SFLOAT with LESS, alpha blending, triangle list; offscreen render read back
`centre pixel=7D7F86FF` (the greystone fill colour) and `corner pixel=000000FF` (clear colour).
`spikes/spike_shader.out.txt`: `glslangValidator -V` output passes `spirv-val`.

**Rationale**: Principle I keeps the shim free of game logic; drawing "what" is decided in COBOL, the
shim decides only "how to submit to Vulkan". The same split makes the client's render output testable in
COBOL without a GPU (R9: tests inspect the render list) while the shim's submit path is tested against the
real GPU.

**Alternatives considered**: meshing in C (game logic in the shim, violates Principle I); one generic
"draw call list" API with arbitrary pipeline state (larger shim surface, nothing needs it).

---

## R5. Platform boundary for windowing, input, directory listing and console input

**Finding**: Principle I lists the shim capabilities as "Vulkan, sockets, zlib, and cryptography". Four
capabilities the spec requires are not on that list and cannot be reached from COBOL without C:

| Capability | Needed by | Why COBOL cannot reach it directly |
|---|---|---|
| A window, its Vulkan surface, keyboard/mouse/scroll/text input, cursor capture | US2 to US18 (every on-screen story) | GLFW delivers typed text, scroll and key events only through C callbacks; a Vulkan surface needs a native window. |
| Directory enumeration | US16 (world list, delete world), US18 (packs folder) | `C$LIST-DIRECTORY` is not in GnuCOBOL 3.2 (`spike_fileio.out.txt`); `opendir`/`readdir` return a platform-specific `struct dirent` layout. |
| Non-blocking console line input | US15 (server console while serving players) | `ACCEPT` blocks the single-threaded server loop. |
| Local network addresses | US17 ("the game shows the address others can join at") | `getifaddrs` returns linked C structures. |

**Decision (pending operator)**: plan.md raises this as open decision **Q1**. The design in
`contracts/shim-abi.md` assumes the recommended option (amend Principle I to list "windowing and input",
"directory enumeration" and "console input" as shim capabilities, and read "local addresses" as part of
"sockets"); every such function is isolated in its own shim module (`cc_win`, `cc_fs`, `cc_con`, `cc_net`) so
the decision changes only which modules are allowed, not the COBOL design.

**Alternatives considered** (listed in Q1): COBOL calling GLFW and libc directly, polling keys without
callbacks (loses typed text for chat and scroll for the hotbar, and puts platform struct layouts in COBOL,
contrary to FR-011's narrow-boundary rule); writing helper processes in another language (not allowed:
"build scripts and test harnesses MAY use any language" does not cover shipped programs).

---

## R6. Process model: one thread, one event loop per program

**Decision**:
- Server: one thread. Each loop iteration: `cc_net_poll` waits up to the time left until the next tick on
  the listener, every connection and the console (stdin); accepted bytes are fed to the core; the core runs
  every due 50 ms tick (20 ticks per second, the rate 05b Ticking State and 01 §7.5 keep-alive timing assume);
  outbound bytes are flushed.
- Client: one thread. Each frame: poll window events (`cc_win_poll`), apply input, poll the network
  connection without waiting, run due core ticks when hosting a single-player world (R7), build and submit
  the frame (FIFO present paces the loop).
- Pack downloads (US18) run inside the same loop as non-blocking HTTP or HTTPS state machines (R10).

**Rationale**: COBOL has no portable threads; a single loop avoids every shared-state hazard and is enough
because no performance target exists.

---

## R7. Single-player and "open to others": the core runs inside the client

**Decision**:
- The game rules, world, persistence, commands and the server side of the protocol live in the **core**
  package (COBOL). The server program and the client both link it.
- Single-player (US16): the client opens the world with the core and connects to it through an
  **in-memory connection**: the same packet bytes as a network connection, passed through buffers instead of
  a socket, with neither compression nor encryption (02, Offline mode: "Encryption and compression are also
  never used on in-memory (singleplayer) connections"). Everything else (status is not used; login,
  configuration and play) is identical, so the client has one protocol code path.
- Open to others (US17): the client starts the core's TCP listener (the same code the server program uses)
  on an ephemeral port chosen by the operating system, and shows `<local address>:<port>` for each non-loopback
  IPv4 address. Joining guests are ordinary network connections of the same core.
- Pausing (US16 scenario 4): while the pause menu is open and the world is not open to others, the client
  does not run core ticks.

**Evidence**: 02 "Offline mode" paragraph (read 2026-11-05). In-process linking is proven by
`spike_modules.out.txt` (multiple COBOL modules in one executable).

**Handoff item confirmed**: "Single-player (US16) is plausibly an in-process server sharing the server's
game logic" and "Opening to others (US17) would then start that server's network listener".

---

## R8. World storage layout and per-player data

**Decision**: one world folder holds everything (FR-004). Layout, NBT schemas and file names are fixed in
[contracts/world-folder.md](contracts/world-folder.md). Summary:

```text
<world>/
  level.dat                                   gzip NBT: world name, data version 5023, time of day, spawn, per-dimension weather
  access.dat                                  gzip NBT: operators, bans, allow-list (offline identities)
  players/<offline-uuid>.dat                  gzip NBT: dimension, position, rotation, game mode, health, food, inventory
  dimensions/<namespace>/<path>/region/r.<x>.<z>.mca     chunks (07 §6, §7)
  dimensions/<namespace>/<path>/entities/r.<x>.<z>.mca   mobs and ground items (07 §8)
```

Writes are made only on save (autosave is not specified; the `save` command, clean stop and quitting a
single-player world save). FR-012: no crash-safety behaviour is specified, so files are written in place.

**Docs-first (FR-005, constitution Principle II)**: 07 covers NBT, region files, chunk NBT and names the
`entities/` folder but defines no `level.dat`, player or access files, no entity NBT and no per-dimension
folder rule. These are a documentation gap; the Foundational phase transcribes `contracts/world-folder.md`
into a new `docs/protocol/07-nbt-and-anvil.md` section 9 before any persistence code is written.

**Handoff item confirmed**: "Per-player stored data ... are not covered by 07's region-file sections" and
"Mobs and ground items likely go in 07 §8's `entities/` region folder; extra dimensions need a
per-dimension folder layout".

---

## R9. Test strategy, harness, coverage and lint

**Decision**:

| Concern | Decision |
|---|---|
| Unit of test | A test program: a COBOL program (`*.cob`) for COBOL code, a C program for shim code. Each test program contains one or more test cases. |
| Naming | `acc_<story>_<topic>.cob` for acceptance tests (one or more cases per acceptance scenario), `contract_<seam>_<side>.cob`/`.c` for contract tests, `test_<unit>.cob`/`.c` for implementation tests. Gherkin is not available for COBOL, so acceptance case names contain "acceptance" and Given/When/Then (constitution 4.1 fallback), for example `acceptance US4-2 given a held block when place on a face then block appears in default state`. |
| Assertion library | `tools/testlib/` (test infrastructure, excluded from coverage): COBOL copybook `TESTLIB.cpy` and program `TEST-ASSERT`, C header `testlib.h`. Every case prints exactly one line: `TEST <case name> PASS` or `TEST <case name> FAIL expected=<x> observed=<y>`. |
| Runner | `tools/runtests.py` (stdlib Python): builds and runs every test program of the selected packages, parses the lines, prints each failing case with expected and observed, prints `passed <n> failed <m>`, exits 1 if any failed or any test program exited non-zero (US1 scenarios 2 and 3). |
| Coverage | COBOL: `cobc --coverage`; gcov writes per-`.cob` line counts (`#####` = never executed). C: `clang --coverage`, same gcov format. `tools/coverage.py` runs gcov over every production source file of the selected packages after the tests and fails on any `#####` line (constitution 4.2: 100 %). Excluded paths: `*/tests/**`, `tools/**`, `specs/**`. |
| Lint | COBOL: `cobc -fsyntax-only -free -Wall -Werror`; C: `clang -fsyntax-only -std=c11 -Wall -Wextra -Werror`; GLSL: `glslangValidator -V` + `spirv-val`; Python: `python3 -m py_compile`. |
| Typecheck and build (gate 7) | `cobc` and `clang` compilation of every touched package with the flags above; a COBOL program that is not compiled was not type-checked. |
| GPU-dependent tests | Shim `cc_vk_*` and `cc_win_*` tests run against the real MoltenVK and a real hidden GLFW window (no test double). They need a logged-in macOS session with a GPU, which every supported Contributor machine has (FR-011). |
| Client render assertions | Client tests call the COBOL frame builder and assert on the **render list** and **screen model** it produces (contract `client` data in data-model.md); no GPU needed. Texture correctness (SC-004) is asserted on the RGBA bytes of the stitched atlas against `tools/fixtures/textures/*.rgba`, produced by an independent Python implementation of the standin-content §1.4 recipes (test infrastructure). |
| HTTP/HTTPS tests | `tools/testsrv/` (test infrastructure): a loopback HTTP and HTTPS server in stdlib Python with a throwaway test CA; client download tests set the **standard OpenSSL environment variable** `SSL_CERT_FILE` to that CA, so no shipped code exists only for tests (constitution 3.4). |

**Evidence**:
- `spikes/spike_coverage.out.txt`: gcov produced per-COBOL-line counts for `spike_coverage.cob`: executed
  lines `1:`, the untaken `ELSE` branch and the unused paragraph `#####:` (lines 10, 16, 17).
- `spikes/spike_lint.out.txt`: `-Wall -Werror` accepts a truncating `MOVE` (exit 0); `-Wall -Wextra -Werror`
  rejects it (`possible-truncate`, exit 1). The lint command uses `-Wall -Werror` because `-Wextra`'s
  `possible-truncate` fires on every narrowing `COMPUTE`, which COBOL code does deliberately; the decision is
  recorded here so it is not a suppression.
- `spikes/spike_libs.out.txt`: `SSL_CERT_FILE=/dev/null` makes verification fail (`verify=20 unable to get
  local issuer certificate`) while the default store verifies `example.com` (`verify=0 (ok)`,
  `HTTP/1.1 200 OK`), so the environment variable controls the trust store without code.
- `spikes/spike_pipeline.out.txt`: offscreen render and readback works, so shim tests can assert pixels.

**Alternatives considered**: COBOL Check / cobol-unit-test (Java-based, adds a JVM, no coverage
integration); Python `behave` driving COBOL drivers (a second process boundary per assertion, and Gherkin
adds nothing COBOL tests cannot name); a test-only offscreen mode in the client (shipped behaviour only for
tests, forbidden by 3.4).

---

## R10. Resource pack download over HTTP and HTTPS

**Decision**: the client implements an HTTP/1.1 GET client in COBOL (request line, the headers of 08 §9.3,
`Content-Length` and `Transfer-Encoding: chunked` responses, status 200 only is success) over `cc_net_*`
for `http` URLs and over `cc_tls_*` (OpenSSL, system trust store via `SSL_CTX_set_default_verify_paths`,
TLS 1.2 minimum, host name verification) for `https` URLs. SHA-1 via `cc_sha1`. Cache per 08 §9.4.
Redirects: 08 does not state redirect behaviour; a non-200 status is a failed download (08 §9.2 "HTTP
error"). The size limit (08 §9.3) is checked against `Content-Length` and while streaming.

**Evidence**: `spikes/spike_libs.out.txt`: TLS 1.3 handshake, verification `ok`, `HTTP/1.1 200 OK` from
`example.com:443`; SHA-1 of `abc` = `a9993e36...d89d` (the published test vector).

**Constitution fit**: TLS is cryptography (Principle I list); HTTP itself is plain COBOL over sockets.
**Handoff item superseded**: "neither HTTP nor TLS is on the constitution's shim list" — HTTP needs no
shim; TLS falls under "cryptography".

---

## R11. Offline identity and crypto primitives

**Decision**: the offline UUID (02, Offline mode) is computed with `cc_md5` over `"OfflinePlayer:" + name`
(UTF-8), then the version-3 and variant bits are set in COBOL. No encryption, no compression on in-memory
connections, compression on network connections per 01 §3 with the server's threshold (decided in
`contracts/wire-profile.md`: threshold 256).

**Evidence**: `spikes/spike_libs.out.txt`: `offline-uuid(Notch)=b50ad385829d3141a2167e7d7539ba7f`, which
is the well-known offline UUID for that name (b50ad385-829d-3141-a216-7e7d7539ba7f), so MD5 plus bit setting
is correct. zlib-wrapped deflate (`header=789c`), raw inflate (zip entries) and gzip (`magic=1f8b`, 07 §5.1)
all round-trip.

---

## R12. Protocol usage profile for the new gameplay (FR-005)

**Decision**: CobolCraft's game semantics on top of protocol 777 are fixed in
[contracts/wire-profile.md](contracts/wire-profile.md) and transcribed into a new
`docs/protocol/09-cobolcraft-profile.md` in the Foundational phase. The key mappings, each checked against
05a/05b/05c on 2026-11-05:

| Need | Packets (verified ids) |
|---|---|
| Unsigned chat and commands (FR-010) | 05c Chat 0x09 with absent signature; Chat Command 0x07 (unsigned form: "the form used when no argument needs a signature"); 05c "Signed chat": servers that do not enforce secure chat accept unsigned chat. Server never sends Chat Session data; broadcast via System Chat 05b 0x7C (124). |
| Command tree and suggestions (US14-1) | 05a Commands 0x10 (16), Command Suggestions 0x0F (15); 05c Command Suggestion 0x0F (15). Parsers used: `brigadier:integer` (3), `brigadier:double` (2), `brigadier:string` (5, single word and greedy), `game_profile` (7) with custom suggestions `minecraft:ask_server` for player and dimension names. |
| Health, food, death, respawn (US7, US8) | 05b Set Health 0x6A (106), Respawn 0x54 (84), 05a Player Combat Kill 0x45 (69) (death screen message), 05c Client Command 0x0C (12) (perform respawn), 05a Damage Event 0x19 / Hurt Animation 0x2B (seeing that they were hurt). |
| Ground items (US5) | 05a Add Entity 0x01 with `cobolcraft:loose_item`, 05b Set Entity Data 0x65 (item stack metadata, 00 §12), Take Item Entity 0x7F (127), Remove Entities 0x4E (78), Set Entity Motion 0x67, Teleport Entity 0x80; 05c Player Action 0x29 drop-item / drop-stack statuses for throwing. |
| Crafting (US10) | 05b Recipe Book Add 0x4B (75) to list every recipe with its display; 05c Place Recipe 0x27 (39) as the "craft one" request; result through Container Set Slot 05a 0x14 / Set Player Inventory 05b 0x6E. |
| Weather (US11) | 05a Game Event 0x27 (39): START_RAINING (1), STOP_RAINING (2), RAIN_LEVEL_CHANGE (7), THUNDER_LEVEL_CHANGE (8). Each original weather kind is assigned a (rain level, thunder level) pair; the client derives the kind from the pair. Biome `has_precipitation` (04 §4.3) selects where a kind shows. |
| Dimensions (US12) | 05a Login 0x32 dimension-names list holds every enabled dimension; 05b Respawn 0x54 on travel; further `dimension_type` and `worldgen/biome` registry entries in configuration (04). |
| Mobs (US9) | Add Entity 0x01, Move Entity 0x36/0x37/0x39, Rotate Head 0x55, Remove Entities 0x4E, Entity Event 0x22 / Hurt Animation 0x2B; 05c Attack 0x01 (attacks on mobs and players; "Attacks have their own packet (0x01)", 05c 0x1A). |
| Eating (US8) | 05c Use Item 0x43 starts eating; 05c Player Action 0x29 `RELEASE_USE_ITEM` (6) before the eating time ends cancels it; the server completes the meal after the eating time. |
| Throwing (US5-3) | 05c Player Action 0x29 `DROP_ITEM` (5) one item, `DROP_ALL_ITEMS` (4) whole stack. |

**Handoff items**: signed-chat (confirmed: unsigned allowed), command tree vocabulary (confirmed: the
parsers above suffice), health/respawn ids (confirmed), crafting (decided: recipe-book packets plus Place
Recipe, not a crafting-grid container), weather (confirmed fits Game Event rain/thunder slots; superseded
"need a different signal": no new signal is needed), dimension change (confirmed: Respawn), ground items
(confirmed: Take Item Entity and entity metadata).

---

## R13. Content and asset documentation gaps (FR-015, FR-005)

**Decision**: the Foundational phase extends the docs before any code that depends on them:

| Document | Addition | Driven by |
|---|---|---|
| `docs/design/standin-content.md` | New sections for ground-item rules, health and death, hunger and food items, mobs, recipes, weather, extra dimensions, command set (exactly the FR-015 list), §1.3 updated so survival yields drop as ground items, §3 `loose_item` made non-optional, §4.3/§4.6/§4.7 entries added, and an original 8 x 8 bitmap font (glyph rows for ASCII 32 to 126). | FR-015, FR-002, FR-003 |
| `docs/protocol/08-resource-packs.md` | §10 extended with the new item textures, entity textures (`textures/entity/<mob>.png`), weather textures (`textures/environment/<kind>.png`), the font (`font/default.json` with one `bitmap` provider, `textures/font/ascii.png`) and lang keys for every new name and message; §8 font row changed from "later" to required; Open questions 4 and 6 answered with CobolCraft's own rule (our renderer's element-rotation order and default-UV formula), which the built-in pack depends on. | FR-003, SC-004, SC-005, US18-3 |
| `docs/protocol/07-nbt-and-anvil.md` | New §9 from `contracts/world-folder.md`. | FR-004, FR-014 |
| `docs/protocol/09-cobolcraft-profile.md` (new) | From `contracts/wire-profile.md`. | FR-001, FR-005 |

All content is original and in the `cobolcraft:` namespace (FR-015); the Foundational task text names the
constraints of FR-015 for each section. Content authoring is a document deliverable: it is verified by
review (constitution 4.1), not by tests.

**Handoff items**: "mob appearance needs entity model and texture handling ... that 08 does not yet
describe" (confirmed; resolved above); "08 Open question 4 and 6 affect the renderer's model baking"
(confirmed; resolved above); "standin-content §4.8 ... `world_clock`" (FR-002 keeps it; confirmed no action);
"standin-content §5.2's light policy is deliberately crude; the renderer still needs a per-face brightness
policy" (confirmed; decided in data-model.md "Render list": top 1.0, north/south 0.8, east/west 0.6,
bottom 0.5, multiplied by max(sky, block light)/15 with a floor of 0.1).

---

## R14. Failure classification (FR-012)

**Decision**: failures not covered by `docs/protocol/` or the spec's scenarios are classified as follows.
Each logs one line to the program's console (`stdout` for the server, the launching terminal for the
client) naming what failed.

| Failure | Class | Behaviour |
|---|---|---|
| A single connection's socket error or malformed packet (server, open-to-others host) | Non-fatal | That connection is closed (01 disconnect rules apply where defined); serving continues. |
| Client's own connection fails (connect refused, DNS failure, socket error) | Non-fatal | Logged; the client returns to the server list. |
| Invalid value in the server configuration file | Fatal | Logged; server exits with status 1. |
| Client started without `--name` or with a name 02 rejects | Fatal | Logged; client exits with status 1. |
| A world file that cannot be read or parsed | Fatal | Logged; program exits (server) or the game shuts down (client). |
| Vulkan, window or GPU initialisation or device-lost error | Fatal | Logged; client exits. |
| A file write that fails during save | Fatal | Logged; program exits. |
| Saved client data file unreadable (server list, options, pack order) | Fatal | Logged; client exits. |
| Unspecified runtime exception (`-debug` checks, C `abort`) | Fatal (platform default) | Runtime message, non-zero exit (constitution 5.6). |

**Rationale**: FR-012 allows only these two outcomes; the class is the plan's call based on whether the
program can go on. Pack-related failures are excluded because 08 §2.3 and §9 define them.

---

## R15. Deferred-work tracking mechanism (constitution 1.4)

**Finding**: the repository has no git remote (`git remote -v` is empty), therefore no issue tracker, and
no debt log or equivalent file exists. No discovery made in this plan phase needs deferral: every gap found
is incorporated into this feature (R5 via Q1, R8, R12, R13). Because later phases of an 18-story feature are
likely to meet a discovery that must be deferred (a fix that changes specified behaviour), plan.md raises
open decision **Q3** so the operator establishes the mechanism before implementation, rather than
an implement phase halting mid-run (constitution 1.4: the plan phase must not invent a convention).

---

## R16. Test infrastructure detection (constitution 3.4) and E2E inventory (4.3)

**Finding**: nothing exists yet: no build files, no test framework, no CI configuration, no remote. All of
the infrastructure in R9 is missing and is created by Setup and Foundational tasks that precede every story
task (plan.md "Infrastructure setup"). The project has no CI; constitution 5.4 gates run locally through the
`make` targets, which is also the only verification surface the spec names (US1, SC-001). CI is not
required by the spec and needs a remote that does not exist.

**E2E inventory**: the repository has no existing E2E journeys. No new journey is proposed: every
acceptance scenario is provable lower on the ladder (implementation, acceptance and contract tests in the
owning package, and in-process cross-package acceptance tests through the client's in-memory single-player
host in the Convergence phase). The real public entry points (a person at the game window, an operator at
the console) are exercised by the Contributor's manual quickstart walk-through, which is documentation, not
a test. Empty inventory: no E2E environment is stood up (constitution 4.3 "Execution timing").

---

## Plan-Phase Handoff verification record (constitution 2.6)

| # | Handoff item (spec.md "Plan-Phase Handoff") | Outcome | Where |
|---|---|---|---|
| 1 | Windowing and input vs the shim boundary, possibly a constitution question | **Confirmed**; raised as Q1 | R5, plan.md Q1 |
| 2 | macOS Vulkan through MoltenVK; keep loading and surface creation portable | **Confirmed**, with the GLFW loader handoff and portability flags | R3 |
| 3 | Chat and commands unsigned with offline identity | **Confirmed** (05c Chat Command 0x07, "Signed chat") | R12 |
| 4 | Command suggestions map onto Commands / Command Suggestions | **Confirmed**; parser subset chosen | R12, contracts/wire-profile.md |
| 5 | Health/hunger/respawn packets; crafting via recipe book or a container | **Confirmed** ids; crafting **decided**: recipe-book packets + Place Recipe | R12 |
| 6 | Weather via Game Event rain/thunder and `has_precipitation` | **Confirmed**; "different signal" **refuted** | R12 |
| 7 | Extra dimensions: dimension_type entries, Login names, Respawn | **Confirmed** | R12 |
| 8 | Ground items: `loose_item`, Take Item Entity, entity metadata | **Confirmed** | R12 |
| 9 | Single-player as in-process server; open-to-others starts its listener; no LAN discovery | **Confirmed** | R7 |
| 10 | Mobs need entity packets and new entity types; mob appearance needs an 08 addition | **Confirmed** | R12, R13 |
| 11 | Player data, weather, server lists need an on-disk design; mobs/items in `entities/`; per-dimension folders | **Confirmed** | R8 |
| 12 | `world_clock` doubted; FR-002 keeps it | **Confirmed** (kept, no action) | R13 |
| 13 | Renderer needs a per-face brightness policy | **Confirmed**; decided | R13, data-model.md |
| 14 | 08 Open questions 4 and 6 affect model baking | **Confirmed**; resolved docs-first with CobolCraft's own rule | R13 |
| 15 | Pack download needs HTTP and HTTPS; neither on the shim list | **Superseded**: HTTP is COBOL over sockets; TLS is cryptography | R10 |
| 16 | Sounds would need `sounds.json` and audio output | **Confirmed out of scope** (spec Assumptions); no action | — |
