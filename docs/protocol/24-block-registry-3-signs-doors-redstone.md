# Block registry, part 3: wall signs to huge mushroom blocks

| Item | Value |
|---|---|
| Covers | Part 3 of 8 of the block registry (design map GAP-1, columns of GAP-29 and GAP-30, round RS4): `Blocks` fields 210 to 314, `spruce_wall_sign` to `red_mushroom_block`, plus the four boundary blocks that the round text names (`ladder`, `rail`, `cobblestone_stairs`, `oak_wall_sign`, fields 206 to 209). For each block: registry key, block id, state properties and their value order, state count, first state id, default state, hardness, resistance, map colour, sound type, note block instrument, light, flags, collision and outline shapes, survival and placement rule, and the behaviour that the class contributes. Data rows (models, loot, tags, recipes) are not listed. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for bootstrap arguments) and of the data files of the same jar (block tags, loot table files, blockstate and model JSON) with no execution. The `Blocks` static initialiser was read in order; each block class was read for `createBlockStateDefinition`, the constructor's default state, shape constants, `canSurvive`, placement, `updateShape` and tick methods. Values that were not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Written for round RS4, part 3 |

Class names in backticks say where a fact was read. They are not the design. "04 §5.2" means section 5.2 of
`04-registry-sync.md`. Sibling documents (parts 1, 2 and 4 to 8 of the block registry) may restate shared rules; where
they differ from this text, the sibling that owns the rule wins and the difference is an Open question.

## Contents

1. Conventions and how ids are computed
2. The block table, fields 206 to 314
3. Properties table (3.1 glass colours, 3.2 facts the flags do not show, 3.3 columns derived by rule, items, loot, tags)
4. State properties used in this range
5. Shape conventions and the shapes of this range (5.3 fences)
6. Block set types (doors, trapdoors, buttons, pressure plates)
7. Classes: states, defaults, survival, placement and behaviour
8. Worked examples
9. Validation
10. Open questions

## 1. Conventions and how ids are computed

1. **Field index** is the 0-based position among the block entries of the `Blocks` initialiser (`air` is 0). Fields 210
   to 314 are the scope. A field is one registered block, except `STAINED_GLASS`, which registers 16 blocks.
2. **Block id** is the registration index in `BuiltInRegistries.BLOCK` (04 §5.1). `Blocks.register` is the only
   registering helper; a collection (`ColorCollection.registerBlocks`) registers its 16 members in the order white,
   orange, magenta, light blue, yellow, lime, pink, gray, light gray, cyan, purple, blue, brown, green, red, black
   (the field order of `ColorCollection.zipMap`). Collections before this range (`BED`, `WOOL`, `WOOL_STAIRS`,
   `WOOL_SLAB`) register 16 blocks each, so **block id = field index + 60 for fields up to 288** (`spruce_wall_sign`, field 210, is block 270), the glass field 289 registers blocks 349 to 364, and
   **block id = field index + 75 from field 290** (`oak_trapdoor`, field 290, is block 365). The block ids of the four boundary blocks are 266 to 269.
