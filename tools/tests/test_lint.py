"""Implementation tests of tools/lint.py against good and bad fixtures."""
import contextlib
import io
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import lint

FIXTURES = os.path.join(os.path.dirname(__file__), "fixtures", "lint")


def path(name):
    return os.path.join(FIXTURES, name)


class Checks(unittest.TestCase):
    def assert_lint(self, name, expected_ok, include_dirs=()):
        ok, output = lint.lint_file(path(name), list(include_dirs))
        self.assertEqual(ok, expected_ok, output)

    def test_cobol(self):
        self.assert_lint("good.cob", True)
        self.assert_lint("bad.cob", False)

    def test_cobol_include_directories(self):
        self.assert_lint("good_copy.cob", False)
        self.assert_lint("good_copy.cob", True, [path("include")])

    def test_c(self):
        self.assert_lint("good.c", True)
        self.assert_lint("bad.c", False)

    def test_glsl(self):
        self.assert_lint("good.vert", True)
        self.assert_lint("bad.frag", False)

    def test_python(self):
        self.assert_lint("good.py", True)
        self.assert_lint("bad.py", False)

    def test_unsupported_file_type_fails(self):
        self.assert_lint("notes.txt", False)


class CommandLine(unittest.TestCase):
    def run_main(self, argv):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = lint.main(argv)
        return status, out.getvalue().splitlines()

    def test_all_good(self):
        status, lines = self.run_main(["-I", path("include"), path("good.cob"), path("good_copy.cob"), path("good.py")])
        self.assertEqual(status, 0)
        self.assertEqual(lines[-1], "lint: 3 files, 0 failed")

    def test_failures_are_named(self):
        status, lines = self.run_main([path("good.c"), path("bad.c"), path("bad.py")])
        self.assertEqual(status, 1)
        self.assertIn("LINT FAIL " + path("bad.c"), lines)
        self.assertIn("LINT FAIL " + path("bad.py"), lines)
        self.assertEqual(lines[-1], "lint: 3 files, 2 failed")

    def test_no_files(self):
        self.assertEqual(self.run_main([]), (0, ["lint: 0 files, 0 failed"]))


if __name__ == "__main__":
    unittest.main()
