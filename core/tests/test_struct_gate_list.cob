*> Implementation test of the structure gate list of WORLD-GEN-DATA-OPEN (core/src/api.cob): a standard world switches on every structure the pipeline can place
*> in a world of the 26.3 standard type (docs/protocol 36-1 to 36-10 and 37-6), the ocean monument (36-6 section 5), the ancient city, the trial chambers and the trail ruins (36-10)
*> among them; a cobolcraft world switches none on. The key list is that of the structure records of the generated data (worldgen/structure), with the Nether and
*> End structures that the dimensions' own generators place (the fortress, the bastion remnant, the end city and, since T51501, the nether fossil).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-GATE-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-TYPE                PIC X(10).
 01 WS-DIR                 PIC X(1024) VALUE "build/struct-gate-list".
 01 WS-COMMAND             PIC X(300).
 01 WS-KEY                 PIC X(80).
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(80) VALUE "minecraft:monument".
    05 FILLER PIC X(80) VALUE "minecraft:ancient_city".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers".
    05 FILLER PIC X(80) VALUE "minecraft:trail_ruins".
    05 FILLER PIC X(80) VALUE "minecraft:mineshaft".
    05 FILLER PIC X(80) VALUE "minecraft:mineshaft_mesa".
    05 FILLER PIC X(80) VALUE "minecraft:igloo".
    05 FILLER PIC X(80) VALUE "minecraft:shipwreck".
    05 FILLER PIC X(80) VALUE "minecraft:shipwreck_beached".
    05 FILLER PIC X(80) VALUE "minecraft:ocean_ruin_warm".
    05 FILLER PIC X(80) VALUE "minecraft:ocean_ruin_cold".
    05 FILLER PIC X(80) VALUE "minecraft:pillager_outpost".
    05 FILLER PIC X(80) VALUE "minecraft:village_plains".
    05 FILLER PIC X(80) VALUE "minecraft:village_desert".
    05 FILLER PIC X(80) VALUE "minecraft:village_savanna".
    05 FILLER PIC X(80) VALUE "minecraft:village_snowy".
    05 FILLER PIC X(80) VALUE "minecraft:village_taiga".
    05 FILLER PIC X(80) VALUE "minecraft:stronghold".
    05 FILLER PIC X(80) VALUE "minecraft:mansion".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_desert".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_jungle".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_swamp".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_mountain".
    05 FILLER PIC X(80) VALUE "minecraft:ruined_portal_ocean".
    05 FILLER PIC X(80) VALUE "minecraft:swamp_hut".
    05 FILLER PIC X(80) VALUE "minecraft:jungle_pyramid".
    05 FILLER PIC X(80) VALUE "minecraft:desert_pyramid".
    05 FILLER PIC X(80) VALUE "minecraft:buried_treasure".
    05 FILLER PIC X(80) VALUE "minecraft:fortress".
    05 FILLER PIC X(80) VALUE "minecraft:end_city".
    05 FILLER PIC X(80) VALUE "minecraft:bastion_remnant".
    05 FILLER PIC X(80) VALUE "minecraft:nether_fossil".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-ENTRY        PIC X(80) OCCURS 33 TIMES.
 PROCEDURE DIVISION.
     MOVE "rm -rf build/struct-gate-list && mkdir -p build/struct-gate-list && cp -R core/tests/fixtures/terrain build/struct-gate-list/vanilla-data"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "N" TO TL-MODE
     MOVE "cobolcraft" TO WS-TYPE
     CALL "STRUCT-GATE-RESET"
     CALL "WORLD-GEN-DATA-OPEN" USING WS-TYPE WS-DIR
     MOVE "acceptance US12 36-10§1 Where the line is drawn for these three structures: given a cobolcraft world when the data is opened then no structure is on" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SD-GATE-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-GEN-DATA-OPEN" USING WS-TYPE WS-DIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         MOVE WS-KEY-ENTRY(WS-I) TO WS-KEY
         CALL "STRUCT-GATE" USING WS-KEY WS-FLAG
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-10§1 Where the line is drawn for these three structures: given a standard world when the data is opened then " FUNCTION TRIM(WS-KEY) " is on" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FLAG TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "acceptance US12 36-10§1 Where the line is drawn for these three structures: given a standard world when the data is opened then exactly the 33 listed structures are on" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE SD-GATE-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-GATE-LIST.
