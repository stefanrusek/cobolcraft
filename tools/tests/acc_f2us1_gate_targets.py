"""Acceptance test F2US1: the new gate targets resolve and `make build` names the extraction program
(contracts/test-harness-delta.md)."""
import os
import subprocess
import unittest

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def dry_run(*targets):
    return subprocess.run(["make", "-n", *targets], cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)


class AcceptanceF2US1GateTargets(unittest.TestCase):
    def test_acceptance_F2US1_gate_targets_resolve(self):
        """acceptance F2US1-5 given the root Makefile when make -n gate-formats gate-content gate-extract gate-tables runs then every target resolves"""
        result = dry_run("gate-formats", "gate-content", "gate-extract", "gate-tables")
        self.assertEqual(result.returncode, 0, result.stdout)
        for package in ("formats", "content", "extract"):
            self.assertIn("-C %s lint" % package, result.stdout)
        self.assertIn("gen_tables.py --check", result.stdout)

    def test_acceptance_F2US1_build_names_the_extraction_program(self):
        """acceptance F2US1-6 given the root Makefile when make -n build runs then build/bin/cobolcraft-extract is named"""
        result = dry_run("build")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("build/bin/cobolcraft-extract", result.stdout)

    def test_acceptance_F2US1_tools_gates_depend_on_gate_tables(self):
        """acceptance F2US1-7 given gate-tools and gate-contract when make -n runs then the drift gate runs in each"""
        for target in ("gate-tools", "gate-contract"):
            result = dry_run(target)
            self.assertEqual(result.returncode, 0, result.stdout)
            self.assertIn("gen_tables.py --check", result.stdout, target)


if __name__ == "__main__":
    unittest.main()
