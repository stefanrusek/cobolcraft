"""Self-test of tools/wire_fixtures.py, the independent wire encoder (T0059): the primitives against vectors
computed by hand from docs/protocol (00, 06, 07), the encoder against existing hand-written fixtures, and
the generated fixtures against the files under contract/fixtures/wire/."""
import contextlib
import io
import os
import shutil
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import contract_check
import wire_fixtures as wf

WIRE = os.path.join(wf.REPO, "contract", "fixtures", "wire")


def existing(name):
    return contract_check.parse_hex(os.path.join(WIRE, name))[0]


class Scalars(unittest.TestCase):
    def test_varint_vectors_of_00_2_1(self):
        for value, hexed in [
            (0, "00"),
            (1, "01"),
            (127, "7f"),
            (128, "8001"),
            (255, "ff01"),
            (25565, "dd c7 01"),
            (2097151, "ff ff 7f"),
            (2147483647, "ff ff ff ff 07"),
            (-1, "ff ff ff ff 0f"),
            (-2147483648, "80 80 80 80 08"),
        ]:
            self.assertEqual(wf.varint(value), bytes.fromhex(hexed.replace(" ", "")), value)

    def test_varint_size_rule(self):
        self.assertEqual(len(wf.varint(2**21 - 1)), 3)
        self.assertEqual(len(wf.varint(2**21)), 4)
        self.assertEqual(len(wf.varint(-1)), 5)

    def test_varint_range_is_checked(self):
        with self.assertRaises(ValueError):
            wf.varint(2**31)
        with self.assertRaises(ValueError):
            wf.varint(-(2**31) - 1)

    def test_varlong_vectors(self):
        self.assertEqual(wf.varlong(0), b"\x00")
        self.assertEqual(wf.varlong(2**63 - 1), bytes.fromhex("ffffffffffffffff7f"))
        self.assertEqual(wf.varlong(-1), bytes.fromhex("ffffffffffffffffff01"))

    def test_fixed_width_are_big_endian(self):
        self.assertEqual(wf.short(-2), b"\xff\xfe")
        self.assertEqual(wf.ushort(0x1234), b"\x12\x34")
        self.assertEqual(wf.int32(-1), b"\xff\xff\xff\xff")
        self.assertEqual(wf.long64(1), b"\x00" * 7 + b"\x01")
        self.assertEqual(wf.float32(1.0), bytes.fromhex("3f800000"))
        self.assertEqual(wf.float64(1.0), bytes.fromhex("3ff0000000000000"))
        self.assertEqual(wf.bool1(True), b"\x01")

    def test_string_and_identifier(self):
        self.assertEqual(wf.string("abc"), bytes.fromhex("03616263"))
        self.assertEqual(wf.string("é"), bytes.fromhex("02c3a9"))
        self.assertEqual(wf.ident("minecraft:stone"), b"\x0fminecraft:stone")

    def test_string_length_limit(self):
        with self.assertRaises(ValueError):
            wf.string("x" * 5, limit=4)

    def test_uuid(self):
        self.assertEqual(wf.uuid("00000000-0000-0000-0000-000000000001"), b"\x00" * 15 + b"\x01")

    def test_position_packing_of_00_4_1(self):
        # X 18357644, Y 831, Z -20882616 (a widely quoted vector for this layout).
        self.assertEqual(wf.position(18357644, 831, -20882616), bytes.fromhex("4607632c15b4833f"))
        self.assertEqual(wf.position(0, 0, 0), b"\x00" * 8)
        self.assertEqual(wf.position(-1, -1, -1), b"\xff" * 8)

    def test_angle_is_floor_of_degrees_times_256_over_360(self):
        self.assertEqual(wf.angle(90.0), b"\x40")
        self.assertEqual(wf.angle(-90.0), b"\xc0")
        self.assertEqual(wf.angle(0.0), b"\x00")
        self.assertEqual(wf.angle(180.0), b"\x80")

    def test_lpvec3_of_00_4_6(self):
        self.assertEqual(wf.lpvec3(0, 0, 0), b"\x00")
        self.assertEqual(wf.lpvec3(1e-6, 0, 0), b"\x00")
        # (1, 0, 0): scale 1, quantised 32766 / 16383 / 16383 at bits 3, 18, 33
        packed = 1 | (32766 << 3) | (16383 << 18) | (16383 << 33)
        self.assertEqual(wf.lpvec3(1, 0, 0), bytes([packed & 0xFF, (packed >> 8) & 0xFF]) + struct.pack(">I", packed >> 16))
        # (8, 0, 0): scale 8 = 0b1000 -> low byte carries 0 | 4, VarInt 2 follows
        self.assertEqual(wf.lpvec3(8, 0, 0)[0] & 7, 4)
        self.assertEqual(wf.lpvec3(8, 0, 0)[-1], 2)
        self.assertEqual(len(wf.lpvec3(8, 0, 0)), 7)

    def test_bitsets(self):
        self.assertEqual(wf.byte_bitset([0, 9]), bytes.fromhex("02 01 02".replace(" ", "")))
        self.assertEqual(wf.byte_bitset([]), b"\x00")
        self.assertEqual(wf.bitset([0, 64]), bytes.fromhex("02" "0100000000000000" "0100000000000000"))
        self.assertEqual(wf.fixed_bitset([0, 9], 10), bytes.fromhex("0102"))


