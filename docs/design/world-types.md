# World types: the standard and the cobolcraft world type

Status: design, round RS2 (GAP-33 and GAP-23 of [README.md](README.md) Part 5). This document defines the **world type**
mechanism: what a world type is, how a world gets its type, what the type selects, what stays shared, the default rule,
the namespace rule, what happens when the generated packs are missing, and how the packs and registries of the two types
are kept apart. It contains no game content rows. Section references use the forms "README Part 4, C7" (this folder's
[README.md](README.md)), "22 §8.2" (docs/protocol/22-extraction-tool.md), "08 §1.6", "04 §5", "07 §9", "standin §1.1"
([standin-content.md](standin-content.md)), "ui §7" ([builtin-ui-art.md](builtin-ui-art.md)) and "CC-0001"
(tickets/CC-0001-client-polish.md). Every judgement call is marked **Decision WT-n** with its reason. Decisions marked "adopted default" are not operator rulings: they are defaults this document adopts until the operator answers, and
the README must say the same. **Pending, not done:** a search of README.md finds no `WT-` identifier, README Part 7 decisions 2, 3, 9 and 10 and Part 4 C10 and R1 still carry the older wording (jar, no seed, no WT-24 to WT-26), so the README is not yet consistent with this document. Section 9 lists the edit, and its README Part 7 row is to list every one of them: WT-12, WT-17 (a valid generated directory instead of the jar), WT-19, WT-20, WT-22, WT-23, WT-24, WT-25, WT-26 and the skin pack placement). Anything that is not
settled is a numbered Open question at the end. Decision numbers are by order of writing, not of position: WT-1 to WT-4 in
section 3, WT-5 to WT-7, WT-19, WT-24 and WT-26 in section 2.1, WT-20 in section 3.1, WT-8, WT-21 and WT-22 in sections 5 and 6.2, WT-9
to WT-11, WT-13 and WT-25 in section 6, WT-14 to WT-16 and WT-23 in section 7, WT-17 and WT-18 in section 8, WT-12 in section 10.

Sources of the rules used here: CC-0001 Decisions "Namespace", "Own world type", "Stand-in content", "Vanilla assets and
data"; README Part 0 (R1 to R10), Part 4 (C1 to C14) and Part 7 (adopted defaults 2, 3, 6, 9, 11, 16, 18); 08 §1.6, §3.1,
§10; 22 §8 and §9. Where this document and the older wording of README Part 4, C10 or Part 7, decision 2 differ, this
document refines them (section 8.1) and says so.

---

## 1. The model

A **world type** is the content set of a world. There are two.

| | **standard** | **cobolcraft** |
|---|---|---|
| Content | Minecraft 26.3: its registries, blocks, items, mobs, recipes, loot, tags, worldgen, dimensions | The invented content of standin-content.md (12 blocks, 18 items, 4 entity types, 9 recipes, 2 dimensions), unchanged as content (CC-0001), re-expressed as components and tags where README Part 7 decisions 4 and 5 and README S11, S21 and S24 already say so. Decision WT-12 adds one block, one item and one recipe: that conflicts with the ticket wording "for now unchanged" and needs operator confirmation (section 10) |
| Where the data rows come from | The generated vanilla data pack and resource pack, built by the extraction tool from the user's client jar (22) | The game itself: the built-in `cobolcraft` pack (08 §10) and the hand-authored core of README Part 4, C3 |
| Where the code comes from | The engines of documents 10 to 21 and the later research documents | The same engines, plus the cobolcraft generators of standin §5.2 and §15.2 |
| Needs the jar or generated packs to run | Yes: a valid generated directory (22 §8.2 result `ok`) | No: runs with nothing generated and nothing in `resourcepacks/` (22 §9.1) |
| Playable by a vanilla client | Aim: yes (README R8, C14) | No (04 §5) |
| Namespace of its content | `minecraft:` | `cobolcraft:` for its own content |

The world type selects **content and nothing else** (08 §1.6). Everything in section 5 is shared.

A world has exactly one type for its whole life (Decision WT-4). A process (server, single-player host, client
connection) holds one world type per world it serves or joins.

---

## 2. Identity and storage

### 2.1 The key

The type is stored in `level.dat` (07 §9.2), as a new key.

| Key | NBT type | Values | Meaning |
|---|---|---|---|
| `WorldType` | String | `standard`, `cobolcraft` | The type of the world. Written when the world is created. Never changed afterwards |
| `Seed` | Long | any | The world seed. Used by the standard generator and, through `obfuscateSeed`, by the hashed seed of the Login packet (see below). Written for both types for a uniform schema (Decision WT-5). The cobolcraft generator uses no seed (standin §5.2: deterministic and stateless), so for a cobolcraft world the value is stored and never read |
| `ContentJar` | String | lower-case hex SHA-256, or absent | For a standard world: the `jar-sha256` of the manifest of the generated directory at creation (22 §6.4). Absent for a cobolcraft world, also when valid generated packs exist at creation (E5): a cobolcraft world does not read them, so there is nothing to record. Informational in this version (Decision WT-6) |

**Placement.** The three keys sit in the root compound of `level.dat`, next to `DataVersion` (07 §9.2; the root is the unnamed compound of 07 §9.1). They are written when a `level.dat` is first created, in the order `WorldType`, `Seed`, `ContentJar` (`ContentJar` omitted when absent), after the keys 07 §9.2 already lists; NBT compounds are unordered on read, so the order is a writing convention only. Where they would sit under another layout is Decision WT-21 and Open question 12.

**A world exists in a folder** if and only if `level.dat` is present in it. (Decision WT-24, adopted default.) A folder with no
`level.dat` and no `dimensions/` content (empty, or holding only other files) holds no world: a creation may use it. A
folder with no `level.dat` but with `dimensions/` content is **not opened and not used for creation**; the dedicated server
prints "This folder holds world data but no level.dat." and exits with code 10, the single-player list shows the row with that
second line and disables Play. Reason: creating over saved chunks would destroy them. This replaces the sentence of 07 §9.5 "A world folder without `level.dat` is created new, with all enabled dimensions" for a folder that holds `dimensions/` content (section 9).

Reading rules for a folder that has `level.dat`, in order:

1. `WorldType` is `standard` or `cobolcraft`: that is the type.
2. `WorldType` is absent and the world folder holds no `dimensions/minecraft/` folder: the type is `cobolcraft`. On the next
   save the server (the dedicated server or the single-player host; no other tool writes these keys, Decision WT-26) writes `WorldType = cobolcraft` and `Seed = 0` if `Seed` is absent, and leaves `ContentJar` absent
   (Decision WT-7). If the world is opened read-only nothing is written and this rule applies again at each open (Decision WT-26). Worlds of feature 001 follow 07 §9.1, which names no `minecraft` dimension folder, so they cannot hold one.
