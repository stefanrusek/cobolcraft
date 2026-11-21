"""Wire fixture catalogue, part 5 (T0057 reconciliation with docs/protocol/09 section 3.5): the fixtures that 09
names and no other catalogue part generates: the cobolcraft enchantment and timeline registries (CORE 3.2, 3.7),
the crafting bench Container Set Content, a generic Disguised Chat, Entity Event permission level, spectator
Player Abilities and a living-mob Set Entity Data."""
import wire_fixtures as wf
from wire_catalog_menus import COBBLE, PLANKS, STONE, stack, text_plain
from wire_catalog_world import head
from wire_fixtures import Compound, Fixture, Float, Int, ListOf, Str, TAG_COMPOUND, TAG_FLOAT, TAG_STRING, fixture, Byte


def registry(name, registry_key, title, doc, inputs, entries):
    fx = Fixture(name, head(title, "configuration", "clientbound (S->C)", 7, doc, inputs))
    fx.field(wf.varint(7), "packet id: VarInt 0x07")
    fx.field(wf.ident(registry_key), "Registry: Identifier")
    fx.field(wf.varint(len(entries)), "Entries: VarInt count %d" % len(entries))
    for number, (key, tag) in enumerate(entries):
        fx.note("---- entry %d: %s ----" % (number, key))
        fx.field(wf.ident(key), "Entry[%d].Id: Identifier" % number)
        fx.field(wf.bool1(True), "Entry[%d].Data present: Boolean true" % number)
        fx.nbt(tag, "Entry[%d].Data" % number)
    return fx


@fixture("config-s2c-07-registry-data-enchantment")
def enchantment():
    cost = lambda base: Compound([("base", Int(base)), ("per_level_above_first", Int(10))])
    attribute = Compound([("attribute", Str("minecraft:mining_efficiency")), ("id", Str("minecraft:enchantment.efficiency")),
                          ("operation", Str("add_value")),
                          ("amount", Compound([("type", Str("minecraft:levels_squared")), ("added", Float(1.0))]))])
    tag = Compound([
        ("description", Compound([("translate", Str("enchantment.minecraft.efficiency"))])),
        ("supported_items", Str("#minecraft:enchantable/mining")),
        ("weight", Int(10)), ("max_level", Int(5)), ("min_cost", cost(1)), ("max_cost", cost(51)), ("anvil_cost", Int(1)),
        ("slots", ListOf(TAG_STRING, [Str("mainhand")])),
        ("effects", Compound([("minecraft:attributes", ListOf(TAG_COMPOUND, [attribute]))])),
    ])
    return registry("config-s2c-07-registry-data-enchantment", "minecraft:enchantment",
                    "Registry Data (minecraft:enchantment), cobolcraft world type",
                    "04 Registry Data and section 6 enchantment; docs/design/cobolcraft-standard-core.md section 3.7 (CORE-14)",
                    ["1 entry: id 0 minecraft:efficiency (CORE section 3.7 row); the effects shape is inferred (CORE Open question 4);",
                     "field order is the order of the CORE row; Float for the amount; supported_items is the tag string"],
                    [("minecraft:efficiency", tag)])


def keyframes(pairs, value):
    return ListOf(TAG_COMPOUND, [Compound([("ticks", Int(t)), ("value", value(v))]) for t, v in pairs])


def track(pairs, value, modifier=None, ease=None):
    members = []
    if modifier:
        members.append(("modifier", Str(modifier)))
    if ease:
        members.append(("ease", Compound([("cubic_bezier", ListOf(TAG_FLOAT, [Float(x) for x in ease]))])))
    members.append(("keyframes", keyframes(pairs, value)))
    return Compound(members)


