*> Acceptance test, US12 furnace, smoker and blast furnace through the real play path (docs/protocol/31-block-entities-2 section 3, 40-menus-2 section 2,
*> 48-real-data-shapes sections 2.3, 4.6, 4.7; T0871 to T0874 wired): the content set is switched to the standard one with the context int providers
*> loaded from a fixture tree written here (the shapes of 48 section 4.6: div over a conditional on block/fast_cooking, numbers alone) and a
*> smelting, a smoking and a blasting recipe in the recipe store. A player places a furnace, opens it (Open Screen type 14, Container Set Content,
*> Container Set Data), shift-clicks raw iron into the input slot and coal into the fuel slot, and the ticks burn the coal (1600 ticks), light the
*> block, cook for 200 ticks and put an iron ingot in the result slot, which takes nothing by hand. The smoker (menu 22) and the blast furnace (menu 10)
*> burn the coal for half the time and cook at twice the speed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-FURNACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CONTENT.
 COPY CTRECIPE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-SAVE-TYPES          PIC X(20000).
 01 WS-SAVE-ROLES          PIC X(64).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-FURNACE             BINARY-LONG.
 01 WS-SMOKER              BINARY-LONG.
 01 WS-BLAST               BINARY-LONG.
 01 WS-COAL                BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-BEEF                BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-SPONGE              BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-A                   BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:test_tag".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SPEED-S             FLOAT-SHORT VALUE 2.
 01 WS-HUGE                BINARY-LONG VALUE 99999.
 01 WS-E1-N                BINARY-LONG.
 01 WS-E2-N                BINARY-LONG.
 01 WS-E3-N                BINARY-LONG.
 01 WS-E4-N                BINARY-LONG.
 01 WS-E5-N                BINARY-LONG.
 01 WS-NM                  PIC X(112).
 01 WS-NMLEN               BINARY-LONG.
 01 WS-STR                 PIC X(8).
 01 WS-STRLEN              BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-COMMAND             PIC X(4000).
 01 WS-DIRF                PIC X(1100) VALUE "build/furnace-fix/t".
 01 WS-STATUS              BINARY-LONG.
 01 WS-BURN                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-PAYLOAD             PIC X(2048).
 01 WS-LEN                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FAST                BINARY-LONG.
 01 WS-ROWNO               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-XP                  FLOAT-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-SRC                 BINARY-LONG.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     PERFORM SWITCH-CONTENT
     MOVE "stone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "furnace" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-FURNACE
     MOVE "smoker" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SMOKER
     MOVE "blast_furnace" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BLAST
     MOVE "coal" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-COAL
     MOVE "raw_iron" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-RAW
     MOVE "beef" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BEEF
     MOVE "iron_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
     MOVE "wet_sponge" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SPONGE
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
     MOVE "bucket" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BUCKET
     MOVE "water_bucket" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-WATER
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 furnace provider shapes: coal burns 1600 in a furnace and 800 in a smoker (div over a conditional on fast_cooking), the speed "
         & "is 1.0 and 2.0, an item without fuel burns 0" TO TL-CASE
     MOVE 0 TO WS-FAST
     CALL "FURN-FUEL" USING WS-COAL WS-FAST WS-BURN WS-SPEED
     MOVE WS-BURN TO WS-E1
     COMPUTE WS-E2 = WS-SPEED * 10
     MOVE 1 TO WS-FAST
     CALL "FURN-FUEL" USING WS-COAL WS-FAST WS-BURN WS-SPEED
     MOVE WS-BURN TO WS-E3
     COMPUTE WS-E4 = WS-SPEED * 10
     CALL "FURN-FUEL" USING WS-DIRT WS-FAST WS-BURN WS-SPEED
     MOVE WS-BURN TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1600 10 800 20 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace provider scanner: a number alone, a conditional alone, a div whose left or right is missing or zero, and text that "
         & "is none of them" TO TL-CASE
     MOVE 1 TO WS-FAST
     MOVE SPACES TO WS-PAYLOAD
     MOVE "  -3.5" TO WS-PAYLOAD
     MOVE 6 TO WS-LEN
     CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LEN WS-FAST WS-VALUE WS-OK
     COMPUTE WS-E1 = WS-VALUE * 10
     MOVE WS-OK TO WS-E2
     MOVE SPACES TO WS-PAYLOAD
     MOVE '{"type":"minecraft:conditional","condition":"minecraft:block/fast_cooking","on_false":"minecraft:cooking/normal_speed_multiplier",'
         & '"on_true":"minecraft:cooking/fast_speed_multiplier"}' TO WS-PAYLOAD
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAYLOAD)) TO WS-LEN
     CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LEN WS-FAST WS-VALUE WS-OK
     COMPUTE WS-E3 = WS-VALUE * 10
     MOVE SPACES TO WS-PAYLOAD
     MOVE '{"type":"minecraft:div","right":{"type":"minecraft:conditional"}}' TO WS-PAYLOAD
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAYLOAD)) TO WS-LEN
     CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LEN WS-FAST WS-VALUE WS-OK
     MOVE WS-OK TO WS-E4
     MOVE SPACES TO WS-PAYLOAD
     MOVE '{"type":"minecraft:div","left":5,"right":{"on_true":"minecraft:cooking/zero","on_false":"minecraft:cooking/zero"}}' TO WS-PAYLOAD
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAYLOAD)) TO WS-LEN
     CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LEN WS-FAST WS-VALUE WS-OK
     MOVE WS-OK TO WS-E5
     MOVE SPACES TO WS-PAYLOAD
     MOVE "   " TO WS-PAYLOAD
     MOVE 3 TO WS-LEN
     CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LEN WS-FAST WS-VALUE WS-OK
     MOVE SPACES TO WS-TEXT
     MOVE WS-OK TO WS-E6
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " blank "
         FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "-35/1 20 0 0 blank 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace recipes: raw iron smelts to an iron ingot (200 ticks, 0.7), beef smokes to cooked beef, raw iron blasts in 100 "
         & "ticks, dirt has no recipe, a #tag ingredient matches by tag" TO TL-CASE
     MOVE 0 TO WS-TYPE
     CALL "FURN-RECIPE" USING WS-TYPE WS-RAW WS-ROWNO WS-RESULT WS-COUNT WS-TIME WS-XP
     MOVE WS-TIME TO WS-E1
     IF WS-RESULT = WS-INGOT
         MOVE 1 TO WS-E2
     ELSE
         MOVE 0 TO WS-E2
     END-IF
     COMPUTE WS-E3 ROUNDED = WS-XP * 10
     MOVE 27 TO WS-TYPE
     CALL "FURN-RECIPE" USING WS-TYPE WS-RAW WS-ROWNO WS-RESULT WS-COUNT WS-TIME WS-XP
     MOVE WS-ROWNO TO WS-E4
     MOVE 28 TO WS-TYPE
     CALL "FURN-RECIPE" USING WS-TYPE WS-RAW WS-ROWNO WS-RESULT WS-COUNT WS-TIME WS-XP
     MOVE WS-TIME TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " smoker " FUNCTION TRIM(WS-E4) " blast " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "200 1 7 smoker 0 blast 100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE WS-FURNACE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-BX TO WS-X
     PERFORM USE-FLOOR
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK

     MOVE "acceptance US12 furnace given a placed furnace when it is used then Open Screen (menu type 14, 3 own slots) and the four Container Set Data "
         & "packets (19) arrive" TO TL-CASE
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE BE-TYPE(WS-BE) TO WS-E3
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 19"
     MOVE WS-TALLY TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " entity " FUNCTION TRIM(WS-E3) " data packets " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "type 14 size 3 entity 0 data packets 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given raw iron and coal in the hotbar when each is shift-clicked then the iron goes to the input slot and the coal "
         & "to the fuel slot, the input slot's cooking total becomes 200" TO TL-CASE
     MOVE WS-RAW TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE WS-COAL TO PL-SLOT-ITEM(WS-ROW, 6)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 6)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 6)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 34 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 35 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-E2
     MOVE BE-F-COOK-TOTAL(WS-BE) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " fuel " FUNCTION TRIM(WS-E2) " total " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 3 fuel 2 total 200" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given the loaded furnace when one tick runs then the coal is burning (1600), one is used up, the cooking timer is 1 "
         & "and the block's lit property is set" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-ID WS-I WS-S WS-TYPE
     MOVE BE-F-LIT(WS-BE) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-E2
     MOVE BE-F-COOK(WS-BE) TO WS-E3
     MOVE WS-TYPE TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "lit " FUNCTION TRIM(WS-E1) " coal " FUNCTION TRIM(WS-E2) " cook " FUNCTION TRIM(WS-E3) " flag " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "lit 1600 coal 1 cook 1 flag 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given 199 more ticks then the first iron ingot is in the result slot, two raw iron are left, the timer restarts, and "
         & "Container Set Data went out" TO TL-CASE
     MOVE 199 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-TALLY
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 19"
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E1
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E2
     MOVE BE-F-COOK(WS-BE) TO WS-E3
     IF WS-TALLY > 0
         MOVE "sent" TO WS-KEY
     ELSE
         MOVE "unsent" TO WS-KEY
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "result " FUNCTION TRIM(WS-E1) " input " FUNCTION TRIM(WS-E2) " cook " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-KEY)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "result 1 input 2 cook 0 sent" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a held iron ingot when it is put on the result slot then it is refused; picking the result up by click "
         & "works" TO TL-CASE
     MOVE WS-INGOT TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO PL-CARRIED-VAR(WS-ROW)
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 2 TO WS-S
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 3)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E1
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E2
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE WS-INGOT TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 4 TO BE-SLOT-COUNT(WS-BE, 3)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "put " FUNCTION TRIM(WS-E1) " cursor " FUNCTION TRIM(WS-E2) " took " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "put 0 cursor 1 took 4" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW)

     MOVE "acceptance US12 furnace given a shift-click of the result slot and of the input and of a plain stack then the result and the input go "
         & "to the inventory, dirt moves between the hotbar and the main inventory" TO TL-CASE
     MOVE WS-INGOT TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 4 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 2 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E1
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-E2
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 8)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 8)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 8)
     MOVE 37 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 10 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-DIRT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E3
     MOVE 3 TO WS-S
     MOVE 0 TO WS-COUNT
     MOVE 3 TO WS-ID
     MOVE SPACES TO WS-TEXT
     STRING "result " FUNCTION TRIM(WS-E1) " input " FUNCTION TRIM(WS-E2) " dirt in main " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "result 0 input 0 dirt in main 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a furnace out of fuel with progress when ticks run then the flame goes out (lit false) and the progress "
         & "decays by 2 a tick; a result slot holding another item stops cooking" TO TL-CASE
     CALL "TEST-BE-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 1) BE-SLOT-COUNT(WS-BE, 2) BE-SLOT-COUNT(WS-BE, 3)
     MOVE 1 TO BE-F-LIT(WS-BE)
     MOVE 10 TO BE-F-COOK(WS-BE)
     MOVE 200 TO BE-F-COOK-TOTAL(WS-BE)
     MOVE WS-THREE TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-LIT(WS-BE) TO WS-E1
     MOVE BE-F-COOK(WS-BE) TO WS-E2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-ID WS-I WS-S WS-TYPE
     MOVE WS-TYPE TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "lit " FUNCTION TRIM(WS-E1) " cook " FUNCTION TRIM(WS-E2) " flag " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "lit 0 cook 4 flag 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a blocked result, no recipe and a non-fuel in the fuel slot then nothing cooks: the timer is reset or stays" TO TL-CASE
     MOVE WS-RAW TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE WS-DIRT TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 5 TO BE-F-COOK(WS-BE)
     MOVE 0 TO BE-F-LIT(WS-BE)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E1
     MOVE BE-F-LIT(WS-BE) TO WS-E2
     MOVE WS-DIRT TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 5 TO BE-F-COOK(WS-BE)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E3
     MOVE WS-RAW TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE WS-DIRT TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 5 TO BE-F-COOK(WS-BE)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "blocked " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " norecipe " FUNCTION TRIM(WS-E3) " nofuel " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "blocked 0/0 norecipe 5 nofuel 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a smelt that is relit mid-way then the progress is rescaled to the new total, and a wet sponge with a bucket "
         & "in the fuel slot turns the bucket into a water bucket" TO TL-CASE
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 1) BE-SLOT-COUNT(WS-BE, 2) BE-SLOT-COUNT(WS-BE, 3)
     MOVE WS-RAW TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE 0 TO BE-F-LIT(WS-BE)
     MOVE 100 TO BE-F-COOK(WS-BE)
     MOVE 200 TO BE-F-COOK-TOTAL(WS-BE)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E1
     MOVE BE-F-COOK-TOTAL(WS-BE) TO WS-E2
     MOVE WS-SPONGE TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-BUCKET TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 1000 TO BE-F-LIT(WS-BE)
     MOVE 199 TO BE-F-COOK(WS-BE)
     MOVE 200 TO BE-F-COOK-TOTAL(WS-BE)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-SLOT-ITEM(WS-BE, 2) TO WS-ID
     MOVE 0 TO WS-E3
     IF WS-ID = WS-WATER
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "cook " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " water bucket " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cook 101/200 water bucket 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a furnace with state, when saved and loaded into another then the four ints, the speed and the recipes used "
         & "are equal" TO TL-CASE
     MOVE 17 TO BE-F-COOK(WS-BE)
     MOVE 180 TO BE-F-COOK-TOTAL(WS-BE)
     MOVE 900 TO BE-F-LIT(WS-BE)
     MOVE 1600 TO BE-F-LIT-TOTAL(WS-BE)
     MOVE 1 TO BE-F-USED-ROW(WS-BE, 1)
     MOVE 3 TO BE-F-USED-COUNT(WS-BE, 1)
     MOVE WS-BE TO WS-SRC
     MOVE "furnace" TO WS-KEY
     MOVE "minecraft:furnace" TO WS-KEY
     MOVE 17 TO WS-LEN
     MOVE 0 TO WS-TYPE
     ADD 20 TO WS-X
     CALL "BE-CREATE" USING WS-DIM WS-X WS-BY WS-Z WS-TYPE WS-KEY WS-LEN WS-BE2
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 2 TO WS-FORM
     CALL "BE-SAVE" USING WS-SRC WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-BE2 PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE BE-F-COOK(WS-BE2) TO WS-E1
     MOVE BE-F-COOK-TOTAL(WS-BE2) TO WS-E2
     MOVE BE-F-LIT(WS-BE2) TO WS-E3
     MOVE BE-F-USED-COUNT(WS-BE2, 1) TO WS-E4
     COMPUTE WS-E5 = BE-F-SPEED(WS-BE2) * 10
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " used " FUNCTION TRIM(WS-E4) " speed " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "17 180 900 used 3 speed 10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a smelt onto a stack of the same item then the result grows and the used count rises; the total rounds up; "
         & "an unknown item gives no recipe, a #tag ingredient gives a recipe of count 1" TO TL-CASE
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 1) BE-SLOT-COUNT(WS-BE, 2) BE-SLOT-COUNT(WS-BE, 3)
     MOVE WS-RAW TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 1)
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE WS-INGOT TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 5 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 3)
     MOVE 100 TO BE-F-LIT(WS-BE)
     MOVE 199 TO BE-F-COOK(WS-BE)
     MOVE 200 TO BE-F-COOK-TOTAL(WS-BE)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-E1
     MOVE BE-F-USED-COUNT(WS-BE, 1) TO WS-E2
     MOVE 201 TO WS-TIME
     CALL "FURN-TOTAL-TIME" USING WS-TIME WS-SPEED-S WS-COUNT
     MOVE WS-COUNT TO WS-E3
     MOVE 0 TO WS-TYPE
     CALL "FURN-RECIPE" USING WS-TYPE WS-HUGE WS-ROWNO WS-RESULT WS-COUNT WS-TIME WS-XP
     MOVE WS-ROWNO TO WS-E4
     CALL "FURN-RECIPE" USING WS-TYPE WS-TAGGED WS-ROWNO WS-RESULT WS-COUNT WS-TIME WS-XP
     MOVE WS-COUNT TO WS-E5
     MOVE WS-TIME TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "result " FUNCTION TRIM(WS-E1) " used " FUNCTION TRIM(WS-E2) " total " FUNCTION TRIM(WS-E3) " unknown " FUNCTION TRIM(WS-E4)
         " tag count " FUNCTION TRIM(WS-E5) " time " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "result 6 used 4 total 101 unknown 0 tag count 1 time 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given progress without fuel then it decays by 2 a tick down to 0 and never below, and above the total it is "
         & "clamped to the total" TO TL-CASE
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 1) BE-SLOT-COUNT(WS-BE, 2) BE-SLOT-COUNT(WS-BE, 3)
     MOVE 0 TO BE-F-LIT(WS-BE)
     MOVE 1 TO BE-F-COOK(WS-BE)
     MOVE 200 TO BE-F-COOK-TOTAL(WS-BE)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E1
     MOVE 10 TO BE-F-COOK(WS-BE)
     MOVE 5 TO BE-F-COOK-TOTAL(WS-BE)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE BE-F-COOK(WS-BE) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "floor " FUNCTION TRIM(WS-E1) " clamp " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "floor 0 clamp 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a smoker and a blast furnace with their inputs and coal when one tick runs then the smoker (menu 22) burns "
         & "the coal for 800 and cooks beef in 100, the blast furnace (menu 10) cooks raw iron in 50" TO TL-CASE
     COMPUTE WS-X = WS-BX + 1
     MOVE WS-SMOKER TO WS-ID
     MOVE WS-BEEF TO WS-A
     PERFORM LOAD-FURNACE
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE BE-F-LIT(WS-BE) TO WS-E2
     MOVE BE-F-COOK-TOTAL(WS-BE) TO WS-E3
     MOVE BE-F-COOK(WS-BE) TO WS-E4
     COMPUTE WS-X = WS-BX + 2
     MOVE WS-BLAST TO WS-ID
     MOVE WS-RAW TO WS-A
     PERFORM LOAD-FURNACE
     MOVE MN-TYPE(WS-ROW) TO WS-E5
     MOVE BE-F-COOK-TOTAL(WS-BE) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "smoker " FUNCTION TRIM(WS-E1) " lit " FUNCTION TRIM(WS-E2) " total " FUNCTION TRIM(WS-E3) " cook " FUNCTION TRIM(WS-E4)
         " blast " FUNCTION TRIM(WS-E5) " total " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "smoker 22 lit 800 total 100 cook 1 blast 10 total 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace the fuel slot takes coal and an empty bucket but not dirt, the result slot nothing, the input slot anything" TO TL-CASE
     COMPUTE WS-X = WS-BX + 2
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-S
     MOVE WS-COAL TO WS-A
     CALL "MENU-MAY-PLACE" USING WS-ROW WS-S WS-A WS-E1-N
     MOVE WS-BUCKET TO WS-A
     CALL "MENU-MAY-PLACE" USING WS-ROW WS-S WS-A WS-E2-N
     MOVE WS-DIRT TO WS-A
     CALL "MENU-MAY-PLACE" USING WS-ROW WS-S WS-A WS-E3-N
     MOVE 2 TO WS-S
     CALL "MENU-MAY-PLACE" USING WS-ROW WS-S WS-A WS-E4-N
     MOVE 0 TO WS-S
     CALL "MENU-MAY-PLACE" USING WS-ROW WS-S WS-A WS-E5-N
     MOVE WS-E1-N TO WS-E1
     MOVE WS-E2-N TO WS-E2
     MOVE WS-E3-N TO WS-E3
     MOVE WS-E4-N TO WS-E4
     MOVE WS-E5-N TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "coal " FUNCTION TRIM(WS-E1) " bucket " FUNCTION TRIM(WS-E2) " dirt " FUNCTION TRIM(WS-E3) " result " FUNCTION TRIM(WS-E4) " input "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "coal 1 bucket 1 dirt 0 result 0 input 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given dirt in a main inventory slot when it is shift-clicked then it goes to the hotbar" TO TL-CASE
     MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, 12)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 12)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 12)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 5 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE PL-SLOT-COUNT(WS-ROW, 12) TO WS-E1
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-DIRT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "main " FUNCTION TRIM(WS-E1) " hotbar " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "main 0 hotbar 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 furnace given a tag with unknown recipes, foreign tag types and a smaller RecipesUsed when it is loaded then the unknown "
         & "recipe and the other types are skipped and the known recipe's count is read" TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "cooking_time_spent" TO WS-NM
     MOVE 18 TO WS-NMLEN
     MOVE "x" TO WS-STR
     MOVE 1 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NMLEN WS-STR WS-STRLEN
     MOVE "lit_total_time" TO WS-NM
     MOVE 14 TO WS-NMLEN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NMLEN WS-E2-N
     MOVE "RecipesUsed" TO WS-NM
     MOVE 11 TO WS-NMLEN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NMLEN
     MOVE "iron_ingot_from_blasting_raw_iron" TO WS-NM
     MOVE 33 TO WS-NMLEN
     MOVE 7 TO WS-COUNT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NMLEN WS-COUNT
     MOVE "no_such_recipe" TO WS-NM
     MOVE 14 TO WS-NMLEN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NMLEN WS-COUNT
     MOVE "text_entry" TO WS-NM
     MOVE 10 TO WS-NMLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NMLEN WS-STR WS-STRLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "speed_multiplier" TO WS-NM
     MOVE 16 TO WS-NMLEN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NMLEN WS-COUNT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 99 TO BE-F-COOK(WS-BE)
     MOVE 99 TO BE-F-LIT-TOTAL(WS-BE)
     CALL "BE-LOAD" USING WS-BE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE BE-F-COOK(WS-BE) TO WS-E1
     MOVE BE-F-LIT-TOTAL(WS-BE) TO WS-E2
     MOVE BE-F-USED-COUNT(WS-BE, 1) TO WS-E3
     MOVE BE-F-USED-ROW(WS-BE, 2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "cook " FUNCTION TRIM(WS-E1) " lit total " FUNCTION TRIM(WS-E2) " used " FUNCTION TRIM(WS-E3) " second " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cook 0 lit total 1 used 7 second 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Places the furnace item WS-ID at WS-X, opens it, shift-clicks the input item WS-A (3) and coal (2) into it and runs one tick; WS-BE is its entity.
 LOAD-FURNACE.
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     PERFORM USE-FLOOR
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     PERFORM USE-BLOCK
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE
     MOVE WS-A TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE WS-COAL TO PL-SLOT-ITEM(WS-ROW, 6)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 6)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 6)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 34 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 35 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS.

