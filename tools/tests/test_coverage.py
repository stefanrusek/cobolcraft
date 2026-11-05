"""Implementation tests of tools/coverage.py against hand-written gcov output fixtures."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import coverage  # noqa: E402

FIXTURES = os.path.join(os.path.dirname(__file__), "fixtures", "coverage")


def fixture(name):
    with open(os.path.join(FIXTURES, name), encoding="utf-8") as handle:
        return handle.read()


def outputs():
    """(package directory gcov ran in, gcov text) pairs; the fixtures' repository root is /repo."""
    return [
        ("/repo/core", fixture("core-api.gcov.txt")),
        ("/repo/core", fixture("core-world.gcov.txt")),
        ("/repo/core", fixture("excluded.gcov.txt")),
        ("/repo/shim", fixture("shim-net.gcov.txt")),
    ]


class Parsing(unittest.TestCase):
    def test_sections_and_line_states(self):
        sections = coverage.parse_gcov(fixture("core-api.gcov.txt"))
        self.assertEqual([source for source, _ in sections], ["/var/folders/xx/T/cob1_0.c", "src/api.cob", "copy/TABLES.cpy"])
        self.assertEqual(sections[1][1], {3: True, 4: True, 5: True, 7: False, 9: False, 10: True})

    def test_exceptional_only_lines_are_unexecuted(self):
        sections = coverage.parse_gcov(fixture("core-world.gcov.txt"))
        self.assertEqual(sections[1][1], {4: False})


class ProductionSet(unittest.TestCase):
    def test_production_sources(self):
        all_packages = ["shim", "proto", "core", "server", "client"]
        for path in [
            "shim/src/cc_net.c",
            "proto/src/buffer.cob",
            "core/src/api.cob",
            "core/copy/TABLES.cpy",
            "server/src/main.cob",
            "client/src/main.cob",
            "client/src/screens/title.cob",
        ]:
            self.assertTrue(coverage.is_production(path, all_packages), path)

    def test_excluded_and_other_paths(self):
        all_packages = ["shim", "proto", "core", "server", "client"]
        for path in [
            "core/tests/test_api.cob",
            "client/tests/fixtures/x.cob",
            "tools/testlib/testassert.cob",
            "specs/001-cobolcraft-complete/spikes/spike_coverage.cob",
            "contract/copy/PROTO.cpy",
            "client/copy/CLSTATE.cpy",
            "shim/src/cc_net.h",
            "../outside/src/x.cob",
        ]:
            self.assertFalse(coverage.is_production(path, all_packages), path)

    def test_only_selected_packages(self):
        self.assertFalse(coverage.is_production("shim/src/cc_net.c", ["core"]))


class Collecting(unittest.TestCase):
    def test_never_executed_production_lines_are_listed(self):
        self.assertEqual(
            coverage.collect(outputs(), "/repo", ["shim", "core"]),
            [
                "core/copy/TABLES.cpy:2",
                "core/src/api.cob:7",
                "core/src/api.cob:9",
                "core/src/world.cob:4",
                "shim/src/cc_net.c:2",
            ],
        )

    def test_scoped_to_selected_packages(self):
        self.assertEqual(
            coverage.collect(outputs(), "/repo", ["shim"]),
            ["shim/src/cc_net.c:2"],
        )

    def test_full_coverage_lists_nothing(self):
        self.assertEqual(coverage.collect(outputs(), "/repo", ["proto"]), [])


if __name__ == "__main__":
    unittest.main()
