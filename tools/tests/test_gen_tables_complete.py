"""Completeness tests of the block property lists, default states, item stack sizes and item components that
tools/gen/gen_tables.py generates (phase 19 defect: 547 multi-state blocks without a property list or default,
909 items without a stack size, a component summary cut at 100 characters)."""
import os
import re
import sys
import unittest

import genlib

sys.path.insert(0, os.path.join(genlib.TOOLS, "gen"))
import gen_tables  # noqa: E402

DIRECTORY = None
RUN = None
GAPS = {}
PROPS_WIDTH = 288
COMPONENTS_WIDTH = 160
MAXDAMAGE_WIDTH = 4


def setUpModule():
    global DIRECTORY, RUN, GAPS
    DIRECTORY, RUN = genlib.generate()
    path = os.path.join(DIRECTORY.name, "gaps.txt")
    if os.path.exists(path):
        with open(path, encoding="ascii") as handle:
            for line in handle:
                match = re.match(r"(block|item) (\S+) (\S+)", line)
                if match:
                    GAPS.setdefault((match.group(1), match.group(3)), set()).add(match.group(2))


def tearDownModule():
    DIRECTORY.cleanup()


def table(name, prefix):
    return genlib.Table(os.path.join(DIRECTORY.name, name), prefix)


def blocks():
    return table("blocks.cpy", "BLOCK").rows()


def items():
    return table("items.cpy", "ITEM").rows()


def parse_spec(text):
    """[(name, count, [values])] of a generated property list (name[a/b/c], name[lo..hi], name[bool])."""
    out = []
    for token in text.split():
        match = re.fullmatch(r"([a-z_0-9]+)\[(.*)\]", token)
        if not match:
            raise AssertionError("bad property token " + token)
        name, body = match.groups()
        if body == "bool":
            values = ["true", "false"]
        elif ".." in body:
            low, high = body.split("..")
            values = [str(n) for n in range(int(low), int(high) + 1)]
        else:
            values = body.split("/")
        out.append((name, values))
    return out


def default_index(spec, default):
    """The index of the default state: sum of value position times stride (24 part 1 section 3, 04 5.2)."""
    index, stride = 0, 1
    for name, values in reversed(spec):
        index += values.index(default[name]) * stride
        stride *= len(values)
    return index


