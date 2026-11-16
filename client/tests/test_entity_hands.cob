 *> Equipment of the mobs (05b 0x68 Set Equipment, 34-3 section 1.4 ItemInHandLayer and CrossedArmsItemLayer): the replica keeps the item of each equipment slot,
 *> ENTITY-HAND-FIND finds the hand of an arm cuboid from its eight corners (the end that hangs lowest or reaches farthest and the direction from the shoulder to the
 *> hand), ENTITIES-MESH keeps the hands of the mob in its row and GROUND-ITEMS-MESH draws the held item there, on both sides.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-HANDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET-ID           BINARY-LONG VALUE 104.
 01 WS-BYTE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CP OCCURS 8 TIMES.
       10 WS-CX            FLOAT-SHORT.
       10 WS-CY            FLOAT-SHORT.
       10 WS-CZ            FLOAT-SHORT.
 01 WS-P.
    05 WS-PV                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-A.
    05 WS-AV                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-OBS                 PIC 9.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
*>       A hanging arm 0.25 x 0.75 x 0.25 centred at (0.375, 1.0, 0.0): the corners in no particular order; the hand is the lower end, the direction down.
*>       A raised arm 0.25 x 0.25 x 0.75 centred at (0.375, 1.2, 0.4): the hand is the far end, the direction +z. A crossed-arms box: its centre, the direction down.
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
             MOVE 0.375 TO WS-CX(WS-K)
             MOVE 1.0 TO WS-CY(WS-K)
             MOVE 0 TO WS-CZ(WS-K)
             IF WS-I = 2
                 MOVE 1.2 TO WS-CY(WS-K)
                 MOVE 0.4 TO WS-CZ(WS-K)
             END-IF
             IF FUNCTION MOD(WS-K, 2) = 0
                 COMPUTE WS-CX(WS-K) = WS-CX(WS-K) + 0.125
             ELSE
                 COMPUTE WS-CX(WS-K) = WS-CX(WS-K) - 0.125
             END-IF
             IF WS-K > 4
                 IF WS-I = 2
                     COMPUTE WS-CZ(WS-K) = WS-CZ(WS-K) + 0.375
                 ELSE
                     COMPUTE WS-CY(WS-K) = WS-CY(WS-K) - 0.375
                 END-IF
             ELSE
                 IF WS-I = 2
                     COMPUTE WS-CZ(WS-K) = WS-CZ(WS-K) - 0.375
                 ELSE
                     COMPUTE WS-CY(WS-K) = WS-CY(WS-K) + 0.375
                 END-IF
             END-IF
             IF FUNCTION MOD(FUNCTION INTEGER((WS-K - 1) / 2), 2) = 1
                 IF WS-I = 2
                     COMPUTE WS-CY(WS-K) = WS-CY(WS-K) + 0.125
                 ELSE
                     COMPUTE WS-CZ(WS-K) = WS-CZ(WS-K) + 0.125
                 END-IF
             ELSE
                 IF WS-I = 2
                     COMPUTE WS-CY(WS-K) = WS-CY(WS-K) - 0.125
                 ELSE
                     COMPUTE WS-CZ(WS-K) = WS-CZ(WS-K) - 0.125
                 END-IF
             END-IF
         END-PERFORM
         MOVE 1 TO WS-KIND
         IF WS-I = 3
             MOVE 2 TO WS-KIND
         END-IF
         CALL "ENTITY-HAND-FIND" USING WS-CORNERS WS-KIND WS-P WS-A WS-OK
         MOVE "N" TO TL-MODE
         MOVE WS-I TO WS-OBS
         MOVE SPACES TO TL-CASE
         STRING "acceptance hands the hand of case " WS-OBS " is found" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance hands the hand of case " WS-OBS " is at the end of the arm" DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 625 TO TL-EXPECTED-N
             WHEN 2 MOVE 775 TO TL-EXPECTED-N
             WHEN OTHER MOVE 1000 TO TL-EXPECTED-N
         END-EVALUATE
         IF WS-I = 2
             COMPUTE TL-OBSERVED-N ROUNDED = WS-PV(3) * 1000
         ELSE
             COMPUTE TL-OBSERVED-N ROUNDED = WS-PV(2) * 1000
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance hands the direction of case " WS-OBS " runs from the shoulder to the hand" DELIMITED BY SIZE INTO TL-CASE
         IF WS-I = 2
             MOVE 1000 TO TL-EXPECTED-N
             COMPUTE TL-OBSERVED-N ROUNDED = WS-AV(3) * 1000
         ELSE
             MOVE -1000 TO TL-EXPECTED-N
             COMPUTE TL-OBSERVED-N ROUNDED = WS-AV(2) * 1000
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Set Equipment: entity id, then pairs (slot byte with 0x80 when more follow, stack): main hand slot 0 an item of id 5, head slot 5 (count 1, item 9).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 7 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 1 TO PB-ISX-COUNT
     MOVE 5 TO PB-ISX-ITEM
     MOVE 0 TO PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 128 TO WS-BYTE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 5 TO WS-BYTE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
     MOVE 9 TO PB-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-PACKET-ID
     MOVE "acceptance hands the main hand item is kept" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-EQ(1, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance hands the head item is kept" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EN-EQ(1, 6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance hands the other slots are empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-EQ(1, 2) + EN-EQ(1, 3) + EN-EQ(1, 7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An empty stack empties the slot; an unknown entity changes nothing.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 0 TO WS-BYTE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
     MOVE 0 TO PB-ISX-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-PACKET-ID
     MOVE "acceptance hands an empty stack empties the slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-EQ(1, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 99 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-PACKET-ID
     MOVE "acceptance hands an unknown entity is ignored" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EN-EQ(1, 6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie holding an item (main hand, the right arm): its mesh finds the right hand, the ground-item pass draws the item as two quads (12 vertices); without
*>   an item no vertex; an item in the off hand is in the left hand; a left-handed mob (mob flags bit 2) swaps the hands.
     MOVE 3 TO EN-EQ(1, 1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands a zombie with an item in its hand has the right hand found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-HAND-OK(1, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance hands the held item is drawn as two quads" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-EQ(1, 1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands without an item nothing is drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO EN-EQ(1, 2)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands an off hand item is drawn once" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO EN-EQ(1, 1)
     MOVE 2 TO EN-MOB-FLAGS(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands both hands hold an item: four quads" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A mob without arms in its model (a cow) holds nothing visible.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 3 TO EN-EQ(1, 1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands a cow holds nothing visible" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A villager holds an item in its crossed arms (one quad pair at the arms).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 3 TO EN-EQ(1, 1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance hands a villager holds the item in its crossed arms" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every mob with arms in its model holds an item: its hand is found by the name of the arm part.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         EVALUATE WS-I
             WHEN 1 MOVE "skeleton" TO WS-KEY
             WHEN 2 MOVE "piglin" TO WS-KEY
             WHEN 3 MOVE "pillager" TO WS-KEY
             WHEN 4 MOVE "witch" TO WS-KEY
             WHEN 5 MOVE "vex" TO WS-KEY
             WHEN 6 MOVE "allay" TO WS-KEY
             WHEN 7 MOVE "iron_golem" TO WS-KEY
             WHEN 8 MOVE "wandering_trader" TO WS-KEY
             WHEN 9 MOVE "zombie_villager" TO WS-KEY
             WHEN 10 MOVE "husk" TO WS-KEY
             WHEN 11 MOVE "evoker" TO WS-KEY
             WHEN OTHER MOVE "drowned" TO WS-KEY
         END-EVALUATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE 3 TO EN-EQ(1, 1)
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance hands a " FUNCTION TRIM(WS-KEY) " holds its item" DELIMITED BY SIZE INTO TL-CASE
         MOVE 12 TO TL-EXPECTED-N
         MOVE RL-GI-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ENTITY-HANDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.

