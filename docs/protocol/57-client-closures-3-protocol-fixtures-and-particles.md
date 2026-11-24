# 57 part 3. Client closures: the Login packet, Level Particles options and what a fixture must check

| Item | Value |
|---|---|
| Covers | Byte-level wire layout of the clientbound Level Particles packet (0x30, id 48) and of the options of every option-carrying particle type, with worked byte examples and the checks a correct dust fixture must make (§1 to §6); the byte-level layout of the clientbound Login (play) packet (0x32, id 50) with the `CommonPlayerSpawnInfo` block, which values vary per dimension and which are constant, the hashed seed rule, when the previous game mode and the last death location are absent, and the checks a correct all-dimensions standard-profile login fixture must make (§7 to §12) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files under `data/minecraft/` in the jar, with no execution. Byte examples and the hashed-seed vectors are computed by a scratch script from the rules read; they are test vectors, not captured from a running artifact |
| Extends | 05a (0x30 Level Particles, 0x32 Login, the Particle and `CommonPlayerSpawnInfo` composites), 05b (Respawn), 42-1 §3 and §7, 46 §5.1, 09 §3.2 and §3.5, 56 §5, 10 §7.7, 43 §4 |
| Corrects (statements now stale, not edited here) | The "hashed seed is presumed or inferred" wording is closed by §10: 05b Open question 2 and the `Seed` row of the `CommonPlayerSpawnInfo` composite ("presumably the obfuscated (hashed) world seed ... (inferred)"); 09 §3.2 ("hashed seed: standard `obfuscateSeed(Seed)` (10 §7.7, WT §2.1, inferred)"); `../design/world-types.md` §2 (the "Login hashed seed (09 §3.2)" paragraph, "**inferred**"); 43 §4 ("05b says the packet field is presumably that hashed seed"). 05b Open question 1 ("client-side meaning of `onlineMode` not traced") is answered in part by §12.1 |

Two proto fixtures exist by name, `play-s2c-30-level-particles-dust` and `play-s2c-32-login-all-dimensions-standard`, and no document has stated what a correct fixture of each must check. §6 and §12 state it, so that a test author can build and check such fixtures from this document and the documents it cites (the fixture files themselves were not read in this round).

## 0. Already documented elsewhere, and what this part adds

| Topic | Already documented in | Status after re-reading the jar this round |
|---|---|---|
| Level Particles field list and ids | 05a 0x30; 42-1 §7.2 (client handling, random draws) | Agrees (field order re-read from the packet codec). This part adds the byte sizes, a full worked packet and the fixture checklist |
| Option layouts per particle type | 05a "Particle"; 42-1 §3 (the authority for meaning); 46 §5.1 (ids) | Agrees on all 22 option types. This part adds the byte-by-byte tables, the decode-time rules (scale clamp, NaN, error cases) and worked examples |
| Particle type ids | 46 §5.1; 42-1 §2 | Agrees: the registration order was re-read from `ParticleTypes.<clinit>` this round (§3) |
| Login and `CommonPlayerSpawnInfo` field list | 05a 0x32 and composite; 05b composite | Agrees. This part adds the byte sizes, a full worked packet per dimension, the server-side source of every field and the client handling |
| Hashed seed | 05b Open question 2 ("presumably hashed"), 09 §3.2 ("inferred"), 10 §7.7 (the function) | The server side is now read, not inferred (§10). The client use is read (§10) |
| Sea level and flat flag per dimension | 56 §5 (flag, -63), 37 and 38 (dimension types) | Re-read: sea levels 63, 32, 0 from the shipped noise settings (§9) |

## 1. Primitive encodings used here

