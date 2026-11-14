"""Implementation tests of tools/runtests.py."""
import contextlib
import io
import os
import shutil
import stat
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import runtests


class LineParsing(unittest.TestCase):
    def test_pass_line(self):
        self.assertEqual(runtests.parse_line("TEST a case PASS"), runtests.Result("a case", True, "", ""))

    def test_fail_line(self):
        self.assertEqual(
            runtests.parse_line("TEST a case FAIL expected=1 2 observed=3"),
            runtests.Result("a case", False, "1 2", "3"),
        )

    def test_fail_line_with_empty_values(self):
        self.assertEqual(
            runtests.parse_line("TEST a case FAIL expected= observed="),
            runtests.Result("a case", False, "", ""),
        )

    def test_other_lines_are_not_cases(self):
        self.assertIsNone(runtests.parse_line("hello"))
        self.assertIsNone(runtests.parse_line("TESTING a case PASS"))


class PackageSelection(unittest.TestCase):
    def test_all_packages_by_default(self):
        self.assertEqual(runtests.PACKAGES, ["shim", "formats", "proto", "content", "extract", "core", "server", "client"])
        self.assertEqual(runtests.DEPENDENCIES["formats"], ["shim"])
        self.assertEqual(runtests.DEPENDENCIES["content"], ["shim", "proto", "formats"])
        self.assertEqual(runtests.DEPENDENCIES["extract"], ["shim", "proto", "formats", "content"])
        self.assertEqual(runtests.select_packages([]), ["shim", "formats", "proto", "content", "extract", "core", "server", "client"])

    def test_selection_keeps_dependency_order(self):
        self.assertEqual(runtests.select_packages(["client", "proto"]), ["proto", "client"])

    def test_build_order_includes_dependencies(self):
        self.assertEqual(runtests.build_order(["core"]), ["shim", "formats", "proto", "content", "core"])
        self.assertEqual(runtests.build_order(["extract"]), ["shim", "formats", "proto", "content", "extract"])
        self.assertEqual(runtests.build_order(["shim"]), ["shim"])
        self.assertEqual(
            runtests.build_order(["server", "client"]), ["shim", "formats", "proto", "content", "core", "server", "client"]
        )

    def test_packages_build_the_libraries_their_makefile_links(self):
        # a fresh gate must build content before core, server and client (DEPS_* of the root Makefile)
        for package in ("core", "server", "client"):
            self.assertIn("content", runtests.build_order([package]))

    def test_convergence_is_selected_only_by_name_and_comes_last(self):
        self.assertNotIn("convergence", runtests.select_packages([]))
        self.assertEqual(runtests.select_packages(["convergence", "core"]), ["core", "convergence"])

    def test_convergence_builds_every_package(self):
        self.assertEqual(runtests.build_order(["convergence"]), ["shim", "formats", "proto", "content", "extract", "core", "server", "client"])

    def test_convergence_directory_and_programs(self):
        repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, repo)
        os.makedirs(os.path.join(repo, "tests", "convergence"))
        for name in ["acc_us2_join.cob", "convharness.cob"]:
            open(os.path.join(repo, "tests", "convergence", name), "w").close()
        self.assertEqual(runtests.discover_tests(repo, "convergence"), ["tests/convergence/acc_us2_join.cob"])
        self.assertEqual(
            runtests.program_path("/b", "tests/convergence/acc_us2_join.cob"),
            os.path.join("/b", "convergence", "tests", "acc_us2_join"),
        )
        self.assertEqual(runtests.package_directory("convergence"), "tests/convergence")
        self.assertEqual(runtests.package_directory("core"), "core")

    def test_unknown_package_is_rejected(self):
        with self.assertRaises(SystemExit), contextlib.redirect_stderr(io.StringIO()):
            runtests.parse_arguments(["nosuchpackage"])

    def test_discover_tests_takes_only_test_programs(self):
        repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, repo)
        tests = os.path.join(repo, "proto", "tests")
        os.makedirs(tests)
        for name in ["acc_us2_a.cob", "contract_b_c.c", "test_c.cob", "helper.cob", "test_d.stdin", "x.c"]:
            open(os.path.join(tests, name), "w").close()
        self.assertEqual(
            runtests.discover_tests(repo, "proto"),
            ["proto/tests/acc_us2_a.cob", "proto/tests/contract_b_c.c", "proto/tests/test_c.cob"],
        )

    def test_discover_tests_without_test_directory(self):
        repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, repo)
        self.assertEqual(runtests.discover_tests(repo, "core"), [])

    def test_program_path(self):
        self.assertEqual(
            runtests.program_path("/b", "proto/tests/test_c.cob"), os.path.join("/b", "proto", "tests", "test_c")
        )


