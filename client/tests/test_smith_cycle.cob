*> Test US12-client (spec 002; docs/protocol/40-menus-3-anvil-grindstone-smithing.md 5.6): the cycling template-hint icons of the smithing table: slot 0 cycles the two template icons, every 30th tick moves the
*> index on; the base and addition helpers have no list without a template and the template's lists with one (a change of list resets the index, not the counter); nothing is drawn for a slot that holds
*> an item; the alpha of a transition rises in quarters over 4 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SMITH-CYCLE.
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
 01 WS-ICON                PIC X(40).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-ALPHA               BINARY-LONG.
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
     MOVE "N" TO TL-MODE
     MOVE 29 TO WS-N
     PERFORM TICKS
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 after 29 ticks the template slot still shows the armor trim template icon" TO TL-CASE
     MOVE "smithing_template_armor_trim" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-N
     PERFORM TICKS
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 the 30th tick moves slot 0 to the netherite upgrade template icon" TO TL-CASE
     MOVE "smithing_template_netherite_upgrade" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-3§5.6 at tick 30 the transition alpha is 0 (the previous icon fades out first)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ALPHA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-N
     PERFORM TICKS
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 two ticks into a transition the alpha is 2 / 4 = 8 sixteenths" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-ALPHA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-N
     PERFORM TICKS
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 from the fourth tick on the alpha is 1 (16 sixteenths)" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-ALPHA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No template: the base and addition helpers show nothing; with the netherite template they list the base and addition icons.
     MOVE 2 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 without a template the base slot helper has no icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ALPHA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BX-COUNT(1)
     MOVE WS-ITEM TO BX-ITEM(1)
     MOVE 1 TO WS-N
     PERFORM TICKS
     MOVE "T" TO TL-MODE
     MOVE 2 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 a netherite upgrade template in slot 0: the base slot starts at the helmet" TO TL-CASE
     MOVE "helmet" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 and the addition slot shows the ingot (a list of one never transitions)" TO TL-CASE
     MOVE "ingot" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Slot 0 holds the template: nothing is drawn there (the slot has an item).
     MOVE 1 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 a slot that holds an item shows no hint icon" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An armor trim template (any other _smithing_template): the armor lists; 30 ticks give the chestplate; a different menu does nothing.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-I WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-PATH = "coast_armor_trim_smithing_template"
             MOVE WS-I TO BX-ITEM(1)
         END-IF
     END-PERFORM
     MOVE 0 TO BX-COUNT(2)
     MOVE 30 TO WS-N
     PERFORM TICKS
     MOVE 2 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 an armor trim template: after 30 more ticks the base slot shows the chestplate" TO TL-CASE
     MOVE "chestplate" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-I
     CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-I WS-ICON WS-ALPHA
     MOVE "acceptance US12 40-3§5.6 and the addition slot the redstone dust (second of the seven)" TO TL-CASE
     MOVE "redstone_dust" TO TL-EXPECTED
     MOVE WS-ICON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The drawing: sprite widgets for the hint icons at (left + 8 + 18 h, top + 48), 16 x 16, the previous icon first while transitioning.
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 1 TO BX-COUNT(1)
     MOVE 0 TO BX-COUNT(2) BX-COUNT(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 0 TO CY-LIST(WS-I) CY-TICK(WS-I) CY-INDEX(WS-I)
     END-PERFORM
     MOVE 1 TO CY-LIST(1)
     MOVE 31 TO CY-TICK(1)
     MOVE 1 TO CY-INDEX(1)
     MOVE 0 TO BX-COUNT(1)
     MOVE 21 TO BM-TYPE
     MOVE 100 TO WS-D1
     MOVE 50 TO WS-D2
     CALL "SMITH-CYCLE-DRAW" USING CLIENT-STATE WS-D1 WS-D2
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         MOVE SM-W-ARG(WS-I) TO WS-E1
         MOVE SM-W-X(WS-I) TO WS-E2
         MOVE SM-W-Y(WS-I) TO WS-E3
         MOVE SM-W-STATE(WS-I) TO WS-E4
         STRING "r" FUNCTION TRIM(WS-E1) "@" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-3§5.6 one tick into a transition (counter 31) slot 0 draws the previous icon (armor trim template, row 129) at alpha 3 / 4 first (state 251), then the current (netherite template, row 130) at alpha 1 / 4 (state 751)" TO TL-CASE
     MOVE "r129@108:98/251 r130@108:98/751 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 8 TO BM-TYPE
     MOVE 2 TO WS-I
     MOVE 1 TO CY-TICK(2)
     CALL "SMITH-CYCLE-TICK" USING CLIENT-STATE
     MOVE "acceptance US12 40-3§5.6 another menu type does not tick the helpers" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CY-TICK(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TICKS.
     PERFORM WS-N TIMES
         CALL "SMITH-CYCLE-TICK" USING CLIENT-STATE
     END-PERFORM
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

 END PROGRAM TEST-SMITH-CYCLE.

 COPY CLTEST.
