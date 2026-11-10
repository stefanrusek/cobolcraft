# Contract cases

One tab-separated table per seam, `contract/cases/<seam>.tsv`, read by `tools/gen/gen_contract.py`. A row names
one entry point of one package (the owner), the package whose `src/` must call it (the caller), the wire
fixtures that state the bytes, the inputs and the expected text. The generator writes one test program per
owner package into `build/gen/<owner>/tests/contract_<seam>_<owner>.cob` (generated, so excluded from coverage);
`tools/runtests.py` builds and runs it like any contract test.

Expected values come from `docs/protocol/` and `contract/fixtures` (their headers state inputs and doc
references), never from running our own code (constitution Principle II).

## Add a row

1. Pick the seam table (or see below for a new one) and add a line with 8 tab-separated columns:
   `id, op, entry, owner, caller, fixtures, inputs, expected`. Inputs are `name=value;name=value` (no double
   quotes). Build ops leave `expected` empty: the expected value is the fixture's bytes.
2. If no op fits, add a template to `OPS` in `tools/gen/gen_contract.py` (one function that returns COBOL lines)
   and a unit test in `tools/tests/test_gen_contract.py`.
3. `python3 tools/gen/gen_contract.py --check` must pass: it validates the table, the fixtures and that
   `CALL "<entry>"` exists in `<caller>/src` (a contract entry nobody calls is a failure).
4. `make contract-wire` (seconds when warm) runs the generated programs. It is intermediate: no coverage, and
   the full `make gate-<pkg>` stays the terminal check. Generated cases also run in the full gates.
5. Replace, do not duplicate: delete the hand-written case the row covers.

## Add a seam

1. Create `contract/cases/<seam>.tsv` with `# seam: <name>` and a `# paths:` line (files or directory prefixes
   whose change selects the seam for `make contract-affected`).
2. Add the ops and the owner template head/tail (`TEMPLATES`) it needs to `gen_contract.py`.
3. Add a `contract-<group>` target to the Makefile like `contract-wire` (`--only-args <seam name prefix>`).
4. `make contract-affected [BASE=main]` maps `git diff` plus untracked files to seams through the `# paths:` lines.
