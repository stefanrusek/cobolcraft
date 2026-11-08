# 04 — Registry and tag synchronization

This document describes how the server tells the client the contents of the data-driven ("dynamic") registries and the tag sets during the configuration phase. It also covers how numeric ids are assigned, both for those synchronized registries and for the built-in ("static") registries that are never sent. Those ids are what play-phase packets carry. For an original game that uses this protocol, this is the key interop surface. The game can define its own entries for every synchronized registry and send them. It cannot change the static registries: blocks, block states, items, entity types and so on. For those, a game that serves the standard world type must reproduce the client's built-in numbering exactly, while the cobolcraft world type keeps its own numbering. §5 states both cases.

Registry names in this document are written without the `minecraft:` namespace (for example `worldgen/biome` means `minecraft:worldgen/biome`). On the wire, a registry is always identified by its full Identifier.

## 1. Packets involved

| Phase | Direction | Id | Packet |
|---|---|---|---|
| Configuration | Clientbound | 0x0F (15) | Select Known Packs (`ClientboundSelectKnownPacks`) |
| Configuration | Serverbound | 0x07 (7) | Select Known Packs (`ServerboundSelectKnownPacks`) |
| Configuration | Clientbound | 0x07 (7) | Registry Data (`ClientboundRegistryDataPacket`) |
| Configuration | Clientbound | 0x0E (14) | Update Tags (`ClientboundUpdateTagsPacket`, shared "common" packet) |
| Play | Clientbound | 0x89 (137) | Update Tags (same class and layout as above) |

## 0x0F Clientbound Select Known Packs (ClientboundSelectKnownPacks)

Configuration phase, clientbound, id 0x0F (15). The server offers the data packs whose contents it assumes the client may already have.

| Field | Type | Notes |
|---|---|---|
| Known Packs | Prefixed Array of KnownPack | VarInt count. The codec sets no upper limit on the count. |

## 0x07 Serverbound Select Known Packs (ServerboundSelectKnownPacks)

Configuration phase, serverbound, id 0x07 (7). The client answers with the subset of offered packs that it has locally.

| Field | Type | Notes |
|---|---|---|
| Known Packs | Prefixed Array of KnownPack | VarInt count, **at most 64**. A larger count makes the decoder fail (`ByteBufCodecs.list(64)`). |

## 0x07 Clientbound Registry Data (ClientboundRegistryDataPacket)

Configuration phase, clientbound, id 0x07 (7). Carries some or all of the entries of one synchronized registry.

| Field | Type | Notes |
|---|---|---|
| Registry | Identifier | The registry key, for example `minecraft:dimension_type`. It is encoded with `Identifier.STREAM_CODEC`, a String of at most 32767 characters parsed as an Identifier. |
| Entries | Prefixed Array of PackedRegistryEntry | VarInt count. The codec sets no upper limit. The entries are in **id order**: see section 4. |

**PackedRegistryEntry**

| Field | Type | Notes |
|---|---|---|
| Id | Identifier | The entry's key within the registry, for example `minecraft:overworld`. |
| Data | Optional NBT | A Boolean present flag, then one network NBT tag (a type byte followed by its payload, with no root name). The tag is read with `ByteBufCodecs.TAG`, which uses the default NBT quota of 2,097,152 bytes and a maximum depth of 512. When the flag is false, the client loads the entry from its own copy of a known pack (section 2). |

## 0x0E / 0x89 Clientbound Update Tags (ClientboundUpdateTagsPacket)

Configuration phase id 0x0E (14) and play phase id 0x89 (137). The layout is the same in both phases.

| Field | Type | Notes |
|---|---|---|
| Registries | Prefixed Array of RegistryTags | VarInt count, no explicit limit. It is encoded as a map keyed by registry. |

**RegistryTags**

| Field | Type | Notes |
|---|---|---|
| Registry | Identifier | Registry key (`ResourceKey.REGISTRY_STREAM_CODEC`, an Identifier). |
| Tags | Prefixed Array of TagEntry | VarInt count. |

**TagEntry**

| Field | Type | Notes |
|---|---|---|
| Tag Name | Identifier | The tag id, written without `#`. |
| Entries | Prefixed Array of VarInt | Each VarInt is the **numeric id of an element in that registry**: the registry's `getId` value. For a synchronized registry, that is the index assigned from the Registry Data order (section 4). For a static registry, it is the built-in id (section 5). |

Notes on tags:

- Each tag is sent already flattened. The entries list holds element ids only. There are no nested tag references.
- When decoding, the client resolves each id with `Registry.get(int)` and **silently drops ids that do not resolve**: an invalid id is ignored, not treated as an error.
- An unknown or mistyped registry key is not tolerated. In the configuration phase, the client resolves non-synchronized registries with `lookupOrThrow` (inferred: this throws for unknown keys).
- The vanilla server only sends registries that have at least one tag. It sends tags for the synchronized registries and for every static registry (`RegistrySynchronization.networkSafeRegistries` is the static layer plus the synchronized world-layer registries).
- If several Update Tags packets arrive during one configuration phase, the client keeps them in a map keyed by registry. A later payload for the same registry **replaces** the earlier one.

## Composite types introduced here

**KnownPack**

| Field | Type | Notes |
|---|---|---|
| Namespace | String(32767) | The vanilla packs use `minecraft`. |
| Id | String(32767) | The pack id. The vanilla base data pack is `core`. Built-in feature packs use their own ids. |
| Version | String(32767) | The vanilla packs use the game version id from `version.json`, `26.3` in this artifact. |

A vanilla KnownPack is therefore (`minecraft`, `core`, `26.3`).

## 2. Known-packs negotiation and omitted entry data

Server-side sequence, from `ServerConfigurationPacketListenerImpl.startConfiguration` and `SynchronizeRegistriesTask`:

