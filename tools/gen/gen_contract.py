#!/usr/bin/env python3
"""Contract case generator, wiring check and seam selection (contract/cases/README.md).

usage: gen_contract.py --write [--out DIR]       generate the test programs and the wiring manifest into DIR
                                                 (default build/gen); exit 1 on a bad table
       gen_contract.py --check                   table and fixtures are valid, and every entry has a
                                                 CALL "<entry>" in its caller package's src/ (exit 1 naming each)
       gen_contract.py --only-args [PREFIX]      the `--only` arguments of tools/runtests.py that run the
                                                 generated programs of the seams named PREFIX* (default all)
       gen_contract.py --affected [PATH ...]     the seams whose `# paths:` match the paths (default: the
                                                 paths git reports changed against --base, default HEAD,
                                                 plus untracked files), one name per line

One table per seam, contract/cases/<seam>.tsv. Each row yields cases in the generated program of its owner
package: build/gen/<owner>/tests/contract_<seam with - as _>_<owner>.cob, built and run like any contract
test by tools/runtests.py (the generated sources are excluded from coverage, constitution 4.2). Expected
values are the table's, which come from docs/protocol and contract/fixtures, never from running the code
under test (Principle II). Test infrastructure, stdlib only.
"""
import argparse
import collections
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CASES = os.path.join(REPO, "contract", "cases")
FIXTURES = "contract/fixtures/wire"
COLUMNS = ["id", "op", "entry", "owner", "caller", "fixtures", "inputs", "expected"]
PACKAGES = ["core", "client", "server", "proto", "content"]

Row = collections.namedtuple("Row", COLUMNS + ["line"])
Seam = collections.namedtuple("Seam", "name paths rows source")


class Problem(Exception):
    pass


def read_table(path):
    """The Seam of one case table file."""
    name = None
    paths = []
    rows = []
    with open(path, encoding="utf-8") as handle:
        for number, text in enumerate(handle.read().split("\n"), 1):
            if text.startswith("# seam:"):
                name = text[len("# seam:"):].strip()
                continue
            if text.startswith("# paths:"):
                paths = text[len("# paths:"):].split()
                continue
            if text.startswith("#") or not text.strip():
                continue
            cells = text.split("\t")
            if len(cells) != len(COLUMNS):
                raise Problem("%s line %d: %d columns, expected %d (%s)" % (path, number, len(cells), len(COLUMNS), ", ".join(COLUMNS)))
            values = dict(zip(COLUMNS, cells))
            inputs = {}
            for part in [p for p in values["inputs"].split(";") if p]:
                key, equals, value = part.partition("=")
                if not equals:
                    raise Problem("%s line %d: input %r is not name=value" % (path, number, part))
                inputs[key] = value
            values["inputs"] = inputs
            values["fixtures"] = [f for f in values["fixtures"].split(",") if f]
            if values["owner"] not in PACKAGES or values["caller"] not in PACKAGES:
                raise Problem("%s line %d: owner and caller must be one of %s" % (path, number, " ".join(PACKAGES)))
            for cell in [values["id"], values["entry"], values["expected"]] + list(inputs.values()):
                if '"' in cell:
                    raise Problem("%s line %d: a double quote in %r" % (path, number, cell))
            rows.append(Row(line=number, **values))
    if not name:
        raise Problem("%s: no `# seam:` line" % path)
    ids = [r.id for r in rows]
    for duplicate in sorted({i for i in ids if ids.count(i) > 1}):
        raise Problem("%s: duplicate id %s" % (path, duplicate))
    return Seam(name, paths, rows, path)


def read_tables(directory=CASES):
    if not os.path.isdir(directory):
        return []
    return [read_table(os.path.join(directory, n)) for n in sorted(os.listdir(directory)) if n.endswith(".tsv")]


# ---------------------------------------------------------------- COBOL templates

def fixture_path(name):
    return "%s/%s.hex" % (FIXTURES, name)


def literal(text):
    return '"%s"' % text


def case_name(seam, row):
    return literal("contract %s %s: %s %s" % (seam.name, row.id, row.entry, row.op))


def need(row, *names):
    for key in names:
        if key not in row.inputs:
            raise Problem("row %s (line %d): op %s needs input %s" % (row.id, row.line, row.op, key))


def same_as_fixture(row):
    if len(row.fixtures) != 1:
        raise Problem("row %s (line %d): op %s needs exactly one fixture" % (row.id, row.line, row.op))
    return [
        "     MOVE %s TO WS-PATH" % literal(fixture_path(row.fixtures[0])),
        "     CALL \"TEST-SAME-AS-FIXTURE\" USING PB-BUFFER WS-PATH TESTLIB-ASSERT",
    ]


