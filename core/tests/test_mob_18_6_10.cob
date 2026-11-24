*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.10, with doc 44 part 1 section 4): chunk-generation spawns.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER            BINARY-LONG.
 01 WS-DIM               BINARY-LONG.
 01 WS-CX                BINARY-LONG.
 01 WS-CZ                BINARY-LONG.
 01 WS-X0                BINARY-LONG.
 01 WS-Z0                BINARY-LONG.
 01 WS-FY                BINARY-LONG.
 01 WS-SIZE              BINARY-LONG VALUE 16.
 01 WS-KIND              BINARY-LONG VALUE 2.
 01 WS-I                 BINARY-LONG.
 01 WS-ROW               BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-TOTAL             BINARY-LONG.
 01 WS-BAD               BINARY-LONG.
 01 WS-HITS              BINARY-LONG.
 01 WS-ENABLED           BINARY-LONG.
 01 WS-BIOME             BINARY-LONG.
 01 WS-DEEP              BINARY-LONG.
 01 WS-KEY               PIC X(48).
 01 WS-D                 FLOAT-LONG.
 01 WS-L1                BINARY-DOUBLE UNSIGNED.
 01 WS-L2                BINARY-DOUBLE UNSIGNED.
 01 WS-MX                FLOAT-LONG.
 01 WS-MZ                FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:plains" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-BIOME
     MOVE "minecraft:deep_dark" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-DEEP
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16) + 1
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     COMPUTE WS-X0 = WS-CX * 16
     COMPUTE WS-Z0 = WS-CZ * 16
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE 1 TO WS-ENABLED
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-CHUNK-GEN-BIOME" USING XR-STATE WS-DIM WS-CX WS-CZ WS-BIOME WS-ENABLED WS-N
         ADD WS-N TO WS-TOTAL
     END-PERFORM
     MOVE "acceptance US15 18§6.10 Chunk-generation spawns: 300 chunk generations at probability 0.1 spawn some animals" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             COMPUTE WS-MX = EN-X(WS-ROW) - WS-X0
             COMPUTE WS-MZ = EN-Z(WS-ROW) - WS-Z0
             IF WS-MX < 0.3 OR WS-MX > 15.7 OR WS-MZ < 0.3 OR WS-MZ > 15.7 OR EN-Y(WS-ROW) NOT = WS-FY + 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.10 Chunk-generation spawns: every mob stands inside the chunk shrunk by its width, on top of the floor" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-BAD
     PERFORM CHECK-N
     MOVE 0 TO WS-HITS
     MOVE 0 TO WS-I
     PERFORM VARYING WS-SEED FROM 1000 BY 1 UNTIL WS-HITS >= 30
         CALL "XORO-SEED" USING WS-SEED WS-MIRROR
         CALL "XORO-NEXT-DOUBLE" USING WS-MIRROR WS-D
         IF WS-D >= 0.1
             CALL "XORO-SEED" USING WS-SEED XR-STATE
             CALL "MS6-CHUNK-GEN-BIOME" USING XR-STATE WS-DIM WS-CX WS-CZ WS-BIOME WS-ENABLED WS-N
             IF WS-N = 0 AND XR-LO = WS-M-LO AND XR-HI = WS-M-HI
                 ADD 1 TO WS-HITS
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.10 Chunk-generation spawns: when nextFloat is not below p nothing spawns and exactly one number was drawn" TO WS-CASE
     COMPUTE WS-E = 30
     COMPUTE WS-O = WS-HITS
     PERFORM CHECK-N
     MOVE 7 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "MS6-CHUNK-GEN-BIOME" USING XR-STATE WS-DIM WS-CX WS-CZ WS-DEEP WS-ENABLED WS-N
     MOVE 0 TO WS-O
     IF XR-LO = WS-M-LO AND XR-HI = WS-M-HI AND WS-N = 0
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 18§6.10 Chunk-generation spawns: a biome with an empty creature list draws nothing" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-ENABLED
     CALL "MS6-CHUNK-GEN-BIOME" USING XR-STATE WS-DIM WS-CX WS-CZ WS-BIOME WS-ENABLED WS-N
     MOVE 0 TO WS-O
     IF XR-LO = WS-M-LO AND XR-HI = WS-M-HI AND WS-N = 0
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 18§6.10 Chunk-generation spawns: with spawn_mobs false nothing spawns and nothing is drawn" TO WS-CASE
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-10.
 COPY CORETEST.
 COPY MOBSPTEST.
