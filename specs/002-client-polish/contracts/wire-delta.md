# Contract: the wire (`core` server side <-> `client` client side; `core` <-> a vanilla client)

**Status**: frozen at plan time; amends `specs/001-cobolcraft-complete/contracts/wire-profile.md`, whose target
document is `docs/protocol/09-cobolcraft-profile.md`.

## 1. Rule

Both world types speak protocol 777 as `docs/protocol/00` to `06` describe it. CobolCraft's choices of 09 that
FR-040 and README Part 7 decisions 7 and 8 retire for the shared rules are replaced by the standard ones: Player
Chat and Disguised Chat with standard chat types (instead of System Chat), the standard command tree and
permission levels, standard Player Abilities (creative and spectator only grant flight, 13 §1.4), the standard
inventory and crafting menus, recipe book packets, Block Destruction, Set Held Item, Player Action (swap with
off-hand), and entity spawn and metadata for every standard entity. The cobolcraft type differs only in content
keys (`cobolcraft:`), the `cobolcraft:surface` and `cobolcraft:sunless` dimension types, and the resulting
registry data (world-types.md WT-16).

## 2. What the Foundational docs round fixes in `09`

A row per packet whose use changes (the profile's "packet inventory with game meaning and wire fixtures"), written
from `05a`, `05b`, `05c` with `docs/protocol/09` kept as the CobolCraft statement. Packets of this feature that
`proto` must encode or decode beyond 001: chunk data with 24 sections and 16-bit paletted containers and biome
containers (06), Update Tags and the 51 world registries (04), Commands (the full tree, 15), Command Suggestions,
Container Set Slot / Content / Click / Set Cursor Item with data components (00 item stack, 40), Place Recipe,
Recipe Book Add / Remove / Settings / Seen (27), Block Destruction, Entity Event, Spawn Entity, Set Entity Data with
every serializer of 46 §12, Update Attributes, Update Mob Effect, Level Event and Level Particles (42), Respawn and
Login for three dimensions (39), Sound-related packets as no-ops (sounds are out of scope, FR-043).

## 3. Materialization

`contract/fixtures/wire/*.hex` gains one fixture per new packet (hex taken from the worked examples of the
documents, or built by the independent Python encoder `tools/wire_fixtures.py` whose output is reviewed against the
document's field table); `contract/copy/PROTO.cpy` gains the composite records. `proto` provides encoders and
decoders for every new composite (`proto-api` addition: `PB-PUT-*` and `PB-GET-*` for item stack with components,
entity metadata entries, chunk palette containers, command nodes); `core` and `client` call them.

## 4. Contract tests

`proto/tests/contract_wire_provider.cob` (each fixture decodes to its fields and re-encodes to the same bytes),
`core/tests/contract_wire_server.cob` (the packet the core builds for a case equals the fixture),
`client/tests/contract_wire_client.cob` (the client decodes each fixture it receives and builds each fixture it
sends), and `core/tests/contract_vanilla_config.cob` and `contract_vanilla_chunk.cob`, the automated half of the
vanilla-client validation (research R10): the configuration packet stream and the chunk data of a standard
world equal the documents' bytes (04 worked examples, 06 worked examples, 46 id tables).
