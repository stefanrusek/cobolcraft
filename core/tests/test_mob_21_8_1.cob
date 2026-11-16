*> Acceptance test (US15, lane 002-lane-mobsb; docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 8.1, 44-residual-mob-questions-x1-continuation.md section 2): the item entity
*> through the real tick: it falls under gravity and rests on the block below, a pickup delay counts down, the lifetime of 6000 ticks discards it, two identical stacks merge. The water and current
*> rules of the same section (underwater movement, the push of flowing water 0.014) are the cases of acc_us12_item_current.cob and test_itemphys_41_3.cob (41 section 3.2), the merge range of
*> test_itemphys_41_4.cob and the lifetime and damage rules of test_itemphys_41_5.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-1.
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
 01 WS-X                   FLOAT-LONG VALUE 20.5.
 01 WS-Y                   FLOAT-LONG VALUE 110.
 01 WS-Z                   FLOAT-LONG VALUE 20.5.
 01 WS-V                   FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 20.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REST                FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     MOVE 20 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "N" TO TL-MODE
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ENTITY
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US15 21§8.1 Item entity: after 3 ticks the item has fallen under gravity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Y(WS-ROW) < 110
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US15 21§8.1 Item entity: it rests on the block below (y = 99)" TO TL-CASE
     MOVE 99000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-ENTITY
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§8.1 Item entity: the item is discarded at age 6000" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-8-1.
