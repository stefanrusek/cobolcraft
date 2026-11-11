*> Acceptance test, US12 shulker box drop keeps its contents (docs/protocol/31-block-entities-1 section 13.4; item component container of 25-1):
*> a shulker box with a named stack in slot 26 and a plain stack in slot 0 is broken: one shulker box item entity drops at the block centre
*> carrying the container component (no loose stacks); placing that stack again restores the slots (item, count and the name patch).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-SHULKER-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CSTACK.
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
 01 WS-SHULKER             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HANDLE              BINARY-LONG.
 01 WS-PATCH               BINARY-LONG.
 01 WS-BIG                 PIC X(2048).
 01 WS-NAMETEXT            PIC X(64).
 01 WS-NAMELEN             BINARY-LONG.
 01 WS-LOOSE               BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     MOVE "minecraft:shulker_box" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHULKER
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
     MOVE WS-SHULKER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 2 TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 9 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 0 TO WS-PATCH
     MOVE "Loot" TO WS-NAMETEXT
     MOVE 4 TO WS-NAMELEN
     CALL "SP-SET-NAME" USING WS-PATCH WS-NAMETEXT WS-NAMELEN
     MOVE 3 TO BE-SLOT-ITEM(WS-BE, 27)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 27)
     MOVE WS-PATCH TO BE-SLOT-VAR(WS-BE, 27)
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 shulker drop given a shulker box holding two stacks when it is broken then one shulker box item entity drops "
         & "with a component patch and no loose stack of the contents drops" TO TL-CASE
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-LOOSE
     MOVE 0 TO WS-DROPPED
     MOVE 0 TO WS-HANDLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1 AND EN-ITEM-COUNT(WS-I) > 0
             IF EN-ITEM(WS-I) = WS-SHULKER
                 ADD 1 TO WS-DROPPED
                 MOVE IP-I-VAR(WS-I) TO WS-HANDLE
             ELSE
                 ADD 1 TO WS-LOOSE
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-DROPPED TO WS-E1
     MOVE WS-LOOSE TO WS-E2
     MOVE SPACES TO WS-TEXT
     IF WS-HANDLE > 0
         MOVE "patch" TO WS-TEXT
     ELSE
         MOVE "nopatch" TO WS-TEXT
     END-IF
     STRING FUNCTION TRIM(WS-TEXT) " shulkers " FUNCTION TRIM(WS-E1) " loose " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-KEY
     MOVE WS-KEY TO WS-TEXT
     MOVE "patch shulkers 1 loose 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 shulker drop given the dropped stack picked up and placed again when the box is placed then slot 0 holds 9 of "
         & "item 2 and slot 26 the item with its name patch" TO TL-CASE
     MOVE WS-SHULKER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E1
     MOVE BE-SLOT-ITEM(WS-BE, 27) TO WS-E2
     MOVE BE-SLOT-VAR(WS-BE, 27) TO WS-PATCH
     CALL "SP-GET-NAME" USING WS-PATCH WS-NAMETEXT WS-NAMELEN
     MOVE SPACES TO WS-TEXT
     STRING "slot0 " FUNCTION TRIM(WS-E1) " slot26 " FUNCTION TRIM(WS-E2) " " WS-NAMETEXT(1:WS-NAMELEN) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slot0 9 slot26 3 Loot" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 shulker drop given an empty shulker box when it is broken then no shulker item drops with contents (nothing is "
         & "spilled)" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         MOVE 0 TO BE-SLOT-COUNT(WS-BE, WS-S) BE-SLOT-ITEM(WS-BE, WS-S) BE-SLOT-VAR(WS-BE, WS-S)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         MOVE 0 TO EN-USED(WS-I)
     END-PERFORM
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-LOOSE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1
             ADD 1 TO WS-LOOSE
         END-IF
     END-PERFORM
     MOVE WS-LOOSE TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "entities " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "entities 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 shulker drop given 27 stacks with 100-byte components (more than the 2048 bytes of a component value) when the "
         & "box is broken then the stacks are scattered loose and no shulker item carries them" TO TL-CASE
     MOVE WS-BX TO WS-X
     MOVE WS-SHULKER TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     PERFORM USE-FLOOR
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE ALL "x" TO WS-BIG
     MOVE 100 TO WS-NAMELEN
     MOVE 0 TO WS-PATCH
     MOVE 70 TO WS-S
     CALL "SP-SET-COMPONENT-X" USING WS-PATCH WS-S WS-BIG WS-NAMELEN
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         MOVE 2 TO BE-SLOT-ITEM(WS-BE, WS-S)
         MOVE 1 TO BE-SLOT-COUNT(WS-BE, WS-S)
         MOVE WS-PATCH TO BE-SLOT-VAR(WS-BE, WS-S)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         MOVE 0 TO EN-USED(WS-I)
     END-PERFORM
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-LOOSE
     MOVE 0 TO WS-DROPPED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1
             IF EN-ITEM(WS-I) = WS-SHULKER
                 ADD 1 TO WS-DROPPED
             ELSE
                 ADD EN-ITEM-COUNT(WS-I) TO WS-LOOSE
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-LOOSE TO WS-E1
     MOVE WS-DROPPED TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "loose " FUNCTION TRIM(WS-E1) " shulkers " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "loose 27 shulkers 0" TO TL-EXPECTED
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

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-SHULKER-DROP.

 COPY CORETEST.
 COPY BETEST.
