"""Tests of tools/make_fixtures.py (T0056, T0057): the generated content trees against the check of
docs/protocol/22-extraction-tool.md section 8.2, the reject archives against what each is meant to be, and the
committed trees and archives against a fresh generation."""
import filecmp
import os
import shutil
import struct
import sys
import tempfile
import unittest
import zipfile
import zlib

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import make_fixtures as mf

ROW = {
    "jar-version": "26.3",
    "jar-sha256": "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d",
    "jar-size": "41483720",
    "world-version": "5023",
    "protocol-version": "777",
    "resource-format": "97.1",
    "data-format": "121.0",
}
KEYS = ["format", "tool", "jar-version", "jar-sha256", "jar-size", "world-version", "protocol-version", "resource-format",
        "data-format", "files-resource", "files-data", "files-feature", "files-total"]
RESOURCE_SENTINELS = ["vanilla-resources/pack.mcmeta", "vanilla-resources/assets/minecraft/lang/en_us.json",
                      "vanilla-resources/assets/minecraft/atlases/blocks.json", "vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png"]
DATA_SENTINELS = ["vanilla-data/pack.mcmeta", "vanilla-data/data/minecraft/worldgen/biome/plains.json",
                  "vanilla-data/data/minecraft/dimension_type/overworld.json", "vanilla-data/data/minecraft/damage_type/generic.json",
                  "vanilla-data/data/minecraft/recipe/stick.json"]


def packs_status(root):
    """22 section 8.2, written independently of the generator."""
    if not os.path.isdir(root):
        return "absent"
    marker = os.path.exists(os.path.join(root, ".cobolcraft-generated"))
    path = os.path.join(root, "manifest.txt")
    if not os.path.exists(path):
        return "incomplete" if marker else "absent"
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    pairs = [line.split("=", 1) for line in lines]
    if len(pairs) < len(KEYS) or any(len(p) != 2 for p in pairs) or [p[0] for p in pairs[: len(KEYS)]] != KEYS:
        return "damaged"
    values = dict(pairs[: len(KEYS)])
    for key in ("jar-size", "world-version", "protocol-version", "files-resource", "files-data", "files-feature", "files-total"):
        if not values[key].isdigit():
            return "damaged"
    if values["format"] != "1":
        return "stale"
    for key, value in ROW.items():
        if values[key] != value:
            return "stale"
    for sentinel in RESOURCE_SENTINELS + DATA_SENTINELS:
        if not os.path.isfile(os.path.join(root, sentinel)):
            return "damaged"
    return "ok"


