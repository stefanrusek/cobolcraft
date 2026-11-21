*> The anvil name field (docs/protocol/40-menus-3-anvil-grindstone-smithing.md sections 3.7 and 3.8): the field text AN-NAME (slot 0 has an item = editable), the responder that sends
*> Rename Item (05c 0x31) and the typing. MENU-EXTRA-INPUT calls ANVIL-INPUT each frame of an open anvil (menu type 8); MENU-DECOR draws the field.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-RENAME-ITEM.
*> USING PB-BUFFER, name (PIC X(256), UTF-8), byte length: Rename Item (05c 0x31), one string (at most 32767 characters).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 49.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-TEXT                PIC X(1024).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TEXT L-LENGTH.
     MOVE SPACES TO WS-TEXT
     IF L-LENGTH > 0
         MOVE L-TEXT(1:L-LENGTH) TO WS-TEXT
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-TEXT L-LENGTH WS-MAX
     GOBACK.
 END PROGRAM CLP-RENAME-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-UNITS.
*> USING text (PIC X(256)), byte length, units out: the length in UTF-16 code units: one per character, two for a 4-byte one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-UNITS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-UNITS.
     MOVE 0 TO L-UNITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-B = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         EVALUATE TRUE
             WHEN WS-B >= 240
                 ADD 2 TO L-UNITS
             WHEN WS-B < 128 OR WS-B >= 192
                 ADD 1 TO L-UNITS
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM ANVIL-UNITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-NAME-SET.
*> USING CLIENT-STATE, name (PIC X(256), UTF-8), byte length: 3.7 setItemName and the send of 3.8: the name is filtered (no section sign, no byte below 32, no 127); over 50 code
*> units it is rejected; the name already sent changes nothing; else it is kept as the last sent and Rename Item is sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1100.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-V                   PIC X(256).
 01 WS-V-LENGTH            BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE SPACES TO WS-V
     MOVE 0 TO WS-V-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-B = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         MOVE 0 TO WS-NEXT
         IF WS-I < L-LENGTH
             COMPUTE WS-NEXT = FUNCTION ORD(L-TEXT(WS-I + 1:1)) - 1
         END-IF
         EVALUATE TRUE
             WHEN WS-B < 32 OR WS-B = 127
                 CONTINUE
             WHEN WS-B = 194 AND WS-NEXT = 167
                 ADD 1 TO WS-I
             WHEN OTHER
                 ADD 1 TO WS-V-LENGTH
                 MOVE L-TEXT(WS-I:1) TO WS-V(WS-V-LENGTH:1)
         END-EVALUATE
     END-PERFORM
     CALL "ANVIL-UNITS" USING WS-V WS-V-LENGTH WS-UNITS
     IF WS-UNITS > 50
         GOBACK
     END-IF
     IF AN-SENT-NULL = 0 AND AN-SENT-LENGTH = WS-V-LENGTH
         IF WS-V-LENGTH = 0 OR AN-SENT(1:AN-SENT-LENGTH) = WS-V(1:WS-V-LENGTH)
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO AN-SENT-NULL
     MOVE WS-V TO AN-SENT
     MOVE WS-V-LENGTH TO AN-SENT-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-RENAME-ITEM" USING PB-BUFFER WS-V WS-V-LENGTH
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM ANVIL-NAME-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-RESPOND.
*> USING CLIENT-STATE: 3.8 onNameChanged: nothing when slot 0 has no item; the name is the field text, "" when it equals the item's default name; then setItemName.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HOVER               PIC X(512).
 01 WS-HOVER-LENGTH        BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BX-COUNT(1) = 0
         GOBACK
     END-IF
     CALL "RK-ITEM-NAME" USING CLIENT-STATE BX-ITEM(1) WS-HOVER WS-HOVER-LENGTH
     MOVE AN-NAME TO WS-NAME
     MOVE AN-NAME-LENGTH TO WS-LENGTH
     IF AN-NAME-LENGTH = WS-HOVER-LENGTH AND AN-NAME(1:AN-NAME-LENGTH) = WS-HOVER(1:WS-HOVER-LENGTH)
         MOVE SPACES TO WS-NAME
         MOVE 0 TO WS-LENGTH
     END-IF
     CALL "ANVIL-NAME-SET" USING CLIENT-STATE WS-NAME WS-LENGTH
