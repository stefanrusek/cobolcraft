# Stand-in content (placeholder data for engineering)

Status: **placeholder**. Nothing in this document is final game design. It is the smallest coherent set of
original content that lets the COBOL client and the COBOL server go end to end: connect, configure, join,
receive chunks, render, walk around, and place and break blocks. Sections 9 to 18 extend it (FR-015) with
ground items, health, hunger, mobs, recipes, weather, a second dimension, the command set, system messages
and a bitmap font. Every value here is expected to be replaced. Section 7 lists what to replace.

Wire formats, packet layouts and the id-assignment rules are in [../protocol/](../protocol/README.md). This
document only chooses *content*. Section references such as "04 §5.2" point into that spec.

Every value in this document is exact. Where a rule needs a pseudo-random choice, it uses the integer hash
`H` of §1.4.1, so two implementations given the same state produce the same result. A "tick" is one server
(or single-player) game tick; there are 20 ticks per second.

## 0. Ground rules and the two compatibility tiers

- **Namespace.** All original content uses `cobolcraft:`.
- **Protocol-required names.** A few keys must use the `minecraft:` namespace because the vanilla client
  looks them up by exact name (04 §3.2). Each such key is marked **[compat name]**. Only the *name* is kept,
  for protocol compatibility. Every value attached to it is our own minimal placeholder.
- **Registry keys are protocol vocabulary, not content.** Names such as `minecraft:dimension_type`,
  `minecraft:worldgen/biome` or `minecraft:wolf_variant` name a *slot in the protocol*. We send them as-is.
  Enum values that a codec fixes (for example skybox `overworld` or `none`, model `normal`, scaling `never`)
  and identifiers the protocol defines (for example the command suggestion type `minecraft:ask_server`) are
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

Registration order defines the block id. Twelve blocks; id 0 is the air-equivalent.

| Block id | Key | Properties | Solid / collides | Opaque (occludes faces, blocks light) | Light emitted | Hand break time | Notes |
|---|---|---|---|---|---|---|---|
| 0 | `cobolcraft:void` | none | no | no | 0 | n/a | Empty space. Not targetable, not breakable, not placeable. |
| 1 | `cobolcraft:baseplate` | none | yes | yes | 0 | unbreakable | Bottom layer of every dimension (y = 0). Creative may place it but nobody may break it. |
| 2 | `cobolcraft:greystone` | none | yes | yes | 0 | 1.5 s | Bulk underground fill. "Hard" class. |
| 3 | `cobolcraft:loam` | none | yes | yes | 0 | 0.6 s | Subsoil. "Soft" class. |
| 4 | `cobolcraft:turf` | none | yes | yes | 0 | 0.7 s | Top surface on higher ground. "Soft" class. Different top, side and bottom faces. |
| 5 | `cobolcraft:grit` | none | yes | yes | 0 | 0.5 s | Top surface on low ground. "Soft" class. No gravity in the stand-in. |
| 6 | `cobolcraft:cardstack` | `axis` (x, y, z); `punched` (true, false) | yes | yes | 0 | 1.0 s | A bound stack of punch cards. Exercises the two-property Cartesian rule. "Hard" class. |
| 7 | `cobolcraft:lucite` | none | yes | **no** | 0 | 0.4 s | Clear block. Tests transparency and face culling. Faces between two lucite blocks are culled; faces against any opaque block are drawn on the lucite side only. |
| 8 | `cobolcraft:glowtube` | `lit` (true, false) | yes | yes | 15 when `lit=true`, 0 when `lit=false` | 0.3 s | Light source. Exercises the one-property rule and block light. Using it (right-click without a held block) toggles `lit`. |
| 9 | `cobolcraft:ledger_tile` | none | yes | yes | 0 | 1.2 s | Plain building block. "Hard" class. |
| 10 | `cobolcraft:goto_pad` | none | yes | yes | 6 | 2.0 s | The means of travel between dimensions (§15). Using it (Use Item On, with any held item or none) starts travel; nothing is ever placed against it and it is never toggled. No class. |
| 11 | `cobolcraft:slag` | none | yes | yes | 0 | 1.2 s | Surface fill of the `cobolcraft:subroutine` dimension (§15). "Hard" class. |

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
  hand-crafted packet.
- An unknown state id should decode to state 0 (void), mirroring 04 §5.2's last paragraph.

### 1.3 Placement, breaking and block yields

- Placing a block item puts the block's **default state**, except:
  - `cardstack`: `axis` follows the clicked face's axis (top/bottom face → y, east/west → x,
    north/south → z); `punched=false`.
- A position can receive a block only if it currently holds `void`, lies inside the dimension's height range,
  and the new block's cell would not overlap any player or mob (US4 edge cases).
- Use Item On a `goto_pad` never places a block, whatever is held: it starts travel (§15.5). Use Item On a
  `glowtube` with no block item held toggles `lit`; with a block item held it places against the glowtube
  as against any other block. Use Item On with a non-block item held (tools, food, `dump_shard`) places
  nothing.
- Breaking sets the position to state 0 (`void`). `baseplate` refuses.
- **Block yields (FR-002).** In survival, a broken block leaves its item **on the ground**: one
  `cobolcraft:loose_item` (§3, §9) holding one item of the block's item, at position (x + 0.5, y + 0.25,
  z + 0.5) for the broken block at (x, y, z), with motion (0, 0, 0) and a pickup delay of 6 ticks (§9.2).
  The block's item is the item that places it (§2): block id 2–9 → item id 2–9 (every `cardstack` state →
  item 6, both `glowtube` states → item 8), `goto_pad` → item 16, `slag` → item 17. In creative mode a break
  yields nothing (FR-007). Nothing is ever added straight to the breaker's inventory.

### 1.4 Placeholder textures

All block textures are **16 × 16** RGBA, generated procedurally at startup. Every recipe below admits
exactly one RGBA image; §1.4.1 defines the vocabulary the recipes use, and §1.5 lists check values.

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
| (missing texture) | — | — | Pixel (x, y) is `#F28C28` if ((x + y) div 2) mod 2 = 0, otherwise `#1A1A1A`: 2-px diagonal stripes running from bottom-left to top-right. Used for any unknown block, item, entity or environment texture; for a texture of another size the same formula is applied at that size. Engine-generated, not a pack file. |

Shading: the renderer applies its own fixed per-face brightness (data-model "Render list": top 1.0, north
and south 0.8, east and west 0.6, bottom 0.5). That is renderer policy, not texture content.

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
| 10 | `cobolcraft:pry_bar` | — | 1 | Tool. Divides break time by 4 for "hard" class blocks (greystone, cardstack, ledger_tile, slag). |
| 11 | `cobolcraft:trowel` | — | 1 | Tool. Divides break time by 4 for "soft" class blocks (loam, turf, grit). |
| 12 | `cobolcraft:grazer_flank` | — | 32 | Food (§11.5), value 3. Yield of the sodgrazer (§12). |
| 13 | `cobolcraft:seared_flank` | — | 32 | Food (§11.5), value 8. Recipe 6 (§13). |
| 14 | `cobolcraft:sod_cake` | — | 16 | Food (§11.5), value 2. Recipe 5 (§13). |
| 15 | `cobolcraft:dump_shard` | — | 64 | Crafting material. Yield of the abend (§12); recipe 8 (§13). |
| 16 | `cobolcraft:goto_pad` | goto_pad (16) | 16 | The travel block (§15). Recipe 7 (§13). |
| 17 | `cobolcraft:slag` | slag (17) | 64 | Building block from the Subroutine (§15). |

English names (08 §10.8) of the blocks and items added by the extension: `goto_pad` "GOTO Pad", `slag`
"Slag", `grazer_flank` "Grazer Flank", `seared_flank` "Seared Flank", `sod_cake` "Sod Cake", `dump_shard`
"Dump Shard".

Tools have no durability in the stand-in. Lucite, glowtube and goto_pad are in no class and break at hand
speed with any item. In creative, every break is instant. Each item's attack damage is in §10.4.

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

