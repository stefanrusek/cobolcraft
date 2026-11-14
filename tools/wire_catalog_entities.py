"""Wire fixture catalogue, part 4 (T0064): entities, effects, events, particles, Login and Respawn for three
dimensions. Written from docs/protocol/05a 0x01, 0x22, 0x2F, 0x30, 0x32, 05b 0x54, 0x65, 0x86, 0x87, 00 section 13,
39 (dimensions), 46 (ids: entity types section 11, mob effects 4.1, attributes 4.2, particles 5.1)."""
import wire_fixtures as wf
from wire_catalog_menus import stack, text_plain
from wire_catalog_world import head
from wire_fixtures import Fixture, fixture

COW, ZOMBIE, ITEM = 30, 154, 72  # entity type ids, 21 section 2 / 46 section 11
UUID1 = "00000000-0000-0000-0000-0000000000b1"


def add_entity(name, title, eid, etype, pos, vel, yaw, pitch, data, inputs):
    fx = Fixture(name, head(title, "play", "clientbound (S->C)", 1, "05a 0x01; 00 sections 4.4 (Angle), 4.6 (LpVec3); 46 section 11 (entity type ids)", inputs))
    fx.field(wf.varint(1), "packet id: VarInt 0x01")
    fx.field(wf.varint(eid), "Entity id: VarInt %d" % eid)
    fx.field(wf.uuid(UUID1), "Entity UUID")
    fx.field(wf.varint(etype), "Entity type: VarInt %d" % etype)
    for label, value in zip("XYZ", pos):
        fx.field(wf.float64(value), "%s: Double %s" % (label, value))
    fx.field(wf.lpvec3(*vel), "Movement: LpVec3 %s" % (vel,))
    fx.field(wf.angle(pitch), "Pitch: Angle %s degrees" % pitch)
    fx.field(wf.angle(yaw), "Yaw: Angle %s degrees" % yaw)
    fx.field(wf.angle(yaw), "Head yaw: Angle %s degrees" % yaw)
    fx.field(wf.varint(data), "Data: VarInt %d" % data)
    return fx


@fixture("play-s2c-01-add-entity-standard-cow")
def add_cow():
    return add_entity("play-s2c-01-add-entity-standard-cow", "Spawn Entity, a cow (standard type id)", 300, COW, (-12.5, 64.0, 40.25), (0, 0, 0), 90.0, 0.0, 0,
                      ["entity id 300; UUID " + UUID1 + "; type 30 (cow); position (-12.5, 64.0, 40.25); movement zero (one byte 00); yaw 90, pitch 0; data 0"])


@fixture("play-s2c-01-add-entity-item-standard")
def add_item():
    return add_entity("play-s2c-01-add-entity-item-standard", "Spawn Entity, a dropped item with movement", 301, ITEM, (0.5, 70.0, 0.5), (0.1, 0.2, -0.1), -45.0, 10.0, 0,
                      ["entity id 301; type 72 (item); position (0.5, 70.0, 0.5); movement (0.1, 0.2, -0.1) as a 6-byte LpVec3 (scale 1); yaw -45, pitch 10; data 0"])


@fixture("play-s2c-01-add-entity-zombie-fast")
def add_fast():
    return add_entity("play-s2c-01-add-entity-zombie-fast", "Spawn Entity, movement scale above 3 (LpVec3 with VarInt)", 302, ZOMBIE, (1.0, 2.0, 3.0), (8.0, 0.0, 0.0), 0.0, 0.0, 0,
                      ["entity id 302; type 154 (zombie); position (1, 2, 3); movement (8, 0, 0): scale 8 > 3, so the low byte carries scale mod 4 | 4 and a VarInt 2 follows"])


