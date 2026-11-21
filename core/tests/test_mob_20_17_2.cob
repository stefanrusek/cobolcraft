*> Acceptance test (lane p49r; docs/protocol/20 section 17.1.1 and 17.1.2): isLookingAtMe and the block ray Level.clip. The numbers are the document's worked cases: a viewer whose eyes are at
*> (0.5, 65.62, 0.5) (feet at y 64) and a creaking at (10.5, 64, 0.5): looking along +x it is seen, along +z it is not, 59 degrees away it is still seen and 61 degrees away it is not (a cone of 60
*> degrees at every distance), a stone block at cell (5, 65, 0) hides all three samples, one at (5, 64, 0) hides none (the sample heights 66.3, 64.5 and 65.15 differ), glass does not block the
*> ray (empty visual shape). Level.clip: the segment (0.5, 65.62, 0.5) to (10.5, 66.3, 0.5) hits the stone at cell (5, 65, 0); a segment along the top face y = 65 exactly runs in the cells above and
*> misses, one at 64.9 hits.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 30.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LOOK                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-FX2                 FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ2                 FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:glass" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GLASS
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 6
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 15
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
*>   The viewer stands at the middle of its block (x.5, feet y, z.5); the creaking 10 blocks east of it.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 0.5
     MOVE WS-BY TO PL-Y(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 0.5
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     COMPUTE WS-X0 = WS-BX + 10.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE WS-X0 TO EN-X(WS-MOB)
     MOVE WS-Y TO EN-Y(WS-MOB)
     MOVE WS-Z TO EN-Z(WS-MOB)
     MOVE -90 TO PL-YAW(WS-PLAYER)
     PERFORM LOOK
     MOVE "looking along +x the creaking 10 blocks away is seen" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-YAW(WS-PLAYER)
     PERFORM LOOK
     MOVE "looking along +z it is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE -31 TO PL-YAW(WS-PLAYER)
     PERFORM LOOK
     MOVE "59 degrees away it is still seen (cos 59 = 0.515 above 0.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE -29 TO PL-YAW(WS-PLAYER)
     PERFORM LOOK
     MOVE "61 degrees away it is not (0.485)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE -90 TO PL-YAW(WS-PLAYER)
*>   Pitch: looking 45 degrees up from the same yaw the creaking (about 3 degrees above the horizon) is 42 degrees off: still seen; 80 degrees up it is not.
     MOVE -45 TO PL-PITCH(WS-PLAYER)
     PERFORM LOOK
     MOVE "looking 45 degrees up it is 42 degrees off the view: seen" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE -80 TO PL-PITCH(WS-PLAYER)
     PERFORM LOOK
     MOVE "looking 80 degrees up it is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-PITCH(WS-PLAYER)
*>   Obstruction: stone at cell (x + 5, y + 1, z) hides all three samples; at (x + 5, y, z) none of them.
     COMPUTE WS-FX = WS-BX + 5
     COMPUTE WS-FY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STONE
     PERFORM LOOK
     MOVE "a stone block at cell (5, 65, 0) hides all three samples" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-BZ WS-STONE
     PERFORM LOOK
     MOVE "a stone block at cell (5, 64, 0) leaves the eye sample free" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-GLASS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-BZ WS-GLASS
     PERFORM LOOK
     MOVE "glass has an empty visual shape: it does not hide the creaking" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-BZ WS-AIR
*>   Level.clip: the worked segment against stone at cell (5, 65, 0).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STONE
     COMPUTE WS-FX2 = WS-BX + 0.5
     COMPUTE WS-FY2 = WS-BY + 1.62
     COMPUTE WS-FZ2 = WS-BZ + 0.5
     COMPUTE WS-TX = WS-BX + 10.5
     COMPUTE WS-TY = WS-BY + 2.3
     COMPUTE WS-TZ = WS-BZ + 0.5
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "the document's segment hits the stone at cell (5, 65, 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE WS-FX2 TO WS-TX
     MOVE WS-FY2 TO WS-TY
     MOVE WS-FZ2 TO WS-TZ
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment from a point to itself is a miss" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A segment along the top face of the block (y = 66 exactly over the block at y 65): it runs in the cells above and misses; 0.1 lower it hits.
     COMPUTE WS-TX = WS-BX + 10.5
     COMPUTE WS-FY2 = WS-BY + 2
     COMPUTE WS-TY = WS-BY + 2
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment exactly along the top face of a block runs in the cells above and misses" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE WS-FY2 = WS-BY + 1.9
     COMPUTE WS-TY = WS-BY + 1.9
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment 0.1 below the top face hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A segment that starts inside a solid cell hits it at once (the start-inside rule), a tiny one inside it does not (below the length of 3e-4), one along +z walks the z axis to a block.
     COMPUTE WS-FY = WS-BY + 1
     COMPUTE WS-FX = WS-BX + 5
     COMPUTE WS-FX2 = WS-BX + 5.5
     COMPUTE WS-FY2 = WS-BY + 1.5
     COMPUTE WS-FZ2 = WS-BZ + 0.5
     COMPUTE WS-TX = WS-BX + 9.5
     COMPUTE WS-TY = WS-BY + 1.5
     COMPUTE WS-TZ = WS-BZ + 0.5
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment starting inside the stone hits it at once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE WS-TX = WS-BX + 5.50001
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment of 1e-5 inside the stone is too short to hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-AIR
     COMPUTE WS-IX = WS-BX + 8
     COMPUTE WS-IZ = WS-BZ + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-FY WS-IZ WS-STONE
     COMPUTE WS-FX2 = WS-BX + 8.5
     COMPUTE WS-FY2 = WS-BY + 1.5
     COMPUTE WS-FZ2 = WS-BZ + 0.5
     COMPUTE WS-TX = WS-BX + 8.5
     COMPUTE WS-TY = WS-BY + 1.5
     COMPUTE WS-TZ = WS-BZ + 10.5
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a segment along +z hits the stone 5 cells ahead" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-FY WS-IZ WS-AIR
*>   A diagonal segment through a cell corner of the walk and a downward one onto the floor.
     COMPUTE WS-FY2 = WS-BY + 5
     COMPUTE WS-TY = WS-BY - 3
     COMPUTE WS-TX = WS-BX + 0.5
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a vertical segment down onto the floor hits it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE WS-FY2 = WS-BY + 5
     COMPUTE WS-TY = WS-BY + 8
     CALL "CREAKING-CLIP" USING WS-DIM WS-FX2 WS-FY2 WS-FZ2 WS-TX WS-TY WS-TZ WS-HIT
     MOVE "a vertical segment up through air misses" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     STOP RUN.

 LOOK.
     CALL "CREAKING-LOOKING" USING WS-MOB WS-PLAYER WS-LOOK
     .

 CASE-LINE.
     MOVE WS-LOOK TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     .

 ASSERT-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§17.1 Creaking: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-17-2.
 COPY CORETEST.
 COPY MOBSPTEST.
