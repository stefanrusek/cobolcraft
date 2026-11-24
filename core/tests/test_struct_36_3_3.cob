*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 3, data the engine interprets): the jigsaw fields of the structure files
*> (3.1: start_pool, start_jigsaw_name, size, start_height as an absolute or a uniform provider, project_start_to_heightmap, use_expansion_hack, max_distance_from_center as an int or an object,
*> pool_aliases, dimension_padding, liquid_settings) of the ancient city, the trial chambers, the plains village, the bastion remnant and the trail ruins; all 28 jigsaw structures of the pack are
*> buildable; JigsawStructure.verifyRange (horizontal distance plus 12 for any terrain adaptation at most 128) on edited files; the jigsaw blocks of a template with their block entity data
*> (3.5: name, target, pool, joint with its default by the front, both priorities) for the 29 jigsaws of trial_chambers/chamber/chamber_1 against the independent reader of gen_jigsaw.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY JSONDOC.
 01 JG-DATA.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/addon".
    05 FILLER PIC X(80) VALUE "minecraft:c1_breeze".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/reward/ominous_vault".
    05 FILLER PIC X(80) VALUE "minecraft:ominous_vault".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/decor/disposal".
    05 FILLER PIC X(80) VALUE "minecraft:disposal".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/addon".
    05 FILLER PIC X(80) VALUE "minecraft:middle_start".
    05 FILLER BINARY-LONG VALUE 23.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:in_connector".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/entrance_cap".
    05 FILLER PIC X(80) VALUE "minecraft:entrance_cap".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/decor/disposal".
    05 FILLER PIC X(80) VALUE "minecraft:disposal".
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 27.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/decor/disposal".
    05 FILLER PIC X(80) VALUE "minecraft:disposal".
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/decor/disposal".
    05 FILLER PIC X(80) VALUE "minecraft:disposal".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:in_connector".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/entrance_cap".
    05 FILLER PIC X(80) VALUE "minecraft:entrance_cap".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/addon".
    05 FILLER PIC X(80) VALUE "minecraft:upper_start".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 25.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 27.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:in_connector".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/entrance_cap".
    05 FILLER PIC X(80) VALUE "minecraft:entrance_cap".
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/addon".
    05 FILLER PIC X(80) VALUE "minecraft:upper_start".
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 27.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/addon".
    05 FILLER PIC X(80) VALUE "minecraft:upper_start".
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 28.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:in_connector".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/chamber/entrance_cap".
    05 FILLER PIC X(80) VALUE "minecraft:entrance_cap".
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 27.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 18.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 27.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 18.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
    05 FILLER BINARY-LONG VALUE 22.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 23.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(80) VALUE "minecraft:empty".
    05 FILLER PIC X(80) VALUE "minecraft:trial_chambers/dispensers/chamber".
    05 FILLER PIC X(80) VALUE "minecraft:copper_dispenser".
 01 JG-TAB REDEFINES JG-DATA.
    05 JG-ROW OCCURS 29 TIMES.
       10 JGE-X BINARY-LONG.
       10 JGE-Y BINARY-LONG.
       10 JGE-Z BINARY-LONG.
       10 JGE-FRONT BINARY-LONG.
       10 JGE-TOP BINARY-LONG.
       10 JGE-JOINT BINARY-LONG.
       10 JGE-PLACE BINARY-LONG.
       10 JGE-SELECT BINARY-LONG.
       10 JGE-NAME PIC X(80).
       10 JGE-POOL PIC X(80).
       10 JGE-TARGET PIC X(80).
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CITY                BINARY-LONG.
 01 WS-TRIAL               BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-BASTION             BINARY-LONG.
 01 WS-TRAIL               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40) VALUE "jigsaw".
 01 WS-TYPE-ID             BINARY-LONG.
 01 WS-TEXT                PIC X(1000).
 01 WS-LEN                 BINARY-LONG.
 01 WS-TID                 PIC X(96) VALUE "minecraft:trial_chambers/chamber/chamber_1".
 01 WS-TROW                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-CASE                PIC X(200).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-3§3 Data the engine interprets: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