**Starting inventory** (FR-002, US4-8; slot numbers of data-model "Inventory": 0–8 hotbar, 9–35 main),
given once to a first-time survival player: slots 0 to 7 hold items 2 to 9 in id order, 64 each (slot 0
greystone, … slot 7 ledger_tile); slot 8 holds one `pry_bar`; slot 9 holds one `trowel`; every other slot is
empty. The held slot is 0.

---

## 3. Entity types

| Entity type id | Key | Size (width × height) | Eye height | Notes |
|---|---|---|---|---|
| 0 | `cobolcraft:operator` | 0.7 × 1.75 | 1.6 | Player-equivalent. Used for the joining player's own entity and in Add Entity (05a, id 1) for other players. Sends no entity metadata in the stand-in. |
| 1 | `cobolcraft:loose_item` | 0.3 × 0.3 | 0.15 | **Required.** An item on the ground (FR-002): every block yield, mob yield, thrown item and death drop is one of these. Rules in §9. Its only entity metadata is its item stack (Set Entity Data, 00 §12, 00 §13): one entry, index 0, serializer 7 (`ITEM_STACK`), sent after its Add Entity and whenever the stack changes. |
| 2 | `cobolcraft:sodgrazer` | 0.9 × 0.9 | 0.7 | Passive mob (§12). |
| 3 | `cobolcraft:abend` | 0.75 × 0.75 | 0.5 | Hostile mob (§12). |

"Size" is the collision box: centred on the entity position horizontally, from the position's y upward.

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
0.6875 blocks, a whisker narrower than the 0.7 collision box). Texture `operator`, 66 × 28: every face
rectangle filled `#3A5A9A`; then two 2 × 2 "eyes" in `#F0F0F0` at front (2, 4)–(3, 5) and front (7, 4)–(8, 5)
(in the upper third of the face toward the look direction). No limbs or animation.

### 3.3 Ground item appearance

A `loose_item` is drawn as its item's icon (§2) on a square 0.3 × 0.3 block quad, bottom edge at the entity
position's y, centred on the position horizontally, turned about the vertical axis to face the camera.

---

## 4. Synchronized registries

### 4.1 How to send them

- **Enabled features.** Send Update Enabled Features (03, id 13) with exactly one flag,
  `minecraft:vanilla` (protocol vocabulary, §0). Our client ignores the flag set.
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
- **NJ** — needed by the join flow or by the play loop, in tier A.
- **OE** — optional, left empty.

### 4.2 Summary

| # | Registry | Class | Entries sent |
|---|---|---|---|
| 0 | `worldgen/biome` | NJ + MV (`minecraft:plains`) | 3 |
| 1 | `chat_type` | NJ (sent for registry completeness, FR-002) | 1 |
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
| 19 | `damage_type` | MV (25 compat keys) + NJ (7 of ours) | 32 |
| 20 | `banner_pattern` | OE | 0 |
| 21 | `enchantment` | OE | 0 |
| 22 | `jukebox_song` | OE | 0 |
| 23 | `instrument` | OE | 0 |
| 24 | `test_environment` | OE | 0 |
| 25 | `test_instance` | OE | 0 |
| 26 | `dialog` | OE | 0 |
| 27 | `world_clock` | NJ (kept by FR-002; see 4.8) | 1 |
| 28 | `timeline` | OE | 0 |
| 29 | `decorated_pot_pattern` | OE | 0 |
| 30 | `block_transformer` | OE | 0 |
| 31 | `worldgen/block_state_provider` | OE | 0 |

That is 18 Registry Data packets and 52 entries (3 biomes, 1 chat type, 13 MV placeholders, 2 dimension
types, 32 damage types, 1 world clock). Both dimension types and all three biomes are always sent, even when
the `extra-dimensions` setting is off, so registry ids never depend on configuration. A tier-A-only server
could drop the 13 MV variant registries and the 25 compat damage keys. The recommendation is to keep them,
because they are cheap and keep tier B working.

### 4.3 `worldgen/biome`

| Id | Key | has_precipitation | temperature | downfall | effects | attributes |
|---|---|---|---|---|---|---|
| 0 | `minecraft:plains` **[compat name]** — our "lowland" | 1 | 0.6 | 0.4 | water_color `"#3A6EA5"`, grass_color `"#4F8F3A"`, foliage_color `"#4F8F3A"` | absent (empty) |
| 1 | `cobolcraft:upland` | 1 | 0.3 | 0.2 | water_color `"#2F5C8C"`, grass_color `"#6B9A55"`, foliage_color `"#6B9A55"` | absent (empty) |
| 2 | `cobolcraft:ash_flats` | 0 | 1.4 | 0.0 | water_color `"#3A2F2A"`, grass_color `"#5A4A40"`, foliage_color `"#5A4A40"` | absent (empty) |

- `temperature_modifier`, `dry_foliage_color` and `grass_color_modifier` are left absent (defaults).
- `minecraft:plains` is used only because the vanilla client looks it up as its fallback biome. In our game
  it means "lowland". It is placed at id 0 so that it is also the natural fallback for our client.
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
| 0 | `cobolcraft:say` | translation_key `cobolcraft.chat.say`, parameters [`sender`, `content`], no style | translation_key `cobolcraft.chat.say.narrate`, parameters [`sender`, `content`] |

Our client's language table maps `cobolcraft.chat.say` to "<%s> %s" and the narrate key to "%s says %s".
Player chat is broadcast as System Chat with the literal text `<name> message` (FR-013, §17), so this entry
is sent for registry completeness only. System messages do not use a chat type.

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
dimension's type.

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
| ambient_light | 0.0 | 0.0 | Our client's brightness floor of 0.1 (data-model "Render list") keeps the Subroutine faintly visible. |
| monster_spawn_light_level | Int 0 (constant form) | Int 0 (constant form) | Our spawning rules are §12.4, not this field; any value in 0–15 is valid. |
| monster_spawn_block_light_limit | 0 | 0 | As above. |
| skybox | absent (default `overworld`) | `none` | Protocol enum constants naming the client's sky mode, not content. |
| cardinal_light | absent (default) | absent (default) | |
| attributes | absent (empty) | absent (empty) | Avoids vanilla `environment_attribute` keys. Our client uses its own sky constants (§4.8, §15.3). |
| timelines | absent (empty) | absent (empty) | |
| default_clock | `"cobolcraft:daylight"` | absent | Refers to the `world_clock` entry in 4.8. A fixed-time dimension has no clock. |

Derived geometry (06 §1, §3.1, §7):

- `surface`: 16 block sections, section Y 0–15. Light covers 18 sections, section Y −1 to 16; light-mask bit
  i is section Y i − 1. Heightmap entries are `ceillog2(257) = 9` bits wide: 7 per Long, 37 Longs per
  heightmap.
- `sunless`: 8 block sections, section Y 0–7. Light covers 10 sections, section Y −1 to 8. Heightmap entries
  are `ceillog2(129) = 8` bits wide: 8 per Long, 32 Longs per heightmap.

### 4.7 `damage_type`

Our own three come first. The compat block follows. Four more of ours follow the compat block; they are
appended so that no earlier id moves.

| Id | Key | message_id | scaling | exhaustion | effects | death_message_type |
|---|---|---|---|---|---|---|
| 0 | `cobolcraft:generic` | `cobolcraft.generic` | `never` | 0.0 | absent | absent |
| 1 | `cobolcraft:impact` | `cobolcraft.impact` | `never` | 0.0 | absent | absent |
| 2 | `cobolcraft:below_world` | `cobolcraft.below_world` | `never` | 0.0 | absent | absent |
| 3–27 | the 25 compat keys below, in the listed order | `cobolcraft.compat` | `never` | 0.0 | absent | absent |
| 28 | `cobolcraft:mob_attack` | `cobolcraft.mob_attack` | `never` | 0.0 | absent | absent |
| 29 | `cobolcraft:player_attack` | `cobolcraft.player_attack` | `never` | 0.0 | absent | absent |
| 30 | `cobolcraft:starvation` | `cobolcraft.starvation` | `never` | 0.0 | absent | absent |
| 31 | `cobolcraft:hail` | `cobolcraft.hail` | `never` | 0.0 | absent | absent |

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
- Our server names only ids 0, 1 and 28–31 in packets (the causes of §10.3). Id 2 (`below_world`) is kept so
  ids never move, but no §10 cause uses it: every dimension's baseplate floor cannot be passed.
