#### Phase 18: US1-content — packs check and accepted jar

**Goal**: the game can tell whether valid generated packs exist and why not (22 §8.2, FR-003, FR-004). **Independent Test**: `CONTENT-PACKS-CHECK` over the fixture trees returns `ok`, `stale`, `damaged`, `absent`, `incomplete`.

- [x] T0181 [US1-content] Write test `content/tests/test_accepted_jar.cob`: the accepted-jar accessor returns the one row of the generated table `content/copy/gen/acceptedjar.cpy` (size, SHA-256, versions, pack formats)
- [x] T0182 [US1-content] Implement the accepted-jar accessor program `CONTENT-ACCEPTED-JAR` in `content/src/accepted-jar.cob`
- [x] T0183 [US1-content] Write acceptance test `content/tests/acc_f2us1_packs_check.cob`: over `contract/fixtures/content/` a valid tree gives `ok`, a missing directory `absent`, a missing sentinel `damaged`, a tampered manifest `stale`, a manifest listing missing parts `incomplete` (22 §8.2); the check reads no jar and hashes nothing [FR-001, FR-002; SC-012]
- [x] T0184 [US1-content] Write edge-case test `content/tests/test_packs_partial.cob` (spec edge case "the jar changes between runs"): a leftover `<generated>.partial` alone gives `absent`; a valid tree beside a stale `.partial` gives `ok` and the check never reads the `.partial`, so loaders cannot read half-written output (22 §7.5)
- [x] T0185 [US1-content] Implement `CONTENT-PACKS-CHECK` (status word and reason text) in `content/src/packs-check.cob`
- [x] T0186 [US1-content] Write consumer test `content/tests/contract_formats_consumer.cob` calling `JSON-STRICT`, `ZIP-*` and `FILE-*` the way `content` does
- [x] T0187 [US1-content] Write implementation tests `content/tests/test_packs_check_paths.cob` for the check's remaining branches (unreadable manifest, short manifest line)
- [x] T0188 [US1-content] Gate: run `make gate-content` and record the command and real output
