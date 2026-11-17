"""Implementation tests of tools/tasks.py."""
import contextlib
import io
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import tasks

ONE_FILE = """\
# Tasks: a feature

Header text.

## Conventions

- a rule that is no task

## Phase 1: Setup

- [x] T001 first
- [ ] T002 second

## PARALLEL GROUP

> lanes

### Lane: core

Lane text.

#### Phase 45b: features (continued)

- [ ] T100 a feature
  - a note under it

#### Phase 46: structures

- [x] T110 a structure

### Lane: client

#### Phase 67: particles

- [ ] T200 a particle

## Phase 76: Convergence

- [ ] T300 the gate

## Notes

- a note

## Lane 002-lane-trees (T4400+)

- [x] T4400 trees

## Phase mobsa2: species leftovers (lane 002-lane-mobsa2)

- [ ] T7400 a species

### Lane models2 (T8500-T8599): overlays
- [x] T8500 overlays

## Lane 002-lane-trees (T4400+)

- [x] T4400 trees
"""


class Splitting(unittest.TestCase):
    def setUp(self):
        self.files, self.index, self.repeated = tasks.split_text(ONE_FILE)

    def test_every_phase_and_lane_is_a_file(self):
        self.assertEqual(
            sorted(self.files),
            [
                "client/phase-67.md", "core/phase-45b.md", "core/phase-46.md", "lanes/mobsa2.md", "lanes/models2.md",
                "lanes/trees.md", "phase-1.md", "phase-76.md",
            ],
        )

    def test_a_file_holds_its_heading_and_body_unchanged(self):
        self.assertEqual(
            self.files["core/phase-45b.md"],
            "#### Phase 45b: features (continued)\n\n- [ ] T100 a feature\n  - a note under it\n",
        )
        self.assertEqual(self.files["phase-1.md"], "## Phase 1: Setup\n\n- [x] T001 first\n- [ ] T002 second\n")

    def test_a_lane_list_ends_at_the_next_lane_of_a_lower_level(self):
        self.assertEqual(
            self.files["lanes/mobsa2.md"],
            "## Phase mobsa2: species leftovers (lane 002-lane-mobsa2)\n\n- [ ] T7400 a species\n",
        )
        self.assertEqual(self.files["lanes/models2.md"], "### Lane models2 (T8500-T8599): overlays\n- [x] T8500 overlays\n")

    def test_the_index_keeps_the_rest_and_links_the_phases(self):
        self.assertEqual(
            self.index,
            """\
# Tasks: a feature

Header text.

## Conventions

- a rule that is no task

- [Phase 1: Setup](tasks/phase-1.md)

## PARALLEL GROUP

> lanes

### Lane: core

Lane text.

- [Phase 45b: features (continued)](tasks/core/phase-45b.md)

- [Phase 46: structures](tasks/core/phase-46.md)

### Lane: client

- [Phase 67: particles](tasks/client/phase-67.md)

- [Phase 76: Convergence](tasks/phase-76.md)

## Notes

- a note




""",
        )

    def test_an_exact_repeat_is_dropped(self):
        self.assertEqual(self.files["lanes/trees.md"], "## Lane 002-lane-trees (T4400+)\n\n- [x] T4400 trees\n")
        self.assertEqual(self.repeated, [])

    def test_a_different_repeat_is_kept_and_named(self):
        files, _, repeated = tasks.split_text("## Lane a (T1+)\n- [x] T1 one\n\n## Lane a (T1+)\n- [x] T1 one\n- [ ] T2 two\n")
        self.assertEqual(files["lanes/a.md"], "## Lane a (T1+)\n- [x] T1 one\n\n## Lane a (T1+)\n- [x] T1 one\n- [ ] T2 two\n")
        self.assertEqual(repeated, ["lanes/a.md"])

    def test_no_task_is_lost(self):
        kept = tasks.counts(self.index)[0] + sum(tasks.counts(body)[0] for body in self.files.values())
        self.assertEqual(kept, tasks.counts(ONE_FILE)[0])

    def test_lane_names_as_file_names(self):
        self.assertEqual(tasks.slug("002-lane-trees"), "trees")
        self.assertEqual(tasks.slug("mobsb3"), "mobsb3")
        self.assertEqual(tasks.slug("Models_2"), "models-2")


class Folder(unittest.TestCase):
    def setUp(self):
        self.feature = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.feature)
        tasks.write(os.path.join(self.feature, "tasks.md"), ONE_FILE)

    def run_main(self, *arguments):
        printed = io.StringIO()
        with contextlib.redirect_stdout(printed):
            status = tasks.main(list(arguments))
        return status, printed.getvalue()

    def test_split_writes_the_files_and_the_index_with_its_notes(self):
        status, printed = self.run_main("split", self.feature)
        self.assertEqual(status, 0)
        self.assertEqual(printed, "split: 8 files, 5 open and 4 done tasks (the one file had 5 and 5)\n")
        index = tasks.read(os.path.join(self.feature, "tasks.md"))
        self.assertIn("**Layout**: this file is the index.", index.split("## Conventions")[0])
        self.assertTrue(index.rstrip().endswith("prints the whole list as one document."))
        self.assertEqual(
            tasks.read(os.path.join(self.feature, "tasks", "client", "phase-67.md")),
            "#### Phase 67: particles\n\n- [ ] T200 a particle\n",
        )

    def test_split_refuses_a_second_time(self):
        self.run_main("split", self.feature)
        status, printed = self.run_main("split", self.feature)
        self.assertEqual(status, 1)
        self.assertIn("exists already", printed)

    def test_status_counts_every_file(self):
        self.run_main("split", self.feature)
        _, printed = self.run_main("status", self.feature, "--open")
        self.assertEqual(
            printed.splitlines(),
            [
                "    1 open     0 done  tasks/client/phase-67.md",
                "    1 open     0 done  tasks/core/phase-45b.md",
                "    1 open     0 done  tasks/lanes/mobsa2.md",
                "    1 open     1 done  tasks/phase-1.md",
                "    1 open     0 done  tasks/phase-76.md",
                "    5 open     4 done  total",
            ],
        )

    def test_join_puts_every_phase_back_in_its_place(self):
        self.run_main("split", self.feature)
        joined = tasks.join_text(self.feature)
        phases = [line for line in joined.splitlines() if line.startswith(("## Phase", "#### Phase", "### Lane", "## Lane"))]
        self.assertEqual(
            phases,
            [
                "## Phase 1: Setup", "### Lane: core", "#### Phase 45b: features (continued)", "#### Phase 46: structures",
                "### Lane: client", "#### Phase 67: particles", "## Phase 76: Convergence", "## Lane lists",
                "## Phase mobsa2: species leftovers (lane 002-lane-mobsa2)", "### Lane models2 (T8500-T8599): overlays",
                "## Lane 002-lane-trees (T4400+)",
            ],
        )
        self.assertEqual(tasks.counts(joined), (5, 4))


