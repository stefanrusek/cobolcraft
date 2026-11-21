#!/usr/bin/env python3
"""Line coverage check (research R9; constitution 4.2). Test infrastructure, stdlib only.

usage: coverage.py [--build DIR] [--changed-since REF [--list-packages]] [PACKAGE ...]

Run after an instrumented test run (`runtests.py --coverage`, which builds with `cobc --coverage` /
`clang --coverage`). For every object file under `<build>/<package>/obj` of the selected packages it
runs `gcov -t` (llvm-cov gcov) from the package directory, merges the line counts of every production
source, prints `UNCOVERED <file>:<line>` for every line never executed and exits 1 if there is one.

Objects: `<build>/<package>/obj` and, when the Convergence tests built them,
`<build>/convergence/obj/<package>` (the instrumented program entry files src/main.cob).

Production sources: shim/src/*.c, proto/src/*.cob, core/src/*.cob, core/copy/*.cpy,
formats/src/*.cob, formats/copy/*.cpy, content/src/*.cob, content/copy/*.cpy (not copy/gen/), extract/src/*.cob,
server/src/*.cob, client/src/**/*.cob. Everything else (tests, tools, specs, contract, generated C,
system headers) is ignored.

`--changed-since REF` is the check of a branch's own work after a run of only its own test programs
(`make cover-changed`): only the production lines that the working tree changed or added since it left REF
(the merge base of REF and HEAD, plus uncommitted and untracked files) are reported, as `UNCOVERED
<file>:<line>`, and the exit status is 1 if there is one. Lines that other test programs cover do not count
against it; it never satisfies a gate. With `--list-packages` it runs nothing and prints the packages that
have changed production sources, on one line.
"""
import argparse
import concurrent.futures
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PACKAGES = ["shim", "formats", "proto", "content", "extract", "core", "server", "client"]
# (directory, extension, whether subdirectories count) of every package's production sources.
PRODUCTION = {
    "shim": [("shim/src", ".c", False)],
    "formats": [("formats/src", ".cob", False), ("formats/copy", ".cpy", False)],
    "proto": [("proto/src", ".cob", False)],
    # content/copy/gen/ (generated registry copybooks, constitution 4.2) is a subdirectory and not recursive.
    "content": [("content/src", ".cob", False), ("content/copy", ".cpy", False)],
    "extract": [("extract/src", ".cob", False)],
    "core": [("core/src", ".cob", False), ("core/copy", ".cpy", False)],
    "server": [("server/src", ".cob", False)],
    "client": [("client/src", ".cob", True)],
}


def parse_gcov(text):
    """[(source, {line: executed})] for every `Source:` section of gcov text output.

    Only executable lines appear: a count means executed, `#####` and `=====` mean never executed.
    """
    sections = []
    for raw in text.splitlines():
        count, _, rest = raw.partition(":")
        number, _, content = rest.partition(":")
        count, number = count.strip(), number.strip()
        if number == "0":
            if content.startswith("Source:"):
                sections.append((content[len("Source:"):], {}))
            continue
        if not sections or count == "-" or not number.isdigit():
            continue
        sections[-1][1][int(number)] = count not in ("#####", "=====")
    return sections


def is_production(path, packages):
    """True when the repository-relative `path` is a production source of one of `packages`."""
    directory = os.path.dirname(path)
    for package in packages:
        for root, extension, recursive in PRODUCTION[package]:
            inside = directory == root or (recursive and directory.startswith(root + "/"))
            if inside and path.endswith(extension):
                return True
    return False


def collect(outputs, repo, packages):
    """Sorted `file:line` of every never-executed production line.

    `outputs` are (directory gcov ran in, gcov text) pairs; relative sources resolve against that
    directory. A line counts as executed if any object executed it.
    """
    lines = {}
    for directory, text in outputs:
        for source, counts in parse_gcov(text):
            path = os.path.relpath(os.path.normpath(os.path.join(directory, source)), repo)
            if not is_production(path, packages):
                continue
            merged = lines.setdefault(path, {})
            for number, executed in counts.items():
                merged[number] = merged.get(number, False) or executed
    return [
        "%s:%d" % (path, number)
        for path in sorted(lines)
        for number in sorted(lines[path])
        if not lines[path][number]
    ]