class BlockCompletenessTest(unittest.TestCase):
    def test_generation_succeeds_and_reports_counts(self):
        """given the documents when the generator runs then it exits 0 and prints the completeness counts"""
        self.assertEqual(RUN.returncode, 0, RUN.stdout)
        for label in ("blocks without property list", "blocks without default state", "items without max stack"):
            self.assertRegex(RUN.stdout, r"COUNT %s \d+" % label)

    def test_every_multi_state_block_has_a_full_property_list(self):
        """given 24 parts 1 to 8 when the rows are read then every multi-state block lists names and values"""
        gap = GAPS.get(("block", "properties"), set())
        missing = []
        for row in blocks():
            states = int(row["STATES"])
            if states == 1:
                continue
            if row["KEY"] in gap:
                self.assertEqual(row["PROPS"], "", row["KEY"])
                continue
            if not row["PROPS"]:
                missing.append(row["KEY"])
                continue
            spec = parse_spec(row["PROPS"])
            names = [n for n, _ in spec]
            self.assertEqual(names, sorted(names), row["KEY"])
            self.assertEqual(len(set(names)), len(names), row["KEY"])
            product = 1
            for _, values in spec:
                self.assertGreater(len(values), 1, row["KEY"])
                self.assertEqual(len(set(values)), len(values), row["KEY"])
                product *= len(values)
            self.assertEqual(product, states, row["KEY"])
            self.assertLessEqual(len(row["PROPS"]), PROPS_WIDTH, row["KEY"])
        self.assertEqual(missing, [])

    def test_single_state_blocks_have_no_property_list(self):
        """given 24 part 1 section 3 when a block has one state then its list is empty"""
        for row in blocks():
            if int(row["STATES"]) == 1:
                self.assertEqual(row["PROPS"], "", row["KEY"])

    def test_every_block_has_a_default_state_inside_its_range(self):
        """given the documents when the rows are read then every block has a default state id of its own range"""
        gap = GAPS.get(("block", "default"), set())
        missing = []
        for row in blocks():
            if row["KEY"] in gap:
                self.assertEqual(row["DEFAULT"], "", row["KEY"])
                continue
            if not row["DEFAULT"]:
                missing.append(row["KEY"])
                continue
            first, states, default = int(row["FIRST"]), int(row["STATES"]), int(row["DEFAULT"])
            self.assertTrue(first <= default < first + states, row["KEY"])
            if states == 1:
                self.assertEqual(default, first, row["KEY"])
        self.assertEqual(missing, [])

    def test_default_follows_the_stride_rule_of_the_property_list(self):
        """given 24 part 1 section 3 when a default is decoded then it is a legal value of every property"""
        for row in blocks():
            if not row["PROPS"] or not row["DEFAULT"]:
                continue
            spec = parse_spec(row["PROPS"])
            index = int(row["DEFAULT"]) - int(row["FIRST"])
            strides = []
            stride = 1
            for _, values in reversed(spec):
                strides.append(stride)
                stride *= len(values)
            strides.reverse()
            picked = [(index // s) % len(v) for (_, v), s in zip(spec, strides)]
            self.assertEqual(sum(p * s for p, s in zip(picked, strides)), index, row["KEY"])

    def test_documented_default_examples(self):
        """given the worked examples of 24 parts 2 to 6 when defaults are looked up then the documents' indexes hold"""
        by_key = {r["KEY"]: r for r in blocks()}

        def offset(key):
            return int(by_key[key]["DEFAULT"]) - int(by_key[key]["FIRST"])
        self.assertEqual(offset("oak_stairs"), 11)
        self.assertEqual(offset("cobblestone_stairs"), 11)
        self.assertEqual(offset("oak_door"), 11)
        self.assertEqual(offset("oak_wall_sign"), 1)
        self.assertEqual(offset("lever"), 9)
        self.assertEqual(offset("repeater"), 3)
        self.assertEqual(offset("redstone_wire"), 1160)
        self.assertEqual(offset("fire"), 31)
        self.assertEqual(offset("chiseled_bookshelf"), 63)
        self.assertEqual(offset("note_block"), 1)
        self.assertEqual(offset("redstone_lamp"), 1)
        self.assertEqual(offset("redstone_torch"), 0)
        self.assertEqual(offset("oak_fence"), 31)
        self.assertEqual(offset("oak_fence_gate"), 7)
        self.assertEqual(offset("cobblestone_wall"), default_index(
            parse_spec(by_key["cobblestone_wall"]["PROPS"]),
            {"east": "none", "north": "none", "south": "none", "west": "none", "up": "true", "waterlogged": "false"}))
        self.assertEqual(offset("tube_coral"), 0)
        self.assertEqual(offset("observer"), 5)

    def test_family_lists_of_the_examples(self):
        """given 24 part 2 section 4 when the property lists are read then stairs, anvil and lamp list their values"""
        by_key = {r["KEY"]: r for r in blocks()}
        self.assertEqual(by_key["oak_stairs"]["PROPS"], "facing[north/south/west/east] half[top/bottom] "
                         "shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool]")
        self.assertEqual(by_key["anvil"]["PROPS"], "facing[north/south/west/east]")
        self.assertEqual(by_key["redstone_lamp"]["PROPS"], "lit[bool]")
        self.assertEqual(by_key["oak_slab"]["PROPS"], "type[top/bottom/double] waterlogged[bool]")
        self.assertEqual(by_key["oak_door"]["PROPS"], "facing[north/south/west/east] half[upper/lower] "
                         "hinge[left/right] open[bool] powered[bool]")
        self.assertEqual(by_key["white_bed"]["PROPS"], "facing[north/south/west/east] occupied[bool] part[head/foot]")

    def test_property_lists_agree_with_the_part_6_table(self):
        """given 24 part 6 section 7.1 (properties with values and default index) when compared then equal"""
        path = gen_tables.doc_files(genlib.DOCS, "24-")[5]
        by_key = {r["KEY"]: r for r in blocks()}
        checked = 0
        for t in gen_tables.parse_tables(gen_tables.read_lines(path)):
            if t["h"][:2] != ["field", "key (block)"]:
                continue
            for r in t["rows"]:
                key = r[1]
                if key not in by_key or "<" in key or r[5] == "-":
                    continue
                spec = []
                for part in r[5].split(";"):
                    name, values = (x.strip() for x in part.split(":"))
                    if values == "bool":
                        values = "true/false"
                    elif ".." in values:
                        low, high = values.split("..")
                        values = "/".join(str(n) for n in range(int(low), int(high) + 1))
                    spec.append((name, values.split("/")))
                row = by_key[key]
                self.assertEqual(parse_spec(row["PROPS"]), spec, key)
                self.assertEqual(int(row["DEFAULT"]) - int(row["FIRST"]), int(r[7]), key)
                checked += 1
        self.assertGreater(checked, 60)

    def test_default_agrees_with_the_part_2_layout_table(self):
        """given 24 part 2 section 4 (state layout and default index) when compared then the defaults equal"""
        path = gen_tables.doc_files(genlib.DOCS, "24-")[1]
        by_key = {r["KEY"]: r for r in blocks()}
        checked = 0
        for t in gen_tables.parse_tables(gen_tables.read_lines(path)):
            if t["h"][:3] != ["block (classes)", "properties in sorted order, with value counts", "states"]:
                continue
            for r in t["rows"]:
                keys = []
                for token in re.findall(r"[<>*a-z_0-9]+", r[0]):
                    if "<colour>" in token or "*" in token:
                        suffix = token.replace("<colour>", "").replace("*", "")
                        keys.extend(k for k in by_key if k.endswith(suffix) and token.endswith(suffix))
                    elif token in by_key:
                        keys.append(token)
                for key in keys:
                    if not re.fullmatch(r"[\d\s]+", r[5]) or not by_key[key]["DEFAULT"]:
                        continue
                    if int(by_key[key]["STATES"]) != int(re.sub(r"\D", "", r[2])):
                        continue
                    row = by_key[key]
                    self.assertEqual(int(row["DEFAULT"]) - int(row["FIRST"]), int(re.sub(r"\D", "", r[5])), key)
                    checked += 1
        self.assertGreater(checked, 100)

    def test_gaps_are_documented_and_counted(self):
        """given the generator when a block cannot be completed then gaps.txt names it with the reason"""
        self.assertTrue(os.path.exists(os.path.join(DIRECTORY.name, "gaps.txt")))
        missing_props = sum(1 for r in blocks() if int(r["STATES"]) > 1 and not r["PROPS"])
        self.assertEqual(missing_props, len(GAPS.get(("block", "properties"), set())))
        self.assertRegex(RUN.stdout, r"COUNT blocks without property list %d\b" % missing_props)
        missing_default = sum(1 for r in blocks() if not r["DEFAULT"])
        self.assertRegex(RUN.stdout, r"COUNT blocks without default state %d\b" % missing_default)
        self.assertEqual(missing_default, len(GAPS.get(("block", "default"), set())))
        self.assertEqual(missing_props, 0)
        self.assertEqual(GAPS, {})


class ItemCompletenessTest(unittest.TestCase):
    def test_every_item_has_a_stack_size(self):
        """given 25 parts 1 to 8 and x1 when the rows are read then every item has a stack size of 1 to 99"""
        gap = GAPS.get(("item", "stack"), set())
        missing = []
        for row in items():
            if row["KEY"] in gap:
                self.assertEqual(row["STACK"], "", row["KEY"])
                continue
            if not row["STACK"]:
                missing.append(row["KEY"])
                continue
            self.assertTrue(1 <= int(row["STACK"]) <= 99, row["KEY"])
        self.assertEqual(missing, [])
        self.assertRegex(RUN.stdout, r"COUNT items without max stack %d\b" % len(gap))

    def test_stack_sizes_of_documented_items(self):
        """given the rules of 25 parts 3 to 8 when stack sizes are looked up then the documented values hold"""
        by_key = {r["KEY"]: r for r in items()}
        expected = {"stone": 64, "oak_planks": 64, "honey_bottle": 16, "brush": 1, "snowball": 16, "bucket": 16,
                    "water_bucket": 1, "saddle": 1, "white_harness": 1, "bundle": 1, "white_bundle": 1,
                    "white_cushion": 16, "minecart": 1, "white_shulker_box": 1, "music_disc_13": 1,
                    "ender_pearl": 16, "oak_sign": 16, "iron_pickaxe": 1, "elytra": 1, "trident": 1,
                    "crossbow": 1, "suspicious_stew": 1, "goat_horn": 1, "disc_fragment_5": 64,
                    "nautilus_shell": 64, "heart_of_the_sea": 64, "loom": 64, "ominous_bottle": 64,
                    "chicken_spawn_egg": 64, "white_dye": 64, "iron_helmet": 1, "mushroom_stew": 1,
                    "egg": 16, "filled_map": 64, "oak_boat": 1, "cake": 1, "white_bed": 1, "potion": 1}
        for key, value in expected.items():
            self.assertEqual(by_key[key]["STACK"], str(value), key)

    def test_part_4_stack_census(self):
        """given 25 part 4 check 4 (ids 975 to 1127: 90 rows of 1, 26 of 16, 37 of 64) when counted then equal"""
        census = {}
        for row in items():
            if 975 <= int(row["ID"]) <= 1127:
                census[row["STACK"]] = census.get(row["STACK"], 0) + 1
        self.assertEqual(census, {"1": 90, "16": 26, "64": 37})

    def test_durable_items_have_stack_one(self):
        """given 25 part 1 section 6.4 (durability sets stack 1) when rows with a max damage are read then stack 1"""
        durable = 0
        for row in items():
            if row["MAXDAMAGE"] or re.search(r"\bmax_damage \d+", row["COMPONENTS"]):
                self.assertEqual(row["STACK"], "1", row["KEY"])
                durable += 1
        self.assertGreater(durable, 75)

    def test_max_damage_is_carried_whole(self):
        """given the 2 character MAX-DAMAGE column of the contract copybook when damage has 3 digits then the
        components carry it"""
        by_key = {r["KEY"]: r for r in items()}
        self.assertIn("max_damage 250", by_key["iron_pickaxe"]["COMPONENTS"])
        self.assertIn("max_damage 432", by_key["elytra"]["COMPONENTS"])
        self.assertIn("max_damage 336", by_key["shield"]["COMPONENTS"])
        self.assertEqual(by_key["shield"]["MAXDAMAGE"], "336")

    def test_components_are_structured_entries_and_not_cut(self):
        """given the documents when the summary is read then it is whole name-value entries within the width"""
        gap = GAPS.get(("item", "components"), set())
        for row in items():
            text = row["COMPONENTS"]
            self.assertLessEqual(len(text), COMPONENTS_WIDTH, row["KEY"])
            if row["KEY"] in gap:
                continue
            for entry in text.split(", ") if text else []:
                self.assertRegex(entry, r"[a-z_0-9]+( \S.*)?", row["KEY"])
                self.assertEqual(entry, entry.strip(), row["KEY"])
                self.assertNotIn("`", entry, row["KEY"])
                self.assertNotIn("(section", entry, row["KEY"])
        by_key = {r["KEY"]: r for r in items()}
        self.assertIn("enchantment_glint_override true", by_key["enchanted_golden_apple"]["COMPONENTS"])
        self.assertIn("blocks_attacks", by_key["shield"]["COMPONENTS"])
        self.assertIn("use_remainder glass_bottle", by_key["honey_bottle"]["COMPONENTS"])
        self.assertIn("fuel wood_blocks", by_key["oak_log"]["COMPONENTS"])
        self.assertIn("compostable low", by_key["oak_sapling"]["COMPONENTS"])
        self.assertEqual(by_key["stone"]["COMPONENTS"], "")

    def test_item_gaps_are_none(self):
        """given the widened contract width when summaries are generated then none overflows"""
        self.assertEqual(GAPS.get(("item", "components"), set()), set())

    def test_the_four_long_summaries_are_whole(self):
        """given 25 parts 3, 4, 6 and 7 when the four former overflow items are read then no entry is lost"""
        by_key = {r["KEY"]: r["COMPONENTS"] for r in items()}
        self.assertIn("consumable enchanted_golden_apple", by_key["enchanted_golden_apple"])
        self.assertIn("mob_visibility {piglin,piglin_brute} 0.5", by_key["piglin_head"])
        self.assertIn("equippable offhand unswappable", by_key["shield"])
        self.assertIn("repairable tag wooden_tool_materials", by_key["shield"])
        self.assertIn("repairable item tag repairs_turtle_helmet", by_key["turtle_helmet"])

    def test_max_damage_column_holds_four_digits(self):
        """given 17 section 2 when tool durabilities are read then the numeric column carries them whole"""
        by_key = {r["KEY"]: r for r in items()}
        self.assertEqual(by_key["iron_pickaxe"]["MAXDAMAGE"], "250")
        self.assertEqual(by_key["diamond_pickaxe"]["MAXDAMAGE"], "1561")
        self.assertEqual(by_key["netherite_sword"]["MAXDAMAGE"], "2031")
        self.assertEqual(by_key["elytra"]["MAXDAMAGE"], "432")
        widths = {n: w for n, _, w in table("items.cpy", "ITEM").columns}
        self.assertEqual(widths["MAXDAMAGE"], MAXDAMAGE_WIDTH)
        self.assertEqual(widths["COMPONENTS"], COMPONENTS_WIDTH)
        self.assertEqual({n: w for n, _, w in table("blocks.cpy", "BLOCK").columns}["PROPS"], PROPS_WIDTH)

    def test_note_block_and_bookshelf_lists_are_whole(self):
        """given 24 part 2 section 4 when the two long lists are read then every value is named"""
        by_key = {r["KEY"]: r["PROPS"] for r in blocks()}
        note = parse_spec(by_key["note_block"])
        self.assertEqual([n for n, _ in note], ["instrument", "note", "powered"])
        self.assertEqual(len(note[0][1]), 27)
        self.assertEqual(note[0][1][0], "harp")
        shelf = parse_spec(by_key["chiseled_bookshelf"])
        self.assertEqual(len(shelf), 7)
        self.assertEqual(shelf[0][0], "facing")


if __name__ == "__main__":
    unittest.main()
