"""Wire fixture catalogue, part 2 (T0062): containers, cursor, Open Screen, recipe placement and the recipe book
of the standard world type. Written from docs/protocol/00 section 12, 05a 0x12 to 0x14 and 0x3C, 05b 0x4B to 0x4D
and 0x62, 05c 0x12, 0x27, 0x2F, 0x30; ids from 46 sections 5.5, 8.1, 9; item ids from 25 part 1."""
import wire_fixtures as wf
from wire_catalog_world import head
from wire_fixtures import Compound, Fixture, Str, fixture

STONE, COBBLE, PLANKS, BEDROCK = 1, 62, 63, 87  # item ids, 25 part 1
C_DAMAGE, C_CUSTOM_NAME, C_MAX_STACK = 3, 6, 1  # data component ids, 46 section 8.1


def text_plain(text):
    """TextComponent as network NBT: a plain String root (00 section 9.1)."""
    return wf.nbt_network(Str(text))


def text_translate(key):
    return wf.nbt_network(Compound([("translate", Str(key))]))


def stack(item, count, added=(), removed=()):
    """ItemStack (00 12.1): count, item, DataComponentPatch (added values are bytes), removed ids."""
    if count <= 0:
        return wf.varint(0)
    out = wf.varint(count) + wf.varint(item) + wf.varint(len(added)) + wf.varint(len(removed))
    for ctype, value in added:
        out += wf.varint(ctype) + value
    for ctype in removed:
        out += wf.varint(ctype)
    return out


def hashed(item=None, count=0, added=(), removed=()):
    """HashedStack (00 12.4)."""
    if item is None:
        return wf.bool1(False)
    out = wf.bool1(True) + wf.varint(item) + wf.varint(count) + wf.varint(len(added))
    for ctype, digest in added:
        out += wf.varint(ctype) + wf.int32(digest)
    out += wf.varint(len(removed))
    for ctype in removed:
        out += wf.varint(ctype)
    return out


DAMAGED_STONE = stack(STONE, 1, added=[(C_DAMAGE, wf.varint(5)), (C_CUSTOM_NAME, text_plain("Hi"))], removed=[C_MAX_STACK])


@fixture("play-s2c-14-container-set-slot-components")
def set_slot_components():
    fx = Fixture("play-s2c-14-container-set-slot-components", head(
        "Container Set Slot with data components", "play", "clientbound (S->C)", 0x14,
        "05a 0x14; 00 section 12.1 (ItemStack) and 12.2 (DataComponentPatch); 46 section 8.1 (component ids 3 damage, 6 custom_name, 1 max_stack_size)",
        ["container 0, state id 5, slot 36 (hotbar 0 of the 46-slot inventory menu); stack 1 x stone (item 1)",
         "patch: added damage (3) = VarInt 5 and custom_name (6) = text component plain String \"Hi\" (network NBT); removed max_stack_size (1)"]))
    fx.field(wf.varint(0x14), "packet id: VarInt 0x14")
    fx.field(wf.varint(0), "Container id: VarInt 0")
    fx.field(wf.varint(5), "State id: VarInt 5")
    fx.field(wf.short(36), "Slot: Short 36")
    fx.field(wf.varint(1) + wf.varint(STONE), "Item: Count 1, Item 1 (stone)")
    fx.field(wf.varint(2) + wf.varint(1), "Patch: AddedCount 2, RemovedCount 1")
    fx.field(wf.varint(C_DAMAGE) + wf.varint(5), "  added[0]: damage (3) = VarInt 5")
    fx.field(wf.varint(C_CUSTOM_NAME) + text_plain("Hi"), "  added[1]: custom_name (6) = network NBT String \"Hi\"")
    fx.field(wf.varint(C_MAX_STACK), "  removed[0]: max_stack_size (1)")
    assert fx.bytes() == wf.varint(0x14) + wf.varint(0) + wf.varint(5) + wf.short(36) + DAMAGED_STONE
    return fx


