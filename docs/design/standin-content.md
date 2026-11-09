# Content of the cobolcraft world type

Status: **content document** of the cobolcraft world type, the invented `cobolcraft:` content of the game: its 12 blocks,
18 items, 4 entity types (two of them mobs), 9 recipes, 2 dimensions, 3 biomes, procedural textures and bitmap font. The
file began as placeholder data for engineering and is re-scoped under the operator's decisions "Own world type" and
"Stand-in content" (tickets/CC-0001-client-polish.md, Decisions): the content is kept unchanged and is demoable with no jar
and no packs. What it no longer is: a source of rules. Health, hunger, damage, the hurt window, day length, movement,
commands, crafting screens, ground items and weather mechanism are the **standard rules of documents 10 to 21 in both world
types** (README R2); sections 9 to 17 keep only the content that sits on those rules, and two interim rows (§9 values and
§14.3 timing) that stay until the named gaps close (README R9). The world type mechanism is in
[world-types.md](world-types.md); the registry rows and the cobolcraft content in the standard data schemas are in
[cobolcraft-standard-core.md](cobolcraft-standard-core.md).

Wire formats, packet layouts and the id-assignment rules are in [../protocol/](../protocol/README.md). This document only
chooses *content*. Section references use these forms: "04 §5.2" is docs/protocol/04-registry-sync.md; "core §5.1" is
cobolcraft-standard-core.md; "README S21" and "README R2" are rows and rules of [README.md](README.md) (this folder);
"WT-n" is a Decision of world-types.md; "faithful §3" is faithful-pack-mapping.md; a bare "§1.4.1" is a section of this
file. Section numbers of the earlier edition are kept, so citations of content sections still resolve; the retired
sections (§7, §10, §11 apart from §11.5, §16) stay as short stubs that say where the rule lives now.

Every value in this document is exact. Where a content rule needs a pseudo-random choice, it uses the integer hash `H` of
§1.4.1, so two implementations given the same state produce the same result. A "tick" is one server (or single-player)
game tick; there are 20 ticks per second. `Time` in the rules of §12 and §14 is the total tick count of the shared world
clock `minecraft:overworld` (core §3.1, 12 §3.2); the day is 24000 ticks, so every "`Time` mod 80" or "`Time` mod 100"
rule has the same phase on both sides of a day wrap (Open question 14).

## 0. Ground rules and the two compatibility tiers

- **Namespace.** The cobolcraft world type's own content uses `cobolcraft:`. The standard world type uses `minecraft:`
  for everything, and `cobolcraft:` is where CobolCraft extends or diverges (README R1). The rule itself is stated in the
  intro of 08 and in world-types.md.
- **Protocol-required names.** A few keys must use the `minecraft:` namespace because the vanilla client looks them up by
  exact name (04 §3.2). Each such key is marked **[compat name]**. The cobolcraft world type's own client load must pass the
  vanilla validators (04 §3.2), and the shared rules read some of these keys (the damage types and chat types of core §3.5
  and §3.6, the clock of core §3.1), so where a shared rule reads an entry its value is the standard value written in core
  §3; the value of an entry no rule reads is our own minimal placeholder.
- **Registry keys are protocol vocabulary, not content.** Names such as `minecraft:dimension_type`,
  `minecraft:worldgen/biome` or `minecraft:wolf_variant` name a *slot in the protocol*. We send them as-is. Enum values that
  a codec fixes (for example skybox `overworld` or `none`, model `normal`, scaling `never`) and identifiers the protocol
  defines (for example the command suggestion type `minecraft:ask_server`) are protocol constants in the same sense.

The game owns both client and server, so two compatibility tiers exist. They map onto the world types:

| Tier | Meaning | Where it applies |
|---|---|---|
| A. Own-client | The COBOL client parses and uses everything sent. | **Required.** Both world types. |
| B. Vanilla-parse | A vanilla 26.3 client can finish the configuration phase without a registry load error (04 §3.2). | **The cobolcraft world type only**, for the configuration phase only. It costs very little and lets a reference client act as a test oracle for our Registry Data encoder. The standard world type uses the vanilla ids and registries (04 §5), and for it the vanilla client is a validation goal for play too (README R8). |

Tier B cannot extend into play for the cobolcraft world type. Its static registries (blocks, block states, items, entity
types) are original content and are never sent: a vanilla client numbers them from its own built-in tables (04 §5). Our
block state 2 would be drawn as whatever vanilla state 2 is. Original static content and a playable vanilla client are
mutually exclusive for this world type; that is accepted, and the vanilla client is an oracle for configuration only here.
The standard world type uses the vanilla numbering and has no such limit (README C1).

---

## 1. cobolcraft world: blocks

### 1.1 Blocks

Registration order defines the block id. Twelve blocks; id 0 is the air-equivalent. The hand break times of the earlier
edition are replaced by standard block properties, so the shared break formula (13 §2.1) applies: **hardness**, the
**mineable tag** (class) and the tool tier (none, core §5.1 CORE-17). The values below are the ones of core §5.1, which is
the authority for them and for the resulting break times in ticks (CORE-18, CORE-27); the nearest standard block each value
came from is listed under the table.

| Block id | Key | Properties | Solid / collides | Opaque (occludes faces, blocks light) | Light emitted | Hardness (core §5.1) | Mineable tag | Notes |
|---|---|---|---|---|---|---|---|---|
| 0 | `cobolcraft:void` | none | no | no | 0 | n/a | none | Empty space. Not targetable, not breakable, not placeable. |
| 1 | `cobolcraft:baseplate` | none | yes | yes | 0 | -1.0 (unbreakable) | none | Bottom layer of every dimension (y = 0). Creative may place it but nobody may break it (13 §2.5, §2.6). |
| 2 | `cobolcraft:greystone` | none | yes | yes | 0 | 1.5 | `mineable/pickaxe` | Bulk underground fill. |
| 3 | `cobolcraft:loam` | none | yes | yes | 0 | 0.5 | `mineable/shovel` | Subsoil. |
| 4 | `cobolcraft:turf` | none | yes | yes | 0 | 0.6 | `mineable/shovel` | Top surface on higher ground. Different top, side and bottom faces. |
| 5 | `cobolcraft:grit` | none | yes | yes | 0 | 0.5 | `mineable/shovel` | Top surface on low ground. No gravity: it is not a falling block in this world type. |
| 6 | `cobolcraft:cardstack` | `axis` (x, y, z); `punched` (true, false) | yes | yes | 0 | 0.7 | `mineable/pickaxe` | A bound stack of punch cards. Exercises the two-property Cartesian rule. |
| 7 | `cobolcraft:lucite` | none | yes | **no** | 0 | 0.3 | none | Clear block. Tests transparency and face culling. Faces between two lucite blocks are culled; faces against any opaque block are drawn on the lucite side only. |
| 8 | `cobolcraft:glowtube` | `lit` (true, false) | yes | yes | 15 when `lit=true`, 0 when `lit=false` | 0.2 | none | Light source. Exercises the one-property rule and block light. Using it (right-click without a held block) toggles `lit`. |
| 9 | `cobolcraft:ledger_tile` | none | yes | yes | 0 | 0.8 | `mineable/pickaxe` | Plain building block. |
| 10 | `cobolcraft:goto_pad` | none | yes | yes | 6 | 1.3 | none | The means of travel between dimensions (§15). Using it (Use Item On, with any held item or none) starts travel; nothing is ever placed against it and it is never toggled. |
| 11 | `cobolcraft:slag` | none | yes | yes | 0 | 0.4 | `mineable/pickaxe` | Surface fill of the `cobolcraft:subroutine` dimension (§15). |

Nearest standard block of each value (the source of the properties above, README S10, S11, decision 4, and the optional
skin mapping of faithful §3, README decision 10; they are not replacements): `void` is `air`; `baseplate` is `bedrock`;
`greystone` is `stone`; `loam` is `dirt`; `turf` is `grass_block`; `grit` is `sand`; `lucite` is `glass`; `glowtube` is
`redstone_lamp`; `slag` is `netherrack`. `cardstack`, `ledger_tile` and `goto_pad` have no equivalent; their hardness is
derived from the earlier hand times (core §5.1, CORE-18). The tools that mine the two mineable tags are in §2 and core §5.3.

**One addition (README decision 3, an adopted default).** The cobolcraft world type also carries one crafting bench block,
`cobolcraft:crafting_bench`, appended as block id 12 and state 18 (core §5.1, WT-12), so that the shared 3 x 3 crafting menu
(13 §3.5) exists in this world type. The table above, §1.2 and the texture sections keep the original twelve blocks; the
bench's texture and check values are owed (Open question 15).

All blocks are full 1 × 1 × 1 cubes. There are no fluids: every section's fluid count (06 §4) is 0 while the shared fluid
rules (GAP-9) are not enabled in this world type.

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
| 16 | goto_pad | — | yes |
| 17 | slag | — | yes |

Total: **18 block states**. Consequences for chunk encoding (06 §5.3):

- `ceillog2(18) = 5`, so the global (direct) block palette is **5 bits** wide. (With the original 16 states it
  was 4 bits; adding `goto_pad` and `slag` crossed the 16-state boundary.)
- A section with 1 distinct state is single value (bits 0). A section with 2–16 distinct states needs at most
  4 bits: the Linear palette, packed at 4 bits. A section with 17 or 18 distinct states needs 5 bits: the
  **HashMap** palette at 5 bits. Generated terrain never holds more than 9 distinct states in a section
  (§5.2, §15.2), so the HashMap kind is reached only when players build a section containing 17 or 18
  different states. The Global kind (9 bits or more) is never reached by this content; tests for it need a
  hand-crafted packet. (The standard world type's far larger state count does reach it, 06 §5.3.)
- An unknown state id decodes by the generic rule of 04 §5.2 (the default state of the air-equivalent, here state 0 of
  `void`).

### 1.3 Placement, breaking and block yields

- Placing a block item puts the block's **default state**, except:
  - `cardstack`: `axis` follows the clicked face's axis (top/bottom face → y, east/west → x,
    north/south → z); `punched=false`.
- Which positions accept a block, and the overlap test with players and mobs, are the shared placement rule (GAP-30). Its
  cobolcraft instance: a position can receive a block only if it currently holds `void` (core §4.1 proposes the tag
  `minecraft:replaceable` with `void` as its only member) and lies inside the dimension's height range.
- Use Item On a `goto_pad` never places a block, whatever is held: it starts travel (§15.5). Use Item On a
  `glowtube` with no block item held toggles `lit`; with a block item held it places against the glowtube
  as against any other block. Use Item On with a non-block item held (tools, food, `dump_shard`) places
  nothing.
- Breaking sets the position to state 0 (`void`). `baseplate` refuses (hardness -1.0, §1.1).
- **Block yields (FR-002).** The yield of a block is its item, one of it, from the block's loot table (core §5.6); the
  dropped stack is an item entity with the shared rules (18 §6.11: pickup delay 10, lifetime 6000, merging; §9). The
  block's item is the item that places it (§2): block id 2–9 → item id 2–9 (every `cardstack` state →
  item 6, both `glowtube` states → item 8), `goto_pad` → item 16, `slag` → item 17. The creative rule (a break yields
  nothing, and is instant) is 13 §2.5. The earlier position, motion and delay rules for the dropped item are retired
  (README S15, S50).

### 1.4 Placeholder textures

All block textures are **16 × 16** RGBA, generated procedurally at startup. Every recipe below admits
exactly one RGBA image; §1.4.1 defines the vocabulary the recipes use, and §1.5 lists check values. They are the art of
the built-in pack of the cobolcraft world type (08 §10.3). The rules for the standard world type's textures are in 08,
14 and faithful; Faithful's `minecraft:` textures do not bind to these `cobolcraft:` blocks except through the optional
skin of faithful §3.

#### 1.4.1 Drawing rules (shared by every procedural texture in this document)

- **Coordinates.** Pixel (x, y): x is the column, 0 at the left; y is the row, 0 at the top (PNG order).
  A 16 × 16 texture has x and y from 0 to 15.
- **Colours.** `#RRGGBB` is that colour with alpha 255 unless an alpha is stated. "Alpha p %" means the alpha
  byte round(p × 255 / 100) with halves rounded up; the values used are 60 % = 153, 66 % = 168, 80 % = 204,
  92 % = 235. **Transparent** means RGBA (0, 0, 0, 0). A texture that is not filled starts transparent.
