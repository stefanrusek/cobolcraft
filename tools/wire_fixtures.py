#!/usr/bin/env python3
"""Independent wire encoder and fixture generator (T0059; specs/002-client-polish/contracts/wire-delta.md section 3).
Test infrastructure, stdlib only.

usage: wire_fixtures.py [--out DIR] [--check] [NAME ...]

Writes (or with --check compares) the wire fixtures that are not taken from a worked example of a
document: contract/fixtures/wire/<name>.hex, one packet body per file, packet id first, `#` comments naming
every field (proto-api.md section 3). The encoder below is written from docs/protocol/00, 06, 07 and the
packet documents 05a to 05c only; it shares no code with `proto`, so a fixture is an independent statement
of the bytes. The catalogue of fixtures is the `wire_catalog_*.py` modules next to this file.

Prints `wire_fixtures: wrote <n> files` or, with --check, `wire_fixtures: <n> files, <m> differ` and one
`<name>: missing` or `<name>: differs` line per problem; --check exits 1 when any differs.
"""
import math
import os
import struct
import sys
import uuid as uuidlib

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
WIRE_DIR = os.path.join(REPO, "contract", "fixtures", "wire")

# ----------------------------------------------------------------------------------------------
# Scalars (00 sections 2 to 6)


def _varnum(value, bits, name):
    low, high = -(1 << (bits - 1)), (1 << (bits - 1)) - 1
    if not low <= value <= high:
        raise ValueError("%s out of range: %d" % (name, value))
    value &= (1 << bits) - 1
    out = bytearray()
    while value & ~0x7F:
        out.append((value & 0x7F) | 0x80)
        value >>= 7
    out.append(value)
    return bytes(out)


def varint(value):
    return _varnum(value, 32, "VarInt")


def varlong(value):
    return _varnum(value, 64, "VarLong")


def byte(value):
    return struct.pack(">b", value)


def ubyte(value):
    return struct.pack(">B", value)


def short(value):
    return struct.pack(">h", value)


def ushort(value):
    return struct.pack(">H", value)


def int32(value):
    return struct.pack(">i", value)


def long64(value):
    return struct.pack(">q", value)


def float32(value):
    return struct.pack(">f", value)


def float64(value):
    return struct.pack(">d", value)


def bool1(value):
    return b"\x01" if value else b"\x00"


def string(text, limit=32767):
    if len(text) > limit:
        raise ValueError("string longer than %d" % limit)
    raw = text.encode("utf-8")
    return varint(len(raw)) + raw


def ident(text):
    if ":" not in text:
        raise ValueError("identifier without namespace: %s" % text)
    return string(text)


def uuid(text):
    return uuidlib.UUID(text).bytes


def position(x, y, z):
    """Packed block position (00 section 4.1): X in bits 38 to 63, Z in 12 to 37, Y in 0 to 11."""
    return struct.pack(">Q", ((x & 0x3FFFFFF) << 38) | ((z & 0x3FFFFFF) << 12) | (y & 0xFFF))


def angle(degrees):
    """Angle byte (00 section 4.4): floor(degrees * 256 / 360), kept to 8 bits."""
    return struct.pack(">B", math.floor(degrees * 256 / 360) & 0xFF)


def lpvec3(x, y, z):
    """LpVec3 (00 section 4.6): 1 byte for a zero vector, else 6 bytes (+ VarInt when the scale exceeds 3)."""
    comps = [0.0 if c != c else max(-1.7179869183e10, min(1.7179869183e10, c)) for c in (x, y, z)]
    biggest = max(abs(c) for c in comps)
    if biggest < 3.051944088384301e-5:
        return b"\x00"
    scale = math.ceil(biggest)
    low = scale & 3
    extra = b""
    if scale > 3:
        low |= 4
        extra = varint(scale >> 2)
    packed = low
    for shift, c in zip((3, 18, 33), comps):
        quant = int(math.floor((c / scale * 0.5 + 0.5) * 32766 + 0.5))
        packed |= quant << shift
    return struct.pack("<H", packed & 0xFFFF)[0:1] + struct.pack(">B", (packed >> 8) & 0xFF) + struct.pack(">I", (packed >> 16) & 0xFFFFFFFF) + extra