1. The server sends Select Known Packs, listing the KnownPack identity of every loaded data pack that has one. These are the packs whose `PackLocationInfo.knownPackInfo` is present, which in vanilla means the built-in vanilla packs.
2. The server waits for the serverbound Select Known Packs. If one arrives when no negotiation is in progress, the server fails with "Unexpected response from client: received pack selection, but no negotiation ongoing".
3. On the reply, the vanilla server tests whether the client's list **equals the requested list exactly**, with the same elements in the same order.
   - If it does, the set of shared packs is the requested set.
   - Otherwise, the set of shared packs is **empty** and all data is sent in full.
4. The server then sends one Registry Data packet per synchronized registry, in the order of section 3. It skips any registry it does not have. Each registry's entries come in the registry's own id order (`Registry.listElements`).
   - For each entry: if the entry was registered from a pack whose KnownPack is in the shared set, Data is **absent**. Otherwise Data holds the entry encoded with the registry's codec (section 6).
5. The server then sends one Update Tags packet with all tags.

Client side, from `ClientConfigurationPacketListenerImpl` and `KnownPacksManager`:

- When it receives Select Known Packs, the client builds a trusted repository of its own vanilla packs. It answers with the offered packs that it recognizes (matching namespace, id and version), **in the order the server offered them**. It then selects those packs for later lookups.
- When an entry arrives with no Data, the client loads it at configuration end from the selected packs. The resource path is `data/<entry namespace>/<registry path>/<entry path>.json`, built by `FileToIdConverter.registry`. If the file is missing, the error is "Failed to find resource … for element …" and registry loading fails.
- If no Select Known Packs was ever received, the client looks entries up in an empty resource provider. Every Data-less entry then fails. Nothing in the client requires Select Known Packs to arrive before Registry Data (inferred from the absence of any check in `handleRegistryData`).

Guidance for an original server:

- The simplest correct behaviour is to send Select Known Packs with an empty list, or to skip it. Then send **every entry with Data present**.
- Data can be omitted only for entries that are byte-for-byte what the client's own copy of a confirmed pack contains. That cannot apply to entries the game defines itself.
- With the standard world type, a vanilla client could take such entries from its own pack. CobolCraft's own client has no known packs, so the empty-list rule above stays for it.

## 3. Synchronized registries

The synchronized set and its order come from `RegistryDataLoader.SYNCHRONIZED_REGISTRIES`, a list of 32 `RegistryData` records. Each record gives a registry key, the element codec used on the network, and a validator. `RegistrySynchronization.isNetworkable` treats exactly this set as "networkable".

| # | Registry | Element codec used for the network | Validator |
|---|---|---|---|
| 0 | `worldgen/biome` | `Biome.NETWORK_CODEC` | none |
| 1 | `chat_type` | `ChatType.DIRECT_CODEC` | none |
| 2 | `trim_pattern` | `TrimPattern.DIRECT_CODEC` | none |
| 3 | `trim_material` | `TrimMaterial.DIRECT_CODEC` | none |
| 4 | `wolf_variant` | `WolfVariant.NETWORK_CODEC` | **non-empty** |
| 5 | `wolf_sound_variant` | `WolfSoundVariant.NETWORK_CODEC` | **non-empty** |
| 6 | `pig_variant` | `PigVariant.NETWORK_CODEC` | **non-empty** |
| 7 | `pig_sound_variant` | `PigSoundVariant.NETWORK_CODEC` | **non-empty** |
| 8 | `frog_variant` | `FrogVariant.NETWORK_CODEC` | **non-empty** |
| 9 | `cat_variant` | `CatVariant.NETWORK_CODEC` | **non-empty** |
| 10 | `cat_sound_variant` | `CatSoundVariant.NETWORK_CODEC` | **non-empty** |
| 11 | `cow_sound_variant` | `CowSoundVariant.DIRECT_CODEC` | **non-empty** |
| 12 | `cow_variant` | `CowVariant.NETWORK_CODEC` | **non-empty** |
| 13 | `chicken_sound_variant` | `ChickenSoundVariant.DIRECT_CODEC` | **non-empty** |
| 14 | `chicken_variant` | `ChickenVariant.NETWORK_CODEC` | **non-empty** |
| 15 | `zombie_nautilus_variant` | `ZombieNautilusVariant.NETWORK_CODEC` | **non-empty** |
| 16 | `painting_variant` | `PaintingVariant.DIRECT_CODEC` | **non-empty** |
| 17 | `sulfur_cube_archetype` | `SulfurCubeArchetype.DIRECT_CODEC` | none |
| 18 | `dimension_type` | `DimensionType.NETWORK_CODEC` | none |
| 19 | `damage_type` | `DamageType.DIRECT_CODEC` | none |
| 20 | `banner_pattern` | `BannerPattern.DIRECT_CODEC` | none |
| 21 | `enchantment` | `Enchantment.DIRECT_CODEC` | none |
| 22 | `jukebox_song` | `JukeboxSong.DIRECT_CODEC` | none |
| 23 | `instrument` | `Instrument.DIRECT_CODEC` | none |
| 24 | `test_environment` | `TestEnvironmentDefinition.DIRECT_CODEC` | none |
| 25 | `test_instance` | `GameTestInstance.DIRECT_CODEC` | none |
| 26 | `dialog` | `Dialog.DIRECT_CODEC` | none |
| 27 | `world_clock` | `WorldClock.DIRECT_CODEC` | none |
| 28 | `timeline` | `Timeline.NETWORK_CODEC` | none |
| 29 | `decorated_pot_pattern` | `DecoratedPotPattern.CODEC` | none |
| 30 | `block_transformer` | `BlockTransformer.DIRECT_CODEC` | none |
| 31 | `worldgen/block_state_provider` | `BlockStateProvider.DIRECT_CODEC` | none |

### 3.1 Ordering

- The vanilla server sends Registry Data packets in the table order above.
- **The client does not depend on that order.** `RegistryDataCollector` stores received entries in a hash map keyed by registry. When the same registry arrives in several packets, the entry lists are **appended** in arrival order, so one registry may be split across packets.
- Nothing is processed until the client receives Finish Configuration. It then loads all synchronized registries together (`RegistryDataLoader.load`). Cross-registry references, for example an entry naming an element of another synchronized registry or a tag, are resolved against every registry being loaded plus the static registries. No registry has to arrive before another.
- The order of entries **within** a registry does matter. It defines the numeric ids (section 4).

