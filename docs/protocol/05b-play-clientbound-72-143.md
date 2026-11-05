# Play phase, clientbound, ids 72–143

This document covers clientbound packets 72 (0x48) through 143 (0x8F) of the play phase. Ids are the
registration order in the clientbound builder of `net.minecraft.network.protocol.game.GameProtocols`
(the `lambda$static$3` builder). The method registers every packet in a straight line with no
conditional registration, so the id is simply the position in the list. Id 0 is the bundle delimiter
registered through `withBundlePacket`.

The shared ("common" and "cookie") packets in this range use the same codec as in the configuration
phase. Each one gets a stub section with its id and a pointer to [03-configuration.md](03-configuration.md).
The one exception is Show Dialog (0x8F), whose play-phase codec is different.

## Conventions used in this file

- Type names follow the canonical list in the shared brief, and [00-data-types.md](00-data-types.md)
  defines them. Composite types introduced in this file are defined at the end, under
  "Composite types introduced here".
- **RegistryId<registry>** is a bare VarInt holding the numeric id of an entry in the named registry.
  There is no inline alternative. It comes from `ByteBufCodecs.registry(key)` or
  `ByteBufCodecs.holderRegistry(key)`. For synchronized (data-driven) registries the numeric id is the
  index assigned during registry sync (see [04-registry-sync.md](04-registry-sync.md)).
- **Holder<registry>** is the registry-or-inline encoding from `ByteBufCodecs.holder(key, direct)`.
  The VarInt is 0 for "inline value follows" and *id + 1* for a registry reference. Each use below
  states what the inline value is.
- **OptionalVarInt** (`ByteBufCodecs.OPTIONAL_VAR_INT`) is a single VarInt: 0 means absent and
  *n* > 0 means present with value *n* − 1.
- **TextComponent** covers every `ComponentSerialization` stream codec (`STREAM_CODEC`,
  `TRUSTED_STREAM_CODEC`, `TRUSTED_CONTEXT_FREE_STREAM_CODEC`). On the wire they are the same network-NBT
  text component. They differ only in decoder trust and registry context. The `TRUSTED_OPTIONAL` form
  is written here as Optional TextComponent.
- **String** with no stated maximum means `FriendlyByteBuf.readUtf()` or `ByteBufCodecs.STRING_UTF8`,
  both of which use a maximum of 32767 characters.
- **Enum X** is `FriendlyByteBuf.readEnum`/`writeEnum`, a VarInt of the Java enum ordinal.
  **IdEnum X** is `ByteBufCodecs.idMapper(...)`, a VarInt of the enum's declared id. For every enum
  in this file the declared id equals the ordinal. An out-of-range id decodes to id 0 (strategy
  `ZERO`) unless the text says otherwise.
- "Prefixed Array of X (max N)" means the VarInt count is checked against N on decode.

---

## 0x48 (72) Clientbound Player Look At (ClientboundPlayerLookAtPacket)

Tells the client to rotate its player to face a point or an entity. The encoding is hand-written in
`write(FriendlyByteBuf)` and the matching constructor.

| Field | Type | Notes |
|---|---|---|
| From anchor | Enum EntityAnchor | Which part of the local player is aimed: 0 = feet, 1 = eyes. |
| Target X | Double | Target point. Used directly when there is no target entity, and as a fallback if the target entity is unknown. |
| Target Y | Double | |
| Target Z | Double | |
| Is entity | Boolean | If true, the next two fields are present. |
| Entity id | VarInt | Present only if *Is entity*. The network entity id of the target. |
| To anchor | Enum EntityAnchor | Present only if *Is entity*. Which part of the target is aimed at (0 = feet, 1 = eyes). |

## 0x49 (73) Clientbound Player Position (ClientboundPlayerPositionPacket)

Server-driven teleport and position sync of the local player. The join flow requires this packet. It
is a `StreamCodec.composite` of three fields.

| Field | Type | Notes |
|---|---|---|
| Teleport id | VarInt | Transaction id. The client acknowledges it with serverbound Accept Teleportation (serverbound id 0) (inferred from naming and the serverbound packet; see 05c). |
| Change | PositionMoveRotation | Position, velocity, yaw and pitch. See the composite types section. |
| Relative flags | TeleportFlags | An Int bit set (from `Relative.SET_STREAM_CODEC`). It says which components of *Change* are relative to the client's current values rather than absolute (inferred meaning). |

## 0x4A (74) Clientbound Player Rotation (ClientboundPlayerRotationPacket)

Composite codec. The field order was checked against the getter order in the bootstrap table.

| Field | Type | Notes |
|---|---|---|
| Yaw | Float | Degrees. |
| Yaw is relative | Boolean | If true, *Yaw* is added to the current yaw (inferred). |
| Pitch | Float | Degrees. |
| Pitch is relative | Boolean | If true, *Pitch* is added to the current pitch (inferred). |

## 0x4B (75) Clientbound Recipe Book Add (ClientboundRecipeBookAddPacket)

| Field | Type | Notes |
|---|---|---|
| Entries | Prefixed Array of RecipeBookAddEntry | No explicit maximum. |
| Replace | Boolean | If true, the client clears its known recipe list before it adds these entries (inferred from the field name). |

RecipeBookAddEntry (`ClientboundRecipeBookAddPacket$Entry`):

