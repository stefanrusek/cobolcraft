*> Implementation test (002-lane-mobs3, T4201): a folder pack whose directory holds more than 64 sub-directories lists every
*> file below it. The vanilla pack's textures/entity directory has 79 sub-directories; PACK-FOLDER-SCAN's pending-directory
*> stack held 64, so the pig, sheep, spider, zombie and skeleton folders were never listed and their textures were the
*> missing-texture stripes. The test builds a pack with 120 sub-directories, each with one file, and finds the first, the
*> 64th, the 65th and the last file.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-WIDE-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-CMD                 PIC X(400) VALUE
    "rm -rf build/client-test-widedir; mkdir -p build/client-test-widedir; cp client/tests/fixtures/mini-vanilla/pack.mcmeta build/client-test-widedir/; for i in $(seq -w 1 120); do mkdir -p build/client-test-widedir/assets/minecraft/textures/entity/d$i; echo x > build/client-test-widedir/assets/minecraft/textures/entity/d$i/t.png; done".
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   PIC 999.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING WS-CMD
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/wide" TO PK-ID(PK-COUNT)
     MOVE 14 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "build/client-test-widedir" TO PK-ROOT(PK-COUNT)
     MOVE 25 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     MOVE "N" TO TL-MODE
     MOVE "pack wide dir the table holds one file per directory" TO TL-CASE
     MOVE 120 TO TL-EXPECTED-N
     MOVE PK-FILE-COUNT(PK-COUNT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE 1 TO WS-N
             WHEN 2 MOVE 64 TO WS-N
             WHEN 3 MOVE 65 TO WS-N
             WHEN OTHER MOVE 120 TO WS-N
         END-EVALUATE
         MOVE SPACES TO WS-PATH
         STRING "assets/minecraft/textures/entity/d" WS-N "/t.png" DELIMITED BY SIZE INTO WS-PATH
         MOVE 43 TO WS-LENGTH
         CALL "PACK-FILE-FIND" USING CLIENT-STATE PK-COUNT WS-PATH WS-LENGTH WS-INDEX
         MOVE "pack wide dir the file of a directory (1, 64, 65, 120) is found" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-INDEX > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-PACK-WIDE-DIR.
 COPY CLTEST.