class Absorbing(unittest.TestCase):
    """A branch that left before the split and changed the one file."""

    def setUp(self):
        self.repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.repo)
        self.feature = os.path.join(self.repo, "specs", "f")
        self.git("init", "-q", "-b", "trunk")
        tasks.write(os.path.join(self.feature, "tasks.md"), ONE_FILE)
        self.commit("one file")
        self.git("checkout", "-q", "-b", "lane")
        text = ONE_FILE.replace("- [ ] T100 a feature", "- [x] T100 a feature").replace("- [ ] T200 a particle", "- [x] T200 a particle")
        tasks.write(os.path.join(self.feature, "tasks.md"), text + "\n## Lane 002-lane-new (T9000+)\n\n- [x] T9000 new work\n")
        self.commit("lane work")
        self.git("checkout", "-q", "trunk")
        with contextlib.redirect_stdout(io.StringIO()):
            tasks.main(["split", self.feature])
        self.commit("split")

    def git(self, *arguments, check=True):
        return subprocess.run(
            ["git", "-c", "user.name=t", "-c", "user.email=t@example.invalid", *arguments],
            cwd=self.repo, check=check, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
        )

    def commit(self, message):
        self.git("add", "-A")
        self.git("commit", "-q", "-m", message)

    def absorb(self, reference):
        printed = io.StringIO()
        with contextlib.redirect_stdout(printed):
            status = tasks.main(["absorb", self.feature, reference])
        return status, printed.getvalue()

    def file(self, relative):
        return tasks.read(os.path.join(self.feature, relative))

    def test_ticks_and_a_new_lane_list_land_in_the_split_files(self):
        status, printed = self.absorb("lane")
        self.assertEqual(status, 0, printed)
        self.assertIn("- [x] T100 a feature", self.file("tasks/core/phase-45b.md"))
        self.assertIn("- [x] T200 a particle", self.file("tasks/client/phase-67.md"))
        self.assertEqual(self.file("tasks/lanes/new.md"), "## Lane 002-lane-new (T9000+)\n\n- [x] T9000 new work\n")
        self.assertEqual(
            sorted(line.split()[1] for line in printed.splitlines() if line.startswith("changed ")),
            ["specs/f/tasks/client/phase-67.md", "specs/f/tasks/core/phase-45b.md", "specs/f/tasks/lanes/new.md"],
        )
        self.assertNotIn("T9000", self.file("tasks.md"))

    def test_changes_made_here_since_the_split_are_kept(self):
        path = os.path.join(self.feature, "tasks", "core", "phase-45b.md")
        tasks.write(path, tasks.read(path) + "- [ ] T101 added after the split\n")
        self.commit("more work here")
        status, _ = self.absorb("lane")
        self.assertEqual(status, 0)
        self.assertIn("- [x] T100 a feature", self.file("tasks/core/phase-45b.md"))
        self.assertIn("- [ ] T101 added after the split", self.file("tasks/core/phase-45b.md"))

    def test_during_a_merge_that_stopped_on_the_one_file(self):
        merge = self.git("merge", "--no-edit", "lane", check=False)
        self.assertNotEqual(merge.returncode, 0)
        status, _ = self.absorb("MERGE_HEAD")
        self.assertEqual(status, 0)
        self.assertNotIn("<<<<<<<", self.file("tasks.md"))
        self.assertIn("**Layout**", self.file("tasks.md"))
        self.assertIn("- [x] T200 a particle", self.file("tasks/client/phase-67.md"))
        self.assertEqual(self.git("diff", "--name-only", "--diff-filter=U").stdout, "")

    def test_the_same_line_changed_on_both_sides_is_a_conflict(self):
        path = os.path.join(self.feature, "tasks", "core", "phase-45b.md")
        tasks.write(path, tasks.read(path).replace("- [ ] T100 a feature", "- [ ] T100 a feature, reworded here"))
        self.commit("reworded")
        status, printed = self.absorb("lane")
        self.assertEqual(status, 1)
        self.assertIn("CONFLICT specs/f/tasks/core/phase-45b.md", printed)
        self.assertIn("<<<<<<<", self.file("tasks/core/phase-45b.md"))

    def test_a_branch_with_the_split_layout_needs_nothing(self):
        self.git("checkout", "-q", "-b", "newer")
        self.git("checkout", "-q", "trunk")
        status, printed = self.absorb("newer")
        self.assertEqual(status, 0)
        self.assertIn("has the split layout already", printed)


if __name__ == "__main__":
    unittest.main()
