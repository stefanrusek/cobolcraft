# Block entities, part 4: jukebox, lectern, bell, campfire, enchanting table, brushable block, beehive

| Item | Value |
|---|---|
| Covers | Seven block entity types: `jukebox`, `lectern`, `bell`, `campfire` (also `soul_campfire`), `enchanting_table`, `brushable_block` (suspicious sand and gravel) and `beehive` (also `bee_nest`), each with its saved fields, update tag, tickers, event handling, client animation state and the block-side code that drives it. The `Occupant` record of the beehive, the book item components the lectern stores, and the campfire cooking recipe schema are specified here as well. |
| Does not cover | The shared block entity model (base class, chunk save and load, ticker registration, update packet plumbing): the sibling documents of 31 that exist: 31-1 section 1 onward (shared model and containers), 31-2, 31-3, 31-5, 31-6, 31-7 and 31-8 (the `31-block-entities-5-*` document exists at the time of this revision; nothing here relies on its content). Data rows (recipes, loot tables, tags, the `jukebox_song` entries, the `bees_stay_in_hive` keyframes, sprites): the extraction tool. The bee entity itself: 19 and 44 (the part-3 and part-4 documents of 44). The menu screen of the lectern (RS14). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `world.level.block.entity.{JukeboxBlockEntity, LecternBlockEntity (+$1, $2), BellBlockEntity, CampfireBlockEntity, EnchantingTableBlockEntity, BrushableBlockEntity, BeehiveBlockEntity (+$Occupant, $BeeData, $BeeReleaseStatus), BlockEntity, BlockEntityTypes, BlockEntityTypeIds}`; `world.level.block.{JukeboxBlock, LecternBlock, BellBlock, CampfireBlock, EnchantingTableBlock, BrushableBlock, BeehiveBlock}`; `world.item.{JukeboxSong, JukeboxSongPlayer, JukeboxPlayable, BrushItem}`; `world.item.component.{WrittenBookContent, WritableBookContent, BookContent, TypedEntityData (+$1), Bees}`; `world.item.crafting.{CampfireCookingRecipe, AbstractCookingRecipe}`; `world.inventory.LecternMenu`; `world.{ContainerHelper, Containers, Nameable}`; `world.ticks.ContainerSingleItem`; `server.network.Filterable`; `core.{Direction, BlockPos, Vec3i}`; `client.renderer.LevelEventHandler`; `client.renderer.blockentity.{BellRenderer, EnchantTableRenderer, LecternRenderer, CampfireRenderer, BrushableBlockRenderer}`; `client.model.object.{bell.BellModel, book.BookModel}`; `world.entity.animal.bee.Bee$BeeEnterHiveGoal`; `world.level.levelgen.feature.treedecorators.BeehiveDecorator`. Scratch notes were kept outside the repository. |

Scope decisions: standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-8). Registry-like data (recipes, loot tables, tags, `jukebox_song`, the environment attribute `bees_stay_in_hive`, sprites) is extracted by the tool and is not tabulated; this document specifies the code: fields, formulas, orderings and the engines that interpret the data.

Recalled knowledge is not evidence: every number below was read from the artifact in this round. Statements marked "(inferred)" are deductions, and anything not read is listed in the Open questions.

## Contents

1. Overview and shared facts
2. Jukebox
3. Lectern
4. Bell
5. Campfire
6. Enchanting table
7. Brushable block
8. Beehive
9. Validation section
10. Open questions

---

## 1. Overview and shared facts

### 1.1 The seven types

