# Stand-in content (placeholder data for engineering)

Status: **placeholder**. Nothing in this document is final game design. It is the smallest coherent set of
original content that lets the COBOL client and the COBOL server go end to end: connect, configure, join,
receive chunks, render, walk around, and place and break blocks. Every value here is expected to be
replaced. Section 7 lists what to replace.

Wire formats, packet layouts and the id-assignment rules are in [../protocol/](../protocol/README.md). This
document only chooses *content*. Section references such as "04 §5.2" point into that spec.

## 0. Ground rules and the two compatibility tiers

- **Namespace.** All original content uses `cobolcraft:`.
- **Protocol-required names.** A few keys must use the `minecraft:` namespace because the vanilla client
  looks them up by exact name (04 §3.2). Each such key is marked **[compat name]**. Only the *name* is kept,
  for protocol compatibility. Every value attached to it is our own minimal placeholder.
- **Registry keys are protocol vocabulary, not content.** Names such as `minecraft:dimension_type`,
  `minecraft:worldgen/biome` or `minecraft:wolf_variant` name a *slot in the protocol*. We send them as-is.
  Enum values that a codec fixes (for example skybox `overworld`, model `normal`, scaling `never`) are
  protocol constants in the same sense.

The game owns both client and server, so two compatibility tiers exist:

| Tier | Meaning | Status for the stand-in |
|---|---|---|
| A. Own-client | The COBOL client parses and uses everything sent. | **Required.** This is the target. |
| B. Vanilla-parse | A vanilla 26.3 client can finish the configuration phase without a registry load error (04 §3.2). | **Kept as a goal for the configuration phase only.** It costs very little and lets a reference client act as a test oracle for our Registry Data encoder. |

Tier B cannot extend into play. The static registries (blocks, block states, items, entity types) are never
sent. A vanilla client numbers them from its own built-in tables (04 §5). Our block state 2 would be drawn as
whatever vanilla state 2 is. Original static content and a playable vanilla client are mutually exclusive.
That is accepted: the vanilla client is an oracle for configuration only.

---

## 1. Block registry

### 1.1 Blocks

Registration order defines the block id. Ten blocks; id 0 is the air-equivalent.

| Block id | Key | Properties | Solid / collides | Opaque (occludes faces, blocks light) | Light emitted | Hand break time | Notes |
|---|---|---|---|---|---|---|---|
| 0 | `cobolcraft:void` | none | no | no | 0 | n/a | Empty space. Not targetable, not breakable, not placeable. |
| 1 | `cobolcraft:baseplate` | none | yes | yes | 0 | unbreakable | Bottom layer of the world (y = 0). Creative may place it but nobody may break it. |
| 2 | `cobolcraft:greystone` | none | yes | yes | 0 | 1.5 s | Bulk underground fill. "Hard" class. |
| 3 | `cobolcraft:loam` | none | yes | yes | 0 | 0.6 s | Subsoil. "Soft" class. |
| 4 | `cobolcraft:turf` | none | yes | yes | 0 | 0.7 s | Top surface on higher ground. "Soft" class. Different top, side and bottom faces. |
| 5 | `cobolcraft:grit` | none | yes | yes | 0 | 0.5 s | Top surface on low ground. "Soft" class. No gravity in the stand-in. |
| 6 | `cobolcraft:cardstack` | `axis` (x, y, z); `punched` (true, false) | yes | yes | 0 | 1.0 s | A bound stack of punch cards. Exercises the two-property Cartesian rule. "Hard" class. |
| 7 | `cobolcraft:lucite` | none | yes | **no** | 0 | 0.4 s | Clear block. Tests transparency and face culling. Faces between two lucite blocks are culled; faces against any opaque block are drawn on the lucite side only. |
| 8 | `cobolcraft:glowtube` | `lit` (true, false) | yes | yes | 15 when `lit=true`, 0 when `lit=false` | 0.3 s | Light source. Exercises the one-property rule and block light. Using it (right-click without a held block) toggles `lit`. |
| 9 | `cobolcraft:ledger_tile` | none | yes | yes | 0 | 1.2 s | Plain building block. "Hard" class. |

All blocks are full 1 × 1 × 1 cubes. There are no fluids: every section's fluid count (06 §4) is 0.

