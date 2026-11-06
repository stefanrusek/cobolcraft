"""Acceptance test US1-1: the documented build command produces the client and the server programs.

Running them is the Convergence test tests/convergence/acc_binaries.cob."""
import os
import stat
import subprocess
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import scratch


class AcceptanceUS1Build(unittest.TestCase):
    def setUp(self):
        self.copy = scratch.make_copy()

    def tearDown(self):
        scratch.remove_copy(self.copy)

    def test_acceptance_US1_1(self):
        """acceptance US1-1 given a fresh checkout with the prerequisites when make runs then
        build/bin/cobolcraft and build/bin/cobolcraft-server are produced as executable files"""
        result = subprocess.run(["make", "-C", self.copy], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        output = result.stdout
        self.assertEqual(result.returncode, 0, output[-4000:])
        for name in ("cobolcraft", "cobolcraft-server"):
            path = os.path.join(self.copy, "build", "bin", name)
            self.assertTrue(os.path.isfile(path), path + " missing\n" + output)
            self.assertTrue(os.stat(path).st_mode & stat.S_IXUSR, path + " not executable")


if __name__ == "__main__":
    unittest.main()
