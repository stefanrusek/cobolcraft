"""Wire fixture catalogue, part 3 (T0063): the command tree, command suggestions, chat command and the chat
packets with standard chat types. Written from docs/protocol/05a 0x0F, 0x10, 0x21, 0x42, 05c 0x07, 0x0F,
15, 15a and 16 section 8; parser ids from 05a (the registry table, 62 parsers)."""
import wire_fixtures as wf
from wire_catalog_menus import text_plain
from wire_catalog_world import head
from wire_fixtures import Fixture, fixture

PARSERS = (
    "bool float double integer long string entity game_profile block_pos column_pos vec3 vec2 block_state block_predicate "
    "item_stack item_predicate team_color hex_color component style message nbt_compound_tag nbt_tag nbt_path objective "
    "objective_criteria operation particle angle rotation scoreboard_slot score_holder swizzle team item_slot item_slots "
    "resource_location function entity_anchor int_range float_range dimension gamemode time resource_or_tag "
    "resource_or_tag_key resource resource_key resource_selector template_mirror template_rotation heightmap loot_table "
    "loot_predicate loot_modifier context_float_provider context_int_provider slot_source dialog feature swing_animation uuid"
).split()


def parser_props(pid, name):
    if name == "float":
        return wf.number_range_float(0.0, 1.0), "NumberRange(Float) min 0.0 max 1.0"
    if name == "double":
        return wf.number_range_double(-1.5, None), "NumberRange(Double) min -1.5, no max"
    if name == "integer":
        return wf.number_range_int(-5, 5), "NumberRange(Int) min -5 max 5"
    if name == "long":
        return wf.number_range_long(None, 1000000000000), "NumberRange(Long) no min, max 1e12"
    if name == "string":
        return wf.varint(2), "string kind 2 GREEDY_PHRASE"
    if name == "entity":
        return wf.ubyte(3), "flags 0x03 (single, players only)"
    if name == "score_holder":
        return wf.ubyte(1), "flags 0x01 (multiple)"
    if name == "time":
        return wf.int32(0), "Int minimum 0"
    if name in ("resource_or_tag", "resource_or_tag_key", "resource", "resource_key", "resource_selector"):
        return wf.ident("minecraft:item"), "registry key minecraft:item"
    return b"", "no properties"


@fixture("play-s2c-10-commands-all-parsers")
def commands_all():
    fx = Fixture("play-s2c-10-commands-all-parsers", head(
        "Commands, a tree holding every argument parser kind", "play", "clientbound (S->C)", 0x10,
        "05a 0x10 (CommandNode, flags, parser registry and property layouts, NumberRange); 15, 15a (tree structure); 46 section 10 and worked example 3",
        ["node 0 root, child [1]; node 1 literal \"all\" (not executable) with 62 children, nodes 2..63, one argument node per parser id 0..61",
         "named a<id> (a0 .. a61), each executable (flag 0x04); every node's properties are the ones of its parser (see the lines below)",
         "node 64: literal \"alias\" with redirect (flag 0x08) to node 1, executable; node 65: argument \"who\" parser entity with custom suggestions",
         "  (flag 0x10, minecraft:ask_server); node 66: literal \"op_only\" restricted (flag 0x20), executable; root children are [1, 64, 65, 66]",
         "root index 0"]))
    nodes = []
    notes = []
    nodes.append(wf.command_node(wf.NODE_ROOT, [1, 64, 65, 66]))
    notes.append("node 0: root, children 1, 64, 65, 66")
    nodes.append(wf.command_node(wf.NODE_LITERAL, list(range(2, 64)), name="all"))
    notes.append("node 1: literal \"all\", 62 children")
    for pid, name in enumerate(PARSERS):
        props, text = parser_props(pid, name)
        nodes.append(wf.command_node(wf.NODE_ARGUMENT | wf.NODE_EXECUTABLE, [], name="a%d" % pid, parser=pid, props=props))
        notes.append("node %d: argument a%d, executable, parser %d (%s), %s" % (pid + 2, pid, pid, name, text))
    assert len(nodes) == 64
    nodes.append(wf.command_node(wf.NODE_LITERAL | wf.NODE_EXECUTABLE | wf.NODE_REDIRECT, [], name="alias", redirect=1))
    notes.append("node 64: literal \"alias\", executable, redirect 1")
    nodes.append(wf.command_node(wf.NODE_ARGUMENT | wf.NODE_SUGGEST, [], name="who", parser=6, props=wf.ubyte(1), suggestions="minecraft:ask_server"))
    notes.append("node 65: argument \"who\", parser 6 entity flags 0x01, custom suggestions minecraft:ask_server")
    nodes.append(wf.command_node(wf.NODE_LITERAL | wf.NODE_EXECUTABLE | wf.NODE_RESTRICTED, [], name="op_only"))
    notes.append("node 66: literal \"op_only\", executable, restricted")
    fx.field(wf.varint(0x10), "packet id: VarInt 0x10")
    fx.field(wf.varint(len(nodes)), "Nodes: VarInt count %d" % len(nodes))
    for data, text in zip(nodes, notes):
        fx.field(data, text, wrap=24)
    fx.field(wf.varint(0), "Root index: VarInt 0")
    return fx


@fixture("play-c2s-0f-command-suggestion-standard")
def suggestion_request():
    fx = Fixture("play-c2s-0f-command-suggestion-standard", head(
        "Command Suggestion request", "play", "serverbound (C->S)", 0x0F, "05c 0x0F", ["transaction id 300 (two-byte VarInt); text \"/gamemode c\""]))
    fx.field(wf.varint(0x0F), "packet id: VarInt 0x0f")
    fx.field(wf.varint(300), "Transaction id: VarInt 300")
    fx.field(wf.string("/gamemode c", 32500), "Text: String \"/gamemode c\"")
    return fx