- **Order.** Recipe steps are applied in the order written; a later step overwrites the pixels it names.
- **Integer hash `H`.** All arithmetic is on non-negative integers; `div` is integer division (floor) and
  `mod` the non-negative remainder. For a negative input v, "v mod 4294967296" is the mathematical
  remainder (for example −1 → 4294967295).
  - `mix(v)` for 0 ≤ v < 4294967296:
    1. v ← (v × 2654435761) mod 4294967296
    2. v ← (v div 65536) + (v mod 65536) × 65536 (swap the two 16-bit halves)
    3. v ← (v × 2246822519) mod 4294967296
    4. v ← (v div 65536) + (v mod 65536) × 65536
  - `H(v1, …, vn)`: h ← 2166136261; for each vi in order, h ← mix((h + (vi mod 4294967296)) mod
    4294967296); the result is h (0 ≤ h < 4294967296). Every product fits in 64 unsigned bits.
  - Check values: mix(0) = 0; mix(1) = 4052846564; H(0) = 652388419; H(1, 2) = 1898060780;
    H(−1) = 1792697577.
- **Noise.** "Noise `name`: fill F; p1 % C1, p2 % C2" means: for every pixel, n = H(b1, …, bk, x, y) mod 100,
  where b1 … bk are the ASCII byte values of the texture name `name` (the file stem of 08 §10.3, for example
  `greystone` or `turf_top`); the pixel is C1 if n < p1, C2 if p1 ≤ n < p1 + p2, and F otherwise. The
  percentages are therefore probabilities per pixel, not exact counts (the exact counts are in §1.5). Check
  value: for `greystone`, H(103, 114, 101, 121, 115, 116, 111, 110, 101, 0, 0) = 1030435555, so n at (0, 0)
  is 55 and the pixel is the fill colour; n at (15, 15) is 10, giving `#6C6E75`.
- **Border.** "A 1-px border" of a rectangle is every pixel of the rectangle in its first or last column or
  its first or last row. Without a named rectangle it is the whole texture: x ∈ {0, 15} or y ∈ {0, 15}.
- **Rectangle** `R(x0, y0, x1, y1)`: every pixel with x0 ≤ x ≤ x1 and y0 ≤ y ≤ y1 (both corners included).
- **Line** `L(x0, y0, x1, y1, w)`: let dx = x1 − x0, dy = y1 − y0, n = max(|dx|, |dy|), and sgn the sign
  (−1, 0 or 1). If n = 0 the centre pixels are just (x0, y0); otherwise for i = 0 … n the centre pixel is
  xi = x0 + sgn(dx) × ((2 × i × |dx| + n) div (2 × n)), yi = y0 + sgn(dy) × ((2 × i × |dy| + n) div (2 × n)).
  Width: if |dx| > |dy| (shallow line) each centre pixel (xi, yi) contributes (xi, yi + k) for
  k = 0 … w − 1 (thickened downward); otherwise (steep or exactly diagonal) it contributes (xi + k, yi) for
  k = 0 … w − 1 (thickened to the right). Pixels outside the texture are dropped.
- **Triangle** `T(A, B, C)` with integer corners: pixel (x, y) is filled when the three edge values
  E(A, B), E(B, C), E(C, A) are all ≥ 0 or all ≤ 0, where E(P, Q) = (Qx − Px) × (y − Py) − (Qy − Py) ×
  (x − Px). Pixels on an edge are therefore filled (inclusive rule); corners are pixel centres.

#### 1.4.2 Block texture recipes