def objects(build, package):
    """The package's instrumented objects: its library objects, and the program entry objects the
    Convergence tests build and run (`<build>/convergence/obj/<package>`, kept apart so a package
    gate, which does not run them, never sees them)."""
    found = []
    for root in (os.path.join(build, package, "obj"), os.path.join(build, "convergence", "obj", package)):
        for directory, _, names in os.walk(root):
            found.extend(os.path.join(directory, name) for name in names if name.endswith(".o"))
    return sorted(found)


HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")


def parse_diff(text):
    """{path: {line numbers}} of the lines a `git diff -U0` text adds or changes (new numbering)."""
    changed = {}
    path = None
    for line in text.splitlines():
        if line.startswith("+++ "):
            path = line[6:] if line.startswith("+++ b/") else None
            continue
        match = HUNK.match(line)
        if match and path is not None:
            start, count = int(match.group(1)), int(match.group(2) or "1")
            if count:
                changed.setdefault(path, set()).update(range(start, start + count))
    return changed


def changed_lines(repo, reference):
    """{path: {line numbers}, or None for every line} of what the working tree of `repo` changed since it
    left `reference`: the diff against their merge base, and every untracked file as a whole."""

    def git(*arguments):
        return subprocess.run(["git", "-C", repo, *arguments], check=True, stdout=subprocess.PIPE, text=True).stdout

    base = git("merge-base", reference, "HEAD").strip()
    changed = parse_diff(git("diff", "-U0", "--no-color", "--no-ext-diff", "--no-renames", base))
    for path in git("ls-files", "--others", "--exclude-standard").splitlines():
        changed[path] = None
    return changed


def restrict(uncovered, changed):
    """The `file:line` entries of `uncovered` that are changed lines."""
    kept = []
    for entry in uncovered:
        path, _, number = entry.rpartition(":")
        if path in changed and (changed[path] is None or int(number) in changed[path]):
            kept.append(entry)
    return kept


def changed_packages(changed):
    """The packages with a changed production source, in PACKAGES order."""
    return [p for p in PACKAGES if any(is_production(path, [p]) for path in changed)]


def gcov_output(package_dir, obj):
    completed = subprocess.run(
        ["gcov", "-t", "-o", obj, obj], cwd=package_dir, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
    )
    return completed.stdout


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description="Fail on never-executed production lines.")
    parser.add_argument("--build", default=os.path.join(REPO, "build", "coverage"), help="instrumented build root")
    parser.add_argument("--changed-since", metavar="REF", help="report only the lines changed since the tree left REF")
    parser.add_argument("--list-packages", action="store_true", help="with --changed-since: print the changed packages")
    parser.add_argument("--jobs", type=int, default=os.cpu_count() or 1, metavar="N", help="run N gcov at a time")
    parser.add_argument("packages", nargs="*", choices=PACKAGES, metavar="PACKAGE", help=" ".join(PACKAGES))
    return parser.parse_args(argv)


def main(argv):
    arguments = parse_arguments(argv)
    packages = [p for p in PACKAGES if not arguments.packages or p in arguments.packages]
    build = os.path.abspath(arguments.build)
    changed = changed_lines(REPO, arguments.changed_since) if arguments.changed_since else None
    if arguments.list_packages:
        print(" ".join(changed_packages(changed or {})))
        return 0
    work = [(os.path.join(REPO, package), obj) for package in packages for obj in objects(build, package)]
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(arguments.jobs, 1)) as pool:
        outputs = list(zip((d for d, _ in work), pool.map(lambda item: gcov_output(*item), work)))
    uncovered = collect(outputs, REPO, packages)
    if changed is not None:
        uncovered = restrict(uncovered, changed)
    for line in uncovered:
        print("UNCOVERED " + line)
    if changed is None:
        print("coverage: %d objects, %d uncovered lines" % (len(outputs), len(uncovered)))
    else:
        print("coverage: %d objects, %d uncovered changed lines" % (len(outputs), len(uncovered)))
    return 1 if uncovered else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
