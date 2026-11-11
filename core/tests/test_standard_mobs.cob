*> Implementation test (crash fix, 002-lane-crashfix2; docs/design/world-types.md WT-22): in a standard world the entity type ids are
*> vanilla ids, so the cobolcraft stand-in mob table (sodgrazer 2, abend 3) does not apply. MOBS-TICK took every row of type >= 2
*> for a mob, so the player's own row (type 158 and the like) reached MOB-AI and indexed MB-KIND out of bounds. The world is opened
*> as cobolcraft, then the content set is replaced by the standard fixture set (as test_standard_roles does).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STANDARD-MOBS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 205.
 01 WS-FEW                 BINARY-LONG VALUE 5.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-VANILLA             BINARY-LONG VALUE 100.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 5.
 01 WS-CAUSE               BINARY-LONG VALUE 1.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-PLAYER-TYPE         BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "content/tests/fixtures/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "ENTITIES-OPEN"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-ENTITY-ROW(WS-ROW) TO WS-ROW

*>   A day of ticks spans two spawn ticks (Time mod 100 = 0): the player row is no mob and no stand-in mob appears.
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test standard mobs: ticking a standard world with a player does not crash and spawns no stand-in mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-ROWS
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A row of a vanilla type id (as a saved standard world holds) is inert: it stays where it is.
     MOVE PL-X(CN-PLAYER(WS-CONN)) TO WS-X
     MOVE PL-Y(CN-PLAYER(WS-CONN)) TO WS-Y
     MOVE PL-Z(CN-PLAYER(WS-CONN)) TO WS-Z
     CALL "MOB-SPAWN" USING EN-DIM(WS-ROW) WS-VANILLA WS-X WS-Y WS-Z WS-YAW WS-OTHER
     CALL "TEST-TICKS" USING WS-FEW
     MOVE "test standard mobs: a vanilla-type row is kept and stays put through ticks" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "kept" TO TL-EXPECTED
     IF EN-USED(WS-OTHER) = 1 AND EN-X(WS-OTHER) = WS-X AND EN-Z(WS-OTHER) = WS-Z
         MOVE "kept" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   MOB-STEP, called on such a row directly, leaves it alone as well.
     CALL "MOB-STEP" USING WS-OTHER
     MOVE "test standard mobs: MOB-STEP of a vanilla-type row changes nothing" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "kept" TO TL-EXPECTED
     IF EN-USED(WS-OTHER) = 1 AND EN-X(WS-OTHER) = WS-X AND EN-Z(WS-OTHER) = WS-Z AND EN-HURT(WS-OTHER) = 0
         MOVE "kept" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cell of the inert row neither blocks a placement (it is no mob) nor is it dealt with as one by damage or defeat.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     MOVE EN-TYPE(WS-ROW) TO WS-PLAYER-TYPE
     MOVE EN-DIM(WS-OTHER) TO WS-I
     MOVE 0 TO PL-USED(CN-PLAYER(WS-CONN))
     CALL "BLOCK-OVERLAPS-BODY" USING WS-I WS-BX WS-BY WS-BZ WS-HIT
     MOVE 1 TO PL-USED(CN-PLAYER(WS-CONN))
     MOVE "test standard mobs: a vanilla-type row does not block a block placement" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "HEALTH-MOB-DAMAGE" USING WS-OTHER WS-AMOUNT WS-CAUSE WS-ROW
     MOVE "test standard mobs: damage to a vanilla-type row ends in a plain removal" TO TL-CASE
     MOVE EN-USED(WS-OTHER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The stand-in table index: only cobolcraft types 2 and 3 have a row, and only in a cobolcraft world.
     MOVE "test standard mobs: MOB-INDEX of the player's vanilla type and of stand-in id 2 in a standard world is 0" TO TL-CASE
     CALL "MOB-INDEX" USING WS-PLAYER-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-TYPE
     CALL "MOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test standard mobs: MOB-TABLE-COUNT is 0 in a standard world" TO TL-CASE
     CALL "MOB-TABLE-COUNT" USING WS-COUNT
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE "N" TO TL-MODE
     MOVE "test standard mobs: MOB-INDEX in a cobolcraft world of type 2 is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 2 TO WS-TYPE
     CALL "MOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test standard mobs: MOB-INDEX in a cobolcraft world of type 3 is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE 3 TO WS-TYPE
     CALL "MOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test standard mobs: MOB-INDEX in a cobolcraft world of type 4 is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 4 TO WS-TYPE
     CALL "MOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test standard mobs: MOB-INDEX in a cobolcraft world of type 1 is 0" TO TL-CASE
     MOVE 1 TO WS-TYPE
     CALL "MOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test standard mobs: MOB-TABLE-COUNT in a cobolcraft world is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     CALL "MOB-TABLE-COUNT" USING WS-COUNT
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 COUNT-ROWS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STANDARD-MOBS.
 COPY CORETEST.