class Nbt(unittest.TestCase):
    def test_network_compound(self):
        tag = wf.Compound([("a", wf.Byte(1)), ("b", wf.Str("hi"))])
        self.assertEqual(
            wf.nbt_network(tag),
            bytes.fromhex("0a" "01000161" "01" "08000162" "000268" "69" "00"),
        )

    def test_numbers_lists_and_arrays(self):
        self.assertEqual(wf.nbt_payload(wf.Int(5)), b"\x00\x00\x00\x05")
        self.assertEqual(wf.nbt_payload(wf.Double(1.0)), bytes.fromhex("3ff0000000000000"))
        self.assertEqual(wf.nbt_payload(wf.ListOf(wf.TAG_STRING, [wf.Str("a")])), bytes.fromhex("08" "00000001" "00 01 61".replace(" ", "")))
        self.assertEqual(wf.nbt_payload(wf.ListOf(wf.TAG_INT, [])), bytes.fromhex("00" "00000000"))
        self.assertEqual(wf.nbt_payload(wf.IntArray([1])), bytes.fromhex("00000001" "00000001"))

    def test_matches_the_existing_chat_type_fixture(self):
        decoration = lambda key: wf.Compound(
            [("translation_key", wf.Str(key)), ("parameters", wf.ListOf(wf.TAG_STRING, [wf.Str("sender"), wf.Str("content")]))]
        )
        entry = wf.Compound([("chat", decoration("cobolcraft.chat.say")), ("narration", decoration("cobolcraft.chat.say.narrate"))])
        body = wf.varint(7) + wf.ident("minecraft:chat_type") + wf.varint(1) + wf.ident("cobolcraft:say") + wf.bool1(True) + wf.nbt_network(entry)
        self.assertEqual(body, existing("config-s2c-07-registry-data-chat-type.hex"))


class Chunks(unittest.TestCase):
    def test_long_counts_of_06_5_5(self):
        for bits, entries, longs in [(4, 4096, 256), (5, 4096, 342), (6, 4096, 410), (7, 4096, 456), (8, 4096, 512), (15, 4096, 1024),
                                     (1, 64, 1), (2, 64, 2), (3, 64, 4), (6, 64, 7), (9, 256, 37)]:
            self.assertEqual(len(wf.pack_longs([0] * entries, bits)), longs * 8, (bits, entries))

    def test_entries_never_span_two_longs_and_fill_from_the_low_bits(self):
        data = wf.pack_longs(list(range(1, 13)), 5)  # 12 per long
        first = struct.unpack(">q", data[:8])[0]
        for index in range(12):
            self.assertEqual((first >> (5 * index)) & 31, index + 1)
        self.assertEqual(first >> 60, 0)
        self.assertEqual(len(data), 8)

    def test_second_long_starts_at_value_after_the_last_full_long(self):
        values = [i % 16 for i in range(4096)]
        data = wf.pack_longs(values, 4)
        second = struct.unpack(">Q", data[8:16])[0]
        self.assertEqual(second & 0xF, values[16])

    def test_value_out_of_range_is_refused(self):
        with self.assertRaises(ValueError):
            wf.pack_longs([16], 4)

    def test_single_value_container(self):
        self.assertEqual(wf.container_single(9), bytes.fromhex("00" "09"))

    def test_indirect_container_for_blocks_packs_four_bits_for_one_to_four(self):
        values = [10] * 4096
        values[0] = 20
        body = wf.container_indirect(values, [10, 20], kind="block")
        self.assertEqual(body[:4], bytes.fromhex("04" "02" "0a" "14"))
        self.assertEqual(len(body), 1 + 1 + 2 + 256 * 8)

    def test_indirect_bits_follow_the_palette_size_for_blocks_and_biomes(self):
        self.assertEqual(wf.bits_for_palette(2, "block"), 4)
        self.assertEqual(wf.bits_for_palette(17, "block"), 5)
        self.assertEqual(wf.bits_for_palette(33, "block"), 6)
        self.assertEqual(wf.bits_for_palette(257, "block"), None)  # direct
        self.assertEqual(wf.bits_for_palette(2, "biome"), 1)
        self.assertEqual(wf.bits_for_palette(5, "biome"), 3)
        self.assertEqual(wf.bits_for_palette(9, "biome"), None)

    def test_direct_container_has_no_palette(self):
        body = wf.container_direct([5] * 64, 7, "biome")
        self.assertEqual(body[0], 7)
        self.assertEqual(len(body), 1 + 8 * 8)  # 9 entries per long at 7 bits

    def test_ceillog2(self):
        self.assertEqual([wf.ceillog2(n) for n in (1, 2, 3, 4, 5, 1000, 29999)], [0, 1, 2, 2, 3, 10, 15])

    def test_light_data_layout_of_06_7(self):
        sky = {0: b"\x11" * 2048}
        body = wf.light_data(26, sky_arrays=sky, block_arrays={}, sky_empty=[1], block_empty=[1, 2])
        # masks as ByteBitSet: sky bit 0, block none, empty sky bit 1, empty block bits 1 and 2
        expected_masks = bytes.fromhex("0101" "00" "0102" "0106")
        self.assertEqual(body[: len(expected_masks)], expected_masks)
        self.assertEqual(body[len(expected_masks)], 1)  # one sky array
        self.assertEqual(wf.varint(2048), body[len(expected_masks) + 1 : len(expected_masks) + 3])
        self.assertEqual(body[-1], 0)  # zero block arrays

    def test_section_matches_06_4(self):
        body = wf.section(4096, 0, wf.container_single(1), wf.container_single(0))
        self.assertEqual(body, bytes.fromhex("1000" "0000" "0001" "0000"))


