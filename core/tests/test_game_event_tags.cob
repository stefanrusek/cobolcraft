*> Implementation test (lane p49y; a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped as a pass without it; docs/protocol/30-redstone-8 sections 3.1 and 3.5.1, 31-block-entities-8 sections 3.6.1 to 3.6.5): the member lists of the
*> game event and block tags, the careful source rule and the exact occlusion traversal.
*> - the 61 events of the registry against the five game event tags and the frequency table of 30-8 section 3.5.1, one case per event (the expected flags are the table's, typed in this file);
*> - the block tag lists: 64 members of dampens_vibrations, 16 of occludes_vibration_signals (the worked state ids and the key lists), amethyst_block as the resonator;
*> - a crouching cat or ocelot is stepping carefully like a player with the shift key (its step is not heard, its block_destroy is), a fox is not;
*> - the occlusion line test of 31-8 3.6.5 examples 1 to 8 (the expected results are the document's), the end cell and the start cell count, the end point on a cell boundary tests the cell beyond it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAME-EVENT-TAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY CITEMS.
 COPY WARDENSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-EVENT               PIC X(32).
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FREQ                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TAG-NAME            PIC X(32).
 01 WS-TAG-SEL             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-GOT                 PIC X(8).
 01 WS-KEY48               PIC X(48).
 01 WS-CAT                 BINARY-LONG.
 01 WS-FOX                 BINARY-LONG.
 01 WS-OCELOT              BINARY-LONG.
 01 WS-RES                 PIC 9.
 01 WS-TYPE-OF             BINARY-LONG.
 01 WS-NUM-EDIT            PIC Z9.
*> the registry rows of 30-8 section 3.5.1: name, frequency, then the flags V W I S A as 0 or 1
 01 WS-ROWS-TEXT.
    05 FILLER PIC X(48) VALUE "block_activate 10 11000".
    05 FILLER PIC X(48) VALUE "block_attach 10 11000".
    05 FILLER PIC X(48) VALUE "block_change 11 11000".
    05 FILLER PIC X(48) VALUE "block_close 09 11000".
    05 FILLER PIC X(48) VALUE "block_deactivate 09 11000".
    05 FILLER PIC X(48) VALUE "block_destroy 12 11000".
    05 FILLER PIC X(48) VALUE "block_detach 09 11000".
    05 FILLER PIC X(48) VALUE "block_open 10 11000".
    05 FILLER PIC X(48) VALUE "block_place 13 11000".
    05 FILLER PIC X(48) VALUE "bounce 02 11000".
    05 FILLER PIC X(48) VALUE "container_close 09 11000".
    05 FILLER PIC X(48) VALUE "container_open 10 11000".
    05 FILLER PIC X(48) VALUE "drink 08 11000".
    05 FILLER PIC X(48) VALUE "eat 08 11000".
    05 FILLER PIC X(48) VALUE "elytra_glide 04 11000".
    05 FILLER PIC X(48) VALUE "entity_damage 07 11000".
    05 FILLER PIC X(48) VALUE "entity_die 15 11000".
    05 FILLER PIC X(48) VALUE "entity_dismount 05 11000".
    05 FILLER PIC X(48) VALUE "entity_interact 06 11000".
    05 FILLER PIC X(48) VALUE "entity_mount 06 11000".
    05 FILLER PIC X(48) VALUE "entity_place 14 11000".
    05 FILLER PIC X(48) VALUE "entity_action 04 11000".
    05 FILLER PIC X(48) VALUE "equip 05 11000".
    05 FILLER PIC X(48) VALUE "explode 15 11000".
    05 FILLER PIC X(48) VALUE "flap 01 10000".
    05 FILLER PIC X(48) VALUE "fluid_pickup 12 11000".
    05 FILLER PIC X(48) VALUE "fluid_place 13 11000".
    05 FILLER PIC X(48) VALUE "hit_ground 02 11100".
    05 FILLER PIC X(48) VALUE "instrument_play 03 11000".
    05 FILLER PIC X(48) VALUE "item_interact_finish 03 11100".
    05 FILLER PIC X(48) VALUE "item_interact_start 00 00100".
    05 FILLER PIC X(48) VALUE "jukebox_play 00 00000".
    05 FILLER PIC X(48) VALUE "jukebox_stop_play 00 00000".
    05 FILLER PIC X(48) VALUE "lightning_strike 14 11000".
    05 FILLER PIC X(48) VALUE "note_block_play 10 11001".
    05 FILLER PIC X(48) VALUE "prime_fuse 10 11000".
    05 FILLER PIC X(48) VALUE "projectile_land 02 11000".
    05 FILLER PIC X(48) VALUE "projectile_shoot 03 11100".
    05 FILLER PIC X(48) VALUE "sculk_sensor_tendrils_clicking 00 01010".
    05 FILLER PIC X(48) VALUE "shear 06 11000".
    05 FILLER PIC X(48) VALUE "shriek 00 01000".
    05 FILLER PIC X(48) VALUE "splash 02 11000".
    05 FILLER PIC X(48) VALUE "step 01 11100".
    05 FILLER PIC X(48) VALUE "swim 01 11100".
    05 FILLER PIC X(48) VALUE "teleport 14 11000".
    05 FILLER PIC X(48) VALUE "unequip 04 11000".
 01 WS-ROWS REDEFINES WS-ROWS-TEXT.
    05 WS-ROW-TEXT         PIC X(48) OCCURS 46 TIMES.
 01 WS-R-NAME              PIC X(32).
 01 WS-R-FREQ              PIC 99.
 01 WS-R-FLAGS             PIC X(5).
 01 WS-R-EXPECT            PIC X(8).
 01 WS-LIST                PIC X(96).
 01 WS-COLOURS-TEXT.
    05 FILLER PIC X(11) VALUE "white".
    05 FILLER PIC X(11) VALUE "orange".
    05 FILLER PIC X(11) VALUE "magenta".
    05 FILLER PIC X(11) VALUE "light_blue".
    05 FILLER PIC X(11) VALUE "yellow".
    05 FILLER PIC X(11) VALUE "lime".
    05 FILLER PIC X(11) VALUE "pink".
    05 FILLER PIC X(11) VALUE "gray".
    05 FILLER PIC X(11) VALUE "light_gray".
    05 FILLER PIC X(11) VALUE "cyan".
    05 FILLER PIC X(11) VALUE "purple".
    05 FILLER PIC X(11) VALUE "blue".
    05 FILLER PIC X(11) VALUE "brown".
    05 FILLER PIC X(11) VALUE "green".
    05 FILLER PIC X(11) VALUE "red".
    05 FILLER PIC X(11) VALUE "black".
 01 WS-COLOURS REDEFINES WS-COLOURS-TEXT.
    05 WS-COLOUR           PIC X(11) OCCURS 16 TIMES.
*> occlusion worked examples: event and listener offsets from the origin cell, up to four wool cells (offsets), the expected result
 01 WS-EDX                 FLOAT-LONG.
 01 WS-EDY                 FLOAT-LONG.
 01 WS-EDZ                 FLOAT-LONG.
 01 WS-LDX                 FLOAT-LONG VALUE 0.5.
 01 WS-LDY                 FLOAT-LONG VALUE 0.5.
 01 WS-LDZ                 FLOAT-LONG VALUE 0.5.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-EX2                 FLOAT-LONG.
 01 WS-EY2                 FLOAT-LONG.
 01 WS-EZ2                 FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-WN                  BINARY-LONG.
 01 WS-WOOLS.
    05 WS-WOOL-CELL OCCURS 4 TIMES.
       10 WS-WOX           BINARY-LONG.
       10 WS-WOY           BINARY-LONG.
       10 WS-WOZ           BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-WHY                 PIC X(150).
 01 WS-SOURCE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "implementation 30-8 tags: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:white_wool" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WOOL
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE 12001 TO CW-TIME

*>   1. The registry against the five game event tags: one case per event, the frequency and the flags V W I S A.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 46
         MOVE SPACES TO WS-R-NAME WS-R-FLAGS
         UNSTRING WS-ROW-TEXT(WS-I) DELIMITED BY SPACE INTO WS-R-NAME WS-R-FREQ WS-R-FLAGS
         PERFORM CHECK-EVENT
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         MOVE SPACES TO WS-R-NAME
         MOVE WS-I TO WS-NUM-EDIT
         STRING "resonate_" DELIMITED BY SIZE FUNCTION TRIM(WS-NUM-EDIT) DELIMITED BY SIZE INTO WS-R-NAME
         MOVE WS-I TO WS-R-FREQ
         MOVE "11000" TO WS-R-FLAGS
         PERFORM CHECK-RESONATE
     END-PERFORM
     MOVE "no_such_event" TO WS-EVENT
     MOVE "warden_can_listen" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE "an unknown event is in no tag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "step" TO WS-EVENT
     MOVE "no_such_tag" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE "an unknown tag has no member" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE

*>   2. The block tag lists: 16 colours times four families.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE SPACES TO WS-KEY48
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool" DELIMITED BY SIZE INTO WS-KEY48
         MOVE 2 TO WS-TAG-SEL
         CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY48 WS-TAG-SEL WS-FLAG
         ADD WS-FLAG TO WS-COUNT
     END-PERFORM
     MOVE "occludes_vibration_signals holds the 16 wool blocks" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             MOVE SPACES TO WS-KEY48
             EVALUATE WS-J
                 WHEN 1
                     STRING FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool" DELIMITED BY SIZE INTO WS-KEY48
                 WHEN 2
                     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_carpet" DELIMITED BY SIZE INTO WS-KEY48
                 WHEN 3
                     STRING FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool_slab" DELIMITED BY SIZE INTO WS-KEY48
                 WHEN OTHER
                     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool_stairs" DELIMITED BY SIZE INTO WS-KEY48
             END-EVALUATE
             MOVE 1 TO WS-TAG-SEL
             CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY48 WS-TAG-SEL WS-FLAG
             ADD WS-FLAG TO WS-COUNT
         END-PERFORM
     END-PERFORM
     MOVE "dampens_vibrations holds the 64 wool, carpet, wool slab and wool stairs blocks (with or without the namespace)" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         PERFORM VARYING WS-J FROM 2 BY 1 UNTIL WS-J > 4
             MOVE SPACES TO WS-KEY48
             EVALUATE WS-J
                 WHEN 2
                     STRING FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_carpet" DELIMITED BY SIZE INTO WS-KEY48
                 WHEN 3
                     STRING FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool_slab" DELIMITED BY SIZE INTO WS-KEY48
                 WHEN OTHER
                     STRING FUNCTION TRIM(WS-COLOUR(WS-I)) DELIMITED BY SIZE "_wool_stairs" DELIMITED BY SIZE INTO WS-KEY48
             END-EVALUATE
             MOVE 2 TO WS-TAG-SEL
             CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY48 WS-TAG-SEL WS-FLAG
             ADD WS-FLAG TO WS-COUNT
         END-PERFORM
     END-PERFORM
     MOVE "the 48 carpets, wool slabs and wool stairs do not occlude" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "stone" TO WS-KEY48
     MOVE 1 TO WS-TAG-SEL
     CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY48 WS-TAG-SEL WS-FLAG
     MOVE "stone is in no wool list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "white_carpet_x" TO WS-KEY48
     CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY48 WS-TAG-SEL WS-FLAG
     MOVE "a key that merely contains carpet is not a member" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO WS-TAG-SEL
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-WOOL WS-TAG-SEL WS-FLAG
     MOVE "the white wool state is in dampens_vibrations" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 2 TO WS-TAG-SEL
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-WOOL WS-TAG-SEL WS-FLAG
     MOVE "the white wool state is in occludes_vibration_signals" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 3 TO WS-TAG-SEL
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-WOOL WS-TAG-SEL WS-FLAG
     MOVE "the white wool state is not a vibration resonator" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "minecraft:amethyst_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-STATE WS-TAG-SEL WS-FLAG
     MOVE "amethyst_block is the vibration resonator" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO WS-TAG-SEL
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-STATE WS-TAG-SEL WS-FLAG
     MOVE "and dampens nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-NONE WS-TAG-SEL WS-FLAG
     MOVE "state -1 is in no block tag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO WS-TAG-SEL
     CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-STONE WS-TAG-SEL WS-FLAG
     MOVE "stone is not in dampens_vibrations" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE

*>   3. The careful source rule: a crouching cat or ocelot, not a fox.
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE WS-TYPE TO WS-CAT
     MOVE "minecraft:ocelot" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE WS-TYPE TO WS-OCELOT
     MOVE "minecraft:fox" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE WS-TYPE TO WS-FOX
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 1000 TO CW-TICKS
     MOVE WS-CAT TO WS-I
     MOVE "cat" TO WS-NAME
     PERFORM CAREFUL-CASES
     MOVE WS-OCELOT TO WS-I
     MOVE "ocelot" TO WS-NAME
     PERFORM CAREFUL-CASES

*>   3b. A fox that is crouching is not careful (30-8 3.5.1): its step is heard.
     PERFORM NEW-WARDEN
     MOVE WS-FOX TO WS-TYPE-OF
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE-OF WS-X WS-Y WS-Z WS-YAW WS-CAT
     MOVE 1 TO EN-CROUCHING(WS-CAT)
     MOVE 4 TO EN-FOX-FLAGS(WS-CAT)
     MOVE "step" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-CAT
     MOVE "a crouching fox is not stepping carefully: its step is heard" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-CAT
     CALL "ENTITY-REMOVE" USING WS-WARDEN

*>   4. The occlusion worked examples of 31-8 3.6.5 (listener cell = the origin cell).
     MOVE 3.5 TO WS-EDX
     MOVE 0.5 TO WS-EDY WS-EDZ
     MOVE 1 TO WS-WN
     MOVE 1 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1) WS-WOZ(1)
     MOVE 1 TO WS-EXPECT
     MOVE "example 1: event (3.5,0.5,0.5), wool (1,0,0): all six rays cross it" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2 TO WS-WOX(1)
     MOVE "example 1: wool (2,0,0) gives the same" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 1 TO WS-WOX(1)
     MOVE 1 TO WS-WOY(1)
     MOVE 0 TO WS-EXPECT
     MOVE "example 1: wool (1,1,0) is on no ray" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 3 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1)
     MOVE 1 TO WS-EXPECT
     MOVE "example 7: wool at the event cell (3,0,0) occludes: the start cell counts" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 0 TO WS-WOX(1)
     MOVE "wool at the listener cell (0,0,0) occludes: the end cell counts" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2.5 TO WS-EDX WS-EDY
     MOVE 1 TO WS-WOX(1) WS-WOY(1)
     MOVE 0 TO WS-WOZ(1)
     MOVE 1 TO WS-EXPECT
     MOVE "example 2: perfect diagonal (2.5,2.5,0.5), wool (1,1,0): every ray passes it" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2 TO WS-WOX(1)
     MOVE 1 TO WS-WOY(1)
     MOVE 0 TO WS-EXPECT
     MOVE "example 2b: wool (2,1,0) only: the up and west rays go round it" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 1 TO WS-WOX(1)
     MOVE 2 TO WS-WOY(1)
     MOVE "example 2c: wool (1,2,0) only: the down, north, south and east rays pass beside it" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2 TO WS-WN
     MOVE 2 TO WS-WOX(1)
     MOVE 1 TO WS-WOY(1)
     MOVE 1 TO WS-WOX(2)
     MOVE 2 TO WS-WOY(2)
     MOVE 0 TO WS-WOZ(2)
     MOVE 1 TO WS-EXPECT
     MOVE "example 2d: wool (2,1,0) and (1,2,0): the corner-touching case, every ray crosses one" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 1 TO WS-WN
     MOVE 1 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1)
     MOVE 0 TO WS-EXPECT
     MOVE "example 2e: wool (1,0,0) only" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 0 TO WS-WOX(1)
     MOVE 1 TO WS-WOY(1)
     MOVE "example 2e: wool (0,1,0) only" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 3.5 TO WS-EDX
     MOVE 1.5 TO WS-EDY
     MOVE 2 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1)
     MOVE "example 3: event (3.5,1.5,0.5), wool (2,0,0) only: the up and west rays take another way" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2 TO WS-WN
     MOVE 1 TO WS-WOX(2)
     MOVE 1 TO WS-WOY(2)
     MOVE 0 TO WS-WOZ(2)
     MOVE 1 TO WS-EXPECT
     MOVE "example 3: wool (2,0,0) and (1,1,0) together occlude" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 1 TO WS-WN
     MOVE 2 TO WS-WOX(1)
     MOVE 1 TO WS-WOY(1)
     MOVE "example 3: wool (2,1,0) occludes (all six rays cross it)" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 1 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1)
     MOVE "example 3: wool (1,0,0) occludes" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 2.5 TO WS-EDX WS-EDY WS-EDZ
     MOVE 1 TO WS-WOX(1) WS-WOY(1) WS-WOZ(1)
     MOVE "example 4: 3-D diagonal (2.5,2.5,2.5), wool (1,1,1)" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 0.5 TO WS-EDX WS-EDZ
     MOVE 3.5 TO WS-EDY
     MOVE 0 TO WS-WOX(1) WS-WOZ(1)
     MOVE 2 TO WS-WOY(1)
     MOVE "example 5: straight above (0.5,3.5,0.5), wool (0,2,0)" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 0.7 TO WS-EDX
     MOVE 0.2 TO WS-EDY
     MOVE 0.9 TO WS-EDZ
     MOVE 0 TO WS-WN
     MOVE 0 TO WS-EXPECT
     MOVE "example 6: event in the listener cell, no wool: only that cell, not occluded" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 3.9 TO WS-EDX
     MOVE 0.1 TO WS-EDY
     MOVE 0.99 TO WS-EDZ
     MOVE 0.01 TO WS-LDX
     MOVE 0.99 TO WS-LDY
     MOVE 0.5 TO WS-LDZ
     MOVE 1 TO WS-WN
     MOVE 1 TO WS-WOX(1)
     MOVE 0 TO WS-WOY(1) WS-WOZ(1)
     MOVE 1 TO WS-EXPECT
     MOVE "example 8: unsnapped positions (3.9,0.1,0.99) and (0.01,0.99,0.5), wool (1,0,0)" TO WS-WHY
     PERFORM CHECK-OCC
     MOVE 0.5 TO WS-LDX WS-LDY WS-LDZ

