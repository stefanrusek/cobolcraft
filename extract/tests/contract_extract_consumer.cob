*> Consumer-side contract test (T0313; named contract_extract_consumer because cobc refuses a source base name over 31 bytes; the contract names it contract_content_consumer_extract in the content package, it
*> lives in this lane so lanes stay disjoint): what `content` reads of the tool's real output. The output of the
*> operator's real jar (tmp/minecraft-26.3-client.jar, git-ignored; the test FAILS when it is absent) passes
*> CONTENT-PACKS-CHECK (ok); a tampered manifest gives stale, a removed sentinel damaged, a removed manifest with the marker
*> incomplete, a removed directory absent. Each damage is made in a copy of the manifest and sentinel files only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-EXTRACT-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY CONTENT.
 COPY FORMATS.
 01 WS-NAME                PIC X(64).
 01 WS-GEN                 PIC X(1100).
 01 WS-JAR                 PIC X(1100).
 01 WS-ROOT                PIC X(1100).
 01 WS-COPY                PIC X(1100).
 01 WS-EXIT                BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     MOVE "consumer" TO WS-NAME
     CALL "EXT-OUTPUT" USING WS-NAME WS-GEN WS-EXIT
     MOVE "contract content consumer: the tool runs on the real jar and exits 0 (input present)" TO TL-CASE
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
     CALL "CONTENT-PACKS-CHECK" USING WS-GEN WS-STATUS WS-REASON
     MOVE "contract content consumer: the tool's real output passes CONTENT-PACKS-CHECK" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract content consumer: its reason text is empty for ok" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-REASON TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A copy of the files the check reads (manifest, marker, the sentinels); the damage is made in the copy.
     MOVE "consumer-copy" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COPY
     STRING FUNCTION TRIM(WS-ROOT) "/generated" DELIMITED BY SIZE INTO WS-COPY
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-COPY) " && (cd " FUNCTION TRIM(WS-GEN)
         " && tar cf - .cobolcraft-generated manifest.txt vanilla-resources vanilla-data) | (cd "
         FUNCTION TRIM(WS-COPY) " && tar xf -)" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: the copy is ok too" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A removed sentinel: damaged.
     MOVE SPACES TO WS-COMMAND
     STRING "mv " FUNCTION TRIM(WS-COPY) "/vanilla-data/data/minecraft/recipe/stick.json " FUNCTION TRIM(WS-ROOT)
         "/stick.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: a removed sentinel gives damaged" TO TL-CASE
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-COMMAND
     STRING "mv " FUNCTION TRIM(WS-ROOT) "/stick.json " FUNCTION TRIM(WS-COPY)
         "/vanilla-data/data/minecraft/recipe/stick.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL

*>   A tampered manifest: stale (the digest, then the resource format).
     MOVE SPACES TO WS-COMMAND
     STRING "sed 's/^jar-sha256=4/jar-sha256=5/' " FUNCTION TRIM(WS-GEN) "/manifest.txt > " FUNCTION TRIM(WS-COPY)
         "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: a tampered digest gives stale" TO TL-CASE
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-COMMAND
     STRING "sed 's/^resource-format=97.1$/resource-format=96.0/' " FUNCTION TRIM(WS-GEN) "/manifest.txt > "
         FUNCTION TRIM(WS-COPY) "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: a tampered resource format gives stale" TO TL-CASE
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No manifest, the marker there: incomplete; nothing at all: absent.
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-COPY) "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: no manifest with the marker gives incomplete" TO TL-CASE
     MOVE CT-PACKS-INCOMPLETE TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-COPY) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "CONTENT-PACKS-CHECK" USING WS-COPY WS-STATUS WS-REASON
     MOVE "contract content consumer: no directory gives absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-EXTRACT-CONSUMER.

 COPY EXTEST.
