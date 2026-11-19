*> Natural spawning of bats (docs/protocol/21 section 8.10, 18 section 6.1; lane p49o, T36050): the spawn attempt of the ambient category (3) of a chunk whose only air is a dark pocket under a stone roof, over a stone floor
*> (the tag bats_spawnable_on), makes a bat in the pocket (checkBatSpawnRules: below the surface height of the column, nextBoolean false, brightness not above nextInt(4), stone below); the same pocket under open
*> sky (no roof) never makes one. The documents give no Halloween test for the bat (21 section 8.10: "The method has no further tests"), so none is made.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-10C.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-CASE                PIC X(140).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STONE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-ROOF                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 16.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-CAT                 BINARY-LONG VALUE 3.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TREG                PIC X(48) VALUE "block".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:base_stone_overworld".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-BAT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ROW                 BINARY-LONG.
 01 WS-BATS                BINARY-LONG.
 01 WS-BAT-Y               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ID TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TREG WS-TTAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "minecraft:bat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BAT-TYPE WS-ENTITY-ROW WS-STATUS
*>   A chunk next to the player: a stone floor with three layers of air and, in the first part, a stone roof over the whole chunk.
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16) + 1
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     COMPUTE WS-X0 = WS-CX * 16
     COMPUTE WS-Z0 = WS-CZ * 16
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-ROOF = WS-FY + 4
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
*>   Open sky: 4000 attempts never make a bat.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         CALL "MS6-SPAWN-CHUNK" USING WS-STATE WS-DIM WS-CAT WS-CX WS-CZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-FOUND
     END-PERFORM
     PERFORM COUNT-BATS
     MOVE "acceptance US15 21§8.10 under open sky the ambient attempt never makes a bat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BATS TO WS-O
     PERFORM CHECK-N
*>   The roof.
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X >= WS-X0 + WS-SIZE
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z >= WS-Z0 + WS-SIZE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-ROOF WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000 OR WS-FOUND > 0
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         CALL "MS6-SPAWN-CHUNK" USING WS-STATE WS-DIM WS-CAT WS-CX WS-CZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-FOUND
     END-PERFORM
     PERFORM COUNT-BATS
     MOVE "acceptance US15 21§8.10 under a stone roof over stone the ambient attempt makes a bat" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-BATS > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.10 the bat is in the pocket between floor and roof" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-BATS > 0
         IF WS-BAT-Y >= WS-FY + 1 AND WS-BAT-Y < WS-ROOF
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     STOP RUN.

*> WS-BATS: the bats in the world, WS-BAT-Y the y of the last.
 COUNT-BATS.
     MOVE 0 TO WS-BATS
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-BAT-TYPE
             ADD 1 TO WS-BATS
             MOVE EN-Y(WS-ROW) TO WS-BAT-Y
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-E WS-O.
 END PROGRAM TEST-MOB-21-8-10C.
 COPY CORETEST.
 COPY CMDTEST.
 COPY MOBSPTEST.