### 3.2 What the client validates; which registries are mandatory

When Finish Configuration arrives, the client builds its registries from what it collected. Load errors are gathered. Any error fails the whole load with "Failed to load registries due to errors", reported as a crash report "Network Registry Load". The connection cannot continue (inferred: the exception is raised while the packet is being handled).

The client checks the following:

1. **Decoding.** Every entry with Data must decode with the codec in section 3. Otherwise the error is "Failed to parse value … for key … from server". Every entry without Data must be found in a selected known pack (section 2).
2. **Duplicate ids.** Registering the same key twice in one registry is an error ("Adding duplicate key … to registry", from `MappedRegistry.register`). Do not repeat an Id within a registry, including across split packets.
3. **Dangling references.** When a registry is frozen, references to elements or tags that were never defined are errors: "Unbound values in registry …" and "Unbound tags in registry …" from `MappedRegistry.freeze` (inferred for the tag case).
4. **Validators.** The 13 registries marked **non-empty** must hold at least one entry, or the error is "Registry must be non-empty: <registry>". The others may be empty.
5. **Registries never mentioned.** If a synchronized registry gets no Registry Data packet at all, its loader does nothing and it stays empty.
   - The client still builds play-phase state from the result, so an empty registry is fatal wherever play-phase code needs an element from it. See the hard-coded keys below.
   - If the server sends Update Tags for a synchronized registry but no Registry Data for it, the client creates that registry with **zero elements** and the tag ids then resolve to nothing.
6. **Keys the client looks up directly.** Several client-side classes look up specific **vanilla keys** with `getOrThrow`. Those keys must exist under the exact vanilla Identifier, whatever else the game defines:
   - `DamageSources`, built for every client `Level`, calls `getOrThrow` on a fixed set of 25 `damage_type` keys in its constructor (cactus, campfire, cramming, dragon_breath, drown, dry_out, ender_pearl, fall, fell_out_of_world, fly_into_wall, freeze, generic, generic_kill, hot_floor, in_fire, in_wall, lava, lightning_bolt, magic, on_fire, outside_border, stalagmite, starve, sweet_berry_bush, wither — all `minecraft:`). Another 24 keys are looked up lazily only when the corresponding damage is applied. Every one of them must be present in the `damage_type` registry.
   - `ClientLevel`, `ClientChunkCache` and `PalettedContainerFactory` call `getOrThrow` for the `worldgen/biome` key `minecraft:plains`, used as the fallback or default biome. That key must exist.
   - Play-phase packets that name a dimension type, chat type and so on carry ids into these registries. Those ids must be valid (section 4).

In practice, a minimal original server must send at least these:
- the 13 non-empty registries, each with at least one entry;
- `damage_type` with the 25 required keys;
- `worldgen/biome` containing `minecraft:plains`;
- `dimension_type` with every dimension type that the Login (play) and Respawn packets will reference;
- `chat_type` with every chat type used by chat packets.

Whether other play-phase code paths need further hard-coded keys is listed under Open questions.

### 3.3 Tags and static registries at configuration end

- **Tags for synchronized registries** are bound while those registries load.
- **Tags for non-synchronized (static) registries** are applied after loading, using `Registry.prepareTagReload` followed by `apply`. They replace that registry's tag set.
- On an in-memory (integrated server) connection the client skips the static-registry tag step. A network client always applies it.
- **Default item components** that depend on registries are then rebuilt (`BuiltInRegistries.DATA_COMPONENT_INITIALIZERS`). On a network connection this is limited to keys for which `RegistrySynchronization.isNetworkable` is true.

## 4. Ids of synchronized-registry entries

- The client registers each synchronized registry's entries **in the order received**: the concatenation of all Entries arrays for that registry, in packet order. `MappedRegistry.register` gives each new key the next index, so the first entry is id 0, the second id 1, and so on, with no gaps.
- The vanilla server sends entries in its own id order, so both sides agree.

That index is what play-phase packets use:

- **Plain registry reference** (`ByteBufCodecs.registry(key)`): one VarInt, the element's id. An unknown id fails with `byIdOrThrow`.
- **Holder reference** (`ByteBufCodecs.holderRegistry(key)`): one VarInt id, against the holder id-map (`Registry.asHolderIdMap`), which uses the same numbering.
- **Holder-or-inline** (`ByteBufCodecs.holder(key, directCodec)`): a VarInt N.
  - N = 0 means an inline value follows, encoded with the direct stream codec.
  - N > 0 means a reference to element id N − 1.
- **HolderSet** (`ByteBufCodecs.holderSet(key)`): a VarInt N.
  - N = 0 means a tag follows, as an Identifier. The tag must exist on the client (`Registry.get(TagKey)` followed by `orElseThrow`).
  - N > 0 means N − 1 element references follow, each a VarInt id as for a holder reference. The decoder pre-sizes its list to at most 65536, but that is a capacity, not a limit on the count.
- **Tags** in Update Tags use the same ids.

A server that defines its own entries is free to choose the order. It only has to be consistent: use the index at which each entry appeared in Registry Data.

## 5. Ids of static (built-in) registries

Static registries are never sent. These include blocks, items, entity types, block entity types, fluids, sound events, particle types, menu types, mob effects, potions, data component types, game events, attributes, stat types, recipe serializers, command argument types and others. The full list of static registries is the set of `public static final` registry fields of `net.minecraft.core.registries.BuiltInRegistries`.

The client numbers each one itself, so **a server must use exactly the client's numbering**. An original game cannot add, remove or reorder blocks, block states, items or any other static entries. It can only choose which existing ids it uses.

How this applies depends on the world type of the game (the standard world type and the cobolcraft world type, see docs/design/README.md Part 4, C1):

