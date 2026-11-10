*> contract_wire_server.cob block and inventory cases (test infrastructure; tasks T429, T430;
*> docs/protocol/09-cobolcraft-profile.md §3.2, §3.4 rule 3). Serverbound Player Action (start,
*> abort and stop destroy), Use Item On, Set Carried Item, Container Click and Set Creative Mode Slot
*> decode with PLAY-DECODE to their stated values. Clientbound Block Update, Section Blocks Update,
*> Block Changed Ack, Block Destruction, Container Set Slot, Set Held Slot and Light Update equal the
*> core's builder output for each fixture's stated inputs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-BLOCK-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CHANGED             PIC X(24).
 01 WS-ENTRIES.
    05 WS-ENTRY OCCURS 3 TIMES.
       10 WS-EX            BINARY-LONG.
       10 WS-EY            BINARY-LONG.
       10 WS-EZ            BINARY-LONG.
       10 WS-ES            BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-29-player-action-start-destroy decodes: action 0, block "
         & "(4, 53, 8), face 1, sequence 1" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-start-destroy.hex" TO WS-PATH
     MOVE "41 0 action 0 at 4 53 8 face 1 seq 1" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-29-player-action-abort-destroy decodes: action 2, block "
         & "(4, 53, 8), face 1, sequence 2" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-abort-destroy.hex" TO WS-PATH
     MOVE "41 0 action 2 at 4 53 8 face 1 seq 2" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-29-player-action-stop-destroy decodes: action 3, block "
         & "(4, 53, 8), face 1, sequence 3" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-stop-destroy.hex" TO WS-PATH
     MOVE "41 0 action 3 at 4 53 8 face 1 seq 3" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-42-use-item-on decodes: main hand, block (4, 53, 8), "
         & "face 1, cursor (0.5, 1.0, 0.5), not inside, no border hit, sequence 4" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-42-use-item-on.hex" TO WS-PATH
     MOVE "66 0 hand 0 at 4 53 8 face 1 cursor 0.50 1.00 0.50 inside 0 border 0 seq 4"
         TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-36-set-carried-item decodes: slot 3" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-36-set-carried-item.hex" TO WS-PATH
     MOVE "54 0 slot 3" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-12-container-click decodes: container 0, state id 1, "
         & "slot 0, button 0, PICKUP, changed {0: empty}, carried 64 x item 2" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-12-container-click.hex" TO WS-PATH
     MOVE "18 0 container 0 state 1 slot 0 button 0 type 0 changed 1 [0 0x0] carried 2x64"
         TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-39-set-creative-mode-slot decodes: slot 9, 64 x item 7"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-39-set-creative-mode-slot.hex" TO WS-PATH
     MOVE "57 0 slot 9 stack 7x64" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-08-block-update equals the core's Block Update of "
         & "(8, 59, 8) to state 14" TO TL-CASE
     MOVE 8 TO WS-X WS-Z
     MOVE 59 TO WS-Y
     MOVE 14 TO WS-STATE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-UPDATE-BUILD" USING WS-X WS-Y WS-Z WS-STATE PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-08-block-update.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-56-section-blocks-update equals the core's Section "
         & "Blocks Update of section (0, 3, 0): (8, 11, 8) 14, (9, 7, 8) 15, (8, 12, 8) 11"
         TO TL-CASE
     MOVE 8 TO WS-EX(1) WS-EZ(1) WS-EZ(2) WS-EX(3) WS-EZ(3)
     MOVE 11 TO WS-EY(1)
     MOVE 14 TO WS-ES(1)
     MOVE 9 TO WS-EX(2)
     MOVE 7 TO WS-EY(2)
     MOVE 15 TO WS-ES(2)
     MOVE 12 TO WS-EY(3)
     MOVE 11 TO WS-ES(3)
     MOVE 0 TO WS-X WS-Z
     MOVE 3 TO WS-Y WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "SECTION-BLOCKS-UPDATE-BUILD" USING WS-X WS-Y WS-Z WS-COUNT WS-ENTRIES PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-56-section-blocks-update.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-04-block-changed-ack equals the core's Block Changed "
         & "Ack of sequence 7" TO TL-CASE
     MOVE 7 TO WS-NUM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-ACK-BUILD" USING WS-NUM PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-04-block-changed-ack.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-05-block-destruction equals the core's Block "
         & "Destruction by entity 1 of (5, 53, 8) at stage 3" TO TL-CASE
     MOVE 1 TO WS-NUM
     MOVE 5 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-STATE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-DESTRUCTION-BUILD" USING WS-NUM WS-X WS-Y WS-Z WS-STATE PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-05-block-destruction.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-14-container-set-slot equals the core's Container Set "
         & "Slot of container 0, state id 2, slot 0, 63 x item 2" TO TL-CASE
     MOVE 2 TO WS-NUM
     MOVE 0 TO WS-SLOT
     MOVE 63 TO PB-IS-COUNT
     MOVE 2 TO PB-IS-ITEM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONTAINER-SET-SLOT-BUILD" USING WS-ZERO WS-NUM WS-SLOT PB-ITEMSTACK PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-6b-set-held-slot equals the core's Set Held Slot 0 "
         & "(US4 inventory)" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-HELD-SLOT-BUILD" USING WS-ZERO PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-31-light-update equals the core's Light Update of chunk "
         & "(0, 0) of cobolcraft:main after the marker glowtube (8, 59, 8) is toggled off, "
         & "sections 3 and 4" TO TL-CASE
     MOVE 0 TO WS-X WS-Z
     CALL "WORLD-CHUNK" USING WS-DIM WS-X WS-Z WS-ROW
     MOVE 8 TO WS-X WS-Z
     MOVE 59 TO WS-Y
     MOVE 14 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "000110000000000000000000" TO WS-CHANGED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "LIGHT-UPDATE-BUILD" USING WS-ROW WS-CHANGED PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-31-light-update.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-BLOCK-CASES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIREBLOCK-DECODE-CASE.