def op_decode_core_chat(seam, row):
    """Serverbound Chat decodes with PLAY-DECODE: `<id> <outcome> message <text> length <n>`."""
    if len(row.fixtures) != 1 or not row.expected:
        raise Problem("row %s (line %d): op %s needs one fixture and an expected text" % (row.id, row.line, row.op))
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %s TO WS-PATH" % literal(fixture_path(row.fixtures[0])),
        "     CALL \"TEST-LOAD-HEX\" USING WS-PATH PB-BUFFER",
        "     CALL \"PB-GET-VARINT\" USING PB-BUFFER WS-PACKET-ID",
        "     CALL \"PLAY-DECODE\" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME",
        "     MOVE SPACES TO TL-OBSERVED",
        "     MOVE 1 TO WS-PTR",
        "     MOVE WS-PACKET-ID TO WS-EDIT",
        "     MOVE WS-OUTCOME TO WS-EDIT2",
        "     STRING FUNCTION TRIM(WS-EDIT) \" \" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE",
        "         INTO TL-OBSERVED POINTER WS-PTR",
        "     MOVE PSB-MESSAGE-LENGTH TO WS-EDIT",
        "     STRING \" message \" PSB-MESSAGE(1:FUNCTION MAX(PSB-MESSAGE-LENGTH, 1)) \" length \"",
        "         FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR",
        "     MOVE %s TO TL-EXPECTED" % literal(row.expected),
        "     CALL \"TEST-ASSERT\" USING TESTLIB-ASSERT",
    ]


def op_build_core_chat_line(seam, row):
    """CHAT-LINE-BUILD of (name, message) equals the fixture's bytes."""
    need(row, "name", "message")
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %s TO WS-NAME" % literal(row.inputs["name"]),
        "     MOVE %d TO WS-NAME-LENGTH" % len(row.inputs["name"]),
        "     MOVE %s TO WS-MESSAGE" % literal(row.inputs["message"]),
        "     MOVE %d TO WS-MESSAGE-LENGTH" % len(row.inputs["message"]),
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"CHAT-LINE-BUILD\" USING WS-NAME WS-NAME-LENGTH WS-MESSAGE WS-MESSAGE-LENGTH PB-BUFFER",
    ] + same_as_fixture(row)


def op_build_client_chat(seam, row):
    """CLP-CHAT of (text, timestamp) equals the fixture's bytes."""
    need(row, "text", "time")
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %s TO WS-TEXT" % literal(row.inputs["text"]),
        "     MOVE %d TO WS-TEXT-LENGTH" % len(row.inputs["text"]),
        "     MOVE %d TO WS-TIME" % int(row.inputs["time"]),
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"CLP-CHAT\" USING PB-BUFFER WS-TEXT WS-TEXT-LENGTH WS-TIME",
    ] + same_as_fixture(row)


def op_build_client_chat_command(seam, row):
    """CLP-CHAT-COMMAND of the command (no leading slash) equals the fixture's bytes."""
    need(row, "command")
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %s TO WS-TEXT" % literal(row.inputs["command"]),
        "     MOVE %d TO WS-TEXT-LENGTH" % len(row.inputs["command"]),
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"CLP-CHAT-COMMAND\" USING PB-BUFFER WS-TEXT WS-TEXT-LENGTH",
    ] + same_as_fixture(row)


def op_history_client(seam, row):
    """The clientbound fixtures fed to the client's PROTO-PACKET, in order, leave the chat history `|text|text`."""
    if not row.fixtures or not row.expected:
        raise Problem("row %s (line %d): op %s needs fixtures and an expected text" % (row.id, row.line, row.op))
    lines = []
    for name in row.fixtures:
        lines.append("     MOVE %s TO WS-PATH" % literal(fixture_path(name)))
        lines.append("     CALL \"TEST-FEED\" USING CLIENT-STATE WS-CONN WS-PATH")
    lines += [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE \"T\" TO TL-MODE",
        "     MOVE SPACES TO TL-OBSERVED",
        "     MOVE 1 TO WS-INDEX",
        "     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CH-COUNT",
        "         MOVE CH-LENGTH(WS-I) TO WS-COUNT",
        "         STRING \"|\" CH-TEXT(WS-I)(1:WS-COUNT) DELIMITED BY SIZE INTO TL-OBSERVED",
        "             WITH POINTER WS-INDEX",
        "     END-PERFORM",
        "     MOVE %s TO TL-EXPECTED" % literal(row.expected),
        "     CALL \"TEST-ASSERT\" USING TESTLIB-ASSERT",
    ]
    return lines