Property value orders (as they would be declared; these define state numbering):

- `axis`: enum, values in the order **x, y, z**.
- `punched`: boolean, therefore **true, false** (04 §5.2).
- `lit`: boolean, therefore **true, false**.

### 1.2 Block state ids

Computed with the rule in 04 §5.2: walk blocks in id order; inside a block, sort properties by name, take the
Cartesian product with the first-sorted property varying slowest; each block's first state id is the number
of states before it.

For `cardstack`, the sorted property names are `axis` < `punched`, so `axis` varies slowest and `punched`
fastest. Value counts: axis 3, punched 2. State offset = axis_index × 2 + punched_index.

| State id | Block | Property values | Default state of its block? |
|---|---|---|---|
| 0 | void | — | yes |
| 1 | baseplate | — | yes |
| 2 | greystone | — | yes |
| 3 | loam | — | yes |
| 4 | turf | — | yes |
| 5 | grit | — | yes |
| 6 | cardstack | axis=x, punched=true | |
| 7 | cardstack | axis=x, punched=false | |
| 8 | cardstack | axis=y, punched=true | |
| 9 | cardstack | axis=y, punched=false | **yes** (default is not the first state, on purpose) |
| 10 | cardstack | axis=z, punched=true | |
| 11 | cardstack | axis=z, punched=false | |
| 12 | lucite | — | yes |
| 13 | glowtube | lit=true | **yes** |
| 14 | glowtube | lit=false | |
| 15 | ledger_tile | — | yes |

Total: **16 block states**. Consequences for chunk encoding (06 §5.3):

- `ceillog2(16) = 4`, so the global (direct) block palette is 4 bits wide.
- Any section with 2–16 distinct states needs at most 4 bits, which is the Linear palette. A server using
  this content will only ever emit bits = 0 (single value) or bits = 4 (Linear). The HashMap and Global
  kinds are never reached. Tests for those paths need a larger registry or a hand-crafted packet.
- An unknown state id should decode to state 0 (void), mirroring 04 §5.2's last paragraph.

### 1.3 Placement rules

- Placing a block item puts the block's **default state**, except:
  - `cardstack`: `axis` follows the clicked face's axis (top/bottom face → y, east/west → x,
    north/south → z); `punched=false`.
- A position can receive a block only if it currently holds `void`.
- Breaking sets the position to state 0 (`void`). `baseplate` refuses.
- No drops in the stand-in. In survival, a broken block's item is added straight to the breaker's inventory
  (or discarded if full). See entity type 1 for the optional later step.

### 1.4 Placeholder textures

All textures are **16 × 16**, generated procedurally at startup. "Noise" means a deterministic per-pixel
pick from a seeded hash of (x, y, texture name), so the result is identical on every machine.

| Block | Face(s) | Recipe |
|---|---|---|
| void | — | Not rendered. |
| baseplate | all | Fill `#2B2B33`. Draw both diagonals of every 4 × 4 cell in `#45454F` (a fine crosshatch). |
| greystone | all | Fill `#7D7F86`. Noise: 20 % of pixels `#6C6E75`, 8 % `#8E9097`. |
| loam | all | Fill `#7A5634`. Noise: 15 % of pixels `#664629`, 5 % `#8C6640`. |
| turf | top | Fill `#4F8F3A`. Noise: 20 % of pixels `#447D32`, 10 % `#5CA044`. |
| turf | sides | The loam recipe, then rows 0–3 (top 4 rows) replaced by the turf-top recipe; row 4 has every other pixel turf-top. |
| turf | bottom | The loam recipe. |
| grit | all | Fill `#D2C08A`. Noise: 30 % of pixels `#C2AE76`, 10 % `#E0D09E`. |
| cardstack | ends (the two faces normal to `axis`) | Fill `#EDE6CF`. A 1-px border in `#B9AE8C`. |
| cardstack | sides | Fill `#EDE6CF`. A horizontal `#B9AE8C` line every 2 rows (card edges), running across the stack's long direction. When `punched=true`, add a 2 × 1 `#2A2A2A` "hole" at every 4th pixel of every 4th line. |
| lucite | all | Fully transparent interior (alpha 0). A 1-px border in `#BFE6F2` at alpha 60 %. One 3-pixel diagonal "glint" in `#FFFFFF` at alpha 80 % near the top-left. |
| glowtube | all, lit | Fill `#FFE38A`. A 4-px-wide vertical bar in the centre in `#FFF6D0`. A 1-px border in `#A08A3C`. |
| glowtube | all, unlit | The same layout with `#7A6E4A` fill, `#8F8460` bar, `#4E4630` border. |
| ledger_tile | all | 4 × 4 checkerboard of `#3E6C8F` and `#355D7B`, with a 1-px `#24425A` grid line on every 8th row and column. |
| (missing texture) | — | Diagonal 2-px stripes alternating `#F28C28` and `#1A1A1A`. Used for any unknown block, item or entity. |