Ids are the `block_entity_type` registry ids of 46 section 5.4 (the id travels in Block Entity Data, 05a 0x06, and in the chunk packet's block entity list, 06). "Update tag" is what `getUpdateTag` returns and "packet" says whether `getUpdatePacket` is overridden; the base class returns **no packet** (null) and an **empty compound** as the update tag, which is the behaviour of every type below that does not say otherwise.

| Type key (id) | Class | Valid blocks (`BlockEntityTypes`) | Saved keys (section) | Update packet and tag | Ticker |
|---|---|---|---|---|---|
| `jukebox` (4) | `JukeboxBlockEntity` | `jukebox` | `RecordItem`, `ticks_since_song_started` (2.2) | none, empty tag | the block installs it only while `has_record` is true (2.5) |
| `lectern` (29) | `LecternBlockEntity` | `lectern` | `Book`, `Page` (3.2) | none, empty tag | none |
| `bell` (30) | `BellBlockEntity` | `bell` | none | none, empty tag | always, client and server (4.3) |
| `campfire` (32) | `CampfireBlockEntity` | `campfire`, `soul_campfire` | `Items`, `CookingTimes`, `CookingTotalTimes` (5.2) | block entity data packet; tag is `{Items}` only (5.6) | server: lit cooks, unlit cools; client: lit particles (5.3) |
| `enchanting_table` (13) | `EnchantingTableBlockEntity` | `enchanting_table` | `CustomName` (6.2) | none, empty tag | client only (6.3) |
| `brushable_block` (40) | `BrushableBlockEntity` | `suspicious_sand`, `suspicious_gravel` | `LootTable`, `LootTableSeed`, `item` (7.2) | block entity data packet; tag is `{hit_direction?, item?}` (7.3) | none: the block's scheduled tick (7.6) |
| `beehive` (33) | `BeehiveBlockEntity` | `bee_nest`, `beehive` | `bees`, `flower_pos` (8.3) | none, empty tag | server only (8.8) |

`OP_ONLY_CUSTOM_DATA` (a set in `BlockEntityTypes`) contains six types, `command_block`, `lectern`, `sign`, `hanging_sign`, `mob_spawner` and `trial_spawner` (read: the `BlockEntityTypes` static initialiser builds the set with a six-argument `Set.of` in that order): custom block entity data on an item placed by a player is honoured for these types only for players who may use game-master blocks. `LecternBlock.getStateForPlacement` repeats this test for its own `has_book` state (3.7).

### 1.2 The on-disk wrapper and the item stack forms

Every block entity compound in a chunk's `block_entities` list (07 section 7) carries, besides the keys of its own `saveAdditional`, the keys written by `BlockEntity`: `id` (string, the type key), `x`, `y`, `z` (ints) and, when the entity has implicit components, `components`. Details of the wrapper belong to 31-1 section 1; nothing below depends on more than that.

Item stacks are stored with `ItemStack.CODEC` (`id`, `count`, optional `components`; 45 section 8). Lists of slots are stored by `ContainerHelper.saveAllItems`: an `Items` list of `{Slot: byte, id, count, components?}` compounds, empty slots skipped; load ignores out-of-range slots (45 section 9.1). The campfire uses the three-argument save with the always-write flag true, so `Items` is present even when empty.

Positions (`flower_pos`) are `Int Array(3)` (45 part 1).

### 1.3 Signals shared with other documents

- **Block events** (the Bell uses one): Level.blockEvent(pos, block, b0, b1) is queued, then delivered to the block entity's `triggerEvent(b0, b1)` on the server and sent in Block Event (05a 0x07) to nearby clients, which call the same method. `triggerEvent` returns true when handled.
- **Level events** (jukebox 1010 and 1011, lectern 1043, brush 3008, campfire extinguish 1009): Level Event packet (05a 0x2F).
- **Table trigonometry** (read from `Mth`; the definitions of `sin` and `cos` are also stated in 21 section 6.4.2): `Mth.sin(d)` = `SIN[(long)(d * 10430.378350470453) & 65535]` and `Mth.cos(d)` = `SIN[(long)(d * 10430.378350470453 + 16384.0) & 65535]`, with `SIN` a 65536-entry float table (`SIN[k] = (float) sin(k / 10430.378350470453)`, 21 section 6.4.2, 11 section 4); the result is a float. Every `sin` below (bell animation, book animation, book pose, renderer bob) is this table lookup, not the exact function. `Mth.atan2(y, x)` (the first argument is the one called `dz` below, the second `dx`) is the game's own routine, **not** `Math.atan2`; it returns a double. It is a table-based arctangent: NaN when `x*x + y*y` is NaN; otherwise the vector is folded into the first octant (negative `y` and negative `x` are made positive, and the two are exchanged when `y > x`), normalised to unit length with an approximate inverse square root, and the angle of the folded unit vector is read from a 257-entry arcsine table indexed by `round(y * 256)` (`ASIN_TAB[k] = asin(k / 256)`, with a companion `COS_TAB[k] = cos(ASIN_TAB[k])`), plus one cubic residual correction in the small sine `e` between the true `y` and the table abscissa: the correction is `e * (6 + e*e) * 0.16666666666666666`. The folds are undone in the order swap (`PI/2 - angle`, 1.5707963267948966), negative `x` (`PI - angle`, 3.141592653589793), negative `y` (negate), so the result lies in -PI to PI. Constants read: `FRAC_BIAS` = 2^44 (the rounding trick that makes the table index the low bits of `FRAC_BIAS + y`, spacing 2^-8); the inverse square root is the classic bit-hack form with magic constant 6910469410427058090 (`0x5FE6EB50C7B537AA`) applied to the half-shifted raw bits followed by one Newton step with the factor 1.5 and half the argument. The tables are built with the exact `Math.asin` and `Math.cos` of the Java runtime at class initialisation (the last-bit value of those library calls is not specified here). An implementation using exact trigonometry differs from the game by small amounts (the `Mth.sin` table has 65536 steps of 2*PI/65536); bit-exact animation needs these definitions.
- **Direction numbering**, used by several rules below (read from the `Direction` constants): ordinal and 3D data value `DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5`; 2D data value `SOUTH 0, WEST 1, NORTH 2, EAST 3` (DOWN and UP have -1); `toYRot` = `(data2D & 3) * 90` degrees, so SOUTH 0, WEST 90, NORTH 180, EAST 270; `getClockWise` maps NORTH to EAST, EAST to SOUTH, SOUTH to WEST, WEST to NORTH.
- **Squared-distance rule `closerToCenterThan(position, d)`** (used by the bell and the bee goal): true when the squared distance from `position` to the block centre `(X + 0.5, Y + 0.5, Z + 0.5)` is strictly less than `d * d`.
- **`Containers.dropItemStack(level, x, y, z, stack)`**, used by the campfire: let `w` = width of the item entity type (0.25, 41). The three coordinates are drawn first, in the order x, y, z, each with one `nextDouble`: `px = floor(x) + nextDouble * (1 - w) + w / 2`, `py = floor(y) + nextDouble * (1 - w)`, `pz = floor(z) + nextDouble * (1 - w) + w / 2`. Then, while the stack is not empty: split off `nextInt(21) + 10` items (or the rest), build an item entity at `(px, py, pz)` with that stack, set its motion to `(triangle(0, 0.11485000171139836), triangle(0.2, 0.11485000171139836), triangle(0, 0.11485000171139836))` in the order x, y, z (`triangle(c, d) = c + d * (nextDouble - nextDouble)`, 41), and add it. No pickup-delay call is made in this helper. `Containers.dropContents(level, pos, list)` calls this for each stack with the integer position coordinates `(X, Y, Z)` (the block's lower corner).

---

## 2. Jukebox

This section adds to 25 section 5 (which specifies the inserting of a disc, the song player, the client playback and the 22 song files): it closes that document's Open question 7 (loading), names the coupling to the block, and corrects nothing in 25 section 5 except where stated. The song file schema is `JukeboxSong.DIRECT_CODEC` (`sound_event`, `description`, `length_in_seconds` positive float, `comparator_output` int 0 to 15; 04 section 6, 23).

### 2.1 State

| Field | Type | Default | Notes |
|---|---|---|---|
| `item` | item stack | empty | capacity 1 (`getMaxStackSize` = 1) |
| song player | `JukeboxSongPlayer` | `song` = none, `ticksSinceSongStarted` = 0 | constructed with the change callback `onSongChanged` and the block position; `PLAY_EVENT_INTERVAL_TICKS` = 20 |

`JukeboxSong.lengthInTicks = ceil(length_in_seconds * 20)` (float arithmetic); `hasFinished(t)` is `t >= lengthInTicks + 20` (the constant `SONG_END_PADDING_TICKS` = 20). `JukeboxSong.fromStack(stack)` is the song named by the stack's `jukebox_playable` component, or none.

### 2.2 Saved fields

| Key | NBT type | Written when | Default on read |
|---|---|---|---|
| `RecordItem` | item stack compound (1.2) | the stored item is not empty | empty stack |
| `ticks_since_song_started` | Long | the song player currently has a song | absent means no resume |

Load (`loadAdditional`), in order:
1. Read `RecordItem` into a local `loaded` (empty when absent or undecodable).
2. If the current `item` is not empty and `loaded` is not the same item with the same components (`isSameItemSameComponents`), call the song player's `stop(level, blockState)` (a no-op when no song is playing; when it does stop, 2.4 applies, including the level event 1011 and the game event; `level` may be unset during chunk load, in which case the stop path's null handling is not traced, Open question 4).
3. Set `item = loaded`.
4. If `ticks_since_song_started` is present: if the song of `item` exists, call `setSongWithoutPlaying(song, ticks)`; otherwise nothing.

`setSongWithoutPlaying(song, ticks)` returns without effect when `song.hasFinished(ticks)`; else it stores the song and the tick count and sends **no** event and **no** notification (so no neighbour update).

### 2.3 Container rules

| Rule | Value |
|---|---|
| `canPlaceItem(slot, stack)` | the stack has the `jukebox_playable` component and slot 0 of this container is empty |
| `canTakeItem(target, slot, stack)` | `target.hasAnyMatching(stack -> stack.isEmpty())`: the **destination** container has an empty slot (the predicate is the method reference `ItemStack::isEmpty`, read from the bootstrap table; this closes the part of 25 section 5.2 that marks it "not traced") |
| `getTheItem`, `splitTheItem(n)` | the item; `splitTheItem` returns the item and sets the slot empty whatever `n` is |
| `setTheItem(stack)` | store; `hasRecord = !stack.isEmpty()`; if the level is set and the block state at the position is the entity's cached state, set `has_record = hasRecord` with flags 2 and fire `block_change` (context: the block state); then, if `hasRecord` and the stack has a song, `play(level, song)`, otherwise `stop(level, state)` |
| `popOutTheItem` | as 25 section 5.2 (server only; item entity at the block's lower corner plus (0.5, 1.01, 0.5) displaced by `offsetRandomXZ(random, 0.7)`, default pickup delay 10, then `onSongChanged`). Also called by `preRemoveSideEffects` when the block is removed |
| `onSongChanged` | `updateNeighborsAt(pos, block)` then `setChanged` |
| `setRemoved` | after the base behaviour: fire game event `jukebox_stop_play` at the position (context: block state) and send level event **1011** with data 0 |
| `getComparatorOutput` | `comparator_output` of the song of the stored item, or 0 when the item has no song; it does **not** depend on whether the song is playing |
| `setSongItemWithoutPlaying(stack)`, `tryForcePlaySong()` | store the stack and, for the first, call `setSongWithoutPlaying(song, 0)`, update neighbours and `setChanged`; the second calls `play` for the stored item's song. **No caller of either exists in the artifact** (searched every class of the jar); they are API only |

### 2.4 Song player (confirms 25 section 5.3)

`play(level, song)`: set `song`, `ticks = 0`, send level event **1010** at the position with data = the song's id in the `jukebox_song` registry (`Registry.getId`), call the change callback. `stop`: nothing when no song; else `song = none`, `ticks = 0`, game event `jukebox_stop_play` (context: the block state), level event **1011** data 0, change callback. `tick`: no song, return; if `hasFinished(ticks)`, `stop` and return; if `ticks mod 20 == 0` fire game event `jukebox_play` and spawn the note particles; then `ticks = ticks + 1`. Note particles (server only): `ServerLevel.sendParticles(note, x, y, z, count 0, dx, 0, 0, speed 1)` with `(x, y, z)` = bottom centre of the block `(X + 0.5, Y, Z + 0.5)` plus (0, 1.2000000476837158, 0) and `dx = nextInt(4) / 24.0f`.

### 2.5 Block coupling (`JukeboxBlock`, rows complement 24 section 7.11)

| Rule | Value |
|---|---|
| Properties | `has_record` boolean, default false |
| Ticker | `getTicker` returns the entity's `tick` (which calls the song player) only when `has_record` is true; it is returned for the client level as well, but the client's song player never holds a song because no packet carries it, so the client tick does nothing (inferred from 1.1: no update tag, no packet) |
| `setPlacedBy` | after the base behaviour, if the item's block entity data component contains the key `RecordItem`, set `has_record` true with flags 2 |
| Use with an item | if `has_record`: try with empty hand. Else `JukeboxPlayable.tryInsertIntoJukebox` (25 section 5.1); if that does not consume the action, try with empty hand |
| Use without an item | if `has_record` and the entity is a jukebox: `popOutTheItem`, success; else pass |
| Signal | the block is a signal source; `ownSignal` is **15** while the entity's song player is playing, else 0 |
| Analog output | `hasAnalogOutputSignal` true; `getAnalogOutputSignal` is `getComparatorOutput()` (2.3) |
| After removal | `Containers.updateNeighboursAfterDestroy` |

### 2.6 Client events (confirms 25 section 5.4)

Level event 1010 looks the song up by registry index in the client's `jukebox_song` registry (nothing happens for an unknown index); level event 1011 stops the sound at the position and tells living entities within the block box inflated by 3.0 that no record plays (`setRecordPlayingNearby(pos, false)`; 1010 passes true). The notified entities are `LivingEntity` instances; `Parrot` overrides the method (19).

### 2.7 Worked example

A jukebox holds `music_disc_13` (song `13`: 178.0 s, comparator 1; 25 part 7, worked example 2). `lengthInTicks = 3560`; the song stops when `ticks` reaches 3580 inside a tick: the tick that sees `ticks = 3580` calls `stop` (level event 1011, game event, `onSongChanged`) and does not emit or increment. Events: tick offsets 0, 20, 40, ... 3560 emit `jukebox_play` (179 emissions; the one at 3580 is the stop). The note particle per emission has `dx` in {0, 1/24, 2/24, 3/24}. Comparator output while holding the disc: 1, also after the song ended. A hopper-style destination with all slots full cannot take the disc (`canTakeItem` false).

---

## 3. Lectern

### 3.1 State

| Field | Type | Default | Notes |
|---|---|---|---|
| `book` | item stack | empty | the stored book; `hasBook` (the entity method) is true when the stack has `writable_book_content` or `written_book_content` |
| `page` | int | 0 | current page index |
| `pageCount` | int | 0 | cached page count of `book` |

Constants: `DATA_PAGE` = 0, `NUM_DATA` = 1, `SLOT_BOOK` = 0, `NUM_SLOTS` = 1. The entity is a `MenuProvider` (the menu is `lectern`, menu id 17, 46 section 5.5) with display name the translatable component `container.lectern`.

`getPageCount(stack)`: the number of pages of `written_book_content` if present; else the number of pages of `writable_book_content`; else 0.

### 3.2 Saved fields

| Key | NBT type | Written when | Default on read |
|---|---|---|---|
| `Book` | item stack compound | the book is not empty | no book (empty) |
| `Page` | Int | together with `Book` | 0 (then clamped as described below; -1 for a 0-page book) |

Load: decode `Book`, then **resolve** it with no player (3.4) and store the result; `pageCount = getPageCount(book)`; `page = clamp(Page, 0, pageCount - 1)`. The integer `Mth.clamp(v, min, max)` was read: it is `min(max(v, min), max)` (the lower bound is applied first, then the upper). For a book with 0 pages the call is `clamp(Page, 0, -1)` = `min(max(Page, 0), -1)` = **-1** for every `Page` value, so a lectern holding a 0-page book keeps `page = -1` after load (`getRedstoneSignal` then uses `pageCount > 1` false, so the page value does not enter the signal). For 1 or more pages the result is the usual range 0 to `pageCount - 1`.

### 3.3 Operations

| Operation | Rule |
|---|---|
| `setBook(stack)` / `setBook(stack, player)` | `book = resolve(stack, player)` (3.4); `page = 0`; `pageCount = getPageCount(book)`; `setChanged` |
| `setPage(n)` (private; the menu's data write) | `n' = clamp(n, 0, pageCount - 1)` (= `min(max(n, 0), pageCount - 1)`, so -1 when `pageCount` is 0); if `n' != page`: `page = n'`, `setChanged`, then `LecternBlock.signalPageChange` (3.7) |
| `onBookItemRemove` | (as `setBook`, `page` is set to 0, not to the clamp result) `page = 0`, `pageCount = 0`, `LecternBlock.resetBookState(null, level, pos, state, false)` (3.7) |
| `getRedstoneSignal` | `floor( (pageCount > 1 ? page / (pageCount - 1) : 1.0) * 14 ) + (hasBook ? 1 : 0)` with float arithmetic (`page` and `pageCount - 1` converted to float) |
| `clearContent` | `setBook(empty)` (note: this runs the `setBook` path, not `onBookItemRemove`) |
| `preRemoveSideEffects(pos, state)` | if the state has `has_book` and the level is set: drop the book: `f = 0.25f`; the item entity is at `x = X + 0.5 + f * stepX(facing)`, `y = Y + 1`, `z = Z + 0.5 + f * stepZ(facing)` with the stack copy, default pickup delay (10), added to the level; `facing` is the state's `facing` |
| `createMenu` | a `LecternMenu` with the container view (3.5) and the data view (`get(0)` = `page`, `set(0, v)` = `setPage(v)`, count 1) |

### 3.4 Book content handling

Both book components are items' `BookContent` (a list of `Filterable` pages and a `withReplacedPages` operation).

**`Filterable<T>`** is a record of `raw: T` and `filtered: Optional<T>`. Reading with filtering on gives `filtered` when present else `raw`; with filtering off, `raw`. Its NBT/JSON codec accepts either the record form `{raw, filtered?}` or a bare `T` (the bare value becomes `raw` with no filtered text); it encodes in the record form (inferred from the argument order of `Codec.withAlternative`, Open question 3). Its wire form is `raw` then an optional `filtered` (inferred, Open question 2).

**`writable_book_content`** (a book and quill): `pages` list of `Filterable<String>`, default empty; each page string 0 to 1024 characters (`PAGE_EDIT_LENGTH`), at most 100 pages (`MAX_PAGES`; the record constructor throws above 100). Wire: `Filterable<String(1024)>` list bounded to 100 entries.

**`written_book_content`** (a signed book): record `{title: Filterable<String 0..32>, author: String, generation: int 0..3 (default 0), pages: list<Filterable<Component>> (default empty), resolved: boolean (default false)}`. Constants: `PAGE_LENGTH` = 32767 (a page whose flat JSON encoding is longer than 32767 characters is rejected by the codec), `TITLE_LENGTH` = 16, `TITLE_MAX_LENGTH` = 32, `MAX_GENERATION` = 3; the record constructor throws when `generation` is outside 0..3. The `EMPTY` instance has an empty title, empty author, generation 0, no pages and `resolved` true. `craftCopy` returns the same content with `generation + 1`. `withReplacedPages(pages)` returns the content with the new pages and `resolved` **false**. Wire: title as `Filterable<String(32)>`, author as a string, generation as VarInt, pages as a list of `Filterable<Component>`, `resolved` as a boolean.

**Resolution of dynamic text** (`resolveForItem(stack, context, registries)`, used by the lectern on set and on load): if the stack has `written_book_content` whose `resolved` is false, resolve each page, in order, by running the text-component resolver on the raw page and, when present, on the filtered page; a page whose resolved text no longer fits `PAGE_LENGTH` (32767 flat characters), or whose resolution throws, is handled so: a thrown error keeps the original component for that page; a too-long result makes the whole resolution fail. On success the stack's component is replaced by the content with the resolved pages and `resolved` true; on failure the stack's content is replaced by the **original** content marked `resolved` true (so a failing book is resolved only once). The method returns whether the stack changed; stacks without the component, or already resolved, are untouched. The lectern resolves on the server level only (when the level is not a server level the stack is stored as given).

The resolver context is a command source stack built by the lectern: source `CommandSource.NULL`, position the block centre, rotation `Vec2.ZERO`, the server level, permission set `LevelBasedPermissionSet.GAMEMASTER` (read: it is `create(PermissionLevel.GAMEMASTERS)`, where `PermissionLevel` is an enum of five constants in the order `ALL`, `MODERATORS`, `GAMEMASTERS`, `ADMINS`, `OWNERS`; the numeric levels behind the constants were not read, so no number is stated here), and the name/display name of the player doing the placing when there is one (otherwise the literal `Lectern`); so selectors, scores and NBT components in a book run with the `GAMEMASTER` permission set at the lectern. The component resolver itself (`ComponentUtils.resolve`: selectors, scores, NBT, translation arguments) was not read (Open question 1).

### 3.5 The container and data views (menu data)

`LecternBlockEntity$1` (the `Container` given to the menu): size 1; `isEmpty` is `book.isEmpty()`; `getItem(0)` the book (other slots empty); `getMaxStackSize` 1; `canPlaceItem` always false; `setItem` does nothing; `clearContent` does nothing; `setChanged` forwards to the entity; `stillValid(player)` is the standard block-entity range test (`Container.stillValidBlockEntity`) **and** `hasBook`. `removeItem(0, n)` splits `n` from the book and, when the book is then empty, runs `onBookItemRemove`; `removeItemNoUpdate(0)` returns the book, sets the entity's book to empty and runs `onBookItemRemove` (for any other slot both return empty).

`LecternBlockEntity$2` (the `ContainerData`): one value, index 0 is `page`; a write to index 0 calls `setPage`.

**Menu button ids** (`LecternMenu`, sent in Container Button Click, 05c 0x11, with the container id and the button id; the server calls `clickMenuButton(player, id)`, which returns true when handled):

| Id | Action |
|---|---|
| 1 `BUTTON_PREV_PAGE` | `setData(0, page - 1)` |
| 2 `BUTTON_NEXT_PAGE` | `setData(0, page + 1)` |
| 3 `BUTTON_TAKE_BOOK` | if `player.mayBuild()` is false: return false. Else `book = container.removeItemNoUpdate(0)`; `container.setChanged()`; add the book to the player's inventory; if it does not fit, drop it with `player.drop(book, false, PREDICTED)`; return true |
| 100 and above (`BUTTON_PAGE_JUMP_RANGE_START`) | `setData(0, id - 100)`; return true |
| any other | false |

`setData(index, value)` in the menu writes the container data and then `broadcastChanges()`, so the new page reaches clients in Container Set Data (05a 0x13: container id, property index 0, short value). The menu has one slot (the book, at slot 0, container-local position (0, 0, 0)) and no inventory slots of its own; `quickMoveStack` returns empty; `stillValid` forwards to the container.

### 3.6 Client side

The lectern entity sends no update packet. The client learns `has_book` from the block state; the page list reaches the client (inferred) through the menu's slot synchronisation (the book item stack with its components) and the data slot. The block entity renderer draws a book (the same model and texture as the enchanting table, 6.5) when `has_book` is true. Pose: translate `(0.5, 1.0625, 0.5)`; rotate about Y by `-yRot` degrees where `yRot = toYRot(clockWise(facing))`; rotate about Z by `67.5` degrees; translate `(0, -0.125, 0)`; the book state is the constant `BookModel.State.forAnimation(0, 0.1, 0.9, 1.2)`, that is openness `(sin(0 * 0.02) * 0.1 + 1.25) * 1.2 = 1.5` (`sin` is the table lookup of 1.3; `SIN[0]` is 0), page flips 0.1 and 0.9 (6.5 gives the model).

### 3.7 Block coupling (`LecternBlock`)

Properties: `facing` (horizontal, default NORTH), `powered` (default false), `has_book` (default false). The shapes belong to the block registry (24).

| Rule | Value |
|---|---|
| Placement | `facing` = opposite of the player's horizontal direction; `has_book` = true only when the placing player can use game-master blocks and the item's block entity data contains the key `Book` (so ordinary players never place a lectern that already has a book) |
| Use with an item | if `has_book`: try with empty hand. Else if the stack is in the item tag `lectern_books`: `tryPlaceBook`; success when placed, pass when not. Else if the stack is empty and the hand is the main hand: pass. Else try with empty hand |
| `tryPlaceBook` | when `has_book` is false: on the server `placeBook`; returns true (also on the client), else false. `placeBook`: if the entity is a lectern: `setBook(stack.consumeAndReturn(1, entity))`; `resetBookState(entity, level, pos, state, true)`; play `block.lectern.book_put` (sound event `BOOK_PUT`, blocks, volume 1, pitch 1) at the position |
| Use without an item | if `has_book`: on the server open the menu (`openMenu`) and award the custom stat `interact_with_lectern`; success. Else consume. (`getMenuProvider` returns none when `has_book` is false.) |
| `resetBookState(entity, level, pos, state, hasBook)` | set `powered` false and `has_book` to the flag, with block update; fire game event `block_change`; update the neighbour below (`updateBelow`) |
| `signalPageChange(level, pos, state)` | `changePowered(true)` (set `powered` true with block update, `updateBelow`); schedule a block tick in **2** ticks (`PAGE_CHANGE_IMPULSE_TICKS`); send level event **1043** (page turn) |
| Scheduled tick | `changePowered(false)` |
| Signal | source; `ownSignal` 15 when `powered`; `getDirectSignal` returns 15 for direction UP when `powered`, else 0; `updateBelow` updates the block below with an orientation derived from `facing` (opposite, UP) |
| Analog output | when `has_book` is true and the entity is a lectern: `getRedstoneSignal()` (3.3); otherwise 0 |
| After removal | when `powered`, `updateBelow` |
| Pathfinding | not pathfindable |

Level event 1043 on the client plays `BOOK_PAGE_TURN` (blocks, volume 1, pitch `nextFloat * 0.1 + 0.9`, no distance delay) at the position.

### 3.8 Worked examples

1. A written book with 5 pages is set (`setBook`): `page = 0`, `pageCount = 5`, signal `floor(0 / 4 * 14) + 1 = 1`. Next page twice (button 2 twice): page 2, signal `floor(0.5 * 14) + 1 = 8`; each change sets `powered` true, plans a tick in 2 ticks, which sets `powered` false. Jump to page 4 (button 104): signal `floor(1.0 * 14) + 1 = 15`. A request for page 9 (button 109) clamps to page 4.
2. A 1-page book or a book with 0 pages: `pageCount > 1` is false, so the factor is 1.0 and the signal is 15 (with `has_book`).
3. A lectern loaded with `Page: 7` and a 3-page book gets `page = 2`.
4. Button 3 by a player in adventure mode (`mayBuild` false): nothing happens, the book stays.

---

## 4. Bell

44 section 2.11a already describes the bell's tick, resonance and the villager reaction in prose; this section restates the exact tick order, adds the block side that rings it, the event wiring and the client animation, and gives the particle formula (42-7 section 9.4 has the count rule; the count definition below is exact).

### 4.1 State and constants

| Field | Type | Default | Notes |
|---|---|---|---|
| `lastRingTimestamp` | long | 0 | game time of the last entity-list refresh |
| `ticks` | int | 0 | ticks since the ring started (public; the renderer reads it) |
| `shaking` | boolean | false | |
| `clickDirection` | `Direction` | none | |
| `nearbyEntities` | list of living entities | none | cached list |
| `resonating` | boolean | false | |
| `resonationTicks` | int | 0 | |

Constants: `DURATION` 50, `GLOW_DURATION` 60, `MIN_TICKS_BETWEEN_SEARCHES` 60, `MAX_RESONATION_TICKS` 40, `TICKS_BEFORE_RESONATION` 5, `SEARCH_RADIUS` 48, `HEAR_BELL_RADIUS` 32, `HIGHLIGHT_RAIDERS_RADIUS` 48. The entity has no saved fields and no update data.

### 4.2 Ringing and the event

- **`onHit(direction)`** (server, from the block): `clickDirection = direction`; if `shaking`, `ticks = 0`, else `shaking = true`; then `level.blockEvent(pos, block, 1, direction.get3DDataValue())`.
- **`triggerEvent(type, data)`**: for `type == 1`: `updateEntities()`; `resonationTicks = 0`; `clickDirection = Direction.from3DDataValue(data)`; `ticks = 0`; `shaking = true`; return true. Any other type: the base behaviour. The event runs on the server and on every client the packet reaches.
- **`updateEntities()`**: if `gameTime <= lastRingTimestamp + 60` and a cached list exists, return (the list is reused). Otherwise: `lastRingTimestamp = gameTime`; `nearbyEntities` = every `LivingEntity` whose bounding box intersects the block's box inflated by 48 (a box gather; no distance test). On the server only, for each such entity that is alive and not removed and whose position satisfies `closerToCenterThan(position, 32)`, set the brain memory `heard_bell_time` to the current game time (44 section 2.11a, 2.11 for the villager reaction).

### 4.3 Tick (client and server)

`BellBlock.getTicker` returns the same logic for both sides, with a different end action; the entity ticks every tick whether or not it is shaking. Order inside one tick:

1. If `shaking`: `ticks = ticks + 1`.
2. If `ticks >= 50`: `shaking = false`, `ticks = 0`.
3. If `ticks >= 5` and `resonationTicks == 0` and `areRaidersNearby`: `resonating = true` and play `block.bell.resonate` (`BELL_RESONATE`, blocks, volume 1, pitch 1, no source entity) at the position.
4. If `resonating`: if `resonationTicks < 40`, `resonationTicks = resonationTicks + 1`; else run the end action on the cached list and set `resonating = false`.

`areRaidersNearby(pos, list)`: any entity in the cached list that is alive, not removed, satisfies `closerToCenterThan(position, 32)` and is in the entity type tag `raiders`. (`resonationTicks` stays 40 after the end action, so the resonance cannot restart before the next ring resets it to 0.) The cached list is set by the first event; a tick before any event cannot reach step 3 because `ticks >= 5` needs a ring.

**End action, server (`makeRaidersGlow`)**: every entity in the list that is alive, not removed, within `closerToCenterThan(position, 48)` and in the `raiders` tag gets the effect `glowing` for 60 ticks (default amplifier 0).

**End action, client (`showBellParticles`)**: with `c` = the number of entities in the cached list whose position satisfies `closerToCenterThan(position, 48)` (**every living entity, not only raiders**; the first predicate has no alive or tag test) and a counter `color` starting at 16700985 (0xFED639), for each entity in the list that is alive, not removed, within 48 and in the `raiders` tag, in list order: with `dx = e.x - X`, `dz = e.z - Z` (the entity position minus the bell's integer corner, **not** the centre) and `d = sqrt(dx*dx + dz*dz)`: `px = X + 0.5 + dx / d`, `pz = Z + 0.5 + dz / d`, `py = Y + 0.5` (the division is real-valued, so `d = 0` gives non-finite values; the case is not guarded); `n = clamp((c - 21) / -2, 3, 15)` with Java integer division (truncating toward zero); then `n` times: `color = color + 5` (shared by all raiders, so the first particle of the bell uses 16700990), spawn `entity_effect` with colour int `color` (ARGB, 42-2 section 1) at `(px, py, pz)` with velocity (0, 0, 0).

### 4.4 Client animation state and renderer

The renderer takes `ticks + partialTick` and the click direction when `shaking` (else none). The model (`BellModel`, texture 32 by 32) has a part `bell_body` (box origin (-3, -6, -3), size (6, 7, 6), texture offset (0, 0), part offset (8, 12, 8)) with a child `bell_base` (box origin (4, 4, 4), size (8, 2, 8), texture offset (0, 13), offset (-8, -12, -8)). Animation: with a shake direction, `a = Mth.sin(ticks / PI) / (4 + ticks / 3)` (table lookup, 1.3); then `xRot = -a` for NORTH, `+a` for SOUTH, and `zRot = -a` for EAST, `+a` for WEST (the switch indices are NORTH 1, SOUTH 2, EAST 3, WEST 4; other directions leave both 0); without a shake direction both rotations are 0. They are assigned to `bell_body`.

### 4.5 Block side (`BellBlock`)

Properties: `facing` (default NORTH), `attachment` (`floor`, `ceiling`, `single_wall`, `double_wall`; default floor), `powered` (default false). Placement, shapes and `updateShape` are block-registry matter (24); the ring logic:

| Rule | Value |
|---|---|
| Ring sources | use without item (`onHit` with check, player = user); a projectile hit (`onProjectileHit`: the projectile's owner if it is a player, else none; also the check); an explosion that can trigger blocks (`onExplosionHit`: `attemptToRing(level, pos, null direction)` then the base behaviour); a redstone rising edge (`neighborChanged`: when `hasNeighborSignal` differs from `powered`: if the new signal is true, `attemptToRing(level, pos, null)`; then set `powered` to the new signal) |
| `onHit(level, state, hit, player, check)` | `dir = hit.getDirection()`; `pos = hit.getBlockPos()`; when `check` is true the hit counts only if `isProperHit(state, dir, hit.location.y - pos.y)`; (both call sites pass `check = true`); when it counts: `attemptToRing(player, level, pos, dir)`; if that returned true and a player is known, award the custom stat `bell_ring`; the method returns true when the hit counted (use then returns success, else pass) |
| `isProperHit(state, dir, relY)` | false when `dir`'s axis is Y or `relY > 0.8123999834060669`; else by attachment: `floor`: true when `dir`'s axis equals `facing`'s axis; `single_wall` and `double_wall`: true when the axes differ; `ceiling`: true |
| `attemptToRing(entity, level, pos, dir)` | on the server and if the entity is a bell: if `dir` is none use the state's `facing`; call `onHit(dir)` (4.2); play `block.bell.use` (sound event `BELL_BLOCK`, blocks, **volume 2.0**, pitch 1.0, no source entity) at the position; fire game event `block_change` with the ringing entity as source; return true. On the client or without an entity: false |

### 4.6 Worked example

A bell is struck at game time 1000 with 30 living entities in the 48-block box, 25 of them within 48 of the centre, 3 raiders within 32. Number the entity ticks after the event 1, 2, 3, ...: tick n sets `ticks = n` (step 1). At tick 5 step 3 starts the resonance (raider nearby, `resonationTicks` is 0, resonate sound) and step 4 raises `resonationTicks` to 1 in the same tick; ticks 6 to 44 raise it to 2 to 40; at tick 45 `resonationTicks` is already 40, so the end action runs and `resonating` becomes false (forty ticks after the start tick; 44 section 2.11a words this "41 ticks after it starts", which counts the tick of the start as the first). At tick 50 `ticks` reaches 50 and the shake stops (`ticks` reset to 0); `resonationTicks` stays 40, so no second resonance until the next ring. Client particles: `c = 25`, `n = clamp((25 - 21) / -2, 3, 15) = clamp(-2, 3, 15) = 3` per raider; the colours of the 9 particles of 3 raiders are 16700990, 16700995, ... 16701030. With `c = 1`: `n = 10`; `c = 2`: 9; `c = 17` or more: 3.

---

## 5. Campfire

### 5.1 State

| Field | Type | Default | Notes |
|---|---|---|---|
| `items` | 4 item stacks | all empty | the four grill slots (`NUM_SLOTS` = 4) |
| `cookingProgress` | int[4] | 0 | ticks cooked (saved as `CookingTimes`) |
| `cookingTime` | int[4] | 0 | ticks needed (saved as `CookingTotalTimes`) |

`BURN_COOL_SPEED` = 2. The item slots are numbered 0 to 3.

### 5.2 Saved fields

| Key | NBT type | Written | Read |
|---|---|---|---|
| `Items` | List of `{Slot, id, count, components?}` (1.2) | always (written even when empty) | all four slots are reset to empty, then every element with `0 <= Slot < 4` is loaded |
| `CookingTimes` | Int Array | always (the four `cookingProgress` values) | if present, copied into `cookingProgress` for `min(length, 4)` entries (a shorter array leaves the rest as they were); if absent, `cookingProgress` is filled with 0 |
| `CookingTotalTimes` | Int Array | always (the four `cookingTime` values) | as above into `cookingTime`; absent fills 0 |

Item components: the entity's implicit component is `container` (the four stacks), applied from and collected into an item stack's `container` component; `removeComponentsFromTag` discards the key `Items`.

### 5.3 Tickers (`CampfireBlock.getTicker`)

| Side | State `lit` | Ticker |
|---|---|---|
| server | true | `cookTick(serverLevel, pos, state, entity, recipeCheck)` with a recipe check created for the recipe type `campfire_cooking` |
| server | false | `cooldownTick` |
| client | true | `particleTick` |
| client | false | none |

**`cookTick`**: `changed = false`; for each slot `i` in order 0 to 3: skip empty stacks; otherwise `changed = true`; `cookingProgress[i] += 1`; if `cookingProgress[i] >= cookingTime[i]`:
1. Build a single-item recipe input from the stack; look up the `campfire_cooking` recipe for it with the cached check (`RecipeManager.CachedCheck.getRecipeFor`; the cache only remembers the last recipe, Open question 6).
2. `result` = the recipe's assembled result stack when a recipe exists, **else the input stack itself** (an item with no recipe is returned unchanged).
3. If `result` is enabled by the level's feature flags: drop it with `Containers.dropItemStack(level, X, Y, Z, result)` (1.3; the block's integer coordinates); set slot `i` empty; `sendBlockUpdated(pos, state, state, 3)`; fire game event `block_change` (context: the block state). If the item is not feature-enabled nothing happens and the slot keeps `cookingProgress >= cookingTime`, so the attempt repeats every tick.
After the loop, if `changed`, `setChanged(level, pos, state)`. Note that `cookingProgress` of a slot is **not** reset when the slot empties; it is reset by `placeFood`.

**`cooldownTick`** (unlit, server and only when the level ticks the entity): `changed = false`; for each slot: if `cookingProgress[i] > 0`: `changed = true`; `cookingProgress[i] = clamp(cookingProgress[i] - 2, 0, cookingTime[i])`. If `changed`, `setChanged`. It applies to empty and non-empty slots alike.

**`particleTick`** (client, lit): 42-6 section 4.1 has the full rule; read again here with the same result. Draws, in order: (1) one `nextFloat`; if it is below 0.11, loop `pass = 0, 1, ...` while `pass < nextInt(2) + 2` (the bound is **re-drawn at every pass**, including the first test) and call `makeParticles(level, pos, signal_fire, false)` per pass. (2) For each slot `i` in order 0 to 3: if the stack is not empty, draw `nextFloat`; if it is below 0.2: `d = from2DDataValue(floorMod(i + facing.get2DDataValue(), 4))` and emit four `smoke` particles at `x = X + 0.5 - stepX(d) * 0.3125 + stepX(clockWise(d)) * 0.3125`, `y = Y + 0.5`, `z = Z + 0.5 - stepZ(d) * 0.3125 + stepZ(clockWise(d)) * 0.3125`, velocity (0, 0.0005, 0), with no further random draws. Empty slots draw nothing.

### 5.4 Placing food (`placeFood(level, entity, stack)`, server)

Called by the block's use-with-item when the held stack passes the property set `campfire_input` (the ingredients of the `campfire_cooking` recipes, data) on a server level: `CampfireBlock.useItemOn` calls `placeFood`; when it returns true it awards the custom stat `interact_with_campfire` and returns server success; otherwise consume. `placeFood`: scan slots 0 to 3; at the first empty slot: look up the `campfire_cooking` recipe for the stack; **if none, return false** (the scan stops, even if later slots are empty); else `cookingTime[slot] = recipe.cookingTime`, `cookingProgress[slot] = 0`, `items[slot] = stack.consumeAndReturn(1, entity)` (one item; creative players do not lose it, 17 section 1), fire game event `block_change` (context: the entity and the block state), then `markUpdated` (`setChanged` and `sendBlockUpdated(pos, state, state, 3)`), return true. If no slot is empty return false.

### 5.5 Cooking recipe schema (`campfire_cooking`)

The recipe is data; the engine reads its fields: common recipe info (`group`, `category`: the cooking book category `food`, `blocks` or `misc`, as in `CookingBookInfo`), `ingredient` (an ingredient), `result` (an item stack template: `id`, optional `count`, optional `components`), `experience` (float, default 0.0; **not used by the campfire**), `cookingtime` (int, **required** in this version, in ticks). The recipe's stream form carries the same fields. Ex.: the shipped recipe `cooked_beef_from_campfire_cooking` has category `food`, `cookingtime` 600, experience 0.35, ingredient `minecraft:beef`, result `minecraft:cooked_beef` (the archive holds 9 `campfire_cooking` recipes, 13).

### 5.6 Update tag and packet

`getUpdatePacket` returns the block entity data packet for this entity; `getUpdateTag` returns a compound holding only `Items` (written by the same always-write `saveAllItems`). Cooking progress is not sent, so the client entity has no progress values. The client entity's `items` drive the particles (5.3) and the item models (5.8).

### 5.7 Removal

`preRemoveSideEffects` drops every stack with `Containers.dropContents(level, pos, items)` (1.3).

### 5.8 Client rendering of the food

For each non-empty slot `i` the renderer draws the item with the display context `fixed`. The item model state is updated with the seed `(int) pos.asLong() + i` (the low 32 bits of the packed position plus the slot). Pose per slot: translate `(0.5, 0.44921875, 0.5)`; rotate about Y by `-toYRot(from2DDataValue((i + facing.get2DDataValue()) mod 4))` degrees; rotate about X by 90 degrees; translate `(-0.3125, -0.3125, 0)`; scale `(0.375, 0.375, 0.375)`.

### 5.9 Block coupling (what the entity relies on)

`lit` extinguishing: use with an item in the tag `douses_campfires` on a lit campfire: on the server send level event **1009** (fizz); `douse(entity, level, pos, state)` (client side only: 20 calls of `makeParticles(level, pos, signal_fire, true)`; both sides: game event `block_change`); set `lit` false; damage the item by 1. `placeLiquid` of water into a lit campfire: play `GENERIC_EXTINGUISH_FIRE` (blocks, 1.0, 1.0), `douse`, set `waterlogged` true and `lit` false. `entityInside` of a lit campfire hurts a living entity with the `campfire` damage type for the block's integer fire damage (1 or 2, 17 section 4). `signal_fire` is true when the block below is a hay block (set at placement and when the block below changes). `isSmokeyPos(level, pos)` (the rule the beehive uses for sedation, 8.7; `pos` is the hive position): for `i = 1` to `5`: let `b` = the block `i` below `pos`. If `b` is a **lit campfire** (it has the property `lit`, is in the block tag `campfires`, and `lit` is true) return true. Otherwise compute the collision shape of `b` (queried with the empty collision context, and with the level and the **hive** position as the position arguments) and test whether it intersects the "virtual post", a centred column 4 units wide, 16 units tall (`Block.column(4, 0, 16)`): if it does, **return** whether the block `i + 1` below `pos` (the one directly under `b`) is a lit campfire, ending the scan; if it does not, continue with `i + 1`. After `i = 5` without a result: false. So smoke reaches the hive through air and through blocks whose collision shape misses the centre column, and a single obstruction counts only when a lit campfire sits right under it. (17 section 3.5 and 42-6 section 4.1 describe the rule more loosely.)

### 5.10 Worked examples

1. Raw beef is placed in slot 0 at game time 5000 with an empty grill: `cookingTime[0] = 600`, `cookingProgress[0] = 0`. After 600 lit server ticks (progress 600 >= 600) the cooked beef drops at `(X + 0.125 .. X + 0.875, Y .. Y + 0.75, Z + 0.125 .. Z + 0.875)` (`w = 0.25`), slot 0 is empty and the progress stays 600 until the next placement.
2. The campfire is extinguished at progress 250 of 600: unlit, the progress decreases by 2 per tick: after 125 ticks it is 0 (and it never goes below 0). Relit at progress 100 the food needs 500 more ticks.
3. An item with no campfire recipe (a stick) cannot be placed: `placeFood` returns false, the item stays in the hand.
4. A saved campfire with `CookingTimes: [I; 10, 0]` and `CookingTotalTimes: [I; 600]` loaded into a freshly created entity (all arrays 0) gives progress `[10, 0, 0, 0]` and totals `[600, 0, 0, 0]`: each present array is copied for `min(length, 4)` entries and the remaining entries keep their previous values (they are refilled with 0 only when the key is absent).

---

## 6. Enchanting table

### 6.1 State

| Field | Type | Default | Meaning |
|---|---|---|---|
| `name` | text component | none | the custom name |
| `time` | int | 0 | client ticks counter |
| `flip`, `oFlip` | float | 0 | page flip angle now and last tick |
| `flipT` | float | 0 | flip target |
| `flipA` | float | 0 | flip velocity |
| `open`, `oOpen` | float | 0 | book openness now and last tick |
| `rot`, `oRot` | float | 0 | book yaw now and last tick (radians) |
| `tRot` | float | 0 | target yaw |

A static random source `RANDOM` (`RandomSource.create()`, not seeded from the world) is shared by all tables; it is used only by the animation.

### 6.2 Saved fields and naming

| Key | NBT type | Written | Read |
|---|---|---|---|
| `CustomName` | text component (JSON-form component codec) | when set (nullable store) | `parseCustomNameSafe`: the component, or none when absent or unparsable |

The entity is `Nameable`: `getName` is the custom name or the default `container.enchant` (translatable); `getCustomName` the custom name; `getDisplayName` is `getName` (the interface default). Implicit components: `custom_name` (read on placement from the item, collected into the item on pick-block); `removeComponentsFromTag` discards `CustomName`. The menu (`EnchantmentMenu`) is opened by the block with this display name as the title (RS14). No update packet is sent (1.1).

### 6.3 Animation (`bookAnimationTick`, client only; `EnchantingTableBlock.getTicker` returns it only when the level is client-side)

Per client tick, with `P` the block centre `(X + 0.5, Y + 0.5, Z + 0.5)`:

1. `oOpen = open`, `oRot = rot`.
2. Find the nearest player to `P` within **3.0** blocks (`getNearestPlayer(x, y, z, 3.0, false)`). Read: the default method `Level.getNearestPlayer(x, y, z, distance, boolean)` selects the entity filter from the boolean: **true** gives `NO_CREATIVE_OR_SPECTATOR`, **false** gives `NO_SPECTATORS`. The table passes false, so creative-mode players count (the book opens for them) and spectators do not. The distance limit is a squared-distance comparison against `3.0 * 3.0` (the comparison of the underlying predicate overload was not re-read; the sibling method `hasNearbyAlivePlayer` was read and compares `distanceToSqr` with the squared limit, which supports this).
3. If there is one: `dx = player.x - (X + 0.5)`, `dz = player.z - (Z + 0.5)`; `tRot = (float) Mth.atan2(dz, dx)` (the game's routine, 1.3, not the exact function); `open = open + 0.1`; then if `open < 0.5` **or** `RANDOM.nextInt(40) == 0` (the second is drawn only when `open >= 0.5`): repeat `old = flipT; flipT = flipT + (float)(RANDOM.nextInt(4) - RANDOM.nextInt(4))` **until** `flipT != old` (the first draw is the positive term).
4. Else: `tRot = tRot + 0.02`; `open = open - 0.1`.
5. Normalise `rot` into [-PI, PI): while `rot >= PI`, `rot -= 2 PI`; while `rot < -PI`, `rot += 2 PI` (floats `3.1415927`, `6.2831855`); the same for `tRot`.
6. `delta = tRot - rot`, normalised the same way; `rot = rot + delta * 0.4`.
7. `open = clamp(open, 0, 1)`.
8. `time = time + 1`.
9. `oFlip = flip`; `f = clamp((flipT - flip) * 0.4, -0.2, 0.2)`; `flipA = flipA + (f - flipA) * 0.9`; `flip = flip + flipA`.

Order of random draws: per tick with a player and `open < 0.5`: pairs of `nextInt(4)` (a then b) per loop pass; with `open >= 0.5`: one `nextInt(40)` first and, only when it is 0, the pairs.

### 6.4 Render state (`EnchantTableRenderer`)

With partial tick `p`: `flip = lerp(p, oFlip, flip)`, `open = lerp(p, oOpen, open)`, `time = time + p`, `d = rot - oRot` normalised to [-PI, PI) as above, `yRot = oRot + d * p`. Pose: translate `(0.5, 0.75, 0.5)`; translate `(0, 0.1 + Mth.sin(time * 0.1) * 0.01, 0)`; rotate about Y by `-yRot` (radians); rotate about Z by 80 degrees; `f1 = frac(flip + 0.25) * 1.6 - 0.3`, `f2 = frac(flip + 0.75) * 1.6 - 0.3` (`frac(v) = v - floor(v)`); state `forAnimation(time, clamp(f1, 0, 1), clamp(f2, 0, 1), open)`; render with the book texture: `BOOK_TEXTURE`, built in the renderer's static initialiser by applying the default-namespace mapper of the block-entity sprite sheet (`Sheets.BLOCK_ENTITIES_MAPPER`) to the sprite name `enchantment/enchanting_table_book` (read). `sin` in the bob term is the table lookup of 1.3.

### 6.5 Book model (`BookModel`, texture 64 by 32) and its state

Parts (each box is `origin, size`, texture offset; part pose offset or rotation):

| Part | Box origin | Box size | Texture offset | Pose |
|---|---|---|---|---|
| `left_lid` | (-6, -5, -0.005) | (6, 10, 0.005) | (0, 0) | offset (0, 0, -1) |
| `right_lid` | (0, -5, -0.005) | (6, 10, 0.005) | (16, 0) | offset (0, 0, 1) |
| `seam` | (-1, -5, 0) | (2, 10, 0.005) | (12, 0) | rotation (0, PI/2, 0) (1.5707964) |
| `left_pages` | (0, -4, -0.99) | (5, 8, 1) | (0, 10) | none |
| `right_pages` | (0, -4, -0.01) | (5, 8, 1) | (12, 10) | none |
| `flip_page1` | (0, -4, 0) | (5, 8, 0.005) | (24, 10) | none |
| `flip_page2` | (0, -4, 0) | (5, 8, 0.005) | (24, 10) | none |

`State` is `(openness, pageFlip1, pageFlip2)`; `forAnimation(time, flip1, flip2, open)` gives `openness = (Mth.sin(time * 0.02) * 0.1 + 1.25) * open`; the `x` offsets use `Mth.sin(o)` (all table lookups, 1.3). `setupAnim`: `o = openness`; `left_lid.yRot = PI + o`; `right_lid.yRot = -o`; `left_pages.yRot = o`; `right_pages.yRot = -o`; `flip_page1.yRot = o - o * 2 * pageFlip1`; `flip_page2.yRot = o - o * 2 * pageFlip2`; and `left_pages.x`, `right_pages.x`, `flip_page1.x`, `flip_page2.x` all `= Mth.sin(o)`.

### 6.6 Worked example

A player stands 2 blocks east of the table's centre (dx = 2, dz = 0) after a long absence: `tRot` becomes `Mth.atan2(0, 2) = 0` (exactly 0: no fold applies and the table index is 0); `open` rises by 0.1f per tick (from 0 it reaches 0.5 after 5 ticks: the five-fold float sum computed in single precision is exactly 0.5, while after 4 ticks it is 0.4000000059604645 and after 3 ticks 0.30000001192092896, so the `open < 0.5` test is false from the fifth tick on; computed in this round, not read from a trace), during which every tick draws pairs of `nextInt(4)` until the sum changes; from `open >= 0.5` only a 1-in-40 tick moves `flipT`. When the player leaves (> 3 blocks) `tRot` drifts by +0.02 per tick and `open` falls 0.1 per tick, closing in 10 ticks from 1.0. `rot` converges toward `tRot` by 40 percent of the (normalised) gap per tick.

---

## 7. Brushable block

### 7.1 State

| Field | Type | Default | Saved | Notes |
|---|---|---|---|---|
| `brushCount` | int | 0 | no | counted brushes |
| `brushCountResetsAtTick` | long | 0 | no | game time after which the count decays |
| `coolDownEndsAtTick` | long | 0 | no | game time before which a brush is ignored |
| `item` | item stack | empty | yes (7.2) | the buried item, once the loot is rolled |
| `hitDirection` | `Direction` | none | not by `saveAdditional`; written in the update tag (7.3) and **read** by `loadAdditional` (7.2) | the face first brushed |
| `lootTable` | loot table key | none | yes | the table to roll on the first brush |
| `lootTableSeed` | long | 0 | yes | seed for the roll |

Constants: `BRUSH_COOLDOWN_TICKS` 10, `BRUSH_RESET_TICKS` 40, `REQUIRED_BRUSHES_TO_BREAK` 10. The block property `dusted` is an integer property of the block (0..3, `BlockStateProperties.DUSTED`).

### 7.2 Saved fields

| Key | NBT type | Written | Read |
|---|---|---|---|
| `LootTable` | String (resource key of a loot table) | when `lootTable` is set (`trySaveLootTable`) | `LootTable.KEY_CODEC`; absent means none |
| `LootTableSeed` | Long | only with `LootTable` and only when non-zero | default 0 |
| `item` | item stack compound | only when **no** loot table is set and the item is not empty | read only when no `LootTable` key is present; if a `LootTable` is present the item is set to empty |
| `hit_direction` | Int (`Direction.LEGACY_ID_CODEC`, the 3D data value 0 to 5) | **never** by `saveAdditional` (only by the update tag, 7.3) | read by `loadAdditional` after the loot table and item handling; absent means none. This is how the client receives the direction from the Block Entity Data tag |

`brushCount`, the two timestamps and `hitDirection` are **not** saved. After a reload the count is 0 while the block's `dusted` value is what the block state stored; nothing schedules a tick on load (the block schedules ticks on placement, on neighbour updates and on every counted brush), so a reloaded half-dusted block keeps its `dusted` value until it is brushed again, at which point the first counted brush recomputes `dusted` from the count 1 (inferred from 7.4 and 7.6).

### 7.3 Update tag and packet

`getUpdatePacket` is the block entity data packet. `getUpdateTag` = the base (empty) compound plus: `hit_direction` stored with the legacy id codec (`Direction.LEGACY_ID_CODEC`: a single integer, the 3D data value 0 to 5; **omitted when null**) and, when the item is not empty, `item` encoded as an item stack with a registry-aware serialisation context. The loot table is never sent, and the item is empty while a loot table is pending.

### 7.4 Brushing (`brush(gameTime, level, entity, direction, brushItem)`, server)

Called by `BrushItem.onUseTick` (17 section 3.5 gives the item side: use duration 200, one action every 10 ticks counted as `t = 200 - remaining + 1` with `t mod 10 == 5`, so actions fall at `t = 5, 15, ..., 195`, 20 per full use, each exactly 10 ticks apart). Each counted brush action also makes a sound on the item side (`BrushItem.onUseTick`, before the server-only call to `brush`, so the call is made on both sides): the sound event is `getBrushSound()` of the target block when it is a `BrushableBlock`, else `brush_generic`, played with the four-argument `Level.playSound(player, pos, sound, BLOCKS)` (the using player is the first argument; the overload is the default method of `LevelAccessor`, read: it forwards to the six-argument form with volume 1.0 and pitch 1.0). `BrushableBlock` is constructed with `(turnsInto, brushSound, brushCompletedSound, properties)`; read from the block registration: suspicious gravel passes `brush_gravel` for both sounds and suspicious sand passes `brush_sand` for both. The completed sound is played by the client's level event **3008** handler (7.7): `playLocalSound(pos, completedSound, PLAYERS, 1.0, 1.0, false)`, followed by the block break particles for the state id in the event data. Steps, returning a boolean "completed":

1. If `hitDirection` is none, `hitDirection = direction`.
2. `brushCountResetsAtTick = gameTime + 40` (also for a brush rejected by step 3).
3. If `gameTime < coolDownEndsAtTick` return false.
4. `coolDownEndsAtTick = gameTime + 10`. (A brush exactly 10 ticks after the last is accepted: the test is `<`.)
5. `unpackLootTable(level, entity, brushItem)` (7.5).
6. `before = completionState`; `brushCount = brushCount + 1`.
7. If `brushCount >= 10`: `brushingCompleted` (7.7); return true.
8. Schedule a block tick for this block in **2** ticks; `after = completionState`; if `before != after`: set the block state with `dusted = after` (`setBlockAndUpdate`); return false.

`completionState`: 0 when `brushCount == 0`; 1 when `brushCount < 3`; 2 when `brushCount < 6`; else 3.

### 7.5 Rolling the loot (`unpackLootTable`)

Does nothing when `lootTable` is none. Else: load the table from the server's reloadable registries; when the brusher is a server player, trigger the `generate_loot` criterion with the table key; build loot parameters in the parameter set `archaeology` (26, parameter sets): `origin` = block centre, `luck` = the brusher's luck, `this_entity` = the brusher, `tool` = the brush stack; roll with the seed `lootTableSeed` (`getRandomItems(params, seed)`); the result is expected to hold at most one stack: 0 items give an empty stack, 1 gives that stack, more than 1 logs a warning and uses the first. Then `lootTable = none` and `setChanged`. (The seed is not cleared.) (26 section 11.8 states the same.)

### 7.6 Block-scheduled tick (`BrushableBlock`)

There is no entity ticker. The block schedules a 2-tick block tick on placement (`onPlace`), when a neighbour update reaches `updateShape` (always, for any direction), and on every counted brush that did not complete. The block tick:
1. If the entity is a brushable block entity: `checkReset(level)`.
2. If the block below is free (`FallingBlock.isFree`: the same test as sand and gravel, 29) and the position is not below the world's minimum Y: turn the block into a falling block entity (`FallingBlockEntity.fall(level, pos, state)`) and call `disableDrop` on it (the falling entity never drops a block item). Whether the buried item or the loot table survives the fall is the falling entity's behaviour (Open question 9). When the falling entity breaks instead of landing, `onBrokenAfterFall` sends level event 2001 (block break effect with the block state id) at the entity's bounding-box centre block and fires game event `block_destroy`.

**`checkReset(level)`**: if `brushCount != 0` and `gameTime >= brushCountResetsAtTick`: `before = completionState`; `brushCount = max(0, brushCount - 2)`; `after = completionState`; if they differ set `dusted = after` (`setBlockAndUpdate`); `brushCountResetsAtTick = gameTime + 4`. Then (always): if `brushCount == 0`: `hitDirection = none`, `brushCountResetsAtTick = 0`, `coolDownEndsAtTick = 0`; else schedule a block tick in 2 ticks. So progress decays by 2 every 4 ticks (checked on the 2-tick cadence), starting 40 ticks after the last brush action.

Client animation `animateTick` of the block: with probability 1 in 16 (`nextInt(16) == 0`), when the block below is free: spawn a `falling_dust` particle with the block state at `(X + nextDouble, Y - 0.05, Z + nextDouble)` and velocity (0, 0, 0) (42-6).

### 7.7 Completion (`brushingCompleted`, `dropContent`)

1. `dropContent(level, entity, brushItem)`: first `unpackLootTable` again (no-op normally). If `item` is not empty: with `w` and `h` the width and height of the item entity type (0.25 and 0.25), `f = 1 - w`, `half = w / 2`, `dir = hitDirection or UP`, `p = pos.relative(dir)`: the item entity is at `x = pX + 0.5 * f + half`, `y = pY + 0.5 + h / 2`, `z = pZ + 0.5 * f + half` (with `w = 0.25`: `(pX + 0.5, pY + 0.625, pZ + 0.5)`, the centre of the neighbouring block on the brushed face), with a stack split off the item of size `nextInt(21) + 10` (the whole stack when smaller), **motion zero**, added to the level; `item = empty`. No pickup-delay call is made.
2. Level event **3008** at the position with data = `Block.getId(current block state)` (the state id including the current `dusted` value). Client handling (read): if that state's block is a `BrushableBlock`, play its completed sound (7.4) as a local sound in the `PLAYERS` source at volume 1.0, pitch 1.0 with no distance delay; then spawn the destroy-block particle effect for the state.
3. Replace the block with the default state of `turnsInto` of the brushable block (suspicious sand turns into `sand`, suspicious gravel into `gravel`; block constructor data of 24) or `air` when the block is not a brushable block.

### 7.8 Client rendering (`BrushableBlockRenderer`)

Draws the buried item when `dusted > 0`, the hit direction is known and the item model state is non-empty. The light value is that of the neighbouring position on the hit face. With `s = dusted / 10 * 0.75` (integer `dusted` converted to float) the translation `t = (0.5, 0, 0.5)` is adjusted by direction: EAST `t.x = 0.73 + s`; WEST `t.x = 0.25 - s`; UP `t.y = 0.25 + s`; DOWN `t.y = -0.23 - s`; NORTH `t.z = 0.25 - s`; SOUTH `t.z = 0.73 + s`. Pose: translate `(0, 0.5, 0)`, translate `t`, rotate about Y by 75 degrees, rotate about Y by `11 + (hit is EAST or WEST ? 90 : 0)` degrees, scale 0.5, item display context `fixed`.

### 7.9 Differences from 17 section 3.5 (that section stays correct for the item side)

| 17 section 3.5 says | Read here |
|---|---|
| "a progress reset after 40 ticks without brushing (it schedules a block tick of 40)" | the reset time is 40 ticks; the scheduled block tick is always **2** ticks (7.4 step 8, 7.6); the decay is then 2 brushes every 4 ticks |
| "7 to 12" dust particles per brush action | `nextInt(7, 12)` with an exclusive upper bound: **7 to 11** particles (read in `BrushItem.spawnDustParticles`) |
| the dropped item has "speed 0.1 x random" | the item's motion is **zero** (7.7) |
| "spawned beside the block on the face the player brushed" | at the centre of the neighbouring block on that face, y offset 0.625 (7.7); the face defaults to UP when the entity never recorded one |

### 7.10 Worked examples

1. Ten brushes at game times T, T+10, ..., T+90 (the cadence of the item): brush 1: `dusted` 0 to 1; brush 3: `dusted` 2; brush 6: `dusted` 3; brush 10 (at T+90) completes: the item drops at (hit neighbour centre, +0.625), level event 3008, the block becomes sand or gravel; the brush loses 1 durability (17 section 3.5).
2. One brush at time 100 (count 1, `dusted` 1, resets at 140): block ticks run at 102, 104, ..., 140: at 140 `checkReset` sets the count to `max(0, 1 - 2) = 0`, `dusted` 0, clears `hitDirection` and the timestamps.
3. Brushes at 100, 110, 120, 130 (count 4, `dusted` 2), then stop. Resets at 170: count 2 (`dusted` 1), next reset at 174: count 0 (`dusted` 0).
4. Two brush actions 9 ticks apart: the second is rejected by the cooldown but refreshes the reset time to `gameTime + 40`.

---

## 8. Beehive

### 8.1 Constants

`MAX_OCCUPANTS` = 3; `MIN_TICKS_BEFORE_REENTERING_HIVE` = 400 (the literal 400 used for a sedated bee's stay-out countdown); `MIN_OCCUPATION_TICKS_NECTAR` = 2400; `MIN_OCCUPATION_TICKS_NECTARLESS` = 600. `BeehiveBlock.MAX_HONEY_LEVELS` = 5; the block property `honey_level` is 0..5 (default 0) and `facing` is horizontal (default NORTH).

### 8.2 State

| Field | Type | Default | Notes |
|---|---|---|---|
| `stored` | list of `BeeData` (at most 3) | empty | one per bee inside; `BeeData` = the `Occupant` plus a live `ticksInHive` counter |
| `savedFlowerPos` | `BlockPos` | none | a flower the bees remember |

### 8.3 Saved fields and the `Occupant` record

| Key | NBT type | Written | Read |
|---|---|---|---|
| `bees` | List of `Occupant` compounds (below) | always, also when empty | absent means empty; each element becomes a `BeeData` (its counter starts at the stored `ticks_in_hive`); there is no length check against `MAX_OCCUPANTS` on load |
| `flower_pos` | Int Array(3) | when set (nullable store) | absent means none |

`Occupant` record (the entry of `bees` and of the item component `bees`):

| Field | NBT key | Type | Notes |
|---|---|---|---|
| `entityData` | `entity_data` | compound: `id` (string, an entity type key) plus the entity's other saved tags | `TypedEntityData`: the `id` is split off on read (an entry without `id`, or with an invalid type, fails to decode) and written back on save |
| `ticksInHive` | `ticks_in_hive` | Int | ticks the bee has spent inside |
| `minTicksInHive` | `min_ticks_in_hive` | Int | the bee leaves once its counter **exceeds** this |

Wire form (`Occupant.STREAM_CODEC`): the `TypedEntityData` stream form (the entity type's stream codec, a VarInt registry id by 46 convention (inferred), then a compound tag), then VarInt `ticks_in_hive`, then VarInt `min_ticks_in_hive`. Implicit component: `bees` (the item component `Bees` = `Occupant.LIST_CODEC` wrapped; default empty), applied on placement (replacing `stored`) and collected on pick-up; `removeComponentsFromTag` discards `bees` (and calls the base behaviour).

**Tags removed from a stored or released bee** (`IGNORED_BEE_TAGS`, 25 names, applied when a bee is stored and again when it is released): `Air`, `drop_chances`, `equipment`, `Brain`, `CanPickUpLoot`, `DeathTime`, `fall_distance`, `FallFlying`, `Fire`, `HurtTime`, `LeftHanded`, `Motion`, `NoGravity`, `OnGround`, `PortalCooldown`, `Pos`, `Rotation`, `sleeping_pos`, `CannotEnterHiveTicks`, `TicksSincePollination`, `CropsGrownSincePollination`, `hive_pos`, `Passengers`, `leash`, `UUID`. (A released bee therefore gets a fresh UUID, no brain state, no pollination counters, and is placed by the release code, not by `Pos`.)

**`Occupant.of(entity)`**: save the entity with its normal save (`Entity.save`), remove the ignored tags, read `HasNectar` (default false) from the result; the record is `entityData` = (entity type, the cleaned tag), `ticksInHive` 0, `minTicksInHive` = **2400** when the bee has nectar else **600**. **`Occupant.create(ticksInHive)`** (worldgen: 35 part 4 draws the argument): a bee with an empty tag, the given counter and `minTicksInHive` 600. **`BeeData.tick()`**: `ticksInHive += 1`; returns `ticksInHive > minTicksInHive`. **`BeeData.toOccupant()`** copies the data with the live counter. **`BeeData.hasNectar()`**: the `HasNectar` byte of the entity data, default false.

### 8.4 Entering (`addOccupant(bee)`)

Called by the bee's enter-hive goal. That goal's `canBeeUse` needs a `hivePos`, `wantsToEnterHive` (19), the bee within 2.0 of the hive centre (`closerToCenterThan(bee position, 2.0)`) and a beehive block entity at `hivePos`; when the hive is full it clears the bee's `hivePos` (and still returns true; the start does nothing); `canBeeContinueToUse` is false; `start` calls `addOccupant`. Rules:

1. If `stored.size >= 3`, return.
2. `bee.stopRiding()`, `ejectPassengers()`, `dropLeash()`.
3. `storeBee(Occupant.of(bee))` (appends a `BeeData`).
4. If the level is set: if the bee has a saved flower position and (the hive has none **or** `random.nextBoolean()`), the hive adopts the bee's flower position (the draw happens only when the hive already has one). Play `block.beehive.enter` (`BEEHIVE_ENTER`, blocks, volume 1, pitch 1, no source entity) at the integer position `(X, Y, Z)`; fire game event `block_change` with the bee as source.
5. `bee.discard()` and `setChanged` (the base behaviour, not the fire-checking override of 8.7).

### 8.5 Releasing (`releaseOccupant(level, pos, state, occupant, outList, status, flowerPos)`, static)

Status values (`BeeReleaseStatus`, in order): `HONEY_DELIVERED`, `BEE_RELEASED`, `EMERGENCY`.

1. If the environment attribute `bees_stay_in_hive` evaluated at `pos` is true (33 section 3.4; the day timeline sets it true from tick 12542 until 23460 in the overworld, 19 "Hive entry") and `status != EMERGENCY`: return false (nobody leaves).
2. `facing` = the block state's `facing`; `out = pos.relative(facing)`; `blocked` = the block at `out` has a non-empty collision shape. If `blocked` and `status != EMERGENCY`: return false.
3. `entity = occupant.createEntity(level, pos)` (8.6); if it is none return false.
4. If `entity` is a bee:
   a. If `flowerPos != null` and the bee has no saved flower position and `random.nextFloat() < 0.9`: `bee.setSavedFlowerPos(flowerPos)` (the draw happens only when the first two conditions hold).
   b. If `status == HONEY_DELIVERED`: `bee.dropOffNectar()`; and if the hive state is in the block tag `beehives` and has the `honey_level` property and the level is below 5: `inc = (nextInt(100) == 0) ? 2 : 1`; if `level + inc > 5` then `inc = inc - 1`; set `honey_level = level + inc` (`setBlockAndUpdate`). (The `nextInt(100)` is drawn only when the level is below 5.)
   c. If `outList` is given, append the bee.
   d. Position: `wd = entity.bbWidth`; `off = blocked ? 0 : 0.55 + wd / 2`; `x = X + 0.5 + off * stepX(facing)`, `y = Y + 0.5 - entity.bbHeight / 2`, `z = Z + 0.5 + off * stepZ(facing)`; `snapTo(x, y, z, entity.yRot, entity.xRot)`.
5. Play `block.beehive.exit` (`BEEHIVE_EXIT`, blocks, volume 1, pitch 1, no source entity) at `pos`; fire game event `block_change` (source: the entity; the block state at `pos`).
6. `level.addFreshEntity(entity)`; return its result.

### 8.6 `Occupant.createEntity(level, pos)`

Copy the entity data tag (without `id`), remove the ignored tags, load the entity with `EntityType.loadEntityRecursive(type, tag, level, spawnReason LOAD, no processor)`; the result must exist **and** be in the entity type tag `beehive_inhabitors` or the method returns none; `setNoGravity(true)`; for a bee: `setHivePos(pos)` and `setBeeReleaseData(ticksInHive, bee)`:
- **Age**: unless the bee's age is locked: with `age = bee.getAge()`: if `age < 0`, `setAge(min(0, age + ticksInHive))`; if `age > 0`, `setAge(max(0, age - ticksInHive))`.
- **Love**: `setInLoveTime(max(0, inLoveTime - ticksInHive))`.
(The time spent inside counts as time passing for growth, breeding cool-down and love.)

### 8.7 Fire, sedation, anger

- **Fire test** (`isFireNearby`): any block in the 3 by 3 by 3 box centred on the hive whose block is an instance of the fire block class (`fire`; soul fire is a different class and does not count). Where tested: the entity's `setChanged()` override (any `setChanged` that is not the base-class call in `addOccupant`/`releaseAllOccupants`/`tickOccupants`'s static form): if a fire is nearby, run `emptyAllLivingFromHive(none, state, EMERGENCY)` before the base behaviour; and `BeehiveBlock.updateShape` when the neighbouring block is a fire block (same call).
- **Sedation** (`isSedated`): `CampfireBlock.isSmokeyPos(level, pos)` (5.9).
- **`emptyAllLivingFromHive(player, state, status)`**: `list = releaseAllOccupants(state, status)` (removes every stored bee for which `releaseOccupant` returned true, with the entity's `savedFlowerPos`; calls the base `setChanged` when the result list is not empty); then, when `player != null`, for each released bee within squared distance 16.0 of the player: when not sedated, `bee.setTarget(player)`; when sedated, `bee.setStayOutOfHiveCountdown(400)`.
- **Block-side callers** (`BeehiveBlock`): breaking the block with a tool that does not carry the enchantment tag `prevents_bee_spawns_when_mining` releases all bees with `EMERGENCY` (with the player), updates the comparator neighbours and angers nearby bees (`angerNearbyBees`); the `bee_nest_destroyed` criterion is triggered in either case, with the occupant count read after any release. Explosion hits anger nearby bees. `getDrops` releases all bees (no player, `EMERGENCY`) when the loot context's entity is primed TNT, a creeper, a wither skull, the wither boss or a TNT minecart. In creative mode (`preventsBlockDrops`), with the `block_drops` game rule on, destroying a hive that holds bees or has honey level above 0 drops one hive item whose components are the entity's collected components (the `bees` component) plus `block_state` = `{honey_level: n}`, at the block's integer position with default pickup delay. `angerNearbyBees(level, pos)`: when any `Bee` is in the box of the block inflated by (8, 6, 8) and any `Player` too, every bee in the box without a target gets a random player from the player list as target. Pick-block copies `block_state` honey level. `dropHoneycomb` rolls the `harvest/beehive` table; `useItemOn` (shears, glass bottle) is 17 section 3 (honey level 5 gate; `releaseBeesAndResetHoneyLevel` sets `honey_level` 0 and releases with `EMERGENCY` when not smoky).
- **Analog output**: the comparator output is the `honey_level`.

### 8.8 Tick (server only; `BeehiveBlock.getTicker` returns none for client levels)

1. `tickOccupants(level, pos, state, stored, savedFlowerPos)`: `changed = false`; for each `BeeData` in list order: if `data.tick()` (counter now exceeds the minimum): `status = data.hasNectar() ? HONEY_DELIVERED : BEE_RELEASED`; if `releaseOccupant(level, pos, state, data.toOccupant(), none list, status, savedFlowerPos)` returns true: `changed = true` and remove the entry. After the loop, if `changed`: the static `setChanged(level, pos, state)` (no fire test).
2. If `stored` is not empty and `nextDouble() < 0.005`: play `block.beehive.work` (`BEEHIVE_WORK`, blocks, volume 1, pitch 1, no source entity) at `(X + 0.5, Y, Z + 0.5)`.

A bee whose release is blocked or suppressed (daylight attribute, blocked exit) keeps its counter growing past the minimum and is retried every tick.

### 8.9 Comparison with other documents

- 17 section 3 (shears and bottle rules) and 19 (the bee: goals and `wantsToEnterHive`) cover the block-side use and the bee-side decisions; this section is the block entity half. The bee's `HasNectar`, `hive_pos`, `flower_pos`, `CannotEnterHiveTicks`, `TicksSincePollination` and `CropsGrownSincePollination` keys are in 45 part 4.
- Worldgen: `BeehiveDecorator` and tree beehives place `bee_nest` facing south and call `storeBee(Occupant.create(nextInt(599)))` for each of `2 + nextInt(2)` occupants (35 part 4).
- Dispensers shearing a full hive: the `ShearsDispenseItemBehavior` class references the hive (not read in this round; Open question 10).

### 8.10 Worked examples

1. A bee with nectar enters a hive at honey level 4: `Occupant.of` gives `ticks_in_hive` 0, `min_ticks_in_hive` 2400. After 2401 server ticks `data.tick()` is true; `hasNectar` so the status is `HONEY_DELIVERED`; if it is night in the overworld (`bees_stay_in_hive` true) the bee stays and is retried each tick; once released, `dropOffNectar`, the honey level becomes 5 (`inc` 1; or `inc` 2 with chance 1/100, which is reduced to 1 because 4 + 2 > 5), the bee is placed at `(X + 0.5 + (0.55 + wd/2) * stepX, Y + 0.5 - h/2, Z + 0.5 + (0.55 + wd/2) * stepZ)` where `facing` points out of the hive.
2. A nectarless bee: it leaves after 601 ticks inside (`BEE_RELEASED`), no honey change.
3. A fire block placed next to the hive: `updateShape` calls `emptyAllLivingFromHive(none, state, EMERGENCY)`: bees leave even at night and even when the exit is blocked (the blocked position is then `off = 0`: the bee appears at the hive's centre column).
4. A player breaks a hive containing 3 bees without silk touch: all 3 are released with `EMERGENCY`; those within 4 blocks (squared distance <= 16) of the player target the player, unless a lit campfire smokes the hive, in which case they get a 400-tick stay-out countdown instead.
5. A hive holds `bees: [ {entity_data: {id: "minecraft:bee", HasNectar: 1b, ...}, ticks_in_hive: 500, min_ticks_in_hive: 2400} ]`: after loading, the counter continues from 500; the bee needs 1901 more ticks.

---

## 9. Validation section

Each row is a test an implementation can run from this document alone.

| # | Input | Expected |
|---|---|---|
| V1 | Jukebox holds `music_disc_13` (3560 ticks) and starts at tick 0 | level event 1010 with data = the song's registry id at start; `jukebox_play` events at ticks 0, 20, ..., 3560; at the tick that sees `ticks = 3580` level event 1011 and `has_record` stays true; comparator output 1 |
| V2 | Jukebox NBT `{RecordItem: <disc>, ticks_since_song_started: 4000L}` for the 3560-tick disc | the stack loads, `setSongWithoutPlaying` is ignored (finished), no song plays; saving writes `RecordItem` only (no tick key) |
| V3 | Jukebox NBT with a changed `RecordItem` while another disc plays | the player stops (event 1011 and game event) before the new item is stored |
| V4 | `canTakeItem` of a jukebox into a full chest | false; into a chest with one empty slot: true |
| V5 | Lectern, 5-page book, page 2 | `getRedstoneSignal` 8; page 4: 15; page 0: 1; 1-page book: 15 |
| V6 | Lectern menu button 109 with a 5-page book | page 4; `powered` true for 2 ticks; level event 1043 |
| V7 | Lectern menu button 3 by a player who cannot build | returns false, book unchanged |
| V8 | Lectern NBT `{Book: <written book>, Page: 7}` with 3 pages | page 2 |
| V9 | Bell rung once with a raider 20 blocks away and no other entity | step 3 triggers at `ticks == 5`; the server gives the raider `glowing` 60 ticks at the end action 40 ticks later |
| V10 | Bell client count `c` = 1, 2, 3, 15, 17, 40 | particles per raider 10, 9, 9, 3, 3, 3 |
| V11 | Bell struck on its side at relative y 0.9 | no ring (`isProperHit` false) |
| V12 | Campfire slot with raw beef (`cookingtime` 600) lit for 600 ticks | the result drops, slot empty, progress stays 600 |
| V13 | The same slot unlit with progress 250 | 0 after 125 ticks, never negative |
| V14 | `placeFood` with a stick | false, the stack unchanged; with beef on a grill whose slot 0 is occupied and slot 1 empty: slot 1 is used |
| V15 | Campfire update tag | contains only `Items` |
| V16 | Brushable block: brushes at T and T+9 | the second is ignored but resets the reset time to T+49; at T+10 a brush counts |
| V17 | Brushable block with count 10 reached | level event 3008, block becomes sand (or gravel), the item has zero motion at the neighbour centre +0.625 |
| V18 | Brushable block with count 4 untouched for 70 ticks | counts 2 then 0 on the 2-tick block ticks after reset times |
| V19 | Brushable update tag with no hit direction and an empty item | an empty compound |
| V20 | Beehive with a nectar bee entered 2401 ticks ago at honey level 5, daytime | the bee is released, honey stays 5 |
| V21 | Beehive release with the exit blocked and status `BEE_RELEASED` | no release; with `EMERGENCY` the bee is placed at the centre column (`off` 0) |
| V22 | Fire block within the 3 by 3 by 3 box | `setChanged` empties the hive with `EMERGENCY` |
| V23 | Beehive NBT round trip | `bees` always written (empty list when none); `flower_pos` only when set; a stored bee has none of the 25 ignored tags |
| V24 | Enchanting table with a player at 2 blocks | `open` increases by 0.1 per tick to 1; no player: `open` decreases by 0.1 and `tRot` increases by 0.02 per tick |
| V25 | `isSmokeyPos` for a hive: lit campfire 3 below with air between; full block 1 below and lit campfire 2 below; full block 1 below, air 2 below, lit campfire 3 below; lit campfire 6 below | true; true; false; false |

---

## 10. Open questions

1. **Component resolver.** `ComponentUtils.resolve` (the text-component resolver run on written-book pages by the lectern: selectors, scores, NBT sources, translation arguments, the `ResolutionContext` built from a command source stack) was not read. Its specification belongs with the commands (15, 16) or the chat components; the lectern relies on it (3.4).
2. **Component `Filterable` wire form.** Section 3.4's statement that the stream form is `raw` followed by an optional `filtered` is inferred from the codec composition (a `CodecOperation` whose body was not decoded); a wire fixture is needed.
3. **`Filterable` encode form.** That the codec encodes in the record form `{raw, filtered?}` is inferred from the argument order of `Codec.withAlternative` (first argument primary); not checked against a saved book.
4. **Jukebox load without a level.** Load step 2 can call the song player's `stop` while the entity's level is still unset (chunk load). The behaviour with a null level in `JukeboxSongPlayer.stop` (which dereferences the level for the game event and the level event) was not traced; in practice step 2 only runs when a song is playing, which cannot hold on a freshly created entity.
5. (Closed.) `Mth.clamp(int, int, int)` was read: `min(max(v, min), max)`, so a 0-page lectern keeps `page = -1` after load or `setPage` (3.2, 3.3).
6. **Recipe check cache.** `RecipeManager.createCheck(campfire_cooking)` returns a `CachedCheck`; whether it only caches the last matching recipe (inferred from its name and use) or filters differently from `getRecipeFor(type, input, level)` (used by `placeFood`) was not read. The set `campfire_input` (`RecipePropertySet.CAMPFIRE_INPUT`) is taken to be the union of ingredients of all `campfire_cooking` recipes (inferred).
7. (Closed, with one residue.) The boolean of `getNearestPlayer(x, y, z, distance, boolean)` was read (false selects `NO_SPECTATORS`, 6.3). Not re-read: the body of the predicate overload `getNearestPlayer(x, y, z, distance, predicate)`, so the squared-distance comparison of 6.3 is inferred from the sibling `hasNearbyAlivePlayer`.
8. (Closed for the book.) The book sprite name is `enchantment/enchanting_table_book` (6.4). The bell sprite is `bell/bell_body` in the block entity sprite mapper; the resource-pack path of these sprites is data (14).
9. **Falling brushable blocks.** `BrushableBlock.tick` calls `FallingBlockEntity.fall` and `disableDrop`. Whether the falling entity carries the block entity's data (so a buried item survives the fall and is restored on landing) is the falling block entity's behaviour (29, 41), not read here.
10. **Dispenser shearing.** `ShearsDispenseItemBehavior` references the hive; its use of `BeehiveBlock.dropHoneycomb` and `releaseBeesAndResetHoneyLevel` and its rules were not read.
11. **Brush dust particles.** The count was read: `nextInt(7, 12)`, exclusive bound, so 7 to 11 particles (7.9; 17 section 3.5 says "7 to 12" and is not edited here). The particle delta values seen in `DustParticlesDelta` include -0.1, -1.0 and 0.1, with 1.0E-6f used as an epsilon, but the full `DustParticlesDelta.fromDirection` table was not decoded.
12. **Hive release before the bee leaves.** `Bee.setHivePos`, `dropOffNectar`, `setSavedFlowerPos`, `getAge`, `isAgeLocked` and the `inLove` accessors are bee entity methods; their exact effects are in 19 and 45 part 4, not re-read.
13. **Lectern menu slot class.** `LecternMenu$1` (the slot class that wraps the container slot) was not read: whether it overrides `setChanged` to notify the menu is not recorded.
14. **Block shapes and placement rules** of the seven blocks (lectern, bell, campfire, enchanting table, suspicious sand and gravel, beehive and bee nest, jukebox) are block registry data (24) and were not read here.
15. **`jukebox_song` entries and the `lectern_books`, `douses_campfires`, `raiders`, `beehive_inhabitors`, `beehives`, `campfires` tags** are data (extracted by the tool) and are not tabulated.
16. **Brush sound parameters (resolved).** The four-argument `Level.playSound` used by `BrushItem.onUseTick` is the `LevelAccessor` default that forwards volume 1.0 and pitch 1.0 (7.4). Not traced: the six-argument implementation's distance attenuation and the client sound engine's handling of the excluded player (the first argument).
17. **`Mth.asin`/`cos` table values.** The `ASIN_TAB` and `COS_TAB` entries are computed at class initialisation by the runtime's `Math.asin` and `Math.cos` (1.3); bit-exact values of those library calls were not read and are not tabulated.
