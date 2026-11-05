#!/usr/bin/env python3
"""Lint driver (research R9). Test infrastructure, stdlib only.

usage: lint.py [-I DIR]... FILE...

Checks each file by its extension and prints `LINT FAIL <file>` (after the tool's own output) for
every file that fails, then `lint: <n> files, <m> failed`; exits 1 if any failed.
- .cob     cobc -fsyntax-only -free -Wall -Werror -I contract/copy -I DIR...
           (-Wall, not -Wextra: research R9 records why)
- .c, .h   clang -fsyntax-only -std=c11 -Wall -Wextra -Werror -I contract/include -I DIR...
- .vert, .frag   glslangValidator -V, then spirv-val on the result
- .py      python3 -m py_compile
Any other file type fails.
"""
import argparse
import os
import subprocess
import sys
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def run(command):
    completed = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return completed.returncode == 0, completed.stdout


def include_flags(include_dirs):
    flags = []
    for directory in include_dirs:
        flags += ["-I", directory]
    return flags


def lint_cobol(path, include_dirs):
    command = ["cobc", "-fsyntax-only", "-free", "-Wall", "-Werror", "-I", os.path.join(REPO, "contract", "copy")]
    return run(command + include_flags(include_dirs) + [path])


def lint_c(path, include_dirs):
    command = ["clang", "-fsyntax-only", "-std=c11", "-Wall", "-Wextra", "-Werror", "-I", os.path.join(REPO, "contract", "include")]
    return run(command + include_flags(include_dirs) + [path])


def lint_glsl(path, include_dirs):
    with tempfile.TemporaryDirectory() as directory:
        spirv = os.path.join(directory, "shader.spv")
        ok, output = run(["glslangValidator", "-V", path, "-o", spirv])
        if not ok:
            return ok, output
        return run(["spirv-val", spirv])


def lint_python(path, include_dirs):
    return run([sys.executable, "-m", "py_compile", path])


CHECKS = {
    ".cob": lint_cobol,
    ".c": lint_c,
    ".h": lint_c,
    ".vert": lint_glsl,
    ".frag": lint_glsl,
    ".py": lint_python,
}


def lint_file(path, include_dirs):
    """(passed, tool output) for one file."""
    check = CHECKS.get(os.path.splitext(path)[1])
    if check is None:
        return False, "unsupported file type: %s\n" % path
    return check(path, include_dirs)


def main(argv):
    parser = argparse.ArgumentParser(description="Lint COBOL, C, GLSL and Python sources.")
    parser.add_argument("-I", dest="include_dirs", action="append", default=[], help="include directory")
    parser.add_argument("files", nargs="*")
    arguments = parser.parse_args(argv)
    failed = 0
    for path in arguments.files:
        ok, output = lint_file(path, arguments.include_dirs)
        if not ok:
            failed += 1
            sys.stdout.write(output)
            print("LINT FAIL " + path)
    print("lint: %d files, %d failed" % (len(arguments.files), failed))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