def _bits_to_bytes(indices, count=None):
    size = (max(indices) // 8 + 1) if indices else 0
    if count is not None:
        size = (count + 7) // 8
    data = bytearray(size)
    for index in indices:
        data[index // 8] |= 1 << (index % 8)
    return bytes(data)


def byte_bitset(indices):
    """ByteBitSet (00 section 6.3): VarInt byte count, then the bytes; no trailing zero byte."""
    data = _bits_to_bytes(indices)
    return varint(len(data)) + data


def fixed_bitset(indices, count):
    return _bits_to_bytes(indices, count)


def bitset(indices):
    """BitSet (00 section 6.3): VarInt long count, then the longs (bit i is bit i mod 64 of long i div 64)."""
    longs = (max(indices) // 64 + 1) if indices else 0
    words = [0] * longs
    for index in indices:
        words[index // 64] |= 1 << (index % 64)
    return varint(longs) + b"".join(struct.pack("<Q", w) for w in words)


def prefixed(items):
    """A Prefixed Array of already encoded elements."""
    return varint(len(items)) + b"".join(items)


def optional_varint(value):
    """OptionalVarInt (00 section 2.2): 0 = absent, otherwise value + 1."""
    return varint(0 if value is None else value + 1)


# ----------------------------------------------------------------------------------------------
# NBT (07 sections 1 to 3; network framing 00 section 8)

TAG_END, TAG_BYTE, TAG_SHORT, TAG_INT, TAG_LONG, TAG_FLOAT, TAG_DOUBLE = 0, 1, 2, 3, 4, 5, 6
TAG_BYTE_ARRAY, TAG_STRING, TAG_LIST, TAG_COMPOUND, TAG_INT_ARRAY, TAG_LONG_ARRAY = 7, 8, 9, 10, 11, 12


class Tag:
    kind = TAG_END
    label = ""

    def __init__(self, value):
        self.value = value


class Byte(Tag):
    kind, label = TAG_BYTE, "Byte"


class Short(Tag):
    kind, label = TAG_SHORT, "Short"


class Int(Tag):
    kind, label = TAG_INT, "Int"


class Long(Tag):
    kind, label = TAG_LONG, "Long"


class Float(Tag):
    kind, label = TAG_FLOAT, "Float"


class Double(Tag):
    kind, label = TAG_DOUBLE, "Double"


class Str(Tag):
    kind, label = TAG_STRING, "String"


class IntArray(Tag):
    kind, label = TAG_INT_ARRAY, "Int Array"


class LongArray(Tag):
    kind, label = TAG_LONG_ARRAY, "Long Array"


class ListOf(Tag):
    kind, label = TAG_LIST, "List"

    def __init__(self, element_kind, items):
        super().__init__(items)
        self.element_kind = element_kind if items == [] or element_kind is not None else items[0].kind


class Compound(Tag):
    kind, label = TAG_COMPOUND, "Compound"

    def __init__(self, members):
        super().__init__(list(members))


def _nbt_string(text):
    raw = text.encode("utf-8")
    return struct.pack(">H", len(raw)) + raw


def nbt_payload(tag):
    kind = tag.kind
    if kind == TAG_BYTE:
        return struct.pack(">b", tag.value)
    if kind == TAG_SHORT:
        return struct.pack(">h", tag.value)
    if kind == TAG_INT:
        return struct.pack(">i", tag.value)
    if kind == TAG_LONG:
        return struct.pack(">q", tag.value)
    if kind == TAG_FLOAT:
        return struct.pack(">f", tag.value)
    if kind == TAG_DOUBLE:
        return struct.pack(">d", tag.value)
    if kind == TAG_STRING:
        return _nbt_string(tag.value)
    if kind == TAG_INT_ARRAY:
        return struct.pack(">i", len(tag.value)) + b"".join(struct.pack(">i", v) for v in tag.value)
    if kind == TAG_LONG_ARRAY:
        return struct.pack(">i", len(tag.value)) + b"".join(struct.pack(">q", v) for v in tag.value)
    if kind == TAG_LIST:
        if not tag.value:
            return struct.pack(">bi", TAG_END, 0)
        return struct.pack(">bi", tag.element_kind, len(tag.value)) + b"".join(nbt_payload(t) for t in tag.value)
    if kind == TAG_COMPOUND:
        out = b""
        for name, member in tag.value:
            out += struct.pack(">b", member.kind) + _nbt_string(name) + nbt_payload(member)
        return out + b"\x00"
    raise ValueError("unknown tag kind %r" % kind)


def nbt_network(tag):
    """Network root (00 section 8): the type byte and the payload, no root name."""
    return struct.pack(">b", tag.kind) + nbt_payload(tag)


def nbt_steps(tag, name=None, depth=0):
    """[(bytes, comment, depth)] walking a tag in wire order, one step per tag header and scalar."""
    steps = []
    pad = "  " * depth
    kind_name = tag.label
    head = struct.pack(">b", tag.kind)
    if name is not None:
        steps.append((head + _nbt_string(name), "%sNBT %s (type %02x) name \"%s\"" % (pad, kind_name, tag.kind, name), depth))
    kind = tag.kind
    if kind == TAG_COMPOUND:
        for member_name, member in tag.value:
            steps.extend(nbt_steps(member, member_name, depth + 1))
        steps.append((b"\x00", "%sNBT End: end of the compound" % pad, depth + 1))
    elif kind == TAG_LIST:
        element = tag.element_kind
        steps.append((struct.pack(">bi", element, len(tag.value)), "%s  list element type %02x, count %d" % (pad, element, len(tag.value)), depth + 1))
        for index, item in enumerate(tag.value):
            if item.kind == TAG_COMPOUND:
                steps.append((b"", "%s  [%d] Compound" % (pad, index), depth + 1))
                steps.extend(nbt_steps(item, None, depth + 2))
            else:
                steps.append((nbt_payload(item), "%s  [%d] %s %s" % (pad, index, item.label, _show(item)), depth + 1))
    else:
        steps.append((nbt_payload(tag), "%s  %s %s" % (pad, kind_name, _show(tag)), depth + 1))
    return steps


def _show(tag):
    if tag.kind in (TAG_INT_ARRAY, TAG_LONG_ARRAY):
        return "[%d values]" % len(tag.value)
    return repr(tag.value)


# ----------------------------------------------------------------------------------------------
# Paletted containers and light (06)


def ceillog2(value):
    return 0 if value <= 1 else (value - 1).bit_length()


def pack_longs(values, bits):
    """06 section 6: floor(64 / bits) entries per long, lowest bits first, never spanning, big-endian longs."""
    per_long = 64 // bits
    longs = (len(values) + per_long - 1) // per_long
    words = [0] * longs
    for index, value in enumerate(values):
        if not 0 <= value < (1 << bits):
            raise ValueError("value %d does not fit %d bits" % (value, bits))
        words[index // per_long] |= value << ((index % per_long) * bits)
    return b"".join(struct.pack(">Q", w) for w in words)


def bits_for_palette(size, kind):
    """The bits byte of an indirect palette of `size` values (06 section 5.3); None when direct is needed."""
    if kind == "block":
        bits = max(4, ceillog2(size))
        return bits if bits <= 8 else None
    bits = ceillog2(size)
    return bits if 1 <= bits <= 3 else (1 if size <= 1 else None)


def container_single(value):
    return ubyte(0) + varint(value)


def container_indirect(values, palette, kind):
    bits = bits_for_palette(len(palette), kind)
    if bits is None:
        raise ValueError("palette too large for an indirect container")
    index = {v: i for i, v in enumerate(palette)}
    return ubyte(bits) + prefixed([varint(v) for v in palette]) + pack_longs([index[v] for v in values], bits)


def container_direct(values, bits, kind):
    del kind
    return ubyte(bits) + pack_longs(values, bits)


def section(nonempty, fluid, blocks, biomes):
    return struct.pack(">hh", nonempty, fluid) + blocks + biomes


def light_data(light_sections, sky_arrays, block_arrays, sky_empty, block_empty):
    """LightData (06 section 7): four ByteBitSets then the arrays in ascending bit order."""
    del light_sections
    out = byte_bitset(sorted(sky_arrays)) + byte_bitset(sorted(block_arrays))
    out += byte_bitset(sorted(sky_empty)) + byte_bitset(sorted(block_empty))
    out += prefixed([varint(len(sky_arrays[i])) + sky_arrays[i] for i in sorted(sky_arrays)])
    out += prefixed([varint(len(block_arrays[i])) + block_arrays[i] for i in sorted(block_arrays)])
    return out


# ----------------------------------------------------------------------------------------------
# Command nodes (05a 0x10)

NODE_ROOT, NODE_LITERAL, NODE_ARGUMENT = 0, 1, 2
NODE_EXECUTABLE, NODE_REDIRECT, NODE_SUGGEST, NODE_RESTRICTED = 0x04, 0x08, 0x10, 0x20


def command_node(flags, children, name=None, redirect=None, parser=None, props=b"", suggestions=None):
    out = ubyte(flags) + prefixed([varint(c) for c in children])
    if flags & NODE_REDIRECT:
        out += varint(redirect)
    kind = flags & 3
    if kind in (NODE_LITERAL, NODE_ARGUMENT):
        out += string(name, 32767)
    if kind == NODE_ARGUMENT:
        out += varint(parser) + props
        if flags & NODE_SUGGEST:
            out += ident(suggestions)
    return out


def number_range(kind_format, minimum, maximum):
    flags = (1 if minimum is not None else 0) | (2 if maximum is not None else 0)
    out = ubyte(flags)
    if minimum is not None:
        out += struct.pack(kind_format, minimum)
    if maximum is not None:
        out += struct.pack(kind_format, maximum)
    return out


def number_range_int(minimum, maximum):
    return number_range(">i", minimum, maximum)


def number_range_long(minimum, maximum):
    return number_range(">q", minimum, maximum)


def number_range_float(minimum, maximum):
    return number_range(">f", minimum, maximum)


def number_range_double(minimum, maximum):
    return number_range(">d", minimum, maximum)


# ----------------------------------------------------------------------------------------------
# Fixture files


class Fixture:
    """A packet body built field by field: every field is bytes and a comment, rendered one per line."""

    def __init__(self, name, header):
        self.name = name
        self.header = list(header)
        self.steps = []

    def field(self, data, comment, wrap=16):
        self.steps.append((bytes(data), comment, wrap, 0))
        return self

    def note(self, comment):
        self.steps.append((b"", comment, 16, 0))
        return self

    def nbt(self, tag, comment=None):
        """A network NBT root: its header line, then every tag of it."""
        pad = comment or "network NBT"
        self.steps.append((struct.pack(">b", tag.kind), "%s: root %s (type %02x), unnamed" % (pad, tag.label, tag.kind), 16, 0))
        if tag.kind == TAG_COMPOUND:
            for member_name, member in tag.value:
                for data, text, depth in nbt_steps(member, member_name, 1):
                    self.steps.append((data, text, 16, 0))
            self.steps.append((b"\x00", "NBT End: end of the root compound", 16, 0))
        else:
            self.steps.append((nbt_payload(tag), "root payload", 16, 0))
        return self

    def bytes(self):
        return b"".join(step[0] for step in self.steps)

    def render(self):
        lines = ["# " + line if line else "#" for line in self.header]
        lines.append("")
        for data, comment, wrap, _ in self.steps:
            if not data:
                lines.append("# " + comment if comment else "")
                continue
            chunks = [data[i : i + wrap] for i in range(0, len(data), wrap)]
            for number, chunk in enumerate(chunks):
                tokens = " ".join("%02x" % b for b in chunk)
                text = "# " + comment if number == 0 else "#   (continued)"
                lines.append("%-*s  %s" % (wrap * 3 - 1, tokens, text))
        return "\n".join(lines) + "\n"


_CATALOG = {}


def fixture(name):
    """Register a catalogue function `f() -> Fixture` under the fixture file name (without `.hex`)."""

    def register(function):
        if name in _CATALOG:
            raise ValueError("duplicate fixture " + name)
        _CATALOG[name] = function
        return function

    return register


def _load_catalog():
    import importlib

    here = os.path.dirname(os.path.abspath(__file__))
    for entry in sorted(os.listdir(here)):
        if entry.startswith("wire_catalog_") and entry.endswith(".py"):
            sys.path.insert(0, here) if here not in sys.path else None
            importlib.import_module(entry[:-3])


def catalog_names():
    _load_catalog()
    return sorted(_CATALOG)


def build(name):
    _load_catalog()
    result = _CATALOG[name]()
    if result.name != name:
        raise ValueError("fixture %s builds %s" % (name, result.name))
    return result


def write_all(out_dir, names=None):
    os.makedirs(out_dir, exist_ok=True)
    for name in names or catalog_names():
        with open(os.path.join(out_dir, name + ".hex"), "w", encoding="utf-8") as handle:
            handle.write(build(name).render())


def check(out_dir, names=None):
    """['<name>: missing' | '<name>: differs'] for the catalogue entries whose file is absent or not what is built."""
    problems = []
    for name in names or catalog_names():
        path = os.path.join(out_dir, name + ".hex")
        if not os.path.exists(path):
            problems.append("%s: missing" % name)
            continue
        with open(path, encoding="utf-8") as handle:
            if handle.read() != build(name).render():
                problems.append("%s: differs" % name)
    return problems


def main(argv):
    out_dir = WIRE_DIR
    check_only = False
    names = []
    args = list(argv)
    while args:
        arg = args.pop(0)
        if arg == "--out":
            out_dir = args.pop(0)
        elif arg == "--check":
            check_only = True
        else:
            names.append(arg)
    names = names or None
    if check_only:
        selected = names or catalog_names()
        problems = check(out_dir, names)
        for problem in problems:
            print(problem)
        print("wire_fixtures: %d files, %d differ" % (len(selected), len(problems)))
        return 1 if problems else 0
    write_all(out_dir, names)
    print("wire_fixtures: wrote %d files" % len(names or catalog_names()))
    return 0


if __name__ == "__main__":
    sys.modules.setdefault("wire_fixtures", sys.modules["__main__"])  # the catalogue modules import this file by name
    sys.exit(main(sys.argv[1:]))
