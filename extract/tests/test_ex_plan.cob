*> Implementation test for EX-PLAN, EX-DEST, EX-ACTION and EX-TARGET-CHECK (22 §6.1, §6.3, §7.3 steps 5 and 7, §7.5; T0299):
*> the payload entry list, the counts and the destination paths over a small archive (tests/fixtures/mini.zip, made
*> by tools/make_extract_fixtures.py), the entry names that cannot become a pack path (CCX-043) or collide (CCX-044),
*> the regeneration decision over the content fixtures and the target check (CCX-051).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-PLAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE                PIC X(1024).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-ZIP-STATUS          BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-DEST                PIC X(1100).
 01 WS-ENTRY               BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-SCRATCH             PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-EXPECT-TEXT         PIC 999.
 01 WS-I                   BINARY-LONG.
 01 WS-LISTED              PIC X(300).
 PROCEDURE DIVISION.
*>   The small archive: 16 entries, 8 of them payload.
     MOVE "extract/tests/fixtures/mini.zip" TO WS-FILE
     PERFORM OPEN-ZIP
     MOVE -1 TO WS-STATUS
     CALL "EX-PLAN" USING WS-ZIP WS-STATUS
     MOVE "plan: mini archive gives status 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: 8 payload entries" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EXP-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: resource files 4 (2 assets, pack.png, pack.mcmeta)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EXR-RESOURCE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: data files 4 (2 data, pack.png, pack.mcmeta)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EXR-DATA TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: feature files 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EXR-FEATURE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: payload total 11" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EXR-TOTAL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "plan: skipped file entries 5 (markers, version.json, class, manifest)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EXR-SKIPPED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   The kinds in central directory order: pack.png (4), assets 1 1, data 2 2, feature 3 3 3.
     MOVE "plan: kinds in central directory order" TO TL-CASE
     PERFORM KINDS-TEXT
     MOVE "4 1 1 2 2 3 3 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-LISTED) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "plan: the first payload entry is pack.png, entry number 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EXP-INDEX(1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   Destinations (22 §6.1).
     MOVE "assets/minecraft/lang/en_us.json" TO WS-NAME
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-WHICH
     PERFORM DEST-OF
     MOVE "dest: assets go to vanilla-resources verbatim" TO TL-CASE
     MOVE "vanilla-resources/assets/minecraft/lang/en_us.json" TO TL-EXPECTED
     MOVE WS-DEST TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "data/minecraft/recipe/stick.json" TO WS-NAME
     MOVE 2 TO WS-KIND
     PERFORM DEST-OF
     MOVE "dest: data goes to vanilla-data verbatim" TO TL-CASE
     MOVE "vanilla-data/data/minecraft/recipe/stick.json" TO TL-EXPECTED
     MOVE WS-DEST TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "data/minecraft/datapacks/trade_rebalance/data/minecraft/loot_table/a.json" TO WS-NAME
     MOVE 3 TO WS-KIND
     PERFORM DEST-OF
     MOVE "dest: a feature pack file goes under featurepacks" TO TL-CASE
     MOVE "featurepacks/trade_rebalance/data/minecraft/loot_table/a.json" TO TL-EXPECTED
     MOVE WS-DEST TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "pack.png" TO WS-NAME
     MOVE 4 TO WS-KIND
     PERFORM DEST-OF
     MOVE "dest: pack.png first goes to the resource pack" TO TL-CASE
     MOVE "vanilla-resources/pack.png" TO TL-EXPECTED
     MOVE WS-DEST TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-WHICH
     PERFORM DEST-OF
     MOVE "dest: pack.png second goes to the data pack" TO TL-CASE
     MOVE "vanilla-data/pack.png" TO TL-EXPECTED
     MOVE WS-DEST TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   Names that cannot become a pack path, and the collision.
     MOVE "extract/tests/fixtures/plan-upper.zip" TO WS-FILE
     MOVE 43 TO WS-EXPECT
     PERFORM PLAN-ONE
     MOVE "plan: CCX-043 text for an upper-case segment, exit 4" TO TL-CASE
     MOVE "CCX-043 Entry name assets/minecraft/Foo.txt cannot become a pack path." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 4 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "extract/tests/fixtures/plan-dot-segment.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "extract/tests/fixtures/plan-empty-segment.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "extract/tests/fixtures/plan-high-byte.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "extract/tests/fixtures/plan-datapack-stray.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "extract/tests/fixtures/plan-datapack-bare.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "contract/fixtures/extract/t-bad-path.zip" TO WS-FILE
     PERFORM PLAN-ONE
     MOVE "contract/fixtures/extract/t-duplicate-path.zip" TO WS-FILE
     MOVE 44 TO WS-EXPECT
     PERFORM PLAN-ONE
     MOVE "plan: CCX-044 text names the output path" TO TL-CASE
     MOVE "CCX-044 Two entries map to vanilla-resources/assets/minecraft/a.txt." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   An archive with nothing to extract plans nothing.
     MOVE "contract/fixtures/extract/ok-small.zip" TO WS-FILE
     MOVE 0 TO WS-EXPECT
     PERFORM PLAN-ONE
     MOVE "plan: no payload entry gives an empty plan" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EXP-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   Regeneration (22 §6.3): do nothing only for a valid tree without --force.
     MOVE 0 TO EXO-FORCE
     MOVE "contract/fixtures/content/valid" TO EXO-GEN
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: a valid tree without --force is up to date (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ACTION TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO EXO-FORCE
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: --force rebuilds (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ACTION TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO EXO-FORCE
     MOVE "contract/fixtures/content/stale" TO EXO-GEN
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: another jar digest rebuilds (0)" TO TL-CASE
     PERFORM ASSERT-NUMBER
     MOVE "contract/fixtures/content/incomplete" TO EXO-GEN
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: no manifest rebuilds (0)" TO TL-CASE
     PERFORM ASSERT-NUMBER
     MOVE "contract/fixtures/content/damaged" TO EXO-GEN
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: a missing sentinel rebuilds (0)" TO TL-CASE
     PERFORM ASSERT-NUMBER
     MOVE "contract/fixtures/content/nothing-here" TO EXO-GEN
     CALL "EX-ACTION" USING WS-ACTION
     MOVE "action: no directory builds (0)" TO TL-CASE
     PERFORM ASSERT-NUMBER

*>   The target check (22 §7.5 step 0).
     MOVE "target" TO WS-SCRATCH
     CALL "EXT-SCRATCH" USING WS-SCRATCH WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) "/empty " FUNCTION TRIM(WS-ROOT)
         "/marked " FUNCTION TRIM(WS-ROOT) "/foreign && touch " FUNCTION TRIM(WS-ROOT) "/marked/.cobolcraft-generated "
         FUNCTION TRIM(WS-ROOT) "/marked/x " FUNCTION TRIM(WS-ROOT) "/foreign/x " FUNCTION TRIM(WS-ROOT) "/a-file"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ROOT) "/absent" DELIMITED BY SIZE INTO WS-DIR
     MOVE 0 TO WS-EXPECT
     PERFORM TARGET-ONE
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ROOT) "/empty" DELIMITED BY SIZE INTO WS-DIR
     PERFORM TARGET-ONE
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ROOT) "/marked" DELIMITED BY SIZE INTO WS-DIR
     PERFORM TARGET-ONE
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ROOT) "/foreign" DELIMITED BY SIZE INTO WS-DIR
     MOVE 51 TO WS-EXPECT
     PERFORM TARGET-ONE
     MOVE "target: CCX-051 text and exit 5" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-051 Refusing to replace " FUNCTION TRIM(WS-DIR)
         ": it was not made by this tool (no .cobolcraft-generated marker)." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 5 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ROOT) "/a-file" DELIMITED BY SIZE INTO WS-DIR
     PERFORM TARGET-ONE
     STOP RUN.

 OPEN-ZIP.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FILE)) TO WS-FILE-LENGTH
     CALL "ZIP-OPEN" USING WS-FILE WS-FILE-LENGTH WS-ZIP WS-ZIP-STATUS
     MOVE SPACES TO TL-CASE
     STRING "plan: " FUNCTION TRIM(WS-FILE) " opens" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ZIP-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 PLAN-ONE.
     PERFORM OPEN-ZIP
     MOVE -1 TO WS-STATUS
     CALL "EX-PLAN" USING WS-ZIP WS-STATUS
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE WS-EXPECT TO WS-EXPECT-TEXT
     MOVE SPACES TO TL-CASE
     STRING "plan: " FUNCTION TRIM(WS-FILE) " gives CCX code " WS-EXPECT-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 TARGET-ONE.
     MOVE -1 TO WS-STATUS
     CALL "EX-TARGET-CHECK" USING WS-DIR WS-STATUS
     MOVE WS-EXPECT TO WS-EXPECT-TEXT
     MOVE SPACES TO TL-CASE
     STRING "target: " FUNCTION TRIM(WS-DIR) " gives " WS-EXPECT-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 DEST-OF.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     MOVE SPACES TO WS-DEST
     CALL "EX-DEST" USING WS-NAME WS-NAME-LENGTH WS-KIND WS-WHICH WS-DEST.

 KINDS-TEXT.
     MOVE SPACES TO WS-LISTED
     MOVE 1 TO WS-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EXP-COUNT
         MOVE EXP-KIND(WS-I) TO WS-KIND
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO WS-LISTED POINTER WS-ENTRY
         END-IF
         MOVE FUNCTION CHAR(WS-KIND + 49) TO WS-LISTED(WS-ENTRY:1)
         ADD 1 TO WS-ENTRY
     END-PERFORM.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-PLAN.

 COPY EXTEST.
