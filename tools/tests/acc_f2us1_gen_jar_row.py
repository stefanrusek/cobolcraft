"""Acceptance test F2US1: the accepted-jar table generated from README.md and 22 section 4.1 (T0072)."""
import os
import unittest

import genlib


class AcceptanceF2US1GenJarRow(unittest.TestCase):
    def test_acceptance_F2US1_accepted_jar_row_equals_the_recorded_row(self):
        """acceptance F2US1-5 given README and 22 section 4.1 when acceptedjar.cpy is read then it is the single row"""
        directory, result = genlib.generate()
        with directory:
            self.assertEqual(result.returncode, 0, result.stdout)
            table = genlib.Table(os.path.join(directory.name, "acceptedjar.cpy"), "ACCEPTEDJAR")
            self.assertEqual(table.count, 1)
            self.assertEqual(table.row(1), {
                "VERSION": "26.3", "SIZE": "41483720",
                "SHA256": "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d",
                "WORLD": "5023", "PROTOCOL": "777", "RESOURCE": "97.1", "DATA": "121.0"})


if __name__ == "__main__":
    unittest.main()