Shading: the renderer applies its own fixed per-face brightness (for example top 100 %, sides 80 %/60 %,
bottom 50 %). That is renderer policy, not texture content.

---

## 2. Item registry

Item ids are our own static numbering. On the wire an item appears as `RegistryId<item>` inside an ItemStack
(00 §12.1). The stand-in uses **no data components**: every non-empty stack is sent with AddedCount = 0 and
RemovedCount = 0, so no `data_component_type` numbering is needed yet.

| Item id | Key | Places block (state) | Max stack | Notes |
|---|---|---|---|---|
| 0 | `cobolcraft:nothing` | — | — | Air-equivalent. Never appears in a non-empty stack. Reserved so id 0 is never a real item. |
| 1 | `cobolcraft:baseplate` | baseplate (1) | 64 | Creative only. |
| 2 | `cobolcraft:greystone` | greystone (2) | 64 | |
| 3 | `cobolcraft:loam` | loam (3) | 64 | |
| 4 | `cobolcraft:turf` | turf (4) | 64 | |
| 5 | `cobolcraft:grit` | grit (5) | 64 | |
| 6 | `cobolcraft:cardstack` | cardstack (axis from face, punched=false) | 64 | |
| 7 | `cobolcraft:lucite` | lucite (12) | 64 | |
| 8 | `cobolcraft:glowtube` | glowtube (13) | 64 | |
| 9 | `cobolcraft:ledger_tile` | ledger_tile (15) | 64 | |
| 10 | `cobolcraft:pry_bar` | — | 1 | Tool. Divides break time by 4 for "hard" class blocks (greystone, cardstack, ledger_tile). |
| 11 | `cobolcraft:trowel` | — | 1 | Tool. Divides break time by 4 for "soft" class blocks (loam, turf, grit). |

Tools have no durability in the stand-in. Lucite and glowtube are in no class and break at hand speed with
any item. In creative, every break is instant.

Item icons: a block item uses its block's texture (the top face for turf, the end face for cardstack) drawn
as a flat 16 × 16 icon. Tool icons, on a transparent background:

- `pry_bar`: a 2-px-wide `#9AA3AD` line from (2, 13) to (12, 3), with a 3-px hook in `#9AA3AD` bending
  left at the top end and a `#C24A3A` grip over the bottom 4 px.
- `trowel`: a filled `#B8BEC6` triangle with corners (8, 1), (3, 9), (13, 9); a 2-px `#6B4A2B` handle from
  (8, 10) to (8, 15).

Suggested starting inventory (survival testing): hotbar slots 1–9 hold items 2–9 (×64 each) and the
pry bar; the trowel goes in the first main-inventory slot.

---

## 3. Entity types

| Entity type id | Key | Size (width × height) | Eye height | Notes |
|---|---|---|---|---|
| 0 | `cobolcraft:operator` | 0.7 × 1.75 | 1.6 | Player-equivalent. Used for the joining player's own entity and in Add Entity (05a, id 1) for other players. Sends no entity metadata in the stand-in. |
| 1 | `cobolcraft:loose_item` | 0.3 × 0.3 | 0.15 | **Optional.** A dropped item. Not needed for the first milestone (section 1.3 puts broken blocks straight into the inventory). Add it when testing pickup. Its sprite is the item icon drawn as a billboard. |

Operator appearance (placeholder): an axis-aligned box of the size above. Faces filled `#3A5A9A`. The face
toward the look direction has two 2 × 2 `#F0F0F0` "eyes" in its upper third. No limbs or animation.

---

## 4. Synchronized registries