| Block | Face(s) | Texture (file stem) | Recipe |
|---|---|---|---|
| void | — | — | Not rendered. |
| baseplate | all | `baseplate` | Fill `#2B2B33`. Every pixel with x mod 4 = y mod 4, or (x mod 4) + (y mod 4) = 3, is `#45454F` (both diagonals of every 4 × 4 cell: a fine crosshatch). |
| greystone | all | `greystone` | Noise `greystone`: fill `#7D7F86`; 20 % `#6C6E75`, 8 % `#8E9097`. |
| loam | all | `loam` | Noise `loam`: fill `#7A5634`; 15 % `#664629`, 5 % `#8C6640`. |
| turf | top | `turf_top` | Noise `turf_top`: fill `#4F8F3A`; 20 % `#447D32`, 10 % `#5CA044`. |
| turf | sides | `turf_side` | Pixel (x, y) is the `turf_top` texture's pixel (x, y) when y ≤ 3, or when y = 4 and x is even; every other pixel is the `loam` texture's pixel (x, y). (The noise is evaluated with the names `turf_top` and `loam`, so those rows are identical to those textures.) |
| turf | bottom | `loam` | The loam texture itself. |
| grit | all | `grit` | Noise `grit`: fill `#D2C08A`; 30 % `#C2AE76`, 10 % `#E0D09E`. |
| cardstack | ends (the two faces normal to `axis`) | `cardstack_end` | Fill `#EDE6CF`. A 1-px border in `#B9AE8C`. |
| cardstack | sides, `punched=false` | `cardstack_side` | Fill `#EDE6CF`. Every pixel with y odd is `#B9AE8C` (the card edges: eight 1-px horizontal lines at y = 1, 3, …, 15). The lines are horizontal in the texture; the block state file turns them so they cross the stack's long direction (08 §10.3, §10.6). |
| cardstack | sides, `punched=true` | `cardstack_side_punched` | The `cardstack_side` recipe, then every pixel with y ∈ {2, 10} and x mod 4 ∈ {1, 2} is `#2A2A2A` (punched holes: four 2 × 1 holes in each of the card rows y = 2 and y = 10, 16 pixels). |
| lucite | all | `lucite` | Transparent interior. A 1-px border in `#BFE6F2` at alpha 60 %. Then the "glint", the three pixels (2, 4), (3, 3) and (4, 2) (a diagonal rising to the right near the top-left corner), in `#FFFFFF` at alpha 80 %. |
| glowtube | all, `lit=true` | `glowtube_lit` | Fill `#FFE38A`. `R(6, 0, 9, 15)` (a 4-px-wide vertical bar in the centre) in `#FFF6D0`. Then a 1-px border in `#A08A3C` (the border overwrites the bar's end pixels). |
| glowtube | all, `lit=false` | `glowtube_unlit` | The same three steps with `#7A6E4A` fill, `#8F8460` bar, `#4E4630` border. |
| ledger_tile | all | `ledger_tile` | Pixel (x, y) is `#24425A` if x mod 8 = 0 or y mod 8 = 0 (grid lines on columns 0 and 8 and rows 0 and 8); otherwise `#3E6C8F` if (x div 4) + (y div 4) is even and `#355D7B` if it is odd (a 4 × 4 checkerboard). |
| goto_pad | all | `goto_pad` | With ring r = min(x, y, 15 − x, 15 − y): r = 0 → `#3B2F5C`; r ∈ {1, 3, 5} → `#1F1B2E`; r ∈ {2, 4} → `#6A4FB3`; r ≥ 6 (the central 4 × 4) → `#C9B8FF`. |
| slag | all | `slag` | Noise `slag`: fill `#4A3F3A`; 25 % `#3A302C`, 12 % `#6E4A32`. |
| (missing texture) | — | — | Pixel (x, y) is `#F28C28` if ((x + y) div 2) mod 2 = 0, otherwise `#1A1A1A`: 2-px diagonal stripes running from bottom-left to top-right. Used for any unknown block, item, entity or environment texture; for a texture of another size the same formula is applied at that size. Engine-generated, not a pack file, for both world types: the standard missing sprite is the magenta and black pattern of 14 §3.1, and the colours here are CobolCraft's own and are kept (README S18, decision 12). |

Shading: the per-face brightness and smooth lighting of the renderer are the shared rules of 12 §1.1 to §1.8 (they agree with
the fixed factors of the earlier edition, 12 §0; CC-0007). That is renderer policy, not texture content.

### 1.5 Check values for every procedural texture

The rules of §1.4, §2, §3, §12 and §14 are normative. The table lists, for each texture they produce, the
pixel count of every colour and the SHA-256 of the raw RGBA bytes (rows top to bottom, pixels left to right,
bytes R, G, B, A). Both were computed from the rules; if a value here ever disagrees with a rule, the
document is wrong and is corrected first (FR-005). `@a` marks a colour with alpha a.

| Texture | Size | Pixel counts | SHA-256 of RGBA |
|---|---|---|---|
| `baseplate` | 16 × 16 | `#2B2B33` 128, `#45454F` 128 | `2bbb7aa0d530f0d38100c79ea2f80df44b27cde5a5518caa1c650664bce7a916` |
| `greystone` | 16 × 16 | `#7D7F86` 187, `#6C6E75` 52, `#8E9097` 17 | `b473ead8649daf8186bd2a303e4f6f3288831c63b7e327177eb0fa3b2b566cee` |
| `loam` | 16 × 16 | `#7A5634` 204, `#664629` 42, `#8C6640` 10 | `e208539e46fed7bfb2d1e5c9d092de1ab14a7cd49619b334512416e189363310` |
| `turf_top` | 16 × 16 | `#4F8F3A` 177, `#447D32` 48, `#5CA044` 31 | `15304ea35bf48575eb0529c4c8faf654fc3faa58bfbe122649361f82e155bee6` |
| `turf_side` | 16 × 16 | `#7A5634` 143, `#4F8F3A` 50, `#664629` 34, `#447D32` 14, `#5CA044` 8, `#8C6640` 7 | `d6fe9df78922c412c393a463032d2292fbaa7a94b80f2a0e14927a724a4e2e43` |
| `grit` | 16 × 16 | `#D2C08A` 151, `#C2AE76` 78, `#E0D09E` 27 | `dac28fa900d75b16ba7c5c184595ab0082bf99fde3565151c98f86b7b38440e4` |
| `cardstack_end` | 16 × 16 | `#EDE6CF` 196, `#B9AE8C` 60 | `1a9aa27fa59204d40e155a37421c2375a4c67f5cee13be111cb5b626a24d7ced` |
| `cardstack_side` | 16 × 16 | `#B9AE8C` 128, `#EDE6CF` 128 | `9302182c5129392eed4fb193fb73718e646685703f150a0cda0884e23c5b0157` |
| `cardstack_side_punched` | 16 × 16 | `#B9AE8C` 128, `#EDE6CF` 112, `#2A2A2A` 16 | `1be7e736442bf273808251bde69e62ddca33e7de2f836adf50c54c54a6796362` |
| `lucite` | 16 × 16 | transparent 193, `#BFE6F2@153` 60, `#FFFFFF@204` 3 | `d09fd8bda8db1bd837e0096bd0edbdc3229d0603513ac0462631588fc8593a3e` |
| `glowtube_lit` | 16 × 16 | `#FFE38A` 140, `#A08A3C` 60, `#FFF6D0` 56 | `c48a12dbd68706cdba82a23dcd0ce8e37c3da8981b058bf5d7fe558d16f95793` |
| `glowtube_unlit` | 16 × 16 | `#7A6E4A` 140, `#4E4630` 60, `#8F8460` 56 | `3b96aecd64b6d66802b22d7b0de174536b110b8bde71694a5988db1df5568489` |
| `ledger_tile` | 16 × 16 | `#3E6C8F` 100, `#355D7B` 96, `#24425A` 60 | `841ce48a8d3082c3ef57c9f9f9dbf14b43cdffcf282c94400252b0c6882f72a4` |
| `goto_pad` | 16 × 16 | `#1F1B2E` 108, `#6A4FB3` 72, `#3B2F5C` 60, `#C9B8FF` 16 | `65ebc8ad125c36645f3f1b2314f0e22d9b9e11d2eab47d90ab0f6a0f8c5c7801` |
| `slag` | 16 × 16 | `#4A3F3A` 160, `#3A302C` 63, `#6E4A32` 33 | `e4998305a40ef5c665430d402e09b291fd42a333d89a785c6fe78d4fbc453685` |
| `missing` | 16 × 16 | `#1A1A1A` 128, `#F28C28` 128 | `e02de2199f86fa3741e8247e922b875409013958658f413c8ff4f22390e72f6e` |
| `pry_bar` | 16 × 16 | transparent 228, `#9AA3AD` 20, `#C24A3A` 8 | `a69fa3d81cfdbe97856c4f8c3644706c103fcedcecf69430872671dc910fc3fa` |
| `trowel` | 16 × 16 | transparent 197, `#B8BEC6` 47, `#6B4A2B` 12 | `5db08a94e8ee6043db28cfe5837f09fece450503909d39d0478151570c687036` |
| `grazer_flank` | 16 × 16 | transparent 195, `#B5544A` 49, `#E3B7A0` 6, `#EDE6CF` 6 | `eb3ed5a8b379b98d1fcf3cea90fa91cf9748dd95e00471310d39dd0fa455e449` |
| `seared_flank` | 16 × 16 | transparent 195, `#6E3B22` 49, `#A0623A` 6, `#EDE6CF` 6 | `b53d86d09809b24d11f88e04d266e525a9742c0d9f462d592522263ce2a206dc` |
| `sod_cake` | 16 × 16 | transparent 166, `#7A5634` 60, `#4F8F3A` 20, `#5A3F26` 10 | `44bb3a608442514240e1fd5a235fa779b0b01fd3112dc0606a0cbc224c61524f` |
| `dump_shard` | 16 × 16 | transparent 221, `#8F7CFF` 27, `#E8F04A` 8 | `71bf66cf5d7ab57a3695370af7a25af0fcbb7f66c52fd59a271671fefa2c4d23` |
| `drizzle` | 16 × 16 | transparent 236, `#A7C1DC@168` 20 | `6d18e91a3dc51a2d407a37364c0c5dad703fe42224e4b484bdbea1ead279c2a6` |
| `hailstorm` | 16 × 16 | transparent 192, `#EEF2F7@235` 64 | `8491fbe46d9ffbd115acba19d9959967465dd86f7aca5527a59a28ef81b3e67f` |
| `operator` | 66 × 28 | `#3A5A9A` 1466, transparent 374, `#F0F0F0` 8 | `63ec194d41ecc3c146401c1569e04ac735691008a1b966183a2d0cbe7a044227` |
| `sodgrazer` | 80 × 23 | transparent 694, `#5E7A3C` 524, `#8A7458` 284, `#4F6A31` 192, `#708C4A` 88, `#6B5A44` 54, `#1C1C1C` 4 | `3df378dfb09b75d13e401d01f0bf0e625383da7d3f56fc0a0fe204ad19819c28` |
| `abend` | 72 × 12 | `#2E2A4F` 500, `#8F7CFF` 264, `#4A4580` 88, `#E8F04A` 12 | `050a68af7d5389077d857102cc301f6bd8f65ac79e610385a91e0878574dcb5f` |

---

## 2. Item registry

Item ids are our own static numbering (the standard world type's are the vanilla registration order, 04 §5.1). On the wire
an item appears as `RegistryId<item>` inside an ItemStack (00 §12.1). Stacks are encoded as 00 §12.1 in both world types.
The cobolcraft items carry **no data components in a stack**: every non-empty stack is sent with AddedCount = 0 and
RemovedCount = 0, a valid empty patch (README S22), so no `data_component_type` numbering is needed for stacks. The items'
own default components (stack size, `tool`, `food`, `consumable`, attack modifiers) are the prototype components of core
§5.2 to §5.4 and are not repeated here, except the maximum stack size.

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
| 10 | `cobolcraft:pry_bar` | — | 1 | Tool: a `tool` component with mining speed 4.0 on `#minecraft:mineable/pickaxe`, attack damage 4 (core §5.3). Mines the pickaxe class of §1.1. |
| 11 | `cobolcraft:trowel` | — | 1 | Tool: a `tool` component with mining speed 4.0 on `#minecraft:mineable/shovel`, attack damage 2 (core §5.3). Mines the shovel class of §1.1. |
| 12 | `cobolcraft:grazer_flank` | — | 32 | Food (§11.5), `food` nutrition 3 (core §5.4). Yield of the sodgrazer (§12). |
| 13 | `cobolcraft:seared_flank` | — | 32 | Food (§11.5), nutrition 8. Recipe 6 (§13). |
| 14 | `cobolcraft:sod_cake` | — | 16 | Food (§11.5), nutrition 2. Recipe 5 (§13). |
| 15 | `cobolcraft:dump_shard` | — | 64 | Crafting material. Yield of the abend (§12); recipe 8 (§13). |
| 16 | `cobolcraft:goto_pad` | goto_pad (16) | 16 | The travel block (§15). Recipe 7 (§13). |
| 17 | `cobolcraft:slag` | slag (17) | 64 | Building block from the Subroutine (§15). |

The bench item `cobolcraft:crafting_bench` is appended as item id 18 (README decision 3, core §5.2); see the addition note
of §1.1.

English names (08 §10.8) of the blocks and items added by the extension: `goto_pad` "GOTO Pad", `slag`
"Slag", `grazer_flank` "Grazer Flank", `seared_flank` "Seared Flank", `sod_cake` "Sod Cake", `dump_shard`
"Dump Shard".

Tools have no durability (core §5.3, CORE-19; "no durability" stays allowed). Break time is the shared formula 13 §2.1
from the block's hardness and mineable tag (§1.1) and the tool's speed; the earlier rule "divides break time by 4" is
replaced by it (a tool speed of 4.0 divides the time by 4 in the formula, CORE-18). `lucite`, `glowtube` and `goto_pad` are
in no mineable tag and break at hand speed with any item. In creative, every break is instant (13 §2.5). Each item's
attack damage is an attribute modifier of the item (core §5.3: 4 for `pry_bar`, 2 for `trowel`, 1 for any other item);
reach, cooldown and the rest of combat are 17 §4.

Item icons are 16 × 16 RGBA. A block item uses its block's texture (the top face for turf, the end face for
cardstack, the lit texture for glowtube) drawn as a flat icon. The other icons are drawn with the §1.4.1
rules on a transparent background (texture file stem = the item's key path):

- `pry_bar`: `L(2, 13, 12, 3, 2)` (the shaft, a 2-px diagonal) in `#9AA3AD`; then `L(11, 2, 9, 2, 2)` (the
  hook: x 9–11, y 2–3, bending left from the top end) in `#9AA3AD`; then every pixel of the shaft line with
  y ≥ 10 (its bottom 4 rows, 8 pixels) is `#C24A3A` (the grip).
- `trowel`: `T((8, 1), (3, 9), (13, 9))` (the blade) in `#B8BEC6`; then `L(8, 10, 8, 15, 2)` (the handle:
  x 8–9, y 10–15) in `#6B4A2B`.
- `grazer_flank`: `R(4, 5, 11, 10)` in `#B5544A`; `T((11, 5), (14, 8), (11, 10))` in `#B5544A`;
  `L(5, 6, 10, 6, 1)` (a fat stripe) in `#E3B7A0`; `L(1, 7, 3, 7, 2)` (the bone end: x 1–3, y 7–8) in
  `#EDE6CF`.
- `seared_flank`: the `grazer_flank` steps with `#6E3B22` instead of `#B5544A` and `#A0623A` instead of
  `#E3B7A0` (the bone stays `#EDE6CF`).
- `sod_cake`: `R(3, 7, 12, 12)` in `#7A5634`; `R(3, 5, 12, 6)` in `#4F8F3A`; `L(3, 13, 12, 13, 1)` in
  `#5A3F26`.
- `dump_shard`: `T((8, 1), (4, 12), (11, 9))` in `#8F7CFF`; then `L(8, 3, 7, 10, 1)` (a highlight) in
  `#E8F04A`.

**cobolcraft: starting kit** (FR-002, US4-8; README S23, adopted default of decision 6; slot numbers of data-model
"Inventory": 0–8 hotbar, 9–35 main). This is a rule of the cobolcraft world type only: the standard world type starts with
an empty inventory. It is given once to a first-time survival player: slots 0 to 7 hold items 2 to 9 in id order, 64 each
(slot 0 greystone, … slot 7 ledger_tile); slot 8 holds one `pry_bar`; slot 9 holds one `trowel`; every other slot is empty.
The held slot is 0. It is not given again on respawn (17 §4.10). The data form of the kit is core §5.8.

---

## 3. Entity types

| Entity type id | Key | Collision box (width × height) | Eye height | Notes |
|---|---|---|---|---|
| 0 | `cobolcraft:operator` | 0.6 × 1.8 | 1.62 | Player-equivalent, the **player role** (WT-22): the joining player's own entity and, in Add Entity (05a, id 1), other players. Gameplay uses the standard player box (21 §2) and the standard player metadata. The model and texture of §3.2 stay. |
| 1 | `cobolcraft:loose_item` | 0.25 × 0.25 | 0.2125 | **Required.** The **item entity role** (WT-22): the standard item entity (21 §2, size and eye height as the standard `item`). Its metadata is the standard layout (21 App A: the item stack as `DATA_ITEM`, `ITEM_STACK`). Ground-item rules: §9 and 18 §6.11. |
| 2 | `cobolcraft:sodgrazer` | 0.9 × 0.9 | 0.7 | Passive mob (§12). |
| 3 | `cobolcraft:abend` | 0.75 × 0.75 | 0.5 | Hostile mob (§12). |

"Size" is the collision box: centred on the entity position horizontally, from the position's y upward. The earlier
stand-in boxes of `operator` (0.7 × 1.75, eye 1.6) and `loose_item` (0.3 × 0.3, eye 0.15) are retired (README S24); the
ids and keys are unchanged.

### 3.1 Entity models and textures

Entity appearance is described as boxes drawn with one entity texture per entity type (08 §10, texture
`textures/entity/<key path>.png`).

- **Model space.** Units are model pixels, 1 model pixel = 1/16 block. The origin is the entity position
  (bottom centre of its box). +y is up, +z points the way the entity faces (its look direction), and +x is
  toward the entity's left hand (the space is right-handed). A model box is given by its two corners `from`
  and `to`. A model is placed in the world by rotating it about +y by −yaw degrees (right-handed rotation;
  protocol yaw: 0 faces +Z, 90 faces −X) and translating it to the entity position.
- **Faces.** Each box has six faces: front (+z), back (−z), left (+x), right (−x), top (+y), bottom (−y).
  For a box w × h × d model pixels (sizes along x, y, z), front and back are w × h texels, left and right
  d × h, top and bottom w × d: one texel per model pixel.
- **Texel orientation.** Each face is seen from outside its box. Front, back, left and right: row 0 is the
  top (+y) edge; column 0 is the −x edge for the front, the +x edge for the back, the +z edge for the left
  and the −z edge for the right. Top: row 0 is the −z edge, column 0 the −x edge. Bottom: row 0 is the −z
  edge, column 0 the +x edge.
- **Strip layout.** A texture is a vertical stack of strips, one per *part* in the order the model lists its
  parts; several boxes may share one part. A part of size w × h × d occupies a strip max(h, d) texels tall,
  starting below the previous strip (the first at y = 0). Inside the strip, with its top row at y = s, the
  face rectangles start at y = s and are, from the left: front at x = 0, back at x = w, left at x = 2w,
  right at x = 2w + d, top at x = 2w + 2d, bottom at x = 3w + 2d. The texture is (the largest 4w + 2d of
  its parts) wide and (the sum of the strip heights) tall. Texels in no face rectangle are transparent.
- **Face-local coordinates.** "Front (a, b)" in a recipe means the texel at column a, row b of that part's
  front rectangle. Noise in an entity texture (§1.4.1) uses the texel's coordinates in the whole texture
  image and the entity type's key path as the name.

### 3.2 Operator appearance

One part, `box`, from (−5.5, 0, −5.5) to (5.5, 28, 5.5): 11 × 28 × 11 model pixels (0.6875 × 1.75 ×
0.6875 blocks, a little wider than the 0.6 collision box of §3). Texture `operator`, 66 × 28: every face
rectangle filled `#3A5A9A`; then two 2 × 2 "eyes" in `#F0F0F0` at front (2, 4)–(3, 5) and front (7, 4)–(8, 5)
(in the upper third of the face toward the look direction). No limbs or animation.

### 3.3 Ground item appearance

A `loose_item` is drawn as its item's icon (§2) on a square 0.3 × 0.3 block quad, bottom edge at the entity
position's y, centred on the position horizontally, turned about the vertical axis to face the camera. This is the
built-in pack's drawing of the cobolcraft items; the shared item-entity rendering by the item model's `ground` display
transform (12 §8.2, §8.4) applies wherever a model exists (Open question 16).

---

## 4. Synchronized registries

The rows of the registries that the shared rules read (clock, timelines, dimension types, biomes, chat types, damage types,
the enchantment) and their tags are written out in core §3 and §4; this section keeps the sending rules, the class key and
the cobolcraft-only content (biomes, placeholders, dimension geometry). The counts and the rows below are those of the
cobolcraft world type.

### 4.1 How to send them

- **Enabled features.** Send Update Enabled Features (03, id 13) with exactly one flag,
  `minecraft:vanilla` (protocol vocabulary, §0). Our client ignores the flag set.
- **Known packs.** Send Select Known Packs with an **empty list** (or skip it). Every entry is sent with
  Data present. This is the simplest correct behaviour in 04 §2, and it holds for both world types.
- **Order.** Order the Registry Data packets as in 04 §3. The client does not depend on that order, but
  keeping it makes byte-level comparison against reference captures easier.
- **Entry order is the id.** The tables below list entries in id order (04 §4); core §1 (CORE-2) fixes the id order of the
  registries it adds.
- **Empty registries.** The server sends every registry that the loaded content defines. For a registry the content leaves
  empty, send no Registry Data packet at all (04 §3.2 item 5; core §2 lists which). The 13 variant registries (MV) are
  non-empty because they hold the placeholders of §4.5.
- **Static references in entry data.** The cobolcraft-only entries (placeholder variants, our biomes) use an inline form
  with our own identifier or leave the field at its default. The standard-core entries of core §3 reference standard static
  registries (attributes, blocks, items) by their real names, as the shared rules need.

Key to the "Class" column:

- **MV** — mandatory by validation: the vanilla client's non-empty validator or a hard-coded key lookup
  fails without it (04 §3.2). Needed for tier B only; our own client does not need it.
- **NJ** — needed by the join flow or by the play loop, in tier A.
- **OE** — optional, left empty.
- **SC** — standard core: an entry set the shared engines read (core §3).

### 4.2 Summary

| # | Registry | Class | Entries sent |
|---|---|---|---|
| 0 | `worldgen/biome` | NJ + MV (`minecraft:plains`) | 3 |
| 1 | `chat_type` | NJ + SC (core §3.5) | 8 |
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
| 18 | `dimension_type` | NJ | 2 |
| 19 | `damage_type` | MV (the standard keys) + SC (core §3.6) | 52 |
| 20 | `banner_pattern` | OE | 0 |
| 21 | `enchantment` | SC (core §3.7) | 1 |
| 22 | `jukebox_song` | OE | 0 |
| 23 | `instrument` | OE | 0 |
| 24 | `test_environment` | OE | 0 |
| 25 | `test_instance` | OE | 0 |
| 26 | `dialog` | OE | 0 |
| 27 | `world_clock` | NJ + SC (core §3.1) | 1 |
| 28 | `timeline` | SC (core §3.2) | 2 |
| 29 | `decorated_pot_pattern` | OE | 0 |
| 30 | `block_transformer` | OE (core CORE-15; Open question 17) | 0 |
| 31 | `worldgen/block_state_provider` | OE | 0 |

That is 20 Registry Data packets and 82 entries (3 biomes, 8 chat types, 13 MV placeholders, 2 dimension types, 52 damage
types, 1 enchantment, 1 world clock, 2 timelines; core §2). The earlier edition sent 18 packets and 52 entries. Both
dimension types and all three biomes are always sent, even when the `extra-dimensions` setting is off, so registry ids
never depend on configuration. A tier-A-only server could drop the 13 MV variant registries and the compat damage keys.
The recommendation is to keep them, because they are cheap and keep tier B working.

### 4.3 `worldgen/biome`

| Id | Key | has_precipitation | temperature | downfall | effects | attributes |
|---|---|---|---|---|---|---|
| 0 | `minecraft:plains` **[compat name]** — our "lowland" | 1 | 0.6 | 0.4 | water_color `"#3A6EA5"`, grass_color `"#4F8F3A"`, foliage_color `"#4F8F3A"` | absent (empty) |
| 1 | `cobolcraft:upland` | 1 | 0.3 | 0.2 | water_color `"#2F5C8C"`, grass_color `"#6B9A55"`, foliage_color `"#6B9A55"` | absent (empty) |
| 2 | `cobolcraft:ash_flats` | 0 | 1.4 | 0.0 | water_color `"#3A2F2A"`, grass_color `"#5A4A40"`, foliage_color `"#5A4A40"` | absent (empty) |

- `temperature_modifier`, `dry_foliage_color` and `grass_color_modifier` are left absent (defaults). The rows as data are
  core §3.4 (CORE-9: the lowland keeps 0.6 and 0.4, not the standard plains 0.8 and 0.4 of 10 §7.8).
- `minecraft:plains` is used because the vanilla client looks it up as its fallback biome. In the cobolcraft world type it
  means "lowland". It is placed at id 0 so that it is also the natural fallback for our client.
- Lowland and upland are the biomes of `cobolcraft:main` (§5.2); `ash_flats` is the only biome of
  `cobolcraft:subroutine` (§15.2).
- `has_precipitation` follows §14: weather is drawn and has its gameplay effect in lowland and upland, and
  never in `ash_flats` (the Subroutine has no weather at all).
- With 3 biomes, the global biome palette is `ceillog2(3) = 2` bits. Main-dimension sections spanning both
  lowland and upland use the Linear palette at 1 bit; every other section (including every subroutine
  section) is single value. The biome Global kind (4 bits or more) is never reached.

### 4.4 `chat_type`

| Id | Key | chat | narration |
|---|---|---|---|
| (4 in core §3.5) | `cobolcraft:say` | translation_key `cobolcraft.chat.say`, parameters [`sender`, `content`], no style | translation_key `cobolcraft.chat.say.narrate`, parameters [`sender`, `content`] |

The cobolcraft chat type is kept. Our client's language table maps `cobolcraft.chat.say` to "<%s> %s" and the narrate key to
"%s says %s". The shared commands and player chat use the standard chat types (`minecraft:chat`, `emote_command`,
`say_command`, `msg_command_incoming` and `_outgoing`, the team types; 16 §8, README decision 7), which this world type
also carries: the eight rows and their ids are core §3.5 (CORE-13). No shared engine sends `cobolcraft:say`
(Open question 18).

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

Two entries. The Login and Respawn packets' CommonPlayerSpawnInfo carries the id of the player's current
dimension's type. The rows as data, with their attributes and timelines, are core §3.3; this table keeps the geometry and
points to core where a shared rule changed a field.

| Id | Key | Used by |
|---|---|---|
| 0 | `cobolcraft:surface` | `cobolcraft:main` (§5) |
| 1 | `cobolcraft:sunless` | `cobolcraft:subroutine` (§15) |

| Field | `cobolcraft:surface` (id 0) | `cobolcraft:sunless` (id 1) | Why |
|---|---|---|---|
| has_fixed_time | absent (false) | 1 | Day/night advances on the surface; the Subroutine has no day. |
| has_skylight | 1 | 0 | The Subroutine has no sky light at all (§15.3). |
| has_ceiling | 0 | 0 | |
| has_ender_dragon_fight | 0 | 0 | Required field with no meaning for us. Always false. |
| coordinate_scale | 1.0 (Double) | 1.0 (Double) | Travel keeps x and z (§15.5). |
| min_y | 0 | 0 | Multiple of 16. Keeps every Y non-negative, which simplifies the COBOL arithmetic. |
| height | 256 | 128 | Multiples of 16, at least 16; min_y + height ≤ 2032. |
| logical_height | 256 | 128 | ≤ height. |
| infiniburn | empty List `[]` | empty List `[]` | Required HolderSet over static `block`. An empty list names no block and no tag, so neither vanilla block names nor an Update Tags entry are needed. |
| ambient_light | 0.0 | 0.0 | See core §3.3 (the renderer reads `ambient_light_color`, 12 §3.1). |
| monster_spawn_light_level, monster_spawn_block_light_limit | core §3.3 (CORE-26) | core §3.3 | The standard Overworld values, which govern spawner-block checks; our spawning rules are §12.4 and natural spawning is stopped by the empty `natural_mob_spawns` of core §3.4. |
| skybox | absent (default `overworld`) | `none` | Protocol enum constants naming the client's sky mode, not content. |
| cardinal_light | absent (default) | absent (default) | |
| attributes | core §3.3 (the standard overworld map of 12 §3.1) | core §3.3 (CORE-8) | Day length and sky come from the shared rules (12 §3), not from constants of this document. |
| timelines | core §3.3: `["minecraft:day","minecraft:moon"]` | absent (empty) | CORE-7. |
| default_clock | `"minecraft:overworld"` (core §3.1) | absent | A fixed-time dimension has no clock. `has_fixed_time` for `sunless` stays (Open question 12). |

Derived geometry (06 §1, §3.1, §7):

- `surface`: 16 block sections, section Y 0–15. Light covers 18 sections, section Y −1 to 16; light-mask bit
  i is section Y i − 1. Heightmap entries are `ceillog2(257) = 9` bits wide: 7 per Long, 37 Longs per
  heightmap.
- `sunless`: 8 block sections, section Y 0–7. Light covers 10 sections, section Y −1 to 8. Heightmap entries
  are `ceillog2(129) = 8` bits wide: 8 per Long, 32 Longs per heightmap.

### 4.7 `damage_type`

The 52 entries of the cobolcraft world type are the 51 standard damage types with their standard values (exhaustion,
scaling, effects: 17 §4.12) and the one cobolcraft-only type `cobolcraft:hail` (core §3.6, CORE-4, CORE-10 to CORE-12;
ids by core §3.6, sorted by path, so the earlier ids 0 to 31 no longer apply). The earlier 25 compat keys carried
placeholder values (scaling `never`, exhaustion 0.0); they now carry the standard values, and the shared rules use the
standard keys (`minecraft:fall`, `minecraft:starve`, `minecraft:mob_attack`, `minecraft:player_attack`, ...).

Retired from the earlier table (README S37): `cobolcraft:generic`, `cobolcraft:impact`, `cobolcraft:below_world` (no rule
uses them; core CORE-11), `cobolcraft:mob_attack`, `cobolcraft:player_attack` and `cobolcraft:starvation` (the standard
keys replace them). Kept: `cobolcraft:hail`, used by the hail rule of §14.6.

The correctness of the key `fell_out_of_world` against `out_of_world` is open (core Open question 1); this document no
longer asserts either.

### 4.8 `world_clock`, day length and sky

Retired as a content section (README S38; shared rule for both world types). The clock is `minecraft:overworld` (core
§3.1), the day is 24000 ticks with the standard night shape, and the sky colours come from the timeline and attributes
(12 §3.1, §3.2; core §3.2, §3.3), not from the earlier 30000-tick day, the daylight factor and the day and night colours.
The `time` command acts on that clock (16 §4.5).

### 4.9 Optional-empty registries (OE)

`trim_pattern`, `trim_material`, `sulfur_cube_archetype`, `banner_pattern`, `jukebox_song`, `instrument`,
`test_environment`, `test_instance`, `dialog`, `decorated_pot_pattern`, `worldgen/block_state_provider`: **no packet
sent**. None has a validator, and nothing in this content references them.

Removed from the earlier OE list (README S39): `enchantment` (one entry, core §3.7: the shared tool rules read it, 17
§6) and `timeline` (two entries, core §3.2: the shared sky reads it, 12 §3.2). `block_transformer` is also removed from the
list by README S39 (17 §3.1), but core CORE-15 sends none, because no cobolcraft item has the component; it stays empty
here and sends no packet (Open question 17).

---

## 5. Dimension and world generator

### 5.1 Dimension

| Item | Value |
|---|---|
| Level (dimension) key | `cobolcraft:main` |
| Dimension type | `cobolcraft:surface` (id 0) |
| Y range | 0 to 255 (min_y 0, height 256) |
| Sea level (CommonPlayerSpawnInfo) | 48. Nominal only; there is no water. |
| Login "dimension names" | [`cobolcraft:main`, `cobolcraft:subroutine`] when the `extra-dimensions` setting is on (FR-009, the default); [`cobolcraft:main`] when it is off. The list holds every enabled dimension (§15), in this order. |
| Is flat / is debug | false / false |
| Hashed seed | Derived from the world seed by the standard rule (10 §7.7: the first 8 bytes of the SHA-256 of the 8 little-endian bytes of the seed), not 0. |
| Game mode | From the server configuration or the world (FR-007, FR-009). Previous game mode: absent (0). |
| View distance / simulation distance | The configured view distance for both. It is a server setting (FR-009, default 8, retained); the standard client default is 12 (13 §7.2). |

### 5.2 Generator

Deterministic and stateless: any column can be generated on its own from its (x, z) alone. The generator
reads no seed yet (the Login hashed seed is still derived from the world seed, §5.1).

**Surface height.** For world block column (x, z), the surface height h is 52 plus 6 times sin(x / 23)
times cos(z / 31), with angles in radians (IEEE 754 double), rounded to the nearest integer with halves away
from zero (as §15.2). h therefore lies between 46 and 58.
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
- Section 0 holds 2 distinct states (baseplate, greystone) and section 1 only greystone (single value).
  Sections 2 and 3 hold 1 to 9 distinct states (section 3 reaches 9 only in a marker chunk whose surface has
  both turf and grit): single value when 1, otherwise the 4-bit Linear palette.
- Heightmaps (WORLD_SURFACE, MOTION_BLOCKING, MOTION_BLOCKING_NO_LEAVES) are identical. Each stores the
  topmost non-void Y + 1, because min_y is 0. Marker columns count the marker blocks.
- Block entities: none.

**Light.** The shared light engine (32; the client reads the levels as 12 §1.4 and §1.8 define) applies in this world type
(README S41, R2). The earlier column-drop sky light and taxicab block light policy is retired. What this content supplies to
the engine is the per-block data of §1.1 (light emitted, opacity, and `lucite` as non-opaque) and the dimension types of
§4.6 (`surface` has sky light, `sunless` has none). Generated chunks contain only marker glowtubes as light sources.

**Spawn point.** Feet at (4.5, 54.0, 8.5), facing east (+X): yaw −90.0, pitch 0.0. Column (4, 8) has h = 52 + round(6 × sin(4/23) ×
cos(8/31)) = 52 + round(1.004) = 53, so the player stands on its turf. Chunk (0, 0) is a marker chunk, so the
marker pillar at (8, 55–59, 8) is four blocks ahead in plain view. (The column (8, 8) itself is not used
because the pillar occupies it.) The world spawn point is always in `cobolcraft:main`; `setworldspawn`
(16 §4.7) moves it within this dimension.

---

## 6. Tags

The tags of the cobolcraft world type are the core's (core §4): Update Tags is **no longer empty**. It carries the block
tags the shared mining and placement rules read (`minecraft:mineable/pickaxe` and `minecraft:mineable/shovel` with the
cobolcraft blocks as members, plus the proposed `replaceable`, `air`, `causes_suffocation` and `blocks_motion*` tags), the
item tag `minecraft:enchantable/mining` and the damage type tags, with the payload in core §4.4. Cobolcraft blocks and tools
join the standard tags instead of carrying tags of their own (README S42, decision 4): the earlier own tags
`cobolcraft:hard`, `cobolcraft:soft` and `cobolcraft:tools` retire (the classes of §1.1 are `mineable/pickaxe` and
`mineable/shovel`; the tools read them, §2). The tier tags (`needs_*`, `incorrect_for_*`) are not carried (core CORE-17,
Open question 19).

`dimension_type.infiniburn` uses an empty list, not a tag (§4.6).

---

## 7. Removed

The earlier "Stand-in → replace later checklist" is removed (README S43). It was the work list of a first run; README Part 6
and the status log of README replace it. Its items are answered or owned elsewhere: block set, textures, items, ground items,
health, hunger, mobs, recipes, weather, biomes, dimensions, generator, lighting engine, command names, chat types, day
length, font (kept as the fallback), hashed seed, tier B, sounds (out of scope).

---

## 8. Open questions

These are the questions of the earlier edition that remain open for the cobolcraft world type (README S44). Questions 1, 7
and 11 are closed; 6 (state permutation order) is 04 Open question 5; 8 (Y bounds) is closed by 10 §5; 9 (section
counts) is 06 Open questions 1 and 3; 10 (level key) is closed by the standard key `minecraft:overworld`; 13 (Brigadier
string kinds) is 05a Open question 1 and 15a. Their numbers are not reused. Questions 14 and up were added by this edition.

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

12. **A fixed-time dimension type without `default_clock`.** `sunless` sets `has_fixed_time` and omits
    `default_clock`. Whether a vanilla client accepts that combination in configuration was not traced (04
    marks both fields optional). Tier A is unaffected. If a tier B configuration test fails on it, give
    `sunless` the `default_clock` `"minecraft:overworld"` too; our client ignores it for a fixed-time type.

14. **The `Time` of the §12 and §14 rules.** The rules `Time` mod 80 (wander, hail), mod 100 (spawn cycle) and the hash input
    `Time` were written for a counter that wraps at 30000. They now read the total tick count of the shared clock
    `minecraft:overworld` (header paragraph). Whether a wrapped day time or the total ticks is meant is not stated; both
    give the same phase for mod 80 and mod 100 (24000 is a multiple of 80 and of 100), but the hash input differs, so the
    exact random choices of the earlier edition are not reproduced. Owner: the planner, with 33 §3 (the clock).
15. **Texture, check values and recipes of the bench.** The crafting bench (README decision 3, core §5.1, §5.2, §5.7) has no
    texture recipe or check value in §1.4.2 or §1.5 and no English name here (core Open question 11 lists the language keys;
    builtin-ui-art.md owes the art). Recipes 5 (`sod_cake`, five ingredients) and 7 (`goto_pad`, seven) both need the 3 × 3
    grid; README S65 names only recipe 7 (core Open question 12). §13 follows core §5.7. Decision 3 is an adopted default, not
    an operator ruling.
16. **Rendering of the two role entities.** §3.3 keeps the 0.3 × 0.3 quad for ground items and §3.2 keeps the `operator`
    box of 11 × 28 × 11 model pixels, which is 0.6875 blocks wide against the standard 0.6 collision box; README S25 says to
    keep both. Whether the item model's `ground` display transform (12 §8.2, §8.4) replaces the quad for block items is not
    decided.
17. **`block_transformer`.** README S39 and C3 list a minimal entry; core CORE-15 sends none (no cobolcraft item has the
    component) and records the departure (core Open question 15). This file follows core; the README text is to be corrected
    or the operator asks for the entry.
18. **`cobolcraft:say`.** No shared engine sends it (core CORE-13, Open question 16). Keep it or drop it when 09 is rewritten.
19. **Tier tags and tool requirement.** Every cobolcraft block yields its item without a tool (core CORE-17, Open question 13),
    against README S10's nearest block `stone`, which requires a tool. Operator to confirm.
20. **Break times.** The earlier hand times are gone; the shared formula with the hardness of §1.1 gives, for example,
    `greystone` by hand about 2.25 s against the earlier 1.5 s, and `grit` about 0.75 s against 0.5 s (core Open question 14).
    Operator to confirm the nearest-standard rule of README decision 4 or the alternative of keeping the old times.
21. **Interim rows.** Two sets of values stay only until their gap closes (README R9, decision 14): the thrown-item motion, the
    ground-item movement and the pickup box of §9 (GAP-26, 18 Open question 6, 21 Open question 13) and the timing of the
    natural weather schedule of §14.3 (GAP-11). When a clean-room round specifies them, §9.1 (throw), §9.2 step 3, §9.3 and
    §14.3 are deleted.
22. **Hail.** README Part 6 task T23 lists §14.6 among the sections to delete, while README S66 and decision 5 keep `hail` as the
    cobolcraft-only damage extra of the `hailstorm` skin. This file follows S66 (Part 2 governs): §14.6 stays, reduced to the
    cobolcraft rule, and uses the standard damage-event path (17 §4).
23. **Subroutine clock.** `sunless` has no `default_clock`, so plain `/time` has no clock in the Subroutine (core Open question
    22); the behaviour is not specified. Also whether a vanilla client accepts a fixed-time dimension with neither a clock nor
    timelines is untraced (core Open question 22, Open question 12 here).

---

## 9. Ground items (interim values)

Ground items are **item entities** under the shared rules (18 §6.11; README S50): lifetime 6000 ticks, default pickup delay
10, and merging of equal stacks within a box inflated by 0.5 horizontally while below the maximum stack. The entity type
is `cobolcraft:loose_item` (§3), whose metadata is the standard layout (21 App A). The rest of this section holds only the
**interim values** that the shared documents do not yet give (GAP-26; 18 Open question 6, 21 Open question 13): they stay
for both world types until that gap closes, and then §9 is deleted (README R9, decision 14). A ground item holds one item
stack (item and count, 1 ≤ count ≤ the item's max stack).

### 9.1 Where ground items come from

Item entities are created, with the shared defaults, by a survival block break (§1.3), a mob defeat (§12.5) and a death drop
(17 §4.10). The interim rows are the throws:

| Source | Position | Initial motion | Pickup delay |
|---|---|---|---|
| Throw (Player Action 5 `DROP_ITEM`: one item; 4 `DROP_ALL_ITEMS`: the whole stack, from the held hotbar slot; any game mode) | the thrower's feet + (0, 1.3, 0) | see below | 30 ticks |
| Inventory-screen throw (Container Click, container 0, any game mode): mode 4 `THROW` on a slot, button 0 (Q) one item, button 1 (Ctrl+Q) the whole stack, from that slot; mode 0 `PICKUP` with slot −999 (a click or drag release outside the window), button 0 the whole carried stack, button 1 one carried item | as Throw | as Throw | 30 ticks |
| Inventory screen closed while carrying (Close Container, container 0) | the carried stack goes back into the inventory as INV-ADD places it; only what does not fit is thrown, as Throw | as Throw | 30 ticks |

**Thrown motion (interim).** With the thrower's yaw Y and pitch P in degrees (protocol convention: yaw 0 faces +Z,
yaw 90 faces −X; pitch positive looks down):
mx = −sin(Y) × cos(P) × 0.25, my = −sin(P) × 0.25 + 0.12, mz = cos(Y) × cos(P) × 0.25 (blocks per tick).
There is no random spread. A throw from an empty slot does nothing.

### 9.2 Per-tick rules

Ground items are processed once per tick, only while their chunk is loaded, in ascending network entity id
order (the order of the steps within the server tick is 18 §2), in this order of steps:

1. **Pickup delay.** If it is above 0, it decreases by 1.
2. **Age and despawn.** The shared rule of 18 §6.11 (lifetime 6000 ticks; no player-distance condition) replaces the earlier
   player-distance rule and the 4800-tick lifetime. The age is saved as `Age` (world-folder.md §3); a new ground item has
   age 0. A despawned item is removed and viewers are sent Remove Entities; it skips the remaining steps. Equal stacks
   merge (18 §6.11); the earlier "ground items never merge" rule is retired.
3. **Movement (interim).** The item's box is x ± 0.15, y to y + 0.3, z ± 0.15. A cell (i, j, k) is
   [i, i + 1] × [j, j + 1] × [k, k + 1]; the box *overlaps* a solid cell when they share positive volume
   (touching faces do not overlap); a cell in an unloaded chunk counts as solid. A new item is *falling*.
   1. If the box overlaps any solid cell (a block was placed into it), y ← (the highest j among those
      cells) + 1.
   2. A *resting* item becomes falling, with motion (0, 0, 0), when the cell directly below it,
      (floor(x), floor(y) − 1, floor(z)), is not solid; otherwise it stays resting and skips steps 3 to 5.
   3. vy ← vy − 0.035 (gravity).
   4. Move along Y by vy, then along X by vx, then along Z by vz. A move is blocked when the box at the new
      position would overlap a solid cell; an unblocked move adds the velocity to that coordinate. A blocked
      X or Z move leaves that coordinate unchanged and sets that velocity to 0. A blocked Y move with
      vy < 0 sets y to (the highest j among the overlapped solid cells) + 1 and makes the item *resting*; a
      blocked Y move with vy > 0 leaves y unchanged and sets vy to 0.
   5. If the item came to rest, its motion becomes (0, 0, 0). Otherwise vx, vy and vz are each multiplied
      by 0.97 (drag).

   Viewers are sent Teleport Entity with the new position after each tick in which the item's position
   changed.
4. **Pickup.** See §9.3.

### 9.3 Pickup

- **Range (interim).** A player is in pickup range of an item when the item's box (above) overlaps, with positive
  volume or touching, the player's box expanded by 0.75 block in x and in z and by 0.25 block in y (the
  player's box is x ± 0.35, y to y + 1.75, z ± 0.35, so the expanded box is x ± 1.1, y − 0.25 to y + 2.0,
  z ± 1.1).
- **Who.** An alive player in survival or creative mode, in the same dimension, while the item's pickup
  delay is 0.
- **Order and exactly-once.** For each item in ascending entity id order, the players in range are tried in
  the order in which they entered the world this run (earliest first). For each player, as many items of the
  stack as fit are added to the inventory with the inventory add rule (data-model §4: matching stacks first,
  then empty slots in slot order). The item's count is reduced by that number before the next player is
  tried; the next player is tried only if items remain. A player whose inventory takes nothing is skipped.
- **Wire.** For each player who took k > 0 items: Take Item Entity (collected entity = the item, collector =
  the player, count = k) to viewers, and the player's inventory update. If the count reached 0, the item is
  then removed (Remove Entities). If items remain (partial pickup, US5 edge case), the item stays where it is
  and viewers are sent Set Entity Data with the reduced stack.

### 9.4 Persistence

A ground item is saved with its position, motion, stack and age (world-folder.md §3). Its pickup delay is
not saved; a loaded item has pickup delay 0. Ground items stay in their dimension when players travel (US12
edge case).

### 9.5 Order of the rules within a server tick

Retired (README S51, shared rule): the per-tick order of living entities and mobs is 18 §2, the player rules are 17 §4.9.
The content rules of §12 (mob AI, physics, spawning) and §14.6 (hail) run in the entity step of 18 §2.

---

## 10. Health and death

Retired for both world types (README S52 to S59). The rules are the standard ones, and a content note stays only where the
cobolcraft world type adds something:

| Earlier section | Now |
|---|---|
| §10.1 health (maximum 30) | `max_health` 20 (17 §1.5). |
| §10.2 taking damage, hurt cooldown 12 | The 10-tick invulnerability window (17 §4.7). |
| §10.3 causes of damage, fall, starvation | Fall 17 §4.11 and 13 §1.3, starvation 17 §4.9, lightning 17 §4.11; damage types `minecraft:fall`, `starve`, `mob_attack`, `player_attack` (§4.7). Hail is the cobolcraft-only cause (§14.6); the abend's hit of 3 is its `attack_damage` attribute (core §5.5). There is no set-health command: use `damage`, `effect`, `kill` and `attribute` (16 §5). |
| §10.4 attack damage and reach | Attack strength, reach and exhaustion 17 §4.1 to §4.3 and §1.5; the item damages 4 and 2 are modifiers of the two tools (core §5.3, §2 above). |
| §10.5 recovery | 17 §4.9. |
| §10.6 death and respawn | 17 §4.10; the starting kit is not given again (§2). |
| §10.7 death texts | The standard `death.*` keys and death screen (17 §4.10, GAP-27); the abend uses the generic mob message (README decision 5; core §5.5, Open question 2). |

---

## 11. Food

### 11.1 to 11.4 and 11.6

Retired for both world types (README S60 to S62, S63). Food and saturation (maximum 20, new player food 20 and saturation
5.0), exhaustion and the threshold are 17 §4.9; movement speeds, flying, jump, gravity, mouse look and reach are 13 §1,
§7.2 and 17 §1.5; eating (the `consumable` component, 1.6 s default, completion effects) is 17 §1.2, §4.9 and core §5.4.
The earlier 24-point food level, the 30-tick eating time and the Entity Event rule are deleted (Entity Event 9: 09 Open
question 7).

### 11.5 Food items

| Item id | Key | English name | Food value (`food` nutrition, core §5.4) | How it is obtained (SC-008) |
|---|---|---|---|---|
| 12 | `cobolcraft:grazer_flank` | Grazer Flank | 3 | Yield of a defeated sodgrazer (2 per mob, §12.5). |
| 13 | `cobolcraft:seared_flank` | Seared Flank | 8 | Recipe 6 (§13): 2 grazer flank + 1 glowtube → 2. |
| 14 | `cobolcraft:sod_cake` | Sod Cake | 2 | Recipe 5 (§13): 4 turf + 1 loam → 1. |

Icons in §2. The three foods are items with the standard `food` and `consumable` components (core §5.4); eating follows the
standard rule.

---

## 12. Mobs

The two mobs are cobolcraft content. Their health, damage, hurt window, knockback and death follow the shared combat rules
(17 §4, 18 §3, §7; README S64), and the attributes the shared engines read are written in core §5.5; the stand-in AI and
physics of §12.2 and §12.3 and the spawn cycle of §12.4 remain the mobs' own (core CORE-26, CORE-29 to CORE-31).

### 12.1 Mob types

| | `cobolcraft:sodgrazer` | `cobolcraft:abend` |
|---|---|---|
| Entity type id (§3) | 2 | 3 |
| English name | Sodgrazer | Abend |
| Kind | passive | hostile |
| Collision box (width × height), eye height | 0.9 × 0.9, 0.7 | 0.75 × 0.75, 0.5 |
| Maximum health (`max_health`, core §5.5) | 8 | 12 |
| Wander speed | 0.05 blocks per tick | 0.04 blocks per tick |
| Flee speed | 0.1 blocks per tick | — |
| Pursue speed | — | 0.12 blocks per tick |
| Notice range | — | 12.0 blocks |
| Give-up range | — | 20.0 blocks |
| Attack reach | — | 1.75 blocks |
| Attack damage | — | 3 (the `attack_damage` attribute, core §5.5) |
| Attack cooldown | — | 30 ticks |
| Yield on defeat | one ground item of 2 `grazer_flank` | one ground item of 1 `dump_shard` |
| Spawns in | `cobolcraft:main` by day, on turf | `cobolcraft:main` at night, and `cobolcraft:subroutine` always; on dark ground |

Distances between a mob and a player are 3D Euclidean distances between their positions (feet).

### 12.2 Physics

Each tick, after its AI step has set the wanted horizontal velocity (hx, hz):

1. vy ← (vy − 0.05) × 0.96.
2. Move along Y by vy with the blocking rule of §9.2 step 3.4, using the mob's collision box (x ± width / 2,
   y to y + height, z ± width / 2): blocked downward → y on top of the highest overlapped solid cell, vy ← 0,
   on-ground; blocked upward → y unchanged, vy ← 0, not on-ground; not blocked → y ← y + vy, not on-ground.
