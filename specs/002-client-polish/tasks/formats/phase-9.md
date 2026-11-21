#### Phase 9: US3-formats — user pack archives

**Goal**: user resource packs (zip methods 0 and 8, thousands of entries) read correctly (FR-007). **Independent Test**: `acc_f2us3_user_zip` against the real Faithful zip.

- [x] T0134 [US3-formats] Write acceptance test `formats/tests/acc_f2us3_user_zip.cob`: given `tmp/Faithful 32x - 26.3.zip` (real input, fails loudly when absent) and the stored and deflated fixtures, every entry lists, resolves by name and reads with a matching CRC, and a name lookup does not scan [FR-007, FR-008, FR-009, FR-010; SC-001]
- [x] T0135 [US3-formats] Make `acc_f2us3_user_zip` pass in `formats/src/zip.cob`; if the test already passes when written, record that evidence and mark this task done
- [x] T0136 [US3-formats] Gate: run `make gate-formats` and record the command and real output