- **Standard world type.** This is the requirement. Server and client use the vanilla numbering of every static registry, so that a reference client can validate ids, registry contents and chunk encodings. The numbering is code, not data: it is specified by the block and item registry documents (docs/design/README.md Part 5, GAP-1 and GAP-2) and for entity types by 21 section 2.
- **Cobolcraft world type.** The content is original and keeps its own numbering, so the static ids it sends do not match the client's built-in registries. That is why a vanilla client can pass configuration for this world type but cannot play it. CobolCraft's own client reads the original content from its built-in pack.

### 5.1 Where the order comes from

- `BuiltInRegistries.bootStrap` runs `createContents`. That calls each registry's loader in the `LOADERS` map, which triggers the static initializers of the content classes (for example `net.minecraft.world.level.block.Blocks` and `net.minecraft.world.item.Items`). It then freezes every registry.
- Inside each content class, entries register in the order of the static initializer's `register(...)` calls. In practice that is the order of the field declarations.
- `MappedRegistry.register` gives each key the next index (`byId.size()`), so a static registry's numeric id is **its registration index, starting at 0**.
- The protocol never transmits these ids. Server and client agree only because both run the same bootstrap.
- To obtain the numbering without running the client, use the jar's built-in data generator reports:
  - `net.minecraft.data.info.RegistryDumpReport` writes `registries.json`, giving every static registry entry's `protocol_id` (its `Registry.getId`).
  - `net.minecraft.data.info.BlockListReport` writes `blocks.json`, giving every block state's `id` (`Block.getId(state)`).
  - This document does not reproduce that content. The block registry and the item registry are specified by their own documents (docs/design/README.md Part 5, GAP-1 and GAP-2, research items RS1 and RS2). The extraction tool does not produce the registries: they are code, not data.

### 5.2 Block state ids

Block states have their own global id space, separate from the block registry. It is held in `Block.BLOCK_STATE_REGISTRY`, an `IdMapper`. The ids are assigned once, after all blocks are registered, by a static block in `Blocks`:

1. Iterate `BuiltInRegistries.BLOCK` in registry order, by block id ascending.
2. For each block, iterate `block.getStateDefinition().getPossibleStates()` in list order.
3. Add each state to `BLOCK_STATE_REGISTRY` with `IdMapper.add`, which assigns `nextId` and then increments it.

The result is:
- State ids are contiguous from 0.
- Each block owns one consecutive range.
- The first state id of a block is the total number of states of all blocks before it.

The order of `getPossibleStates()` is set by the `StateDefinition` constructor:

- **Property order.** The block's properties are put into an `ImmutableSortedMap` keyed by property name. The keys use natural `String` ordering, which compares UTF-16 code units lexicographically; for ASCII names this is plain byte order. The order in which the block declared its properties does not matter.
- **No properties.** The block has exactly one state.
- **One property.** There is one state per value, in the property's value order.
- **Two or more properties.** The states are the Cartesian product (Guava `Lists.cartesianProduct`) of each property's value list, with properties taken in the sorted-name order.
  - The product is in lexicographic order with the first list varying slowest. This is Guava's documented behaviour; the bytecode only shows the call.
  - In other words, the property whose name sorts **first** varies **slowest**, and the property whose name sorts **last** varies **fastest**.
- **Value order** within each property comes from `Property.getPossibleValues()`:
  - Boolean property: `true` first, then `false`.
  - Integer property: `min`, `min+1`, …, `max`, ascending.
  - Enum property: the list given when the property was created. `EnumProperty.create(name, class)` uses all enum constants in declaration (ordinal) order, and the filtered variant keeps that order for the constants that pass the filter. The variant that takes an explicit list or varargs uses **exactly the order given**, which need not be ordinal order.

Formula. Sort a block's properties by name: P₀ … Pₖ₋₁. Each has value count cᵢ, and vᵢ is the 0-based index of the state's value in Pᵢ's value list. Then:

state id = (first state id of the block) + Σᵢ vᵢ · Πⱼ₌ᵢ₊₁…ₖ₋₁ cⱼ

The block's default state is not necessarily its first state.

When decoding, `Block.stateById` maps an id with no state to the default state of the air block rather than failing. `Block.getId` maps a null state to 0.

### 5.3 Static ids on the wire

- Play-phase fields that reference a static registry are encoded as a VarInt registration index. They use `ByteBufCodecs.registry`, `holderRegistry` or `idMapper` against the client's built-in registry.
- Block state fields use `Block.BLOCK_STATE_REGISTRY` ids: a VarInt in packets, and palette entries in chunk data (see 06-chunk-format.md).
- Tags for static registries (section 1) also use these ids. A server **may** send its own tag definitions for static registries. That is the one way an original game can reshape static content groupings without changing ids. In the standard world type the server does not invent tags: it sends the tags of the loaded data pack (docs/design/README.md Part 5, GAP-6).

## 6. Entry schemas of the synchronized registries

The Data NBT of each entry is decoded with the codec in section 3, through `RegistryOps` over `NbtOps`.

- The NBT tag holding an entry is normally a Compound.
- Numeric fields accept any numeric NBT tag (inferred from `NbtOps` number handling).
- Booleans are Byte tags, 0 or 1.
- Identifiers are String tags.
- References to elements of other registries are written as an Identifier String, or as an inline object where the field allows it.
- Holder sets accept an Identifier String, a List of Identifier Strings, or a `#`-prefixed tag String (inferred from `HolderSetCodec` conventions where not stated per field).

Field tables use: | Field | NBT type | Req/Opt (default) | Notes |. Only schemas are given here, never registry content.

### 6.0 Conventions and shared types

- **Required / optional.** "Req" means `fieldOf`: the field must be present. "Opt (X)" means `optionalFieldOf` with default X: X is used when the field is absent, and a present but malformed value is an error. "Opt (absent)" means the field is optional and has no default.
- **Ranges.** `intRange(a,b)` is inclusive. Positive means > 0. Non-negative means ≥ 0.
- **Reference forms.**
  - "Id ref" (`RegistryFixedCodec`, `RegistryCodecs.holder(key)` with no direct codec): an Identifier String naming an element of the given registry. No inline object, no tag.
  - "Id-or-inline" (`RegistryFileCodec`): either an Identifier String, or an inline Compound in the element's own schema.
  - "HolderSet" (`HolderSetCodec`): a `#`-prefixed tag String, a single Identifier String, or a List of Identifiers. Where the element codec allows inline objects, the list may also hold inline Compounds.
