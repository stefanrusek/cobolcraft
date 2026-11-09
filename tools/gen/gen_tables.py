#!/usr/bin/env python3
"""Registry copybook generator and drift gate (contracts/test-harness-delta.md `make gate-tables`).

usage: gen_tables.py (--check | --write) [--out DIR]

`--write` regenerates the registry copybooks into DIR (default content/copy/gen/). `--check` regenerates
them into a scratch directory, compares every file byte for byte with DIR and exits 1 naming each file that
differs, is missing or is unexpected; it exits 0 when DIR equals the regeneration. No table is defined yet,
so the generated set is empty. Test infrastructure, stdlib only.
"""
import argparse
import os
import sys
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DEFAULT_OUT = os.path.join(REPO, "content", "copy", "gen")
# Files that live in the generated directory without being generated.
KEEP = {".gitkeep"}


def generate(directory):
    """Write every generated file into `directory` and return their names (none yet)."""
    os.makedirs(directory, exist_ok=True)
    return []


def listing(directory):
    """Sorted names of the files under `directory` (empty when it does not exist)."""
    found = []
    for root, _, names in os.walk(directory):
        found.extend(os.path.relpath(os.path.join(root, name), directory) for name in names if name not in KEEP)
    return sorted(found)


def read(path):
    with open(path, "rb") as handle:
        return handle.read()


def drift(expected_dir, actual_dir):
    """Names of the files of the two directories that differ, are missing or are unexpected."""
    differing = []
    for name in sorted(set(listing(expected_dir)) | set(listing(actual_dir))):
        expected = os.path.join(expected_dir, name)
        actual = os.path.join(actual_dir, name)
        if not (os.path.isfile(expected) and os.path.isfile(actual) and read(expected) == read(actual)):
            differing.append(name)
    return differing


def main(argv):
    parser = argparse.ArgumentParser(description="Generate or check the registry copybooks.")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="fail when DIR differs from a fresh regeneration")
    mode.add_argument("--write", action="store_true", help="regenerate DIR")
    parser.add_argument("--out", default=DEFAULT_OUT, help="generated directory (default content/copy/gen)")
    arguments = parser.parse_args(argv)
    if arguments.write:
        generate(arguments.out)
        return 0
    with tempfile.TemporaryDirectory(prefix="gen-tables-") as scratch:
        generate(scratch)
        differing = drift(scratch, arguments.out)
    for name in differing:
        print("DRIFT " + name)
    print("gen_tables: %d differing files" % len(differing))
    return 1 if differing else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
