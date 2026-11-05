# Protocol 777 interoperability specification

This is a written specification of the network protocol and data formats used by Java Edition 26.3.
The original voxel game built in this repository uses this protocol as its network layer. It is written in
prose and tables only. It covers the plumbing: framing, packets, registry synchronization,
chunk encoding, NBT and region files. It does not cover gameplay, content, worldgen or rendering.

| Item | Value |
|---|---|
| Protocol version | 777 |
| World data version | 5023 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; the class names in the artifact are not obfuscated |

## Documents

| File | Contents |
|---|---|
| [00-data-types.md](00-data-types.md) | Primitive and composite wire types, entity metadata, item stacks |
| [01-transport.md](01-transport.md) | Framing, compression, encryption, connection state machine |
| [02-handshake-status-login.md](02-handshake-status-login.md) | Handshake, status, login, cookies, authentication hash |
| [03-configuration.md](03-configuration.md) | Configuration phase packets and the shared "common" packets |
| [04-registry-sync.md](04-registry-sync.md) | Registry and tag synchronization, numeric id assignment, entry schemas |
| [05a-play-clientbound-00-71.md](05a-play-clientbound-00-71.md) | Play phase, clientbound, ids 0–71 |
| [05b-play-clientbound-72-143.md](05b-play-clientbound-72-143.md) | Play phase, clientbound, ids 72–143 |
| [05c-play-serverbound.md](05c-play-serverbound.md) | Play phase, serverbound, ids 0–68 |
| [06-chunk-format.md](06-chunk-format.md) | Chunk sections, paletted containers, light data |
| [07-nbt-and-anvil.md](07-nbt-and-anvil.md) | NBT binary format and region files |
| [08-resource-packs.md](08-resource-packs.md) | Resource pack format (for packs in our own namespace), stacking, server-pushed packs |

Game design documents live in [../design/](../design/). The first is [standin-content.md](../design/standin-content.md), the placeholder content used to unblock engineering.

## Conventions

- Packet ids are shown in hex and decimal. Within each phase and direction, a packet's id is the order in which it is registered.
- Fields marked "(inferred)" were deduced rather than read directly. Each document ends with an "Open questions" section.