- **TextComponent** is the NBT form of a chat component: a String, a Compound or a List (`ComponentSerialization.CODEC`).

#### SoundEvent (Id-or-inline over static registry `sound_event`)

The value is either an Identifier String naming a built-in sound event, or an inline Compound:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| sound_id | String (Identifier) | Req | |
| range | Float | Opt (absent), lenient | Read with `lenientOptionalFieldOf`, so a malformed value counts as absent. Absent gives a variable-range event; present gives a fixed range. |

#### ResourceTexture

An Identifier String. The client derives the texture path `textures/<path>.png` from it (`ClientAsset$ResourceTexture`).

#### ModelAndTexture

A MapCodec, so its fields sit flat in the parent compound.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| model | String enum | Opt (`normal`) | The allowed values depend on the registry and are listed per registry below. |
| asset_id | String (ResourceTexture) | Req | |

#### IntProvider / FloatProvider

- **Constant form:** a bare Int (or Float).
- **Compound form:** dispatches on `type` over the static `int_provider_type` (or `float_provider_type`) registry.
- Sub-type fields are not expanded here.

#### EnvironmentAttributeMap

Used by `worldgen/biome` and `dimension_type` under the key `attributes`, through `EnvironmentAttributeMap.NETWORK_CODEC`.

- **Shape.** A Compound. Each key is an Identifier from the static `environment_attribute` registry. Only attributes marked syncable are kept (`filterSyncable` is applied in both directions).
- **Value form.** Either the attribute's raw value, or a Compound `{modifier: String, argument: <modifier-specific>}`.
- **Modifier ids:** `override`, `alpha_blend`, `add`, `subtract`, `multiply`, `blend_to_gray`, `minimum`, `maximum`, `and`, `nand`, `or`, `nor`, `xor`, `xnor`, `append`, `overlay`. Each attribute type allows only a subset.

### worldgen/biome — `Biome.NETWORK_CODEC`

The network codec leaves out generation settings. The climate fields are inlined at the top level.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| has_precipitation | Byte (bool) | Req | |
| temperature | Float | Req | |
| temperature_modifier | String enum | Opt (`none`) | `none` or `frozen` |
| downfall | Float | Req | |
| attributes | Compound | Opt (empty) | EnvironmentAttributeMap |
| effects | Compound | Req | See below |

`effects` (`BiomeSpecialEffects`):

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| water_color | Color | Req | Color is a `"#RRGGBB"` String, an Int (packed RGB), or a List of 3 Floats (`ExtraCodecs.STRING_RGB_COLOR`). |
| foliage_color | Color | Opt (absent) | |
| dry_foliage_color | Color | Opt (absent) | |
| grass_color | Color | Opt (absent) | |
| grass_color_modifier | String enum | Opt (`none`) | `none`, `dark_forest` or `swamp` |

### chat_type — `ChatType.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| chat | Compound | Req | ChatTypeDecoration |
| narration | Compound | Req | ChatTypeDecoration |

ChatTypeDecoration:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| translation_key | String | Req | |
| parameters | List of String | Req | Each value is `sender`, `target` or `content`. |
| style | Compound | Opt (empty style) | Uses the same style keys as a text component. |

### trim_pattern — `TrimPattern.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| asset_id | String (Identifier) | Req | |
| description | TextComponent | Req | |
| decal | Byte (bool) | Opt (false) | |

### trim_material — `TrimMaterial.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| palette_id | String (Identifier) | Req | |
| description | TextComponent | Req | |

### wolf_variant — `WolfVariant.NETWORK_CODEC`

The network codec leaves out `spawn_conditions`. The same is true of every `*_variant` network codec below.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| assets | Compound | Req | WolfAssetInfo |
| baby_assets | Compound | Req | WolfAssetInfo |

WolfAssetInfo: `wild`, `tame` and `angry`. Each is a String (ResourceTexture) and each is Req.

### Sound-variant registries

These registries share one pattern. The entry has two Compound fields, `adult_sounds` and `baby_sounds`, both Req. Each is a sound set whose fields are all Req and all SoundEvent. The exception is `cow_sound_variant`, whose four fields sit directly on the entry.

| Registry (codec) | Sound set fields |
|---|---|
| wolf_sound_variant (`WolfSoundVariant.NETWORK_CODEC`, same codec as the direct one) | ambient_sound, death_sound, growl_sound, hurt_sound, pant_sound, whine_sound, step_sound |
| pig_sound_variant (`PigSoundVariant.NETWORK_CODEC`) | ambient_sound, hurt_sound, death_sound, step_sound, eat_sound |
| cat_sound_variant (`CatSoundVariant.NETWORK_CODEC`) | ambient_sound, stray_ambient_sound, hiss_sound, hurt_sound, death_sound, eat_sound, beg_for_food_sound, purr_sound, purreow_sound |
| chicken_sound_variant (`ChickenSoundVariant.DIRECT_CODEC`) | ambient_sound, hurt_sound, death_sound, step_sound |
| cow_sound_variant (`CowSoundVariant.DIRECT_CODEC`) | No adult/baby split. The entry itself has ambient_sound, hurt_sound, death_sound and step_sound. |

### Model/texture variant registries