### 4.1 How to send them

- **Known packs.** Send Select Known Packs with an **empty list** (or skip it). Every entry is sent with
  Data present. This is the simplest correct behaviour in 04 §2.
- **Order.** Order the Registry Data packets as in 04 §3. The client does not depend on that order, but
  keeping it makes byte-level comparison against reference captures easier.
- **Entry order is the id.** The tables below list entries in id order (04 §4).
- **Empty registries.** For a registry left empty, send no Registry Data packet at all (04 §3.2 item 5).
- **No vanilla static references in entry data.** Wherever a field points into a static registry (sound
  events, blocks, items, environment attributes), we either use an inline form with our own identifier or
  leave the field at its default. That keeps tier A free of vanilla static vocabulary.

Key to the "Class" column:

- **MV** — mandatory by validation: the vanilla client's non-empty validator or a hard-coded key lookup
  fails without it (04 §3.2). Needed for tier B only; our own client does not need it.
- **NJ** — needed by the join flow or by the first-milestone play loop, in tier A.
- **OE** — optional, left empty.

### 4.2 Summary

| # | Registry | Class | Entries sent |
|---|---|---|---|
| 0 | `worldgen/biome` | NJ + MV (`minecraft:plains`) | 2 |
| 1 | `chat_type` | NJ (only once chat is wired up) | 1 |
| 2 | `trim_pattern` | OE | 0 |
| 3 | `trim_material` | OE | 0 |
| 4 | `wolf_variant` | MV | 1 |
| 5 | `wolf_sound_variant` | MV | 1 |
| 6 | `pig_variant` | MV | 1 |
| 7 | `pig_sound_variant` | MV | 1 |
| 8 | `frog_variant` | MV | 1 |
| 9 | `cat_variant` | MV | 1 |
| 10 | `cat_sound_variant` | MV | 1 |
| 11 | `cow_sound_variant` | MV | 1 |
| 12 | `cow_variant` | MV | 1 |
| 13 | `chicken_sound_variant` | MV | 1 |
| 14 | `chicken_variant` | MV | 1 |
| 15 | `zombie_nautilus_variant` | MV | 1 |
| 16 | `painting_variant` | MV | 1 |
| 17 | `sulfur_cube_archetype` | OE | 0 |
| 18 | `dimension_type` | NJ | 1 |
| 19 | `damage_type` | MV (25 compat keys) + NJ (3 of ours) | 28 |
| 20 | `banner_pattern` | OE | 0 |
| 21 | `enchantment` | OE | 0 |
| 22 | `jukebox_song` | OE | 0 |
| 23 | `instrument` | OE | 0 |
| 24 | `test_environment` | OE | 0 |
| 25 | `test_instance` | OE | 0 |
| 26 | `dialog` | OE | 0 |
| 27 | `world_clock` | NJ (recommended; see 4.8) | 1 |
| 28 | `timeline` | OE | 0 |
| 29 | `decorated_pot_pattern` | OE | 0 |
| 30 | `block_transformer` | OE | 0 |
| 31 | `worldgen/block_state_provider` | OE | 0 |

That is 18 Registry Data packets and 45 entries. A tier-A-only server could drop the 13 MV variant
registries and the 25 compat damage keys. The recommendation is to keep them, because they are cheap and keep
tier B working.

### 4.3 `worldgen/biome`

| Id | Key | has_precipitation | temperature | downfall | effects | attributes |
|---|---|---|---|---|---|---|
| 0 | `minecraft:plains` **[compat name]** — our "lowland" | 0 | 0.6 | 0.4 | water_color `"#3A6EA5"`, grass_color `"#4F8F3A"`, foliage_color `"#4F8F3A"` | absent (empty) |
| 1 | `cobolcraft:upland` | 0 | 0.3 | 0.2 | water_color `"#2F5C8C"`, grass_color `"#6B9A55"`, foliage_color `"#6B9A55"` | absent (empty) |

- `temperature_modifier`, `dry_foliage_color` and `grass_color_modifier` are left absent (defaults).
- `minecraft:plains` is used only because the vanilla client looks it up as its fallback biome. In our game
  it means "lowland". It is placed at id 0 so that it is also the natural fallback for our client.
