*> contract_wire_server.cob recipe and container cases (test infrastructure; docs/protocol/05a 0x12, 05b 0x4B, 05c 0x27;
*> 27 section 4.4; 13 section 3.5): Place Recipe (cobolcraft and standard menus) decodes with PLAY-DECODE; the empty
*> replacing Recipe Book Add equals the core's RECBOOK-BUILD of a player who knows nothing; the crafting bench Container
*> Set Content equals PLAY-CONTENT-BUILD of the stated bench menu; the 46-slot inventory fixture and the component Container Set Slot fixture
*> equal the core's builders over the stack patch pool (T3652). The cobolcraft-shaped play-s2c-4b-recipe-book-add fixture belongs to
*> the 001 recipe book (one display per ingredient line with counts) and is no longer a core output.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CRAFT-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 COPY PLAYPKT.
 COPY CMENU.
 COPY RECBOOK.
 COPY CSTACK.
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
 01 WS-REPLACE             BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-A3                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-A4                  BINARY-LONG.
 01 WS-NAME                PIC X(64).
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

     MOVE "contract wire server play-c2s-27-place-recipe-standard decodes: container 2, recipe display "
         & "id 300, use max items true" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-27-place-recipe-standard.hex" TO WS-PATH
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
     MOVE "39 0 container 2 recipe 300 use max 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-4b-recipe-book-add-standard-replace-empty equals the core's Recipe "
         & "Book Add (replace) of a player who knows no recipe" TO TL-CASE
     INITIALIZE PL-ENTRY(WS-ROW)
     CALL "RECBOOK-RESET" USING WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-REPLACE
     CALL "RECBOOK-BUILD" USING WS-ROW WS-REPLACE PB-BUFFER WS-TOTAL
     MOVE "contract/fixtures/wire/play-s2c-4b-recipe-book-add-standard-replace-empty.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-12-container-set-content-crafting-bench equals the core's Container "
         & "Set Content of the bench menu 1 (state 1, result 1 x item 62, grid cells 1 and 5 one item 63, first "
         & "hotbar slot 64 x item 1)" TO TL-CASE
     INITIALIZE PL-ENTRY(WS-ROW)
     INITIALIZE MN-ENTRY(WS-ROW)
     MOVE 1 TO PL-USED(WS-ROW) MN-WINDOW(WS-ROW) MN-STATE-ID(WS-ROW)
     MOVE 12 TO MN-TYPE(WS-ROW)
     MOVE 62 TO MN-RESULT-ITEM(WS-ROW)
     MOVE 1 TO MN-RESULT-COUNT(WS-ROW)
     MOVE 63 TO MN-BGRID-ITEM(WS-ROW, 1) MN-BGRID-ITEM(WS-ROW, 5)
     MOVE 1 TO MN-BGRID-COUNT(WS-ROW, 1) MN-BGRID-COUNT(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-crafting-bench.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     INITIALIZE PL-ENTRY(WS-ROW)
     INITIALIZE MN-ENTRY(WS-ROW)

     MOVE "contract wire server play-s2c-12-container-set-content-46-slots equals the core's Container Set Content "
         & "(state 3, 64 x item 1 at slot 36, the damaged named stone at slot 40, off-hand, cursor)" TO TL-CASE
     PERFORM STONE-PATCH
     INITIALIZE PL-ENTRY(WS-ROW)
     INITIALIZE MN-ENTRY(WS-ROW)
     MOVE 1 TO PL-USED(WS-ROW)
     MOVE 3 TO PL-STATE-ID(WS-ROW)
     MOVE 1 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE WS-A4 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 62 TO MN-EQUIP-ITEM(WS-ROW, 5)
     MOVE 1 TO MN-EQUIP-COUNT(WS-ROW, 5)
     MOVE 63 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 5 TO PL-CARRIED-COUNT(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-46-slots.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     INITIALIZE PL-ENTRY(WS-ROW)
     INITIALIZE MN-ENTRY(WS-ROW)

     MOVE "contract wire server play-s2c-14-container-set-slot-components equals the core's Container Set Slot of "
         & "container 0, state 5, slot 36 holding the damaged, named stone" TO TL-CASE
     PERFORM STONE-PATCH
     MOVE 1 TO WS-A1 WS-TOTAL
     CALL "SP-EXPORT" USING WS-A1 WS-TOTAL WS-A4 PB-ITEMSTACK-X
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WS-A2
     MOVE 5 TO WS-A3
     MOVE 36 TO WS-A1
     CALL "CONTAINER-SET-SLOT-BUILD-X" USING WS-A2 WS-A3 WS-A1 PB-ITEMSTACK-X PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot-components.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server the component-bearing stack of play-s2c-14-container-set-slot-components reads back "
         & "as damage 5, name Hi, one removed component" TO TL-CASE
     CALL "SP-GET-DAMAGE" USING WS-A1 WS-A4 WS-A2
     CALL "SP-GET-NAME" USING WS-A4 WS-NAME WS-A3
     MOVE WS-A2 TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "damage " FUNCTION TRIM(WS-EDIT) " name " WS-NAME(1:WS-A3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "damage 5 name Hi" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

*>   The patch of the stone in play-s2c-14-container-set-slot-components: the handle in WS-A4.
 STONE-PATCH.
     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot-components.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A1
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A2
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A3
     CALL "PB-GET-SHORT" USING PB-BUFFER WS-A2
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     CALL "SP-INTERN" USING PB-ITEMSTACK-X WS-A4.
 END PROGRAM WIRE-CRAFT-CASES.
