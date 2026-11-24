"""Acceptance test F2US2: the flags of every generated block against the documents and the extracted data (T48000).

The core reads three words of the flags column of content/copy/gen/blocks.cpy (core/src/block-props.cob): noCollision (or
air) makes a block non-solid, noOcclusion makes it translucent and " replaceable " lets a placement replace it. A row of
24 part 2 section 5 that names its blocks by an ordinal range or by words ("140 to 154 the fifteen flowers", "119 each
`<colour>_bed`") once reached no block, so the fifteen flowers were solid.

The extracted data (CC_GENERATED_DIR, the extraction tool's output) carries no block report, so collision and occlusion
have no per-block record there. What it does carry is the tags of the jar: `replaceable` and `air` are the exact sets of
the two flags, and the tags of blocks that never collide (flowers, buttons, rails, crops, plates, signs, corals, ...) say
which blocks must carry noCollision. Those cases skip when the extracted data is absent.
"""
import json
import os
import re
import shutil
import tempfile
import unittest

import genlib

GENERATED = os.environ.get("CC_GENERATED_DIR", "")
TAGS = os.path.join(GENERATED, "vanilla-data", "data", "minecraft", "tags", "block")
COMMITTED = os.path.join(genlib.REPO, "content", "copy", "gen", "blocks.cpy")

# Tags whose every member has no collision (the documents' rows give noCollision to each).
NEVER_COLLIDES = ["small_flowers", "buttons", "rails", "crops", "coral_plants", "wall_corals", "pressure_plates", "signs",
                  "all_hanging_signs", "fire", "cave_vines", "portals", "saplings"]
# Members of those tags the documents give a collision shape (24 part 8 rows 853 and 854: AzaleaBlock, no noCollision).
HAS_COLLISION = {"azalea", "flowering_azalea"}
# Members of tag `replaceable` that are replaceable but still collide (24 part 5 row `light`: replaceable noLootTable
# noOcclusion; `snow` is a layer block with a collision shape).
REPLACEABLE_AND_SOLID = {"light", "snow"}


def blocks():
    return {r["KEY"]: r for r in genlib.Table(COMMITTED, "BLOCK").rows()}


def words(row):
    return set(row["FLAGS"].split())


def tag(name, seen=()):
    """Block keys of a tag of the extracted data, nested tags expanded."""
    with open(os.path.join(TAGS, name + ".json"), encoding="utf-8") as handle:
        values = json.load(handle)["values"]
    out = set()
    for value in values:
        value = value["id"] if isinstance(value, dict) else value
        if value.startswith("#"):
            out |= tag(value[1:].split(":", 1)[1])
        else:
            out.add(value.split(":", 1)[1])
    return out


def need_extracted_data(test):
    return unittest.skipUnless(os.path.isdir(TAGS), "CC_GENERATED_DIR holds no extracted block tags")(test)


