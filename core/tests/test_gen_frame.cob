*> Implementation test of the item frame in the worldgen entity channel (core/src/gen-ent.cob GENT-ADD-FRAME, entity-data.cob ENTITY-NBT-ONE; docs 36-8 section 9.4 Elytra marker, 44 part 9
*> section 5.3; T26000): a frame request is a compound with the id, Facing and the Item; applying it makes an item frame entity (the decor of core/src/decor-44b.cob) that faces the direction,
*> holds the item, hangs at the cell's centre moved 0.46875 against the facing and is not made twice; a frame without an Item is empty; ENTITY-NBT-ONE of a file reads a frame too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-FRAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 COPY GENENT.
 COPY PROJSTATE.
 COPY STRUCTPIECE.
 COPY PROTO.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG VALUE 3.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY112              PIC X(112).
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-FRAME-TYPE          BINARY-LONG.
 01 WS-GLOW-TYPE           BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ELYTRA              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-DX                  FLOAT-LONG.
 01 WS-META                PIC X(96).
 01 WS-J                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NBT                 PIC X(200).
 01 WS-NLEN                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "N" TO TL-MODE
     MOVE "minecraft:item_frame" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-FRAME-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:glow_item_frame" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-GLOW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE -1 TO WS-ELYTRA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "elytra"
             COMPUTE WS-ELYTRA = WS-I - 1
         END-IF
     END-PERFORM
     MOVE 0 TO GEL-COUNT GEL-LOST GE-COUNT GE-LOST
     MOVE 10 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 20 TO WS-Z
     MOVE "minecraft:elytra" TO WS-KEY
     MOVE 4 TO WS-DIRECTION
     CALL "GENT-ADD-FRAME" USING WS-X WS-Y WS-Z WS-DIRECTION WS-KEY
     MOVE "test gen frame: a frame request is kept with its position" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF GEL-COUNT = 1 AND GEL-X(1) = 10.96875 AND GEL-Z(1) = 20.5 AND GEL-Y(1) = 70.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GEN-ENT-LEVEL TO GEN-ENT
     MOVE 0 TO GEL-COUNT
     CALL "GENT-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO WS-FRAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-FRAME-TYPE
             MOVE WS-I TO WS-FRAME
         END-IF
     END-PERFORM
     MOVE "test gen frame: applying it makes one item frame entity" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FRAME > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FRAME = 0
         STOP RUN
     END-IF
     CALL "PJ-FIND" USING EN-ID(WS-FRAME) WS-SLOT
     MOVE "test gen frame: the frame is a kind 12 decor entity facing west (data value 4)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PJ-KIND(WS-SLOT) * 10 + PJ-I1(WS-SLOT)
     MOVE 124 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen frame: it holds the elytra, unrotated, not glowing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (PJ-I2(WS-SLOT) - WS-ELYTRA) * 100 + PJ-I3(WS-SLOT) * 10 + PJ-I4(WS-SLOT)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen frame: the elytra is a real item of the table" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ELYTRA > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen frame: facing west it hangs at the cell's centre moved 0.46875 against the facing (x 10.96875, y 70.5, z 20.5)" TO TL-CASE
     COMPUTE WS-DX = EN-X(WS-FRAME) - 10.96875
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION ABS(WS-DX) * 100000 + FUNCTION ABS(EN-Y(WS-FRAME) - 70.5) * 100000 + FUNCTION ABS(EN-Z(WS-FRAME) - 20.5) * 100000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the Elytra marker of the end city: the frame faces the piece's rotation of south at the marker cell (ENDCITY-MARKER, 36-8 9.4)
     MOVE "Elytra" TO WS-META
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         MOVE 0 TO GEL-COUNT GEL-LOST
         MOVE WS-I TO SP-T-ROT(1)
         CALL "ENDCITY-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
         MOVE -1 TO WS-FACING
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > GEL-LEN(1) - 9
             IF GEL-NBT(1)(WS-J:8) = X"010006" & "Facin"
                 COMPUTE WS-FACING = FUNCTION ORD(GEL-NBT(1)(WS-J + 9:1)) - 1
             END-IF
         END-PERFORM
         EVALUATE WS-I
             WHEN 0 MOVE 3 TO WS-WANT
             WHEN 1 MOVE 4 TO WS-WANT
             WHEN 2 MOVE 2 TO WS-WANT
             WHEN OTHER MOVE 5 TO WS-WANT
         END-EVALUATE
         MOVE "test gen frame: the Elytra marker asks for one frame facing the rotation of south (rotation 0 to 3: south, west, north, east)" TO TL-CASE
         COMPUTE TL-OBSERVED-N = GEL-COUNT * 10 + WS-FACING
         COMPUTE TL-EXPECTED-N = 10 + WS-WANT
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO GEL-COUNT GEL-LOST
     MOVE "Chestnut" TO WS-META
     CALL "ENDCITY-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "Other" TO WS-META
     CALL "ENDCITY-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test gen frame: a Chest marker makes no frame and an unknown marker nothing" TO TL-CASE
     MOVE GEL-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an entities file's glow item frame without an Item is an empty glowing frame; a frame whose Facing is not horizontal is not made
     MOVE SPACES TO WS-NBT
     MOVE 1 TO WS-NLEN
     STRING X"080002" "id" X"0019" "minecraft:glow_item_frame" X"010006" "Facing" X"02" X"090003" "Pos" X"06" X"00000003" X"4024000000000000" X"4051800000000000" X"4034000000000000" X"00"
         DELIMITED BY SIZE INTO WS-NBT WITH POINTER WS-NLEN
     CALL "PB-RESET" USING PB-BUFFER
     COMPUTE WS-NLEN = WS-NLEN - 1
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-NBT WS-NLEN
     MOVE 0 TO PB-POS
     MOVE EN-COUNT TO WS-BEFORE
     CALL "ENTITY-NBT-ONE" USING WS-DIM PB-BUFFER
     MOVE 0 TO WS-GLOW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-GLOW-TYPE
             MOVE WS-I TO WS-GLOW
         END-IF
     END-PERFORM
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GLOW > 0
         CALL "PJ-FIND" USING EN-ID(WS-GLOW) WS-SLOT
         COMPUTE TL-OBSERVED-N = PJ-I1(WS-SLOT) * 100 + PJ-I2(WS-SLOT) * 10 + PJ-I4(WS-SLOT)
     END-IF
     MOVE "test gen frame: a glow item frame of an entities file facing north without an Item is empty and glowing" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-NBT
     MOVE 1 TO WS-NLEN
     STRING X"080002" "id" X"0014" "minecraft:item_frame" X"010006" "Facing" X"01" X"00"
         DELIMITED BY SIZE INTO WS-NBT WITH POINTER WS-NLEN
     CALL "PB-RESET" USING PB-BUFFER
     COMPUTE WS-NLEN = WS-NLEN - 1
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-NBT WS-NLEN
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-BEFORE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         ADD EN-USED(WS-I) TO WS-BEFORE
     END-PERFORM
     CALL "ENTITY-NBT-ONE" USING WS-DIM PB-BUFFER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         ADD EN-USED(WS-I) TO WS-COUNT
     END-PERFORM
     MOVE "test gen frame: a frame facing up (Facing 1) is not made" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT - WS-BEFORE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GEN-FRAME.

 COPY NOSPAWN.
 COPY CORETEST.