# ---------------------------------------------------------------- core world ops (play to core hooks, core to proto)

def number_input(row, key):
    need(row, key)
    try:
        return int(row.inputs[key])
    except ValueError:
        raise Problem("row %s (line %d): input %s is not an integer" % (row.id, row.line, key))


def known_divergence(row):
    return row.id.startswith("!")


def clean_id(row):
    return row.id.lstrip("!")


def world_case_name(seam, row):
    mark = " [known divergence from the docs]" if known_divergence(row) else ""
    return literal("contract %s %s: %s %s%s" % (seam.name, clean_id(row), row.entry, row.op, mark))


def assert_text(seam, row):
    """Compare TL-OBSERVED with the row's expected text. A row whose id starts with `!` records a documented
    behaviour the code does not have yet: it passes while the code differs and fails (naming the row) as soon
    as the code matches the docs, so the mark is removed then (like a strict expected failure)."""
    lines = ['     MOVE "T" TO TL-MODE', "     MOVE %s TO TL-EXPECTED" % literal(row.expected)]
    if not known_divergence(row):
        return lines + ["     CALL \"TEST-ASSERT\" USING TESTLIB-ASSERT"]
    return lines + [
        "     IF TL-OBSERVED = TL-EXPECTED",
        "         MOVE \"known divergence still present: remove the ! mark of the row\" TO TL-EXPECTED",
        "         MOVE \"the code now matches the documented value\" TO TL-OBSERVED",
        "     ELSE",
        "         DISPLAY \"DIVERGENCE %s documented=\" FUNCTION TRIM(TL-EXPECTED) \" code=\" FUNCTION TRIM(TL-OBSERVED)" % clean_id(row),
        "         MOVE \"known divergence\" TO TL-EXPECTED",
        "         MOVE \"known divergence\" TO TL-OBSERVED",
        "     END-IF",
        "     CALL \"TEST-ASSERT\" USING TESTLIB-ASSERT",
    ]


def drain_blocks(seam, row):
    """Drain the player's connection into TL-OBSERVED (whole text, or the last packet with observe=last)."""
    lines = [
        "     MOVE SPACES TO WS-TEXT",
        "     CALL \"TEST-DRAIN-BLOCKS\" USING WS-CONN WS-TEXT",
    ]
    if row.inputs.get("observe", "all") == "last":
        lines += [
            "     MOVE SPACES TO WS-LAST",
            "     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING))",
            "     MOVE 1 TO WS-PTR",
            "     PERFORM UNTIL WS-PTR > WS-LEN",
            "         UNSTRING WS-TEXT DELIMITED BY SPACE INTO WS-LAST WITH POINTER WS-PTR",
            "     END-PERFORM",
            "     MOVE WS-LAST TO TL-OBSERVED",
        ]
    else:
        lines.append("     MOVE FUNCTION TRIM(WS-TEXT TRAILING) TO TL-OBSERVED")
    return lines


def set_position(row):
    return [
        "     MOVE %d TO WS-X" % number_input(row, "x"),
        "     MOVE %d TO WS-Y" % number_input(row, "y"),
        "     MOVE %d TO WS-Z" % number_input(row, "z"),
    ]


def op_core_use_on(seam, row):
    """Use Item On (BLOCK-USE-ON through the core's packet feed) with a held item; what the player is sent."""
    need(row, "item", "face", "seq")
    return [
        "     MOVE %s TO TL-CASE" % world_case_name(seam, row),
        "     MOVE %d TO PL-SLOT-ITEM(WS-ROW, 1)" % number_input(row, "item"),
        "     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)",
    ] + set_position(row) + [
        "     MOVE %d TO WS-FACE" % number_input(row, "face"),
        "     MOVE %d TO WS-SEQ" % number_input(row, "seq"),
        "     CALL \"TEST-USE-ON\" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ",
    ] + drain_blocks(seam, row) + assert_text(seam, row)


