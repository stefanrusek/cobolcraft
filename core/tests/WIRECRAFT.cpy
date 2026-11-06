*> contract_wire_server.cob crafting cases (test infrastructure; task T550;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Crafting rows and the Recipe Book Add fixture note;
*> standin-content §13). Clientbound Recipe Book Add equals the core's builder output for the
*> fixture's stated inputs: a player whose inventory holds only 4 greystone in one slot.
*> Serverbound Place Recipe decodes with PLAY-DECODE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CRAFT-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-EDIT5               PIC -(9)9.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-27-place-recipe decodes: container 0, recipe display "
         & "id 0, use max items false" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-27-place-recipe.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     MOVE PSB-CONTAINER TO WS-EDIT3
     MOVE PSB-RECIPE TO WS-EDIT4
     MOVE PSB-USE-MAX TO WS-EDIT5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " container "
         FUNCTION TRIM(WS-EDIT3) " recipe " FUNCTION TRIM(WS-EDIT4) " use max "
         FUNCTION TRIM(WS-EDIT5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "39 0 container 0 recipe 0 use max 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-4b-recipe-book-add equals the core's Recipe Book Add "
         & "for a player whose inventory holds only 4 greystone (craftable: display id 0 only)"
         TO TL-CASE
     INITIALIZE PL-ENTRY(WS-ROW)
     MOVE 1 TO PL-USED(WS-ROW)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 13)
     MOVE 4 TO PL-SLOT-COUNT(WS-ROW, 13)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CRAFT-BOOK-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-4b-recipe-book-add.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-CRAFT-CASES.