3. Move along X by hx, then along Z by hz. A blocked move is retried as a **step-up**: if the mob is on the
   ground and its box at (new position, y + 1) overlaps no solid cell, the mob moves there (y increases by 1);
   otherwise that coordinate is unchanged. A cell in an unloaded chunk counts as solid.

Mobs do not push or collide with other entities. Viewers are sent movement and head rotation (yaw) after
each tick in which they changed.

### 12.3 Behaviour (AI)

- **Wander** (sodgrazer when not fleeing; abend without a target). On every tick with `Time` mod 80 = 0, the
  mob decides with r = H(floor(x), floor(y), floor(z), `Time`) (§1.4.1): if r mod 3 = 0 it stands still
  ((hx, hz) = (0, 0)) until its next decision; otherwise its yaw becomes ((r div 3) mod 8) × 45 degrees and
  until its next decision it walks with hx = −sin(yaw) × wander speed, hz = cos(yaw) × wander speed. A new
  or loaded mob stands still until its first decision.
- **Flee** (sodgrazer). When a player's attack damages a sodgrazer, for the next 40 ticks it moves directly
  away from that player's position: (hx, hz) = flee speed × the unit horizontal vector from the player to the
  mob (if they share x and z, it uses its current yaw), and its yaw faces that way. It never attacks (US9-3).
