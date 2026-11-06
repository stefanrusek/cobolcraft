"""Scratch copies of the repository for the US1 acceptance tests (test infrastructure).

A scratch copy holds everything a Contributor's checkout holds except version control data, build
outputs and every existing test program, so the copy's test run contains exactly the test programs
an acceptance case adds.
"""
import os
import shutil
import subprocess
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
# Test directories: their test programs (and the programs' sibling files) are left out; everything
# else in them (fixture generators, helper copybooks) is kept, since package builds use it.
TEST_DIRS = {
    os.path.join("shim", "tests"),
    os.path.join("proto", "tests"),
    os.path.join("core", "tests"),
    os.path.join("server", "tests"),
    os.path.join("client", "tests"),
    os.path.join("tools", "tests"),
    os.path.join("tests", "convergence"),
}
TEST_PREFIXES = ("acc_", "contract_", "test_")


def make_copy():
    """Copy the repository to a new temporary directory and return its path."""
    root = tempfile.mkdtemp(prefix="cobolcraft-scratch-")
    copy = os.path.join(root, "repo")

    def ignore(directory, names):
        relative = os.path.relpath(directory, REPO)
        skipped = []
        for name in names:
            if name in (".git", "build", "__pycache__"):
                skipped.append(name)
            elif relative in TEST_DIRS and name.startswith(TEST_PREFIXES):
                skipped.append(name)
        return skipped

    shutil.copytree(REPO, copy, ignore=ignore)
    return copy


def remove_copy(copy):
    shutil.rmtree(os.path.dirname(copy))


def write(copy, relative, text):
    path = os.path.join(copy, relative)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)


def make(copy, target):
    """Run `make <target>` in the copy; return (exit status, standard output).

    make's own diagnostics (such as "make: *** [test] Error 1") go to standard error, so the last line
    of standard output is the last line the command itself printed."""
    result = subprocess.run(["make", "-C", copy, target], stdout=subprocess.PIPE, text=True)
    return result.returncode, result.stdout


COBOL_TEST = """\
 IDENTIFICATION DIVISION.
 PROGRAM-ID. {program}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 PROCEDURE DIVISION.
     MOVE "{case}" TO TL-CASE
     SET TL-NUMBER TO TRUE
     MOVE {expected} TO TL-EXPECTED-N
     MOVE {observed} TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
"""

C_TEST = """\
#include "testlib.h"

int main(void) {{
    tl_int("{case}", {expected}, {observed});
    return 0;
}}
"""

C_CRASH = """\
#include <stdlib.h>

int main(void) {
    abort();
}
"""
