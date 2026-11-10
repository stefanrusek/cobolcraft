# Tools, weapons and combat

| Item | Value |
|---|---|
| Covers | The item data-component model for tools, weapons and armor-adjacent items; a complete table of the tools, weapons and utility items with their durability, damage, speed, tier and enchantability; the special use of each; the full attack, damage, armor, knockback, hunger, death and experience pipeline; the enchantment table; durability loss, Unbreaking, Mending, anvil, grindstone and crafting-grid repair |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (version 26.3). This is the artifact already recorded in [README.md](README.md); no new artifact. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files inside the jar (`data/minecraft/enchantment`, `damage_type`, `tags`, `block_transformer`, `loot_table/gameplay`), with no execution |
| Ticket | `tickets/CC-0001-client-polish.md`, story "As a Player, I want all the tools and weapons to work" |

Read first: [00](00-data-types.md) §12 (item stacks and data component patches), [04](04-registry-sync.md) (the
`attribute_modifiers` schema), [05a](05a-play-clientbound-00-71.md) to [05c](05c-play-serverbound.md) (packets),
[09](09-cobolcraft-profile.md), [11](11-world-generation-caves-and-ores.md) §9 (ore drops, Fortune, experience), and
[13](13-client-gameplay-and-controls.md) (cited as "13 §n"; movement, the block-break progress formula in 13 §2.1, the
hardness and tier table in 13 §2.6, crafting). None of those is repeated here. [../design/standin-content.md](../design/standin-content.md)
is the content of the cobolcraft world type (cited "standin-content §n"). This document is the vanilla reference
for the behaviour the ticket asks for. The rules below apply in both world types: the standard world type and the
cobolcraft world type share them (docs/design/README.md Part 0, R2), and the stand-in numbers for these rules (its
maximum health 30, hurt cooldown 12 and fall rule in standin-content §10) are retired. Only content (blocks, items,
mobs, recipes) differs between the world types.

Conventions: "tick" is 1/20 s. `float` values are IEEE single precision unless said otherwise; the artifact computes
most combat arithmetic in `float`, so implementations that need bit-exact results use single precision and the
order of operations given. Class and method names in backticks say where a fact was read. "(inferred)" marks a value
deduced rather than read; "(recalled, not verified)" marks a statement the reader remembers from outside the artifact and did not read in this round (it must not be implemented from without a follow-up round); each such item that matters is repeated in "Open questions". A registry key written
without namespace (`iron_ingot`) is in the `minecraft` namespace. Note on the artifact: this version has **no
per-tool item classes** (there is no `PickaxeItem`, `AxeItem` and so on); tools are plain `Item`s whose behaviour
comes entirely from data components that `Item$Properties` helper methods attach (section 1.4).

---

## 1. The item data-component model

### 1.1 Prototype components and patches

Every item type has a **prototype**: a map of data components built at registration (`Items`, through
`Item$Properties`) and finalised by the registry bootstrap (`Item$Properties.finalizeInitializer`; some components
are `delayedComponent`s, built once the block/damage-type/sound registries exist). An item stack is an item type
plus a **patch** (00 §12.2): the patch lists components added or changed (value) and components removed (marker).
The effective value of a component on a stack is the patch entry if present, else the prototype's. Consequences an
implementation needs:

- Durability damage is the `damage` component, stored in the patch (a freshly crafted tool has no `damage` entry;
  the prototype value is 0). Enchantments are the `enchantments` component, the custom name is `custom_name`, the
  anvil surcharge is `repair_cost`.
- A stack whose patch removes a component loses the behaviour (an `unbreakable` marker never exists in a
  prototype; adding it makes `isDamageableItem` false, section 1.3).
- Two stacks merge only if item and effective component values are equal (the `ItemStack.isSameItemSameComponents`
  rule used by every merge in 13 §3.7).

### 1.2 Component type ids used by this document

The data component type registry is static (never sent, 04 §1). Ids are the registration order read from
`DataComponents.<clinit>`; the complete table is below for the components that matter here (the full registry has 122 types,
0..121; the others are cosmetic or entity-variant components). These ids are the VarInt that precedes each patch
entry on the wire (00 §12.2).

| Id | Name | Value type (wire layout, fields in order) |
|---|---|---|
| 1 | `max_stack_size` | VarInt |
| 2 | `max_damage` | VarInt |
| 3 | `damage` | VarInt |
| 4 | `unbreakable` | no payload (Unit) |
| 5 | `use_effects` | Boolean can_sprint, Boolean interact_vibrations, Float speed_multiplier (section 1.3) |
| 6 | `custom_name` | text component (00 §9) |
| 7 | `minimum_attack_charge` | Float (0..1) |
| 8 | `damage_type` | Holder of damage_type (the damage type this item's attack uses) |
| 12 | `rarity` | enum VarInt |
| 13 | `enchantments` | ItemEnchantments: Map of Holder(enchantment) to VarInt level (04 gives the registry; the map encoding is VarInt count, then pairs) |
| 16 | `attribute_modifiers` | List of entries: attribute holder, modifier (Identifier id, Double amount, operation), slot group, display (see 04 §schemas and 1.3) |
| 19 | `repair_cost` | VarInt |
| 21 | `enchantment_glint_override` | Boolean |
| 22 | `intangible_projectile` | Unit |
| 23 | `food` | FoodProperties (nutrition VarInt, saturation Float, can_always_eat Boolean) |
| 24 | `consumable` | Float consume_seconds, enum animation, sound holder, Boolean has_consume_particles, list of consume effects |
| 25 | `use_remainder` | ItemStackTemplate (the item left after use) |
| 26 | `use_cooldown` | Float seconds, Optional Identifier cooldown_group |
| 27 | `damage_resistant` | HolderSet of damage_type (the item entity does not burn or explode away for these types) |
| 28 | `tool` | List of rules, Float default_mining_speed, VarInt damage_per_block, Boolean can_destroy_blocks_in_creative (rule: HolderSet of block, Optional Float speed, Optional Boolean correct_for_drops) |
| 29 | `weapon` | VarInt item_damage_per_attack, Float disable_blocking_for_seconds |
| 30 | `attack_range` | six Floats: min_reach, max_reach, min_creative_reach, max_creative_reach, hitbox_margin, mob_factor |
| 31 | `enchantable` | VarInt enchantability value |
| 32 | `equippable` | enum slot, sound holder, Optional asset, Optional camera overlay, Optional HolderSet of entity type, Boolean dispensable, Boolean swappable, Boolean damage_on_hurt, Boolean equip_on_interact, Boolean can_be_sheared, sound holder shearing_sound |
| 33 | `repairable` | HolderSet of item (the repair ingredients) |
| 34 | `glider` | Unit (elytra flight) |
| 36 | `death_protection` | list of consume effects (totem) |
| 37 | `blocks_attacks` | Float block_delay_seconds, Float disable_cooldown_scale, List of damage reductions, item damage function, Optional HolderSet bypassed_by, Optional block sound, Optional disable sound |
| 38 | `piercing_weapon` | Boolean deals_knockback, Boolean dismounts, Optional sound, Optional hit_sound |
| 39 | `kinetic_weapon` | VarInt contact_cooldown_ticks, VarInt delay_ticks, three Optional conditions (dismount, knockback, damage; each VarInt max_duration_ticks, Float min_speed, Float min_relative_speed), Float forward_movement, Float damage_multiplier, Optional sound, Optional hit_sound |
| 40 | `attack_animation` | enum swing type (default `whack`; spears use `stab`), VarInt duration ticks |
| 43 | `block_transformer` | Holder of a block transformer (the strip / till / flatten data, section 3.1) |
| 45 | `stored_enchantments` | ItemEnchantments (as id 13; the enchantments an `enchanted_book` holds) |
| 51 | `charged_projectiles` | list of item stacks (a loaded crossbow) |
| 53 | `potion_contents`, 54 `potion_duration_scale` | potion data; Float scale (tipped arrow 0.125, lingering 0.25) |
| 61 | `bucket_entity_data` | CustomData (NBT) of the creature in a mob bucket |
| 66 | `jukebox_playable` | (not used here) |
| 69 | `lodestone_tracker` | Optional GlobalPos target, Boolean tracked |
| 71 | `fireworks` | VarInt flight_duration, list of explosions |
| 74 | `banner_patterns` | list of (pattern holder, dye colour) layers (a shield's or banner's pattern) |
| 75 | `base_color` | dye colour enum (VarInt) |
| 83 | `break_sound` | sound holder (played when the item breaks) |

**Sub-records of `blocks_attacks`**: a damage reduction is (Float `horizontal_blocking_angle`, Optional HolderSet of damage types `type`, Float `base`, Float `factor`); the item damage function is (Float `threshold`, Float `base`, Float `factor`); the two Optional sound fields are Optional sound holders. **Sound holders** (`SoundEvent.STREAM_CODEC`, read) are the `Holder` encoding of 00 §10.2: a VarInt selector, 0 followed by an inline sound event (Identifier `location`, then Optional Float `fixed_range`: Boolean flag and Float), or n > 0 meaning the sound-event registry entry n - 1. The field order of the other components follows the table above; `attack_range` and `kinetic_weapon` and `piercing_weapon` use the same Float, VarInt, Boolean and Optional wire types.

Float fields in `tool`, `weapon`, `attack_range`, `kinetic_weapon` use the Float wire type (big-endian IEEE single, 00 §1);
Optionals are a Boolean presence flag then the value (00 §6.6).

### 1.3 The records, with their semantics

**`max_damage` and `damage` (durability).** `max_damage` is the durability. `isDamageableItem` is true when
`max_damage` is present and > 0, `unbreakable` is absent, and `damage` is present in the effective components (the prototype gives
`damage` 0 whenever `durability(n)` was used). `Item$Properties.durability(n)` always sets three components at
once: `max_damage` = n, `max_stack_size` = 1, `damage` = 0. The current damage is clamped to [0, max_damage] on read and write
(`ItemStack.getDamageValue`, `setDamageValue`). A stack **breaks** when its damage reaches max_damage after a hurt (section 5.1).
The client draws a durability bar whenever damage > 0 (`Item.isBarVisible`, `getBarWidth`, `getBarColor`; the exact bar geometry is 12 §n territory and is not traced here (inferred: 13 px wide, filled by (max - damage) / max)).

**`tool`** (`Tool`): an ordered list of rules, a default mining speed, `damage_per_block`, and `can_destroy_blocks_in_creative`.
A rule is (block set, optional speed, optional correct_for_drops). Two lookups scan the list in order and stop at the first
rule that matches the block AND carries the wanted field:
- mining speed (`Tool.getMiningSpeed`): the first matching rule that has a speed gives it; else `default_mining_speed`;
- correct for drops (`Tool.isCorrectForDrops`): the first matching rule that has `correct_for_drops` gives that
  Boolean; if no rule matches the answer is false.
The block-break formula that consumes both is 13 §2.1 (not repeated). `damage_per_block` is the durability cost of a
completed block break (section 5.1). `can_destroy_blocks_in_creative` is false for swords, the mace and the trident, true for every
other tool, and shears. An item with no `tool` component has speed 1.0 and `can_destroy_blocks_in_creative` true
(`Item.getDestroySpeed`, `Item.canDestroyBlock`).

**`weapon`** (`Weapon`): `item_damage_per_attack` is the durability cost when the item hits an entity (section 5.1);
`disable_blocking_for_seconds` is how long a hit with this item disables an enemy's blocking item (section 3.6). Swords, the mace,
the trident and spears have disable 0; every axe has 5.0; pickaxes, shovels and hoes have 0.

**`attribute_modifiers`**: a list of (attribute, modifier, slot group). The modifier has an Identifier `id`,
a Double `amount` and an operation (`add_value`, `add_multiplied_base`, `add_multiplied_total`). Tools and weapons
carry exactly two entries in the `mainhand` slot group: `attack_damage` with id `base_attack_damage` and `attack_speed` with id
`base_attack_speed`, both `add_value`. The modifier is **added** to the player's base attribute (attack damage base 1.0, attack speed base 4.0,
section 1.5). So an item's displayed damage is 1 + its modifier, and its attack speed is 4 + its modifier.
Armor entries carry `armor`, `armor_toughness` and (netherite only) `knockback_resistance` in the matching armor slot group
(section 2.5); enchantments add their own modifiers through the enchantment effect system (section 6).
Effective attribute value (`AttributeInstance.calculateValue`, read): v = base + sum of all `add_value` amounts; x = v; for each `add_multiplied_base` modifier x += v x amount (the multiplier applies to the sum v, not to the bare base); then for each `add_multiplied_total` modifier x = x x (1 + amount); the result is clamped to the attribute's range (`Attribute.sanitizeValue`). The clientbound Update Attributes packet (0x86) carries the modifiers of equipped items.

**`attack_range`** (`AttackRange`): reach used for attacks with the item. Fields: min_reach, max_reach, min_creative_reach, max_creative_reach, hitbox_margin, mob_factor (Float each, 0..64 for the reaches). When an item has none, `AttackRange.defaultFor(entity)` builds (0, R, 0, R, 0, 1.0) with R = the entity's `entity_interaction_range` attribute (read from the bytecode: the same R is used for the survival and the creative maximum; creative reach differs only through the attribute value itself), hitbox margin 0 and mob factor 1.0. `effectiveMinRange` / `effectiveMaxRange` pick the creative or survival fields by `Player.isCreative`. Spears carry (2.0, 4.5, 2.0, 6.5, 0.125, 0.5): they cannot hit closer than 2.0 blocks and reach 4.5 (6.5 in creative), the target hitbox is enlarged by 0.125, and the factor for mobs is 0.5.

**`minimum_attack_charge`** (Float, spears: 1.0): the attack strength below which the item cannot attack at all
(`Player.cannotAttackWithItem`: attack is refused while (attack ticker + partial) / delay < this value; default 0).

**`use_effects`** (`UseEffects`): while the item is being used (drawing, blocking, charging): `can_sprint` (default false, spear true),
`interact_vibrations` (default true; spears false) and `speed_multiplier` (default 0.2, spears 1.0), the factor applied to the movement
input while using (13 §1.1 slow-down while using an item).

