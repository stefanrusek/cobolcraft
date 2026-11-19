*> The entity data of the non-mob entities (docs/protocol/21 sections 8.9 and 8.16; lane p49f, T21500 and T21510): the armor stand sends its flags (15, Byte) and six poses (16 to 21, Rotations), the item frame its
*> direction (8), item (9) and rotation (10), each sent once the state is complete and again when it changes; the interaction entity sends width, height and response (8, 9, 10), the block and item display
*> entities their block state or stack (23, 24); the cushion its colour (8), the mannequin its main hand (15), model customisation (16) and immovable flag (18). A player who right-clicks a cushion without
*> secondary use sits on it while nobody sits there (8.16).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-RESPONSE            BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-COMMON              PIC X(240) VALUE "8=I0,9=I0,10=I0,11=V0.00/0.00/0.00,12=V1.00/1.00/1.00,13=Q0.00/0.00/0.00/1.00,14=Q0.00/0.00/0.00/1.00,15=I0,16=I-1,17=F1.00,18=F0.00,19=F1.00,20=F0.00,21=F0.00,22=I-1,".
 01 WS-EXPECT              PIC X(400).
 01 WS-ID                  PIC Z(8)9.
 01 WS-ITEM-N              PIC Z(8)9.
 01 WS-TID                 BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-SNEAK1              BINARY-LONG VALUE 1.
 01 WS-FILL-ID             BINARY-LONG.
 01 WS-FILL-KIND           BINARY-LONG VALUE 1.
 01 WS-FILL-SLOT           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 5.
 01 WS-DTYPE               BINARY-LONG VALUE 1.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-SAVE-SET            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIAMOND WS-ITEM-ROW WS-STATUS
     MOVE WS-DIAMOND TO WS-ITEM-N
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 20
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
*>   The armor stand: flags and six poses once, nothing while unchanged, everything again on a change.
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";15=I0,16=R0.00/0.00/0.00,17=R0.00/0.00/0.00,18=R-10.00/0.00/-10.00,"
         "19=R-15.00/0.00/10.00,20=R-1.00/0.00/-1.00,21=R1.00/0.00/1.00)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:armor_stand 21§8.9 Add Entity then metadata 15 flags and 16 to 21 the six default poses" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "THROWN-TICK"
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 minecraft:armor_stand 21§8.9 nothing is sent while the stand does not change" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 5 TO PJ-I1(WS-SLOT)
     MOVE 30 TO PJ-POSE(WS-SLOT, 1)
     CALL "THROWN-TICK"
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";15=I5,16=R30.00/0.00/0.00,17=R0.00/0.00/0.00,18=R-10.00/0.00/-10.00,"
         "19=R-15.00/0.00/10.00,20=R-1.00/0.00/-1.00,21=R1.00/0.00/1.00)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:armor_stand 21§8.9 small + show arms (5) and a head pose of 30 degrees are sent on the tick" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The item frame: direction (8), item (9) and rotation (10).
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "minecraft:item_frame" TO WS-KEY
     MOVE 12 TO WS-KIND
     MOVE 3 TO WS-DIR
     CALL "DECOR-SPAWN" USING WS-KIND WS-KEY WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";8=I3,9=S0x0,10=I0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:item_frame 21§8.9 Add Entity then metadata 8 direction, 9 empty stack, 10 rotation 0" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE WS-DIAMOND TO PJ-I2(WS-SLOT)
     MOVE 3 TO PJ-I3(WS-SLOT)
     CALL "THROWN-TICK"
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";8=I3,9=S" FUNCTION TRIM(WS-ITEM-N) "x1,10=I3)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:item_frame 21§8.9 a diamond in the frame turned to 3 is sent on the tick" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   A painting sends its direction (the variant is not stored).
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "minecraft:painting" TO WS-KEY
     MOVE 13 TO WS-KIND
     MOVE 4 TO WS-DIR
     CALL "DECOR-SPAWN" USING WS-KIND WS-KEY WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";8=I4)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:painting 21§8.9 Add Entity then metadata 8 direction" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The interaction entity.
     MOVE 2.5 TO WS-WIDTH
     MOVE 0.75 TO WS-HEIGHT
     MOVE 1 TO WS-RESPONSE
     CALL "INTERACTION-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-WIDTH WS-HEIGHT WS-RESPONSE WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE "minecraft:interaction" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ITEM-ROW WS-STATUS
     MOVE "acceptance US15 minecraft:interaction 21§8.9 the entity is of type interaction" TO WS-CASE
     MOVE WS-TYPE TO WS-E
     MOVE EN-TYPE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";8=F2.50,9=F0.75,10=Z1)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:interaction 21§8.9 metadata 8 width, 9 height (Floats), 10 response (Boolean)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The block display and item display entities: field 23 (and 24).
     CALL "BDISPLAY-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";" FUNCTION TRIM(WS-COMMON) "23=I5)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:block_display 21§8.9 metadata 23 = the block state" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
     CALL "IDISPLAY-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-DTYPE WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";" FUNCTION TRIM(WS-COMMON) "23=S" FUNCTION TRIM(WS-ITEM-N) "x1,24=I1)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:item_display 21§8.9 metadata 23 = the stack, 24 = the display type" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The text display: the common fields, the empty text component (a root String of length 0: 3 bytes), line width 200, background 0x40000000, opacity -1, flags 0 (21 section 8.9.3).
     CALL "TDISPLAY-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE "minecraft:text_display" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ITEM-ROW WS-STATUS
     MOVE "acceptance US15 minecraft:text_display 21§8.9.3 the entity is of type text_display" TO WS-CASE
     MOVE WS-TYPE TO WS-E
     MOVE EN-TYPE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";" FUNCTION TRIM(WS-COMMON) "23=D0:3,24=I200,25=I1073741824,26=I-1,27=I0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:text_display 21§8.9.3 defaults: text empty, line width 200, background 0x40000000, opacity -1, flags 0" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The mannequin.
     CALL "MANNEQUIN-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE "minecraft:mannequin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ITEM-ROW WS-STATUS
     MOVE "acceptance US15 minecraft:mannequin 21§8.16 the entity is of type mannequin" TO WS-CASE
     MOVE WS-TYPE TO WS-E
     MOVE EN-TYPE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";15=I1,16=I127,17=D0:8,18=Z0,19=D1:48)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:mannequin 21§8.16.2 main hand right (1), 127 layers, the empty profile (8 bytes), not immovable, the label description (48 bytes)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   The cushion: colour (8); a right-click without secondary use sits on it, once.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 1
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE 11 TO WS-COLOUR
     CALL "CUSHION-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-COLOUR WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID WS-TID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";8=I11)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:cushion 21§8.16 Add Entity then metadata 8 = the dye colour" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-TID WS-HAND0 WS-SNEAK1
     MOVE "acceptance US15 minecraft:cushion 21§8.16 a player using secondary use does not sit" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-TID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 minecraft:cushion 21§8.16 a right-click sits the player on the cushion" TO WS-CASE
     MOVE WS-ROW TO WS-E
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:cushion 21§8.16 the cushion has its passenger" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE EN-RIDER(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   Somebody sits there: a second sit is refused (the same player cannot sit twice either).
     CALL "CUSHION-USE" USING WS-PLAYER WS-ROW WS-STATUS
     MOVE "acceptance US15 minecraft:cushion 21§8.16 while somebody sits on it nobody else can" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
     CALL "CUSHION-USE" USING WS-PLAYER PL-ENTITY-ROW(WS-PLAYER) WS-STATUS
     MOVE "acceptance US15 minecraft:cushion 21§8.16 a row that is no cushion is not used" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
