*> Acceptance test (wrap agent B, T29572; docs/protocol/31-block-entities-2 sections 4.1 and 5.4 to 5.6): the slot rules by face of the brewing stand under the hopper's item transfer. A hopper over a
*> brewing stand puts into the reagent slot only, one beside it into the fuel slot and the empty potion slots, one under it takes the potion slots and a glass bottle of the reagent slot, never
*> the reagent or the fuel. The stand-in world (its brewing recipes and the blaze powder provider, like acc_p70c_brew); the furnace has its own test (acc_wrapb_hopper_faces).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-HOPPER-BREW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-NX                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OBS                 PIC X(160).
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-WART                BINARY-LONG.
 01 WS-BLAZE               BINARY-LONG.
 01 WS-BOTTLE              BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-COMMAND             PIC X(4000).
 01 WS-DIRF                PIC X(1100) VALUE "build/wrapb-brew-fix/t".
 01 WS-SAVE-TYPES          PIC X(20000).
 01 WS-SAVE-ROLES          PIC X(64).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE "1" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     PERFORM SWITCH-CONTENT
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 20
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 60 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 61 BY 1 UNTIL WS-Y > 64
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 80.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "nether_wart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-WART
     MOVE "blaze_powder" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-BLAZE
     MOVE "glass_bottle" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-BOTTLE
     MOVE "potion" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-POTION

*>   F. a hopper over a brewing stand puts a reagent into the reagent slot (31-2 4.1 UP gives [3])
     MOVE 10 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 61 TO WS-Y MOVE "brewing_stand" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 62 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-WART TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-BLAZE TO BE-SLOT-ITEM(WS-BE, 2) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 4) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 5) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 4.1 a hopper over a brewing stand puts both nether warts into the reagent slot, blaze powder is refused" TO WS-CASE
     MOVE "2 0 2" TO WS-EXP
     PERFORM ASSERT-ABC
*>   G. a hopper beside a brewing stand puts blaze powder into the fuel slot
     MOVE 12 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 61 TO WS-Y MOVE "brewing_stand" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-BLAZE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
*>   (the stand uses the powder at once: Fuel 20 and one item left in the hopper show that it went through the fuel slot)
     MOVE BE-XI(WS-BE2, 3) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     COMPUTE WS-C = BE-SLOT-COUNT(WS-BE2, 1) + BE-SLOT-COUNT(WS-BE2, 2) + BE-SLOT-COUNT(WS-BE2, 3)
     MOVE "acceptance wrapb hopper 31-2 4.1 a hopper beside a brewing stand puts blaze powder into the fuel slot (Fuel 20, one left, no potion slot used)" TO WS-CASE
     MOVE "20 1 0" TO WS-EXP
     PERFORM ASSERT-ABC
*>   H. a hopper beside a brewing stand puts a water-less nether wart nowhere: neither fuel nor potion input
     MOVE 14 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 4 TO WS-X MOVE 61 TO WS-Y MOVE "brewing_stand" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM MAKE-HOPPER-EAST
     MOVE WS-WART TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 4) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 5) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 4.1 a hopper beside a brewing stand cannot put nether wart into the side slots" TO WS-CASE
     MOVE "0 0 2" TO WS-EXP
     PERFORM ASSERT-ABC
*>   I. a hopper under a brewing stand takes a potion slot and never the reagent (DOWN gives [0, 1, 2, 3]; slot 3 only a glass bottle)
     MOVE 16 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 62 TO WS-Y MOVE "brewing_stand" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-WART TO BE-SLOT-ITEM(WS-BE2, 4) MOVE 3 TO BE-SLOT-COUNT(WS-BE2, 4)
     MOVE WS-POTION TO BE-SLOT-ITEM(WS-BE2, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE2, 1)
     MOVE 61 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 30 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE2, 4) TO WS-B
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-C
     MOVE "acceptance wrapb hopper 31-2 4.1 a hopper under a brewing stand takes the potion and leaves the nether wart" TO WS-CASE
     MOVE "0 3 1" TO WS-EXP
     PERFORM ASSERT-ABC