*>   5. The line test itself: the end point exactly on a cell boundary tests the cell beyond it (T is extended by 1e-7), the start point on a boundary the cell before it.
     COMPUTE WS-CX = WS-BX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-WOOL
     COMPUTE WS-EX = WS-BX + 0.5
     COMPUTE WS-EY = WS-BY + 0.5
     COMPUTE WS-EZ = WS-BZ + 0.5
     COMPUTE WS-LX = WS-BX + 3
     MOVE WS-EY TO WS-LY
     MOVE WS-EZ TO WS-LZ
     CALL "GAME-EVENT-RAY" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-HIT
     MOVE "a segment ending exactly on the boundary x = 3 tests the wool cell (3,0,0) beyond it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "GAME-EVENT-RAY" USING WS-DIM WS-LX WS-LY WS-LZ WS-EX WS-EY WS-EZ WS-HIT
     MOVE "a segment starting on the boundary x = 3 and walking back also tests the wool cell (3,0,0) (S is extended)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-LX = WS-BX + 2.9
     CALL "GAME-EVENT-RAY" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-HIT
     MOVE "a segment ending at x = 2.9 never reaches the wool cell (3,0,0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE WS-EX TO WS-EX2
     MOVE WS-EY TO WS-EY2
     MOVE WS-EZ TO WS-EZ2
     CALL "GAME-EVENT-RAY" USING WS-DIM WS-EX WS-EY WS-EZ WS-EX2 WS-EY2 WS-EZ2 WS-HIT
     MOVE "two equal points visit no cell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-AIR