- **Target** (abend). Without a target, an abend takes the nearest alive survival player in its dimension
  within the notice range (ties: the earliest-entering player). It drops its target when that player is
  farther than the give-up range, switches to creative, disconnects, dies or changes dimension (US9 edge case).
- **Pursue** (abend with a target). Its yaw faces the target (yaw = atan2(−dx, dz) in degrees, with (dx, dz)
  from the mob to the target). If the horizontal distance to the target is above 1.0, (hx, hz) = pursue speed
  × the unit horizontal vector toward the target; otherwise (0, 0).
- **Attack** (abend). Its attack cooldown decreases by 1 each tick to a minimum of 0. When it has a target
  within the attack reach and the cooldown is 0, the target takes 3 damage (damage type `minecraft:mob_attack`, through the shared combat rules, 17 §4) and the
  cooldown becomes 30.
- AI state (wander decision, flee time, target, cooldown) is not saved; a loaded mob starts idle.

### 12.4 Spawning

On every tick with `Time` mod 100 = 0, for each enabled dimension in the order `cobolcraft:main`
(dimension index 0), `cobolcraft:subroutine` (dimension index 1) that has at least one alive player in it,
for each alive player p in it in entering order:

1. r = H(dimension index, floor(p.x), floor(p.z), `Time`).
2. dx = (r mod 41) − 20 and dz = ((r div 41) mod 41) − 20. If max(|dx|, |dz|) < 8, there is no spawn for p.
3. Column X = floor(p.x) + dx, Z = floor(p.z) + dz. Its chunk must be loaded. Let `top` be the y of the
   highest non-void block in the column; the cells (X, top + 1, Z) and (X, top + 2, Z) must be void and
   inside the height range.
