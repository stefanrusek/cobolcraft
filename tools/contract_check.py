#!/usr/bin/env python3
"""Contract check (contracts/proto-api.md §3, test-harness-delta.md; used by `make gate-contract`).
Test infrastructure.

usage: contract_check.py [--repo DIR] [FILE ...]

Every file (default: every contract/fixtures/wire/*.hex) must parse: `#` starts a comment that runs
to the end of the line, the rest is whitespace-separated two-digit hex tokens, at least one byte.
Prints `ERROR <file>: <problem>` per failing file and `contract_check: <n> files, <m> failed`.

Without FILE arguments it also checks the contract copybooks (contract/copy/*.cpy): each must compile
in a program of its own, and tools/probe/probe_contract.cob must `COPY` each one (so the probe
compiles every copybook and a new one cannot be left out). Prints `ERROR <copybook>: <problem>` and
`contract_check: <n> copybooks, <m> failed`. Exits 1 if anything failed.
"""
import glob
import os
import re
import string
import subprocess
import sys
import tempfile

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


def copybook_names(repo):
    """File names of the contract copybooks, sorted."""
    return sorted(os.path.basename(p) for p in glob.glob(os.path.join(repo, "contract", "copy", "*.cpy")))


def compile_copybooks(repo, cobc="cobc"):
    """[(copybook, [message, ...])] for every copybook that does not compile in a program of its own."""
    problems = []
    copy_dir = os.path.join(repo, "contract", "copy")
    with tempfile.TemporaryDirectory() as scratch:
        for name in copybook_names(repo):
            source = os.path.join(scratch, "check.cob")
            with open(source, "w", encoding="utf-8") as handle:
                handle.write(
                    " IDENTIFICATION DIVISION.\n PROGRAM-ID. COPYBOOK-CHECK.\n DATA DIVISION.\n"
                    " WORKING-STORAGE SECTION.\n COPY %s.\n PROCEDURE DIVISION.\n     GOBACK.\n"
                    % os.path.splitext(name)[0]
                )
            result = subprocess.run(
                [cobc, "-fsyntax-only", "-free", "-std=default", "-I", copy_dir, source],
                capture_output=True,
                text=True,
                cwd=scratch,
            )
            if result.returncode != 0:
                lines = [line.strip() for line in (result.stderr + result.stdout).splitlines() if "error" in line]
                problems.append((name, lines or ["cobc exited %d" % result.returncode]))
    return problems


def probe_missing(repo):
    """Copybooks that tools/probe/probe_contract.cob does not COPY."""
    with open(os.path.join(repo, "tools", "probe", "probe_contract.cob"), encoding="utf-8") as handle:
        copied = {m.upper() for m in re.findall(r"^\s*COPY\s+([A-Za-z0-9-]+)\s*\.", handle.read(), re.M)}
    return [n for n in copybook_names(repo) if os.path.splitext(n)[0].upper() not in copied]


ROW_VIEWS = [("blocks.cpy", "GEN-BLOCK-W-", "CT-BLOCK-ROW"), ("items.cpy", "GEN-ITEM-W-", "CT-ITEM-ROW"),
             ("entities.cpy", "GEN-ENTITY-W-", "CT-ENTITY-ROW"), ("staticids.cpy", "GEN-STATIC-W-", "CT-STATIC-ID-ROW")]


def row_width_problems(repo):
    """Messages for each CONTENT.cpy row view whose field widths differ from the generated column widths
    (content/copy/gen/*.cpy GEN-<TABLE>-W-* constants, in file order). Skipped without those files."""
    problems = []
    content = os.path.join(repo, "contract", "copy", "CONTENT.cpy")
    if not os.path.exists(content):
        return problems
    with open(content, encoding="utf-8") as handle:
        text = handle.read()
    for gen_name, prefix, view in ROW_VIEWS:
        gen_path = os.path.join(repo, "content", "copy", "gen", gen_name)
        if not os.path.exists(gen_path):
            continue
        with open(gen_path, encoding="utf-8") as handle:
            expected = [int(w) for w in re.findall(r"^78 %s\S+ VALUE (\d+)\." % prefix, handle.read(), re.M)]
        group = re.search(r"^ 01 %s\.\n((?:    05 .*\n)+)" % view, text, re.M)
        actual = [int(w) for w in re.findall(r"PIC X\((\d+)\)", group.group(1))] if group else []
        if actual != expected:
            problems.append("%s widths %s differ from %s widths %s" % (view, actual, gen_name, expected))
    return problems


def main(argv):
    argv = list(argv)
    repo = REPO
    if argv[:1] == ["--repo"]:
        repo = argv[1]
        argv = argv[2:]
    explicit = bool(argv)
    files = argv or default_files(repo)
    failed = 0
    for path in files:
        _, errors = parse_hex(path)
        if errors:
            failed += 1
            for error in errors:
                print("ERROR %s: %s" % (path, error))
    print("contract_check: %d files, %d failed" % (len(files), failed))
    if explicit:
        return 1 if failed else 0
    names = copybook_names(repo)
    bad = {}
    for line in row_width_problems(repo):
        bad.setdefault("CONTENT.cpy", []).append(line)
    for name, lines in compile_copybooks(repo):
        bad[name] = lines
    for name in probe_missing(repo):
        bad.setdefault(name, []).append("not copied by tools/probe/probe_contract.cob")
    for name in sorted(bad):
        for line in bad[name]:
            print("ERROR %s: %s" % (name, line))
    print("contract_check: %d copybooks, %d failed" % (len(names), len(bad)))
    return 1 if failed or bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