@fixture("play-s2c-12-container-set-content-46-slots")
def set_content():
    fx = Fixture("play-s2c-12-container-set-content-46-slots", head(
        "Container Set Content, 46-slot inventory menu", "play", "clientbound (S->C)", 0x12,
        "05a 0x12; 00 section 12.1; 13 section 3 (46 slots: 0 result, 1-4 crafting grid, 5-8 armour, 9-35 main, 36-44 hotbar, 45 off-hand)",
        ["container 0, state id 3, 46 slots, all empty except slot 36 = 64 x stone, slot 40 = the damaged stone of the Container Set Slot fixture,",
         "slot 45 (off-hand) = 1 x cobblestone (item 62); carried item = 5 x oak_planks (item 63)"]))
    fx.field(wf.varint(0x12), "packet id: VarInt 0x12")
    fx.field(wf.varint(0), "Container id: VarInt 0")
    fx.field(wf.varint(3), "State id: VarInt 3")
    fx.field(wf.varint(46), "Slots: VarInt count 46")
    for slot in range(46):
        if slot == 36:
            fx.field(stack(STONE, 64), "slot 36: 64 x stone, empty patch")
        elif slot == 40:
            fx.field(DAMAGED_STONE, "slot 40: stone with damage, custom_name, removed max_stack_size")
        elif slot == 45:
            fx.field(stack(COBBLE, 1), "slot 45 (off-hand): 1 x cobblestone")
        else:
            fx.field(stack(0, 0), "slot %d: empty (Count 0)" % slot)
    fx.field(stack(PLANKS, 5), "Carried item: 5 x oak_planks")
    return fx


@fixture("play-s2c-62-set-cursor-item")
def cursor():
    fx = Fixture("play-s2c-62-set-cursor-item", head(
        "Set Cursor Item", "play", "clientbound (S->C)", 0x62, "05b 0x62; 00 section 12.1",
        ["cursor holds 16 x oak_planks (item 63), empty patch"]))
    fx.field(wf.varint(0x62), "packet id: VarInt 0x62")
    fx.field(stack(PLANKS, 16), "Contents: ItemStack 16 x oak_planks")
    return fx


@fixture("play-s2c-62-set-cursor-item-empty")
def cursor_empty():
    fx = Fixture("play-s2c-62-set-cursor-item-empty", head(
        "Set Cursor Item, empty", "play", "clientbound (S->C)", 0x62, "05b 0x62 (the optional form encodes the empty stack); 00 section 12.1",
        ["cursor empty: Count 0, nothing follows"]))
    fx.field(wf.varint(0x62), "packet id: VarInt 0x62")
    fx.field(stack(0, 0), "Contents: ItemStack Count 0")
    return fx


@fixture("play-s2c-3c-open-screen-crafting")
def open_screen():
    fx = Fixture("play-s2c-3c-open-screen-crafting", head(
        "Open Screen, crafting table", "play", "clientbound (S->C)", 0x3C,
        "05a 0x3C; 46 section 5.5 and worked example 2 (menu type crafting = 12); 00 section 9.1",
        ["container id 2; menu type 12 (crafting); title translate component container.crafting (network NBT compound)"]))
    fx.field(wf.varint(0x3C), "packet id: VarInt 0x3c")
    fx.field(wf.varint(2), "Container id: VarInt 2")
    fx.field(wf.varint(12), "Menu type: VarInt 12 (crafting)")
    fx.nbt(Compound([("translate", Str("container.crafting"))]), "Title: TextComponent")
    return fx


@fixture("play-s2c-3c-open-screen-chest-with-name")
def open_screen_chest():
    fx = Fixture("play-s2c-3c-open-screen-chest-with-name", head(
        "Open Screen, single chest with a plain string title", "play", "clientbound (S->C)", 0x3C,
        "05a 0x3C; 46 worked example 2 (generic_9x3 = 2); 00 section 9.1 (plain String form)",
        ["container id 127 (one-byte VarInt maximum); menu type 2 (generic_9x3); title plain String \"Loot\""]))
    fx.field(wf.varint(0x3C), "packet id: VarInt 0x3c")
    fx.field(wf.varint(127), "Container id: VarInt 127")
    fx.field(wf.varint(2), "Menu type: VarInt 2 (generic_9x3)")
    fx.field(text_plain("Loot"), "Title: network NBT String \"Loot\"")
    return fx


