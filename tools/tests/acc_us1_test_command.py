"""Acceptance test US1-2: the documented test command runs both packages' tests and states the counts."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import scratch


class AcceptanceUS1TestCommand(unittest.TestCase):
    def setUp(self):
        self.copy = scratch.make_copy()

    def tearDown(self):
        scratch.remove_copy(self.copy)

    def test_acceptance_US1_2(self):
        """acceptance US1-2 given a built checkout when make test runs then both packages' tests run
        and the output states passed and failed counts"""
        scratch.write(
            self.copy,
            "proto/tests/test_scratch_cobol.cob",
            scratch.COBOL_TEST.format(
                program="TEST-SCRATCH-COBOL", case="scratch cobol case", expected=7, observed=7
            ),
        )
        scratch.write(
            self.copy,
            "shim/tests/test_scratch_c.c",
            scratch.C_TEST.format(case="scratch c case", expected=7, observed=7),
        )
        status, output = scratch.make(self.copy, "test")
        self.assertEqual(output.strip().splitlines()[-1], "passed 2 failed 0", output)
        self.assertEqual(status, 0, output)


if __name__ == "__main__":
    unittest.main()
