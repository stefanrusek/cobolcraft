*> Test US12-client (spec 002, deferred part of T3216 to T3229; docs/protocol/40-menus-3-anvil-grindstone-smithing.md sections 3.7 and 3.8): the anvil name field at GUI 320 x 240 (left 72,
*> top 37). The field (text origin (left + 62, top + 24), background (left + 59, top + 20) 110 x 16, max length 50) is editable exactly when slot 0 has an item; a change of the left item sets
*> the field to the item's name and its responder sends Rename Item (05c 0x31, one string) when the name differs from the one last sent ("" when the text equals the default name);
*> typed characters (no section sign, no control character) and Backspace edit it; a name over 50 is neither typed nor sent; the inventory key types into the focused field instead of closing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-3-ANVIL.
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
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CID                 BINARY-LONG VALUE 9.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-TEXT                PIC X(1024).
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LONG                PIC X(256).
 01 WS-LONG-LENGTH         BINARY-LONG.
 01 WS-HEXDIGITS           PIC X(16) VALUE "0123456789abcdef".
 01 WS-HEX                 PIC XX.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 12 TIMES.
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
     MOVE 8 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 2 TO WS-ID
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ID WS-NAME WS-NAME-LENGTH
*>   The field is not editable with an empty slot 0: typed text is dropped and nothing is sent.
     PERFORM DRAIN
     MOVE 1 TO WS-N
     MOVE 97 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.8 anvil: with an empty slot 0 the field is not editable: typed text is dropped and nothing is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-3§3.8 anvil: the disabled field holds no text" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE AN-NAME-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     PERFORM FIELD-LIST
     MOVE "acceptance US12 40-3§3.8 anvil: the disabled field background (the disabled sprite) 110 x 16 at (left + 59, top + 20) = (131, 57), swatch panel (2), and no text" TO TL-CASE
     MOVE "overlay 131:57:110x16:2 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An item in slot 0: the field takes the item's name and Rename Item is sent with "" (the text equals the default name).
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.8 anvil: a new item in slot 0 sets the field to the default name and sends Rename Item (31) with the empty name (00)" TO TL-CASE
     MOVE "3100" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-3§3.8 anvil: the field text is the item's name" TO TL-CASE
     MOVE WS-NAME(1:WS-NAME-LENGTH) TO TL-EXPECTED
     MOVE AN-NAME(1:AN-NAME-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIELD-LIST
     MOVE SPACES TO TL-EXPECTED
     STRING "overlay 131:57:110x16:7 label 134:61:" WS-NAME(1:WS-NAME-LENGTH) " " DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-3§3.8 anvil: the enabled field background 110 x 16 at (131, 57), swatch black (7), and the text at (left + 62, top + 24) = (134, 61)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Typing one character: Rename Item with the whole text (length byte = default length + 1).
     MOVE 1 TO WS-N
     MOVE 33 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     PERFORM DRAIN
     COMPUTE WS-K = WS-NAME-LENGTH + 1
     PERFORM HEX2
     MOVE "acceptance US12 40-3§3.8 anvil: typing one character sends Rename Item with the default name and that character" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "31" WS-HEX DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Backspace back to the default name: the text equals the default, so the name is "" again.
     MOVE 1 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-BACKSPACE TO WS-A(1)
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.8 anvil: Backspace back to the default name sends the empty name (3100)" TO TL-CASE
     MOVE "3100" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Clear the field with Backspace, then type Excalibur in one frame.
     PERFORM UNTIL AN-NAME-LENGTH = 0
         MOVE 1 TO WS-N
         MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
         MOVE CC-KEY-BACKSPACE TO WS-A(1)
         PERFORM FRAME
     END-PERFORM
     PERFORM DRAIN
     MOVE 9 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4) WS-KIND(5) WS-KIND(6) WS-KIND(7) WS-KIND(8) WS-KIND(9)
     MOVE 69 TO WS-A(1)
     MOVE 120 TO WS-A(2)
     MOVE 99 TO WS-A(3)
     MOVE 97 TO WS-A(4)
     MOVE 108 TO WS-A(5)
     MOVE 105 TO WS-A(6)
     MOVE 98 TO WS-A(7)
     MOVE 117 TO WS-A(8)
     MOVE 114 TO WS-A(9)
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.8 anvil: typing Excalibur sends Rename Item (31) with the string: 09 and its 9 bytes (worked example E2)" TO TL-CASE
     MOVE "3109457863616c69627572" TO TL-EXPECTED
     MOVE WS-TEXT(1:22) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same name is not sent again; a section sign is not typed.
     MOVE 1 TO WS-N
     MOVE 167 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.7 anvil: a section sign is not typed (the filter removes it): no packet and the text stays Excalibur" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "-" AN-NAME(1:AN-NAME-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-Excalibur" TO TL-EXPECTED
     IF WS-TEXT(1:4) NOT = SPACES
         MOVE "-sent" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A control character (7) is not typed either.
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 31 TO WS-A(1)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.7 anvil: a control character (31) is not typed" TO TL-CASE
     MOVE "Excalibur" TO TL-EXPECTED
     MOVE AN-NAME(1:AN-NAME-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Set Rename Item directly: the same name is not sent twice; 51 characters are rejected.
     MOVE SPACES TO WS-LONG
     MOVE "Excalibur" TO WS-LONG
     MOVE 9 TO WS-LONG-LENGTH
     CALL "ANVIL-NAME-SET" USING CLIENT-STATE WS-LONG WS-LONG-LENGTH
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.7 anvil: setItemName with the name already sent returns false: nothing is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The filter of setItemName: the section sign (C2 A7), a newline and a byte 127 are removed.
     MOVE SPACES TO WS-LONG
     MOVE X"41C2A7420A43" TO WS-LONG(1:6)
     MOVE 6 TO WS-LONG-LENGTH
     CALL "ANVIL-NAME-SET" USING CLIENT-STATE WS-LONG WS-LONG-LENGTH
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.7 anvil: setItemName removes the section sign and the newline: A, section sign, B, newline, C is sent as ABC (31 03 414243)" TO TL-CASE
     MOVE "3103414243" TO TL-EXPECTED
     MOVE WS-TEXT(1:10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-LONG
     MOVE ALL "a" TO WS-LONG(1:51)
     MOVE 51 TO WS-LONG-LENGTH
     CALL "ANVIL-NAME-SET" USING CLIENT-STATE WS-LONG WS-LONG-LENGTH
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.7 anvil: a 51-character name is rejected and no packet is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-LONG-LENGTH
     CALL "ANVIL-NAME-SET" USING CLIENT-STATE WS-LONG WS-LONG-LENGTH
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.7 anvil: a 50-character name is accepted: Rename Item with length 50 (0x32)" TO TL-CASE
     MOVE "3132" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "a" TO WS-LONG(51:1)
     MOVE "N" TO TL-MODE
*>   The field's own limit is 50: typing a 51st unit is ignored.
     MOVE 50 TO AN-NAME-LENGTH
     MOVE ALL "a" TO AN-NAME(1:50)
     MOVE 1 TO WS-N
     MOVE 98 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.8 anvil: the field holds at most 50 characters (max length 50)" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE AN-NAME-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   A character outside the BMP is 4 bytes and 2 UTF-16 units: with 49 characters it does not fit (49 + 2 > 50), a plain one does.
     MOVE ALL "a" TO AN-NAME(1:49)
     MOVE 49 TO AN-NAME-LENGTH
     MOVE 1 TO WS-N
     MOVE 128512 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.8 anvil: a 4-byte character counts 2 code units: with 49 characters it is not typed" TO TL-CASE
     MOVE 49 TO TL-EXPECTED-N
     MOVE AN-NAME-LENGTH TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 48 TO AN-NAME-LENGTH
     MOVE 1 TO WS-N
     MOVE 128512 TO WS-A(1)
     MOVE CC-EV-TEXT TO WS-KIND(1)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.8 anvil: with 48 characters the 4-byte character fits (48 + 2 = 50): 52 bytes" TO TL-CASE
     MOVE 52 TO TL-EXPECTED-N
     MOVE AN-NAME-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   The responder does nothing with an empty slot 0 (no packet).
     MOVE 0 TO BX-COUNT(1)
     PERFORM DRAIN
     CALL "ANVIL-RESPOND" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "acceptance US12 40-3§3.8 anvil: onNameChanged with no item in slot 0 returns at once: nothing is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BX-COUNT(1)
*>   Keys: the inventory key types into the focused field (editable) and does not close; Escape closes.
     MOVE 2 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-E TO WS-A(2)
     PERFORM FRAME
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-3§3.8 anvil: with an item in slot 0 the inventory key does not close the screen (the focused field consumes input)" TO TL-CASE
     MOVE SCR-CONTAINER TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BX-COUNT(1)
     MOVE 2 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-E TO WS-A(2)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.8 anvil: with an empty slot 0 the field cannot consume input: the inventory key closes the screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO WS-CID
     MOVE 8 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE 2 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-ESCAPE TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-ESCAPE TO WS-A(2)
     PERFORM FRAME
     MOVE "acceptance US12 40-3§3.8 anvil: Escape closes the container" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A reopened anvil is a new menu (a new container id): itemName is null again (the first name sent, even "", goes out).
     ADD 1 TO WS-CID
     MOVE 8 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     PERFORM DRAIN
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM DRAIN
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-3§3.7 anvil: a reopened anvil starts with itemName null: the default name goes out again as the empty name" TO TL-CASE
     MOVE "3100" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> One frame with the first WS-N events of WS-EVENTS.
 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

 DRAIN.
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .

*> WS-K (0 to 255) as two lowercase hex digits WS-HEX.
 HEX2.
     COMPUTE WS-HI = WS-K / 16
     COMPUTE WS-LO = FUNCTION MOD(WS-K, 16)
     MOVE WS-HEXDIGITS(WS-HI + 1:1) TO WS-HEX(1:1)
     MOVE WS-HEXDIGITS(WS-LO + 1:1) TO WS-HEX(2:1)
     .

*> The field's widgets: each overlay of 110 x 16 as "overlay x:y:wxh:swatch " and each label from y 61 as "label x:y:text ", into TL-OBSERVED; TL-EXPECTED is cleared.
 FIELD-LIST.
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 110 AND SM-W-H(WS-I) = 16
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-ARG(WS-I) TO WS-E3
             STRING "overlay " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":110x16:" FUNCTION TRIM(WS-E3) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-Y(WS-I) = 61
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING "label " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 OPEN-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE WS-CID TO WS-ID
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

 END PROGRAM TEST-SCREEN-40-3-ANVIL.

 COPY CLTEST.
