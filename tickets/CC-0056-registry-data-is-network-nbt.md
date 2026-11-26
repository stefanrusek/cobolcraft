---
spile: ticket
id: CC-0056
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0026]
  supersedes: []
implementation:
  branch:
  pr:
---

# CC-0056: Registry Data of a standard world is network NBT for every registry

## Summary
When a client does not claim the core pack, the server sends each registry entry of a standard world with its Data. That Data is network NBT for every synchronised registry (`docs/protocol/04-registry-sync.md` section 2), so the CobolCraft client reads all of them without an error line.

## User Stories

### As a Player, I want to join a standard world without error lines in the terminal
- Given a standard world hosted in a child process (`CC_SP_PROCESS=1`) or by a dedicated server
- When the CobolCraft client joins it
- Then no `ERROR registry: ... does not decode` line is printed
- And every registry the client received holds its entries

## Functional Requirements
- FR-001: Registry Data sent by `REGISTRY-PACKET-BUILD` is network NBT for all registries of `core/copy/SYNCREG.cpy`.
- FR-002: The CobolCraft client reads `minecraft:painting_variant` of a standard world from Registry Data.

## Notes
> [!NOTE]
> Current behaviour, measured 2026-11-26 on 004-perf-frame b47e077d (release build): `REGISTRY-PACKET-BUILD` (`core/src/registries.cob`) converts only `minecraft:worldgen/biome` and `minecraft:dimension_type` to network NBT. For the other 30 registries the Data is the raw JSON text of the vanilla-data pack. A client on a non-memory connection passes Registry Data to `CONTENT-CLIENT-REGISTRY-ADD` (`client/src/protocol-config.cob:546`, `content/src/client-registry.cob:150`), which rejects it and prints one line per registry: 30 lines at each join in process mode, none in the in-process host (memory connection). A raw probe that answers Select Known Packs with an empty list received the same bytes from the release dedicated server (`/Users/stefanrusek/Code/gatefast-logs/perfround/t2/ded/probe.txt`). A vanilla client claims the core pack and gets entries without Data. No visible effect other than the lines was found; no client program reads those 30 registries from the content set. Read in code only: the client's `REGISTRY-READ` reads `minecraft:painting_variant` as NBT from the same packet.