class ContentTrees(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.out = tempfile.mkdtemp()
        mf.write_content(cls.out)

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.out)

    def tree(self, name):
        return os.path.join(self.out, name)

    def test_statuses_of_the_five_trees(self):
        self.assertEqual(
            {n: packs_status(self.tree(n)) for n in ("valid", "stale", "damaged", "incomplete", "damaged-manifest")},
            {"valid": "ok", "stale": "stale", "damaged": "damaged", "incomplete": "incomplete", "damaged-manifest": "damaged"},
        )

    def test_absent_is_a_missing_directory(self):
        self.assertEqual(packs_status(self.tree("absent")), "absent")
        self.assertFalse(os.path.exists(self.tree("absent")))

    def test_valid_tree_has_the_layout_of_22_5_2(self):
        valid = self.tree("valid")
        for entry in [".cobolcraft-generated", "manifest.txt", "index.txt"] + RESOURCE_SENTINELS + DATA_SENTINELS:
            self.assertTrue(os.path.isfile(os.path.join(valid, entry)), entry)
        self.assertEqual(os.path.getsize(os.path.join(valid, ".cobolcraft-generated")), 0)
        for pack in ("minecart_improvements", "redstone_experiments", "trade_rebalance"):
            self.assertTrue(os.path.isfile(os.path.join(valid, "featurepacks", pack, "pack.mcmeta")), pack)

    def test_valid_tree_has_a_handful_of_registries_tags_recipes_and_worldgen(self):
        data = os.path.join(self.tree("valid"), "vanilla-data", "data", "minecraft")
        for entry in ["dimension_type/the_nether.json", "dimension_type/the_end.json", "chat_type/chat.json", "recipe/crafting_table.json",
                      "tags/block/planks.json", "tags/item/planks.json", "worldgen/biome/desert.json", "worldgen/noise_settings/overworld.json"]:
            self.assertTrue(os.path.isfile(os.path.join(data, entry)), entry)

    def test_every_json_file_is_strict_json(self):
        import json

        def no_duplicates(pairs):
            keys = [k for k, _ in pairs]
            self.assertEqual(len(keys), len(set(keys)))
            return dict(pairs)

        count = 0
        for base, _, files in os.walk(self.tree("valid")):
            for name in files:
                if name.endswith(".json") or name.endswith(".mcmeta"):
                    with open(os.path.join(base, name), encoding="utf-8") as handle:
                        json.loads(handle.read(), object_pairs_hook=no_duplicates)
                    count += 1
        self.assertGreater(count, 15)

    def test_manifest_counts_and_index_match_the_tree(self):
        valid = self.tree("valid")
        values = dict(line.split("=", 1) for line in open(os.path.join(valid, "manifest.txt"), encoding="utf-8").read().splitlines())
        index = open(os.path.join(valid, "index.txt"), encoding="utf-8").read().splitlines()
        self.assertEqual(int(values["files-total"]), len(index))
        self.assertEqual(int(values["files-total"]), int(values["files-resource"]) + int(values["files-data"]) + int(values["files-feature"]))
        for line in index:
            crc, size, path = line.split(" ", 2)
            data = open(os.path.join(valid, path), "rb").read()
            self.assertEqual((crc, int(size)), ("%08x" % (zlib.crc32(data) & 0xFFFFFFFF), len(data)), path)
        listed = {line.split(" ", 2)[2] for line in index}
        found = set()
        for base, _, files in os.walk(valid):
            for name in files:
                rel = os.path.relpath(os.path.join(base, name), valid)
                if rel not in (".cobolcraft-generated", "manifest.txt", "index.txt"):
                    found.add(rel)
        self.assertEqual(listed, found)

    def test_generated_pack_mcmeta_have_the_sizes_and_crcs_of_22_6_2(self):
        for path, size, crc in [("vanilla-resources/pack.mcmeta", 129, "c6f2b630"), ("vanilla-data/pack.mcmeta", 123, "14f8038e")]:
            data = open(os.path.join(self.tree("valid"), path), "rb").read()
            self.assertEqual((len(data), "%08x" % (zlib.crc32(data) & 0xFFFFFFFF)), (size, crc), path)

    def test_stale_differs_from_valid_only_in_the_digest(self):
        a = open(os.path.join(self.tree("valid"), "manifest.txt")).read().splitlines()
        b = open(os.path.join(self.tree("stale"), "manifest.txt")).read().splitlines()
        self.assertEqual([i for i, (x, y) in enumerate(zip(a, b)) if x != y], [3])
        self.assertEqual(len(a), len(b))

    def test_damaged_lacks_exactly_one_sentinel(self):
        def files(root):
            return {os.path.relpath(os.path.join(b, n), root) for b, _, ns in os.walk(root) for n in ns}

        self.assertEqual(files(self.tree("valid")) - files(self.tree("damaged")), {"vanilla-data/data/minecraft/recipe/stick.json"})
        self.assertEqual(files(self.tree("damaged")) - files(self.tree("valid")), set())