@fixture("config-s2c-07-registry-data-timeline")
def timeline():
    bez = (0.362, 0.241, 0.638, 0.759)
    colour = lambda a, b, c, d: [(a[0], a[1]), (b[0], b[1]), (c[0], c[1]), (d[0], d[1])]
    def two(c1, c2, t=(133, 11867, 13670, 22330)):
        return colour((t[0], c1), (t[1], c1), (t[2], c2), (t[3], c2))
    sunrise = [(71, "#5fefa333"), (310, "#29f5ba33"), (565, "#06fbd433"), (730, "#00ffe533"), (11270, "#00ffe533"),
               (11397, "#04fcd833"), (11522, "#0ff9cb33"), (11690, "#29f5ba33"), (11929, "#5fefa333"), (12243, "#b1e78733"),
               (12358, "#cce47e33"), (12512, "#e9e07233"), (12613, "#f6dd6b33"), (12732, "#feda6333"), (12841, "#fed75c33"),
               (13035, "#ecd25133"), (13252, "#c1cc4733"), (13775, "#36be3733"), (13888, "#1fbb3533"), (14039, "#09b73333"),
               (14192, "#00b33333"), (21807, "#00b23333"), (21961, "#09b73333"), (22112, "#1fbb3533"), (22225, "#36be3733"),
               (22748, "#c1cc4733"), (22965, "#ecd25133"), (23159, "#fed75c33"), (23272, "#feda6333"), (23488, "#e9e07233"),
               (23642, "#cce47e33"), (23757, "#b1e78733")]
    stars = [(92, 0.037), (627, 0.0), (11373, 0.0), (11732, 0.016), (11959, 0.044), (12399, 0.143), (12729, 0.258),
             (13228, 0.5), (22772, 0.5), (23032, 0.364), (23356, 0.225), (23758, 0.101)]
    s, f = Str, Float
    day = Compound([
        ("clock", Str("minecraft:overworld")), ("period_ticks", Int(24000)),
        ("time_markers", Compound([
            ("minecraft:day", Compound([("ticks", Int(1000)), ("show_in_commands", Byte(1))])),
            ("minecraft:noon", Compound([("ticks", Int(6000)), ("show_in_commands", Byte(1))])),
            ("minecraft:night", Compound([("ticks", Int(13000)), ("show_in_commands", Byte(1))])),
            ("minecraft:midnight", Compound([("ticks", Int(18000)), ("show_in_commands", Byte(1))])),
            ("minecraft:wake_up_from_sleep", Int(0))])),
        ("tracks", Compound([
            ("minecraft:visual/sky_color", track(two("#ffffff", "#000000"), s, "multiply")),
            ("minecraft:visual/fog_color", track(two("#ffffff", "#0f0f16"), s, "multiply")),
            ("minecraft:visual/cloud_color", track(two("#ffffffff", "#ff191926"), s, "multiply")),
            ("minecraft:visual/sky_light_color", track(two("#ffffff", "#7a7aff", (730, 11270, 13140, 22860)), s, "multiply")),
            ("minecraft:visual/sky_light_factor", track(two(1.0, 0.24, (730, 11270, 13140, 22860)), f, "multiply")),
            ("minecraft:visual/star_brightness", track(stars, f, "maximum")),
            ("minecraft:visual/sun_angle", track([(6000, 360.0), (6000, 0.0)], f, None, bez)),
            ("minecraft:visual/moon_angle", track([(6000, 540.0), (6000, 180.0)], f, None, bez)),
            ("minecraft:visual/star_angle", track([(6000, 360.0), (6000, 0.0)], f, None, bez)),
            ("minecraft:visual/sunrise_sunset_color", track(sunrise, s)),
            ("minecraft:gameplay/sky_light_level", track(two(1.0, 0.26666668), f, "multiply")),
        ])),
    ])
    phases = ["full_moon", "waning_gibbous", "third_quarter", "waning_crescent", "new_moon", "waxing_crescent",
              "first_quarter", "waxing_gibbous"]
    moon = Compound([
        ("clock", Str("minecraft:overworld")), ("period_ticks", Int(192000)),
        ("tracks", Compound([("minecraft:visual/moon_phase", track([(24000 * i, p) for i, p in enumerate(phases)], Str))])),
    ])
    return registry("config-s2c-07-registry-data-timeline", "minecraft:timeline",
                    "Registry Data (minecraft:timeline), cobolcraft world type",
                    "04 Registry Data and section 6 timeline (Timeline.NETWORK_CODEC); docs/design/cobolcraft-standard-core.md section 3.2 (CORE-6)",
                    ["2 entries: id 0 minecraft:day (every track of CORE 3.2 and the five time markers), id 1 minecraft:moon (moon_phase track);",
                     "field order is the order of the CORE JSON; colours are Strings, numbers Float, ticks Int; cubic_bezier is 4 Floats;",
                     "the marker wake_up_from_sleep is a bare Int, the others Compounds with ticks and show_in_commands (Byte 1)"],
                    [("minecraft:day", day), ("minecraft:moon", moon)])


@fixture("play-s2c-12-container-set-content-crafting-bench")
def bench_content():
    fx = Fixture("play-s2c-12-container-set-content-crafting-bench", head(
        "Container Set Content, crafting bench menu (10 + 36 = 46 slots)", "play", "clientbound (S->C)", 0x12,
        "05a 0x12; 00 section 12.1; 13 section 3.5 (bench: 0 result, 1-9 grid, 10-36 main, 37-45 hotbar); 09 section 3.5",
        ["container 1, state id 1, 46 slots, all empty except slot 0 (result) = 1 x cobblestone, slot 1 = 1 x oak_planks,",
         "slot 5 = 1 x oak_planks, slot 37 (first hotbar) = 64 x stone; carried item empty"]))
    fx.field(wf.varint(0x12), "packet id: VarInt 0x12")
    fx.field(wf.varint(1), "Container id: VarInt 1")
    fx.field(wf.varint(1), "State id: VarInt 1")
    fx.field(wf.varint(46), "Slots: VarInt count 46")
    special = {0: (COBBLE, 1), 1: (PLANKS, 1), 5: (PLANKS, 1), 37: (STONE, 64)}
    for slot in range(46):
        if slot in special:
            fx.field(stack(*special[slot]), "slot %d: %d x item %d" % ((slot,) + special[slot][::-1]))
        else:
            fx.field(stack(0, 0), "slot %d: empty (Count 0)" % slot)
    fx.field(stack(0, 0), "Carried item: empty")
    return fx


