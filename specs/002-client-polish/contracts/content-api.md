# Contract: `content` library (`content` -> `core`, `server`, `client`)

**Status**: frozen at plan time. Materialized as `contract/copy/CONTENT.cpy` (constants, record shapes) and the
generated tables under `content/copy/gen/` (R2, R3; not hand-edited). Package `content` builds
`build/content/libcontent.a` over `shim`, `proto` and `formats`.

**What it is.** The registry model of 23 and the two content sets (R6). It never runs game rules.

## 1. Records (`CONTENT.cpy`)

| Record | Fields |
|---|---|
| `CT-SET` (one per open world or connection; EXTERNAL) | type (`standard` or `cobolcraft`), packs status (`ok`, `absent`, `incomplete`, `stale`, `damaged`), generated directory, registry counts |
| `CT-BLOCK-ROW`, `CT-ITEM-ROW`, `CT-ENTITY-ROW`, `CT-STATIC-ID-ROW` | fixed-width views of the generated rows (data-model §2); read only through the accessors below |
| `CT-REGISTRY`, `CT-ENTRY` | registry key, entries in id order with their JSON/NBT payload offsets (23 §3.4) |
| `CT-TAG` | tag key, resolved member ids (23 §6.3) |

## 2. Entry points

| Program | Parameters | Behaviour |
|---|---|---|
| `CONTENT-PACKS-CHECK` | generated directory, OUT status word, OUT reason text | The check of 22 §8.2 (manifest, accepted-jar row, sentinels). Reads no jar and hashes nothing. |
| `CONTENT-OPEN` | type, generated directory, OUT status | Opens a content set. Standard: refuses unless the check is `ok`; loads the 51 world registries, dimensions and tags from `vanilla-data` and the world's `datapacks/` through the 23 sequence (strict JSON, freeze, validate). Cobolcraft: attaches the built-in layer only; never reads the generated data pack. |
| `CONTENT-CLOSE` | - | Frees the set. |
| `CONTENT-BLOCK-BY-KEY`, `CONTENT-BLOCK-OF-STATE`, `CONTENT-STATE-PROPS`, `CONTENT-STATE-DEFAULT` | key or state id -> row, property values | Block and state lookups (24 part 1 §2, §3). Works for both sets (cobolcraft states 0 to 17 are rows of the built-in layer). |
| `CONTENT-ITEM-BY-KEY`, `CONTENT-ITEM-BY-ID`, `CONTENT-ITEM-COMPONENT` | -> row / component value | 25 and 17 §1 default components. |
| `CONTENT-ENTITY-BY-KEY`, `CONTENT-STATIC-ID` | registry key, entry key -> id | 46 id tables. |
| `CONTENT-REGISTRY-ENTRY`, `CONTENT-REGISTRY-COUNT` | registry, index -> entry | Entries for the Registry Data packets and for rules (recipes, loot, enchantments, biomes, damage types). |
| `CONTENT-TAG-HAS`, `CONTENT-TAG-MEMBERS` | tag key, entry id -> 0/1 / list | Tag resolution of 23 §6; the same programs serve the client's network-form tags (23 §6.6). |
| `CONTENT-CLIENT-REGISTRY-ADD`, `CONTENT-CLIENT-FINISH` | Registry Data / Update Tags packet bodies | The client's load from the network (23 §4) and the decision of the world type from `minecraft:dimension_type` at Finish Configuration (world-types.md WT-16). |

## 3. Rules

- Both sets answer the same questions with the same record shapes; a caller never tests the world type to decide a
  lookup (the type chooses which rows exist, nothing else).
- An unknown key or id is a defined outcome (row 0 / "not found" status), never a crash; a chunk or entity with a
  key outside the set is the WT-23 case handled by the caller.

## 4. Contract tests

`content/tests/contract_content_provider.cob` (lookups return the worked examples of 24 §16, 46 §15, 23 §3.4 and
§6.7 for the standard set and the 001 stand-in rows for the cobolcraft set) and one consumer test in each of
`core`, `client` (`contract_content_consumer.cob`) that opens a set through a fixture generated directory
(`contract/fixtures/content/` small valid and damaged trees) and asserts the status words and one lookup each.
