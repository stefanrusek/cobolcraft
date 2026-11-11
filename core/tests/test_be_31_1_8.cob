*> Test of 31 section 8 (Container openers and open or close events; T0855): the opener counter (8.2) with the hooks of the chest family
*> (block event 1 with the new count), the barrel (OPEN property, no block event), the trapped chest (neighbour updates), the spectator and
*> removed guards (8.1), the recheck tick (worked example 5) and the search box inflation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 COPY BEFX.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-CHEST               BINARY-LONG.
 01 WS-BARREL              BINARY-LONG.
 01 WS-TRAPPED             BINARY-LONG.
 01 WS-RANGE               BINARY-LONG VALUE 4500.
 01 WS-USERS               BINARY-LONG.
 01 WS-SPEC                BINARY-LONG VALUE 0.
 01 WS-MAXR                BINARY-LONG.
 01 WS-INFL                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT5               PIC -(9)9.
 01 WS-EDIT6               PIC -(9)9.
 01 WS-EDIT7               PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "minecraft:chest" TO WS-KEY
     MOVE 15 TO WS-LEN
     MOVE 1 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-CHEST
     ADD 1 TO WS-X
     MOVE "minecraft:barrel" TO WS-KEY
     MOVE 16 TO WS-LEN
     MOVE 26 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-BARREL
     ADD 1 TO WS-X
     MOVE "minecraft:trapped_chest" TO WS-KEY
     MOVE 23 TO WS-LEN
     MOVE 2 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-TRAPPED

     MOVE "acceptance US12 31-1§8 openers: example 5: A opens (sound, event, tick 5, block event 1), B opens (count 2, nothing else), B closes, A closes" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-CHEST TO WS-CUR
     CALL "BE-OPEN-INC" USING WS-CHEST WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-INC" USING WS-CHEST WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-DEC" USING WS-CHEST WS-SPEC BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-DEC" USING WS-CHEST WS-SPEC BE-FX
     PERFORM FX-TEXT
     MOVE "c1 s1 e1 t5 b1 p-1 n0 | c2 s0 e0 t0 b2 p-1 n0 | c1 s0 e0 t0 b1 p-1 n0 | c0 s2 e2 t0 b0 p-1 n0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§8 openers: recheck: a lost opener is repaired, the block event goes out unconditionally and another tick is scheduled while open" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     CALL "BE-OPEN-INC" USING WS-CHEST WS-RANGE WS-SPEC BE-FX
     CALL "BE-OPEN-INC" USING WS-CHEST WS-RANGE WS-SPEC BE-FX
     MOVE 1 TO WS-USERS
     MOVE 3000 TO WS-MAXR
     CALL "BE-OPEN-RECHECK" USING WS-CHEST WS-USERS WS-MAXR BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-RECHECK" USING WS-CHEST WS-USERS WS-MAXR BE-FX
     PERFORM FX-TEXT
     MOVE 0 TO WS-USERS
     CALL "BE-OPEN-RECHECK" USING WS-CHEST WS-USERS WS-MAXR BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-RECHECK" USING WS-CHEST WS-USERS WS-MAXR BE-FX
     PERFORM FX-TEXT
     MOVE 2 TO WS-USERS
     CALL "BE-OPEN-RECHECK" USING WS-CHEST WS-USERS WS-MAXR BE-FX
     PERFORM FX-TEXT
     MOVE "c1 s0 e0 t5 b1 p-1 n0 | c1 s0 e0 t5 b1 p-1 n0 | c0 s2 e2 t0 b0 p-1 n0 | c0 s0 e0 t0 b0 p-1 n0 | c2 s1 e1 t5 b2 p-1 n0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§8 openers: the barrel has no block event and sets the OPEN property true on the first opener and false on the last" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-BARREL TO WS-CUR
     CALL "BE-OPEN-INC" USING WS-BARREL WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-DEC" USING WS-BARREL WS-SPEC BE-FX
     PERFORM FX-TEXT
     MOVE "c1 s1 e1 t5 b-1 p1 n0 | c0 s2 e2 t0 b-1 p0 n0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§8 openers: the trapped chest also updates neighbours when the count changes" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-TRAPPED TO WS-CUR
     CALL "BE-OPEN-INC" USING WS-TRAPPED WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     MOVE "c1 s1 e1 t5 b1 p-1 n1 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§8 openers: a spectator or a removed entity opens and closes nothing" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-BARREL TO WS-CUR
     MOVE 1 TO WS-SPEC
     CALL "BE-OPEN-INC" USING WS-BARREL WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     MOVE 0 TO WS-SPEC
     MOVE 1 TO BE-REMOVED(WS-BARREL)
     CALL "BE-OPEN-INC" USING WS-BARREL WS-RANGE WS-SPEC BE-FX
     PERFORM FX-TEXT
     CALL "BE-OPEN-DEC" USING WS-BARREL WS-SPEC BE-FX
     PERFORM FX-TEXT
     MOVE "c0 s0 e0 t0 b-1 p-1 n0 | c0 s0 e0 t0 b-1 p-1 n0 | c0 s0 e0 t0 b-1 p-1 n0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§8 openers: the container user search box is inflated by the range plus 4.0 (8.2); the range is the maximum seen" TO TL-CASE
     CALL "BE-SEARCH-INFLATE" USING WS-CHEST WS-INFL
     MOVE WS-INFL TO WS-EDIT
     MOVE BE-OPEN-RANGE(WS-CHEST) TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "7000 3000" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 FX-TEXT.
     MOVE BE-OPEN-COUNT(WS-CUR) TO WS-EDIT
     MOVE FX-SOUND TO WS-EDIT2
     MOVE FX-EVENT TO WS-EDIT3
     MOVE FX-TICK TO WS-EDIT4
     MOVE FX-BLOCK-EVENT TO WS-EDIT5
     MOVE FX-PROP TO WS-EDIT6
     MOVE FX-NEIGHBOURS TO WS-EDIT7
     STRING "c" FUNCTION TRIM(WS-EDIT) " s" FUNCTION TRIM(WS-EDIT2) " e" FUNCTION TRIM(WS-EDIT3) " t" FUNCTION TRIM(WS-EDIT4)
         " b" FUNCTION TRIM(WS-EDIT5) " p" FUNCTION TRIM(WS-EDIT6) " n" FUNCTION TRIM(WS-EDIT7) " | " DELIMITED BY SIZE
         INTO WS-TEXT WITH POINTER WS-PTR.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-8.

 COPY CORETEST.