*>   J. and takes a glass bottle that sits in the reagent slot
     MOVE 18 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 62 TO WS-Y MOVE "brewing_stand" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-BOTTLE TO BE-SLOT-ITEM(WS-BE2, 4) MOVE 1 TO BE-SLOT-COUNT(WS-BE2, 4)
     MOVE 61 TO WS-Y MOVE "hopper" TO WS-K MOVE "facing" TO WS-PN MOVE "down" TO WS-PV
     PERFORM MAKE-DEF PERFORM SET-P PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 4) TO WS-A
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B
     MOVE "acceptance wrapb hopper 31-2 4.1 a hopper under a brewing stand takes a glass bottle of the reagent slot" TO WS-CASE
     MOVE "0 1 0" TO WS-EXP
     MOVE 0 TO WS-C
     PERFORM ASSERT-ABC
     STOP RUN.

 SWITCH-CONTENT.
*>   the standard content set with the brewing providers and two brewing recipes (the generated pack carries no brewing recipes), as acc_p70c_brew does
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/wrapb-brew-fix 2>/dev/null; rm -rf build/wrapb-brew-fix; mkdir -p build/wrapb-brew-fix && cp -R content/tests/fixtures/std "
         "build/wrapb-brew-fix/t && mkdir -p build/wrapb-brew-fix/t/vanilla-data/data/minecraft/context_int_provider/brewing && cd build/wrapb-brew-fix/t/"
         "vanilla-data/data/minecraft/context_int_provider/brewing && printf '20' > uses_default.json && printf '1.0' > speed_default.json"
         X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     CALL "FURN-PROVIDERS-LOAD" USING WS-DIRF
     MOVE 2 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2)
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE "minecraft:potion" TO RR-ING(1, 1)
     MOVE "minecraft:nether_wart" TO RR-ING(1, 2)
     MOVE "minecraft:potion" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE "minecraft:water minecraft:awkward" TO RR-EXTRA(1)
     MOVE "brewing/awkward" TO RR-KEY(1)
     MOVE 20 TO RR-SERIALIZER(2)
     MOVE "minecraft:potion" TO RR-ING(2, 1)
     MOVE "minecraft:sugar" TO RR-ING(2, 2)
     MOVE "minecraft:potion" TO RR-RESULT-ID(2)
     MOVE 1 TO RR-RESULT-COUNT(2)
     MOVE "minecraft:awkward minecraft:swiftness" TO RR-EXTRA(2)
     MOVE "brewing/swiftness" TO RR-KEY(2)
     MOVE CORE-ENTITY-TYPES TO WS-SAVE-TYPES
     MOVE CORE-ENTITY-ROLES TO WS-SAVE-ROLES
     CALL "BLOCKS-OPEN"
     CALL "CORE-TABLES-OPEN"
     MOVE WS-SAVE-TYPES TO CORE-ENTITY-TYPES
     MOVE WS-SAVE-ROLES TO CORE-ENTITY-ROLES.

 CLEAR-ROW.
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z
     PERFORM VARYING WS-NX FROM 0 BY 1 UNTIL WS-NX > 8
         MOVE WS-NX TO WS-X
         PERFORM VARYING WS-Y FROM 61 BY 1 UNTIL WS-Y > 64
             MOVE "air" TO WS-K
             PERFORM PUT-DEF
         END-PERFORM
     END-PERFORM.

 MAKE-HOPPER-EAST.
*>   a hopper facing east at (3, 101, WS-Z), its block entity in WS-BE
     MOVE 3 TO WS-X MOVE 61 TO WS-Y MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 ASSERT-ABC.
*>   WS-A, WS-B and WS-C as "a b c" against WS-EXP
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBS
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-HOPPER-BREW.

 COPY CORETEST.
 COPY PORTALTEST.
