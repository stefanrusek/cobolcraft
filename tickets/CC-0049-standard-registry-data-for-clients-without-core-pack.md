---
spile: ticket
id: CC-0049
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0049: A standard world sends NBT Registry Data to a client without the core pack

## Summary

A client that does not have the vanilla core pack, such as the CobolCraft client joining another host's standard world,
receives every registry entry as network NBT in the schema of 04 section 6.

## User Stories

### As a Player, I want to join a standard world with the CobolCraft client

- Given a server with a standard world, when a CobolCraft client joins over the network, then every Registry Data entry
  decodes and the client enters play.

## Functional Requirements

- FR-001: Every entry sent with Data is one network NBT tag (09 section 3.5.9).

## Notes

> [!NOTE]
> The current behaviour: only `worldgen/biome` and `dimension_type` are converted (`core/src/registries.cob`); every
> other entry of a standard set goes out as the JSON text of the pack. A vanilla client no longer sees this, because it
> echoes the core pack and receives no Data. The effect on a CobolCraft guest was read from the code, not tried.
>
> Related: the cobolcraft world type sends Update Tags with zero registries although
> `docs/design/cobolcraft-standard-core.md` section 4.4 lists tags.