3. **State ids** follow 04 §5.2: properties sorted by name, first name slowest; boolean values `true` then `false`;
   integer values ascending; enum values in the property's list order. The **first state id** column of section 2 was
   computed in this round by summing the state counts of every block before it (property lists read from each class's
   `createBlockStateDefinition`, walking superclasses). The base for `spruce_wall_sign` is **7423** (an earlier draft of this part left out the 9 leaf blocks of 28 states each, 252 states, and gave 7171; corrected, see Open question 1). It equals 575 (24 part 2 section 1.2, `B105`) plus 6 848 (the 6 848 states of part 2's range, which ends just before `spruce_wall_sign`), as 24 part 2 states. State ids in this document are absolute (they do not depend on a base of another part).
4. **Key** is `minecraft:<name>`; the table gives `<name>`. Wall variants (`*_wall_sign`, `redstone_wall_torch`, ...)
   are separate blocks with no item of their own; `Blocks.wallVariant` gives them the loot table of the standing
   block and, when its flag is true, the same description id (the flag is true for every wall variant in this range).
5. **Hardness / resistance** are `destroyTime` and `explosionResistance`. `strength(f)` sets both to `f`;
   `strength(a, b)` sets hardness `a`, resistance `b`; `instabreak()` is `strength(0)`.
6. **Properties defaults** (`BlockBehaviour$Properties` constructor): map colour `NONE`, collision on, sound `STONE`,
   light 0, friction 0.6, speed factor 1.0, jump factor 1.0, can occlude true, push reaction `PUSH_PULL`, instrument
   `HARP`, not replaceable, not random-ticking, no forced solidity. **These defaults are overridden by the block classes' constructors**: `WallSignBlock`, `CeilingHangingSignBlock`, `WallHangingSignBlock`, `DoorBlock`, `TrapDoorBlock`, `ButtonBlock` and `BasePressurePlateBlock` call `Properties.sound(...)` with the sound type of their `WoodType` or `BlockSetType`, so the `Blocks` entry of those blocks shows no sound (section 6; the Sound column of section 3 shows the effective value). `InfestedBlock` sets destroy time and resistance in its constructor (section 7.13). Default predicates: valid spawn = top face sturdy
   and own light emission below 14; redstone conductor = collision shape is a full block; suffocating = block is in
   the `causes_suffocation` tag and its collision shape is a full block; view blocking = the suffocating predicate;
   no post-process; no emissive rendering.
7. **Builder meanings used here.** `noCollision()` = no collision and cannot occlude; `noOcclusion()` = cannot occlude
   only; `forceSolidOn()` / `forceSolidOff()` override the solidity test; `ofLegacyCopy(b)` copies hardness,
   resistance, collision, random ticking, light function, map colour function, sound, friction, speed factor,
   bounce, dynamic shape, can occlude, air, lava ignition, liquid, forced solidity, push reaction, correct-tool flag,
   offset, particle flag, features, emissive predicate, instrument and replaceable from block `b`.
8. **`isSolid()`** (used by sign, cake and cactus rules) is computed per state: forced on, then forced off, then false
   if the collision shape is empty, then true if the collision shape's bounding box mean edge length (`AABB.getSize`)
   is at least 0.7291666666666666, then true if its height is at least 1, else false. `AABB.getSize` was read: it is the sum of the x, y and z extents divided by 3.0.
9. **Flag legend** for section 3: `noCollision`, `noOcclusion`, `solidOn`/`solidOff` (forced solidity),
   `replaceable`, `randomTick`, `lavaBurn` (`ignitedByLava`, a fire-spread input, owned by the fire round),
   `needsTool` (`requiresCorrectToolForDrops`), `push=` push reaction, `speed=`, `friction=`, `rsCond`, `suff`,
   `spawn` (valid-spawn predicate: `always`, `never`, or only polar bear), `postProcess`, `viewBlock`.
   Light `lit?N:0` means N when `lit` is true. Map colour names are `MapColor` constants (data of `MapColor`, owned
   by the colour round); `x_planks`-style references in the artifact were resolved to the colour of that block's
   default state (planks: its colour; logs: the top colour, since the default axis is Y).


## 2. The block table, fields 206 to 314

"Offset from base" is the first state id minus 7423 (the first state of `spruce_wall_sign`); negative values are the
four boundary blocks. The glass row is 16 blocks of one state each: block id 349 + c and state id 8768 + c, with c the
colour index in the order of section 1, item 2 (white 0 ... black 15). Keys are `<color>_stained_glass`
(`white_stained_glass`, `light_blue_stained_glass`, `light_gray_stained_glass`, ...).

Constructor arguments: `WoodType` names the sign wood; `BlockSetType` names the set type of section 6; a button also
has its press duration in ticks; infested blocks name their host block.

| Field | Key | Block id | Class | Ctor argument | States | First state id | Offset from base |
|---|---|---|---|---|---|---|---|
| 206 | `ladder` | 266 | LadderBlock | - | 8 | 7307 | -116 |
| 207 | `rail` | 267 | RailBlock | - | 20 | 7315 | -108 |
| 208 | `cobblestone_stairs` | 268 | StairBlock | - | 80 | 7335 | -88 |
| 209 | `oak_wall_sign` | 269 | WallSignBlock | OAK | 8 | 7415 | -8 |
| 210 | `spruce_wall_sign` | 270 | WallSignBlock | SPRUCE | 8 | 7423 | 0 |
| 211 | `birch_wall_sign` | 271 | WallSignBlock | BIRCH | 8 | 7431 | 8 |
| 212 | `acacia_wall_sign` | 272 | WallSignBlock | ACACIA | 8 | 7439 | 16 |
| 213 | `cherry_wall_sign` | 273 | WallSignBlock | CHERRY | 8 | 7447 | 24 |
| 214 | `jungle_wall_sign` | 274 | WallSignBlock | JUNGLE | 8 | 7455 | 32 |
| 215 | `dark_oak_wall_sign` | 275 | WallSignBlock | DARK_OAK | 8 | 7463 | 40 |
| 216 | `pale_oak_wall_sign` | 276 | WallSignBlock | PALE_OAK | 8 | 7471 | 48 |
| 217 | `mangrove_wall_sign` | 277 | WallSignBlock | MANGROVE | 8 | 7479 | 56 |
| 218 | `poplar_wall_sign` | 278 | WallSignBlock | POPLAR | 8 | 7487 | 64 |
| 219 | `bamboo_wall_sign` | 279 | WallSignBlock | BAMBOO | 8 | 7495 | 72 |
| 220 | `oak_hanging_sign` | 280 | CeilingHangingSignBlock | OAK | 64 | 7503 | 80 |
| 221 | `spruce_hanging_sign` | 281 | CeilingHangingSignBlock | SPRUCE | 64 | 7567 | 144 |
| 222 | `birch_hanging_sign` | 282 | CeilingHangingSignBlock | BIRCH | 64 | 7631 | 208 |
| 223 | `acacia_hanging_sign` | 283 | CeilingHangingSignBlock | ACACIA | 64 | 7695 | 272 |
| 224 | `cherry_hanging_sign` | 284 | CeilingHangingSignBlock | CHERRY | 64 | 7759 | 336 |
| 225 | `jungle_hanging_sign` | 285 | CeilingHangingSignBlock | JUNGLE | 64 | 7823 | 400 |
| 226 | `dark_oak_hanging_sign` | 286 | CeilingHangingSignBlock | DARK_OAK | 64 | 7887 | 464 |
| 227 | `pale_oak_hanging_sign` | 287 | CeilingHangingSignBlock | PALE_OAK | 64 | 7951 | 528 |
| 228 | `crimson_hanging_sign` | 288 | CeilingHangingSignBlock | CRIMSON | 64 | 8015 | 592 |
| 229 | `warped_hanging_sign` | 289 | CeilingHangingSignBlock | WARPED | 64 | 8079 | 656 |
| 230 | `mangrove_hanging_sign` | 290 | CeilingHangingSignBlock | MANGROVE | 64 | 8143 | 720 |
| 231 | `poplar_hanging_sign` | 291 | CeilingHangingSignBlock | POPLAR | 64 | 8207 | 784 |
| 232 | `bamboo_hanging_sign` | 292 | CeilingHangingSignBlock | BAMBOO | 64 | 8271 | 848 |
| 233 | `oak_wall_hanging_sign` | 293 | WallHangingSignBlock | OAK | 8 | 8335 | 912 |
| 234 | `spruce_wall_hanging_sign` | 294 | WallHangingSignBlock | SPRUCE | 8 | 8343 | 920 |
| 235 | `birch_wall_hanging_sign` | 295 | WallHangingSignBlock | BIRCH | 8 | 8351 | 928 |
| 236 | `acacia_wall_hanging_sign` | 296 | WallHangingSignBlock | ACACIA | 8 | 8359 | 936 |
| 237 | `cherry_wall_hanging_sign` | 297 | WallHangingSignBlock | CHERRY | 8 | 8367 | 944 |
| 238 | `jungle_wall_hanging_sign` | 298 | WallHangingSignBlock | JUNGLE | 8 | 8375 | 952 |
| 239 | `dark_oak_wall_hanging_sign` | 299 | WallHangingSignBlock | DARK_OAK | 8 | 8383 | 960 |
| 240 | `pale_oak_wall_hanging_sign` | 300 | WallHangingSignBlock | PALE_OAK | 8 | 8391 | 968 |
| 241 | `mangrove_wall_hanging_sign` | 301 | WallHangingSignBlock | MANGROVE | 8 | 8399 | 976 |
| 242 | `poplar_wall_hanging_sign` | 302 | WallHangingSignBlock | POPLAR | 8 | 8407 | 984 |
| 243 | `crimson_wall_hanging_sign` | 303 | WallHangingSignBlock | CRIMSON | 8 | 8415 | 992 |
| 244 | `warped_wall_hanging_sign` | 304 | WallHangingSignBlock | WARPED | 8 | 8423 | 1000 |
| 245 | `bamboo_wall_hanging_sign` | 305 | WallHangingSignBlock | BAMBOO | 8 | 8431 | 1008 |
| 246 | `lever` | 306 | LeverBlock | - | 24 | 8439 | 1016 |
| 247 | `stone_pressure_plate` | 307 | PressurePlateBlock | STONE | 2 | 8463 | 1040 |
| 248 | `iron_door` | 308 | DoorBlock | IRON | 64 | 8465 | 1042 |
| 249 | `oak_pressure_plate` | 309 | PressurePlateBlock | OAK | 2 | 8529 | 1106 |
| 250 | `spruce_pressure_plate` | 310 | PressurePlateBlock | SPRUCE | 2 | 8531 | 1108 |
| 251 | `birch_pressure_plate` | 311 | PressurePlateBlock | BIRCH | 2 | 8533 | 1110 |
| 252 | `jungle_pressure_plate` | 312 | PressurePlateBlock | JUNGLE | 2 | 8535 | 1112 |
| 253 | `acacia_pressure_plate` | 313 | PressurePlateBlock | ACACIA | 2 | 8537 | 1114 |
| 254 | `cherry_pressure_plate` | 314 | PressurePlateBlock | CHERRY | 2 | 8539 | 1116 |
| 255 | `dark_oak_pressure_plate` | 315 | PressurePlateBlock | DARK_OAK | 2 | 8541 | 1118 |
| 256 | `pale_oak_pressure_plate` | 316 | PressurePlateBlock | PALE_OAK | 2 | 8543 | 1120 |
| 257 | `mangrove_pressure_plate` | 317 | PressurePlateBlock | MANGROVE | 2 | 8545 | 1122 |
| 258 | `poplar_pressure_plate` | 318 | PressurePlateBlock | POPLAR | 2 | 8547 | 1124 |
| 259 | `bamboo_pressure_plate` | 319 | PressurePlateBlock | BAMBOO | 2 | 8549 | 1126 |
| 260 | `redstone_ore` | 320 | RedStoneOreBlock | - | 2 | 8551 | 1128 |
| 261 | `deepslate_redstone_ore` | 321 | RedStoneOreBlock | - | 2 | 8553 | 1130 |
| 262 | `redstone_torch` | 322 | RedstoneTorchBlock | - | 2 | 8555 | 1132 |
| 263 | `redstone_wall_torch` | 323 | RedstoneWallTorchBlock | - | 8 | 8557 | 1134 |
| 264 | `stone_button` | 324 | ButtonBlock | STONE, 20 ticks | 24 | 8565 | 1142 |
| 265 | `snow` | 325 | SnowLayerBlock | - | 8 | 8589 | 1166 |
| 266 | `ice` | 326 | IceBlock | - | 1 | 8597 | 1174 |
| 267 | `snow_block` | 327 | Block | - | 1 | 8598 | 1175 |
| 268 | `cactus` | 328 | CactusBlock | - | 16 | 8599 | 1176 |
| 269 | `cactus_flower` | 329 | CactusFlowerBlock | - | 1 | 8615 | 1192 |
| 270 | `clay` | 330 | Block | - | 1 | 8616 | 1193 |
| 271 | `sugar_cane` | 331 | SugarCaneBlock | - | 16 | 8617 | 1194 |
| 272 | `jukebox` | 332 | JukeboxBlock | - | 2 | 8633 | 1210 |
| 273 | `oak_fence` | 333 | FenceBlock | - | 32 | 8635 | 1212 |
| 274 | `netherrack` | 334 | NetherrackBlock | - | 1 | 8667 | 1244 |
| 275 | `soul_sand` | 335 | SoulSandBlock | - | 1 | 8668 | 1245 |
| 276 | `soul_soil` | 336 | Block | - | 1 | 8669 | 1246 |
| 277 | `basalt` | 337 | RotatedPillarBlock | - | 3 | 8670 | 1247 |
| 278 | `polished_basalt` | 338 | RotatedPillarBlock | - | 3 | 8673 | 1250 |
| 279 | `soul_torch` | 339 | TorchBlock | SOUL_FIRE_FLAME | 1 | 8676 | 1253 |
| 280 | `soul_wall_torch` | 340 | WallTorchBlock | SOUL_FIRE_FLAME | 4 | 8677 | 1254 |
| 281 | `copper_torch` | 341 | TorchBlock | COPPER_FIRE_FLAME | 1 | 8681 | 1258 |
| 282 | `copper_wall_torch` | 342 | WallTorchBlock | COPPER_FIRE_FLAME | 4 | 8682 | 1259 |
| 283 | `glowstone` | 343 | Block | - | 1 | 8686 | 1263 |
| 284 | `nether_portal` | 344 | NetherPortalBlock | - | 2 | 8687 | 1264 |
| 285 | `carved_pumpkin` | 345 | CarvedPumpkinBlock | - | 4 | 8689 | 1266 |
| 286 | `jack_o_lantern` | 346 | CarvedPumpkinBlock | - | 4 | 8693 | 1270 |
| 287 | `cake` | 347 | CakeBlock | - | 7 | 8697 | 1274 |
| 288 | `repeater` | 348 | RepeaterBlock | - | 64 | 8704 | 1281 |
| 289 | `x_stained_glass (16)` | 349 to 364 | StainedGlassBlock | - | 1 | 8768 + 1 per color | 1345 |
| 290 | `oak_trapdoor` | 365 | TrapDoorBlock | OAK | 64 | 8784 | 1361 |
| 291 | `spruce_trapdoor` | 366 | TrapDoorBlock | SPRUCE | 64 | 8848 | 1425 |
| 292 | `birch_trapdoor` | 367 | TrapDoorBlock | BIRCH | 64 | 8912 | 1489 |
| 293 | `jungle_trapdoor` | 368 | TrapDoorBlock | JUNGLE | 64 | 8976 | 1553 |
| 294 | `acacia_trapdoor` | 369 | TrapDoorBlock | ACACIA | 64 | 9040 | 1617 |
| 295 | `cherry_trapdoor` | 370 | TrapDoorBlock | CHERRY | 64 | 9104 | 1681 |
| 296 | `dark_oak_trapdoor` | 371 | TrapDoorBlock | DARK_OAK | 64 | 9168 | 1745 |
| 297 | `pale_oak_trapdoor` | 372 | TrapDoorBlock | PALE_OAK | 64 | 9232 | 1809 |
| 298 | `mangrove_trapdoor` | 373 | TrapDoorBlock | MANGROVE | 64 | 9296 | 1873 |
| 299 | `poplar_trapdoor` | 374 | TrapDoorBlock | POPLAR | 64 | 9360 | 1937 |
| 300 | `bamboo_trapdoor` | 375 | TrapDoorBlock | BAMBOO | 64 | 9424 | 2001 |
| 301 | `stone_bricks` | 376 | Block | - | 1 | 9488 | 2065 |
| 302 | `mossy_stone_bricks` | 377 | Block | - | 1 | 9489 | 2066 |
| 303 | `cracked_stone_bricks` | 378 | Block | - | 1 | 9490 | 2067 |
| 304 | `chiseled_stone_bricks` | 379 | Block | - | 1 | 9491 | 2068 |
| 305 | `packed_mud` | 380 | Block | - | 1 | 9492 | 2069 |
| 306 | `mud_bricks` | 381 | Block | - | 1 | 9493 | 2070 |
| 307 | `infested_stone` | 382 | InfestedBlock | host stone | 1 | 9494 | 2071 |
| 308 | `infested_cobblestone` | 383 | InfestedBlock | host cobblestone | 1 | 9495 | 2072 |
| 309 | `infested_stone_bricks` | 384 | InfestedBlock | host stone_bricks | 1 | 9496 | 2073 |
| 310 | `infested_mossy_stone_bricks` | 385 | InfestedBlock | host mossy_stone_bricks | 1 | 9497 | 2074 |
| 311 | `infested_cracked_stone_bricks` | 386 | InfestedBlock | host cracked_stone_bricks | 1 | 9498 | 2075 |
| 312 | `infested_chiseled_stone_bricks` | 387 | InfestedBlock | host chiseled_stone_bricks | 1 | 9499 | 2076 |
| 313 | `brown_mushroom_block` | 388 | HugeMushroomBlock | - | 64 | 9500 | 2077 |
| 314 | `red_mushroom_block` | 389 | HugeMushroomBlock | - | 64 | 9564 | 2141 |

## 3. Properties table

One row per block field. Hardness and resistance are in game units. "Map colour" for the glass row is the dye
colour's map colour (section 3.1). Rows whose Flags column is `-` set none of the listed flags. Copied blocks:
`deepslate_redstone_ore` is `ofLegacyCopy(redstone_ore)` with map colour `DEEPSLATE`, hardness 4.5, resistance 3.0 and
sound `DEEPSLATE`, so it keeps `randomTick`, `needsTool`, instrument `basedrum` and the lit light function (9 when lit);
`packed_mud` is `ofLegacyCopy(dirt)` with hardness 1.0, resistance 3.0 and sound `PACKED_MUD` (its remaining properties come from `dirt`: map colour `DIRT` (read in the `dirt` entry), no instrument call so `harp`, no correct-tool flag; `dirt` itself belongs to part 1). The `redstone_ore` row shows its own flags;
`needsTool` and `randomTick` apply to both ores.

**Sound rule.** The Sound column is the effective sound type. Rows 209 to 245 (signs and hanging signs), 247 to 259 (pressure plates), 248 (iron door), 264 (button) and 290 to 300 (trapdoors) take it from the class constructor, not from the `Blocks` entry: wall signs from `WoodType.soundType`, ceiling and wall hanging signs from `WoodType.hangingSignSoundType`, doors, trapdoors, buttons and pressure plates from `BlockSetType.soundType` (tables in section 6). The wood and set types without an explicit sound constant (oak, spruce, birch, acacia, jungle, dark oak, pale oak, poplar, mangrove) use `WOOD` for signs, doors, trapdoors, buttons and plates and `HANGING_SIGN` for hanging signs. `iron_door` is `IRON`, not `STONE`. Row 208 (`cobblestone_stairs`) is `ofLegacyCopy(cobblestone)`; rows 307 to 312: hardness is the host block's default destroy time divided by 2 (stone 1.5, cobblestone 2.0, the four stone brick hosts 1.5), resistance 0.75 (section 7.13).

| Field | Key | Map color | Instrument | Hardness | Resistance | Light | Sound (effective) | Flags |
|---|---|---|---|---|---|---|---|---|
| 206 | `ladder` | - | harp | 0.4 | 0.4 | 0 | LADDER | noOcclusion, solidOff, push=POPPED |
| 207 | `rail` | - | harp | 0.7 | 0.7 | 0 | METAL | noCollision |
| 208 | `cobblestone_stairs` | STONE | basedrum | 2.0 | 6.0 | 0 | STONE | needsTool, viewBlock=occlusion-box test (`legacyCopy:cobblestone`) |
| 209 | `oak_wall_sign` | WOOD | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 210 | `spruce_wall_sign` | PODZOL | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 211 | `birch_wall_sign` | SAND | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 212 | `acacia_wall_sign` | COLOR_ORANGE | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 213 | `cherry_wall_sign` | TERRACOTTA_WHITE | bass | 1 | 1 | 0 | CHERRY_WOOD | noCollision, solidOn, lavaBurn |
| 214 | `jungle_wall_sign` | DIRT | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 215 | `dark_oak_wall_sign` | COLOR_BROWN | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 216 | `pale_oak_wall_sign` | QUARTZ | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 217 | `mangrove_wall_sign` | COLOR_RED | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 218 | `poplar_wall_sign` | COLOR_LIGHT_GRAY | bass | 1 | 1 | 0 | WOOD | noCollision, solidOn, lavaBurn |
| 219 | `bamboo_wall_sign` | COLOR_YELLOW | bass | 1 | 1 | 0 | BAMBOO_WOOD | noCollision, solidOn, lavaBurn |
| 220 | `oak_hanging_sign` | WOOD | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 221 | `spruce_hanging_sign` | PODZOL | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 222 | `birch_hanging_sign` | SAND | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 223 | `acacia_hanging_sign` | COLOR_ORANGE | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 224 | `cherry_hanging_sign` | TERRACOTTA_PINK | bass | 1 | 1 | 0 | CHERRY_WOOD_HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 225 | `jungle_hanging_sign` | DIRT | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 226 | `dark_oak_hanging_sign` | COLOR_BROWN | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 227 | `pale_oak_hanging_sign` | QUARTZ | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 228 | `crimson_hanging_sign` | CRIMSON_STEM | bass | 1 | 1 | 0 | NETHER_WOOD_HANGING_SIGN | noCollision, solidOn |
| 229 | `warped_hanging_sign` | WARPED_STEM | bass | 1 | 1 | 0 | NETHER_WOOD_HANGING_SIGN | noCollision, solidOn |
| 230 | `mangrove_hanging_sign` | COLOR_RED | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 231 | `poplar_hanging_sign` | COLOR_LIGHT_GRAY | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 232 | `bamboo_hanging_sign` | COLOR_YELLOW | bass | 1 | 1 | 0 | BAMBOO_WOOD_HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 233 | `oak_wall_hanging_sign` | WOOD | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 234 | `spruce_wall_hanging_sign` | WOOD | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 235 | `birch_wall_hanging_sign` | SAND | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 236 | `acacia_wall_hanging_sign` | COLOR_ORANGE | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 237 | `cherry_wall_hanging_sign` | TERRACOTTA_PINK | bass | 1 | 1 | 0 | CHERRY_WOOD_HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 238 | `jungle_wall_hanging_sign` | DIRT | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 239 | `dark_oak_wall_hanging_sign` | COLOR_BROWN | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 240 | `pale_oak_wall_hanging_sign` | QUARTZ | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 241 | `mangrove_wall_hanging_sign` | COLOR_RED | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 242 | `poplar_wall_hanging_sign` | COLOR_LIGHT_GRAY | bass | 1 | 1 | 0 | HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 243 | `crimson_wall_hanging_sign` | CRIMSON_STEM | bass | 1 | 1 | 0 | NETHER_WOOD_HANGING_SIGN | noCollision, solidOn |
| 244 | `warped_wall_hanging_sign` | WARPED_STEM | bass | 1 | 1 | 0 | NETHER_WOOD_HANGING_SIGN | noCollision, solidOn |
| 245 | `bamboo_wall_hanging_sign` | COLOR_YELLOW | bass | 1 | 1 | 0 | BAMBOO_WOOD_HANGING_SIGN | noCollision, solidOn, lavaBurn |
| 246 | `lever` | - | harp | 0.5 | 0.5 | 0 | STONE | noCollision, push=POPPED |
| 247 | `stone_pressure_plate` | STONE | basedrum | 0.5 | 0.5 | 0 | STONE | noCollision, solidOn, push=POPPED |
| 248 | `iron_door` | METAL | harp | 5.0 | 5.0 | 0 | IRON | noOcclusion, push=POPPED |
| 249 | `oak_pressure_plate` | WOOD | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 250 | `spruce_pressure_plate` | PODZOL | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 251 | `birch_pressure_plate` | SAND | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 252 | `jungle_pressure_plate` | DIRT | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 253 | `acacia_pressure_plate` | COLOR_ORANGE | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 254 | `cherry_pressure_plate` | TERRACOTTA_WHITE | bass | 0.5 | 0.5 | 0 | CHERRY_WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 255 | `dark_oak_pressure_plate` | COLOR_BROWN | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 256 | `pale_oak_pressure_plate` | QUARTZ | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 257 | `mangrove_pressure_plate` | COLOR_RED | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 258 | `poplar_pressure_plate` | COLOR_LIGHT_GRAY | bass | 0.5 | 0.5 | 0 | WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 259 | `bamboo_pressure_plate` | COLOR_YELLOW | bass | 0.5 | 0.5 | 0 | BAMBOO_WOOD | noCollision, solidOn, lavaBurn, push=POPPED |
| 260 | `redstone_ore` | STONE | basedrum | 3.0 | 3.0 | lit?9:0 | STONE | randomTick, needsTool |
| 261 | `deepslate_redstone_ore` | DEEPSLATE | basedrum | 4.5 | 3.0 | lit?9:0 | DEEPSLATE | randomTick, needsTool |
| 262 | `redstone_torch` | - | harp | 0 | 0 | lit?7:0 | WOOD | noCollision, push=POPPED |
| 263 | `redstone_wall_torch` | - | harp | 0 | 0 | lit?7:0 | WOOD | noCollision, push=POPPED |
| 264 | `stone_button` | - | harp | 0.5 | 0.5 | 0 | STONE | noCollision, push=POPPED |
| 265 | `snow` | SNOW | harp | 0.1 | 0.1 | 0 | SNOW | solidOff, replaceable, randomTick, needsTool, push=POPPED, viewBlock=layers>=8 |
| 266 | `ice` | ICE | harp | 0.5 | 0.5 | 0 | GLASS | noOcclusion, randomTick, friction=0.98, rsCond=never, spawn=polar bear only |
| 267 | `snow_block` | SNOW | harp | 0.2 | 0.2 | 0 | SNOW | needsTool |
| 268 | `cactus` | PLANT | harp | 0.4 | 0.4 | 0 | WOOL | randomTick, push=POPPED |
| 269 | `cactus_flower` | COLOR_PINK | harp | 0 | 0 | 0 | CACTUS_FLOWER | noCollision, lavaBurn, push=POPPED |
| 270 | `clay` | CLAY | flute | 0.6 | 0.6 | 0 | GRAVEL | - |
| 271 | `sugar_cane` | PLANT | harp | 0 | 0 | 0 | GRASS | noCollision, randomTick, push=POPPED |
| 272 | `jukebox` | DIRT | bass | 2 | 6.0 | 0 | WOOD | lavaBurn |
| 273 | `oak_fence` | WOOD | bass | 2 | 3.0 | 0 | WOOD | solidOn, lavaBurn |
| 274 | `netherrack` | NETHER | basedrum | 0.4 | 0.4 | 0 | NETHERRACK | needsTool |
| 275 | `soul_sand` | COLOR_BROWN | cow_bell | 0.5 | 0.5 | 0 | SOUL_SAND | speed=0.4, rsCond=always, suff=always, spawn=always, postProcess |
| 276 | `soul_soil` | COLOR_BROWN | harp | 0.5 | 0.5 | 0 | SOUL_SOIL | - |
| 277 | `basalt` | COLOR_BLACK | basedrum | 1.25 | 4.2 | 0 | BASALT | needsTool |
| 278 | `polished_basalt` | COLOR_BLACK | basedrum | 1.25 | 4.2 | 0 | BASALT | needsTool |
| 279 | `soul_torch` | - | harp | 0 | 0 | 10 | WOOD | noCollision, push=POPPED |
| 280 | `soul_wall_torch` | - | harp | 0 | 0 | 10 | WOOD | noCollision, push=POPPED |
| 281 | `copper_torch` | - | harp | 0 | 0 | 14 | WOOD | noCollision, push=POPPED |
| 282 | `copper_wall_torch` | - | harp | 0 | 0 | 14 | WOOD | noCollision, push=POPPED |
| 283 | `glowstone` | SAND | pling | 0.3 | 0.3 | 15 | GLASS | rsCond=never |
| 284 | `nether_portal` | - | harp | -1.0 | -1.0 | 11 | GLASS | noCollision, randomTick, push=IMMOVEABLE |
| 285 | `carved_pumpkin` | COLOR_ORANGE | harp | 1 | 1 | 0 | WOOD | push=POPPED, spawn=always |
| 286 | `jack_o_lantern` | COLOR_ORANGE | harp | 1 | 1 | 15 | WOOD | push=POPPED, spawn=always |
| 287 | `cake` | - | harp | 0.5 | 0.5 | 0 | WOOL | solidOn, push=POPPED |
| 288 | `repeater` | - | harp | 0 | 0 | 0 | STONE | push=POPPED |
| 289 | `<colour>_stained_glass` (16 keys: `white_stained_glass` ... `black_stained_glass`) | dye colour map colour (3.1) | hat | 0.3 | 0.3 | 0 | GLASS | noOcclusion, rsCond=never, suff=never, spawn=never |
| 290 | `oak_trapdoor` | WOOD | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 291 | `spruce_trapdoor` | PODZOL | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 292 | `birch_trapdoor` | SAND | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 293 | `jungle_trapdoor` | DIRT | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 294 | `acacia_trapdoor` | COLOR_ORANGE | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 295 | `cherry_trapdoor` | TERRACOTTA_WHITE | bass | 3.0 | 3.0 | 0 | CHERRY_WOOD | noOcclusion, lavaBurn, spawn=never |
| 296 | `dark_oak_trapdoor` | COLOR_BROWN | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 297 | `pale_oak_trapdoor` | QUARTZ | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 298 | `mangrove_trapdoor` | COLOR_RED | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 299 | `poplar_trapdoor` | COLOR_LIGHT_GRAY | bass | 3.0 | 3.0 | 0 | WOOD | noOcclusion, lavaBurn, spawn=never |
| 300 | `bamboo_trapdoor` | COLOR_YELLOW | bass | 3.0 | 3.0 | 0 | BAMBOO_WOOD | noOcclusion, lavaBurn, spawn=never |
| 301 | `stone_bricks` | STONE | basedrum | 1.5 | 6.0 | 0 | STONE | needsTool |
| 302 | `mossy_stone_bricks` | STONE | basedrum | 1.5 | 6.0 | 0 | STONE | needsTool |
| 303 | `cracked_stone_bricks` | STONE | basedrum | 1.5 | 6.0 | 0 | STONE | needsTool |
| 304 | `chiseled_stone_bricks` | STONE | basedrum | 1.5 | 6.0 | 0 | STONE | needsTool |
| 305 | `packed_mud` | DIRT | harp | 1 | 3.0 | 0 | PACKED_MUD | - |
| 306 | `mud_bricks` | TERRACOTTA_LIGHT_GRAY | basedrum | 1.5 | 3.0 | 0 | MUD_BRICKS | needsTool |
| 307 | `infested_stone` | CLAY | harp | 0.75 | 0.75 | 0 | STONE | - |
| 308 | `infested_cobblestone` | CLAY | harp | 1.0 | 0.75 | 0 | STONE | - |
| 309 | `infested_stone_bricks` | CLAY | harp | 0.75 | 0.75 | 0 | STONE | - |
| 310 | `infested_mossy_stone_bricks` | CLAY | harp | 0.75 | 0.75 | 0 | STONE | - |
| 311 | `infested_cracked_stone_bricks` | CLAY | harp | 0.75 | 0.75 | 0 | STONE | - |
| 312 | `infested_chiseled_stone_bricks` | CLAY | harp | 0.75 | 0.75 | 0 | STONE | - |
| 313 | `brown_mushroom_block` | DIRT | bass | 0.2 | 0.2 | 0 | WOOD | lavaBurn |
| 314 | `red_mushroom_block` | COLOR_RED | bass | 0.2 | 0.2 | 0 | WOOD | lavaBurn |

### 3.1 Stained glass map colours

Each member sets map colour = the dye colour's map colour (`DyeColor.getMapColor`, the first of its two map colours),
instrument `hat`, hardness and resistance 0.3, sound `GLASS`, `noOcclusion`, and the three predicates (valid spawn,
redstone conductor, suffocating) all `never`. Colour table: white `SNOW`, orange `COLOR_ORANGE`, magenta
`COLOR_MAGENTA`, light blue `COLOR_LIGHT_BLUE`, yellow `COLOR_YELLOW`, lime `COLOR_LIGHT_GREEN`, pink `COLOR_PINK`, gray
`COLOR_GRAY`, light gray `COLOR_LIGHT_GRAY`, cyan `COLOR_CYAN`, purple `COLOR_PURPLE`, blue `COLOR_BLUE`, brown
`COLOR_BROWN`, green `COLOR_GREEN`, red `COLOR_RED`, black `COLOR_BLACK`.

### 3.2 Facts that the flags do not show

- `snow`: random-ticking; `isViewBlocking` is true only when layers is 8 (the predicate tests layers >= 8).
- `ice` valid-spawn predicate is true only for the polar bear entity type; `soul_sand`, `carved_pumpkin` and
  `jack_o_lantern` spawn predicates are always true; glass is never.
- `nether_portal` hardness is -1 (unbreakable), push reaction `IMMOVEABLE`, sound `GLASS`, light 11, random-ticking.
- `soul_sand` has post-process `postProcessAbove` (the position above the block is re-processed after placement).
- Light is a constant for every state except `redstone_ore`, `deepslate_redstone_ore` (9 when `lit`), `redstone_torch`
  and `redstone_wall_torch` (7 when `lit`); the constant-light blocks are `soul_torch`/`soul_wall_torch` 10,
  `copper_torch`/`copper_wall_torch` 14, `glowstone` 15, `nether_portal` 11, `jack_o_lantern` 15.

### 3.3 Columns derived by rule, associated item, loot key and tags

The columns below are not repeated per row; each follows from a rule, and the rule's owner is cited. Column schema, defaults and the
derivation of the per-state values: 24 part 1 sections 5.2, 7 and 9.

**Associated item.** `BlockItemIds` constants name block and item together: for every block of this range except the 27 wall variants and `nether_portal`, the item key
equals the block key (24 part 1 section 11). Wall variants (`*_wall_sign`, `*_wall_hanging_sign`, `redstone_wall_torch`, `soul_wall_torch`,
`copper_wall_torch`) and `nether_portal` are registered with `BlockIds` and have no item. The glass collection registers `<colour>_stained_glass` items.

**Loot table key.** `blocks/<block key>` (24 part 1 section 4.1). Wall variants take the table of the standing block through `wallVariant`
(`oak_wall_sign` uses `blocks/oak_sign`, `redstone_wall_torch` uses `blocks/redstone_torch`, and so on), so none of the 27 wall variants has its own table file.
`deepslate_redstone_ore` and `packed_mud` are `ofLegacyCopy` blocks and use their own keys (the copy does not carry the table). Reading all 97 own table files of the range (124 blocks minus the 27 wall variants): the rows below give, per key, the category and the drop. Every pool of the plain self tables is guarded by `survives_explosion`; silk-touch pools are guarded by the predicate `tool/can_silk_touch` instead and have no explosion guard. The contents of the pools are otherwise data (loot document).

| Category | Keys | Drop |
|---|---|---|
| empty (no pools, no drops) | `nether_portal`, `cake` | none |
| silk touch only | `ice`, the 16 `<colour>_stained_glass`, the six `infested_*` | the block itself with silk touch (`ice`, glass); the infested blocks give their host block (`stone`, `cobblestone`, `stone_bricks`, `mossy_stone_bricks`, `cracked_stone_bricks`, `chiseled_stone_bricks`) with silk touch; otherwise nothing from the table (the silverfish spawns, 7.13) |
| silk touch, else other drop | `redstone_ore`, `deepslate_redstone_ore` | block with silk; else `redstone` count uniform 4 to 5, plus the fortune bonus (uniform bonus, multiplier 1), then explosion decay |
| | `snow_block` | block with silk; else 4 `snowball`, explosion decay |
| | `clay` | block with silk; else 4 `clay_ball`, explosion decay |
| | `glowstone` | block with silk; else `glowstone_dust` uniform 2 to 4, plus fortune bonus (uniform, multiplier 1), limited to 1 to 4, explosion decay |
| | `brown_mushroom_block`, `red_mushroom_block` | block with silk; else the matching mushroom item, count uniform -6 to 2 limited to at least 0, explosion decay |
| | `snow` | pool condition: the breaker entity exists (empty entity predicate). Without silk touch: `snowball` x `layers` (1 to 8). With silk touch: `snow` item x `layers` for 1 to 7 layers, one `snow_block` at 8 layers |
| self, with a state condition | `iron_door` | the `iron_door` item only when the broken state's `half` is `lower` (so one drop per door); pool guarded by `survives_explosion` |
| self (plain) | the remaining 63: `ladder`, `rail`, `cobblestone_stairs`, the 13 `*_hanging_sign` (own tables) and the 11 `*_wall_sign` and 13 `*_wall_hanging_sign` through their standing block, `lever`, `stone_pressure_plate`, the 11 wooden pressure plates, `redstone_torch` / `redstone_wall_torch`, `stone_button`, `cactus`, `cactus_flower`, `sugar_cane`, `jukebox`, `oak_fence`, `netherrack`, `soul_sand`, `soul_soil`, `basalt`, `polished_basalt`, the soul and copper torches (standing and wall), `carved_pumpkin`, `jack_o_lantern`, `repeater`, the 11 trapdoors, the four stone brick blocks, `packed_mud`, `mud_bricks` | the block's own item (wall variants: the standing block's item) |