- With 2 biomes, the global biome palette is `ceillog2(2) = 1` bit. Sections spanning both biomes use the
  Linear palette at 1 bit; others use single value.
- No precipitation anywhere, so weather never needs rendering.

### 4.4 `chat_type`

| Id | Key | chat | narration |
|---|---|---|---|
| 0 | `cobolcraft:say` | translation_key `cobolcraft.chat.say`, parameters [`sender`, `content`], no style | translation_key `cobolcraft.chat.say.narrate`, parameters [`sender`, `content`] |

Our client's language table maps `cobolcraft.chat.say` to "<%s> %s" and the narrate key to "%s says %s".
Not needed until chat is implemented; join works without it. System messages do not use a chat type.

### 4.5 Mandatory variant registries (MV)

Each of the 13 registries gets **one** entry with key `cobolcraft:placeholder`. None of them is used by our
game. They exist only so a vanilla client passes its non-empty validators.

Shared placeholder values:

- **Texture** (ResourceTexture): `"cobolcraft:entity/placeholder"`. Our client never resolves it.
- **Sound** (SoundEvent): the inline compound `{sound_id: "cobolcraft:silent"}` with no `range`. The inline
  form is used deliberately: a bare string would be an id reference into the static `sound_event` registry,
  which our identifier is not in.

| Registry | Entry data |
|---|---|
| `wolf_variant` | `assets` and `baby_assets` are each `{wild, tame, angry}`, all set to the placeholder texture. |
| `wolf_sound_variant` | `adult_sounds` and `baby_sounds` each set all seven fields (ambient_sound, death_sound, growl_sound, hurt_sound, pant_sound, whine_sound, step_sound) to the placeholder sound. |
| `pig_variant` | `model` `"normal"`, `asset_id` and `baby_asset_id` the placeholder texture. |
| `pig_sound_variant` | `adult_sounds` and `baby_sounds` each set ambient_sound, hurt_sound, death_sound, step_sound and eat_sound to the placeholder sound. |
| `frog_variant` | `asset_id` the placeholder texture. |
| `cat_variant` | `asset_id` and `baby_asset_id` the placeholder texture. |
| `cat_sound_variant` | `adult_sounds` and `baby_sounds` each set all nine fields (ambient_sound, stray_ambient_sound, hiss_sound, hurt_sound, death_sound, eat_sound, beg_for_food_sound, purr_sound, purreow_sound) to the placeholder sound. |
| `cow_sound_variant` | ambient_sound, hurt_sound, death_sound and step_sound directly on the entry, all the placeholder sound. |
| `cow_variant` | `model` `"normal"`, `asset_id` and `baby_asset_id` the placeholder texture. |
| `chicken_sound_variant` | `adult_sounds` and `baby_sounds` each set ambient_sound, hurt_sound, death_sound and step_sound to the placeholder sound. |
| `chicken_variant` | `model` `"normal"`, `asset_id` and `baby_asset_id` the placeholder texture. |
| `zombie_nautilus_variant` | `model` `"normal"`, `asset_id` the placeholder texture. |
| `painting_variant` | `width` 1, `height` 1, `asset_id` `"cobolcraft:placeholder"`, `title` the plain string `"Placeholder"`, no author. |

### 4.6 `dimension_type`

One entry. It is the only dimension type, so its id is 0, which the Login packet's CommonPlayerSpawnInfo
carries.

| Id | Key |
|---|---|
| 0 | `cobolcraft:surface` |

| Field | Value | Why |
|---|---|---|
| has_fixed_time | absent (false) | Day/night may advance. |
| has_skylight | 1 | Sky light is sent in chunk packets. |
| has_ceiling | 0 | |
| has_ender_dragon_fight | 0 | Required field with no meaning for us. Always false. |
| coordinate_scale | 1.0 (Double) | |
| min_y | 0 | Multiple of 16. Keeps every Y non-negative, which simplifies the COBOL arithmetic. |
| height | 256 | Multiple of 16, at least 16; min_y + height = 256 ≤ 2032. |
| logical_height | 256 | ≤ height. |
| infiniburn | empty List `[]` | Required HolderSet over static `block`. An empty list names no block and no tag, so neither vanilla block names nor an Update Tags entry are needed. |
| ambient_light | 0.0 | |
| monster_spawn_light_level | Int 0 (constant form) | No monsters exist; any value in 0–15 is fine. |
| monster_spawn_block_light_limit | 0 | |
| skybox | absent (default `overworld`) | Protocol enum constant naming the client's sky mode, not content. |
| cardinal_light | absent (default) | |
| attributes | absent (empty) | Avoids vanilla `environment_attribute` keys. Our client uses its own sky and fog constants. |
| timelines | absent (empty) | |
| default_clock | `"cobolcraft:daylight"` | Refers to the `world_clock` entry in 4.8. |