4. The candidate type:
   - `cobolcraft:main`, night (the shared predicate `isDarkOutside`, core §5.5 CORE-30): `abend`, if the block light layer of the shared light engine (core §5.5 CORE-30) at (X, top + 1, Z) is at most 5.
   - `cobolcraft:main`, day: `sodgrazer`, if the block at (X, top, Z) is turf.
   - `cobolcraft:subroutine`: `abend`, if the block at (X, top, Z) is slag and the block light at
     (X, top + 1, Z) is at most 5.
   - otherwise no spawn.
5. No spawn if the type is `abend` and the `hostile-mobs` setting is off (FR-009, US9-6); or if the
   dimension already holds, in its loaded chunks, **12** sodgrazers (sodgrazer) or **8** abends (abend);
   or if any player in the dimension is within 8.0 blocks of the spawn position.
6. Otherwise one mob of that type appears at (X + 0.5, top + 1, Z + 0.5) with yaw ((r div 1681) mod 8) × 45
   and full health. Exactly one mob per player per spawn tick at most.

While `hostile-mobs` is off, every abend is removed at once and at every tick (US9-6). There is no other
despawning: mobs stay until defeated, removed by command or removed by that setting.

### 12.5 Defeat

A mob whose health reaches 0 is removed (viewers: Remove Entities) and its yield (§12.1) appears as one ground
item at the mob's position (loot table core §5.6; item entity §9). Mobs are saved with type, position, motion, rotation and health
(world-folder.md §3) and belong to their dimension (US12 edge case).

### 12.6 Appearance

Models and textures follow §3.1. The textures are the files `textures/entity/sodgrazer.png` and
`textures/entity/abend.png`.

**Sodgrazer** (parts in this order: `body`, `head`, `leg`):

| Part | Boxes (from → to, model pixels) | Size w × h × d |
|---|---|---|
| `body` | (−7, 3, −6) → (7, 12, 6) | 14 × 9 × 12 |
| `head` | (−4, 6, 6) → (4, 14, 11) | 8 × 8 × 5 |
| `leg` (four boxes share it) | (2, 0, 2) → (5, 3, 5); (−5, 0, 2) → (−2, 3, 5); (2, 0, −5) → (5, 3, −2); (−5, 0, −5) → (−2, 3, −2) | 3 × 3 × 3 |

Texture `sodgrazer`, 80 × 23 (strips: `body` y 0–11, `head` y 12–19, `leg` y 20–22): every face rectangle of
`body` is noise `sodgrazer`: fill `#5E7A3C`; 25 % `#4F6A31`, 10 % `#708C4A`; every face rectangle of `head`
is filled `#8A7458`, then its front (1, 2)–(2, 2) and front (5, 2)–(6, 2) are `#1C1C1C` (two 2 × 1 eyes);
every face rectangle of `leg` is filled `#6B5A44`.

**Abend** (one part, `body`): the box (−6, 0, −6) → (6, 12, 6), 12 × 12 × 12. Texture `abend`, 72 × 12:
every face rectangle is noise `abend`: fill `#2E2A4F`; 15 % `#4A4580`; then a 1-px border of each face
rectangle in `#8F7CFF`; then front (2, 3)–(4, 4) and front (7, 3)–(9, 4) are `#E8F04A` (two 3 × 2 eyes).

