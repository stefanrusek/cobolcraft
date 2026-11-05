#!/usr/bin/env python3
"""Line coverage check (research R9; constitution 4.2). Test infrastructure, stdlib only.

usage: coverage.py [--build DIR] [PACKAGE ...]

Run after an instrumented test run (`runtests.py --coverage`, which builds with `cobc --coverage` /
`clang --coverage`). For every object file under `<build>/<package>/obj` of the selected packages it
runs `gcov -t` (llvm-cov gcov) from the package directory, merges the line counts of every production
source, prints `UNCOVERED <file>:<line>` for every line never executed and exits 1 if there is one.

Production sources: shim/src/*.c, proto/src/*.cob, core/src/*.cob, core/copy/*.cpy,
server/src/*.cob, client/src/**/*.cob. Everything else (tests, tools, specs, contract, generated C,
system headers) is ignored.
"""
import argparse
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PACKAGES = ["shim", "proto", "core", "server", "client"]
# (directory, extension, whether subdirectories count) of every package's production sources.
PRODUCTION = {
    "shim": [("shim/src", ".c", False)],
    "proto": [("proto/src", ".cob", False)],
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
    found = []
    for directory, _, names in os.walk(os.path.join(build, package, "obj")):
        found.extend(os.path.join(directory, name) for name in names if name.endswith(".o"))
    return sorted(found)


def gcov_output(package_dir, obj):
    completed = subprocess.run(
        ["gcov", "-t", "-o", obj, obj], cwd=package_dir, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
    )
    return completed.stdout


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description="Fail on never-executed production lines.")
    parser.add_argument("--build", default=os.path.join(REPO, "build", "coverage"), help="instrumented build root")
    parser.add_argument("packages", nargs="*", choices=PACKAGES, metavar="PACKAGE", help=" ".join(PACKAGES))
    return parser.parse_args(argv)


def main(argv):
    arguments = parse_arguments(argv)
    packages = [p for p in PACKAGES if not arguments.packages or p in arguments.packages]
    build = os.path.abspath(arguments.build)
    outputs = []
    for package in packages:
        package_dir = os.path.join(REPO, package)
        outputs.extend((package_dir, gcov_output(package_dir, obj)) for obj in objects(build, package))
    uncovered = collect(outputs, REPO, packages)
    for line in uncovered:
        print("UNCOVERED " + line)
    print("coverage: %d objects, %d uncovered lines" % (len(outputs), len(uncovered)))
    return 1 if uncovered else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