class AcceptanceF2US2BlockFlags(unittest.TestCase):
    def test_acceptance_F2US2_flags_are_words(self):
        """acceptance F2US2-20 given the generated blocks when the flags are read then none holds a comma or a semicolon"""
        bad = [k for k, r in blocks().items() if re.search(r"[,;]", r["FLAGS"])]
        self.assertEqual(bad, [])

    def test_acceptance_F2US2_ranges_and_collections_of_part_2_carry_their_flags(self):
        """acceptance F2US2-21 given 24 part 2 section 5 when the range rows are read then flowers, beds, buttons carry flags"""
        rows = blocks()
        flowers = ["dandelion", "golden_dandelion", "torchflower", "poppy", "blue_orchid", "allium", "azure_bluet",
                   "red_tulip", "orange_tulip", "white_tulip", "pink_tulip", "oxeye_daisy", "cornflower", "wither_rose",
                   "lily_of_the_valley"]
        self.assertEqual(len(flowers), 15)
        for key in flowers:
            self.assertIn("noCollision", words(rows[key]), key)
            self.assertEqual(rows[key]["HARDNESS"], "0", key)
        beds = [k for k in rows if k.endswith("_bed")]
        self.assertEqual(len(beds), 17)  # the 16 colours and straw_bed (row 120)
        for key in beds:
            self.assertIn("noOcclusion", words(rows[key]), key)
        buttons = [k for k in rows if k.endswith("_button") and k.split("_")[0] in
                   ("oak", "spruce", "birch", "jungle", "acacia", "cherry", "dark", "pale", "mangrove", "poplar", "bamboo")]
        self.assertEqual(len(buttons), 11)
        for key in buttons:
            self.assertIn("noCollision", words(rows[key]), key)
        potted = [k for k in rows if k.startswith("potted_")] + ["flower_pot"]
        self.assertEqual(len(potted), 40)
        for key in potted:
            self.assertIn("noOcclusion", words(rows[key]), key)
        bars = [k for k in rows if k.endswith("copper_bars") or k.endswith("copper_chain")]
        self.assertEqual(len(bars), 16)
        for key in bars:
            self.assertIn("noOcclusion", words(rows[key]), key)

    @need_extracted_data
    def test_acceptance_F2US2_replaceable_is_the_extracted_tag(self):
        """acceptance F2US2-22 given tag replaceable of the extracted data when compared then the flag marks the same blocks"""
        rows = blocks()
        want = tag("replaceable")
        self.assertEqual(want - set(rows), set())
        got = {k for k, r in rows.items() if "replaceable" in words(r)}
        self.assertEqual(sorted(got - want), [])
        self.assertEqual(sorted(want - got), [])

    @need_extracted_data
    def test_acceptance_F2US2_air_is_the_extracted_tag(self):
        """acceptance F2US2-23 given tag air of the extracted data when compared then the flag marks the same blocks"""
        rows = blocks()
        want = tag("air")
        got = {k for k, r in rows.items() if "air" in words(r)}
        self.assertEqual(sorted(got ^ want), [])

    @need_extracted_data
    def test_acceptance_F2US2_blocks_that_never_collide_carry_noCollision(self):
        """acceptance F2US2-24 given the extracted tags of non-colliding blocks when compared then each member has the flag"""
        rows = blocks()
        missing = []
        members = set()
        for name in NEVER_COLLIDES:
            for key in tag(name) - HAS_COLLISION:
                members.add(key)
                if key not in rows:
                    missing.append("%s (tag %s) is no block" % (key, name))
                elif "noCollision" not in words(rows[key]):
                    missing.append("%s (tag %s)" % (key, name))
        for key in tag("replaceable") - REPLACEABLE_AND_SOLID:
            members.add(key)
            if "noCollision" not in words(rows[key]) and "air" not in words(rows[key]):
                missing.append("%s (tag replaceable)" % key)
        self.assertGreater(len(members), 150)
        self.assertEqual(missing, [])

    def test_acceptance_F2US2_a_flag_row_that_reaches_no_block_fails_the_generator(self):
        """acceptance F2US2-25 given a part 2 row whose ordinals are lost when --write runs then it exits 1 naming the row"""
        scratch = tempfile.TemporaryDirectory()
        try:
            docs = os.path.join(scratch.name, "protocol")
            shutil.copytree(genlib.DOCS, docs)
            path = os.path.join(docs, "24-block-registry-2-leaves-flora-signs.md")
            with open(path, encoding="utf-8") as handle:
                text = handle.read()
            self.assertIn("| 140 to 154 the fifteen flowers |", text)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(text.replace("| 140 to 154 the fifteen flowers |", "| the fifteen flowers |"))
            out = tempfile.TemporaryDirectory()
            try:
                run = genlib.run("--write", "--out", out.name, "--docs", docs)
            finally:
                out.cleanup()
            self.assertEqual(run.returncode, 1, run.stdout)
            self.assertIn("PROBLEM flags of a row reach no block", run.stdout)
            self.assertIn("the fifteen flowers", run.stdout)
        finally:
            scratch.cleanup()


if __name__ == "__main__":
    unittest.main()