Counts over the 124 keys: 2 empty; 31 silk-touch category (23 silk touch only: `ice`, 16 glass, 6 infested; 8 with an alternative drop: the two ores, `snow`, `snow_block`, `clay`, `glowstone`, the two mushroom blocks); 91 self (64 with their own table, `iron_door` among them, and 27 wall variants that use the standing block's table). The own-table total is 2 + 31 + 64 = 97.

**`iron_door` and the correct-tool flag.** The `iron_door` entry of `Blocks` is map colour `METAL`, `strength(5.0)`, `noOcclusion`, push `POPPED` and nothing else: it does **not** call `requiresCorrectToolForDrops` in 26.3 (read in the static initialiser), so it drops with any tool or with the bare hand; it is in `mineable/pickaxe` only, which makes the pickaxe mine it faster. Do not add the flag from older versions.

**Correct tool and tier, per block.** `needsTool` rows of section 3 are the only blocks in this range whose drops require a correct tool. A tool is correct for drops when the block is in the tool's `mineable/*` tag and not in the `incorrect_for_<tier>_tool` tag of the tool's tier; the `incorrect_for_*` tags are built from `needs_stone_tool`, `needs_iron_tool` and `needs_diamond_tool` (`incorrect_for_wooden_tool` = all three; the stone, gold and copper tool tags exclude the iron and diamond tiers). Read from the tag files (expanded):

| Blocks | Mining tag | Tier tag | Drops with |
|---|---|---|---|
| `redstone_ore`, `deepslate_redstone_ore` | pickaxe | `needs_iron_tool` (so in `incorrect_for_wooden_tool`, `incorrect_for_stone_tool`, `incorrect_for_gold_tool`, `incorrect_for_copper_tool`) | iron, diamond or netherite pickaxe; silk touch drop per 3.3 |
| `cobblestone_stairs`, `stone_bricks`, `mossy_stone_bricks`, `cracked_stone_bricks`, `chiseled_stone_bricks`, `mud_bricks`, `netherrack`, `basalt`, `polished_basalt` | pickaxe | none | any pickaxe (wooden and up) |
| `snow`, `snow_block` | shovel | none | any shovel |
| every other block of the range | per section 3.3 tag table | none | any tool or none (no `needsTool`; this includes `iron_door` and the infested blocks) |

No block of this range is a member of `needs_stone_tool` or `needs_diamond_tool` (both tag files expanded and compared with the 124 keys: no member), nor of `incorrect_for_iron_tool`, `incorrect_for_diamond_tool` or `incorrect_for_netherite_tool`. Blocks outside every `mineable/*` tag (`lever`, the torches, `cactus`, `cactus_flower`, `sugar_cane`, `glowstone`, `nether_portal`, `cake`, `repeater`, the 16 stained glass blocks) have no tool-speed bonus; no block of the range is in `mineable/hoe`.

**Friction, speed factor and jump factor.** Defaults 0.6, 1.0, 1.0 (section 1, item 6). In this range only `ice` sets friction (0.98) and only `soul_sand` sets the
speed factor (0.4); no block sets the jump factor.

**Light opacity (lightDampening) and occlusion shape.** From 24 part 1 section 5.2: dampening is 15 when the occlusion shape is a full block, else 0 when skylight
propagates (the shape is not a full block and the fluid is empty), else 1; the occlusion shape is empty when the block cannot occlude, else the block's outline (the default
`getOcclusionShape`).

