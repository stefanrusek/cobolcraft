*> Acceptance test, US12 sneaking (docs/protocol/05c 0x2B Player Input, flag 0x20; 31-1 section 10.2 placement): the sneak state follows Player Input;
*> a sneaking player placing a chest against the side of a single chest joins it (taking its facing, right half when the new chest is
*> counter-clockwise of the clicked side) whatever way he looks, a sneaking player holding an item does not open a container but one with an
*> empty hand does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-SNEAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-CHEST               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-FLAGS               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-CHEST
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STONE
     PERFORM PREPARE-GROUND
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 9 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 sneak given Player Input with the shift flag then the player is sneaking, and not after Player Input 0" TO TL-CASE
     MOVE 32 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-CONN WS-FLAGS
     MOVE PL-SNEAKING(WS-ROW) TO WS-E1
     MOVE 0 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-CONN WS-FLAGS
     MOVE PL-SNEAKING(WS-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "on " FUNCTION TRIM(WS-E1) " off " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "on 1 off 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 sneak given a sneaking player looking east holding a chest when he clicks the east side of a north-facing single "
         & "chest then the new chest faces north and is the right half, the old one the left half" TO TL-CASE
     MOVE 32 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-CONN WS-FLAGS
     MOVE 270 TO PL-YAW(WS-ROW)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 5 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = WS-BX + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE2
     COMPUTE WS-E1 = WS-STATE - CB-FIRST-STATE(WS-ID + 1)
     COMPUTE WS-E2 = WS-STATE2 - CB-FIRST-STATE(WS-ID + 1)
     MOVE SPACES TO WS-TEXT
     STRING "old " FUNCTION TRIM(WS-E1) " new " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "old 3 new 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 sneak given a sneaking player holding an item when he uses a chest then it does not open (the item is only held), with an empty hand it opens" TO TL-CASE
     MOVE 0 TO PL-YAW(WS-ROW)
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE "minecraft:book" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     MOVE 0 TO WS-I
     IF MN-WINDOW(WS-ROW) > 0
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E1
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-BLOCK
     MOVE 0 TO WS-I
     IF MN-WINDOW(WS-ROW) > 0
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " then " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0 then 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE
         MOVE 0 TO WS-STATE2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-S = WS-BY + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-BZ WS-STATE2
         END-PERFORM
     END-PERFORM.

 USE-FLOOR.
     ADD 1 TO WS-SEQ
     COMPUTE WS-Y = WS-BY - 1
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM DRAIN.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-SNEAK.

 COPY CORETEST.
 COPY BETEST.