def click(name, title, state, slot, button, ctype, changed, carried, inputs):
    fx = Fixture(name, head(title, "play", "serverbound (C->S)", 0x12, "05c 0x12; 00 section 12.4 (HashedStack, HashedPatchMap)", inputs))
    fx.field(wf.varint(0x12), "packet id: VarInt 0x12")
    fx.field(wf.varint(2), "Container id: VarInt 2")
    fx.field(wf.varint(state), "State id: VarInt %d" % state)
    fx.field(wf.short(slot), "Slot: Short %d" % slot)
    fx.field(wf.byte(button), "Button: Byte %d" % button)
    fx.field(wf.varint(ctype), "Click type: VarInt %d" % ctype)
    fx.field(wf.varint(len(changed)), "Changed slots: Map count %d" % len(changed))
    for key, value in changed:
        fx.field(wf.short(key), "  slot key: Short %d" % key)
        fx.field(value, "  value: HashedStack")
    fx.field(carried, "Carried item: HashedStack")
    return fx


@fixture("play-c2s-12-container-click-quick-move")
def click_quick():
    return click("play-c2s-12-container-click-quick-move", "Container Click, shift-click (QUICK_MOVE)", 7, 9, 0, 1,
                 [(9, hashed()), (36, hashed(STONE, 64))], hashed(),
                 ["container 2 (crafting bench), state id 7, slot 9, button 0, click type 1 QUICK_MOVE",
                  "changed: slot 9 -> empty, slot 36 -> 64 x stone with no components; carried item empty (Present false)"])


@fixture("play-c2s-12-container-click-hashed-components")
def click_hashed():
    return click("play-c2s-12-container-click-hashed-components", "Container Click with hashed components", 300, 45, 1, 0,
                 [(45, hashed(STONE, 1, added=[(C_DAMAGE, -559038737)], removed=[C_MAX_STACK]))],
                 hashed(PLANKS, 2, added=[(C_CUSTOM_NAME, 0x12345678)]),
                 ["container 2, state id 300 (two-byte VarInt), slot 45, button 1 (right click), click type 0 PICKUP",
                  "changed: slot 45 -> 1 x stone, added damage (3) with hash -559038737 (0xdeadbeef as a signed Int), removed max_stack_size (1)",
                  "carried: 2 x oak_planks, added custom_name (6) with hash 0x12345678"])


@fixture("play-c2s-12-container-click-outside")
def click_outside():
    return click("play-c2s-12-container-click-outside", "Container Click outside the window (slot -999)", 1, -999, 0, 0, [], hashed(COBBLE, 3),
                 ["container 2, state id 1, slot -999 (SLOT_CLICKED_OUTSIDE), button 0, PICKUP; no changed slots; carried 3 x cobblestone"])


@fixture("play-c2s-27-place-recipe-standard")
def place_recipe():
    fx = Fixture("play-c2s-27-place-recipe-standard", head(
        "Place Recipe, standard menu", "play", "serverbound (C->S)", 0x27, "05c 0x27; 27 (display ids)",
        ["container 2, recipe display id 300 (two-byte VarInt), use max items true"]))
    fx.field(wf.varint(0x27), "packet id: VarInt 0x27")
    fx.field(wf.varint(2), "Container id: VarInt 2")
    fx.field(wf.varint(300), "Recipe: VarInt 300")
    fx.field(wf.bool1(True), "Use max items: Boolean true")
    return fx


# ---- recipe book (05b 0x4B to 0x4D)

def sd_empty():
    return wf.varint(0)


def sd_item(item):
    return wf.varint(4) + wf.varint(item)


def sd_stack(item, count):
    return wf.varint(5) + wf.varint(item) + wf.varint(count) + wf.varint(0) + wf.varint(0)


def sd_tag(tag):
    return wf.varint(6) + wf.varint(0) + wf.ident(tag)


def sd_composite(parts):
    return wf.varint(10) + wf.prefixed(parts)


def ingredient(ids):
    return wf.varint(len(ids) + 1) + b"".join(wf.varint(i) for i in ids)


def entry(display_id, display, group, category, requirements):
    out = wf.varint(display_id) + display + wf.optional_varint(group) + wf.varint(category)
    if requirements is None:
        out += wf.bool1(False)
    else:
        out += wf.bool1(True) + wf.prefixed([ingredient(i) for i in requirements])
    return out


def shapeless(ingredients, result, station):
    return wf.varint(0) + wf.prefixed(ingredients) + result + station