class Commands(unittest.TestCase):
    def test_flags_children_redirect_name(self):
        node = wf.command_node(flags=wf.NODE_LITERAL | wf.NODE_EXECUTABLE, children=[2, 3], name="say")
        self.assertEqual(node, bytes.fromhex("05" "02" "02" "03" "03" "736179"))

    def test_redirect_is_present_only_with_its_flag(self):
        node = wf.command_node(flags=wf.NODE_LITERAL | wf.NODE_REDIRECT, children=[], redirect=7, name="tp")
        self.assertEqual(node, bytes.fromhex("09" "00" "07" "02" "7470"))

    def test_number_range_flags_follow_05a(self):
        node = wf.command_node(flags=wf.NODE_ARGUMENT, children=[], name="n", parser=3, props=wf.number_range_int(0, None))
        self.assertEqual(node, bytes.fromhex("02" "00" "01" "6e" "03" "01" "00000000"))


class Fixtures(unittest.TestCase):
    def test_render_is_comments_and_hex_tokens_that_parse_back(self):
        fx = wf.Fixture("x", ["Title", "line two"])
        fx.field(b"\x0b", "packet id")
        fx.field(bytes(range(20)), "twenty bytes")
        text = fx.render()
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        path = os.path.join(scratch, "x.hex")
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        data, errors = contract_check.parse_hex(path)
        self.assertEqual(errors, [])
        self.assertEqual(data, b"\x0b" + bytes(range(20)))
        self.assertEqual(data, fx.bytes())
        self.assertTrue(text.startswith("# Title\n# line two\n"))

    def test_encoder_reproduces_existing_hand_written_fixtures(self):
        fx = wf.Fixture("t", [])
        fx.field(wf.varint(0x14), "id")
        fx.field(wf.varint(0) + wf.varint(2) + wf.short(0) + wf.varint(63) + wf.varint(2) + wf.varint(0) + wf.varint(0), "body")
        self.assertEqual(fx.bytes(), existing("play-s2c-14-container-set-slot.hex"))
        self.assertEqual(wf.varint(0x0B) + wf.varint(9), existing("play-s2c-0b-chunk-batch-finished.hex"))

    def test_every_catalog_entry_has_a_name_a_header_and_parses(self):
        names = wf.catalog_names()
        self.assertGreater(len(names), 40)
        self.assertEqual(len(names), len(set(names)))
        for name in names:
            fx = wf.build(name)
            self.assertEqual(fx.name, name)
            self.assertTrue(fx.header, name)
            self.assertGreater(len(fx.bytes()), 0, name)

    def test_catalog_names_follow_the_naming_rule_of_proto_api_3(self):
        import re

        for name in wf.catalog_names():
            self.assertRegex(name, r"^(config|play|login|status|handshake)-(c2s|s2c)-[0-9a-f]{2}-[a-z0-9]+(-[a-z0-9]+)*$", name)

    def test_no_catalog_entry_replaces_an_unrelated_fixture(self):
        # a generated fixture is either new or identical to what the repository holds
        self.assertEqual(wf.check(WIRE), [])

    def test_check_reports_a_missing_and_a_changed_file(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        problems = wf.check(scratch)
        self.assertEqual(len(problems), len(wf.catalog_names()))
        self.assertTrue(problems[0].endswith("missing"))
        wf.write_all(scratch)
        self.assertEqual(wf.check(scratch), [])
        name = wf.catalog_names()[0]
        with open(os.path.join(scratch, name + ".hex"), "a", encoding="utf-8") as handle:
            handle.write("# changed\n")
        self.assertEqual(wf.check(scratch), ["%s: differs" % name])

    def test_command_line(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = wf.main(["--out", scratch])
        self.assertEqual(status, 0)
        self.assertIn("wire_fixtures: wrote %d files" % len(wf.catalog_names()), out.getvalue())
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = wf.main(["--check", "--out", scratch])
        self.assertEqual(status, 0)
        self.assertIn("wire_fixtures: %d files, 0 differ" % len(wf.catalog_names()), out.getvalue())
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = wf.main(["--check", "--out", scratch + "-none"])
        self.assertEqual(status, 1)


if __name__ == "__main__":
    unittest.main()
