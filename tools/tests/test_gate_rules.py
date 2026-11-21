"""Implementation tests of the root Makefile's gate and cover-changed rules (dry runs)."""
import os
import subprocess
import unittest

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def make(*arguments):
    return subprocess.run(["make", *arguments], cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)


def top_level_makes(output):
    """The package builds a dry run of a gate starts itself (not the lines of the sub-makes)."""
    return [line for line in output.splitlines() if " -C " in line and "BUILD=" in line and "make" in line.split(" -C ")[0]]


class GateRules(unittest.TestCase):
    def test_a_package_gate_builds_in_parallel(self):
        # without the dependencies: their dry run stops where a library a package links is not built yet
        result = make("-n", "gate-server", "JOBS=3", "DEPS_server=")
        builds = top_level_makes(result.stdout)
        self.assertEqual(len(builds), 1, result.stdout)
        self.assertIn("-j 3 -C server lib bin BUILD=" + os.path.join(REPO, "build"), builds[0])

    def test_build_runs_the_packages_in_parallel(self):
        result = make("-n", "build", "JOBS=3")
        self.assertIn("-j 3 -C core lib", result.stdout)


class CoverChanged(unittest.TestCase):
    def test_a_reference_is_required(self):
        result = make("cover-changed")
        self.assertEqual(result.returncode, 2, result.stdout)
        self.assertIn("cover-changed: set SINCE=<ref>", result.stdout)

    def test_no_changed_production_source_is_reported(self):
        # HEAD against itself, in a tree whose only differences are not production sources, or none
        listed = subprocess.run(
            ["python3", "tools/coverage.py", "--changed-since", "HEAD", "--list-packages"],
            cwd=REPO, stdout=subprocess.PIPE, text=True,
        ).stdout.strip()
        result = make("-n", "cover-changed", "SINCE=HEAD")
        if listed:
            self.assertIn("--changed-since HEAD " + listed, result.stdout)
        else:
            self.assertIn("no production source changed since HEAD", result.stdout)


if __name__ == "__main__":
    unittest.main()
