"""Acceptance test F2US2: the item table generated from docs/protocol/25-item-registry-1..8 and x1 (T0068)."""
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


def items():
    return genlib.Table(os.path.join(DIRECTORY.name, "items.cpy"), "ITEM")


class AcceptanceF2US2GenItems(unittest.TestCase):
    def test_acceptance_F2US2_item_count_equals_the_validation_section(self):
        """acceptance F2US2-8 given 25 part 8 section 13 (V2, V3) when items.cpy is read then 1658 ids 0 to 1657"""
        self.assertEqual(RUN.returncode, 0, RUN.stdout)
        self.assertIn("COUNT items 1658", RUN.stdout)
        table = items()
        self.assertEqual(table.count, 1658)
        self.assertEqual([int(r["ID"]) for r in table.rows()], list(range(1658)))
        self.assertEqual(len({r["KEY"] for r in table.rows()}), 1658)

    def test_acceptance_F2US2_anchor_items_of_section_14(self):
        """acceptance F2US2-9 given 25 part 1 section 14 and part 8 section 11.6 when ids are looked up then keys equal"""
        keys = {int(r["ID"]): r["KEY"] for r in items().rows()}
        anchors = {0: "air", 1: "stone", 63: "oak_planks", 77: "oak_sapling", 87: "bedrock", 111: "ancient_debris",
                   120: "copper_block", 128: "gold_block", 163: "oak_log", 215: "oak_leaves", 227: "azalea_leaves",
                   1505: "composter", 1577: "echo_shard", 1657: "ominous_bottle"}
        for number, key in anchors.items():
            self.assertEqual(keys[number], key)

    def test_acceptance_F2US2_row_layout_and_block_link(self):
        """acceptance F2US2-10 given data-model section 2 when read then 400-character rows and block links"""
        table = items()
        for size, value in table.literals:
            self.assertEqual((size, len(value)), ("400", 400))
        by_key = {r["KEY"]: r for r in table.rows()}
        self.assertEqual(by_key["stone"]["BLOCK"], "1")
        self.assertEqual(by_key["stone"]["STACK"], "64")
        self.assertEqual(by_key["composter"]["BLOCK"] != "", True)


if __name__ == "__main__":
    unittest.main()
