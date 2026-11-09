"""Acceptance test F2US2: the block tables generated from docs/protocol/24-block-registry-1..8 (T0066)."""
import os
import unittest

import genlib

DIRECTORY = None
RUN = None


def setUpModule():
    global DIRECTORY, RUN
    DIRECTORY, RUN = genlib.generate()


def tearDownModule():
    DIRECTORY.cleanup()


def blocks():
    return genlib.Table(os.path.join(DIRECTORY.name, "blocks.cpy"), "BLOCK")


class AcceptanceF2US2GenBlocks(unittest.TestCase):
    def test_acceptance_F2US2_generation_exits_zero_and_prints_counts(self):
        """acceptance F2US2-1 given the block documents when --write runs then it exits 0 and prints the counts"""
        self.assertEqual(RUN.returncode, 0, RUN.stdout)
        self.assertIn("COUNT blocks 1286", RUN.stdout)
        self.assertIn("COUNT block states 35723", RUN.stdout)

    def test_acceptance_F2US2_counts_equal_the_validation_section(self):
        """acceptance F2US2-2 given 24 part 8 section 11.1 when the table is read back then 1286 blocks and 35723 states"""
        table = blocks()
        rows = table.rows()
        self.assertEqual(table.count, 1286)
        self.assertEqual(len(rows), 1286)
        self.assertEqual(sum(int(r["STATES"]) for r in rows), 35723)
        self.assertEqual([int(r["ID"]) for r in rows], list(range(1286)))
        self.assertEqual(rows[-1]["KEY"], "firefly_bush")
        self.assertEqual(int(rows[-1]["FIRST"]), 35722)

    def test_acceptance_F2US2_state_ranges_are_contiguous(self):
        """acceptance F2US2-3 given the rows when state ranges are walked then no gap and no overlap"""
        expected = 0
        for row in blocks().rows():
            self.assertEqual(int(row["FIRST"]), expected, row["KEY"])
            expected += int(row["STATES"])

    def test_acceptance_F2US2_worked_examples_of_section_16(self):
        """acceptance F2US2-4 given 24 part 1 section 16 when examples 1 to 4 are looked up then the ids equal"""
        by_key = {r["KEY"]: r for r in blocks().rows()}
        log = by_key["oak_log"]
        self.assertEqual((int(log["STATES"]), int(log["FIRST"]), int(log["DEFAULT"])), (3, 139, 140))
        leaves = by_key["oak_leaves"]
        self.assertEqual((int(leaves["STATES"]), int(leaves["FIRST"]), int(leaves["DEFAULT"])), (28, 267, 294))
        self.assertEqual(int(by_key["spruce_leaves"]["FIRST"]), 295)
        propagule = by_key["mangrove_propagule"]
        self.assertEqual((int(propagule["STATES"]), int(propagule["FIRST"]), int(propagule["DEFAULT"])), (40, 46, 51))
        self.assertEqual(int(by_key["poplar_sapling"]["FIRST"]), 86)
        self.assertEqual((int(by_key["water"]["FIRST"]), int(by_key["water"]["STATES"])), (89, 16))
        self.assertEqual(int(by_key["sand"]["FIRST"]), 121)
        stone = by_key["stone"]
        self.assertEqual((stone["HARDNESS"], stone["BLAST"], stone["TOOL"]), ("1.5", "6.0", "yes"))
        self.assertEqual(by_key["dirt"]["HARDNESS"], "0.5")

    def test_acceptance_F2US2_part_boundaries_and_collections(self):
        """acceptance F2US2-5 given 24 part 8 section 11.2 and Appendix A when seams are looked up then they equal"""
        by_key = {r["KEY"]: r for r in blocks().rows()}
        self.assertEqual((int(by_key["orange_poplar_leaves"]["FIRST"]), int(by_key["orange_poplar_leaves"]["STATES"])), (547, 28))
        self.assertEqual(int(by_key["yellow_poplar_leaves"]["FIRST"]), 575)
        poly = by_key["polished_blackstone_wall"]
        self.assertEqual((int(poly["ID"]), int(poly["FIRST"]), int(poly["STATES"])), (1030, 26126, 324))
        self.assertEqual(int(by_key["chiseled_nether_bricks"]["FIRST"]), 26450)
        self.assertEqual((int(by_key["white_bed"]["ID"]), int(by_key["black_bed"]["ID"])), (119, 134))
        self.assertEqual(int(by_key["white_candle"]["FIRST"]), 26469)
        self.assertEqual(int(by_key["black_candle_cake"]["ID"]), 1067)
        self.assertEqual(int(by_key["waxed_oxidized_copper"]["ID"]), 1131)
        self.assertEqual(int(by_key["potted_azalea_bush"]["ID"]) > 0, True)

    def test_acceptance_F2US2_rows_are_400_character_literals(self):
        """acceptance F2US2-6 given data-model section 2 when the copybook is read then every literal row is 400 characters"""
        for name, prefix in (("blocks.cpy", "BLOCK"), ("blockprops.cpy", "BLOCKPROP")):
            table = genlib.Table(os.path.join(DIRECTORY.name, name), prefix)
            self.assertTrue(table.literals, name)
            for size, value in table.literals:
                self.assertEqual((size, len(value)), ("400", 400), name)
            self.assertEqual(len(table.data), -(-table.count * table.width // 400) * 400, name)
            with open(os.path.join(DIRECTORY.name, name), encoding="ascii") as handle:
                self.assertLessEqual(max(len(line) for line in handle.read().split("\n")), 512, name)

    def test_acceptance_F2US2_block_property_table(self):
        """acceptance F2US2-7 given 24 part 1 section 13 when blockprops is read then axis and snowy are defined"""
        table = genlib.Table(os.path.join(DIRECTORY.name, "blockprops.cpy"), "BLOCKPROP")
        pairs = {(r["NAME"], r["VALUES"]) for r in table.rows()}
        self.assertIn(("snowy", "true, false"), pairs)
        self.assertIn(("axis", "x, y, z"), {(n, v[:7]) for n, v in pairs})


if __name__ == "__main__":
    unittest.main()