| Field | Type | Notes |
|---|---|---|
| Contents | RecipeDisplayEntry | See the composite types section. |
| Flags | Byte | Bit 0x01 = show notification (`FLAG_NOTIFICATION`). Bit 0x02 = highlight as new (`FLAG_HIGHLIGHT`). |

## 0x4C (76) Clientbound Recipe Book Remove (ClientboundRecipeBookRemovePacket)

| Field | Type | Notes |
|---|---|---|
| Recipes | Prefixed Array of VarInt | Each element is a RecipeDisplayId, the server-assigned display index used in RecipeDisplayEntry. |

## 0x4D (77) Clientbound Recipe Book Settings (ClientboundRecipeBookSettingsPacket)

The single field is `RecipeBookSettings.STREAM_CODEC`, which is four consecutive TypeSettings
(`RecipeBookSettings$TypeSettings`, each one Boolean *open* followed by Boolean *filtering*).

| Field | Type | Notes |
|---|---|---|
| Crafting open | Boolean | |
| Crafting filtering | Boolean | |
| Furnace open | Boolean | |
| Furnace filtering | Boolean | |
| Blast furnace open | Boolean | |
| Blast furnace filtering | Boolean | |
| Smoker open | Boolean | |
| Smoker filtering | Boolean | |

## 0x4E (78) Clientbound Remove Entities (ClientboundRemoveEntitiesPacket)

| Field | Type | Notes |
|---|---|---|
| Entity ids | Prefixed Array of VarInt | Network entity ids to despawn. No explicit maximum. |

## 0x4F (79) Clientbound Remove Mob Effect (ClientboundRemoveMobEffectPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Effect | RegistryId<mob_effect> | `MobEffect.STREAM_CODEC` = `holderRegistry(MOB_EFFECT)`. There is no inline form. |

## 0x50 (80) Clientbound Reset Score (ClientboundResetScorePacket)

| Field | Type | Notes |
|---|---|---|
| Owner | String (max 32767) | Score holder name. |
| Objective name | Optional String (max 32767) | Written with `writeNullable` (Boolean present flag, then the string). Absent means "reset this owner in all objectives" (inferred). |

## 0x51 (81) Clientbound Resource Pack Pop (ClientboundResourcePackPopPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x52 (82) Clientbound Resource Pack Push (ClientboundResourcePackPushPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x53 (83) Clientbound Post Effects (ClientboundPostEffectsPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x54 (84) Clientbound Respawn (ClientboundRespawnPacket)

Sent when the player changes dimension or respawns. Composite codec.

| Field | Type | Notes |
|---|---|---|
| Spawn info | CommonPlayerSpawnInfo | See the composite types section. The same structure is embedded in the play Login packet (id 50, 0x32). |
| Data to keep | Byte | Bit set. 0x01 = keep attribute modifiers (`KEEP_ATTRIBUTE_MODIFIERS`). 0x02 = keep entity data / metadata (`KEEP_ENTITY_DATA`). 0x03 = keep all (`KEEP_ALL_DATA`). 0 keeps nothing. |

## 0x55 (85) Clientbound Rotate Head (ClientboundRotateHeadPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Head yaw | Angle | A raw signed byte, 1/256 turn. |

## 0x56 (86) Clientbound Section Blocks Update (ClientboundSectionBlocksUpdatePacket)

Multiple block changes within one 16×16×16 chunk section.

| Field | Type | Notes |
|---|---|---|
| Section position | SectionPos | A packed Long. See the composite types section. |
| Count | VarInt | Number of following entries. |
| Entries | Count × VarLong | Each value is *(blockStateId << 12) \| localPos*. *localPos* is 12 bits: local X in bits 8–11, local Z in bits 4–7, local Y in bits 0–3. *blockStateId* is the global block-state id (`Block.BLOCK_STATE_REGISTRY`), in bits 12 and up. The decoder extracts it with an unsigned shift by 12. |

## 0x57 (87) Clientbound Select Advancements Tab (ClientboundSelectAdvancementsTabPacket)

| Field | Type | Notes |
|---|---|---|
| Tab | Optional Identifier | `writeNullable`: a Boolean, then an Identifier if true. Identifies an advancement (a root). Absent means no tab is selected (inferred). |

## 0x58 (88) Clientbound Server Data (ClientboundServerDataPacket)

| Field | Type | Notes |
|---|---|---|
| MOTD | TextComponent | Context-free trusted text component. |
| Icon | Optional ByteArray(VarInt len) | Server icon bytes, presumably PNG (inferred). No explicit length cap (plain `BYTE_ARRAY`). |

## 0x59 (89) Clientbound Set Action Bar Text (ClientboundSetActionBarTextPacket)

| Field | Type | Notes |
|---|---|---|
| Text | TextComponent | |

## 0x5A (90) Clientbound Set Border Center (ClientboundSetBorderCenterPacket)

| Field | Type | Notes |
|---|---|---|
| Center X | Double | |
| Center Z | Double | |

## 0x5B (91) Clientbound Set Border Lerp Size (ClientboundSetBorderLerpSizePacket)

| Field | Type | Notes |
|---|---|---|
| Old size | Double | Diameter. |
| New size | Double | Diameter. |
| Lerp time | VarLong | Duration of the transition, presumably in milliseconds (inferred). |

## 0x5C (92) Clientbound Set Border Size (ClientboundSetBorderSizePacket)