def op_core_action(seam, row):
    """Player Action (BLOCK-ACTION), after optionally setting a block with `setblock`; what the player is sent."""
    need(row, "action", "face", "seq")
    lines = ["     MOVE %s TO TL-CASE" % world_case_name(seam, row)] + set_position(row)
    if "setblock" in row.inputs:
        lines += ["     MOVE %d TO WS-STATE" % number_input(row, "setblock"),
                  "     CALL \"WORLD-SET-BLOCK\" USING WS-DIM WS-X WS-Y WS-Z WS-STATE"]
    return lines + [
        "     MOVE %d TO WS-ACTION" % number_input(row, "action"),
        "     MOVE %d TO WS-FACE" % number_input(row, "face"),
        "     MOVE %d TO WS-SEQ" % number_input(row, "seq"),
        "     CALL \"TEST-ACTION\" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ",
    ] + drain_blocks(seam, row) + assert_text(seam, row)


def op_core_block_change(seam, row):
    """BLOCK-CHANGE called directly (the hook every core system uses); what a viewer is sent."""
    need(row, "state")
    return [
        "     MOVE %s TO TL-CASE" % world_case_name(seam, row),
    ] + set_position(row) + [
        "     MOVE %d TO WS-STATE" % number_input(row, "state"),
        "     CALL \"BLOCK-CHANGE\" USING WS-DIM WS-X WS-Y WS-Z WS-STATE",
    ] + drain_blocks(seam, row) + assert_text(seam, row)


def op_build_core_set_health(seam, row):
    """SET-HEALTH-BUILD of (health, food, saturation) equals the fixture's bytes."""
    need(row, "health", "food", "saturation")
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %s TO WS-HEALTH" % row.inputs["health"],
        "     MOVE %d TO WS-FOOD" % number_input(row, "food"),
        "     MOVE %s TO WS-SATURATION" % row.inputs["saturation"],
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"SET-HEALTH-BUILD\" USING WS-HEALTH WS-FOOD WS-SATURATION PB-BUFFER",
    ] + same_as_fixture(row)


def op_build_proto_mob_effect(seam, row):
    """Update Mob Effect: the packet id, then PB-PUT-UPDATE-MOB-EFFECT of (entity, effect, amplifier, duration, flags)."""
    need(row, "entity", "effect", "amplifier", "duration", "flags")
    lines = [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %d TO WS-PACKET-ID" % number_input(row, "packet"),
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"PB-PUT-VARINT\" USING PB-BUFFER WS-PACKET-ID",
    ]
    for key, field in [("entity", "WS-ENTITY"), ("effect", "WS-EFFECT"), ("amplifier", "WS-AMPLIFIER"),
                       ("duration", "WS-DURATION"), ("flags", "WS-FLAGS")]:
        lines.append("     MOVE %d TO %s" % (number_input(row, key), field))
    lines.append("     CALL \"PB-PUT-UPDATE-MOB-EFFECT\" USING PB-BUFFER WS-ENTITY WS-EFFECT WS-AMPLIFIER WS-DURATION WS-FLAGS")
    return lines + same_as_fixture(row)


def op_build_core_recipe_book_empty(seam, row):
    """RECBOOK-BUILD (replace) of a player who knows no recipe equals the fixture's bytes."""
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     INITIALIZE PL-ENTRY(WS-ROW)",
        "     CALL \"RECBOOK-RESET\" USING WS-ROW",
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     MOVE 1 TO WS-REPLACE",
        "     CALL \"RECBOOK-BUILD\" USING WS-ROW WS-REPLACE PB-BUFFER WS-TOTAL",
    ] + same_as_fixture(row)


def op_build_core_chunk(seam, row):
    """CHUNK-PACKET-BUILD of the chunk (cx, cz) of the dimension row equals the fixture's bytes."""
    need(row, "dim", "cx", "cz")
    return [
        "     MOVE %s TO TL-CASE" % case_name(seam, row),
        "     MOVE %d TO WS-DIM" % number_input(row, "dim"),
        "     MOVE %d TO WS-CX" % number_input(row, "cx"),
        "     MOVE %d TO WS-CZ" % number_input(row, "cz"),
        "     CALL \"PB-RESET\" USING PB-BUFFER",
        "     CALL \"CHUNK-PACKET-BUILD\" USING WS-DIM WS-CX WS-CZ PB-BUFFER",
    ] + same_as_fixture(row)


