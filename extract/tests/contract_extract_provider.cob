*> Contract test, provider side (specs/002-client-polish/contracts/extract-cli.md "Contract tests"; T0312): the tool's
*> output tree and manifest against 22 §5.2, §6.1, §6.2, §6.4 and §6.5 with the operator's real jar
*> (tmp/minecraft-26.3-client.jar, git-ignored; the test FAILS when it is absent). The tree is checked by an independent
*> reader (extract/tests/check_tree.py: Python zipfile, the mapping of 22 §6.1 written again): every payload file
*> equals the jar's bytes (T6), the counts (T5), index.txt (6.5), the two pack.mcmeta (6.2), the kinds (T7).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-EXTRACT-PROVIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-NAME                PIC X(64).
 01 WS-GEN                 PIC X(1100).
 01 WS-JAR                 PIC X(1100).
 01 WS-EXIT                BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-REPORT              PIC X(1100).
 01 WS-TEXT                PIC X(8192).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NEEDLE              PIC X(200).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-LF                  PIC X VALUE X"0A".
 01 WS-EXPECTED            PIC X(1024).
 01 WS-POINTER             BINARY-LONG.
 01 WS-CHECKS.
    05 FILLER              PIC X(60) VALUE "skipped 11391".
    05 FILLER              PIC X(60) VALUE "payload-files 21488".
    05 FILLER              PIC X(60) VALUE "payload-missing 0".
    05 FILLER              PIC X(60) VALUE "payload-different 0".
    05 FILLER              PIC X(60) VALUE "extra-files 0".
    05 FILLER              PIC X(60) VALUE "files-resource 11605".
    05 FILLER              PIC X(60) VALUE "files-data 9779".
    05 FILLER              PIC X(60) VALUE "files-feature 106".
    05 FILLER              PIC X(60) VALUE "dirs-resource 209".
    05 FILLER              PIC X(60) VALUE "dirs-data 539".
    05 FILLER              PIC X(60) VALUE "dirs-feature 22".
    05 FILLER              PIC X(60) VALUE "index-final-newline yes".
    05 FILLER              PIC X(60) VALUE "index-lines 21490".
    05 FILLER              PIC X(60) VALUE "index-bad-lines 0".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-resources ok".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-resources-crc c6f2b630".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-resources-size 129".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-data ok".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-data-crc 14f8038e".
    05 FILLER              PIC X(60) VALUE "mcmeta-vanilla-data-size 123".
    05 FILLER              PIC X(60) VALUE "json-files 15919".
    05 FILLER              PIC X(60) VALUE "json-unparsable 0".
    05 FILLER              PIC X(60) VALUE "nbt-files 1511".
    05 FILLER              PIC X(60) VALUE "nbt-without-gzip-magic 0".
    05 FILLER              PIC X(60) VALUE "png-files 3964".
    05 FILLER              PIC X(60) VALUE "png-without-signature 0".
    05 FILLER              PIC X(60) VALUE "texture-mcmeta-without-png 0".
 01 WS-CHECK-TABLE REDEFINES WS-CHECKS.
    05 WS-CHECK            PIC X(60) OCCURS 27 TIMES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "provider" TO WS-NAME
     CALL "EXT-OUTPUT" USING WS-NAME WS-GEN WS-EXIT
     MOVE "contract extract provider: the tool runs on the real jar and exits 0 (input present)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-EXIT NOT = 0
         MOVE "minecraft-26.3-client.jar" TO WS-NAME
         CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-JAR)
         STOP RUN
     END-IF

*>   The independent reader.
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
     MOVE "provider-report.txt" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-REPORT
     MOVE SPACES TO WS-COMMAND
     STRING "python3 -I extract/tests/check_tree.py " FUNCTION TRIM(WS-JAR) " " FUNCTION TRIM(WS-GEN) " > "
         FUNCTION TRIM(WS-REPORT) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "contract extract provider: the independent reader ran (status 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 8191 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-REPORT WS-OFFSET WS-TEXT WS-LENGTH WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE SPACES TO WS-NEEDLE
         STRING "CHECK " FUNCTION TRIM(WS-CHECK(WS-I)) WS-LF DELIMITED BY SIZE INTO WS-NEEDLE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NEEDLE TRAILING)) TO WS-NEEDLE-LENGTH
         MOVE 0 TO WS-FOUND
         INSPECT WS-TEXT TALLYING WS-FOUND FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH)
         MOVE SPACES TO TL-CASE
         STRING "contract extract provider: " FUNCTION TRIM(WS-CHECK(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   manifest.txt (6.4): the thirteen lines for the accepted jar.
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/manifest.txt" DELIMITED BY SIZE INTO WS-PATH
     MOVE SPACES TO WS-TEXT
     MOVE 4096 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-TEXT WS-LENGTH WS-STATUS
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POINTER
     STRING "format=1" WS-LF "tool=cobolcraft-extract 1" WS-LF "jar-version=26.3" WS-LF
         "jar-sha256=4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d" WS-LF
         "jar-size=41483720" WS-LF "world-version=5023" WS-LF "protocol-version=777" WS-LF
         "resource-format=97.1" WS-LF "data-format=121.0" WS-LF "files-resource=11605" WS-LF
         "files-data=9779" WS-LF "files-feature=106" WS-LF "files-total=21490" WS-LF
         DELIMITED BY SIZE INTO WS-EXPECTED POINTER WS-POINTER
     MOVE "contract extract provider: manifest.txt is the text of 22 §6.4" TO TL-CASE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT(1:1024) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract extract provider: manifest.txt is 298 bytes" TO TL-CASE
     MOVE 298 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The marker is empty; the tool's own --verify passes too.
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/.cobolcraft-generated" DELIMITED BY SIZE INTO WS-PATH
     MOVE 8 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-TEXT WS-LENGTH WS-STATUS
     MOVE "contract extract provider: the marker is an empty file" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-EXTRACT-PROVIDER.

 COPY EXTEST.
