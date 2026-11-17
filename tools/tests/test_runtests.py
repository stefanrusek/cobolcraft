"""Implementation tests of tools/runtests.py."""
import contextlib
import io
import os
import shutil
import stat
import sys
import tempfile
import threading
import time
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

    def test_PWD_names_the_directory_the_program_runs_in(self):
        program = self.program('import os\nprint("TEST pwd " + ("PASS" if os.environ["PWD"] == os.getcwd() else "FAIL expected=cwd observed=" + os.environ["PWD"]))\n')
        self.assertEqual(runtests.run_program(program, self.source, os.path.realpath(self.repo)), [runtests.Result("pwd", True, "", "")])

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


class Jobs(unittest.TestCase):
    def test_default_is_the_JOBS_variable(self):
        self.assertEqual(runtests.default_jobs({"JOBS": "3"}), 3)

    def test_default_without_a_usable_JOBS_is_the_processor_count(self):
        for environment in ({}, {"JOBS": ""}, {"JOBS": "0"}, {"JOBS": "many"}):
            self.assertEqual(runtests.default_jobs(environment), os.cpu_count())

    def test_jobs_argument(self):
        self.assertEqual(runtests.parse_arguments(["--jobs", "5"]).jobs, 5)


class Sandboxes(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.repo)
        for directory in ("core/tests", "build/coverage", "build/testsrv", "build/core-test-world"):
            os.makedirs(os.path.join(self.repo, directory))
        open(os.path.join(self.repo, "Makefile"), "w").close()
        self.root = os.path.join(self.repo, "build", "coverage", "sandbox")

    def test_repository_entries_are_links_and_build_is_its_own(self):
        os.makedirs(os.path.join(self.repo, "docs", "protocol"))
        os.makedirs(os.path.join(self.repo, ".git"))
        sandbox = runtests.make_sandbox(self.repo, self.root, 2)
        self.assertEqual(sandbox, os.path.join(self.root, "2"))
        self.assertTrue(os.path.islink(os.path.join(sandbox, "Makefile")))
        # a folder that is not a package: real, with its entries linked
        self.assertFalse(os.path.islink(os.path.join(sandbox, "docs")))
        self.assertTrue(os.path.islink(os.path.join(sandbox, "docs", "protocol")))
        self.assertFalse(os.path.islink(os.path.join(sandbox, "build")))
        self.assertFalse(os.path.lexists(os.path.join(sandbox, ".git")))

    def test_package_folders_are_copies(self):
        fixtures = os.path.join(self.repo, "core", "tests", "fixtures")
        os.makedirs(fixtures)
        with open(os.path.join(fixtures, "a.hex"), "w") as handle:
            handle.write("00")
        sandbox = runtests.make_sandbox(self.repo, self.root, 0)
        inside = os.path.join(sandbox, "core", "tests", "fixtures")
        self.assertFalse(os.path.islink(inside))
        self.assertFalse(os.path.islink(os.path.join(inside, "a.hex")))
        with open(os.path.join(inside, "a.hex")) as handle:
            self.assertEqual(handle.read(), "00")
        # leaving a package folder with .. stays in the sandbox
        self.assertEqual(
            os.path.realpath(os.path.join(inside, "..", "..", "..", "build")), os.path.realpath(os.path.join(sandbox, "build"))
        )
        # what a program writes or changes there stays out of the repository
        open(os.path.join(inside, "made.txt"), "w").close()
        with open(os.path.join(inside, "a.hex"), "w") as handle:
            handle.write("ff")
        os.chmod(os.path.join(inside, "a.hex"), 0)
        self.assertFalse(os.path.exists(os.path.join(fixtures, "made.txt")))
        with open(os.path.join(fixtures, "a.hex")) as handle:
            self.assertEqual(handle.read(), "00")
        os.chmod(os.path.join(inside, "a.hex"), 0o644)

    def test_build_outputs_are_shared_and_scratch_is_not(self):
        sandbox = runtests.make_sandbox(self.repo, self.root, 0)
        self.assertEqual(sorted(os.listdir(os.path.join(sandbox, "build"))), sorted(runtests.SHARED_BUILD_ENTRIES))
        self.assertTrue(os.path.islink(os.path.join(sandbox, "build", "testsrv")))
        self.assertNotIn("core-test-world", os.listdir(os.path.join(sandbox, "build")))

    def test_a_shared_folder_a_test_program_may_build_into_exists(self):
        sandbox = runtests.make_sandbox(self.repo, self.root, 0)
        self.assertTrue(os.path.isdir(os.path.join(self.repo, "build", "bin")))
        self.assertEqual(os.path.realpath(os.path.join(sandbox, "build", "bin")), os.path.realpath(os.path.join(self.repo, "build", "bin")))

    def test_a_sandbox_is_emptied_when_made_again(self):
        sandbox = runtests.make_sandbox(self.repo, self.root, 0)
        os.makedirs(os.path.join(sandbox, "build", "core-test-world"))
        runtests.make_sandbox(self.repo, self.root, 0)
        self.assertFalse(os.path.exists(os.path.join(sandbox, "build", "core-test-world")))
        # the real folders the links pointed at are untouched
        self.assertTrue(os.path.isdir(os.path.join(self.repo, "build", "testsrv")))
        self.assertTrue(os.path.isdir(os.path.join(self.repo, "core", "tests")))


