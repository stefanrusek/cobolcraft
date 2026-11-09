"""Implementation tests of tools/contract_check.py against good and bad .hex fixtures."""
import contextlib
import io
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import contract_check

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


COPYBOOK_GOOD = " 78 GOOD-ONE   VALUE 1.\n 01 GOOD-REC.\n    05 GOOD-F  PIC X.\n"
COPYBOOK_BAD = " 01 BAD-REC.\n    05 BAD-F  PIC Z(.\n"


def make_repo(test, copybooks, probe_text=None, wire=None):
    """A scratch repository holding the given contract copybooks (name -> text)."""
    repo = tempfile.mkdtemp()
    test.addCleanup(shutil.rmtree, repo)
    copy = os.path.join(repo, "contract", "copy")
    os.makedirs(copy)
    for name, text in copybooks.items():
        with open(os.path.join(copy, name), "w", encoding="utf-8") as handle:
            handle.write(text)
    if probe_text is not None:
        os.makedirs(os.path.join(repo, "tools", "probe"))
        with open(os.path.join(repo, "tools", "probe", "probe_contract.cob"), "w", encoding="utf-8") as handle:
            handle.write(probe_text)
    if wire is not None:
        os.makedirs(os.path.join(repo, "contract", "fixtures", "wire"))
        for name, text in wire.items():
            with open(os.path.join(repo, "contract", "fixtures", "wire", name), "w", encoding="utf-8") as handle:
                handle.write(text)
    return repo


class Copybooks(unittest.TestCase):
    def test_names_are_every_contract_copybook_sorted(self):
        repo = make_repo(self, {"B.cpy": COPYBOOK_GOOD, "A.cpy": COPYBOOK_GOOD, "notes.txt": "x"})
        self.assertEqual(contract_check.copybook_names(repo), ["A.cpy", "B.cpy"])

    def test_good_copybook_compiles(self):
        repo = make_repo(self, {"GOOD.cpy": COPYBOOK_GOOD})
        self.assertEqual(contract_check.compile_copybooks(repo), [])

    def test_bad_copybook_is_reported_by_name(self):
        repo = make_repo(self, {"GOOD.cpy": COPYBOOK_GOOD, "BAD.cpy": COPYBOOK_BAD})
        problems = contract_check.compile_copybooks(repo)
        self.assertEqual([name for name, _ in problems], ["BAD.cpy"])
        self.assertTrue(problems[0][1])

    def test_probe_must_copy_every_copybook(self):
        probe = " WORKING-STORAGE SECTION.\n COPY GOOD.\n"
        repo = make_repo(self, {"GOOD.cpy": COPYBOOK_GOOD, "OTHER.cpy": COPYBOOK_GOOD}, probe_text=probe)
        self.assertEqual(contract_check.probe_missing(repo), ["OTHER.cpy"])

    def test_probe_covering_all_has_no_missing(self):
        probe = " COPY GOOD.\n COPY OTHER.\n"
        repo = make_repo(self, {"GOOD.cpy": COPYBOOK_GOOD, "OTHER.cpy": COPYBOOK_GOOD}, probe_text=probe)
        self.assertEqual(contract_check.probe_missing(repo), [])

    def test_the_new_copybooks_exist_and_the_real_probe_copies_them(self):
        names = contract_check.copybook_names(contract_check.REPO)
        for name in ["CONTENT.cpy", "FORMATS.cpy", "CELLS.cpy", "JSONDOC.cpy", "PROTO.cpy"]:
            self.assertIn(name, names)
        self.assertEqual(contract_check.probe_missing(contract_check.REPO), [])

    def test_the_real_copybooks_compile(self):
        self.assertEqual(contract_check.compile_copybooks(contract_check.REPO), [])


GEN_BLOCKS = "78 GEN-BLOCK-OFF-ID VALUE 0.\n78 GEN-BLOCK-W-ID VALUE 4.\n78 GEN-BLOCK-OFF-KEY VALUE 4.\n78 GEN-BLOCK-W-KEY VALUE 35.\n"
CONTENT_VIEW = " 01 CT-BLOCK-ROW.\n    05 CT-BR-ID  PIC X(4).\n    05 CT-BR-KEY PIC X(%d).\n"


class RowWidths(unittest.TestCase):
    def repo_with(self, key_width):
        repo = make_repo(self, {"CONTENT.cpy": CONTENT_VIEW % key_width})
        gen = os.path.join(repo, "content", "copy", "gen")
        os.makedirs(gen)
        with open(os.path.join(gen, "blocks.cpy"), "w", encoding="utf-8") as handle:
            handle.write(GEN_BLOCKS)
        return repo

    def test_agreeing_widths_have_no_problem(self):
        self.assertEqual(contract_check.row_width_problems(self.repo_with(35)), [])

    def test_a_differing_width_is_reported(self):
        problems = contract_check.row_width_problems(self.repo_with(36))
        self.assertEqual(len(problems), 1)
        self.assertIn("CT-BLOCK-ROW", problems[0])

    def test_a_repository_without_generated_tables_is_skipped(self):
        self.assertEqual(contract_check.row_width_problems(make_repo(self, {"CONTENT.cpy": "x"})), [])

    def test_the_real_row_views_match_the_generated_tables(self):
        self.assertEqual(contract_check.row_width_problems(contract_check.REPO), [])


class DefaultRun(unittest.TestCase):
    def run_main(self, argv):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            status = contract_check.main(argv)
        return status, out.getvalue().splitlines()

    def test_default_run_checks_fixtures_copybooks_and_probe(self):
        probe = " COPY GOOD.\n"
        repo = make_repo(self, {"GOOD.cpy": COPYBOOK_GOOD}, probe_text=probe, wire={"a.hex": "01 02\n"})
        status, lines = self.run_main(["--repo", repo])
        self.assertEqual(status, 0)
        self.assertEqual(lines, ["contract_check: 1 files, 0 failed", "contract_check: 1 copybooks, 0 failed"])

    def test_default_run_fails_on_bad_copybook_missing_probe_and_bad_fixture(self):
        repo = make_repo(self, {"BAD.cpy": COPYBOOK_BAD, "NEW.cpy": COPYBOOK_GOOD}, probe_text=" COPY BAD.\n",
                         wire={"a.hex": "zz\n"})
        status, lines = self.run_main(["--repo", repo])
        self.assertEqual(status, 1)
        self.assertTrue(any(line.startswith("ERROR %s" % os.path.join(repo, "contract", "fixtures", "wire", "a.hex")) for line in lines))
        self.assertTrue(any(line.startswith("ERROR BAD.cpy: ") for line in lines))
        self.assertIn("ERROR NEW.cpy: not copied by tools/probe/probe_contract.cob", lines)
        self.assertEqual(lines[-1], "contract_check: 2 copybooks, 2 failed")

    def test_explicit_files_skip_the_copybook_check(self):
        status, lines = self.run_main([path("good.hex")])
        self.assertEqual((status, lines), (0, ["contract_check: 1 files, 0 failed"]))


class RealFixtures(unittest.TestCase):
    def test_every_wire_fixture_of_the_repository_parses(self):
        files = contract_check.default_files(contract_check.REPO)
        self.assertGreater(len(files), 100)
        for name in files:
            self.assertEqual(contract_check.parse_hex(name)[1], [], name)


if __name__ == "__main__":
    unittest.main()
