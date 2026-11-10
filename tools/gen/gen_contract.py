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


# op name -> (owner package, template)
OPS = {
    "decode-core-chat": ("core", op_decode_core_chat),
    "build-core-chat-line": ("core", op_build_core_chat_line),
    "build-client-chat": ("client", op_build_client_chat),
    "build-client-chat-command": ("client", op_build_client_chat_command),
    "history-client": ("client", op_history_client),
}

CORE_HEAD = """\
 IDENTIFICATION DIVISION.
 PROGRAM-ID. {program}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
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
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
"""
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


def program_name(seam, owner):
    return "contract_%s_%s" % (seam.name.replace("-", "_"), owner)


def generate(seam):
    """{path relative to the output root: source text} of the seam's generated test programs."""
    by_owner = collections.OrderedDict()
    for row in seam.rows:
        if row.op not in OPS:
            raise Problem("row %s (line %d): unknown op %s" % (row.id, row.line, row.op))
        owner, template = OPS[row.op]
        if owner != row.owner:
            raise Problem("row %s (line %d): op %s belongs to the %s package" % (row.id, row.line, row.op, owner))
        by_owner.setdefault(owner, []).extend(template(seam, row))
    out = {}
    for owner, lines in by_owner.items():
        name = program_name(seam, owner)
        head, tail = TEMPLATES[owner]
        text = "*> GENERATED by tools/gen/gen_contract.py from %s; do not edit.\n" % os.path.relpath(seam.source, REPO)
        text += head.format(program=name.upper().replace("_", "-")) + "\n".join(lines) + "\n"
        text += tail.format(program=name.upper().replace("_", "-"))
        out["%s/tests/%s.cob" % (owner, name)] = text
    return out


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
            for r in seam.rows if call_site(repo, r.caller, r.entry) is None]


def check_fixtures(seam, repo=REPO):
    return ["%s: row %s names missing fixture %s" % (seam.name, r.id, fixture_path(f))
            for r in seam.rows for f in r.fixtures if not os.path.isfile(os.path.join(repo, fixture_path(f)))]


def manifest(seams, repo=REPO):
    lines = ["seam\tentry\towner\tcaller\tcall site\n"]
    for seam in seams:
        for row in seam.rows:
            lines.append("%s\t%s\t%s\t%s\t%s\n" % (seam.name, row.entry, row.owner, row.caller, call_site(repo, row.caller, row.entry) or "MISSING"))
    return "".join(lines)


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
        if arguments.check:
            for seam in seams:
                generate(seam)
            problems = [p for seam in seams for p in check_fixtures(seam) + check_wiring(seam)]
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
