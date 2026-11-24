"""Tests of tools/make_client_fixtures.py (T0058): options.txt fixtures against docs/protocol/13 sections 7.1, 7.2 and
7.4 (reference parser and range table written here) and the legacy options.dat against the format of the 001
client (gzip NBT, root Compound with a List "EnabledPacks" of String)."""
import gzip
import os
import shutil
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import make_client_fixtures as mcf

FILES = mcf.generate()


def parse(name):
    """(version, {key: value}, [skipped lines]) the way 13 section 7.1 reads a file."""
    lines = FILES[name].decode("utf-8").split("\n")
    assert lines[-1] == ""
    options, skipped = {}, []
    for line in lines[:-1]:
        if ":" not in line:
            skipped.append(line)
            continue
        key, value = line.split(":", 1)
        options[key] = value
    return options.pop("version", None), options, skipped


# (low, high) of the stored file value, 13 section 7.2 and 7.4
RANGES = {
    "renderDistance": (2, 32), "simulationDistance": (5, 32), "entityDistanceScaling": (0.5, 5.0),
    "maxFps": (10, 260), "fov": (-1.0, 1.0), "biomeBlendRadius": (0, 7), "cloudRange": (2, 128),
    "weatherRadius": (3, 10), "chunkSectionFadeInTime": (0.0, 2.0), "mipmapLevels": (0, 4), "maxAnisotropyBit": (1, 3),
    "glintSpeed": (0.0, 1.0), "mouseSensitivity": (0.0, 1.0), "mouseWheelSensitivity": (0.01, 10.0), "sprintWindow": (0, 10),
    "gamma": (0.0, 1.0), "chatOpacity": (0.0, 1.0), "chatDelay": (0.0, 6.0), "notificationDisplayTime": (0.5, 10.0),
    "menuBackgroundBlurriness": (0, 10), "soundCategory_master": (0.0, 1.0), "guiScale": (0, 2147483646),
}


class Options(unittest.TestCase):
    def test_default_file_holds_the_documented_defaults(self):
        version, options, skipped = parse("options-default.txt")
        self.assertEqual(FILES["options-default.txt"].decode().split("\n")[0], "version:5023")
        self.assertEqual((version, skipped), ("5023", []))
        expect = {"fov": "0.0", "renderDistance": "12", "simulationDistance": "12", "maxFps": "120", "guiScale": "0",
                  "gamma": "0.5", "mouseSensitivity": "0.5", "mouseWheelSensitivity": "1.0", "entityDistanceScaling": "1.0",
                  "chunkSectionFadeInTime": "0.75", "chatHeightUnfocused": "0.4375", "chatVisibility": "0", "particles": "0",
                  "attackIndicator": "1", "narrator": "0", "textureFiltering": "0", "prioritizeChunkUpdates": "0",
                  "renderClouds": '"true"', "graphicsPreset": '"fancy"', "mainHand": '"right"', "musicFrequency": '"DEFAULT"',
                  "inactivityFpsLimit": '"afk"', "resourcePacks": "[]", "incompatibleResourcePacks": "[]",
                  "key_key.forward": "key.keyboard.w", "key_key.jump": "key.keyboard.space",
                  "key_key.sneak": "key.keyboard.left.shift", "key_key.sprint": "key.keyboard.left.control",
                  "key_key.attack": "key.mouse.left", "key_key.use": "key.mouse.right", "key_key.chat": "key.keyboard.t",
                  "key_key.command": "key.keyboard.slash", "key_key.togglePerspective": "key.keyboard.f5",
                  "key_key.smoothCamera": "key.keyboard.unknown", "sprintWindow": "7", "biomeBlendRadius": "2",
                  "cloudRange": "128", "mipmapLevels": "4", "weatherRadius": "10", "menuBackgroundBlurriness": "5",
                  "enableVsync": "true", "fullscreen": "false", "lang": "en_us"}
        for key, value in expect.items():
            self.assertEqual(options.get(key), value, key)
        for category in "master music record weather block hostile neutral player ambient voice ui".split():
            self.assertEqual(options["soundCategory_" + category], "1.0")
        for part in "cape jacket left_sleeve right_sleeve left_pants_leg right_pants_leg hat".split():
            self.assertEqual(options["modelPart_" + part], "true")
        for n in range(1, 10):
            self.assertEqual(options["key_key.hotbar.%d" % n], "key.keyboard.%d" % n)
        self.assertNotIn("fullscreenResolution", options)

    def test_full_file_differs_from_the_default_in_every_key(self):
        _, default, _ = parse("options-default.txt")
        version, full, skipped = parse("options-full.txt")
        self.assertEqual(skipped, [])
        self.assertEqual(set(full) - set(default), {"fullscreenResolution"})
        self.assertEqual(set(default) - set(full), set())
        same = [k for k in default if default[k] == full[k]]
        self.assertEqual(same, [])
        self.assertEqual(FILES["options-full.txt"].decode().rstrip("\n").split("\n")[-1].split(":")[0], "fullscreenResolution")
        self.assertEqual(full["resourcePacks"], '["vanilla","file/Faithful 32x - 26.3.zip"]')

    def test_full_file_values_are_in_range(self):
        _, full, _ = parse("options-full.txt")
        for key, (low, high) in RANGES.items():
            value = float(full[key])
            self.assertTrue(low <= value <= high, "%s %s" % (key, value))
        self.assertIn(full["chatVisibility"], ("1", "2"))
        self.assertEqual(full["fov"], "1.0")  # fov 110

    def test_corrupt_file_has_bad_lines_and_good_lines(self):
        version, options, skipped = parse("options-corrupt.txt")
        self.assertGreaterEqual(len(skipped), 2)
        self.assertEqual(options["renderDistance"], "far")
        self.assertEqual(options["gamma"], "bright")
        self.assertEqual(options["graphicsPreset"], '"turbo"')
        self.assertEqual(options["resourcePacks"], '["vanilla"')
        self.assertIn("unknownOption", options)
        self.assertEqual(options["mouseSensitivity"], "0.25")  # a good line after the bad ones
        self.assertEqual(options["key_key.forward"], "key.keyboard.w")

    def test_corrupt_file_has_no_version_line_first(self):
        self.assertFalse(FILES["options-corrupt.txt"].decode().startswith("version:"))

    def test_out_of_range_file_values_all_fall_outside(self):
        version, options, skipped = parse("options-out-of-range.txt")
        self.assertEqual((version, skipped), ("5023", []))
        self.assertGreaterEqual(len(options), 15)
        for key, text in options.items():
            low, high = RANGES[key]
            self.assertFalse(low <= float(text) <= high, "%s %s" % (key, text))

    def test_expected_lists_the_kept_defaults(self):
        text = FILES["expected.txt"].decode()
        self.assertIn("options-out-of-range.txt renderDistance 12", text)
        self.assertIn("options-corrupt.txt gamma 0.5", text)