SERIALIZER_NAMES = (
    "BYTE INT LONG FLOAT STRING COMPONENT OPTIONAL_COMPONENT ITEM_STACK BOOLEAN ROTATIONS BLOCK_POS OPTIONAL_BLOCK_POS DIRECTION "
    "OPTIONAL_LIVING_ENTITY_REFERENCE BLOCK_STATE OPTIONAL_BLOCK_STATE PARTICLE PARTICLES VILLAGER_DATA OPTIONAL_UNSIGNED_INT POSE "
    "CAT_VARIANT CAT_SOUND_VARIANT COW_VARIANT COW_SOUND_VARIANT WOLF_VARIANT WOLF_SOUND_VARIANT FROG_VARIANT PIG_VARIANT "
    "PIG_SOUND_VARIANT CHICKEN_VARIANT CHICKEN_SOUND_VARIANT ZOMBIE_NAUTILUS_VARIANT OPTIONAL_GLOBAL_POS PAINTING_VARIANT "
    "SNIFFER_STATE ARMADILLO_STATE COPPER_GOLEM_STATE WEATHERING_COPPER_STATE VECTOR3 QUATERNION RESOLVABLE_PROFILE HUMANOID_ARM DYE_COLOR"
).split()


def serializer_value(sid):
    """(bytes, text) of the value of serializer `sid` (00 section 13.2)."""
    fl = wf.float32
    table = {
        0: (wf.byte(0x20), "Byte 0x20"),
        1: (wf.varint(300), "VarInt 300"),
        2: (wf.varlong(5000000000), "VarLong 5000000000"),
        3: (fl(1.5), "Float 1.5"),
        4: (wf.string("name"), "String \"name\""),
        5: (text_plain("c"), "TrustedTextComponent plain String \"c\""),
        6: (wf.bool1(True) + text_plain("o"), "Optional TextComponent present, plain String \"o\""),
        7: (stack(63, 3), "ItemStack 3 x oak_planks"),
        8: (wf.bool1(True), "Boolean true"),
        9: (fl(1.0) + fl(2.0) + fl(3.0), "Rotations (1.0, 2.0, 3.0)"),
        10: (wf.position(-1, 64, 2), "Position (-1, 64, 2)"),
        11: (wf.bool1(True) + wf.position(5, 6, 7), "Optional Position present (5, 6, 7)"),
        12: (wf.varint(4), "Direction VarInt 4 (west)"),
        13: (wf.bool1(True) + wf.uuid(UUID1), "Optional UUID present"),
        14: (wf.varint(88), "block state VarInt 88 (bedrock)"),
        15: (wf.varint(0), "optional block state VarInt 0 (absent)"),
        16: (wf.varint(21) + wf.int32(0xFF8800) + fl(1.0), "Particle dust (21): Int colour 0xff8800, Float scale 1.0"),
        17: (wf.prefixed([wf.varint(55)]), "Particles: count 1, heart (55), no option bytes"),
        18: (wf.varint(2) + wf.varint(9) + wf.varint(3), "VillagerData plains (2), librarian (9), level 3"),
        19: (wf.varint(8), "OptionalUnsignedInt VarInt 8 (value 7)"),
        20: (wf.varint(5), "Pose VarInt 5 (crouching)"),
        33: (wf.bool1(True) + wf.ident("minecraft:overworld") + wf.position(1, 2, 3), "Optional GlobalPos present: minecraft:overworld (1, 2, 3)"),
        34: (wf.varint(4), "Holder<painting_variant> reference VarInt 4 (id 3 + 1)"),
        35: (wf.varint(3), "Sniffer state VarInt 3 (sniffing)"),
        36: (wf.varint(2), "Armadillo state VarInt 2 (scared)"),
        37: (wf.varint(1), "Copper golem state VarInt 1 (getting_item)"),
        38: (wf.varint(3), "Weathering state VarInt 3 (oxidized)"),
        39: (fl(0.5) + fl(1.5) + fl(-2.0), "Vector3f (0.5, 1.5, -2.0)"),
        40: (fl(0.0) + fl(0.0) + fl(0.0) + fl(1.0), "Quaternionf (0, 0, 0, 1)"),
        41: (wf.bool1(False) + wf.bool1(True) + wf.string("Steve", 16) + wf.bool1(False) + wf.varint(0) + wf.bool1(False) * 4,
             "ResolvableProfile partial: name \"Steve\", no id, empty properties, empty skin patch (4 absent options)"),
        42: (wf.varint(1), "HumanoidArm VarInt 1 (right)"),
        43: (wf.varint(11), "DyeColor VarInt 11 (blue)"),
    }
    if 21 <= sid <= 32:
        return wf.varint(sid - 20), "RegistryId VarInt %d" % (sid - 20)
    return table[sid]