| Registry (codec) | Fields |
|---|---|
| pig_variant (`PigVariant.NETWORK_CODEC`) | ModelAndTexture (model `normal` or `cold`), plus `baby_asset_id` (ResourceTexture, Req) |
| cow_variant (`CowVariant.NETWORK_CODEC`) | ModelAndTexture (model `normal`, `cold` or `warm`), plus `baby_asset_id` (Req) |
| chicken_variant (`ChickenVariant.NETWORK_CODEC`) | ModelAndTexture (model `normal` or `cold`), plus `baby_asset_id` (Req) |
| zombie_nautilus_variant (`ZombieNautilusVariant.NETWORK_CODEC`) | ModelAndTexture (model `normal` or `warm`) |
| cat_variant (`CatVariant.NETWORK_CODEC`) | `asset_id` and `baby_asset_id`, both ResourceTexture, both Req |
| frog_variant (`FrogVariant.NETWORK_CODEC`) | `asset_id` (ResourceTexture, Req) |

### painting_variant — `PaintingVariant.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| width | Int | Req | Range 1–16 |
| height | Int | Req | Range 1–16 |
| asset_id | String (Identifier) | Req | |
| title | TextComponent | Opt (absent) | |
| author | TextComponent | Opt (absent) | |

### sulfur_cube_archetype — `SulfurCubeArchetype.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| items | HolderSet over static `item` | Req | Ids or a tag only. |
| attribute_modifiers | List of Compound | Req | Each element has `attribute` (Id ref, static `attribute` registry), `id` (Identifier), `amount` (Double) and `operation`. `operation` is one of `add_value`, `add_multiplied_base` or `add_multiplied_total`. All four are Req. |
| buoyant | Byte (bool) | Opt (false) | |
| explosion | Compound | Opt (absent) | `power` (Int ≥ 0), `causes_fire` (bool), `fuse` (Int ≥ 1). All Req. |
| contact_damage | Compound | Opt (absent) | `damage_type` (Id ref, `damage_type`), `amount` (FloatProvider, min ≥ 0, inferred), `attribute_to_source` (bool). All Req. |
| knockback_modifiers | Compound | Req | `horizontal_power` and `vertical_power`, both Float and both Req. |
| sound_settings | Compound | Req | `hit_sound` and `push_sound` (SoundEvent), `push_sound_impulse_threshold` and `push_sound_cooldown` (Float). All Req. |

### dimension_type — `DimensionType.NETWORK_CODEC`

The record constructor rejects inconsistent values, and the codec wrapper turns that into a decode error (inferred). The checks are:
- `height` must be at least 16 and a multiple of 16;
- `min_y` must be a multiple of 16;
- `min_y + height` must not exceed 2032;
- `logical_height` must not exceed `height`.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| has_fixed_time | Byte (bool) | Opt (false) | |
| has_skylight | Byte (bool) | Req | |
| has_ceiling | Byte (bool) | Req | |
| has_ender_dragon_fight | Byte (bool) | Req | |
| coordinate_scale | Double | Req | Range 1.0E-5 to 3.0E7 |
| min_y | Int | Req | Range −2032 to 2031 (inferred from `BlockPos` packing) |
| height | Int | Req | Range 16 to 4064 |
| logical_height | Int | Req | Range 0 to 4064 |
| infiniburn | HolderSet over static `block` | Req | |
| ambient_light | Float | Req | |
| monster_spawn_light_level | IntProvider | Req | Its values must lie within 0–15. |
| monster_spawn_block_light_limit | Int | Req | Range 0–15 |
| skybox | String enum | Opt (`overworld`) | `none`, `overworld` or `end` |
| cardinal_light | String enum | Opt (`default`) | `default` or `nether` |
| attributes | Compound | Opt (empty) | EnvironmentAttributeMap |
| timelines | HolderSet over `timeline` | Opt (empty) | |
| default_clock | String | Opt (absent) | Id ref into `world_clock` |

### damage_type — `DamageType.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| message_id | String | Req | |
| scaling | String enum | Req | `never`, `when_caused_by_living_non_player` or `always` |
| exhaustion | Float | Req | |
| effects | String enum | Opt (`hurt`) | `hurt`, `thorns`, `drowning`, `burning`, `poking` or `freezing` |
| death_message_type | String enum | Opt (`default`) | `default`, `fall_variants` or `intentional_game_design` |

### banner_pattern — `BannerPattern.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| asset_id | String (Identifier) | Req | |
| translation_key | String | Req | |

### enchantment — `Enchantment.DIRECT_CODEC`

The definition fields are flattened into the top-level Compound.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| description | TextComponent | Req | |
| supported_items | HolderSet over static `item` | Req | Ids or a tag. |
| primary_items | HolderSet over static `item` | Opt (absent) | |
| weight | Int | Req | Range 1–1024 |
| max_level | Int | Req | Range 1–255 |
| min_cost | Compound | Req | Cost |
| max_cost | Compound | Req | Cost |
| anvil_cost | Int | Req | Must be ≥ 0 |
| slots | List of String | Req | Equipment slot groups: `any`, `mainhand`, `offhand`, `hand`, `feet`, `legs`, `chest`, `head`, `armor`, `body`, `saddle` |
| exclusive_set | HolderSet over `enchantment` | Opt (empty) | |
| effects | Compound | Opt (empty) | Component map (see below) |

- **Cost:** `base` (Int, Req) and `per_level_above_first` (Int, Req).
- **effects:** a Compound keyed by Identifiers from the static `enchantment_effect_component_type` registry (`DataComponentMap` codec over a dispatched map). Each value is decoded by that component type's own codec. The value shapes are:
  - lists of conditional effects (dispatched effect objects plus a loot-condition `requirements`);
  - attribute-effect lists;
  - a single value-effect;
  - unit;
  - sound lists.
- Per-component schemas are not expanded here.


### jukebox_song — `JukeboxSong.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| sound_event | SoundEvent | Req | |
| description | TextComponent | Req | |
| length_in_seconds | Float | Req | Must be positive |
| comparator_output | Int | Req | Range 0–15 |

### instrument — `Instrument.DIRECT_CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| sound_event | SoundEvent | Req | |
| use_duration | Float | Req | Must be ≥ 0 |
| range | Float | Req | Must be positive |
| durability_damage | Int | Opt (0) | Must be ≥ 0 |
| description | TextComponent | Req | |

### test_environment — `TestEnvironmentDefinition.DIRECT_CODEC`