@fixture("play-s2c-21-disguised-chat")
def disguised_emote():
    fx = Fixture("play-s2c-21-disguised-chat", head(
        "Disguised Chat, chat type minecraft:emote_command", "play", "clientbound (S->C)", 0x21,
        "05a 0x21, ChatTypeBound; 16 section 8 (me); 09 section 3.5 (emote_command id 1 as id + 1)",
        ["message plain String \"waves\"; chat type id 1 (Holder VarInt 2); sender name plain String \"Alice\"; no target"]))
    fx.field(wf.varint(0x21), "packet id: VarInt 0x21")
    fx.field(text_plain("waves"), "Message: TextComponent plain String \"waves\"")
    fx.field(wf.varint(2), "Chat type: Holder reference VarInt 2 (registry id 1 + 1)")
    fx.field(text_plain("Alice"), "Sender name: TextComponent plain String \"Alice\"")
    fx.field(wf.bool1(False), "Target name: Optional absent")
    return fx


@fixture("play-s2c-22-entity-event-permission-level")
def event_permission():
    fx = Fixture("play-s2c-22-entity-event-permission-level", head(
        "Entity Event 28 (permission level 4)", "play", "clientbound (S->C)", 0x22,
        "05a 0x22; 09 section 3.5 (event id 24 + level, 24 = level 0 to 28 = level 4)",
        ["entity id 1 (the player's own, Int); event id 28 (level 4)"]))
    fx.field(wf.varint(0x22), "packet id: VarInt 0x22")
    fx.field(wf.int32(1), "Entity id: Int 1")
    fx.field(wf.byte(28), "Event id: Byte 28 (permission level 4)")
    return fx


@fixture("play-s2c-41-player-abilities-spectator")
def abilities_spectator():
    fx = Fixture("play-s2c-41-player-abilities-spectator", head(
        "Player Abilities (spectator)", "play", "clientbound (S->C)", 0x41,
        "05a 0x41 (Byte flags, Float flying speed, Float walking speed); 09 Open question 13 (byte 0x07 until a read round settles it)",
        ["flags 0x07 (0x01 invulnerable | 0x02 flying | 0x04 can fly); flying speed 0.05; walking speed 0.1"]))
    fx.field(wf.varint(0x41), "packet id: VarInt 0x41")
    fx.field(wf.byte(0x07), "Flags: Byte 0x07 (invulnerable | flying | can fly)")
    fx.field(wf.float32(0.05), "Flying speed: Float 0.05")
    fx.field(wf.float32(0.1), "Walking speed: Float 0.1")
    return fx


@fixture("play-s2c-65-set-entity-data-living")
def entity_data_living():
    fx = Fixture("play-s2c-65-set-entity-data-living", head(
        "Set Entity Data, a living mob (flags, custom name, health)", "play", "clientbound (S->C)", 0x65,
        "05b 0x65; 00 section 13.1 and 13.2 (serializer ids); 45 (entity base indices: 0 flags, 2 custom name; living health 9)",
        ["entity id 301; index 0 BYTE flags 0x00; index 2 OPTIONAL_COMPONENT custom name \"Bessie\"; index 9 FLOAT health 10.0; end marker 0xFF"]))
    fx.field(wf.varint(0x65), "packet id: VarInt 0x65")
    fx.field(wf.varint(301), "Entity id: VarInt 301")
    fx.field(wf.ubyte(0) + wf.varint(0) + wf.byte(0), "Metadata[0]: index 0, serializer BYTE (0), value 0x00")
    fx.field(wf.ubyte(2) + wf.varint(6) + wf.bool1(True) + text_plain("Bessie"), "Metadata[1]: index 2, serializer OPTIONAL_COMPONENT (6), present \"Bessie\"")
    fx.field(wf.ubyte(9) + wf.varint(3) + wf.float32(10.0), "Metadata[2]: index 9, serializer FLOAT (3), value 10.0")
    fx.field(wf.ubyte(255), "Metadata end: UByte 0xFF")
    return fx
