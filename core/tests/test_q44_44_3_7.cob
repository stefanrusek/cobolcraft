*> Test of 44 part 3 section 5 (raid persistence, 45-6 section 12.2 and 14.5; lane 002-lane-p49h, T22007): the raids of a standard world are written to
*> dimensions/minecraft/<dimension>/data/minecraft/raids.dat by the world save (next_id, tick and a raid compound with the thirteen keys) and read back when the world opens;
*> an ended raid is not resurrected (the file is rewritten without it); a cobolcraft world writes no file. Needs the generated packs (CC_GENERATED_DIR).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRWORLD.
 COPY DIMENSIONS.
 COPY RAIDSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-WANT                PIC X(400).
 01 WS-A                   BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-FILE                PIC X(128) VALUE Z"build/core-test-world/dimensions/minecraft/overworld/data/minecraft/raids.dat".
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ENV                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US15 44-3§5 raid persistence: no generated packs here, skipped" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE 1 TO WS-O
         CALL "Q3-EQ" USING WS-CASE WS-E WS-O
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE 8211 TO CW-TICKS
     INITIALIZE RD-STATE
     MOVE 3 TO RD-NEXT-ID
     MOVE 1 TO RD-USED(1) RD-STARTED(1)
     MOVE 2 TO RD-ID(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE 100 TO RD-CX(1)
     MOVE 64 TO RD-CY(1)
     MOVE -40 TO RD-CZ(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE 2 TO RD-GROUPS(1) RD-OMEN(1)
     MOVE 5400 TO RD-TICKS(1)
     MOVE 71000 TO RD-TOTAL(1)
     MOVE 1 TO RD-USED(2) RD-STARTED(2)
     MOVE 3 TO RD-ID(2)
     MOVE WS-DIM TO RD-DIM(2)
     MOVE 7 TO RD-CX(2)
     MOVE 70 TO RD-CY(2)
     MOVE 9 TO RD-CZ(2)
     MOVE 2 TO RD-STATUS(2)
     MOVE 5 TO RD-GROUPS(2) RD-OMEN(2)
     MOVE 7 TO RD-POST(2)
     MOVE 9000 TO RD-TICKS(2)
     MOVE 1 TO RD-USED(3) RD-STARTED(3)
     MOVE 4 TO RD-ID(3)
     MOVE WS-DIM TO RD-DIM(3)
     MOVE 3 TO RD-STATUS(3)
     MOVE 1 TO RD-USED(4)
     MOVE 5 TO RD-ID(4)
     MOVE WS-DIM TO RD-DIM(4)
     MOVE 4 TO RD-STATUS(4)
*>   The first raid has two heroes: a player in play and an entity id that no player holds.
     MOVE PL-ENTITY-ID(WS-ROW) TO RD-HERO(1, 1)
     MOVE 556 TO RD-HERO(1, 2)
     CALL "RAID-NBT-WRITE" USING PB-BUFFER WS-DIM
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "data" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "{next_id:3,tick:8211,raids:[{id:2,started:1,active:1,ticks_active:5400,raid_omen_level:2,groups_spawned:2,cooldown_ticks:0,post_raid_ticks:0,total_health:71.000,group_count:5,status:ongoing,center:I[100,64,-40],heroes_of_the_village:[I["
         TO WS-WANT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL FUNCTION TRIM(WS-WANT)
     MOVE "acceptance US15 44-3§5 the saved data holds next_id, tick and the first raid with its keys up to the heroes list (45-6 14.5)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL "[I["
     MOVE "acceptance US15 44-3§5 the heroes list holds one UUID (the player in play; the entity id no player holds is left out) in the whole file" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "{id:3,started:1,active:0,ticks_active:9000,raid_omen_level:5,groups_spawned:5,cooldown_ticks:0,post_raid_ticks:7,total_health:0.000,group_count:5,status:victory,center:I[7,70,9],heroes_of_the_village:[]},"
         TO WS-WANT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL FUNCTION TRIM(WS-WANT)
     MOVE "acceptance US15 44-3§5 a victorious raid is saved inactive with its status and post-raid ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "{id:4,started:1,active:0,ticks_active:0,raid_omen_level:0,groups_spawned:0,cooldown_ticks:0,post_raid_ticks:0,total_health:0.000,group_count:5,status:loss,center:I[0,0,0],heroes_of_the_village:[]},{id:5,started:0,active:0,ticks_active:0,raid_omen_level:0,groups_spawned:0,cooldown_ticks:0,post_raid_ticks:0,total_health:0.000,group_count:5,status:stopped,center:I[0,0,0],heroes_of_the_village:[]}]}"
         TO WS-WANT
     MOVE 0 TO WS-A
     INSPECT WS-TEXT TALLYING WS-A FOR ALL FUNCTION TRIM(WS-WANT)
     MOVE "acceptance US15 44-3§5 a lost and a stopped raid are saved with their status words" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A table with no free entry drops the raids it reads.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > RD-MAX
         MOVE 1 TO RD-USED(WS-A)
         MOVE 900 TO RD-ID(WS-A)
         MOVE 99 TO RD-DIM(WS-A)
     END-PERFORM
     CALL "RAID-NBT-READ" USING PB-BUFFER WS-DIM
     MOVE "acceptance US15 44-3§5 with every entry in use a raid read from the file is dropped" TO WS-CASE
     MOVE 900 TO WS-E
     MOVE RD-ID(1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > RD-MAX
         INITIALIZE RD-ENTRY(WS-A)
     END-PERFORM
     MOVE 3 TO RD-NEXT-ID
     MOVE 1 TO RD-USED(1) RD-STARTED(1)
     MOVE 2 TO RD-ID(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE 100 TO RD-CX(1)
     MOVE 64 TO RD-CY(1)
     MOVE -40 TO RD-CZ(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE 2 TO RD-GROUPS(1) RD-OMEN(1)
     MOVE 5400 TO RD-TICKS(1)
     MOVE 71000 TO RD-TOTAL(1)
     MOVE 1 TO RD-USED(2) RD-STARTED(2)
     MOVE 3 TO RD-ID(2)
     MOVE WS-DIM TO RD-DIM(2)
     MOVE 7 TO RD-CX(2)
     MOVE 70 TO RD-CY(2)
     MOVE 9 TO RD-CZ(2)
     MOVE 2 TO RD-STATUS(2)
     MOVE 5 TO RD-GROUPS(2) RD-OMEN(2)
     MOVE 7 TO RD-POST(2)
     MOVE 9000 TO RD-TICKS(2)
     MOVE 0 TO RD-USED(3) RD-USED(4)
*>   The world save writes the file; opening the world again reads the raids back.
     CALL "CORE-SAVE"
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     MOVE "acceptance US15 44-3§5 the world save wrote dimensions/minecraft/overworld/data/minecraft/raids.dat" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE RETURN-CODE TO WS-O
     MOVE 0 TO RETURN-CODE
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     INITIALIZE RD-STATE
*>   The settings of the standard world, as PT-OPEN made them.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-ENV TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE "acceptance US15 44-3§5 reopening the world restores next_id" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE RD-NEXT-ID TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 the first raid is back: id, dimension, centre" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE RD-ID(1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 the first raid is in the overworld" TO WS-CASE
     MOVE WS-DIM TO WS-E
     MOVE RD-DIM(1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 the first raid's centre z" TO WS-CASE
     MOVE -40 TO WS-E
     MOVE RD-CZ(1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 the first raid is ongoing and started" TO WS-CASE
     COMPUTE WS-E = 1 * 10 + 1
     COMPUTE WS-O = RD-STATUS(1) * 10 + RD-STARTED(1)
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 waves spawned, omen level and ticks active come back" TO WS-CASE
     COMPUTE WS-E = 2 * 1000000 + 2 * 100000 + 5400
     COMPUTE WS-O = RD-GROUPS(1) * 1000000 + RD-OMEN(1) * 100000 + RD-TICKS(1)
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 total health 71.0 comes back in thousandths" TO WS-CASE
     MOVE 71000 TO WS-E
     MOVE RD-TOTAL(1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§5 the second raid is a victory with 7 post-raid ticks" TO WS-CASE
     COMPUTE WS-E = 2 * 100 + 7
     COMPUTE WS-O = RD-STATUS(2) * 100 + RD-POST(2)
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A raid that ended and left the map is not resurrected: the next save rewrites the file without it.
     INITIALIZE RD-STATE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE "acceptance US15 44-3§5 after the raids ended the rewritten file holds none" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > RD-MAX
         ADD RD-USED(WS-A) TO WS-O
     END-PERFORM
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A file that cannot be read is an empty value.
     MOVE 1 TO RD-USED(1)
     CALL "SYSTEM" USING "echo junk > build/core-test-world/dimensions/minecraft/overworld/data/minecraft/raids.dat"
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE "acceptance US15 44-3§5 a raids.dat that is not NBT reads as no raids" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > RD-MAX
         ADD RD-USED(WS-A) TO WS-O
     END-PERFORM
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-7.
 COPY CORETEST.
 COPY PORTALTEST.
 COPY Q3TEST.
