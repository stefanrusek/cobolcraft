*> Coverage of the woodland mansion piece layout's edge cases (docs/protocol/36-structures-7-woodland-mansion.md sections 6.1, 6.7, 6.8; core/src/struct-man-place.cob): a full piece list drops the next entry and counts it
*> lost, the 1x2 secret room of floor 0 takes a name 1x2_s1 or 1x2_s2, a 1x2 room with a door and room direction no row of the table covers adds nothing, and the door-less origin of a 2x2 room (a secret 2x2 room)
*> becomes the 2x2_s1 piece one cell east of the cell's position, with no draw.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-A-MAN-LAYOUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-NAME                PIC X(24).
 01 WS-NAME-OUT            PIC X(24).
 01 WS-KIND                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG VALUE 0.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG VALUE 0.
 01 WS-QY                  BINARY-LONG VALUE 70.
 01 WS-QZ                  BINARY-LONG VALUE 0.
 01 WS-DOOR                BINARY-LONG VALUE 3.
 01 WS-ROOM                BINARY-LONG VALUE 3.
 01 WS-GRID1               BINARY-LONG VALUE 1.
 01 WS-GRID3               BINARY-LONG VALUE 3.
 01 WS-VAL2                BINARY-LONG VALUE 2.
 01 WS-CODE                BINARY-LONG.
 01 WS-X3                  BINARY-LONG VALUE 3.
 01 WS-Y3                  BINARY-LONG VALUE 3.
 01 WS-BEFORE              BINARY-DOUBLE UNSIGNED.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROT                BINARY-LONG VALUE 0.
 01 WS-MIR                BINARY-LONG VALUE 0.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   MNP-EMIT with the table full
     MOVE 1500 TO MN-COUNT
     MOVE 0 TO MN-LOST
     MOVE "entrance" TO WS-NAME
     CALL "MNP-EMIT" USING WS-NAME WS-QX WS-QY WS-QZ WS-ROT WS-MIR
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-7§6.1 an entry over the table is counted lost" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MN-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6.1 a full table keeps its 1500 entries" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     MOVE MN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MN-COUNT MN-LOST
*>   the 1x2 secret room of floor 0: 1x2_s1 or 1x2_s2, one draw
     MOVE 5 TO WS-KIND
     MOVE 0 TO WS-FLOOR
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     MOVE SP-RNG TO WS-BEFORE
     CALL "MNP-NAME" USING WS-KIND WS-FLOOR WS-STAIRS WS-NAME
     MOVE "acceptance US12 36-7§6.8 a floor-0 secret 1x2 room is named 1x2_s1 or 1x2_s2 and draws once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF (WS-NAME = "1x2_s1" OR WS-NAME = "1x2_s2") AND SP-RNG NOT = WS-BEFORE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a 1x2 room with a door direction and room direction that no row of the table pairs adds nothing
     MOVE 9 TO WS-DOOR
     MOVE 9 TO WS-ROOM
     CALL "MNP-ROOM-1X2" USING WS-QX WS-QY WS-QZ WS-DOOR WS-ROOM WS-FLOOR WS-STAIRS
     MOVE "acceptance US12 36-7§6.7 a 1x2 room with no matching row adds no piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the secret 2x2 room, directly and through the cell of a door-less 2x2 room's origin
     CALL "MNP-ROOM-2X2S" USING WS-QX WS-QY WS-QZ
     MOVE "acceptance US12 36-7§6.7 the secret 2x2 room adds one piece named 2x2_s1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-7§6.7 the entry of the secret 2x2 room is 2x2_s1" TO TL-CASE
     MOVE "2x2_s1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE ME-NAME(1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO MN-COUNT MN-LOST
     MOVE 0 TO MN-ROT MN-OY
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 5
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
             MOVE 0 TO MN-CELL(WS-G, WS-I)
         END-PERFORM
     END-PERFORM
     CALL "MNG-SET" USING WS-GRID1 WS-X3 WS-Y3 WS-VAL2
     COMPUTE WS-CODE = 262144 + 10 + 1048576
     CALL "MNG-SET" USING WS-GRID3 WS-X3 WS-Y3 WS-CODE
     MOVE 0 TO WS-FLOOR
     MOVE 0 TO WS-QY
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     MOVE SP-RNG TO WS-BEFORE
     CALL "MNP-CELL" USING WS-FLOOR WS-QY WS-X3 WS-Y3
     MOVE MN-COUNT TO WS-COUNT
     MOVE "acceptance US12 36-7§6.7 the door-less origin of a 2x2 room adds the secret piece" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-7§6.7 that piece is 2x2_s1" TO TL-CASE
     MOVE "2x2_s1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE ME-NAME(1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-7§6.7 the secret 2x2 room draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF SP-RNG = WS-BEFORE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-A-MAN-LAYOUT.
