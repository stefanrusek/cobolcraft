# Contract: the extraction tool surface (`extract` <-> Player and Server operator; `extract` -> `content`)

**Status**: frozen at plan time. The behaviour is `docs/protocol/22-extraction-tool.md` (sections 4 to 7, 12); this
contract fixes the package seams only. Package `extract` builds `build/bin/cobolcraft-extract` from `src/main.cob`
(one `CALL` of `EX-MAIN`, as `SV-MAIN` and `CL-MAIN` do) and `build/extract/libextract.a`.

| Item | Contract |
|---|---|
| Command line | `cobolcraft-extract [--jar P] [--game-dir P] [--generated-dir P] [--force] [--verify] [--dry-run] [--quiet]` (22 §7.1). Unknown option: CCX-001, exit 1. |
| Output | the generated directory of 22 §5.2, written to `<generated>.partial` and swapped in (22 §7.5); messages and exit codes of 22 §7.4 (`CCX-nnn`). |
| Accepted jar | the row of `content`'s generated accepted-jar table; `extract` links no other copy (data-model §1). |
| Valid result | `CONTENT-PACKS-CHECK` returns `ok` on the output (this is what the loaders trust); `--verify` is the full integrity check (22 §7.6). |
| Programs | `EX-MAIN`, `EX-ARGS`, `EX-JAR-FIND`, `EX-CHECK` (22 §4.2 C1 to C5), `EX-PLAN` (22 §6.3), `EX-WALK` (22 §7.3 step 7), `EX-WRITE-MANIFEST`, `EX-WRITE-INDEX`, `EX-VERIFY`. |
| Inputs | the user's jar. Tests read `tmp/minecraft-26.3-client.jar` (the operator's git-ignored input) and fail loudly when it is absent; the tool's reject tests use small hand-made archives under `contract/fixtures/extract/`. |
| Git | `generated/` is added to `.gitignore` (Setup task); no jar or generated file is ever committed (SC-012), verified once by a review task and by `git ls-files` in the tool's own acceptance test. |

**Contract tests.** `extract/tests/contract_extract_provider.cob` (output tree and manifest against 22 §5.2, §6.4,
§6.5, counts of 22 §12 T5 with the real jar) and `content/tests/contract_content_consumer_extract.cob` (the
extraction tool's real output passes `CONTENT-PACKS-CHECK`; a tampered manifest gives `stale`, a removed sentinel
`damaged`). Both fail loudly without the jar: this is the credential-gated real-provider pattern of 4.1 (the
"credential" is the user's own jar), and the plan records the real-config debt: none beyond the file in `tmp/`.
