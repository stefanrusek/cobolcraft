#!/usr/bin/env python3
"""Reads the node listings of docs/protocol/57-client-closures-4-command-tree.md section 7 and writes the fixture
core/tests/fixtures/command-tree-57-4.txt: one line per node, depth first, "<depth> <node text>", for the unfiltered
dedicated tree (all levels), the roots in the order of section 6.1 (the order of the document's headings, with the aliases
at their section 6.1 positions), `{Tn}` and `{=Tn}` expanded, the gamerule listing built from its table.

It also writes the Commands packets of the levels 2, 3 and 4 of a dedicated server and the retired stand-in names (everyone = level 0, operator = level 4)
as wire fixtures under contract/fixtures/wire/, encoded independently of the core from the listings alone (the structural equality of 2.2, the numbering of 4.4,
the flags of 2.1, the properties of 2.1).

It also writes core/copy/BRDOC.cpy (the same lines, every command but gamerule and the aliases) for BR-DOC-FILL
(core/src/cmd-tree-doc.cob).

Usage: gen_command_tree.py [doc] [out]   (defaults: the doc of this repository and the fixture next to this script)
Also prints the node count of every command next to the count in its heading.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
DOC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "docs/protocol/57-client-closures-4-command-tree.md")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "command-tree-57-4.txt")

text = open(DOC, encoding="utf-8").read()


def parse_block(block):
    """Lines of one listing to a forest of [text, children]; {Tn} and {=Tn} expanded."""
    roots = []
    stack = []  # (indent, node)
    labels = {}
    pending = []  # (node, label) of {=Tn}
    for raw in block.split("\n"):
        if not raw.strip():
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        line = raw.strip()
        label = None
        same = None
        m = re.search(r"\s+\{(=?)T(\d+)\}$", line)
        if m:
            line = line[: m.start()].rstrip()
            if m.group(1):
                same = m.group(2)
            else:
                label = m.group(2)
        node = [canon(line), []]
        while stack and stack[-1][0] >= indent:
            stack.pop()
        if stack:
            stack[-1][1][1].append(node)
        else:
            roots.append(node)
        stack.append((indent, node))
        if label:
            labels[label] = node
        if same:
            pending.append((node, same))
    for node, same in pending:
        node[1].extend(copy_nodes(labels[same][1]))
    return roots


def canon(line):
    """name, then the marks in a fixed order: x, R<n>, ->/path, sug=<name>."""
    tokens = line.split(" ")
    head, rest = tokens[0], tokens[1:]
    marks = []
    for want in (lambda t: t == "x", lambda t: re.match(r"R\d$", t), lambda t: t.startswith("->/"), lambda t: t.startswith("sug=")):
        marks += [t for t in rest if want(t)]
    assert sorted(marks) == sorted(rest), line
    return " ".join([head] + marks)


def copy_nodes(nodes):
    return [[n[0], copy_nodes(n[1])] for n in nodes]


def count(nodes):
    return sum(1 + count(n[1]) for n in nodes)


sections = {}
order = []
for m in re.finditer(r"^### 7\.(\d+) `([^`]+)` \(level (\d), (\d+) tree nodes?(?:, \d+ wire nodes)?\)\n(.*?)(?=^### |^---|\Z)", text, re.S | re.M):
    num, name, level, nodes, body = m.groups()
    if name == "gamerule":
        rules = []
        for r in re.finditer(r"^\| `([a-z_]+)` \| (bool#0|integer#3(?:\(([^)]*)\))?) \| (yes|no) \|$", body, re.M):
            rid, arg, props, feature = r.groups()
            rules.append((rid, arg, props, feature))
        root = ["gamerule R2", []]
        for rid, arg, props, feature in rules:
            if feature == "yes":
                continue  # needs the feature minecart_improvements (section 4.6): not in the default tree
            for nm in (rid, "minecraft:" + rid):
                a = "<value:bool#0> x" if arg.startswith("bool") else "<value:integer#3(%s)> x" % props
                lit = [nm + " x", [[a, []]]]
                root[1].append(lit)
        forest = [root]
    else:
        code = re.search(r"```\n(.*?)```", body, re.S)
        forest = parse_block(code.group(1))
        if name == "locate":
            # Deviation from the listing (lane buglocate3, operator report): /locate structure completes structure ids and tags through
            # the ask_server provider, which the Commands packet marks on its argument node (the listing has no provider there).
            arg = forest[0][1][0][1][0]
            assert arg[0].startswith("<structure:") and "sug=" not in arg[0]
            arg[0] += " sug=ask"
    order.append(name)
    sections[name] = (int(level), int(nodes), forest)

aliases = []
am = re.search(r"### 7\.88 Alias nodes.*?```\n(.*?)```", text, re.S)
for line in am.group(1).split("\n"):
    if line.strip():
        aliases.append(line.strip())

# section 6.1 order of the root literals (indices 1 to 91)
rows = re.findall(r"^\| (\d+) \| `([^`]+)`( \(alias of `[^`]+`\))? \|", text, re.M)
root_order = []
for r in rows:
    if int(r[0]) != len(root_order) + 1:
        break
    root_order.append(r[1])
assert len(root_order) == 91, len(root_order)

lines = []
doc_lines = []


def emit(nodes, depth):
    for n in nodes:
        lines.append("%d %s" % (depth, n[0]))
        if not doc_skip:
            doc_lines.append("%2d %s" % (depth, n[0]))
        emit(n[1], depth + 1)


bad = 0
doc_skip = False
for name in root_order:
    doc_skip = name == "gamerule"
    if name in sections:
        level, nodes, forest = sections[name]
        got = count(forest)
        if got != nodes:
            print("COUNT %s heading %d parsed %d" % (name, nodes, got), file=sys.stderr)
            bad += 1
        emit(forest, 0)
    else:
        al = [a for a in aliases if a.split(" ")[0] == name]
        if not al:
            print("MISSING %s" % name, file=sys.stderr)
            bad += 1
        else:
            lines.append("0 " + canon(al[0]))

with open(OUT, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

BRDOC = os.path.join(ROOT, "core", "copy", "BRDOC.cpy")
with open(BRDOC, "w", encoding="utf-8") as f:
    f.write("*> The node listings of docs/protocol/57-client-closures-4-command-tree.md section 7 (every command but gamerule and the aliases), one row per node, depth first:\n")
    f.write("*> the depth in two digits, a space, then the document's notation (the name or <name:parser#id(properties)>, then x, R<n>, ->/target, sug=<provider>).\n")
    f.write("*> Generated by core/tests/fixtures/gen_command_tree.py: do not edit. Read by BR-DOC-FILL (core/src/cmd-tree-doc.cob).\n")
    f.write(" 78 BRDOC-ROWS             VALUE %d.\n" % len(doc_lines))
    f.write(" 01 BRDOC-DATA.\n")
    for l in doc_lines:
        assert '"' not in l and len(l) <= 84, l
        f.write('    05 FILLER              PIC X(84) VALUE "%s".\n' % l)
    f.write(" 01 BRDOC-TABLE REDEFINES BRDOC-DATA.\n")
    f.write("    05 BRDOC-ROW            PIC X(84) OCCURS %d TIMES.\n" % len(doc_lines))
# ---- the Commands packets (57-4 sections 2, 4 and 10) -------------------------------------------------------------------------------------------------------
import struct

NUMBER = {1: "f", 2: "d", 3: "i", 4: "q"}
EXTREME = {1: (-3.4028234663852886e38, 3.4028234663852886e38), 2: (-1.7976931348623157e308, 1.7976931348623157e308),
           3: (-2147483648, 2147483647), 4: (-9223372036854775808, 9223372036854775807)}


class N:
    """A node of the unfiltered tree: kind 1 literal / 2 argument, name, parser id and properties of an argument, marks."""

    def __init__(self, text):
        t = text.split(" ")
        head, self.marks = t[0], t[1:]
        self.kids = []
        self.level = 0
        self.exec = "x" in self.marks
        self.redirect = None
        self.sug = None
        for m in self.marks:
            if re.match(r"R\d$", m):
                self.level = int(m[1])
            elif m.startswith("->/"):
                self.redirect = m[3:]
            elif m.startswith("sug="):
                self.sug = m[4:]
        m = re.match(r"^<([^:<>]+):[a-z_0-9]+#(\d+)(?:\((.*)\))?>$", head)
        if m:
            self.kind = 2
            self.name = m.group(1)
            self.parser = int(m.group(2))
            self.props = m.group(3) or ""
        else:
            self.kind = 1
            self.name = head
            self.parser = -1
            self.props = ""

    def prop_bytes(self):
        p, props = self.parser, self.props
        items = props.split(",") if props else []
        if p in NUMBER:
            lo = hi = None
            for it in items:
                if it.startswith("min="):
                    lo = it[4:]
                elif it.startswith("max="):
                    hi = it[4:]
            conv = float if p in (1, 2) else int
            lo = conv(lo) if lo is not None else None
            hi = conv(hi) if hi is not None else None
            out = bytes([(1 if lo is not None else 0) + (2 if hi is not None else 0)])
            for v in (lo, hi):
                if v is not None:
                    out += struct.pack(">" + NUMBER[p], v)
            return out
        if p == 5:
            return varint({"word": 0, "phrase": 1, "greedy": 2}[props])
        if p == 6:
            return bytes([(1 if "single" in items else 0) + (2 if "players" in items else 0)])
        if p == 31:
            return bytes([1 if "multiple" in items else 0])
        if p == 43:
            return struct.pack(">i", int(items[0][4:]))
        if 44 <= p <= 48:
            return varint(len(props)) + props.encode()
        return b""


def varint(v):
    out = b""
    v &= 0xFFFFFFFF
    while True:
        if v < 0x80:
            return out + bytes([v])
        out += bytes([(v & 0x7F) | 0x80])
        v >>= 7


def string(s):
    b = s.encode()
    return varint(len(b)) + b


def build_forest(order_names):
    roots = []
    for name in order_names:
        if name in sections:
            forest = sections[name][2]
            roots.append(make(forest[0]))
        else:
            al = [a for a in aliases if a.split(" ")[0] == name][0]
            roots.append(make([canon(al), []]))
    return roots


def make(tree):
    n = N(tree[0])
    n.kids = [make(k) for k in tree[1]]
    return n


def gamerule_full(root):
    return root


def encode(level, roots, feature_gamerule=False):
    """The Commands packet payload (after the packet id) for a source of the permission level."""
    # the filtered copy: a node whose own level is held, in depth first order; redirects kept to nodes copied earlier
    root = N("root")
    root.kind = 0
    root.kids = roots
    copied = []
    def walk(n):
        for c in n.kids:
            if c.level <= level:
                c.copy_index = len(copied)
                copied.append(c)
                walk(c)
    for n in [root]:
        walk(n)
    include = set(id(c) for c in copied) | {id(root)}
    by_name = {c.name: c for c in roots}
    def kept_redirect(c):
        if c.redirect is None:
            return None
        if c.redirect == "":
            return root
        t = by_name.get(c.redirect)
        if t is not None and id(t) in include and t.copy_index < c.copy_index:
            return t
        return None
    root.copy_index = -1
    def visible_kids(n):
        return [c for c in n.kids if id(c) in include]
    cache = {}
    def klass(n):
        """A key equal for nodes that 2.2 merges, else a key of the node alone."""
        if id(n) in cache:
            return cache[id(n)]
        kids = tuple(sorted(klass(c) for c in visible_kids(n)))
        mergeable = (not n.exec) and (n.kind == 1 or (n.kind == 2 and n.parser in NUMBER))
        if mergeable:
            key = ("m", n.kind, n.name, n.parser, n.props, kids)
        else:
            key = ("u", id(n))
        cache[id(n)] = key
        return key
    index = {}
    order = []
    queue = [root]
    head = 0
    while head < len(queue):
        n = queue[head]
        head += 1
        k = klass(n)
        if k in index:
            continue
        index[k] = len(order)
        order.append(n)
        queue.extend(visible_kids(n))
        r = kept_redirect(n)
        if r is not None:
            queue.append(r)
    out = varint(len(order))
    for n in order:
        flags = n.kind
        if n.exec:
            flags += 4
        r = kept_redirect(n)
        if r is not None:
            flags += 8
        if n.sug and n.kind == 2:
            flags += 16
        if n.kind and n.level > 0:
            flags += 32
        out += bytes([flags])
        kids = visible_kids(n)
        out += varint(len(kids)) + b"".join(varint(index[klass(c)]) for c in kids)
        if r is not None:
            out += varint(index[klass(r)])
        if n.kind == 1:
            out += string(n.name)
        elif n.kind == 2:
            out += string(n.name) + varint(n.parser) + n.prop_bytes()
            if n.sug:
                out += string("minecraft:" + {"ask": "ask_server"}.get(n.sug, n.sug))
    out += varint(0)
    return out, len(order), order, (lambda n: index[klass(n)]), kept_redirect


def write_fixture(path, title, level, payload, count, extra):
    lines = ["# Fixture: Commands, %s (%d nodes)" % (title, count),
             "# Phase: play. Direction: clientbound (S->C). Packet id 0x10 (16).",
             "# Doc refs: 57-client-closures-4 sections 2 (layout, merged nodes), 4 (numbering), 5 (counts), 7 (the node listings), 05a 0x10 CommandNode, 15 section 3.",
             "# Stated inputs: the tree of a dedicated server's player with permission level %d: %s" % (level, extra),
             "#   encoded by core/tests/fixtures/gen_command_tree.py from the listings of section 7 alone (equal nodes of 2.2 merged, breadth first numbering of 4.4); not captured.",
             "",
             "10                                               # packet id: VarInt 0x10"]
    for i in range(0, len(payload), 16):
        lines.append(" ".join("%02x" % b for b in payload[i:i + 16]))
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


WIRE = os.path.join(ROOT, "contract", "fixtures", "wire")
all_roots = build_forest(root_order)
for level, names, extra in [(0, ["play-s2c-10-commands-everyone"], "the 26 nodes of 10.1 (the retired name of the profile 09 table)"),
                            (2, ["play-s2c-10-commands-level2-dedicated"], "the 2333 nodes of 5.1"),
                            (3, ["play-s2c-10-commands-level3-dedicated"], "the 2385 nodes of 5.1"),
                            (4, ["play-s2c-10-commands-operator"], "the 2396 nodes of 5.1 (the retired name of the profile 09 table)")]:
    payload, count = encode(level, all_roots)[:2]
    print("level %d: %d nodes, %d bytes" % (level, count, len(payload)))
    write_fixture(os.path.join(WIRE, names[0] + ".hex"), "level %d, dedicated server" % level, level, payload, count, extra)

print("%d lines, %d problems" % (len(lines), bad))