All integers and floating-point values below are big-endian on the wire (Netty `ByteBuf` default; the `Int` codec was read to use `readInt` / `writeInt`, 00 lists the others). A VarInt is the 7-bit-group form of 00; a negative VarInt (for example sea level -63) is always five bytes. A Boolean is one byte, 0x00 false and 0x01 true. An Identifier is a VarInt byte length followed by that many UTF-8 bytes (`ResourceKey.streamCodec` reads and writes the location as an Identifier string). A `Position` is the packed 64-bit block position of 00 §4.1 (X in bits 38 to 63, Z in bits 12 to 37, Y in bits 0 to 11, each two's complement).

Gap closed: one place for the wire primitives the later sections name.

## 2. The Level Particles packet (id 0x30 = 48)

The id was re-derived this round by counting the `addPacket` entries of the clientbound template in `GameProtocols`: the entry for `CLIENTBOUND_LEVEL_PARTICLES` is index 48, `CLIENTBOUND_LOGIN` is 50 and `CLIENTBOUND_RESPAWN` is 84, out of 144 entries (0 to 143). This matches 05a, 05b and 09.

Body, in wire order (the record `ClientboundLevelParticlesPacket` and its stream codec, 14 components):

| # | Field (record component) | Wire type | Size | Notes |
|---|---|---|---|---|
| 1 | `particle` | VarInt type id, then that type's option bytes | 1 byte (ids 0 to 127) plus options (§4) | Comes first, before the coordinates. An unknown id is a decode error (the registry codec reads with a throwing lookup) |
| 2 | `overrideLimiter` | Boolean | 1 | Also known as the "long distance" flag (the same Boolean). When true the particle skips the 32-block distance test and the Particles option test (42-1 §7.1 step 2). The particle type's own override flag is OR-ed with it |
| 3 | `alwaysShow` | Boolean | 1 | Feeds the Particles-option status roll (`calculateParticleLevel`): with option MINIMAL, an always-show particle is first upgraded to DECREASED with probability 1 in 10 and is then thinned by the DECREASED rule (kept 2 times in 3), about 6.7 percent overall (42-1 §7.1, which has the draw order; re-read, agrees) |
| 4 | `x` | Double | 8 | World coordinate |
| 5 | `y` | Double | 8 | |
| 6 | `z` | Double | 8 | |
| 7 | `xDist` | Float | 4 | Spread (count > 0) or direction component (count = 0) |
| 8 | `yDist` | Float | 4 | |
| 9 | `zDist` | Float | 4 | |
| 10 | `xMaxSpeed` | Float | 4 | |
| 11 | `yMaxSpeed` | Float | 4 | |
| 12 | `zMaxSpeed` | Float | 4 | |
| 13 | `count` | VarInt | 1 to 5 | 0 selects speed mode (one particle). A negative count is not guarded; the spawn loop condition makes it run zero times (inferred from the loop test) |
| 14 | `randomizationType` | VarInt id of an enum | 1 | 0 `DEFAULT`, 1 `ALTERNATIVE`, 2 `ALTERNATIVE_WITH_SPEED`; an out-of-range id decodes as 0 (the by-id map uses the "zero" out-of-bounds strategy) |

Everything after the particle is fixed length except the two VarInts: 1 + 1 + 24 + 24 = 50 bytes, then `count` and `randomizationType`. The shorter packet constructor (no randomisation argument) sets the three max speeds all to its single speed argument and the randomisation to `DEFAULT`; that constructor is not a wire form.

Client handling (re-read; 42-1 §7.2 has the full draw order and is the authority): `handleParticleEvent` with count 0 spawns one particle with velocity (xMaxSpeed times xDist, yMaxSpeed times yDist, zMaxSpeed times zDist); with count above 0 and `DEFAULT` it draws six `nextGaussian` values per particle; any other randomisation draws uniform `nextDouble` offsets (`isAlternative` is "not DEFAULT"). A thrown error while adding one particle is logged ("Could not spawn particle effect") and ends the handler.

Gap closed: the full packet layout with sizes; the meaning of the override limiter ("long distance") flag; decode failure modes.

## 3. Particle type ids (cross-check of 46 §5.1 and 05a)

`ParticleTypes.<clinit>` makes 128 `register` calls. The numeric id is the call order (0 to 127). The 22 calls that pass the four-argument form (name, override flag, map-codec function, stream-codec function) are exactly the option-carrying types; the other 106 use the two-argument form (a `SimpleParticleType`, no option bytes). The static field declarations of the 22 are in the same order as the calls, which fixes the options class of each. Every id and key below agrees with 46 §5.1 and with 05a's option table.

| Id | Key | Options class | Wire after the VarInt id | Own override flag |
|---|---|---|---|---|
| 1 | `block` | `BlockParticleOption` | VarInt state id | false |
| 2 | `block_marker` | `BlockParticleOption` | VarInt state id | true |
| 7 | `geyser` | `GeyserParticleOptions` | Int | true |
| 8 | `geyser_base` | `GeyserBaseParticleOptions` | Int, Float | true |
| 9 | `geyser_poof` | `GeyserBaseParticleOptions` | Int, Float | true |
| 10 | `geyser_plume` | `GeyserParticleOptions` | Int | true |
| 15 | `dragon_breath` | `PowerParticleOption` | Float | false |
| 21 | `dust` | `DustParticleOptions` | Int, Float | false |
| 22 | `dust_color_transition` | `DustColorTransitionOptions` | Int, Int, Float | false |
| 23 | `effect` | `SpellParticleOption` | Int, Float | false |
| 28 | `entity_effect` | `ColorParticleOption` | Int | false |
| 36 | `falling_dust` | `BlockParticleOption` | VarInt state id | false |
| 46 | `tinted_leaves` | `ColorParticleOption` | Int | false |
| 48 | `sculk_charge` | `SculkChargeParticleOptions` | Float | true |
| 52 | `flash` | `ColorParticleOption` | Int | false |
| 56 | `instant_effect` | `SpellParticleOption` | Int, Float | false |
| 57 | `item` | `ItemParticleOption` | item stack template | false |
| 58 | `vibration` | `VibrationParticleOption` | position source, VarInt | true |
| 59 | `trail` | `TrailParticleOption` | 3 Doubles, Int, VarInt | false |
| 115 | `shriek` | `ShriekParticleOption` | VarInt | false |
| 121 | `dust_pillar` | `BlockParticleOption` | VarInt state id | false |
| 125 | `block_crumble` | `BlockParticleOption` | VarInt state id | false |

(The override column is the flag read from the second argument of the register call; 42-1 §2 tabulates the flag of all 128.) Dust is id 21 = byte `15`, dust colour transition 22 = `16`, block 1 = `01`, item 57 = `39`, entity effect 28 = `1C`, sculk charge 48 = `30`, shriek 115 = `73`. The type id is always one byte because all ids are below 128.

The stream codec that carries the id is the registry codec (`ByteBufCodecs.registry(PARTICLE_TYPE)`), then a dispatch on the type to that type's own stream codec. There is no length prefix: a decoder that does not know a type's layout cannot skip it.

Gap closed: particle type id order cross-check; which class and layout each option type uses.

## 4. Option encodings, byte by byte

### 4.1 Dust (id 21): `Int colour`, `Float scale` (8 bytes)

| Bytes | Field | Rules |
|---|---|---|
| 4 | colour, Int | Stored raw as the full 32-bit word, not masked on either side. The client reads only the low 24 bits (`vector3fFromRGB24`: red = bits 16 to 23, green = bits 8 to 15, blue = bits 0 to 7, each divided by 255.0). A correct server writes the high byte as 0x00 (42-1 note 3). Pure red is `00 FF 00 00` (the constant `REDSTONE_PARTICLE_COLOR` is 16711680 = 0x00FF0000) |
| 4 | scale, Float | The constructor of the shared base class clamps the value to the range 0.01 to 4.0 (constants `MIN_SCALE` 0.01f and `MAX_SCALE` 4.0f) on every construction, including when the client decodes it. A wire value below 0.01 becomes 0.01 and one above 4.0 becomes 4.0. The clamp compares "less than minimum" first and otherwise takes the smaller of the value and the maximum, so a NaN passes through unclamped (read from `Mth.clamp(FFF)`). The constant `REDSTONE` is colour 16711680, scale 1.0. The data form (JSON, NBT and command form) uses a different codec, `SCALE`, which validates the scale and returns an error for a value outside 0.01 to 4.0 instead of clamping (read in `ScalableParticleOptionsBase`); only the wire form clamps |

Bit patterns: 0.01 = `3C 23 D7 0A`, 0.5 = `3F 00 00 00`, 1.0 = `3F 80 00 00`, 4.0 = `40 80 00 00`.

### 4.2 Dust colour transition (id 22): `Int from`, `Int to`, `Float scale` (12 bytes)

Same colour and scale rules as dust (`getFromColor`, `getToColor` both go through `vector3fFromRGB24`; the same clamp). The constant `SCULK_TO_REDSTONE` is from 3790560 (`00 39 D6 E0`) to 16711680 (`00 FF 00 00`), scale 1.0.

### 4.3 Block family (ids 1, 2, 36, 121, 125): `VarInt state id`

One VarInt, the id in the global block state registry (`Block.BLOCK_STATE_REGISTRY`; 24 part 1 §3 for the id rule, `air` 0, `stone` 1, `oak_planks` 15). The codec maps the id with the throwing lookup (`byIdOrThrow`), so an id that is not a state is a decode error (`IllegalArgumentException`), not an absent state. Five types share the class; the type id in front distinguishes them.

### 4.4 Item (id 57): `ItemStackTemplate`

| Field | Wire type | Rules |
|---|---|---|
| item | VarInt | `Item.STREAM_CODEC` is the holder registry codec: the plain item registry id, no +1 (diamond is 1012, 25 part 4; bytes `F4 07`) |
| count | VarInt | The record constructor throws `IllegalStateException` ("Item must be non-empty") when the count is 0 or the item is `air`; that test is the only range check read: a negative count is not rejected by the constructor and no upper bound was read. A fixture uses 1 |
| components | `DataComponentPatch` | 00 §12.2: VarInt added count, VarInt removed count, then the entries. An empty patch is `00 00` |

### 4.5 Colour options (ids 28, 46, 52): `Int colour` (4 bytes)

The full 32-bit word is ARGB (alpha in the high byte). The getters split it as alpha = bits 24 to 31, red 16 to 23, green 8 to 15, blue 0 to 7. Two consumers read the alpha getter (`SpellParticle$MobEffectProvider`, which is the entity effect particle, and `FireworkParticles$FlashProvider`, which is the flash), so for `entity_effect` and `flash` a server must write an opaque alpha (`FF`) or the particle is drawn with that alpha. Opaque red is `FF FF 00 00`. `tinted_leaves` also carries the whole word, but its only provider (`FallingLeavesParticle$TintedLeavesProvider`) calls `getRed`, `getGreen` and `getBlue` and not `getAlpha`, so the alpha byte is unused there (a server writes `FF` anyway for a uniform form).

### 4.6 Spell options (ids 23 `effect`, 56 `instant_effect`): `Int colour`, `Float power` (8 bytes)

The getters read red, green, blue from the Int (as above); the alpha byte is not read. Power is a Float (no clamp read). Colour -1 (`FF FF FF FF`) reads as white (42-1 §3).

### 4.7 Other single-value options

The packet is not the only source of these options in a client: `LevelEventHandler` also constructs `SculkChargeParticleOptions` (twice, from level events) and `ShriekParticleOption` (once) on the client itself, with no wire form involved (read: the `new` and constructor calls in that class).

| Type | Id | Bytes | Meaning |
|---|---|---|---|
| `dragon_breath` | 15 | Float | `power` (record component name; meaning not re-derived here, 42-2) |
| `sculk_charge` | 48 | Float | `roll`: the provider copies it into the particle's `roll` and `oRoll`, and `SingleQuadParticle` applies it as the argument of `Quaternionf.rotateZ`; JOML's `rotateZ` takes an angle in radians (library behaviour, recalled, not verified; 42-5 §2 also says radians) |
| `shriek` | 115 | VarInt | `delay`: the particle's `delay` counter starts at this value and the tick method decrements it by one per particle tick while it is above 0 (read in `ShriekParticle`), so the unit is client ticks |
| `geyser`, `geyser_plume` | 7, 10 | Int | `waterBlocks`: a fixed 4-byte Int, not a VarInt. Read by `GeyserEruptionParticle` (stored) and `GeyserPlumeParticle` (read twice in its constructor); the unit is a count of water blocks by the field name (name-derived; the use is 42-5 §2.16) |
| `geyser_base`, `geyser_poof` | 8, 9 | Int, Float | `waterBlocks` (as above) and `burstImpulseBase`, a Float read by `GeyserBaseParticle$Provider` and passed on; its meaning is the field name's and 42-5 §2.16's (name-derived here) |

### 4.8 Vibration (id 58): `PositionSource`, `VarInt arrival ticks`

The position source is the dispatch codec of `PositionSource`: a VarInt registry id of the position source type, then that type's fields. The type ids come from the registration order in `PositionSourceType.<clinit>`: `block` is 0 and `entity` is 1 (this matches 46 §13.3).

| Source | Fields after the VarInt type id |
|---|---|
| block (0) | `Position`, 8 bytes (`BlockPos.STREAM_CODEC`) |
| entity (1) | VarInt entity id, Float y offset |

Then the VarInt arrival time in ticks. (The data-form codec rejects entity sources; the wire form accepts both: 42-1 §3.)

### 4.9 Trail (id 59): `Vec3 target`, `Int colour`, `VarInt duration`

`Vec3.STREAM_CODEC` is three Doubles (x, y, z; 24 bytes; the decoder class reads `readDouble` three times), not the low-precision form. Then an Int colour and a VarInt duration. `TrailParticle$Provider` passes `color()` to the particle, which splits it with `ARGB.red`, `ARGB.green` and `ARGB.blue` only (after `ARGB.scaleRGB`), so the high byte is unused (agrees with 42-1 §3: RGB24), and the provider calls `setLifetime` with the duration, so the duration is in client ticks.

Gap closed: byte layout, ranges and decode rules of every option-carrying particle type, including the scale clamp (0.01 to 4.0) and the colour packing.

## 5. Worked byte examples

Option bytes only (after the particle's own id they are exactly what follows; the first byte is the VarInt type id). Block state ids from 24 part 1, item id from 25 part 4.

| Particle | Option bytes, hex | Length |
|---|---|---|
| dust, red (0x00FF0000), scale 1.0 | `15 00 FF 00 00 3F 80 00 00` | 9 |
| dust, colour 0x3366CC, scale 0.5 | `15 00 33 66 CC 3F 00 00 00` | 9 |
| dust colour transition, sculk (3790560) to red (16711680), scale 1.0 | `16 00 39 D6 E0 00 FF 00 00 3F 80 00 00` | 13 |
| block, `stone` (state 1) | `01 01` | 2 |
| block, `oak_planks` (state 15) | `01 0F` | 2 |
| falling dust, `oak_planks` | `24 0F` | 2 |
| item, `diamond` (1012), count 1, empty patch | `39 F4 07 01 00 00` | 6 |
| entity effect, opaque red (0xFFFF0000) | `1C FF FF 00 00` | 5 |
| effect, colour 0x00FF8000, power 1.0 | `17 00 FF 80 00 3F 80 00 00` | 9 |
| sculk charge, roll 1.0 | `30 3F 80 00 00` | 5 |
| shriek, delay 5 | `73 05` | 2 |
| dragon breath, power 1.0 | `0F 3F 80 00 00` | 5 |
| tinted leaves, 0xFF5A8C2D | `2E FF 5A 8C 2D` | 5 |
| flash, 0xFFFFFFFF | `34 FF FF FF FF` | 5 |
| vibration, block (10, 64, -3), 20 ticks | `3A 00 00 00 02 BF FF FF D0 40 14` | 11 |
| vibration, entity 7, y offset 0.5, 20 ticks | `3A 01 07 3F 00 00 00 14` | 8 |
| trail, target (1.5, 64.0, -2.5), colour 0x3366CC, duration 40 | `3B 3F F8 00 00 00 00 00 00 40 50 00 00 00 00 00 00 C0 04 00 00 00 00 00 00 00 33 66 CC 28` | 30 |
| geyser, water blocks 6 | `07 00 00 00 06` | 5 |
| geyser base, water blocks 6, impulse 0.5 | `08 00 00 00 06 3F 00 00 00` | 9 |
| heart (simple type, no options) | `37` | 1 |

(The vibration block position is the packed long `00 00 02 BF FF FF D0 40`: X 10 in bits 38 and up, Z -3 as 26 bits in bits 12 to 37, Y 64 in the low 12 bits.)

Complete packet, the packet-id byte first and then the body: a red dust at (1.5, 64.0, -2.5), spread 0, max speed 0, one particle, default randomisation, no override, not always visible. 62 bytes including the id byte:

```
30                                   packet id
15 00 FF 00 00 3F 80 00 00           dust, colour 0x00FF0000, scale 1.0
00                                   override limiter false
00                                   always show false
3F F8 00 00 00 00 00 00              x = 1.5
40 50 00 00 00 00 00 00              y = 64.0
C0 04 00 00 00 00 00 00              z = -2.5
00 00 00 00  00 00 00 00  00 00 00 00      x, y, z distance = 0.0
00 00 00 00  00 00 00 00  00 00 00 00      x, y, z max speed = 0.0
01                                   count 1
00                                   randomisation DEFAULT
```

Gap closed: byte-level worked examples for dust, dust transition, block, item, entity effect and sculk charge (and the rest).

## 6. What a correct dust fixture must contain and check

A fixture named `play-s2c-30-level-particles-dust` is, by the name (inferred: one Level Particles packet whose particle is the dust type), correct when all of the following hold:

1. **Packet id** `30` as the first body byte (VarInt 48).
2. **Particle type** VarInt 21 (byte `15`); the particle is the dust type, not `dust_color_transition` (22) or `dust_pillar` (121).
3. **Options**: exactly 8 bytes after the type id: Int colour then Float scale, in that order. The colour's high byte is `00` for a normal fixture (a decoder may also accept other high bytes, which are ignored by the client). The scale must lie in 0.01 to 4.0 inclusive; a fixture that wants to prove the clamp may carry a value outside it and must then state that the client sees the clamped value (0.01 or 4.0), and the decoder must report the clamped value on decode if it models the constructor.
4. **Override limiter** and **always show**: one Boolean byte each, written `00` or `01`. Dust's own override flag is false (§3), so with override limiter false the particle is subject to the 32-block distance test and the Particles option (42-1 §7.1). A fixture meant to be visible in tests that place the camera far away sets override limiter to 1.
5. **Position**: three Doubles (24 bytes), big-endian. A decoder compares them exactly.
6. **Distances and max speeds**: six Floats (24 bytes) in the order x dist, y dist, z dist, x max speed, y max speed, z max speed. With count 0 the distances are direction components and the max speeds multipliers (velocity = max speed times distance per axis); with count above 0 they are spreads and speeds (42-1 §7.2).
7. **Count** a VarInt (`01` in the example, a VarInt of 0 for speed mode) and **randomisation** a VarInt in 0 to 2.
8. **No trailing bytes**: the packet is exactly 1 (id) + 9 (dust) + 2 + 24 + 24 + 1 + 1 = 62 bytes including the id byte for the example above; with a one-byte count and a one-byte randomisation the total is always 62 bytes including the id for a dust packet.
9. **Round trip**: decode then re-encode gives the same bytes. Because the Int colour is stored raw, the round trip is exact including a non-zero high byte; only the scale can change (by clamping), so a fixture with an in-range scale round-trips bit-exactly.

The decoder verification list, field by field: type id 21; colour (compare the full Int and, separately, the low 24 bits as the colour the client uses); scale (Float, compare bit pattern, and check the range); override limiter; always show; x, y, z; the six Floats; count; randomisation; and that no byte remains.

Gap closed: what a correct dust fixture must contain and which fields a decoder must verify, including the packet's other fields.

## 7. The Login (play) packet (id 0x32 = 50)

Body (`ClientboundLoginPacket`, 12 components, wire order read from the stream codec and from the accessor order of its bootstrap methods):

| # | Field (record component) | Wire type | Size | Notes |
|---|---|---|---|---|
| 1 | `playerId` | Int | 4 | Fixed 4-byte Int, not a VarInt |
| 2 | `hardcore` | Boolean | 1 | |
| 3 | `levels` | collection of Identifier: VarInt count, then each Identifier | varies | A `Set` of level keys. The decoder builds a set, so a duplicate key collapses. Order on the wire is the sender's iteration order |
| 4 | `maxPlayers` | VarInt | 1 to 5 | |
| 5 | `chunkRadius` | VarInt | 1 to 5 | The view distance in chunks |
| 6 | `simulationDistance` | VarInt | 1 to 5 | |
| 7 | `reducedDebugInfo` | Boolean | 1 | |
| 8 | `showDeathScreen` | Boolean | 1 | |
| 9 | `doLimitedCrafting` | Boolean | 1 | |
| 10 | `commonPlayerSpawnInfo` | `CommonPlayerSpawnInfo` (§8) | varies | |
| 11 | `onlineMode` | Boolean | 1 | Field name `onlineMode` (05b Open question 1) |
| 12 | `enforcesSecureChat` | Boolean | 1 | |

The collection codec has no maximum size (the single-argument `ByteBufCodecs.collection`). Nothing follows field 12.

Gap closed: the full field list and order of the Login packet with byte sizes.

## 8. `CommonPlayerSpawnInfo` (10 fields, also the body of Respawn's first field)

| # | Field | Wire type | Rules |
|---|---|---|---|
| 1 | dimension type | VarInt | `DimensionType.STREAM_CODEC`, the holder registry codec: the entry's id in the `minecraft:dimension_type` registry as the client received it in configuration (04 §6; ids follow 23 §3.4). Decoded with a throwing lookup, so an id the client does not have is a decode error. No inline form |
| 2 | dimension | Identifier | `ResourceKey.streamCodec(DIMENSION)`: the level key |
| 3 | seed | Long | 8 bytes. The hashed seed (§10) |
| 4 | game mode | VarInt | `GameType.STREAM_CODEC`: 0 survival, 1 creative, 2 adventure, 3 spectator; an out-of-range id decodes as 0 |
| 5 | previous game mode | VarInt, optional form | `GameType.OPTIONAL_STREAM_CODEC`, built on `OPTIONAL_VAR_INT`: **0 means none; a present mode is written as id + 1** (survival 1, creative 2, adventure 3, spectator 4). Not a -1 byte convention |
| 6 | is debug | Boolean | |
| 7 | is flat | Boolean | |
| 8 | last death location | Boolean present flag, then `GlobalPos` when 1 | `GlobalPos`: Identifier dimension, then `Position` (8 bytes). When the flag is 0 nothing follows |
| 9 | portal cooldown | VarInt | ticks |
| 10 | sea level | VarInt | a negative level is five bytes: -63 is `C1 FF FF FF 0F` |

Gap closed: CommonPlayerSpawnInfo encoding, including the "none" encoding of the previous game mode.

## 9. Where each value comes from, and what varies per dimension

### 9.1 Server side (`PlayerList.placeNewPlayer`, `ServerPlayer.createCommonSpawnInfo`)

| Field | Source |
|---|---|
| `playerId` | the player entity's network id |
| `hardcore` | the level data's hardcore flag |
| `levels` | `MinecraftServer.levelKeys()`: the keys of **every** level the server has loaded, the same set for every player (not filtered by the player's dimension) |
| `maxPlayers`, `chunkRadius`, `simulationDistance` | the player list's max players, view distance and simulation distance |
| `reducedDebugInfo` | game rule `reduced_debug_info` |
| `showDeathScreen` | the negation of game rule `immediate_respawn` |
| `doLimitedCrafting` | game rule `limited_crafting` |
| spawn info | `createCommonSpawnInfo(level)` for the level the player is placed in: the level's dimension type holder and key; `obfuscateSeed(level.getSeed())`; the player's game mode; `Optional.ofNullable(previousGameMode)`; `level.isDebug()`; `level.isFlat()`; the player's last death location; the player's portal cooldown; `level.getSeaLevel()` |
| `onlineMode` | `MinecraftServer.usesAuthentication()` |
| `enforcesSecureChat` | `MinecraftServer.enforceSecureProfile()` |

33 §6.4 and 09 §3.2 give the CobolCraft values of the rule-driven fields.

### 9.2 Per dimension: what varies and what is constant

| Value | `minecraft:overworld` | `minecraft:the_nether` | `minecraft:the_end` | Notes |
|---|---|---|---|---|
| dimension key (spawn info field 2) | `minecraft:overworld` | `minecraft:the_nether` | `minecraft:the_end` | varies |
| dimension type file | `dimension_type/overworld.json` | `dimension_type/the_nether.json` | `dimension_type/the_end.json` | the jar has four files: the three above and `overworld_caves.json`, which no shipped world preset's level stem uses |
| dimension type id (field 1) | per §9.3 | per §9.3 | per §9.3 | varies; must equal the id the client received |
| sea level (field 10), noise world | 63 | 32 | 0 | read from `sea_level` in `worldgen/noise_settings/overworld.json`, `nether.json`, `end.json`; the level stems of the `normal` preset name these three settings |
| sea level, `flat_all_dimensions` preset | -63 | -63 | -63 | all three level stems use the `minecraft:flat` generator (read in `world_preset/flat_all_dimensions.json`); `FlatLevelSource.getSeaLevel` returns -63 |
| sea level, `flat` preset | -63 | 32 | 0 | only the overworld stem is flat in `world_preset/flat.json`; the other two stay noise levels |
| is flat (field 7) | world-wide, see below | same value | same value | 56 §5.1: one value for the whole world, true exactly when the **overworld** stem is a flat generator, in every dimension |
| is debug (field 6) | false | false | false | true only for the debug preset (`debug_all_block_states`), not in the standard profile |
| hashed seed (field 3) | the same value in all three dimensions | | | `obfuscateSeed` of the one world seed (§10) |
| game mode, previous game mode, last death location, portal cooldown | per player, not per dimension | | | §11 |

Constant across the packet for every dimension of the standard profile: hardcore false, the `levels` set (all three keys with `extra-dimensions` on, 09 §3.2 and §3.5; only the overworld with it off), max players 20, view and simulation distance (the configured view distance), `onlineMode` false, `enforcesSecureChat` false (09 §3.2 values; the field sources are in §9.1).

### 9.3 Dimension type ids

The client assigns dimension type ids in the order it receives the Registry Data entries (04 §4), and the server sends in its registry order, which is the path-first sorted order of 23 §3.4 for a pack-loaded registry. Sorting the four shipped keys path first gives `overworld`, `overworld_caves`, `the_end`, `the_nether`:

| Registry content sent | overworld | the_nether | the_end |
|---|---|---|---|
| all four shipped entries (computed from the sort rule) | 0 | 3 | 2 |
| only the three used entries (04 §3.2 allows a minimal server to send just the dimension types the Login and Respawn packets reference; computed) | 0 | 2 | 1 |

The fixture must use the ids of the Registry Data fixture it is paired with, not a guess. The worked bytes in §12 use the four-entry table; a three-entry registry changes only the dimension type byte.

Gap closed: which Login values vary per dimension (key, type id, sea level, and for flat presets sea level) and which are constant.

## 10. The hashed seed

- **Server rule (read).** `createCommonSpawnInfo` passes `BiomeManager.obfuscateSeed(ServerLevel.getSeed())`, where `getSeed()` is the world seed (the `Seed` of `level.dat`, 07; the seed text rule is 11 §12). So the Login and Respawn `seed` field is the hash of the world seed, never the raw seed. This closes 05b Open question 2 and the "inferred" in 09 §3.2 and world-types.
- **The function (read).** `obfuscateSeed(s)` calls `Hashing.sha256().hashLong(s).asLong()` (Guava). 10 §7.7 gives it as the first 8 bytes of SHA-256 of the 8 little-endian bytes of `s`, read as a little-endian 64-bit integer. The byte order of the two Guava calls is library behaviour, and Guava is not in the game jar, so that detail is carried over from 10 §7.7 and is not re-read (Open question 1). Test vectors computed with that rule (scratch script, not captured from a running game; the wire Long is big-endian):

| World seed | `obfuscateSeed` (decimal) | Wire bytes of the Long |
|---|---|---|
| 0 | 8794265229978523055 | `7A 0B 81 A1 F5 70 55 AF` |
| 1 | -6467378160175308932 | `A6 3F 41 D4 36 A1 9F 7C` |
| 12345 | 293737985876514017 | `04 13 91 24 51 35 54 E1` |
| -1 | 6759447113877070610 | `5D CE 61 56 44 AE A3 12` |

- **Client use (read).** `handleLogin` passes `CommonPlayerSpawnInfo.seed()` to the `ClientLevel` constructor, which hands it to the `Level` constructor, which builds `new BiomeManager(this, seed)`. The field `biomeZoomSeed` of `BiomeManager` holds it. The client uses the value for nothing else (no other read of `seed()` in the join handling). It is the seed of the fuzzy 4 x 4 x 4 biome zoom (10 §7.7), which decides biome-dependent colours at biome borders (43 §4: grass, foliage and water tint blending).
- **Is 0 acceptable?** Yes for the protocol: the field is a plain Long with no validation on decode or in `handleLogin`. A server that sends 0 gets a client whose biome zoom offsets differ from the offsets of a server that hashes the seed, so tint blending at biome borders can differ from the server-side biome the generator used (a consequence of 43 §4 and 10 §7.7, not separately read this round); nothing fails. For the standard world type the correct value is `obfuscateSeed(Seed)` of `level.dat` (07); the cobolcraft world type sends 0 by decision (09 §3.2). That a fixture of the standard profile must use the hash, not 0, is a decision of this document (it follows from the server rule above, which is read), not a fact read from the artifact about decoding.

Gap closed: the hashed seed rule (what the client uses it for, whether 0 is acceptable).

## 11. Previous game mode and last death location: when they are absent

- **Previous game mode** is `Optional.ofNullable` of the player's `previousGameModeForPlayer`, which is null until the player's game mode has changed in the session or a saved previous mode is loaded. `changeGameModeForPlayer` stores the old current mode as the previous one when the mode changes; the player's NBT loader reads `playerGameType` and `previousPlayerGameType` (45 part 3) through `readPlayerMode`, which returns `Optional.orElse(null)` of the read value, so it is null when the key is absent (read). So a freshly created player, and a player that never changed mode, has no previous mode: wire byte `00`. After a change from survival to creative the byte is `01` (survival id 0 plus 1).
- **Last death location** is set once per death at the end of `ServerPlayer.die` (the player's own dimension key and block position at death; read: `die` has no early return and every branch in it jumps to a point before the set call, which is followed only by the unload mark and the final return), is copied to the new player object on respawn by `restoreFrom` (read: the copy is not inside any branch and the method has a single return at its end), and is stored in the player NBT as `LastDeathLocation` only when present (45 part 3). Until the player first dies it is absent: one byte `00`. When present it is `01`, an Identifier and an 8-byte `Position`; the dimension in it can differ from the dimension in field 2.
- **Portal cooldown** is the player's entity portal cooldown (a saved Entity field `PortalCooldown`, 45 part 1); a new player has no stored value (read as 0, inferred) and the Login field is a VarInt, `00` for 0.
- **The client** passes `lastDeathLocation` to the local player, `portalCooldown` to the local player, and sets the local game mode from `gameType` with the previous mode `orElse(null)` (`MultiPlayerGameMode.setLocalMode`).

Gap closed: when previous game mode and last death location are absent.

## 12. Client handling of the Login fields, and the all-dimensions fixture

### 12.1 What `handleLogin` does with each field

| Field | Client use |
|---|---|
| `levels` | copied to a list, shuffled (`Collections.shuffle`) and stored as a linked set on the connection; the only reader found is the connection's `levels()` accessor used by `ClientSuggestionProvider.levels()` (command suggestions of dimension arguments; the accessor body was not read, Open question 5) |
| `chunkRadius`, `simulationDistance` | stored as the server render distance and simulation distance (`Options.setServerRenderDistance`) |
| dimension type, dimension | passed to the new `ClientLevel`. No comparison with the `levels` set was seen in `handleLogin` (inferred: the spawn dimension need not be a member, but a server always sends it as one) |
| is debug, is flat, sea level, hardcore | passed to `ClientLevel$ClientLevelData` and the level constructor (difficulty is set to NORMAL here and corrected by a later Change Difficulty packet); the flat flag has two effects (56 §5.3). `ClientLevel.getSeaLevel` returns the stored value |
| seed | biome zoom seed (§10) |
| `playerId` | set as the local player's entity id |
| `reducedDebugInfo`, `showDeathScreen`, `doLimitedCrafting` | set on the local player |
| game mode, previous game mode, last death, portal cooldown | §11 |
| `onlineMode` | stored; when true the client prepares its chat key pair |
| `enforcesSecureChat` | read twice later in the join handling; the consumers were not traced (Open question 11) |

After the packet the client starts the level-loading wait (50) and expects Game Event 13 and the chunk batches (09 §3.2).

### 12.2 A correct `play-s2c-32-login-all-dimensions-standard` fixture

How the fixture name is read (inferred): "all dimensions" in `play-s2c-32-login-all-dimensions-standard` is taken to mean that the `levels` set (field 3) lists every dimension of the standard profile, not that the packet is sent once per dimension; the spawn info is that of the player's current dimension, the overworld (09 §3.2). By the field table of §7 and §8, a Login packet with the same `levels` set and the nether or end spawn info is also a valid packet, and the nether and end byte lines below are valid companion fixtures; the checks below apply to each with the per-dimension values of §9.2. Field by field, for the overworld packet:

| # | Field | Required value |
|---|---|---|
| 0 | packet id | `32` (VarInt 50) |
| 1 | entity id | the fixture's own choice (4 bytes, big-endian) |
| 2 | hardcore | `00` |
| 3 | dimension names | VarInt count 3, then exactly the Identifiers `minecraft:overworld`, `minecraft:the_nether`, `minecraft:the_end` (any order; 09 §3.5 lists them in this order). No duplicates, no other keys. Encoded lengths 19, 20 and 17 bytes (prefixes `13`, `14`, `11`) |
| 4 | max players | 20 (`14`) |
| 5, 6 | view distance, simulation distance | 8 and 8 (`08 08`) |
| 7 | reduced debug info | `00` |
| 8 | show death screen | `01` (immediate respawn off) |
| 9 | limited crafting | `00` |
| 10.1 | dimension type | the overworld's id in the paired Registry Data fixture (0 with four entries, §9.3) |
| 10.2 | dimension | `minecraft:overworld`; must be one of the three names of field 3 |
| 10.3 | hashed seed | `obfuscateSeed` of the fixture's world seed (§10), eight bytes; not 0 |
| 10.4 | game mode | 0 or 1 |
| 10.5 | previous game mode | `00` for a fresh player; if the fixture models a mode change, 1 + previous id |
| 10.6, 10.7 | is debug, is flat | `00 00` for a noise world; `00 01` if the world is a flat preset (then sea level -63 for the overworld, §9.2) |
| 10.8 | last death location | `00` for a player that has not died |
| 10.9 | portal cooldown | `00` |
| 10.10 | sea level | 63 (`3F`) for the overworld of a noise world |
| 11 | online mode | `00` |
| 12 | enforces secure chat | `00` |
| end | no trailing bytes | |

A decoder must verify, in order: the id; entity id; the hardcore flag; the count and every name of the set (exactly the three, no more, no fewer); the three small VarInts; the three flags; the dimension type id (and that it is a registry id the paired Registry Data fixture defines); the dimension key and that it is in the set; the Long; the game mode range 0 to 3; the previous game mode (0 or 1 to 4); both flags; the death flag and, when 1, the two parts of the `GlobalPos`; the portal cooldown; the sea level; the last two flags; and that the packet ends there. The all-dimensions point of the fixture is field 3; a companion check, which the same test can run on the Respawn fixtures of 09 §3.5, is that the sea level and dimension type id follow the destination dimension (§9.2).

Worked bytes (noise world, seed 12345 so the hashed seed is `04 13 91 24 51 35 54 E1`, entity id 1, game mode 0, four-entry registry; hexadecimal; each line is one packet, 109 bytes of body plus the id for the overworld):

Overworld (dimension type 0, sea level 63):
```
32 00 00 00 01 00 03 13 6D 69 6E 65 63 72 61 66 74 3A 6F 76 65 72 77 6F 72 6C 64
14 6D 69 6E 65 63 72 61 66 74 3A 74 68 65 5F 6E 65 74 68 65 72
11 6D 69 6E 65 63 72 61 66 74 3A 74 68 65 5F 65 6E 64
14 08 08 00 01 00
00 13 6D 69 6E 65 63 72 61 66 74 3A 6F 76 65 72 77 6F 72 6C 64
04 13 91 24 51 35 54 E1 00 00 00 00 00 00 3F 00 00
```
Nether (dimension type 3, key `minecraft:the_nether` (`14` + 20 bytes), sea level 32): the same up to the spawn info, then `03 14 6D 69 6E 65 63 72 61 66 74 3A 74 68 65 5F 6E 65 74 68 65 72 04 13 91 24 51 35 54 E1 00 00 00 00 00 00 20 00 00` (110 bytes of body).
End (dimension type 2, key `minecraft:the_end` (`11` + 17 bytes), sea level 0): the same, then `02 11 6D 69 6E 65 63 72 61 66 74 3A 74 68 65 5F 65 6E 64 04 13 91 24 51 35 54 E1 00 00 00 00 00 00 00 00 00` (107 bytes of body).

In each packet the nine bytes after the hashed seed are: game mode `00`, previous game mode `00`, is debug `00`, is flat `00`, last death `00`, portal cooldown `00` (six zero bytes), then the sea level (`3F`, `20` or `00`), then online mode `00` and enforces secure chat `00`. For a fixture with a previous mode and a death location, the spawn info of a creative player who came from survival and died in the Nether at (1, 3, 2) is: `... 01` (game mode creative) `01` (previous: survival + 1) `00 00` (debug, flat) `01 14 6D 69 6E 65 63 72 61 66 74 3A 74 68 65 5F 6E 65 74 68 65 72 00 00 00 40 00 00 20 03` (present, key, packed position) `00` (portal cooldown) `3F` (sea level) `00 00`.

Gap closed: what a correct login fixture for each of overworld, nether and end must check, field by field, including the hashed seed rule and the absence rules.

## Open questions

1. **Guava `hashLong` and `asLong` byte order.** The jar calls `Hashing.sha256().hashLong(seed).asLong()`; the byte order of the two calls is Guava behaviour and the library is not in the game jar. 10 §7.7 states it (and the test vectors of §10 follow it); this part did not read it. A fixture that includes a hashed seed should take its value from a source that runs the function.
2. **Byte order of the wire primitives, residual.** The codecs of Float, Double and Long were read to be plain `ByteBuf` `readFloat` / `readDouble` / `readLong` (and the matching writes), as the `Int` codec is `readInt` / `writeInt`, and `Vec3$1` uses `readDouble` and `writeDouble`. That these are big-endian is Netty's default byte order (library behaviour, recalled, not verified here; 00 states it). Nothing in the packet codecs swaps the byte order.
3. **JOML `rotateZ` unit.** §4.7 says the sculk charge roll is radians because it is the argument of `Quaternionf.rotateZ`; the unit of that library method is recalled, not verified (42-5 §2 says radians).
4. **Meaning of the geyser `burstImpulseBase`, `waterBlocks` and `dragon_breath` power.** The wire form is read; the meaning given is the record component names and the readers named in §4.7 (name-derived); 42-5 §2.16 and 42-2 own the behaviour.
5. **Client consumer of the `levels` set.** The connection accessor `levels()` and `ClientSuggestionProvider.levels()` exist; the body of the latter was not read, so "used for dimension-argument suggestions" is inferred.
6. **Spawn dimension not in `levels`.** No comparison was seen in `handleLogin`; whether a later consumer misbehaves when the spawn dimension is not in the set was not traced.
7. **Sea level consumers on the client.** `ClientLevel.getSeaLevel` returns the stored value; the shared (non-client-package) code that calls it on a client level was not enumerated.
8. **Dimension type id order.** The ids of §9.3 follow from the sort rule of 23 §3.4 applied to the four shipped keys and are computed, not read from a running registry; 37 Open question 8 notes the same dependence on pack order.
9. **The two fixtures and their names.** They were not read, as the round forbids it. The readings of the names (a single dust packet; a Login whose `levels` set holds all three dimensions, sent with the overworld spawn info, with the nether and end packets as companions) are this document's own inference (§6, §12.2). §6 and §12.2 are written to be checked against the fixtures; any difference between a fixture and those sections is either a defect of the fixture or a different reading of the name, to be settled by the fixture's owner, not a reason to relax a check.
10. **Particle types read only by name.** The registration of each of the 106 simple types was counted (two-argument form) but the individual flag of the override column for those was not copied here; 42-1 §2 has the full 128-row table.
11. **`enforcesSecureChat` consumers.** `handleLogin` stores the flag and the join code reads it twice more; what those reads do (a warning screen, chat signing) was not traced.
12. **New-player portal cooldown.** A player with no stored `PortalCooldown` sends 0 (inferred; the NBT read of the field was not traced).