class RejectArchives(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.out = tempfile.mkdtemp()
        mf.write_extract(cls.out)

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.out)

    def path(self, name):
        return os.path.join(self.out, name)

    def expected(self):
        table = {}
        for line in open(self.path("expected.txt"), encoding="utf-8").read().splitlines():
            if line and not line.startswith("#"):
                name, code = line.split()
                table[name] = code
        return table

    def test_every_listed_file_exists_and_every_file_is_listed(self):
        listed = set(self.expected())
        present = set(os.listdir(self.out)) - {"expected.txt"}
        self.assertEqual(listed, present)

    def test_codes_cover_the_reject_series_of_22_7_4(self):
        codes = set(self.expected().values())
        self.assertTrue({"CCX-020", "CCX-021", "CCX-030", "CCX-031", "CCX-040", "CCX-041", "CCX-042", "CCX-043", "CCX-044"} <= codes, codes)

    def test_not_a_zip_and_too_short(self):
        self.assertEqual(open(self.path("c-not-a-zip.bin"), "rb").read()[:4], b"This")
        self.assertLess(os.path.getsize(self.path("c-too-short.bin")), 22)
        self.assertFalse(zipfile.is_zipfile(self.path("c-not-a-zip.bin")))

    def test_crc_archive_has_a_central_crc_that_is_wrong(self):
        with zipfile.ZipFile(self.path("t-bad-crc.zip")) as archive:
            with self.assertRaises(zipfile.BadZipFile):
                archive.read("a.txt")

    def test_deflate_archive_is_not_inflatable(self):
        with zipfile.ZipFile(self.path("t-bad-deflate.zip")) as archive:
            with self.assertRaises((zlib.error, zipfile.BadZipFile)):
                archive.read("a.txt")

    def test_size_mismatch_archive_declares_the_wrong_size(self):
        with zipfile.ZipFile(self.path("t-size-mismatch.zip")) as archive:
            self.assertEqual(archive.getinfo("a.txt").file_size, 20)  # the actual data is 11 bytes

    def test_zip64_encrypted_and_method_flags_are_in_the_central_record(self):
        def central(name):
            data = open(self.path(name), "rb").read()
            at = data.rindex(b"PK\x01\x02")
            return struct.unpack("<4s6H3I5H2I", data[at : at + 46])

        self.assertEqual(central("c-zip64.zip")[8], 0xFFFFFFFF)  # compressed size marker
        self.assertEqual(central("c-encrypted.zip")[3] & 1, 1)  # general purpose flag bit 0
        self.assertEqual(central("c-method-99.zip")[4], 99)
        data = open(self.path("c-several-disks.zip"), "rb").read()
        eocd = data.rindex(b"PK\x05\x06")
        self.assertNotEqual(struct.unpack("<HH", data[eocd + 4 : eocd + 8]), (0, 0))

    def test_version_json_archives_carry_the_id_the_name_says(self):
        for name, ident in [("c-wrong-id.zip", "99.9"), ("c-right-id-wrong-digest.zip", "26.3")]:
            with zipfile.ZipFile(self.path(name)) as archive:
                self.assertIn(b'"id": "%s"' % ident.encode(), archive.read("version.json"))
        with zipfile.ZipFile(self.path("c-no-version-json.zip")) as archive:
            self.assertNotIn("version.json", archive.namelist())

    def test_path_archives(self):
        with zipfile.ZipFile(self.path("t-bad-path.zip")) as archive:
            self.assertTrue(any(".." in n for n in archive.namelist()))
        with zipfile.ZipFile(self.path("t-duplicate-path.zip")) as archive:
            names = [n for n in archive.namelist()]
            self.assertEqual(len(names), 2)

    def test_the_good_baseline_archive_is_a_valid_zip(self):
        with zipfile.ZipFile(self.path("ok-small.zip")) as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(archive.read("a.txt"), b"hello world")


class Committed(unittest.TestCase):
    def test_committed_fixtures_equal_a_fresh_generation(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        mf.write_all(scratch)
        self.assertEqual(mf.compare(scratch, os.path.join(mf.REPO, "contract", "fixtures")), [])

    def test_compare_reports_changed_missing_and_extra(self):
        a, b = tempfile.mkdtemp(), tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, a)
        self.addCleanup(shutil.rmtree, b)
        for root in (a, b):
            os.makedirs(os.path.join(root, "content"))
        open(os.path.join(a, "content", "x"), "w").write("1")
        open(os.path.join(b, "content", "x"), "w").write("2")
        open(os.path.join(a, "content", "y"), "w").write("1")
        open(os.path.join(b, "content", "z"), "w").write("1")
        self.assertEqual(sorted(mf.compare(a, b)), ["content/x: differs", "content/y: missing", "content/z: extra"])

    def test_command_line(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        self.assertEqual(mf.main(["--out", scratch]), 0)
        self.assertEqual(mf.main(["--check", "--out", scratch]), 0)
        os.remove(os.path.join(scratch, "extract", "expected.txt"))
        self.assertEqual(mf.main(["--check", "--out", scratch]), 1)


if __name__ == "__main__":
    unittest.main()
