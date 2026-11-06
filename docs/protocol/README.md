# Protocol 777 interoperability specification

This is a written specification of the network protocol and data formats used by Java Edition 26.3.
The original voxel game built in this repository uses this protocol as its network layer. It is written in
prose and tables only. It covers the plumbing (framing, packets, registry synchronization, chunk encoding, NBT and
region files) and, from document 10 on, the behaviour of the shipped game that the original game reproduces:
world generation, client rendering and controls, texture-only resource packs, commands, tools, weapons and combat,
and mobs. Documents 10 to 21 were written from the artifacts below in clean-room rounds (reader and reviewer
agents, see `.claude/skills/clean-room/SKILL.md`); implementers work from these documents only.

| Item | Value |
|---|---|
| Protocol version | 777 |
| World data version | 5023 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; the class names in the artifact are not obfuscated |
| Second artifact | `brigadier-1.3.11.jar` (`com.mojang:brigadier` 1.3.11, the release the 26.3 version manifest names), SHA-256 `9d09cf4819de83dfcd38bcb212d5f2227131791cef3abbfca3321d6fb2b9a64d`, SHA-1 `3373d1e7bf00c8b99bed1ea4efb8c47344e4a887`. Read only for document 15a: the game jar does not contain the command library |
| Third-party data | `Faithful 32x - 26.3.zip` (a resource pack, data not code), SHA-256 `596035002e8c369ca673b5b922cd532a38a2aaabe80f317f5ac4d5c7680c7bf2`. Read for document 14 and `../design/faithful-pack-mapping.md`. Neither jar nor pack is committed |

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
| [07-nbt-and-anvil.md](07-nbt-and-anvil.md) | NBT binary format and region files; §9 the CobolCraft world folder (layout, `.dat` schemas, entity and chunk storage) |
| [08-resource-packs.md](08-resource-packs.md) | Resource pack format (for packs in our own namespace), stacking, server-pushed packs |
| [09-cobolcraft-profile.md](09-cobolcraft-profile.md) | CobolCraft's profile of protocol 777: identity and message rule, transport choices, the packet inventory with game meaning and wire fixtures, packets never sent |
| [10-world-generation-terrain.md](10-world-generation-terrain.md) | Overworld terrain: random sources, noise, density functions, climate and biome table, aquifers, surface rules, stage order |
| [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md) | Caves (cheese, spaghetti, noodle), carvers, ore veins, ore and decoration features, ore drops, decoration seeding |
| [12-client-rendering.md](12-client-rendering.md) | Client rendering in numbers: lighting and ambient occlusion, atlas sampling, sky, fog, clouds, crack overlay, GUI layout, first-person hand, third-person camera, player model |
| [13-client-gameplay-and-controls.md](13-client-gameplay-and-controls.md) | Movement and flight, block-break progress, crafting and the recipe book, off-hand, F3 overlay, F5, options, the resource-pack screen |
| [14-texture-only-packs.md](14-texture-only-packs.md) | How the client resolves textures, atlases, GUI sprites, colormaps and fonts, and what a texture-only pack supplies |
| [15-commands-framework.md](15-commands-framework.md) | Command tree, per-player filtering, parse and error rules, every argument type, selectors, permissions, execution and feedback, `execute`, functions, signing, suggestions |
| [15a-brigadier-command-library.md](15a-brigadier-command-library.md) | The Brigadier command library (second artifact): string reader, tree, dispatcher, execution, argument types, suggestions, usage, messages |
| [16-commands-catalog.md](16-commands-catalog.md) | Every command of the 26.3 server: grammar, permission level, behaviour, results, messages, gamerules, aliases |
| [17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md) | Item components, every tool and weapon, special uses, combat, damage types, enchantments, durability and repair |
| [18-mob-framework.md](18-mob-framework.md) | Entity model, attributes, goals and the Brain, pathfinding, natural spawning, damage and loot, breeding, taming, leashing, tracking |
| [19-mobs-land-friendly-and-neutral.md](19-mobs-land-friendly-and-neutral.md) | Land passive, neutral and friendly mobs, villagers and trades |
| [20-mobs-overworld-hostile.md](20-mobs-overworld-hostile.md) | Overworld hostile mobs, raids and patrols |
| [21-mobs-aquatic-nether-end-bosses-and-entities.md](21-mobs-aquatic-nether-end-bosses-and-entities.md) | Aquatic, Nether and End mobs, the dragon fight, the wither, all-entities ownership table, other entities |

Game design documents live in [../design/](../design/). [standin-content.md](../design/standin-content.md) is the placeholder content used to unblock engineering. [faithful-pack-mapping.md](../design/faithful-pack-mapping.md) binds the stand-in content to the Faithful 32x pack's texture paths.

## Conventions

- Packet ids are shown in hex and decimal. Within each phase and direction, a packet's id is the order in which it is registered.
- Fields marked "(inferred)" were deduced rather than read directly. Each document ends with an "Open questions" section.
- **Recalled knowledge is not evidence.** Every value in documents 10 to 21 was read from an artifact in its round. Anything not read is marked "(recalled, not verified)" or "(inferred)" and listed in the document's Open questions. See "Recalled knowledge is not evidence" in the clean-room skill.
- **Section references** between documents use the form "17 §4.4"; a reference such as "18 framework: <topic>" names a topic of document 18.