Derived geometry (06 §1, §3.1, §7):

- 16 block sections, section Y 0–15. Min section Y = 0.
- Light covers 18 sections, section Y −1 to 16; light-mask bit i is section Y i − 1.
- Heightmap entries are `ceillog2(257) = 9` bits wide: 7 per Long, 37 Longs per heightmap.

### 4.7 `damage_type`

Our own three come first. The compat block follows.

| Id | Key | message_id | scaling | exhaustion | effects | death_message_type |
|---|---|---|---|---|---|---|
| 0 | `cobolcraft:generic` | `cobolcraft.generic` | `never` | 0.0 | absent | absent |
| 1 | `cobolcraft:impact` | `cobolcraft.impact` | `never` | 0.0 | absent | absent |
| 2 | `cobolcraft:below_world` | `cobolcraft.below_world` | `never` | 0.0 | absent | absent |
| 3–27 | the 25 compat keys below, in the listed order | `cobolcraft.compat` | `never` | 0.0 | absent | absent |

Compat keys **[compat name]**, ids 3 to 27 in this order:

`minecraft:in_fire`, `minecraft:campfire`, `minecraft:lightning_bolt`, `minecraft:on_fire`,
`minecraft:lava`, `minecraft:hot_floor`, `minecraft:in_wall`, `minecraft:cramming`, `minecraft:drown`,
`minecraft:starve`, `minecraft:cactus`, `minecraft:fall`, `minecraft:ender_pearl`,
`minecraft:fly_into_wall`, `minecraft:fell_out_of_world`, `minecraft:generic`, `minecraft:magic`,
`minecraft:wither`, `minecraft:dragon_breath`, `minecraft:dry_out`, `minecraft:sweet_berry_bush`,
`minecraft:freeze`, `minecraft:stalagmite`, `minecraft:outside_border`, `minecraft:generic_kill`.

- These names are kept **only** because the vanilla client's `DamageSources` looks them up by exact key.
  They carry no meaning in our game, our server never emits them, and they all share one placeholder value.
- **Verified.** These 25 keys match the set the 26.3 `DamageSources` constructor resolves (checked against the jar; see 04 §3.2). An earlier draft used the old name `out_of_world`, which is corrected here to `fell_out_of_world`.
- Our server uses ids 0–2 in any packet that names a damage type.

### 4.8 `world_clock`

| Id | Key | Data |
|---|---|---|
| 0 | `cobolcraft:daylight` | empty Compound |

Classed NJ as a recommendation, not a proven requirement. It gives Set Time (05b, id 115) a clock to report
and gives the dimension type a `default_clock`. If it turns out to be unnecessary, drop both the entry and
`default_clock`, and send Set Time with an empty clock map. Day length is our own: 24,000 ticks for a full
cycle at rate 1.0 is a placeholder.

### 4.9 Optional-empty registries (OE)

`trim_pattern`, `trim_material`, `sulfur_cube_archetype`, `banner_pattern`, `enchantment`,
`jukebox_song`, `instrument`, `test_environment`, `test_instance`, `dialog`, `timeline`,
`decorated_pot_pattern`, `block_transformer`, `worldgen/block_state_provider`: **no packet sent**. None
has a validator, and nothing in the first milestone references them.

---

## 5. Dimension and world generator

### 5.1 Dimension

| Item | Value |
|---|---|
| Level (dimension) key | `cobolcraft:main` |
| Dimension type | `cobolcraft:surface` (id 0) |
| Y range | 0 to 255 (min_y 0, height 256) |
| Sea level (CommonPlayerSpawnInfo) | 48. Nominal only; there is no water. |
| Login "dimension names" | [`cobolcraft:main`] |
| Is flat / is debug | false / false |
| Hashed seed | 0 for the stand-in |
| Game mode | 1 (creative) for the first milestone, then 0 (survival) to test break timing. Previous game mode: absent (0). |
| View distance / simulation distance | 8 / 8 |

