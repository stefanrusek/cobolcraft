*> Real-data test (skipped as a pass without the generated packs; T1318 to T1328, docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md sections 3.1, 4.1, 5.1 and 6): the structure
*> records and structure sets of the generated vanilla data are loaded by STRUCT-LOAD and each parameter table row is a case: ancient_city (start pool city_center, size 7, start height -27, no heightmap,
*> max distance 116, no expansion hack, step underground_decoration = 7, terrain adaptation beard_box, set random_spread 24 / 8 / salt 20083232), trial_chambers (pool chamber/end, size 20, distance 116,
*> padding 10 and 10, ignore_waterlogging, encapsulate, step underground_structures = 3, set 34 / 12 / 94251327) and trail_ruins (pool tower, size 7, start height -15, heightmap WORLD_SURFACE_WG, distance 80,
*> bury, step 3, set 34 / 8 / 83469867), the abandoned camps of the section 6 table (18 records, pool abandoned_camp/tent/<biome>, size 2, height 0 with WORLD_SURFACE_WG, distance 80, hack on,
*> surface_structures = 4, beard_thin) and the record counts (52 structures, 28 of type jigsaw). Not read by the loader and so not checked: spawn_overrides (36-1 section 10 / struct-override.cob),
*> start_jigsaw_name, pool_aliases and the uniform start height of the trial chambers (their SDT-JIG-OK is 0: the assembler does not build them yet).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-10-PARAMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-JIG                 BINARY-LONG.
 01 WS-CAMPS               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TXT                 PIC X(80).
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
         MOVE "acceptance US12 36-10§3 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS

*>   section 6: the 52 records, 28 of type jigsaw (the type id of STRUCT-ENUM-ID)
     MOVE 0 TO WS-JIG WS-CAMPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-JIG-POOL(WS-I) NOT = SPACES
             ADD 1 TO WS-JIG
         END-IF
         IF SDT-KEY(WS-I)(1:25) = "minecraft:abandoned_camp_"
             ADD 1 TO WS-CAMPS
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-10§6 All jigsaw structures in this version and the parameters they use: 52 structure records" TO TL-CASE
     MOVE 52 TO TL-EXPECTED-N
     MOVE SD-ST-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§6 All jigsaw structures in this version and the parameters they use: 28 jigsaw records (3 + 6 + 1 + 18)" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-JIG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§6 All jigsaw structures in this version and the parameters they use: 18 abandoned camp records" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-CAMPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I)(1:25) = "minecraft:abandoned_camp_"
             IF SDT-JIG-SIZE(WS-I) NOT = 2 OR SDT-JIG-Y(WS-I) NOT = 0 OR SDT-JIG-PROJ(WS-I) NOT = 0
                 OR SDT-JIG-HOR(WS-I) NOT = 80 OR SDT-JIG-HACK(WS-I) NOT = 1 OR SDT-STEP(WS-I) NOT = 4
                 OR SDT-ADAPT(WS-I) NOT = 2 OR SDT-JIG-POOL(WS-I)(1:30) NOT = "minecraft:abandoned_camp/tent/"
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-10§6 All jigsaw structures in this version and the parameters they use: every camp has size 2, height 0, WORLD_SURFACE_WG, distance 80, hack, surface_structures, beard_thin and a tent pool" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   3.1 ancient city
     MOVE "minecraft:ancient_city" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "acceptance US12 36-10§3 Ancient city: start pool is ancient_city/city_center, size 7, start height -27" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-JIG-SIZE(WS-ROW) * 1000 + (0 - SDT-JIG-Y(WS-ROW))
     MOVE 7027 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§3 Ancient city: the pool is minecraft:ancient_city/city_center" TO TL-CASE
     PERFORM TEXT-OF-POOL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TXT = "minecraft:ancient_city/city_center"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§3 Ancient city: no heightmap projection (-1), distance 116 on every axis, no expansion hack" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SDT-JIG-PROJ(WS-ROW) + 1) * 10000000 + SDT-JIG-HOR(WS-ROW) * 10000 + SDT-JIG-VER(WS-ROW) * 10 + SDT-JIG-HACK(WS-ROW)
     COMPUTE TL-EXPECTED-N = 0 * 10000000 + 116 * 10000 + 116 * 10 + 0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§3 Ancient city: step underground_decoration (7) and terrain adaptation beard_box (3)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-STEP(WS-ROW) * 10 + SDT-ADAPT(WS-ROW)
     MOVE 73 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-SET
     MOVE "acceptance US12 36-10§3 Ancient city: its set is random_spread with spacing 24, separation 8" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-KIND(WS-SET) * 10000 + SS-SPACING(WS-SET) * 100 + SS-SEPARATION(WS-SET)
     MOVE 22408 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§3 Ancient city: salt 20083232" TO TL-CASE
     MOVE 20083232 TO TL-EXPECTED-N
     MOVE SS-SALT(WS-SET) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§3 Ancient city: the start jigsaw name is not read, so the assembler does not build it yet (SDT-JIG-OK 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   4.1 trial chambers
     MOVE "minecraft:trial_chambers" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "acceptance US12 36-10§4 Trial chambers: size 20, distance 116, dimension padding 10 and 10" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 20 * 1000000 + 116 * 1000 + 10 * 10 + 10
     COMPUTE TL-OBSERVED-N = SDT-JIG-SIZE(WS-ROW) * 1000000 + SDT-JIG-HOR(WS-ROW) * 1000 + SDT-JIG-PADB(WS-ROW) * 10 + SDT-JIG-PADT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§4 Trial chambers: liquid_settings ignore_waterlogging (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SDT-JIG-LIQ(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§4 Trial chambers: step underground_structures (3) and terrain adaptation encapsulate (4)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-STEP(WS-ROW) * 10 + SDT-ADAPT(WS-ROW)
     MOVE 34 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-SET
     MOVE "acceptance US12 36-10§4 Trial chambers: its set is random_spread with spacing 34, separation 12" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-KIND(WS-SET) * 10000 + SS-SPACING(WS-SET) * 100 + SS-SEPARATION(WS-SET)
     MOVE 23412 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§4 Trial chambers: salt 94251327" TO TL-CASE
     MOVE 94251327 TO TL-EXPECTED-N
     MOVE SS-SALT(WS-SET) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§4 Trial chambers: the pool aliases and the uniform start height are not built yet (SDT-JIG-OK 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   5.1 trail ruins
     MOVE "minecraft:trail_ruins" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "acceptance US12 36-10§5 Trail ruins: size 7, start height -15, WORLD_SURFACE_WG (0), distance 80" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-JIG-SIZE(WS-ROW) * 100000 + (0 - SDT-JIG-Y(WS-ROW)) * 1000 + SDT-JIG-PROJ(WS-ROW) * 500 + SDT-JIG-HOR(WS-ROW)
     COMPUTE TL-EXPECTED-N = 7 * 100000 + 15 * 1000 + 0 + 80
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§5 Trail ruins: the pool is minecraft:trail_ruins/tower" TO TL-CASE
     PERFORM TEXT-OF-POOL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TXT = "minecraft:trail_ruins/tower"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§5 Trail ruins: step underground_structures (3) and terrain adaptation bury (1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-STEP(WS-ROW) * 10 + SDT-ADAPT(WS-ROW)
     MOVE 31 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-SET
     MOVE "acceptance US12 36-10§5 Trail ruins: its set is random_spread with spacing 34, separation 8" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-KIND(WS-SET) * 10000 + SS-SPACING(WS-SET) * 100 + SS-SEPARATION(WS-SET)
     MOVE 23408 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§5 Trail ruins: salt 83469867" TO TL-CASE
     MOVE 83469867 TO TL-EXPECTED-N
     MOVE SS-SALT(WS-SET) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-10§5 Trail ruins: the assembler can build it (SDT-JIG-OK 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SDT-JIG-OK(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> FIND-ROW: WS-ROW the structure row of WS-KEY (0 when absent: the row 1 is used so the cases fail instead of reading row 0)
 FIND-ROW.
     MOVE 1 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     .
*> FIND-SET: WS-SET the set row that lists the structure of WS-ROW as an entry
 FIND-SET.
     MOVE 1 TO WS-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-I)
             IF SE-STRUCT(SS-EN-FIRST(WS-I) + WS-K) = WS-ROW
                 MOVE WS-I TO WS-SET
             END-IF
         END-PERFORM
     END-PERFORM
     .
 TEXT-OF-POOL.
     MOVE SDT-JIG-POOL(WS-ROW) TO WS-TXT
     .
 END PROGRAM TEST-STRUCT-36-10-PARAMS.