The entry dispatches on `type` over the static `test_environment_definition_type` registry. Each type's fields sit flat beside `type`.

| type | Fields |
|---|---|
| `all_of` | `definitions`: a List of Id-or-inline `test_environment` (Req) |
| `clock_time` | `clock`: an Id ref into `world_clock` (Req). `time`: an Int ≥ 0 (Req). |
| `difficulty` | `difficulty`: `peaceful`, `easy`, `normal` or `hard` (Req) |
| `function` | `setup` and `teardown`: Identifier, both Opt |
| `game_rules` | `rules`: a Compound mapping game rule id to a value (Req) |
| `timeline_attributes` | `timelines`: a List of Id refs into `timeline` (Req) |
| `weather` | `weather`: `clear`, `rain` or `thunder` (Req) |

### test_instance — `GameTestInstance.DIRECT_CODEC`

The entry dispatches on `type`: `block_based` (no extra fields) or `function` (adds `function`, an Identifier, Req). The shared fields below sit flat in the same compound:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| environment | String or Compound | Req | Id-or-inline `test_environment` |
| dimension | String (Identifier) | Opt (`minecraft:overworld`) | |
| structure | String (Identifier) | Req | |
| max_ticks | Int | Req | Must be positive |
| setup_ticks | Int | Opt (0) | Must be ≥ 0 |
| required | Byte (bool) | Opt (true) | |
| rotation | String enum | Opt (`none`) | `none`, `clockwise_90`, `180` or `counterclockwise_90` |
| manual_only | Byte (bool) | Opt (false) | |
| max_attempts | Int | Opt (1) | Must be positive |
| required_successes | Int | Opt (1) | Must be positive |
| sky_access | Byte (bool) | Opt (false) | |
| padding | Int | Opt (0) | Range 0–128 |

### dialog — `Dialog.DIRECT_CODEC`

The entry dispatches on `type` over the static `dialog_type` registry, whose values are `notice`, `confirmation`, `multi_action`, `server_links` and `dialog_list`. The common fields and the type's own fields sit flat in one Compound.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| type | String (Identifier) | Req | |
| title | TextComponent | Req | |
| external_title | TextComponent | Opt (absent) | |
| can_close_with_escape | Byte (bool) | Opt (true) | |
| pause | Byte (bool) | Opt (true) | If true, `after_action` must be `close` or `wait_for_response`. |
| after_action | String enum | Opt (`close`) | `close`, `none` or `wait_for_response` |
| body | Compound or List | Opt (empty) | One DialogBody or a list of them |
| inputs | List of Compound | Opt (empty) | Input |

Fields added by each type:

| type | Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|---|
| notice | action | ActionButton | Opt (an OK button) | |
| confirmation | yes, no | ActionButton | Req | |
| multi_action | actions | List of ActionButton | Req | Must be non-empty |
| multi_action | exit_action | ActionButton | Opt (absent) | |
| multi_action | columns | Int | Opt (2) | Must be positive |
| server_links | exit_action | ActionButton | Opt (absent) | |
| server_links | columns | Int | Opt (2) | Must be positive |
| server_links | button_width | Int | Opt (150) | Range 1–1024 |
| dialog_list | dialogs | HolderSet over `dialog` | Req | Inline entries are allowed. |
| dialog_list | exit_action | ActionButton | Opt (absent) | |
| dialog_list | columns | Int | Opt (2) | Must be positive |
| dialog_list | button_width | Int | Opt (150) | Range 1–1024 |

ActionButton:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| label | TextComponent | Req | |
| tooltip | TextComponent | Opt (absent) | |
| width | Int | Opt (150) | Range 1–1024 |
| action | Compound | Opt (absent) | Action (see below) |

Action dispatches on `type`:

| type | Fields |
|---|---|
| `open_url` | `url` (String URI) |
| `run_command` | `command` (String) |
| `suggest_command` | `command` (String) |
| `show_dialog` | `dialog`: Id-or-inline `dialog` |
| `change_page` | `page`: Int, must be positive |
| `copy_to_clipboard` | `value` (String) |
| `custom` | `id` (Identifier, Req), `payload` (any NBT, Opt) |
| `dynamic/run_command` | `template`: a String that must contain at least one `$(var)` |
| `dynamic/custom` | `id` (Identifier, Req), `additions` (Compound, Opt) |

Input:
- `key`: String made of letters, digits and `_`. Req.
- `type`: dispatch over the static `input_control_type` registry. Req.
- The control's own fields sit flat beside these two.

| Control type | Fields |
|---|---|
| `boolean` | `label` (TextComponent, Req), `initial` (bool, Opt false), `on_true` (String, Opt "true"), `on_false` (String, Opt "false") |
| `number_range` | `label` (Req), `label_format` (String, Opt "options.generic_value"), `width` (Int 1–1024, Opt 200), `start` and `end` (Float, Req), `initial` (Float, Opt, must lie between start and end), `step` (Float, Opt, must be positive) |
| `single_option` | `label` (Req), `label_visible` (bool, Opt true), `width` (Int 1–1024, Opt 200), `options` (List, Req, non-empty). Each option is a String id or a Compound `{id: String Req, display: TextComponent Opt, initial: bool Opt false}`, and at most one option may be initial. |
| `text` | `label` (Req), `label_visible` (bool, Opt true), `width` (Int 1–1024, Opt 200), `initial` (String, Opt "", length ≤ max_length), `max_length` (Int, Opt 32, must be positive), `multiline` (Compound, Opt). `multiline` holds `max_lines` (Int, must be positive, Opt) and `height` (Int 1–512, Opt). |

DialogBody dispatches on `type`:

| type | Fields |
|---|---|
| `plain_message` | `contents` (TextComponent, Req), `width` (Int 1–1024, Opt 200) |
| `item` | `item` (Req) is an item id String or `{id, count Int 1–99 Opt 1, components Compound Opt}`. `description` (Opt) is a plain_message body without `type`, or a bare component. Also `show_decorations` (bool, Opt true), `show_tooltip` (bool, Opt true), `width` (Int 1–256, Opt 16) and `height` (Int 1–256, Opt 16). |

