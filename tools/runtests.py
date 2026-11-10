#!/usr/bin/env python3
"""Test runner (research R9; contracts/test-harness.md §1, §3). Test infrastructure, stdlib only.

usage: runtests.py [--build DIR] [--coverage] [PACKAGE ...]

For the selected packages (default: all, in dependency order) it builds their libraries and the
libraries they depend on (`make lib`), builds each package's test programs (`make tests`), runs every test program
from the repository root and reads its `TEST <case> PASS` / `TEST <case> FAIL expected=<x>
observed=<y>` lines. It prints every failing case as `FAIL <case> expected=<x> observed=<y>`, then
`passed <n> failed <m>`, and exits 1 if any case failed.

Test programs are the sources `<package>/tests/{acc,contract,test}_*.{cob,c}`; the program built from
`<package>/tests/<name>.<ext>` is `<build>/<package>/tests/<name>`. The pseudo-package `convergence`
(never selected by default) is `tests/convergence/` (the Convergence phase's cross-package acceptance
tests): it depends on every package, and its programs are `<build>/convergence/tests/<name>`. Every
test program runs with the environment variable COBOLCRAFT_BUILD set to the build root.
Sibling files of a test source:
- `<name>.stdin`: fed to the program as standard input (otherwise standard input is empty).
- `<name>.expect`: line 1 the expected exit status, optional line 2 a text standard error must
  contain; the program is then one case named after it (for fatal-path tests).
A program without `.expect` that exits non-zero counts as one failure named after the program.
"""
import argparse
import collections
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PACKAGES = ["shim", "formats", "proto", "content", "extract", "core", "server", "client"]
CONVERGENCE = "convergence"
DIRECTORIES = {CONVERGENCE: "tests/convergence"}
DEPENDENCIES = {
    "shim": [],
    "formats": ["shim"],
    "proto": ["shim"],
    "content": ["shim", "proto", "formats"],
    "extract": ["shim", "proto", "formats", "content"],
    "core": ["shim", "formats", "proto", "content"],
    "server": ["shim", "formats", "proto", "content", "core"],
    "client": ["shim", "formats", "proto", "content", "core"],
    CONVERGENCE: list(PACKAGES),
}
TEST_PREFIXES = ("acc_", "contract_", "test_")
TEST_EXTENSIONS = (".cob", ".c")

Result = collections.namedtuple("Result", "case passed expected observed")


def parse_line(line):
    """The Result of one `TEST` output line, or None for any other line."""
    if not line.startswith("TEST "):
        return None
    body = line[len("TEST "):]
    if body.endswith(" PASS"):
        return Result(body[: -len(" PASS")], True, "", "")
    marker = body.find(" FAIL expected=")
    split = body.rfind(" observed=")
    if marker < 0 or split < marker:
        return None
    return Result(body[:marker], False, body[marker + len(" FAIL expected="):split], body[split + len(" observed="):])


def select_packages(names):
    """The named packages (every real package when none are named) in dependency order; the
    convergence pseudo-package, when named, comes last."""
    return [p for p in PACKAGES if not names or p in names] + [p for p in [CONVERGENCE] if p in names]


def package_directory(package):
    """The package's directory, relative to the repository root."""
    return DIRECTORIES.get(package, package)


def build_order(selected):
    """The selected packages and everything they depend on, in dependency order."""
    needed = set(selected)
    for package in selected:
        needed.update(DEPENDENCIES[package])
    return [p for p in PACKAGES if p in needed]


def discover_tests(repo, package):
    """Repository-relative paths of the package's test program sources, sorted."""
    relative = DIRECTORIES.get(package, package + "/tests")
    directory = os.path.join(repo, relative)
    if not os.path.isdir(directory):
        return []
    return [
        relative + "/" + name
        for name in sorted(os.listdir(directory))
        if name.startswith(TEST_PREFIXES) and name.endswith(TEST_EXTENSIONS)
    ]


def program_path(build, source):
    directory, _, name = source.rpartition("/")
    package = next((p for p, d in DIRECTORIES.items() if d == directory), directory.split("/")[0])
    return os.path.join(build, package, "tests", os.path.splitext(name)[0])


def describe_status(returncode):
    return "signal %d" % -returncode if returncode < 0 else "exit %d" % returncode


def read_expect(path):
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().splitlines()
    return int(lines[0]), lines[1] if len(lines) > 1 else ""


def run_program(program, source, cwd):
    """Run one test program from `cwd`; return its Results."""
    name = os.path.splitext(source)[0]
    if not os.path.isfile(program):
        return [Result(name, False, "test program built", "missing")]
    stdin_path = os.path.join(cwd, name + ".stdin")
    expect_path = os.path.join(cwd, name + ".expect")
    stdin = open(stdin_path, "rb") if os.path.isfile(stdin_path) else subprocess.DEVNULL
    try:
        completed = subprocess.run([program], cwd=cwd, stdin=stdin, capture_output=True)
    finally:
        if stdin is not subprocess.DEVNULL:
            stdin.close()
    stdout = completed.stdout.decode("utf-8", "replace")
    stderr = completed.stderr.decode("utf-8", "replace")
    results = [r for r in (parse_line(line) for line in stdout.splitlines()) if r is not None]
    status = describe_status(completed.returncode)
    if os.path.isfile(expect_path):
        expected_status, expected_stderr = read_expect(expect_path)
        if completed.returncode == expected_status and expected_stderr in stderr:
            results.append(Result(name, True, "", ""))
        else:
            expected = "exit %d" % expected_status
            if expected_stderr:
                expected += " stderr containing " + expected_stderr
            observed = status + " stderr " + " | ".join(stderr.splitlines())
            results.append(Result(name, False, expected, observed))
    elif completed.returncode != 0:
        results.append(Result(name, False, "exit 0", status))
        for line in stderr.splitlines():
            print("  " + name + ": " + line)
    return results


def report(results):
    lines = [
        "FAIL %s expected=%s observed=%s" % (r.case, r.expected, r.observed) for r in results if not r.passed
    ]
    passed = sum(1 for r in results if r.passed)
    lines.append("passed %d failed %d" % (passed, len(results) - passed))
    return lines


def make(package, target, build, coverage):
    command = ["make", "-C", os.path.join(REPO, package_directory(package)), target, "BUILD=" + build, "COVERAGE=" + ("1" if coverage else "0")]
    returncode = subprocess.run(command).returncode
    if returncode != 0:
        print("ERROR build: %s exited %d" % (" ".join(command), returncode))
    return returncode == 0


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description="Build and run the test programs of the selected packages.")
    parser.add_argument("--build", default=os.path.join(REPO, "build"), help="build output root")
    parser.add_argument("--coverage", action="store_true", help="build with coverage instrumentation")
    parser.add_argument(
        "packages", nargs="*", choices=PACKAGES + [CONVERGENCE], metavar="PACKAGE", help=" ".join(PACKAGES + [CONVERGENCE])
    )
    return parser.parse_args(argv)


def main(argv):
    arguments = parse_arguments(argv)
    build = os.path.abspath(arguments.build)
    selected = select_packages(arguments.packages)
    os.environ["COBOLCRAFT_BUILD"] = build
    for package in build_order(selected):
        if not make(package, "lib", build, arguments.coverage):
            return 1
    for package in selected:
        if not make(package, "tests", build, arguments.coverage):
            return 1
    results = []
    for package in selected:
        for source in discover_tests(REPO, package):
            results.extend(run_program(program_path(build, source), source, REPO))
    for line in report(results):
        print(line)
    return 0 if all(r.passed for r in results) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