| Field | Type | Notes |
|---|---|---|
| Size | Double | Diameter. |

## 0x5D (93) Clientbound Set Border Warning Delay (ClientboundSetBorderWarningDelayPacket)

| Field | Type | Notes |
|---|---|---|
| Warning delay | VarInt | |

## 0x5E (94) Clientbound Set Border Warning Distance (ClientboundSetBorderWarningDistancePacket)

| Field | Type | Notes |
|---|---|---|
| Warning blocks | VarInt | |

## 0x5F (95) Clientbound Set Camera (ClientboundSetCameraPacket)

| Field | Type | Notes |
|---|---|---|
| Camera entity id | VarInt | Network entity id that the client views from. |

## 0x60 (96) Clientbound Set Chunk Cache Center (ClientboundSetChunkCacheCenterPacket)

The client keeps loaded the chunks within the view radius of this center. The join flow requires this
packet: the client discards chunks outside the radius around this center (inferred).

| Field | Type | Notes |
|---|---|---|
| Chunk X | VarInt | Chunk coordinate (block X >> 4) (inferred). |
| Chunk Z | VarInt | Chunk coordinate (block Z >> 4) (inferred). |

## 0x61 (97) Clientbound Set Chunk Cache Radius (ClientboundSetChunkCacheRadiusPacket)

| Field | Type | Notes |
|---|---|---|
| Radius | VarInt | View distance in chunks. The play Login packet carries the initial value as *chunk radius*. |

## 0x62 (98) Clientbound Set Cursor Item (ClientboundSetCursorItemPacket)

| Field | Type | Notes |
|---|---|---|
| Contents | ItemStack | The optional form (`ItemStack.OPTIONAL_STREAM_CODEC`), which can encode the empty stack. |

## 0x63 (99) Clientbound Set Default Spawn Position (ClientboundSetDefaultSpawnPositionPacket)

| Field | Type | Notes |
|---|---|---|
| Respawn data | RespawnData | See the composite types section: dimension, position, yaw and pitch. |

## 0x64 (100) Clientbound Set Display Objective (ClientboundSetDisplayObjectivePacket)

| Field | Type | Notes |
|---|---|---|
| Slot | IdEnum DisplaySlot | VarInt, written with `writeById`. 0 = list, 1 = sidebar, 2 = below name. 3–18 = the team-coloured sidebars, in TeamColor order (3 = black … 18 = white). |
| Objective name | String (max 32767) | An empty string presumably clears the slot (inferred). |

## 0x65 (101) Clientbound Set Entity Data (ClientboundSetEntityDataPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Metadata | EntityMetadata | See [00-data-types.md](00-data-types.md). It is a sequence of entries, each with a UByte index, a VarInt serializer id (`EntityDataSerializers`) and a serializer-specific value. The sequence ends with a UByte 0xFF (`EOF_MARKER` = 255). |

## 0x66 (102) Clientbound Set Entity Link (ClientboundSetEntityLinkPacket)

| Field | Type | Notes |
|---|---|---|
| Source entity id | Int | The leashed entity. Fixed 4-byte Int, not a VarInt. |
| Destination entity id | Int | The leash holder. A value that resolves to no entity, presumably 0 or −1, detaches the leash (inferred). |

## 0x67 (103) Clientbound Set Entity Motion (ClientboundSetEntityMotionPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Velocity | LpVec3 | The low-precision vector (`Vec3.LP_STREAM_CODEC`, implemented in `LpVec3`). See the composite types section. |

## 0x68 (104) Clientbound Set Equipment (ClientboundSetEquipmentPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Equipment | repeated (Byte, ItemStack) | One or more pairs. The Byte holds the equipment slot ordinal in its low 7 bits. Bit 0x80 (`CONTINUE_MASK`) is set on every pair except the last. The ItemStack is the optional (empty-allowed) form. The decoder reads pairs until it reads a byte whose bit 0x80 is clear. |

Equipment slot ordinals (`EquipmentSlot.VALUES`, which is `values()` order): 0 = main hand,
1 = off hand, 2 = feet, 3 = legs, 4 = chest, 5 = head, 6 = body, 7 = saddle.

## 0x69 (105) Clientbound Set Experience (ClientboundSetExperiencePacket)

| Field | Type | Notes |
|---|---|---|
| Progress | Float | Fraction of the current level, 0–1 (inferred). |
| Level | VarInt | |
| Total experience | VarInt | |

## 0x6A (106) Clientbound Set Health (ClientboundSetHealthPacket)

| Field | Type | Notes |
|---|---|---|
| Health | Float | |
| Food | VarInt | |
| Saturation | Float | |

## 0x6B (107) Clientbound Set Held Slot (ClientboundSetHeldSlotPacket)

| Field | Type | Notes |
|---|---|---|
| Slot | VarInt | Selected hotbar slot index. |

## 0x6C (108) Clientbound Set Objective (ClientboundSetObjectivePacket)

| Field | Type | Notes |
|---|---|---|
| Objective name | String (max 32767) | |
| Method | Byte | 0 = add (`METHOD_ADD`), 1 = remove (`METHOD_REMOVE`), 2 = change (`METHOD_CHANGE`). |
| Display name | TextComponent | Present only if Method is 0 or 2. |
| Render type | Enum ObjectiveRenderType | Present only if Method is 0 or 2. VarInt ordinal: 0 = integer, 1 = hearts. |
| Number format | Optional NumberFormat | Present only if Method is 0 or 2. See the composite types section. |

