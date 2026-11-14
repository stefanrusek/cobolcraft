*> Acceptance test (US1-extract; FR-001, FR-002; SC-012; 22 §5.2, §6.1, §12 T5): the operator's real jar
*> tmp/minecraft-26.3-client.jar (git-ignored; the test FAILS loudly when it is absent).
*> US1-1 Given the jar, When the tool runs, Then the vanilla resource pack and data pack exist in the layout of
*>   22 §5.2 with the counts of T5 (11,605 resource files, 9,779 data files, 106 feature files, 209, 539 and 22
*>   directories) and the packs check says ok.
*> US1-2 Given the packs exist, When the tool runs again, Then it does nothing (CCX-100, exit 0).
*> US1-3 Given an unrecognised jar (another id, one flipped byte, a truncated file), When the tool runs, Then it is
*>   rejected (CCX-030 or CCX-031, or CCX-020 for a file that is no archive) and nothing is written.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-REAL-JAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY CONTENT.
 COPY FORMATS.
 01 WS-NAME                PIC X(64).
 01 WS-GEN                 PIC X(1100).
 01 WS-ROOT                PIC X(1100).
 01 WS-JAR                 PIC X(1100).
 01 WS-EXIT                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-LINE                PIC X(4000).
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-FILES.
    05 FILLER              PIC X(90) VALUE ".cobolcraft-generated".
    05 FILLER              PIC X(90) VALUE "manifest.txt".
    05 FILLER              PIC X(90) VALUE "index.txt".
    05 FILLER              PIC X(90) VALUE "vanilla-resources/pack.mcmeta".
    05 FILLER              PIC X(90) VALUE "vanilla-resources/pack.png".
    05 FILLER              PIC X(90) VALUE "vanilla-resources/assets/minecraft/lang/en_us.json".
    05 FILLER              PIC X(90) VALUE "vanilla-resources/assets/minecraft/atlases/blocks.json".
    05 FILLER              PIC X(90) VALUE "vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png".
    05 FILLER              PIC X(90) VALUE "vanilla-data/pack.mcmeta".
    05 FILLER              PIC X(90) VALUE "vanilla-data/pack.png".
    05 FILLER              PIC X(90) VALUE "vanilla-data/data/minecraft/worldgen/biome/plains.json".
    05 FILLER              PIC X(90) VALUE "vanilla-data/data/minecraft/dimension_type/overworld.json".
    05 FILLER              PIC X(90) VALUE "vanilla-data/data/minecraft/damage_type/generic.json".
    05 FILLER              PIC X(90) VALUE "vanilla-data/data/minecraft/recipe/stick.json".
    05 FILLER              PIC X(90) VALUE "featurepacks/minecart_improvements/pack.mcmeta".
    05 FILLER              PIC X(90) VALUE "featurepacks/redstone_experiments/pack.mcmeta".
    05 FILLER              PIC X(90) VALUE "featurepacks/trade_rebalance/pack.mcmeta".
    05 FILLER              PIC X(90) VALUE "featurepacks/trade_rebalance/data/minecraft/loot_table/chests/ancient_city.json".
 01 WS-FILE-TABLE REDEFINES WS-FILES.
    05 WS-FILE             PIC X(90) OCCURS 18 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-FILE-STATUS         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "real-jar" TO WS-NAME
     CALL "EXT-OUTPUT" USING WS-NAME WS-GEN WS-EXIT
     MOVE "acceptance US1-1 Given the real jar, When the tool runs, Then it exits 0 (input present)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     IF WS-EXIT NOT = 0
         MOVE "minecraft-26.3-client.jar" TO WS-NAME
         CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-JAR)
         STOP RUN
     END-IF