class ProgramRuns(unittest.TestCase):
    """Test programs are stood in for by executable Python scripts next to a fake test source."""

    def setUp(self):
        self.repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.repo)
        os.makedirs(os.path.join(self.repo, "core", "tests"))
        self.source = "core/tests/test_x.cob"
        open(os.path.join(self.repo, self.source), "w").close()

    def program(self, body):
        path = os.path.join(self.repo, "prog")
        with open(path, "w") as handle:
            handle.write("#!" + sys.executable + "\nimport sys\n" + body)
        os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR)
        return path

    def sibling(self, extension, text):
        with open(os.path.join(self.repo, "core", "tests", "test_x" + extension), "w") as handle:
            handle.write(text)

    def run_it(self, program):
        return runtests.run_program(program, self.source, self.repo)

    def test_cases_are_collected(self):
        program = self.program('print("TEST one PASS")\nprint("noise")\nprint("TEST two FAIL expected=1 observed=2")\n')
        self.assertEqual(
            self.run_it(program),
            [runtests.Result("one", True, "", ""), runtests.Result("two", False, "1", "2")],
        )

    def test_program_runs_in_the_given_directory(self):
        program = self.program('import os\nprint("TEST cwd " + ("PASS" if os.path.isdir("core") else "FAIL expected=core observed=none"))\n')
        self.assertEqual(self.run_it(program), [runtests.Result("cwd", True, "", "")])

    def test_stdin_file_is_fed(self):
        self.sibling(".stdin", "hello\n")
        program = self.program('line = sys.stdin.readline().strip()\nprint("TEST stdin FAIL expected=hello observed=" + line if line != "hello" else "TEST stdin PASS")\n')
        self.assertEqual(self.run_it(program), [runtests.Result("stdin", True, "", "")])

    def test_without_stdin_file_input_is_empty(self):
        program = self.program('print("TEST empty " + ("PASS" if sys.stdin.read() == "" else "FAIL expected= observed=data"))\n')
        self.assertEqual(self.run_it(program), [runtests.Result("empty", True, "", "")])

    def test_crash_is_one_failure_named_after_the_program(self):
        program = self.program('print("TEST before PASS")\nsys.stderr.write("boom\\n")\nsys.exit(3)\n')
        printed = io.StringIO()
        with contextlib.redirect_stdout(printed):
            results = self.run_it(program)
        self.assertEqual(printed.getvalue(), "  core/tests/test_x: boom\n")
        self.assertEqual(
            results,
            [
                runtests.Result("before", True, "", ""),
                runtests.Result("core/tests/test_x", False, "exit 0", "exit 3"),
            ],
        )

    def test_signal_is_reported(self):
        program = self.program("import os, signal\nos.kill(os.getpid(), signal.SIGABRT)\n")
        self.assertEqual(
            self.run_it(program), [runtests.Result("core/tests/test_x", False, "exit 0", "signal 6")]
        )

    def test_missing_program_is_one_failure(self):
        self.assertEqual(
            self.run_it(os.path.join(self.repo, "absent")),
            [runtests.Result("core/tests/test_x", False, "test program built", "missing")],
        )

    def test_expect_file_matching_is_one_passing_case(self):
        self.sibling(".expect", "4\nERROR fatal: boom\n")
        program = self.program('sys.stderr.write("ERROR fatal: boom\\n")\nsys.exit(4)\n')
        self.assertEqual(self.run_it(program), [runtests.Result("core/tests/test_x", True, "", "")])

    def test_expect_file_wrong_status_fails(self):
        self.sibling(".expect", "4\nERROR fatal: boom\n")
        program = self.program('sys.stderr.write("ERROR fatal: boom\\n")\nsys.exit(0)\n')
        self.assertEqual(
            self.run_it(program),
            [
                runtests.Result(
                    "core/tests/test_x",
                    False,
                    "exit 4 stderr containing ERROR fatal: boom",
                    "exit 0 stderr ERROR fatal: boom",
                )
            ],
        )

    def test_expect_file_wrong_stderr_fails(self):
        self.sibling(".expect", "4\nERROR fatal: boom\n")
        program = self.program('sys.stderr.write("other\\nlines\\n")\nsys.exit(4)\n')
        self.assertEqual(
            self.run_it(program),
            [
                runtests.Result(
                    "core/tests/test_x",
                    False,
                    "exit 4 stderr containing ERROR fatal: boom",
                    "exit 4 stderr other | lines",
                )
            ],
        )

    def test_expect_file_without_stderr_line(self):
        self.sibling(".expect", "2\n")
        program = self.program("sys.exit(2)\n")
        self.assertEqual(self.run_it(program), [runtests.Result("core/tests/test_x", True, "", "")])


class Reporting(unittest.TestCase):
    def test_report_lists_failures_and_counts(self):
        lines = runtests.report(
            [runtests.Result("a", True, "", ""), runtests.Result("b", False, "1", "2"), runtests.Result("c", True, "", "")]
        )
        self.assertEqual(lines, ["FAIL b expected=1 observed=2", "passed 2 failed 1"])

    def test_report_of_nothing(self):
        self.assertEqual(runtests.report([]), ["passed 0 failed 0"])


if __name__ == "__main__":
    unittest.main()