def shaped(w, h, ingredients, result, station):
    return wf.varint(1) + wf.varint(w) + wf.varint(h) + wf.prefixed(ingredients) + result + station


def furnace(ing, fuel, result, station, duration, xp):
    return wf.varint(2) + ing + fuel + result + station + wf.varint(duration) + wf.float32(xp)


def stonecutter(inp, result, station):
    return wf.varint(3) + inp + result + station


def smithing(template, base, addition, result, station):
    return wf.varint(4) + template + base + addition + result + station


@fixture("play-s2c-4b-recipe-book-add-standard")
def recipe_add():
    fx = Fixture("play-s2c-4b-recipe-book-add-standard", head(
        "Recipe Book Add, all five recipe display types and slot display types", "play", "clientbound (S->C)", 0x4B,
        "05b 0x4B, RecipeDisplayEntry, RecipeDisplay, SlotDisplay; 46 section 9 (ids; recipe book categories 0 crafting_building_blocks, 4 furnace_food, 10 stonecutter, 11 smithing); 27 (flags)",
        ["Replace false. Item ids are fixture inputs from 25 part 1: stone 1, cobblestone 62, oak_planks 63, bedrock 87",
         "entry 0 id 0 shapeless: ingredients [tag minecraft:planks, item 62], result item_stack 4 x stone, station empty, no group, category 0, flags 3 (notify, highlight), craftable [[62],[63]]",
         "entry 1 id 300 shaped 2x2: four item 63, result item_stack 1 x stone, station item 63; group 5 (OptionalVarInt 6); category 0; requirements absent; flags 2",
         "entry 2 id 301 furnace: ingredient item 62, fuel any_fuel, result item 1, station empty, duration 200, experience 0.1; category 4; flags 0",
         "entry 3 id 302 stonecutter: input composite [item 62, item 63], result item_stack 2 x stone, station empty; category 10",
         "entry 4 id 303 smithing: template item 87, base with_remainder(item 62, item 63), addition dyed(item 1, item 62), result item 1, station empty; category 11"]))
    fx.field(wf.varint(0x4B), "packet id: VarInt 0x4b")
    entries = [
        (entry(0, shapeless([sd_tag("minecraft:planks"), sd_item(COBBLE)], sd_stack(STONE, 4), sd_empty()), None, 0, [[COBBLE], [PLANKS]]), 3, "shapeless: tag + item, requirements present"),
        (entry(300, shaped(2, 2, [sd_item(PLANKS)] * 4, sd_stack(STONE, 1), sd_item(PLANKS)), 5, 0, None), 2, "shaped 2x2, group 5, requirements absent"),
        (entry(301, furnace(sd_item(COBBLE), wf.varint(1), sd_item(STONE), sd_empty(), 200, 0.1), None, 4, None), 0, "furnace with any_fuel"),
        (entry(302, stonecutter(sd_composite([sd_item(COBBLE), sd_item(PLANKS)]), sd_stack(STONE, 2), sd_empty()), None, 10, None), 0, "stonecutter with composite input"),
        (entry(303, smithing(sd_item(BEDROCK), wf.varint(9) + sd_item(COBBLE) + sd_item(PLANKS),
                             wf.varint(7) + sd_item(STONE) + sd_item(COBBLE), sd_item(STONE), sd_empty()), None, 11, None), 0, "smithing with with_remainder and dyed"),
    ]
    fx.field(wf.varint(len(entries)), "Entries: VarInt count 5")
    for number, (data, flags, text) in enumerate(entries):
        fx.field(data, "entry %d: RecipeDisplayEntry, %s" % (number, text))
        fx.field(wf.byte(flags), "entry %d flags: Byte %d" % (number, flags))
    fx.field(wf.bool1(False), "Replace: Boolean false")
    return fx


@fixture("play-s2c-4b-recipe-book-add-standard-replace-empty")
def recipe_add_empty():
    fx = Fixture("play-s2c-4b-recipe-book-add-standard-replace-empty", head(
        "Recipe Book Add, empty list with replace", "play", "clientbound (S->C)", 0x4B, "05b 0x4B; 27 (sendInitialRecipeBook for a player with no known recipes)",
        ["no entries; Replace true (the client clears its list)"]))
    fx.field(wf.varint(0x4B), "packet id: VarInt 0x4b")
    fx.field(wf.varint(0), "Entries: VarInt count 0")
    fx.field(wf.bool1(True), "Replace: Boolean true")
    return fx


