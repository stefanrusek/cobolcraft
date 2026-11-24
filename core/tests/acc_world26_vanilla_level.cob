*> Acceptance test (world-types.md section 2.1 rule 3 and WT-26; docs/protocol/33 section 10): a world folder that
*> came from a real 26.3 game (level.dat holding one compound `Data`, no WorldType key, dimensions/minecraft/, the
*> seed in data/minecraft/world_gen_settings.dat) is recognised as a standard world and read: LevelName, GameType,
*> the game time of the day, the spawn position (`pos`) and the seed. The fixture is synthetic
*> (core/tests/fixtures/gen_world26.py). A level.dat with no `Data` and no WorldType stays refused (acc_f2us2_world_type).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WORLD26-VANILLA-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-COMMAND             PIC X(200).
 01 WS-FOLDER              PIC X(64) VALUE "build/w26-folder".
 01 WS-REQUEST             PIC X(10) VALUE SPACES.
 01 WS-TYPE                PIC X(10).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OBSERVED            PIC X(200).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(19)9.
 01 WS-D1                  PIC -(5)9.9.
 01 WS-D2                  PIC -(5)9.9.
 01 WS-D3                  PIC -(5)9.9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "rm -rf build/w26-folder && mkdir -p build/w26-folder/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp -R core/tests/fixtures/world26/. build/w26-folder/" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/w26-folder" TO CW-FOLDER
     MOVE 16 TO CW-FOLDER-LENGTH

     CALL "WORLD-TYPE-DECIDE" USING WS-REQUEST WS-TYPE WS-STATUS
     MOVE WS-STATUS TO WS-E1
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance world26 given a 26.3 level.dat with Data and no WorldType when the type is decided then it is standard"
         TO TL-CASE
     MOVE "0 standard" TO TL-EXPECTED
     PERFORM CHECK

     CALL "LEVEL-DAT-READ"
     MOVE SPACES TO WS-OBSERVED
     MOVE CW-GAME-MODE TO WS-E1
     MOVE CW-TIME TO WS-E2
     MOVE CW-SEED TO WS-E4
     STRING FUNCTION TRIM(CW-NAME) "|" FUNCTION TRIM(WS-E1) "|" FUNCTION TRIM(WS-E2) "|"
         FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance world26 given the 26.3 level.dat when it is read then name, mode, day time and seed are the file's"
         TO TL-CASE
     MOVE "Vanilla Fixture|1|4520|7891309618905890105" TO TL-EXPECTED
     PERFORM CHECK

     MOVE SPACES TO WS-OBSERVED
     MOVE CW-SPAWN-X TO WS-D1
     MOVE CW-SPAWN-Y TO WS-D2
     MOVE CW-SPAWN-Z TO WS-D3
     STRING FUNCTION TRIM(WS-D1) "|" FUNCTION TRIM(WS-D2) "|" FUNCTION TRIM(WS-D3) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE "acceptance world26 given spawn.pos 12 70 -34 when read then the spawn point is that position" TO TL-CASE
     MOVE "12.0|70.0|-34.0" TO TL-EXPECTED
     PERFORM CHECK

*>   No world_gen_settings.dat: the seed stays as it was (the in-memory value), nothing fails.
     MOVE "rm build/w26-folder/data/minecraft/world_gen_settings.dat" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 42 TO CW-SEED
     CALL "LEVEL-DAT-READ"
     MOVE CW-SEED TO WS-E4
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-E4) TO WS-OBSERVED
     MOVE "acceptance world26 given no world_gen_settings.dat when the level is read then the seed is unchanged" TO TL-CASE
     MOVE "42" TO TL-EXPECTED
     PERFORM CHECK
*>   A world with no access.dat loads (the lists stay empty), as a real 26.3 world does.
     CALL "WORLD-LOAD"
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(CW-NAME) TO WS-OBSERVED
     MOVE "acceptance world26 given a folder with no access.dat when the world is loaded then it loads" TO TL-CASE
     MOVE "Vanilla Fixture" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-WORLD26-VANILLA-LEVEL.

 COPY CORETEST.