*>   US1-1: the layout of 22 §5.2.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(WS-GEN) "/" FUNCTION TRIM(WS-FILE(WS-I)) DELIMITED BY SIZE INTO WS-PATH
         CALL "FILE-EXISTS" USING WS-PATH WS-FILE-STATUS
         MOVE SPACES TO TL-CASE
         STRING "acceptance US1-1 the pack has " FUNCTION TRIM(WS-FILE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-FILE-STATUS TO TL-OBSERVED-N
         PERFORM ASSERT-NUMBER
     END-PERFORM
     MOVE "acceptance US1-1 11,605 resource files (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/vanilla-resources -type f | wc -l | tr -d ' '" DELIMITED BY SIZE
         INTO WS-COMMAND
     PERFORM EXPECT-COUNT-11605
     MOVE "acceptance US1-1 9,779 data files (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/vanilla-data -type f | wc -l | tr -d ' '" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 9779 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US1-1 106 feature files (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/featurepacks -type f | wc -l | tr -d ' '" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 106 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US1-1 209 resource directories below the pack root (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/vanilla-resources -mindepth 1 -type d | wc -l | tr -d ' '"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 209 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US1-1 539 data directories below the pack root (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/vanilla-data -mindepth 1 -type d | wc -l | tr -d ' '"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 539 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US1-1 22 feature directories below the three pack roots (T5)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "find " FUNCTION TRIM(WS-GEN) "/featurepacks -mindepth 2 -type d | wc -l | tr -d ' '"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 22 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "CONTENT-PACKS-CHECK" USING WS-GEN WS-STATUS WS-REASON
     MOVE "acceptance US1-1 the packs check says ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   US1-2: a second run does nothing.
     MOVE SPACES TO WS-COMMAND
     STRING "touch " FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "real-jar" TO WS-NAME
     CALL "EXT-OUTPUT" USING WS-NAME WS-GEN WS-EXIT
     MOVE "acceptance US1-2 Given the packs, When the tool runs again, Then exit 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US1-2 it says up to date (CCX-100)" TO TL-CASE
     MOVE "CCX-100" TO TL-EXPECTED
     MOVE EXR-LINE(1:7) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-2 it rebuilt nothing (the planted file is still there)" TO TL-CASE
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-FILE-STATUS
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-FILE-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL

*>   US1-3: an unrecognised jar is rejected and nothing is written.
     MOVE "real-jar-reject" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) " && cp " FUNCTION TRIM(WS-JAR)
         " " FUNCTION TRIM(WS-ROOT) "/flipped.jar && printf 'x' | dd of=" FUNCTION TRIM(WS-ROOT)
         "/flipped.jar bs=1 seek=1000000 conv=notrunc 2>/dev/null && head -c 1000000 " FUNCTION TRIM(WS-JAR) " > "
         FUNCTION TRIM(WS-ROOT) "/truncated.jar" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/generated" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-ROOT) "/flipped.jar|--generated-dir|" FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE
         INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "acceptance US1-3 Given the jar with one byte changed, When run, Then CCX-031 (exit 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-3 the message is CCX-031" TO TL-CASE
     MOVE "CCX-031" TO TL-EXPECTED
     MOVE EXR-LINE(1:7) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-ROOT) "/truncated.jar|--generated-dir|" FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE
         INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "acceptance US1-3 Given a truncated jar, When run, Then CCX-020 (exit 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-3 the message is CCX-020" TO TL-CASE
     MOVE "CCX-020" TO TL-EXPECTED
     MOVE EXR-LINE(1:7) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-LINE
     STRING "--jar|contract/fixtures/extract/c-wrong-id.zip|--generated-dir|" FUNCTION TRIM(WS-GEN)
         DELIMITED BY SIZE INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "acceptance US1-3 Given a jar of another id, When run, Then CCX-030 (exit 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-3 the message is CCX-030" TO TL-CASE
     MOVE "CCX-030" TO TL-EXPECTED
     MOVE EXR-LINE(1:7) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-3 nothing was written by the three rejected runs" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test ! -e " FUNCTION TRIM(WS-GEN) " && test ! -e " FUNCTION TRIM(WS-GEN) ".partial"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 EXPECT-COUNT-11605.
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 11605 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US1-REAL-JAR.

 COPY EXTEST.