### world_clock — `WorldClock.DIRECT_CODEC`

The entry has no fields (`MapCodec.unitCodec`). Send an empty Compound. Any keys present are ignored (inferred).

### timeline — `Timeline.NETWORK_CODEC`

This has the same shape as the direct codec. The only difference is that tracks for environment attributes not marked syncable are dropped, on encode and on decode. The direct codec's validation also applies.

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| clock | String | Req | Id ref into `world_clock` |
| period_ticks | Int | Opt (absent) | Must be positive |
| tracks | Compound | Opt (empty) | Keyed by an Identifier from static `environment_attribute`. The value is a Track. |
| time_markers | Compound | Opt (empty) | Keyed by marker Identifier. The value is a TimeMarkerInfo. |

When `period_ticks` is present:
- marker ticks must be in [0, period);
- keyframe ticks must be in [0, period].

Track:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| modifier | String | Opt (`override`) | A modifier id that the attribute's type allows (list in 6.0) |
| keyframes | List of Compound | Req | Each keyframe has `ticks` (Int ≥ 0, Req) and `value`, whose type depends on the modifier and attribute (Req). The list must be non-empty and ordered by ticks, with at most 2 keyframes on the same tick. |
| ease | String or Compound | Opt (`linear`) | Either a named easing String, or `{cubic_bezier: [x1, y1, x2, y2]}` as 4 Floats with x1 and x2 in [0,1]. |

TimeMarkerInfo is either a bare Int (the tick count, which implies `show_in_commands` false) or a Compound with `ticks` (Int ≥ 0, Req) and `show_in_commands` (bool, Opt false).


### decorated_pot_pattern — `DecoratedPotPattern.CODEC`

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| asset_id | String (Identifier) | Req | |

### block_transformer — `BlockTransformer.DIRECT_CODEC`

The entry's top-level NBT tag is a **List** of 1 to 200 Compounds, not a Compound. Each element:

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| block_state_provider | String or Compound | Req | Id-or-inline `worldgen/block_state_provider` |
| sound | SoundEvent | Opt (empty sound) | |
| particle | String enum | Opt (`none`) | `none`, `scrape`, `wax_on` or `wax_off` |
| disallowed_faces | List of String | Opt (empty) | Direction names |
| loot | String (Identifier) | Opt (absent) | A loot table key. Not resolved. |
| drop_strategy | String enum | Opt (`from_middle`) | `clicked_face` or `from_middle` |
| update_from_neighbors | Byte (bool) | Opt (true) | |
| transform_type | String enum | Opt (`single_block`) | `single_block` or `copper_chest` |
| consume_on_use | Byte (bool) | Opt (true) | |
| item_damage_per_use | Int | Opt (0) | Must be ≥ 0 |

### worldgen/block_state_provider — `BlockStateProvider.DIRECT_CODEC`

The entry takes exactly one of two forms (`Codec.xor`):

1. **A bare block state Compound.** It is written in the BlockState NBT form below and means a simple provider.
2. **A typed provider Compound.** It dispatches on `type` over the static `block_state_provider_type` registry, which has 10 types. That type's fields sit inline; they are not expanded here.

**BlockState NBT form** (`BlockState.FULL_CODEC`, from the `StateHolder` codec):

| Field | NBT type | Req/Opt (default) | Notes |
|---|---|---|---|
| id | String (Identifier) | Req | A block id in the static `block` registry |
| properties | Compound | Opt (the default state) | Maps property name to value String. Present only for blocks that have properties. A missing or invalid property falls back to its default value. |

The keys are lowercase `id` and `properties`, as read from the `StateHolder` constant pool.



## Open questions

1. **Hard-coded vanilla keys in synchronized registries.** Section 3.2 lists the client's `getOrThrow` lookups that were confirmed: the 25 `damage_type` keys and `worldgen/biome` `minecraft:plains`. Other client code paths may need specific vanilla keys too, for example chat-type, dimension-type or timeline lookups during rendering and HUD. No exhaustive search of client `getOrThrow` and `lookupOrThrow` calls was done.
2. **Item default components.** `DataComponentInitializers` rebuilds item default components against the received registries. Whether that requires particular entries, for example instrument or jukebox_song keys referenced by default item components, was not traced.
3. **How a failure ends the connection.** After the "Network Registry Load" crash report, it is not confirmed whether the client disconnects with a message or crashes outright.
4. **Unbound tag references.** Element data can reference a `#tag` of a synchronized registry that no Update Tags packet defines. Whether the client's loading lookup creates such tags lazily (and later fails at freeze with "Unbound tags in registry") or rejects them immediately was not confirmed.
5. **Cartesian product order.** The order of block-state permutations rests on the documented contract of Guava `Lists.cartesianProduct` (first list varies slowest). Guava's bytecode was not inspected.
6. **Dimension Y bounds.** They are derived from `BlockPos.PACKED_Y_LENGTH`, assumed to be 12 bits. Its static initializer was not fully traced.
7. **Unexpanded sub-schemas.** The following are named in section 6 but not expanded:
   - IntProvider and FloatProvider sub-types;
   - per-attribute EnvironmentAttributeMap value codecs, and which attributes are syncable;
   - enchantment effect components;
   - block-state-provider types;
   - text component style sub-objects (click, hover, color, font);
   - the URI and chat-string validation in dialog actions;
   - game rule value types in `test_environment`.
8. **Timeline whole-registry validation.** `Timeline` has a registry-level check with the messages "Timeline has no track for …" and "… defined multiple times". The synchronized list gives `timeline` no validator, so this probably does not run on the network load, but that was not confirmed.
9. **Lenient numeric types.** It is inferred, not traced, that numeric fields accept any numeric NBT tag type when read through `NbtOps`.
10. **Client re-ordering.** Inside `RegistryDataLoader.load`, element registration preserves list order (`Util.sequence`). It was not checked whether any later step re-sorts a registry, for example while tags are bound. The ids in section 4 assume none does.