@fixture("play-s2c-0f-command-suggestions-standard")
def suggestion_response():
    fx = Fixture("play-s2c-0f-command-suggestions-standard", head(
        "Command Suggestions response", "play", "clientbound (S->C)", 0x0F, "05a 0x0F (SuggestionEntry with optional tooltip)",
        ["transaction id 300; replaced range start 10, length 1; suggestions: \"creative\" (no tooltip), \"c\" with tooltip plain String \"short\""]))
    fx.field(wf.varint(0x0F), "packet id: VarInt 0x0f")
    fx.field(wf.varint(300), "Transaction id: VarInt 300")
    fx.field(wf.varint(10), "Start: VarInt 10")
    fx.field(wf.varint(1), "Length: VarInt 1")
    fx.field(wf.varint(2), "Suggestions: VarInt count 2")
    fx.field(wf.string("creative") + wf.bool1(False), "[0] Text \"creative\", tooltip absent")
    fx.field(wf.string("c") + wf.bool1(True) + text_plain("short"), "[1] Text \"c\", tooltip present: plain String \"short\"")
    return fx


@fixture("play-c2s-07-chat-command-standard")
def chat_command():
    text = "gamemode creative " + "x" * 120 + " Steve"
    fx = Fixture("play-c2s-07-chat-command-standard", head(
        "Chat Command (unsigned)", "play", "serverbound (C->S)", 0x07, "05c 0x07; 09 section 1",
        ["command text of 144 characters (a two-byte length VarInt): \"gamemode creative \" + 120 x \"x\" + \" Steve\""]))
    fx.field(wf.varint(0x07), "packet id: VarInt 0x07")
    fx.field(wf.string(text), "Command: String (VarInt length 144 + UTF-8)", wrap=24)
    return fx


def bound(fx, chat_type_id, sender, target):
    fx.field(wf.varint(chat_type_id + 1), "Chat type: Holder reference VarInt %d (registry id %d + 1)" % (chat_type_id + 1, chat_type_id))
    fx.field(text_plain(sender), "Sender name: TextComponent plain String \"%s\"" % sender)
    if target is None:
        fx.field(wf.bool1(False), "Target name: Optional absent")
    else:
        fx.field(wf.bool1(True) + text_plain(target), "Target name: Optional present, plain String \"%s\"" % target)


@fixture("play-s2c-42-player-chat")
def player_chat():
    fx = Fixture("play-s2c-42-player-chat", head(
        "Player Chat (unsigned), chat type minecraft:chat", "play", "clientbound (S->C)", 0x42,
        "05a 0x42, SignedMessageBodyPacked, FilterMask, ChatTypeBound; 09 section 1 (unsigned chat); chat_type registry order of config-s2c-07-registry-data-chat-type-standard (chat = 0)",
        ["global index 5; sender UUID 00000000-0000-0000-0000-0000000000a1 (Alice); per-sender index 2; no signature; content \"hello\",",
         "timestamp 1700000000000 ms, salt 0, last seen none; unsigned content absent; filter mask PASS_THROUGH;",
         "chat type minecraft:chat (id 0, Holder VarInt 1); sender name plain String \"Alice\"; no target"]))
    fx.field(wf.varint(0x42), "packet id: VarInt 0x42")
    fx.field(wf.varint(5), "Global index: VarInt 5")
    fx.field(wf.uuid("00000000-0000-0000-0000-0000000000a1"), "Sender: UUID")
    fx.field(wf.varint(2), "Index: VarInt 2")
    fx.field(wf.bool1(False), "Signature: Optional absent")
    fx.field(wf.string("hello", 256), "Body.Content: String \"hello\"")
    fx.field(wf.long64(1700000000000), "Body.Timestamp: Long 1700000000000")
    fx.field(wf.long64(0), "Body.Salt: Long 0")
    fx.field(wf.varint(0), "Body.Last seen: Prefixed Array count 0")
    fx.field(wf.bool1(False), "Unsigned content: Optional absent")
    fx.field(wf.varint(0), "Filter mask: VarInt 0 PASS_THROUGH")
    bound(fx, 0, "Alice", None)
    return fx


@fixture("play-s2c-21-disguised-chat-say")
def disguised_say():
    fx = Fixture("play-s2c-21-disguised-chat-say", head(
        "Disguised Chat, chat type minecraft:say_command", "play", "clientbound (S->C)", 0x21,
        "05a 0x21, ChatTypeBound; 16 section 8.1; chat_type ids of config-s2c-07-registry-data-chat-type-standard (say_command = 1)",
        ["message plain String \"restart soon\"; chat type id 1 (Holder VarInt 2); sender name plain String \"Server\"; no target"]))
    fx.field(wf.varint(0x21), "packet id: VarInt 0x21")
    fx.field(text_plain("restart soon"), "Message: TextComponent plain String \"restart soon\"")
    bound(fx, 1, "Server", None)
    return fx


@fixture("play-s2c-21-disguised-chat-msg-incoming")
def disguised_msg():
    fx = Fixture("play-s2c-21-disguised-chat-msg-incoming", head(
        "Disguised Chat, chat type minecraft:msg_command_incoming with a target", "play", "clientbound (S->C)", 0x21,
        "05a 0x21; 16 section 8.3 (msg); chat_type ids (msg_command_incoming = 2)",
        ["message plain String \"psst\"; chat type id 2 (Holder VarInt 3); sender name \"Alice\"; target name \"Bob\" present"]))
    fx.field(wf.varint(0x21), "packet id: VarInt 0x21")
    fx.field(text_plain("psst"), "Message: TextComponent plain String \"psst\"")
    bound(fx, 2, "Alice", "Bob")
    return fx