When Method is 1 nothing follows the Method byte.

## 0x6D (109) Clientbound Set Passengers (ClientboundSetPassengersPacket)

| Field | Type | Notes |
|---|---|---|
| Vehicle entity id | VarInt | |
| Passengers | Prefixed Array of VarInt | Written with `writeVarIntArray`: a VarInt count, then VarInt entity ids. |

## 0x6E (110) Clientbound Set Player Inventory (ClientboundSetPlayerInventoryPacket)

| Field | Type | Notes |
|---|---|---|
| Slot | VarInt | Player inventory slot index. |
| Contents | ItemStack | Optional (empty-allowed) form. |

## 0x6F (111) Clientbound Set Player Team (ClientboundSetPlayerTeamPacket)

This packet is polymorphic on the Method byte.

| Field | Type | Notes |
|---|---|---|
| Team name | String (max 32767) | |
| Method | Byte | 0 = add, 1 = remove, 2 = change (update parameters), 3 = join (add players), 4 = leave (remove players). |
| Parameters | TeamParameters | Present only if Method is 0 or 2. See the composite types section. |
| Players | Prefixed Array of String (max 32767) | Present only if Method is 0, 3 or 4. Score-holder names (player names or entity UUID strings). |

Layouts by method:

| Method | Fields after Method |
|---|---|
| 0 add | TeamParameters, Players |
| 1 remove | (nothing) |
| 2 change | TeamParameters |
| 3 join | Players |
| 4 leave | Players |

## 0x70 (112) Clientbound Set Score (ClientboundSetScorePacket)

| Field | Type | Notes |
|---|---|---|
| Owner | String (max 32767) | Score holder name. |
| Objective name | String (max 32767) | |
| Score | VarInt | |
| Display | Optional TextComponent | Custom display name for this score entry. |
| Number format | Optional NumberFormat | |

## 0x71 (113) Clientbound Set Simulation Distance (ClientboundSetSimulationDistancePacket)

| Field | Type | Notes |
|---|---|---|
| Simulation distance | VarInt | In chunks. |

## 0x72 (114) Clientbound Set Subtitle Text (ClientboundSetSubtitleTextPacket)

| Field | Type | Notes |
|---|---|---|
| Text | TextComponent | |

## 0x73 (115) Clientbound Set Time (ClientboundSetTimePacket)

| Field | Type | Notes |
|---|---|---|
| Game time | Long | Total world ticks. |
| Clock updates | Prefixed Array of (RegistryId<world_clock>, ClockNetworkState) | A map with a VarInt entry count, then key/value pairs. Keys come from `WorldClock.STREAM_CODEC` = `holderRegistry(WORLD_CLOCK)`. No explicit maximum. |

ClockNetworkState:

| Field | Type | Notes |
|---|---|---|
| Total ticks | VarLong | |
| Partial tick | Float | |
| Rate | Float | Clock speed multiplier (inferred). |

## 0x74 (116) Clientbound Set Title Text (ClientboundSetTitleTextPacket)

| Field | Type | Notes |
|---|---|---|
| Text | TextComponent | |

## 0x75 (117) Clientbound Set Titles Animation (ClientboundSetTitlesAnimationPacket)

| Field | Type | Notes |
|---|---|---|
| Fade in | Int | Ticks. Fixed 4-byte Int. |
| Stay | Int | Ticks. |
| Fade out | Int | Ticks. |

## 0x76 (118) Clientbound Sound Entity (ClientboundSoundEntityPacket)

| Field | Type | Notes |
|---|---|---|
| Sound | Holder<sound_event> | VarInt 0 is followed by an inline SoundEvent (see the composite types section). Otherwise the value is registry id + 1. |
| Source | Enum SoundSource | VarInt ordinal. See the table under 0x77. |
| Entity id | VarInt | The emitting entity. |
| Volume | Float | |
| Pitch | Float | |
| Seed | Long | Random seed for sound variant selection. |

## 0x77 (119) Clientbound Sound (ClientboundSoundPacket)

| Field | Type | Notes |
|---|---|---|
| Sound | Holder<sound_event> | Same as in 0x76. |
| Source | Enum SoundSource | VarInt ordinal. |
| X | Int | Fixed-point. The block coordinate is this value divided by 8.0 (`LOCATION_ACCURACY` = 8.0). |
| Y | Int | Fixed-point, ÷ 8. |
| Z | Int | Fixed-point, ÷ 8. |
| Volume | Float | |
| Pitch | Float | |
| Seed | Long | |

SoundSource ordinals: 0 master, 1 music, 2 records, 3 weather, 4 blocks, 5 hostile, 6 neutral,
7 players, 8 ambient, 9 voice, 10 ui.

## 0x78 (120) Clientbound Start Configuration (ClientboundStartConfigurationPacket)

No fields (`StreamCodec.unit`). The server sends it to move the connection from play back to the
configuration phase. The client replies with serverbound Configuration Acknowledged (see 05c and
[01-transport.md](01-transport.md)).

## 0x79 (121) Clientbound Stop Sound (ClientboundStopSoundPacket)

