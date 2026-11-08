# Enchantment effect components: schema and engine

| Item | Value |
|---|---|
| Covers | The `effects` map of an enchantment definition: the 31 effect component types, the wrapper records (conditional and targeted), the level-based number type, the value effects, entity effects and location-based effects, the loot-context parameter sets that requirement predicates run in, how the effects of many enchantments and levels combine, the location-based activation state machine, and every hook point in gameplay code that evaluates an effect component. Not covered: the rows of the 43 enchantments (data pack; the per-enchantment formulas already read are in [17](17-tools-weapons-and-combat.md) section 6.3), the loot condition grammar and condition list ([26](26-loot-and-predicates.md) sections 8 and 10), the enchanting table arithmetic (17 section 6.5). The `Enchantment` definition fields that are not effects are summarised in section 13; the rest of that area is listed as out of scope in the Open questions. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (version 26.3). The artifact already recorded in [README.md](README.md); no new artifact. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.item.enchantment.*`, `...enchantment.effects.*`, the call sites of `EnchantmentHelper` and `EnchantmentEffectComponents` across the jar, and a few `data/minecraft/enchantment/*.json` files used as worked examples, with no execution |
| Ticket / round | `tickets/CC-0001-client-polish.md`; `docs/design/README.md` GAP-7g, round RS8 |

Read first: [04](04-registry-sync.md) (the `enchantment` registry entry, the `effects` Compound), [17](17-tools-weapons-and-combat.md)
sections 4, 5 and 6 (combat arithmetic, durability, per-enchantment formulas), [00](00-data-types.md) (NBT, identifiers).
Operator decision (CC-0001, "Vanilla assets and data"): the enchantment rows are data extracted from the user's jar by the
tool; this document specifies the **schemas and the engine** that interpret those rows. A row the tool extracts is valid for
the engine if it satisfies sections 2 to 7.

Conventions: `float` arithmetic is IEEE single precision unless "double" is said; the artifact computes every level-based
value in single precision and a few operations (exponent, binomial approximation) through double precision and back,
so implementations that need bit-exact results follow the stated precision. "Level" is the enchantment level L (an int
from 1 up) of the enchantment whose effect is being evaluated. A key written without namespace is in `minecraft`.
Class and method names in backticks say where a fact was read. "(inferred)" marks a value deduced rather than read.

---

## 1. Model in one paragraph

An enchantment definition holds a map from **effect component type** to a value. Every type has a fixed value shape:
a list of *conditional effects* (an effect object plus an optional loot-condition `requirements`), a list of *targeted*
conditional effects (also naming who is enchanted and who is affected), a single value effect, a list of attribute
effects, a list of sounds, or a unit. Effects that produce numbers are **value effects** (add, multiply, set ...)
whose numeric argument is a **level-based value** (constant, linear, lookup ...). Effects that act on the world are
**entity effects** or **location-based effects**. Gameplay code asks `EnchantmentHelper` to evaluate one component
type on an item, on an entity's equipment, or on a single item in a slot: the helper iterates the enchantments
stored on the item, builds a loot context for each (carrying the enchantment level), tests each conditional effect's
`requirements` against that context, and applies the effects that pass, in order. Level never reaches an effect except
through its level-based values and through the loot context parameter `enchantment_level`.

---

## 2. The effect component map

### 2.1 Encoding

The `effects` field of an enchantment (04, `enchantment` registry) is a Compound whose keys are identifiers from the static registry
`enchantment_effect_component_type` and whose value is decoded by that type's codec. The codec is the generic data-component
map codec (`EnchantmentEffectComponents.CODEC`): an unknown key is an error, a key may appear once, an absent key means "no effect".
All values are persistent (NBT/JSON) codecs; none is network-only. The effect lists use the validated list form: when a
list is decoded, each element's `requirements` is checked against the loot context key set of the component (section 7.1);
a requirement that reads a parameter the set does not provide is reported by that validation step (the codec shows `validateHolder` on the optional `requirements` only). Whether a reported problem drops the whole enchantment or only logs it was not read, so "the enchantment fails to load" is (inferred); see Open question 16 and [23](23-registry-loading.md).

### 2.2 The 31 component types

Registration order below is the order of the static initializer (`EnchantmentEffectComponents`); the numeric registry
id of each type is its position, 0-based (inferred from the order; the wire never carries these numbers, because keys are identifiers). "Set" is the loot context key set of 7.1.

| # | Key | Value shape | Effect object type | Set | Hook (section 9) |
|---|---|---|---|---|---|
| 0 | `damage_protection` | list of conditional | value effect | DAMAGE | H1 |
| 1 | `damage_immunity` | list of conditional | `damage_immunity` (unit object `{}`) | DAMAGE | H2 |
| 2 | `damage` | list of conditional | value effect | DAMAGE | H3 |
| 3 | `smash_damage_per_fallen_block` | list of conditional | value effect | DAMAGE | H4 |
| 4 | `knockback` | list of conditional | value effect | DAMAGE | H5 |
| 5 | `armor_effectiveness` | list of conditional | value effect | DAMAGE | H6 |
| 6 | `post_attack` | list of **targeted** | entity effect | DAMAGE | H7 |
| 7 | `post_piercing_attack` | list of conditional | entity effect | DAMAGE | H8 |
| 8 | `hit_block` | list of conditional | entity effect | HIT_BLOCK | H9 |
| 9 | `item_damage` | list of conditional | value effect | ITEM | H10 |
| 10 | `equipment_drops` | list of **targeted (drops form)** | value effect | DAMAGE | H11 |
| 11 | `location_changed` | list of conditional | location-based effect | LOCATION | H12 |
| 12 | `tick` | list of conditional | entity effect | ENTITY | H13 |
| 13 | `ammo_use` | list of conditional | value effect | ITEM | H14 |
| 14 | `projectile_piercing` | list of conditional | value effect | ITEM | H15 |
| 15 | `projectile_spawned` | list of conditional | entity effect | ENTITY | H16 |
| 16 | `projectile_spread` | list of conditional | value effect | ENTITY | H17 |
| 17 | `projectile_count` | list of conditional | value effect | ENTITY | H18 |
| 18 | `trident_return_acceleration` | list of conditional | value effect | ENTITY | H19 |
| 19 | `fishing_time_reduction` | list of conditional | value effect | ENTITY | H20 |
| 20 | `fishing_luck_bonus` | list of conditional | value effect | ENTITY | H21 |
| 21 | `block_experience` | list of conditional | value effect | ITEM | H22 |
| 22 | `mob_experience` | list of conditional | value effect | ENTITY | H23 |
| 23 | `repair_with_xp` | list of conditional | value effect | ITEM | H24 |
| 24 | `attributes` | list of attribute effects (no wrapper, no requirements, not validated against a set) | `EnchantmentAttributeEffect` | none | H25 |
| 25 | `crossbow_charge_time` | **single** value effect (no list, no requirements) | value effect | none | H26 |
| 26 | `crossbow_charging_sounds` | list of `{start?, mid?, end?}` (each an optional sound event holder) | none | none | H27 |
| 27 | `trident_sound` | list of sound event holders | none | none | H28 |
| 28 | `prevent_equipment_drop` | unit (empty object) | none | none | H29 |
| 29 | `prevent_armor_change` | unit (empty object) | none | none | H30 |
| 30 | `trident_spin_attack_strength` | **single** value effect (no requirements) | value effect | none | H31 |

Notes read from the codecs: the value effect of a `list of conditional` is polymorphic over the six value-effect types of
section 5; the entity effect is polymorphic over the types of section 6.1; the location-based effect over 6.2. Exactly two
component types use a single value effect rather than a list: `crossbow_charge_time` (25) and `trident_spin_attack_strength` (30). Their effect is evaluated
without a loot context and without requirements, so a level-only expression is the whole behaviour. `mob_experience`
(22) has a hook but no shipped enchantment of this artifact uses it (the enchantment bootstrap class never names it): it is
specified here because a data pack may use it.

**Load-time versus run-time sets.** A requirement is checked at load only for the parameters it reads, against the component's set (7.1). `post_piercing_attack` is validated against the DAMAGE set, but at run time (9.2) it is evaluated in an ENTITY-type context that has only `this_entity`, `enchantment_level` and `origin`. A requirement that reads `damage_source`, `attacking_entity` or `direct_attacking_entity` therefore loads without error and can never be satisfied when the hook runs (the parameter is missing; how a missing parameter makes a condition evaluate is in [26](26-loot-and-predicates.md) section 8).

---

## 3. Wrapper records

### 3.1 Conditional effect (`ConditionalEffect`)

| Field | Type | Default | Meaning |
|---|---|---|---|
| `effect` | the component's effect object (a dispatched object with a `type` field, section 5 or 6) | required | what runs |
| `requirements` | a loot condition (any loot predicate, [26](26-loot-and-predicates.md) section 8, wrapped as a holder: an inline predicate or a reference) | absent = always true | tested against the loot context built for this evaluation |

`matches(context)`: true when `requirements` is absent, otherwise the predicate's result on the context.

### 3.2 Targeted conditional effect (`TargetedConditionalEffect`)

Used by `post_attack` and `equipment_drops`.

| Field | Type | Meaning |
|---|---|---|
| `enchanted` | target, `attacker`, `damaging_entity` or `victim` | whose equipment must carry the enchantment for this effect to be considered |
| `affected` | target, same three names | the entity the effect is applied to |
| `effect` | the effect object | |
| `requirements` | optional loot condition | |

`post_attack` uses the full form (`enchanted` and `affected` both read from the data). `equipment_drops` uses a
restricted form (`equipmentDropsCodec`): `enchanted` accepts only `attacker` or `victim` (the "non damage" target codec),
there is no `affected` field in the data and `affected` is fixed to `victim`. The three target names are serialized
names `attacker`, `damaging_entity`, `victim`; the enum order is attacker, damaging_entity, victim.

How a target resolves against a `DamageSource` and the victim: `attacker` = the source's causing entity (`getEntity`);
`damaging_entity` = the source's direct entity (`getDirectEntity`; for an arrow, the arrow; for a melee hit, the attacker);
`victim` = the entity that received the damage. An unresolved (null) affected entity skips the effect silently.

### 3.3 Enchanted item in use (`EnchantedItemInUse`)

The record passed to entity and location effects: the item stack, the equipment slot it sits in (may be null when the
iteration had no slot), the owner (a living entity, may be null for slotless item iterations), and an `onBreak` callback
(called with the stack when applying `change_item_damage` breaks the item).

---

## 4. Level-based values (`LevelBasedValue`)

Every numeric argument of an effect is a level-based value: a function from the enchantment level (int) to a float.

### 4.1 Encoding

Either a bare number (a constant) or an object whose `type` selects one of six registered types
(registry `enchantment_level_based_value_type`, order of registration: `clamped`, `fraction`, `levels_squared`, `linear`,
`exponent`, `lookup`). A `constant` type object is **not** a registered type in this artifact: the constant exists only as the bare-number
form (inferred from the absence of a registration; the typed constant codec is referenced only from the constant record itself).

### 4.2 Types and formulas

| Type | Fields | Value at level L |
|---|---|---|
| bare number | the number (float) | the number |
| `linear` | `base` (float), `per_level_above_first` (float) | base + per_level_above_first x (L - 1) (float arithmetic: (L-1) converted to float, multiplied, added) |
| `levels_squared` | `added` (float) | float(L x L) + added (L x L is an int square) |
| `lookup` | `values` (list of floats), `fallback` (a level-based value) | if L is at most the list length: values[L - 1] (1-based by level); otherwise fallback evaluated at L. L below 1 is not guarded (would index out of range); levels are always at least 1 |
| `fraction` | `numerator`, `denominator` (level-based values) | the denominator is evaluated first; if it equals 0.0 the result is 0.0; otherwise numerator / denominator (float division) |
| `clamped` | `value` (level-based value), `min`, `max` (floats) | clamp(value(L), min, max). Decoding fails with an error unless max is strictly greater than min: max <= min is rejected, so min = max is **not** allowed. The message reads "Max must be larger than min, min: X, max: Y" (floats formatted by the string concatenation) |
| `exponent` | `base`, `power` (level-based values) | (float) pow(double(base(L)), double(power(L))) (double `pow`, narrowed to float) |

Nested expressions are unbounded (fraction of linear of lookup, as in Unbreaking).

### 4.3 Worked examples

| Expression | L | Result |
|---|---|---|
| linear base 1.0, per level 0.5 (Sharpness `damage`) | 1 / 3 / 5 | 1.0 / 2.0 / 3.0 |
| levels_squared added 1 | 3 | 10.0 |
| lookup values [1.2, 1.75, 2.2], fallback linear 1.5 + 0.35 per level | 2 / 3 / 4 | 1.75 / 2.2 / 1.5 + 0.35 x 3 = 2.55 (fallback evaluated at L = 4) |
| fraction numerator linear 2 + 2/level, denominator linear 10 + 5/level (Unbreaking, armor entry) | 1 / 2 / 3 | 2/10 = 0.2 / 4/15 = 0.26667 / 6/20 = 0.3 |
| fraction numerator linear 1 + 1/level, denominator linear 2 + 1/level (Unbreaking, other entry) | 1 / 2 / 3 | 0.5 / 0.66667 / 0.75 |
| exponent base 2.0, power 3.0 | any | 8.0 |
| fraction with denominator constant 0 | any | 0.0 |
| clamped (linear 3 + 1/level) min 0, max 4 | 4 | 6.0 clamped to 4.0 |

(The lookup row's `wind_burst` values are the ones read in 17 section 6.3; the fallback numbers there are read there. The Unbreaking expressions were read from `data/minecraft/enchantment/unbreaking.json`.)

---

## 5. Value effects (`EnchantmentValueEffect`)

A value effect transforms a float: `process(level, random, value) -> float`. Registry `enchantment_value_effect_type`,
registration order and ids: `add`, `all_of`, `multiply`, `remove_binomial`, `exponential`, `set`.

| Type | Fields | Result |
|---|---|---|
| `add` | `value` (level-based) | value + v(L) |
| `multiply` | `factor` (level-based) | value x factor(L) |
| `set` | `value` (level-based) | v(L) (ignores the input) |
| `exponential` (`ScaleExponentially`) | `base`, `exponent` (level-based) | (float)(double(value) x pow(double(base(L)), double(exponent(L)))) |
| `all_of` | `effects` (list of value effects) | applied left to right, each receiving the previous result |
| `remove_binomial` | `chance` (level-based) | see 5.1 |

All fields are required. The `random` argument is consumed only by `remove_binomial`; which random source is passed depends on the hook (section 8.3).

### 5.1 `remove_binomial`

Input n (float, a count of events such as durability points), p = chance(L) (float). The result is n minus the number of
events removed, so it is a float that is generally a whole number.

1. Decide the method. The **normal approximation** is used when n is greater than 128.0 and n x p is at least 20.0 and
   n x (1 - p) is at least 20.0 (all float). Otherwise the **exact** method is used.
2. Exact: the number of draws is the smallest integer count of events that is at least n (n = 10.0 gives 10, n = 10.5 gives 11); one `nextFloat` is drawn from the random source per event, and k is the number of draws that come out less than p.
3. Normal: mean = floor(double(n x p)) (double floor of the float product); sd = sqrt(double(n x p x (1 - p))); k = (int) round(mean + nextGaussian x sd) where `round` is the double round-half-up to long, then narrowed; k is clamped to 0 .. (int)n.
4. Result = n - float(k).

Draw order: exactly one `nextGaussian` in the normal case, n draws of `nextFloat` in the exact case. The generator is the hook's random source (8.3).

### 5.2 Worked examples

1. Unbreaking III on a non-armor item (second entry of Unbreaking: chance 0.75; the first entry's requirement is `match_tool` armor tag and fails): 10 durability points arrive. Ten draws, say 0.10, 0.90, 0.50, 0.80, 0.30, 0.74, 0.76, 0.20, 0.99, 0.60: those below 0.75 are 0.10, 0.50, 0.30, 0.74, 0.20, 0.60, so k = 6 and the result is 10 - 6 = 4 points of damage.
2. n = 1000, p = 0.3: n x p = 300 and n x (1 - p) = 700 are both at least 20 and n > 128, so the normal method: mean = 300, sd = sqrt(1000 x 0.3 x 0.7) = 14.49; with the Gaussian draw 0.5, k = round(300 + 7.245) = 307, result 693.
3. n = 130, p = 0.1: n > 128 but n x p = 13 < 20, so the exact method (130 draws).

---

## 6. Entity effects and location-based effects

An **entity effect** (`EnchantmentEntityEffect`) has `apply(level, enchantedItemInUse, entity, position)` where `entity` is
the affected entity and `position` a Vec3. Registry `enchantment_entity_effect_type`; registration order:
`all_of`, `apply_mob_effect`, `change_item_damage`, `damage_entity`, `explode`, `ignite`, `apply_impulse`,
`apply_exhaustion`, `play_sound`, `replace_block`, `replace_disk`, `run_function`, `set_block_properties`,
`spawn_particles`, `summon_entity`.

A **location-based effect** (`EnchantmentLocationBasedEffect`) has `onChangedBlock(level, enchLevel, itemInUse, entity, position, newlyActive)` and `onDeactivated(itemInUse, entity, position, enchLevel)` (default: nothing). Registry `enchantment_location_based_effect_type`, registration order: `all_of`, `apply_mob_effect`, `attribute`, `change_item_damage`, `damage_entity`, `explode`, `ignite`, `apply_impulse`, `apply_exhaustion`, `play_sound`, `replace_block`, `replace_disk`, `run_function`, `set_block_properties`, `spawn_particles`, `summon_entity` (every entity type plus `attribute`). For every type except `attribute`, `onChangedBlock` simply calls the entity effect's `apply` (the `newlyActive` flag is ignored) and `onDeactivated` does nothing. The attribute effect (6.3) is the only location-based type that uses `newlyActive` semantics and `onDeactivated`.

An `all_of` of entity effects (`effects` list) applies each member in list order. The location `all_of` forwards both callbacks to every member.

### 6.1 Entity effect types

All numeric fields are level-based values (section 4) unless stated. `entity` is the affected entity (for `post_attack` the `affected` target, for `tick` the wearer, etc.). `pos` is the Vec3 position handed in by the hook (the affected entity's position for every hook except `hit_block`, which passes the hit location).

| Type | Fields (default) | Behaviour |
|---|---|---|
| `all_of` | `effects`: list of entity effects | apply in order |
| `apply_mob_effect` | `to_apply`: holder set of mob effects; `min_duration`, `max_duration` (seconds); `min_amplifier`, `max_amplifier` | only for living entities. Steps: (1) pick one effect uniformly from the set using the entity's own random (`getRandomElement`; empty set: nothing); (2) duration ticks = round(randomBetween(min_duration, max_duration) x 20); (3) amplifier = max(0, round(randomBetween(min_amplifier, max_amplifier))); `round` is `Math.round` on a float to an int, i.e. round half up (floor of x + 0.5). `randomBetween(r, a, b)` = a + nextFloat x (b - a). Draw order on the entity's random: set pick, duration, amplifier. Then `addEffect(new instance(effect, duration, amplifier))` |
| `change_item_damage` | `amount` | when the item stack has both `max_damage` and `damage` components: n = (int) amount(L) (truncation); `hurtAndBreak(n, level, owner-if-ServerPlayer-else-null, item's onBreak)`. Otherwise nothing. n may be negative (repair) |
| `damage_entity` | `min_damage`, `max_damage`, `damage_type` (damage type holder) | d = randomBetween(entity random, min_damage(L), max_damage(L)); `entity.hurtServer(level, source, d)` where the source is a new damage source of `damage_type` whose causing entity is the enchanted item's **owner** (so the owner is credited, and the entity struck by the effect is the affected one). Damage goes through the full hurt pipeline (17 section 4.4), including the hurt window |
| `explode` | `attribute_to_user` (bool, false), `damage_type` (optional holder), `knockback_multiplier` (optional level-based), `immune_blocks` (optional block holder set), `offset` (Vec3, 0,0,0), `radius` (level-based), `create_fire` (bool, false), `block_interaction` (one of `none`, `block`, `mob`, `tnt`, `trigger`), `small_particle`, `large_particle` (particle options), `block_particles` (weighted list of explosion particle info, empty), `sound` (sound event holder) | centre = pos + offset. Calls the level explosion with: causing entity = the affected entity if `attribute_to_user` else none; a damage calculator that allows block damage when `block_interaction` is not `none`, uses the custom damage type when `damage_type` is present, scales knockback by `knockback_multiplier(L)` when present, and spares `immune_blocks`; radius = max(radius(L), 0); then fire, interaction, particles and sound as given. The explosion algorithm itself is not in this document (GAP: world simulation) |
| `ignite` | `duration` | `entity.igniteForSeconds(duration(L))` (seconds, float) |
| `apply_impulse` | `direction` (Vec3), `coordinate_scale` (Vec3), `magnitude` (level-based) | v = rotate(direction by the entity's look quaternion) multiplied component-wise by `coordinate_scale`, then by magnitude(L); entity delta movement += v. For a server player: send Set Entity Motion (05a) and clear the entity's "sync velocity" flag; for other entities set the flag so the normal entity sync sends it. Living entities then start a 10-tick post-impulse grace time (fall-damage and similar context resets are deferred 10 ticks) |
| `apply_exhaustion` | `amount` | players only: `causeFoodExhaustion(amount(L))` (17 section 4.9) |
| `play_sound` | `sound`: one sound event or a list (compact form: a bare string is a one-element list; the list is size-limited to 255 entries), `volume`, `pitch`: float providers; volume is bounded to 1.0E-5 .. 10.0, pitch has only the 1.0E-5 minimum and no maximum | not when the entity is silent. index = clamp(L - 1, 0, count - 1) (so a list of three sounds is selected by level, 1 to 3, and the last is used above); plays at pos, in the entity's sound source category, volume and pitch sampled from the entity's random |
| `replace_block` | `offset` (Vec3i, 0), `predicate` (optional block predicate), `block_state` (block state provider), `trigger_game_event` (optional game event) | p = block position containing pos, plus offset. If the predicate is absent or passes at (level, p): set the state `provider.getState(entity random, p)` with block update; if the set succeeded and an event is named, emit that game event at p with the entity as source |
| `replace_disk` | `radius`, `height` (level-based), `offset` (Vec3i, 0), `predicate` (optional), `block_state` (provider), `trigger_game_event` (optional) | c = block position containing pos plus offset; r = (int) radius(L); h = (int) height(L). The set of cells is the box between c + (-r, 0, -r) and c + (r, min(h - 1, 0), r) (corners in either order; for h of 1 or more it is the single layer at c's Y; see Open question 5). A cell qualifies when the horizontal distance squared from the **pos** (not from c) x and z to the cell's centre column is less than r squared (the vertical term is zero: the y used is the cell's own y plus 0.5), and the predicate (if any) passes at that cell; qualifying cells get the same set-and-event step as `replace_block`. Cells are visited in `betweenClosed` order |
| `run_function` | `function` (identifier) | looks up the function; when present runs it as a command source: the server's command source with permission level gamemaster, output suppressed, entity = the affected entity, level, position = pos, rotation = the entity's rotation vector; when the function does not exist, logs an error "Enchantment run_function effect failed for non-existent function {}" and does nothing |
| `set_block_properties` | `properties` (block state properties map, as in the `block_state` item component), `offset` (Vec3i, 0), `trigger_game_event` (optional) | p = block position containing pos plus offset; new state = the current state with the properties applied; when it differs from the current state: set with block update and emit the event as in `replace_block` |
| `spawn_particles` | `particle`, `horizontal_position`, `vertical_position` (position sources), `horizontal_velocity`, `vertical_velocity` (velocity sources), `speed` (float provider, constant 0) | see 6.4 |
| `summon_entity` | `entity` (holder set of entity types), `join_team` (bool, false) | not when the block position containing pos is outside spawnable bounds. Pick one type at random from the set using the level's random (empty: nothing); spawn it with spawn reason `triggered` at the block position; if the new entity is a lightning bolt and the enchanted item's owner is a server player, record the player as the cause; if `join_team` and the affected entity is on a team, add the new entity to that team; finally move the new entity to pos with the affected entity's yaw and pitch (the roles of the last step are read from the call order and marked inferred) |

### 6.2 Location-based effect types

The sixteen types of 6 above, with the entity types behaving as in 6.1 and with their `apply` run once per activation (section 10). The additional type:

### 6.3 `attribute` (`EnchantmentAttributeEffect`; also the element type of the `attributes` component)

| Field | Type | Meaning |
|---|---|---|
| `id` | identifier | base modifier id |
| `attribute` | attribute holder | the attribute modified |
| `amount` | level-based | modifier amount |
| `operation` | `add_value`, `add_multiplied_base` or `add_multiplied_total` | how the amount combines (attribute formula in 17 section 1.5 and 04) |

The modifier created for equipment slot S has the identifier `id` + "/" + S's serialized name (`mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`) and amount `amount(L)`. As a location-based effect: on activation the modifiers are added to the living entity's attribute map as **transient** modifiers (not saved), for the slot in which the item sits; on deactivation they are removed by the same identifiers. As the `attributes` component: `EnchantmentHelper.forEachModifier` (H25) reports (attribute, modifier) pairs for an item and a slot or slot group; the item attribute-modifier machinery (13, 17 section 1.5) applies them like item attribute modifiers. A slot filter applies: an effect counts when the enchantment is active in that slot (7.4).

### 6.4 `spawn_particles` position and velocity sources

All of the following was read from `SpawnParticlesEffect` and its `PositionSource` / `PositionSourceType` / `VelocitySource` members.

- Position source `{type, offset (float, 0), scale (positive float, 1)}`; `type` is `entity_position` or `in_bounding_box`. Per axis the coordinate is: type(coordinate source)(arg1 = the entity's position on that axis, arg2 = the centre on that axis, arg3 = extent x scale, random) + offset. `entity_position` returns arg1; `in_bounding_box` returns centre + (nextDouble - 0.5) x (extent x scale). Centres: x = entity x, y = entity y + height / 2, z = entity z. Extents: the entity's bounding box width for x and z, its height for y. Constraint at decode: an `entity_position` source with a scale other than 1 is rejected ("Cannot scale an entity position coordinate source").
- Velocity source `{movement_scale (float, 0), base (float provider, 0)}`: component = the entity's known movement on that axis x movement_scale + sample(base). The horizontal source serves x and z, the vertical source serves y.
- The particle is sent to nearby clients with count 0 and the three velocity components and `speed` sampled once (the standard "directional particle" form, 05a Level Particles). Draws on the entity's random, in order: x position, y position, z position, velocity x (horizontal source), velocity y (vertical source), velocity z (horizontal source), then one `speed` sample.

---

## 7. Requirements: loot contexts

Requirements are ordinary loot conditions ([26](26-loot-and-predicates.md) section 8 gives the grammar and the condition list, section 10 the predicates; 26 section 3.2 lists the same parameter sets as the table below and 26 section 8.1 repeats the level-based value forms). What this document adds is the **parameters each hook supplies**.

### 7.1 Context key sets (`LootContextParamSets`)

| Set | Used by components | Parameters present |
|---|---|---|
| ITEM (`enchanted_item`) | `item_damage`, `ammo_use`, `projectile_piercing`, `block_experience`, `repair_with_xp` | `tool` (the item stack), `enchantment_level` |
| ENTITY (`enchanted_entity`) | `tick`, `projectile_spawned`, `projectile_spread`, `projectile_count`, `trident_return_acceleration`, `fishing_time_reduction`, `fishing_luck_bonus`, `mob_experience` | `this_entity`, `enchantment_level`, `origin` |
| LOCATION (`enchanted_location`) | `location_changed` | `this_entity`, `enchantment_level`, `origin`, `enchantment_active` (bool) |
| DAMAGE (`enchanted_damage`) | `damage_protection`, `damage_immunity`, `damage`, `smash_damage_per_fallen_block`, `knockback`, `armor_effectiveness`, `post_attack`, `post_piercing_attack`, `equipment_drops` | `this_entity` (the **victim**), `enchantment_level`, `origin` (the victim's position), `damage_source`; optional `attacking_entity` (the source's causing entity) and `direct_attacking_entity` (the source's direct entity) |
| HIT_BLOCK | `hit_block` | `this_entity`, `enchantment_level`, `origin` (the hit location), `block_state` |

(`enchanted_damage` and the others are the names the artifact's sets are given in data pack documents; the parameter lists were read from the context builders in `Enchantment`.) The conditions the shipped data uses on these sets include `match_tool` (reads `tool`), `damage_source_properties`, `entity_properties` with `entity` = `this`, `attacker` or `direct_attacker`, `random_chance` with the `enchantment_level` number provider as chance, `all_of`, `inverted`, `any_of`, `weather_check` and `location_check`; and `enchantment_active_check` (field `active`, a boolean; it reads the `enchantment_active` parameter of the LOCATION set and Soul Speed uses it twice; see 26 section 3.1 and section 8). Inside `location_check` and `entity_properties` the shipped data uses the block, fluid and location predicates of 26 section 10 (for example the `movement_affected_by` block predicate with a block tag). The semantics of every condition are in 26, not repeated here.

### 7.2 Context construction

A context is built per (enchantment, level, hook evaluation), never cached. No random sequence identifier is passed (an empty optional), so the context uses the level's random (conditions that need randomness, `random_chance`, draw from the **level's** random, in condition evaluation order, so a `random_chance` condition consumes level-random draws; value effects consume the hook's own random, 8.3).

### 7.3 Interaction of requirements and levels

The enchantment level reaches predicates only via the `enchantment_level` number provider (as in Thorns: chance = 0.15 + 0.15 x (L - 1)). A requirement is evaluated once per conditional effect per enchantment per hook call, in list order, **before** the effect runs, and a failing requirement skips only that one effect.

### 7.4 Slot activity

An enchantment is "active" in an equipment slot when the slot is in the enchantment's `slots` set (04, `slots` groups: `any`, `mainhand`, `offhand`, `hand`, `feet`, `legs`, `chest`, `head`, `armor`, `body`, `saddle`; `any` matches every slot; `armor` is feet, legs, chest and head; `hand` is mainhand and offhand) (`Enchantment.matchingSlot`). Slot-aware iterations (8.2) skip enchantments that are not active in the item's slot; item-only iterations ignore slots.

---

## 8. The engine: how levels, enchantments and effects combine

### 8.1 Where the levels come from

`EnchantmentHelper` reads `item.enchantments` (the `enchantments` data component, an `ItemEnchantments` map from enchantment to level) of a stack. The `stored_enchantments` component (books) is never iterated. `getItemEnchantmentLevel(enchantment, item)` returns that map's level, 0 when absent. `getEnchantmentLevel(enchantment, entity)` is the maximum of `getItemEnchantmentLevel` over the items in the slots where the enchantment is active (`Enchantment.getSlotItems`: for each slot in the equipment slot enum order mainhand, offhand, feet, legs, chest, head, body, saddle whose group matches, the non-empty item). `getHighestLevel(item, componentType)` scans the item's enchantments and returns the effect value and level of the **highest-level** enchantment that defines the component (ties: the first found; the scan order is the map order). When no enchantment on the stack defines the component the result is null (no value, no level).

### 8.2 Iteration modes

| Mode | Used by | What is visited |
|---|---|---|
| item only | stack-level hooks (`damage` on the weapon, `item_damage`, ammo, piercing, projectile count and spread, block experience, trident, crossbow, fishing, repair) and two hooks whose `EnchantedItemInUse` still carries a slot or owner: `hit_block` (the slot, when given, is only stored in the record; no `matchingSlot` filter) and `projectile_spawned` (null slot, owner = the projectile's owner when it is a living entity, else null; no living owner required) | every enchantment on the one given stack, in the map's iteration order, with its level; no slot test |
| item in slot | `runIterationOnItem` with slot and owner: `post_attack` on the attacker's `mainhand` weapon, `post_piercing_attack` on `mainhand`, location changes of one item, and the per-slot passes of equipment mode | enchantments on the stack that are active in the given slot |
| equipment | `damage_protection`, `damage_immunity`, `tick`, `location_changed`, `equipment_drops`, `mob_experience`, post-attack on the victim | for each slot of the equipment slot enum in order mainhand, offhand, feet, legs, chest, head, body, saddle: the item in the slot, then the item-in-slot mode for it |

An enchanted item in the wrong slot (a helmet in the main hand) therefore contributes nothing to an equipment iteration, but still counts in an item-only iteration.

### 8.3 Combining values

Each value hook starts from a float (the incoming base value) held in a mutable cell and visits (enchantment, level) pairs; for each pair it takes the list of effects of its component type, and for each conditional effect in list order that matches, replaces the cell by `process(level, random, cell)`. Consequently:

- Effects **fold** in the visit order: enchantment visit order (the iteration order of the item's enchantment map, which is hash order and is **not** specified by the data; Open question 6), then list order within an enchantment.
- `add` effects commute with each other, but `add` and `multiply`/`set`/`exponential` do not; vanilla data uses one kind per component (sum for damage, protection, count; `multiply` only on `repair_with_xp`; `set` on `ammo_use`, `block_experience`), so the order is only observable in packs that mix kinds.
- The **random source** passed to `process`: for item-only hooks (`item_damage`, `ammo_use`, `projectile_piercing`, `block_experience`, `repair_with_xp`) the **level's** random; for entity-context hooks (`damage_protection`, `damage`, `smash_damage_per_fallen_block`, `knockback`, `armor_effectiveness`, `projectile_*`, `trident_return_acceleration`, `fishing_*`, `mob_experience`, `equipment_drops`) the **enchanted-from entity's** random (victim for damage-set hooks; the shooter or fisher for the rest); for the two single-value components (`crossbow_charge_time`, `trident_spin_attack_strength`) the wielder's random.
- The final value is clamped or truncated by the helper (the table in section 9). Truncation is a float-to-int cast (toward zero).

`damage_immunity` is not folded: the damage is ignored when **any** matching conditional effect of any equipped enchantment exists (a boolean OR; the `damage_immunity` effect object carries no data). `prevent_equipment_drop` and `prevent_armor_change` are likewise boolean presence tests (`has`).

Entity effects (post attack, post piercing attack, hit block, tick, projectile spawned) are not folded: each matching effect applies, in the same visit order, with side effects.

### 8.4 `pickHighestLevel`

For list-valued components that are not effects (`crossbow_charging_sounds`, `trident_sound`), the engine takes the list of the highest-level enchantment that defines the component and returns the element at index min(level, size) - 1 (so a three-element sound list is picked by level 1 to 3, the last element beyond). When no enchantment defines the component the result is empty and the caller supplies its own default: `CrossbowItem` falls back to its built-in default charging-sound set (H27) and `TridentItem.releaseUsing` to the trident throw sound (H28). Constants, all read: `CrossbowItem.DEFAULT_SOUNDS` = start `item.crossbow.loading_start`, mid `item.crossbow.loading_middle`, end `item.crossbow.loading_end`; the default of `TridentItem.releaseUsing` when no `trident_sound` is present is `item.trident.throw`. Shipped data: Quick Charge's `crossbow_charging_sounds` has three entries (levels 1 to 3) with start `item.crossbow.quick_charge_1`, `_2`, `_3` and end `item.crossbow.loading_end` in each (no mid); Riptide's `trident_sound` list is `item.trident.riptide_1`, `_2`, `_3`.

---

## 9. Hook points

"Initial" is the value the hook starts from; "Result" is the clamp or conversion. Class and method names are where the call was read (`EnchantmentHelper.<method>`). Each row is evaluated server side only (a `ServerLevel` is required). 17 sections 4 to 6 give the surrounding arithmetic.

| Id | Component | Helper method | Called from | Initial -> result |
|---|---|---|---|---|
| H1 | `damage_protection` | `getDamageProtection(level, living, source)` (equipment mode) | `LivingEntity.getDamageAfterMagicAbsorb` | 0 -> sum P, used as damage x (1 - clamp(P, 0, 20) / 25) (17 section 6.4) |
| H2 | `damage_immunity` | `isImmuneToDamage(level, living, source)` (equipment mode) | `LivingEntity.isInvulnerableTo` | false -> true if any match |
| H3 | `damage` | `modifyDamage(level, weapon, victim, source, damage)` (item only) | `ServerPlayer.getEnchantedDamage` (players), `Mob.doHurtTarget`, `LivingEntity.stabAttack`, `AbstractArrow.onHitEntity`, `ThrownTrident.onHitEntity` | base damage -> the folded value (not clamped) |
| H4 | `smash_damage_per_fallen_block` | `modifyFallBasedDamage(...)` | `MaceItem.getAttackDamageBonus` | base bonus per block -> value |
| H5 | `knockback` | `modifyKnockback(level, weapon, victim, source, knockback)` | `LivingEntity.getKnockback`, `AbstractArrow.doKnockback` | base -> value |
| H6 | `armor_effectiveness` | `modifyArmorEffectiveness(level, item, victim, source, effectiveness)` | `CombatRules.getDamageAfterAbsorb` | base effectiveness -> value |
| H7 | `post_attack` | `doPostAttackEffects(level, victim, source)`, `doPostAttackEffectsWithItemSource`, `...OnBreak` | `Player.itemAttackInteraction`, `Player.doSweepAttack`, `Mob.doHurtTarget`, `LivingEntity.stabAttack`, `AbstractArrow.onHitEntity`, `ThrownTrident.onHitEntity`, and the special attackers: `IronGolem`, `Bee`, `EnderDragon`, `ChargeAttack`, `RamTarget`, `HoglinBase`, `AbstractCubeMob`, `EvokerFangs`, `LargeFireball`, `SmallFireball`, `WitherSkull`, `ShulkerBullet`, `LlamaSpit`, `AbstractWindCharge` | see 9.1 |
| H8 | `post_piercing_attack` | `doPostPiercingAttackEffects(level, living)` | `LivingEntity.postPiercingAttack` | runs on the living entity's weapon in `mainhand` (9.2) |
| H9 | `hit_block` | `onHitBlock(level, item, owner, entity, slot, position, state, onBreak)` | `ServerPlayerGameMode.handleBlockBreakAction`, `AbstractArrow` and `ThrownTrident` (`hitBlockEnchantmentEffects`) | position = the hit location |
| H10 | `item_damage` | `processDurabilityChange(level, stack, amount)` | `ItemStack.processDurabilityChange` (called from `hurtAndBreak`) | amount -> (int) value; skipped (0) when the stack is not damageable or the player has infinite materials; applied only when amount is positive; amounts of 0 or less are returned unchanged |
| H11 | `equipment_drops` | `processEquipmentDropChance(level, mob, source, chance)` | `Mob.dropCustomDeathLoot` | see 9.3 |
| H12 | `location_changed` | `runLocationChangedEffects(level, living)` and the one-item variant | `LivingEntity.onChangedBlock`, `LivingEntity.collectEquipmentChanges`, `ServerPlayer.setGameMode` | state machine of section 10 |
| H13 | `tick` | `tickEffects(level, living)` (equipment mode) | `LivingEntity.baseTick` | each tick, once per enchanted item active in its slot |
| H14 | `ammo_use` | `processAmmoUse(level, weapon, ammo, count)` | `ProjectileWeaponItem.useAmmo` (called by `draw`) | initial 1 -> (int) value, no clamp (Infinity sets 0); skipped (0 consumed) for any living entity whose `hasInfiniteMaterials` is true, and for every projectile after the first; see 9.5 |
| H15 | `projectile_piercing` | `getPiercingCount(level, weapon, ammo)` | `AbstractArrow` constructor | initial 0.0; the base pierce level of the arrow is **not** an input (the ammo stack argument only reaches the loot context) -> max(0, (int) value). The `AbstractArrow` constructor sets the arrow's pierce level (narrowed to a byte) only when the result is greater than 0; when it is 0 the arrow's own pierce level is left untouched |
| H16 | `projectile_spawned` | `onProjectileSpawned(level, weapon, projectile, onBreak)` | `Projectile.applyOnProjectileSpawned` | item-only iteration of the one stack, no slot test; runs for any projectile (a living owner is not required); the `EnchantedItemInUse` has a null slot, owner = the projectile's owner if living else null, and the `onBreak` callback; effect target = the projectile at its position. Second pass: `Projectile.applyOnProjectileSpawned` runs the helper again on an `AbstractArrow`'s own weapon item when that stack is non-empty and its `Item` differs from the stack passed in |
| H17 | `projectile_spread` | `processProjectileSpread(level, weapon, shooter, spread)` | `ProjectileWeaponItem.shoot` | initial 0.0 -> max(0.0, value) (degrees) |
| H18 | `projectile_count` | `processProjectileCount(level, weapon, shooter, count)` | `ProjectileWeaponItem.draw` | initial 1 -> max(0, (int) value); the result is the number of `useAmmo` iterations in 9.5 |
| H19 | `trident_return_acceleration` | `getTridentReturnToOwnerAcceleration` | `ThrownTrident.getLoyaltyFromItem` | initial 0 -> max(0, (int) value) |
| H20 | `fishing_time_reduction` | `getFishingTimeReduction(level, rod, entity)` | `FishingRodItem.use` | 0.0 -> max(0.0, value) seconds |
| H21 | `fishing_luck_bonus` | `getFishingLuckBonus` | `FishingRodItem.use` | 0 -> max(0, (int) value) |
| H22 | `block_experience` | `processBlockExperience(level, tool, xp)` | `Block.tryDropExperience` | xp sampled from the block's int provider -> (int) value, no clamp; xp is popped only if the result is positive |
| H23 | `mob_experience` | `processMobExperience(level, killer, mob, xp)` (equipment mode, on the killer when it is a living entity) | `LivingEntity.getExperienceReward` | xp -> (int) value |
| H24 | `repair_with_xp` | `modifyDurabilityToRepairFromXp(level, item, xp)` and `getRandomItemWith` | `ExperienceOrb.repairPlayerItems` | see 9.4 |
| H25 | `attributes` | `forEachModifier(stack, slot or slot group, consumer)` | `ItemStack.forEachModifier` | modifiers reported for a slot or group, 6.3 |
| H26 | `crossbow_charge_time` | `modifyCrossbowChargingTime(stack, living, time)` | `CrossbowItem.getChargeDuration` | initial 1.25 (seconds) -> max(0.0, value); duration ticks = floor(value x 20) |
| H27 | `crossbow_charging_sounds` | `pickHighestLevel` | `CrossbowItem.getChargingSounds` | 8.4 |
| H28 | `trident_sound` | `pickHighestLevel` | `TridentItem.releaseUsing` | 8.4 (default the trident throw sound when none) |
| H29 | `prevent_equipment_drop` | `has(stack, type)` | `Mob.dropCustomDeathLoot`, `AbstractHorse`, `Allay`, `ArmorStand` drop code, `Player.destroyVanishingCursedItems` | boolean |
| H30 | `prevent_armor_change` | `has` | `ArmorSlot.mayPickup`, `Equippable.swapWithEquipmentSlot`, `Mob.compareArmor`, `Mob.attemptToShearEquipment`, `Piglin.canReplaceCurrentItem`, `ZombieVillager` conversion | boolean |
| H31 | `trident_spin_attack_strength` | `getTridentSpinAttackStrength(stack, living)` | `TridentItem.use`, `TridentItem.releaseUsing` | initial 0.0 -> value, no clamp; the item is a riptide trident when the component is present (`has`) |

Other consumers of enchantment levels that do not use effect components (loot functions and conditions, which read levels through `getItemEnchantmentLevel` or `getEnchantmentLevel`): `ApplyBonusCount`, `EnchantedCountIncreaseFunction`, `BonusLevelTableCondition`, `LootItemRandomChanceWithEnchantedBonusCondition`; the anvil, grindstone, repair recipe and enchanting table menus; the `/enchant` command; `BeehiveBlock`, `DecoratedPotBlock`, `IceBlock`, `InfestedBlock` tag checks (`hasTag(item, tag)` on enchantment tags such as the silk-touch-like tag; the tag names are data); `SkeletonTrapGoal`, `Pillager`, `Vindicator`, `Enderman` and `Mob.enchantSpawnedEquipment` apply enchantments from enchantment providers (`enchantItemFromProvider`, a data registry `enchantment_provider` with types `by_cost`, `by_cost_with_difficulty`, `single`).

### 9.1 `post_attack` (H7) in detail

`doPostAttackEffectsWithItemSourceOnBreak(level, victim, source, weapon, onBreak)`:

1. If the victim is a living entity: visit the victim's **equipment** (all slots, slot-active enchantments only); each enchantment's `post_attack` list is filtered to the entries whose `enchanted` is `victim`.
2. Then, only if a weapon stack is given (non-null) and the source's causing entity (the attacker) is a living entity: visit the weapon in slot `mainhand` with the attacker as owner (slot-active enchantments only); entries whose `enchanted` is `attacker` are considered.
3. Otherwise (a weapon is given, the attacker is **not** a living entity), and only when `onBreak` is supplied (the thrown trident case): visit the weapon item-only, with no slot filter, with a null slot and a null owner in the `EnchantedItemInUse` and the `onBreak` callback attached; entries whose `enchanted` is `attacker` are considered (the same target as step 2). Step 3 is the alternative to step 2, never an additional pass over the same weapon. If the attacker is not living and `onBreak` is null, nothing runs for the weapon.

For each considered entry the effect runs when its `requirements` pass in a DAMAGE context built with `this_entity` = victim; the effect is then applied at the **affected** entity's position, where `affected` resolves as in 3.2. The `enchanted` target `damaging_entity` is accepted by the codec but no helper step passes it as the enchanted side, so such an entry never runs (inferred from the three steps; steps 2 and 3 both pass `attacker`, step 1 passes `victim`).
`doPostAttackEffects(level, victim, source)` (no explicit weapon): when the attacker is a living entity it uses its `getWeaponItem` (its main-hand-derived weapon); otherwise it runs steps with no weapon (step 1 only).

### 9.2 `post_piercing_attack` (H8)

The living entity's weapon in `mainhand`: its enchantments' `post_piercing_attack` effects are filtered by requirements in an ENTITY-position context built from the **piercing entity's own position**; the effect applies to the piercing entity (entity = owner = the wielder). Lunge (17 section 6.3) uses this. Because the context is built by `Enchantment.entityContext` while the component is validated against the DAMAGE set (2.2, notes), a requirement reading the damage source or the attacker parameters is accepted at load and cannot match at run time.

### 9.3 `equipment_drops` (H11)

Input: the mob's current drop chance for a slot (float, from the mob's drop chances). Output float chance. Two passes over the same mutable value, the first visits the **victim's** equipment and applies entries whose `enchanted` and `affected` are both `victim`; the second runs only when the source's attacker is a living entity and visits the **attacker's** equipment, applying entries with `enchanted` = `attacker` (and `affected` = `victim`). Each application folds `process(level, victim random, value)`. The result chance is compared with a `nextFloat` by the caller (`Mob.dropCustomDeathLoot`), after it has already skipped slots whose item is empty or carries `prevent_equipment_drop`; the caller also rolls a random durability loss for damaged drops (not an enchantment matter).

### 9.4 `repair_with_xp` (H24, Mending)

`ExperienceOrb.repairPlayerItems(player, xp)`:
1. Build the candidate list: for each slot in the equipment slot enum order, take the item; keep it only if it passes the predicate `ItemStack.isDamaged` (read: the item is damageable and its damage value is greater than 0). For each kept item, add **one candidate per enchantment on the item that defines `repair_with_xp` and is active in that slot** (the enchantment loop sits inside the slot loop). An item that carries two enchantments defining `repair_with_xp` therefore appears twice and is twice as likely in the pick. Choose one candidate uniformly with the player's random (`Util.getRandomSafe`). No candidate: return xp unchanged.
2. durability = modifyDurabilityToRepairFromXp(item, xp): initial float(xp), folded, result max(0, (int) value). For Mending this is xp x 2 (its `multiply` factor 2.0).
3. repaired = min(durability, item damage); item damage -= repaired (the damage is set even when repaired is 0).
4. If repaired <= 0 (the item had no damage or durability came out as 0): all the xp counts as consumed and the method returns 0. Otherwise remaining xp = xp - (repaired x xp) / durability (int multiply then int divide); if remaining <= 0 return 0; else repeat from step 1 with the remaining xp and return that call's result. The return value is thus the xp left over after the whole chain: the unchanged xp only when step 1 found no candidate, otherwise 0 or whatever a later pass found no candidate for.

### 9.5 Ammunition draw and shot (H14, H18, with H17)

Read from `ProjectileWeaponItem.draw`, `useAmmo` and `shoot`:

1. `draw(weapon, ammo, shooter)`: an empty ammo stack gives an empty list. Otherwise count = `projectile_count` result (H18; 1 when not on a server level). A copy of the weapon is made once.
2. For i = 0 .. count - 1, one `useAmmo(weapon_i, ammo, shooter, extra = i > 0)` call, where weapon_0 is the real weapon and weapon_i for i > 0 is the copy. Each non-empty result is appended to the list.
3. `useAmmo`: the number to consume, use, is `ammo_use` (H14, initial 1) unless `extra` is true or the shooter's `hasInfiniteMaterials` is true (any living entity, not only players) or the level is not a server level, in which case use = 0. So only the first projectile consumes ammunition.
4. If use is greater than the ammo stack count: the result is an empty stack (no projectile). If use is 0: the result is a copy of the ammo with count 1 and the `intangible_projectile` component set (such a projectile is not pickable). Otherwise the result is `ammo.split(use)`; when that empties the ammo stack and the shooter is a Player, the stack is removed from the inventory.
5. `shoot`: for each non-empty projectile of the list, in list order, the projectile is created, spawned (which runs `applyOnProjectileSpawned`, H16) and `hurtAndBreak(getDurabilityUse(projectile), ...)` is applied to the weapon in the hand's slot (`getDurabilityUse` returns 1 for the base class; subclasses may override, not read here); the loop stops when the weapon stack is empty.

---


## 10. Location-based activation (`location_changed`)

`LivingEntity` keeps `activeLocationDependentEnchantments`: equipment slot -> (enchantment -> set of the effect instances currently active). `activeLocationDependentEnchantments(slot)` returns the per-slot map, which `Enchantment.runLocationChangedEffects` indexes by the enchantment itself. The set is an array-backed set (membership by the set's own equality test; the identity claim of earlier drafts was not verified). `runLocationChangedEffects(level, enchLevel, itemInUse, entity)` for one enchantment and its item and slot:

1. If the item-in-use's slot is null: return at once; nothing is removed or deactivated. If the slot is set but the enchantment is **not** active in it (`matchingSlot` false): remove only **this enchantment's** entry from the slot's map; for every effect instance in the removed set call `onDeactivated(itemInUse, entity, entity position, level)`; stop. Other enchantments' entries in the slot are untouched.
2. Otherwise fetch this enchantment's set (may be absent). For each conditional effect in the enchantment's `location_changed` list: wasActive = the effect is in the set. Build a LOCATION context with `enchantment_active` = wasActive. If `matches`: if not wasActive, create the set if needed (storing it in the slot's map under this enchantment) and add the effect; call `effect.onChangedBlock(level, enchLevel, itemInUse, entity, entity position, newlyActive = not wasActive)`. If it does not match and wasActive: remove it from the set and call `onDeactivated(itemInUse, entity, position, enchLevel)`.
3. If this enchantment's set exists and is empty afterwards, remove this enchantment's entry from the slot's map (only that entry).

When it runs: `LivingEntity.onChangedBlock` (the entity moved to a different block position) runs every equipped item; `collectEquipmentChanges` runs it for the single item of a slot whose stack changed (and `stopLocationBasedEffects` for the slot whose item left); `ServerPlayer.setGameMode` runs or stops all location effects when the game mode changes (spectator stops them); `LivingEntity.stopLocationBasedEffects` calls `onDeactivated` for every active effect and clears the map (entity removal). Consequently `entity position` is the position at the time of the callback, and the `enchantment_active` condition parameter lets a pack distinguish "just stepped" from "was already active" (Frost Walker and Soul Speed in 17 section 6.3 rely on it, together with the `attribute` modifiers which are transient and removed on deactivation).

---

## 11. Worked examples

1. **Protection IV helmet vs a creeper explosion**: the helmet's `damage_protection` entry is `add` linear(1.0, 1.0): L = 4 gives 4.0; its requirement `damage_source_properties` tag `bypasses_invulnerability` expected false passes. With four such pieces, folded P = 16.0; damage 10 -> 10 x (1 - 16/25) = 3.6.
2. **Sharpness V iron sword vs a zombie**: base damage d from the attack steps (17 section 4.2); the `damage` list has one `add` linear(1.0, 0.5); L = 5 gives +3.0, so d + 3.0 (before the critical and cooldown steps defined in 17).
3. **Unbreaking III non-armor, 10 points**: 5.2 example 1 (result 4).
4. **Unbreaking III on armor**: armor entry applies (requirement matches `tool` in the armor tag), chance 0.3: for n = 10 and draws 0.1, 0.5, 0.9, 0.2, 0.7, 0.35, 0.29, 0.99, 0.0, 0.45, those below 0.3 are 0.1, 0.2, 0.29, 0.0, so k = 4, result 6. Neither requirement consumes random draws, because `match_tool` and `inverted` read only the `tool` parameter, so the non-armor entry (whose `inverted` requirement fails) skips without touching either random source.
5. **Mending**: 9.4: xp 5 on an item with 4 damage: durability 10, repaired 4, remaining = 5 - (4 x 5) / 10 = 3, next item or 3 returned.
6. **Thorns II** on a chestplate hit by a zombie: `post_attack` entry, `enchanted` victim, `affected` attacker, requirement `random_chance` with chance linear(0.15, 0.15): L = 2 gives 0.30. When it passes (one draw of the level random), the `all_of` runs `damage_entity` (thorns damage type, uniform 1 to 5 using the **zombie's** random, causing entity = the chestplate's wearer) and `change_item_damage` 2 on the chestplate.
7. **Multishot spread, three arrows** (projectile hooks): count = max(0, 1 + 2) = 3 for L = 1 (`projectile_count` add 2 L per 17 section 6.3); spread S = max(0, 0 + 10 L) = 10 degrees (the data value in 17); step = 2 x S / (n - 1) = 10; start = ((n - 1) mod 2) x step / 2 = 0; arrow i (0-based, empty stacks skipped) gets angle start + sign x ((i + 1) / 2, integer division) x step with sign +1 for the first and alternating afterwards: arrow 0: 0 + 1 x 0 x 10 = 0 (the centre), arrow 1: sign -1, (2/2) = 1: -10, arrow 2: sign +1, (3/2) = 1: +10. For n = 1 the step is 0. The arrows spawn in list order (`ProjectileWeaponItem.shoot`, `draw`).
8. **Frost Walker activation**: `location_changed` entry with the `enchantment_active` conditions: first step onto water sets the effect active (newlyActive true), replace_disk radius clamp(3 + (L - 1), 0, 16) etc. (17); stepping away with the condition failing calls `onDeactivated` (nothing for replace_disk).

---

## 12. Validation (checks an implementation passes)

1. Decode each of the 43 shipped enchantments' `effects` Compound without error and re-encode to an equal map. Key set must be a subset of the 31 keys of 2.2.
2. Unit tests for each level-based type with the table of 4.3 (all values exactly as stated, in single precision).
3. `remove_binomial` with a scripted random: the 10 draws of 5.2 example 1 give 4.0; n = 130, p = 0.1 consumes 130 draws; n = 1000, p = 0.3 with Gaussian 0.5 gives 693.
4. A value hook with two matching entries folds in list order: `add 1` then `multiply 2` on input 3 gives 8; reversed gives 7.
5. Requirement failure skips only its own entry and consumes no value-effect random; a `random_chance` requirement consumes the level random.
6. Equipment iteration ignores an enchanted helmet held in the main hand; the item-only iteration does not.
7. Location activation: stepping onto a matching block calls `onChangedBlock` with newlyActive true once; staying (same block position not re-evaluated) no call; a second evaluation with the condition still true calls with newlyActive false; leaving calls `onDeactivated` once; removing the item calls it for every active effect.
8. `apply_mob_effect`: order of draws (set pick, duration, amplifier) and clamping of the amplifier at 0.
9. Hook table: every H row has a test that the helper is called from each listed place (stubs).
10. The clamped type rejects max <= min (min = max fails with "Max must be larger than min"); a requirement using a parameter outside the component's set is reported by validation (that this rejects the whole enchantment is (inferred), Open question 16).

---

## 13. Related definition fields and item components (read, not engine)

Read from the codecs and accessors of `net.minecraft.world.item.enchantment.*`; the numbers fed to the enchanting table and anvil are in 17 section 6.5.

| Item | Read facts |
|---|---|
| `Enchantment` definition fields | `description` (text), `exclusive_set` (optional holder set of enchantments), `effects` (section 2), and, flat in the same top-level object (the shipped `data/minecraft/enchantment/*.json` files have no `definition` key), `supported_items` (holder set of items, required), `primary_items` (optional holder set), `weight` (int 1 to 1024), `max_level` (int 1 to 255), `min_cost` and `max_cost` (cost objects), `anvil_cost` (a non-negative int), `slots` (list of equipment slot groups, 7.4). The shipped files read (for example Quick Charge, Riptide, Soul Speed) list exactly the keys `description`, `exclusive_set`, `effects`, `supported_items`, `primary_items`, `weight`, `max_level`, `min_cost`, `max_cost`, `anvil_cost`, `slots` at the top level. |
| Cost object | `base` (int), `per_level_above_first` (int); value at level L = base + per_level_above_first x (L - 1) (int arithmetic) |
| `EnchantmentInstance` | pair (enchantment holder, int level); exposes the enchantment's `weight` for weighted picks |
| `ItemEnchantments` | data component `enchantments`: map from enchantment to int level, persistent level range 1 to 255 (a level outside it fails to decode); backed by a hash map (the iteration order of 8.3); network form is a map with VarInt levels |
| `Enchantable` item component | one field `value` (a positive int); network form carries it as the same single int |
| `Repairable` item component | one field `items` (holder set of items usable to repair) |

---

## Open questions

1. The `constant` type name: only the bare-number form of a constant is accepted in this artifact (inferred from the registry bootstrap and the absence of any `constant` registration); a data pack written as `{"type": "minecraft:constant"}` is expected to fail, not verified by decoding.
2. Numeric registry ids of the six enchantment type registries (`enchantment_effect_component_type`, `enchantment_entity_effect_type`, `enchantment_level_based_value_type`, `enchantment_location_based_effect_type`, `enchantment_value_effect_type` and `enchantment_provider_type`; sections 2 to 6 use the first five, the sixth is named in section 9's provider remark) and of the 31 component types are registration order (inferred); they matter only if a registry-sync consumer ever sends them, and 04 shows keys, not ids.
3. `spawn_particles`: resolved; the argument roles and draw order were read (6.4). Nothing remains open.
4. `summon_entity`: whose yaw and pitch the new entity receives and which entity's team is joined are inferred from call order (the affected entity in both cases).
5. `replace_disk`: the vertical extent is `min(h - 1, 0)` as read, which is 0 for every h of 1 or more (a single layer) and negative or zero otherwise; whether this is intended is not known. The shipped Frost Walker uses height 1.
6. Iteration order over an item's enchantments is the order of a hash map in the artifact (`ItemEnchantments`); it determines the fold order when two enchantments touch the same component with non-commuting effects. Vanilla data never does; the order was not traced further (a deterministic choice, such as registry id order, is acceptable for the standard world type).
7. Resolved in this round: the `repair_with_xp` candidate predicate is `ItemStack.isDamaged` (damageable and damage > 0), read from the call site in `ExperienceOrb.repairPlayerItems`; the duplicate-candidate weighting is in 9.4. `ItemStack.isDamageableItem` was read: true when the stack has the `max_damage` component, does not have `unbreakable`, and has the `damage` component; `isDamaged` = that and damage value > 0 (default 0). The `change_item_damage` effect separately requires both `max_damage` and `damage`. Nothing remains open here.
8. `Mob.dropCustomDeathLoot` details beyond the enchantment hooks (the dropped durability randomization, `isPreserved`, the killed-by-player condition) are only partly read; they belong to the mob drop round (18 section 7.6).
9. Explosion mechanics (`explode`, wind burst): the world-simulation round (33) owns the explosion algorithm; here only the argument mapping is specified.
10. Loot condition semantics used by requirements (`entity_properties` predicate fields, `damage_source_properties`, `weather_check`, `location_check`, `random_chance` with `enchantment_level`) are in [26](26-loot-and-predicates.md) sections 8 and 10; not repeated.
11. The attribute modifier suffix `"/" + slot` is read from the concatenation recipe; the interplay with item attribute-modifier slot groups for the `attributes` component (which slots a group-wide query includes) was read only at the helper level.
12. `post_attack` with `enchanted` = `damaging_entity`: concluded unreachable from the three helper steps; not found in any shipped enchantment (not exhaustively checked against the 43 files).
13. The post-impulse grace time effect (`applyPostImpulseGraceTime(10)`): its consumers (fall damage and a few movement checks) were not traced here; see 17 section 4.8 and 33.
14. Resolved: the default crossbow sounds and trident throw sound were read (8.4).
15. Out of scope or only partly read in this round (listed rather than guessed): the JSON layout is read (flat, 13); the semantic use of `exclusive_set`, `supported_items`, `primary_items`, `weight` and the cost curves in the enchanting table and anvil (17 section 6.5 and the data tool 22); the `enchantment_provider` subtypes `by_cost`, `by_cost_with_difficulty` and `single` (only named in section 9, field lists not read); how `stored_enchantments` is read by the book-specific menus (8.1 only says the effect engine never iterates it); the `EnchantmentInstance` weighted-selection routine.
16. Whether a validation problem on a requirement (a parameter outside the component's set) drops the enchantment or only logs: searched `Enchantment` and `ConditionalEffect` codecs, where only `validateHolder(ValidationContext, "requirements")` was visible; the registry loader behaviour is not read here (see 23).
17. `ProjectileWeaponItem.getDurabilityUse` overrides in subclasses (crossbow with fireworks, and so on) were not read; only the base value 1 is.
