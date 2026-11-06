# Quickstart: validating CobolCraft, complete

**Feature**: `001-cobolcraft-complete` | **Plan**: [plan.md](plan.md)

Runnable validation scenarios proving the feature end to end on the supported platform (FR-011: macOS on
Apple silicon). Commands are those of [contracts/test-harness.md](contracts/test-harness.md); program
surfaces are [contracts/operator-surface.md](contracts/operator-surface.md) and
[contracts/client-surface.md](contracts/client-surface.md).

## 0. Prerequisites

```sh
xcode-select --install                      # if the command line tools are missing
brew install gnucobol glfw molten-vk vulkan-loader vulkan-headers glslang openssl@3 pkg-config
make bootstrap                              # exit 0 = every prerequisite present; shaders compiled
```

Expected: `make bootstrap` exits 0. With a prerequisite missing it names it and prints the `brew install`
line, and exits 1.

## 1. Build and test (US1, SC-001)

```sh
make            # expect build/bin/cobolcraft and build/bin/cobolcraft-server
make test       # expect a final line "passed <n> failed 0" and exit status 0
make gate       # lint + build + tests + 100 % coverage; exit status 0
```

Failure path (US1-3): temporarily change an expected value in any `test_*.cob`; `make test` lists
`FAIL <case> expected=… observed=…` and exits non-zero. Revert the change.

## 2. Server and join (US2, US3, US13)

```sh
mkdir -p /tmp/cc-srv && cd /tmp/cc-srv
<repo>/build/bin/cobolcraft-server
```

Expected console: `Created new world in ./world`, `Ready: accepting players on 0.0.0.0:25565`; a new
`cobolcraft-server.conf` with the defaults of operator-surface.md §2.

In a second terminal:

```sh
<repo>/build/bin/cobolcraft --name Alice --gamedir /tmp/cc-alice
```

Add server `localhost`, see the description and `0` players online, join. Expected: standing on turf facing
east, marker pillar four blocks ahead, lucite transparent, glowtube lighting nearby blocks; console shows
`Alice joined`. Walk a few hundred blocks; terrain keeps streaming.

## 3. Two players (US4 to US9, US11, SC-002, SC-006)

Start a second client with `--name Bob --gamedir /tmp/cc-bob`, join the same server. Each sees the other as
the operator figure. Break, place and toggle blocks; each change appears for both. Chat both ways; the order is
the same for both. In survival (`/` command from the extension's game-mode command, as an operator): break a
block, see its item on the ground, pick it up; throw an item; take fall damage; eat; meet mobs; craft a recipe;
force a weather kind by command and see it for both.

## 4. Persistence (US13-4, US15-2, SC-003)

Type the stop command at the server console. Expected: `Stopping: …`, both clients return to the server list
with the stopping message, `Stopped`, process exits 0. Start the server again; rejoin: dimension, position,
inventory, health and food are as left; blocks, mobs and ground items are where they were.

## 5. Dimensions (US12, SC-012)

Use the extension's means of travel to each extra dimension and back; inventory, health, food and mode are
unchanged; disconnecting in an extra dimension and rejoining puts the player back there.

## 6. Single-player and open to others (US16, US17, SC-010, SC-013)

From the main menu create a survival world, play, quit to the menu, reopen: as left. Open it to others from the
pause menu, read the shown address, have the second client add and join it; both see each other's changes;
quit the host: the guest is disconnected with the host-closed message. Copy `saves/<folder>` to a server
directory as `world/` and start the server: the same world is served.

## 7. Resource packs (US18, SC-005)

Create `/tmp/cc-alice/resourcepacks/test/` containing `pack.mcmeta` (`min_format`/`max_format` 97) and
replacements for `assets/cobolcraft/textures/block/greystone.png`, the trowel icon and one mob texture.
Enable it on the pack screen: only those three change. Zip the folder, serve it
(`python3 -m http.server` in its directory), set `pack-url`, `pack-sha1` (`shasum -a 1 test.zip`) and `pack-id`
in the server configuration, restart, join: prompt, accept, the pack is applied above local packs; rejoin:
no second download (the client's `downloads/` cache is used).

## 8. Failure behaviour (FR-012)

- Start the client without `--name`: one `FATAL arguments: …` line, exit status 1.
- Put `port=abc` in the configuration file and start the server: `FATAL configuration: port: …`, exit status 1.
- Stop the server while a client is connected through a network failure (kill -9): the client logs
  `ERROR connection: …` in its terminal and returns to the server list.
