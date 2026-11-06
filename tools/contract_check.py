#!/usr/bin/env python3
"""Wire fixture check (contracts/proto-api.md §3; used by `make gate-contract`). Test infrastructure.

usage: contract_check.py [FILE ...]

Every file (default: every contract/fixtures/wire/*.hex) must parse: `#` starts a comment that runs
to the end of the line, the rest is whitespace-separated two-digit hex tokens, at least one byte.
Prints `ERROR <file>: <problem>` per failing file and `contract_check: <n> files, <m> failed`;
exits 1 if any failed.
"""
import glob
import os
import string
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_hex(path):
    """(bytes, [problem, ...]) of one fixture file."""
    data = bytearray()
    errors = []
    with open(path, encoding="utf-8") as handle:
        for number, line in enumerate(handle, start=1):
            for token in line.split("#", 1)[0].split():
                if len(token) == 2 and all(c in string.hexdigits for c in token):
                    data.append(int(token, 16))
                else:
                    errors.append("line %d: bad token '%s'" % (number, token))
    if not data and not errors:
        errors.append("no bytes")
    return bytes(data), errors


def default_files(repo):
    return sorted(glob.glob(os.path.join(repo, "contract", "fixtures", "wire", "*.hex")))


def main(argv):
    files = argv or default_files(REPO)
    failed = 0
    for path in files:
        _, errors = parse_hex(path)
        if errors:
            failed += 1
            for error in errors:
                print("ERROR %s: %s" % (path, error))
    print("contract_check: %d files, %d failed" % (len(files), failed))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
