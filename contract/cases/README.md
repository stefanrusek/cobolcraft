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

## Seams on the branch

| Table | Group target | What it pins |
|---|---|---|
| `wire-chat.tsv` | `make contract-wire` | chat packets, both sides of the same fixtures (core builds and decodes, client sends and reads) |
| `wire-core.tsv` | `make contract-wire` | core to proto packets: Set Health, Update Mob Effect, Level Chunk With Light of the spawn chunk (no fixture with block entities exists yet; Container Set Content needs player state beyond the row inputs and stays in WIRECRAFT.cpy and WIREPLAY.cpy) |
| `play-core-blocks.tsv` | `make contract-play` | what the core sends a player for Use Item On, Player Action and `BLOCK-CHANGE`, in the order of doc 29 §7 |
| `content-recipes.tsv` | `make contract-content` | `PB-RECIPE-ENTRY` record size (copybook, table and probe must agree, computed from the copybook) and the Recipe Book Add of a player who knows no recipe |

`make contract-affected [BASE=main]` runs the seams whose `# paths:` match the changed files. All three run in
seconds once the libraries are built.

## Known divergence rows

A row id that starts with `!` records a behaviour the docs state and the code does not have. The generated case
passes while the code differs (and prints a `DIVERGENCE` line with both values when the program is run
directly) and fails as soon as the code matches the docs, so the `!` is then removed. Use it only for a
documented rule, never to park a wrong expectation.

## The unwired report

`python3 tools/gen/gen_contract.py --unwired` writes `contract/cases/unwired.txt`: the core host contract entries
(core-host-api.md, core-host-delta.md) with the hosts that call them, and every program of a `src/` that no
`src/` file calls (`tests only` or `no caller`). Calls are textual (`CALL "NAME"`, `ENTRY "NAME"`), so a call
through a data item or from C is not seen: a listed program is a candidate to check. A contract entry that a
completed task (`- [X]`) of any `specs/*/tasks.md` names and no host calls is an error: it fails
`gen_contract.py --check` (and so `gate-tables`); the other entries are warnings. Regenerate the file when a
lane wires something up; it is not checked for freshness.

## Record sizes

`PB-RECIPE-ENTRY` grew from 125 to 1061 bytes (commit 7db9151) and the contract probe lagged it. A `copy-size`
row (content-recipes.tsv) makes `gen_contract.py --check` sum the record's size from `contract/copy` itself and
compare it with the row and with the probe's expectation, so any of the three drifting fails in seconds.