*>   A viewer who comes later gets the data as ENTITY-EXTRA-NEEDED and ENTITY-EXTRA-DATA say.
     CALL "ENTITY-EXTRA-NEEDED" USING WS-ROW WS-NEEDED
     MOVE "acceptance US15 minecraft:cushion 21§8.16 a cushion whose data was sent has entity data for later viewers" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEEDED TO WS-O
     PERFORM CHECK-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EXTRA-DATA" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 minecraft:cushion 21§8.16 the later viewer's Set Entity Data is not empty" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PB-LENGTH > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
*>   A row without a state entry has nothing to sync.
     CALL "DECOR-DATA-SYNC" USING PL-ENTITY-ROW(WS-PLAYER)
*>   Another content set has no such entity types: nothing is made.
     MOVE CT-SET-TYPE TO WS-SAVE-SET
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "CUSHION-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-COLOUR WS-ROW
     MOVE WS-SAVE-SET TO CT-SET-TYPE
     MOVE "acceptance US15 minecraft:cushion 21§8.16 without the entity type no cushion is made" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     PERFORM CHECK-N
*>   A full state table: nothing is made.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         COMPUTE WS-FILL-ID = 900000 + WS-I
         CALL "PJ-ALLOC" USING WS-FILL-ID WS-FILL-KIND WS-FILL-SLOT
     END-PERFORM
     CALL "MANNEQUIN-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE "acceptance US15 minecraft:mannequin 21§8.16 with the state table full no mannequin is made" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-9.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
