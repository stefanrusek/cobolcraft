*> Acceptance test of the noise spawn finder run against a standard world's real data (docs/protocol/36-structures-1 section 4.9, 33 sections 6.2 and 6.3; the generated
*> vanilla data pack of CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it): the fitness of a probe from the density functions equals the fitness from
*> the multi-noise climate sampler's quantised values (an independent path to the same five numbers), the search result is the lowest fitness of the 928 probes of the two passes in
*> probe order (enumerated here with the ring programs), the origin chunk is the chunk of that position, and the initial world spawn of the new world is found in the 11 x 11 chunk
*> square around the origin chunk, not around chunk (0, 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPAWN-ORIGIN-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CTWORLDGEN.
 COPY GENQUEUE.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld".
 01 WS-ROOT                BINARY-LONG.
 01 WS-BOXES               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG VALUE 0.
 01 WS-FIT                 BINARY-DOUBLE.
 01 WS-FIT2                BINARY-DOUBLE.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-VALUES.
    05 WS-V                BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-PASS                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-PROBES              BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-SCX                 BINARY-LONG.
 01 WS-SCZ                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance spawn origin standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Origin" TO CS-NEW-WORLD-NAME
     MOVE 2 TO GQ-SP-PIN
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
     MOVE 0 TO WS-BOXES
     IF WS-ROOT > 0
         MOVE WGN-CHILD(WS-ROOT, 16) TO WS-BOXES
     END-IF
     MOVE "acceptance spawn origin standard: the opened world holds the overworld noise settings with their spawn target boxes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BOXES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-BOXES = 0
         STOP RUN
     END-IF
     MOVE "T" TO TL-MODE

*>   The fitness from the density functions equals the fitness from the climate sampler at the aligned quart cell.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         COMPUTE WS-X = (WS-K * 397) - 2000
         COMPUTE WS-Z = 1500 - (WS-K * 211)
         CALL "SPAWN-FITNESS-AT" USING WS-BOXES WS-X WS-Z WS-FIT
         PERFORM CLIMATE-FITNESS
         IF WS-FIT NOT = WS-FIT2
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance spawn origin standard: the fitness at 12 probes equals the one from the climate sampler's quantised values" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The search: enumerate the two passes (928 positions with the initial probe) and keep the strictly lower fitness.
     MOVE 0 TO WS-X WS-Z WS-PROBES
     PERFORM CLIMATE-FITNESS
     MOVE WS-FIT2 TO WS-BEST
     MOVE 0 TO WS-BX WS-BZ
     ADD 1 TO WS-PROBES
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         MOVE WS-BX TO WS-CX
         MOVE WS-BZ TO WS-CZ
         IF WS-PASS = 1
             MOVE 2048 TO WS-MAX
             MOVE 512 TO WS-STEP
         ELSE
             MOVE 512 TO WS-MAX
             MOVE 32 TO WS-STEP
         END-IF
         MOVE 0 TO WS-ANGLE
         MOVE WS-STEP TO WS-RADIUS
         PERFORM UNTIL WS-RADIUS > WS-MAX
             CALL "SPAWN-RING-POINT" USING WS-CX WS-CZ WS-ANGLE WS-RADIUS WS-X WS-Z
             PERFORM CLIMATE-FITNESS
             ADD 1 TO WS-PROBES
             IF WS-FIT2 < WS-BEST
                 MOVE WS-FIT2 TO WS-BEST
                 MOVE WS-X TO WS-BX
                 MOVE WS-Z TO WS-BZ
             END-IF
             CALL "SPAWN-RING-NEXT" USING WS-ANGLE WS-RADIUS WS-STEP
         END-PERFORM
     END-PERFORM
     MOVE "acceptance spawn origin standard: the two passes probe 928 positions" TO TL-CASE
     MOVE 928 TO TL-EXPECTED-N
     MOVE WS-PROBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SPAWN-SEARCH" USING WS-BOXES WS-X WS-Z
     MOVE "T" TO TL-MODE
     MOVE "acceptance spawn origin standard: SPAWN-SEARCH returns the lowest fitness of the probes in probe order" TO TL-CASE
     MOVE WS-X TO WS-E1
     MOVE WS-Z TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-BX TO WS-E1
     MOVE WS-BZ TO WS-E2
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "# spawn finder result of seed 12345: " FUNCTION TRIM(TL-OBSERVED) " fitness " WS-BEST

*>   The origin chunk is the chunk of that position.
     CALL "SPAWN-ORIGIN" USING WS-OX WS-OZ
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
     MOVE "acceptance spawn origin standard: the origin chunk is the chunk of the result" TO TL-CASE
     MOVE WS-OX TO WS-E1
     MOVE WS-OZ TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-CX TO WS-E1
     MOVE WS-CZ TO WS-E2
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The new world's spawn lies in the 11 x 11 chunk square around the origin chunk (the world opened above searched it).
     COMPUTE WS-SCX = FUNCTION INTEGER(CW-SPAWN-X / 16)
     COMPUTE WS-SCZ = FUNCTION INTEGER(CW-SPAWN-Z / 16)
     COMPUTE WS-DX = WS-SCX - WS-OX
     COMPUTE WS-DZ = WS-SCZ - WS-OZ
     MOVE 0 TO WS-BAD
     IF WS-DX < -5 OR WS-DX > 5 OR WS-DZ < -5 OR WS-DZ > 5
         MOVE 1 TO WS-BAD
     END-IF
     MOVE "acceptance spawn origin standard: the world spawn is within 5 chunks of the origin chunk" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "# origin chunk " WS-OX " " WS-OZ " spawn " CW-SPAWN-X " " CW-SPAWN-Y " " CW-SPAWN-Z
     STOP RUN.

*> WS-FIT2: the fitness of the probe (WS-X, WS-Z) from the climate sampler: the five quantised values of the quart cell at the aligned column.
 CLIMATE-FITNESS.
     CALL "SPAWN-ALIGN" USING WS-X WS-QX
     CALL "SPAWN-ALIGN" USING WS-Z WS-QZ
     COMPUTE WS-QX = WS-QX / 4
     COMPUTE WS-QZ = WS-QZ / 4
     CALL "CLIMATE-SAMPLE" USING WS-QX WS-QY WS-QZ WS-TARGET
     MOVE WS-T(3) TO WS-V(1)
     MOVE WS-T(4) TO WS-V(2)
     MOVE WS-T(1) TO WS-V(3)
     MOVE WS-T(2) TO WS-V(4)
     MOVE WS-T(6) TO WS-V(5)
     CALL "SPAWN-FITNESS-OF" USING WS-BOXES WS-X WS-Z WS-VALUES WS-FIT2.

 END PROGRAM ACC-SPAWN-ORIGIN-STANDARD.

 COPY CORETEST.
