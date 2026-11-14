"""Wire fixture catalogue, part 1 (T0060, T0061): configuration registries and tags, chunk and light data,
block changes and block breaking of the standard world type. Written from docs/protocol/04, 06, 05a, 05c, 13."""
import struct

import wire_fixtures as wf
from wire_fixtures import (Byte, Compound, Double, Float, Int, ListOf, Str, TAG_STRING, Fixture, fixture)

PLAIN_BLOCKS = {"air": 0, "stone": 1, "grass_block": 9, "dirt": 10, "cobblestone": 14, "oak_planks": 15, "bedrock": 88}
NO_BIOMES = 65  # fixture input: size of the synchronized biome registry; direct biome width = ceillog2 = 7
BLOCK_STATES = 35723  # 24 part 8 whole-registry check; direct block width = ceillog2 = 16


def head(title, phase, direction, pid, refs, inputs):
    lines = [
        "Fixture: %s" % title,
        "Phase: %s. Direction: %s. Packet id 0x%02x (%d)." % (phase, direction, pid, pid),
        "Doc refs: " + refs,
        "Stated inputs:",
    ]
    lines += ["  " + line for line in inputs]
    return lines


def dim_entry(scale, skylight, ceiling, fixed, dragon, min_y, height, logical, burn, ambient, spawn_light, spawn_block, sky, cardinal):
    members = []
    if fixed:
        members.append(("has_fixed_time", Byte(1)))
    members += [
        ("has_skylight", Byte(int(skylight))),
        ("has_ceiling", Byte(int(ceiling))),
        ("has_ender_dragon_fight", Byte(int(dragon))),
        ("coordinate_scale", Double(scale)),
        ("min_y", Int(min_y)),
        ("height", Int(height)),
        ("logical_height", Int(logical)),
        ("infiniburn", Str(burn)),
        ("ambient_light", Float(ambient)),
        ("monster_spawn_light_level", spawn_light),
        ("monster_spawn_block_light_limit", Int(spawn_block)),
        ("skybox", Str(sky)),
        ("cardinal_light", Str(cardinal)),
    ]
    return Compound(members)


@fixture("config-s2c-07-registry-data-dimension-type-standard")
def dimension_type():
    fx = Fixture("config-s2c-07-registry-data-dimension-type-standard", head(
        "Registry Data (minecraft:dimension_type), standard world type", "configuration", "clientbound (S->C)", 7,
        "04 Registry Data, section 4 (ids in packet order), section 6 dimension_type; 37 section 2.1 (values of the three dimension types); 23 section 7.1 (IntProvider forms)",
        ["registry minecraft:dimension_type, 3 entries in id order: 0 minecraft:overworld, 1 minecraft:the_nether, 2 minecraft:the_end",
         "values of 37 section 2.1 (min_y -64/0/0, height 384/256/256, logical 384/128/256); optional fields not listed there are absent",
         "monster_spawn_light_level: overworld uniform 0..7 (compound form), nether constant 7, end constant 15 (bare Int)",
         "no known packs, so every entry has Data present"]))
    fx.field(wf.varint(7), "packet id: VarInt 0x07")
    fx.field(wf.ident("minecraft:dimension_type"), "Registry: Identifier")
    fx.field(wf.varint(3), "Entries: VarInt count 3")
    uniform = Compound([("type", Str("minecraft:uniform")), ("min_inclusive", Int(0)), ("max_inclusive", Int(7))])
    entries = [
        ("minecraft:overworld", dim_entry(1.0, True, False, False, False, -64, 384, 384, "#minecraft:infiniburn_overworld", 0.0, uniform, 0, "overworld", "default")),
        ("minecraft:the_nether", dim_entry(8.0, False, True, True, False, 0, 256, 128, "#minecraft:infiniburn_nether", 0.1, Int(7), 15, "none", "nether")),
        ("minecraft:the_end", dim_entry(1.0, True, False, True, True, 0, 256, 256, "#minecraft:infiniburn_end", 0.25, Int(15), 0, "end", "default")),
    ]
    for number, (key, tag) in enumerate(entries):
        fx.note("---- entry %d: %s ----" % (number, key))
        fx.field(wf.ident(key), "Entry[%d].Id: Identifier" % number)
        fx.field(wf.bool1(True), "Entry[%d].Data present: Boolean true" % number)
        fx.nbt(tag, "Entry[%d].Data" % number)
    return fx


