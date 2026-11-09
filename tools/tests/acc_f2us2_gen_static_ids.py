"""Acceptance test F2US2: static registry ids, entity types and tag names (T0070)."""
import os
import unittest

import genlib

DIRECTORY = None
RUN = None
COUNTS = {"mob_effect": 40, "attribute": 40, "potion": 46, "particle_type": 128, "game_event": 61, "fluid": 5,
          "block_entity_type": 49, "menu": 25, "map_decoration_type": 40, "villager_type": 7,
          "villager_profession": 15, "point_of_interest_type": 21, "stat_type": 9, "custom_stat": 78,
          "data_component_type": 122, "consume_effect_type": 5, "number_format_type": 3, "recipe_display": 5,
          "slot_display": 11, "recipe_book_category": 13, "recipe_type": 8, "recipe_serializer": 22,
          "data_component_predicate_type": 15, "command_argument_type": 62, "debug_subscription": 16,
          "position_source_type": 2, "sound_event": 1991}


def setUpModule():
    global DIRECTORY, RUN
    DIRECTORY, RUN = genlib.generate()


def tearDownModule():
    DIRECTORY.cleanup()


def table(name, prefix):
    return genlib.Table(os.path.join(DIRECTORY.name, name), prefix)


class AcceptanceF2US2GenStaticIds(unittest.TestCase):
    def test_acceptance_F2US2_counts_of_section_16(self):
        """acceptance F2US2-11 given 46 section 16 when staticids.cpy is read then every registry has its count"""
        self.assertEqual(RUN.returncode, 0, RUN.stdout)
        seen = {}
        for row in table("staticids.cpy", "STATIC").rows():
            seen[row["REGISTRY"]] = seen.get(row["REGISTRY"], 0) + 1
        for registry, count in COUNTS.items():
            self.assertEqual(seen.get(registry), count, registry)

    def test_acceptance_F2US2_ids_are_row_positions(self):
        """acceptance F2US2-12 given 46 section 2 when read then each registry's ids are 0 to n-1"""
        per = {}
        for row in table("staticids.cpy", "STATIC").rows():
            per.setdefault(row["REGISTRY"], []).append(int(row["ID"]))
        for registry, ids in per.items():
            self.assertEqual(ids, list(range(len(ids))), registry)

    def test_acceptance_F2US2_worked_examples_of_section_15(self):
        """acceptance F2US2-13 given 46 section 15 examples 1 to 11 when ids are looked up then they equal"""
        lookup = {(r["REGISTRY"], r["KEY"]): int(r["ID"]) for r in table("staticids.cpy", "STATIC").rows()}
        expected = {("mob_effect", "speed"): 0, ("mob_effect", "haste"): 2, ("mob_effect", "regeneration"): 9,
                    ("menu", "crafting"): 12, ("menu", "generic_9x3"): 2, ("menu", "hopper"): 16,
                    ("menu", "furnace"): 14, ("command_argument_type", "brigadier:integer"): 3,
                    ("command_argument_type", "entity"): 6, ("command_argument_type", "uuid"): 61,
                    ("block_entity_type", "chest"): 1, ("block_entity_type", "sign"): 7,
                    ("block_entity_type", "furnace"): 0, ("particle_type", "block"): 1,
                    ("particle_type", "flash"): 52, ("particle_type", "dust"): 21, ("particle_type", "heart"): 55,
                    ("particle_type", "vibration"): 58, ("stat_type", "custom"): 8, ("custom_stat", "jump"): 23,
                    ("sound_event", "entity.allay.ambient_with_item"): 0, ("sound_event", "entity.cat.ambient"): 288,
                    ("sound_event", "entity.wolf.ambient"): 1807, ("sound_event", "item.honey_bottle.drink"): 844,
                    ("sound_event", "entity.horse.ambient"): 853, ("point_of_interest_type", "test_instance"): 19,
                    ("point_of_interest_type", "lightning_rod"): 20, ("data_component_type", "custom_name"): 6,
                    ("data_component_type", "max_damage"): 2, ("data_component_type", "tool"): 28,
                    ("data_component_type", "waxed"): 120}
        for key, number in expected.items():
            self.assertEqual(lookup.get(key), number, key)

    def test_acceptance_F2US2_entity_types(self):
        """acceptance F2US2-14 given 21 section 2 and 46 section 11 when entities.cpy is read then 161 rows and anchors"""
        entities = table("entities.cpy", "ENTITY")
        rows = entities.rows()
        self.assertEqual(entities.count, 161)
        self.assertEqual([int(r["ID"]) for r in rows], list(range(161)))
        by_key = {r["KEY"]: r for r in rows}
        for key, number in (("pig", 101), ("item", 72), ("player", 159), ("fishing_bobber", 160)):
            self.assertEqual(int(by_key[key]["ID"]), number)
        self.assertTrue(by_key["pig"]["SIZE"] and by_key["pig"]["CATEGORY"])

    def test_acceptance_F2US2_tag_names(self):
        """acceptance F2US2-15 given 24 part 1 section 12.3 when tagnames.cpy is read then 218 + 66 + 17 names"""
        tags = table("tagnames.cpy", "TAGNAME")
        sources = {}
        for row in tags.rows():
            sources[row["SOURCE"]] = sources.get(row["SOURCE"], 0) + 1
        self.assertEqual(sources, {"BlockTags": 218, "BlockItemTags": 66, "ItemOnly": 17})
        keys = {r["KEY"] for r in tags.rows()}
        for name in ("mob_interactable_doors", "wool", "logs_that_burn"):
            self.assertIn(name, keys)


if __name__ == "__main__":
    unittest.main()
