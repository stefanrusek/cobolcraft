*> Implementation test of the drag preview of the inventory screen (40-menus-1 section 5.2 and 5.4; task T4603): while a left drag over several slots is held,
*> every slot of the drag set is covered by the 16 x 16 translucent white rectangle and shows the carried item with its share of the cursor (count / n, the slot's
*> own count added, limited to the stack maximum), and the stack on the cursor shows the remainder (yellow, 0 included); with a one-slot set nothing is drawn.
*> Starting items: slots 0 to 7 hold 64 of items 2 to 9.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAG-PREVIEW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 15.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-PY                  FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-OVERLAYS           BINARY-LONG.
 01 WS-PREVIEWS           BINARY-LONG.
 01 WS-SHARE              PIC X(8).
 01 WS-REST               PIC X(8).
 01 WS-REST-COLOUR        BINARY-LONG.
 01 WS-SHARE-COLOUR       BINARY-LONG.
 01 WS-JIT               BINARY-LONG VALUE 0.
 01 WS-DOWN              BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-FEED-STARTING-ITEMS" USING CLIENT-STATE WS-CONN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO IN-CAPTURED
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE 0 TO WS-SLOT
     PERFORM CLICK-SLOT
     MOVE "T" TO TL-MODE

*>   A left drag over three empty slots, held: 32 on the cursor, share 10 each, 2 left.
     MOVE "test drag preview a held left drag over three empty slots covers them and shows 10 on each and 2 on the cursor" TO TL-CASE
     MOVE 12 TO WS-SLOT
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM DRAG-DOWN
     PERFORM DRAG-NUDGE
     PERFORM DRAG-TO
     MOVE 13 TO WS-SLOT
     PERFORM DRAG-TO
     MOVE 14 TO WS-SLOT
     PERFORM DRAG-TO
     PERFORM SCAN
     MOVE "overlays 3 previews 3 share 10 cursor 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OVERLAYS TO WS-E1
     MOVE WS-PREVIEWS TO WS-E2
     STRING "overlays " FUNCTION TRIM(WS-E1) " previews " FUNCTION TRIM(WS-E2) " share "
         FUNCTION TRIM(WS-SHARE) " cursor " FUNCTION TRIM(WS-REST) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAG-UP

*>   The cursor's 2 go back onto slot 0 (34), a right click takes the larger half (17).
     PERFORM RESET-CURSOR
*>   A right drag over the three slots (10 of the item each now) puts one item on each: 11; the cursor keeps 14.
     MOVE "test drag preview a held right drag over three slots shows one more item on each and 14 on the cursor" TO TL-CASE
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE 12 TO WS-SLOT
     PERFORM DRAG-DOWN
     PERFORM DRAG-NUDGE
     PERFORM DRAG-TO
     MOVE 13 TO WS-SLOT
     PERFORM DRAG-TO
     MOVE 14 TO WS-SLOT
     PERFORM DRAG-TO
     PERFORM SCAN
     MOVE "overlays 3 previews 3 share 11 cursor 14" TO TL-EXPECTED
     MOVE WS-OVERLAYS TO WS-E1
     MOVE WS-PREVIEWS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "overlays " FUNCTION TRIM(WS-E1) " previews " FUNCTION TRIM(WS-E2) " share "
         FUNCTION TRIM(WS-SHARE) " cursor " FUNCTION TRIM(WS-REST) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAG-UP

*>   In creative a middle drag (clone: a full stack each) over slot 0 (32 of the item) and an empty slot is limited to 64; the cursor keeps nothing: yellow "0".
     MOVE "test drag preview a held clone drag limits the share to the stack maximum in yellow and shows a yellow 0 on the cursor" TO TL-CASE
     PERFORM RESET-CURSOR
     MOVE 1 TO PL-MODE
     MOVE 2 TO WS-BUTTON
     MOVE 0 TO WS-SLOT
     PERFORM DRAG-DOWN
     PERFORM DRAG-NUDGE
     PERFORM DRAG-TO
     MOVE 16 TO WS-SLOT
     PERFORM DRAG-TO
     PERFORM SCAN
     MOVE "overlays 2 previews 2 share 64 yellow 16777045 cursor 0 yellow 16777045" TO TL-EXPECTED
     MOVE WS-OVERLAYS TO WS-E1
     MOVE WS-PREVIEWS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-SHARE-COLOUR TO WS-E3
     MOVE WS-REST-COLOUR TO WS-E4
     STRING "overlays " FUNCTION TRIM(WS-E1) " previews " FUNCTION TRIM(WS-E2) " share "
         FUNCTION TRIM(WS-SHARE) " yellow " FUNCTION TRIM(WS-E3) " cursor " FUNCTION TRIM(WS-REST)
         " yellow " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAG-UP