@fixture("config-s2c-07-registry-data-chat-type-standard")
def chat_type():
    fx = Fixture("config-s2c-07-registry-data-chat-type-standard", head(
        "Registry Data (minecraft:chat_type), standard world type", "configuration", "clientbound (S->C)", 7,
        "04 Registry Data and section 6 chat_type (ChatTypeDecoration); 16 section 8 (chat type data)",
        ["registry minecraft:chat_type, 3 entries in id order: 0 minecraft:chat, 1 minecraft:say_command, 2 minecraft:msg_command_incoming",
         "chat: translation_key chat.type.text, parameters [sender, content]; narration chat.type.text.narrate, parameters [sender, content]",
         "say_command: chat.type.announcement; msg_command_incoming: commands.message.display.incoming with style {color gray, italic true}",
         "(16 section 8 gives the keys and parameter order; the vanilla chat entry is the plain chat.type.text pair)"]))
    fx.field(wf.varint(7), "packet id: VarInt 0x07")
    fx.field(wf.ident("minecraft:chat_type"), "Registry: Identifier")
    fx.field(wf.varint(3), "Entries: VarInt count 3")

    def deco(key, params, style=False):
        members = [("translation_key", Str(key)), ("parameters", ListOf(TAG_STRING, [Str(p) for p in params]))]
        if style:
            members.append(("style", Compound([("color", Str("gray")), ("italic", Byte(1))])))
        return Compound(members)

    sc = ["sender", "content"]
    entries = [
        ("minecraft:chat", Compound([("chat", deco("chat.type.text", sc)), ("narration", deco("chat.type.text.narrate", sc))])),
        ("minecraft:say_command", Compound([("chat", deco("chat.type.announcement", sc)), ("narration", deco("chat.type.text.narrate", sc))])),
        ("minecraft:msg_command_incoming", Compound([("chat", deco("commands.message.display.incoming", sc, True)), ("narration", deco("chat.type.text.narrate", sc))])),
    ]
    for number, (key, tag) in enumerate(entries):
        fx.note("---- entry %d: %s ----" % (number, key))
        fx.field(wf.ident(key), "Entry[%d].Id: Identifier" % number)
        fx.field(wf.bool1(True), "Entry[%d].Data present: Boolean true" % number)
        fx.nbt(tag, "Entry[%d].Data" % number)
    return fx


@fixture("config-s2c-0e-update-tags-standard")
def update_tags():
    fx = Fixture("config-s2c-0e-update-tags-standard", head(
        "Update Tags, standard world type", "configuration", "clientbound (S->C)", 0x0E,
        "04 Update Tags (RegistryTags, TagEntry), section 5 (static ids), 24 part 1 rows (block ids), 25 part 1 (item ids), 46 section 15",
        ["2 registries: minecraft:block with tag minecraft:planks = [oak_planks 13] and minecraft:base_stone_overworld = [stone 1, cobblestone 12]",
         "minecraft:dimension_type with tag minecraft:in_overworld = [0] (synchronized registry, id = Registry Data order)"]))
    fx.field(wf.varint(0x0E), "packet id: VarInt 0x0e")
    fx.field(wf.varint(3), "Registries: VarInt count 3")
    groups = [
        ("minecraft:block", [("minecraft:planks", [13]), ("minecraft:base_stone_overworld", [1, 12])]),
        ("minecraft:item", [("minecraft:planks", [63])]),
        ("minecraft:dimension_type", [("minecraft:in_overworld", [0])]),
    ]
    for key, tags in groups:
        fx.field(wf.ident(key), "Registry: Identifier")
        fx.field(wf.varint(len(tags)), "Tags: VarInt count")
        for name, ids in tags:
            fx.field(wf.ident(name), "Tag name: Identifier")
            fx.field(wf.prefixed([wf.varint(i) for i in ids]), "Entries: VarInt count then ids %s" % ids)
    return fx


# ---------------------------------------------------------------------------------------------
# Chunk data (06)

def heightmap(values, bits=9):
    return wf.pack_longs(values, bits)


def long_lines(fx, data, comment):
    fx.field(data, comment, wrap=32)


