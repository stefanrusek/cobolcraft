*> Implementation test of the merge rule (core/src/ground-items.cob; tasks T475; standin-content
*> §9.2 "Ground items never merge"; RULES.cpy RULE-GI-MERGES 0): two identical ground items (one
*> greystone each) spawned at the same position, and two lying side by side, stay separate entities
*> with their own counts however long they lie there. No player is in the world (nothing picks
*> them up); the items rest on greystone at (20, 98, 20) and (21, 98, 20) of cobolcraft:main.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-MERGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG VALUE 98.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 1.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 99.25.
 01 WS-Z                   FLOAT-LONG VALUE 20.5.
 01 WS-V                   FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 200.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     MOVE 20 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 21 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE

     MOVE "test ground item merge two identical items at the same position stay two entities "
         & "of one item each (standin §9.2: ground items never merge)" TO TL-CASE
     MOVE 20.5 TO WS-X
     PERFORM SPAWN
     PERFORM SPAWN
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "1:2x1 2:2x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test ground item merge two identical items lying side by side stay two entities"
         TO TL-CASE
     MOVE 21.5 TO WS-X
     PERFORM SPAWN
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 2 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "2:2x1 3:2x1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW.

*> WS-TEXT: "<id>:<item>x<count>" of ground items WS-ENTITY and WS-ENTITY + 1, or "<id>:none".
 DESCRIBE.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM 2 TIMES
         CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
         MOVE WS-ENTITY TO WS-E1
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E1) ":" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         IF WS-ROW = 0
             STRING "none" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         ELSE
             MOVE EN-ITEM(WS-ROW) TO WS-E1
             MOVE EN-ITEM-COUNT(WS-ROW) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
                 INTO WS-TEXT POINTER WS-PTR
         END-IF
         ADD 1 TO WS-ENTITY
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-GROUND-ITEM-MERGE.

 COPY CORETEST.
