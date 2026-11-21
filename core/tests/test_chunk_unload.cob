*> Implementation test of chunk unloading (core/src/chunks-stream.cob CHUNKS-UNLOAD after
*> CHUNKS-FOLLOW, core/src/world.cob WORLD-CHUNK-RELEASE; docs/protocol/07-nbt-and-anvil.md §9.5;
*> tasks T1068): when a player's chunk cache center moves, every loaded chunk outside every player's
*> view square in its dimension is released from the chunk cache; a changed chunk is first written
*> to its region file and reads back the same when it comes into view again, an unchanged one is
*> generated again; a player who walks far enough to load more than 4096 distinct chunks in total
*> does not hit the cache-full fatal. Releasing keeps the hash chains of colliding chunks intact.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-UNLOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
  COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-MAX-USED            BINARY-LONG.
 01 WS-DIR                 PIC X(128) VALUE
     "build/core-test-world/dimensions/cobolcraft/main/region".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 55.
 01 WS-TEXT                PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE

*>   Alice is in chunk (0, 0); view distance 2. A block of chunk (1, 1) changes.
     MOVE 20 TO WS-X MOVE 70 TO WS-Y MOVE 20 TO WS-Z
     MOVE 15 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test chunk unload when Alice moves 20 chunks away, the chunks of her old view are "
         & "released: changed chunk (1, 1) written to r.0.0.mca first, unchanged chunk (-1, -1) "
         & "not written" TO TL-CASE
     MOVE 328.5 TO PL-X(CN-PLAYER(WS-ALICE))
     PERFORM FOLLOW
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-CX WS-CZ
     PERFORM DESCRIBE-CHUNK
     MOVE -1 TO WS-CX WS-CZ
     PERFORM DESCRIBE-CHUNK
     MOVE "loaded 0 stored 0 loaded 0 stored 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test chunk unload when Alice comes back, chunk (1, 1) reads back from its region file "
         & "with the changed block, and is not changed; chunk (-1, -1) is generated again"
         TO TL-CASE
     MOVE 4.5 TO PL-X(CN-PLAYER(WS-ALICE))
     PERFORM FOLLOW
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     STRING "block " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE CK-CHANGED(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " changed " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE -1 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW > 0
         STRING FUNCTION TRIM(WS-OBSERVED) " generated" DELIMITED BY SIZE INTO WS-OBSERVED
     END-IF
     MOVE "block 15 changed 0 generated" TO TL-EXPECTED
     PERFORM CHECK

*>   A walk east in steps of 5 chunks: 25 new chunks a step, 170 steps (4250 distinct chunks).
     MOVE "test chunk unload a player who walks far enough to load more than 4096 distinct chunks "
         & "does not hit the cache-full fatal; no more than 3 view squares stay loaded" TO TL-CASE
     MOVE 0 TO WS-MAX-USED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 170
         COMPUTE PL-X(CN-PLAYER(WS-ALICE)) = WS-I * 80 + 4.5
         PERFORM FOLLOW
         MOVE 0 TO WS-USED
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
             ADD CK-USED(WS-ROW) TO WS-USED
         END-PERFORM
         MOVE FUNCTION MAX(WS-USED, WS-MAX-USED) TO WS-MAX-USED
     END-PERFORM
     MOVE SPACES TO WS-OBSERVED
     IF WS-MAX-USED <= 75
         MOVE "at most 75 loaded" TO WS-OBSERVED
     ELSE
         MOVE WS-MAX-USED TO WS-EDIT
         STRING "loaded " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     END-IF
     MOVE "at most 75 loaded" TO TL-EXPECTED
     PERFORM CHECK

*>   Hash chains: chunks (0, 50), (4096, 50) and (8192, 50) share a bucket (73 x 4096 = 0 mod
*>   4096); the newest is at the head of the chain, (0, 50) at its end.
     MOVE "test chunk unload releasing a chunk at the end of its hash chain, then one in the "
         & "middle, keeps the others findable" TO TL-CASE
     MOVE 0 TO WS-CX
     MOVE 50 TO WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 4096 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW2
     MOVE 8192 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-I
     MOVE 4096 TO WS-CX
     CALL "WORLD-CHUNK-RELEASE" USING WS-ROW
     MOVE SPACES TO WS-OBSERVED
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-I
     IF WS-I = WS-ROW2
         MOVE "second found" TO WS-OBSERVED
     END-IF
     MOVE 0 TO WS-CX
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-I
     MOVE WS-I TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " first " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED
     CALL "WORLD-CHUNK-RELEASE" USING WS-ROW2
     MOVE 4096 TO WS-CX
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-I
     MOVE WS-I TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " then " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE "second found first 0 then 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 FOLLOW.
     CALL "CHUNKS-FOLLOW" USING WS-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT.

*> "loaded <0|1> stored <outcome>" for chunk (WS-CX, WS-CZ) of cobolcraft:main.
 DESCRIBE-CHUNK.
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW > 0
         MOVE 1 TO WS-ROW
     END-IF
     MOVE WS-ROW TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " loaded " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "REGION-READ" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " stored " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CHUNK-UNLOAD.

 COPY CORETEST.