3. `WorldType` is absent and the folder holds `dimensions/minecraft/...`: the folder is not from a version that had no type key,
   so the world is **not opened**. The message is `cobolcraft.world_type.missing` (key name proposed, text "This world has no
   world type and cannot be opened."). Nothing is altered. Exit code and list row as in rule 4.
4. `WorldType` is any other string (the match is exact and case-sensitive: `Standard` is another string), or the tag is not a String (a wrong NBT type; `<value>` is then shown as `(not a string)`; Decision WT-26): the world is **not opened**. The message is `cobolcraft.world_type.unknown` (key
   name proposed, text "This world was made by a newer version of the game (world type '<value>')."). Nothing is altered.
   The dedicated server prints the text on the console and exits with code 10 (section 3.5). The single-player world list
   shows the row with the second line "Unknown world type '<value>'", and Play is disabled (ui §7.3).

**Seed rules.** At creation, `Seed` is the value the creator gave, or, when none was given, one random 64-bit value drawn at
creation. The creator gives it on the Create New World screen (an optional text field) or
in the server configuration (key `level-seed`, empty means draw). **Decision WT-19 (seed input, adopted default).** The text
rule: a text that is an optional minus sign followed by **one or more** decimal digits (a lone `-` is not a number and is hashed), and fits a signed 64-bit integer, is that number. The text is taken exactly as typed or configured, with no trimming of whitespace (so a text with a space is not a number and is hashed); a leading `+` is not a minus sign, so `+5` is hashed; leading zeros are allowed and the value is the parsed one (`007` is 7, `-0` is 0); a text whose value is outside the signed 64-bit range is hashed. Any other
non-empty text is hashed: `h = 0`; for each UTF-16 code unit `c` of the text, `h = (31 * h + c)` in 32-bit two's complement
wrap-around; the seed is `h` sign-extended to 64 bits. The text is first turned into UTF-16 code units: a typed or configured UTF-8 text is decoded to code points, and each code point above U+FFFF becomes a surrogate pair (high surrogate first), so the hash is over those units. Test vectors: `a` gives 97, `ab` gives 3105, `abc` gives 96354, `hello` gives 99162322 (each below 2^31, so sign extension changes nothing). (This is the 32-bit string hash of the Java platform; whether vanilla uses it
for the seed field is not read here, so equality with vanilla seeds is not claimed.) The random draw uses the platform's random source, uniform over all 64-bit values, and has no algorithm or test value to specify (any value is valid). Reason: a
fixed, stated rule is needed to implement the field and the key, a number must stay a number so a seed copied from a vanilla
game can be typed, and no README or spec text gives another. The field and key names are final in this document. On reading: a standard world whose `Seed` is absent is **not opened** (the generator cannot run without
it), with the text "This world has no seed and cannot be opened." and the same exit code and list row treatment as rule 4. A
cobolcraft world whose `Seed` is absent reads it as 0.

**Login hashed seed (09 §3.2).** In a cobolcraft world it is 0 (standin §5.1, §15, 09 §3.2). In a standard world it is
`obfuscateSeed(Seed)` (**inferred**: 05b, on `Seed` in CommonPlayerSpawnInfo, calls the hashed-seed meaning "presumably" and its open item 2 says the bytecode shows only a Long; supported by 10 §7.7, which reads `MinecraftServer` and `ServerPlayer` calling `obfuscateSeed` with the same world seed "for other purposes"), with `obfuscateSeed` defined in 10 §7.7 as the first 8 bytes of the SHA-256 of the 8 little-endian bytes of the seed, read as
a little-endian 64-bit integer.

**Decision WT-5 (Seed for both types).** Reason: one schema, so 07 §9.2 gets one new key either way. The cobolcraft value is
unused (the generator takes no seed and the Login hashed seed is the fixed 0 above); it is written only to keep one schema.

**Decision WT-6 (ContentJar is informational).** Only one jar row is accepted today (22 §4.1). Rows are only added, never
removed, so a world made from row X can always be opened while the packs are valid. The key records provenance so a future
second row can decide whether to warn. It never blocks opening in this version. Reason: no rule can be tested with one row.

**Decision WT-7 (absent key means cobolcraft).** Worlds written before this key existed come from feature 001, which had
only the cobolcraft content. Treating them as standard would send the wrong registries. Reason: the only possible type for
them. The exception is reading rule 3, a folder that cannot have come from feature 001.

**Decision WT-26 (reading edges and the exit code, adopted default).** (a) The keys of section 2.1 are written only by the
server or the single-player host, never by a tool; a world opened read-only is not written and rule 2 is re-applied at each
open. (b) `WorldType` matching is exact and case-sensitive; a non-String tag falls into rule 4. (c) Exit code **10** is a
judgement call, not a read fact: `contracts/operator-surface.md` names only status 1 (line 36) and names no codes 2 to 9, so 10
is free in the contract as written; it was chosen to stay clear of the tool's codes 1 to 6 (22 §7.4) and of status 1. Reason:
no source states these edges; each is the least surprising reading.

### 2.2 Folder layout

The world folder is unchanged (07 §9.1): `dimensions/<namespace>/<path>/` is the dimension key split at the colon. A
standard world holds `dimensions/minecraft/overworld/`, `dimensions/minecraft/the_nether/` and
`dimensions/minecraft/the_end/`. A cobolcraft world holds `dimensions/cobolcraft/main/` and
`dimensions/cobolcraft/subroutine/`. Because the two sets of folder names never coincide, a folder copied by hand from one
type into the other is recognisable, and the `WorldType` key always decides.

---

## 3. How a world gets its type

### 3.1 The three surfaces

| Surface | Where | Effect |
|---|---|---|
| Single-player creation | Create New World screen, one cycle button (ui §7.2, Decision UI-15) | Sets the type of the new world |
| Dedicated server | Configuration key `world-type` (values `auto`, `standard`, `cobolcraft`) | Sets the type of a world the server **creates**. Ignored for an existing world |
| `level.dat` | `WorldType` (section 2.1) | The type of an existing world. Always wins |

Order of evaluation at server start: first, does a world exist in the folder; if so its `level.dat` decides and the configuration
key is not consulted (but see the invalid-value rule below). Only when no world exists is the configuration read for the type.

**Decision WT-1 (the configuration key is a creation default only).** `world-type` in the server configuration is the
starting value for a world the server creates, exactly as the allow-list setting is only the starting value (07 §9.2; spec
FR-009). Once the world exists, `level.dat` decides. If the configuration says `standard` and the folder holds a cobolcraft
world, the server runs the cobolcraft world and prints one line on the console: `world-type=standard is ignored: this world is cobolcraft`. Reason: a configuration edit must never reinterpret saved chunks.

**Decision WT-20 (configuration edge cases, adopted default).** A `world-type` value other than the three is an invalid value
in the sense of `contracts/operator-surface.md` (an invalid value is fatal): the server follows the contract's form, prints
`FATAL configuration: world-type: must be auto, standard or cobolcraft (got '<value>')` and exits with **status 1**, before
looking at any world. A configuration file that exists but has no `world-type` key (written by an older server): a missing key takes
its default (the contract), so the value is `auto`, and the file is **not** rewritten (07: defaults are written only when the file
is absent). Reason: the contract already defines both cases; this document adds no second console form. The refusals of
Decision WT-3 and of section 2.1 (not a configuration syntax problem but a world that cannot be used) use exit code 10, which
the contract does not have: that is a contract addition listed in section 9.

**Decision WT-2 (the default is `auto`, and `auto` is written, not a resolved value).** When the server writes a new
configuration file with default values (spec US13), it writes `world-type=auto`. The rule of section 3.2 is applied only when
a world is created. Reason: if the server wrote the resolved value, a server first started before the tool was run would
write `cobolcraft` into its file and keep creating cobolcraft worlds after the packs were generated, with no sign why.

### 3.2 The default rule

Applied when a world is created and the choice is `auto` (server) or untouched (single-player). **Untouched** is an explicit
state of the Create screen: the type button is in the state *auto* until the player presses it for the first time. In *auto*
the button label shows the type the rule yields; after the first press the choice is *explicit*, even when the player cycles back
to the label it started on. The state lives only in the screen and is not stored.

| Result of the generated-pack check (22 §8.2) | Type chosen |
|---|---|
| `ok` | `standard` |
| `absent`, `incomplete`, `stale`, `damaged` | `cobolcraft` |

This is README Part 7, decision 2 as adopted, with the check of 22 §8.2 in place of "the jar" (section 8.1). On the Create
New World screen the cycle button starts on the type the rule yields (ui §7.2). The server and the single-player host run
the check before creating a world; the client runs it at start-up and at each resource reload (22 §8.2).

**When the status is re-evaluated.** "Available" is not a process-wide fact but the result of the latest check. The client
re-runs the check on: start-up, each resource reload, each time the world list screen is shown, and each time the Create
screen is opened. The Create screen shows the result it got when it opened. Pressing Create runs the check once more on the
server or host side; if the result differs from the one the screen showed, the second result applies, by the state of the button:

| Button state | Second result | Outcome |
|---|---|---|
| auto | `ok` | `standard` (even if the screen showed cobolcraft: the rule of this section is applied to the result at creation) |
| auto | not `ok` | `cobolcraft`, with the visible fallback notice (the text of `cobolcraft.world_type.auto_fallback`, shown on the world list row and on the next screen) |
| explicit `standard` | not `ok` | No world made; Decision WT-3 (missing-data screen) |
| explicit `standard` | `ok` | `standard` (also when the first check was not `ok` and this one is) |
| dedicated server configured `standard` | not `ok` | No world made; exit code 10 (Decision WT-3) |
| explicit `cobolcraft` | any | `cobolcraft` |

The dedicated server has no screen: its `auto` is evaluated once, at creation (Decision WT-2), and a configured `standard` is the
*explicit standard* row. **Ownership.** This section owns the outcomes (which type, whether a world is made); ui §7.2, §8.3
(Decisions UI-15, UI-25) own what the screens show. If the two ever differ, this section decides the outcome and ui is to be edited.

The check reads nothing but `manifest.txt` and the sentinels (22 §8.2), so running it at every point of this list costs a few file stats. The server and the host check before each world creation and each world open, cobolcraft worlds included (for the banner and the console line). Both 22 §8.2 (start-up and reload only) and
ui §8.1 (its own list of points) must be reconciled with this list (section 9).

### 3.3 Explicit choice and no silent fallback

**Decision WT-3 (an explicit choice is never changed silently).** If the player or the configuration names `standard` and the
check is not `ok`, no world is created. The single-player game opens the missing-data screen (ui §8.3, Decision UI-16) which
offers `Use CobolCraft World Type`; the dedicated server prints the message of 22 §9.2 and exits with code 10 (22
§8.6; the tool's own codes 1 to 6 in 22 §7.4 stay the tool's; 10 is the server's refusal code for a world that cannot be created or
opened, distinct from status 1 of a configuration error in the contract; a design choice that adds a status to the contract, section 9). Only
the `auto` choice (server configuration `auto`, or the untouched button of section 3.2) falls back, and it falls back by the rule of section 3.2, visibly: the Create screen shows the
type it chose. Reason: a world that silently became the other type would hold other chunks, other ids and another
dimension set than the owner asked for, and could not be converted (Decision WT-4). An explicit `standard` with a not-`ok` check on a button that was touched, or on a server configured `standard`, is the same case.

### 3.4 No conversion

**Decision WT-4 (a world's type cannot change).** There is no command, setting or screen that converts a world between
types, and the world folder is not edited to try. Reason: the saved data holds keys (section 7.5), and the keys of one type do not exist in the registries of the other, so every
chunk palette entry and entity of a converted world would name content that has no counterpart. (The differing numeric
ids of 04 §5 and 46 are a wire matter and are not the reason.) A conversion would be a translation table for content that has none. The world list shows the type (ui §7.3) so the owner knows which is which.

### 3.5 Worked examples

| # | Situation | Result |
|---|---|---|
| E1 | First start of a dedicated server, no config file, check `ok` | Config written with `world-type=auto`; world created `standard`; `level.dat` has `WorldType = standard`, `ContentJar = <manifest sha256>` |
| E2 | Same, check `absent` | Config written with `world-type=auto`; world created `cobolcraft` |
| E3 | Later the operator runs the tool. The server restarts with the existing cobolcraft world | The world stays `cobolcraft` (level.dat wins). A new, separately named world folder would be `standard` |
| E4 | Config says `world-type=standard`, check `stale`, no world folder | Server prints the `cobolcraft.packs.stale` text and the tool command line, exits with code 10. No folder is created |
| E5 | Config says `world-type=cobolcraft`, check `ok`, no folder | Cobolcraft world. The generated packs are present but the cobolcraft world does not read the generated data pack (22 §8.3) |
| E6 | Single-player, Create New World, check `ok`, the player presses Create without touching the type button (state *auto*) | Standard world |
| E6a | Single-player, the screen opened with check `ok`, the type button untouched, and the check is `damaged` when Create is pressed | Cobolcraft world, with the visible fallback notice (section 3.2) |
| E7 | Single-player, check `damaged`, the player cycles to Standard and presses Create | No world made. The missing-data screen opens with `Use CobolCraft World Type` |
| E8 | An existing world has `WorldType = standard`, the check is `damaged` | The world list row shows the short reason in the second line; Play opens the missing-data screen; the world is not opened and not altered |

**Exact texts.** Console lines are English; language keys are proposals (inferred); ui §7.4/§9 already places `auto_fallback`, `unknown`, `missing`, `no_level` and `no_seed` in the built-in pack, plus `unknown.short` ("Unknown world type '%s'", the world list second line; a ui addition not defined here). The texts below stay the source for the console lines. The client-visible texts are: `cobolcraft.world_type.unknown` "This world was made by a newer version of the game (world type '<value>').", `cobolcraft.world_type.missing`, `cobolcraft.world_type.no_level` and `cobolcraft.world_type.no_seed` as in the rows below, and the fallback notice `cobolcraft.world_type.auto_fallback`.

| Case | Key | Text |
|---|---|---|
| `auto`, check not `ok`, no world | `cobolcraft.world_type.auto_fallback` | `world-type=auto: Minecraft content is not usable (<result>), created a cobolcraft world` where `<result>` is `absent`, `incomplete`, `stale` or `damaged` |
| Existing cobolcraft world, check not `ok` | the 22 §9.2 key of the result (`cobolcraft.packs.<result>`); no new key | Server console: `Standard worlds are unavailable: ` followed by that text (the prefix is console-only, not a language key). Client: the title banner of 22 §9.2 already shows it, nothing more. The key `cobolcraft.world_type.standard.unavailable` keeps the one text of 22 §9.2; it is not drawn by any ui screen (the ui screens use the `short` keys, ui §7.4 and its Open question 25), so this document makes no claim about its use. The console prefix `Standard worlds are unavailable:` is a proposed wording, not a rule, until Open question 1 is settled |
| Existing standard world cannot open (check not `ok`) | the 22 §9.2 key of the result | Server: that text, then the tool command line, exit code 10. Host: the missing-data screen (ui §8.3) with that text |
| `WorldType` unknown | `cobolcraft.world_type.unknown` | see section 2.1 rule 4; exit code 10 |
| `WorldType` absent, standard dimension folders | `cobolcraft.world_type.missing` | see section 2.1 rule 3; exit code 10 |
| `level.dat` absent, `dimensions/` present | `cobolcraft.world_type.no_level` | "This folder holds world data but no level.dat."; exit code 10 |
| Standard `Seed` absent | `cobolcraft.world_type.no_seed` | "This world has no seed and cannot be opened."; exit code 10 |
| `world-type` ignored | `cobolcraft.world_type.config_ignored` | `world-type=standard is ignored: this world is cobolcraft` (and the same with the two types swapped) |
| Invalid `world-type` | `cobolcraft.world_type.config_invalid` | `FATAL configuration: world-type: must be auto, standard or cobolcraft (got '<value>')`, exit status 1 (the contract's form) |

---

## 4. What the type selects

For each area, the standard world type's source, the cobolcraft world type's source and where the rule is written.

| Area | Standard | Cobolcraft | Notes |
|---|---|---|---|
| Static registries of content: blocks, block states, items, entity types (the fluid registry is not among them: see the next row) | The vanilla numbering of 04 §5, 46, 24; ids match a vanilla client (README R8, C1) | Its own numbering: standin §1.2 (18 states), §2, §3, with Decision WT-12 appended; a vanilla client cannot play it | Chunk palettes use the registry in force (06 §5). The global palette width follows from the state count: 5 bits for 18 or 19 states. The figures 12/18/18/9 apply instead of the 13/19/19/10 of Decision WT-12 if the operator rejects the bench (Open question 16); every figure here that includes the bench is conditional on that |
| Other static registries (fluids, mob effects, attributes, menu types, data component types, particle types, game events and the rest) | The vanilla numbering of 04 §5 | The same vanilla keys and numbering as the standard type (Decision WT-9): protocol vocabulary that shared engines and commands name. The fluid registry is **not empty** in the cobolcraft type: it holds the vanilla keys, so 04 §5 numbering is unchanged, but no cobolcraft block state maps to a fluid and the cobolcraft generator places none | standin defines no numbering for these; none is invented |
| Block registry | Document 24 | standin §1.1 | |
| Item registry and default components | 17 §1, §2 and the item research documents | standin §2, re-expressed as components (README S21) | |
| Entity types and mobs | 21 §2 (161 types), 18 to 21 | standin §3, §12: operator, loose_item, sodgrazer, abend | The framework, spawning engine, damage and loot engines are shared |
| Recipes | The generated data pack (13 §3 for the engine) | standin §13, plus the bench recipe of Decision WT-12 | Both are interpreted by the same recipe engine |
| Loot | Generated data pack and the loot engines | standin §1.3, §12.5 | |
| Tags | Generated data pack | Hand-authored: the standard tags the shared rules read, with cobolcraft entries added (Decision WT-11) | |
| Synchronized registries (Registry Data, Update Tags) | Every registry the loaded data pack defines, order of 04 §3 | The set of 09 §3.1 as re-scoped, plus the standard core (README C3) | |
| Dimensions | `minecraft:overworld`, `minecraft:the_nether`, `minecraft:the_end`; overworld Y -64 to 319 | `cobolcraft:main`, `cobolcraft:subroutine`; Y 0 to 255 (standin §4.6, §5, §15) | Travel: portals (standard); `cobolcraft:goto_pad` (cobolcraft) |
| Biomes and world generation | 10, 11 and the later worldgen documents | standin §5.2, §15.2 | |
| Starting state | Empty inventory (README decision 6) | The starting inventory of standin §2 (README S23) and spec US4 to US8; the generator is standin §5.2 | |
| Textures, models, fonts, language | Generated resource pack, then Faithful or other user packs | The built-in `cobolcraft` pack (08 §10, the UI art of ui) | Packs are stacked for both types by README C7 |
| Names in commands | `minecraft:` keys | `cobolcraft:` keys for the type's own content (section 6.3) | |
| Extra-dimension setting `extra-dimensions` (FR-009) | Applies to Nether and End | Applies to `cobolcraft:subroutine` | README decision 16 |
| Hand-authored core | Not needed: all rows come from the pack | README C3: standard `damage_type`, `chat_type`, `world_clock`, `timeline`, `enchantment`, `block_transformer`, tags | The cobolcraft type is the only one that needs it |

---

## 5. What is shared

Both world types use these unchanged. A document that states one of them must not carry a per-type value.

| Shared | Rule from |
|---|---|
| Protocol 777 framing, packets, wire types, transport, handshake, offline login | 00 to 03, 05a to 05c, 09 |
| Health 20, food 20, saturation and exhaustion, the 10-tick hurt window, fall damage, regeneration, starvation, armor, knockback | 17 §1.5, §4; 13 §1 |
| Day of 24000 ticks, the standard timeline, `time` command and `advance_time` rule | 12 §3.2; 16 §4.5 |
| Weather as the server-level mechanism with clear, rain and thunder (in the cobolcraft type `drizzle` and `hailstorm` are skins, README decision 5) | 12 §3.5; 16 §4.10 |
| Movement, flight rules, block-break progress, crafting grids (46-slot inventory menu, bench), recipe book, off-hand, F3, F5, options, the pack screen | 13, 12 §5 |
| Combat, tools and weapons rules, enchantment engine | 17 |
| The mob framework: attributes, goals, Brain, pathfinding, spawning engine, loot rolling, breeding, taming | 18 |
| Ground item rules: lifetime 6000, pickup delay 10, merge | 18 §6.11 |
| Commands: the whole standard set, grammar, permission levels 0 to 4, selectors, argument parsers, suggestions, chat types | 15, 15a, 16 |
| Player chat: Player Chat and Disguised Chat with standard chat types | README decision 7 |
| Operator status and bans: levels 0 to 4 in `access.dat` | README decision 8 |
| World folder format, region files, `level.dat` and `players/` schemas (except the content of keys). Whatever layout 07 §9 settles on is the same for both types (Decision WT-21) | 07 §9 (README Part 7, decision 9: CobolCraft schemas), amended by design edit P07-3 and README T15 |
| Lighting, sky, fog, clouds | 12; CC-0007 |
| Pack format, pack stacking, server-pushed packs, the zip reader | 08, 22 §8 |
| Rendering engine, atlas sampling, GUI layout rules | 12, 14 |

**Decision WT-21 (save layout is not decided here; outside the world-type mechanism).** This document adds three keys to
`level.dat` (section 2.1) and nothing else to the save format. It does **not** adopt the 33 §10 layout, does not change `Time`,
does not move clocks or weather out of `level.dat`, and adds no migration. README Part 7, decision 9 says to keep the CobolCraft
schemas of 07 §9. The only rule stated is that a per-type save schema would hide a difference (Decision WT-8), so whatever
07 §9 holds applies to both types. Where the three keys sit if 07 and 33 adopt the 26.3 layout (33 §10 puts the seed in
`world_gen_settings.dat` and the game time in a `Data` compound of `level.dat`) is for their owners: Open question 12. Likewise
the `players/` inventory (07 §9.2 covers slots 0 to 35, README C5 makes it 46 slots) is a matter of 07, noted in Open question 12.

**Decision WT-8 (no per-type gameplay rule).** If a rule needs to differ between the two types, it is not shared and must be
named in section 4, not hidden inside an engine. Today section 4 lists none. Reason: CC-0001 "Own world type" says the
standard gameplay rules apply to both.

---

## 6. The namespace rule

### 6.1 The rule

> Anything with a vanilla equivalent uses `minecraft:`. `cobolcraft:` is only for the places where CobolCraft extends or
> diverges from Minecraft.

This is CC-0001 Decisions "Namespace", README R1 and 08 §1.6. This document makes it testable in this form: **the rule governs
the standard type and the shared vocabulary** (everything of section 6.2 rows 1, 2, 4 and 7). Content of the cobolcraft type
that resembles vanilla content (`cobolcraft:greystone` and the others of Decision WT-10, `cobolcraft:operator`,
`cobolcraft:loose_item`) stays `cobolcraft:`, because it is a divergence by CC-0001 "Own world type", not a vanilla
equivalent under another name. 08 §1.6 is to say this (section 9).

**Decision WT-25 (reading of the namespace rule, adopted default).** CC-0001 words the rule as "`minecraft:` for anything with a
vanilla equivalent". This document reads it with CC-0001 "Own world type" (the cobolcraft content stays unchanged) as in the
paragraph above, and so narrows the ticket's wording to the standard type and the shared vocabulary. That is a reading, not an
operator ruling: it is listed for README Part 7 and for operator confirmation (Open question 17). Reason: renaming the
invented content would change it, which the ticket forbids.

### 6.2 Where each namespace is used

| Thing | Namespace | Reason |
|---|---|---|
| Standard world type, everything: registry keys, block, item and entity keys, texture and model paths, language keys, tags, dimension keys, recipes, loot | `minecraft:` | The content is Minecraft's |
| Registry slot names (`minecraft:dimension_type`, `minecraft:worldgen/biome` and the rest), engine names (08 `[engine name]`), codec constants | `minecraft:` in both types | Protocol vocabulary, not content (standin §0) |
| Cobolcraft world type: its blocks, items, entity types, dimensions, recipes, and biomes of its own (`cobolcraft:upland` and `cobolcraft:ash_flats`) | `cobolcraft:` | Original content, a divergence. The exception is `minecraft:plains`, kept as a compat biome (README S02, 04 §3.2 item 6, standin §4) because clients look it up |
| Cobolcraft world type: the entries the shared rules need by name (damage types, chat types, `world_clock`, `timeline`, `enchantment`, `block_transformer`, the shared tags) | `minecraft:` | They have vanilla equivalents and the shared engines look them up by name (README C3) |
| Tag entries: a cobolcraft block in a shared tag | The tag keeps its `minecraft:` key; the entry value is the `cobolcraft:` key | For example `minecraft:mineable/pickaxe` lists `cobolcraft:greystone` (Decision WT-11) |
| CobolCraft-only language keys and screens (`cobolcraft.packs.*`, `cobolcraft.world_type.*`, the three keys of README S72) | `cobolcraft.` prefix (language keys are dotted, not namespaced identifiers) | CobolCraft extension, never collides with the vanilla keys |
| `cobolcraft:` content in the standard type | None. The standard world type holds no `cobolcraft:` entry (for example `cobolcraft:hail` of README decision 5 exists in the cobolcraft type only) | Decision WT-9 |
| Other static registries (mob effects, attributes, menu types, data component types, particle types, game events) in the cobolcraft type | `minecraft:`, vanilla numbering | Protocol vocabulary; Decision WT-9 |
| The built-in pack's id and the generated pack's id | `cobolcraft` and `vanilla` (pack ids, not identifiers) | 22 §8.1 |

**Decision WT-9 (the standard type holds no `cobolcraft:` content, and the cobolcraft type holds no `minecraft:` blocks, items
or entity types).** The static content registries (blocks, block states, items, entity types) of the standard type contain only
`minecraft:` entries, and those of the cobolcraft type contain only `cobolcraft:` entries, with no `minecraft:air`: the empty
state of the cobolcraft type is `cobolcraft:void` (standin §1.1). The rule is **restricted to those four registries**. The
other static registries (fluids, mob effects, attributes, menu types, data component types, particle types, game events and the
rest) are protocol vocabulary that the shared engines and commands name (`/effect give minecraft:speed`, attributes in 17
and 18, menu types in 13), so both types hold the same `minecraft:` keys with the vanilla numbering of 04 §5 and README C1.
Synchronized registries of the cobolcraft type keep their `minecraft:` keys as in README C3 (section 6.2); how complete the
hand-authored set is remains Open question 7. Reason: a content key that exists in both types would suggest equal meaning and
equal id, and separate content key spaces make a wrong-type reference an error at load time instead of a silent
substitution; vocabulary has no such risk.

**Decision WT-22 (shared engines resolve roles, not names).** Shared engines need a few pieces of content that have different
keys per type. They do not look up `minecraft:air`, `minecraft:player` or `minecraft:item` by name; the world context holds a
small role table, built with the registries (four roles; the fourth comes from cobolcraft-standard-core.md Decision CORE-25; fluids are not a role, they need no lookup because both types hold the vanilla fluid keys, Decision WT-9):

| Role | Standard | Cobolcraft |
|---|---|---|
| Empty block state | `minecraft:air` | `cobolcraft:void` (standin §1.1) |
| The player entity | `minecraft:player` (id 159, inferred: 21 §2, README row 3, 19 Open question 31; see 46) | `cobolcraft:operator` (id 0) (README S24) |
| The item entity | `minecraft:item` (id 72, inferred, same source) | `cobolcraft:loose_item` (id 1) (README S24) |
| The crafting block | `minecraft:crafting_table` | `cobolcraft:crafting_bench` (Decision CORE-25: the shared menu engine tests the role, so the menu stays valid only while the block at its position is the crafting block, 13 §3.5) |

07 §9.3 stores the item entity under its role key, so for the cobolcraft type the stored entity id is `cobolcraft:loose_item`
and for the standard type `minecraft:item` (section 9). Reason: this is the one way a shared engine reaches type-specific
content without a per-type branch. Roles beyond these four (a bedrock-like floor block, entity type tags such as the
undead tag) are Open question 13. A shared engine that needs the floor block today cannot find `cobolcraft:baseplate`; the owner of that role is the owner of this document together with cobolcraft-standard-core.md, and no engine may name the floor block until a role is added.

**Decision WT-10 (the vanilla-equivalent test applies to the standard core, not to cobolcraft content).** The cobolcraft
blocks `greystone`, `loam`, `turf`, `grit`, `lucite` and `slag` resemble stone, dirt, grass, sand, glass and netherrack, and
the entity types `operator` and `loose_item` have the player and the item entity as equivalents, but
they stay `cobolcraft:` (CC-0001 "Own world type": the invented content stays, unchanged). They are a divergence, not an
alias. Reason: renaming them `minecraft:stone` and the like would put two incompatible registries under one key space and
break Decision WT-9, and would give a vanilla client a wrong picture of ids it cannot read.

**Decision WT-11 (the core is `minecraft:`, its cobolcraft members are listed by `cobolcraft:` value).** The hand-authored
core of the cobolcraft type uses the standard keys and, where a tag lists content, adds `cobolcraft:` values. Break time of
cobolcraft blocks uses the shared formula through tags and component values (README decision 4). Reason: shared engines read
`minecraft:mineable/*` by name; they have no other way to find the cobolcraft blocks.

### 6.3 Commands and identifiers

Identifier parsing is shared: a bare name without a colon means `minecraft:` (15). Consequences:

| Input | Standard world | Cobolcraft world |
|---|---|---|
| `/give @s stone` | Gives `minecraft:stone` | Error: unknown item `minecraft:stone` |
| `/give @s cobolcraft:greystone` | Error: unknown item | Gives `cobolcraft:greystone` |
| `/tp @s ~ ~ ~` in the `minecraft:overworld` | Works | n/a (the dimension is `cobolcraft:main`) |
| `/execute in cobolcraft:subroutine run ...` | Error: unknown dimension | Works |
| `/gamerule`, `/time`, `/weather`, `/effect give @s minecraft:speed` | Work. `speed` exists in the standard effect registry | Work. `speed` exists because mob effects are vocabulary held by both types (Decision WT-9); the set of cobolcraft entries for the synchronized registries is Open question 7 |

**Decision WT-13 (no namespace fallback in the parsers).** Command parsers do not try the other namespace when a name is
unknown. Reason: the shared parsers are specified once (15); a fallback would let a command mean different things per type
and would make the error text differ from vanilla's.

### 6.4 Faithful and other `minecraft:` packs

A user pack written for `minecraft:` replaces the generated pack's textures by path. It has no effect on `cobolcraft:`
content unless the optional skin pack is on (README Part 3.5 and decision 10): an extra built-in pack, off by default,
that supplies `cobolcraft:` paths for blocks and items. **Its place in the stack is outside this document** (it is not one of the
two built-in packs of 22 §8.1 and is absent from section 7.3); Open question 14. The skin is not part of the world type; it is a user pack choice
that exists only so that the Faithful pack is useful to the cobolcraft type.

---

## 7. Keeping the two types apart

### 7.1 One value, read once

**Decision WT-14 (the world type is a value in the world's context, never a global).** Server and client each hold the
world type in the context of the world or connection. The registry loader, the chunk codec, the block, item and entity
lookups, the command tree builder, the recipe set and the pack stack builder receive it from the context. Loading a world
builds new registry instances; leaving a world discards them. No table is shared between two worlds. Reason: a process may
leave a cobolcraft world and open a standard one (the single-player client does), and stale ids would otherwise survive.

### 7.2 Registries

| Registry kind | Standard | Cobolcraft |
|---|---|---|
| Static (never sent) | Built from code by the vanilla numbering | Built from standin §1, §2, §3 with its own numbering |
| Synchronized (Registry Data, Update Tags) | Built by the registry loader from `vanilla-data` (04 §3) | Built from the hand-authored core and the stand-in tables, no file is read |
| Tags | Loaded from the data pack | Hand-authored, same loader interface so the engines read both the same way |

The loader interface is the same for both types: it returns the registries and tags of the context. The only difference is the source.

**Dependency.** The registry rows, tags, damage types, chat types, clock and timelines of the cobolcraft type are now listed in
[cobolcraft-standard-core.md](cobolcraft-standard-core.md) (cited as "CORE-n"), which closes GAP-35 (Open question 7). Still open:
09 §3.1 today sends Update Tags with zero registries and 18 Registry Data packets with 52 entries (standard-core line on 52
entries notes the stand-in sent the same), and 04 §3.2 makes several variant registries mandatory and non-empty; 09 §3.1 must be
edited to carry the standard-core set (section 9) before the cobolcraft type can be shown to satisfy the 04 §3.2 validators.

### 7.3 Packs

Resource packs (client), from bottom to top, as in 22 §8.1 and README C7:

| Level | Pack | Standard world | Cobolcraft world |
|---|---|---|---|
| 1 | `cobolcraft` built-in | Present, fixed. Supplies the UI fallbacks, the CobolCraft language keys and the font fallback; has no content the standard world uses except when the vanilla pack is missing | Present, fixed. Supplies everything |
| 2 | `vanilla` generated | Present when valid. Required for a standard world | Present when valid, because it is on whenever valid (22 §8.1). Supplies `minecraft:` UI sprites and language. On any path both packs hold, the generated pack wins (Decision WT-18, 22 §8.1) |
| 3 | User packs (Faithful) | As enabled | As enabled. Affects only `minecraft:` paths |
| 4 | Server-pushed | As sent | As sent |

Data packs (server and single-player host), per 22 §8.3: a standard world loads `vanilla-data` as level 1; a cobolcraft
world loads **no** data pack, even if `vanilla-data` exists. Feature packs are not loaded in this version (22 Open question 5).

**Decision WT-15 (the stack of section 7.3 is the same in both types; the isolation is by namespace).** The client does not build a
different pack stack for a cobolcraft world when the generated pack is valid. Reason: the two key spaces are disjoint
(Decision WT-9), the only shared paths are engine vocabulary (22 §9.1), and one stack means one reload path to test. The
exception is the language: because the generated `en_us` replaces built-in keys of the same name (22 Open question 3),
CobolCraft's own texts use the `cobolcraft.` prefix (section 6.2) so that no vanilla key can replace them. Standard keys the
cobolcraft world uses (for example the death keys) are supplied by the generated pack when it is present and by the built-in
fallback set otherwise, in the standard wording (README P08-12).

### 7.4 How a client knows the type of a server

The wire has no world type field. **Decision WT-16 (the client reads the type from the `minecraft:dimension_type` registry).**
The `minecraft:dimension_type` registry holds, in the cobolcraft type, the entries `cobolcraft:surface` (id 0) and
`cobolcraft:sunless` (id 1) (standin §4.6, §5.1; 09 §3.2), and in the standard type `minecraft:overworld` and the other
vanilla entries. The keys `cobolcraft:main` and `cobolcraft:subroutine` are dimension (level) keys, not dimension types; they
appear only in the Login packet's dimension names list in the play phase. The rule: if the Registry Data packet of
`minecraft:dimension_type` holds an entry keyed `cobolcraft:surface`, the connection is `cobolcraft`; otherwise it is
`standard`. A vanilla server is therefore `standard`. A server that sends `cobolcraft:surface` is `cobolcraft` by definition, even if it also sends vanilla entries.

**Ordering.** The rule is evaluated at Finish Configuration, not on arrival of a packet. 04 §3.1 says the client does not
depend on the order of Registry Data packets, processes nothing until Finish Configuration, and appends the entry lists when one
registry arrives split over several packets. So the rule reads: the connection is `cobolcraft` if **any** entry keyed
`cobolcraft:surface` is present across **all** packets of `minecraft:dimension_type` received before Finish Configuration;
otherwise `standard`. The client keeps no key lists for the decision beyond what 04 §3.1 already has it collect. For orientation
only: in the vanilla order of 04 §3 `dimension_type` is index 18 of 32, followed by 13 more registries; in 09 §3.1 it is the 16th
of 18 packets (id 0x07), followed by `damage_type` and `world_clock`. Update Tags (0x0E in 09) comes after the Registry Data
packets, and static ids first appear in Update Tags and in the play phase, both after Finish Configuration has been reached
for the registries, so the decision is made before any static id is used. The alternative of reading the Login dimension names
is rejected because it is later.

**Single-player.** The host runs in the same process, so the client reads the type from `level.dat` and applies the same rule on
the loopback connection as a cross-check. If the cross-check disagrees, the client disconnects, does not enter the world,
shows an error screen with the text "The world type of this game could not be confirmed." and returns to the world list; the
world is not altered. (It indicates a defect; the rule only guards against it.)

### 7.5 Persistence of ids

Chunks and entities store keys, not numeric ids (07 §7.3 palette entries, 07 §9.3 entity storage), so saved data does not
depend on a registry's numbering. This is what makes Decision WT-4 enforceable. **Decision WT-23 (foreign keys fail closed, adopted default).** A chunk whose palette
or entity list holds a key that is not in the world type's registries is **not loaded**; the server prints one console line
`chunk <x> <z> in <dimension> holds content of another world type and was not loaded` and the chunk is neither generated over
nor rewritten, so the file stays as found. A player cannot enter it (it is treated as outside the loaded area). This also holds
for one unknown entity type in an otherwise valid chunk, since rewriting the chunk would drop the entity. Reason: replacing
with air or regenerating would destroy the saved data. This only occurs through hand-copied folders, since `level.dat` decides
the type. (04 §5.2, mapping an unknown wire state id to the air default, concerns wire ids and does not apply to saved keys.)

---

## 8. When the generated packs are missing

### 8.1 Refinement of the older rule

README Part 4, C10 and Part 7, decision 2 say a missing or wrong **jar** disables the standard type. 22 §8.6 says the run-time
question is the generated directory, not the jar. This document follows 22: the jar is needed once, to generate; after
that the game depends on a valid generated directory (check `ok`). 22 Open question 2 asks the operator to confirm. **Decision WT-17 (adopted until the operator
answers).** The standard type is available if and only if the check of 22 §8.2 is `ok`.

### 8.2 Matrix

| Situation | Client | Server and single-player host |
|---|---|---|
| Check `ok` | Both types available. Default is `standard` | Both types available |
| Check `absent`, `incomplete`, `stale` or `damaged` | The cobolcraft built-in pack alone (plus user packs). Title banner shows the reason (22 §9.2). The standard type is selectable on Create and explains itself (ui §7.2). Joining servers still works | Standard worlds cannot be created or opened. Cobolcraft worlds run |
| Dedicated server configured `standard`, check not `ok`, **no existing world** | n/a | Refuses to start with the text of 22 §9.2 and the tool command line, exit code 10 (Decision WT-3). If a world exists, it is evaluated first (section 3.1): an existing cobolcraft world opens and the configuration line is printed; an existing standard world follows the last two rows |
| Dedicated server `auto`, check not `ok`, no world | n/a | Creates a cobolcraft world; prints the `cobolcraft.world_type.auto_fallback` line (section 3.5) |
| Existing standard world, check not `ok` | Not opened, not altered; row shows the reason | Server refuses to start: it prints the 22 §9.2 text followed by the tool command line and exits with code 10 (Decision WT-3, section 3.5); host refuses to open |
| Existing cobolcraft world, check not `ok` | Opens | Opens. The client shows the title banner of 22 §9.2; the server prints the `Standard worlds are unavailable:` console line (section 3.5) |
| Joining a standard server with no valid generated resource pack | Joins. `minecraft:` content with no asset is drawn with the engine's missing texture (orange and black stripes, README decision 12). The title banner shows the reason | n/a |
| Joining a cobolcraft server with no generated pack | Joins and looks complete | n/a |
| Generated packs become valid while the client is running | After a resource reload (22 §8.1), the standard type becomes available. No restart is needed for the list; an open world keeps its type | The server rechecks at the next world creation or open; the client's re-evaluation points are in section 3.2 |

**Decision WT-18 (the cobolcraft type never reads the generated data pack, and uses the generated resource pack only as
the shared stack).** Reason: the cobolcraft world must **behave** identically (game rules, ids, content) with and without generated packs; looks are not covered. The visible
difference allowed is the standard `minecraft:` UI sprites and fonts, which the built-in pack must also supply so that the
world runs with no pack (22 §9.1, README C11). Precedence of a path present in both packs: the generated pack replaces the built-in file of the same path (ui §0 and §10; 08 §3.2).

---

## 9. Changes needed in other documents

These are not made here. Each is a statement for the owner of the document.

| Document | Change |
|---|---|
| 07 §9.2 `level.dat` (T15) | Add `WorldType`, `Seed`, `ContentJar` of section 2.1, the reading rules, the Seed rules (Decision WT-19) and the folder rule of Decision WT-24. Nothing else is asked by this document; the layout questions of Decision WT-21 (33 §10 layout, `players/` slots) are Open question 12 |
| 07 §9.5 | Replace "A world folder without `level.dat` is created new, with all enabled dimensions" by the folder rule of Decision WT-24 (a folder with `dimensions/` content and no `level.dat` is not opened and not used); add exit code 10 and the world-list row treatment of section 2.1 and Decision WT-26 |
| 07 §9.1, §9.3 | Dimension folder names of the standard dimensions; entity id of the item entity by role (`minecraft:item` standard, `cobolcraft:loose_item` cobolcraft; Decision WT-22). This is the one place this change is asked: the 07 §9.2 row asks only for the keys |
| 33 §10 | Note where the keys of section 2.1 would sit under the 26.3 layout (the seed in `world_gen_settings.dat`); no migration is defined here (Decision WT-21, Open question 12) |
| standin §4.6, §5.1 | State that they describe the cobolcraft type only; cite the dimension type keys and hashed seed 0 that Decision WT-16 and section 2.1 use |
| 04 §5 | Static numbering per world type; vanilla numbering for the non-content static registries in both (Decision WT-9) |
| 22 §8.6 and Open question 2 | Reconcile with Decision WT-17 and the exit code 10 of section 3.5 (not only §9.2) |
| 22 §8.2 and ui §8.1 | Their lists of when the check runs (22 §8.2: start-up and reload; ui §8.1: its own points) to match section 3.2: also when the world list is shown, when the Create screen opens, at Create press, and before every world open |
| builtin-ui-art.md (ui) | Cross-reference only: ui §7.4/§9 already places the `world_type.*` keys of section 3.5 (and `unknown.short`); its Open question 25 asks that the `standard.unavailable` claim be dropped, which section 3.5 now does |
| 08 §1.6 | Cite this document, and restate the rule in the testable form of section 6.1 (Decision WT-25, an adopted default): it governs the standard type and the shared vocabulary; cobolcraft content that resembles vanilla stays `cobolcraft:` |
| 22 §9.2 | Reconcile: the standard choice stays selectable (Open question 1) |
| 09 §3.1 (T11) | Registry set per type as in section 7.2; the type detection of Decision WT-16; today still 18 packets and 52 entries: it must carry the standard-core set (cobolcraft-standard-core.md) |
| 13 §3.5 and the menu engine | The crafting block is a role (Decision WT-22, CORE-25): the engine tests the role, not `minecraft:crafting_table` |
| spec FR-009, `contracts/operator-surface.md` | Add `world-type` (values `auto`, `standard`, `cobolcraft`, default `auto`) and `level-seed`; the file-absent write rule; the invalid value (`FATAL configuration`, status 1) and missing key rules of Decision WT-20 are already the contract's forms. **Contract change:** a new exit status 10 for a world that cannot be created or opened (Decision WT-3, section 2.1) |
| ui §7.1 | The key `WorldType` and values are final; remove "working names" |
| README Part 4, C10; Part 7, decision 2 | Replace "jar" with "valid generated directory" (Decision WT-17), and mark it adopted until the operator answers |
| README Part 7 | One entry per adopted default of this document, each marked as not an operator ruling: WT-12 (decision 3), WT-17 (a valid generated directory instead of the jar), WT-19 (seed input and text hash), WT-20 (configuration edge cases), WT-22 (role table, four roles), WT-23 (fail closed on foreign keys), WT-24 (a world is a folder with `level.dat`), WT-25 (reading of the namespace rule), WT-26 (reading edges and exit code 10), and the skin pack placement (decision 10). WT-21 states that whatever 07 §9 holds applies to both types and adds no change of its own (its open points are Open question 12) |
| cobolcraft-standard-core.md §5 | Already holds the values of Decision WT-12 (section 10); standin §1, §2, §13 need only point to it |

---

## 10. The one content change: Decision WT-12 and the crafting bench

(The decision is numbered WT-12 by order of writing and sits here because it is a content change, not a mechanism.)

**Decision WT-12 (one cobolcraft addition; README Part 7, decision 3, an adopted default, not an operator ruling).** The only
addition to the cobolcraft content is the `cobolcraft:crafting_bench` block and item with a recipe from the inventory grid.
Under that default the type has 13 blocks, 19 block states, 19 items and 10 recipes (the bench block has one state). The
global block palette stays 5 bits (`ceillog2(19)` is 5). Reason: the shared rule that 3x3 recipes need a bench (README R6)
applies to both types, and two recipes need the 3x3 grid: recipe 7 (seven ingredients) and recipe 5 (`sod_cake`, five ingredients), the correction of cobolcraft-standard-core.md §5.7 to README S65. Without the bench `goto_pad` and `sod_cake` would not be obtainable.

**Conflict with the operator's ticket.** CC-0001 says the cobolcraft content stays "for now unchanged"; this decision adds a block, an
item and a recipe. The ticket and spec are the operator's, so this addition needs operator confirmation (Open question 16);
until then it is only an adopted default and the counts of 12/18/18/9 remain the ticket-conformant ones.

This document holds no content rows. The values are owned by cobolcraft-standard-core.md §5 (not standin: the earlier statement
that standin must carry them is out of date): block id 12 and state 18, hardness 0.8, tag `minecraft:mineable/pickaxe`, item 18,
and recipe 9 as shaped `##/##` of 4 `ledger_tile` with category `building`. What this document fixes is the numbering rule: the bench
is **appended**, so existing ids stay stable. Checked against standin §1.1 and §1.2: blocks 0 (`void`) to 11 (`slag`) and states 0
to 17 are all in use, so block id 12 and state id 18 are free; standin §2 items hold ids 0 to 17. Block id 12 and state id 18 (states
0 to 17 unchanged), item id 18 (items 0 to 17 unchanged), recipe id 9 (recipes 0 to 8 unchanged). The counts 13/19/19/10 match
standard-core.

---

## Open questions

1. **22 §9.2 says the standard choice is disabled** while the packs are invalid; ui §7.2 keeps it selectable and explains on
   Create; this document sides with ui §7.2 and calls its own console prefix proposed. The three-way disagreement (22 §9.2, ui §7.2, this document) must be settled by the owner of 22 or the operator before the README Part 7 entry for it is written; the owner of the 22 §9.2 edit is the owner of 22.
2. **Jar versus generated directory at run time** (22 Open question 2, Decision WT-17): operator to confirm. Also whether
   the title screen may start the tool.
3. **Type detection on the wire** (Decision WT-16): inferring from the `cobolcraft:surface` entry works but is implicit. Order is not a problem: 04 §3.1 says the vanilla server sends Registry Data in the order of 04 §3, and the client does not depend on order, so detection runs at Finish Configuration. A
   brand payload value such as `cobolcraft:<type>` in the configuration phase would be explicit. Which to adopt?
4. **Opening a standard world made with another accepted jar** (`ContentJar`, Decision WT-6): no rule exists until a second
   jar row exists. A newer data pack may change worldgen of unexplored chunks.
5. **Language collision** (22 Open question 3): Decision WT-15 avoids it for CobolCraft's own keys only. Standard keys in the
   cobolcraft world whose text the generated pack replaces: accepted, since both are the standard wording.
6. **Bare names in the cobolcraft world** (section 6.3): `/give @s greystone` fails because a bare name means `minecraft:`.
   Would a default-namespace rule per world type be wanted? Decision WT-13 says no for this version.
7. **Mob effects, enchantments and similar registries in the cobolcraft type**: resolved in content by
   cobolcraft-standard-core.md (GAP-35 closed there; searched: its §5 and its section 9 edit list). What remains is the 09 §3.1
   edit (section 9) and checking that the core's set satisfies 04 §3.2.
8. **Vanilla client against a cobolcraft server**: passes configuration only (04 §5). Whether a vanilla client should be
   refused at login with a clear message instead is not decided.
9. **Moving a world folder between machines with different generated packs**: a standard world on a machine without the
   packs follows section 8.2 (not opened). No export of the needed data is offered.
10. **Single-player world opened to others**: guests join the world's type; the guest client needs a valid generated resource
    pack for a standard world, or sees the missing-texture look (section 8.2). Whether the host should warn guests is open.
11. **Seed input and text hash.** Fixed by Decision WT-19 as an adopted default (Java-style 32-bit string hash). Open: whether
    vanilla uses the same hash, so that a typed seed word gives the same world. Searched: README Part 4 and 7, ui §7, 07 §9.2, spec FR-009 wording: none names a seed input; the jar was not opened for this document.
12. **Save layout of 07 and 33** (Decision WT-21): 07 §9.2 (`Time` as time of day, per-dimension `Weather`, 36 inventory slots)
    and 33 §10 (game time, clocks, weather, game rules and border outside `level.dat`, seed in `world_gen_settings.dat`, a `Data`
    compound) disagree, and README Part 7 decision 9 says to keep the CobolCraft schemas. Whether to adopt the 26.3 layout, with a
    migration, and where `WorldType`, `Seed` and `ContentJar` then sit, belongs to the owners of 07 and 33. This document does not decide it.
13. **Other roles for shared engines**: a floor block like bedrock, entity type tags such as the undead tag, and the 26.3
    fluids. Searched: standin §1, §3, README S24, cobolcraft-standard-core.md. The core has the `baseplate` block (the bedrock
    row) and says a tag file with `cobolcraft:` values is added for a mob such as the `abend`'s `undead`; whether the floor block
    needs a role (as the crafting block now has, WT-22) is not decided.
14. **Skin pack placement**: level, id, and whether it is fixed or optional in the stack (README decision 10; 22 §8.1 knows two
    built-in packs).
15. **Crafting bench values** (Decision WT-12): resolved. cobolcraft-standard-core.md §5 holds them (section 10). Remaining: standin §1, §2, §13 should point to it.
16. **Operator confirmation of the bench** (Decision WT-12): CC-0001 says the cobolcraft content stays "for now unchanged". The
    addition of section 10 conflicts with that wording until the operator confirms it.
17. **Operator confirmation of the namespace reading** (Decision WT-25): that CC-0001's "`minecraft:` for anything with a vanilla
    equivalent" does not apply to the invented cobolcraft content (greystone, operator, loose_item and the rest), and that the
    standard type and the cobolcraft type hold none of each other's content (Decision WT-9).