@fixture("play-s2c-65-set-entity-data-all-serializers")
def entity_data():
    fx = Fixture("play-s2c-65-set-entity-data-all-serializers", head(
        "Set Entity Data, one entry for every one of the 44 serializers", "play", "clientbound (S->C)", 0x65,
        "05b 0x65; 00 section 13.1 (wire structure), 13.2 (serializer ids 0 to 43), 13.3 (ResolvableProfile), 4.3 (GlobalPos), 4.5; 46 section 12 and worked example 7",
        ["entity id 300; metadata index i carries serializer id i for i = 0 to 43 (index and serializer are equal), then the 0xFF end marker",
         "values are fixture inputs, one per serializer, stated in each line; registry ids 1..12 for the twelve variant serializers 21 to 32"]))
    fx.field(wf.varint(0x65), "packet id: VarInt 0x65")
    fx.field(wf.varint(300), "Entity id: VarInt 300")
    for sid in range(44):
        data, text = serializer_value(sid)
        fx.field(wf.ubyte(sid) + wf.varint(sid), "Metadata[%d] (%s): index UByte %d, serializer VarInt %d" % (sid, SERIALIZER_NAMES[sid], sid, sid))
        fx.field(data, "  value: " + text, wrap=24)
    fx.field(wf.ubyte(255), "Metadata end: UByte 0xFF")
    return fx


@fixture("play-s2c-22-entity-event-poof")
def entity_event():
    fx = Fixture("play-s2c-22-entity-event-poof", head(
        "Entity Event 60 (poof)", "play", "clientbound (S->C)", 0x22, "05a 0x22 (Int entity id, Byte event); 18 section on death (Entity Event 60)",
        ["entity id 300 (Int, four bytes); event 60"]))
    fx.field(wf.varint(0x22), "packet id: VarInt 0x22")
    fx.field(wf.int32(300), "Entity id: Int 300")
    fx.field(wf.byte(60), "Event id: Byte 60 (poof)")
    return fx


@fixture("play-s2c-86-update-attributes")
def attributes():
    fx = Fixture("play-s2c-86-update-attributes", head(
        "Update Attributes with a modifier", "play", "clientbound (S->C)", 0x86,
        "05b 0x86 (AttributeSnapshot, AttributeModifier); 46 section 4.2 (max_health 23, movement_speed 26)",
        ["entity 300; attribute max_health (23) base 20.0 with no modifier; movement_speed (26) base 0.1 with one modifier",
         "minecraft:sprinting, amount 0.3, operation 2 (add multiplied total)"]))
    fx.field(wf.varint(0x86), "packet id: VarInt 0x86")
    fx.field(wf.varint(300), "Entity id: VarInt 300")
    fx.field(wf.varint(2), "Attributes: VarInt count 2")
    fx.field(wf.varint(23) + wf.float64(20.0) + wf.varint(0), "[0] max_health (23), base Double 20.0, modifiers count 0")
    fx.field(wf.varint(26) + wf.float64(0.1) + wf.varint(1), "[1] movement_speed (26), base Double 0.1, modifiers count 1")
    fx.field(wf.ident("minecraft:sprinting") + wf.float64(0.3) + wf.varint(2), "  modifier: id minecraft:sprinting, amount 0.3, operation 2")
    return fx


@fixture("play-s2c-87-update-mob-effect")
def mob_effect():
    fx = Fixture("play-s2c-87-update-mob-effect", head(
        "Update Mob Effect, Haste", "play", "clientbound (S->C)", 0x87, "05b 0x87; 46 worked example 1 (haste = 2)",
        ["entity 300; effect haste (2); amplifier 1; duration 600 ticks; flags 0x07 (ambient, visible, show icon)"]))
    fx.field(wf.varint(0x87), "packet id: VarInt 0x87")
    fx.field(wf.varint(300), "Entity id: VarInt 300")
    fx.field(wf.varint(2), "Effect: VarInt 2 (haste)")
    fx.field(wf.varint(1), "Amplifier: VarInt 1")
    fx.field(wf.varint(600), "Duration: VarInt 600")
    fx.field(wf.byte(7), "Flags: Byte 0x07")
    return fx