*>   the block states of the jigsaw blocks (their orientations) need the content set of an opened standard world
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-ENV TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-JIG-OK(WS-I) = 1
             ADD 1 TO WS-N
         END-IF
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:ancient_city"
                 MOVE WS-I TO WS-CITY
             WHEN "minecraft:trial_chambers"
                 MOVE WS-I TO WS-TRIAL
             WHEN "minecraft:village_plains"
                 MOVE WS-I TO WS-PLAINS
             WHEN "minecraft:bastion_remnant"
                 MOVE WS-I TO WS-BASTION
             WHEN "minecraft:trail_ruins"
                 MOVE WS-I TO WS-TRAIL
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-3§3.1 all 28 jigsaw structures of the pack are read as buildable (none uses a field the engine lacks) and no other type is" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ancient city: absolute -27, start_jigsaw_name, beard_box, 116
     MOVE "acceptance US12 36-3§3.1 ancient_city: size 7, absolute start height -27, no heightmap, no hack, distance 116 (vertical 4064), liquid default" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-SIZE(WS-CITY) = 7 AND SDT-JIG-Y(WS-CITY) = -27 AND SDT-JIG-YKIND(WS-CITY) = 0 AND SDT-JIG-PROJ(WS-CITY) = -1
        AND SDT-JIG-HACK(WS-CITY) = 0 AND SDT-JIG-HOR(WS-CITY) = 116 AND SDT-JIG-VER(WS-CITY) = 116 AND SDT-JIG-LIQ(WS-CITY) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-3§3.1 ancient_city: start_jigsaw_name is minecraft:city_anchor, terrain_adaptation beard_box (3), no dimension_padding, no alias" TO TL-CASE
     MOVE 1030 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SDT-JIG-NAMED(WS-CITY) * 1000 + SDT-ADAPT(WS-CITY) * 10 + SDT-JIG-PADSET(WS-CITY) + SDT-JIG-AL-N(WS-CITY)
     IF SDT-JIG-NAME(WS-CITY) NOT = "minecraft:city_anchor"
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   trial chambers: uniform -40 to -20, padding 10 as an int (both sides), ignore_waterlogging, encapsulate, three alias bindings
     MOVE "acceptance US12 36-3§3.1 trial_chambers: size 20, a uniform start height from -40 to -20, distance 116 (an int: vertical 116 too), no start jigsaw name" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-SIZE(WS-TRIAL) = 20 AND SDT-JIG-YKIND(WS-TRIAL) = 1 AND SDT-JIG-Y(WS-TRIAL) = -40 AND SDT-JIG-Y2(WS-TRIAL) = -20
        AND SDT-JIG-HOR(WS-TRIAL) = 116 AND SDT-JIG-VER(WS-TRIAL) = 116 AND SDT-JIG-NAMED(WS-TRIAL) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-3§3.1 trial_chambers: dimension_padding 10 is decoded (both sides), liquid ignore_waterlogging, encapsulate (4), no heightmap, three alias bindings" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-PADSET(WS-TRIAL) = 1 AND SDT-JIG-PADB(WS-TRIAL) = 10 AND SDT-JIG-PADT(WS-TRIAL) = 10 AND SDT-JIG-LIQ(WS-TRIAL) = 1
        AND SDT-ADAPT(WS-TRIAL) = 4 AND SDT-JIG-PROJ(WS-TRIAL) = -1 AND SDT-JIG-AL-N(WS-TRIAL) = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the plains village
     MOVE "acceptance US12 36-3§3.1 village_plains: town_centers, size 6, WORLD_SURFACE_WG, expansion hack, distance 80, beard_thin (2), padding absent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-POOL(WS-PLAINS) = "minecraft:village/plains/town_centers" AND SDT-JIG-SIZE(WS-PLAINS) = 6 AND SDT-JIG-PROJ(WS-PLAINS) = 0
        AND SDT-JIG-HACK(WS-PLAINS) = 1 AND SDT-JIG-HOR(WS-PLAINS) = 80 AND SDT-ADAPT(WS-PLAINS) = 2 AND SDT-JIG-PADSET(WS-PLAINS) = 0
        AND SDT-JIG-NAMED(WS-PLAINS) = 0 AND SDT-JIG-AL-N(WS-PLAINS) = 0 AND SDT-JIG-YKIND(WS-PLAINS) = 0 AND SDT-JIG-Y(WS-PLAINS) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-3§3.1 bastion_remnant (size 6, no heightmap, no adaptation) and trail_ruins (size 7, WORLD_SURFACE_WG, bury 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-SIZE(WS-BASTION) = 6 AND SDT-JIG-PROJ(WS-BASTION) = -1 AND SDT-ADAPT(WS-BASTION) = 0 AND SDT-JIG-HACK(WS-BASTION) = 0
        AND SDT-JIG-SIZE(WS-TRAIL) = 7 AND SDT-JIG-PROJ(WS-TRAIL) = 0 AND SDT-ADAPT(WS-TRAIL) = 1 AND SDT-JIG-HACK(WS-TRAIL) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VERIFY-RANGE-CASES
     PERFORM BLOCK-CASES
     STOP RUN.

*> JigsawStructure.verifyRange on a file edited in memory: the row 128 holds the structure
 VERIFY-RANGE-CASES.
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-TYPE-ID
     MOVE WS-TYPE-ID TO SDT-TYPE(128)
     MOVE 0 TO SDT-ADAPT(128)
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": 128}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 verifyRange: distance 128 with terrain_adaptation none (extra 0) is accepted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(128) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO SDT-ADAPT(128)
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 verifyRange: distance 128 with beard_box (extra 12) is rejected" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(128) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": 116}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 verifyRange: distance 116 with beard_box (116 + 12 = 128) is accepted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(128) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": {"horizontal": 117, "vertical": 40}}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 verifyRange: an object distance of 117 horizontal (vertical 40) with beard_box is rejected; the vertical is read" TO TL-CASE
     MOVE 40000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SDT-JIG-OK(128) * 1000000 + SDT-JIG-VER(128) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SDT-ADAPT(128)
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 an object distance with only horizontal 117 has the default vertical 4064 (adaptation none)" TO TL-CASE
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": {"horizontal": 117}}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE 1004064 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SDT-JIG-OK(128) * 1000000 + SDT-JIG-VER(128)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"type": "minecraft:trapezoid"}, "use_expansion_hack": false, "max_distance_from_center": 80}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 a start height of a provider the engine does not read is not buildable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(128) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"type": "minecraft:uniform", "min_inclusive": {"absolute": 5}, "max_inclusive": {"absolute": 9}}, "use_expansion_hack": false, "max_distance_from_center": 80}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 a uniform start height from 5 to 9 is read as kind 1 with both ends" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-OK(128) = 1 AND SDT-JIG-YKIND(128) = 1 AND SDT-JIG-Y(128) = 5 AND SDT-JIG-Y2(128) = 9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": 80, "pool_aliases": [{"type": "minecraft:foo"}]}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.4 a malformed alias binding makes the structure not buildable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(128) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:jigsaw", "start_pool": "minecraft:a", "size": 3, "start_height": {"absolute": 0}, "use_expansion_hack": false, "max_distance_from_center": 80, "start_jigsaw_name": "x:y", "dimension_padding": {"bottom": 3}}' TO WS-TEXT
     PERFORM READ-ROW
     MOVE "acceptance US12 36-3§3.1 start_jigsaw_name gets its namespace (minecraft:) and a padding object defaults the missing side to 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-JIG-NAME(128) = "x:y" AND SDT-JIG-PADSET(128) = 1 AND SDT-JIG-PADB(128) = 3 AND SDT-JIG-PADT(128) = 0 AND SDT-JIG-NAMED(128) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 READ-ROW.
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     MOVE 0 TO SD-AL-COUNT SD-AL-ECOUNT
     CALL "STRUCT-JIG-READ" USING JSON-DOC 128
     .

