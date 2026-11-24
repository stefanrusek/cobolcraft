# Block registry, part 9: `BlockState.rotate` and `BlockState.mirror` for every block

| Item | Value |
|---|---|
| Covers | The two block-state transforms that structure templates, and any other caller, apply to a block state: `BlockState.rotate(Rotation)` and `BlockState.mirror(Mirror)`. The `Rotation` and `Mirror` enumerations and how a mirror becomes a rotation of a direction; the per-property-family rules (`facing` with four, five and six values, `axis`, the 16-step `rotation`, the four boolean sides of fences, panes, bars, vines and tripwire, the `none`/`low`/`tall` wall sides, the `none`/`side`/`up` redstone sides, the six-face booleans of multiface blocks and huge mushrooms, stairs `shape`, rail `shape`, door `hinge`, the 12-value `orientation` of crafters and jigsaw blocks); a table that assigns each of the 1286 registered blocks to its rule (the 587 blocks that change under rotation, 511 of which also change under mirror), the explicit statement that the other 699 blocks are returned unchanged, and worked examples. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas and method references), with no execution. Read in full: `Rotation`, `Mirror`, `Direction` (`getClockWise`, `getCounterClockWise`, the constants), `OctahedralGroup`, `SymmetricGroup3`, `FrontAndTop`, `SegmentedAnglePrecision`, `RotationSegment`, `BlockBehaviour` and `BlockBehaviour$BlockStateBase` (`rotate`, `mirror`), `BlockStateProperties` (the properties used here), `RailShape`, `StairsShape`, `WallSide`, `RedstoneSide`, `DoorHingeSide`, `ChestType`, `AttachFace`, `BellAttachType`, and every method named `rotate` or `mirror` with a `BlockState` parameter in the 65 block classes that declare one (listed in section 4; the 66th declaring class is the identity default in `BlockBehaviour`), with their `$1` switch-map companions. The registration class of each of the 1286 blocks was read from the constructor references and lambda bodies in the `Blocks` static initialiser and from the collection factories (`ColorCollection`, `WeatheringCopperCollection`). The client resource files `assets/minecraft/blockstates/*.json` were used only to cross-check block keys and the value sets of `facing`. |
| Status | Reviewed (clean-room round 2). Reader round for the open question 3 of 36-2 section 13 (`BlockState.rotate` and `BlockState.mirror` per block). |
| Shared rules | Block ids, property definitions and state numbering are in 24-block-registry-1 to 8 (cited "24-block-registry-N §M"); this part does not repeat them. Structure templates apply a mirror first and then a rotation to each block state: [36-structures-2-templates-and-processors.md](36-structures-2-templates-and-processors.md) section 5.3 step 3 (the processed state is `mirror` then `rotate`). |

Class, method and field names in backticks say where a fact was read. They are not the design. "36-2 §3" means section 3 of
[36-structures-2-templates-and-processors.md](36-structures-2-templates-and-processors.md). Values not read are marked "(inferred)" and listed in the
Open questions (section 8).

## Contents

1. Scope and dispatch
2. The enumerations and the direction primitives
3. The per-property rules
4. Which block uses which rule
5. Properties that no transform touches
6. Worked examples
7. Validation
8. Open questions
Appendix A. Every block that changes, by rule family

---

## 1. Scope and dispatch

`BlockState.rotate(rotation)` returns the state `Block.rotate(state, rotation)` of its block returns, and `BlockState.mirror(mirror)` returns
`Block.mirror(state, mirror)` (`BlockBehaviour$BlockStateBase`). The base implementation of both in `BlockBehaviour` returns the state it was given. A block
class overrides one or both; 65 classes under `net.minecraft.world.level.block` do (section 4.1). No class outside that package declares either method (the only
other classes that mention the two descriptors are the callers `StructurePiece`, `DesertPyramidPiece`, `NetherFossilPieces$NetherFossilPiece` and `StructureTemplate`).

Rules that hold for every block:

* A transform changes only the properties named in the rule. Every other property keeps its value (for example `waterlogged`, `powered`, `half`, `open`, `type`). The result is always a state of the same block.
* `Rotation.NONE` and `Mirror.NONE` are the identity for every block. (The doors' mirror tests `Mirror.NONE` explicitly; the other rules fall out of a rotation by `NONE`.)
* A block that does not override a method is unchanged by it: 699 of the 1286 blocks are unchanged by both methods (section 4.2).
* The transforms are pure functions of the state and the enumeration value; they read no neighbour, no position and no block entity.
* Rotation and mirror values are applied in the order the caller chooses. Structure templates apply `mirror` and then `rotate` (36-2 §5.3 step 3); the examples of section 6 show both orders where it matters.

---

## 2. The enumerations and the direction primitives

### 2.1 `Rotation`

| Ordinal | Constant | Serialized name | Quarter turns clockwise (viewed from above) | `OctahedralGroup` held |
|---|---|---|---|---|
| 0 | `NONE` | `none` | 0 | `IDENTITY` |
| 1 | `CLOCKWISE_90` | `clockwise_90` | 1 | `ROT_90_Y_NEG` |
| 2 | `CLOCKWISE_180` | `180` | 2 | `ROT_180_FACE_XZ` |
| 3 | `COUNTERCLOCKWISE_90` | `counterclockwise_90` | 3 | `ROT_90_Y_POS` |

`Rotation.getRotated(other)` adds the quarter turns modulo 4 (`CLOCKWISE_90` + `CLOCKWISE_90` = `CLOCKWISE_180`; `CLOCKWISE_90` + `COUNTERCLOCKWISE_90` = `NONE`;
`NONE` is the identity). In the tables below "cw90", "cw180" and "ccw90" abbreviate the three non-trivial rotations.

### 2.2 `Mirror`

| Ordinal | Constant | Serialized name | `OctahedralGroup` held | Axis whose coordinate is negated |
|---|---|---|---|---|
| 0 | `NONE` | `none` | `IDENTITY` | none |
| 1 | `LEFT_RIGHT` | `left_right` | `INVERT_Z` | Z (north and south swap) |
| 2 | `FRONT_BACK` | `front_back` | `INVERT_X` | X (east and west swap) |

In 36-2 §3.1 the same mirror replaces `z` by `-z` (`LEFT_RIGHT`) or `x` by `-x` (`FRONT_BACK`) in block positions; the property rules below are the matching
change of the properties. `LEFT_RIGHT` and `FRONT_BACK` are not the same as "mirror about the north-south" or the like; use the axis column.

### 2.3 `Direction`

Constants and ordinals: `DOWN` 0, `UP` 1, `NORTH` 2, `SOUTH` 3, `WEST` 4, `EAST` 5 (the 3D data value equals the ordinal). The 2D data value (horizontal
only) is `SOUTH` 0, `WEST` 1, `NORTH` 2, `EAST` 3. Clockwise viewed from above is `NORTH` to `EAST` to `SOUTH` to `WEST` to `NORTH`
(`Direction.getClockWise()`); `getCounterClockWise()` is the inverse (`NORTH` to `WEST` to `SOUTH` to `EAST` to `NORTH`). `getOpposite()` pairs `DOWN`/`UP`, `NORTH`/`SOUTH`, `WEST`/`EAST`.

`Rotation.rotate(direction)`: a direction on the Y axis (`UP`, `DOWN`) is returned unchanged for every rotation; a horizontal direction moves as in this table:

| Rotation | `north` becomes | `east` becomes | `south` becomes | `west` becomes | `up`, `down` |
|---|---|---|---|---|---|
| `NONE` | north | east | south | west | unchanged |
| `CLOCKWISE_90` | east | south | west | north | unchanged |
| `CLOCKWISE_180` | south | west | north | east | unchanged |
| `COUNTERCLOCKWISE_90` | west | north | east | south | unchanged |

`Mirror.mirror(direction)`: `LEFT_RIGHT` swaps `north` and `south` and leaves every other direction; `FRONT_BACK` swaps `east` and `west` and leaves every other direction;
`NONE` leaves all.

`Mirror.getRotation(direction)`: `CLOCKWISE_180` when the mirror is `LEFT_RIGHT` and the direction is on the Z axis, or the mirror is `FRONT_BACK` and the direction is on the X axis;
`NONE` in every other case (including every `UP`, `DOWN` and every `NONE` mirror). Rotating a direction by `Mirror.getRotation(d)` gives `Mirror.mirror(d)`; the blocks that use one form and the blocks that use the other
form therefore agree, and this document writes both as "mirror the direction".

### 2.4 The two integer helpers (16-step rotations)

For a rotation value `i` in `0..n-1` with `n = 16`:

* `Rotation.rotate(i, n)`: `NONE` gives `i`; `CLOCKWISE_90` gives `(i + n/4) mod n` = `(i + 4) mod 16`; `CLOCKWISE_180` gives `(i + n/2) mod n` = `(i + 8) mod 16`; `COUNTERCLOCKWISE_90` gives `(i + 3n/4) mod n` = `(i + 12) mod 16`.
* `Mirror.mirror(i, n)`: `NONE` gives `i`; `LEFT_RIGHT` gives `(8 - i) mod 16`; `FRONT_BACK` gives `(16 - i) mod 16` = `(-i) mod 16` (closed forms checked for every `i` in `0..15` against the artifact's integer method).

The `rotation` property of signs, banners and skulls is read by `RotationSegment.convertToSegment(direction)` as `get2DDataValue << 2` for a horizontal direction (and 0 for `UP` or `DOWN`, `SegmentedAnglePrecision.fromDirection`), so value 0 faces south, 4 west, 8 north and 12 east (values grow
clockwise viewed from above; consistent with `CLOCKWISE_90` adding 4). The constants `NORTH_0`, `EAST_90`, `SOUTH_180`, `WEST_270` declared in `RotationSegment` disagree with that reading; see Open question 6.

### 2.5 The group action on `orientation` (`OctahedralGroup`)

`Rotation.rotation()` and `Mirror.rotation()` give the `OctahedralGroup` of the tables in 2.1 and 2.2. For a direction `d`, `OctahedralGroup.rotate(d)` takes the axis of `d`, replaces it by the axis the inverse
axis permutation sends it to, and flips the sign of the direction when the group inverts that new axis. For the five groups used here the result is: `ROT_90_Y_NEG` is the direction map of `CLOCKWISE_90` of 2.3 (north to east, east to south, south to west, west to north, `UP` and `DOWN` fixed);
`ROT_90_Y_POS` is the map of `COUNTERCLOCKWISE_90`; `ROT_180_FACE_XZ` swaps north/south and east/west; `INVERT_Z` swaps north and south only; `INVERT_X` swaps east and west only; the identity fixes everything.
(These five direction maps were decoded from the `OctahedralGroup` constants and their permutation and inversion flags.)

In every case the group action on a direction is the same map as `Rotation.rotate(direction)` and `Mirror.mirror(direction)` of 2.3. This is used for `FrontAndTop` values (section 3.11). `OctahedralGroup.rotate(FrontAndTop)` applies the direction action to the front and to the top and then looks the pair up (decoded from its bytecode).

---

## 3. The per-property rules

Notation: `R(d)` is `Rotation.rotate(d)` of 2.3, `M(d)` is `Mirror.mirror(d)` of 2.3. "Property moves" means that the value stored in the property named after direction `d` is written into the property named after `R(d)` (or `M(d)`),
and the property values themselves are not changed. Every block named in a rule is listed with its rule family in section 4 and Appendix A.

### 3.1 Family A, B, C: `facing` (four, five or six values)

New `facing` after `rotate` is `R(facing)`; after `mirror` it is `M(facing)`. The two tables of 2.3 are the whole rule. Nothing else changes.

| Property | Values | Blocks |
|---|---|---|
| `facing` (horizontal) | north, east, south, west | family A (213 blocks) |
| `facing` (hopper) | down, north, south, west, east (no `up`) | family C (`hopper`) |
| `facing` (all directions) | north, east, south, west, up, down | family B (41 blocks) |

Notes:

* A vertical value (`up`, `down`) is a fixed point of every rotation and every mirror. Rotation and mirror therefore never produce a value outside the domain: the hopper's `down` stays `down` and its horizontal values stay horizontal.
* Family A2 is the same rule for `rotate` only: the three anvils (`anvil`, `chipped_anvil`, `damaged_anvil`) rotate their `facing` but ignore `mirror` (they use the default of `BlockBehaviour`).
* Blocks of family A that carry a second direction-like property keep it: `face` (`floor`, `wall`, `ceiling`) of levers, buttons and grindstones; `attachment` of bells; `part` of beds; `half` of trapdoors; `type` of chests; `hinge` and `half` of doors are in 3.10.
* `RodBlock` (end rod, lightning rods) and `HugeMushroomBlock` (3.6) call `Mirror.mirror(direction)` directly; every other family A, B, C class calls `Mirror.getRotation(facing)` and then rotates; the results are equal (2.3).

### 3.2 Family D, D2: `axis`

For `rotate` only (no block of this family overrides `mirror`): when the rotation is `CLOCKWISE_90` or `COUNTERCLOCKWISE_90`, the value `x` becomes `z` and the value `z` becomes `x`; `y` is unchanged. `NONE` and `CLOCKWISE_180` leave
the state unchanged. `mirror` returns the state unchanged. (`RotatedPillarBlock.rotatePillar` and `NetherPortalBlock.rotate`; the portal's `axis` has only `x` and `z`.)

| Rotation | `x` | `y` | `z` |
|---|---|---|---|
| `NONE`, `CLOCKWISE_180` | x | y | z |
| `CLOCKWISE_90`, `COUNTERCLOCKWISE_90` | z | y | x |

### 3.3 Family E: the 16-step `rotation`

Property `rotation`, values `0..15` (`BlockStateProperties.ROTATION_16`, mask of a 4-bit `SegmentedAnglePrecision`). The new value is `Rotation.rotate(rotation, 16)` after a rotation and `Mirror.mirror(rotation, 16)` after a mirror (2.4): add 4, 8 or 12 for the three rotations;
`LEFT_RIGHT` gives `(8 - i) mod 16`, `FRONT_BACK` gives `(16 - i) mod 16`. Standing signs, ceiling hanging signs, banners and skulls (including the wither skeleton skull and the player head) use this rule; their `waterlogged`, `attached` and `powered` properties are unchanged. The wall variants of these blocks use `facing` (family A).

Full table (the new value of the state whose `rotation` is the first column):

| rotation | cw90 | cw180 | ccw90 | left_right | front_back |
|---|---|---|---|---|---|
| 0 | 4 | 8 | 12 | 8 | 0 |
| 1 | 5 | 9 | 13 | 7 | 15 |
| 2 | 6 | 10 | 14 | 6 | 14 |
| 3 | 7 | 11 | 15 | 5 | 13 |
| 4 | 8 | 12 | 0 | 4 | 12 |
| 5 | 9 | 13 | 1 | 3 | 11 |
| 6 | 10 | 14 | 2 | 2 | 10 |
| 7 | 11 | 15 | 3 | 1 | 9 |
| 8 | 12 | 0 | 4 | 0 | 8 |
| 9 | 13 | 1 | 5 | 15 | 7 |
| 10 | 14 | 2 | 6 | 14 | 6 |
| 11 | 15 | 3 | 7 | 13 | 5 |
| 12 | 0 | 4 | 8 | 12 | 4 |
| 13 | 1 | 5 | 9 | 11 | 3 |
| 14 | 2 | 6 | 10 | 10 | 2 |
| 15 | 3 | 7 | 11 | 9 | 1 |

### 3.4 Family F: four boolean sides

Properties `north`, `east`, `south`, `west`, each boolean. On `rotate` the properties move: the new value of the property named `R(d)` is the old value of the property named `d`. In the form "new from old":

| Rotation | new `north` from | new `east` from | new `south` from | new `west` from |
|---|---|---|---|---|
| `CLOCKWISE_90` | old `west` | old `north` | old `east` | old `south` |
| `CLOCKWISE_180` | old `south` | old `west` | old `north` | old `east` |
| `COUNTERCLOCKWISE_90` | old `east` | old `south` | old `west` | old `north` |

On `mirror`: `LEFT_RIGHT` exchanges the values of `north` and `south` and keeps `east` and `west`; `FRONT_BACK` exchanges `east` and `west` and keeps `north` and `south`. Other properties are unchanged: `waterlogged` (fences, bars, panes), `up` (vines), `attached`, `disarmed`, `powered` (tripwire).
Blocks: fences (including `nether_brick_fence`), `iron_bars`, the eight copper bars, `glass_pane`, the 16 stained glass panes (class `CrossCollisionBlock`), `vine` (class `VineBlock`) and `tripwire` (class `TripWireBlock`): 42 blocks. The tripwire hook is family A.

### 3.5 Family G and H: the typed sides (walls, moss carpet, redstone wire)

The four side properties are moved exactly as in 3.4 (same tables), but the property values are enumerations and travel with the property unchanged:

| Block | Side properties | Side values | Properties that stay put |
|---|---|---|---|
| walls (32 blocks, `WallBlock`) | `north`, `east`, `south`, `west` | `none`, `low`, `tall` (`WallSide`) | `up` (boolean), `waterlogged` |
| `pale_moss_carpet` (`MossyCarpetBlock`) | `north`, `east`, `south`, `west` | `none`, `low`, `tall` (`WallSide`) | `base` (boolean) |
| `redstone_wire` (`RedstoneWireBlock`) | `north`, `east`, `south`, `west` | `up`, `side`, `none` (`RedstoneSide`) | `power` |

The word `up` of the redstone value is a side value, not a direction: it is moved with its property and never changed into another value.

### 3.6 Family I: the six boolean faces of huge mushrooms

`brown_mushroom_block`, `red_mushroom_block` and `mushroom_stem` have six boolean properties `north`, `east`, `south`, `west`, `up`, `down`. `rotate`: the value of the property of direction `d` moves to the property of `R(d)` for the four horizontal directions; `up` and `down` stay. `mirror`: the value of property `d` moves to the property of `M(d)`:
`LEFT_RIGHT` exchanges `north` and `south`, `FRONT_BACK` exchanges `east` and `west`. (Same tables as 3.4 for the horizontal four.)

### 3.7 Family J: multiface blocks

`glow_lichen`, `sculk_vein` and `resin_clump` (class `MultifaceBlock` and its subclass `MultifaceSpreadeableBlock`) have the six booleans `north`, `east`, `south`, `west`, `up`, `down` and `waterlogged`. The value of the property of face `d` moves to the property of `R(d)` (rotate) or `M(d)` (mirror) for every face that is a property of the block; `up` and `down` stay,
`waterlogged` stays. For these three blocks every rotation and both mirrors apply (the class guards against faces that are not properties; all six are always properties, so no transform is skipped).

### 3.8 Family K: stairs

Property `facing` (four values) and `shape` (`straight`, `inner_left`, `inner_right`, `outer_left`, `outer_right`).

* `rotate`: `facing` becomes `R(facing)`; `shape` is unchanged for every rotation.
* `mirror`, `LEFT_RIGHT`: applies only when `facing` is `north` or `south`; otherwise the state is unchanged. When it applies, `facing` is rotated by 180 degrees (north to south or south to north) and `shape` changes as in the first table below.
* `mirror`, `FRONT_BACK`: applies only when `facing` is `east` or `west`; otherwise the state is unchanged. When it applies, `facing` is rotated by 180 degrees (east to west or west to east) and `shape` changes as in the second table below.
* `mirror`, `NONE`: unchanged.

| Old `shape` | New `shape` under `LEFT_RIGHT` (facing north or south) | New `shape` under `FRONT_BACK` (facing east or west) |
|---|---|---|
| `straight` | straight | straight |
| `inner_left` | `inner_right` | `inner_left` |
| `inner_right` | `inner_left` | `inner_right` |
| `outer_left` | `outer_right` | `outer_right` |
| `outer_right` | `outer_left` | `outer_left` |

The inner shapes are exchanged under `LEFT_RIGHT` but kept under `FRONT_BACK`. This asymmetry is what the bytecode does (the inner cases of the `FRONT_BACK` branch set the same shape that was read; the outer cases swap); see Open question 4. `half` and `waterlogged` are unchanged.

### 3.9 Family L: rails

Property `shape`; ten values for `rail`, six values (`north_south`, `east_west` and the four `ascending_*`; the corner shapes are excluded by the property's filter) for `powered_rail`, `activator_rail` and `detector_rail`. The same two functions (`BaseRailBlock.rotate(shape, rotation)` and `mirror(shape, mirror)`) serve all four blocks. Other properties (`powered`, `waterlogged`) are unchanged.
The tables below are the complete rules; for a shape the result is the shape obtained by transforming each end direction, where `ascending_X` has its high side toward `X` and its low side toward the opposite direction (the tables were checked against that description for all ten shapes and all five transforms).

| shape | cw90 | cw180 | ccw90 | left_right | front_back |
|---|---|---|---|---|---|
| `north_south` | `east_west` | `north_south` | `east_west` | `north_south` | `north_south` |
| `east_west` | `north_south` | `east_west` | `north_south` | `east_west` | `east_west` |
| `ascending_east` | `ascending_south` | `ascending_west` | `ascending_north` | `ascending_east` | `ascending_west` |
| `ascending_west` | `ascending_north` | `ascending_east` | `ascending_south` | `ascending_west` | `ascending_east` |
| `ascending_north` | `ascending_east` | `ascending_south` | `ascending_west` | `ascending_south` | `ascending_north` |
| `ascending_south` | `ascending_west` | `ascending_north` | `ascending_east` | `ascending_north` | `ascending_south` |
| `south_east` | `south_west` | `north_west` | `north_east` | `north_east` | `south_west` |
| `south_west` | `north_west` | `north_east` | `south_east` | `north_west` | `south_east` |
| `north_west` | `north_east` | `south_east` | `south_west` | `south_west` | `north_east` |
| `north_east` | `south_east` | `south_west` | `north_west` | `south_east` | `north_west` |

`NONE` rotation and `NONE` mirror return the shape unchanged. Under `LEFT_RIGHT` the shapes `north_south`, `east_west`, `ascending_east` and `ascending_west` are unchanged (their ends lie on the X axis or are symmetric about it); under `FRONT_BACK` the shapes `north_south`, `east_west`, `ascending_north` and `ascending_south` are unchanged.

### 3.10 Family M: doors

Property `facing` (four values), `hinge` (`left`, `right`), `half`, `open`, `powered`.

* `rotate`: `facing` becomes `R(facing)`; `hinge` is unchanged.
* `mirror`, `NONE`: unchanged.
* `mirror`, `LEFT_RIGHT` or `FRONT_BACK`: `facing` is rotated by `Mirror.getRotation(facing)` (so it flips only when `facing` is on the mirrored axis), and `hinge` always toggles (`left` to `right`, `right` to `left`), whether or not `facing` changed.

Applies to the 14 wooden and iron doors and the eight copper doors (22 blocks). Trapdoors, fence gates and buttons have no `hinge` and are plain family A.

### 3.11 Family N: `orientation` (crafter, jigsaw block)

The property `orientation` has twelve values (`FrontAndTop`): `down_east`, `down_north`, `down_south`, `down_west`, `up_east`, `up_north`, `up_south`, `up_west`, `west_up`, `east_up`, `north_up`, `south_up`. A value is a pair
(front, top) written `front_top`: the first word is the front direction, the second the top direction (`FrontAndTop.front()`, `.top()`). `rotate` and `mirror` apply the group action of 2.5 to both words of the pair: for a rotation, each horizontal word
moves as in 2.3 and the words `up` and `down` stay; for a mirror, `north`/`south` swap under `LEFT_RIGHT` and `east`/`west` swap under `FRONT_BACK`. The pair is then looked up as a value (`FrontAndTop.fromFrontAndTop(front, top)`); the pairs that can arise
from a valid value are always valid values. Complete table:

| orientation | cw90 | cw180 | ccw90 | left_right | front_back |
|---|---|---|---|---|---|
| `down_east` | `down_south` | `down_west` | `down_north` | `down_east` | `down_west` |
| `down_north` | `down_east` | `down_south` | `down_west` | `down_south` | `down_north` |
| `down_south` | `down_west` | `down_north` | `down_east` | `down_north` | `down_south` |
| `down_west` | `down_north` | `down_east` | `down_south` | `down_west` | `down_east` |
| `up_east` | `up_south` | `up_west` | `up_north` | `up_east` | `up_west` |
| `up_north` | `up_east` | `up_south` | `up_west` | `up_south` | `up_north` |
| `up_south` | `up_west` | `up_north` | `up_east` | `up_north` | `up_south` |
| `up_west` | `up_north` | `up_east` | `up_south` | `up_west` | `up_east` |
| `west_up` | `north_up` | `east_up` | `south_up` | `west_up` | `east_up` |
| `east_up` | `south_up` | `west_up` | `north_up` | `east_up` | `west_up` |
| `north_up` | `east_up` | `south_up` | `west_up` | `south_up` | `north_up` |
| `south_up` | `west_up` | `north_up` | `east_up` | `north_up` | `south_up` |

The other properties of the crafter (`crafting`, `triggered`) are unchanged; the jigsaw has no other property.

---

## 4. Which block uses which rule

### 4.1 The 65 classes that declare `rotate` or `mirror`

The rule provider is the class that supplies the rule; a block's registered class (the class its `Blocks` registration instantiates) inherits it from the nearest ancestor that declares the method. Both methods are declared unless "rotate only" is shown.

| Rule family | Provider classes (`net.minecraft.world.level.block` unless a package is shown) | Property or properties read |
|---|---|---|
| A (facing, four values) | `HorizontalDirectionalBlock` (the base of beds, buttons, levers, trapdoors, fence gates, glazed terracotta, repeater, comparator, cocoa, carved pumpkin, loom, dried ghast, shelf mushroom, dripleaves, and so on), `AbstractFurnaceBlock`, `AttachedStemBlock`, `BaseCoralWallFanBlock`, `BeehiveBlock`, `BellBlock`, `CalibratedSculkSensorBlock`, `CampfireBlock`, `ChestBlock`, `ChiseledBookShelfBlock`, `CopperGolemStatueBlock`, `DecoratedPotBlock`, `EndPortalFrameBlock`, `EnderChestBlock`, `FlowerBedBlock`, `GrindstoneBlock`, `LadderBlock`, `LeafLitterBlock`, `LecternBlock`, `RedstoneWallTorchBlock`, `ShelfBlock`, `SmallDripleafBlock`, `StonecutterBlock`, `TripWireHookBlock`, `VaultBlock`, `WallBannerBlock`, `WallHangingSignBlock`, `WallSignBlock`, `WallSkullBlock`, `WallTorchBlock` | `facing` |
| A2 (facing, rotate only) | `AnvilBlock` | `facing` |
| B (facing, six values) | `BarrelBlock`, `CommandBlock`, `DispenserBlock`, `ShulkerBoxBlock`, `ObserverBlock`, `AmethystClusterBlock`, `RodBlock`, `piston.PistonBaseBlock`, `piston.PistonHeadBlock`, `piston.MovingPistonBlock` | `facing` |
| C (facing, five values) | `HopperBlock` | `facing` |
| D (axis, rotate only) | `RotatedPillarBlock` (also through `rotatePillar`: `CreakingHeartBlock`, `InfestedRotatedPillarBlock`) | `axis` (x, y, z) |
| D2 (axis, rotate only) | `NetherPortalBlock` | `axis` (x, z) |
| E (sixteen steps) | `StandingSignBlock`, `CeilingHangingSignBlock`, `BannerBlock`, `SkullBlock` | `rotation` |
| F (four booleans) | `CrossCollisionBlock`, `VineBlock`, `TripWireBlock` | `north`, `east`, `south`, `west` |
| G (wall sides) | `WallBlock`, `MossyCarpetBlock` | `north`, `east`, `south`, `west` |
| H (redstone sides) | `RedstoneWireBlock` | `north`, `east`, `south`, `west` |
| I (six booleans) | `HugeMushroomBlock` | `north`, `east`, `south`, `west`, `up`, `down` |
| J (multiface) | `MultifaceBlock` | the six face booleans |
| K (stairs) | `StairBlock` | `facing`, `shape` |
| L (rails) | `RailBlock`, `PoweredRailBlock`, `DetectorRailBlock` (rule in `BaseRailBlock`) | `shape` |
| M (doors) | `DoorBlock` | `facing`, `hinge` |
| N (orientation) | `CrafterBlock`, `JigsawBlock` | `orientation` |

The identity default is declared by `BlockBehaviour` itself (the 66th declaring class). Every one of the 65 classes above supplies the rule of at least one registered block.
Classes that declare only `rotate`: `AnvilBlock`, `NetherPortalBlock`, `CreakingHeartBlock`, `InfestedRotatedPillarBlock`, `RotatedPillarBlock` (five classes; the other 61 declare both). `CreakingHeartBlock` has `axis` and rotates it like a log.

### 4.2 Counts

The `Blocks` static initialiser has 911 fields and registers 1286 blocks: 878 fields register one block, 18 fields are 16-colour collections (`ColorCollection`: bed, wool, wool stairs, wool slab, stained glass, dyed terracotta, stained glass pane, carpet, banner, wall banner, dyed shulker box, glazed terracotta, concrete, concrete stairs, concrete slab, concrete powder, dyed candle, dyed candle cake) and 15 fields are weathering collections of 8 blocks each (four weathering states and their four waxed forms: copper bars, copper chain, copper lantern, copper block, cut copper, chiseled copper, cut copper stairs, cut copper slab, copper door, copper trapdoor, copper grate, copper bulb, copper chest, copper golem statue, lightning rod): 878 + 18 x 16 + 15 x 8 = 1286.

| Rule family | Blocks | Changes under rotate | Changes under mirror |
|---|---|---|---|
| A facing, four values | 213 | yes | yes |
| A2 facing, rotate only | 3 | yes | no |
| B facing, six values | 41 | yes | yes |
| C facing, five values | 1 | yes | yes |
| D axis | 72 | yes (90 and 270 only) | no |
| D2 portal axis | 1 | yes (90 and 270 only) | no |
| E sixteen steps | 49 | yes | yes |
| F four booleans | 42 | yes | yes |
| G wall sides | 33 | yes | yes |
| H redstone sides | 1 | yes | yes |
| I six booleans | 3 | yes | yes |
| J multiface | 3 | yes | yes |
| K stairs | 97 | yes (facing only) | yes |
| L rails | 4 | yes | yes |
| M doors | 22 | yes (facing only) | yes |
| N orientation | 2 | yes | yes |
| Total that change under `rotate` | 587 | | |
| Total that change under `mirror` | 511 | | |
| Blocks unchanged by both | 699 | | |

The 76 blocks of families A2, D and D2 are the ones that change under `rotate` and not under `mirror` (587 - 76 = 511). Within a changed family, a particular state can still be a fixed point (for example a `facing` of `up` under every transform, or a `north_south` rail under `CLOCKWISE_180`).

### 4.3 Key patterns

The full list of block keys is in 24-block-registry-1 to 8 (an implementer iterates those keys and consults Appendix A: every key absent from Appendix A is unchanged by both transforms). The explicit key lists are in Appendix A.

| Pattern | Family | Notes |
|---|---|---|
| `<wood>_log`, `<wood>_wood`, `stripped_<wood>_log`, `stripped_<wood>_wood`, `crimson_stem`, `warped_stem`, hyphae, `basalt`, `polished_basalt`, `quartz_pillar`, `purpur_pillar`, `bone_block`, `hay_block`, `deepslate`, the three froglights, `muddy_mangrove_roots`, `bamboo_block`, `iron_chain`, the eight copper chains, `creaking_heart`, `infested_deepslate` | D | the exact set (72) is in Appendix A.5 |
| `<wood>_sign` | E | 13 blocks |
| `<wood>_hanging_sign` | E | 13 blocks |
| `<wood>_wall_sign`, `<wood>_wall_hanging_sign`, `<wood>_shelf` | A | 13 blocks each |
| `<colour>_banner` | E | 16 blocks |
| `<colour>_wall_banner` | A | 16 blocks |
| `skeleton_skull`, `wither_skeleton_skull`, `zombie_head`, `creeper_head`, `dragon_head`, `piglin_head`, `player_head` | E | 7 blocks |
| the seven wall forms of those heads | A | 7 blocks |
| `<wood>_fence`, `nether_brick_fence`, `iron_bars`, `glass_pane`, `<colour>_stained_glass_pane`, copper bars (8) | F | 40 blocks |
| `<wood>_stairs`, `<stone>_stairs`, `<colour>_wool_stairs`, `<colour>_concrete_stairs`, the eight cut copper stairs | K | 97 blocks |
| `*_wall` (32 stone walls) | G | 32 blocks |
| `<wood>_door`, `iron_door`, the eight copper doors | M | 22 blocks |
| `<wood>_trapdoor`, `iron_trapdoor`, the eight copper trapdoors | A | 22 blocks |
| `<wood>_fence_gate`, `<wood>_button`, `stone_button`, `polished_blackstone_button` | A | 13 and 15 blocks |
| `<colour>_bed`, `<colour>_glazed_terracotta`, `straw_bed` | A | 16, 16 and 1 blocks |
| `shulker_box`, `<colour>_shulker_box` | B | 17 blocks |
| `chest`, `trapped_chest`, the eight copper chests, `ender_chest` | A | 11 blocks |
| the eight `lightning_rod` forms, `end_rod` | B | 9 blocks |

---

## 5. Properties that no transform touches

Every transform leaves these unchanged, with the block still in its family (the list answers the properties of the scope list that are not rotated or mirrored by any rule):

* `half` (stairs, trapdoors, doors), `type` (slabs, chests, `piston_head`; so a chest's `single`, `left` or `right` value is kept by both `rotate` and `mirror`: `ChestBlock` overrides both methods with the `facing` rule only), `part` (beds), `face` (`floor`, `wall`, `ceiling` of levers, buttons, grindstones: `AttachFace`), `attachment` (bell: `floor`, `ceiling`, `single_wall`, `double_wall`), `up` of walls (family G) and of fire and vines, `thickness` of `pointed_dripstone`, `waterlogged`, `power` (redstone wire) and `powered`, `attached`, `disarmed` (tripwire).
* `vertical_direction` of `pointed_dripstone` and `sulfur_spike`: their classes (`PointedDripstoneBlock`, `SulfurSpikeBlock`) declare neither method.
* Blocks that look as if they should rotate but are unchanged: `chorus_plant` (six booleans `north` to `down`; class `ChorusPlantBlock` extends `PipeBlock`, which declares neither method), `fire` (`north`, `east`, `south`, `west`, `up` booleans), `soul_fire`, the standing `torch` family and every `facing`-less block. The walls' `up` and `low`/`tall` are in family G; the moss carpet `base` is in 3.5.
* `creaking_heart` rotates its `axis` like a log (family D) and has no mirror rule; `nether_portal` is family D2.

---

## 6. Worked examples

Inputs are property maps; properties not listed keep their values. "Mirror then rotate" is the order of 36-2 §5.3.

**Stairs (family K).**

1. `facing=east, half=bottom, shape=inner_left`, rotate `CLOCKWISE_90`: `facing=south`, `shape=inner_left`, `half=bottom`.
2. `facing=north, shape=outer_left`, mirror `LEFT_RIGHT`: `facing=south`, `shape=outer_right`.
3. `facing=north, shape=inner_left`, mirror `LEFT_RIGHT`: `facing=south`, `shape=inner_right`.
4. `facing=east, shape=inner_left`, mirror `FRONT_BACK`: `facing=west`, `shape=inner_left` (inner shapes kept; 3.8).
5. `facing=east, shape=outer_right`, mirror `FRONT_BACK`: `facing=west`, `shape=outer_left`.
6. `facing=east, shape=inner_right`, mirror `LEFT_RIGHT`: unchanged (the facing is not on the Z axis). `facing=north, shape=straight`, mirror `FRONT_BACK`: unchanged.
7. Mirror `LEFT_RIGHT` then rotate `COUNTERCLOCKWISE_90`, `facing=south, shape=outer_left`: after the mirror `facing=north, shape=outer_right`; after the rotation `facing=west, shape=outer_right`.

**Doors (family M).**

1. `facing=north, hinge=left, half=lower, open=false`, rotate `CLOCKWISE_90`: `facing=east`, `hinge=left`.
2. Same state, mirror `LEFT_RIGHT`: `facing=south`, `hinge=right`.
3. Same state, mirror `FRONT_BACK`: `facing=north` (the Z-axis facing is not flipped by `FRONT_BACK`), `hinge=right`.
4. `facing=east, hinge=right`, mirror `LEFT_RIGHT`: `facing=east`, `hinge=left`.

**Rails (family L).**

1. `rail`, `shape=south_east`, rotate `CLOCKWISE_90`: `south_west`; rotate `CLOCKWISE_180`: `north_west`; rotate `COUNTERCLOCKWISE_90`: `north_east`.
2. `shape=ascending_north`, mirror `LEFT_RIGHT`: `ascending_south`; mirror `FRONT_BACK`: unchanged.
3. `shape=ascending_east`, rotate `CLOCKWISE_90`: `ascending_south`; mirror `LEFT_RIGHT`: unchanged; mirror `FRONT_BACK`: `ascending_west`.
4. `powered_rail`, `shape=east_west, powered=true`, rotate `COUNTERCLOCKWISE_90`: `shape=north_south`, `powered=true`.
5. `rail`, `shape=north_east`, mirror `FRONT_BACK`: `north_west`.

**Chests (family A).**

1. `chest`, `facing=north, type=left, waterlogged=false`, mirror `LEFT_RIGHT`: `facing=south`, `type=left` (the type is not exchanged).
2. Same state, rotate `CLOCKWISE_180`: `facing=south`, `type=left`. Mirror `FRONT_BACK`: unchanged.

**Redstone wire (family H).**

1. `north=side, east=up, south=none, west=none, power=7`, rotate `CLOCKWISE_90`: `east=side` (from north), `south=up` (from east), `west=none` (from south), `north=none` (from west), `power=7`.
2. Same state, mirror `LEFT_RIGHT`: `north=none, south=side, east=up, west=none`.
3. Same state, mirror `FRONT_BACK`: `north=side, south=none, east=none, west=up`.

**Walls (family G).**

1. `north=low, east=tall, south=none, west=none, up=true`, rotate `COUNTERCLOCKWISE_90`: `north=tall` (from east), `east=none` (from south), `south=none` (from west), `west=low` (from north), `up=true`.
2. Same state, rotate `CLOCKWISE_180`: `north=none, east=none, south=low, west=tall`.
3. `pale_moss_carpet` `base=true, north=tall, east=low, south=none, west=none`, rotate `CLOCKWISE_90`: `east=tall`, `south=low`, `west=none`, `north=none`, `base=true`.

**Fences and panes (family F).**

1. `north=true, east=false, south=false, west=true`, rotate `CLOCKWISE_180`: `north=false, east=true, south=true, west=false`.
2. `vine` `up=true, north=true, east=false, south=false, west=false`, rotate `CLOCKWISE_90`: `up=true`, `east=true`, others false.
3. `tripwire` `north=true, south=true, attached=true`, mirror `FRONT_BACK`: unchanged (east and west are both false and are exchanged).

**Facing (families A, B, C).**

1. `piston`, `facing=west, extended=false`, rotate `CLOCKWISE_90`: `facing=north`. `facing=up`: unchanged under every transform.
2. `hopper`, `facing=east`, rotate `COUNTERCLOCKWISE_90`: `facing=north`; `facing=down` unchanged.
3. `wall_torch`, `facing=east`, mirror `LEFT_RIGHT`: unchanged; mirror `FRONT_BACK`: `facing=west`.
4. `oak_trapdoor`, `facing=east, half=top, open=true`, rotate `CLOCKWISE_90`: `facing=south`, `half=top`, `open=true`.
5. `white_bed`, `facing=north, part=head`, rotate `CLOCKWISE_180`: `facing=south`, `part=head`.
6. `anvil`, `facing=east`, rotate `CLOCKWISE_90`: `facing=south`; mirror `FRONT_BACK`: unchanged (the anvil has no mirror rule).

**Axis (family D).** `oak_log` `axis=x`, rotate `CLOCKWISE_90`: `axis=z`; `axis=y`: unchanged; `axis=z`, rotate `CLOCKWISE_180`: unchanged; any axis, any mirror: unchanged.

**Sixteen steps (family E).** `oak_sign` `rotation=3`: rotate `CLOCKWISE_90` gives 7, `CLOCKWISE_180` gives 11, `COUNTERCLOCKWISE_90` gives 15; mirror `LEFT_RIGHT` gives 5; mirror `FRONT_BACK` gives 13. `rotation=0`: `LEFT_RIGHT` gives 8, `FRONT_BACK` gives 0. `rotation=9`, `FRONT_BACK`: 7.

**Orientation (family N).** `jigsaw` `orientation=north_up`, rotate `CLOCKWISE_90`: `east_up`; mirror `LEFT_RIGHT`: `south_up`; mirror `FRONT_BACK`: unchanged. `crafter` `orientation=up_north`: rotate `CLOCKWISE_90`: `up_east`; mirror `LEFT_RIGHT`: `up_south`. `down_west`, rotate `COUNTERCLOCKWISE_90`: `down_south`.

**Multiface and huge mushroom (families I, J).** `glow_lichen` `north=true, up=true`, rotate `CLOCKWISE_90`: `east=true`, `up=true`; mirror `LEFT_RIGHT`: `south=true`, `up=true`. `red_mushroom_block` `north=true, down=true`: rotate `COUNTERCLOCKWISE_90`: `west=true`, `down=true`.

**Blocks that do not change.** `chorus_plant` with `north=true`: any transform returns the same state. `lever` `face=wall, facing=north`, rotate `CLOCKWISE_90`: `face=wall`, `facing=east`. `bell` `attachment=single_wall, facing=south`, mirror `LEFT_RIGHT`: `attachment=single_wall`, `facing=north`.

The examples were computed from the tables of this document by hand and by a small script that implements the document's own formulas; they were not run against the artifact.

---

## 7. Validation

An implementation matches this document when:

1. For each of the 4 rotations and 3 mirrors, every table of section 3 is reproduced exactly (the 16-value table of 3.3, the 10-shape rail tables of 3.9, the 12-value orientation table of 3.11, the stairs table of 3.8).
2. For every `facing`, `rotate` followed by the inverse rotation returns the input; `mirror` applied twice returns the input; for the rails, the stairs and the 16-step rotation the same two identities hold (the stairs under `LEFT_RIGHT`: shape swaps are involutions; under `FRONT_BACK`: the identity on inner shapes and the swap on outer shapes are involutions).
3. The counts hold: 587 blocks change under `rotate`, 511 under `mirror`, 699 under neither; the families of 4.2 have the stated sizes; the sum of the families is 587.
4. Every block of Appendix A has its rule; no block outside Appendix A changes under either transform.
5. For a door, `mirror` toggles `hinge` for both non-trivial mirrors regardless of the facing; for a chest, no transform changes `type`.

---

## 8. Open questions

1. `Entity.rotate`, `Entity.mirror`, hanging entities and block entity data (a sign's text, a banner's patterns) are not rotated by these methods and are outside this document (36-2 §13 question 5; 31).
2. Closed (read): 14 blocks are registered through `BlockItemIds` constants that hold a pair (block key, item key) built by `BlockItemId.create(block, item)`; the block key is the one used. Pairs read: `REDSTONE_DUST` (`redstone_wire`, `redstone`), `TRIPWIRE` (`tripwire`, `string`), `POWDER_SNOW` (`powder_snow`, `powder_snow_bucket`), `WHEAT_CROP` (`wheat`, `wheat_seeds`), `COCOA_CROP` (`cocoa`, `cocoa_beans`), `CARROT_CROP` (`carrots`, `carrot`), `POTATO_CROP` (`potatoes`, `potato`), `TORCHFLOWER_CROP` (`torchflower_crop`, `torchflower_seeds`), `PITCHER_CROP` (`pitcher_crop`, `pitcher_pod`), `BEETROOT_CROP` (`beetroots`, `beetroot_seeds`), `SWEET_BERRY_CROP` (`sweet_berry_bush`, `sweet_berries`), `GLOW_BERRY_CROP` (`cave_vines`, `glow_berries`), `PUMPKIN_CROP` (`pumpkin_stem`, `pumpkin_seeds`), `MELON_CROP` (`melon_stem`, `melon_seeds`). Of the 14, `tripwire` (family F) and `redstone_wire` (family H) are listed in Appendix A; the other twelve are unchanged blocks. The client carries 1288 blockstate files for 1286 blocks: the two extra, `item_frame` and `glow_item_frame`, have no block registration (they are entity models); the other 1286 file names equal the 1286 block keys.
3. The keys of the collection blocks (`<colour>_<base>`; the weathering prefixes `exposed_`, `weathered_`, `oxidized_`, `waxed_`; the special names `copper_block`, `exposed_copper`, `weathered_copper`, `oxidized_copper` for the copper block) follow the naming helpers' arguments and were cross-checked against the client's file names for all 1286 blocks (no mismatch); the helper bodies themselves were not read (inferred).
4. The stair rule under `FRONT_BACK` keeps both inner shapes and swaps both outer shapes, while `LEFT_RIGHT` swaps both pairs. This is read from `StairBlock.mirror`; the geometry of the shapes suggests a symmetric rule, but the artifact is the reference and no reason for the asymmetry was found.
5. A mirrored double chest keeps `type=left` or `type=right`; whether a later neighbour update re-pairs the halves is not part of these methods (24-block-registry and 29 hold `updateShape`); not traced here.
6. The constants `RotationSegment.NORTH_0`, `EAST_90`, `SOUTH_180`, `WEST_270` (0, 4, 8, 12) name `0` as north, while `RotationSegment.convertToSegment(Direction)` returns `get2DDataValue() << 2`, which puts south at 0, west at 4, north at 8 and east at 12. The transform formulas of 2.4 do not depend on which is right; the compass reading of a `rotation` value used in 2.4 follows `convertToSegment`. The use of the constants was not traced.
7. The registration class of a block was taken from the first constructor reference or lambda body in its `Blocks` registration; for collection fields the first factory is the waxed (or plain) block and the second the weathering block (the order of the arguments of `WeatheringCopperCollection.registerBlocks`). The totals per class were cross-checked: 911 fields, 1286 blocks, 66 declaring classes counting `BlockBehaviour`, 587 + 699 = 1286.
8. The domains of `facing` in family B were confirmed from the client block state files for the dispenser, dropper, command blocks, barrel, observer, pistons, rods and amethyst buds, and from `DirectionalBlock.FACING = BlockStateProperties.FACING` for the shulker boxes and moving piston; the property value order (state numbering) is in 24-block-registry-1.
9. `GrindstoneBlock` (a subclass of `FaceAttachedHorizontalDirectionalBlock`, itself a subclass of `HorizontalDirectionalBlock`) redeclares both methods with the same `facing` rule as its ancestor; the two were treated as one rule. No class declares only one of the two methods other than the five listed in 4.1.

---

## Appendix A. Every block that changes, by rule family

Keys are block keys without the `minecraft:` prefix, in registration order within each provider class. "Rule provider" is the class of 4.1 that supplies the rule.

### A.1 Horizontal facing, rotate and mirror (rule family A)

Total 213 blocks.

* Rule provider `AbstractFurnaceBlock`, 3 blocks (registered classes: `BlastFurnaceBlock` 1, `FurnaceBlock` 1, `SmokerBlock` 1): `furnace`, `smoker`, `blast_furnace`

* Rule provider `AttachedStemBlock`, 2 blocks (registered classes: `AttachedStemBlock` 2): `attached_pumpkin_stem`, `attached_melon_stem`

* Rule provider `BaseCoralWallFanBlock`, 10 blocks (registered classes: `BaseCoralWallFanBlock` 5, `CoralWallFanBlock` 5): `dead_tube_coral_wall_fan`, `dead_brain_coral_wall_fan`, `dead_bubble_coral_wall_fan`, `dead_fire_coral_wall_fan`, `dead_horn_coral_wall_fan`, `tube_coral_wall_fan`, `brain_coral_wall_fan`, `bubble_coral_wall_fan`, `fire_coral_wall_fan`, `horn_coral_wall_fan`

* Rule provider `BeehiveBlock`, 2 blocks (registered classes: `BeehiveBlock` 2): `bee_nest`, `beehive`

* Rule provider `BellBlock`, 1 blocks (registered classes: `BellBlock` 1): `bell`

* Rule provider `CalibratedSculkSensorBlock`, 1 blocks (registered classes: `CalibratedSculkSensorBlock` 1): `calibrated_sculk_sensor`

* Rule provider `CampfireBlock`, 2 blocks (registered classes: `CampfireBlock` 2): `campfire`, `soul_campfire`

* Rule provider `ChestBlock`, 10 blocks (registered classes: `ChestBlock` 1, `CopperChestBlock` 4, `TrappedChestBlock` 1, `WeatheringCopperChestBlock` 4): `chest`, `trapped_chest`, `copper_chest`, `exposed_copper_chest`, `weathered_copper_chest`, `oxidized_copper_chest`, `waxed_copper_chest`, `waxed_exposed_copper_chest`, `waxed_weathered_copper_chest`, `waxed_oxidized_copper_chest`

* Rule provider `ChiseledBookShelfBlock`, 1 blocks (registered classes: `ChiseledBookShelfBlock` 1): `chiseled_bookshelf`

* Rule provider `CopperGolemStatueBlock`, 8 blocks (registered classes: `CopperGolemStatueBlock` 4, `WeatheringCopperGolemStatueBlock` 4): `copper_golem_statue`, `exposed_copper_golem_statue`, `weathered_copper_golem_statue`, `oxidized_copper_golem_statue`, `waxed_copper_golem_statue`, `waxed_exposed_copper_golem_statue`, `waxed_weathered_copper_golem_statue`, `waxed_oxidized_copper_golem_statue`

* Rule provider `DecoratedPotBlock`, 1 blocks (registered classes: `DecoratedPotBlock` 1): `decorated_pot`

* Rule provider `EndPortalFrameBlock`, 1 blocks (registered classes: `EndPortalFrameBlock` 1): `end_portal_frame`

* Rule provider `EnderChestBlock`, 1 blocks (registered classes: `EnderChestBlock` 1): `ender_chest`

* Rule provider `FlowerBedBlock`, 2 blocks (registered classes: `FlowerBedBlock` 2): `pink_petals`, `wildflowers`

* Rule provider `GrindstoneBlock`, 1 blocks (registered classes: `GrindstoneBlock` 1): `grindstone`

* Rule provider `HorizontalDirectionalBlock`, 94 blocks (registered classes: `BedBlock` 16, `BigDripleafBlock` 1, `BigDripleafStemBlock` 1, `ButtonBlock` 15, `CarvedPumpkinBlock` 2, `CocoaBlock` 1, `ComparatorBlock` 1, `DriedGhastBlock` 1, `FenceGateBlock` 13, `GlazedTerracottaBlock` 16, `LeverBlock` 1, `LoomBlock` 1, `RepeaterBlock` 1, `ShelfMushroomBlock` 1, `StrawBedBlock` 1, `TrapDoorBlock` 18, `WeatheringCopperTrapDoorBlock` 4): `white_bed`, `orange_bed`, `magenta_bed`, `light_blue_bed`, `yellow_bed`, `lime_bed`, `pink_bed`, `gray_bed`, `light_gray_bed`, `cyan_bed`, `purple_bed`, `blue_bed`, `brown_bed`, `green_bed`, `red_bed`, `black_bed`, `straw_bed`, `lever`, `stone_button`, `carved_pumpkin`, `jack_o_lantern`, `repeater`, `oak_trapdoor`, `spruce_trapdoor`, `birch_trapdoor`, `jungle_trapdoor`, `acacia_trapdoor`, `cherry_trapdoor`, `dark_oak_trapdoor`, `pale_oak_trapdoor`, `mangrove_trapdoor`, `poplar_trapdoor`, `bamboo_trapdoor`, `oak_fence_gate`, `cocoa`, `shelf_mushroom`, `oak_button`, `spruce_button`, `birch_button`, `jungle_button`, `acacia_button`, `cherry_button`, `dark_oak_button`, `pale_oak_button`, `mangrove_button`, `poplar_button`, `bamboo_button`, `comparator`, `iron_trapdoor`, `spruce_fence_gate`, `birch_fence_gate`, `jungle_fence_gate`, `acacia_fence_gate`, `cherry_fence_gate`, `dark_oak_fence_gate`, `pale_oak_fence_gate`, `mangrove_fence_gate`, `poplar_fence_gate`, `bamboo_fence_gate`, `white_glazed_terracotta`, `orange_glazed_terracotta`, `magenta_glazed_terracotta`, `light_blue_glazed_terracotta`, `yellow_glazed_terracotta`, `lime_glazed_terracotta`, `pink_glazed_terracotta`, `gray_glazed_terracotta`, `light_gray_glazed_terracotta`, `cyan_glazed_terracotta`, `purple_glazed_terracotta`, `blue_glazed_terracotta`, `brown_glazed_terracotta`, `green_glazed_terracotta`, `red_glazed_terracotta`, `black_glazed_terracotta`, `dried_ghast`, `loom`, `crimson_trapdoor`, `warped_trapdoor`, `crimson_fence_gate`, `warped_fence_gate`, `crimson_button`, `warped_button`, `polished_blackstone_button`, `copper_trapdoor`, `exposed_copper_trapdoor`, `weathered_copper_trapdoor`, `oxidized_copper_trapdoor`, `waxed_copper_trapdoor`, `waxed_exposed_copper_trapdoor`, `waxed_weathered_copper_trapdoor`, `waxed_oxidized_copper_trapdoor`, `big_dripleaf`, `big_dripleaf_stem`

* Rule provider `LadderBlock`, 1 blocks (registered classes: `LadderBlock` 1): `ladder`

* Rule provider `LeafLitterBlock`, 1 blocks (registered classes: `LeafLitterBlock` 1): `leaf_litter`

* Rule provider `LecternBlock`, 1 blocks (registered classes: `LecternBlock` 1): `lectern`

* Rule provider `RedstoneWallTorchBlock`, 1 blocks (registered classes: `RedstoneWallTorchBlock` 1): `redstone_wall_torch`

* Rule provider `ShelfBlock`, 13 blocks (registered classes: `ShelfBlock` 13): `acacia_shelf`, `bamboo_shelf`, `birch_shelf`, `cherry_shelf`, `crimson_shelf`, `dark_oak_shelf`, `jungle_shelf`, `mangrove_shelf`, `oak_shelf`, `pale_oak_shelf`, `poplar_shelf`, `spruce_shelf`, `warped_shelf`

* Rule provider `SmallDripleafBlock`, 1 blocks (registered classes: `SmallDripleafBlock` 1): `small_dripleaf`

* Rule provider `StonecutterBlock`, 1 blocks (registered classes: `StonecutterBlock` 1): `stonecutter`

* Rule provider `TripWireHookBlock`, 1 blocks (registered classes: `TripWireHookBlock` 1): `tripwire_hook`

* Rule provider `VaultBlock`, 1 blocks (registered classes: `VaultBlock` 1): `vault`

* Rule provider `WallBannerBlock`, 16 blocks (registered classes: `WallBannerBlock` 16): `white_wall_banner`, `orange_wall_banner`, `magenta_wall_banner`, `light_blue_wall_banner`, `yellow_wall_banner`, `lime_wall_banner`, `pink_wall_banner`, `gray_wall_banner`, `light_gray_wall_banner`, `cyan_wall_banner`, `purple_wall_banner`, `blue_wall_banner`, `brown_wall_banner`, `green_wall_banner`, `red_wall_banner`, `black_wall_banner`

* Rule provider `WallHangingSignBlock`, 13 blocks (registered classes: `WallHangingSignBlock` 13): `oak_wall_hanging_sign`, `spruce_wall_hanging_sign`, `birch_wall_hanging_sign`, `acacia_wall_hanging_sign`, `cherry_wall_hanging_sign`, `jungle_wall_hanging_sign`, `dark_oak_wall_hanging_sign`, `pale_oak_wall_hanging_sign`, `mangrove_wall_hanging_sign`, `poplar_wall_hanging_sign`, `crimson_wall_hanging_sign`, `warped_wall_hanging_sign`, `bamboo_wall_hanging_sign`

* Rule provider `WallSignBlock`, 13 blocks (registered classes: `WallSignBlock` 13): `oak_wall_sign`, `spruce_wall_sign`, `birch_wall_sign`, `acacia_wall_sign`, `cherry_wall_sign`, `jungle_wall_sign`, `dark_oak_wall_sign`, `pale_oak_wall_sign`, `mangrove_wall_sign`, `poplar_wall_sign`, `bamboo_wall_sign`, `crimson_wall_sign`, `warped_wall_sign`

* Rule provider `WallSkullBlock`, 7 blocks (registered classes: `PiglinWallSkullBlock` 1, `PlayerWallHeadBlock` 1, `WallSkullBlock` 4, `WitherWallSkullBlock` 1): `skeleton_wall_skull`, `wither_skeleton_wall_skull`, `zombie_wall_head`, `player_wall_head`, `creeper_wall_head`, `dragon_wall_head`, `piglin_wall_head`

* Rule provider `WallTorchBlock`, 3 blocks (registered classes: `WallTorchBlock` 3): `wall_torch`, `soul_wall_torch`, `copper_wall_torch`

### A.2 Horizontal facing, rotate only (rule family A2)

Total 3 blocks.

* Rule provider `AnvilBlock`, 3 blocks (registered classes: `AnvilBlock` 3): `anvil`, `chipped_anvil`, `damaged_anvil`

### A.3 Six-value facing (rule family B)

Total 41 blocks.

* Rule provider `AmethystClusterBlock`, 4 blocks (registered classes: `AmethystClusterBlock` 4): `amethyst_cluster`, `large_amethyst_bud`, `medium_amethyst_bud`, `small_amethyst_bud`

* Rule provider `BarrelBlock`, 1 blocks (registered classes: `BarrelBlock` 1): `barrel`

* Rule provider `CommandBlock`, 3 blocks (registered classes: `CommandBlock` 3): `command_block`, `repeating_command_block`, `chain_command_block`

* Rule provider `DispenserBlock`, 2 blocks (registered classes: `DispenserBlock` 1, `DropperBlock` 1): `dispenser`, `dropper`

* Rule provider `MovingPistonBlock`, 1 blocks (registered classes: `MovingPistonBlock` 1): `moving_piston`

* Rule provider `ObserverBlock`, 1 blocks (registered classes: `ObserverBlock` 1): `observer`

* Rule provider `PistonBaseBlock`, 2 blocks (registered classes: `PistonBaseBlock` 2): `sticky_piston`, `piston`

* Rule provider `PistonHeadBlock`, 1 blocks (registered classes: `PistonHeadBlock` 1): `piston_head`

* Rule provider `RodBlock`, 9 blocks (registered classes: `EndRodBlock` 1, `LightningRodBlock` 4, `WeatheringLightningRodBlock` 4): `end_rod`, `lightning_rod`, `exposed_lightning_rod`, `weathered_lightning_rod`, `oxidized_lightning_rod`, `waxed_lightning_rod`, `waxed_exposed_lightning_rod`, `waxed_weathered_lightning_rod`, `waxed_oxidized_lightning_rod`

* Rule provider `ShulkerBoxBlock`, 17 blocks (registered classes: `ShulkerBoxBlock` 17): `shulker_box`, `white_shulker_box`, `orange_shulker_box`, `magenta_shulker_box`, `light_blue_shulker_box`, `yellow_shulker_box`, `lime_shulker_box`, `pink_shulker_box`, `gray_shulker_box`, `light_gray_shulker_box`, `cyan_shulker_box`, `purple_shulker_box`, `blue_shulker_box`, `brown_shulker_box`, `green_shulker_box`, `red_shulker_box`, `black_shulker_box`

### A.4 Hopper facing (five values) (rule family C)

Total 1 blocks.

* Rule provider `HopperBlock`, 1 blocks (registered classes: `HopperBlock` 1): `hopper`

### A.5 Axis (rotate only) (rule family D)

Total 72 blocks.

* Rule provider `CreakingHeartBlock`, 1 blocks (registered classes: `CreakingHeartBlock` 1): `creaking_heart`

* Rule provider `InfestedRotatedPillarBlock`, 1 blocks (registered classes: `InfestedRotatedPillarBlock` 1): `infested_deepslate`

* Rule provider `RotatedPillarBlock`, 70 blocks (registered classes: `ChainBlock` 5, `HayBlock` 1, `RotatedPillarBlock` 60, `WeatheringCopperChainBlock` 4): `pale_oak_wood`, `oak_log`, `spruce_log`, `birch_log`, `jungle_log`, `acacia_log`, `cherry_log`, `dark_oak_log`, `pale_oak_log`, `mangrove_log`, `poplar_log`, `muddy_mangrove_roots`, `bamboo_block`, `stripped_spruce_log`, `stripped_birch_log`, `stripped_jungle_log`, `stripped_acacia_log`, `stripped_cherry_log`, `stripped_dark_oak_log`, `stripped_pale_oak_log`, `stripped_oak_log`, `stripped_mangrove_log`, `stripped_poplar_log`, `stripped_bamboo_block`, `oak_wood`, `spruce_wood`, `birch_wood`, `jungle_wood`, `acacia_wood`, `cherry_wood`, `dark_oak_wood`, `mangrove_wood`, `poplar_wood`, `stripped_oak_wood`, `stripped_spruce_wood`, `stripped_birch_wood`, `stripped_jungle_wood`, `stripped_acacia_wood`, `stripped_cherry_wood`, `stripped_dark_oak_wood`, `stripped_pale_oak_wood`, `stripped_mangrove_wood`, `stripped_poplar_wood`, `basalt`, `polished_basalt`, `iron_chain`, `copper_chain`, `exposed_copper_chain`, `weathered_copper_chain`, `oxidized_copper_chain`, `waxed_copper_chain`, `waxed_exposed_copper_chain`, `waxed_weathered_copper_chain`, `waxed_oxidized_copper_chain`, `quartz_pillar`, `hay_block`, `purpur_pillar`, `bone_block`, `warped_stem`, `stripped_warped_stem`, `warped_hyphae`, `stripped_warped_hyphae`, `crimson_stem`, `stripped_crimson_stem`, `crimson_hyphae`, `stripped_crimson_hyphae`, `deepslate`, `ochre_froglight`, `verdant_froglight`, `pearlescent_froglight`

### A.6 Portal axis (rotate only) (rule family D2)

Total 1 blocks.

* Rule provider `NetherPortalBlock`, 1 blocks (registered classes: `NetherPortalBlock` 1): `nether_portal`

### A.7 Rotation 0 to 15 (rule family E)

Total 49 blocks.

* Rule provider `BannerBlock`, 16 blocks (registered classes: `BannerBlock` 16): `white_banner`, `orange_banner`, `magenta_banner`, `light_blue_banner`, `yellow_banner`, `lime_banner`, `pink_banner`, `gray_banner`, `light_gray_banner`, `cyan_banner`, `purple_banner`, `blue_banner`, `brown_banner`, `green_banner`, `red_banner`, `black_banner`

* Rule provider `CeilingHangingSignBlock`, 13 blocks (registered classes: `CeilingHangingSignBlock` 13): `oak_hanging_sign`, `spruce_hanging_sign`, `birch_hanging_sign`, `acacia_hanging_sign`, `cherry_hanging_sign`, `jungle_hanging_sign`, `dark_oak_hanging_sign`, `pale_oak_hanging_sign`, `crimson_hanging_sign`, `warped_hanging_sign`, `mangrove_hanging_sign`, `poplar_hanging_sign`, `bamboo_hanging_sign`

* Rule provider `SkullBlock`, 7 blocks (registered classes: `PlayerHeadBlock` 1, `SkullBlock` 5, `WitherSkullBlock` 1): `skeleton_skull`, `wither_skeleton_skull`, `zombie_head`, `player_head`, `creeper_head`, `dragon_head`, `piglin_head`

* Rule provider `StandingSignBlock`, 13 blocks (registered classes: `StandingSignBlock` 13): `oak_sign`, `spruce_sign`, `birch_sign`, `acacia_sign`, `cherry_sign`, `jungle_sign`, `dark_oak_sign`, `pale_oak_sign`, `mangrove_sign`, `poplar_sign`, `bamboo_sign`, `crimson_sign`, `warped_sign`

### A.8 Four boolean sides (rule family F)

Total 42 blocks.

* Rule provider `CrossCollisionBlock`, 40 blocks (registered classes: `FenceBlock` 14, `IronBarsBlock` 6, `StainedGlassPaneBlock` 16, `WeatheringCopperBarsBlock` 4): `oak_fence`, `iron_bars`, `copper_bars`, `exposed_copper_bars`, `weathered_copper_bars`, `oxidized_copper_bars`, `waxed_copper_bars`, `waxed_exposed_copper_bars`, `waxed_weathered_copper_bars`, `waxed_oxidized_copper_bars`, `glass_pane`, `nether_brick_fence`, `white_stained_glass_pane`, `orange_stained_glass_pane`, `magenta_stained_glass_pane`, `light_blue_stained_glass_pane`, `yellow_stained_glass_pane`, `lime_stained_glass_pane`, `pink_stained_glass_pane`, `gray_stained_glass_pane`, `light_gray_stained_glass_pane`, `cyan_stained_glass_pane`, `purple_stained_glass_pane`, `blue_stained_glass_pane`, `brown_stained_glass_pane`, `green_stained_glass_pane`, `red_stained_glass_pane`, `black_stained_glass_pane`, `spruce_fence`, `birch_fence`, `jungle_fence`, `acacia_fence`, `cherry_fence`, `dark_oak_fence`, `pale_oak_fence`, `mangrove_fence`, `poplar_fence`, `bamboo_fence`, `crimson_fence`, `warped_fence`

* Rule provider `TripWireBlock`, 1 blocks (registered classes: `TripWireBlock` 1): `tripwire`

* Rule provider `VineBlock`, 1 blocks (registered classes: `VineBlock` 1): `vine`

### A.9 Four wall-side sides (rule family G)

Total 33 blocks.

* Rule provider `MossyCarpetBlock`, 1 blocks (registered classes: `MossyCarpetBlock` 1): `pale_moss_carpet`

* Rule provider `WallBlock`, 32 blocks (registered classes: `WallBlock` 32): `resin_brick_wall`, `cobblestone_wall`, `mossy_cobblestone_wall`, `brick_wall`, `prismarine_wall`, `red_sandstone_wall`, `mossy_stone_brick_wall`, `granite_wall`, `stone_brick_wall`, `mud_brick_wall`, `nether_brick_wall`, `andesite_wall`, `red_nether_brick_wall`, `sandstone_wall`, `end_stone_brick_wall`, `diorite_wall`, `blackstone_wall`, `polished_blackstone_brick_wall`, `polished_blackstone_wall`, `tuff_wall`, `polished_tuff_wall`, `tuff_brick_wall`, `sulfur_wall`, `polished_sulfur_wall`, `sulfur_brick_wall`, `cinnabar_wall`, `polished_cinnabar_wall`, `cinnabar_brick_wall`, `cobbled_deepslate_wall`, `polished_deepslate_wall`, `deepslate_tile_wall`, `deepslate_brick_wall`

### A.10 Redstone wire (rule family H)

Total 1 blocks.

* Rule provider `RedstoneWireBlock`, 1 blocks (registered classes: `RedstoneWireBlock` 1): `redstone_wire`

### A.11 Six boolean faces (huge mushroom) (rule family I)

Total 3 blocks.

* Rule provider `HugeMushroomBlock`, 3 blocks (registered classes: `HugeMushroomBlock` 3): `brown_mushroom_block`, `red_mushroom_block`, `mushroom_stem`

### A.12 Multiface (rule family J)

Total 3 blocks.

* Rule provider `MultifaceBlock`, 3 blocks (registered classes: `GlowLichenBlock` 1, `MultifaceBlock` 1, `SculkVeinBlock` 1): `glow_lichen`, `resin_clump`, `sculk_vein`

### A.13 Stairs (rule family K)

Total 97 blocks.

* Rule provider `StairBlock`, 97 blocks (registered classes: `StairBlock` 93, `WeatheringCopperStairBlock` 4): `white_wool_stairs`, `orange_wool_stairs`, `magenta_wool_stairs`, `light_blue_wool_stairs`, `yellow_wool_stairs`, `lime_wool_stairs`, `pink_wool_stairs`, `gray_wool_stairs`, `light_gray_wool_stairs`, `cyan_wool_stairs`, `purple_wool_stairs`, `blue_wool_stairs`, `brown_wool_stairs`, `green_wool_stairs`, `red_wool_stairs`, `black_wool_stairs`, `oak_stairs`, `cobblestone_stairs`, `brick_stairs`, `stone_brick_stairs`, `mud_brick_stairs`, `resin_brick_stairs`, `nether_brick_stairs`, `sandstone_stairs`, `spruce_stairs`, `birch_stairs`, `jungle_stairs`, `quartz_stairs`, `acacia_stairs`, `cherry_stairs`, `dark_oak_stairs`, `pale_oak_stairs`, `mangrove_stairs`, `poplar_stairs`, `bamboo_stairs`, `bamboo_mosaic_stairs`, `prismarine_stairs`, `prismarine_brick_stairs`, `dark_prismarine_stairs`, `red_sandstone_stairs`, `purpur_stairs`, `white_concrete_stairs`, `orange_concrete_stairs`, `magenta_concrete_stairs`, `light_blue_concrete_stairs`, `yellow_concrete_stairs`, `lime_concrete_stairs`, `pink_concrete_stairs`, `gray_concrete_stairs`, `light_gray_concrete_stairs`, `cyan_concrete_stairs`, `purple_concrete_stairs`, `blue_concrete_stairs`, `brown_concrete_stairs`, `green_concrete_stairs`, `red_concrete_stairs`, `black_concrete_stairs`, `polished_granite_stairs`, `smooth_red_sandstone_stairs`, `mossy_stone_brick_stairs`, `polished_diorite_stairs`, `mossy_cobblestone_stairs`, `end_stone_brick_stairs`, `stone_stairs`, `smooth_sandstone_stairs`, `smooth_quartz_stairs`, `granite_stairs`, `andesite_stairs`, `red_nether_brick_stairs`, `polished_andesite_stairs`, `diorite_stairs`, `crimson_stairs`, `warped_stairs`, `blackstone_stairs`, `polished_blackstone_brick_stairs`, `polished_blackstone_stairs`, `tuff_stairs`, `polished_tuff_stairs`, `tuff_brick_stairs`, `sulfur_stairs`, `polished_sulfur_stairs`, `sulfur_brick_stairs`, `cinnabar_stairs`, `polished_cinnabar_stairs`, `cinnabar_brick_stairs`, `cut_copper_stairs`, `exposed_cut_copper_stairs`, `weathered_cut_copper_stairs`, `oxidized_cut_copper_stairs`, `waxed_cut_copper_stairs`, `waxed_exposed_cut_copper_stairs`, `waxed_weathered_cut_copper_stairs`, `waxed_oxidized_cut_copper_stairs`, `cobbled_deepslate_stairs`, `polished_deepslate_stairs`, `deepslate_tile_stairs`, `deepslate_brick_stairs`

### A.14 Rails (rule family L)

Total 4 blocks.

* Rule provider `DetectorRailBlock`, 1 blocks (registered classes: `DetectorRailBlock` 1): `detector_rail`

* Rule provider `PoweredRailBlock`, 2 blocks (registered classes: `PoweredRailBlock` 2): `powered_rail`, `activator_rail`

* Rule provider `RailBlock`, 1 blocks (registered classes: `RailBlock` 1): `rail`

### A.15 Doors (rule family M)

Total 22 blocks.

* Rule provider `DoorBlock`, 22 blocks (registered classes: `DoorBlock` 18, `WeatheringCopperDoorBlock` 4): `oak_door`, `iron_door`, `spruce_door`, `birch_door`, `jungle_door`, `acacia_door`, `cherry_door`, `dark_oak_door`, `pale_oak_door`, `mangrove_door`, `poplar_door`, `bamboo_door`, `crimson_door`, `warped_door`, `copper_door`, `exposed_copper_door`, `weathered_copper_door`, `oxidized_copper_door`, `waxed_copper_door`, `waxed_exposed_copper_door`, `waxed_weathered_copper_door`, `waxed_oxidized_copper_door`

### A.16 Orientation (rule family N)

Total 2 blocks.

* Rule provider `CrafterBlock`, 1 blocks (registered classes: `CrafterBlock` 1): `crafter`

* Rule provider `JigsawBlock`, 1 blocks (registered classes: `JigsawBlock` 1): `jigsaw`