@fixture("play-s2c-2f-level-event")
def level_event():
    fx = Fixture("play-s2c-2f-level-event", head(
        "Level Event 2001 (block break effect)", "play", "clientbound (S->C)", 0x2F,
        "05a 0x2F; 42 part 4 section 13.3 and 42 part 7 section 8 (event 2001: Int data is the block state id)",
        ["event 2001; location (-3, 12, 9); data 88 (bedrock state id); global false"]))
    fx.field(wf.varint(0x2F), "packet id: VarInt 0x2f")
    fx.field(wf.int32(2001), "Event type: Int 2001")
    fx.field(wf.position(-3, 12, 9), "Location: Position (-3, 12, 9)")
    fx.field(wf.int32(88), "Data: Int 88")
    fx.field(wf.bool1(False), "Global: Boolean false")
    return fx


@fixture("play-s2c-30-level-particles-dust")
def particles():
    fx = Fixture("play-s2c-30-level-particles-dust", head(
        "Level Particles, dust", "play", "clientbound (S->C)", 0x30,
        "05a 0x30 and Particle (dust: Int colour, Float scale); 46 section 5.1 and worked example 5 (dust = 21)",
        ["particle dust colour 0xff0000 scale 2.0; override limiter false; always show true; position (0.5, 65.0, 0.5);",
         "distance (0.25, 0.5, 0.25); max speed 0.0 on each axis (three floats); count 7; randomization 1 (ALTERNATIVE)"]))
    fx.field(wf.varint(0x30), "packet id: VarInt 0x30")
    fx.field(wf.varint(21) + wf.int32(0xFF0000) + wf.float32(2.0), "Particle: type VarInt 21 (dust), Int colour 0xff0000, Float scale 2.0")
    fx.field(wf.bool1(False), "Override limiter: Boolean false")
    fx.field(wf.bool1(True), "Always show: Boolean true")
    for label, v in (("X", 0.5), ("Y", 65.0), ("Z", 0.5)):
        fx.field(wf.float64(v), "%s: Double %s" % (label, v))
    for label, v in (("X distance", 0.25), ("Y distance", 0.5), ("Z distance", 0.25), ("X max speed", 0.0), ("Y max speed", 0.0), ("Z max speed", 0.0)):
        fx.field(wf.float32(v), "%s: Float %s" % (label, v))
    fx.field(wf.varint(7), "Count: VarInt 7")
    fx.field(wf.varint(1), "Randomization: VarInt 1")
    return fx


@fixture("play-s2c-30-level-particles")
def particles_block():
    fx = Fixture("play-s2c-30-level-particles", head(
        "Level Particles, block (state id option)", "play", "clientbound (S->C)", 0x30, "05a 0x30 and Particle (block: VarInt state id); 46 section 5.1 (block = 1)",
        ["particle block with state 35722; override limiter true; always show false; position (-1.5, 3.0, 8.25); zero spread and speed; count 0; randomization 0"]))
    fx.field(wf.varint(0x30), "packet id: VarInt 0x30")
    fx.field(wf.varint(1) + wf.varint(35722), "Particle: type VarInt 1 (block), state VarInt 35722")
    fx.field(wf.bool1(True), "Override limiter: Boolean true")
    fx.field(wf.bool1(False), "Always show: Boolean false")
    for label, v in (("X", -1.5), ("Y", 3.0), ("Z", 8.25)):
        fx.field(wf.float64(v), "%s: Double %s" % (label, v))
    for label in ("X distance", "Y distance", "Z distance", "X max speed", "Y max speed", "Z max speed"):
        fx.field(wf.float32(0.0), "%s: Float 0.0" % label)
    fx.field(wf.varint(0), "Count: VarInt 0")
    fx.field(wf.varint(0), "Randomization: VarInt 0")
    return fx


DIMENSIONS = [
    ("minecraft:overworld", 0, 63),
    ("minecraft:the_nether", 1, 32),
    ("minecraft:the_end", 2, 0),
]