- The `message_id` values are protocol fields; our death messages are the §10.7 translation keys.

### 4.8 `world_clock`, day length and sky

| Id | Key | Data |
|---|---|---|
| 0 | `cobolcraft:daylight` | empty Compound |

Kept by FR-002 (§8 question 7 is closed). It gives Set Time (05b, id 115) a clock to report and gives the
`surface` dimension type its `default_clock`.

- **Day length.** The time of day `Time` runs from 0 to 29999 and advances by 1 every tick, wrapping from
  29999 to 0 (30,000 ticks = 25 minutes per cycle at rate 1.0). A new world starts at `Time` 0. One `Time`
  is shared by every dimension; the Subroutine's sky ignores it (§15.3).
- **Night.** It is *night* when 16000 ≤ `Time` < 29000 and *day* otherwise (used by §12.4).
- **Daylight factor** (client, `surface` dimension): with u in thousandths,
  - 0 ≤ `Time` < 15000: u = 1000;
  - 15000 ≤ `Time` < 16000: u = 1000 − ((`Time` − 15000) × 4) div 5;
  - 16000 ≤ `Time` < 29000: u = 200;
  - 29000 ≤ `Time` < 30000: u = 200 + ((`Time` − 29000) × 4) div 5.

  The daylight factor is u / 1000 (it multiplies sky light in the per-face brightness rule). Weather lowers
  u (§14.5).
- **Sky colour** (client clear colour, `surface` dimension): each of the R, G and B channels is
  N + trunc((D − N) × (u − 200) / 800), with D the day colour `#8FB8E6`, N the night colour `#0E1222`, and
  trunc truncating toward zero. At u = 1000 the sky is `#8FB8E6`; at u = 200 it is `#0E1222`. Weather tints
  it afterwards (§14.5).

### 4.9 Optional-empty registries (OE)

`trim_pattern`, `trim_material`, `sulfur_cube_archetype`, `banner_pattern`, `enchantment`,
`jukebox_song`, `instrument`, `test_environment`, `test_instance`, `dialog`, `timeline`,
`decorated_pot_pattern`, `block_transformer`, `worldgen/block_state_provider`: **no packet sent**. None
has a validator, and nothing in this content references them.

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
| Hashed seed | 0 for the stand-in |
| Game mode | From the server configuration or the world (FR-007, FR-009). Previous game mode: absent (0). |
| View distance / simulation distance | The configured view distance (default 8) for both. |

### 5.2 Generator

Deterministic and stateless: any column can be generated on its own from its (x, z) alone. No seed is used
yet.

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

**Light (stand-in policy).**

- Sky light: 15 in every void cell at or above the column's top non-void block + 1; 0 everywhere at or
  below it. There is no sideways spreading, and lucite does not let sky light through in the stand-in.
  Light sections fully at 15 are sent as arrays; light sections fully at 0 go in the empty mask.
- Block light: from each light-emitting block (a lit glowtube emits 15, a goto_pad 6; §1.1), level L at the
  block, minus 1 per block of taxicab distance through non-opaque cells, down to 0; where several sources
  reach a cell, the highest level wins. Generated chunks contain only marker glowtubes. Recompute the
  affected sections when a light-emitting block is placed, broken or toggled.
- This is deliberately crude. It exists to exercise the LightData encoding, not to look right.

**Spawn point.** Feet at (4.5, 54.0, 8.5), facing east (+X): yaw −90.0, pitch 0.0. Column (4, 8) has h = 52 + round(6 × sin(4/23) ×
cos(8/31)) = 52 + round(1.004) = 53, so the player stands on its turf. Chunk (0, 0) is a marker chunk, so the
marker pillar at (8, 55–59, 8) is four blocks ahead in plain view. (The column (8, 8) itself is not used
because the pillar occupies it.) The world spawn point is always in `cobolcraft:main`; the set-spawn command
(§16) moves it within this dimension.

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
| `minecraft:block` | `cobolcraft:hard` | 2 greystone, 6 cardstack, 9 ledger_tile, 11 slag |
| `minecraft:block` | `cobolcraft:soft` | 3 loam, 4 turf, 5 grit |
| `minecraft:item` | `cobolcraft:tools` | 10 pry_bar, 11 trowel |

If they are sent, the client should take tool speed from the tags rather than hard-coding section 2's
"class" lists. Until then both sides hard-code those lists.

---

## 7. Stand-in → replace later checklist

- [ ] Block set, names, break times and textures (section 1). The state registry now has 18 states, so the
      HashMap chunk palette is reachable (only by player building); the Global palette still is not.
- [ ] Real texture art and an atlas pipeline in place of the procedural recipes (1.4, 2, 3.1, 12.6, 14.5).
- [ ] Item set, stack sizes, tool behaviour; tool durability via data components (which brings in a
      `data_component_type` numbering).
- [ ] Ground-item rules (9): real physics (bouncing, sliding), merging of identical items.
- [ ] Player entity size, model and metadata (3).
- [ ] Health, damage values, fall rule, death and respawn rules (10); damage types: our own set now exists
      (4.7) — decide whether the compat block stays (tier B).
- [ ] Hunger, exhaustion rates, walking and sprint speeds, eating time, food items (11).
- [ ] Mob types, models, behaviour and spawning (12); a seeded random source in place of the `H`-based rules.
- [ ] Recipe set and the crafting interaction (13).
- [ ] Weather kinds, durations, drawing and effects (14).
- [ ] Biomes: real climate values and sky/fog via `attributes`; more than three biomes.
- [ ] Dimensions: height, min_y and ambient light; the Subroutine and its travel block (15).
- [ ] World generator: real noise, a seed, caves, water and fluids (non-zero fluid counts).
- [ ] A lighting engine in place of the column-drop sky light and taxicab block light.
- [ ] Command names, syntax and message texts (16, 17).
- [ ] Chat types and their language strings.
- [ ] Day length and sky colours (4.8); possibly a `timeline`. `world_clock` itself is kept (FR-002).
- [ ] The bitmap font (18).
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
7. ~~**Is `world_clock` / `default_clock` needed at all?**~~ Closed: FR-002 keeps the `world_clock` entry and
   the `surface` dimension type's `default_clock`; §4.8 now also fixes the day length, night and sky colour.
   The fixed-time `sunless` type has no `default_clock` (see question 12).
8. **Dimension Y bounds** (04 Open question 6). These do not affect us: both dimension types (min_y 0, height
   256 and 128) are well inside every candidate limit.
9. **Section buffer and count validation** (06 Open questions 1 and 3). Our server must write exactly 16
   sections (`surface`) or 8 sections (`sunless`) with correct non-empty counts. Our client should decide
   whether it trusts the counts or recomputes them. Recomputing is recommended, since the cost is small at 18
   states.
10. **Level key `cobolcraft:main` versus `minecraft:overworld`.** The vanilla client may treat the
    `minecraft:overworld` level key specially in play (for example compass behaviour). This is not relevant
    to tier A, and tier B does not reach play, so we keep our own keys (`cobolcraft:main`,
    `cobolcraft:subroutine`).
11. ~~**Feature flags.**~~ Resolved: Update Enabled Features (03, id 13) is sent in configuration with the
    single flag `minecraft:vanilla` (protocol vocabulary, like the registry keys of §0), as
    `docs/protocol/09-cobolcraft-profile.md` §3.1 fixes. A vanilla client may disable all items without it;
    sending it keeps that question out of tier B.
12. **A fixed-time dimension type without `default_clock`.** `sunless` sets `has_fixed_time` and omits
    `default_clock`. Whether a vanilla client accepts that combination in configuration was not traced (04
    marks both fields optional). Tier A is unaffected. If a tier B configuration test fails on it, give
    `sunless` the `default_clock` `"cobolcraft:daylight"` too; our client ignores it for a fixed-time type.