*> USING fixture path, scratch PB-BUFFER, TESTLIB-ASSERT (TL-CASE and TL-EXPECTED set): loads the
*> fixture, reads the packet id and decodes the rest with PLAY-DECODE. Observed text: packet id,
*> outcome, then the fields that packet has.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PLAYPKT.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT-REAL           PIC -(6)9.99.
 LINKAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH PB-BUFFER TESTLIB-ASSERT.
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED POINTER WS-PTR
     IF WS-PACKET-ID = 41
         MOVE PSB-ACTION TO WS-EDIT
         STRING " action " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 66
         MOVE PSB-HAND TO WS-EDIT
         STRING " hand " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 41 OR WS-PACKET-ID = 66
         MOVE PSB-BX TO WS-EDIT
         MOVE PSB-BY TO WS-EDIT2
         MOVE PSB-BZ TO WS-EDIT3
         STRING " at " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " "
             FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PSB-FACE TO WS-EDIT
         STRING " face " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 66
         MOVE PSB-CURSOR-X TO WS-EDIT-REAL
         STRING " cursor " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-CURSOR-Y TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-CURSOR-Z TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-INSIDE TO WS-EDIT
         MOVE PSB-BORDER TO WS-EDIT2
         STRING " inside " FUNCTION TRIM(WS-EDIT) " border " FUNCTION TRIM(WS-EDIT2)
             DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 41 OR WS-PACKET-ID = 66
         MOVE PSB-SEQUENCE TO WS-EDIT
         STRING " seq " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 18
         MOVE PSB-CONTAINER TO WS-EDIT
         MOVE PSB-STATE-ID TO WS-EDIT2
         STRING " container " FUNCTION TRIM(WS-EDIT) " state " FUNCTION TRIM(WS-EDIT2)
             DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 18 OR WS-PACKET-ID = 54 OR WS-PACKET-ID = 57
         MOVE PSB-SLOT TO WS-EDIT
         STRING " slot " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 18
         MOVE PSB-BUTTON TO WS-EDIT
         MOVE PSB-CLICK-TYPE TO WS-EDIT2
         MOVE PSB-CHANGED-COUNT TO WS-EDIT3
         STRING " button " FUNCTION TRIM(WS-EDIT) " type " FUNCTION TRIM(WS-EDIT2) " changed "
             FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-CHANGED-COUNT
             MOVE PSB-CHANGED-SLOT(WS-I) TO WS-EDIT
             MOVE PSB-CHANGED-ITEM(WS-I) TO WS-EDIT2
             MOVE PSB-CHANGED-AMOUNT(WS-I) TO WS-EDIT3
             STRING " [" FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT3) "]" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-PERFORM
         MOVE PSB-CARRIED-ITEM TO WS-EDIT
         MOVE PSB-CARRIED-COUNT TO WS-EDIT2
         STRING " carried " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2)
             DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 57
         MOVE PSB-STACK-ITEM TO WS-EDIT
         MOVE PSB-STACK-COUNT TO WS-EDIT2
         STRING " stack " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2)
             DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM WIREBLOCK-DECODE-CASE.