# op name -> (owner package, template)
OPS = {
    "decode-core-chat": ("core", op_decode_core_chat),
    "build-core-chat-line": ("core", op_build_core_chat_line),
    "build-client-chat": ("client", op_build_client_chat),
    "build-client-chat-command": ("client", op_build_client_chat_command),
    "history-client": ("client", op_history_client),
    "copy-size": ("proto", None),
    "build-core-recipe-book-empty": ("core", op_build_core_recipe_book_empty),
    "core-use-on": ("core", op_core_use_on),
    "core-action": ("core", op_core_action),
    "core-block-change": ("core", op_core_block_change),
    "build-core-set-health": ("core", op_build_core_set_health),
    "build-proto-mob-effect": ("core", op_build_proto_mob_effect),
    "build-core-chunk": ("core", op_build_core_chunk),
}
# Ops that need an opened world and a joined player (the "world" head of the core program).
WORLD_OPS = {"core-use-on", "core-action", "core-block-change", "build-core-chunk", "build-core-recipe-book-empty"}

CORE_HEAD = """\
 IDENTIFICATION DIVISION.
 PROGRAM-ID. {program}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PLAYPKT.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-MESSAGE             PIC X(768).
 01 WS-MESSAGE-LENGTH      BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-FOOD                BINARY-LONG.
 01 WS-SATURATION          FLOAT-SHORT.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-AMPLIFIER           BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LAST                PIC X(64).
 PROCEDURE DIVISION.
{open_world}     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
{join}"""
CORE_TAIL = """\
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 END PROGRAM {program}.

 COPY CORETEST.
"""
CLIENT_HEAD = """\
 IDENTIFICATION DIVISION.
 PROGRAM-ID. {program}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256).
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
"""
CLIENT_TAIL = """\
     STOP RUN.
 END PROGRAM {program}.

 COPY CLTEST.
"""
TEMPLATES = {"core": (CORE_HEAD, CORE_TAIL), "client": (CLIENT_HEAD, CLIENT_TAIL)}
OPEN_WORLD = """\
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
"""
JOIN = """\
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
"""


def program_name(seam, owner):
    return "contract_%s_%s" % (seam.name.replace("-", "_"), owner)


def generate(seam):
    """{path relative to the output root: source text} of the seam's generated test programs."""
    by_owner = collections.OrderedDict()
    for row in seam.rows:
        if row.op not in OPS:
            raise Problem("row %s (line %d): unknown op %s" % (row.id, row.line, row.op))
        owner, template = OPS[row.op]
        if template is None:
            continue  # checked statically by --check (copy-size)
        if owner != row.owner:
            raise Problem("row %s (line %d): op %s belongs to the %s package" % (row.id, row.line, row.op, owner))
        by_owner.setdefault(owner, []).extend(template(seam, row))
    world = any(r.op in WORLD_OPS for r in seam.rows)
    out = {}
    for owner, lines in by_owner.items():
        name = program_name(seam, owner)
        head, tail = TEMPLATES[owner]
        text = "*> GENERATED by tools/gen/gen_contract.py from %s; do not edit.\n" % os.path.relpath(seam.source, REPO)
        text += head.format(program=name.upper().replace("_", "-"), open_world=OPEN_WORLD if world and owner == "core" else "",
                            join=JOIN if world and owner == "core" else "") + "\n".join(lines) + "\n"
        text += tail.format(program=name.upper().replace("_", "-"))
        out["%s/tests/%s.cob" % (owner, name)] = text
    return out



# ---------------------------------------------------------------- record sizes

USAGE_BYTES = {"BINARY-LONG": 4, "BINARY-SHORT": 2, "BINARY-DOUBLE": 8, "BINARY-CHAR": 1, "FLOAT-SHORT": 4, "FLOAT-LONG": 8}


def copybook_constants(text):
    return {name: int(value) for name, value in re.findall(r"^\s*78\s+(\S+)\s+VALUE\s+(\d+)\s*\.", text, re.M)}