13. **Brigadier string kinds** (05a Open question 1). The command tree (§16.3) uses `brigadier:string` kinds
    0 (single word) and 2 (greedy phrase), whose ordinals are inferred. Client and server are both ours and
    use the same values, so tier A is self-consistent either way.

---

## 9. Ground items

Rules for `cobolcraft:loose_item` (§3; data-model §5). A ground item holds one item stack (item and count,
1 ≤ count ≤ the item's max stack).

### 9.1 Where ground items come from

| Source | Position | Initial motion | Pickup delay |
|---|---|---|---|
| Survival block break (§1.3) | (x + 0.5, y + 0.25, z + 0.5) of the broken block | (0, 0, 0) | 6 ticks |
| Mob defeat (§12.5) | the mob's position | (0, 0, 0) | 6 ticks |
| Throw (Player Action 5 `DROP_ITEM`: one item; 4 `DROP_ALL_ITEMS`: the whole stack, from the held hotbar slot; any game mode) | the thrower's feet + (0, 1.3, 0) | see below | 30 ticks |
| Death drop (§10.6) | the dead player's feet + (0, 0.5, 0) | see §10.6 | 30 ticks |

**Thrown motion.** With the thrower's yaw Y and pitch P in degrees (protocol convention: yaw 0 faces +Z,
yaw 90 faces −X; pitch positive looks down):
mx = −sin(Y) × cos(P) × 0.25, my = −sin(P) × 0.25 + 0.12, mz = cos(Y) × cos(P) × 0.25 (blocks per tick).
There is no random spread. A throw from an empty slot does nothing.

### 9.2 Per-tick rules

Ground items are processed once per tick, only while their chunk is loaded, in ascending network entity id
order, in this order of steps (§9.5 places the steps in the server tick):

1. **Pickup delay.** If it is above 0, it decreases by 1.
2. **Age and despawn.** If any player (any game mode, alive or dead) is in the same dimension with a feet
   position within **32.0** blocks (3D Euclidean distance between positions) of the item, its age increases
   by 1. Otherwise its age does not change (US5 edge case). When the age reaches **4800** ticks (4 minutes
   of a player being near), the item despawns: it is removed and viewers are sent Remove Entities. The age is
   saved as `Age` (world-folder.md §3); a new ground item has age 0. A despawned item skips the
   remaining steps.
3. **Movement.** The item's box is x ± 0.15, y to y + 0.3, z ± 0.15. A cell (i, j, k) is
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

Ground items never merge: two identical items lying side by side stay two entities.

### 9.3 Pickup

- **Range.** A player is in pickup range of an item when the item's box (above) overlaps, with positive
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

1. Received packets are handled in arrival order (break, place, throw, attack, eat start and stop, craft,
   command, travel).
2. `Time` advances (§4.8).
3. Weather countdown and changes (§14.3).
4. Player survival rules, players in entering order: hurt cooldown, eating completion (§11.6), exhaustion
   from time (§11.2), food point removal (§11.3), starvation (§10.3), recovery (§10.5), hail (§14.6).
5. Mob spawning (§12.4).
6. Mobs in ascending entity id order: hurt cooldown, AI (§12.3), physics (§12.2), hail (§14.6).
7. Ground items (§9.2).

All "every N ticks" rules that test `Time` use its value after step 2.

---

## 10. Health and death

These rules apply to players in survival mode only; creative players take no damage and have no health shown
(FR-007, US7-6). A player who switches to creative keeps their health and food values unchanged until they
switch back (US7 edge case).

### 10.1 Health

- **Maximum health: 30.** Health is a whole number from 0 to 30, sent as a Float in Set Health and saved as
  a Float (world-folder.md §2). A new player and a respawned player have 30.
- Mobs have the health of §12.1.

### 10.2 Taking damage

- Damage of amount A to a player or a mob: if its *hurt cooldown* is above 0, the damage is ignored.
  Otherwise health ← max(0, health − A), and the hurt cooldown is set to 12 ticks. The hurt cooldown
  decreases by 1 every tick (step 4 or 6 of §9.5) and never below 0.
- A damaged entity's viewers are sent Damage Event (with the §10.3 damage type id) and Hurt Animation; a
  damaged player is also sent Set Health.
- A player whose health reaches 0 dies (§10.6). A mob whose health reaches 0 is defeated (§12.5).

### 10.3 Causes of damage

| Cause | Amount | Damage type (§4.7) | Death message key (§10.7) |
|---|---|---|---|
| Falling | 2 × (floor(D) − 4) when floor(D) ≥ 5, otherwise none. D is the fall distance below. The **safe fall height is 4 blocks**. | `cobolcraft:impact` (1) | `cobolcraft.death.fall` |
| Hit by an abend (§12) | 3 | `cobolcraft:mob_attack` (28) | `cobolcraft.death.mob.abend` |
| Hit by another player (only when `player-combat` is on, FR-009) | the attacker's held item's damage (§10.4) | `cobolcraft:player_attack` (29) | `cobolcraft.death.player` |
| Starvation: while food is 0, every 60th consecutive tick at food 0 | 1 | `cobolcraft:starvation` (30) | `cobolcraft.death.starvation` |
| Hail (§14.6) | 1 | `cobolcraft:hail` (31) | `cobolcraft.death.hail` |
| Set-health command to 0 (§16) | sets health to 0 directly, ignoring the hurt cooldown | `cobolcraft:generic` (0) | `cobolcraft.death.command` |

**Fall distance.** The server keeps each player's *fall start*, the highest feet y reached since the player
was last on the ground. Each accepted Move Player packet with on-ground true ends a fall: D = fall start − the
new feet y, damage is applied as in the table, and the fall start becomes the new feet y. While the player is
on the ground, flying, or in creative mode, the fall start follows the feet y. Teleporting, travel and respawn
set the fall start to the new feet y.

**Starvation counter.** A per-player counter counts consecutive ticks with food at 0; at 60 the player takes
1 starvation damage and the counter returns to 0. It returns to 0 whenever food is above 0. Starvation can
kill.

Mobs take damage from player attacks (§10.4) and hail only; they take no fall damage and do not starve.

### 10.4 Attacks and item damage

| Held item (held hotbar slot) | Attack damage against players and mobs |
|---|---|
| empty slot (bare hand) | 1 |
| `pry_bar` (10) | 4 |
| `trowel` (11) | 2 |
| every other item | 1 |

An Attack packet (05c 0x01) from an alive player in either game mode hits when the target is a player or mob
in the same dimension, the target is alive, and the distance from the attacker's eye point (feet +
(0, 1.6, 0)) to the nearest point of the target's collision box is at most **4.0** blocks. A hit on a player
does damage only if `player-combat` is on and the target is in survival mode (US7 edge case). A hit on a
`loose_item` or out of reach does nothing. Every hit adds attack exhaustion to a survival attacker (§11.2).

### 10.5 Recovery

While a survival player's food is at least **20** and health is below 30, a per-player counter counts
consecutive ticks; at **50** the player gains 1 health (up to 30), gains 2.5 exhaustion (§11.2), is sent Set
Health, and the counter returns to 0. The counter returns to 0 whenever the condition does not hold.

### 10.6 Death and respawn

- **On death.** The dead player is sent Player Combat Kill whose message is the death message (§10.7); every
  connected player, in every dimension, is sent the same message as System Chat; the server console prints it
  (operator-surface.md §3). The player's dimension, position and game mode are unchanged until respawn.
- **Inventory.** Every non-empty slot s (0 to 35, ascending) becomes one ground item holding that slot's
  whole stack, at the dead player's feet + (0, 0.5, 0), with motion (((s mod 6) × 2 − 5) × 0.02, 0.2,
  (((s div 6) mod 6) × 2 − 5) × 0.02) and pickup delay 30. The inventory is then empty. Nothing is kept.
- **Respawn** (Client Command 0x0C action 0, PERFORM_RESPAWN, from a dead player): the player reappears at
  the world spawn point in `cobolcraft:main` (§5.2 or as set by command), with health 30, food 24, exhaustion
  0, all counters 0, and the game mode, held slot and inventory unchanged (empty, unless a command gave items
  while dead). The starting inventory (§2) is not given again.
