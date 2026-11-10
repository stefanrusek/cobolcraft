*> contract_wire_server.cob recipe and container cases (test infrastructure; docs/protocol/05a 0x12, 05b 0x4B, 05c 0x27;
*> 27 section 4.4; 13 section 3.5): Place Recipe (cobolcraft and standard menus) decodes with PLAY-DECODE; the empty
*> replacing Recipe Book Add equals the core's RECBOOK-BUILD of a player who knows nothing; the crafting bench Container
*> Set Content equals PLAY-CONTENT-BUILD of the stated bench menu; the 46-slot inventory fixture is read up to its first
*> component-bearing slot (BLOCKED, see the case). The cobolcraft-shaped play-s2c-4b-recipe-book-add fixture belongs to
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

     MOVE "contract wire server play-s2c-12-container-set-content-46-slots reads: container 0, state 3, 46 "
         & "slots, 64 x item 1 at slot 36 (the stacks before the component-bearing slot 40)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-46-slots.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A1
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A2
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A3
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-A1 TO WS-EDIT
     MOVE WS-A2 TO WS-EDIT2
     MOVE WS-A3 TO WS-EDIT3
     STRING "container " FUNCTION TRIM(WS-EDIT) " state " FUNCTION TRIM(WS-EDIT2) " slots "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
*>   Slot 40 carries a data component patch (a damaged, named stone) that the item stack record has no field for:
*>   the stacks before it are read, the rest of the packet is not (BLOCKED: components in PB-ITEMSTACK).
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 39
         CALL "PB-GET-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
         IF WS-I = 36
             MOVE PB-IS-COUNT TO WS-EDIT
             MOVE PB-IS-ITEM TO WS-EDIT2
             MOVE WS-I TO WS-EDIT4
             STRING FUNCTION TRIM(TL-OBSERVED) " s" FUNCTION TRIM(WS-EDIT4) "=" FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE PB-ERROR TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " error " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "container 0 state 3 slots 46 s36=1x64 error 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-CRAFT-CASES.