| Field | Type | Notes |
|---|---|---|
| Flags | Byte | Bit 0x01 = a source is present. Bit 0x02 = a sound name is present. |
| Source | Enum SoundSource | Present only if Flags & 0x01. |
| Sound | Identifier | Present only if Flags & 0x02. This is a sound-event identifier, not a registry id. |

The encoder writes 3 when both are set, 1 for source only, 2 for name only and 0 for neither. The
decoder tests each bit with `> 0`.

## 0x7A (122) Clientbound Store Cookie (ClientboundStoreCookiePacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x7B (123) Clientbound Swing Animation (ClientboundSwingAnimationPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Hand | IdEnum InteractionHand | VarInt: 0 = main hand, 1 = off hand. |
| Animation | SwingAnimation | IdEnum SwingAnimationType (VarInt: 0 = none, 1 = whack, 2 = stab; ids assumed equal to ordinals (inferred)), then a VarInt duration. |

## 0x7C (124) Clientbound System Chat (ClientboundSystemChatPacket)

| Field | Type | Notes |
|---|---|---|
| Content | TextComponent | |
| Overlay | Boolean | If true, the text is shown on the action bar instead of in chat (inferred). |

## 0x7D (125) Clientbound Tab List (ClientboundTabListPacket)

| Field | Type | Notes |
|---|---|---|
| Header | TextComponent | |
| Footer | TextComponent | |

## 0x7E (126) Clientbound Tag Query (ClientboundTagQueryPacket)

The response to a serverbound block-entity or entity tag query.

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | Echoes the query id. |
| Tag | NBT | `readNbt`, which may be absent. Network NBT whose root is TAG_End (0) decodes to "no tag". |

## 0x7F (127) Clientbound Take Item Entity (ClientboundTakeItemEntityPacket)

| Field | Type | Notes |
|---|---|---|
| Collected entity id | VarInt | The item / XP / arrow entity being picked up. |
| Collector entity id | VarInt | |
| Amount | VarInt | Stack count picked up. |

## 0x80 (128) Clientbound Teleport Entity (ClientboundTeleportEntityPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Change | PositionMoveRotation | |
| Relative flags | TeleportFlags | Int bit set. |
| On ground | Boolean | |

## 0x81 (129) Clientbound Test Instance Block Status (ClientboundTestInstanceBlockStatus)

| Field | Type | Notes |
|---|---|---|
| Status | TextComponent | |
| Size | Optional Vec3i | Vec3i is three VarInts (X, Y, Z). |

## 0x82 (130) Clientbound Ticking State (ClientboundTickingStatePacket)

| Field | Type | Notes |
|---|---|---|
| Tick rate | Float | Ticks per second. |
| Is frozen | Boolean | |

## 0x83 (131) Clientbound Ticking Step (ClientboundTickingStepPacket)

| Field | Type | Notes |
|---|---|---|
| Tick steps | VarInt | Number of ticks to step while frozen. |

## 0x84 (132) Clientbound Transfer (ClientboundTransferPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x85 (133) Clientbound Update Advancements (ClientboundUpdateAdvancementsPacket)

| Field | Type | Notes |
|---|---|---|
| Reset | Boolean | If true, the client clears all advancement state first. |
| Added | Prefixed Array of PositionedAdvancement | See below. |
| Removed | Prefixed Array of Identifier | Advancement ids to remove. Decoded into a set. |
| Progress | Prefixed Array of (Identifier, AdvancementProgress) | A map: VarInt count, then pairs of advancement id and progress. |
| Show advancements | Boolean | Whether the client should show toasts for this update (inferred). |

PositionedAdvancement (`ClientboundUpdateAdvancementsPacket$PositionedAdvancement`):

| Field | Type | Notes |
|---|---|---|
| Advancement | AdvancementHolder | An Identifier id followed by an Advancement. See the composite types section. |
| X | Float | Display position in the advancement tree. |
| Y | Float | |

## 0x86 (134) Clientbound Update Attributes (ClientboundUpdateAttributesPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Attributes | Prefixed Array of AttributeSnapshot (max 128) | |

AttributeSnapshot:

| Field | Type | Notes |
|---|---|---|
| Attribute | RegistryId<attribute> | `Attribute.STREAM_CODEC` = `holderRegistry(ATTRIBUTE)`. |
| Base value | Double | |
| Modifiers | Prefixed Array of AttributeModifier | No explicit maximum. |

AttributeModifier:

| Field | Type | Notes |
|---|---|---|
| Id | Identifier | Modifier identifier. |
| Amount | Double | |
| Operation | IdEnum AttributeOperation | VarInt: 0 = add value, 1 = add multiplied base, 2 = add multiplied total. |

## 0x87 (135) Clientbound Update Mob Effect (ClientboundUpdateMobEffectPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Effect | RegistryId<mob_effect> | |
| Amplifier | VarInt | |
| Duration | VarInt | Ticks. The server presumably uses −1 for infinite (inferred). |
| Flags | Byte | 0x01 = ambient, 0x02 = visible (particles), 0x04 = show icon, 0x08 = blend. |

## 0x88 (136) Clientbound Update Recipes (ClientboundUpdateRecipesPacket)