*>   a zero direction component on a cell edge: the same cell is simply tested twice (31-8 3.6.2 point 8): a horizontal segment along the edge y = by + 1 tests the row above
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-WOOL
     COMPUTE WS-EY = WS-BY + 1
     COMPUTE WS-LY = WS-BY + 1
     COMPUTE WS-LX = WS-BX + 3.5
     CALL "GAME-EVENT-RAY" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-HIT
     MOVE "a segment lying exactly on the cell edge y = by + 1 (zero y direction, frac 0) still walks and meets wool (3,1,0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     STOP RUN.

*> One event of the table (WS-R-NAME, WS-R-FREQ, WS-R-FLAGS V W I S A) against the frequency table and the five tags.
 CHECK-EVENT.
     MOVE WS-R-NAME TO WS-EVENT
     PERFORM CHECK-EVENT-ROW
     .

 CHECK-RESONATE.
     MOVE WS-R-NAME TO WS-EVENT
     PERFORM CHECK-EVENT-ROW
     .

 CHECK-EVENT-ROW.
     CALL "GAME-EVENT-FREQUENCY" USING WS-EVENT WS-FREQ
     MOVE SPACES TO WS-GOT
     MOVE "vibrations" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE WS-FLAG TO WS-RES
     MOVE WS-RES TO WS-GOT(1:1)
     MOVE "warden_can_listen" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE WS-FLAG TO WS-RES
     MOVE WS-RES TO WS-GOT(2:1)
     MOVE "ignore_vibrations_sneaking" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE WS-FLAG TO WS-RES
     MOVE WS-RES TO WS-GOT(3:1)
     MOVE "shrieker_can_listen" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE WS-FLAG TO WS-RES
     MOVE WS-RES TO WS-GOT(4:1)
     MOVE "allay_can_listen" TO WS-TAG-NAME
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG-NAME WS-EVENT WS-FLAG
     MOVE WS-FLAG TO WS-RES
     MOVE WS-RES TO WS-GOT(5:1)
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-EVENT) DELIMITED BY SIZE " frequency " DELIMITED BY SIZE WS-R-FREQ DELIMITED BY SIZE
         " tags VWISA " DELIMITED BY SIZE WS-R-FLAGS DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-R-FREQ * 100000 + FUNCTION NUMVAL(WS-R-FLAGS)
     COMPUTE TL-OBSERVED-N = WS-FREQ * 100000 + FUNCTION NUMVAL(WS-GOT(1:5))
     PERFORM CASE-LINE
     .

