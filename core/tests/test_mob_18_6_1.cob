*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.1, with doc 44 part 1 section 4.7): the spawn cycle: which categories a tick tries.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-TIME               BINARY-DOUBLE.
 01 WS-MOBS               BINARY-LONG.
 01 WS-MONSTERS           BINARY-LONG.
 01 WS-CAT               BINARY-LONG.
 01 WS-SEED              BINARY-DOUBLE UNSIGNED.
 01 WS-CHUNKS             BINARY-LONG VALUE 289.
 01 WS-N                  BINARY-LONG.
 01 WS-COUNTS.
    05 WS-COUNT           BINARY-LONG OCCURS 8 TIMES.
 01 WS-FLAGS.
    05 WS-FLAG            BINARY-LONG OCCURS 8 TIMES.
 01 WS-PLAYER            BINARY-LONG.
 01 WS-OTHER             BINARY-LONG.
 01 WS-OTHER-CONN        BINARY-LONG.
 01 WS-NAME              PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH       BINARY-LONG VALUE 5.
 01 WS-DIM               BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-TICK              BINARY-LONG.
 01 WS-CX                BINARY-LONG.
 01 WS-CZ                BINARY-LONG.
 01 WS-X0                BINARY-LONG.
 01 WS-Z0                BINARY-LONG.
 01 WS-FY                BINARY-LONG.
 01 WS-SIZE              BINARY-LONG VALUE 16.
 01 WS-KIND              BINARY-LONG VALUE 2.
 01 WS-SPAWNED           BINARY-LONG.
 01 WS-FOUND             BINARY-LONG.
 01 WS-BIOME             BINARY-LONG.
 01 WS-PLAINS            BINARY-LONG.
 01 WS-KEY               PIC X(48).
 01 WS-EKEY              PIC X(112).
 01 WS-TYPE              BINARY-LONG.
 01 WS-ENTITY-ROW        PIC X(66).
 01 WS-STATUS            BINARY-LONG.
 01 WS-ROW               BINARY-LONG.
 01 WS-X                 FLOAT-LONG.
 01 WS-Y                 FLOAT-LONG.
 01 WS-Z                 FLOAT-LONG.
 01 WS-YAW               FLOAT-SHORT VALUE 0.
 01 WS-SAVED             BINARY-LONG.
 01 WS-BEFORE            BINARY-LONG.
 PROCEDURE DIVISION.
     INITIALIZE WS-COUNTS
     MOVE 1 TO WS-MOBS WS-MONSTERS
     MOVE 400 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: on a tick with gameTime mod 400 = 0 all seven categories are tried" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: creature is the second category and is on" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAG(2) TO WS-O
     PERFORM CHECK-N

     MOVE 401 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: on other ticks the creature category is left out (six remain)" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: the creature flag is 0 off the friendly cycle" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAG(2) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: monster stays on every tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     PERFORM CHECK-N

     MOVE 0 TO WS-MONSTERS
     MOVE 400 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: spawn_monsters off drops the monster category only" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     MOVE "acceptance US15 18§6.1 The spawn cycle: the monster flag is 0 with spawn_monsters off" TO WS-CASE
     PERFORM CHECK-N

     MOVE 0 TO WS-MOBS
     MOVE 1 TO WS-MONSTERS
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: spawn_mobs false makes the list empty" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-1§4.7 spawn_mobs false: no flag is set" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-FLAG(1) + WS-FLAG(2) + WS-FLAG(3) + WS-FLAG(7)
     PERFORM CHECK-N

     MOVE 1 TO WS-MOBS
     MOVE 70 TO WS-COUNT(1)
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: a category at its global cap is left out" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     PERFORM CHECK-N
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OTHER-CONN
     MOVE CN-PLAYER(WS-OTHER-CONN) TO WS-OTHER
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE SPACES TO WS-EKEY
     MOVE "minecraft:pig" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE "minecraft:zombie" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
*>   The tick: 40 ticks run the whole cycle (the chunks are dealt out over 20 ticks); it never crashes and keeps the creature count within the cap.
     PERFORM VARYING WS-TICK FROM 0 BY 1 UNTIL WS-TICK > 39
         MOVE WS-TICK TO CW-TIME
         CALL "MS6-CYCLE"
     END-PERFORM
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.1 The spawn cycle: 40 ticks of MS6-CYCLE with two players keep the mob count small (the two placed plus few natural)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-FOUND >= 2 AND WS-FOUND < 60
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE CT-SET-TYPE TO WS-SAVED
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE WS-FOUND TO WS-BEFORE
     MOVE 0 TO CW-TIME
     CALL "MS6-CYCLE"
     MOVE WS-SAVED TO CT-SET-TYPE
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.1 The spawn cycle: a world that is not a standard set is left alone" TO WS-CASE
     MOVE WS-BEFORE TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
*>   One attempt per chunk and category: a grass floor over a whole chunk, 3000 seeds, y drawn uniformly so some land above the floor.
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16) + 1
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     COMPUTE WS-X0 = WS-CX * 16
     COMPUTE WS-Z0 = WS-CZ * 16
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000 OR WS-FOUND > 0
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 2 TO WS-CAT
         CALL "MS6-SPAWN-CHUNK" USING XR-STATE WS-DIM WS-CAT WS-CX WS-CZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-FOUND
     END-PERFORM
     MOVE "acceptance US15 18§6.1 The spawn cycle: one position per chunk and category eventually lands above the floor and spawns a pack" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-FOUND > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "minecraft:plains" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-PLAINS
     COMPUTE WS-X0 = WS-X0 + 4000
     CALL "MS6-BIOME-AT" USING WS-DIM WS-X0 WS-FY WS-Z0 WS-BIOME
     MOVE "acceptance US15 18§6.6 Spawner data: a column that is not loaded uses the plains list" TO WS-CASE
     MOVE WS-PLAINS TO WS-E
     MOVE WS-BIOME TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-X0 = WS-CX * 16
     CALL "MS6-BIOME-AT" USING WS-DIM WS-X0 WS-FY WS-Z0 WS-BIOME
     MOVE "acceptance US15 18§6.6 Spawner data: a loaded column gets a biome row of the table" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-BIOME > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-1.
 COPY CORETEST.
 COPY MOBSPTEST.