def record_size(path, record):
    """Bytes of the 01 record of a copybook, summed from the level numbers, PIC and USAGE clauses and OCCURS
    counts (no REDEFINES, SYNC or edited pictures: a record that uses one is rejected with a Problem)."""
    text = "\n".join(line.split("*>")[0] for line in read_text(path).split("\n"))
    constants = copybook_constants(text)
    items = []
    inside = False
    for statement in [x.strip() for x in re.split(r"\.\s*(?:\n|$)", text)]:
        match = re.match(r"(\d+)\s+(\S+)(.*)$", statement, re.S)
        if not match or statement.startswith("78"):
            continue
        level, name, rest = int(match.group(1)), match.group(2), " ".join(match.group(3).split())
        if level == 1:
            inside = name == record
            if inside:
                items = []
        if not inside:
            continue
        if "REDEFINES" in rest or "SYNC" in rest:
            raise Problem("%s: %s uses REDEFINES or SYNC in %s" % (path, record, name))
        occurs = re.search(r"OCCURS\s+(\w+)", rest)
        count = 1
        if occurs:
            count = int(occurs.group(1)) if occurs.group(1).isdigit() else constants[occurs.group(1)]
        size = None
        usage = re.search(r"(BINARY-LONG|BINARY-SHORT|BINARY-DOUBLE|BINARY-CHAR|FLOAT-SHORT|FLOAT-LONG)", rest)
        picture = re.search(r"PIC(?:TURE)?\s+(?:IS\s+)?([9X])(?:\((\d+)\))?", rest)
        if usage:
            size = USAGE_BYTES[usage.group(1)]
        elif picture:
            size = int(picture.group(2) or 1)
        items.append([level, size, count])
    if not items:
        raise Problem("%s: no 01 record %s" % (path, record))
    total = []

    def sum_group(index):
        level, size, count = items[index]
        if size is not None:
            return size * count, index + 1
        inner, nxt = 0, index + 1
        while nxt < len(items) and items[nxt][0] > level:
            part, nxt = sum_group(nxt)
            inner += part
        return inner * count, nxt

    size, _ = sum_group(0)
    return size


def probe_length(repo, record):
    """The length the contract probe expects for `record`, from the `contract <COPYBOOK> <record> length` case."""
    text = read_text(os.path.join(repo, "tools", "probe", "probe_contract.cob"))
    match = re.search(r'contract \w+ %s length" TO TL-CASE\s+MOVE (\d+) TO TL-EXPECTED-N' % re.escape(record), text)
    return int(match.group(1)) if match else None


def check_sizes(seam, repo=REPO):
    """Problems for copy-size rows: the copybook's record size, the row's expected size and the probe's must agree."""
    problems = []
    for row in seam.rows:
        if row.op != "copy-size":
            continue
        try:
            actual = record_size(os.path.join(repo, "contract", "copy", row.inputs.get("copybook", "") + ".cpy"), row.entry)
        except (Problem, OSError, KeyError) as error:
            problems.append("%s: row %s: %s" % (seam.name, row.id, error))
            continue
        if actual != int(row.expected):
            problems.append("%s: row %s: record %s is %d bytes in contract/copy, the row expects %s" % (seam.name, row.id, row.entry, actual, row.expected))
        probe = probe_length(repo, row.entry)
        if probe is not None and probe != int(row.expected):
            problems.append("%s: row %s: the contract probe expects %d bytes for %s, the row %s" % (seam.name, row.id, probe, row.entry, row.expected))
    return problems


# ---------------------------------------------------------------- wiring

def source_files(repo, package):
    root = os.path.join(repo, package, "src")
    for base, _, names in os.walk(root):
        for name in sorted(names):
            if name.endswith(".cob"):
                yield os.path.join(base, name)


def call_site(repo, package, entry):
    """`file:line` of the first CALL "<entry>" in the package's src/, or None. The name is matched whole."""
    needle = 'CALL "%s"' % entry
    for path in sorted(source_files(repo, package)):
        with open(path, encoding="utf-8", errors="replace") as handle:
            for number, text in enumerate(handle, 1):
                code = text.split("*>")[0]
                if needle in code:
                    return "%s:%d" % (os.path.relpath(path, repo), number)
    return None


def check_wiring(seam, repo=REPO):
    """Problems (one string each) for entries without a call site in their caller package."""
    return ["%s: contract entry %s has no CALL \"%s\" in %s/src (caller of row %s)" % (seam.name, r.entry, r.entry, r.caller, r.id)
            for r in seam.rows if r.op != "copy-size" and call_site(repo, r.caller, r.entry) is None]


def check_fixtures(seam, repo=REPO):
    return ["%s: row %s names missing fixture %s" % (seam.name, r.id, fixture_path(f))
            for r in seam.rows for f in r.fixtures if not os.path.isfile(os.path.join(repo, fixture_path(f)))]


def manifest(seams, repo=REPO):
    lines = ["seam\tentry\towner\tcaller\tcall site\n"]
    for seam in seams:
        for row in seam.rows:
            lines.append("%s\t%s\t%s\t%s\t%s\n" % (seam.name, row.entry, row.owner, row.caller,
                         "record in contract/copy" if row.op == "copy-size" else call_site(repo, row.caller, row.entry) or "MISSING"))
    return "".join(lines)



# ---------------------------------------------------------------- unwired report