*> Writes the registry fixtures, switches the content set to the standard one (the rows are compiled in), loads the registries and the recipes and
*> rebuilds the core tables from it.
 SWITCH-CONTENT.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/furnace-fix 2>/dev/null; rm -rf build/furnace-fix; mkdir -p build/furnace-fix && cp -R content/tests/fixtures/std "
         "build/furnace-fix/t && mkdir -p build/furnace-fix/t/vanilla-data/data/minecraft/context_int_provider/cooking && cd build/furnace-fix/t/"
         "vanilla-data/data/minecraft/context_int_provider/cooking && "
         "printf '%s' '{" '"type":"minecraft:div","left":1600,"right":{"type":"minecraft:conditional","condition":"minecraft:block/fast_cooking",'
         '"on_false":"minecraft:cooking/normal_burn_time_reduction_factor","on_true":"minecraft:cooking/fast_burn_time_reduction_factor"}}'
         "' > time_coal.json && printf '1' > normal_burn_time_reduction_factor.json && printf '2' > fast_burn_time_reduction_factor.json && "
         "printf '%s' '{" '"type":"minecraft:conditional","condition":"minecraft:block/fast_cooking","on_false":"minecraft:cooking/normal_speed_multiplier",'
         '"on_true":"minecraft:cooking/fast_speed_multiplier"}' "' > speed_default.json && printf '1.0' > normal_speed_multiplier.json && "
         "printf '2.0' > fast_speed_multiplier.json" X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     CALL "FURN-PROVIDERS-LOAD" USING WS-DIRF
     MOVE 5 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2) RC-ROW(3) RC-ROW(4) RC-ROW(5)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE SPACES TO RR-ING(WS-I, 1)
     END-PERFORM
     MOVE 14 TO RR-SERIALIZER(1)
     MOVE "minecraft:raw_iron" TO RR-ING(1, 1)
     MOVE "minecraft:iron_ingot" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 200 TO RR-COOK-TIME(1)
     MOVE 0.7 TO RR-EXPERIENCE(1)
     MOVE "iron_ingot_from_smelting_raw_iron" TO RR-KEY(1)
     MOVE 16 TO RR-SERIALIZER(2)
     MOVE "minecraft:beef" TO RR-ING(2, 1)
     MOVE "minecraft:cooked_beef" TO RR-RESULT-ID(2)
     MOVE 1 TO RR-RESULT-COUNT(2)
     MOVE 200 TO RR-COOK-TIME(2)
     MOVE 0.35 TO RR-EXPERIENCE(2)
     MOVE "cooked_beef_from_smoking_beef" TO RR-KEY(2)
     MOVE 15 TO RR-SERIALIZER(3)
     MOVE "minecraft:raw_iron" TO RR-ING(3, 1)
     MOVE "minecraft:iron_ingot" TO RR-RESULT-ID(3)
     MOVE 1 TO RR-RESULT-COUNT(3)
     MOVE 100 TO RR-COOK-TIME(3)
     MOVE 0.7 TO RR-EXPERIENCE(3)
     MOVE "iron_ingot_from_blasting_raw_iron" TO RR-KEY(3)
     MOVE CORE-ENTITY-TYPES TO WS-SAVE-TYPES
     MOVE CORE-ENTITY-ROLES TO WS-SAVE-ROLES
     MOVE 14 TO RR-SERIALIZER(4)
     MOVE "minecraft:wet_sponge" TO RR-ING(4, 1)
     MOVE "minecraft:sponge" TO RR-RESULT-ID(4)
     MOVE 1 TO RR-RESULT-COUNT(4)
     MOVE 200 TO RR-COOK-TIME(4)
     MOVE 0.15 TO RR-EXPERIENCE(4)
     MOVE "sponge" TO RR-KEY(4)
     MOVE 14 TO RR-SERIALIZER(5)
     MOVE "#minecraft:test_tag" TO RR-ING(5, 1)
     MOVE "minecraft:iron_ingot" TO RR-RESULT-ID(5)
     MOVE 0 TO RR-RESULT-COUNT(5)
     MOVE 50 TO RR-COOK-TIME(5)
     MOVE "from_tag" TO RR-KEY(5)
     CALL "BLOCKS-OPEN"
     CALL "CORE-TABLES-OPEN"
     MOVE WS-SAVE-TYPES TO CORE-ENTITY-TYPES
     MOVE WS-SAVE-ROLES TO CORE-ENTITY-ROLES
     MOVE "gravel" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-TAGGED
     MOVE WS-TAGGED TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TAG-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE
         MOVE 0 TO WS-STATE2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-S = WS-BY + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-BZ WS-STATE2
         END-PERFORM
     END-PERFORM.

 USE-FLOOR.
     ADD 1 TO WS-SEQ
     COMPUTE WS-Y = WS-BY - 1
     MOVE WS-BZ TO WS-Z
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-FURNACE.

 COPY CORETEST.
 COPY BETEST.