| Field | Type | Notes |
|---|---|---|
| Item sets | Prefixed Array of (Identifier, RecipePropertySet) | A map. The key is the identifier of a recipe-property-set key (`ResourceKey.streamCodec(RecipePropertySet.TYPE_KEY)`). The value is RecipePropertySet. No explicit maximum. |
| Stonecutter recipes | Prefixed Array of SelectableRecipeEntry | `SelectableRecipe$SingleInputSet.noRecipeCodec()`: the list of single-input selectable recipes, without the recipe body. See the composite types section. |

## 0x89 (137) Clientbound Update Tags (ClientboundUpdateTagsPacket)

Common packet. See [03-configuration.md](03-configuration.md) and [04-registry-sync.md](04-registry-sync.md).

## 0x8A (138) Clientbound Projectile Power (ClientboundProjectilePowerPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Acceleration power | Double | |

## 0x8B (139) Clientbound Custom Report Details (ClientboundCustomReportDetailsPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x8C (140) Clientbound Server Links (ClientboundServerLinksPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x8D (141) Clientbound Waypoint (ClientboundTrackedWaypointPacket)

| Field | Type | Notes |
|---|---|---|
| Operation | IdEnum WaypointOperation | VarInt: 0 = track, 1 = untrack, 2 = update. Unlike most enums here, an out-of-range id *wraps* (strategy `WRAP`). |
| Waypoint | TrackedWaypoint | See the composite types section. |

## 0x8E (142) Clientbound Clear Dialog (ClientboundClearDialogPacket)

Common packet with no fields (`StreamCodec.unit`). See [03-configuration.md](03-configuration.md).

## 0x8F (143) Clientbound Show Dialog (ClientboundShowDialogPacket)

This is a common packet, but the play phase registers a different codec from the configuration
phase. Play uses `ClientboundShowDialogPacket.STREAM_CODEC`. Configuration uses
`CONTEXT_FREE_STREAM_CODEC`, which encodes only the inline dialog.

| Field | Type | Notes |
|---|---|---|
| Dialog | Holder<dialog> | VarInt 0 means an inline dialog follows, encoded as network NBT through the dialog codec (`ByteBufCodecs.fromCodecWithRegistriesTrusted(Dialog.DIRECT_CODEC)`). Otherwise the value is the dialog registry id + 1. The inline NBT schema is described in [03-configuration.md](03-configuration.md). |

---

## Composite types introduced here

### CommonPlayerSpawnInfo

`net.minecraft.network.protocol.game.CommonPlayerSpawnInfo`, a 10-field composite. The getter order was
checked against the codec bootstrap table. It appears in Respawn (0x54) and in the play Login packet
(id 50, 0x32, documented in [05a](05a-play-clientbound-00-71.md)).

| Field | Type | Notes |
|---|---|---|
| Dimension type | RegistryId<dimension_type> | `DimensionType.STREAM_CODEC` = `holderRegistry(DIMENSION_TYPE)`. This is the index into the dimension_type registry as synchronized during configuration. There is no inline form. |
| Dimension | Identifier | `ResourceKey.streamCodec(DIMENSION)`: the level (dimension) key, e.g. a namespaced id. |
| Seed | Long | The seed value the client uses for client-side effects. It is presumably the obfuscated (hashed) world seed, not the raw seed (inferred). |
| Game mode | IdEnum GameType | VarInt: 0 = survival, 1 = creative, 2 = adventure, 3 = spectator. Out of range decodes to 0. |
| Previous game mode | OptionalVarInt GameType | `GameType.OPTIONAL_STREAM_CODEC`: VarInt 0 = none. Otherwise *gameModeId + 1*. This is **not** the −1 byte convention. |
| Is debug | Boolean | The world is a debug world. |
| Is flat | Boolean | The world is a superflat world, which affects client horizon rendering (inferred). |
| Last death location | Optional GlobalPos | Boolean present flag, then GlobalPos. |
| Portal cooldown | VarInt | Ticks. |
| Sea level | VarInt | |

For reference while implementing the join flow, here is the field order of the play Login packet (id 50,
`ClientboundLoginPacket`) as read from its composite codec: Int player entity id · Boolean hardcore ·
Prefixed Array of Identifier (dimension keys) · VarInt max players · VarInt chunk (view) radius ·
VarInt simulation distance · Boolean reduced debug info · Boolean show death screen · Boolean do limited
crafting · CommonPlayerSpawnInfo · Boolean online mode (field `onlineMode`) · Boolean enforces secure chat.
The authoritative description is in 05a.

### GlobalPos

| Field | Type | Notes |
|---|---|---|
| Dimension | Identifier | Level key. |
| Position | Position | Packed block position (`BlockPos.STREAM_CODEC`). |

### RespawnData

`LevelData$RespawnData.STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| Position | GlobalPos | |
| Yaw | Float | The persistent codec clamps it to −180..180. The stream codec does not enforce that range. |
| Pitch | Float | The persistent codec clamps it to −90..90. The stream codec does not enforce that range. |

### PositionMoveRotation

`net.minecraft.world.entity.PositionMoveRotation.STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| X | Double | Position (`Vec3.STREAM_CODEC`, three Doubles). |
| Y | Double | |
| Z | Double | |
| Velocity X | Double | Delta movement (`Vec3.STREAM_CODEC`). |
| Velocity Y | Double | |
| Velocity Z | Double | |
| Yaw | Float | Degrees. |
| Pitch | Float | Degrees. |

### TeleportFlags