SRC_PACKAGES = ["shim", "formats", "proto", "content", "extract", "core", "server", "client"]
HOSTS = ["server", "client"]
CONTRACT_DOCS = ["specs/001-cobolcraft-complete/contracts/core-host-api.md", "specs/002-client-polish/contracts/core-host-delta.md"]
UNWIRED = os.path.join(CASES, "unwired.txt")


def read_text(path):
    with open(path, encoding="utf-8", errors="replace") as handle:
        return handle.read()


def src_text(repo, package):
    """{relative path: source text without comments} of the package's src/ COBOL sources."""
    out = {}
    for path in sorted(source_files(repo, package)):
        lines = [line.split("*>")[0] for line in read_text(path).split("\n")]
        out[os.path.relpath(path, repo)] = "\n".join(lines)
    return out


def contract_entries(repo):
    """Entry points the core host contract names: the CORE-* names in the first column of its tables."""
    names = []
    for doc in CONTRACT_DOCS:
        path = os.path.join(repo, doc)
        if os.path.isfile(path):
            for line in read_text(path).split("\n"):
                if line.startswith("| `CORE-"):
                    name = line.split("`")[1]
                    if name.isupper() or "-" in name:
                        names.append(name)
    return list(dict.fromkeys(names))


def ticked_names(repo):
    """Names that a completed task (`- [X]`) of any specs/*/tasks.md mentions."""
    ticked = set()
    specs = os.path.join(repo, "specs")
    for feature in sorted(os.listdir(specs)) if os.path.isdir(specs) else []:
        path = os.path.join(specs, feature, "tasks.md")
        if os.path.isfile(path):
            for line in read_text(path).split("\n"):
                if line.startswith("- [X]") or line.startswith("- [x]"):
                    ticked.update(re.findall(r"[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+", line))
    return ticked


def call_pattern(name):
    return re.compile(r'(CALL\s+(STATIC\s+)?|ENTRY\s+)"%s"' % re.escape(name))


def contract_report(repo=REPO):
    """(entries, strict): each contract entry with the hosts that call it and whether a src defines it; the
    entries that a completed task names and no host calls (errors)."""
    sources = {package: src_text(repo, package) for package in SRC_PACKAGES}
    definitions = "\n".join(text for package in sources for text in sources[package].values())
    entries = []
    for name in contract_entries(repo):
        pattern = call_pattern(name)
        callers = sorted({path.split("/")[0] for package in HOSTS for path, text in sources[package].items() if pattern.search(text)})
        entries.append((name, callers, re.search(r"PROGRAM-ID\.\s+%s\s*\." % re.escape(name), definitions) is not None))
    ticked = ticked_names(repo)
    return entries, [name for name, callers, defined in entries if not callers and name in ticked]


def called_names(text):
    return set(re.findall(r'(?:CALL\s+(?:STATIC\s+)?|ENTRY\s+)"([^"]+)"', text))


def unwired_report(repo=REPO):
    """(entries, strict, programs): contract_report plus the programs of every src/ that no src/ calls (a test may)."""
    entries, strict = contract_report(repo)
    sources = {package: src_text(repo, package) for package in SRC_PACKAGES}
    called = called_names("\n".join(text for package in SRC_PACKAGES for text in sources[package].values()))
    tests = ""
    for package in SRC_PACKAGES:
        directory = os.path.join(repo, package, "tests")
        if os.path.isdir(directory):
            for name in sorted(os.listdir(directory)):
                if name.endswith((".cob", ".cpy")):
                    tests += read_text(os.path.join(directory, name))
    tested = called_names(tests)
    programs = []
    for package in SRC_PACKAGES:
        for path, text in sources[package].items():
            if path.endswith("/main.cob"):
                continue
            for name in re.findall(r"PROGRAM-ID\.\s+([A-Z0-9-]+)\s*\.", text):
                if name not in called:
                    programs.append((package, name, path, "tests only" if name in tested else "no caller"))
    return entries, strict, programs