*>   3.3 createResult, the part this client can compute (the server's Set Container Slot and Set Container Data overwrite it): with an empty right slot (rename only, steps 4, 11 to 14) a non-blank name
*>   that differs from the default gives a copy of the left stack and the cost 1; a blank name gives no result and cost 0 (the client keeps no custom_name to remove). A right stack is the server's.
     IF BX-COUNT(2) = 0
         IF WS-LENGTH > 0
             MOVE BX-ITEM(1) TO BX-ITEM(3)
             MOVE BX-COUNT(1) TO BX-COUNT(3)
             MOVE BX-DAMAGE(1) TO BX-DAMAGE(3)
             MOVE 1 TO BM-DATA(1)
         ELSE
             MOVE 0 TO BX-ITEM(3) BX-COUNT(3) BX-DAMAGE(3)
             MOVE 0 TO BM-DATA(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ANVIL-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-INPUT.
*> USING CLIENT-STATE: an anvil is a new menu per opening (the field and the name sent are reset when the container id changes); a changed item in slot 0 sets the field to its default
*> name (empty without an item) and runs the responder; an editable field (slot 0 has an item) takes the frame's typed characters (no section sign, nothing below 32 or 127, at most 50
*> code units) and Backspace, each change running the responder once per frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-CHANGED             BINARY-LONG.
 01 WS-HOVER               PIC X(512).
 01 WS-HOVER-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF AN-ID NOT = BM-ID
         MOVE BM-ID TO AN-ID
         MOVE -1 TO AN-ITEM
         MOVE 0 TO AN-NAME-LENGTH AN-SENT-LENGTH
         MOVE 1 TO AN-SENT-NULL
         MOVE SPACES TO AN-NAME AN-SENT
     END-IF
     MOVE -1 TO WS-ITEM
     IF BX-COUNT(1) > 0
         MOVE BX-ITEM(1) TO WS-ITEM
     END-IF
     IF WS-ITEM NOT = AN-ITEM
         MOVE WS-ITEM TO AN-ITEM
         MOVE SPACES TO AN-NAME
         MOVE 0 TO AN-NAME-LENGTH
         IF WS-ITEM >= 0
             CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-HOVER WS-HOVER-LENGTH
             MOVE WS-HOVER(1:WS-HOVER-LENGTH) TO AN-NAME
             MOVE WS-HOVER-LENGTH TO AN-NAME-LENGTH
             CALL "ANVIL-RESPOND" USING CLIENT-STATE
         END-IF
     END-IF
     IF BX-COUNT(1) > 0
         MOVE 0 TO WS-CHANGED
         CALL "ANVIL-UNITS" USING AN-NAME AN-NAME-LENGTH WS-UNITS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) NOT = 127 AND IN-TEXT(WS-I) NOT = 167
                 CALL "UTF8-ENCODE" USING IN-TEXT(WS-I) WS-BYTES WS-COUNT
                 MOVE 1 TO WS-ADD
                 IF WS-COUNT = 4
                     MOVE 2 TO WS-ADD
                 END-IF
                 IF WS-UNITS + WS-ADD <= 50
                     MOVE WS-BYTES(1:WS-COUNT) TO AN-NAME(AN-NAME-LENGTH + 1:WS-COUNT)
                     ADD WS-COUNT TO AN-NAME-LENGTH
                     ADD WS-ADD TO WS-UNITS
                     MOVE 1 TO WS-CHANGED
                 END-IF
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND AN-NAME-LENGTH > 0
             CALL "TEXT-DROP-LAST" USING AN-NAME AN-NAME-LENGTH
             MOVE 1 TO WS-CHANGED
         END-IF
         IF WS-CHANGED = 1
             CALL "ANVIL-RESPOND" USING CLIENT-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ANVIL-INPUT.