*> 3.5: the jigsaw blocks of trial_chambers/chamber/chamber_1 against the independent reader
 BLOCK-CASES.
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-TID WS-TROW
     CALL "JIG-TPL-JIGS" USING WS-TROW WS-FIRST WS-COUNT
     MOVE "acceptance US12 36-3§3.5 chamber_1 holds 29 jigsaw blocks with block entity data" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-COUNT
             COMPUTE WS-N = WS-FIRST + WS-J
             IF JX-X(WS-N) = JGE-X(WS-I) AND JX-Y(WS-N) = JGE-Y(WS-I) AND JX-Z(WS-N) = JGE-Z(WS-I)
                 ADD 1 TO WS-SEEN
                 MOVE JX-TAG(WS-N) TO WS-TAG
                 IF JX-FRONT(WS-N) NOT = JGE-FRONT(WS-I) OR JX-TOP(WS-N) NOT = JGE-TOP(WS-I) OR JX-JOINT(WS-N) NOT = JGE-JOINT(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
                 IF TN-NAME(WS-TAG) NOT = JGE-NAME(WS-I) OR TN-POOL(WS-TAG) NOT = JGE-POOL(WS-I) OR TN-TARGET(WS-TAG) NOT = JGE-TARGET(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
                 IF TN-PRIO-PLACE(WS-TAG) NOT = JGE-PLACE(WS-I) OR TN-PRIO-SELECT(WS-TAG) NOT = JGE-SELECT(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-3§3.5 every jigsaw of chamber_1 is found by position and its front, top, joint (aligned for a horizontal front, else rollable), name, pool, target and two priorities are the data's" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     IF WS-BAD = 0
         MOVE WS-SEEN TO TL-OBSERVED-N
     ELSE
         MOVE WS-BAD TO TL-OBSERVED-N
         ADD 1000 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-STRUCT-36-3-3.

 COPY NOSPAWN.
 COPY CORETEST.