| Blocks | Occlusion shape | Light opacity |
|---|---|---|
| redstone ores, `snow_block`, `clay`, `jukebox`, `netherrack`, `soul_sand`, `soul_soil`, `basalt`, `polished_basalt`, `glowstone`, the four stone brick blocks, `packed_mud`, `mud_bricks`, the six infested blocks, the two mushroom blocks, `carved_pumpkin`, `jack_o_lantern` | full cube (soul sand's full outline, not its 14-high collision) | 15 |
| `ice` | empty (`noOcclusion`) | 1 (a full shape does not propagate skylight) |
| stained glass (16) | empty | 0 (`TransparentBlock.propagatesSkylightDown` is true) |
| `snow` | outline of the layer count (`useShapeForLightOcclusion`) | 15 at 8 layers (a full cube); 0 at 1 to 7 layers (derived by the default rule) |
| `oak_fence` | the occlusion shape of 5.3 | 0 when dry, 1 when waterlogged (`CrossCollisionBlock.propagatesSkylightDown` is false when waterlogged) |
| `cobblestone_stairs`, `cactus`, `cake`, `repeater` | the outline (they can occlude) | 0 (1 in waterlogged states of the stairs) |
| `ladder`, signs, hanging signs, wall hanging signs, `rail`, `lever`, plates, `stone_button`, torches, `nether_portal`, `cactus_flower`, `sugar_cane`, `iron_door`, trapdoors | empty (`noCollision` or `noOcclusion` also forbids occlusion) | 0 (1 in waterlogged states of the ladder, signs, hanging signs, rails and trapdoors, by the default rule) |

**Tint class.** none for every block of this range except `sugar_cane` (grass colour in the world, 24 part 1 sections 9.1 and 9.3).

**Block tags that gameplay code reads by name.** The tag contents are data of the jar (`data/minecraft/tags/block`, expanded through included tags; the tag model and the
tag names that code reads are in 24 part 1 section 12). Membership of the blocks of this range (blocks not named are in none of the tag):

| Tag | Members in this range |
|---|---|
| `mineable/axe` | `ladder`, the 11 wall signs, all 13 ceiling hanging signs and 13 wall hanging signs, the 11 wooden pressure plates, `jukebox`, `oak_fence`, `carved_pumpkin`, `jack_o_lantern`, the 11 trapdoors, the two mushroom blocks (66 in all) |
| `mineable/pickaxe` | `rail`, `cobblestone_stairs`, `stone_pressure_plate`, `iron_door`, the two redstone ores, `stone_button`, `ice`, `netherrack`, `basalt`, `polished_basalt`, the four stone brick blocks, `packed_mud`, `mud_bricks`, the six infested blocks (23) |
| `mineable/shovel` | `snow`, `snow_block`, `clay`, `soul_sand`, `soul_soil` |
| `needs_iron_tool` | `redstone_ore`, `deepslate_redstone_ore` (through it also `incorrect_for_wooden_tool`, `incorrect_for_gold_tool`, `incorrect_for_stone_tool`, `incorrect_for_copper_tool`) |
| `sword_efficient` | `carved_pumpkin`, `jack_o_lantern` |
| `climbable`, `fall_damage_resetting` | `ladder` (`fall_damage_resetting` is the climbable set plus the sweet berry bush and cobweb) |
| `signs`, `wall_signs` | the 11 wall signs (the block tag `signs` is the union of `standing_signs` and `wall_signs`; its members in this range are the 11 wall signs) |
| `ceiling_hanging_signs`, `wall_hanging_signs`, `all_hanging_signs`, `all_signs` | the 13 hanging signs, the 13 wall hanging signs, both, and all 37 sign blocks of the range |
| `doors`, `trapdoors`, `wooden_trapdoors` | `iron_door`; the 11 trapdoors (all wooden) |
| `buttons`, `stone_buttons` | `stone_button` |
| `pressure_plates`, `wooden_pressure_plates`, `stone_pressure_plates` | 12 plates; the 11 wooden plates; `stone_pressure_plate` |
| `fences`, `wooden_fences` | `oak_fence` |
| `rails`, `prevent_mob_spawning_inside` | `rail` |
| `stairs` | `cobblestone_stairs` |
| `snow` | `snow`, `snow_block` |
| `ice` | `ice` |
| `ores`, `redstone_ores` | the two redstone ores |
| `stone_bricks` | the four stone brick blocks |
| `impermeable` | the 16 stained glass blocks |
| `replaceable` | `snow` |
| `replaceable_by_mushrooms` | the two mushroom blocks |
| `flowers`, `bee_attractive`, `support_override_cactus_flower` | `cactus_flower` (flowers, bee_attractive); `cactus` (override) |
| `washed_away_by_fluids` | `rail`, `lever`, `redstone_torch`, `redstone_wall_torch`, `stone_button`, `snow`, `cactus_flower`, `soul_torch`, `soul_wall_torch`, `copper_torch`, `copper_wall_torch`, `repeater` |
| `blocks_motion`, `causes_suffocation`, `entities_can_teleport_to`, `blocks_lava_fire_spread`, `blocks_dolphin_jump`, `ice_melts_when_destroyed_above` (each also through the `blocks_motion*` family) | 98 of the 124 blocks: all except `ladder`, `rail`, the 11 wall signs, `lever`, `redstone_torch`, `redstone_wall_torch`, `stone_button`, `snow`, `cactus_flower`, `sugar_cane`, `soul_torch`, `soul_wall_torch`, `copper_torch`, `copper_wall_torch`, `nether_portal`, `repeater` (26 blocks) |
| `blocks_fluid_flow` | 109 of the 124 blocks: all except the same list without the 11 wall signs (15 blocks) |
| `cannot_support_snow_layer`, `support_override_snow_layer` | `ice`; `soul_sand` |
| `supports_*` for plants | `clay` (azalea, big dripleaf, small dripleaf, mangrove propagule); `soul_soil` (crimson and warped fungus and roots, nether sprouts); `soul_sand` (nether wart); `ice` (lily pad); `netherrack`, `soul_sand`, `soul_soil` (wither rose) |
| `soul_speed_blocks`, `soul_fire_base_blocks`, `wither_summon_base_blocks`, `triggers_ambient_dried_ghast_block_sounds` | `soul_sand`, `soul_soil` |
| `base_stone_nether`, `infiniburn_*`, `sculk_replaceable*` | `netherrack` and `basalt` (`base_stone_nether`); `netherrack` (the three `infiniburn_*`); `clay`, `netherrack`, `soul_sand`, `soul_soil`, `basalt` (the two `sculk_replaceable` tags) |
| `piglin_repellents`, `hoglin_repellents`, `portals` | `soul_torch` and `soul_wall_torch`; `nether_portal`; `nether_portal` |
| `enderman_holdable` | `cactus`, `cactus_flower`, `clay`, `carved_pumpkin` |
| `foxes_spawnable_on`, `goats_spawnable_on`, `rabbits_spawnable_on`, `wolves_spawnable_on` | `snow`, `snow_block` |
| `wall_post_override` | the 11 wall signs and the 12 pressure plates (through the tags `signs` and `pressure_plates`), `soul_torch`, `redstone_torch`, `copper_torch`, `cactus_flower` (27 in all) |
| others read by name | `azalea_grows_on` (`snow_block`); `ice_spike_replaceable` (`ice`, `snow_block`; the tag also includes `substrate_overworld`, none of whose members is in this range); `azalea_root_replaceable` (`snow_block`, `clay`); `axolotls_spawnable_on`, `lush_ground_replaceable` (`clay`); `geode_invalid_blocks`, `polar_bears_spawnable_on_alternate` (`ice`); `combination_step_sound_blocks`, `enchantment_power_transmitter`, `mangrove_roots_can_grow_through` (`snow`); `cat_does_not_teleport_to`, `dangerous_for_teleportation`, `enderman_does_not_teleport_to`, `happy_ghast_avoids` (`cactus`); `cannot_place_basalt_pillar_on`, `enables_bubble_column_push_up` (`soul_sand`) |

(The tag `blocks_motion` is read by the movement and heightmap code through the `blocks_motion*` family; these tags are listed because the jar's tag files contain the blocks above, not
because this part verified each call site; their use is the subject of 24 part 1 section 12.2.)

## 4. State properties used in this range

Value lists are in id order (first value = index 0). Property names are the state-string names; they are what sorts
the properties for state ids.

| Property (name) | Values in order | Count | Read from |
|---|---|---|---|
| `facing` (horizontal; `HorizontalDirectionalBlock.FACING` = `HORIZONTAL_FACING`) | north, south, west, east | 4 | `EnumProperty.create(name, Direction, predicate)` keeps `Direction` ordinal order (down, up, north, south, west, east) filtered by `Plane.HORIZONTAL` |
| `face` (`ATTACH_FACE`) | floor, wall, ceiling | 3 | `AttachFace` constants |
| `half` (`Half`) | top, bottom | 2 | `Half` constants |
| `half` (`DoubleBlockHalf`, door) | upper, lower | 2 | `DoubleBlockHalf` constants |
| `hinge` | left, right | 2 | `DoorHingeSide` |
| `axis` (`AXIS`) | x, y, z | 3 | `Direction$Axis` constants |
| `axis` (`HORIZONTAL_AXIS`) | x, z | 2 | explicit list |
| `shape` (rail) | north_south, east_west, ascending_east, ascending_west, ascending_north, ascending_south, south_east, south_west, north_west, north_east | 10 | `RailShape` |
| `shape` (stairs) | straight, inner_left, inner_right, outer_left, outer_right | 5 | `StairsShape` |
| `rotation` (`ROTATION_16`) | 0 to 15 | 16 | `IntegerProperty` 0 to `RotationSegment.getMaxSegmentIndex()` = 15 (precision 4 bits) |
| `layers` | 1 to 8 | 8 | `IntegerProperty` |
| `age` (`AGE_15`) | 0 to 15 | 16 | `IntegerProperty` |
| `bites` | 0 to 6 | 7 | `IntegerProperty` |
| `delay` | 1 to 4 | 4 | `IntegerProperty` |
| booleans: `attached`, `has_record`, `lit`, `locked`, `open`, `powered`, `waterlogged`, `north`, `east`, `south`, `west`, `up`, `down` | true, false | 2 each | `BooleanProperty` |

Segment numbers of `rotation` for the four horizontal directions: north 0, east 4, south 8, west 12
(`RotationSegment.convertToDirection`); `convertToSegment(Direction)` is **not** its inverse as read: it returns 0 for vertical directions and
`Direction.get2DDataValue << 2` for horizontal ones (data values south 0, west 1, north 2, east 3, so south 0, west 4, north 8, east 12; Open question 7). `convertToSegment(float yaw)` is `round(yaw * 16 / 360)` masked to 0 to 15; `convertToDegrees(i)` is `i * 22.5`, minus 360 when 180 or more.

## 5. Shape conventions and the shapes of this range

### 5.1 Builders (read from `Block` and `Shapes`)

All coordinates are in sixteenths of a block unless stated; a box is written `box(x0,y0,z0,x1,y1,z1)`.

| Builder | Meaning |
|---|---|
| `box(x0,y0,z0,x1,y1,z1)` | the box with those corners, each divided by 16 |
| `column(w, y0, y1)` | `box(8-w/2, y0, 8-w/2, 8+w/2, y1, 8+w/2)` |
| `column(wx, wz, y0, y1)` | `box(8-wx/2, y0, 8-wz/2, 8+wx/2, y1, 8+wz/2)` |
| `cube(s)` | `column(s, 8-s/2, 8+s/2)` (centred cube) |
| `boxZ(wx, y0, y1, z0, z1)` | `box(8-wx/2, y0, z0, 8+wx/2, y1, z1)` |
| `boxZ(wx, wy, z0, z1)` | `box(8-wx/2, 8-wy/2, z0, 8+wx/2, 8+wy/2, z1)` |
| `boxZ(w, z0, z1)` | `boxZ(w, w, z0, z1)` |

**Rotation.** `Shapes.rotateHorizontal(s)` returns four shapes: NORTH = `s` unchanged, EAST = `s` rotated 90 degrees
clockwise seen from above, SOUTH = 180, WEST = 270. Rotating a box by 90 clockwise about the block centre maps
(x, z) to (1 - z, x) in block units, i.e. new x range = [1 - z1, 1 - z0], new z range = [x0, x1] (read: `BLOCK_ROT_Y_90` is `ROT_90_Y_NEG`, Open question 13). `rotateHorizontalAxis(s)` returns
{Z: `s`, X: `s` rotated 90}. `rotateAll(s)` adds UP = `s` under `BLOCK_ROT_X_270` and DOWN = under `BLOCK_ROT_X_90`.
`rotateAttachFace(s)` returns for FACE = wall the horizontal rotations of `s`; for floor, the horizontal rotations of
`s` after `BLOCK_ROT_X_270`; for ceiling, after `BLOCK_ROT_Y_180` composed with `BLOCK_ROT_X_90` (rotation order as
read; the resulting boxes for the lever and button are stated in 5.2).
`Shapes.or` is union. Shapes are voxel shapes: the union of boxes, not a single bounding box.

### 5.2 Shapes by class

| Class (blocks) | Collision | Outline (getShape) |
|---|---|---|
| `WallSignBlock` (all `*_wall_sign`) | none (`noCollision`) | by `facing`: north `box(0,4.5,14,16,12.5,16)`; others by horizontal rotation: east `box(0,4.5,0,2,12.5,16)`, south `box(0,4.5,0,16,12.5,2)`, west `box(14,4.5,0,16,12.5,16)` |
| `CeilingHangingSignBlock` (`*_hanging_sign`, 13) | none | rotation 0 or 8: `box(1,0,7,15,10,9)`; rotation 4 or 12: `box(7,0,1,9,10,15)`; every other rotation: `box(3,0,3,13,16,13)`. `getBlockSupportShape` equals the outline. |
| `WallHangingSignBlock` (`*_wall_hanging_sign`, 13) | plank only by facing axis: axis z `box(0,14,6,16,16,10)`, axis x `box(6,14,0,10,16,16)` | by facing axis: z = plank + `box(1,0,7,15,10,9)`; x = plank + `box(7,0,1,9,10,15)` |
| `LeverBlock` | none | wall, facing north: `box(5,4,10,11,12,16)`, other facings by horizontal rotation; floor, facing north: `box(5,0,4,11,6,12)` (read: `rotateAttachFace` applies `ROT_90_X_POS`, see Open question 13; the model's base footprint x 5 to 11, z 4 to 12 agrees, see 7.5); ceiling, facing north: `box(5,10,4,11,16,12)` (the model's x 180 turn agrees; the composition order is not decoded, Open question 13); for facing east or west the floor and ceiling boxes swap their x and z extents. The shape does not depend on `powered`. |
| `PressurePlateBlock` | none | unpressed (`powered` false) `column(14, 0, 1)` = `box(1,0,1,15,1,15)`; pressed `column(14, 0, 0.5)`. Entity detection box `column(14, 0, 4)` = `box(1,0,1,15,4,15)` moved to the block. |
| `DoorBlock` (`iron_door`) | same as outline (read: facing when closed; when open, counter-clockwise of `facing` if `hinge` is right, clockwise if left) | base shape `boxZ(16,13,16)` = `box(0,0,13,16,16,16)` for NORTH, rotated per facing; the facing used is `facing` when closed, and when open `facing` rotated counter-clockwise if `hinge` is right, clockwise if left |
| `RedstoneTorchBlock`, `TorchBlock` (standing) | none | `column(4, 0, 10)` = `box(6,0,6,10,10,10)` |
| `WallTorchBlock`, `RedstoneWallTorchBlock` | none | north `boxZ(5, 3, 13, 11, 16)` = `box(5.5,3,11,10.5,13,16)`, others by horizontal rotation |
| `ButtonBlock` (`stone_button`) | none | base `boxZ(6, 4, 8, 16)` = `box(5,6,8,11,10,16)` for wall facing north, rotated by `rotateAttachFace`; the shape is that base minus `cube(12)` (unpowered, leaves 2 thick: `box(5,6,14,11,10,16)`) or minus `cube(14)` (powered, leaves 1 thick: `box(5,6,15,11,10,16)`) (`BooleanOp.ONLY_FIRST`). Floor, facing north: `box(5,0,6,11,2,10)` unpowered, `box(5,0,6,11,1,10)` powered (read, and equal to the model boxes of `button` and `button_pressed`); ceiling: `box(5,14,6,11,16,10)` / `box(5,15,6,11,16,10)` (the blockstate data turns the model 180 degrees about the x axis for ceiling, see 7.5); east and west swap the x and z extents (x 6 to 10, z 5 to 11). |
| `SnowLayerBlock` | `box(0,0,0,16, 2*(layers-1), 16)`: layer 1 has a zero-height collision, layer 8 height 14 | `box(0,0,0,16, 2*layers, 16)`; `getBlockSupportShape` and the visual shape use the outline; `useShapeForLightOcclusion` is true; shade brightness is 0.2 at 8 layers, 1.0 otherwise |
| `IceBlock` | full cube | full cube |
| `CactusBlock` | `column(14, 0, 15)` | `column(14, 0, 16)` |
| `CactusFlowerBlock` | none | `column(14, 0, 12)` |
| `SugarCaneBlock` | none | `column(12, 0, 16)` |
| `FenceBlock` | by side booleans, 24 high, see 5.3 | by side booleans, 16 high, see 5.3 |
| `SoulSandBlock` | `column(16, 0, 14)` = `box(0,0,0,16,14,16)` | support shape and visual shape full cube |
| `NetherPortalBlock` | none | axis z: `box(6,0,0,10,16,16)`; axis x: `box(0,0,6,16,16,10)` (base `column(4, 16, 0, 16)` registered for axis Z, rotated for axis X) |
| `CakeBlock` | same as outline | by `bites` b (0 to 6): `box(1 + 2b, 0, 1, 15, 8, 15)` |
| `RepeaterBlock` | same as outline | `column(16, 0, 2)` = `box(0,0,0,16,2,16)` |
| Glass, mushrooms, bricks, infested, netherrack, clay, snow block, jukebox, carved pumpkin, basalt, glowstone | full cube | full cube |
| `TrapDoorBlock` | same as outline | base `boxZ(16,13,16)` rotated by `rotateAll`; open: shape of `facing` (slab at the `facing`-opposite side: north `box(0,0,13,16,16,16)` etc.); closed bottom half: `box(0,0,0,16,3,16)`; closed top half: `box(0,13,0,16,16,16)` |
| `LadderBlock` | same as outline | `boxZ(16,13,16)` rotated per `facing`: north `box(0,0,13,16,16,16)`, east `box(0,0,0,3,16,16)`, south `box(0,0,0,16,16,3)`, west `box(13,0,0,16,16,16)` |
| `RailBlock` | none | flat `column(16, 0, 2)` for `north_south`, `east_west` and the four curves; slope `column(16, 0, 8)` for `ascending_north`, `ascending_east`, `ascending_south`, `ascending_west` (`RailShape.isSlope`, read) |

### 5.3 Fence shapes (`FenceBlock`, `CrossCollisionBlock`)

`CrossCollisionBlock.makeShapes(postWidth, postHeight, armWidth, armY0, armY1)` builds, for each of the 32 states (the
shape depends only on the four side booleans; `waterlogged` does not change it), the union of a centred post
`column(postWidth, 0, postHeight)` and, for each side whose boolean is true, an arm `boxZ(armWidth, armY0, armY1, 0, 8)` turned to
that side (the north arm is `box(8 - armWidth/2, armY0, 0, 8 + armWidth/2, armY1, 8)`). `FenceBlock` passes (4, 16, 4, 16, 24)
to the constructor, which builds three shape sets:

| Set | Call | Post | North arm | Used for |
|---|---|---|---|---|
| outline (`getShape`, and `getVisualShape`) | `makeShapes(4, 16, 4, 0, 16)` | `box(6,0,6,10,16,10)` | `box(6,0,0,10,16,8)` | targeting and rendering |
| collision | `makeShapes(4, 24, 4, 0, 24)` | `box(6,0,6,10,24,10)` | `box(6,0,0,10,24,8)` | entity movement (a fence is 1.5 blocks high) |
| occlusion (`getOcclusionShape`) | `makeShapes(4, 16, 2, 6, 15)` | `box(6,0,6,10,16,10)` | `box(7,6,0,9,15,8)` | face culling and light |

East, south and west arms are the north arm turned by the horizontal rotations of 5.1. `isPathfindable` is false for every
state of the class (`CrossCollisionBlock`), and the block does not propagate skylight when `waterlogged` is true
(section 3.3).

## 6. Block set types and wood types

Doors, trapdoors, buttons and pressure plates take their sound type and sound events from a `BlockSetType`; signs and
hanging signs take their sound types from a `WoodType`; each wood type names a block set type. Both are records created in
the static initialisers of `BlockSetType` and `WoodType`. A class applies the sound type with `Properties.sound(...)` in its
own constructor, which overrides any sound already in the `Blocks` entry (section 3, "Sound").

### 6.1 `BlockSetType`

The one-argument constructor (used by oak, spruce, birch, acacia, jungle, dark oak, pale oak, poplar and mangrove) fixes
`canOpenByHand` true, `canOpenByWindCharge` true, `canButtonBeActivatedByArrows` true, plate sensitivity `EVERYTHING`, sound type
`WOOD` and the `WOODEN_*` events. Plate sensitivity `EVERYTHING` counts every entity, `MOBS` only living entities (the plate's
detection class, section 7.7).

| Set type | By hand | Wind charge | Arrows on button | Plate sensitivity | Sound type | Door close / open | Trapdoor close / open | Plate click off / on | Button click off / on |
|---|---|---|---|---|---|---|---|---|---|
| `iron` | no | no | no | EVERYTHING | `IRON` | `IRON_DOOR_*` | `IRON_TRAPDOOR_*` | `METAL_PRESSURE_PLATE_*` | `STONE_BUTTON_*` |
| `copper` | yes | yes | no | EVERYTHING | `COPPER` | `COPPER_DOOR_*` | `COPPER_TRAPDOOR_*` | `METAL_PRESSURE_PLATE_*` | `STONE_BUTTON_*` |
| `gold` | no | yes | no | EVERYTHING | `METAL` | `IRON_DOOR_*` | `IRON_TRAPDOOR_*` | `METAL_PRESSURE_PLATE_*` | `STONE_BUTTON_*` |
| `stone` | yes | yes | no | MOBS | `STONE` | `IRON_DOOR_*` | `IRON_TRAPDOOR_*` | `STONE_PRESSURE_PLATE_*` | `STONE_BUTTON_*` |
| `polished_blackstone` | yes | yes | no | MOBS | `STONE` | `IRON_DOOR_*` | `IRON_TRAPDOOR_*` | `STONE_PRESSURE_PLATE_*` | `STONE_BUTTON_*` |
| `oak`, `spruce`, `birch`, `acacia`, `jungle`, `dark_oak`, `pale_oak`, `poplar`, `mangrove` | yes | yes | yes | EVERYTHING | `WOOD` | `WOODEN_DOOR_*` | `WOODEN_TRAPDOOR_*` | `WOODEN_PRESSURE_PLATE_*` | `WOODEN_BUTTON_*` |
| `cherry` | yes | yes | yes | EVERYTHING | `CHERRY_WOOD` | `CHERRY_WOOD_DOOR_*` | `CHERRY_WOOD_TRAPDOOR_*` | `CHERRY_WOOD_PRESSURE_PLATE_*` | `CHERRY_WOOD_BUTTON_*` |
| `crimson`, `warped` | yes | yes | yes | EVERYTHING | `NETHER_WOOD` | `NETHER_WOOD_DOOR_*` | `NETHER_WOOD_TRAPDOOR_*` | `NETHER_WOOD_PRESSURE_PLATE_*` | `NETHER_WOOD_BUTTON_*` |
| `bamboo` | yes | yes | yes | EVERYTHING | `BAMBOO_WOOD` | `BAMBOO_WOOD_DOOR_*` | `BAMBOO_WOOD_TRAPDOOR_*` | `BAMBOO_WOOD_PRESSURE_PLATE_*` | `BAMBOO_WOOD_BUTTON_*` |

`*` stands for `CLOSE`/`OPEN` or `CLICK_OFF`/`CLICK_ON` in the column's order. The mapping of the enum constants to the
detection class (`EVERYTHING` to `Entity`, `MOBS` to `LivingEntity`) was read from the plate's switch by the names of
the classes (the order of the compiler's switch index was not decoded; Open question 15).

### 6.2 `WoodType`

The two-argument constructor (every wood except cherry, crimson, warped and bamboo) fixes sound type `WOOD`, hanging-sign
sound type `HANGING_SIGN` and the fence gate events `FENCE_GATE_CLOSE` / `FENCE_GATE_OPEN`.

| Wood type | Block set type | Sound type (standing and wall sign) | Hanging-sign sound type (ceiling and wall hanging sign) |
|---|---|---|---|
| oak, spruce, birch, acacia, jungle, dark oak, pale oak, poplar, mangrove | same name | `WOOD` | `HANGING_SIGN` |
| cherry | `cherry` | `CHERRY_WOOD` | `CHERRY_WOOD_HANGING_SIGN` |
| crimson, warped | `crimson`, `warped` | `NETHER_WOOD` | `NETHER_WOOD_HANGING_SIGN` |
| bamboo | `bamboo` | `BAMBOO_WOOD` | `BAMBOO_WOOD_HANGING_SIGN` |

(The fence gate events of cherry, crimson, warped and bamboo are the `CHERRY_WOOD_FENCE_GATE_*`, `NETHER_WOOD_FENCE_GATE_*`
and `BAMBOO_WOOD_FENCE_GATE_*` constants; fence gates are not in this range.) The wood type of a sign is the constructor
argument of section 2.

## 7. Classes: states, defaults, survival, placement and behaviour

State ids follow section 1, item 3. "Default" is the state set by the constructor. A state change "returns air" when
`updateShape` returns the default state of `air`, which removes the block. "Waterlogged" handling is common to every class
with a `waterlogged` property: `getFluidState` gives the water source when it is true, and `updateShape` schedules a water
tick (`FlowingFluid.getTickDelay`) when it is true; the placement state sets it when the fluid at the target is water.
Redstone engine rules (the quasi-connectivity, `ExperimentalRedstoneUtils` orientation arguments) belong to the redstone
document; this part gives the signal strengths each class reports.

### 7.1 Ladder (`LadderBlock`, field 206)

| Item | Rule |
|---|---|
| States | `facing` (4, north first) x `waterlogged` (2) = 8; default north, dry |
| Survival | the block at `pos.relative(facing.opposite)` has its face toward `facing` sturdy (`isFaceSturdy`, full support); `updateShape` returns air when the changed neighbour is on that side and the test fails |
| Placement | refuses (returns no state) when the clicked-on block is itself a ladder facing the clicked face and the click is not on a replaceable block; otherwise tries the player's nearest looking directions in order; the first horizontal one for which `facing = direction.opposite` survives is used (waterlogged when the fluid is water); none survives: no placement |
| Other | tag `climbable`, `fall_damage_resetting`; rotate and mirror act on `facing` |

### 7.2 Rails (`RailBlock`, field 207; `BaseRailBlock`)

| Item | Rule |
|---|---|
| States | `shape` (10 values, order of section 4) x `waterlogged` (2) = 20; default `north_south`, dry |
| Shape | `RailShape.isSlope()` is true for `ascending_north`, `ascending_east`, `ascending_south` and `ascending_west`: those states use the slope shape `column(16, 0, 8)` (a box 8/16 high over the whole cell), every other state (including the four curves) the flat shape `column(16, 0, 2)`. Collision is none |
| Survival | the block below can support a rigid block (`canSupportRigidBlock`) |
| Placement | `shape` = `east_west` when the player's horizontal direction is east or west, else `north_south`; waterlogged when the fluid is water. Connection to neighbours (`RailState`, `updateState`) then adjusts `shape`; `RailBlock.updateState` recomputes when a neighbour changes and only when the rail is not a signal source: it counts potential connections and reconnects when the count is 3 |
| Neighbour | `neighborChanged` removes and drops the rail (`dropResources`) when `shouldBeRemoved` (support lost or an ascending rail's high side lost its support), else recomputes the shape |

The connection solver (`RailState`) is not specified here (Open question 5).

### 7.3 Stairs (`StairBlock`, field 208)

`cobblestone_stairs` is `registerLegacyStair(cobblestone)`: `ofLegacyCopy(cobblestone)` then the view-blocking predicate of
24 part 7 (section 3 of this document shows the copied values). States: `facing` (4) x `half` (2: top, bottom) x `shape` (5)
x `waterlogged` (2) = 80, default north, bottom, straight, dry. The shapes, the placement (`half` from the clicked face or,
for a side click, from the click height against 0.5; `shape` from `getStairsShape` of the neighbours) and the `updateShape`
rule are the stair rules of 24 part 7; they are not repeated here.

### 7.4 Signs (fields 209 to 245)

| Class | States | Default | Survival | Placement | Notes |
|---|---|---|---|---|---|
| `WallSignBlock` (11) | `facing` (4) x `waterlogged` (2) = 8 | north, dry | the block at `pos.relative(facing.opposite)` is `isSolid()` (section 1, item 8); `updateShape` returns air when that neighbour changes and the test fails | nearest looking directions in order; the first horizontal direction d with `facing = d.opposite` that survives (the loop skips vertical directions) | sign block entity; outline in 5.2; yaw `facing.toYRot` |
| `CeilingHangingSignBlock` (13) | `rotation` (16) x `attached` (2) x `waterlogged` (2) = 64; sorted `attached`, `rotation`, `waterlogged` | rotation 8, attached false, dry | the block above (`pos.above`) has its DOWN face sturdy with support type `CENTER`; `updateShape` returns air when the changed neighbour is above and the test fails | see below | `getBlockSupportShape` is the outline; yaw = `RotationSegment.convertToDegrees(rotation)` |
| `WallHangingSignBlock` (13) | `facing` (4) x `waterlogged` (2) = 8 | north, dry | `canSurvive` is not overridden (always true); placement and `updateShape` use `canPlace` instead | see below | no pathfinding (`isPathfindable` false); collision is the plank of 5.2 |

`WallHangingSignBlock.canPlace(state, level, pos)` is true when at least one of the two blocks beside the sign (at
`pos.relative(facing.clockwise)` and `pos.relative(facing.counterclockwise)`) passes `canAttachTo`: a neighbour in tag
`wall_hanging_signs` passes when its `facing` lies on the same axis as this sign's `facing`; any other neighbour passes
when its face toward the sign is sturdy with support type FULL. Placement picks the first nearest looking direction that is
horizontal and parallel to the clicked face's axis, sets `facing` to its opposite and requires `canSurvive` and `canPlace`.
`updateShape` returns air when the changed neighbour is on the axis perpendicular to `facing` (the `facing.clockwise` axis)
and the sign no longer passes `canSurvive`; because `canSurvive` is always true, only `canPlace` placement protects the sign
(Open question 6).

Ceiling hanging sign placement (`CeilingHangingSignBlock.getStateForPlacement`, read in full). Inputs: the clicked position `p`, the block state `A` at `p.above`, the player's horizontal facing `d` (the direction of the player's yaw), the player's yaw, and the secondary-use flag `sneak` (sneaking).

1. `waterlogged` = the fluid at `p` is water.
2. `attached` starts as: **true** when the collision shape of `A` has no full DOWN face (`Block.isFaceFull`) **or** `sneak` is true; **false** only when that face is full and `sneak` is false. (An earlier draft of this document had the first condition reversed.)
3. If `A` is in tag `all_hanging_signs` and `sneak` is false, `attached` may be cleared, by exactly one of two checks: when `A` has the `facing` property (a wall hanging sign), `attached` becomes false when the axis of that `facing` equals the axis of `d`; otherwise, when `A` has the `rotation` property and `rotation` is one of 0, 4, 8, 12 (the values for which `RotationSegment.convertToDirection` returns a direction), `attached` becomes false when that direction's axis equals the axis of `d`. Any other `rotation` value leaves `attached` unchanged.
4. `rotation` = when `attached` is false, `convertToSegment(d.opposite)`, that is 0 (d north), 4 (d east), 8 (d south), 12 (d west) (section 4: south 0, west 4, north 8, east 12 for the argument, so the opposite of the player's facing); when `attached` is true, `convertToSegment(yaw + 180)`, that is `round((yaw + 180) * 16 / 360)` masked to 0 to 15.
5. The result is the default state with those three values; placement is then accepted or refused by `canSurvive` (the block above must have a CENTER-sturdy DOWN face).

Check of the two `rotation` branches: for an axis-aligned facing the two formulas give the same number (facing north, yaw 180: `(180 + 180)` gives 16, masked 0; the opposite of north is south, segment 0; facing east, yaw 270: 450 gives 20, masked 4; the opposite of east is west, segment 4), so the table mismatch of Open question 7 does not change behaviour: placement always passes the **opposite** of the player's facing to the direction form. Using a hanging sign item on the underside of a ceiling hanging sign
chains another hanging sign instead of opening the text editor (`shouldTryToChainAnotherHangingSign`: the hit direction is
DOWN, the item is a hanging sign item, and the sign's side clicked has no click command). `rotate` adds the turn to `rotation`
modulo 16; `mirror` applies `Mirror.mirror(rotation, 16)`.

Sign interaction (all sign classes, `SignBlock`): `setPlacedBy` opens the text editor for the placing server player on the front
side when the block entity is not waxed and the text is editable; `useItemOn` lets a `SignApplicator` item (dye, glow ink sac,
ink sac, honeycomb) apply to the side the player is facing; `useWithoutItem` runs the clicked side's click commands, plays the
sign's "interaction failed" sound when the sign is waxed, else opens the editor when no other player is editing and the player
may build. The block entities (`SignBlockEntity`, `HangingSignBlockEntity`) and the text format belong to the block entity
document (Open question 8). Signs are always `isPossibleToRespawnInThis`.

### 7.5 Lever and stone button (fields 246 and 264)

Both extend `FaceAttachedHorizontalDirectionalBlock`: states `face` (floor, wall, ceiling) x `facing` (4) x `powered` (2) = 24;
sorted `face`, `facing`, `powered`; default `face` wall, facing north, `powered` false (index 9 of 24 for the lever and for
the button, first state + 9).

| Item | Rule |
|---|---|
| Connected direction | floor: DOWN; ceiling: UP; wall: `facing` (the direction the block's back points, i.e. the block is attached to the neighbour at `pos.relative(connected.opposite)`) |
| Survival | the neighbour at `pos.relative(connectedDirection.opposite)` has its face toward the connected direction sturdy (`FaceAttachedHorizontalDirectionalBlock.canAttach`); `updateShape` returns air when the changed neighbour is that one and survival fails |
| Placement | nearest looking directions in order: for the first vertical direction, `face` = ceiling when it is UP else floor, `facing` = the player's horizontal direction; for the first horizontal direction, `face` = wall and `facing` = its opposite; the first candidate that survives is used |
| Lever use | toggles `powered`; on the server plays `LEVER_CLICK` (volume 0.3, pitch 0.6 when it becomes powered, 0.5 when unpowered), sends game event `BLOCK_ACTIVATE` or `BLOCK_DEACTIVATE`, and updates the neighbour at the connected side and the neighbour beyond it; the client spawns a red dust particle on use; `animateTick` spawns particles at random while powered (probability 0.25) |
| Lever signal | `isSignalSource` true; own signal 15 when powered; direct signal 15 toward the block on the connected side only (`getDirectSignal` returns 15 when powered and the queried direction equals the connected direction) |
| Button use | when unpowered: sets `powered` true, updates neighbours, schedules a tick after the press duration (20 ticks for the stone button; wooden buttons use 30 in other ranges), plays the set type's click sound and sends `BLOCK_ACTIVATE`; when powered the use is consumed with no effect |
| Button tick | when powered, `checkPressed`: for a set type whose arrows can press (`canButtonBeActivatedByArrows`), looks for an arrow entity (class `AbstractArrow`) overlapping the button's current outline moved to the position; sets `powered` to whether one exists, and when the state changed updates neighbours, plays the click and sends the game event; when still powered reschedules after the press duration. Stone and polished blackstone buttons ignore arrows (no `entityInside` effect) |
| Button signal | same as the lever: own 15 when powered, direct 15 toward the connected side |
| Explosion | `onExplosionHit` triggers (toggles the lever; presses the unpowered button) when the explosion can trigger blocks |

Lever outline and the button outline: section 5.2. The floor and ceiling collision-free outlines were checked against the
visual models: the button model is `box(5,0,6,11,2,10)` (unpressed) and `box(5,0,6,11,1.02,10)` (pressed) for floor north, and
the block state data places ceiling variants with a 180-degree turn about the x axis, so ceiling north is `box(5,14,6,11,16,10)`;
east and west swap the extents to x from 6 to 10 and z from 5 to 11 (the outline cut uses 1.0 pressed thickness, the model 1.02).
The lever model's base occupies x from 5 to 11 and z from 4 to 12 for floor north, which agrees with the outline `box(5,0,4,11,6,12)`
(height 6 is the wall shape's depth 6 turned onto the floor by `ROT_90_X_POS`; the wall box is `boxZ(6, 8, 10, 16)` in the lever's `makeShapes`).

### 7.6 Pressure plates (`PressurePlateBlock`, fields 247 and 249 to 259)

| Item | Rule |
|---|---|
| States | `powered` (2); default false |
| Survival | the block below can support a rigid block (`canSupportRigidBlock`) or can support the cell centre from above (`canSupportCenter`, direction UP); `updateShape` returns air when the changed neighbour is below and survival fails |
| Signal | 15 when powered, else 0; the plate is a signal source; direct signal 15 when the queried direction is UP (otherwise 0) |
| Detection | the detection box is `column(14, 0, 4)` (the first box of that shape) moved to the position; the count is of entities of the class given by the plate sensitivity (all entities for `EVERYTHING`, living entities for `MOBS`), excluding spectators and entities that ignore block triggers; a count above 0 gives signal 15 |
| Update | `entityInside` on the server: when the current signal is 0, runs `checkPressed`; `tick` (every 20 ticks while pressed): when the signal is above 0 runs `checkPressed`. `checkPressed` compares the new strength with the current one; on a change it sets `powered`, updates the plate's and the block below's neighbours, marks the position dirty, plays the set type's click (off when it turns off, on when it turns on) and the game event `BLOCK_DEACTIVATE` / `BLOCK_ACTIVATE`; if the new strength is above 0 it schedules the next tick after 20 ticks (`getPressedTime`) |
| Removal | `affectNeighborsAfterRemoval` updates neighbours when the removed state was powered |

### 7.7 Doors (`DoorBlock`, field 248) and trapdoors (`TrapDoorBlock`, fields 290 to 300)

| Item | Door | Trapdoor |
|---|---|---|
| States | `facing` (4) x `half` (upper, lower) x `hinge` (left, right) x `open` x `powered` = 64; sorted `facing`, `half`, `hinge`, `open`, `powered` | `facing` (4) x `half` (top, bottom) x `open` x `powered` x `waterlogged` = 64; sorted in that order |
| Default | north, lower, hinge left, closed, unpowered | north, bottom, closed, unpowered, dry |
| By hand | `canOpenByHand` of the set type: the iron door answers `PASS` (cannot be opened by hand), wooden doors toggle `open` with flag value 10 and play the open or close sound with pitch `0.9 + random * 0.1` and the game event `BLOCK_OPEN` / `BLOCK_CLOSE` | same sound rule (volume 1, pitch `0.9 + random * 0.1`), `toggle` sets `open` (flag value 2), schedules the water tick when waterlogged |
| Redstone | `neighborChanged`: powered = signal at the block or at the block above (lower half) or below (upper half); when the changed block is not the door and `powered` differs: if `powered` differs from `open`, plays the sound and the game event; sets `powered` and `open` to the new value (flag value 2) | when the power state differs from `powered`: if it also differs from `open`, sets `open`, plays the sound; sets `powered`; schedules the water tick when waterlogged |
| Wind charge | `onExplosionHit` of the lower half opens or closes the door when the set type allows wind charges and the door is not powered | opens when the set type allows wind charges and it is not powered |
| Survival | lower half: the block below has its UP face sturdy (full); upper half: the block below is the same door block; `updateShape`: a vertical neighbour change keeps the pair (the upper half takes the lower half's state when the lower half is a door of the same type with the other half value, else returns air), a lower-half change from below with failed survival returns air | none beyond placement; trapdoors never fail survival |
| Placement | the target cell and the one above must be replaceable and the target height below the world maximum; `facing` = the player's horizontal direction; `hinge` from the rule of 7.7.1; `powered` and `open` = whether the target cell or the cell above has a neighbour signal; `half` lower; `setPlacedBy` places the upper half above | when the placement does not replace the clicked block and the clicked face is horizontal: `facing` = the clicked face and `half` = top when the click height within the cell is above 0.5, else bottom; otherwise `facing` = the opposite of the player's horizontal direction and `half` = bottom when the clicked face is UP, else top; `open` and `powered` both true when the cell has a neighbour signal; waterlogged when the fluid is water |
| Destruction | the creative-mode break of the lower half does not drop (`DoublePlantBlock.preventDropFromBottomPart` when the player has no correct tool or prevents drops) | none |
| Seed | `getSeed` for the model offset: the x of the lower half's position, the y of the position below the upper half, the z (`Mth.getSeed`) | default |
| Pathfinding | `isPathfindable` true for land and air only when `open`; false for water | `open` for land and air, `waterlogged` for water (switch order of the cases not decoded, Open question 15) |

#### 7.7.1 Door hinge (`DoorBlock.getHinge`)

Inputs: the player's horizontal direction `d`, the clicked position `p`, and the four blocks `L0` at `p + ccw(d)`, `L1` at
`p + up + ccw(d)`, `R0` at `p + cw(d)`, `R1` at `p + up + cw(d)` (`ccw`, `cw` are the counter-clockwise and clockwise horizontal
directions seen from above).

1. Score `s` = `-1` for each of `L0`, `L1` whose collision shape is a full block, plus `+1` for each of `R0`, `R1` whose collision
   shape is a full block (so `s` is between -2 and 2).
2. `leftDoor` = `L0` is a door block in its lower half; `rightDoor` = `R0` is a door block in its lower half.
3. The hinge is **right** when (`leftDoor` and not `rightDoor`) or `s` > 0.
4. Otherwise the hinge is **left** when (`rightDoor` and not `leftDoor`) or `s` < 0.
5. Otherwise the click offset inside the cell decides: with `(sx, sz)` the step of `d` and `(dx, dz)` the click position minus the
   cell origin, the hinge is right when (`sx` < 0 and `dz` < 0.5) or (`sx` > 0 and `dz` > 0.5) or (`sz` < 0 and `dx` > 0.5) or
   (`sz` > 0 and `dx` < 0.5); else left.

### 7.8 Redstone ore and redstone torches (fields 260 to 263)

| Block | States | Default | Rules |
|---|---|---|---|
| `redstone_ore`, `deepslate_redstone_ore` (`RedStoneOreBlock`) | `lit` (2) | lit false (second state) | punching (`attack`), stepping on it without sneaking (`stepOn`) and using an item on it (`useItemOn`, which also lights the block and, when the item is a block item that can be placed, passes so placement proceeds) set `lit` true (spark particles on the client); random-ticks only while `lit`, and then sets `lit` false; break experience: uniform integer 1 to 5 (`UniformInt.of(1, 5)`) when drops are enabled; light 9 when lit |
| `redstone_torch` (`RedstoneTorchBlock`) | `lit` (2) | **lit true** (first state) | survival: the block below can support the cell centre from above (`canSupportCenter` UP, `BaseTorchBlock`); outline `column(4, 0, 10)` |
| `redstone_wall_torch` (`RedstoneWallTorchBlock`) | `facing` (4) x `lit` (2) = 8, sorted `facing`, `lit` | north, lit true | survival: the neighbour at `pos.relative(facing.opposite)` has its face toward `facing` sturdy; placement as for wall torches below, using the standing torch's loot and the facing of the first valid direction |

Redstone torch behaviour. `onPlace` and removal notify the six neighbours (random orientation). The torch is lit unless the block it
is attached to (below for the standing torch, `pos.relative(facing.opposite)` for the wall torch) receives a signal (`hasSignal` in
the direction of that block). `neighborChanged` schedules a tick after 2 ticks when the lit state differs from "no signal on the
support" and no tick is already due this tick. `tick` removes entries older than 60 game ticks from this position's toggle list,
then: if lit and the support is powered, sets `lit` false and, if the position has toggled too often (a toggle is recorded each time;
8 or more entries within the window), plays level event 1502 (burnout) and schedules another tick after 160 ticks; if not lit and
the support is not powered and the torch is not toggling too often, sets `lit` true. Signals: own 15 when lit; `getSignal` toward every
direction except UP for the standing torch (the torch powers the blocks around and below it but not the one above), toward every direction except
`facing` for the wall torch; direct signal (`getDirectSignal`) 15 toward DOWN only (the support block, strongly powered), taken from `getSignal`.
The wall torch's non-lit state also affects light (7 when lit).

Wall torch common rules (`WallTorchBlock`, `soul_wall_torch`, `copper_wall_torch`, `redstone_wall_torch`): states `facing` (4), default
north, survival as above, placement picks the first horizontal nearest-looking direction d with `facing = d.opposite` that survives,
`updateShape` returns air when the changed neighbour is on the support side and survival fails; the standing torches (`TorchBlock`) have
no state (soul, copper: 1 state), survival `canSupportCenter(below, UP)`, and `updateShape` returns air when the changed neighbour is below
and survival fails. Their particle options are the constructor argument of section 2.

### 7.9 Repeater (`RepeaterBlock`, field 288)

States `delay` (1 to 4) x `facing` (4) x `locked` (2) x `powered` (2) = 64, sorted `delay`, `facing`, `locked`, `powered`; default delay 1, north,
unlocked, unpowered (first state + 3). Survival: the block below has its UP face sturdy with support type RIGID. Placement: `facing` = the opposite of the
player's horizontal direction, `locked` = whether a side diode powers it (`isLocked`: the stronger of the two side inputs, from diodes only, is above 0).
Use (when the player may build): cycles `delay` 1, 2, 3, 4, 1. The turn-on delay is `delay * 2` game ticks. The input is read from the block behind (the
neighbour at `facing`): the larger of the world signal there and, when that block is redstone wire, its `power`; the repeater turns on when the input is above 0.
`neighborChanged` (when the cell still holds a repeater) removes the block with its drops and updates all six neighbours when survival fails, else runs `checkTickOnNeighbor`: nothing while locked; when `powered` differs from the input test and no tick of this block is already due this game tick, it schedules a tick after the block's delay (`delay * 2` game ticks) with priority `HIGH`, raised to `EXTREMELY_HIGH` when the block in front is a diode that does not face the repeater (`shouldPrioritize`), else to `VERY_HIGH` when the repeater is currently powered. `tick` does nothing while locked; when on and the input is 0 it turns off (flag value 2); when off it turns on and, if the input is 0, schedules a tick after the delay with priority `VERY_HIGH` so that it turns off again. `setPlacedBy` schedules a tick after 1 tick when the input is above 0. Output signal: 15 when powered, given only toward the direction it faces (queried direction equal to `facing`); the direct signal equals it. Outline: 5.2.

### 7.10 Snow layers, ice, cactus, cactus flower and sugar cane (fields 265 to 271)

| Block | States | Default | Rules |
|---|---|---|---|
| `snow` (`SnowLayerBlock`) | `layers` 1 to 8 (8) | layers 1 | survival: the block below is not in tag `cannot_support_snow_layer`, and either is in `support_override_snow_layer`, or its UP face is full (`Block.isFaceFull` of its collision shape), or it is a snow layer block with 8 layers; `updateShape` returns air when survival fails. Random tick: when the **block light** at the position is above 11, drops the block's resources and removes it (game event `BLOCK_DESTROY`). Replacement by a placing item: when the held item is snow and `layers` is below 8: if the placement replaces the clicked block it is replaceable only when the clicked face is UP, else always; when the held item is not snow or layers is 8, replaceable only when `layers` is 1 (the `replaceable` builder flag). Placement onto an existing snow layer block raises `layers` by one up to 8 |
| `ice` (`IceBlock`) | none | - | random tick: when the block light at the position is above `11 - lightDampening` (above 10 for ice) it melts: removed when the dimension's attribute `water_evaporates` is true, else becomes water (block update, `BLOCK_DESTROY`). `playerDestroy` (without a silk touch tool, tag `prevents_ice_melting` on the tool): removed when `water_evaporates`, else when the block below blocks motion or is a liquid and not in tag `ice_melts_when_destroyed_above` the block becomes water |
| `cactus` (`CactusBlock`) | `age` 0 to 15 (16) | age 0 | survival and growth: section 7.10.1 |
| `cactus_flower` (`CactusFlowerBlock`, a `VegetationBlock`) | none | - | may be placed on a block in `support_override_cactus_flower` or whose UP face is sturdy with support type CENTER |
| `sugar_cane` (`SugarCaneBlock`) | `age` 0 to 15 (16) | age 0 | section 7.10.2 |

The random-tick scheduling of snow and ice (which positions are ticked, the ice and snow formation step) is in 33 section 2.4; this part gives only the per-block random-tick effects.

#### 7.10.1 Cactus

1. Survival (`canSurvive`): for each of the four horizontal neighbours, the neighbour must not be `isSolid()` and its fluid must not be lava; the block below
   must be a cactus or in tag `supports_cactus`; the block above must not be a liquid. `tick` (scheduled by `updateShape` after one tick when survival fails)
   destroys the cactus with drops.
2. Random tick, with `age` the age at entry: do nothing unless the cell above is empty. Let `h` be 1 plus the number of cactus blocks directly below, counted by
   walking down; the walk returns with no effect when `h` reaches exactly 3 while `age` is 15.
3. If `age` is 8 and a default cactus could survive above: the flower chance is 0.1 when `h` is below 3 and 0.25 when `h` is 3 or more; a random `nextDouble`
   not above the chance sets the cell above to the default `cactus_flower`. (Then continue at step 5.)
4. Otherwise, if `age` is 15 and `h` is below 3: places a default cactus above, sets this block's age to 0 (flag value 260) and sends a neighbour change from the new block.
5. If the entry age is below 15 (also after step 3), sets age + 1 (flag value 260).

Entities inside a cactus take the `cactus` damage of 1.0. Outline and collision: 5.2 (collision `column(14, 0, 15)`).

#### 7.10.2 Sugar cane

1. Survival: the block below is sugar cane; or the block below is in tag `supports_sugar_cane` and at least one of the four horizontal neighbours of the
   block **below** has a fluid in tag `supports_sugar_cane_adjacently` or is itself a block in that tag. `tick` destroys the cane with drops when survival fails.
2. Random tick: only when the cell above is empty. Count `h` = 1 plus the sugar cane blocks directly below; nothing happens when `h` is 3 or more. Otherwise: age 15 places a
   default sugar cane above and sets this block's age to 0; age below 15 sets age + 1 (flag value 260).
3. Tint: `sugar_cane` uses the grass colour (24 part 1 section 9.3).

### 7.11 Jukebox, fence, soul sand and nether portal (fields 272 to 275, 284)

| Block | States | Default | Rules |
|---|---|---|---|
| `jukebox` (`JukeboxBlock`) | `has_record` (2) | false | use with a record item inserts it (`JukeboxPlayable.tryInsertIntoJukebox`); use with the hand empty and a record present pops it out; on removal, contents drop; `setPlacedBy` sets `has_record` true when the item carries block entity data with a record; own signal 15 while playing, analog comparator output from the block entity; ticks only while `has_record` |
| `oak_fence` (`FenceBlock`) | `east`, `north`, `south`, `waterlogged`, `west` (32) | all false | shapes: 5.3; connection state and placement `FenceBlock.getStateForPlacement`/`updateShape` set a side when the neighbour is the same fence kind, a sturdy face, or a fence gate whose connection allows the direction (`isSameFence`, `FenceGateBlock.connectsToDirection`); the exact comparison (wood-only matching, sturdy face test) is in the fence rules of 24 part 5 and 6 |
| `soul_sand` | none | - | collision 14 high, outline and support shape full; speed factor 0.4; post-process above; tags `soul_speed_blocks`, `supports_nether_wart`, `enables_bubble_column_push_up`, `wither_summon_base_blocks` |
| `nether_portal` (`NetherPortalBlock`) | `axis` (x, z) | x | outline 5.2; `updateShape` returns air when a neighbour along a different axis than the portal's own axis changed and the portal shape (`PortalShape.findAnyShape`) is no longer complete, unless the neighbour is a portal block; random tick may spawn a zombified piglin: only when monsters spawn, difficulty is not peaceful, the dimension attribute `nether_portal_spawns_piglins` is true, and `nextInt(2000)` is below the difficulty id, a player is close enough for spawning, and the block below is valid for spawning; entities inside start the portal transition (entity must be able to use portals); transition time for players is the game-rule delay (default or creative); clone item is empty |

### 7.12 Carved pumpkin, jack o'lantern and cake (fields 285 to 287)

| Block | States | Default | Rules |
|---|---|---|---|
| `carved_pumpkin`, `jack_o_lantern` (`CarvedPumpkinBlock`) | `facing` (4) | north | `onPlace` (not when replacing the same block) tries to spawn a golem; `canSpawnGolem` is true when a base pattern matches; tag `sword_efficient` |
| `cake` (`CakeBlock`) | `bites` 0 to 6 (7) | 0 | survival: the block below is `isSolid()` (`updateShape` returns air when it fails from below); eating (empty main hand or any item that does not place a candle): requires the player to be able to eat (`canEat(false)`), awards the eat stat, restores food by 2 with saturation modifier 0.1, game event `EAT`; `bites` below 6 gives `bites + 1`, else the cake is removed (`BLOCK_DESTROY`); a candle item used on an uneaten cake (`bites` 0) turns it into the candle cake of that candle; analog output (comparator) `(7 - bites) * 2`, so 14, 12, 10, 8, 6, 4, 2 for 0 to 6 bites; no loot table drops (empty table) |

Golem patterns (`BlockPattern`, rows listed top to bottom, one aisle; each row is a string of columns left to right; `^` carved pumpkin or jack o'lantern
(`PUMPKINS_PREDICATE`), `#` the body block, `~` air (`isAir`), a blank is any block):

| Golem | Base pattern (checked by `canSpawnGolem`) | Full pattern (spawns) | Body block | Spawn position (pattern coordinates x, y, z) | Spawned |
|---|---|---|---|---|---|
| snow | rows ` `, `#`, `#` | `^`, `#`, `#` | `snow_block` | (0, 2, 0): the lowest body block | snow golem |
| iron | `~ ~`, `###`, `~#~` | `~^~`, `###`, `~#~` | `iron_block` | (1, 2, 0): the lowest centre body block | iron golem with `playerCreated` true |
| copper | ` `, `#` | `^`, `#` | any block in tag `copper` | (0, 0, 0): the top of the pattern, the pumpkin cell | copper golem; the body block is replaced by a copper chest of the same weathering (`CopperChestBlock.getFromCopperBlock`), the golem's weather state from the body block's age (a waxed block uses its unwaxed counterpart; unknown gives the unaffected state) |

`spawnGolemInWorld` clears the pattern blocks (`clearPatternBlocks`), places the entity at the spawn cell centre in x and z, 0.05 above the cell's floor, with zero rotation,
adds it, and triggers the advancement for server players within 5 blocks of the golem's bounding box. The search that tries the pattern in the four horizontal
orientations (`BlockPattern.find`) was not read (Open question 10).

### 7.13 Infested blocks, mushroom blocks and plain blocks (fields 276 to 314)

| Block | States | Default | Rules |
|---|---|---|---|
| `infested_*` (`InfestedBlock`, host block in the constructor) | none | - | `destroyTime = host default destroy time / 2`; resistance 0.75; after breaking, when the game rule `block_drops` is true and the tool does not carry an enchantment of tag `prevents_infested_spawns`, a silverfish is created (spawn reason `triggered`) at the block centre in x and z (`x + 0.5`, `y`, `z + 0.5`), with zero rotation, and its spawn animation plays. The class keeps maps from host to infested block and from host states to infested states (copying state properties) |
| `brown_mushroom_block`, `red_mushroom_block` (`HugeMushroomBlock`) | `down`, `east`, `north`, `south`, `up`, `west` (booleans, 64) | all true (first state) | placement: each face property is true when the neighbour in that direction is **not** the same block, else false; `updateShape` for a neighbour of the same block sets that face false, else keeps the state; rotate and mirror permute the faces |
| `snow_block`, `clay`, `netherrack`, `soul_soil`, `glowstone`, stone brick family, `packed_mud`, `mud_bricks` (`Block`, `NetherrackBlock`) | none | - | no behaviour beyond the properties; `basalt` and `polished_basalt` are `RotatedPillarBlock` with `axis` (x, y, z; default y) |
| `repeater`, `stained glass` | see 7.9; stained glass `TransparentBlock` (propagates skylight, `getShadeBrightness` 1.0, `skipRendering` for adjacent glass) | - | - |

## 8. Worked examples

State id = first state id + sum of (value index x weight), with properties sorted by name (04 section 5.2), values in the order of section 4.

1. **Ids.** `spruce_trapdoor` is field 291, block id 291 + 75 = 366 (the glass collection sits between). `oak_wall_sign` is field 209, block id 269.
   `black_stained_glass` is block 364 and state 8783; `oak_trapdoor` is field 290, block 365. `red_mushroom_block` is block 389.
2. **`spruce_trapdoor`** (first state 8848). Sorted: `facing` (4), `half` (2), `open` (2), `powered` (2), `waterlogged` (2), weights 16, 8, 4, 2, 1. State facing east
   (index 3), half bottom (1), open false (1), powered false (1), waterlogged false (1): 3 x 16 + 8 + 4 + 2 + 1 = 63, id 8911 (the block's last state). Default (north, bottom,
   closed, unpowered, dry): 0 + 8 + 4 + 2 + 1 = 15, id 8863.
3. **`oak_wall_sign`** first 7415: facing north, dry = 0 x 2 + 1 = 1 gives 7416; `spruce_wall_sign` default 7424; `bamboo_wall_sign` (first 7495) facing west (index 2), dry = 2 x 2 + 1 = 5,
   id 7500.
4. **`lever`** first 8439: `face` wall (1) x 8, facing north (0) x 2, powered false (1): 9, default 8448. A lever on the floor facing east powered true: face floor 0, facing east 3 x 2 = 6, powered true 0: 6, id 8445.
5. **`repeater`** first 8704: sorted `delay`, `facing`, `locked`, `powered`; weights 16, 4, 2, 1. Delay 4 (index 3), facing south (1), locked true (0), powered true (0): 48 + 4 = 52, id 8756; default (delay 1, north,
   unlocked, unpowered) = 0 + 0 + 2 + 1 = 3, id 8707.
6. **`oak_hanging_sign`** first 7503: `attached` (2, weight 32), `rotation` (16, weight 2), `waterlogged` (2, weight 1). Default rotation 8, attached false, dry: 32 + 16 + 1 = 49, id 7552. rotation 0, attached true,
   waterlogged true: 0, id 7503.
7. **`oak_fence`** first 8635: sorted `east`, `north`, `south`, `waterlogged`, `west`; weights 16, 8, 4, 2, 1; connected to north only, dry: east false 16 + north true 0 + south false 4 + waterlogged false 2 +
   west false 1 = 23, id 8658.
8. **`iron_door`** first 8465: sorted `facing` (16), `half` (upper 0, lower 1; weight 8), `hinge` (left 0, right 1; weight 4), `open` (weight 2), `powered` (weight 1). Default: north 0, lower 8, left 0, closed 2,
   unpowered 1 = 11, id 8476. The upper half of the same door facing east, hinge right, open, powered: 3 x 16 + 0 + 4 + 0 + 0 = 52, id 8517.
9. **`cobblestone_stairs`** first 7335: default (north, bottom, straight, dry) = 0 + 10 + 0 + 1 = 11, id 7346 (weights `facing` 20, `half` 10, `shape` 2, `waterlogged` 1).
10. **Door hinge.** A player facing north places a door; the west neighbours (left, `ccw(north)` is west) at the lower and upper level are full stone, the east side is open air. `s` = -2, no door beside: step 3 fails, step 4 gives
    hinge left. With stone on both sides `s` = 0, no doors: the click offset decides: `d` is north, so `(sx, sz)` = (0, -1) and the hinge is right when `dx` > 0.5.
11. **Cake signal.** `bites` 3: (7 - 3) x 2 = 8. A fresh cake gives 14; the last slice (6 bites) gives 2.
12. **Infested hardness.** `infested_stone`: stone has hardness 1.5, so 0.75; `infested_cobblestone`: cobblestone has hardness 2.0, so 1.0; each has resistance 0.75.
13. **Cactus growth.** A column of height 2 (the top cactus age 15, air above, `h` = 2): a random tick on the top places a default cactus above and sets the old top's age to 0; a column of height 3 with the top at age 15:
    `h` reaches 3 with age 15, so nothing happens. At age 8 with `h` = 3 the flower chance is 0.25 (0.1 for `h` below 3), then the age becomes 9.
14. **Snow placement.** Using the snow item on a 3-layer snow block when the placement replaces the clicked block: if the clicked face is UP the block is replaceable and `getStateForPlacement` yields `layers` 4 (`min(8, 3 + 1)`); a
    side click makes `canBeReplaced` false, so the item is placed in the neighbouring cell as layer 1 (or on a block there per that cell's rules).
15. **Redstone torch burnout.** A torch toggled eight times at one position within a 60-game-tick window: the next evaluation plays level event 1502 and re-checks 160 ticks later instead of re-lighting.
16. **Shapes.** `ladder` facing east is `box(0,0,0,3,16,16)`; `oak_wall_hanging_sign` facing north collision `box(0,14,6,16,16,10)`; a closed trapdoor, top half: `box(0,13,0,16,16,16)`.

## 9. Validation

Checks performed in this fix pass, against the jar only:

| Check | Result |
|---|---|
| Field count | the `Blocks` entries from `spruce_wall_sign` to `red_mushroom_block` number 105 (fields 210 to 314); 109 with the four boundary blocks (206 to 209); the glass field registers 16 blocks, so the range holds 124 blocks |
| Block id rule | field + 60 up to field 288, ids 349 to 364 for field 289, field + 75 from field 290 (`oak_trapdoor` 365, `red_mushroom_block` 389) |
| State totals | the state counts of section 2 sum to 2 321 states from field 206 to field 314 (first state 7307 to the end 9627); the next block (field 315) starts at 9628, which is the first state of `mushroom_stem` in 24 part 8; the 105 blocks of the scope start at 7423 and span 2 205 states |
| State counts | each count is the product of the value counts of the properties in the class's `createBlockStateDefinition` (walking superclasses) |
| Blockstate files | variant counts of `lever` 24, `stone_button` 24, `repeater` 64, `stone_pressure_plate` 2, `snow` 8, `cake` 7, `redstone_wall_torch` 8 agree with the state counts; `oak_trapdoor` 16 = 64 / 4 (`powered`, `waterlogged` omitted by the file), `oak_wall_sign` 4 = 8 / 2, `iron_door` 32 = 64 / 2; `oak_fence` uses 5 multipart entries |
| Properties | every row of section 3 was compared with the `Blocks` entry; sound types of classes with their own sound (section 3) were taken from the class constructors and the `WoodType` / `BlockSetType` tables |
| Constants cross-checked | fence post width 4 appears in the constructor call and in `makeShapes`; wall-sign `boxZ` converts to the same plank dimensions as the hanging-sign plank; button cut shapes (`cube(12)`, `cube(14)`) leave 2 and 1 sixteenths; button model boxes agree with the outline cut |

Checkpoints an implementation can test: (a) the id formula on examples 1 to 9 of section 8; (b) base 7423 against part 2 (`spruce_wall_sign`, block 270); (c) all 105 keys of section 2 parse and are unique; (d) trapdoor
shape selection for the four (open, half) cases of 5.2; (e) the cactus flower chance 0.1 below height 3 and 0.25 at height 3 or more at age 8; (f) the redstone torch: default state lit, first state of its block 8555.

## 10. Open questions

1. **Part 1 and part 2 consistency (closed).** The first draft summed the states without the 9 leaf blocks (28 states each) and gave `spruce_wall_sign` 7171. 24 part 2 section 1.2 resolves `B105` = 575 and states 7307 for `ladder`, 7415 for `oak_wall_sign`, 7423 for `spruce_wall_sign`; 24 part 8 gives `mushroom_stem` 9628, which equals this part's end 9627 plus one. Every id of sections 2, 8 and 9 was re-based by +252 and agrees with both siblings. Nothing remains open; a sibling that still shows the old numbers is wrong.
2. **Map colours and sound types.** The numeric `MapColor` table and the `SoundType` tables (volume, pitch, five events per type) are not in this part; names only are given. Part 1 section 8 owns the enumerations.
3. **`deepslate_redstone_ore` and `packed_mud`** copy properties from `redstone_ore` and `dirt` (`ofLegacyCopy`); the `dirt` side belongs to part 1.
4. **Ceiling hanging sign placement (closed).** The full rule is in steps 1 to 5 of 7.4 and was read from the method's bytecode; nothing is inferred.
5. **Rail connection and shape updates** (`RailState`, `BaseRailBlock.updateDir`, `shouldBeRemoved`) were not read beyond the entry points of 7.2.
6. **Wall hanging sign support.** `canSurvive` is not overridden (true); whether any other path removes an unsupported wall hanging sign than `updateShape` after `canPlace` was not found.
7. **Segment numbering (resolved).** `convertToDirection` maps 0, 4, 8, 12 to north, east, south, west while `convertToSegment(Direction)` gives south 0, west 4, north 8, east 12, 0 for vertical directions. Ceiling hanging sign placement always passes the opposite of the player's facing, and the yaw branch adds 180 degrees, so both branches give the same segment (worked check in 7.4); no compensation is missing. Not resolved: why `convertToDirection` names segment 0 north (a naming of the sign's plane, not used by any rule here).
8. **Block entities and text.** `SignBlockEntity`, `HangingSignBlockEntity`, `JukeboxBlockEntity`, sign editing, wax and click commands belong to the block entity documents.
9. **Tick priority values.** The priorities `EXTREMELY_HIGH`, `VERY_HIGH` and `HIGH` used by the repeater (7.9) and the torch are named only; their numeric order and effect on scheduled ticks belong to the tick scheduler (33 section 2).
10. **Golem pattern search.** `BlockPattern.find` (how the pattern is matched in the four orientations and which block of a match is the origin) was not read; the pattern strings and predicates are in 7.12.
11. **Redstone engine.** Signal propagation (`ExperimentalRedstoneUtils` orientations, `getControlInputSignal`, quasi-connectivity) belongs to the redstone document; only each class's own signals are listed.
12. **Rail and door pathfinding flags.** `isPathfindable` results for doors and trapdoors by `PathComputationType` were read from compiler switch tables whose index order was not decoded; the case-to-result mapping is by the order of the tableswitch targets (inferred).
13. **Rotation constants.** Read: `BLOCK_ROT_Y_90` is `ROT_90_Y_NEG` (swap x and z, then negate x), so (x, z) goes to (1 - z, x) in block units; `BLOCK_ROT_X_270` is `ROT_90_X_POS` (swap y and z, then negate y), which maps the wall lever's box `box(5,4,10,11,12,16)` to the floor box `box(5,0,4,11,6,12)`, and `BLOCK_ROT_X_90` is `ROT_90_X_NEG`; the model's x 180 turn for ceiling agrees with the ceiling box `box(5,10,4,11,16,12)`. Not decoded: the Cayley table behind `OctahedralGroup.compose`, i.e. the operand order in the ceiling composition (`BLOCK_ROT_Y_180` with `BLOCK_ROT_X_90`); the ceiling box is therefore confirmed by the blockstate model turn and by symmetry (the box is symmetric in x and z about the block centre) rather than by the composed table.
14. **Block-light and `water_evaporates`.** The environment attribute `water_evaporates` (ice) and `nether_portal_spawns_piglins` are data of the dimension types; their per-dimension values belong to the dimension document.
15. **Plate sensitivity and set-type switch indices (searched again, still open).** The class constants of the plate's switch were re-read; the compiler's switch-map index order was not decoded. The pairing of `EVERYTHING` and `MOBS` with `Entity` and `LivingEntity` was inferred from the switch's class constants; the same applies to the case order of `isPathfindable` switches.
16. **Tags.** Section 3.3 lists tag membership read from the jar's tag files (883 files under `data/minecraft/tags`); tags that merely include other tags were expanded. The set of block tags that code reads by name is in part 1 section 12.
17. **Loot tables.** Section 3.3 gives the category of each table (silk touch, self, none); the full tables and conditions belong to the loot document.
18. **Fence and fence-gate connection rule** (`FenceBlock.connectsTo`, `isSameFence`, `FenceGateBlock.connectsToDirection`) is stated at the level of 7.11 only.
