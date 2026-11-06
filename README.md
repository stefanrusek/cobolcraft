# CobolCraft

A block-building game client and game server written in COBOL, with a thin C layer for the
operating system, windowing, Vulkan graphics, networking and compression.

This document is for Contributors (how to build both programs and run their tests from a terminal),
Server operators (running the server) and Players (running the client). For a full end-to-end walk
through every feature, see [`specs/001-cobolcraft-complete/quickstart.md`](specs/001-cobolcraft-complete/quickstart.md).

## Supported platform

macOS on Apple silicon (arm64). This is the only platform the programs are built and tested on for
now; Linux, Windows and Android are follow-up platforms.

## Prerequisites

Install the Xcode command line tools (for `clang` and `gcov`) and [Homebrew](https://brew.sh), then
the rest with one command:

```sh
xcode-select --install
brew install gnucobol glfw molten-vk vulkan-loader vulkan-headers glslang openssl@3 pkg-config
```

| Tool | Used for |
|---|---|
| GnuCOBOL 3.2 (`cobc`) | All game code |
| Apple clang | The C layer, and the C compiler `cobc` drives |
| GLFW 3.4 or later | Window and input |
| Vulkan loader and headers, MoltenVK | Graphics (MoltenVK runs Vulkan over Metal) |
| glslang (`glslangValidator`, `spirv-val`) | Compiling and checking the shaders |
| OpenSSL 3 (`openssl@3`) | SHA-1, MD5 and HTTPS. The build uses OpenSSL 3 even when a newer OpenSSL is also installed. |
| zlib (part of macOS) | Compression |
| Python 3 | Test runner, coverage and lint drivers (standard library only) |
| gcov (part of the command line tools) | Line coverage |

## Commands

Run every command from the repository root.

| Command | What it does |
|---|---|
| `make bootstrap` | Checks every prerequisite above. If one is missing it names it, prints the install line and exits 1. Otherwise it creates `build/` and compiles the shaders. Run it once after cloning. |
| `make` | Builds the client `build/bin/cobolcraft` and the server `build/bin/cobolcraft-server`. |
| `make test` | Builds and runs the tests of every package, then prints the counts of passed and failed cases. |
| `make lint` | Checks every COBOL, C, shader and Python source. |
| `make coverage` | Runs the tests with coverage instrumentation, then fails if any line of production code was never executed. |
| `make gate` | `make lint`, `make`, `make coverage` and the tests of the build tools. Run it before you commit. |
| `make gate-<package>` | The same for one package: `shim`, `proto`, `core`, `server`, `client` or `tools`. |
| `make gate-contract` | Checks the shared interface definitions in `contract/`: every wire fixture parses, every header and copybook compiles, and they lint. |
| `make clean` | Removes `build/`. |

A fresh checkout goes:

```sh
make bootstrap
make
make test
```

## Running the server

`build/bin/cobolcraft-server` takes no arguments and works in the current directory: it reads
`./cobolcraft-server.conf` and keeps its world in `./world/`, so start it from the directory the
server should live in:

```sh
mkdir -p ~/cobolcraft-server && cd ~/cobolcraft-server
<repo>/build/bin/cobolcraft-server
```

The first start creates the world and prints `Created new world in ./world`; once it listens it prints
`Ready: accepting players on 0.0.0.0:25565`. Every console line starts with the time, `[HH:MM:SS] `.

### Configuration

When `cobolcraft-server.conf` is missing the server writes it with the defaults, each key after a one-line
comment. One `key=value` per line; `#` starts a comment; a missing key takes its default.

| Key | Values | Default |
|---|---|---|
| `port` | 1 to 65535 | `25565` |
| `default-game-mode` | `creative`, `survival` | `creative` |
| `description` | text, up to 256 characters (shown in the server list) | `A CobolCraft server` |
| `view-distance` | 2 to 32 chunks | `8` |
| `player-combat` | `true`, `false` | `true` |
| `hostile-mobs` | `true`, `false` | `true` |
| `weather-changes` | `true`, `false` | `true` |
| `extra-dimensions` | `true`, `false` | `true` |
| `allow-list` | `true`, `false`: enforcement for a newly created world (an existing world keeps its own setting, changed with the `guestlist` command) | `false` |
| `pack-url` | `http://…` or `https://…` address of a resource pack zip to offer, or empty for no offer | empty |
| `pack-sha1` | the zip's SHA-1, 40 hex digits (`shasum -a 1 pack.zip`), or empty | empty |
| `pack-id` | a UUID, or empty: then it is derived from `pack-url` and `pack-sha1`, so a new pack version gets a new id | empty |
| `pack-required` | `true`, `false`: players who decline the pack are disconnected | `false` |
| `pack-prompt` | message shown with the offer, or empty | empty |

An unknown key or an invalid value stops the server at once with
`FATAL configuration: <key>: <problem>` and exit status 1.

### Console

The console shows players joining (`<name> joined`), leaving (`<name> left`), changing dimension, dying and
chatting. Every line typed at the console is a command, without a leading `/`, run with operator
permission; its answer is printed. `howto` lists all commands; a few common ones:

| Command | Effect |
|---|---|
| `roster` | Lists the players online |
| `promote <player>` / `demote <player>` | Grants or revokes operator status |
| `mode <player> survival` / `mode <player> creative` | Sets a player's game mode |
| `eject <player> [<reason>]`, `bar <player>`, `unbar <player>` | Disconnects or bans a player |
| `guestlist on` / `off` / `add <player>` / `remove <player>` / `show` | The allow-list |
| `skies <dimension> clear\|drizzle\|hailstorm [<seconds>]` | Sets the weather |
| `persist` | Saves the world now |
| `shutdown` | Saves, disconnects every player with the stopping message, prints `Stopped` and exits 0 |

The complete command set, with who may use each command, is §16 of
[`docs/design/standin-content.md`](docs/design/standin-content.md). End of input on the console
does not stop the server; use `shutdown`.

## Running the client

```sh
build/bin/cobolcraft --name <name> [--gamedir <path>]
```

`--name` is required: your player name, 1 to 16 letters, digits or `_`. `--gamedir` is where the client
keeps its data (default `~/.cobolcraft`, created if absent):

| Path | Contents |
|---|---|
| `servers.dat` | the server list |
| `options.dat` | the enabled resource packs, in order |
| `resourcepacks/` | your resource packs: `<name>.zip` files and `<name>/` folders |
| `saves/<folder>/` | single-player worlds |
| `downloads/` | resource packs downloaded from servers (a cache) |

From the title screen, **Multiplayer** opens the server list: add a server by its address (`host` or
`host:port`, default port 25565); each entry shows its description and players online; select one and
join. **Single-player** lists your worlds. **Resource Packs** opens the pack screen.

### Controls

| Control | Binding |
|---|---|
| Move forward / back / left / right | W / S / A / D |
| Sprint | Hold Left Control while moving forward |
| Jump; fly up (creative, flying) | Space |
| Fly on or off (creative) | Space twice within 0.3 s |
| Descend (flying) | Left Shift |
| Look | Mouse |
| Break / attack | Left mouse button (hold to break in survival) |
| Place / use / toggle a glowtube / eat (hold) | Right mouse button |
| Hotbar slot | 1 to 9, scroll wheel |
| Inventory | E |
| Crafting | C |
| Throw one / throw the stack | Q / Ctrl+Q (in the inventory screen: from the slot under the pointer) |
| Throw what you carry (inventory screen) | Drag or click it outside the window (right click: one item) |
| Chat / command | T / `/` (opens chat with `/` typed) |
| Pause menu | Escape |

While chat is closed, the 10 most recent messages show for 10 seconds each; with chat open, the scroll
wheel moves back through the last 100.

### Single-player and opening to others

**Single-player** on the title screen lists your worlds: create one (name, survival or creative), open
it, or delete it after confirming. A single-player world is the same game as a server with the default
settings, and you may use every command in it. Escape pauses it; **Save and Leave the World** saves it and
returns to the title screen, and it opens again as you left it.

**Open to Others** on the pause menu lets other players join your world over the network: choose the
guest game mode and whether guests may use operator commands, then **Open the World**. The screen shows
`Others can join at <address>:<port>`; another player adds that address to their server list and joins.
Pausing no longer pauses the world while it is open. When you leave the world it is saved and every guest
is disconnected.

A single-player world folder (`saves/<folder>`) can be copied to a server directory as `world/` and served,
and a server's `world/` can be copied into `saves/` and played: the format is the same.

### Resource packs

Put a pack in `<gamedir>/resourcepacks/`, as a folder or a `.zip`, with a `pack.mcmeta` at its top
(format 97). The **Resource Packs** screen lists the packs; enable them and order them there (the top
pack wins). A pack replaces textures, models, fonts and texts by path; anything it leaves out comes from
the packs below it and the built-in pack. A pack that cannot be used is listed with the reason.

When a server offers a pack you are asked whether to use it (or the server list entry's choice applies);
an accepted pack is downloaded, checked against its hash, cached in `downloads/`, and applied above your
own packs until you disconnect. Declining a required pack disconnects you with the server's message.

## Failures

Both programs report problems on their console:

- `ERROR <what>: <detail>`: something failed but the program carries on (for example a lost connection,
  after which the client returns to the server list, or a resource pack the client could not fully use).
- `FATAL <what>: <detail>`: the program cannot go on and exits with status 1 (for example
  `FATAL arguments: …` for a missing or invalid `--name`, or `FATAL configuration: …` for a bad server
  configuration value).

Nothing else is retried or recovered.

## Reading test output

`make test` prints one line for every failing test case and ends with the totals:

```text
FAIL acceptance US4-2 given a held block when place on a face then block appears expected=12 observed=0
passed 341 failed 1
```

Each `FAIL` line names the case, then what the test expected and what it observed. A test program
that crashes counts as one failure named after the program (for example
`FAIL core/tests/test_world expected=exit 0 observed=signal 11`), followed by its error output.
The command exits 0 only when nothing failed.

`make coverage` prints one `UNCOVERED <file>:<line>` line for every production line no test
executed. Production code is everything under `shim/src`, `proto/src`, `core/src`, `core/copy`,
`server/src` and `client/src`; tests, `tools/` and `specs/` are not counted.

## Repository layout

| Directory | Contents |
|---|---|
| `shim/` | The C layer, built into `build/shim/libccshim.a`; shaders in `shim/shaders/` |
| `proto/` | The network protocol codec (COBOL), `build/proto/libproto.a` |
| `core/` | The game itself (COBOL), shared by server and client, `build/core/libcore.a` |
| `server/` | The server program |
| `client/` | The client program |
| `contract/` | Shared interface definitions: C header, COBOL copybooks, wire fixtures |
| `tools/` | Build and test tooling: test runner, coverage, lint, bootstrap, test libraries |
| `docs/` | Protocol and game design documents |

Every package has its own `Makefile` with the targets `lib`, `tests` and `lint` (and `bin` for
`server` and `client`), and its tests in `<package>/tests/`.

## Writing tests

A test is a program in `<package>/tests/` named `acc_<story>_<topic>` (acceptance test),
`contract_<seam>_<side>` (contract test) or `test_<unit>` (implementation test), with `.cob` or, in
`shim/`, `.c`. Each case prints one line, `TEST <case> PASS` or
`TEST <case> FAIL expected=<x> observed=<y>`:

- COBOL: `COPY TESTLIB.` in working storage, fill `TL-CASE`, set `TL-TEXT` or `TL-NUMBER`, fill
  `TL-EXPECTED`/`TL-OBSERVED` (text) or `TL-EXPECTED-N`/`TL-OBSERVED-N` (numbers), then
  `CALL "TEST-ASSERT" USING TESTLIB-ASSERT` (`tools/testlib/TESTLIB.cpy`).
- C: `#include "testlib.h"` and call `tl_int`, `tl_str` or `tl_bytes` (`tools/testlib/testlib.h`).

Test programs run from the repository root. A file `<test>.stdin` next to a test source is fed to it
as standard input. A file `<test>.expect` turns the program into one case that passes when the
program exits with the status on its first line and, if there is a second line, its error output
contains that text.

## Where outputs go

Everything the build writes is under `build/`: the programs in `build/bin/`, compiled shaders in
`build/shaders/`, each package's objects and library in `build/<package>/` and its test programs in
`build/<package>/tests/`. The coverage build is kept apart in `build/coverage/`.