*>   A left drag over one slot only draws nothing.
     MOVE "test drag preview a held drag over one slot draws no rectangle and no preview" TO TL-CASE
     MOVE 15 TO WS-SLOT
     PERFORM DRAG-DOWN
     PERFORM DRAG-NUDGE
     PERFORM DRAG-TO
     PERFORM SCAN
     MOVE "overlays 0 previews 0" TO TL-EXPECTED
     MOVE WS-OVERLAYS TO WS-E1
     MOVE WS-PREVIEWS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "overlays " FUNCTION TRIM(WS-E1) " previews " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAG-UP
     STOP RUN.

*> The cursor's stack goes back onto slot 0 (left click), then a right click takes the larger half of it.
 RESET-CURSOR.
     MOVE 0 TO WS-SLOT
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK-SLOT
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK-SLOT.

*> Counts the white overlay rectangles and the cursor-kind slot widgets over slots in the widget list; WS-SHARE the text of the first preview,
*> WS-REST the text of the last widget of the list that is the cursor stack, WS-REST-COLOUR its colour.
 SCAN.
     MOVE 0 TO WS-OVERLAYS WS-PREVIEWS WS-REST-COLOUR WS-SHARE-COLOUR
     MOVE SPACES TO WS-SHARE WS-REST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-ARG(WS-I) = SW-WHITE AND SM-W-W(WS-I) = 16
             ADD 1 TO WS-OVERLAYS
         END-IF
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 36
             IF SM-W-W(WS-I) = 18
                 ADD 1 TO WS-PREVIEWS
                 IF WS-PREVIEWS = 1
                     IF SM-W-LENGTH(WS-I) > 0
                         MOVE SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) TO WS-SHARE
                     END-IF
                     MOVE SM-W-COLOUR(WS-I) TO WS-SHARE-COLOUR
                 END-IF
             ELSE
                 IF SM-W-LENGTH(WS-I) > 0
                     MOVE SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) TO WS-REST
                 END-IF
                 MOVE SM-W-COLOUR(WS-I) TO WS-REST-COLOUR
             END-IF
         END-IF
     END-PERFORM.

*> Window position of the centre of slot widget WS-SLOT (WS-PX, WS-PY).
 SLOT-POS.
     MOVE 2 TO WS-PX WS-PY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-SLOT
             COMPUTE WS-PX = (SM-W-X(WS-I) + SM-W-W(WS-I) / 2) * CL-GUI-SCALE
             COMPUTE WS-PY = (SM-W-Y(WS-I) + SM-W-H(WS-I) / 2) * CL-GUI-SCALE
         END-IF
     END-PERFORM.

*> One frame: the cursor over slot WS-SLOT, button WS-BUTTON down (WS-N 2) or up (3) or only moved (1).
 FRAME.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = WS-PX + WS-JIT
     MOVE WS-PY TO WS-Y(1)
     MOVE WS-PX TO WS-X(2)
     MOVE WS-PY TO WS-Y(2)
     MOVE WS-BUTTON TO WS-A(2)
     MOVE WS-DOWN TO WS-KIND(2)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N.

 RAW-CLICK.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-BUTTON TO WS-A(1) WS-A(2)
     MOVE WS-PX TO WS-X(1) WS-X(2)
     MOVE WS-PY TO WS-Y(1) WS-Y(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     PERFORM OBSERVE.

 CLICK-SLOT.
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     PERFORM FRAME
     PERFORM OBSERVE.

 DRAG-DOWN.
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     MOVE 2 TO WS-N
     PERFORM FRAME.

 DRAG-NUDGE.
     MOVE 8 TO WS-JIT
     PERFORM DRAG-TO
     MOVE 0 TO WS-JIT.

 DRAG-TO.
     MOVE 1 TO WS-N
     PERFORM FRAME.

 DRAG-UP.
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     MOVE 2 TO WS-N
     PERFORM FRAME
     PERFORM OBSERVE.

 OBSERVE.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-SLOT-COUNT(WS-SLOT + 1) TO WS-E1
     MOVE PL-SLOT-ITEM(WS-SLOT + 1) TO WS-E2
     STRING FUNCTION TRIM(WS-TEXT) " slot " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-DRAG-PREVIEW.
 COPY CLTEST.