Check values for both textures and for `operator` are in §1.5.

---

## 13. Recipes

The recipe set of the cobolcraft world type: nine recipes, **shapeless recipes in the standard recipe format** (13 §3.1;
the data rows, matching, the unlock rule and the bench recipe are core §5.7). They are crafted in the inventory 2 × 2 grid
or the crafting bench's 3 × 3 grid, in both game modes (13 §3.5, 12 §5.6a, §5.6b; README R6, S65). Feature 001's crafting
screen, the Place Recipe rule and the display ids are retired. Recipe 5 (five ingredients) and recipe 7 (seven) do not fit
the 2 × 2 grid and need the bench, the one addition of README decision 3 (§1.1, core §5.7). The recipe numbers below are
the names used elsewhere in this document.

| Recipe | Ingredients | Result |
|---|---|---|

| 0 | 4 `greystone` | 2 `ledger_tile` |
| 1 | 4 `grit` | 2 `lucite` |
| 2 | 3 `greystone` + 1 `cardstack` | 1 `pry_bar` |
| 3 | 2 `greystone` + 1 `cardstack` | 1 `trowel` |
| 4 | 1 `lucite` + 1 `dump_shard` | 2 `glowtube` |
| 5 | 4 `turf` + 1 `loam` | 1 `sod_cake` |
| 6 | 2 `grazer_flank` + 1 `glowtube` | 2 `seared_flank` |
| 7 | 4 `ledger_tile` + 2 `dump_shard` + 1 `glowtube` | 1 `goto_pad` |
| 8 | 2 `cardstack` + 2 `lucite` | 1 `dump_shard` |

Ingredients are listed in this order. No recipe uses `baseplate`, `slag`, `sod_cake`, `seared_flank`, `pry_bar`, `trowel`
or `goto_pad` as an ingredient. The bench recipe (4 `ledger_tile`, shaped) is core §5.7.

**How each ingredient is obtained in survival (SC-008)**, from the §2 starting inventory and the world with
default settings:

| Item | Obtained from |
|---|---|
| `greystone` | Starting inventory (64); breaking terrain from y 1 to h − 4 anywhere (§5.2). |
| `loam` | Starting inventory (64); breaking terrain from y h − 3 to h − 1. |
| `turf` | Starting inventory (64); breaking the surface where h ≥ 50. |
| `grit` | Starting inventory (64); breaking the surface where h < 50. |
| `cardstack` | Starting inventory (64); the marker pillars (two per marker chunk, plus one punched). |
| `lucite` | Starting inventory (64); marker pillars; recipe 1. |
| `glowtube` | Starting inventory (64); marker pillars (main and subroutine); recipe 4. |
| `ledger_tile` | Starting inventory (64); recipe 0. |
| `dump_shard` | Yield of the abend: main dimension at night, or the Subroutine (§12.4); recipe 8 (needs no mob, so it works with `hostile-mobs` off). |
| `grazer_flank` | Yield of the sodgrazer: main dimension by day, on turf (§12.4). |

Every result is therefore obtainable too: `goto_pad` needs only main-dimension ingredients (shards from night
abends or recipe 8), so travel never depends on having travelled first. `slag` comes only from breaking
subroutine terrain (§15.2). This holds for every setting of FR-009: with `hostile-mobs` off, recipe 8 is the
source of `dump_shard`; `sodgrazer` spawning does not depend on any setting.

---

## 14. Weather

The weather **mechanism** is the standard one for both world types (README S66, C5): one server-level weather state with
clear, rain and thunder levels (16 §4.10, 33 §4), the wire events Game Event 1, 2, 7 and 8, the sky, fog and precipitation
rendering (12 §3.3, §3.5, 14 §8.2), and lightning (17 §4.11). The earlier sections on where weather applies (§14.2), the
wire (§14.4), the client drawing (§14.5, apart from the two environment textures) and the gameplay effects (§14.6, apart
from hail) are retired. What stays is the cobolcraft content on top of it and one interim row.

### 14.1 Weather kinds (a skin of the standard levels)

| Kind key | English name | Standard state it skins | Environment texture | Gameplay effect |
|---|---|---|---|---|
| `cobolcraft:clear` | Clear | clear | none | none |
| `cobolcraft:drizzle` | Drizzle | rain | `textures/environment/drizzle.png` | none beyond rain |
| `cobolcraft:hailstorm` | Hailstorm | thunder | `textures/environment/hailstorm.png` | hail damage (§14.6) |

`drizzle` is rain and `hailstorm` is thunder (README decision 5); the pair of levels on the wire is the standard one for
that state, and the client maps a received state back to the kind. `cobolcraft:subroutine` has no weather (a dimension
with no sky light cannot have weather, 33 §4.1; core §3.3 CORE-8).

### 14.3 How the weather changes (interim until GAP-11)

The natural schedule (the choice of the next state and its duration) is not yet specified by the shared documents
(GAP-11); the standard durations are in 16 §4.10 (clear 12000 to 180000, rain 12000 to 24000, thunder 3600 to 15600).
Until GAP-11 closes, the earlier schedule stays as a placeholder, applied to the one server-level state:

- Every tick, if the `weather-changes` setting is on (FR-009) and the remaining time is not −1, it decreases
  by 1. While the setting is off it does not change (US11-4).
- A new world starts with `cobolcraft:clear` and 6000 remaining ticks. When the remaining time reaches 0, with
  r = H(0, `Time`) (§1.4.1):
  - if the current kind is clear: the next kind is drizzle when r mod 100 < 70, otherwise hailstorm;
  - otherwise the next kind is clear;
  - the remaining time becomes: clear 6000 + ((r div 100) mod 6001); drizzle 2400 + ((r div 100) mod
    2401); hailstorm 1200 + ((r div 100) mod 1201).
- The `weather` command (16 §4.10) sets the state and either a duration or "until changed"; the earlier cobolcraft
  `skies` command is retired (§16).

### 14.5 Environment textures

The sky tint and precipitation geometry of the earlier edition are retired (12 §3.3, §3.5, 14 §8.2 apply). The two
environment textures stay, as the cobolcraft world type's art for the two skins:

- **Environment textures** (16 × 16, transparent background, §1.4.1 rules):
  - `drizzle`: for each column x in {1, 5, 9, 13}, with s = (x × 7) mod 16, the five pixels
    (x, (s + k) mod 16) for k = 0 … 4 are `#A7C1DC` at alpha 66 % (streaks, 20 pixels).
  - `hailstorm`: for each 4 × 4 cell (cx, cy) with cx, cy from 0 to 3, with r = H(the ASCII bytes of
    `hailstorm`, cx, cy), ox = r mod 3 and oy = (r div 3) mod 3: `R(4cx + ox, 4cy + oy, 4cx + ox + 1,
    4cy + oy + 1)` is `#EEF2F7` at alpha 92 % (sixteen 2 × 2 pellets).

### 14.6 Hail (cobolcraft-only damage extra)

On every tick with `Time` mod 80 = 0 while the state is `hailstorm`, every alive survival player and every mob in
the dimension that is *exposed* takes 1 damage of the damage type `cobolcraft:hail` (§4.7), through the standard damage
path (17 §4). An entity is exposed when the biome cell containing its position has `has_precipitation` = 1 and every cell
of its column (floor(x), j, floor(z)) with floor(y + height) ≤ j ≤ the dimension's top y is void. Drizzle and clear have no
gameplay effect beyond the standard rain rules. The lightning of thunder is the standard 17 §4.11 (5.0 and ignition).

---

## 15. Extra dimensions

### 15.1 The Subroutine dimension

| Item | Value |
|---|---|
| Level (dimension) key | `cobolcraft:subroutine` (English name: Subroutine; command argument `subroutine`) |
| Dimension type | `cobolcraft:sunless` (id 1, §4.6) |
| Y range | 0 to 127 (min_y 0, height 128) |
| Sea level (CommonPlayerSpawnInfo) | 32. Nominal only. |
| Biome | `cobolcraft:ash_flats` (id 2) everywhere |
| Weather | none (§14.1) |
| Time | fixed: no day or night (`has_fixed_time`) |
| Enabled | when the `extra-dimensions` setting is on (FR-009, default on) |
| World folder | `dimensions/cobolcraft/subroutine/` (world-folder.md §1) |

The main dimension is `cobolcraft:main` (§5), English name: Main; command argument `main`.

### 15.2 Generator

Deterministic and stateless, like §5.2.

**Floor height.** For column (x, z), h = 32 + round(5 × sin(x / 11) × cos(z / 13)), angles in radians,
rounded to the nearest integer with halves away from zero. h lies between 27 and 37.

| Y | Block |
|---|---|
| 0 | baseplate |
| 1 to h − 3 | greystone |
| h − 2 to h | slag |
| h + 1 to 127 | void |

**Markers.** In every chunk whose chunk X and chunk Z are both multiples of 3 (mathematical modulo, so
negative multiples count), a lit glowtube (state 13) at local (8, h + 1, 8).

**Chunk payloads.** Sections 0–2 (Y 0–47) hold terrain: section 0 has 2 distinct states (4-bit Linear);
sections 1 and 2 have 1 to 4 (single value when 1, otherwise 4-bit Linear). Sections 3–7 are single-value void. Every section's biome palette is single value `ash_flats`. Heightmaps store the
topmost non-void Y + 1. No block entities.

### 15.3 Light and sky

- No sky light: the dimension type has `has_skylight` 0, so chunk and light packets carry no sky light
  (sky light masks and empty sky light masks are all zero).
- Block light by the shared light engine (§5.2; glowtubes 15, goto_pads 6).
- The sky is the standard attributes of core §3.3 (CORE-8): `skybox` `none`, sky and fog colour `#100c12`, sky light factor
  0.0; no sun or moon, no weather.

### 15.4 Mobs

Only abends spawn here, at any time, on slag in block light 5 or less (§12.4). Sodgrazers never spawn here
but may be brought here by command.

### 15.5 Travel

- **Means of travel:** the `cobolcraft:goto_pad` block (§1.1, block id 10, state 16), placed from the
  `cobolcraft:goto_pad` item (item id 16), which comes from recipe 7 (§13).
- **Trigger: Use Item On** (05c 0x42) aimed at a goto_pad block, by an alive player in either game mode,
  whatever is held. (Walking into a goto_pad does nothing.) The server never places a block or uses up an
  item for that packet. It is ignored if the same player travelled in the last 20 ticks, or if the
  `extra-dimensions` setting is off (US12-4: the player stays where they are).
- **Destination:** from `cobolcraft:main` to `cobolcraft:subroutine`, and from `cobolcraft:subroutine` to
  `cobolcraft:main`.
- **Arrival-point rule (both directions).** Let (X, Z) be the block x and z of the goto_pad used. In the
  destination, the chunk holding column (X, Z) is loaded (generated if new). Let `top` be the y of the
  highest non-void block in that column. If `top` is a goto_pad, the arrival goto_pad is that block at
  t = `top`; otherwise a goto_pad is placed at t = `top` + 1 (viewers are sent Block Update; light is
  recomputed). If t + 2 is above the destination's highest y (127 or 255), the travel does not happen. The
  player arrives with feet at (X + 0.5, t + 1, Z + 0.5), standing on the arrival goto_pad, with yaw and pitch
  unchanged. No block is ever removed by travel.
- **Arrival.** The player is sent Respawn with the destination's spawn info and `Data to keep` = 0x03,
  followed by the join sequence for that dimension (contracts/wire-profile.md §3.3), including its weather
  (the shared weather events, §14). Inventory, health, food level and game mode are unchanged (US12-1); eating is cancelled; the fall
  start is reset. Mobs and ground items stay in the dimension they were in.
- **Disabled dimension.** A player whose stored dimension is `cobolcraft:subroutine` while
  `extra-dimensions` is off is placed at the world spawn point in `cobolcraft:main` on joining (US12-4).

---

## 16. Command set