### 5.2 Generator

Deterministic and stateless: any column can be generated on its own from its (x, z) alone. No seed is used
yet.

**Surface height.** For world block column (x, z), the surface height h is 52 plus 6 times sin(x / 23)
times cos(z / 31), with angles in radians, rounded to the nearest integer. h therefore lies between 46 and 58.
That produces gentle, repeating ridges and valleys with no noise library.

**Layers in each column**, bottom to top:

| Y | Block |
|---|---|
| 0 | baseplate |
| 1 to h − 4 | greystone |
| h − 3 to h − 1 | loam |
| h | turf if h ≥ 50, otherwise grit |
| h + 1 to 255 | void |

**Markers.** In every chunk whose chunk X and chunk Z are both multiples of 4, at local (8, 8) with that
column's height h, place:

- cardstack (state 9: axis=y, punched=false) at h + 1 and h + 2;
- cardstack (state 8: axis=y, punched=true) at h + 3;
- lucite (12) at h + 4;
- glowtube lit (13) at h + 5.

That puts most block states, a transparent block and a light source on screen without player action.

**Biomes.** For each 4 × 4 × 4 biome cell, take the surface height at the cell's lowest-x, lowest-z
corner column. If it is 55 or more, the biome is `cobolcraft:upland` (id 1); otherwise `minecraft:plains`
(id 0). The value is the same for every cell in a column, whatever the cell's Y.

**What this means for chunk payloads.**

- Sections 0–3 (Y 0–63) hold terrain; sections 4–15 are entirely void and are single-value palettes of
  state 0 with a non-empty count of 0.
- Terrain sections hold 2–8 distinct states and always use the 4-bit Linear palette.
- Heightmaps (WORLD_SURFACE, MOTION_BLOCKING, MOTION_BLOCKING_NO_LEAVES) are identical. Each stores the
  topmost non-void Y + 1, because min_y is 0. Marker columns count the marker blocks.
- Block entities: none.

**Light (stand-in policy).**

- Sky light: 15 in every void cell at or above the column's top non-void block + 1; 0 everywhere at or
  below it. There is no sideways spreading, and lucite does not let sky light through in the stand-in.
  Light sections fully at 15 are sent as arrays; light sections fully at 0 go in the empty mask.
- Block light: from each lit glowtube, level 15 at the block, minus 1 per block of taxicab distance through
  non-opaque cells, down to 0. Generated chunks contain only marker glowtubes. Recompute the affected
  sections when a glowtube is placed, broken or toggled.
- This is deliberately crude. It exists to exercise the LightData encoding, not to look right.

**Spawn point.** Feet at (4.5, 54.0, 8.5), facing east (+X). Column (4, 8) has h = 52 + round(6 × sin(4/23) ×
cos(8/31)) = 52 + round(1.004) = 53, so the player stands on its turf. Chunk (0, 0) is a marker chunk, so the
marker pillar at (8, 55–59, 8) is four blocks ahead in plain view. (The column (8, 8) itself is not used
because the pillar occupies it.)

---

## 6. Tags

**None are required for the join flow.**

- `dimension_type.infiniburn` uses an empty list, not a tag (4.6).
- No synchronized entry above references a `#tag`.
- Recommendation: send **one Update Tags packet with zero registries** during configuration. That exercises
  the packet path at no risk. 04 §1 shows a partial or empty tag set is tolerated: unknown ids are dropped,
  and a tag-less registry simply has no tags.

Optional tags for our client's own logic, which may be sent later over the static registries (04 §5.3).
They use our own tag names:

| Registry | Tag | Members (numeric ids) |
|---|---|---|
| `minecraft:block` | `cobolcraft:hard` | 2 greystone, 6 cardstack, 9 ledger_tile |
| `minecraft:block` | `cobolcraft:soft` | 3 loam, 4 turf, 5 grit |
| `minecraft:item` | `cobolcraft:tools` | 10 pry_bar, 11 trowel |

If they are sent, the client should take tool speed from the tags rather than hard-coding section 2's
"class" lists. Until then both sides hard-code those lists.