- A player who disconnects while dead is stored with health 0 and is shown the death screen again on the next
  join (data-model §6).

### 10.7 Death and death-screen texts

Every death message is a `translate` text component (contracts/wire-profile.md §1 message rule; texts in 08
§10.8). Every argument is a plain literal text component.

| Key | Arguments | When |
|---|---|---|
| `cobolcraft.death.fall` | [victim name] | Fall damage killed the player. |
| `cobolcraft.death.mob.abend` | [victim name] | An abend's attack killed the player. (One key `cobolcraft.death.mob.<mob key path>` per hostile mob type; the abend is the only one.) |
| `cobolcraft.death.player` | [victim name, attacker name] | Another player's attack killed the player. |
| `cobolcraft.death.starvation` | [victim name] | Starvation killed the player. |
| `cobolcraft.death.hail` | [victim name] | Hail killed the player. |
| `cobolcraft.death.command` | [victim name] | The set-health command set the player's health to 0. |

Client-only texts of the death screen (in the client's own lang lookup, no arguments): the title
`cobolcraft.screen.death.title` and the respawn button label `cobolcraft.screen.death.respawn`. The cause line
under the title is the Player Combat Kill message.

---

## 11. Hunger and food

### 11.1 Food level

- **Maximum food level: 24.** Food is a whole number from 0 to 24, sent as the Food field of Set Health
  (saturation is always sent as 0.0) and saved as an Int. A new player and a respawned player have 24.
- Hunger applies only to alive survival players (US8-6).

### 11.2 Exhaustion

Each survival player has an exhaustion accumulator (a decimal number, starting at 0, not saved: a joining
player starts at 0). It gains:

| Activity | Exhaustion |
|---|---|
| Time: every tick | 0.005 |
| Walking: per block of horizontal distance moved while not sprinting and not flying | 0.02 |
| Running (sprinting: between Player Command 0x2A action 1 `START_SPRINTING` and action 2 `STOP_SPRINTING`): per block of horizontal distance moved while sprinting and not flying | 0.12 (six times walking) |
| Jumping: each accepted Move Player whose on-ground is false, following one whose on-ground was true, with a higher feet y | 0.3 |
| Attacking: each hit (§10.4) | 0.15 |
| Breaking a block (each completed survival break) | 0.025 |
| Recovering 1 health (§10.5) | 2.5 |

Horizontal distance is sqrt(Δx² + Δz²) between consecutive accepted positions. The server keeps the
sprinting flag from Player Command and clears it on death, respawn and travel.

### 11.3 Food point removal

Whenever exhaustion is at least **5.0**, 5.0 is subtracted and, if food is above 0, food decreases by 1 and
the player is sent Set Health. (This repeats within the same tick while exhaustion is still at least 5.0.)

### 11.4 Movement speeds

These are the client's horizontal ground speeds (nothing else in the documents fixes them):

- **Walking speed: 0.2 blocks per tick** (4.0 blocks per second).
- **Sprint speed: 0.28 blocks per tick** (5.6 blocks per second), used while the client is sprinting
  (client-surface.md §3: Left Control held while moving forward).

### 11.5 Food items

| Item id | Key | English name | Food value | How it is obtained (SC-008) |
|---|---|---|---|---|
| 12 | `cobolcraft:grazer_flank` | Grazer Flank | 3 | Yield of a defeated sodgrazer (2 per mob, §12.5). |
| 13 | `cobolcraft:seared_flank` | Seared Flank | 8 | Recipe 6 (§13): 2 grazer flank + 1 glowtube → 2. |
| 14 | `cobolcraft:sod_cake` | Sod Cake | 2 | Recipe 5 (§13): 4 turf + 1 loam → 1. |

Icons in §2.

### 11.6 Eating

- **Start.** Use Item (05c 0x43) from an alive survival player whose held hotbar slot holds a food item and
  whose food is below 24 starts eating that item; the server records the slot and the start tick. Use Item
  with food at 24 (US8-4), in creative mode, or without a food item held does nothing.
- **Eating time: 30 ticks** (1.5 seconds).
- **Completion.** When 30 ticks have passed since the start and the player is still eating, one item leaves
  the slot, food ← min(24, food + the item's value), and the player is sent Set Health, the slot update and
  Entity Event with event id 9 (eating finished, contracts/wire-profile.md §3.3) to the player and its viewers.
- **Cancel.** Player Action 6 `RELEASE_USE_ITEM`, a change of held slot, a change of the slot's contents,
  death, travel or a switch to creative before completion cancels it; nothing is eaten (US8 edge case).

---

## 12. Mobs

### 12.1 Mob types

| | `cobolcraft:sodgrazer` | `cobolcraft:abend` |
|---|---|---|
| Entity type id (§3) | 2 | 3 |
| English name | Sodgrazer | Abend |
| Kind | passive | hostile |
| Collision box (width × height), eye height | 0.9 × 0.9, 0.7 | 0.75 × 0.75, 0.5 |
| Maximum health | 8 | 12 |
| Wander speed | 0.05 blocks per tick | 0.04 blocks per tick |
| Flee speed | 0.1 blocks per tick | — |
| Pursue speed | — | 0.12 blocks per tick |
| Notice range | — | 12.0 blocks |
| Give-up range | — | 20.0 blocks |
| Attack reach | — | 1.75 blocks |
| Attack damage | — | 3 (§10.3) |
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
  within the attack reach and the cooldown is 0, the target takes 3 damage (`mob_attack`, §10.3) and the
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
   - `cobolcraft:main`, night (§4.8): `abend`, if the block light (§5.2) at (X, top + 1, Z) is at most 5.
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
item at the mob's position (§9.1). Mobs are saved with type, position, motion, rotation and health
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

Crafting (US10, data-model §8): a recipe is craftable for a player when the inventory holds every ingredient
count and the result fits after the ingredients are removed. A craft (Place Recipe, contracts/wire-profile.md
§3.3) makes the recipe once, atomically: all ingredients are removed and the result added (inventory add
rule), or nothing changes (US10-3, US10-4). Crafting works the same in both game modes and needs no block.
The display id sent in Recipe Book Add is the recipe's number below.

| Display id | Ingredients | Result |
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

Ingredients are listed in this order in the recipe display. No recipe uses `baseplate`, `slag`, `sod_cake`,
`seared_flank`, `pry_bar`, `trowel` or `goto_pad` as an ingredient.

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

### 14.1 Weather kinds

| Kind key | English name | (rain level, thunder level) | Environment texture | Gameplay effect |
|---|---|---|---|---|
| `cobolcraft:clear` | Clear | (0.0, 0.0) | none | none |
| `cobolcraft:drizzle` | Drizzle | (1.0, 0.0) | `textures/environment/drizzle.png` | none |
| `cobolcraft:hailstorm` | Hailstorm | (1.0, 1.0) | `textures/environment/hailstorm.png` | hail damage (§14.6) |

The pair is what Game Event carries (§14.4). The client maps a received pair back to the kind: rain level
below 0.5 → clear; otherwise thunder level below 0.5 → drizzle; otherwise hailstorm.

### 14.2 Where weather applies

- `cobolcraft:main` has weather. A kind is drawn and has its effect only in biomes with
  `has_precipitation` = 1: lowland and upland (§4.3), i.e. everywhere in the main dimension.
- `cobolcraft:subroutine` has **no weather**: it is always clear, it has no `Weather` entry in `level.dat`,
  and it is never changed by command (US11 edge case).

### 14.3 How the weather changes

Each dimension with weather has a kind and a remaining time in ticks (`level.dat` `Weather`, world-folder.md
§2). A new world starts with `cobolcraft:clear` and 6000 remaining ticks.

- Every tick, if the `weather-changes` setting is on (FR-009) and the remaining time is not −1, it decreases
  by 1. While the setting is off it does not change (US11-4).
- When it reaches 0, with dimension index d (0 for `cobolcraft:main`) and r = H(d, `Time`) (§1.4.1):
  - if the current kind is clear: the next kind is drizzle when r mod 100 < 70, otherwise hailstorm;
  - otherwise the next kind is clear;
  - the remaining time becomes: clear 6000 + ((r div 100) mod 6001); drizzle 2400 + ((r div 100) mod
    2401); hailstorm 1200 + ((r div 100) mod 1201). (Clear lasts 5 to 10 minutes, drizzle 2 to 4, hailstorm 1
    to 2.)
- The set-weather command (§16) sets the kind and either a remaining time (seconds × 20) or −1, meaning
  "until changed": no countdown at all, whatever the setting. −1 is saved as such in `Remaining`.

### 14.4 On the wire

To each player in the dimension, on join, on every change of kind, and on arrival by travel or teleport:
Game Event 1 `START_RAINING` (value 0.0) if the kind's rain level is above 0, otherwise Game Event 2
`STOP_RAINING` (value 0.0); then Game Event 7 `RAIN_LEVEL_CHANGE` with the rain level; then Game Event 8
`THUNDER_LEVEL_CHANGE` with the thunder level. A dimension without weather sends the clear sequence
(`STOP_RAINING`, 7 with 0.0, 8 with 0.0).

### 14.5 How weather is drawn (client)

- **Sky.** The daylight factor uses u′ = (u × 85) div 100 in drizzle and u′ = (u × 70) div 100 in a
  hailstorm (u from §4.8; clear keeps u). The sky colour is first computed from the unadjusted u (§4.8), then
  each channel c becomes (c × 60 + t × 40) div 100 with t from `#7A7F88` in
  drizzle, or (c × 45 + t × 55) div 100 with t from `#5A5E68` in a hailstorm. Clear changes nothing.
- **Precipitation geometry** (drizzle and hailstorm). With the camera in block column (cx, cz) at block y cy:
  for every column (x, z) with |x − cx| ≤ 8 and |z − cz| ≤ 8 whose biome at (x, top + 1, z) has
  `has_precipitation` = 1 (top: the column's highest non-void block), two vertical quads, 1 block wide,
  crossing at the column centre (one in the plane z = z + 0.5 spanning x to x + 1, one in the plane x = x + 0.5
  spanning z to z + 1), from y = max(top + 1, cy − 8) to y = cy + 16 (no quads if that range is empty). The
  kind's environment texture repeats every 1 block vertically (v = y mod 1 per block) and is scrolled
  downward by (`Time` × fall speed) mod 1 blocks (`Time` as the client last received it in Set Time, advanced by 1 per client tick), with fall speed 0.25 blocks per tick for drizzle and 0.5
  for hail. The quads are drawn with alpha blending, unlit, after opaque geometry.
- **Environment textures** (16 × 16, transparent background, §1.4.1 rules):
  - `drizzle`: for each column x in {1, 5, 9, 13}, with s = (x × 7) mod 16, the five pixels
    (x, (s + k) mod 16) for k = 0 … 4 are `#A7C1DC` at alpha 66 % (streaks, 20 pixels).
  - `hailstorm`: for each 4 × 4 cell (cx, cy) with cx, cy from 0 to 3, with r = H(the ASCII bytes of
    `hailstorm`, cx, cy), ox = r mod 3 and oy = (r div 3) mod 3: `R(4cx + ox, 4cy + oy, 4cx + ox + 1,
    4cy + oy + 1)` is `#EEF2F7` at alpha 92 % (sixteen 2 × 2 pellets).

### 14.6 Gameplay effects

- **Hail.** On every tick with `Time` mod 80 = 0 while a dimension's kind is hailstorm, every alive survival
  player and every mob in it that is *exposed* takes 1 damage (`cobolcraft:hail`, §10.3). An entity is
  exposed when the biome cell containing its position has `has_precipitation` = 1 and every cell of its
  column (floor(x), j, floor(z)) with floor(y + height) ≤ j ≤ the dimension's top y is void.
- Drizzle and clear have no gameplay effect.

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
| Weather | none (§14.2) |
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
- Block light exactly as §5.2 (glowtubes 15, goto_pads 6).
- The client draws a fixed sky colour `#100C12`, no sun or moon, no weather; the daylight factor does not
  apply (there is no sky light to scale).

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
  (§14.4). Inventory, health, food level and game mode are unchanged (US12-1); eating is cancelled; the fall
  start is reset. Mobs and ground items stay in the dimension they were in.
- **Disabled dimension.** A player whose stored dimension is `cobolcraft:subroutine` while
  `extra-dimensions` is off is placed at the world spawn point in `cobolcraft:main` on joining (US12-4).

---

## 16. Command set

### 16.1 General rules

- **Typing.** In chat a command is a line starting with `/`; at the server console it is the same text
  without the `/` (operator-surface.md §4). The rest of the line is split into words at single spaces; the
  first word is the command name. A greedy argument (`<message...>`, `<reason...>`) takes the rest of the line
  as written.
- **Permission.** "everyone": any player and the console. "operator": players holding operator status and the
  console (the console always has operator permission). In a single-player world the host holds operator
  status, and every command is available (US16-3); in a world opened to others the host holds it and guests
  hold it only if the host allowed it (US17-1). No command is console-only.
- **Order of checks.** (1) Unknown command name → `cobolcraft.command.unknown`. (2) Not permitted →
  `cobolcraft.command.not_permitted`. (3) Missing argument → `cobolcraft.command.missing_argument`; an
  argument that does not parse, is out of its range, is not one of the listed words, or extra words after
  the last argument → `cobolcraft.command.invalid_argument`. (4) The command's own checks, in the order
  listed in its row. The first failing check sends its message and nothing changes (US14-3, US14-4, US15-3).
- **Player names.** A name argument must be valid as a login name: 1 to 16 characters from `A`–`Z`, `a`–`z`,
  `0`–`9`, `_` (02; contracts/wire-profile.md §1); otherwise `cobolcraft.command.invalid_name`.
  **Target rule (operator decision I1, FR-016):** commands that act on a player in the world — eject
  (disconnect), relocate (teleport, both the moved player and a target player), supply (give item), empty
  (clear inventory), mode (set game mode), vitality (set health), ration (set food), murmur (private message)
  — need that player to be online in this world (exact, case-sensitive name match); an offline name gives
  `cobolcraft.command.player_not_found`. Bar (ban), unbar (lift ban), guestlist add and guestlist remove
  (allow-list), promote and demote (grant and revoke operator status) accept any valid name, online or not;
  the identity is the name and its offline UUID (02 Offline mode; FR-010), so they work for a player who has
  never joined. In a single-player world not opened to others, only the host is online. In a client-hosted
  world (single-player, opened to others or not) the host always holds operator status and cannot be
  disconnected by command: demote, eject and bar naming the host give `cobolcraft.command.is_host`. A dead
  player (awaiting respawn) is online.
- **Names of things.** Items, mob types and dimensions are named by the path of their key (for example
  `pry_bar`, `abend`, `subroutine`), because the single-word argument parser does not accept `:`. A
  disabled dimension counts as nonexistent.
- **Arguments in messages.** Every message is a `translate` component (contracts/wire-profile.md §1); every
  argument is a plain literal text component holding: names as written; integers in decimal without leading
  zeros (with `-` when negative); doubles with exactly two digits after the point, rounded half away from
  zero (for example `4.50`, `-12.25`); name lists as the names joined by `, ` (comma and space) in the stated
  order, or the empty string when the list is empty; usage strings and words exactly as in the tables.
- **Feedback.** Each message below goes to the sender (as System Chat for a player; printed through the
  `en_us` text for the console, operator-surface.md §3), unless the row says it goes elsewhere.

### 16.2 Commands

Ranges: x and z are doubles from −30000000.0 to 30000000.0; y is a double from 0.0 to 256.0 in the tree and
must also lie from the dimension's min_y to min_y + height − 2 (0 to 254 in main, 0 to 126 in the
subroutine), otherwise `cobolcraft.command.invalid_argument`. Where `[<dimension>]` is omitted it means the
sender's dimension for a player and `main` for the console.

| # | Command (usage string) | Who | Effect | Confirmation (key [arguments]) | Command-specific failures (key [arguments]) |
|---|---|---|---|---|---|
| 1 | `howto` | everyone | Lists the commands the sender may use, in this table's order. | `cobolcraft.command.howto.header` [number of entries that follow]; then one `cobolcraft.command.howto.entry` [usage string] per usage form | — |
| 2 | `roster` | everyone | Lists online players in entering order. | `cobolcraft.command.roster` [count, names] | — |
| 3 | `murmur <player> <message...>` | everyone | Sends the message to that player only. The target receives `cobolcraft.command.murmur.incoming` [sender name, message] from a player, or `cobolcraft.command.murmur.incoming_console` [message] from the console. | `cobolcraft.command.murmur.sent` [target name, message] | name invalid; player not found |
| 4 | `promote <player>` | operator | Grants operator status (saved in `access.dat`). If the player is online: they receive `cobolcraft.command.promote.notice` [] and a new command tree at once (US14-5). | `cobolcraft.command.promote.done` [name] | name invalid; `cobolcraft.command.promote.already` [name] |
| 5 | `demote <player>` | operator | Revokes operator status, also from the sender themself or the last operator (US14/US15 edge case). If online: `cobolcraft.command.demote.notice` [] and a new command tree. | `cobolcraft.command.demote.done` [name] | name invalid; `cobolcraft.command.is_host` [name]; `cobolcraft.command.demote.not_operator` [name] |
| 6 | `eject <player> [<reason...>]` | operator | Disconnects the player with `cobolcraft.disconnect.ejected` [reason] or, without a reason, `cobolcraft.disconnect.ejected_plain` [] (§17). | `cobolcraft.command.eject.done` [name] | name invalid; player not found; `cobolcraft.command.is_host` [name] |
| 7 | `bar <player>` | operator | Adds the identity to the ban list (saved). If online, the player is disconnected with `cobolcraft.disconnect.barred` [] (§17). | `cobolcraft.command.bar.done` [name] | name invalid; `cobolcraft.command.is_host` [name]; `cobolcraft.command.bar.already` [name] |
| 8 | `unbar <player>` | operator | Removes the identity from the ban list. | `cobolcraft.command.unbar.done` [name] | name invalid; `cobolcraft.command.unbar.not_barred` [name] |
| 9 | `barlist` | operator | Lists banned names in the order they were added. | `cobolcraft.command.barlist` [count, names] | — |
| 10 | `guestlist on` | operator | Turns allow-list enforcement on (saved in `access.dat`, survives restarts, A2). Players already online stay. | `cobolcraft.command.guestlist.on` [] | — |
| 11 | `guestlist off` | operator | Turns enforcement off. | `cobolcraft.command.guestlist.off` [] | — |
| 12 | `guestlist add <player>` | operator | Adds the identity to the allow-list. | `cobolcraft.command.guestlist.added` [name] | name invalid; `cobolcraft.command.guestlist.already` [name] |
| 13 | `guestlist remove <player>` | operator | Removes the identity. A removed online player stays online. | `cobolcraft.command.guestlist.removed` [name] | name invalid; `cobolcraft.command.guestlist.not_listed` [name] |
| 14 | `guestlist show` | operator | Lists allow-listed names in the order added, and the enforcement state as the word `on` or `off`. | `cobolcraft.command.guestlist.show` [`on` or `off`, count, names] | — |
| 15 | `mode <player> survival` / `mode <player> creative` | operator | Sets the game mode (Game Event 3, abilities, health and food display rules follow, FR-007). | `cobolcraft.command.mode.done` [name, `survival` or `creative`] | name invalid; player not found |
| 16 | `relocate <player> at <x> <y> <z> [<dimension>]` | operator | Moves the player's feet to (x, y, z) in that dimension (Player Position; Respawn and the join sequence when the dimension changes, as §15.5 without any goto_pad). | `cobolcraft.command.relocate.position` [name, x, y, z, dimension path] | name invalid; player not found; `cobolcraft.command.dimension_not_found` [word] |
| 17 | `relocate <player> to <target>` | operator | Moves the player to the target player's dimension and position. | `cobolcraft.command.relocate.player` [name, target name] | name invalid; player not found [the first of the two names, in argument order, that is not online] |
| 18 | `supply <player> <item> [<count>]` | operator | Adds count (1 to 2304, default 1) of the item with the inventory add rule; what does not fit is not added. | `cobolcraft.command.supply.done` [number added, item path, name] | name invalid; player not found; `cobolcraft.command.item_not_found` [word] (also for `nothing`); `cobolcraft.command.supply.no_room` [name] when nothing fits |
| 19 | `empty <player>` | operator | Empties all 36 slots (nothing is dropped). | `cobolcraft.command.empty.done` [name, total number of items removed] | name invalid; player not found |
| 20 | `vitality <player> <amount>` / `vitality <player> full` / `vitality <player> zero` | operator | Sets health to amount (0 to 30), 30 or 0. Health 0 kills the player (§10.3, cause `generic`), after the confirmation is sent. | `cobolcraft.command.vitality.done` [name, new health] | name invalid; player not found; `cobolcraft.command.not_survival` [name] if the player is in creative mode; `cobolcraft.command.not_alive` [name] if the player is dead |
| 21 | `ration <player> <amount>` / `ration <player> full` / `ration <player> zero` | operator | Sets food to amount (0 to 24), 24 or 0. | `cobolcraft.command.ration.done` [name, new food] | name invalid; player not found; `cobolcraft.command.not_survival` [name]; `cobolcraft.command.not_alive` [name] |
| 22 | `conjure <mob> <x> <y> <z> [<dimension>]` | operator | Spawns one mob of that type (`sodgrazer` or `abend`) at the position with yaw 0 and full health, ignoring §12.4's conditions and caps. | `cobolcraft.command.conjure.done` [mob path, x, y, z, dimension path] | `cobolcraft.command.mob_not_found` [word]; dimension not found; `cobolcraft.command.conjure.hostile_disabled` [mob path] for `abend` while `hostile-mobs` is off |
| 23 | `sweep <what> everywhere` / `sweep <what> area <dimension> <x1> <y1> <z1> <x2> <y2> <z2>` | operator | Removes the matching mobs and ground items in every enabled dimension, or those whose position lies in the box from (min x, min y, min z) to (max x, max y, max z) of the two corners, bounds included. `<what>` is `mobs` (every mob), `items` (every ground item), a mob type path (mobs of that type) or an item path (ground items of that item). | `cobolcraft.command.sweep.done` [number removed] | `cobolcraft.command.sweep.unknown_target` [word]; dimension not found |
| 24 | `clock <ticks>` | operator | Sets `Time` (0 to 29999); every player is sent Set Time. | `cobolcraft.command.clock.done` [ticks] | — |
| 25 | `skies <dimension> <kind> [<seconds>]` | operator | Sets the dimension's weather kind (`clear`, `drizzle` or `hailstorm`) for seconds (1 to 86400) × 20 ticks, or until changed when seconds is omitted (§14.3); players there are sent §14.4. | `cobolcraft.command.skies.timed` [dimension path, kind word, seconds] or `cobolcraft.command.skies.held` [dimension path, kind word] | dimension not found; `cobolcraft.command.skies.no_weather` [dimension path] for the Subroutine |
| 26 | `homestead <x> <y> <z>` | operator | Moves the world spawn point (always in `cobolcraft:main`; its yaw unchanged); every player in main is sent Set Default Spawn Position. | `cobolcraft.command.homestead.done` [x, y, z] | — |
| 27 | `announce <message...>` | operator | Every connected player receives `cobolcraft.command.announce.message` [message]; the console prints it. | `cobolcraft.command.announce.done` [] | — |
| 28 | `persist` | operator | Saves the world now (world-folder.md §5). | `cobolcraft.command.persist.done` [], sent after the save | — |
| 29 | `shutdown` | operator | Stops: on a server, saves and disconnects every player with `cobolcraft.disconnect.shutdown` [] and exits (US15-2); in a client-hosted world, it is the host quitting the world (guests get `cobolcraft.disconnect.host_closed` [], US17-4). | `cobolcraft.command.shutdown.done` [], sent before stopping | — |

Rows 10–14 are one command (`guestlist`), rows 16–17 one (`relocate`); `howto` lists each usage string
shown in the second column as one entry (35 entries in all for an operator or the console, 3 for everyone: one entry per
`/`-separated form). The capability map of FR-016: everyone — 1, 2, 3; operator status — 4, 5; disconnect —
6; ban, unban, list bans — 7, 8, 9; allow-list on/off, add, remove, list — 10 to 14; game mode — 15; move to
a position in any dimension or to a player — 16, 17; give item and count — 18; clear inventory — 19; health
and food including full and zero — 20, 21; spawn a mob — 22; remove mobs or ground items in an area or of a
type — 23; time of day — 24; weather in a dimension for a duration or until changed — 25; world spawn point —
26; message to all as the server — 27; save — 28; stop — 29.

### 16.3 Command tree

The Commands packet (05a 0x10) holds, under the root, one literal node per command the receiving player may
use (contracts/wire-profile.md §3.3), with the structure of §16.2: every fixed word (`at`, `to`, `full`,
`zero`, `on`, `off`, `add`, `remove`, `show`, `survival`, `creative`, `everywhere`, `area`, `clear`,
`drizzle`, `hailstorm`) is a literal node; a node is executable where a usage string may end. Argument nodes:

| Argument | Parser (05a parser id) | Properties | Suggestions |
|---|---|---|---|
| `<player>`, `<target>` | `game_profile` (7) | none | `minecraft:ask_server`: online player names (also offered for offline-capable commands) |
| `<item>` | `brigadier:string` (5) | 0 single word | `minecraft:ask_server`: item key paths (ids 1–17) |
| `<mob>` | `brigadier:string` (5) | 0 single word | `minecraft:ask_server`: `sodgrazer`, `abend` |
| `<what>` | `brigadier:string` (5) | 0 single word | `minecraft:ask_server`: `mobs`, `items`, mob type paths, item key paths |
| `<dimension>` | `brigadier:string` (5) | 0 single word | `minecraft:ask_server`: enabled dimension paths (`main`, `subroutine`) |
| `<message...>`, `<reason...>` | `brigadier:string` (5) | 2 greedy phrase | none |
| `<x>`, `<z>`, `<x1>`, `<z1>`, `<x2>`, `<z2>` | `brigadier:double` (2) | min −30000000.0, max 30000000.0 | none |
| `<y>`, `<y1>`, `<y2>` | `brigadier:double` (2) | min 0.0, max 256.0 | none |
| `<count>` | `brigadier:integer` (3) | min 1, max 2304 | none |
| `<amount>` (vitality) | `brigadier:integer` (3) | min 0, max 30 | none |
| `<amount>` (ration) | `brigadier:integer` (3) | min 0, max 24 | none |
| `<ticks>` | `brigadier:integer` (3) | min 0, max 29999 | none |
| `<seconds>` | `brigadier:integer` (3) | min 1, max 86400 | none |

Weather kinds in `skies` and modes in `mode` are literal nodes. A player without operator status is sent a
tree with only `howto`, `roster` and `murmur`; the tree is re-sent when operator status changes (US14-5).

### 16.4 Shared command messages

| Key | Arguments | When |
|---|---|---|
| `cobolcraft.command.unknown` | [the first word as typed] | Not a command name. The text names the help command (`howto`). |
| `cobolcraft.command.not_permitted` | [command name] | The sender may not use the command (US14-3). |
| `cobolcraft.command.missing_argument` | [usage string] | An argument is missing. The text names `howto`. |
| `cobolcraft.command.invalid_argument` | [the offending word as typed, usage string] | An argument is invalid or out of range, or extra words follow. The text names `howto`. |
| `cobolcraft.command.invalid_name` | [the word as typed] | Not valid as a player name at login. |
| `cobolcraft.command.player_not_found` | [name] | A command acting on a player in the world names a player who is not online (§16.1 target rule). |
| `cobolcraft.command.dimension_not_found` | [the word as typed] | No enabled dimension has that path. |
| `cobolcraft.command.item_not_found` | [the word as typed] | No item (other than `nothing`) has that path. |
| `cobolcraft.command.mob_not_found` | [the word as typed] | No mob type has that path. |
| `cobolcraft.command.not_survival` | [name] | Vitality or ration on a creative player. |
| `cobolcraft.command.promote.notice` | [] | To a player who has just been granted operator status. |
| `cobolcraft.command.demote.notice` | [] | To a player whose operator status has just been revoked. |
| `cobolcraft.command.not_alive` | [name] | Vitality or ration on a player who is dead (health 0, awaiting respawn). |
| `cobolcraft.command.is_host` | [name] | Demote, eject or bar names the host of a client-hosted world (§16.1). |

The usage string in `missing_argument` and `invalid_argument` is that of the first usage form, in §16.2
table order, whose fixed words match the words typed so far (for example `guestlist add <player>` for
`/guestlist add`, and `guestlist on` for `/guestlist` alone).

---

## 17. System messages

Disconnect and refusal reasons are `translate` components (contracts/wire-profile.md §1 message rule) with
these keys; their texts are in 08 §10.8. Every argument is a plain literal text component.

| Key | Arguments | Sent as | When |
|---|---|---|---|
| `cobolcraft.disconnect.barred` | [] | Login Disconnect; play Disconnect | A banned player tries to join (US2/US14 edge case); an online player is barred (§16). |
| `cobolcraft.disconnect.not_on_guestlist` | [] | Login Disconnect | Allow-list enforcement is on and the player is not on it. |
| `cobolcraft.disconnect.name_is_host` | [name] | Login Disconnect | A guest joins a world opened to others with the host's name (US17 edge case); the host stays. |
| `cobolcraft.disconnect.replaced` | [] | play (or configuration) Disconnect | The same name logs in again: the earlier connection is closed ("logged in from another location", US2 edge case). |
| `cobolcraft.disconnect.shutdown` | [] | play (or configuration) Disconnect | The server is stopping (US15-2, `shutdown`). |
| `cobolcraft.disconnect.host_closed` | [] | play (or configuration) Disconnect | The host quit a world opened to others (US17-4). |
| `cobolcraft.disconnect.pack_required` | [] | configuration (or play) Disconnect | The player declined a required server pack (US18-7, 08 §9.7). |
| `cobolcraft.disconnect.ejected` | [reason] | play Disconnect | `eject` with a reason (§16). |
| `cobolcraft.disconnect.ejected_plain` | [] | play Disconnect | `eject` without a reason. |

**Player chat stays literal.** A chat message from a player is broadcast as System Chat with the literal text
`<name> message` (§4.4, FR-013), never a `translate` component. Only player-authored chat is literal; every
message the server composes uses the keys of §10.7, §16 and §17.

---

## 18. Bitmap font

An original 8 × 8 bitmap font for ASCII codes 32 to 126, used for all client text (research R13; 08 builds
`assets/cobolcraft/font/default.json` and `assets/cobolcraft/textures/font/ascii.png` from it).

- **Glyph rows.** Each glyph is eight row bytes, top row first. In a row byte, bit 0x80 is column 0 (the
  leftmost) and bit 0x01 is column 7. A set bit is an ink pixel `#FFFFFF` (alpha 255); a clear bit is
  transparent. Row 6 is the baseline row (the bottom of capitals); row 7 holds descenders.
- **Atlas.** `ascii.png` is 128 × 48 pixels: the glyph for code c occupies the 8 × 8 cell whose top-left
  pixel is (((c − 32) mod 16) × 8, ((c − 32) div 16) × 8). (In 08's `bitmap` provider terms: 6 rows of 16
  characters, height 8, ascent 7.)
- **Advance width.** A glyph's advance is (its rightmost column holding a set bit) + 2 pixels: one column of
  ink width plus one column of spacing. The space (code 32) has no ink and advances 4. The table lists every
  advance.
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