@fixture("play-s2c-4b-recipe-book-add-standard-tag-slots")
def recipe_add_slots():
    fx = Fixture("play-s2c-4b-recipe-book-add-standard-tag-slots", head(
        "Recipe Book Add, the remaining slot display types", "play", "clientbound (S->C)", 0x4B,
        "05b SlotDisplay table (types 2, 3, 8); 46 section 9.2",
        ["one shapeless entry id 7, ingredients [with_any_potion(item 63), only_with_component(item 1, component 3 damage),",
         "smithing_trim(base item 1, material item 62, inline pattern asset minecraft:coast, description plain String \"Coast\", decal false)]",
         "result item 1, station empty; category 3; requirements absent; flags 1; Replace false"]))
    fx.field(wf.varint(0x4B), "packet id: VarInt 0x4b")
    fx.field(wf.varint(1), "Entries: VarInt count 1")
    trim = wf.varint(8) + sd_item(STONE) + sd_item(COBBLE) + wf.varint(0) + wf.ident("minecraft:coast") + text_plain("Coast") + wf.bool1(False)
    ingredients = [wf.varint(2) + sd_item(PLANKS), wf.varint(3) + sd_item(STONE) + wf.varint(C_DAMAGE), trim]
    fx.field(entry(7, shapeless(ingredients, sd_item(STONE), sd_empty()), None, 3, None), "entry 0: RecipeDisplayEntry")
    fx.field(wf.byte(1), "entry 0 flags: Byte 1")
    fx.field(wf.bool1(False), "Replace: Boolean false")
    return fx


@fixture("play-s2c-4c-recipe-book-remove")
def recipe_remove():
    fx = Fixture("play-s2c-4c-recipe-book-remove", head(
        "Recipe Book Remove", "play", "clientbound (S->C)", 0x4C, "05b 0x4C", ["display ids [0, 1, 300]"]))
    fx.field(wf.varint(0x4C), "packet id: VarInt 0x4c")
    fx.field(wf.prefixed([wf.varint(i) for i in (0, 1, 300)]), "Recipes: VarInt count 3 then 0, 1, 300")
    return fx


@fixture("play-s2c-4d-recipe-book-settings")
def recipe_settings():
    fx = Fixture("play-s2c-4d-recipe-book-settings", head(
        "Recipe Book Settings", "play", "clientbound (S->C)", 0x4D, "05b 0x4D",
        ["crafting open true filtering false; furnace open false filtering true; blast furnace open true filtering true; smoker open false filtering false"]))
    fx.field(wf.varint(0x4D), "packet id: VarInt 0x4d")
    for name, a, b in [("Crafting", 1, 0), ("Furnace", 0, 1), ("Blast furnace", 1, 1), ("Smoker", 0, 0)]:
        fx.field(wf.bool1(a) + wf.bool1(b), "%s: open %s, filtering %s" % (name, bool(a), bool(b)))
    return fx


@fixture("play-c2s-2f-recipe-book-change-settings")
def recipe_change():
    fx = Fixture("play-c2s-2f-recipe-book-change-settings", head(
        "Recipe Book Change Settings", "play", "serverbound (C->S)", 0x2F, "05c 0x2F", ["book type 1 (furnace), is open true, is filtering false"]))
    fx.field(wf.varint(0x2F), "packet id: VarInt 0x2f")
    fx.field(wf.varint(1), "Book type: VarInt 1 furnace")
    fx.field(wf.bool1(True), "Is open: Boolean true")
    fx.field(wf.bool1(False), "Is filtering: Boolean false")
    return fx


@fixture("play-c2s-30-recipe-book-seen-recipe")
def recipe_seen():
    fx = Fixture("play-c2s-30-recipe-book-seen-recipe", head(
        "Recipe Book Seen Recipe", "play", "serverbound (C->S)", 0x30, "05c 0x30", ["display id 300"]))
    fx.field(wf.varint(0x30), "packet id: VarInt 0x30")
    fx.field(wf.varint(300), "Recipe: VarInt 300")
    return fx