---

## 7. Stand-in → replace later checklist

- [ ] Block set, names, break times and textures (section 1). Grow the state registry past 16 so the
      HashMap and Global chunk palettes are actually reached.
- [ ] Real texture art and an atlas pipeline in place of the procedural recipes (1.4, 2, 3).
- [ ] Item set, stack sizes, tool behaviour; tool durability via data components (which brings in a
      `data_component_type` numbering).
- [ ] Item drops and the `loose_item` entity (1.3, 3).
- [ ] Player entity size, model and metadata (3).
- [ ] Biomes: real climate values and sky/fog via `attributes`; more than two biomes.
- [ ] Dimension height, min_y and ambient light; more than one dimension type.
- [ ] World generator: real noise, a seed, caves, water and fluids (non-zero fluid counts).
- [ ] A lighting engine in place of the column-drop sky light and taxicab block light.
- [ ] Damage types: our own set with real messages; decide whether the compat block stays (tier B).
- [ ] Chat types and their language strings.
- [ ] `world_clock` and day length; possibly a `timeline`.
- [ ] Hashed seed in CommonPlayerSpawnInfo.
- [ ] Decide whether tier B (vanilla client passes configuration) is still worth keeping. If not, drop
      the 13 MV registries and the compat damage keys.
- [ ] Sounds: our own sound identifiers. Play-phase sound packets can use the inline holder form
      (04 §4), so no static sound numbering is required.

---

## 8. Open questions

1. ~~**The exact damage_type key list.**~~ Resolved: the 25 keys in section 4.7 were checked against the 26.3 `DamageSources` constructor.
2. **Other hard-coded vanilla keys** (04 Open question 1). Play-phase code in the vanilla client may also
   look up specific chat_type, dimension_type, timeline or world_clock keys. This affects tier B in play
   only, which we have already given up, so it is low priority. If configuration itself fails in a tier B
   test, look here first.
3. **Default variant lookups.** The MV registries hold a single `cobolcraft:placeholder` entry. The
   assumption is that the vanilla client falls back to "any entry" when its preferred default key (a vanilla
   name) is absent. That is plausible, since that is what a non-empty validator would protect, but it was not
   traced. It only matters if a vanilla client spawns such a mob, which never happens in our game.
4. **Item default components** (04 Open question 2). Whether the vanilla client's
   `DataComponentInitializers` needs particular `instrument` or `jukebox_song` keys after load is not known.
   If a tier B configuration test fails after registries load, this is a likely cause; the fix would be
   compat-named placeholder entries in those registries.
5. **Empty-list HolderSet for `infiniburn`.** That an empty NBT List decodes as an empty direct holder set
   is inferred from 04 §6's HolderSet conventions. If it is rejected, use a tag string such as
   `#cobolcraft:never_burns`, and send that tag (empty) under `minecraft:block` in Update Tags. That runs into
   04 Open question 4 (unbound tags).
6. **Block-state permutation order** (04 Open question 5). The first-property-slowest Cartesian order rests
   on Guava's documented contract. Our client and server both follow the same rule, so the stand-in is
   self-consistent either way. It would only matter if we ever had to agree with vanilla numbering, which we
   do not.
7. **Is `world_clock` / `default_clock` needed at all?** Section 4.8 assumes it is useful. Nothing in 04
   proves it is required, so it is classed NJ only as a recommendation.
8. **Dimension Y bounds** (04 Open question 6). These do not affect us: min_y 0 and height 256 are well
   inside every candidate limit.
9. **Section buffer and count validation** (06 Open questions 1 and 3). Our server must write exactly 16
   sections with correct non-empty counts. Our client should decide whether it trusts the counts or
   recomputes them. Recomputing is recommended, since the cost is small at 16 states.
10. **Level key `cobolcraft:main` versus `minecraft:overworld`.** The vanilla client may treat the
    `minecraft:overworld` level key specially in play (for example compass behaviour). This is not relevant
    to tier A, and tier B does not reach play, so we keep our own key.
11. **Feature flags.** Update Enabled Features (03, id 13) is sent in configuration. The stand-in sends an
    empty list. A vanilla client may disable all items without `minecraft:vanilla`, which again affects only
    a play phase we do not support for it.