def spawn_info(fx, dim_type, dim, sea, prefix="Spawn info."):
    fx.field(wf.varint(dim_type), "%sDimension type: VarInt %d (registry id in config-s2c-07-registry-data-dimension-type-standard)" % (prefix, dim_type))
    fx.field(wf.ident(dim), "%sDimension: Identifier" % prefix)
    fx.field(wf.long64(0x1122334455667788), "%sHashed seed: Long 0x1122334455667788" % prefix)
    fx.field(wf.varint(1), "%sGame mode: VarInt 1 (creative)" % prefix)
    fx.field(wf.varint(1), "%sPrevious game mode: OptionalVarInt 1 (survival)" % prefix)
    fx.field(wf.bool1(False), "%sIs debug: Boolean false" % prefix)
    fx.field(wf.bool1(False), "%sIs flat: Boolean false" % prefix)
    fx.field(wf.bool1(True) + wf.ident("minecraft:overworld") + wf.position(10, 64, -10), "%sLast death location: present, minecraft:overworld (10, 64, -10)" % prefix)
    fx.field(wf.varint(0), "%sPortal cooldown: VarInt 0" % prefix)
    fx.field(wf.varint(sea), "%sSea level: VarInt %d" % (prefix, sea))


@fixture("play-s2c-32-login-all-dimensions-standard")
def login_three():
    fx = Fixture("play-s2c-32-login-all-dimensions-standard", head(
        "Login, standard world with three dimensions", "play", "clientbound (S->C)", 0x32,
        "05a 0x32 and CommonPlayerSpawnInfo; 39 (the three dimensions); 37 section 2.1; 09 section 1",
        ["entity id 1; hardcore false; dimensions [minecraft:overworld, minecraft:the_nether, minecraft:the_end]; max players 20; view and simulation distance 10;",
         "reduced debug false; show death screen true; limited crafting false (the standard 46-slot menu); spawn info of minecraft:overworld: dimension type 0,",
         "hashed seed 0x1122334455667788, creative, previous game mode survival, last death location (10, 64, -10) in the overworld, portal cooldown 0, sea level 63;",
         "online mode false; enforces secure chat false"]))
    fx.field(wf.varint(0x32), "packet id: VarInt 0x32")
    fx.field(wf.int32(1), "Entity id: Int 1")
    fx.field(wf.bool1(False), "Hardcore: Boolean false")
    fx.field(wf.varint(3), "Dimension names: VarInt count 3")
    for name, _, _ in DIMENSIONS:
        fx.field(wf.ident(name), "Dimension name: Identifier %s" % name)
    fx.field(wf.varint(20), "Max players: VarInt 20")
    fx.field(wf.varint(10), "View distance: VarInt 10")
    fx.field(wf.varint(10), "Simulation distance: VarInt 10")
    fx.field(wf.bool1(False), "Reduced debug info: Boolean false")
    fx.field(wf.bool1(True), "Show death screen: Boolean true")
    fx.field(wf.bool1(False), "Limited crafting: Boolean false")
    spawn_info(fx, 0, "minecraft:overworld", 63)
    fx.field(wf.bool1(False), "Online mode: Boolean false")
    fx.field(wf.bool1(False), "Enforces secure chat: Boolean false")
    return fx


def respawn(name, dim, dim_type, sea, keep):
    fx = Fixture(name, head("Respawn into %s" % dim, "play", "clientbound (S->C)", 0x54, "05b 0x54 and CommonPlayerSpawnInfo; 39 (portals)",
                            ["spawn info for %s: dimension type %d, sea level %d, other fields as in play-s2c-32-login-all-dimensions-standard; data to keep 0x%02x" % (dim, dim_type, sea, keep)]))
    fx.field(wf.varint(0x54), "packet id: VarInt 0x54")
    spawn_info(fx, dim_type, dim, sea)
    fx.field(wf.byte(keep), "Data to keep: Byte 0x%02x" % keep)
    return fx


@fixture("play-s2c-54-respawn-main-standard")
def respawn_over():
    return respawn("play-s2c-54-respawn-main-standard", "minecraft:overworld", 0, 63, 0)


@fixture("play-s2c-54-respawn-the-nether-standard")
def respawn_nether():
    return respawn("play-s2c-54-respawn-the-nether-standard", "minecraft:the_nether", 1, 32, 1)


@fixture("play-s2c-54-respawn-the-end-standard")
def respawn_end():
    return respawn("play-s2c-54-respawn-the-end-standard", "minecraft:the_end", 2, 0, 3)
