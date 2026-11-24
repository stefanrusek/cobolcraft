*> Test US12-client (spec 002, deferred part of T3230 to T3239; docs/protocol/40-menus-3-anvil-grindstone-smithing.md section 5.7): the smithing table's tooltips at GUI 320 x 240 (left 72, top 37). With the
*> error flag (data slot 0 is 1) the pointer over the error box (65, 46, 28 x 21) shows container.upgrade.error_tooltip; the pointer over the empty template slot 0 shows
*> container.upgrade.missing_template_tooltip; with a netherite upgrade template in slot 0 the empty slots 1 and 2 show the template's base and addition descriptions; elsewhere nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-3-SMITH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 21.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 1 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE "T" TO TL-MODE
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
*>   The netherite upgrade template of the standard set.
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-I WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-PATH = "netherite_upgrade_smithing_template"
             MOVE WS-I TO WS-ITEM
         END-IF
     END-PERFORM
     PERFORM OPEN-TYPE
*>   Slot 0 empty: the pointer over it shows the missing-template tooltip.
     MOVE 88 TO WS-D1
     MOVE 93 TO WS-D2
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 the pointer over the empty template slot shows Add Smithing Template" TO TL-CASE
     MOVE "Add Smithing Template" TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The base slot with no template: nothing.
     MOVE 106 TO WS-D1
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 an empty template slot gives nothing over slot 1" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The error box with the flag set.
     MOVE 1 TO BM-DATA(1)
     MOVE 142 TO WS-D1
     MOVE 87 TO WS-D2
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 with the error flag the pointer over the error box shows Item can't be upgraded this way" TO TL-CASE
     MOVE "Item can't be upgraded this way" TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BM-DATA(1)
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 without the flag the error box shows nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A netherite upgrade template in slot 0: the empty slots 1 and 2 describe what they take.
     MOVE 1 TO BX-COUNT(1)
     MOVE WS-ITEM TO BX-ITEM(1)
     MOVE 106 TO WS-D1
     MOVE 93 TO WS-D2
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 with a netherite upgrade template the empty base slot shows Add diamond armor, weapon, or tool" TO TL-CASE
     MOVE "Add diamond armor, weapon, or tool" TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 124 TO WS-D1
     PERFORM POINT
     MOVE "acceptance US12 40-3§5.7 and the empty addition slot shows Add Netherite Ingot" TO TL-CASE
     MOVE "Add Netherite Ingot" TO TL-EXPECTED
     PERFORM TIP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

 POINT.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = WS-D1 * 2
     COMPUTE WS-Y(1) = WS-D2 * 2
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> TL-OBSERVED: the first tooltip line (empty without a tooltip).
 TIP.
     MOVE SPACES TO TL-OBSERVED
     IF TT-COUNT > 0
         MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     END-IF
     .

 OPEN-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE 1 TO BM-STATE-ID
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

 END PROGRAM TEST-SCREEN-40-3-SMITH.

 COPY CLTEST.