class ParallelRuns(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.repo)
        os.makedirs(os.path.join(self.repo, "core", "tests"))
        self.root = os.path.join(self.repo, "build", "sandbox")
        self.programs = [("core/tests/test_%d.cob" % n, "/programs/test_%d" % n) for n in range(8)]

    def test_results_keep_the_order_of_the_programs(self):
        def run(program, source, directory):
            time.sleep(0.05 if source.endswith("_0.cob") else 0)  # the first one finishes last
            return [runtests.Result(source, True, "", "")]

        results, times = runtests.run_all(self.programs, self.repo, self.root, 4, run)
        self.assertEqual([r.case for r in results], [source for source, _ in self.programs])
        self.assertEqual([source for _, source in times], [source for source, _ in self.programs])

    def test_no_two_running_programs_share_a_directory(self):
        lock = threading.Lock()
        busy, seen, clashes = set(), set(), []

        def run(program, source, directory):
            with lock:
                if directory in busy:
                    clashes.append(directory)
                busy.add(directory)
                seen.add(directory)
            time.sleep(0.02)
            with lock:
                busy.discard(directory)
            return []

        runtests.run_all(self.programs, self.repo, self.root, 3, run)
        self.assertEqual(clashes, [])
        self.assertEqual(seen, {os.path.join(self.root, str(n)) for n in range(3)})

    def test_a_program_that_failed_is_run_again_alone_in_the_repository_root(self):
        calls = []

        def run(program, source, directory):
            calls.append((source, directory))
            flaky = source.endswith("_3.cob") and directory != self.repo
            broken = source.endswith("_5.cob")
            return [runtests.Result(source, not (flaky or broken), "1", "0")]

        printed = io.StringIO()
        with contextlib.redirect_stdout(printed):
            results, _ = runtests.run_all(self.programs, self.repo, self.root, 4, run)
        self.assertEqual(printed.getvalue(), "RERUN core/tests/test_3.cob\nRERUN core/tests/test_5.cob\n")
        self.assertEqual([r.case for r in results if not r.passed], ["core/tests/test_5.cob"])
        self.assertEqual(len(results), len(self.programs))
        self.assertEqual(calls[-2:], [("core/tests/test_3.cob", self.repo), ("core/tests/test_5.cob", self.repo)])

    def test_one_job_runs_nothing_twice(self):
        calls = []

        def run(program, source, directory):
            calls.append(source)
            return [runtests.Result(source, False, "1", "0")]

        runtests.run_all(self.programs, self.repo, self.root, 1, run)
        self.assertEqual(len(calls), len(self.programs))

    def test_no_more_sandboxes_than_programs(self):
        runtests.run_all(self.programs[:2], self.repo, self.root, 6, lambda program, source, directory: [])
        self.assertEqual(sorted(os.listdir(self.root)), ["0", "1"])

    def test_one_job_runs_in_the_repository_root(self):
        seen = set()

        def run(program, source, directory):
            seen.add(directory)
            return []

        runtests.run_all(self.programs, self.repo, self.root, 1, run)
        self.assertEqual(seen, {self.repo})
        self.assertFalse(os.path.exists(self.root))

    def test_programs_start_slowest_first_and_unknown_ones_before_them(self):
        started = []

        def run(program, source, directory):
            started.append(source)
            return [runtests.Result(source, True, "", "")]

        known = {"core/tests/test_1.cob": 2.0, "core/tests/test_2.cob": 90.0, "core/tests/test_3.cob": 30.0}
        results, times = runtests.run_all(self.programs[:5], self.repo, self.root, 1, run, known)
        self.assertEqual([s[len("core/tests/test_")] for s in started], ["0", "4", "2", "3", "1"])
        self.assertEqual([r.case for r in results], [source for source, _ in self.programs[:5]])
        self.assertEqual([source for _, source in times], [source for source, _ in self.programs[:5]])

    def test_times_are_read_back(self):
        path = os.path.join(self.repo, "times.txt")
        runtests.write_times(path, [(0.5, "core/tests/test_a.cob"), (12.25, "core/tests/test_b.cob")])
        self.assertEqual(runtests.read_times(path), {"core/tests/test_a.cob": 0.5, "core/tests/test_b.cob": 12.25})
        self.assertEqual(runtests.read_times(os.path.join(self.repo, "absent.txt")), {})

    def test_times_are_written_slowest_first(self):
        path = os.path.join(self.repo, "times.txt")
        runtests.write_times(path, [(0.5, "core/tests/test_a.cob"), (12.25, "core/tests/test_b.cob")])
        with open(path, encoding="utf-8") as handle:
            self.assertEqual(handle.read(), "12.25 core/tests/test_b.cob\n0.50 core/tests/test_a.cob\n")


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
