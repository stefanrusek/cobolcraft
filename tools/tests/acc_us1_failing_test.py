"""Acceptance test US1-3: a failing test is named with expected and observed, and the command fails."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import scratch


class AcceptanceUS1FailingTest(unittest.TestCase):
    def setUp(self):
        self.copy = scratch.make_copy()

    def tearDown(self):
        scratch.remove_copy(self.copy)

    def test_acceptance_US1_3(self):
        """acceptance US1-3 given a failing test when make test finishes then it names the case with
        expected and observed and exits unsuccessfully"""
        scratch.write(
            self.copy,
            "proto/tests/test_scratch_failing.cob",
            scratch.COBOL_TEST.format(
                program="TEST-SCRATCH-FAILING", case="scratch failing case", expected=7, observed=8
            ),
        )
        status, output = scratch.make(self.copy, "test")
        lines = output.strip().splitlines()
        self.assertIn("FAIL scratch failing case expected=7 observed=8", lines, output)
        self.assertEqual(lines[-1], "passed 0 failed 1", output)
        self.assertNotEqual(status, 0, output)

    def test_acceptance_US1_3_crash(self):
        """acceptance US1-3 given a test program that crashes when make test finishes then it is
        counted as one failure named after the program and the command exits unsuccessfully"""
        scratch.write(self.copy, "shim/tests/test_scratch_crash.c", scratch.C_CRASH)
        status, output = scratch.make(self.copy, "test")
        lines = output.strip().splitlines()
        self.assertTrue(
            any(line.startswith("FAIL shim/tests/test_scratch_crash expected=") for line in lines),
            output,
        )
        self.assertEqual(lines[-1], "passed 0 failed 1", output)
        self.assertNotEqual(status, 0, output)


if __name__ == "__main__":
    unittest.main()
