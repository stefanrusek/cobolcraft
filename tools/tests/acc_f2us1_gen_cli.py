"""Acceptance test F2US1: the generator drift gate (contracts/test-harness-delta.md `make gate-tables`)."""
import os
import subprocess
import sys
import tempfile
import unittest

TOOLS = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GENERATOR = os.path.join(TOOLS, "gen", "gen_tables.py")


def run(*arguments):
    return subprocess.run([sys.executable, GENERATOR, *arguments], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)


class AcceptanceF2US1GenCli(unittest.TestCase):
    def test_acceptance_F2US1_check_passes_on_an_empty_table_set(self):
        """acceptance F2US1-1 given an empty generated directory when --check runs then it exits 0"""
        with tempfile.TemporaryDirectory() as directory:
            result = run("--check", "--out", directory)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_acceptance_F2US1_check_passes_on_the_repository(self):
        """acceptance F2US1-2 given the repository's content/copy/gen when --check runs then it exits 0"""
        result = run("--check")
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_acceptance_F2US1_check_names_a_file_that_differs(self):
        """acceptance F2US1-3 given a generated file differing by one byte when --check runs then it exits 1 naming the file"""
        with tempfile.TemporaryDirectory() as directory:
            with open(os.path.join(directory, "BLOCKS.cpy"), "wb") as handle:
                handle.write(b"x")
            result = run("--check", "--out", directory)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("BLOCKS.cpy", result.stdout)

    def test_acceptance_F2US1_write_then_check_passes(self):
        """acceptance F2US1-4 given a directory written by --write when --check runs then it exits 0"""
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(run("--write", "--out", directory).returncode, 0)
            self.assertEqual(run("--check", "--out", directory).returncode, 0)


if __name__ == "__main__":
    unittest.main()
