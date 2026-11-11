*> Acceptance test US19-1 to US19-3 (spec 002 FR-020; 13 §4): F with no screen open sends Player Action 7 (swap item with off hand: position 0,
*> face 0, sequence 0) and predicts nothing; F over a hovered slot of the inventory screen with an empty cursor sends a Container Click of type
*> SWAP (2) with button 40 and swaps the slot with the off hand here; the off-hand slot draws beside the hotbar while it holds a stack.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US19-SWAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG VALUE 70.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HOTBAR-X            BINARY-LONG.
 01 WS-OFF-X               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE 6.
 01 WS-HITS                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 3 TO PL-OFFHAND-COUNT
     MOVE 1 TO PL-OFFHAND-ITEM
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US19-1 when F is pressed on the world screen then Player Action 7 swap item with off hand is sent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "290700000000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US19-1 no local prediction: the off hand still holds its 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-OFFHAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The off-hand slot beside the hotbar: a slot widget (argument 37) left of the first hotbar slot.
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-HIT WS-HOTBAR-X WS-OFF-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 37
             MOVE SM-W-X(WS-I) TO WS-OFF-X
             ADD 1 TO WS-HIT
         END-IF
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 0
             MOVE SM-W-X(WS-I) TO WS-HOTBAR-X
         END-IF
     END-PERFORM
     MOVE "acceptance US19-3 the off-hand slot is in the HUD, once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US19-3 the off-hand slot is left of the hotbar" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OFF-X + 20 < WS-HOTBAR-X
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Inventory screen: slot 0 holds 5 of item 2; F with the cursor over it swaps it with the off hand (3 of item 1).
     MOVE 5 TO PL-SLOT-COUNT(1)
     MOVE 2 TO PL-SLOT-ITEM(1)
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 0
             MOVE WS-I TO WS-HIT
         END-IF
     END-PERFORM
     COMPUTE IN-CURSOR-X = (SM-W-X(WS-HIT) + 5) * CL-GUI-SCALE
     COMPUTE IN-CURSOR-Y = (SM-W-Y(WS-HIT) + 5) * CL-GUI-SCALE
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "2802"
     MOVE "acceptance US19-2 F over a hovered slot sends a Container Click (0x12) with button 40 and type SWAP (2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION MIN(WS-HITS, 1) * FUNCTION MIN(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)), 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US19-2 the packet is a Container Click: it starts 12 00" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1200" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US19-2 the slot now holds the off hand's 3 and the off hand the slot's 5" TO TL-CASE
     MOVE 3502 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 1000 + PL-OFFHAND-COUNT * 100 + PL-SLOT-ITEM(1) + 2 - 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US19-SWAP.

 COPY CLTEST.