*> A cat or ocelot (type WS-I) at the player: not crouching its step is heard, crouching it is not, its block_destroy still is.
 CAREFUL-CASES.
     PERFORM NEW-WARDEN
     MOVE WS-I TO WS-TYPE-OF
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE-OF WS-X WS-Y WS-Z WS-YAW WS-SOURCE
     MOVE "step" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-SOURCE
     MOVE SPACES TO TL-CASE
     STRING "a " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE " that is not crouching: its step is heard" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WD-V-DUE(WS-W)
     MOVE 1 TO EN-CROUCHING(WS-SOURCE)
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-SOURCE
     MOVE SPACES TO TL-CASE
     STRING "a crouching " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE " is stepping carefully: its step is not heard" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "swim" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-SOURCE
     MOVE "and neither is its swim (ignore_vibrations_sneaking)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-SOURCE
     MOVE "but its block_destroy is" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-SOURCE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
     .

*> One occlusion case: the event at the origin cell + (WS-EDX, WS-EDY, WS-EDZ), the listener at + (WS-LDX..), the wool cells placed for the call and removed after.
 CHECK-OCC.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-WN
         COMPUTE WS-CX = WS-BX + WS-WOX(WS-J)
         COMPUTE WS-CY = WS-BY + WS-WOY(WS-J)
         COMPUTE WS-CZ = WS-BZ + WS-WOZ(WS-J)
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WOOL
     END-PERFORM
     COMPUTE WS-EX = WS-BX + WS-EDX
     COMPUTE WS-EY = WS-BY + WS-EDY
     COMPUTE WS-EZ = WS-BZ + WS-EDZ
     COMPUTE WS-LX = WS-BX + WS-LDX
     COMPUTE WS-LY = WS-BY + WS-LDY
     COMPUTE WS-LZ = WS-BZ + WS-LDZ
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE WS-WHY TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-WN
         COMPUTE WS-CX = WS-BX + WS-WOX(WS-J)
         COMPUTE WS-CY = WS-BY + WS-WOY(WS-J)
         COMPUTE WS-CZ = WS-BZ + WS-WOZ(WS-J)
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     END-PERFORM
     .

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "implementation 30-8 tags: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A new warden 10 blocks west of the player (survival, alive); the player's block is the origin of the occlusion cases.
 NEW-WARDEN.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WD-MAX
         INITIALIZE WD-ENTRY(WS-J)
     END-PERFORM
     COMPUTE WS-X0 = WS-BX + 0.5 - 10
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE WS-BY TO WS-Y
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     .
 END PROGRAM TEST-GAME-EVENT-TAGS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY PORTALTEST.