**`use_cooldown`** (`UseCooldown`): `seconds`, optional `cooldown_group` (the cooldown is keyed by the group or, if none, by the
item's registry id). Using the item starts a cooldown of seconds x 20 ticks on every item of the group; while it runs the item cannot be
used. The server tells the client with Cooldown (0x16: group id, ticks) and the client greys the item. Values: ender pearl 1.0 s, chorus
fruit 1.0 s, wind charge 0.5 s (read in `Items`); a shield disabled by an axe gets a cooldown through the same mechanism (section 3.6).

**`use_remainder`** and `craft_remainder`: the item that replaces a consumed stack of one (milk bucket becomes a bucket, a potion a
glass bottle, soups a bowl). **`consumable`**: eat/drink time, animation, sound and the on-consume effects; defined for food and potions,
out of scope here beyond the buckets (section 3.8).

**`enchantable`**: the single VarInt `value` is the item's enchantability, used by the enchanting table (section 6.5) and nothing else.
**`repairable`**: the item set that repairs the stack in an anvil (section 5.4). **`equippable`**: which equipment slot the item goes in
(right-click equips it, 13 §4 for the swap), the equip sound, and `damage_on_hurt` (armor true, elytra false: whether wearing it loses
durability when its wearer is hurt, section 4.5). **`damage_resistant`**: set by `fireResistant()` (netherite items, nether star): the
dropped item entity is immune to the damage types in the tag `is_fire` (`Item$Properties.fireResistant` builds `DamageResistant(is_fire)`).
**`damage_type`** (component 8): the damage type attacks with this item use (spears set `spear`; the mace uses `mace_smash` through
its `getItemDamageSource`; every other item, `player_attack`).

### 1.4 How defaults are filled per item (the `Item$Properties` builders)

`Item$Properties` builders fill the prototype; each call below is an exact description of what it sets.

| Builder | Components set |
|---|---|
| `durability(n)` | `max_damage` n, `max_stack_size` 1, `damage` 0 |
| `repairable(tag or item)` | `repairable` (the set) |
| `enchantable(n)` | `enchantable` n |
| `stacksTo(n)` | `max_stack_size` n (default 64 when absent) |
| `rarity(r)` | `rarity` |
| `fireResistant()` | `damage_resistant` (set from the tag of fire damage types) |
| `useCooldown(s)` | `use_cooldown` with no group |
| `usingConvertsTo(item)` | `use_remainder` |
| `tool(material, mineableTag, damage, speed, disableSeconds)` (`ToolMaterial.applyToolProperties`) | common (durability, repairable, enchantable from the material); `tool` = rules [ deny-drops(material's incorrect-blocks tag), mine-and-drop(mineableTag, material speed) ], default speed 1.0, damage_per_block 1, creative break allowed; `attribute_modifiers` = attack_damage (damage + material attack bonus), attack_speed (speed); `weapon` = (item_damage_per_attack 2, disable seconds) |
| `pickaxe(m, dmg, spd)` | `tool(m, mineable/pickaxe, dmg, spd, 0)` |
| `axe(m, dmg, spd)` | `tool(m, mineable/axe, dmg, spd, 5.0)` plus `block_transformer` = the axe transformer (section 3.1) |
| `shovel(m, dmg, spd)` | `tool(m, mineable/shovel, dmg, spd, 0)` plus the shovel transformer |
| `hoe(m, dmg, spd)` | `tool(m, mineable/hoe, dmg, spd, 0)` plus the hoe transformer |
| `sword(m, dmg, spd)` (`ToolMaterial.applySwordProperties`) | common; `tool` = rules [ mine-and-drop(cobweb, 15.0), override-speed(tag `sword_instantly_mines`, 3.4028235E38), override-speed(tag `sword_efficient`, 1.5) ], default speed 1.0, damage_per_block 2, creative break NOT allowed; attributes (dmg + bonus, spd); `weapon` = (1, 0) |
| `spear(m, a, b, c, d, e, f, g, h, i)` | durability, repairable, enchantable from the material; `damage_type` spear; `kinetic_weapon` = (contact_cooldown 10, delay floor(c x 20), dismount (floor(d x 20) ticks, speed e), knockback (floor(f x 20), g), damage (floor(h x 20) ticks, relative speed i), forward_movement 0.38, damage_multiplier b, sounds); `piercing_weapon` = (knockback true, dismount false); `attack_range` (2.0, 4.5, 2.0, 6.5, 0.125, 0.5); `minimum_attack_charge` 1.0; `attack_animation` = (stab, floor(a x 20) ticks); attributes: attack_damage (0 + material bonus), attack_speed (1/a - 4.0), so the speed is 1/a; `use_effects` (can_sprint true, interact_vibrations false, speed 1.0); `weapon` (1, 0) |
| `humanoidArmor(material, type)` | durability = material multiplier x slot base (helmet 11, chestplate 16, leggings 15, boots 13); attributes from the material (section 2.5); `enchantable`; `equippable` (slot, equip sound, asset; `damage_on_hurt` true); `repairable` |
| `wolfArmor`, `horseArmor`, `nautilusArmor` | like humanoid with the body slot (durability multiplier x 16) |

Because the speed modifier for swords/tools is stored as a number below 4, for example -2.4 for swords, an item shows
"attack speed 1.6" (4 - 2.4).

### 1.5 Attributes this document uses (defaults and ranges)

Read from `Attributes.<clinit>` (default; range min..max) and `Player.createAttributes`.

| Attribute | Default | Range | Notes |
|---|---|---|---|
| `max_health` | 20 | 1..1024 | the player uses 20 in both world types |
| `attack_damage` | 2 (generic); **player base 1.0** | 0..2048 | `Player.createAttributes` overrides the base to 1.0 |
| `attack_speed` | 4.0 | 0..1024 | the player's base is the default |
| `attack_knockback` | 0 | 0..5 | |
| `knockback_resistance` | 0 | 0..1 | |
| `armor` | 0 | 0..30 | |
| `armor_toughness` | 0 | 0..20 | |
| `max_absorption` | 0 | (not read) | Absorption adds 4 per level |
| `mining_efficiency` | 0 | 0..1024 | enchantment Efficiency adds here (13 §2.1) |
| `block_break_speed` | 1.0 | 0..1024 | |
| `submerged_mining_speed` | 0.2 | 0..20 | |
| `sweeping_damage_ratio` | 0 | 0..1 | Sweeping Edge adds here |
| `entity_interaction_range` | 3.0 | 0..64 | attack and interact reach |
| `block_interaction_range` | 4.5 | 0..64 | |
| `safe_fall_distance` | 3.0 | -1024..1024 | |
| `fall_damage_multiplier` | 1.0 | 0..100 | |
| `luck` | 0 | -1024..1024 | |
| `oxygen_bonus` | 0 | 0..1024 | Respiration |
| `burning_time` | 1.0 | 0..1024 | Fire Protection multiplies |
| `explosion_knockback_resistance` | 0 | 0..1 | Blast Protection adds |
| `sneaking_speed` | 0.3 | 0..1 | Swift Sneak adds |
| `water_movement_efficiency`, `movement_efficiency` | 0 | 0..1 | Depth Strider; Soul Speed |
| `movement_speed` | 0.7 (generic); player 0.1 | 0..1024 | 13 §1.2 |
| `step_height`, `gravity`, `jump_strength` | 0.6, 0.08, 0.42 | | 13 §1.2 |

---

## 2. Item tables

### 2.1 Tool materials (`ToolMaterial`)

Each tool tier is a record (incorrect-blocks tag, durability, speed, attack-damage bonus, enchantability, repair tag). The "denies drops" block
tags are listed in 11 §9.1 and 13 §2.6 (not repeated): wooden and golden deny `needs_stone_tool` + `needs_iron_tool` + `needs_diamond_tool`;
stone and copper deny `needs_iron_tool` + `needs_diamond_tool`; iron denies `needs_diamond_tool`; diamond and netherite deny nothing.

| Material (`ToolMaterial`) | Durability | Mining speed | Attack bonus | Enchantability | Repair ingredient (item tag) | Denies drops (block tag) |
|---|---|---|---|---|---|---|
| wooden (`WOOD`) | 59 | 2 | 0 | 15 | #wooden_tool_materials (any planks) | `incorrect_for_wooden_tool` |
| stone (`STONE`) | 131 | 4 | 1 | 5 | #stone_tool_materials (cobblestone, blackstone, cobbled_deepslate) | `incorrect_for_stone_tool` |
| copper (`COPPER`) | 190 | 5 | 1 | 13 | copper_ingot | `incorrect_for_copper_tool` |
| iron (`IRON`) | 250 | 6 | 2 | 14 | iron_ingot | `incorrect_for_iron_tool` |
| golden (`GOLD`) | 32 | 12 | 0 | 22 | gold_ingot | `incorrect_for_gold_tool` |
| diamond (`DIAMOND`) | 1561 | 8 | 3 | 10 | diamond | `incorrect_for_diamond_tool` |
| netherite (`NETHERITE`) | 2031 | 9 | 4 | 15 | netherite_ingot | `incorrect_for_netherite_tool` |

Registered per kind (damage and speed modifiers are the numbers given to the builder; the damage modifier already excludes the material bonus,
which the builder adds). Attack damage here is the value the player's attack_damage attribute has with the item in the main hand (base 1.0 + modifier + bonus).
Cooldown ticks is the full-charge delay (section 4.1: 20 / attack speed ticks). Mining speed is the material speed and applies only to blocks in
the kind's `mineable/*` tag (otherwise 1.0, 13 §2.1). Every tool and the sword also has: max stack size 1, repairable by the material's repair tag, and enchantable by
the material's enchantability. All values below are read from `Items` plus `ToolMaterial` and checked by arithmetic.

### 2.2 Swords (tag `swords`; rule set of section 1.4)

| Item | Durability | Damage modifier (as registered) | Attack damage (1 + modifier + bonus) | Speed modifier | Attack speed (4 + modifier) | Cooldown ticks (20 / speed) | Mining speed |
|---|---|---|---|---|---|---|---|
| `wooden_sword` | 59 | 3 | 4 | -2.4 | 1.6 | 12.5 | 2 |
| `stone_sword` | 131 | 3 | 5 | -2.4 | 1.6 | 12.5 | 4 |
| `copper_sword` | 190 | 3 | 5 | -2.4 | 1.6 | 12.5 | 5 |
| `iron_sword` | 250 | 3 | 6 | -2.4 | 1.6 | 12.5 | 6 |
| `golden_sword` | 32 | 3 | 4 | -2.4 | 1.6 | 12.5 | 12 |
| `diamond_sword` | 1561 | 3 | 7 | -2.4 | 1.6 | 12.5 | 8 |
| `netherite_sword` | 2031 | 3 | 8 | -2.4 | 1.6 | 12.5 | 9 |

Sword rules: cobweb mines with speed 15.0 and drops; the blocks in `sword_instantly_mines` (`bamboo`, `bamboo_sapling`) mine at speed 3.4028235E38
(instant; with the 13 §2.1 formula the progress per tick is far above 1); the blocks in `sword_efficient` mine at 1.5 (25 blocks: all leaves and azalea leaves, `vine`,
`glow_lichen`, `pumpkin`, `carved_pumpkin`, `jack_o_lantern`, `melon`, `cocoa`, `big_dripleaf`, `big_dripleaf_stem`, `chorus_plant`, `chorus_flower`). The sword's cobweb rule is built with `Tool$Rule.minesAndDrops` (speed 15.0 and `correct_for_drops` true), so a sword **is** the correct tool for cobweb and cobweb drops what its loot table gives for a correct tool; every other sword rule (`sword_instantly_mines`, `sword_efficient`) is an `overrideSpeed` rule that carries a speed only. A sword has no deny-drops rule. Both lookups of 1.3 use the first matching rule that carries the wanted field, so for the cobweb the cobweb rule (listed first) answers both the speed and the drops question; for a block that needs a tool but is not cobweb (stone, ores) no sword rule carries `correct_for_drops`, so the sword is not correct for it.
Creative players cannot break blocks with a sword (`can_destroy_blocks_in_creative` false). A sword costs 2 durability per broken block and 1 per entity hit.

### 2.3 Pickaxes, axes, shovels, hoes

Pickaxes (`mineable/pickaxe`):

| Item | Durability | Damage modifier (as registered) | Attack damage (1 + modifier + bonus) | Speed modifier | Attack speed (4 + modifier) | Cooldown ticks (20 / speed) | Mining speed |
|---|---|---|---|---|---|---|---|
| `wooden_pickaxe` | 59 | 1 | 2 | -2.8 | 1.2 | 16.6667 | 2 |
| `stone_pickaxe` | 131 | 1 | 3 | -2.8 | 1.2 | 16.6667 | 4 |
| `copper_pickaxe` | 190 | 1 | 3 | -2.8 | 1.2 | 16.6667 | 5 |
| `iron_pickaxe` | 250 | 1 | 4 | -2.8 | 1.2 | 16.6667 | 6 |
| `golden_pickaxe` | 32 | 1 | 2 | -2.8 | 1.2 | 16.6667 | 12 |
| `diamond_pickaxe` | 1561 | 1 | 5 | -2.8 | 1.2 | 16.6667 | 8 |
| `netherite_pickaxe` | 2031 | 1 | 6 | -2.8 | 1.2 | 16.6667 | 9 |

Axes (`mineable/axe`; hit also disables shields for 5.0 s, section 3.6):

| Item | Durability | Damage modifier (as registered) | Attack damage (1 + modifier + bonus) | Speed modifier | Attack speed (4 + modifier) | Cooldown ticks (20 / speed) | Mining speed |
|---|---|---|---|---|---|---|---|
| `wooden_axe` | 59 | 6 | 7 | -3.2 | 0.8 | 25 | 2 |
| `stone_axe` | 131 | 7 | 9 | -3.2 | 0.8 | 25 | 4 |
| `copper_axe` | 190 | 7 | 9 | -3.2 | 0.8 | 25 | 5 |
| `iron_axe` | 250 | 6 | 9 | -3.1 | 0.9 | 22.2222 | 6 |
| `golden_axe` | 32 | 6 | 7 | -3 | 1 | 20 | 12 |
| `diamond_axe` | 1561 | 5 | 9 | -3 | 1 | 20 | 8 |
| `netherite_axe` | 2031 | 5 | 10 | -3 | 1 | 20 | 9 |

Shovels (`mineable/shovel`):

| Item | Durability | Damage modifier (as registered) | Attack damage (1 + modifier + bonus) | Speed modifier | Attack speed (4 + modifier) | Cooldown ticks (20 / speed) | Mining speed |
|---|---|---|---|---|---|---|---|
| `wooden_shovel` | 59 | 1.5 | 2.5 | -3 | 1 | 20 | 2 |
| `stone_shovel` | 131 | 1.5 | 3.5 | -3 | 1 | 20 | 4 |
| `copper_shovel` | 190 | 1.5 | 3.5 | -3 | 1 | 20 | 5 |
| `iron_shovel` | 250 | 1.5 | 4.5 | -3 | 1 | 20 | 6 |
| `golden_shovel` | 32 | 1.5 | 2.5 | -3 | 1 | 20 | 12 |
| `diamond_shovel` | 1561 | 1.5 | 5.5 | -3 | 1 | 20 | 8 |
| `netherite_shovel` | 2031 | 1.5 | 6.5 | -3 | 1 | 20 | 9 |

Hoes (`mineable/hoe`):

| Item | Durability | Damage modifier (as registered) | Attack damage (1 + modifier + bonus) | Speed modifier | Attack speed (4 + modifier) | Cooldown ticks (20 / speed) | Mining speed |
|---|---|---|---|---|---|---|---|
| `wooden_hoe` | 59 | 0 | 1 | -3 | 1 | 20 | 2 |
| `stone_hoe` | 131 | -1 | 1 | -2 | 2 | 10 | 4 |
| `copper_hoe` | 190 | -1 | 1 | -2 | 2 | 10 | 5 |
| `iron_hoe` | 250 | -2 | 1 | -1 | 3 | 6.6667 | 6 |
| `golden_hoe` | 32 | 0 | 1 | -3 | 1 | 20 | 12 |
| `diamond_hoe` | 1561 | -3 | 1 | 0 | 4 | 5 | 8 |
| `netherite_hoe` | 2031 | -4 | 1 | 0 | 4 | 5 | 9 |

Every hoe has attack damage 1 (the modifier cancels the material bonus: for example iron: 1 - 2 + 2 = 1); hoe speed is the material speed on the hoe's
`mineable` blocks (leaves, hay, sponge, sculk, moss, wart blocks and so on). The mineable tags are listed in Appendix A. Mining a block costs 1 durability for
pickaxe/axe/shovel/hoe (`damage_per_block` 1) when the block's hardness is not 0; hitting an entity costs 2 (`item_damage_per_attack` 2). Note the
asymmetry: sword block cost 2 / hit cost 1; other tools block cost 1 / hit cost 2.

### 2.4 Spears

The spear is a kinetic weapon (section 3.12). Registered through `Item$Properties.spear(material, a, b, c, d, e, f, g, h, i)`; the table gives
the derived values (section 1.4 shows the formulas). Attack damage is 1 + material bonus (the modifier is 0 + bonus), attack speed is 1 / a (cooldown ticks = 20 a), the stab swing lasts
floor(a x 20) ticks. Netherite is fire resistant. Wooden spears are fuel (like all wooden tools). Enchantable with Lunge and the sharp-weapon/melee set (section 6).

| Item | Durability | Attack damage (1 + bonus) | Attack speed (1/a) | a: swing seconds | m: kinetic damage multiplier | Delay ticks (c x 20) | Dismount: max ticks, min speed | Knockback: max ticks, min speed | Damage: max ticks, min relative speed |
|---|---|---|---|---|---|---|---|---|---|
| `wooden_spear` | 59 | 1 | 1.5385 | 0.65 | 0.7 | 15 | 100, 14 | 200, 5.1 | 300, 4.6 |
| `stone_spear` | 131 | 2 | 1.3333 | 0.75 | 0.82 | 14 | 90, 13 | 180, 5.1 | 275, 4.6 |
| `copper_spear` | 190 | 2 | 1.1765 | 0.85 | 0.82 | 13 | 80, 12 | 165, 5.1 | 250, 4.6 |
| `iron_spear` | 250 | 3 | 1.0526 | 0.95 | 0.95 | 12 | 50, 11 | 135, 5.1 | 225, 4.6 |
| `golden_spear` | 32 | 1 | 1.0526 | 0.95 | 0.7 | 14 | 70, 13 | 170, 5.1 | 275, 4.6 |
| `diamond_spear` | 1561 | 4 | 0.9524 | 1.05 | 1.075 | 10 | 60, 10 | 130, 5.1 | 200, 4.6 |
| `netherite_spear` | 2031 | 5 | 0.8696 | 1.15 | 1.2 | 8 | 50, 9 | 110, 5.1 | 175, 4.6 |

All spears: contact cooldown 10 ticks, forward movement 0.38, attack range (2.0, 4.5, 2.0, 6.5, 0.125, 0.5), `minimum_attack_charge` 1.0, damage type `spear` (no knockback by itself: `spear` is in `no_knockback`),
repair by the material tag, enchantability by the material, stack size 1, `use_effects` (sprint allowed, speed multiplier 1.0), durability per attack 1.

### 2.5 Armor materials (armor-adjacent; the numbers the damage formula in 4.4 needs)

`ArmorMaterial` = (durability multiplier, defense per slot, enchantability, equip sound, toughness, knockback resistance, repair tag). Item durability = multiplier x slot base
(helmet 11, chestplate 16, leggings 15, boots 13, body 16). Defense per slot is what the `armor` attribute gains with the piece worn; the player's `armor` attribute is the
sum of the worn pieces plus any other modifier, clamped to 0..30.

| Material | Durability multiplier | Boots | Leggings | Chestplate | Helmet | Body (animal armor) | Enchantability | Toughness | Knockback resistance | Repair |
|---|---|---|---|---|---|---|---|---|---|---|
| leather | 5 | 1 | 2 | 3 | 1 | 3 | 15 | 0 | 0 | leather |
| copper | 11 | 1 | 3 | 4 | 2 | 4 | 8 | 0 | 0 | copper_ingot |
| chainmail | 15 | 1 | 4 | 5 | 2 | 4 | 12 | 0 | 0 | #repairs_chain_armor |
| iron | 15 | 2 | 5 | 6 | 2 | 5 | 9 | 0 | 0 | iron_ingot |
| golden | 7 | 1 | 3 | 5 | 2 | 7 | 25 | 0 | 0 | gold_ingot |
| diamond | 33 | 3 | 6 | 8 | 3 | 11 | 10 | 2 | 0 | diamond |
| netherite | 37 | 3 | 6 | 8 | 3 | 19 | 15 | 3 | 0.1 | netherite_ingot |
| turtle_scute | 25 | 2 | 5 | 6 | 2 | 5 | 9 | 0 | 0 | turtle_scute (helmet only) |
| wolf armor (armadillo_scute) | 4 | 3 | 6 | 8 | 3 | 11 | 10 | 0 | 0 | armadillo_scute |

Examples of derived item durability: iron helmet 15 x 11 = 165, iron chestplate 240, iron leggings 225, iron boots 195; diamond helmet 363; netherite chestplate 592; leather boots 65; turtle helmet 275;
wolf armor 64. Items: `leather_*`, `copper_*`, `chainmail_*` (rarity uncommon), `iron_*`, `golden_*`, `diamond_*`, `netherite_*` (fire resistant), `turtle_helmet` (helmet only), horse and nautilus armor of the
same materials, `wolf_armor`. `elytra` is not armor: durability 432, rarity epic, `glider`, equippable in the chest slot with `damage_on_hurt` false, repairable with `phantom_membrane`, no armor value.

### 2.6 Special weapons and tools, complete

| Item | Max stack | Durability | Rarity | Enchantability | Repair ingredient | Components and stats |
|---|---|---|---|---|---|---|
| `mace` | 1 | 500 | epic | 15 | `breeze_rod` | attack_damage modifier +5.0 (damage 6), attack_speed modifier -3.4 (speed 0.6, cooldown 33.3 ticks); `tool` with no rules, default 1.0, damage_per_block 2, no creative break; `weapon` (1, 0); smash attack (3.5) |
| `trident` | 1 | 250 | rare | 1 | none | attack_damage modifier +8.0 (damage 9), attack_speed modifier -2.9 (speed 1.1, cooldown 18.2 ticks); `tool` no rules, default 1.0, damage_per_block 2, no creative break; `weapon` (1, 0); thrown 8.0 (section 3.10) |
| `bow` | 1 | 384 | common | 1 | none | fuel (small); projectile weapon; use duration 72000 (section 3.9) |
| `crossbow` | 1 | 465 | common | 1 | none | fuel (small); `charged_projectiles` default empty (section 3.9) |
| `shield` | 1 | 336 | common | none (`enchantable` absent) | `#wooden_tool_materials` (planks) | `banner_patterns` empty; equippable (offhand, unswappable); `blocks_attacks` (section 3.6); `break_sound` shield break |
| `shears` | 1 | 238 | common | none | none | `tool` (section 3.2); it has no `enchantable` component, so the enchanting table cannot enchant it, but it is in the item tags `enchantable/mining` and `enchantable/durability`, so books on an anvil can (Efficiency, Unbreaking, Mending) |
| `flint_and_steel` | 1 | 64 | common | none | none | section 3.3 |
| `fishing_rod` | 1 | 64 | common | 1 | none | fuel (small); section 3.11 |
| `carrot_on_a_stick` | 1 | 25 | common | none | none | rides a pig; each boost costs 7 durability (`Items` registers `FoodOnAStickItem(EntityTypes.PIG, 7)`) |
| `warped_fungus_on_a_stick` | 1 | 100 | common | none | none | rides a strider; boost cost 1 (`Items` registers `FoodOnAStickItem(EntityTypes.STRIDER, 1)`) |
| `brush` | 1 | 64 | common | none | none | use duration 200 ticks (section 3.5) |
| `spyglass` | 1 | none | common | none | none | use duration 1200 ticks; scoping (section 3.14) |
| `compass` | 64 | none | common | none | none | points at world spawn; `lodestone_tracker` makes it a lodestone compass (section 3.14) |
| `recovery_compass` | 64 | none | uncommon | none | none | points at the last death location (section 3.14) |
| `clock` | 64 | none | common | none | none | shows time; no other behaviour |
| `lead` | 64 | none | common | none | none | section 3.7 |
| `name_tag` | 64 | none | common | none | none | section 3.7 |
| `saddle` | 1 | none | common | none | none | `equippable` (saddle), equip on interact, allowed entities from tag `can_equip_saddle` |
| `elytra` | 1 | 432 | epic | none | `phantom_membrane` | section 3.13 |
| `bucket` | 16 | none | common | none | none | section 3.8 |
| `water_bucket`, `lava_bucket`, `powder_snow_bucket`, `milk_bucket` | 1 | none | common | none | none | craft remainder `bucket`; `lava_bucket` is fuel; milk is consumable and becomes a bucket |
| `pufferfish_bucket`, `salmon_bucket`, `cod_bucket`, `tropical_fish_bucket`, `axolotl_bucket`, `tadpole_bucket`, `sulfur_cube_bucket` | 1 | none | common | none | none | mob buckets; `bucket_entity_data` holds the creature NBT; fish buckets also have food components |
| `ender_pearl` | 16 | none | common | none | none | `use_cooldown` 1.0 s; section 3.15 |
| `snowball`, `egg`, `blue_egg`, `brown_egg` | 16 | none | common | none | none | section 3.15 |
| `wind_charge` | 64 | none | common | none | none | `use_cooldown` 0.5 s; section 3.15 |
| `firework_rocket` | 64 | none | common | none | none | `fireworks` (flight 1 by default); section 3.13 |
| `fire_charge` | 64 | none | common | none | none | section 3.3 |
| `bone_meal` | 64 | none | common | none | none | section 3.4 |
| `splash_potion`, `lingering_potion` | 1 | none | common | none | none | thrown potions (section 3.15); `potion_duration_scale` 1.0 / 0.25 |
| `arrow`, `spectral_arrow`, `tipped_arrow` | 64 | none | common | none | none | tag `arrows`; tipped `potion_duration_scale` 0.125 |
| `totem_of_undying` | 1 | none | uncommon | none | none | `death_protection` (section 4.9) |
| `experience_bottle` | 64 | none | uncommon | none | none | enchantment glint |
| `bundle`, `armor_stand`, boats, minecarts, spawn eggs | | | | | | not tools; out of scope |

The `tool` of shears: rules in order [cobweb: mine and drop, speed 15.0; tag `shears_extreme_breaking_speed` (all leaves): speed 15.0; tag `shears_major_breaking_speed` (all wool, wool slabs, wool stairs): speed 5.0; tag
`shears_minor_breaking_speed` (`vine`, `glow_lichen`): speed 2.0]; default speed 1.0; damage per block 1 (3.2 for the fire exception); creative break allowed.

---

## 3. Special uses

Every use below starts from the serverbound packets Use Item On (0x42, a block target), Use Item (0x43, no target or an entity-independent use), Interact
(0x1A, an entity target) and Player Action (0x29: `RELEASE_USE_ITEM` ordinal 6 ends a draw/charge, `STAB` ordinal 8 is the spear jab); attacks use
Attack (0x01) (05c). Durability loss is `hurtAndBreak` (section 5.1) in the "damage" quoted. Where a use shows a "level event" id it is the clientbound Level Event (0x2F, 05a) with that event number, a sound is the clientbound Sound (0x77), and a changed block is Block Update (0x08)
with the Block Changed Ack (0x04) for the request's sequence number (13 §2.3).

### 3.1 Block transformers: axe, shovel, hoe (data in `data/minecraft/block_transformer/{axe,shovel,hoe}.json`, applied by `BlockTransformers.transformBlock`)

The `block_transformer` component holds a list of transformations. Each transformation is a block-state provider made of ordered
rules (a condition on the clicked state, and the resulting state) plus: `item_damage_per_use` (always 1), `sound`, optional `particle`,
optional `disallowed_faces` (the clicked face must not be one of them), optional `drop_strategy` and `loot`, `update_from_neighbors` (default true),
`transform_type` (`copper_chest` makes both halves of a double chest convert). Algorithm for Use Item On with an item that has the component:

1. If the player is holding a blocking item (`blocks_attacks`) in the **off hand** and is using the main hand and is not sneaking (`isSecondaryUseActive` false), skip: the shield takes priority (`playerHasBlockingItemUseIntent`).
2. Go through the transformations in list order, and inside one through its rules in order; the first transformation whose clicked face is allowed and whose rule matches yields the new state. If none matches, the use does nothing (the normal block use then happens).
3. `Level.setBlock(pos, new, flags 11)` (flags 1 + 2 + 8: notify, send to clients, re-render). Unless `update_from_neighbors` is false the new state is revalidated against its neighbours.
4. Play `sound` at the block (volume 1, pitch 1) and send the particle (if any); `hurtAndBreak(1)` on the used tool (not in creative); fire game event `block_change`; award the item-used trigger.
   For `copper_chest` the other half of a double chest is converted too and the same events fire for it.
5. If `drop_strategy` is `clicked_face`, the loot table in `loot` is rolled (block-interact loot) and its items pop from the clicked face.

**Axe** (`axe.json`, 7 transformations, sound shown):
- Strip (`item.axe.strip`, no particle): `oak`, `dark_oak`, `pale_oak`, `poplar`, `acacia`, `cherry`, `birch`, `jungle`, `spruce`, `mangrove` `_log` -> `stripped_<wood>_log`, `_wood` -> `stripped_<wood>_wood`; `warped_stem`, `warped_hyphae`, `crimson_stem`, `crimson_hyphae` -> their `stripped_` forms; `bamboo_block` -> `stripped_bamboo_block`. The axis property is copied from the original block (25 rules).
- Scrape (`item.axe.scrape`, particle `scrape`): each oxidation level steps back one: `oxidized_X` -> `weathered_X` -> `exposed_X` -> `X`, for the families `copper` (block), `cut_copper`, `chiseled_copper`, `cut_copper_slab`, `cut_copper_stairs`, `copper_trapdoor`, `copper_bulb`, `copper_grate`, and (separate entries with `update_from_neighbors` false) `copper_chest` (with `transform_type` `copper_chest`), `copper_door`, and the lightning rod/golem statue families that the 39-rule entry lists (the stairs, slabs, trapdoors, doors and chests keep their facing, half, shape, type and waterlogged state; "reset" values in the data are only templates: the properties named there are copied from the clicked block). Total rules: 39 (13 block families x 3 oxidation steps: `copper_block`, `cut_copper`, `cut_copper_slab`, `cut_copper_stairs`, `chiseled_copper`, `copper_trapdoor`, `copper_bars`, `copper_grate`, `copper_bulb`, `copper_chain`, `copper_lantern`, `copper_golem_statue`, `lightning_rod`), 3 (the `copper_chest` family) and 3 (the `copper_door` family): 15 families in all.
- Wax off (`item.axe.wax_off`, particle `wax_off`): `waxed_X` -> `X` for the same families at every oxidation level (52 rules in the block entry = the same 13 families x 4 oxidation levels, 4 in the chest entry, 4 in the door entry).
- Hitting with an axe also disables shields (3.6).
- **Honeycomb** (`HoneycombItem`, the wax-on counterpart; not a transformer file): Use Item On a block whose unwaxed form has a waxed form (the 15 families above, at each oxidation level, `HoneycombItem.getWaxed`): the block is replaced by the waxed block with the same properties (`Block.withPropertiesOf`), 1 honeycomb is consumed, level event 3003 and sound `item.honeycomb.wax_on` play, a game event fires, and for a chest the connected half is waxed too; a sign that is not waxed (`tryApplyToSign`) becomes waxed (level event 3003, same sound). Axes undo it with wax-off.

**Shovel** (`shovel.json`, 1 transformation, `item.shovel.flatten`): block in tag `turns_into_dirt_path` (`grass_block`, `dirt`, `podzol`, `coarse_dirt`, `mycelium`, `rooted_dirt`) with an **air** block directly above becomes `dirt_path`; the clicked face must not be `down`.
Extinguish: Use Item On a **lit** campfire or soul campfire (tag `campfires`) with an item in the item tag `douses_campfires` (the seven shovels) clears the `lit` property, sends level event 1009 (fizz) and costs 1 durability (`CampfireBlock.useItemOn`). A splash potion of water also douses campfires (3.15).

**Hoe** (`hoe.json`, 2 transformations, sound `item.hoe.till`, clicked face not `down` for the first):
- Entry 1: block in tag `turns_into_farmland` (`grass_block`, `dirt_path`, `dirt`) with air above -> `farmland` with `moisture` 0; `coarse_dirt` with air above -> `dirt`.
- Entry 2 (drop strategy `clicked_face`, loot `till/rooted_dirt`): `rooted_dirt` -> `dirt` and the loot (a `hanging_roots` item) pops out of the clicked face. (No air-above condition.)
- Hoes are also the fast tool for the `mineable/hoe` blocks (Appendix A); there is no other hoe use.

### 3.2 Shears

- **Mining** (`tool` of 2.6): cobweb 15; leaves 15; wool 5 (all colours, including slabs and stairs); `vine` and `glow_lichen` 2; everything else 1. Block drop: shears are the correct tool for cobweb (drops through the loot table's shears condition), leaves
  (leaves drop themselves with shears through their loot table, the usual `shears_or_silk` condition, section 3.16), vine and glow lichen.
- **Durability**: `ShearsItem.mineBlock` costs `damage_per_block` (1) per broken block unless the block hardness is 0 or the block is in tag `fire` (fire costs nothing).
- **Growing plants**: Use Item On a head block of a growing plant (kelp, weeping/twisting vines, cave vines) that is not at maximum age sets it to its max-age state, sound `block.growing_plant.crop`, 1 durability; this stops its growth.
- **Pumpkin**: Use Item On a `pumpkin` with shears turns it into `carved_pumpkin` (facing: if the clicked face is on the vertical axis the block faces the opposite of the player's horizontal direction, otherwise it faces the clicked face's direction; `PumpkinBlock.useItemOn`), plays `block.pumpkin.carve`, rolls the block-interact loot table `carve/pumpkin`: **4 `pumpkin_seeds`**, spawned at the block centre + 0.65 x the face normal with a small random motion, and costs 1 durability.
- **Beehive / bee nest** (`BeehiveBlock.useItemOn`): with shears at honey level 5: sound `block.beehive.shear`, rolls `harvest/beehive`: **3 `honeycomb`**, 1 durability, then **if no lit campfire is in the 5 blocks below the hive** (`CampfireBlock.isSmokeyPos`: a lit campfire 1 to 5 blocks below, with no solid cover between) the bees inside are released in emergency status and nearby bees (box inflated by 8 x 6 x 8 around the hive) are angered at the nearest player (`angerNearbyBees`) when the hive contains bees; if it is smoky only the honey level resets and the bees stay. With a `glass_bottle` at honey level 5 it fills a `honey_bottle` (bottle sound), with the same smoke rule.
- **Sheep**: Interact (0x1A) on an unsheared adult sheep: `Sheep.shear` plays `entity.sheep.shear`, sets sheared, and rolls the loot table `shearing/sheep/<colour>`: 1 to 3 of `<colour>_wool` (uniform), each as an item entity with a small random upward motion; 1 durability. Sheep regrow wool by eating grass (mob AI, 18-21).
- **Other entities**: `mooshroom` (`shearing/mooshroom/red`: 5 `red_mushroom`; brown: 5 `brown_mushroom`; the mooshroom becomes a cow), `snow_golem` (`carved_pumpkin` x1; the pumpkin head is removed), `bogged` (2 rolls from `brown_mushroom` and `red_mushroom`, 1 each, removing its mushrooms), equippable armor that sets `can_be_sheared` (wolf armor: the armor is removed with the `armor.unequip.wolf` sound). Entity behaviour: 18-21.
- Copper golems have a shearable item (tag `shearable_from_copper_golem`); entity logic: 18-21.

### 3.3 Flint and steel, fire charge

- **Flint and steel** (`FlintAndSteelItem.useOn`, 64 durability): Use Item On: if the block is a campfire, candle or candle cake for which `canLight` is true (the checks read are the `lit` and `waterlogged` properties) it sets `lit` to true (flags 11), plays `item.flintandsteel.use` (volume 1, pitch `nextFloat() x 0.4 + 0.8`), fires a game event and costs 1 durability. Otherwise it targets the block next to the clicked face: if `BaseFireBlock.canBePlacedAt` holds (the target is air and the fire state `canSurvive`; `FireBlock.canSurvive` tests that the block below has a sturdy top face, and `FireBlock.getStateForPlacement` also accepts flammable neighbours: the neighbour flammability numbers were not decoded) it places `BaseFireBlock.getState`: `soul_fire` when the block below passes `SoulFireBlock.canSurviveOnBlock` (blocks in the tag `soul_fire_base_blocks`), else the `FireBlock` placement state; plays the same sound and costs 1 durability. `FlintAndSteelItem` contains no water test; fire is placed only when `BaseFireBlock.canBePlacedAt` holds: the target block is air and (the fire state `canSurvive` there, or `isPortal` finds a valid portal location for it).
- **Fire charge** (`FireChargeItem.useOn`, consumed): the same light/place rules, sound `item.firecharge.use` (pitch `(nextFloat - nextFloat) x 0.2 + 1.0`), the stack shrinks by 1 (not in creative). Dispensed, it launches a small fireball (power 1.0, uncertainty 6.6666665).
- Both are in tag `creeper_igniters` (mob AI).

### 3.3a Flammability (`FireBlock.bootStrap`) and the fire tick constants

`FireBlock.bootStrap` registers (ignite odds, burn odds) per block; blocks absent from the list are not flammable. Read in full:

| (Ignite, burn) | Blocks |
|---|---|
| (5, 5) | every log, wood, stripped log and stripped wood of oak, spruce, birch, jungle, acacia, cherry, dark oak, pale oak, poplar, mangrove (10 families), `bamboo_block`, `stripped_bamboo_block`, `coal_block` |
| (5, 20) | planks, slabs, fence gates, fences, stairs of the 11 wood families (the ten above plus bamboo), `bamboo_mosaic`, `bamboo_mosaic_slab`, `bamboo_mosaic_stairs`, `mangrove_roots`, `composter`, `beehive` |
| (5, 100) | `pale_moss_block`, `pale_moss_carpet`, `pale_hanging_moss` |
| (15, 20) | `target` |
| (15, 60) | `cave_vines`, `cave_vines_plant` |
| (15, 100) | `tnt`, `vine`, `glow_lichen` |
| (30, 20) | `bookshelf`, `lectern`, `bee_nest`, the 11 wooden `_shelf` blocks |
| (30, 60) | all leaves (including poplar leaves), `dried_kelp_block`, `azalea`, `flowering_azalea`, `hanging_roots`, `straw_bed`, the whole `wool`, `wool_stairs` and `wool_slab` colour collections |
| (60, 20) | `hay_block`, every colour of `carpet` |
| (60, 60) | `bamboo`, `scaffolding` |
| (60, 100) | the short plants: grasses, ferns, dead bushes, tall flowers, all small flowers, `pink_petals`, `wildflowers`, `leaf_litter`, `cactus_flower`, `sweet_berry_bush`, `spore_blossom`, big and small dripleaf, `firefly_bush`, `bush` (41 blocks) |

**`FireBlock.tick`** (read from the bytecode, for a fire with `age` 0..15):
1. The fire reschedules itself with delay **30 + nextInt(10)** ticks (`getFireTickDelay`).
2. If `canSpreadFireAround` is false the tick ends (the fire stays); if the fire's `canSurvive` is false the fire is removed. `FireBlock.canSurvive` = (the block below has a sturdy top face) OR (`isValidFireLocation`: any of the six neighbours is flammable, i.e. `getIgniteOdds` > 0; a block whose `waterlogged` property is true counts as 0).
3. `infiniburn` = the block below is in the dimension type's `infiniburn` block tag.
4. If not infiniburn, it is raining and the fire is near rain (`isNearRain`): with probability (`nextFloat < 0.2 + 0.03 x age`) the fire is removed and the tick ends.
5. newAge = min(15, age + nextInt(3) / 2); if it differs the state is set (flags 260).
6. If not infiniburn: if `isValidFireLocation` is false (no flammable neighbour) the fire is removed when the block below has no sturdy top face **or** age > 3, and the tick ends; otherwise (a flammable neighbour exists) if age == 15 and `nextInt(4) == 0` and the block below cannot burn (`canBurn`: ignite odds 0), the fire is removed and the tick ends.
7. `increasedBurnout` = the dimension environment attribute `increased_fire_burnout`; b = -50 if true else 0.
8. `checkBurnOut` is called for the six neighbours with chance 300 + b (east, west, north, south) and 250 + b (below, above) and the fire's age. **`checkBurnOut(pos, chance, age)`**: if `nextInt(chance)` < the burn odds of the block at pos: then if `nextInt(age + 10) < 5` and it is not raining at pos, the block becomes fire with age min(15, age + nextInt(5) / 4); otherwise the block is removed; and if the block was TNT it is primed.
9. Spread: for dx, dz in -1..1 and dy in -1..4 except (0, 0, 0): bound = 100, plus (dy - 1) x 100 when dy > 1; o = `getIgniteOdds(level, pos)` of that position (0 unless it is an empty block; otherwise the maximum ignite odds of its six neighbours); if o > 0: chance = (o + 40 + 7 x difficultyId) / (age + 30), halved if increased burnout; if chance > 0 and `nextInt(bound) <= chance` and it is not raining near it, the position becomes fire with age min(15, age + nextInt(5) / 4).

### 3.4 Bone meal (`BoneMealItem`)

Use Item On (`BoneMealItem.useOn`, `growCrop`, `growWaterPlant`, read): if the clicked block is a `BonemealableBlock` for which `isValidBonemealTarget` holds: on the server, if `isBonemealSuccess` (a random test) passes `performBonemeal` runs, and the stack shrinks by 1 **whether or not it succeeded** (the shrink and Level Event 1505 with data 15 and the use vibration happen for every valid target on the server; the client side returns success without shrinking). Otherwise, if the clicked block's clicked face is sturdy, `growWaterPlant` is run on the **block adjacent to the clicked face** (it must be a full water block): 128 attempts; attempt i starts at that position and walks i / 16 steps (integer division), each step moving by (nextInt(3) - 1, (nextInt(3) - 1) x nextInt(3) / 2, nextInt(3) - 1) and abandoning the attempt if the block reached has a full-block collision shape; the planned plant is `seagrass`; in biomes of the tag `produces_corals_from_bonemeal`, attempt 0 with a horizontal clicked face picks a random block of the tag `wall_corals` (facing the clicked face), otherwise `nextInt(4) == 0` picks a random block of the tag `underwater_bonemeals`; a wall coral that cannot survive there tries up to 4 random horizontal facings; the plant is placed if the position is a full water block and the state can survive; if instead the block reached is already `seagrass` and a valid bone-meal target and `nextInt(10) == 0`, that seagrass is grown with `performBonemeal` (tall seagrass). After the loop the stack shrinks by 1 and the call reports success; Level Event 1505 is then sent. Per-crop growth is block behaviour, out of scope.

### 3.5 Brush (`BrushItem`, 64 durability; `BrushableBlockEntity`)

Use Item On a brushable block (suspicious sand or gravel) starts using the item (use duration 200 ticks, animation brush). `onUseTick` ray-casts the target block within `blockInteractionRange` (releasing the item when the ray misses); on the tick whose remaining counter satisfies the read constants (10, 5) it plays `item.brush.brushing.generic` (or the block's own brush sound) and calls the block entity's `brush(gameTime, player, hitDirection)`; the client spawns 7 to 12 block-dust particles. The block entity (read constants) needs **10 brushes** (`REQUIRED_BRUSHES_TO_BREAK`), with a **10-tick** cooldown between counted brushes (`BRUSH_COOLDOWN_TICKS`) and a progress reset after **40 ticks** without brushing (`BRUSH_RESET_TICKS`; it schedules a block tick of 40); the block's `dusted` state follows the brush count (0 brushes: 0; 1 to 2: 1; 3 to 5: 2; 6 or more: 3), and every counted brush schedules a block tick of 2, at 10 `brushingCompleted` sends level event 3008 (block id), turns the block into the block it `getTurnsInto` (sand or gravel, or air if none), and `dropContent` drops the item rolled from the block's loot table (`unpackLootTable`, at most 1 item; the player's luck is the loot luck): spawned beside the block on the face the player brushed, speed 0.1 x random. Durability: `BrushableBlockEntity.brush` returns true only on the call that completes the block (the 10th counted brush); only then does `BrushItem.onUseTick` damage the brush by 1 (`hurtAndBreak(1)` on the hand slot in use), so a brush loses 1 durability per completed block, not per brush.

### 3.6 Shield and blocking (`blocks_attacks` of the shield)

Shield data (`Items` lambda for `blocks_attacks`): `block_delay_seconds` 0.25 (5 ticks), `disable_cooldown_scale` 1.0, damage reductions = one entry (`horizontal_blocking_angle` 90 degrees, any damage type, base 0, factor 1), item damage function (threshold 3.0, base 1.0, factor 1.0),
`bypassed_by` = damage tag `bypasses_shield`, block sound `item.shield.block`, disable sound `item.shield.break`.

Raising: Use Item (0x43) with a shield in a hand starts "using the item"; use duration 72000. Blocking only counts once the item has been used for at least `block_delay_ticks` = 5 ticks (`LivingEntity.getItemBlockingWith`). Sneaking is not required. The off-hand shield is also raised by right-click with an empty main hand.

Resolution of an incoming hit (`LivingEntity.applyItemBlocking`, run inside `hurtServer` before anything else, 4.2):
1. Not blocking (no item, delay not reached) or the damage source is in `bypasses_shield`, or the direct entity is an arrow with piercing level > 0: no block, 0 damage blocked.
2. Angle: if the source has a position, the angle (radians) between the horizontal head-facing direction (`calculateViewVector(0, headYaw)`) and the horizontal direction from the blocker to the source position, `acos(dot)`; if the source has no position the angle is pi (never blocked). The reduction applies only if the angle is **<= 90 degrees** (angle x 0.017453292 compared against 90 x 0.017453292: the half-plane in front).
3. Blocked damage = clamp(sum over reductions of clamp(base + factor x damage, 0, damage), 0, damage); with the shield's single entry that is the **whole damage** (all of it). The remaining damage is damage - blocked (0 for a shield, so a blocked hit does no damage, no hurt animation sound; a `block` sound plays, pitch `0.8 + nextFloat x 0.4`).
4. Shield durability: `item_damage_function.apply(damage)`: 0 if damage < 3.0, else floor(1.0 + 1.0 x damage); `hurtAndBreak` on the shield, in the hand that is raised (so damage 3.0 costs 4 durability, damage 8 costs 9).
5. If something was blocked, the damage source is not in `is_projectile`, and its direct entity is a living entity, `blockUsingItem(attacker, ..., fullyBlocked)` runs with fullyBlocked = (blocked damage >= incoming damage); `LivingEntity.blockedByItem` then pushes the **attacker** with `knockback(0.5, attacker.x - blocker.x, attacker.z - blocker.z)` (the 4.6 steps, the attacker's resistance applies) only when the block did **not** absorb the whole hit (fullyBlocked false). With the shield's single reduction (base 0, factor 1) a hit in the blocking cone is always fully blocked, so a shield by itself causes no push-back. For a player blocker `Player.blockUsingItem` then also applies rule 6 below.
6. A hit **from a weapon with `disable_blocking_for_seconds` > 0** (every axe, 5.0 s) disables the shield: `BlocksAttacks.disable(...)` gives the shield item a cooldown of round(seconds x 20 x `disable_cooldown_scale`) = **100 ticks**, stops the use, and plays `item.shield.break` at the blocker (pitch `0.8 + nextFloat x 0.4`). While on cooldown the shield cannot be raised (cooldown, section 1.3). The weapon's seconds come from `LivingEntity.getSecondsToDisableBlocking` (the attacker's weapon item).
Statistics: `damage_blocked_by_shield` is incremented by round(blocked x 10) for a player. Banner patterns: `banner_patterns` is the component that stores the shield's pattern layers; applying a banner (crafting) copies them (14 does not cover banners; no gameplay effect).

### 3.7 Lead, name tag, saddle

- **Lead** (`LeadItem.useOn`): Use Item On a block in the block tag `fences`: `bindPlayerMobs` finds the leashable entities near the fence (`Leashable.leashableInArea` around the block centre), attaches those that `canHaveALeashAttachedTo` and are leashed to this player to a `leash_knot` entity (`LeashFenceKnotEntity.getKnot`, created if absent). The search box is a cube of side 32 (+-16) centred on the fence block centre (`Leashable.leashableInArea`), and only entities whose current leash holder is this player are bound (`bindPlayerMobs` filters on `getLeashHolder`); leash constants: breaks beyond 12.0 blocks and stretches elastically beyond 6.0 (`LEASH_TOO_FAR_DIST`, `LEASH_ELASTIC_DIST`), plays the knot placement sound and a game event. Interacting with mobs is entity logic (18-21).
- **Name tag** (`NameTagItem.interactLivingEntity`): Interact (0x1A) on a living entity of a type that `canSerialize` when the stack has a `custom_name` (set in an anvil): sets the entity's custom name, sets the mob's persistence flag (it will not despawn), consumes 1 tag (not in creative).
- **Saddle**: `equippable` with `equip_on_interact` and allowed entities = tag `can_equip_saddle` (horses, pigs, striders, camels and so on): Interact on such a mob (saddle slot empty) moves one saddle in (`Equippable.equipOnTarget`, plays the equip sound, 1 split off the stack). Riding is entity logic.

### 3.8 Buckets (`BucketItem`, `SolidBucketItem`, `MobBucketItem`)

Read facts (the surrounding algorithms were read as listed; deeper branches such as dispenser use are out of scope):
- Empty `bucket` has max stack 16; `water_bucket`, `lava_bucket`, `powder_snow_bucket`, `milk_bucket` and mob buckets stack to 1; the filled ones have craft remainder `bucket` (`lava_bucket` is fuel).
- `BucketItem.use` ray-traces to a block (`BlockHitResult`), requires `Level.mayInteract` and `Player.mayUseItemAt` for the target and for the position next to the hit face, then for an empty bucket calls `BucketPickup.pickupBlock` on the block, and on success replaces the held bucket via `ItemUtils.createFilledResult` (creative keeps the stack) and plays a pickup sound; for a filled bucket it calls `emptyContents`.
- `emptyContents`: the placement position is the clicked block when it can be replaced or is a `LiquidBlockContainer` that accepts the fluid, otherwise the block beside the clicked face; sneaking (`isShiftKeyDown`) is consulted in the replace test. If the dimension environment attribute `water_evaporates` is true, water is not placed (a sound plays and the contents are spent). Otherwise the fluid block is set (flags 11) or a container is waterlogged, the sound is `item.bucket.empty` (`..._lava` for lava) and the bucket becomes `bucket` (`getEmptySuccessItem`; creative keeps the stack).
- `SolidBucketItem` (`powder_snow_bucket`): Use Item On places its block like a block item and returns an empty bucket.
- `MobBucketItem`: empties the water, and spawns the entity type from `bucket_entity_data` (`Bucketable.loadFromBucketTag`, flagged `setFromBucket`) with its ambient sound.
- `milk_bucket` carries `consumable` = the default drink (`defaultDrink`: 1.6 s, drink sound, no consume particles) with the single on-consume effect `ClearAllStatusEffects` (removes every status effect), and `use_remainder` bucket (read in `Consumables`).

### 3.9 Bow and crossbow (projectile weapons)

**Bow** (`BowItem`, 384 durability):
- Use Item (0x43) starts using the bow only if the player has a projectile available (`getProjectile`: first the off-hand then any inventory slot, for items in tag `arrows`: `arrow`, `tipped_arrow`, `spectral_arrow`) or has infinite materials (creative). Use duration 72000 ticks; animation bow; the player slows to `use_effects` default (speed x 0.2, no sprinting, 13 §1.1).
- On release (Player Action `RELEASE_USE_ITEM`, 6) with t = ticks used: **power** p = min((f x f + 2f) / 3, 1.0) with f = t / 20 (that is 20 ticks = 1.0 s for full power); if p < 0.1 nothing is shot and nothing is consumed. Otherwise one projectile is drawn from the stack (the ammo count decreases by 1 unless the Infinity effect applies, 6.3, or in creative); an arrow is created (the held arrow type), **velocity = 3.0 x p**, **inaccuracy 1.0**, critical flag when p == 1.0 exactly, and the bow takes 1 durability (`getDurabilityUse` is 1 per projectile).
  Shooting direction = the player's rotation (pitch, yaw) with zero extra pitch offset; initial velocity = (look direction normalised + each component `RandomSource.triangle(0, 0.0172275 x inaccuracy)`) x velocity (`Projectile.getMovementToShoot`); plus the shooter's known movement without the vertical component if on ground (`shootFromRotation` adds the shooter's horizontal speed: it adds `getKnownMovement` x/z and y only when not on ground).
  Sound `entity.arrow.shoot` at volume 1.0 and pitch `1.0 / (nextFloat x 0.4 + 1.2) + p x 0.5`; stat `item_used` +1.
- **Draw table** (p = (f x f + 2f)/3): t=5: f=0.25, p=0.2917, velocity 0.875; t=10: p=0.4167, v 1.25; t=15: p=0.6458, v 1.9375; t=20: p=1.0 (crit), v 3.0; t >= 20 stays 1.0.
- Flame: the projectile is ignited for 100 ticks (`projectile_spawned` effect). Power, Punch: 6.3.
**Arrow entity** (`AbstractArrow`): base damage 2.0 (`baseDamage`; save-data field `damage`), gravity 0.05/tick, air drag factor 0.99 per tick on velocity, water drag 0.6 (arrow) / 0.99 (thrown trident);
life in the ground 1200 ticks then despawns (`tickDespawn`); `playerTouch` calls `tryPickup`, which depends on an `AbstractArrow$Pickup` mode and adds the pickup item to the inventory (`Inventory.add`), with the take animation (Take Item Entity 0x7F); `AbstractArrow$Pickup` has three values: `DISALLOWED`, `ALLOWED`, `CREATIVE_ONLY` (`tryPickup` switches on the ordinal: `ALLOWED` adds the item to the inventory, `CREATIVE_ONLY` only succeeds for a player with infinite materials, `DISALLOWED` never; which mode a shot arrow gets: the shooter's weapon code, not traced).
**Damage on hit** (`onHitEntity`): `speed` = length of the arrow's velocity (blocks/tick), `base` = enchantment-modified base damage (`EnchantmentHelper.modifyDamage`, the bow's Power adds to it, 6.3) as float, **damage = ceil(clamp(speed x base, 0, 2147483647))** (an int). For piercing arrows (pierce level > 0) the entity is added to an "already hit" set first and the arrow keeps flying until the set has pierce+1 entries (then it is discarded). If the arrow is a crit arrow: **damage = min(damage + nextInt(damage / 2 + 2), 2147483647)** (`nextInt(bound)`, the integer division). The owner's `lastHurtMob` is set; a burning arrow ignites the target for 5 s if the target is not already fire-immune; then `hurtOrSimulate(damageSource arrow (or the owner-attributed `arrow` source), damage)`; on success a living target increments its stuck-arrow count (non-piercing, server only), gets `doKnockback` (the arrow's knockback value from Punch: horizontal push = `knockback x 0.6` scaled by (1 - knockback resistance), with an additional +0.1 up when the horizontal speed is tiny; formula in 4.6), post-attack enchantment effects run, `doPostHurtEffects` (a tipped arrow applies each effect of its `potion_contents` through `PotionContents.forEachEffect(consumer, potion_duration_scale)`, the scale being the arrow's `potion_duration_scale` component, 0.125 for the tipped arrow item), and a player shooter hears the `play_arrow_hit_sound` Game Event (0x27, value 0) when not silent.
On a block hit the arrow sticks, plays `entity.arrow.hit` (pitch `1.2 / (nextFloat x 0.2 + 0.9)`), and `shake` ticks run.
- A **spectral arrow** (`SpectralArrow.doPostHurtEffects`) gives the hit entity Glowing (amplifier 0) for its `duration` field (default 200 ticks, `DEFAULT_DURATION`). A **tipped arrow** carries `potion_contents`.
**Crossbow** (`CrossbowItem`, 465 durability):
- Use (0x43): if the crossbow is charged (`charged_projectiles` not empty) it fires immediately (`performShooting`); else it starts charging if a projectile is available.
- Charge time = floor(20 x `getChargeDuration`), where `getChargeDuration` = 1.25 s modified by the `crossbow_charge_time` effect (Quick Charge adds -0.25 s per level, 6.3): 25, 20, 15, 10 ticks for Quick Charge 0 to 3. Use Item starts charging when a projectile is available; `CrossbowItem.releaseUsing` performs no load or shot itself: it only returns whether `getPowerForTime` (use ticks / charge duration, clamped to 1) is >= 1 and the item is already charged, so releasing early simply stops using the item without loading. On completion `tryLoadProjectiles` moves the ammunition (arrow or `firework_rocket`) into `charged_projectiles`, with the projectile count from `processProjectileCount` (Multishot 3). Infinity's `ammo_use` effect matches only the item `arrow` and the crossbow's own enchantment set excludes Infinity, so it does not apply here.
- Charging sounds: start `item.crossbow.loading_start` (or the Quick Charge start sound 1..3), middle `item.crossbow.loading_middle` at 50% (0.5 of the duration: the progress compare uses 0.2 and 0.5 thresholds in `onUseTick`), end `item.crossbow.loading_end`.
- Firing power: **3.15** for arrows, **1.6** for fireworks; inaccuracy 1.0 and shot sound pitch from `getShotPitch` (the first shot 1.0; multishot extras use a random pitch `nextFloat x 0.5 + 0.43` style values 0.63, 0.43, 0.5, 1.8 read in `getRandomShotPitch`).
- Multishot: 3 projectiles in total (`projectile_count` +2); `projectile_spread` is 10 degrees. For n projectiles the angular step is 2 x spread / (n - 1) (0 if n = 1); projectile i (0 based) is rotated about the up axis by an offset that alternates sign: with n = 3 the offsets are **0, -10, +10 degrees** in that order (the first projectile is the one drawn first). Durability use: 1 per shot, **3 when the projectile is a firework rocket** (`getDurabilityUse`).
- Piercing: arrows get `pierce_level` +1 per level (6.3).
- Crossbow arrows use the same damage formula as bow arrows, with the speed taken from the arrow's actual velocity (shot at 3.15). `ProjectileWeaponItem.createProjectile` sets the crit flag from its `isCrit` argument; the crossbow's `createProjectile` passes the constant 1 (true) to it (read), so crossbow arrows are crit arrows.
- A firework rocket fired from a crossbow explodes with its explosion data; damage 3.13.

### 3.10 Trident (`TridentItem`, 250 durability)

- Melee: attack damage 9 (1 + 8) speed 1.1 (cooldown 18.2 ticks) when held; damage type `trident` for the thrown entity, `player_attack` for melee.
- Throw: Use Item then release (Player Action 6) after the use time **>= 10 ticks** (`TridentItem.releaseUsing` constant 10); a throw also requires that the trident would not break (`nextDamageWillBreak` false) and, with Riptide, that the player is in water or rain. Without Riptide: the trident entity is spawned with **velocity 2.5** (`spawnProjectileFromRotation(..., 2.5, 1.0)`), the item takes 1 durability (`hurtWithoutBreaking`), `item.trident.throw` plays, and the stack is consumed from the hand (creative keeps it).
- **Thrown trident** (`ThrownTrident`): base damage **8.0** (`onHitEntity` constant), then enchantment modification (Impaling, 6.3), damage type `trident`; water drag 0.99 (`getWaterInertia`); `inGroundTime > 4` sets `dealtDamage`. `onHitEntity` sets `dealtDamage`, hurts the entity (`hurtOrSimulate`), runs the post-attack enchantment effects, knockback and `doPostHurtEffects` for a living target, plays `item.trident.hit` and deflects the trident with `ProjectileDeflection.REVERSE` using the vector (0.02, 0.2, 0.02); on a block it sticks (`item.trident.hit_ground`).
- **Loyalty** (`ThrownTrident.tick`, read): with loyalty level L > 0 (the synced `ID_LOYALTY` byte), when `dealtDamage` is set or the trident has `noPhysics`, and the owner exists: if the owner is not an acceptable return target (`isAcceptibleReturnOwner`: not alive or a spectator) the trident is discarded, dropping its pickup item (offset 0.1) when the pickup mode is `ALLOWED`; otherwise `noPhysics` is set (no collisions), the vector v = owner eye position - trident position is computed, the trident's y is raised by v.y x 0.015 x L, its velocity becomes velocity x 0.95 + normalize(v) x 0.05 x L, and `item.trident.return` plays once (volume 10.0). A non-player owner within (bbWidth + 1) of the trident's position makes it discard.
- **Riptide** (`trident_spin_attack_strength` = 1.5 + 0.75 per level above the first, units: strength): thrown by the player while in water/rain: the player is launched: the look vector (x, y, z) is normalised and multiplied by s (`Player.push`), then `Player.startAutoSpinAttack(20 ticks, 8.0 damage, the item)` runs (constants read in `TridentItem.releaseUsing`); if the player is on the ground it is first moved up 1.2 blocks (`move(SELF, (0, 1.2, 0))`). Release requires use time >= 10 ticks; a spin strength > 0 requires in water or rain and not riding; the stack must not break from the use; the player does `autoSpinAttackDmg` (8.0) to entities touched during the spin (`doAutoAttackOnTouch`), the trident is not thrown, durability 1. Sounds are `item.trident.riptide_1..3` by level.
- **Channeling** (6.3): when the trident entity hits an entity in a thunderstorm with the sky visible (and the direct attacker is a trident), or a block in the tag `lightning_rods` under thunder with sky access, a lightning bolt is summoned and `item.trident.thunder` (volume 5.0) plays.

### 3.11 Fishing rod (`FishingRodItem` + `FishingHook`, 64 durability)

- Use Item (0x43) with no hook out: casts: a `FishingHook` is created (`FishingHook(player, level, luck, lure)`, read): with yaw Y and pitch P (radians), let c1 = cos(-Y - pi), s1 = sin(-Y - pi), c2 = -cos(-P), s2 = sin(-P). The hook starts at (player.x - s1 x 0.3, player eye y, player.z - c1 x 0.3) with the player's yaw and pitch. The launch vector is v = (-s1, clamp(-(s2 / c2), -5, 5), -c1); with len = |v|, each component is multiplied by an independent factor 0.6 / len + 0.5 + `triangle(0, 0.0103365)`. The cast stores the Lure value (`fishing_time_reduction`) and the Luck of the Sea value (`fishing_luck_bonus`); sound `entity.fishing_bobber.throw` (volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`).
- Use Item with a hook out: `FishingHook.retrieve(rod)` removes the hook and returns the **durability cost**, which the rod takes (`hurtAndBreak`): (values read in `FishingHook.retrieve`:) **3** if the hook was attached to an item entity, **5** if attached to any other entity (the entity is pulled and Entity Event 31 is broadcast), **1** if a fish was biting (loot given), and **2** if the bobber is resting on the ground (this overrides the others); 0 otherwise. Sound `entity.fishing_bobber.retrieve` (volume 1.0, pitch `0.4 / (nextFloat x 0.4 + 0.8)`).
- **Physics and states** (`FishingHook.tick`, read): the hook has states FLYING, HOOKED_IN_ENTITY and BOBBING. Gravity 0.03 per tick (`getDefaultGravity`). Each tick: the hook is discarded when its owner is missing (a server-side `shouldStopFishing` check also ends it); if it is on the ground its `life` counter increases and the hook is discarded at 1200, otherwise `life` is 0. FLYING: if an entity is hooked, the velocity becomes 0 and the state HOOKED_IN_ENTITY; else if the block at the hook has water (`FluidTags.water`, fluid height > 0) the velocity is multiplied by (0.3, 0.2, 0.3) and the state becomes BOBBING; otherwise `checkCollision` (projectile hit test). HOOKED_IN_ENTITY: if the entity is gone, no longer interactable or in another dimension the hook returns to FLYING, else it follows the entity at 0.8 of its height. BOBBING: e = hook y + vy - blockY - fluidHeight; if |e| < 0.01 then e += signum(e) x 0.1; the new velocity is (vx x 0.9, vy - e x nextFloat x 0.2, vz x 0.9); while a fish is biting an extra (0, -0.1 x r1 x r2, 0) with two nextFloat is added; then `catchingFish` runs (server only, below). The `openWater` flag is recomputed only while the hook is not yet nibbling (`nibble` <= 0 and `timeUntilHooked` <= 0) and the hook has been out of water fewer than 10 ticks (`outOfWaterTime`): **`calculateOpenWater`** looks at four horizontal 5 x 5 layers (x and z from -2 to +2 around the hook's block) at y offsets -1, 0, 1, 2; a layer's type is ABOVE_WATER if all its blocks are air or lily pads, INSIDE_WATER if all are water source blocks with an empty collision shape, otherwise INVALID (types merge by equality: two equal types give that type, otherwise INVALID, `lambda$getOpenWaterTypeForArea$0`); scanning the layers bottom to top it fails on an INVALID layer, on an ABOVE_WATER first layer, or on an INSIDE_WATER layer that follows an ABOVE_WATER layer; so open water means water below and air above with no obstruction, and the treasure branch of the loot table needs it (the random seed of the hook's own random: reseeded every tick from its UUID and the game time).
- **Bite timer** (`catchingFish`, run once per tick while in water; `amount` = 1 per tick): first a modifier: if it is raining at the position above `nextFloat < 0.25` adds 1 more ticks per tick (amount 2); if the sky is not visible `nextFloat < 0.5` removes 1 (amount 0). States, evaluated in this order each tick:
  1. **Nibbling** (`nibble` > 0): decrement; at 0 the bite ends: `timeUntilLured`, `timeUntilHooked` and `nibble` are 0 (the fish got away).
  2. **Fish on its way** (`timeUntilHooked` > 0): `timeUntilHooked -= amount`; while > 0 the fish angle rotates by `triangle(0, 9.188)` degrees and bubble/fishing particles appear (the bubble/fishing particle probability is 0.15 base, raised by (20 - t) x 0.05 when t < 20, else by (40 - t) x 0.02 when t < 40, else by (60 - t) x 0.01 when t < 60, t = `timeUntilHooked` (inferred from the read constant layout 0.15; 20, 20, 0.05; 40, 40, 0.02; 60, 60, 0.01); purely cosmetic); when it reaches 0: the bobber is pulled down (its vertical velocity is set negative; the magnitude was not decoded), `entity.fishing_bobber.splash` plays (volume 0.25, pitch `1.0 + (nextFloat - nextFloat) x 0.4`), a splash particle burst appears, and `nibble = Mth.nextInt(random, 20, 40)` (**inclusive** at both ends, that is `RandomSource.nextInt(40 - 20 + 1) + 20`, so 20..40): **the player can reel in during these 20 to 40 ticks to catch** the loot.
  3. **Fish being lured** (`timeUntilLured` > 0): `timeUntilLured -= amount`; when it reaches 0: choose a random fish angle (`nextFloat x 360`), a position at distance 25..60 (`Mth.nextFloat(25, 60)`) around the bobber, and set `timeUntilHooked = Mth.nextInt(random, 20, 80)` (inclusive, 20..80).
  4. **Waiting**: `timeUntilLured = Mth.nextInt(random, 100, 600) - lureSpeed` (inclusive, 100..600; `lureSpeed` = the Lure value stored at the cast, `fishing_time_reduction` x 20 ticks); Lure gives `fishing_time_reduction` = 5 per level, so 100 ticks per level (Lure III: -300).
  (Without Lure the expected wait before the fish starts to nibble is the mean of the two uniform draws: 350 + 50 = 400 ticks; `Mth.nextInt(random, min, max)` is inclusive at both ends in this document wherever written that way, unlike `RandomSource.nextInt(bound)`, which is exclusive of `bound`.)
- **Reeling a caught fish** (`retrieve`, nibble active): rolls the loot table `gameplay/fishing` with parameters (hook position, tool = the rod, the hook entity, the player's `luck` attribute + `fishing_luck_bonus`), spawns each resulting item as an item entity at the hook position with motion toward the player: `(player - hook) x 0.1` per component, plus `sqrt(distance) x 0.08` upward (`0.1, 0.1, 0.1` and `0.08` read); spawns an experience orb: **`nextInt(6) + 1`** XP (the `6` and `1` constants read) at (player x, player y + 0.5, player z + 0.5) (no offset in x); fish (tag `fishes`) increments the `fish_caught` stat; the rod takes 1 durability.
- **Loot** (`loot_table/gameplay/fishing`): one roll among three sub-tables by `weight + quality x luck`: `junk` weight 10 quality -2, `treasure` weight 5 quality **+2** and **only when the hook is in open water**, `fish` weight 85 quality -1; a weight of an entry is `max(0, floor(weight + quality x luck))`.
  Without luck: fish 85, junk 10, treasure 5 (of 100); with Luck of the Sea III (luck 3): junk 10 - 6 = 4, treasure 5 + 6 = 11, fish 85 - 3 = 82 (of 97).
  - `fish` (one roll, weights): `cod` 60, `salmon` 25, `pufferfish` 13, `tropical_fish` 2.
  - `junk` (one roll): `lily_pad` 17, `leather_boots` 10 (damage uniform 0..0.9 of its durability), `leather` 10, `bone` 10, `potion` (water bottle) 10, `string` 5, `fishing_rod` 2 (damage uniform 0..0.9), `bowl` 10, `stick` 5, `ink_sac` weight 1 (count 10), `tripwire_hook` 10, `rotten_flesh` 10, `bamboo` 10 (only in jungle, sparse jungle and bamboo jungle biomes).
  - `treasure` (one roll, equal weight 1 each): `name_tag`, `saddle`, `bow` (damage uniform 0..0.25, enchant with 30 levels from the tag `on_random_loot`), `fishing_rod` (same enchant), `book` (enchant with 30 levels, from `on_random_loot` giving an enchanted book), `nautilus_shell`.
- Hooked entity: Entity hit by the bobber is hooked (`setHookedEntity`) and is pulled toward the player by `pullEntity` (motion += (player - entity) x 0.1) when retrieved.

### 3.12 Spears (kinetic weapon) and the jab

A spear has two attacks. **Jab**: `ServerGamePacketListenerImpl.handleAttack` returns immediately when the main-hand item has the `piercing_weapon` component, so the Attack packet (0x01) never runs the 4.2 pipeline for a spear. The jab is Player Action `STAB` (ordinal 8, 05c), which calls `PiercingWeapon.attack(attacker, slot)` (read): damage = the attacker's `attack_damage` attribute value; the targets are every entity along the item's `attack_range` ray (`ProjectileUtil.getHitEntitiesAlong`, filtered by `canHitEntity`: alive, not invulnerable to piercing weapons, hittable by projectiles, `canHarmPlayer` for players, not a passenger of the same vehicle); for each one `stabAttack(slot, entity, damage, true, deals_knockback, dismounts)` runs; then `onAttack`, `postPiercingAttack` (Lunge), the hit sound if anything was hit, the attack sound, and a main-hand swing that resets the attack strength (`swingAndResetAttackStrength`); `minimum_attack_charge` 1.0 refuses the jab until the attack strength is full (4.1). Reach 2.0 to 4.5 (`attack_range`, 1.3); damage type `spear` (no knockback of its own: `no_knockback`; the knockback of `stabAttack` is below). Item damage: each `stabAttack` goes through `itemAttackInteraction`, whose `ItemStack.postHurtEnemy` applies the `weapon` component's `item_damage_per_attack` (1 for spears) per entity hit; a charge hit uses the same `stabAttack`, so it costs the same 1 per entity stabbed.
**Charge attack** (kinetic): Use Item starts using the item (use duration 72000 since the item has `kinetic_weapon`; `use_effects` lets the player sprint and keep full speed). Every tick of use (`KineticWeapon.damageEntities`, after `delay_ticks` of use have passed): the attacker's look-vector projection of its speed and of each target's speed are compared; every entity found along the attack range's ray (`ProjectileUtil.getHitEntitiesAlong`, dragon parts collapse to the dragon) that was not stabbed in the last `contact_cooldown_ticks` (10) is evaluated: with `scale` = 1.0 for players and 0.2 for non-player attackers, relative speed r = max(0, attacker speed along look - target speed along look); each of the three conditions (dismount, knockback, damage) passes when ticks since delay <= max_duration_ticks AND attacker speed >= min_speed x scale AND (r >= min_relative_speed x scale). If at least one passes, `stabAttack(slot, target, damage, dealsDamage = damage condition, knockback = knockback condition, dismount = dismount condition)`, with damage = the attacker's **base** attack_damage attribute value + floor(r x damage_multiplier m) (`Mth.floor`). Durability use follows 5.1.
`stabAttack` (`Player.stabAttack`): refused if the entity cannot be attacked; computes `getEnchantedDamage`; scales by (attack strength 1 when using the item in that slot, else attack strength) and `baseDamageScaleFactor`; first `deflectProjectile`; if `dealsDamage` it calls `hurtOrSimulate(source, damage)`; knockback = 0.4 plus `getKnockback` through `causeExtraKnockback` only when the knockback condition passed; dismount: if the target is a passenger and not in tag `cannot_be_dismounted_by_item_usage`, it stops riding; then visual effects, `itemAttackInteraction`, `damageStatsAndHearts`, and **0.1 exhaustion**. The speeds are **blocks per second**: `KineticWeapon.getMotion` takes the entity's known speed (the controlling root vehicle's when riding) in blocks per tick and multiplies it by 20.
The Lunge enchantment (6.3) adds, after a piercing attack, an impulse of 0.458 x L along the player's look direction with the vertical part removed (6.3), exhaustion 4.0 x L and 1 extra item damage; it requires: not riding, not gliding, not in water, and (not a player, or creative, or food level >= 7).

### 3.13 Elytra and fireworks

- Elytra: components `glider`, chest `equippable` (`damage_on_hurt` false), durability 432, repair `phantom_membrane`. `canGlide` is false with Levitation; `canGlideUsing(stack, slot)` needs the `glider` component, the `equippable` slot to match, and `nextDamageWillBreak` false. `startFallFlying` / `tryToStartFallFlying` begin gliding (Player Command 0x2A `START_FALL_FLYING`, 05c, makes the server call `tryToStartFallFlying`: it succeeds when the player is not already gliding, `canGlide` holds and the player is not in liquid, then sets the shared flag 7).
- Flight step (`LivingEntity.updateFallFlyingMovement`, read; v = velocity, L = look vector, p = pitch in radians, lh = horizontal length of L, vh = horizontal length of v, g = effective gravity (attribute `gravity`, 0.08)): (1) c = cos(p)^2 and v.y += g x (-1 + c x 0.75); (2) if v.y < 0 and lh > 0: a = v.y x -0.1 x c and v += (L.x x a / lh, a, L.z x a / lh); (3) if p < 0 (looking up) and lh > 0: b = vh x (-sin p) x 0.04 and v += (-L.x x b / lh, b x 3.2, -L.z x b / lh); (4) if lh > 0: v += ((L.x / lh x vh - v.x) x 0.1, 0, (L.z / lh x vh - v.z) x 0.1); (5) v = v x (0.99, 0.98, 0.99). The result replaces the normal travel step each tick while gliding.
- Durability: `updateFallFlying` runs on the server every tick of gliding with the glide counter n = fallFlyTicks + 1; when n is a multiple of 10 and (n / 10) is even (constants 10 and 2 read) it calls `hurtAndBreak(1)` on one randomly chosen worn glider, which is 1 durability per 20 ticks of flight.
- **Firework rocket** (`FireworkRocketItem`): Use Item while gliding spawns a `FireworkRocketEntity` owned by the player and consumes one; Use Item On a block spawns it at the click point offset 0.15 x the face normal. The rocket starts with velocity (`triangle(0, 0.002297)`, 0.05, `triangle(0, 0.002297)`); **lifetime = 10 x (flight_duration + 1) + nextInt(6) + nextInt(7)** ticks (read in the constructor). While its owner is gliding each tick it adds to the owner's velocity: look x 0.1 + (look x 1.5 - velocity) x 0.5 (constants 0.1, 1.5, 0.5). When `life` exceeds the lifetime it sends Entity Event 17 and `dealExplosionDamage`: base 5.0 plus 2 per explosion effect, to living entities within 5.0 blocks (25.0 squared distance) that pass a line-of-sight clip test, damage type `fireworks`.

### 3.14 Compass types and the spyglass

- `compass` points at the world spawn point (client item property; the clientbound Set Default Spawn Position 0x63 supplies it, 05b). `recovery_compass` points at the last death position (`ServerPlayer.die` stores a global position; the item's pointing logic was not read).
- Lodestone: Use Item On a `lodestone` block with a compass plays `item.lodestone_compass.lock` and converts one compass (the stack is split; creative keeps the stack) into a compass with `lodestone_tracker` = (global position of the lodestone in its dimension, tracked true): the item's name becomes "Lodestone Compass" and it shows the enchantment glint. `inventoryTick` re-validates the target each tick while the item is in an inventory (`LodestoneTracker.tick`: if the lodestone block is gone, the tracker is cleared).
- Spyglass: Use Item starts a use of 1200 ticks (plays `item.spyglass.use`); while used, the camera zooms (client; 12). Releasing plays `item.spyglass.stop_using`. No server stats beyond `item_used`.

### 3.15 Ender pearl, snowball, egg, wind charge, thrown potions

All four are thrown on Use Item (0x43): the projectile starts at the eye with `spawnProjectileFromRotation(speed, inaccuracy)`; sound at volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`; the stack shrinks by 1 (not in creative); stat `item_used`.

| Item | Speed | Inaccuracy | On hit |
|---|---|---|---|
| `ender_pearl` | 1.5 | 1.0 | cooldown 1.0 s on all pearls; on impact (entity or block) 32 portal particles; teleports the **owner** if still valid (`isAllowedToTeleportOwner`: alive, not sleeping, same dimension, connection accepting messages) to the impact point and resets its fall distance; the owner takes **5.0 damage** of type `ender_pearl` (a fall-type source: bypasses armor, 4.4); 5% chance (`nextFloat < 0.05`) to spawn an `endermite` at the destination when the level spawns monsters; sound `entity.player.teleport`; a pearl hitting an entity hurts it with `thrown` for 0.0 |
| `snowball` | 1.5 | 1.0 | `Snowball.onHitEntity` hurts with `thrown` for **3** if the entity is a blaze, else **0**; `onHit` broadcasts Entity Event 3 (particles) and the snowball is removed |
| `egg` | 1.5 | 1.0 | `ThrownEgg.onHitEntity` hurts for 0 (`thrown`); `onHit` (server): if `nextInt(8) == 0`, spawn a chicken (4 if `nextInt(32) == 0`), each with age -24000 (a baby) and the egg's `chicken_variant`; Entity Event 3 |
| `wind_charge` | 1.5 | 1.0 | `use_cooldown` 0.5 s; `AbstractWindCharge.onHitEntity` hurts with `wind_charge` for **1.0** and runs post-attack effects; the burst is a `Level.explode` of radius 1.2 (`WindCharge.explode`) using an explosion calculator with knockback multiplier 1.22 and the immune-block tag `blocks_wind_charge_explosions`, particles gust small/large, sound `entity.wind_charge.wind_burst` |
| `splash_potion` | 0.5, with a -20 degree pitch offset | 1.0 | shatters on any hit (`AbstractThrownPotion.onHit`; level events 2002 or 2007 with the potion colour, 1053/1054 sounds): every `LivingEntity` in the box around the impact inflated by (4, 2, 4) whose bounding box (grown by `ProjectileUtil.computeMargin`) is within squared distance 16.0 of the impact box gets intensity t = 1 - sqrt(distanceSquared) / 4; an instantaneous effect is applied with `applyInstantaneousEffect(..., amplifier, t)`; any other effect has its duration mapped to (int)(duration x t x `potion_duration_scale` + 0.5) (`mapDuration`, constant 0.5) and is applied unless it would end within 20 ticks (`endsWithin(20)`). Water bottles (potions with the douses-fire property): extinguish burning entities in the box, hurt entities sensitive to water for 1.0 with `indirect_magic`, douse fire blocks, lit candles and campfires in the area (`douseFire`), rehydrate axolotls |


### 3.16 Block loot and tools

The block's loot table (11 §9.2 gives the ore forms) is rolled with the tool in the context, and its conditions test: `tool/can_silk_touch` (the `silk_touch` enchantment level >= 1), `match_tool` (item id or tag, for example `shears` or `swords`), and `enchantment_level` for Fortune (`ore_drops`, 11 §9.2) and for Looting on mobs. Leaves drop saplings, sticks and apples with their own random chances (loot data in `loot_table/blocks/*_leaves.json`), and shears or silk touch make leaves drop themselves; cobweb drops `string` with a sword or shears (alternatives: silk touch drops the web). The loot tables are data; their full contents are not repeated here beyond 11 §9.2.

---

## 4. Combat

All of this runs on the server (the client only predicts the swing). The player-versus-entity path is `Player.attack`; the receiving side is
`LivingEntity.hurtServer` and `actuallyHurt`; the defence formulas are in `CombatRules`. Damage amounts are `float`.

### 4.1 Attack strength, cooldown and the attack packet

- Effective attack speed A = the player's `attack_speed` attribute (base 4.0, plus the main-hand item's modifier, plus any other modifier; `MobEffects` (read): Haste modifies `attack_speed` by +0.1 x (amplifier + 1) with operation `add_multiplied_total`, Mining Fatigue by -0.1 x (amplifier + 1) (every effect attribute modifier amount is the registered amount x (amplifier + 1), `MobEffect$AttributeTemplate.create`)); Strength adds +3.0 x (amplifier + 1) and Weakness -4.0 x (amplifier + 1) to `attack_damage` (`add_value`); Absorption adds +4.0 x (amplifier + 1) to `max_absorption`).
- **Full-charge delay** D = (1 / A) x 20 ticks (`Player.getCurrentItemAttackStrengthDelay`). Bare hand: A = 4.0, D = 5 ticks. Iron sword: A = 1.6, D = 12.5. Diamond axe: A = 1.0, D = 20. Mace: A = 0.6, D = 33.33.
- The player has an integer `attackStrengthTicker`. It increases by 1 every tick (in `Player.tick`) and is set to 0 by `resetAttackStrengthTicker` (called on every attack through `Player.onAttack`, and when the held stack changes, inferred from the `itemSwapTicker` reset in the same method).
- **Attack strength scale** s(a) = clamp((ticker + a) / D, 0, 1) (`getAttackStrengthScale(a)`); an attack uses a = 0.5. So s reaches 1 when ticker + 0.5 >= D.
- Minimum charge: an item with `minimum_attack_charge` m > 0 cannot attack while (ticker + a) / D < m (spears: m = 1.0).
- The client sends Attack (0x01, target entity id; 05c) on a left click that hits an entity. `ServerGamePacketListenerImpl.handleAttack` (read, in order): ignores the packet if the client has not finished loading or the player is a spectator; looks up the entity (or entity part) by id; ignores it if missing or outside the world border; ignores it unless `ServerPlayer.isWithinAttackRange(mainHandItem, targetBoundingBox, 3.0)` holds (margin 3.0 blocks added to the item's `attack_range`, 1.3); ignores it if the main-hand item has `piercing_weapon`; **disconnects** the player with `multiplayer.disconnect.invalid_entity_attacked` if the target is an item entity, an experience orb, the player itself, or an arrow that is not attackable; ignores it if the main-hand item's feature is not enabled; ignores it if `cannotAttackWithItem(mainHandItem, 5)` (the integer 5 is a tick margin: the attack is refused when (attack ticker + 5) / delay < the item's `minimum_attack_charge`; items without one have 0); otherwise calls `ServerPlayer.attack(target)` (4.2). Interact (0x1A) uses `isWithinEntityInteractionRange` with the same margin 3.0. A hit also sends Swing Animation (0x7B, 05b) to viewers.

### 4.2 The attack: `Player.attack`, in order

This pipeline is reached from the Attack packet (0x01) for every item **except** one with the `piercing_weapon` component (spears), which ignores that packet and attacks through Player Action `STAB` (3.12).

Inputs: attacker player P, target T, the main-hand stack W.
1. If `cannotAttack(T)` stop. (`Entity.isAttackable` false, or the entity skips attack interaction, e.g. an item frame is handled elsewhere.)
2. base = P's `attack_damage` attribute value (1.0 + item modifier + effect modifiers), or `autoSpinAttackDmg` (8.0) while riptiding.
3. source = `createAttackSource(W)`: the damage type of W's `damage_type` component (`spear`; `mace_smash` for a mace that can smash; else `player_attack`).
4. s = attack strength scale at a = 0.5.
5. enchantDamage E = s x (getEnchantedDamage(T, base, source) - base): the enchantment `damage` effects on W (sharpness, smite, bane, impaling, power for arrows...) applied to `base` with T as the victim. Their sum is E before the s factor (section 6.3).
6. base = base x baseDamageScaleFactor, with **baseDamageScaleFactor = 0.2 + s x s x 0.8** (`Player.baseDamageScaleFactor`).
7. `onAttack` (resets the ticker). If `deflectProjectile(T)` (T is a redirectable projectile in the tag `redirectable_projectile`, for example a fireball or wind charge) the projectile is deflected back along the player's view direction, the sound `player.attack.nodamage` plays and the attack ends.
8. If base <= 0 and E <= 0: no damage; plays `entity.player.attack.nodamage`; ends (steps 10 still runs `postPiercingAttack`).
9. Otherwise:
   - fullStrength = s > 0.9.
   - sprintKnockback = P is sprinting and fullStrength (plays `entity.player.attack.knockback`).
   - base = base + W.getItem().getAttackDamageBonus(T, base, source) (mace smash: 4.4; 0 for every other item).
   - crit = fullStrength and `canCriticalAttack(T)`: P's fall distance > 0, P not on the ground, not on a climbable block, not in water, not "mobility restricted" (Blindness), not a passenger, T is a `LivingEntity`, and P is **not sprinting**. If crit then base = base x 1.5.
   - total = base + E.
   - sweep = `isSweepAttack` (4.3).
   - T's health before = h0; T's velocity before = v0.
   - hurt = `T.hurtOrSimulate(source, total)` (section 4.4 for a living T).
   - If hurt: knockback strength K = `getKnockback(T, source)` + (0.5 if sprintKnockback else 0), where getKnockback = (`attack_knockback` attribute + the Knockback enchantment bonus, 6.3) / 2; then `causeExtraKnockback(T, K, v0, ...)` (4.6) is applied; if sweep: `doSweepAttack(base, source, s)` (4.3); then visual effects (crit particles `magic crit` if crit, sound `entity.player.attack.crit`, `...strong` if fullStrength else `...weak`, `sweep` particles/sounds as set), `setLastHurtMob(T)`, `itemAttackInteraction` (section 5.1: W's `hurtEnemy` / durability and the post-attack enchantment effects: fire aspect, thorns-like effects, channeling, wind burst), damage statistics and heart particles, and **exhaustion 0.1** (4.9).
   - If not hurt: plays `entity.player.attack.nodamage`.
10. `postPiercingAttack` (Lunge, 3.12).

Notes on order: `getEnchantedDamage` is computed against the base before the 0.2 + 0.8 s^2 scaling and the enchant part is scaled by s only (not by s^2); the crit multiplier applies to the weapon part only, never to E; the item bonus (smash) is scaled by neither.

### 4.3 Sweeping

A sweep happens when all hold: fullStrength, not crit, not sprintKnockback, P is on the ground, the horizontal speed squared of P (`getKnownMovement`) is below (movement speed x 2.5)^2 (so P is not running fast), and the main-hand item is in the item tag `swords` (`isSweepAttack`).
`doSweepAttack(damage, source, s)`: plays `entity.player.attack.sweep`; sweepDamage = 1.0 + `sweeping_damage_ratio` attribute x damage (the attribute is 0 without Sweeping Edge; Sweeping Edge adds L / (L + 1)); every `LivingEntity` inside the target's bounding box inflated by (1.0, 0.25, 1.0), other than P and T, not allied to P, not a marker armor stand, and whose squared distance to **T** is < 9.0 (3 blocks) is hurt with `hurtServer(source, getEnchantedDamage(entity, sweepDamage, source) x s)`; each hit entity gets `knockback(0.4, sin(yaw), -cos(yaw))` (the player's yaw, resistance applies) and the post-attack effects; a `sweep_attack` particle appears 0.5 above and 1.0 in front. Example: iron sword, no enchantments, full strength: damage 6, sweepDamage = 1 + 0 x 6 = 1.0; Sweeping Edge III: ratio 0.75 -> 1 + 4.5 = 5.5.

### 4.4 Receiving damage: `LivingEntity.hurtServer(level, source, amount)` and `Player.hurtServer`

**Server player gating** (`ServerPlayer.hurtServer`, `isInvulnerableTo`, `canHarmPlayer`, read): `ServerPlayer.isInvulnerableTo` is true if `Player.isInvulnerableTo` is true, or if the player is changing dimension and the source is not the `ender_pearl` damage type, or if the client has not finished loading (`hasClientLoaded` false). `ServerPlayer.hurtServer` returns false when invulnerable; when the source's entity is a player (or the source is an arrow whose owner is a player) it requires `canHarmPlayer(thatPlayer)`: the server's PvP setting must be on (`ServerLevel.isPvpAllowed`) and the team rule `doTeamsAllowDamage` must allow it (true when either player has no team, or the two teams are not the same team (`Team.isAlliedTo` is reference equality of the teams, null counts as not allied), otherwise only if the team allows friendly fire); only then does it fall through to `Player.hurtServer`, which first calls `removeEntitiesOnShoulder` (parrots on the shoulders fly off). Player-specific first step (`Player.hurtServer`): return false if `isInvulnerableTo` (the damage is of a type disabled by a game rule: drowning, fall, fire or freeze damage rules; or the generic checks below); return false if the player has `abilities.invulnerable` (creative/spectator) and the source is not in `bypasses_invulnerability`; set the idle counter to 0; return false if dead; if the source `scalesWithDifficulty` (damage type `scaling`: `always`, or `when_caused_by_living_non_player` and the cause is a living non-player; list in 4.12): **Peaceful -> 0, Easy -> min(amount / 2 + 1, amount), Normal -> amount, Hard -> amount x 3 / 2**; a result of 0 returns false. Then the `LivingEntity` steps (mobs start here, with no difficulty scaling):

1. `isInvulnerableTo` (`isInvulnerableToBase`: source in `bypasses_invulnerability` is never invulnerable; creative players' own attacks; fire/fall for fire-immune/fall-immune types via entity type tags; enchantment `damage_immunity`, for example Frost Walker against `burn_from_stepping` magma) -> return false.
2. Dead or dying -> false.
3. Source in tag `is_fire` and the entity has Fire Resistance -> false.
4. Wake a sleeper; idle counter 0. A negative amount becomes 0.
5. **Blocking** (3.6): amount -= blocked damage (`applyItemBlocking`). Remember whether something was blocked.
6. Freezing: if the source is in the damage-type tag `is_freezing` **and** the entity's type is in the entity-type tag `freeze_hurts_extra_types`, amount x 5. Sources in `damages_helmet` (falling anvil/block/stalactite) with a helmet on: damage the helmet (`hurtHelmet`) and amount x 0.75. NaN or infinity becomes the max float.
7. **Invulnerability window** (4.7).
8. The attacker and player responsible are resolved (`resolveMobResponsibleForDamage`, `resolvePlayerResponsibleForDamage`). The rest of steps 8 to 10 is gated by the **fresh-hit flag**: true when the hit took the "new window" branch of step 7, false for a "difference" hit (which never plays sounds, never sends the damage event and never knocks back). On a fresh hit: if something was blocked and the blocking item has `blocks_attacks`, its `onBlocked` effect plays (the block sound, volume 1.0, pitch 0.8 + nextFloat x 0.4), otherwise `ServerLevel.broadcastDamageEvent` sends only the `Damage Event` packet (0x19: entity, damage type, cause id, direct id, position) to the players tracking the entity and to the entity itself if it is a player (no hurt animation here); then `markHurt` (velocity sync) unless the type is in `no_impact` (drowning) or the hit was blocked and the remaining amount is 0.
9. **Default knockback** (`dealDefaultKnockback`) happens only on a fresh hit, when the type is not in `no_knockback` and the hit was **not fully blocked** (fully blocked = blocked and the remaining amount <= 0): strength 0.4 away from the source: direction (sourceX - x, sourceZ - z) from `DamageSource.getSourcePosition`; when the direct entity is a projectile the direction is instead the negated pair from `Projectile.calculateHorizontalHurtKnockbackDirection`; the formula in 4.6 with the target's knockback resistance; if the direct entity is not a projectile and the source has no position, (dx, dz) stays (0, 0) and `knockback` then picks a random horizontal direction (4.6 step 3). **`indicateDamage(dx, dz)`** is called whenever the hit was not blocked at all (the third argument of `dealDefaultKnockback` is the blocked flag: blocked > 0): the base implementation does nothing; the `ServerPlayer` override sets `hurtDir = atan2(dz, dx) x 57.2957763671875 - yaw` and sends Hurt Animation (0x2B) to that player.
10. If health <= 0 after the damage: `checkTotemDeathProtection` (4.10); if the totem did not save the entity: on a fresh hit the death sound and `playSecondaryHurtSound` play, then `die`. If the entity is alive and the hit was fresh, the hurt sound (`getHurtSound`) and the secondary hurt sound play. (So sounds follow the fresh-hit flag, not the damage amount.)
11. Only when the hit was not fully blocked are the damage source and time remembered (`lastDamageSource`, `lastDamageStamp`) and active effects given `onMobHurt`. Regardless of blocking: for a `ServerPlayer` victim the `ENTITY_HURT_PLAYER` trigger fires, and, when something was blocked, the statistic `damage_blocked_by_shield` is raised by round(10 x blocked damage) (only if the amount is below the huge-value guard 3.4E37); when the damage source's entity is a `ServerPlayer` the `PLAYER_HURT_ENTITY` trigger fires for it.
12. Returns true when damage was accepted.

`actuallyHurt(level, source, amount)` (called from step 7): return if invulnerable again; then **in this order**
1. amount = `getDamageAfterArmorAbsorb(source, amount)`: unless the source is in `bypasses_armor`, first damage the armor (`hurtArmor`, 4.5 with the incoming amount), then amount = `CombatRules.getDamageAfterAbsorb` (4.5).
2. amount = `getDamageAfterMagicAbsorb(source, amount)`: sources in `bypasses_effects` (starvation) skip everything; **Resistance** (amplifier a, unless the source is in `bypasses_resistance`): amount = max(amount x (25 - 5 x (a + 1)) / 25, 0) (so 20% less per level; level 5 = 100%); the `damage_resisted` statistic gets round(10 x prevented). If amount <= 0 return 0. Sources in `bypasses_enchantments` (sonic boom) skip the next; otherwise protection points P = sum of the `damage_protection` effects of the worn items that apply to this source (6.3), amount = amount x (1 - clamp(P, 0, 20) / 25).
3. **Absorption**: A = the absorption amount; amount' = max(amount - A, 0); the absorption amount becomes A - (amount - amount'); the `damage_absorbed` statistic gets round(10 x absorbed).
4. If amount' == 0 return. For a **player** victim `Player.actuallyHurt` (an override with the same three steps) then adds `source.getFoodExhaustion()` to the exhaustion (4.9), records the damage in the combat tracker, **health = health - amount'**, raises the statistic `damage_taken` by round(10 x amount') and fires the `entity_damage` game event; the absorbed part also raises `damage_absorbed` (round(10 x absorbed)), game event `entity_damage`. A player is sent Set Health (0x6A) with its new health, food and saturation (05b).

### 4.5 Armor and toughness (`CombatRules.getDamageAfterAbsorb`)

Inputs: damage d, armor value R (the `armor` attribute, floored to an integer: `getArmorValue`), toughness T (the `armor_toughness` attribute).
1. f = 2.0 + T / 4.0.
2. e = clamp(R - d / f, R x 0.2, 20.0) (the effective armor points).
3. q = e / 25.0.
4. If the attacker's weapon exists (`source.getWeaponItem`) and the level is a server level, q = clamp(`EnchantmentHelper.modifyArmorEffectiveness(weapon, victim, source, q)`, 0, 1): Breach lowers q by 0.15 per level (6.3). Otherwise q is unchanged.
5. Result = d x (1 - q).
Properties: armor never reduces damage by more than 80% at R = 20 (e <= 20, q <= 0.8); the floor R x 0.2 means even a huge hit is reduced by at least 20% of the armor.

**Armor durability** (`hurtArmor` -> `doHurtEquipment`): when the damage source is not in `bypasses_armor` each of the four armor slots (feet, legs, chest, head) takes `hurtAndBreak(max(1, floor(d / 4)))`, where d is the damage **before** armor reduction but after blocking, difficulty and the other earlier steps (the value passed to `hurtArmor`), but only for pieces whose `equippable.damage_on_hurt` is true, that are damageable and `canBeHurtBy(source)` (not `damage_resistant` to this type). Sources in `damages_helmet` damage only the helmet (`hurtHelmet`) and only with the 4.4 step-6 reduction. Elytra: `damage_on_hurt` false.

### 4.6 Knockback

`LivingEntity.knockback(strength, dx, dz)`:
1. strength = strength x (1 - `knockback_resistance` attribute); if strength <= 0 stop.
2. Mark the entity as needing a velocity sync (the server sends Set Entity Motion, 0x67, to the player victim).
3. m = current velocity. (dx, dz) = (dx, dz); if dx^2 + dz^2 < 1.0E-5 replace them with (nextDouble - nextDouble) x 0.01 each (loop until large enough).
4. d = normalize(dx, 0, dz) x strength.
5. New velocity: x = m.x / 2 - d.x; z = m.z / 2 - d.z; y = if the entity is on the ground then min(0.4, m.y / 2 + strength) else m.y (unchanged).
Sources: default hit knockback strength 0.4 (away from the source); player attack extra knockback K = (attack_knockback + Knockback level) / 2 + (0.5 for sprinting) applied along the attacker's facing: `knockback(K, sin(yaw), -cos(yaw))`; afterwards the attacker's own horizontal velocity is multiplied by (0.6, 1.0, 0.6) and the attacker stops sprinting. A non-living target is pushed by (-sin(yaw) x K, 0.1, cos(yaw) x K) (inferred from the call). Arrows (`AbstractArrow.doKnockback`): strength = Punch value (6.3, 0 without) x (1 - resistance); direction = the arrow's horizontal velocity normalised x strength x 0.6, plus 0.1 up, via `push`. The attack K is applied after the default 0.4, so both apply to the same hit. No knockback for sources in `no_knockback` (the list in 4.12; explosions apply their own).

### 4.7 Invulnerability ticks (the hurt window)

State per living entity: `invulnerableTime` (called `damageCooldownTime`), `lastHurt` (the damage of the last accepted hit), `hurtTime`, `hurtDuration`.
- On an accepted hit while `invulnerableTime <= 10`: lastHurt = amount, invulnerableTime = 20, actuallyHurt(amount), hurtDuration = 10, hurtTime = 10. The hurt animation and the red flash last `hurtDuration` ticks.
- A hit while `invulnerableTime > 10` (the first 10 ticks after the previous hit) and the type not in `bypasses_cooldown` (the tag is empty in this version): if amount <= lastHurt the hit is **ignored (returns false)**; else only the difference is applied: actuallyHurt(amount - lastHurt), lastHurt = amount, and no new window starts and no new hurt animation is sent.
- `invulnerableTime` decreases by 1 each tick to 0. So a victim can be damaged at full strength every 10 ticks (twice a second), with a stronger hit within the first 10 ticks adding only its excess.
- This rule applies in both world types; the stand-in hurt cooldown 12 is retired.

### 4.8 Mace smash, wind burst, density, breach

- A **smash attack** is available when the attacker's fall distance is > 1.5 and it is not gliding (`MaceItem.canSmashAttack`). The attack then uses damage type `mace_smash` and adds a bonus before crit (4.2 step 9): with h = fall distance in blocks, bonus b = 4 x h if h <= 3; 12 + 2 x (h - 3) if 3 < h <= 8; 22 + (h - 8) if h > 8; plus `smash_damage_per_fallen_block` (Density: 0.5 per level) x h (`modifyFallBasedDamage`); the result is `getAttackDamageBonus` and is added to the base damage (not scaled by the attack strength).
- `hurtEnemy` (smash): the attacker's vertical velocity is set to 0.01 (a small bounce), fall damage from the current impulse is ignored (`setIgnoreFallDamageFromCurrentImpulse`), Set Entity Motion is sent; the sound `item.mace.smash_ground_heavy` (fall > 5) / `smash_ground` (on the ground) / `smash_air`; Level Event 2013 with data 750 (smash particles); and a **shockwave**: every `LivingEntity` within 3.5 blocks of the attacker (bounding-box inflate 3.5 and squared distance <= 3.5^2 of the **attacker**), not a spectator, not the attacker or the target, not allied, not a tamed pet owned by the attacker, not a marker armor stand, and not a flying creative player, is knocked back by power (3.5 - distance) x 0.7 x (2 if the fall distance > 5 else 1) x (1 - knockback resistance), directed away from the attacker. `postHurtEnemy` then resets the attacker's fall distance (so it cannot chain).
- Wind Burst (6.3, `enchantment/wind_burst.json`): after a hit by a non-flying attacker whose fall distance >= 1.5 an explosion (radius 3.5, `block_interaction` `trigger`) throws the attacker (and others) with knockback multiplier 1.2, 1.75, 2.2 for levels 1 to 3.
- Breach reduces the armor effectiveness; Density adds fall damage (6.3). The mace has no damage bonus in creative if it cannot break blocks (no tool use). Mace durability 500: 1 per entity hit, 2 per block (it is a `tool` with damage_per_block 2).

### 4.9 Hunger, saturation, exhaustion, regeneration (`FoodData`)

State: foodLevel (0..20, new player 20), saturation (new player 5.0; saturation never exceeds the food level), exhaustion (0..40), a tick timer.
- **Exhaustion** is added by actions (`Player.causeFoodExhaustion`, ignored on the client side and in creative): breaking a block 0.005; attacking an entity 0.1 (and spear jabs 0.1); jumping 0.05, sprint-jumping 0.2 (`ServerPlayer.jumpFromGround`); sprinting 0.1 per metre travelled; swimming or walking underwater 0.01 per metre (the sprint and swim constants 0.1 and 0.01 are read in `checkMovementStatistics`; whether plain walking costs 0 is inferred); taking damage: `Player.actuallyHurt` (read) calls `causeFoodExhaustion(DamageSource.getFoodExhaustion())`, that is the damage type's `exhaustion` field (4.12), once per accepted hit whose final damage is non-zero, after the armor, magic and absorption steps and before the health is reduced; the Hunger effect adds 0.005 x (amplifier + 1) per tick (`HungerMobEffect`); regeneration adds the exhaustion shown below; Lunge adds 4.0 per level. Exhaustion is capped at 40.
- Every tick (`FoodData.tick`): if exhaustion >= 4.0: exhaustion -= 4.0, then if saturation > 0: saturation = max(saturation - 1, 0), else if the difficulty is not Peaceful: foodLevel = max(foodLevel - 1, 0).
- **Natural regeneration** (game rule `natural_health_regeneration`): 
  - if saturation > 0 and the player is hurt and foodLevel >= 20: a timer counts to 10 ticks; then heal(min(saturation, 6.0) / 6.0) and addExhaustion(min(saturation, 6.0)); the timer resets (fast regeneration while saturated).
  - else if foodLevel >= 18 and the player is hurt: a timer counts to 80 ticks; then heal(1.0) and addExhaustion(6.0); the timer resets.
  - else if foodLevel <= 0: timer counts to 80; then if health > 10, or the difficulty is Hard, or the difficulty is Normal and health > 1: hurt the player for 1.0 with the damage type `starve` (it bypasses armor and effects; Peaceful never starves); the timer resets.
  - else the timer is 0.
  - A player with fewer than `6` food points (foodLevel <= 6, `hasEnoughFood` false: constant 6.0) cannot sprint (13 §1.5) or sprint-jump exhaustively.
- Eating: `FoodData.add(nutrition, saturation)` (read) sets food = clamp(food + nutrition, 0, 20) and saturation = clamp(saturation + s, 0, the new food level); `eat(FoodProperties)` passes the food's nutrition and absolute saturation, and `eat(int, float modifier)` passes saturation = `FoodConstants.saturationByModifier(nutrition, modifier)` (the factor 2 appears in it: nutrition x modifier x 2). `FoodConstants`: MAX_FOOD 20, MAX_SATURATION 20.0, START_SATURATION 5.0, SATURATION_FLOOR 2.5, EXHAUSTION_DROP 4.0, HEALTH_TICK_COUNT 80, HEALTH_TICK_COUNT_SATURATED 10, HEAL_LEVEL 18, SPRINT_LEVEL 6, STARVE_LEVEL 0.
- A `ServerPlayer` is sent Set Health (0x6A) whenever health, food or saturation changed (`doTick`), and Set Experience (0x69) whenever experience changed.

### 4.9a Periodic mob-effect ticks (`MobEffectInstance.tickServer`, `MobEffect.shouldApplyEffectTickThisTick`)

Read in this round from `MobEffectInstance`, `LivingEntity.tickEffects` and the effect classes; the effect ids and colours are in 49 §2.4.

**Per-tick order (server).** Once per entity tick, for every active effect instance (iteration order of the entity's effect map):
1. If the instance has no remaining duration (`duration <= 0` and not infinite, `duration == -1` is infinite) it is removed without ticking.
2. The tick duration `d` is the instance's `duration`, or the entity's `tickCount` when the duration is infinite.
3. If the effect's `shouldApplyEffectTickThisTick(d, amplifier)` is true, `applyEffectTick(level, entity, amplifier)` runs (the return value false removes the instance; every effect listed below returns true).
4. The duration is decremented by 1 (the hidden effect underneath, if any, is decremented too); when it reaches 0 and a hidden effect exists, the instance takes over the hidden effect's details.
5. The instance survives while it has remaining duration; otherwise it is removed after this tick. Additionally, an instance whose duration is a multiple of 600 after the step sends an effect update to the clients.

So the periodic effect fires **before** the decrement, with the duration the instance had at the start of the tick: an effect applied for `D` ticks sees `d = D, D-1, ..., 1` and never `d = 0`.

**Interval rule.** The three periodic damage/heal effects compute `n = base >> amplifier` (arithmetic int shift; the JVM masks the shift count to its low 5 bits, so amplifier 32 shifts by 0 (inferred from the bytecode `ishr`, not tested)). If `n > 0` the effect fires on ticks where `d mod n == 0`; if `n <= 0` it fires **every tick**.

| Effect | base | Interval by amplifier 0, 1, 2, 3, 4, 5, 6 | Action when it fires |
|---|---|---|---|
| `poison` | 25 (`DAMAGE_INTERVAL`) | 25, 12, 6, 3, 1, every tick (0), every tick | If health `> 1.0`: `hurtServer(magic, 1.0)`. At health `<= 1.0` nothing happens, so poison never kills |
| `regeneration` | 50 | 50, 25, 12, 6, 3, 1, every tick (0) | If health `< max health`: `heal(1.0)` |
| `wither` | 40 (`DAMAGE_INTERVAL`) | 40, 20, 10, 5, 2, 1, every tick (0) | `hurtServer(wither damage type, 1.0)`; there is **no** minimum-health rule, so wither can kill |
| `hunger` | - | every tick (the effect's `shouldApply...` is constant true) | Players only: `causeFoodExhaustion(0.005 x (amplifier + 1))` (4.9) |

All other effects (`speed`, `strength` and so on) keep the default `shouldApplyEffectTickThisTick`, which is false: they never run `applyEffectTick`, they act through attribute modifiers. `absorption` (modifier based), `bad_omen`, `raid_omen`, `infested`, `oozing`, `weaving` and `wind_charged` have their own triggers (hurt, death or the 20, 33 and 49 documents), not a periodic interval; whether `bad_omen` and `raid_omen` override the interval rule was not re-read here (see 20 for Bad Omen; Open question 1 of this section's round, listed below).

The damage of poison and wither goes through the normal hurt path (4.4): the `magic` and `wither` damage types (4.12) bypass armor, and the hurt window (4.7) applies: a hit of 1.0 inside the invulnerability window that is not larger than the last damage is ignored, so with an interval of 1 tick the hurt rate is limited by the window, not by the effect. Health is changed by `heal` / `hurtServer` only; no other minimum health exists.

**Instant effects** (`instant_health`, `instant_damage`, `saturation`) are `InstantaneousMobEffect`: `isInstantaneous` true, and `shouldApplyEffectTickThisTick(d, a)` is `d >= 1`. When applied by drinking or by a thrown potion (`PotionContents.applyToLivingEntity`, scale 1.0, the effect is never added as an instance) `applyInstantaneousEffect` runs once with scale `s`:

| Effect | Amount at amplifier `a` |
|---|---|
| `instant_health` (not inverted, i.e. a living target that is not undead) | heal `int(s x (4 << a) + 0.5)` |
| `instant_damage` (not inverted) | `hurtServer(magic, int(s x (6 << a) + 0.5))`; with a thrower / owner entity: the `indirect_magic` type with those two entities |
| undead target (`isInvertedHealAndHarm`) | the two effects swap: instant health damages and instant damage heals, with the same amounts |
| `saturation` | players only: `FoodData.eat(a + 1, 1.0)`, i.e. nutrition `a + 1` and the saturation modifier 1.0 (saturation gain `(a + 1) x 1.0 x 2`, 4.9) |

When an instant effect instance is ticked through `applyEffectTick` instead (the base method, scale not applied) the amounts are `6 << a` damage and `max(4 << a, 0)` heal. At scale 1.0 both paths give the same numbers (`s x 6 << a + 0.5` truncates to `6 << a`).

Worked examples: poison I (amplifier 0) with duration 100: fires at `d` = 100, 75, 50, 25 (4 times, 4.0 damage in total if the health stays above 1.0 and the hurt window allows it). Poison II for 60 ticks (interval 12): `d` = 60, 48, 36, 24, 12 (5 times). Regeneration I for 100 ticks: `d` = 100, 50 (2 times, 2.0 health in total). Regeneration II (interval 25) for 100 ticks: 4 times. Wither I (interval 40) for 100 ticks: `d` = 80, 40 (2 times; `d = 100` and `60` are not multiples of 40). A target at health 1.0 with poison: no damage at any tick; at health 1.5 the next poison tick hurts for 1.0, leaving 0.5.

### 4.10 Death, totem, respawn, drops, experience

- **Totem of Undying** (`checkTotemDeathProtection`, only for damage not in `bypasses_invulnerability`): if either hand holds an item with `death_protection`, that stack shrinks by 1 (creative keeps it), the `item_used` stat and the totem advancement trigger fire, health is set to **1.0**, all effects are cleared, then **Regeneration II 900 ticks (amplifier 1), Absorption II 100 ticks (amplifier 1), Fire Resistance I 800 ticks (amplifier 0)** are applied, and Entity Event 35 is broadcast (the totem animation). The entity survives.
- Otherwise `die`: the combat tracker's death message goes out as Player Combat Kill (0x45) to the dead player and System Chat to the others (game rule `show_death_messages`), Entity Event 3 (death) is broadcast, the entity's `deathTime` runs to 20 ticks (`tickDeath`) and then it is removed (a non-player mob). The last death position and dimension are saved (recovery compass).
- **Player drops**: `Player.die` first runs `dropAllDeathLoot` (mob-drop rules, section below) for a non-spectator; `dropEquipment` drops the whole inventory unless the game rule `keep_inventory` is on (`Inventory.dropAll`) after `destroyVanishingCursedItems` removes every item with the `vanishing_curse` enchantment. The dead player is given a velocity: with a damage source, (-cos((hurtDir + yaw) x 0.017453292) x 0.1, 0.1, -sin((hurtDir + yaw) x 0.017453292) x 0.1), otherwise (0, 0.1, 0). **Experience dropped** on player death: `getBaseExperienceReward` = min(level x 7, 100) when `keep_inventory` is off, else 0 (constants 7 and 100).
- **Mob drops** (`dropAllDeathLoot`): when game rule `mob_drops` is on the loot table of the entity type is rolled with the killer in context (`dropFromLootTable`: parameters this entity, damage source, killer, direct killer, the killer player's `luck` as the loot luck); drop equipment and `dropExperience` (the experience orb value of the mob scaled by `processMobExperience` enchantments; per-mob values are in the mob docs 18-21 and the loot tables `loot_table/entities/*.json`). Looting's `equipment_drops` effect is +0.01 per level for a player attacker (read in the enchantment data); In the loot tables (`loot_table/entities/*.json`, 50 of the extracted tables use `enchanted_count_increase` with `enchantment: looting`) the count function adds the given number provider once per Looting level; for example the zombie's `rotten_flesh` is `set_count` uniform 0..2 plus uniform 0..1 per Looting level, and its rare drop uses `random_chance_with_enchanted_bonus` (0.025 unenchanted, 0.035 + 0.01 x (L - 1) with Looting) when killed by a player. The table format and per-mob content are specified in 18 §7.6.
- **Respawn**: the client sends Client Command (0x0C) `PERFORM_RESPAWN` (05c); `PlayerList.respawn` calls `ServerPlayer.findRespawnPositionAndUseSpawnBlock`: it takes the player's stored respawn config (position, angles, dimension, forced flag; `getDimensionOrDefault`); in that level, if the block there is a **respawn anchor** and (the config is forced or its `charge` > 0) and `RespawnAnchorBlock.canSetSpawn(level)` (the dimension's environment attribute `respawn_anchor_works` is true), a stand-up position beside it (`findStandUpPosition`, using `DismountHelper.findSafeDismountLocation`) is found, and its `charge` is reduced by 1 **only if the config is not forced, the real-respawn flag (the boolean `useSpawnBlock` passed to `findRespawnPositionAndUseSpawnBlock`) is true, and a stand-up position was found** (read in this order: forced, flag, found); else if it is a **bed** (`AbstractBedBlock`) whose `BedRule` (the per-dimension environment attribute with fields `can_sleep`, `can_set_spawn`, `destroy_on_use`, `destroy_on_leave`, `error_message`) allows setting spawn, `AbstractBedBlock.findStandUpPosition` gives the position (it tries the four directions around the bed); else if the config is forced and the block and the one above are `isPossibleToRespawnInThis` the position is (x + 0.5, y + 0.1, z + 0.5); otherwise `TeleportTransition.missingRespawnBlock` (the player is told the block is missing and goes to the default respawn data of the level, `getRespawnData`, via `createDefault`); if the config's level does not exist `createDefault` is used. A new `ServerPlayer` is built; `restoreFrom` copies the old data (game mode, base attributes and permanent modifiers, and inventory/experience/effects only when the game rule `keep_inventory` is on); `FoodData` defaults (food 20, saturation 5.0, exhaustion 0) and `max_health` 20 give the new vitals. Then Respawn (0x54) and Set Default Spawn Position (0x63) are sent and the player is added to the level (`addRespawnedPlayer`).
- **Experience**: the player's level and progress: XP needed to go from level L to L + 1 is 7 + 2 L if L < 15; 37 + 5 (L - 15) if 15 <= L < 30; 112 + 9 (L - 30) otherwise (`getXpNeededForNextLevel`, constants read). Total XP is capped at the int range. An XP orb's value mapping (`ExperienceOrb.getExperienceValue(amount)`): split an amount into orbs by taking the largest tier: 2477, 1237, 617, 307, 149, 73, 37, 17, 7, 3, 1; an orb despawns after 6000 ticks; a player picks it up on touch (`playerTouch`), gains `value` points, and **repairs a random Mending item** first (6.4). Orb movement (`ExperienceOrb.tick`, read): gravity applies out of water; in water (`setUnderwaterMovement`: factors 0.99, 0.0005, 0.06, 0.99) it sinks slowly; in lava it jumps randomly; every 20th tick it scans for orbs to merge within 0.5; `followNearbyPlayer` pulls the orb toward the nearest non-spectator, living player within 8 blocks (aim point: the player's feet y + eye height / 2): the velocity gains normalize(offset) x t x t x 0.1 with t = 1 - distance / 8 (read: t is multiplied by itself and by 0.1); the air drag is 0.98 (times the block friction on the ground); lifetime 6000 ticks.

### 4.11 Environmental and special damage (amounts read)

| Source (damage type) | Amount and rule |
|---|---|
| Fall (`fall`) | `LivingEntity.causeFallDamage(distance, multiplier)`: damage = floor((distance + 1.0E-6 - `safe_fall_distance`) x multiplier x `fall_damage_multiplier`) as an integer, applied when > 0; `safe_fall_distance` 3.0, so a fall of 4 blocks does 1, 10 does 7, 23 does 20. Entities in the type tag `fall_damage_immune` take none; `fall`, `ender_pearl`, `stalagmite` are `is_fall`; a Feather Falling suit lowers it (6.3). Hay bales, slime, water and so on change the distance and multiplier (block logic). Sound: small/big fall by amount |
| Lava (`lava`) | `Entity.lavaHurt`: **4.0**, plays `entity.generic.burn`, and sets the entity on fire for **15 s** (`lavaIgnite` 15.0) unless fire-immune |
| Burning (`on_fire`) | while the remaining fire ticks > 0: 1.0 damage every 20 ticks (`baseTick`); `igniteForSeconds(s)` sets 20 x s ticks; extinguished in water; Fire Protection scales burning time through `burning_time` |
| Fire block (`in_fire`) | `BaseFireBlock.entityInside` hurts the entity with `in_fire` for the block's `fireDamage`: **1.0** for `fire` (`FireBlock` passes 1), **2.0** for `soul_fire` (`SoulFireBlock` passes 2); `fireIgnite` also sets the entity alight for 8 s (`igniteForSeconds(8.0)`) if it is not fire-immune (and when already burning, adjusts the remaining ticks) |
| Campfire (`campfire`) | `CampfireBlock.entityInside` hurts a standing entity for the block's integer fire damage: **1** (`campfire`) or **2** (`soul_campfire`), constructor arguments read in `Blocks` |
| Magma block (`hot_floor`) | 1.0 (`MagmaBlock.stepOn`), not when the entity is stepping carefully (sneaking) |
| Drowning (`drown`) | air supply max 300 ticks (`getMaxAirSupply`); underwater, `decreaseAirSupply` removes 1 per tick (`decreaseAirSupply`: with oxygen bonus b > 0 the tick is skipped when `nextDouble() >= 1 / (b + 1)`, i.e. air is lost with probability 1 / (b + 1); otherwise air - 1); the air is first reduced by `decreaseAirSupply`; when `shouldTakeDrowningDamage` (air <= -20, read) holds the air is set to 0, Entity Event 67 is broadcast and the entity takes **2.0** `drown` damage; `increaseAirSupply` adds 4 per tick (read) |
| Void (`out_of_world`) | below `minY - 64` (`checkBelowWorld`): **4.0** each tick, bypasses everything (`bypasses_invulnerability`, `bypasses_resistance`), (the tag `bypasses_invulnerability` contains it, so creative players are hurt too) |
| Starvation (`starve`) | 1.0 per 80 ticks at food 0 (4.9) |
| Cactus | 1.0 (read in `CactusBlock.entityInside`). Other block damage: out of scope (4.12 has the types) |
| Suffocation (`in_wall`) | 1.0 (`LivingEntity.baseTick` constant); world border (`outside_border`): the border's damage per block x distance beyond its safe zone (read structure in `baseTick`) |
| Thorns | the enchantment's `post_attack` effect (6.3): 1..5 damage of type `thorns` with chance 15% x level, costing the armor piece 2 durability |
| Lightning | `Entity.thunderHit` (read): the struck entity's remaining fire ticks are raised by 1; if that leaves it at 0 it is ignited for **8 s**; it is hurt for **5.0** by `lightning_bolt` |
| Explosion | `ExplosionDamageCalculator.getEntityDamageAmount` (read): with explosion radius r, D = 2 r, d = distance from the explosion centre to the entity (squared distance, square-rooted), t = d / D, u = (1 - t) x seenPercent (the fraction of 3-D sample rays from the centre to the entity's box that are not blocked, `ServerExplosion.getSeenPercent`), damage = (u x u + u) / 2 x 7 x D + 1. Entities with d > D are untouched (`hurtEntities` tests distance against D); the damage type is `explosion` or `player_explosion` and scales with difficulty (4.12); knockback uses `explosion_knockback_resistance` (6.3) |

### 4.12 Damage types (`data/minecraft/damage_type/*.json`, `tags/damage_type/*.json`)

Each damage type has `exhaustion` (food exhaustion added to a player victim), `scaling` (`always`: scales with difficulty; `when_caused_by_living_non_player`: scales only when the cause is a living non-player; none of the types uses `never`), optional `effects` (the visual/sound set: `burning`, `drowning`, `freezing`, `poking`, `thorns`) and `death_message_type` (`fall_variants` or `intentional_game_design`, otherwise default).

Exhaustion and scaling are read per damage type from `data/minecraft/damage_type/*.json`. The 51 types fall into groups that are **disjoint** (each type appears in exactly one row):

| Group | Types | Exhaustion | Scaling |
|---|---|---|---|
| A. no exhaustion | `cramming`, `dragon_breath`, `drown`, `ender_pearl`, `fall`, `fly_into_wall`, `freeze`, `generic`, `generic_kill`, `in_wall`, `indirect_magic`, `magic`, `on_fire`, `out_of_world`, `outside_border`, `stalagmite`, `starve`, `wither` (18) | 0.0 | `when_caused_by_living_non_player` |
| B. always scaling, no exhaustion | `sonic_boom` | 0.0 | `always` |
| C. always scaling, exhaustion 0.1 | `bad_respawn_point`, `explosion`, `player_explosion` | 0.1 | `always` |
| D. burning types | `campfire`, `fireball`, `hot_floor`, `in_fire`, `lava`, `sulfur_cube_hot`, `unattributed_fireball` | 0.1 | `when_caused_by_living_non_player` |
| E. other 0.1 types | `arrow`, `cactus`, `dry_out`, `falling_anvil`, `falling_block`, `falling_stalactite`, `fireworks`, `lightning_bolt`, `mace_smash`, `mob_attack`, `mob_attack_no_aggro`, `mob_projectile`, `player_attack`, `spear`, `spit`, `sting`, `sweet_berry_bush`, `thorns`, `thrown`, `trident`, `wind_charge`, `wither_skull` (22) | 0.1 | `when_caused_by_living_non_player` |

(18 + 1 + 3 + 7 + 22 = 51.) `scaling` `always` means the difficulty scaling of 4.4 always applies; the other value applies it only when the cause is a living non-player entity; no type uses a third value. Separate attributes (a column of the file, not a group): `effects` = `burning` for `campfire`, `fireball`, `hot_floor`, `in_fire`, `lava`, `on_fire`, `sulfur_cube_hot`, `unattributed_fireball`; `drowning` for `drown`; `freezing` for `freeze`; `poking` for `sweet_berry_bush`; `thorns` for `thorns`; `death_message_type` = `fall_variants` for `ender_pearl`, `fall`; `intentional_game_design` for `bad_respawn_point`; all others default. (`on_fire` is in group A, exhaustion 0.0, despite its burning effect.)

Tags (membership, as listed in the jar; a tag drives the behaviour named in 4.4 and 4.5):

| Tag | Members | Effect |
|---|---|---|
| `bypasses_armor` | on_fire, in_wall, cramming, drown, fly_into_wall, generic, wither, dragon_breath, starve, fall, ender_pearl, freeze, stalagmite, magic, indirect_magic, out_of_world, generic_kill, sonic_boom, outside_border | skips the armor reduction and armor wear |
| `bypasses_effects` | starve | skips Resistance and enchantment protection |
| `bypasses_enchantments` | sonic_boom | skips protection enchantments |
| `bypasses_resistance` | out_of_world, generic_kill | skips the Resistance effect |
| `bypasses_invulnerability` | out_of_world, generic_kill | hurts creative/invulnerable entities |
| `bypasses_cooldown` | (empty) | none |
| `bypasses_shield` | every type in `bypasses_armor` plus cactus, campfire, dry_out, falling_anvil, falling_stalactite, hot_floor, sulfur_cube_hot, in_fire, lava, lightning_bolt, sweet_berry_bush | cannot be blocked |
| `damages_helmet` | falling_anvil, falling_block, falling_stalactite | helmet absorbs (x 0.75, helmet wear) |
| `is_fire` | in_fire, campfire, on_fire, lava, hot_floor, sulfur_cube_hot, unattributed_fireball, fireball | Fire Resistance blocks; Fire Protection applies; `fire_damage` rule |
| `is_fall` | fall, ender_pearl, stalagmite | Feather Falling; `fall_damage` rule |
| `is_drowning`, `is_freezing`, `is_lightning` | drown; freeze; lightning_bolt | game-rule switches; Channeling-related |
| `is_explosion` | fireworks, explosion, player_explosion, bad_respawn_point | Blast Protection |
| `is_projectile` | arrow, trident, mob_projectile, unattributed_fireball, fireball, wither_skull, thrown, wind_charge | Projectile Protection; shield angle exception |
| `is_player_attack` | player_attack, spear, mace_smash | player melee |
| `no_knockback` | explosion, player_explosion, bad_respawn_point, in_fire, lightning_bolt, on_fire, lava, hot_floor, sulfur_cube_hot, in_wall, cramming, drown, starve, cactus, fall, ender_pearl, fly_into_wall, out_of_world, generic, magic, wither, dragon_breath, dry_out, sweet_berry_bush, freeze, stalagmite, outside_border, generic_kill, campfire, spear | no default knockback |
| `no_impact` | drown | no hurt shake |
| `no_anger` | mob_attack_no_aggro | mob retaliation |
| `always_hurts_ender_dragons` | fireworks, explosion, player_explosion, bad_respawn_point | |

Other tags in the directory (`panic_causes`, `witch_resistant_to`, armor-stand tags, silverfish, `wither_immune_to`, `burn_from_stepping`, `avoids_guardian_thorns` and so on) concern mob AI and block logic (18-21). The sources with a **cause position** (a living attacker or a projectile) knock back from the cause; others (fall, fire) have none.

---

## 5. Durability, Unbreaking, Mending and repair

### 5.1 Durability loss

`ItemStack.hurtAndBreak(amount, entity, slot)` (server): returns at once if the stack is not damageable (1.3). A player with infinite materials (creative) takes no durability damage (`processDurabilityChange` returns 0 for them). Otherwise `amount` is passed through `EnchantmentHelper.processDurabilityChange` (Unbreaking, 5.2), and if the result is > 0 the stack's `damage` increases by it; when `damage >= max_damage` after the increase the item **breaks**: the stack is removed (count set to 0), `LivingEntity.onEquippedItemBroken` runs (the break sound from the `break_sound` component plus an Entity Event, for equipment slots). `nextDamageWillBreak` is true when damage + 1 >= max. `hurtWithoutBreaking` damages but never breaks (the trident throw). Costs (all read):

| Event | Cost |
|---|---|
| Breaking a block with a `tool` item (`Item.mineBlock`) | `damage_per_block` (1 pickaxe/axe/shovel/hoe/shears, 2 sword, mace, trident), only when the block's destroy speed (hardness) is not 0 and the call is on the server; shears do not pay for blocks in tag `fire` |
| Hitting an entity (`ItemStack.hurtEnemy` through `itemAttackInteraction`) | the `weapon` component's `item_damage_per_attack` (1 sword, mace, trident, spear; 2 pickaxe, axe, shovel, hoe), applied once per hit that the target accepted |
| Bow shot | 1 per projectile (`getDurabilityUse`); crossbow 1, **3** for a firework rocket |
| Trident throw | 1 (`hurtWithoutBreaking`) |
| Fishing rod retrieve | 1 / 2 / 3 / 5 (3.11) |
| Flint and steel use, brush completing a block, shears on plant/pumpkin/hive/sheep, axe/hoe/shovel transform, shovel on campfire | 1 each |
| Shield blocked hit | `floor(base + factor x damage)` for damage >= threshold (3.6) |
| Elytra | 1 per 20 ticks gliding (3.13) |
| Armor piece, hit taken | `max(1, floor(damage / 4))` (4.5) |
| Carrot on a stick / warped fungus on a stick boost | 7 / 1 |
| Lunge (spear) | +1 item damage per use through the `change_item_damage` effect (3.12) |

### 5.2 Unbreaking

Data (`enchantment/unbreaking.json`): effect `item_damage`, two entries each `remove_binomial` with a chance c:
- for items in the item tag `enchantable/armor`: c = (2 + 2 x (L - 1)) / (10 + 5 x (L - 1));
- for all other items: c = (1 + (L - 1)) / (2 + (L - 1)) = L / (L + 1).
`remove_binomial(c)` removes each point of the pending damage independently with probability c (a binomial draw over the damage amount). So for a tool with damage 1 and Unbreaking L, the damage is skipped with probability L / (L + 1) (50%, 66.7%, 75%); for armor L = 1..3 skip chances 0.2, 4/15 = 0.2667, 6/20 = 0.3. (The binomial draw structure is read from the effect type name `RemoveBinomial`; its random-number order was not traced.)

### 5.3 Mending

Effect `repair_with_xp` with `multiply` factor 2.0 (`enchantment/mending.json`; slots `any`, max level 1, treasure only). `ExperienceOrb.playerTouch` (read): when the player's `takeXpDelay` is 0 it sets it to 2, takes the orb, and calls `repairPlayerItems(player, xp)` with xp = the orb's value; the returned remainder is given with `giveExperiencePoints`; the orb's count drops by 1 and it is discarded at 0. `repairPlayerItems`: pick one item uniformly at random (`EnchantmentHelper.getRandomItemWith`) from the player's equipment that has an enchantment with the `repair_with_xp` effect (and passes the predicate, which is the item's damaged state); potential = `modifyDurabilityToRepairFromXp(xp)` (xp x 2 through the `multiply` effect, truncated to int); repair = min(potential, the item's damage); damage -= repair; if repair > 0, remainder = xp - repair x xp / potential (integer division); if remainder > 0 the process repeats with the remainder on another random item (recursion), otherwise 0 is returned; if no item qualifies the full xp is returned.

### 5.4 Anvil (`AnvilMenu.createResult`, `onTake`)

Slots: left (the item to work on), right (sacrifice or material), the output, and an optional new name. Cost is the level cost displayed; the result is blocked when cost >= 40 and the player does not have infinite materials ("Too expensive"). All constants below are read.
1. Start: result = copy of left; baseCost = the `repair_cost` component of left (default 0) + that of right (default 0 when right is non-empty); the enchantments of left are loaded (`getEnchantmentsForCrafting`).
2. If right is non-empty:
   - If left is damageable and `isValidRepairItem(right)` (right is in left's `repairable` set): unit u = min(damage, max_damage / 4); if u <= 0 there is no result. Loop up to right's count: damage -= u; cost += 1; u recomputed as min(damage, max_damage / 4) each time; stop when damage is 0 or the right stack is used up. The number consumed is the number of iterations.
   - Else (combining): if right is not an enchanted book and (left is not the same item or not damageable) there is no result. If both are damageable (and right has no `stored_enchantments`): remaining durabilities a = max - damage of left, b = max - damage of right; new remaining = a + b + max x 12 / 100 (integer arithmetic); new damage = max(max - new remaining, 0), applied if lower than the current damage; the enchantment merge below follows, and the cost increases by 2 for combining two damageable items (applied after the durability merge); the other flat additions are 1 per repair unit and 1 per rejected-incompatible enchantment.
   - Enchantment merge (both items; right may be an enchanted book): for each enchantment e of right with level lr: the left level ll (0 if absent); the new level = lr if ll != lr (taking max(ll, lr)), or ll + 1 if they are equal, capped at the enchantment's max level; allowed if `Enchantment.canEnchant(left)` (or left is an enchanted book, or the player has infinite materials) and compatible with every other enchantment already on left (`Enchantment.areCompatible`; an incompatible pair adds cost 1 and skips it, unless infinite materials). Each applied enchantment adds cost level_new x multiplier, where multiplier = the enchantment's `anvil_cost`, halved (integer, minimum 1) when right is an enchanted book. If left had more than one item (count > 1) the combination is refused (cost forced to 40). **If at least one enchantment of right was rejected (not supported by left, or incompatible) and none was applied, the anvil gives no result** (read: the final check empties the output when a rejection happened and nothing was applied; the same "too expensive" exit).
3. Renaming: if the name field is blank and left has a `custom_name`: cost += 1 and the name is removed; else if the new name differs from the current name: cost += 1 and `custom_name` is set to the literal text.
4. Final cost = baseCost + the added costs, clamped to 0..2147483647; if the only change is a rename and cost >= 40, cost = 39; if cost >= 40 and not infinite materials, the result is empty.
5. New `repair_cost` on the result (if non-empty): n = the left item's `repair_cost`, raised to the right item's `repair_cost` when that is larger (max of the two, read); then unless the only added cost was a rename (the code skips the increase when the rename cost equals the total cost and is non-zero), n = `calculateIncreasedRepairCost(n)` = n x 2 + 1 (constants 2 and 1, capped at 2147483647); stored with the enchantments.
6. Taking the result (`onTake`): the player pays the cost in levels (`giveExperienceLevels(-cost)`; free for infinite-materials); the left slot is cleared; the right slot shrinks by the number of units used (or is cleared); and in survival there is a **12% chance** (`nextFloat() < 0.12`) per use that the anvil block is damaged (`AnvilBlock.damage`: chipped -> damaged -> destroyed with level event 1029 on destruction, 1030 otherwise).

### 5.5 Grindstone (`GrindstoneMenu`)

Two inputs and an output. `computeResult`: if both are empty, no result; if one is empty the result is a copy of the other with its non-curse enchantments removed (`removeNonCursesFrom`: curses = the tag `enchantment/curse`; an `enchanted_book` left with none becomes a `book`); if both are present `mergeItems`: they must be the same item (else no result); M = max of the two max_damage; a, b = remaining durabilities (max - damage); remaining = a + b + M x 5 / 100 (integer); a damageable item gets `max_damage` M and damage = max(M - remaining, 0); a non-damageable item needs stack size >= 2 and equal components and yields a stack of 2; enchantments: `mergeEnchantsFrom` carries over only the enchantments in the tag `curse` (`upgrade` keeps the higher level), then `removeNonCursesFrom` runs. The result's `repair_cost` is set from the count of remaining enchantments through the anvil formula (`calculateIncreasedRepairCost(n)` = 2n + 1 applied to `ItemEnchantments.size`). **Experience** (the output slot, `GrindstoneMenu$4`): when the result is taken, T = sum over both input items of the sum of `Enchantment.getMinCost(level)` for each of the item's non-curse enchantments; if T > 0, h = ceil(T / 2) and the XP is h + nextInt(h), spawned as orbs at the block centre (`ExperienceOrb.award`) with level event 1042; if T is 0 no XP. The output slot accepts only items that are damageable or enchanted (`mayPlace` on the input slots).

### 5.6 Repair in the crafting grid (`RepairItemRecipe`)

A shapeless recipe with exactly two ingredients, both the same item, each with a `max_damage` and a `damage` component and stack count 1 (`canCombine`). Result: same item; durability: remaining a + remaining b + max x 5 / 100 (constants 5 and 100 read, integer arithmetic; the exact order of the additions is as listed), the new damage = max - that value, clamped at 0; its `max_damage` is set to the larger of the two max values (`MAX_DAMAGE` is set on the result); enchantments: the merge lambda iterates the union of both items' enchantments and, for those in the tag `enchantment/curse`, sets the larger of the two levels; no other enchantment is carried over (read structure). No XP or level cost.
Crafting menu behaviour for this recipe: 13 §3.

### 5.7 Repair summary

| Method | Repair amount | Cost |
|---|---|---|
| Anvil + material | up to max/4 per material item (repeat) | 1 level per material item + enchant/rename costs |
| Anvil, two same items | a + b + 12% of max | cost per 5.4 |
| Crafting grid, two same items | a + b + 5% of max, enchantments dropped except curses | none |
| Mending | 2 durability per XP point | none |

---

## 6. Enchantments

### 6.1 Data model

An enchantment is a data-driven registry entry (`data/minecraft/enchantment/*.json`, 43 entries in this artifact; synchronised to clients, 04 §registry). Fields: `max_level`; `weight`; `min_cost` and `max_cost` (each `base + per_level_above_first x (level - 1)`); `anvil_cost`; `slots` (equipment slots in which the enchantment is active: `mainhand`, `offhand`, `hand`, `head`, `chest`, `legs`, `feet`, `armor`, `any`); `supported_items` (an item tag the enchantment may be applied to by anvil, book or command); optional `primary_items` (the items the enchanting table may offer it for; default the supported set); optional `exclusive_set` (an enchantment tag; members cannot coexist); `effects` (a map from effect-component name to a list of conditional effects). A level-based number is one of: `linear` (base + per_level_above_first x (L - 1)), `levels_squared` (L x L + added), `fraction` (numerator / denominator, each a level-based number), `lookup` (a list of values by level, with a fallback formula for levels beyond it), `clamped`, or a constant.

### 6.2 Table (read from the 43 JSON files)

| Enchantment | Max level | Weight | Min cost (base + per level above first) | Max cost | Anvil cost | Slots | Supported items (item tag) | Primary items (table) | Exclusive set |
|---|---|---|---|---|---|---|---|---|---|
| `aqua_affinity` | 1 | 2 | 1 + 0 | 41 + 0 | 4 | head | #enchantable/head_armor | (= supported) | - |
| `bane_of_arthropods` | 5 | 5 | 5 + 8 | 25 + 8 | 2 | mainhand | #enchantable/weapon | #enchantable/melee_weapon | set:damage |
| `binding_curse` | 1 | 1 | 25 + 0 | 50 + 0 | 8 | armor | #enchantable/equippable | (= supported) | - |
| `blast_protection` | 4 | 2 | 5 + 8 | 13 + 8 | 4 | armor | #enchantable/armor | (= supported) | set:armor |
| `breach` | 4 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/mace | (= supported) | set:damage |
| `channeling` | 1 | 1 | 25 + 0 | 50 + 0 | 8 | mainhand | #enchantable/trident | (= supported) | - |
| `density` | 5 | 5 | 5 + 8 | 25 + 8 | 2 | mainhand | #enchantable/mace | (= supported) | set:damage |
| `depth_strider` | 3 | 2 | 10 + 10 | 25 + 10 | 4 | feet | #enchantable/foot_armor | (= supported) | set:boots |
| `efficiency` | 5 | 10 | 1 + 10 | 51 + 10 | 1 | mainhand | #enchantable/mining | (= supported) | - |
| `feather_falling` | 4 | 5 | 5 + 6 | 11 + 6 | 2 | armor | #enchantable/foot_armor | (= supported) | - |
| `fire_aspect` | 2 | 2 | 10 + 20 | 60 + 20 | 4 | mainhand | #enchantable/fire_aspect | #enchantable/melee_weapon | - |
| `fire_protection` | 4 | 5 | 10 + 8 | 18 + 8 | 2 | armor | #enchantable/armor | (= supported) | set:armor |
| `flame` | 1 | 2 | 20 + 0 | 50 + 0 | 4 | mainhand | #enchantable/bow | (= supported) | - |
| `fortune` | 3 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/mining_loot | (= supported) | set:mining |
| `frost_walker` | 2 | 2 | 10 + 10 | 25 + 10 | 4 | feet | #enchantable/foot_armor | (= supported) | set:boots |
| `impaling` | 5 | 2 | 1 + 8 | 21 + 8 | 4 | mainhand | #enchantable/trident | (= supported) | set:damage |
| `infinity` | 1 | 1 | 20 + 0 | 50 + 0 | 8 | mainhand | #enchantable/bow | (= supported) | set:bow |
| `knockback` | 2 | 5 | 5 + 20 | 55 + 20 | 2 | mainhand | #enchantable/melee_weapon | (= supported) | - |
| `looting` | 3 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/melee_weapon | (= supported) | - |
| `loyalty` | 3 | 5 | 12 + 7 | 50 + 0 | 2 | mainhand | #enchantable/trident | (= supported) | - |
| `luck_of_the_sea` | 3 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/fishing | (= supported) | - |
| `lunge` | 3 | 5 | 5 + 8 | 25 + 8 | 2 | hand | #enchantable/lunge | (= supported) | - |
| `lure` | 3 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/fishing | (= supported) | - |
| `mending` | 1 | 2 | 25 + 25 | 75 + 25 | 4 | any | #enchantable/durability | (= supported) | - |
| `multishot` | 1 | 2 | 20 + 0 | 50 + 0 | 4 | mainhand | #enchantable/crossbow | (= supported) | set:crossbow |
| `piercing` | 4 | 10 | 1 + 10 | 50 + 0 | 1 | mainhand | #enchantable/crossbow | (= supported) | set:crossbow |
| `power` | 5 | 10 | 1 + 10 | 16 + 10 | 1 | mainhand | #enchantable/bow | (= supported) | - |
| `projectile_protection` | 4 | 5 | 3 + 6 | 9 + 6 | 2 | armor | #enchantable/armor | (= supported) | set:armor |
| `protection` | 4 | 10 | 1 + 11 | 12 + 11 | 1 | armor | #enchantable/armor | (= supported) | set:armor |
| `punch` | 2 | 2 | 12 + 20 | 37 + 20 | 4 | mainhand | #enchantable/bow | (= supported) | - |
| `quick_charge` | 3 | 5 | 12 + 20 | 50 + 0 | 2 | mainhand,offhand | #enchantable/crossbow | (= supported) | - |
| `respiration` | 3 | 2 | 10 + 10 | 40 + 10 | 4 | head | #enchantable/head_armor | (= supported) | - |
| `riptide` | 3 | 2 | 17 + 7 | 50 + 0 | 4 | hand | #enchantable/trident | (= supported) | set:riptide |
| `sharpness` | 5 | 10 | 1 + 11 | 21 + 11 | 1 | mainhand | #enchantable/sharp_weapon | #enchantable/melee_weapon | set:damage |
| `silk_touch` | 1 | 1 | 15 + 0 | 65 + 0 | 8 | mainhand | #enchantable/mining_loot | (= supported) | set:mining |
| `smite` | 5 | 5 | 5 + 8 | 25 + 8 | 2 | mainhand | #enchantable/weapon | #enchantable/melee_weapon | set:damage |
| `soul_speed` | 3 | 1 | 10 + 10 | 25 + 10 | 8 | feet | #enchantable/foot_armor | (= supported) | - |
| `sweeping_edge` | 3 | 2 | 5 + 9 | 20 + 9 | 4 | mainhand | #enchantable/sweeping | (= supported) | - |
| `swift_sneak` | 3 | 1 | 25 + 25 | 75 + 25 | 8 | legs | #enchantable/leg_armor | (= supported) | - |
| `thorns` | 3 | 1 | 10 + 20 | 60 + 20 | 8 | any | #enchantable/armor | #enchantable/chest_armor | - |
| `unbreaking` | 3 | 5 | 5 + 8 | 55 + 8 | 2 | any | #enchantable/durability | (= supported) | - |
| `vanishing_curse` | 1 | 1 | 25 + 0 | 50 + 0 | 8 | any | #enchantable/vanishing | (= supported) | - |
| `wind_burst` | 3 | 2 | 15 + 9 | 65 + 9 | 4 | mainhand | #enchantable/mace | (= supported) | - |

Exclusive sets (tags `enchantment/exclusive_set/*`): `armor` = protection, blast_protection, fire_protection, projectile_protection; `boots` = frost_walker, depth_strider; `bow` = infinity, mending; `crossbow` = multishot, piercing; `damage` = sharpness, smite, bane_of_arthropods, impaling, density, breach; `mining` = fortune, silk_touch; `riptide` = loyalty, channeling (this set is the `exclusive_set` field of the `riptide` enchantment only, so riptide excludes loyalty and channeling; the table's `set:riptide` entry is on `riptide`).
Tags: `treasure` = binding_curse, vanishing_curse, swift_sneak, soul_speed, frost_walker, mending, wind_burst; `curse` = binding_curse, vanishing_curse; `in_enchanting_table` = `non_treasure` (every enchantment not in `treasure`); `tradeable`, `on_random_loot` = non_treasure + binding_curse, vanishing_curse, frost_walker, mending.
Item sets (resolved tags `item/enchantable/*`): `weapon` = swords, spears, axes, mace; `melee_weapon` = swords, spears; `sharp_weapon` = swords, spears, axes; `fire_aspect` = melee weapons + mace; `sweeping` = swords; `lunge` = spears; `mining` = axes, pickaxes, shovels, hoes, shears; `mining_loot` = same without shears; `durability` = 83 items (read in full): all armor (28 humanoid pieces), `turtle_helmet`, `elytra`, `shield`, every sword, axe, pickaxe, shovel, hoe and spear (7 tiers each), `bow`, `crossbow`, `trident`, `flint_and_steel`, `shears`, `brush`, `fishing_rod`, `carrot_on_a_stick`, `warped_fungus_on_a_stick`, `mace`; `mace`, `trident`, `bow`, `crossbow`, `fishing` = the single item; `head_armor`, `chest_armor`, `leg_armor`, `foot_armor` = the seven material sets (leather, copper, chainmail, iron, golden, diamond, netherite; head also `turtle_helmet`); `armor` = all four; `equippable` = armor, elytra, heads, carved pumpkin; `vanishing` = the `durability` set plus `compass`, `carved_pumpkin` and every item in the tag `skulls` (player, creeper, zombie, skeleton, wither skeleton, dragon, piglin heads): 92 items.

### 6.3 Effects, by enchantment (the effect keys read)

Effect values are level-based numbers (6.1). "Req" is the requirement predicate.

| Enchantment | Effect (key) and formula |
|---|---|
| `protection` | `damage_protection` add 1 + 1 x (L - 1) = L protection points, req: the source is not in `bypasses_invulnerability` |
| `fire_protection` | `damage_protection` add 2L, req source in `is_fire`; attribute `burning_time` `add_multiplied_base` -0.15 x L |
| `blast_protection` | `damage_protection` add 2L, req source in `is_explosion`; attribute `explosion_knockback_resistance` +0.15 L |
| `projectile_protection` | `damage_protection` add 2L, req `is_projectile` |
| `feather_falling` | `damage_protection` add 3L, req `is_fall` |
| `respiration` | attribute `oxygen_bonus` +L |
| `aqua_affinity` | attribute `submerged_mining_speed` `add_multiplied_total` 4 + 4 x (L - 1) = 4 (so x5 speed under water) |
| `depth_strider` | attribute `water_movement_efficiency` +0.33333334 L |
| `frost_walker` | `damage_immunity` to `burn_from_stepping`; `location_changed`: replace a disk of water below with `frosted_ice` (age 0), radius clamp(3 + (L - 1), 0, 16), only when on the ground and not riding |
| `soul_speed` | `location_changed` attributes `movement_speed` +0.0405 + 0.0105 (L - 1) and `movement_efficiency` +1 when standing on `soul_speed_blocks`; soul particles (`tick`) |
| `swift_sneak` | attribute `sneaking_speed` +0.15 L |
| `thorns` | `post_attack` (affected attacker, enchanted victim): with chance 0.15 L: `damage_entity` type `thorns` uniform 1..5 and `change_item_damage` 2 on the armor |
| `binding_curse` / `vanishing_curse` | `prevent_armor_change` / `prevent_equipment_drop` |
| `sharpness` | `damage` add 1 + 0.5 (L - 1) |
| `smite` | `damage` add 2.5 L, req victim type in `sensitive_to_smite` (skeleton, stray, wither_skeleton, skeleton_horse, bogged, parched, zombie_horse, camel_husk, zombie, zombie_villager, zombified_piglin, zoglin, drowned, husk, zombie_nautilus, wither, phantom) |
| `bane_of_arthropods` | `damage` add 2.5 L vs `sensitive_to_bane_of_arthropods` (bee, endermite, silverfish, spider, cave_spider); and `post_attack` (direct hits): Slowness amplifier 3 on the victim, duration between `min_duration` 1.5 s and `max_duration` 1.5 + 0.5 (L - 1) s |
| `impaling` | `damage` add 2.5 L vs `sensitive_to_impaling` (turtle, axolotl, guardian, elder_guardian, cod, pufferfish, salmon, tropical_fish, dolphin, squid, glow_squid, tadpole, nautilus, zombie_nautilus) |
| `density` | `smash_damage_per_fallen_block` add 0.5 L per block fallen |
| `breach` | `armor_effectiveness` add -0.15 L (4.5) |
| `wind_burst` | `post_attack` explosion at the attacker (`data/minecraft/enchantment/wind_burst.json`): radius 3.5, knockback multiplier `lookup` [1.2, 1.75, 2.2] for levels 1 to 3 (fallback 1.5 + 0.35 x (L - 1) beyond), block interaction `trigger`, req: the direct attacker is not flying and its fall distance is >= 1.5 |
| `knockback` | `knockback` add L (the attack K uses (attribute + L) / 2, 4.2) |
| `fire_aspect` | `post_attack` (direct hits): `ignite` the victim for 4 + 4 (L - 1) s |
| `looting` | `equipment_drops` add 0.01 L chance (player attacker) |
| `sweeping_edge` | attribute `sweeping_damage_ratio` +L / (L + 1) |
| `efficiency` | attribute `mining_efficiency` +(L x L + 1) (13 §2.1) |
| `silk_touch` | `block_experience` set 0 |
| `fortune` | no effect entry; handled by loot functions (11 §9.2: `ore_drops` formula) |
| `unbreaking` | 5.2 |
| `mending` | 5.3 |
| `power` | `damage` add 1 + 0.5 (L - 1), req the direct attacker is in `arrows` |
| `punch` | `knockback` add L, req direct attacker in `arrows` |
| `flame` | `projectile_spawned`: ignite 100 ticks |
| `infinity` | `ammo_use` set 0 when the ammo item is `arrow` exactly (tipped and spectral arrows are consumed) |
| `multishot` | `projectile_count` +2 L, `projectile_spread` +10 L degrees (L = 1) |
| `piercing` | `projectile_piercing` +L |
| `quick_charge` | `crossbow_charge_time` add -0.25 L (seconds), charging sounds quick_charge_1..3 |
| `loyalty` | `trident_return_acceleration` +L |
| `riptide` | `trident_spin_attack_strength` 1.5 + 0.75 (L - 1); sounds riptide_1..3 |
| `channeling` | `hit_block` / `post_attack`: summon `lightning_bolt` and play `item.trident.thunder` volume 5.0 when thundering and the sky is visible |
| `lunge` | `post_piercing_attack`: item damage 1, exhaustion 4 L, impulse 0.458 L: the vector (0, 0, 1) is rotated by the player's look quaternion, multiplied component-wise by `coordinate_scale` (1, 0, 1) so the vertical part is dropped, scaled by the magnitude, added to the player's velocity (`ApplyEntityImpulse`), Set Entity Motion is sent and a 10-tick post-impulse grace time starts, requires not riding, not gliding, not in water, and (non-players, creative players, or food level >= 7) |
| `luck_of_the_sea` | `fishing_luck_bonus` +L |
| `lure` | `fishing_time_reduction` +5 L (seconds; x 20 ticks, 3.11) |

### 6.4 Protection arithmetic summary

Protection points of one hit P = the sum over every worn item of the matching `damage_protection` values (all armor slots; a piece contributes each of its enchantments that apply to the damage source); the damage is then multiplied by 1 - clamp(P, 0, 20) / 25 (4.4 step 2). Example: four diamond pieces with Protection IV: P = 16 -> x 0.36; with a Protection IV helmet only: x 0.84; Blast Protection IV on all four vs an explosion: 4 x 8 = 32 -> clamped to 20 -> x 0.2.

### 6.5 Enchanting table (`EnchantmentMenu`, `EnchantingTableBlock`, `EnchantmentHelper`)

- **Bookshelf power B** (`EnchantingTableBlock.BOOKSHELF_OFFSETS`, `isValidBookShelf`): the offsets are (dx, dy, dz) with dx and dz from -2 to 2, dy 0 or 1, restricted to the outer ring (|dx| = 2 or |dz| = 2); an offset counts when the block there is in the tag `enchantment_power_provider` (just `bookshelf`) and the block at (dx / 2, dy, dz / 2) (integer division) is in the tag `enchantment_power_transmitter` (air, water, lava, grass, ferns, bushes, seagrass, fire, snow, vines, glow lichen, light, cave air, bubble column, roots, leaf litter, hanging roots and the other 30 listed in the tag). B is capped at 15 in `getEnchantmentCost`.
- **Seeds**: the menu holds `enchantmentSeed` (the player's `getEnchantmentSeed`, renewed after every enchant). When the inputs change (`slotsChanged`, inputs: item in slot 0, lapis in slot 1) the menu seeds its random with the seed and for slots 0, 1, 2 in order computes `costs[i] = getEnchantmentCost(random, i, B, stack)`; a cost lower than i + 1 is set to 0. The offered clue for slot i is `getEnchantmentList(stack, i, costs[i])`, which reseeds the random with **seed + i** and calls `selectEnchantment`.
- **Cost** (`getEnchantmentCost`, read; N = the stack's `enchantable` value, none -> 0): b = min(B, 15); base = nextInt(8) + 1 + (b >> 1) + nextInt(b + 1); slot 0: max(base / 3, 1); slot 1: base x 2 / 3 + 1; slot 2: max(base, b x 2) (integer division).
- **Selection** (`selectEnchantment(random, stack, level, pool)`; the pool is the tag `in_enchanting_table`): m = level + 1 + nextInt(N / 4 + 1) + nextInt(N / 4 + 1); f = (nextFloat + nextFloat - 1) x 0.15; m = clamp(round(m + m x f), 1, 2147483647). Candidates: for each enchantment of the pool whose `primary_items` (default supported) contain the stack (any enchantment for a `book`), the **highest** level L (from `max_level` down to 1) with min_cost(L) <= m <= max_cost(L); one candidate is picked by `weight` (`WeightedRandom`). Then repeatedly: if `nextInt(50) > m` stop; remove from the candidates every enchantment incompatible with the last one picked (`filterCompatibleEnchantments`); stop if none remain; pick another by weight; m = m / 2 (integer).
- **Choosing an option** (`clickMenuButton(player, id)`, id 0..2): needs at least id + 1 lapis lazuli in slot 1 (not for infinite materials), and costs[id] > 0 and the player's level >= id + 1 and >= costs[id] (or infinite materials). Effect: `Player.onEnchantmentPerformed(stack, id + 1)` (the level payment: id + 1 levels), the list is recomputed from the menu's seed, a `book` becomes an `enchanted_book`, each selected enchantment is applied (`ItemStack.enchant`), `id + 1` lapis are consumed, the `enchant_item` stat and trigger fire, the player's enchantment seed is renewed, and the table sound `block.enchantment_table.use` plays with pitch `nextFloat x 0.1 + 0.9`.
- Loot-table enchanting (`enchant_with_levels`, 30 levels from `on_random_loot`, fishing treasure 3.11) uses the same selection with the given level.

---

## 7. Gameplay packets used (not repeated; see 05a to 05c and 09)

| Feature | Serverbound | Clientbound |
|---|---|---|
| Break a block with a tool | Player Action 0x29 (`START_DESTROY_BLOCK`, `STOP_DESTROY_BLOCK`, `ABORT_DESTROY_BLOCK`), sequence | Block Update 0x08, Block Changed Ack 0x04, Block Destruction 0x05 (crack stages), Container Set Slot 0x14 (the tool's new `damage`), Set Equipment 0x68, Sound 0x77, Level Event 0x2F |
| Melee attack | Attack 0x01 (entity id); Interact 0x1A for non-attack interactions (shears on sheep, name tag, lead, saddle) | Damage Event 0x19, Hurt Animation 0x2B, Entity Event 0x22 (hurt/death, totem 35, hook 31, firework 17), Set Entity Motion 0x67, Swing Animation 0x7B, Animate 0x02, Level Particles 0x30, Set Health 0x6A, Set Entity Data 0x65 (health, fire flags), Update Mob Effect 0x87 / Remove Mob Effect 0x4F |
| Use items (food, buckets, bow, shield, throwables, fishing rod, spyglass, firework) | Use Item 0x43; Use Item On 0x42; Player Action `RELEASE_USE_ITEM` (6) and `STAB` (8); Player Command 0x2A (start gliding) | Cooldown 0x16 (the item cooldowns), Add Entity 0x01 and Set Entity Data 0x65 (arrows, tridents, pearls, bobbers, rockets), Teleport Entity 0x80 / Move Entity packets, Projectile Power 0x8A, Take Item Entity 0x7F, Game Event 0x27 (arrow-hit sound), Sound Entity 0x76 |
| Durability and inventory | Container Click 0x12, Set Carried Item 0x36 | Container Set Slot 0x14, Container Set Content 0x12, Set Cursor Item 0x62, Set Player Inventory 0x6E |
| Attributes (reach, armor, attack speed) | | Update Attributes 0x86 (item and enchantment modifiers) |
| Health, hunger, XP, death, respawn | Client Command 0x0C | Set Health 0x6A, Set Experience 0x69, Player Combat Kill 0x45 / Enter 0x44 / End 0x43, Respawn 0x54, Player Position 0x49 (after a pearl or respawn) |
| Anvil, grindstone, enchanting table | Container Click 0x12, Container Close 0x13, button clicks via Container Button Click (05c) | Open Screen 0x3C, Container Set Data 0x13 (costs, enchant levels), Container Set Slot |

---

## 8. Worked examples (computed from sections 2 to 6)

1. **Cooldown**: iron sword A = 4 + (-2.4) = 1.6, D = 20 / 1.6 = 12.5 ticks. Ticker 6: s = (6 + 0.5) / 12.5 = 0.52; scale = 0.2 + 0.52 x 0.52 x 0.8 = 0.41632; damage 6 x 0.41632 = 2.498. Ticker 12: s = 1.0 (12.5 / 12.5), full.
2. **Full hit, crit, Sharpness V, no armor**: diamond sword: attack_damage = 1 + 3 + 3 = 7. Full strength, falling (not sprinting): crit. E = 1.0 x (1 + 0.5 x 4) = 3.0. base = 7 x 1.0 = 7; crit 7 x 1.5 = 10.5; total 10.5 + 3.0 = 13.5.
3. **Same hit on a target in full diamond armor** (armor 20, toughness 8) and Protection IV x4 (P = 16): f = 2 + 8/4 = 4; e = clamp(20 - 13.5/4 = 16.625, 4, 20) = 16.625; q = 0.665; after armor 13.5 x 0.335 = 4.5225; after protection x (1 - 16/25 = 0.36) = 1.6281. Armor wear per piece: max(1, floor(13.5 / 4)) = 3.
4. **Sprint knockback hit**: iron axe (attack_damage 9, A = 0.9, D = 22.2 ticks), ticker 20: s = 20.5 / 22.22 = 0.9225 > 0.9, so fullStrength; sprinting on the ground: sprintKnockback true, no crit (sprinting), no sweep (not a sword). K = 0 + 0.5. The target takes the default 0.4 knockback and then 0.5 along the attacker's facing; the attacker's velocity is multiplied by (0.6, 1, 0.6) and it stops sprinting. A blocking shield on the target is disabled for 100 ticks.
5. **Sweep**: iron sword, Sweeping Edge II, full strength, on the ground, standing still, not sprinting: base 6; ratio 2/3; sweepDamage = 1 + 4 = 5.0 to each other living entity within 3 blocks of the target (x s = 1).
6. **Mace smash**: mace attack_damage 6, full strength, fall h = 10 blocks, Density III, falling and not sprinting: base 6; bonus 22 + (10 - 8) = 24; Density 0.5 x 3 x 10 = 15 (the density term is part of `getAttackDamageBonus`); base = 6 + 39 = 45; crit x 1.5 = 67.5; enchantment part E = 0. Shockwave on an entity 1.0 block from the attacker with fall > 5: (3.5 - 1.0) x 0.7 x 2 = 3.5 (times 1 - knockback resistance).
7. **Bow**: full draw (t >= 20): p = 1.0, velocity 3.0, crit. Damage = ceil(3.0 x 2.0) = 6; crit adds nextInt(6 / 2 + 2 = 5) = 0..4: 6..10. Power V: base 2.0 + (1 + 0.5 x 4 = 3.0) = 5.0: ceil(3.0 x 5.0) = 15, crit + nextInt(15 / 2 + 2 = 9) = 0..8: 15..23. Half draw (t = 10): p = (0.25 + 1.0) / 3 = 0.4167, velocity 1.25, damage ceil(2.5) = 3, no crit.
8. **Break time with enchantments** (13 §2.1 and 13 §9 formulas): iron pickaxe, Efficiency III, stone (hardness 1.5, correct tool): speed 6 + (9 + 1) = 16; progress 16 / 1.5 / 30 = 0.3556; ticks = ceil(1 / 0.3556) = 3. Diamond axe on an oak log (2.0): 8 / 2 / 30 = 0.1333, 8 ticks; Efficiency V: (8 + 26) / 2 / 30 = 0.5667, 2 ticks. Shears on white wool (0.8; wool needs no tool): 5 / 0.8 / 30 = 0.2083, 5 ticks. Sword on cobweb: 15 / hardness / 30 (hardness from 13 §2.6 / the block registry).
9. **Anvil**: two iron pickaxes, left damage 100 of 250, right damage 200 of 250: a = 150, b = 50, bonus 250 x 12 / 100 = 30; remaining 230; damage 20. Repair with iron ingots: u = min(100, 250 / 4 = 62) = 62 per ingot: one ingot -> damage 38, cost +1; a second -> u = 38 -> damage 0, cost +2 total (repair_cost 0). Result `repair_cost` becomes 2 x 0 + 1 = 1 (when stored).
10. **Crafting-grid repair**: two iron pickaxes damage 100 and 200: 150 + 50 + 250 x 5 / 100 = 12 -> 212 remaining, damage 38; no enchantments except curses.
11. **Fall damage**: 10 blocks: floor(10 + 0.000001 - 3.0) = 7; with Feather Falling IV: P = 12, x (1 - 12/25) = 0.52 -> 3.64 (health damage is applied as float after `calculateFallDamage` int 7: 7 x 0.52 = 3.64). Armor does not apply (fall is in `bypasses_armor`).
12. **Hunger**: exhaustion 4.0 reached: exhaustion 0, saturation 5.0 -> 4.0; with food 20 and saturation 4.0 and health 15: after 10 ticks: heal(min(4, 6) / 6) = 0.667, exhaustion +4.0.
13. **Fishing**: Lure II: wait = Mth.nextInt(random, 100, 600) - 200 ticks (inclusive draw, 100..600, so -100..400 ticks after the subtraction) (the subtraction is not clamped: no `max` call follows it in `catchingFish`, so the result can be zero or negative, which counts as expired).

---

## 9. Validation: checkable facts

1. `ToolMaterial` constants: wood (59, 2.0, 0, 15), stone (131, 4.0, 1.0, 5), copper (190, 5.0, 1.0, 13), iron (250, 6.0, 2.0, 14), diamond (1561, 8.0, 3.0, 10), gold (32, 12.0, 0, 22), netherite (2031, 9.0, 4.0, 15).
2. Totals: wooden sword 4 damage / 1.6 speed; stone axe 9 / 0.8; netherite axe 10 / 1.0; diamond hoe 1 / 4.0; netherite pickaxe 6 / 1.2; mace 6 / 0.6; trident 9 / 1.1; wooden spear 1 / 1.5385.
3. Counts: `Items` assigns 1218 item fields; tool materials 7; spears 7; damage types 51; enchantments 43; data component types 122 (ids 0 to 121; `tool` 28, `weapon` 29, `attribute_modifiers` 16, `max_damage` 2, `damage` 3, `enchantable` 31, `repairable` 33, `blocks_attacks` 37, `kinetic_weapon` 39).
4. `block_transformer` entries: axe 7 (rule counts 25, 39, 3, 3, 52, 4, 4), hoe 2, shovel 1.
5. Armor math: R 20, T 8, d 12: result 3.84; R 20, T 0, d 5: f = 2, e = clamp(20 - 2.5, 4, 20) = 17.5, q 0.7, result 1.5.
6. Shield: damage 2.9 costs 0 durability, 3.0 costs 4, 6.0 costs 7; an attacker 91 degrees off the facing is not blocked.
7. Invulnerability: hit 6 then hit 4 within 10 ticks -> second ignored; hit 6 then hit 9 -> 3 applied; after 10 ticks any hit applies in full.
8. Bow power table (3.9) and crossbow charge ticks 25/20/15/10.
9. Regeneration timers: 10 ticks (food 20 and saturation > 0), 80 ticks (food >= 18), starvation 80 ticks.
10. XP per level: L 0 -> 7, L 14 -> 35, L 15 -> 37, L 29 -> 107, L 30 -> 112, L 31 -> 121.

---

## Open questions

Follow-up round: every item that the first pass marked "recalled" or "not decoded" was searched for in the jar. Items found are now stated in place with the class or data file; what is still open is below, each with what was searched.

1. **Spear stab on non-living targets**: what `stabAttack`'s knockback and dismount flags do to non-living targets was not traced (searched `Player.stabAttack`); item damage per stab is read (3.12).
2. (closed) Shield push-back: read in 3.6 step 5.
3. (closed) Server attack range margin: read in 4.1 (3.0).
4. (closed) Crossbow crit flag: read, see 3.9.
5. (closed) Fire spread: `FireBlock.tick`, `checkBurnOut`, `canSurvive` and the flammability table are read in 3.3a; `isNearRain` and `canSpreadFireAround` (a level-side check) were not decoded.
6. (closed) Looting count effects: read in 4.10; per-mob loot content belongs to 18 §7.6 and 19-21.
7. (closed) Experience orb pull exponent: read in 4.10 (t squared).
8. **Item `damage` exhaustion per type**: the table in 4.12 is the data; which damage types actually reach a player's `actuallyHurt` with non-zero damage is gameplay.
9. **Fire and campfire**: `fireIgnite` adjusts remaining fire ticks with a random `nextInt(1, 3)` step (constants 1 and 3 read); the surrounding algebra was not recorded.
10. (closed) Lunge impulse frame: read in 6.3.
11. **`enchantable/*` item tags** other than those printed (`armor`, `bow`, ... tags are single or resolved as stated); the 92-item `vanishing` list is the union stated in 6.2.
12. **Elytra start conditions** (`startFallFlying` constants 7 and 1) and the client-side start (13 §1.4 jump rules); unglide on landing.
13. **Respawn**: bed `BedRule` evaluation (`BedRule$Rule.test`) per dimension was read only as field names; the rest of the respawn flow is read in 4.10.
14. Item components not covered: `food` and `consumable` effect lists (only `milk_bucket`, spider eye and the default drink constants were read), `bundle_contents`, `potion_contents` effects, trim, instruments.
16. **Verified in earlier rounds only** (not re-read in round 3): crossbow and bow numbers, anvil, grindstone and enchanting table, hunger and regeneration, XP orb behaviour, bucket internals, lead / name tag / saddle, elytra physics, and the resolved tag lists.
17. **Periodic mob-effect rules (4.9a)**: the `applyEffectTick` overrides of `bad_omen` and `raid_omen` and the exact amplifier range cap were not re-read for 4.9a; the shift-count masking for amplifiers of 32 and above is deduced from the instruction, not tested (inferred).

## Appendix A. `mineable/*` block tags (complete, resolved)

Blocks mined at the tool material speed by the matching tool kind (13 §2.1); the pickaxe list is the largest. Names are block ids.

**`mineable/axe`** (304 blocks): note_block, bamboo, barrel, bee_nest, beehive, big_dripleaf_stem, big_dripleaf, bookshelf, brown_mushroom_block, campfire, cartography_table, carved_pumpkin, chest, chorus_flower, chorus_plant, cocoa, composter, crafting_table, daylight_detector, fletching_table, glow_lichen, jack_o_lantern, jukebox, ladder, lectern, loom, melon, mushroom_stem, pumpkin, red_mushroom_block, smithing_table, soul_campfire, trapped_chest, vine, white_banner, orange_banner, magenta_banner, light_blue_banner, yellow_banner, lime_banner, pink_banner, gray_banner, light_gray_banner, cyan_banner, purple_banner, blue_banner, brown_banner, green_banner, red_banner, black_banner, white_wall_banner, orange_wall_banner, magenta_wall_banner, light_blue_wall_banner, yellow_wall_banner, lime_wall_banner, pink_wall_banner, gray_wall_banner, light_gray_wall_banner, cyan_wall_banner, purple_wall_banner, blue_wall_banner, brown_wall_banner, green_wall_banner, red_wall_banner, black_wall_banner, acacia_fence_gate, birch_fence_gate, dark_oak_fence_gate, pale_oak_fence_gate, jungle_fence_gate, oak_fence_gate, spruce_fence_gate, crimson_fence_gate, warped_fence_gate, mangrove_fence_gate, bamboo_fence_gate, cherry_fence_gate, poplar_fence_gate, dark_oak_log, dark_oak_wood, stripped_dark_oak_log, stripped_dark_oak_wood, pale_oak_log, pale_oak_wood, stripped_pale_oak_log, stripped_pale_oak_wood, oak_log, oak_wood, stripped_oak_log, stripped_oak_wood, acacia_log, acacia_wood, stripped_acacia_log, stripped_acacia_wood, birch_log, birch_wood, stripped_birch_log, stripped_birch_wood, jungle_log, jungle_wood, stripped_jungle_log, stripped_jungle_wood, spruce_log, spruce_wood, stripped_spruce_log, stripped_spruce_wood, mangrove_log, mangrove_wood, stripped_mangrove_log, stripped_mangrove_wood, cherry_log, cherry_wood, stripped_cherry_log, stripped_cherry_wood, poplar_log, poplar_wood, stripped_poplar_log, stripped_poplar_wood, crimson_stem, stripped_crimson_stem, crimson_hyphae, stripped_crimson_hyphae, warped_stem, stripped_warped_stem, warped_hyphae, stripped_warped_hyphae, oak_planks, spruce_planks, birch_planks, jungle_planks, acacia_planks, dark_oak_planks, pale_oak_planks, crimson_planks, warped_planks, mangrove_planks, bamboo_planks, cherry_planks, poplar_planks, oak_sign, spruce_sign, birch_sign, acacia_sign, jungle_sign, dark_oak_sign, pale_oak_sign, crimson_sign, warped_sign, mangrove_sign, poplar_sign, bamboo_sign, cherry_sign, oak_wall_sign, spruce_wall_sign, birch_wall_sign, acacia_wall_sign, jungle_wall_sign, dark_oak_wall_sign, pale_oak_wall_sign, crimson_wall_sign, warped_wall_sign, mangrove_wall_sign, bamboo_wall_sign, cherry_wall_sign, poplar_wall_sign, oak_button, spruce_button, birch_button, jungle_button, acacia_button, dark_oak_button, pale_oak_button, crimson_button, warped_button, mangrove_button, bamboo_button, cherry_button, poplar_button, oak_door, spruce_door, birch_door, jungle_door, acacia_door, dark_oak_door, pale_oak_door, crimson_door, warped_door, mangrove_door, bamboo_door, cherry_door, poplar_door, oak_fence, acacia_fence, dark_oak_fence, pale_oak_fence, spruce_fence, birch_fence, jungle_fence, crimson_fence, warped_fence, mangrove_fence, bamboo_fence, cherry_fence, poplar_fence, oak_pressure_plate, spruce_pressure_plate, birch_pressure_plate, jungle_pressure_plate, acacia_pressure_plate, dark_oak_pressure_plate, pale_oak_pressure_plate, crimson_pressure_plate, warped_pressure_plate, mangrove_pressure_plate, bamboo_pressure_plate, cherry_pressure_plate, poplar_pressure_plate, oak_slab, spruce_slab, birch_slab, jungle_slab, acacia_slab, dark_oak_slab, pale_oak_slab, crimson_slab, warped_slab, mangrove_slab, bamboo_slab, cherry_slab, poplar_slab, oak_stairs, spruce_stairs, birch_stairs, jungle_stairs, acacia_stairs, dark_oak_stairs, pale_oak_stairs, crimson_stairs, warped_stairs, mangrove_stairs, bamboo_stairs, cherry_stairs, poplar_stairs, acacia_trapdoor, birch_trapdoor, dark_oak_trapdoor, pale_oak_trapdoor, jungle_trapdoor, oak_trapdoor, spruce_trapdoor, crimson_trapdoor, warped_trapdoor, mangrove_trapdoor, bamboo_trapdoor, cherry_trapdoor, poplar_trapdoor, mangrove_roots, oak_hanging_sign, spruce_hanging_sign, birch_hanging_sign, acacia_hanging_sign, cherry_hanging_sign, jungle_hanging_sign, dark_oak_hanging_sign, pale_oak_hanging_sign, crimson_hanging_sign, warped_hanging_sign, mangrove_hanging_sign, poplar_hanging_sign, bamboo_hanging_sign, oak_wall_hanging_sign, spruce_wall_hanging_sign, birch_wall_hanging_sign, acacia_wall_hanging_sign, cherry_wall_hanging_sign, jungle_wall_hanging_sign, dark_oak_wall_hanging_sign, pale_oak_wall_hanging_sign, crimson_wall_hanging_sign, warped_wall_hanging_sign, mangrove_wall_hanging_sign, bamboo_wall_hanging_sign, poplar_wall_hanging_sign, bamboo_mosaic, bamboo_mosaic_slab, bamboo_mosaic_stairs, bamboo_block, stripped_bamboo_block, chiseled_bookshelf, acacia_shelf, bamboo_shelf, birch_shelf, cherry_shelf, crimson_shelf, dark_oak_shelf, jungle_shelf, mangrove_shelf, oak_shelf, pale_oak_shelf, spruce_shelf, warped_shelf, poplar_shelf, creaking_heart

**`mineable/shovel`** (36 blocks): clay, dirt, coarse_dirt, podzol, farmland, grass_block, gravel, mycelium, sand, red_sand, snow_block, snow, soul_sand, dirt_path, soul_soil, rooted_dirt, muddy_mangrove_roots, mud, suspicious_sand, suspicious_gravel, white_concrete_powder, orange_concrete_powder, magenta_concrete_powder, light_blue_concrete_powder, yellow_concrete_powder, lime_concrete_powder, pink_concrete_powder, gray_concrete_powder, light_gray_concrete_powder, cyan_concrete_powder, purple_concrete_powder, blue_concrete_powder, brown_concrete_powder, green_concrete_powder, red_concrete_powder, black_concrete_powder

**`mineable/hoe`** (33 blocks): jungle_leaves, oak_leaves, spruce_leaves, pale_oak_leaves, dark_oak_leaves, acacia_leaves, birch_leaves, azalea_leaves, flowering_azalea_leaves, mangrove_leaves, cherry_leaves, red_poplar_leaves, orange_poplar_leaves, yellow_poplar_leaves, nether_wart_block, warped_wart_block, hay_block, dried_kelp_block, target, shroomlight, sponge, wet_sponge, sculk_sensor, calibrated_sculk_sensor, moss_block, moss_carpet, pale_moss_block, pale_moss_carpet, sculk, sculk_catalyst, sculk_vein, sculk_shrieker, straw_bed

**`mineable/pickaxe`** (552 blocks): stone, granite, polished_granite, diorite, polished_diorite, andesite, polished_andesite, cobblestone, gold_ore, deepslate_gold_ore, iron_ore, deepslate_iron_ore, coal_ore, deepslate_coal_ore, nether_gold_ore, lapis_ore, deepslate_lapis_ore, lapis_block, dispenser, sandstone, chiseled_sandstone, cut_sandstone, gold_block, iron_block, bricks, mossy_cobblestone, obsidian, spawner, diamond_ore, deepslate_diamond_ore, diamond_block, furnace, cobblestone_stairs, stone_pressure_plate, iron_door, redstone_ore, deepslate_redstone_ore, netherrack, basalt, polished_basalt, stone_bricks, mossy_stone_bricks, cracked_stone_bricks, chiseled_stone_bricks, brick_stairs, stone_brick_stairs, nether_bricks, nether_brick_fence, nether_brick_stairs, enchanting_table, brewing_stand, end_stone, sandstone_stairs, emerald_ore, deepslate_emerald_ore, ender_chest, emerald_block, light_weighted_pressure_plate, heavy_weighted_pressure_plate, redstone_block, nether_quartz_ore, hopper, quartz_block, chiseled_quartz_block, quartz_pillar, quartz_stairs, dropper, iron_trapdoor, prismarine, prismarine_bricks, dark_prismarine, prismarine_stairs, prismarine_brick_stairs, dark_prismarine_stairs, prismarine_slab, prismarine_brick_slab, dark_prismarine_slab, terracotta, coal_block, red_sandstone, chiseled_red_sandstone, cut_red_sandstone, red_sandstone_stairs, stone_slab, smooth_stone_slab, sandstone_slab, cut_sandstone_slab, petrified_oak_slab, cobblestone_slab, brick_slab, stone_brick_slab, nether_brick_slab, quartz_slab, red_sandstone_slab, cut_red_sandstone_slab, purpur_slab, smooth_stone, smooth_sandstone, smooth_quartz, smooth_red_sandstone, purpur_block, purpur_pillar, purpur_stairs, end_stone_bricks, magma_block, red_nether_bricks, bone_block, observer, dead_tube_coral_block, dead_brain_coral_block, dead_bubble_coral_block, dead_fire_coral_block, dead_horn_coral_block, tube_coral_block, brain_coral_block, bubble_coral_block, fire_coral_block, horn_coral_block, dead_tube_coral, dead_brain_coral, dead_bubble_coral, dead_fire_coral, dead_horn_coral, dead_tube_coral_fan, dead_brain_coral_fan, dead_bubble_coral_fan, dead_fire_coral_fan, dead_horn_coral_fan, dead_tube_coral_wall_fan, dead_brain_coral_wall_fan, dead_bubble_coral_wall_fan, dead_fire_coral_wall_fan, dead_horn_coral_wall_fan, polished_granite_stairs, smooth_red_sandstone_stairs, mossy_stone_brick_stairs, polished_diorite_stairs, mossy_cobblestone_stairs, end_stone_brick_stairs, stone_stairs, smooth_sandstone_stairs, smooth_quartz_stairs, granite_stairs, andesite_stairs, red_nether_brick_stairs, polished_andesite_stairs, diorite_stairs, polished_granite_slab, smooth_red_sandstone_slab, mossy_stone_brick_slab, polished_diorite_slab, mossy_cobblestone_slab, end_stone_brick_slab, smooth_sandstone_slab, smooth_quartz_slab, granite_slab, andesite_slab, red_nether_brick_slab, polished_andesite_slab, diorite_slab, smoker, blast_furnace, grindstone, stonecutter, bell, warped_nylium, crimson_nylium, netherite_block, ancient_debris, crying_obsidian, respawn_anchor, lodestone, blackstone, blackstone_stairs, blackstone_slab, polished_blackstone, polished_blackstone_bricks, cracked_polished_blackstone_bricks, chiseled_polished_blackstone, polished_blackstone_brick_slab, polished_blackstone_brick_stairs, gilded_blackstone, polished_blackstone_stairs, polished_blackstone_slab, polished_blackstone_pressure_plate, chiseled_nether_bricks, cracked_nether_bricks, quartz_bricks, tuff, calcite, copper_ore, deepslate_copper_ore, dripstone_block, deepslate, cobbled_deepslate, cobbled_deepslate_stairs, cobbled_deepslate_slab, polished_deepslate, polished_deepslate_stairs, polished_deepslate_slab, deepslate_tiles, deepslate_tile_stairs, deepslate_tile_slab, deepslate_bricks, deepslate_brick_stairs, deepslate_brick_slab, chiseled_deepslate, cracked_deepslate_bricks, cracked_deepslate_tiles, smooth_basalt, raw_iron_block, raw_copper_block, raw_gold_block, ice, packed_ice, blue_ice, piston, sticky_piston, piston_head, amethyst_cluster, small_amethyst_bud, medium_amethyst_bud, large_amethyst_bud, amethyst_block, budding_amethyst, infested_cobblestone, infested_chiseled_stone_bricks, infested_cracked_stone_bricks, infested_deepslate, infested_stone, infested_mossy_stone_bricks, infested_stone_bricks, stone_button, polished_blackstone_button, cobblestone_wall, mossy_cobblestone_wall, brick_wall, prismarine_wall, red_sandstone_wall, mossy_stone_brick_wall, granite_wall, stone_brick_wall, nether_brick_wall, andesite_wall, red_nether_brick_wall, sandstone_wall, end_stone_brick_wall, diorite_wall, blackstone_wall, polished_blackstone_brick_wall, polished_blackstone_wall, cobbled_deepslate_wall, polished_deepslate_wall, deepslate_tile_wall, deepslate_brick_wall, mud_brick_wall, tuff_wall, polished_tuff_wall, tuff_brick_wall, resin_brick_wall, cinnabar_wall, polished_cinnabar_wall, cinnabar_brick_wall, sulfur_wall, polished_sulfur_wall, sulfur_brick_wall, shulker_box, white_shulker_box, orange_shulker_box, magenta_shulker_box, light_blue_shulker_box, yellow_shulker_box, lime_shulker_box, pink_shulker_box, gray_shulker_box, light_gray_shulker_box, cyan_shulker_box, purple_shulker_box, blue_shulker_box, brown_shulker_box, green_shulker_box, red_shulker_box, black_shulker_box, anvil, chipped_anvil, damaged_anvil, cauldron, water_cauldron, lava_cauldron, powder_snow_cauldron, rail, powered_rail, detector_rail, activator_rail, conduit, mud_bricks, mud_brick_stairs, mud_brick_slab, packed_mud, crafter, tuff_slab, tuff_stairs, tuff_wall, chiseled_tuff, polished_tuff, polished_tuff_slab, polished_tuff_stairs, polished_tuff_wall, tuff_bricks, tuff_brick_slab, tuff_brick_stairs, tuff_brick_wall, chiseled_tuff_bricks, heavy_core, resin_bricks, resin_brick_slab, resin_brick_wall, resin_brick_stairs, chiseled_resin_bricks, cinnabar, cinnabar_slab, cinnabar_stairs, cinnabar_wall, polished_cinnabar, polished_cinnabar_slab, polished_cinnabar_stairs, polished_cinnabar_wall, cinnabar_bricks, cinnabar_brick_slab, cinnabar_brick_stairs, cinnabar_brick_wall, chiseled_cinnabar, sulfur, potent_sulfur, sulfur_slab, sulfur_stairs, sulfur_wall, polished_sulfur, polished_sulfur_slab, polished_sulfur_stairs, polished_sulfur_wall, sulfur_bricks, sulfur_brick_slab, sulfur_brick_stairs, sulfur_brick_wall, chiseled_sulfur, copper_chest, exposed_copper_chest, weathered_copper_chest, oxidized_copper_chest, waxed_copper_chest, waxed_exposed_copper_chest, waxed_weathered_copper_chest, waxed_oxidized_copper_chest, copper_golem_statue, exposed_copper_golem_statue, weathered_copper_golem_statue, oxidized_copper_golem_statue, waxed_copper_golem_statue, waxed_exposed_copper_golem_statue, waxed_weathered_copper_golem_statue, waxed_oxidized_copper_golem_statue, lightning_rod, exposed_lightning_rod, weathered_lightning_rod, oxidized_lightning_rod, waxed_lightning_rod, waxed_exposed_lightning_rod, waxed_weathered_lightning_rod, waxed_oxidized_lightning_rod, lantern, soul_lantern, copper_lantern, exposed_copper_lantern, weathered_copper_lantern, oxidized_copper_lantern, waxed_copper_lantern, waxed_exposed_copper_lantern, waxed_weathered_copper_lantern, waxed_oxidized_copper_lantern, iron_chain, copper_chain, exposed_copper_chain, weathered_copper_chain, oxidized_copper_chain, waxed_copper_chain, waxed_exposed_copper_chain, waxed_weathered_copper_chain, waxed_oxidized_copper_chain, iron_bars, copper_bars, exposed_copper_bars, weathered_copper_bars, oxidized_copper_bars, waxed_copper_bars, waxed_exposed_copper_bars, waxed_weathered_copper_bars, waxed_oxidized_copper_bars, copper_block, exposed_copper, weathered_copper, oxidized_copper, waxed_copper_block, waxed_exposed_copper, waxed_weathered_copper, waxed_oxidized_copper, copper_bulb, exposed_copper_bulb, weathered_copper_bulb, oxidized_copper_bulb, waxed_copper_bulb, waxed_exposed_copper_bulb, waxed_weathered_copper_bulb, waxed_oxidized_copper_bulb, cut_copper, exposed_cut_copper, weathered_cut_copper, oxidized_cut_copper, waxed_cut_copper, waxed_exposed_cut_copper, waxed_weathered_cut_copper, waxed_oxidized_cut_copper, chiseled_copper, exposed_chiseled_copper, weathered_chiseled_copper, oxidized_chiseled_copper, waxed_chiseled_copper, waxed_exposed_chiseled_copper, waxed_weathered_chiseled_copper, waxed_oxidized_chiseled_copper, cut_copper_stairs, exposed_cut_copper_stairs, weathered_cut_copper_stairs, oxidized_cut_copper_stairs, waxed_cut_copper_stairs, waxed_exposed_cut_copper_stairs, waxed_weathered_cut_copper_stairs, waxed_oxidized_cut_copper_stairs, cut_copper_slab, exposed_cut_copper_slab, weathered_cut_copper_slab, oxidized_cut_copper_slab, waxed_cut_copper_slab, waxed_exposed_cut_copper_slab, waxed_weathered_cut_copper_slab, waxed_oxidized_cut_copper_slab, copper_door, exposed_copper_door, weathered_copper_door, oxidized_copper_door, waxed_copper_door, waxed_exposed_copper_door, waxed_weathered_copper_door, waxed_oxidized_copper_door, copper_trapdoor, exposed_copper_trapdoor, weathered_copper_trapdoor, oxidized_copper_trapdoor, waxed_copper_trapdoor, waxed_exposed_copper_trapdoor, waxed_weathered_copper_trapdoor, waxed_oxidized_copper_trapdoor, copper_grate, exposed_copper_grate, weathered_copper_grate, oxidized_copper_grate, waxed_copper_grate, waxed_exposed_copper_grate, waxed_weathered_copper_grate, waxed_oxidized_copper_grate, white_glazed_terracotta, orange_glazed_terracotta, magenta_glazed_terracotta, light_blue_glazed_terracotta, yellow_glazed_terracotta, lime_glazed_terracotta, pink_glazed_terracotta, gray_glazed_terracotta, light_gray_glazed_terracotta, cyan_glazed_terracotta, purple_glazed_terracotta, blue_glazed_terracotta, brown_glazed_terracotta, green_glazed_terracotta, red_glazed_terracotta, black_glazed_terracotta, white_terracotta, orange_terracotta, magenta_terracotta, light_blue_terracotta, yellow_terracotta, lime_terracotta, pink_terracotta, gray_terracotta, light_gray_terracotta, cyan_terracotta, purple_terracotta, blue_terracotta, brown_terracotta, green_terracotta, red_terracotta, black_terracotta, white_concrete, orange_concrete, magenta_concrete, light_blue_concrete, yellow_concrete, lime_concrete, pink_concrete, gray_concrete, light_gray_concrete, cyan_concrete, purple_concrete, blue_concrete, brown_concrete, green_concrete, red_concrete, black_concrete, pointed_dripstone, sulfur_spike, white_concrete_stairs, orange_concrete_stairs, magenta_concrete_stairs, light_blue_concrete_stairs, yellow_concrete_stairs, lime_concrete_stairs, pink_concrete_stairs, gray_concrete_stairs, light_gray_concrete_stairs, cyan_concrete_stairs, purple_concrete_stairs, blue_concrete_stairs, brown_concrete_stairs, green_concrete_stairs, red_concrete_stairs, black_concrete_stairs, white_concrete_slab, orange_concrete_slab, magenta_concrete_slab, light_blue_concrete_slab, yellow_concrete_slab, lime_concrete_slab, pink_concrete_slab, gray_concrete_slab, light_gray_concrete_slab, cyan_concrete_slab, purple_concrete_slab, blue_concrete_slab, brown_concrete_slab, green_concrete_slab, red_concrete_slab, black_concrete_slab