`Relative.SET_STREAM_CODEC` is an Int (4 bytes, big-endian). Each `Relative` value has a bit index, and
the mask is `1 << bit`. A flag is set when *(value & mask) == mask*.

| Bit | Mask | Name |
|---|---|---|
| 0 | 0x001 | X |
| 1 | 0x002 | Y |
| 2 | 0x004 | Z |
| 3 | 0x008 | Y_ROT (yaw) |
| 4 | 0x010 | X_ROT (pitch) |
| 5 | 0x020 | DELTA_X |
| 6 | 0x040 | DELTA_Y |
| 7 | 0x080 | DELTA_Z |
| 8 | 0x100 | ROTATE_DELTA (rotate the velocity vector by the rotation change) (inferred meaning) |

A set bit means the corresponding component in PositionMoveRotation is relative (added to the current
value). A clear bit means it is absolute (inferred meaning).

### LpVec3
Defined in [00-data-types.md §4.6](00-data-types.md#46-lpvec3-low-precision-velocity-vector).

### SectionPos

A Long (`SectionPos.STREAM_CODEC` maps `ByteBufCodecs.LONG`). Section X is a signed 22-bit value in bits
42–63, section Z a signed 22-bit value in bits 20–41, and section Y a signed 20-bit value in bits 0–19.
Section coordinates are block coordinates >> 4.

### NumberFormat

`NumberFormatTypes.STREAM_CODEC` dispatches on the number_format_type registry. The Optional form used
in this file is a Boolean present flag followed by this structure.

| Field | Type | Notes |
|---|---|---|
| Type | RegistryId<number_format_type> | Built-in registry. The ids follow registration order in `NumberFormatTypes.bootstrap` (inferred): 0 = blank, 1 = styled, 2 = fixed. |
| Body | depends on Type | blank: no fields. styled: one Style, encoded as network NBT via the style codec (`Style$Serializer.TRUSTED_STREAM_CODEC`). fixed: one TextComponent. |

### TeamParameters

`ClientboundSetPlayerTeamPacket$Parameters.STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| Display name | TextComponent | |
| Player prefix | TextComponent | |
| Player suffix | TextComponent | |
| Name tag visibility | IdEnum TeamVisibility | VarInt: 0 = always, 1 = never, 2 = hide for other teams, 3 = hide for own team. |
| Collision rule | IdEnum TeamCollisionRule | VarInt: 0 = always, 1 = never, 2 = push other teams, 3 = push own team. |
| Color | Optional IdEnum TeamColor | VarInt 0–15 in order: black, dark_blue, dark_green, dark_aqua, dark_red, dark_purple, gold, gray, dark_gray, blue, green, aqua, red, light_purple, yellow, white. |
| Options | Byte | 0x01 = friendly fire allowed. 0x02 = can see friendly invisibles. |

### SoundEvent (inline Holder<sound_event> value)

`SoundEvent.DIRECT_STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| Sound id | Identifier | |
| Fixed range | Optional Float | |

### AdvancementHolder and Advancement

AdvancementHolder:

| Field | Type | Notes |
|---|---|---|
| Id | Identifier | |
| Advancement | Advancement | |

Advancement (`Advancement.STREAM_CODEC`). Rewards and criteria definitions are not sent.

| Field | Type | Notes |
|---|---|---|
| Parent | Optional Identifier | |
| Display | Optional DisplayInfo | |
| Requirements | Prefixed Array of (Prefixed Array of String (max 32767)) | AdvancementRequirements: an outer list of OR-groups, each a list of criterion names (inferred semantics). |
| Sends telemetry event | Boolean | |

DisplayInfo (`DisplayInfo.serializeToNetwork` / `fromNetwork`):

| Field | Type | Notes |
|---|---|---|
| Title | TextComponent | |
| Description | TextComponent | |
| Icon | ItemStackTemplate | See below. |
| Frame type | IdEnum AdvancementType | VarInt: 0 = task, 1 = challenge, 2 = goal. |
| Flags | Int | Fixed 4-byte Int. 0x01 = has background, 0x02 = show toast, 0x04 = hidden. Announce-to-chat is not transmitted: the decoder sets it to false. |
| Background | Identifier | Present only if Flags & 0x01. The texture id of a client asset. |

AdvancementProgress (`AdvancementProgress.STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Criteria | Prefixed Array of (String (max 32767), CriterionProgress) | A map from criterion name to progress. |

CriterionProgress: an Optional Long. When present, the Long is the instant the criterion was obtained, in
epoch milliseconds (`ByteBufCodecs.INSTANT` maps through `Instant.toEpochMilli`/`ofEpochMilli`).
Absent means not obtained.

### ItemStackTemplate

`net.minecraft.world.item.ItemStackTemplate.STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| Item | RegistryId<item> | `Item.STREAM_CODEC` = `holderRegistry(ITEM)`. |
| Count | VarInt | |
| Components | DataComponentPatch | See [00-data-types.md](00-data-types.md). |

### HolderSet<registry>
Defined in [00-data-types.md §10.3](00-data-types.md#103-holdersetr).

### RecipeDisplayEntry

`RecipeDisplayEntry.STREAM_CODEC`.

| Field | Type | Notes |
|---|---|---|
| Display id | VarInt | RecipeDisplayId, the server-assigned index referenced by Recipe Book Remove and by serverbound recipe packets. |
| Display | RecipeDisplay | |
| Group | OptionalVarInt | 0 = no group. Otherwise group index + 1. |
| Category | RegistryId<recipe_book_category> | |
| Crafting requirements | Optional (Prefixed Array of Ingredient) | Ingredient = HolderSet<item> (`Ingredient.CONTENTS_STREAM_CODEC`). |

### RecipeDisplay

`RecipeDisplay.STREAM_CODEC` dispatches on the recipe_display built-in registry: a VarInt type id, then
the type-specific body. The ids follow registration order in `RecipeDisplays` (inferred).

| Type id | Name | Body |
|---|---|---|
| 0 | crafting_shapeless | Prefixed Array of SlotDisplay (ingredients), SlotDisplay result, SlotDisplay crafting station |
| 1 | crafting_shaped | VarInt width, VarInt height, Prefixed Array of SlotDisplay (ingredients), SlotDisplay result, SlotDisplay crafting station |
| 2 | furnace | SlotDisplay ingredient, SlotDisplay fuel, SlotDisplay result, SlotDisplay crafting station, VarInt duration, Float experience |
| 3 | stonecutter | SlotDisplay input, SlotDisplay result, SlotDisplay crafting station |
| 4 | smithing | SlotDisplay template, SlotDisplay base, SlotDisplay addition, SlotDisplay result, SlotDisplay crafting station |

### SlotDisplay

`SlotDisplay.STREAM_CODEC` dispatches on the slot_display built-in registry: a VarInt type id, then the
body. This type is recursive. The ids follow registration order in `SlotDisplays` (inferred).

| Type id | Name | Body |
|---|---|---|
| 0 | empty | (none) |
| 1 | any_fuel | (none) |
| 2 | with_any_potion | SlotDisplay |
| 3 | only_with_component | SlotDisplay source, RegistryId<data_component_type> |
| 4 | item | RegistryId<item> |
| 5 | item_stack | ItemStackTemplate |
| 6 | tag | HolderSet<item> |
| 7 | dyed | SlotDisplay dye, SlotDisplay target |
| 8 | smithing_trim | SlotDisplay base, SlotDisplay material, Holder<trim_pattern> (inline value: Identifier asset id, TextComponent description, Boolean decal) |
| 9 | with_remainder | SlotDisplay input, SlotDisplay remainder |
| 10 | composite | Prefixed Array of SlotDisplay |

### RecipePropertySet

A Prefixed Array of RegistryId<item> (`Item.STREAM_CODEC` list), decoded as a set.

### SelectableRecipeEntry

One element of the stonecutter list in Update Recipes (`SelectableRecipe$SingleInputEntry.noRecipeCodec`).

| Field | Type | Notes |
|---|---|---|
| Input | HolderSet<item> | Ingredient. |
| Option display | SlotDisplay | `SelectableRecipe.noRecipeCodec` sends only the display. The recipe itself is not transmitted. |

### TrackedWaypoint

`TrackedWaypoint.STREAM_CODEC`, a hand-written read/write.

| Field | Type | Notes |
|---|---|---|
| Identifier kind | Boolean | `writeEither`: true = UUID follows (left), false = String follows (right). |
| Identifier | UUID or String (max 32767) | Depends on the previous Boolean. |
| Icon | WaypointIcon | |
| Type | Enum WaypointType | VarInt ordinal: 0 = empty, 1 = vec3i, 2 = chunk, 3 = azimuth. |
| Contents | depends on Type | empty: nothing. vec3i: VarInt X, VarInt Y, VarInt Z (block position). chunk: VarInt chunk X, VarInt chunk Z. azimuth: Float angle. |

WaypointIcon (`Waypoint$Icon.STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Style | Identifier | Key of a waypoint style asset. |
| Color | Optional RGB | `ByteBufCodecs.RGB_COLOR`: three unsigned bytes R, G, B. Alpha is not transmitted. |

---

## Open questions

1. **Login online-mode field.** `ClientboundLoginPacket` carries a Boolean field named `onlineMode`
   between CommonPlayerSpawnInfo and enforcesSecureChat. Its client-side meaning was not traced; 05a
   owns this packet.
2. **Seed in CommonPlayerSpawnInfo.** The bytecode only shows a Long. The claim that it is a hashed seed
   comes from naming and convention, not from tracing the server-side construction.
3. **Built-in type registry ids.** The numeric ids for number_format_type, recipe_display and
   slot_display are assumed to equal registration order in their bootstrap methods. That is how built-in
   registries assign ids, but this file did not confirm that no other registration intervenes.
4. **SwingAnimationType ids.** The ids are assumed equal to ordinals (none/whack/stab). The id-extractor
   lambda was not inspected.
5. **Border lerp time unit.** The VarLong is presumably milliseconds, but the client-side use was not
   traced.
6. **Set Entity Link detach value.** The value that means "no holder" (0 vs −1) was not confirmed from
   the bytecode.
7. **Teleport flag semantics.** The bit positions are exact. That "set means relative" and the exact
   effect of ROTATE_DELTA are inferred from names.
8. **Dialog inline NBT schema** (0x8F) and **Style NBT schema** (NumberFormat "styled") are not described
   here. They depend on codec-driven NBT structures owned by other documents.
9. **Entity metadata, ItemStack and DataComponentPatch** layouts are deferred to 00-data-types.md.