def format_unwired(report):
    entries, strict, programs = report
    lines = ["# Unwired report (generated by tools/gen/gen_contract.py --unwired; do not edit).",
             "# Library code that nothing calls. Calls are textual: CALL \"NAME\" or ENTRY \"NAME\" in a src/ file; a call through",
             "# a data item or from C is not seen, so a listed program is a candidate to check, not proof.",
             "",
             "## Core host contract entries (core-host-api.md and core-host-delta.md), with the hosts that call them",
             "# ERROR = a completed task (- [X]) names the entry and no host calls it; WARNING = no host calls it"]
    for name, callers, defined in entries:
        if not callers:
            status = "ERROR" if name in strict else "WARNING"
        else:
            status = "ok"
        lines.append("%s\t%s\tcallers: %s%s" % (status, name, ",".join(callers) or "none", "" if defined else "\t(no PROGRAM-ID in any src)"))
    lines += ["", "## Programs no src/ file calls (%d); `tests only` = a test program calls it, `no caller` = nothing does" % len(programs)]
    for package, name, path, kind in sorted(programs):
        lines.append("WARNING\t%s\t%s\t%s\t%s" % (kind, name, package, path))
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------- selection

def affected(seams, changed):
    """Names of the seams whose `# paths:` entries (file or directory prefix) contain a changed path."""
    names = []
    for seam in seams:
        for path in changed:
            if any(path == p or path.startswith(p.rstrip("/") + "/") for p in seam.paths):
                names.append(seam.name)
                break
    return names


def git_changed(base):
    changed = subprocess.run(["git", "diff", "--name-only", base], cwd=REPO, capture_output=True, text=True, check=True).stdout.split()
    untracked = subprocess.run(["git", "ls-files", "--others", "--exclude-standard"], cwd=REPO, capture_output=True, text=True,
                               check=True).stdout.split()
    return changed + untracked


def only_args(seams, prefix):
    args = []
    for seam in seams:
        if seam.name.startswith(prefix):
            for owner in dict.fromkeys(r.owner for r in seam.rows):
                args += ["--only", program_name(seam, owner)]
    return args


# ---------------------------------------------------------------- command line

def write(seams, out):
    for seam in seams:
        for path, text in generate(seam).items():
            target = os.path.join(out, path)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            if os.path.isfile(target) and open(target, encoding="utf-8").read() == text:
                continue  # unchanged: keep the mtime so make does not rebuild the program
            with open(target, "w", encoding="utf-8") as handle:
                handle.write(text)
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "wiring.tsv"), "w", encoding="utf-8") as handle:
        handle.write(manifest(seams))


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--only-args", nargs="?", const="", metavar="PREFIX")
    mode.add_argument("--unwired", nargs="?", const=UNWIRED, metavar="FILE",
                      help="write the unwired report (default contract/cases/unwired.txt); exit 1 when an entry that a completed task names has no host caller")
    mode.add_argument("--affected", action="store_true")
    mode.add_argument("--affected-args", action="store_true", help="like --affected, printing runtests.py --only arguments")
    parser.add_argument("--out", default=os.path.join(REPO, "build", "gen"))
    parser.add_argument("--base", default="HEAD", help="git revision `--affected` diffs against")
    parser.add_argument("paths", nargs="*", help="paths for --affected instead of the git diff")
    arguments = parser.parse_args(argv)
    try:
        seams = read_tables()
        if arguments.write:
            write(seams, os.path.abspath(arguments.out))
            print("generated %d seams into %s" % (len(seams), arguments.out))
            return 0
        if arguments.unwired:
            report = unwired_report()
            with open(arguments.unwired, "w", encoding="utf-8") as handle:
                handle.write(format_unwired(report))
            for name in report[1]:
                print("ERROR contract entry %s is marked done in tasks.md and no host calls it" % name)
            print("unwired: %d contract entries (%d without a host caller), %d programs without a src caller -> %s" % (
                len(report[0]), sum(1 for e in report[0] if not e[1]), len(report[2]), os.path.relpath(arguments.unwired, REPO)))
            return 1 if report[1] else 0
        if arguments.check:
            for seam in seams:
                generate(seam)
            problems = [p for seam in seams for p in check_fixtures(seam) + check_wiring(seam) + check_sizes(seam)]
            problems += ["contract entry %s is marked done in tasks.md and no host calls it" % n for n in contract_report()[1]]
            for problem in problems:
                print("ERROR " + problem)
            print("contract cases: %d seams, %d rows, %d problems" % (len(seams), sum(len(s.rows) for s in seams), len(problems)))
            return 1 if problems else 0
        if arguments.only_args is not None:
            print(" ".join(only_args(seams, arguments.only_args)))
            return 0
        changed = arguments.paths or git_changed(arguments.base)
        names = affected(seams, changed)
        if arguments.affected_args:
            print(" ".join(only_args([s for s in seams if s.name in names], "")))
            return 0
        for name in names:
            print(name)
        return 0
    except Problem as problem:
        print("ERROR " + str(problem))
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
