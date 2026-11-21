"""Acceptance test F2US2: the drift gate fails on a lost document row and on a hand edit (T0074)."""
import os
import shutil
import tempfile
import unittest

import genlib


class AcceptanceF2US2GenDrift(unittest.TestCase):
    def test_acceptance_F2US2_check_fails_when_a_document_loses_a_block(self):
        """acceptance F2US2-16 given a docs copy without one block row when --check runs then exit 1 naming the count"""
        with tempfile.TemporaryDirectory() as scratch:
            docs = os.path.join(scratch, "protocol")
            shutil.copytree(genlib.DOCS, docs)
            path = [os.path.join(docs, n) for n in sorted(os.listdir(docs)) if n.startswith("24-block-registry-8")][0]
            with open(path, encoding="utf-8") as handle:
                lines = handle.read().split("\n")
            kept = [line for line in lines if not line.startswith("| 9 | dirt | 9 | 10 | 1 | 1 |")]
            self.assertEqual(len(kept), len(lines) - 1)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write("\n".join(kept))
            generated = os.path.join(scratch, "gen")
            self.assertEqual(genlib.run("--write", "--out", generated).returncode, 0)
            result = genlib.run("--check", "--out", generated, "--docs", docs)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("PROBLEM", result.stdout)
        self.assertTrue("Registered blocks" in result.stdout or "1285" in result.stdout, result.stdout)

    def test_acceptance_F2US2_check_fails_when_a_generated_file_is_edited(self):
        """acceptance F2US2-17 given a generated file edited by hand when --check runs then exit 1 naming the file"""
        with tempfile.TemporaryDirectory() as scratch:
            self.assertEqual(genlib.run("--write", "--out", scratch).returncode, 0)
            self.assertEqual(genlib.run("--check", "--out", scratch).returncode, 0)
            path = os.path.join(scratch, "blocks.cpy")
            with open(path, encoding="ascii") as handle:
                text = handle.read()
            with open(path, "w", encoding="ascii") as handle:
                handle.write(text.replace("stone", "stonX", 1))
            result = genlib.run("--check", "--out", scratch)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("DRIFT blocks.cpy", result.stdout)


if __name__ == "__main__":
    unittest.main()