def read_nbt_string(data, pos):
    n = struct.unpack(">H", data[pos:pos + 2])[0]
    return data[pos + 2:pos + 2 + n].decode(), pos + 2 + n


class Legacy(unittest.TestCase):
    def tags(self, name):
        raw = gzip.decompress(FILES[name])
        self.assertEqual(raw[0], 10)
        root, pos = read_nbt_string(raw, 1)
        self.assertEqual(root, "")
        out = {}
        while raw[pos] != 0:
            kind = raw[pos]
            tag, pos = read_nbt_string(raw, pos + 1)
            if kind == 9:
                element, count = struct.unpack(">bi", raw[pos:pos + 5])
                pos += 5
                items = []
                for _ in range(count):
                    assert element == 8
                    s, pos = read_nbt_string(raw, pos)
                    items.append(s)
                out[tag] = items
            elif kind == 3:
                out[tag] = struct.unpack(">i", raw[pos:pos + 4])[0]
                pos += 4
            else:
                self.fail("tag kind %d" % kind)
        self.assertEqual(pos, len(raw) - 1)
        return out

    def test_options_dat_holds_enabled_packs(self):
        self.assertEqual(self.tags("options.dat"), {"EnabledPacks": ["vanilla", "file/Faithful 32x - 26.3.zip"]})

    def test_extra_tags_are_present_next_to_the_packs(self):
        tags = self.tags("options-extra-tags.dat")
        self.assertEqual(tags["EnabledPacks"], ["vanilla"])
        self.assertIn("Unrelated", tags)

    def test_empty_list_file(self):
        self.assertEqual(self.tags("options-empty.dat"), {"EnabledPacks": []})

    def test_gzip_is_reproducible(self):
        self.assertEqual(mcf.generate()["options.dat"], FILES["options.dat"])


class Committed(unittest.TestCase):
    def test_repository_files_match(self):
        self.assertEqual(mcf.check(mcf.OUT_DEFAULT), [])

    def test_check_reports_differences(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        mcf.write(scratch)
        os.remove(os.path.join(scratch, "options.dat"))
        with open(os.path.join(scratch, "options-full.txt"), "a") as handle:
            handle.write("x:1\n")
        self.assertEqual(mcf.check(scratch), ["options-full.txt: differs", "options.dat: missing"])


if __name__ == "__main__":
    unittest.main()