@fixture("play-s2c-2e-level-chunk-with-light-standard-24-sections")
def level_chunk():
    fx = Fixture("play-s2c-2e-level-chunk-with-light-standard-24-sections", head(
        "Level Chunk With Light, standard overworld, 24 sections", "play", "clientbound (S->C)", 0x2E,
        "06 section 2 to 7 (packet, ChunkData, Section, PalettedContainer 5.1 to 5.5, long packing 6, LightData 7); 04 section 3.3; 24 part 8 (35723 states)",
        ["chunk (0, 0) of minecraft:overworld: min_y -64, height 384, so 24 block sections (section Y -4 to 19) and 26 light sections",
         "state ids (24 part 1): air 0, stone 1, dirt 10, bedrock 88",
         "heightmaps: ordinals 1, 4, 5 each 37 longs (9 bits); every column value 128 (surface at y 64: 64 - (-64))",
         "section 0 (y -64..-49): indirect palette [bedrock, stone], bits 4; bedrock layer y=-64 (cells 0..255), the rest stone",
         "sections 1..3: single value stone; section 4: indirect 4 bits [stone, dirt]; section 5: indirect 5 bits (20 distinct ids 100..119)",
         "section 6: indirect 6 bits (40 distinct ids 200..239); section 7: indirect 8 bits (200 distinct ids 300..499)",
         "section 8: direct (16 bits per entry = ceillog2(35723)), entry i holds state (i * 7) mod 35723",
         "sections 9..17: single value stone; sections 18..23 (y 224..319): single value air",
         "biomes: 64 entries each. Biome registry size is a fixture input: 65, so direct width is 7. Biome ids: section 0 single 0 (plains)",
         "  sections 1..3 indirect 1 bit [0,1]; section 4 indirect 2 bits [0..3]; section 5 indirect 3 bits [0..7]; section 6 direct 7 bits; rest single 0",
         "non-empty block count: 4096 for full sections, 0 for air; fluid count 0 everywhere; block entities none",
         "light: sky light arrays for light sections 0 and 20 (all 0xff, value 15); light sections 1 and 2 empty-sky; block light empty for 0..25 except 4",
         "  (so 26 entries are reported: 2 sky arrays, 2 empty sky, 24 empty block bits, 1 block array of 0x11 at index 4)"]))
    fx.field(wf.varint(0x2E), "packet id: VarInt 0x2e")
    fx.field(wf.int32(0), "Chunk X: Int 0")
    fx.field(wf.int32(0), "Chunk Z: Int 0")
    fx.field(wf.varint(3), "Heightmaps: VarInt count 3")
    hm = heightmap([128] * 256)
    for ordinal, name in [(1, "WORLD_SURFACE"), (4, "MOTION_BLOCKING"), (5, "MOTION_BLOCKING_NO_LEAVES")]:
        fx.field(wf.varint(ordinal), "Heightmap type ordinal %d %s" % (ordinal, name))
        fx.field(wf.varint(37), "  longs: VarInt 37")
        long_lines(fx, hm, "  data: 37 big-endian longs (9 bits, 7 per long), every value 128")
    secs = []
    zero = [0] * 64
    for s in range(24):
        if s == 0:
            vals = [1] * 4096
            for i in range(256):
                vals[i] = 88
            blocks = wf.container_indirect(vals, [88, 1], "block")
            blocks = blocks  # palette order is first occurrence: bedrock then stone
            n = 4096
        elif s in (1, 2, 3):
            blocks, n = wf.container_single(1), 4096
        elif s == 4:
            vals = [(10 if (i // 256) % 2 else 1) for i in range(4096)]
            blocks, n = wf.container_indirect(vals, [1, 10], "block"), 4096
        elif s == 5:
            pal = list(range(100, 120))
            blocks, n = wf.container_indirect([pal[i % 20] for i in range(4096)], pal, "block"), 4096
        elif s == 6:
            pal = list(range(200, 240))
            blocks, n = wf.container_indirect([pal[i % 40] for i in range(4096)], pal, "block"), 4096
        elif s == 7:
            pal = list(range(300, 500))
            blocks, n = wf.container_indirect([pal[i % 200] for i in range(4096)], pal, "block"), 4096
        elif s == 8:
            blocks, n = wf.container_direct([(i * 7) % BLOCK_STATES for i in range(4096)], 16, "block"), 4096
        elif s < 18:
            blocks, n = wf.container_single(1), 4096
        else:
            blocks, n = wf.container_single(0), 0
        if s == 0:
            biomes = wf.container_single(0)
        elif s in (1, 2, 3):
            biomes = wf.container_indirect([i % 2 for i in range(64)], [0, 1], "biome")
        elif s == 4:
            biomes = wf.container_indirect([i % 4 for i in range(64)], [0, 1, 2, 3], "biome")
        elif s == 5:
            biomes = wf.container_indirect([i % 8 for i in range(64)], list(range(8)), "biome")
        elif s == 6:
            biomes = wf.container_direct([(i * 3) % NO_BIOMES for i in range(64)], 7, "biome")
        else:
            biomes = wf.container_single(0)
        secs.append((s, n, blocks, biomes))
    buf = b""
    sizes = []
    for s, n, blocks, biomes in secs:
        part = wf.section(n, 0, blocks, biomes)
        sizes.append(len(part))
        buf += part
    fx.field(wf.varint(len(buf)), "Section buffer: ByteArray length VarInt %d" % len(buf))
    for (s, n, blocks, biomes), size in zip(secs, sizes):
        fx.field(wf.short(n), "Section %d (y %d): non-empty block count Short %d" % (s, -64 + 16 * s, n))
        fx.field(wf.short(0), "  fluid count: Short 0")
        fx.field(blocks, "  block states: PalettedContainer (%d bytes)" % len(blocks), wrap=32)
        fx.field(biomes, "  biomes: PalettedContainer (%d bytes)" % len(biomes), wrap=32)
    fx.field(wf.varint(0), "Block entities: VarInt count 0")
    sky = {0: b"\xff" * 2048, 20: b"\xff" * 2048}
    blk = {4: b"\x11" * 2048}
    fx.field(wf.byte_bitset(sorted(sky)), "Sky light mask: ByteBitSet bits 0 and 20")
    fx.field(wf.byte_bitset(sorted(blk)), "Block light mask: ByteBitSet bit 4")
    fx.field(wf.byte_bitset([1, 2]), "Empty sky light mask: ByteBitSet bits 1 and 2")
    empty_block = [i for i in range(26) if i != 4]
    fx.field(wf.byte_bitset(empty_block), "Empty block light mask: ByteBitSet bits 0..25 except 4")
    fx.field(wf.varint(2), "Sky light arrays: VarInt count 2")
    for i in sorted(sky):
        fx.field(wf.varint(2048), "  array for light section %d: length VarInt 2048" % i)
        fx.field(sky[i], "  2048 bytes, every nibble 15", wrap=32)
    fx.field(wf.varint(1), "Block light arrays: VarInt count 1")
    fx.field(wf.varint(2048), "  array for light section 4: length VarInt 2048")
    fx.field(blk[4], "  2048 bytes, every nibble 1", wrap=32)
    return fx


@fixture("play-s2c-31-light-update-standard")
def light_update():
    fx = Fixture("play-s2c-31-light-update-standard", head(
        "Light Update, standard overworld, 26 light sections", "play", "clientbound (S->C)", 0x31,
        "06 section 7 (LightData), section 8 (Light Update, VarInt chunk coordinates), section 1 (26 light sections for 24 block sections)",
        ["chunk (-1, 2); light sections 0..25: sky light arrays for 24 and 25 (0x0f bytes: nibbles 15 and 0), empty sky bits 0..23",
         "block light: array at index 3 (0x22 bytes), empty block bits all other 25 indices"]))
    fx.field(wf.varint(0x31), "packet id: VarInt 0x31")
    fx.field(wf.varint(-1), "Chunk X: VarInt -1 (negative: 5 bytes)")
    fx.field(wf.varint(2), "Chunk Z: VarInt 2")
    sky = {24: b"\x0f" * 2048, 25: b"\x0f" * 2048}
    blk = {3: b"\x22" * 2048}
    body = wf.light_data(26, sky, blk, list(range(24)), [i for i in range(26) if i != 3])
    fx.field(wf.byte_bitset([24, 25]), "Sky light mask: ByteBitSet bits 24, 25")
    fx.field(wf.byte_bitset([3]), "Block light mask: ByteBitSet bit 3")
    fx.field(wf.byte_bitset(list(range(24))), "Empty sky light mask: bits 0..23")
    fx.field(wf.byte_bitset([i for i in range(26) if i != 3]), "Empty block light mask: bits 0..25 except 3")
    fx.field(wf.varint(2), "Sky light arrays: count 2")
    for i in (24, 25):
        fx.field(wf.varint(2048), "  array for light section %d: length 2048" % i)
        fx.field(sky[i], "  2048 bytes 0x0f (nibbles 15 then 0)", wrap=32)
    fx.field(wf.varint(1), "Block light arrays: count 1")
    fx.field(wf.varint(2048), "  array for light section 3: length 2048")
    fx.field(blk[3], "  2048 bytes 0x22 (every nibble 2)", wrap=32)
    assert fx.bytes() == wf.varint(0x31) + wf.varint(-1) + wf.varint(2) + body
    return fx


@fixture("play-s2c-56-section-blocks-update-standard")
def section_blocks():
    fx = Fixture("play-s2c-56-section-blocks-update-standard", head(
        "Section Blocks Update, standard state ids", "play", "clientbound (S->C)", 0x56,
        "06 section 9 (entries (state << 12) | localPos), Composite SectionPos; 24 part 1 (state ids)",
        ["section (0, -4, 0) (the lowest overworld section), 3 changes: (x 1, y 0, z 2) -> bedrock 88; (x 15, y 15, z 15) -> cobblestone 14;",
         "(x 0, y 7, z 0) -> state 35722 (the last state id: 35723 states)"]))
    fx.field(wf.varint(0x56), "packet id: VarInt 0x56")
    pos = ((0 & 0x3FFFFF) << 42) | ((0 & 0x3FFFFF) << 20) | ((-4) & 0xFFFFF)
    fx.field(struct.pack(">Q", pos), "Section position: SectionPos Long (x 0, z 0, y -4)")
    changes = [((1, 0, 2), 88), ((15, 15, 15), 14), ((0, 7, 0), 35722)]
    fx.field(wf.varint(len(changes)), "Count: VarInt 3")
    for (x, y, z), state in changes:
        local = (x << 8) | (z << 4) | y
        fx.field(wf.varlong((state << 12) | local), "change (%d, %d, %d) state %d: VarLong (state << 12) | %#05x" % (x, y, z, state, local))
    return fx


# ---------------------------------------------------------------------------------------------
# Block breaking (T0061; 13 section 2.3, 2.4)

@fixture("play-s2c-05-block-destruction-standard")
def block_destruction():
    fx = Fixture("play-s2c-05-block-destruction-standard", head(
        "Block Destruction, stage 9", "play", "clientbound (S->C)", 5, "05a 0x05; 00 section 4.1; 13 section 2.4",
        ["breaker entity id 300 (two-byte VarInt); location (-12, -60, 40); progress stage 9; stage -1 (255) would remove the overlay"]))
    fx.field(wf.varint(5), "packet id: VarInt 0x05")
    fx.field(wf.varint(300), "Breaker id: VarInt 300")
    fx.field(wf.position(-12, -60, 40), "Location: Position (-12, -60, 40)")
    fx.field(wf.ubyte(9), "Progress: UByte 9")
    return fx


@fixture("play-s2c-05-block-destruction-standard-clear")
def block_destruction_clear():
    fx = Fixture("play-s2c-05-block-destruction-standard-clear", head(
        "Block Destruction, overlay removed", "play", "clientbound (S->C)", 5, "05a 0x05 (values outside 0 to 9 remove the overlay); 13 section 2.4",
        ["breaker entity id 1; location (7, 70, -3); progress 255 (remove the overlay)"]))
    fx.field(wf.varint(5), "packet id: VarInt 0x05")
    fx.field(wf.varint(1), "Breaker id: VarInt 1")
    fx.field(wf.position(7, 70, -3), "Location: Position (7, 70, -3)")
    fx.field(wf.ubyte(255), "Progress: UByte 255")
    return fx


@fixture("play-s2c-08-block-update-standard")
def block_update():
    fx = Fixture("play-s2c-08-block-update-standard", head(
        "Block Update, 16-bit state id", "play", "clientbound (S->C)", 8, "05a 0x08; 00 section 4.1; 24 part 1 (state ids)",
        ["location (100, -64, -100); new state 88 (bedrock); second fixture value 35722 is used by the section update"]))
    fx.field(wf.varint(8), "packet id: VarInt 0x08")
    fx.field(wf.position(100, -64, -100), "Location: Position (100, -64, -100)")
    fx.field(wf.varint(88), "Block state: VarInt 88 (bedrock)")
    return fx


@fixture("play-s2c-08-block-update-standard-large-id")
def block_update_large():
    fx = Fixture("play-s2c-08-block-update-standard-large-id", head(
        "Block Update, three-byte state id", "play", "clientbound (S->C)", 8, "05a 0x08; 24 part 8 (35723 states)",
        ["location (0, 319, 0) (top of the overworld); new state 35722 (the last state id, a three-byte VarInt)"]))
    fx.field(wf.varint(8), "packet id: VarInt 0x08")
    fx.field(wf.position(0, 319, 0), "Location: Position (0, 319, 0)")
    fx.field(wf.varint(35722), "Block state: VarInt 35722")
    return fx


def action(name, ordinal, label, pos, face, seq, extra=""):
    fx = Fixture(name, head(
        "Player Action %d %s" % (ordinal, label), "play", "serverbound (C->S)", 0x29, "05c 0x29; 00 section 4.1; 13 section 2.3 (sequence ids), section 4 (swap)",
        ["action %d %s; location %s; face %d; sequence %d%s" % (ordinal, label, pos, face, seq, extra)]))
    fx.field(wf.varint(0x29), "packet id: VarInt 0x29")
    fx.field(wf.varint(ordinal), "Action: VarInt %d %s" % (ordinal, label))
    fx.field(wf.position(*pos), "Location: Position %s" % (pos,))
    fx.field(wf.ubyte(face), "Face: UByte %d" % face)
    fx.field(wf.varint(seq), "Sequence: VarInt %d" % seq)
    return fx


@fixture("play-c2s-29-player-action-start-destroy-standard")
def pa_start():
    return action("play-c2s-29-player-action-start-destroy-standard", 0, "START_DESTROY_BLOCK", (-12, -60, 40), 1, 41)


@fixture("play-c2s-29-player-action-abort-destroy-standard")
def pa_abort():
    return action("play-c2s-29-player-action-abort-destroy-standard", 2, "ABORT_DESTROY_BLOCK", (-12, -60, 40), 1, 42)


@fixture("play-c2s-29-player-action-stop-destroy-standard")
def pa_stop():
    return action("play-c2s-29-player-action-stop-destroy-standard", 3, "STOP_DESTROY_BLOCK", (-12, -60, 40), 1, 300)


@fixture("play-c2s-29-player-action-swap-item-with-offhand")
def pa_swap():
    return action("play-c2s-29-player-action-swap-item-with-offhand", 7, "SWAP_ITEM_WITH_OFFHAND", (0, 0, 0), 0, 0, " (block-free action: location (0, 0, 0), face 0, sequence 0)")


# ---------------------------------------------------------------------------------------------
# Block Event and Block Entity Data (T0157; 05a 0x07, 0x06; 46 sections 5.4 and 6 example 4)

@fixture("play-s2c-07-block-event-standard")
def block_event():
    fx = Fixture("play-s2c-07-block-event-standard", head(
        "Block Event, chest opened", "play", "clientbound (S->C)", 7, "05a 0x07; 00 section 4.1",
        ["location (3, 64, -5); param 0 = 1; param 1 = 2; block registry id 300 (two-byte VarInt, a block id and not a state id)"]))
    fx.field(wf.varint(7), "packet id: VarInt 0x07")
    fx.field(wf.position(3, 64, -5), "Location: Position (3, 64, -5)")
    fx.field(wf.ubyte(1), "Param 0: UByte 1")
    fx.field(wf.ubyte(2), "Param 1: UByte 2")
    fx.field(wf.varint(300), "Block: VarInt 300")
    return fx


@fixture("play-s2c-06-block-entity-data-standard")
def block_entity_data():
    fx = Fixture("play-s2c-06-block-entity-data-standard", head(
        "Block Entity Data, sign", "play", "clientbound (S->C)", 6, "05a 0x06; 46 section 5.4 (sign = 7); 00 section 4.1; 07 section 1",
        ["location (-8, 70, 21); block entity type 7 (sign); data: network NBT compound {is_waxed: Byte 1, note: String \"hi\"}"]))
    fx.field(wf.varint(6), "packet id: VarInt 0x06")
    fx.field(wf.position(-8, 70, 21), "Location: Position (-8, 70, 21)")
    fx.field(wf.varint(7), "Block entity type: VarInt 7 (sign)")
    fx.nbt(Compound([("is_waxed", Byte(1)), ("note", Str("hi"))]), "Data")
    return fx
