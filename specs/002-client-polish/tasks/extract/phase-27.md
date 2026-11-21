#### Phase 27: US1-extract — the extraction tool (`docs/protocol/22-extraction-tool.md`)

**Goal**: `cobolcraft-extract` writes the vanilla resource pack and data pack from the user's jar (FR-001). **Independent Test**: the 22 §12 T-series against `tmp/minecraft-26.3-client.jar`; `CONTENT-PACKS-CHECK` returns `ok` on the output.

- [x] T0293 [US1-extract] Write test `extract/tests/test_ex_args.cob` for `EX-ARGS`: `--jar --game-dir --generated-dir --force --verify --dry-run --quiet`, defaults (`<game dir>/generated`), unknown option gives CCX-001 and exit 1 (22 §7.1)
- [x] T0294 [US1-extract] Implement `EX-ARGS` in `extract/src/args.cob`
- [x] T0295 [US1-extract] Write test `extract/tests/test_ex_jar_find.cob` for `EX-JAR-FIND`: the search order of 22 §4.3 over a scratch game directory
- [x] T0296 [US1-extract] Implement `EX-JAR-FIND` in `extract/src/jar-find.cob`
- [x] T0297 [US1-extract] Write test `extract/tests/test_ex_check.cob` for `EX-CHECK` C1 to C5 (22 §4.2) over `contract/fixtures/extract/` reject archives: not a zip, wrong SHA-256, missing entries, each with its CCX code
- [x] T0298 [US1-extract] Implement `EX-CHECK` in `extract/src/check.cob` (SHA-256 with `SHA256-*`, accepted row from `CONTENT-ACCEPTED-JAR`)
- [x] T0299 [US1-extract] Write test `extract/tests/test_ex_plan.cob` for `EX-PLAN` (22 §6.3): the payload entry list, the counts, the destination paths
- [x] T0300 [US1-extract] Implement `EX-PLAN` in `extract/src/plan.cob`
- [x] T0301 [US1-extract] Write test `extract/tests/test_ex_walk.cob` for `EX-WALK` (22 §7.3 step 7): each planned entry reads with `ZIP-READ-RANGE`, passes its CRC check and is written under `<generated>.partial`
- [x] T0302 [US1-extract] Implement `EX-WALK` in `extract/src/walk.cob`
- [x] T0303 [US1-extract] Write test `extract/tests/test_ex_manifest.cob` for `EX-WRITE-MANIFEST` (22 §6.4) and `EX-WRITE-INDEX` (22 §6.5): byte format, sentinel `.cobolcraft-generated`
- [x] T0304 [US1-extract] Implement `EX-WRITE-MANIFEST` and `EX-WRITE-INDEX` in `extract/src/manifest.cob`
- [x] T0305 [US1-extract] Write test `extract/tests/test_ex_verify.cob` for `EX-VERIFY` (22 §7.6): full integrity check passes on a good tree and names the damaged file
- [x] T0306 [US1-extract] Implement `EX-VERIFY` in `extract/src/verify.cob`
- [x] T0307 [US1-extract] Write test `extract/tests/test_ex_main.cob` for `EX-MAIN`: idempotence (CCX-100, nothing rebuilt), `--force`, `--dry-run` writes nothing, the atomic swap `<generated>.partial` to `<generated>` (22 §7.5), exit statuses of 22 §7.4
- [x] T0308 [US1-extract] Implement `EX-MAIN` in `extract/src/ex-main.cob` and the one-`CALL` `extract/src/main.cob`
- [x] T0309 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_real_jar.cob` (real input, fails loudly without the jar): scenarios US1-1 (the vanilla resource pack and data pack exist in the layout of 22 §5.2 with the T5 counts: 11,605 resource files, 9,779 data files, 106 feature files), US1-2 second run does nothing, an unrecognised jar is rejected (CCX-030 or CCX-031, nothing written) [FR-001, FR-002; SC-012]
- [x] T0310 [US1-extract] Write edge-case test `extract/tests/test_ex_partial.cob` (spec edge case "the jar changes between runs"): a `.partial` left by an interrupted run is removed and rebuilt by the next run, a jar whose SHA-256 differs from the manifest's is rejected before anything is written, and `<generated>` is never half-written (22 §7.5)
- [x] T0311 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_git_clean.cob`: after a real run `git ls-files` lists no jar and no generated file (SC-012) [FR-001, FR-002]
- [x] T0312 [US1-extract] Write contract test `extract/tests/contract_extract_provider.cob`: output tree and manifest against 22 §5.2, §6.4, §6.5 with the real jar
- [x] T0313 [US1-extract] Write consumer-side test `extract/tests/contract_extract_content_consumer.cob` (the contract names it `contract_content_consumer_extract` in the content package; it lives in this lane so lanes stay disjoint): the tool's real output passes `CONTENT-PACKS-CHECK`; a tampered manifest gives `stale`, a removed sentinel `damaged`
- [x] T0314 [US1-extract] Write consumer test `extract/tests/contract_formats_consumer.cob` calling `ZIP-*`, `CRC32`, `SHA256-*`, `FILE-*`, `DIR-*` the way the tool does
- [x] T0315 [US1-extract] Write implementation tests in `extract/tests/test_extract_cover.cob` for lines of `extract/src` left unexecuted
- [x] T0316 [US1-extract] Gate: run `make gate-extract` and record the command and real output
