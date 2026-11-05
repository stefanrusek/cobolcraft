"""Implementation tests of tools/contract_check.py against good and bad .hex fixtures."""
import contextlib
import io
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import contract_check  # noqa: E402

FIXTURES = os.path.join(os.path.dirname(__file__), "fixtures", "hex")


def path(name):
    return os.path.join(FIXTURES, name)


class Parsing(unittest.TestCase):
    def test_comments_stripped_and_tokens_read(self):
        self.assertEqual(contract_check.parse_hex(path("good.hex")), (bytes([0x00, 0x0A, 0xFF, 0x7F]), []))

    def test_empty_file_rejected(self):
        self.assertEqual(contract_check.parse_hex(path("empty.hex")), (b"", ["no bytes"]))

    def test_bad_tokens_rejected(self):
        for name, token in [("bad-digit.hex", "0g"), ("bad-length.hex", "abc"), ("bad-short.hex", "1")]:
            data, errors = contract_check.parse_hex(path(name))
            self.assertEqual(errors, ["line 1: bad token '%s'" % token], name)


class CommandLine(unittest.TestCase):
    def run_main(self, argv):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = contract_check.main(argv)
        return status, out.getvalue().splitlines()

    def test_good_files(self):
        self.assertEqual(self.run_main([path("good.hex")]), (0, ["contract_check: 1 files, 0 failed"]))

    def test_bad_files_named(self):
        status, lines = self.run_main([path("good.hex"), path("empty.hex"), path("bad-digit.hex")])
        self.assertEqual(status, 1)
        self.assertEqual(
            lines,
            [
                "ERROR %s: no bytes" % path("empty.hex"),
                "ERROR %s: line 1: bad token '0g'" % path("bad-digit.hex"),
                "contract_check: 3 files, 2 failed",
            ],
        )

    def test_default_is_every_wire_fixture_of_the_repository(self):
        repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, repo)
        wire = os.path.join(repo, "contract", "fixtures", "wire")
        os.makedirs(wire)
        shutil.copy(path("good.hex"), os.path.join(wire, "a.hex"))
        shutil.copy(path("empty.hex"), os.path.join(wire, "b.hex"))
        self.assertEqual(contract_check.default_files(repo), [os.path.join(wire, "a.hex"), os.path.join(wire, "b.hex")])


if __name__ == "__main__":
    unittest.main()
