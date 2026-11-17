"""Implementation tests of tools/coverage.py against hand-written gcov output fixtures."""
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import coverage

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


class Objects(unittest.TestCase):
    def test_library_and_convergence_entry_objects(self):
        build = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, build)
        for relative in ["client/obj/loop.o", "client/obj/screens/title.o", "convergence/obj/client/main.o",
                         "convergence/obj/server/main.o", "convergence/tests/acc_x.o", "client/obj/x.gcda"]:
            os.makedirs(os.path.dirname(os.path.join(build, relative)), exist_ok=True)
            open(os.path.join(build, relative), "w").close()
        self.assertEqual(
            coverage.objects(build, "client"),
            sorted(os.path.join(build, r) for r in
                   ["client/obj/loop.o", "client/obj/screens/title.o", "convergence/obj/client/main.o"]),
        )
        self.assertEqual(coverage.objects(build, "core"), [])


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

    def test_new_packages_and_generated_registry_copybooks(self):
        packages = ["formats", "content", "extract"]
        for path in ["formats/src/nbt.cob", "content/src/blocks.cob", "content/copy/CONTENTSTATE.cpy", "extract/src/main.cob"]:
            self.assertTrue(coverage.is_production(path, packages), path)
        for path in ["content/copy/gen/BLOCKS.cpy", "content/copy/gen/sub/ITEMS.cpy", "content/tests/test_x.cob"]:
            self.assertFalse(coverage.is_production(path, packages), path)

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


DIFF = """\
diff --git a/core/src/api.cob b/core/src/api.cob
index 1111111..2222222 100644
--- a/core/src/api.cob
+++ b/core/src/api.cob
@@ -6 +7,2 @@ old
+new line 7
+new line 8
@@ -20,3 +22,0 @@ removed only
-gone
@@ -30 +31 @@ one changed line
-before
+after
diff --git a/core/src/gone.cob b/core/src/gone.cob
deleted file mode 100644
--- a/core/src/gone.cob
+++ /dev/null
@@ -1,2 +0,0 @@
-a
-b
diff --git a/core/copy/TABLES.cpy b/core/copy/TABLES.cpy
new file mode 100644
--- /dev/null
+++ b/core/copy/TABLES.cpy
@@ -0,0 +1,3 @@
+a
+b
+c
"""


class ChangedLines(unittest.TestCase):
    def test_diff_hunks_give_the_new_line_numbers(self):
        self.assertEqual(
            coverage.parse_diff(DIFF),
            {"core/src/api.cob": {7, 8, 31}, "core/copy/TABLES.cpy": {1, 2, 3}},
        )

    def test_uncovered_lines_are_kept_only_where_changed(self):
        uncovered = ["core/copy/TABLES.cpy:2", "core/src/api.cob:7", "core/src/api.cob:9", "core/src/world.cob:4"]
        changed = {"core/src/api.cob": {7, 8, 31}, "core/copy/TABLES.cpy": {1, 3}}
        self.assertEqual(coverage.restrict(uncovered, changed), ["core/src/api.cob:7"])

    def test_a_whole_file_counts_when_its_lines_are_not_known(self):
        # an untracked file: every line is new
        uncovered = ["core/src/api.cob:7", "core/src/new.cob:1", "core/src/new.cob:9"]
        self.assertEqual(
            coverage.restrict(uncovered, {"core/src/new.cob": None}), ["core/src/new.cob:1", "core/src/new.cob:9"]
        )

    def test_packages_with_changed_production_sources(self):
        changed = {"core/src/api.cob": {1}, "client/src/screens/chat.cob": {2}, "core/tests/test_x.cob": {3}, "docs/a.md": None}
        self.assertEqual(coverage.changed_packages(changed), ["core", "client"])

    def test_changes_against_a_reference_in_a_repository(self):
        repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, repo)

        def git(*arguments):
            subprocess.run(
                ["git", "-c", "user.name=t", "-c", "user.email=t@example.invalid", *arguments],
                cwd=repo, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )

        def write(relative, text):
            os.makedirs(os.path.dirname(os.path.join(repo, relative)), exist_ok=True)
            with open(os.path.join(repo, relative), "w", encoding="utf-8") as handle:
                handle.write(text)

        git("init", "-q", "-b", "trunk")
        write("core/src/a.cob", "one\ntwo\nthree\n")
        git("add", "-A")
        git("commit", "-q", "-m", "base")
        git("checkout", "-q", "-b", "lane")
        write("core/src/a.cob", "one\ntwo changed\nthree\nfour\n")
        git("commit", "-q", "-am", "lane work")
        # the reference moved on after the lane branched: its changes are not the lane's
        git("checkout", "-q", "trunk")
        write("core/src/c.cob", "trunk only\n")
        git("add", "-A")
        git("commit", "-q", "-m", "trunk moves")
        git("checkout", "-q", "lane")
        write("core/src/a.cob", "one\ntwo changed\nthree\nfour\nfive uncommitted\n")
        write("core/src/b.cob", "untracked\n")
        self.assertEqual(
            coverage.changed_lines(repo, "trunk"), {"core/src/a.cob": {2, 4, 5}, "core/src/b.cob": None}
        )


if __name__ == "__main__":
    unittest.main()