Retired for both world types (README S68 to S71, R3). The standard command set runs in the cobolcraft world type against the
cobolcraft registries: items, entity types and dimensions are named by their `cobolcraft:` keys through the standard argument
parsers (15 §6, 05a), permissions are the levels 0 to 4 (15 §2), the tree is filtered per player (15 §3.3), and the
messages are the standard keys (15 §5, 16). The earlier general rules, the 29-command table, the command tree and the
`cobolcraft.command.*` message keys are deleted. The dimension arguments of the earlier edition were `main` and
`subroutine`; they are now the keys `cobolcraft:main` and `cobolcraft:subroutine`.

One-time migration note (kept until 09 is rewritten): the earlier command to its standard counterpart. `howto` is `help`
(16 §8.6); `roster` is `list` (8.5); `murmur` is `msg`, `tell` or `w` (8.3); `promote` and `demote` are `op` and `deop`
(11.1, 11.2); `eject` is `kick` (11.8); `bar`, `unbar` and `barlist` are `ban` and `ban-ip`, `pardon` and `pardon-ip`,
and `banlist` (11.3 to 11.7); `guestlist` is `whitelist` (11.22); `mode` is `gamemode` (4.1); `relocate` is `teleport` or
`tp` (5.2); `supply` is `give` (6.1); `empty` is `clear` (6.2); `conjure` is `summon` (5.8); `sweep` is `kill` (5.1); `clock`
is `time` (4.5); `skies` is `weather` (4.10); `homestead` is `setworldspawn` (4.7); `announce` is `say` (8.1); `persist` is
`save-all` (11.9); `shutdown` is `stop` (11.12). `vitality` and `ration` have no standard counterpart (`damage` 5.7,
`effect` 5.10, `attribute` 5.12 and `kill` cover health; there is no set-food command). Dedicated-only commands and
`publish` and `unpublish`: 16 §2.

---

## 17. System messages

Disconnect and refusal reasons are `translate` components (contracts/wire-profile.md §1 message rule) with these keys;
their texts are in 08 §10.8. Every argument is a plain literal text component. Only the keys with no vanilla equivalent stay
(README S72); the others are the standard keys (the ones outside 15 §5 and 16 are GAP-27): `barred`, `replaced`, `shutdown`,
`ejected` and `ejected_plain` retire in favour of the shared standard keys, and `not_on_guestlist` is the standard
`multiplayer.disconnect.not_whitelisted` (16 §11.22).

| Key | Arguments | Sent as | When |
|---|---|---|---|
| `cobolcraft.disconnect.name_is_host` | [name] | Login Disconnect | A guest joins a world opened to others with the host's name (US17 edge case); the host stays. |
| `cobolcraft.disconnect.host_closed` | [] | play (or configuration) Disconnect | The host quit a world opened to others (US17-4). |
| `cobolcraft.disconnect.pack_required` | [] | configuration (or play) Disconnect | The player declined a required server pack (US18-7, 08 §9.7). |

Player chat is the standard Player Chat and Disguised Chat with the standard chat types, in both world types (README
decision 7, 16 §8; the chat type rows are core §3.5); the earlier "player chat stays literal" rule is retired.

---

## 18. Bitmap font

An original 8 × 8 bitmap font for ASCII codes 32 to 126, the built-in **fallback font for both world types** (research R13;
08 builds `assets/cobolcraft/font/default.json` and the pack file `minecraft:font/ascii.png` from it; README S73). The glyph
data and the advance table below are unchanged.

- **Glyph rows.** Each glyph is eight row bytes, top row first. In a row byte, bit 0x80 is column 0 (the
  leftmost) and bit 0x01 is column 7. A set bit is an ink pixel `#FFFFFF` (alpha 255); a clear bit is
  transparent. Row 6 is the baseline row (the bottom of capitals); row 7 holds descenders.
- **Atlas.** `ascii.png` (the file `minecraft:font/ascii.png`) is **128 × 128** pixels, a 16 × 16 grid of 8 × 8 cells as the
  standard font's file is (14 §10.2): the glyph for code c occupies the cell whose top-left pixel is ((c mod 16) × 8,
  (c div 16) × 8), so codes 32 to 126 fill rows 2 to 7 and rows 0, 1 and 8 to 15 are empty. (In 08's `bitmap` provider
  terms: 16 rows of 16 characters, rows 2 to 7 holding the ASCII characters 0x20 to 0x7E, height 8, ascent 7; faithful §6.3.)
- **Advance width.** A glyph's advance is (its rightmost column holding a set bit) + 2 pixels: one column of
  ink width plus one column of spacing. The space (code 32) has no ink and advances 4. The table lists every
  advance. This is the advance rule of 14 §10.3 at scale 1.
- **Missing glyph.** Any character outside codes 32 to 126 is drawn with the box glyph `F8 88 88 88 88 88 F8
  00`, advance 6.

| Code | Character | Rows (hex, top to bottom) | Advance |
|---|---|---|---|
| 32 | space | `00 00 00 00 00 00 00 00` | 4 |
| 33 | `!` | `20 20 20 20 20 00 20 00` | 4 |
| 34 | `"` | `50 50 50 00 00 00 00 00` | 5 |
| 35 | `#` | `50 F8 50 50 50 F8 50 00` | 6 |
| 36 | `$` | `20 78 A0 70 28 F0 20 00` | 6 |
| 37 | `%` | `C8 D0 20 20 40 B0 98 00` | 6 |
| 38 | `&` | `60 90 60 40 A8 90 68 00` | 6 |
| 39 | `'` | `20 20 00 00 00 00 00 00` | 4 |
| 40 | `(` | `10 20 40 40 40 20 10 00` | 5 |
| 41 | `)` | `40 20 10 10 10 20 40 00` | 5 |
| 42 | `*` | `00 A8 70 F8 70 A8 00 00` | 6 |
| 43 | `+` | `00 20 20 F8 20 20 00 00` | 6 |
| 44 | `,` | `00 00 00 00 00 20 20 40` | 4 |
| 45 | `-` | `00 00 00 F8 00 00 00 00` | 6 |
| 46 | `.` | `00 00 00 00 00 00 20 00` | 4 |
| 47 | `/` | `08 10 10 20 40 40 80 00` | 6 |
| 48 | `0` | `70 88 98 A8 C8 88 70 00` | 6 |
| 49 | `1` | `20 60 20 20 20 20 70 00` | 5 |
| 50 | `2` | `70 88 08 30 40 80 F8 00` | 6 |
| 51 | `3` | `F0 08 08 70 08 08 F0 00` | 6 |
| 52 | `4` | `10 30 50 90 F8 10 10 00` | 6 |
| 53 | `5` | `F8 80 F0 08 08 88 70 00` | 6 |
| 54 | `6` | `30 40 80 F0 88 88 70 00` | 6 |
| 55 | `7` | `F8 08 10 20 20 40 40 00` | 6 |
| 56 | `8` | `70 88 88 70 88 88 70 00` | 6 |
| 57 | `9` | `70 88 88 78 08 10 60 00` | 6 |
| 58 | `:` | `00 00 20 00 00 20 00 00` | 4 |
| 59 | `;` | `00 00 20 00 00 20 20 40` | 4 |
| 60 | `<` | `10 20 40 80 40 20 10 00` | 5 |
| 61 | `=` | `00 00 F8 00 F8 00 00 00` | 6 |
| 62 | `>` | `40 20 10 08 10 20 40 00` | 6 |
| 63 | `?` | `70 88 08 30 20 00 20 00` | 6 |
| 64 | `@` | `70 88 B8 A8 B8 80 78 00` | 6 |
| 65 | `A` | `20 50 88 88 F8 88 88 00` | 6 |
| 66 | `B` | `F0 88 88 F0 88 88 F0 00` | 6 |
| 67 | `C` | `78 80 80 80 80 80 78 00` | 6 |
| 68 | `D` | `E0 90 88 88 88 90 E0 00` | 6 |
| 69 | `E` | `F8 80 80 F0 80 80 F8 00` | 6 |
| 70 | `F` | `F8 80 80 F0 80 80 80 00` | 6 |
| 71 | `G` | `78 80 80 B8 88 88 70 00` | 6 |
| 72 | `H` | `88 88 88 F8 88 88 88 00` | 6 |
| 73 | `I` | `70 20 20 20 20 20 70 00` | 5 |
| 74 | `J` | `38 10 10 10 10 90 60 00` | 6 |
| 75 | `K` | `88 90 A0 C0 A0 90 88 00` | 6 |
| 76 | `L` | `80 80 80 80 80 80 F8 00` | 6 |
| 77 | `M` | `88 D8 A8 A8 88 88 88 00` | 6 |
| 78 | `N` | `88 C8 A8 98 88 88 88 00` | 6 |
| 79 | `O` | `70 88 88 88 88 88 70 00` | 6 |
| 80 | `P` | `F0 88 88 F0 80 80 80 00` | 6 |
| 81 | `Q` | `70 88 88 88 A8 90 68 00` | 6 |
| 82 | `R` | `F0 88 88 F0 A0 90 88 00` | 6 |
| 83 | `S` | `78 80 80 70 08 08 F0 00` | 6 |
| 84 | `T` | `F8 20 20 20 20 20 20 00` | 6 |
| 85 | `U` | `88 88 88 88 88 88 70 00` | 6 |
| 86 | `V` | `88 88 88 50 50 50 20 00` | 6 |
| 87 | `W` | `88 88 88 A8 A8 D8 88 00` | 6 |
| 88 | `X` | `88 50 50 20 50 50 88 00` | 6 |
| 89 | `Y` | `88 88 50 20 20 20 20 00` | 6 |
| 90 | `Z` | `F8 08 10 20 40 80 F8 00` | 6 |
| 91 | `[` | `70 40 40 40 40 40 70 00` | 5 |
| 92 | backslash | `80 40 40 20 10 10 08 00` | 6 |
| 93 | `]` | `70 10 10 10 10 10 70 00` | 5 |
| 94 | `^` | `20 50 88 00 00 00 00 00` | 6 |
| 95 | `_` | `00 00 00 00 00 00 00 F8` | 6 |
| 96 | grave accent | `40 20 00 00 00 00 00 00` | 4 |
| 97 | `a` | `00 00 70 08 78 88 78 00` | 6 |
| 98 | `b` | `80 80 F0 88 88 88 F0 00` | 6 |
| 99 | `c` | `00 00 78 80 80 80 78 00` | 6 |
| 100 | `d` | `08 08 78 88 88 88 78 00` | 6 |
| 101 | `e` | `00 00 70 88 F8 80 70 00` | 6 |
| 102 | `f` | `30 40 F0 40 40 40 40 00` | 5 |
| 103 | `g` | `00 00 78 88 88 78 08 70` | 6 |
| 104 | `h` | `80 80 F0 88 88 88 88 00` | 6 |
| 105 | `i` | `20 00 60 20 20 20 70 00` | 5 |
| 106 | `j` | `10 00 30 10 10 10 90 60` | 5 |
| 107 | `k` | `80 80 90 A0 C0 A0 90 00` | 5 |
| 108 | `l` | `60 20 20 20 20 20 70 00` | 5 |
| 109 | `m` | `00 00 D0 A8 A8 A8 88 00` | 6 |
| 110 | `n` | `00 00 F0 88 88 88 88 00` | 6 |
| 111 | `o` | `00 00 70 88 88 88 70 00` | 6 |
| 112 | `p` | `00 00 F0 88 88 F0 80 80` | 6 |
| 113 | `q` | `00 00 78 88 88 78 08 08` | 6 |
| 114 | `r` | `00 00 B0 C8 80 80 80 00` | 6 |
| 115 | `s` | `00 00 78 80 70 08 F0 00` | 6 |
| 116 | `t` | `40 40 F0 40 40 40 30 00` | 5 |
| 117 | `u` | `00 00 88 88 88 88 78 00` | 6 |
| 118 | `v` | `00 00 88 88 50 50 20 00` | 6 |
| 119 | `w` | `00 00 88 A8 A8 A8 50 00` | 6 |
| 120 | `x` | `00 00 88 50 20 50 88 00` | 6 |
| 121 | `y` | `00 00 88 88 88 78 08 70` | 6 |
| 122 | `z` | `00 00 F8 10 20 40 F8 00` | 6 |
| 123 | `{` | `18 20 20 40 20 20 18 00` | 6 |
| 124 | vertical bar | `20 20 20 20 20 20 20 00` | 4 |
| 125 | `}` | `C0 20 20 10 20 20 C0 00` | 5 |
| 126 | `~` | `00 00 40 A8 10 00 00 00` | 6 |
