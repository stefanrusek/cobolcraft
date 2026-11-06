*> Contract test, the client's reading side of the world folder (contracts/world-folder.md §2;
*> docs/protocol/07-nbt-and-anvil.md §9.2): a level.dat written as 07 §9.2 describes (built here with
*> proto NBT-FILE-WRITE: DataVersion, LevelName, GameMode, Time, Spawn, Weather) is read by the
*> client's world list (WORLDS-LIST) with its LevelName and GameMode; a world folder whose level.dat
*> cannot be read shows its folder name; a file in saves/ is not a world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-CONTRACT-WORLD-FOLDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(80)
     VALUE "build/client-test-world-folder/saves/valley/level.dat".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 53.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AXES                PIC X(3) VALUE "XYZ".
 01 WS-F                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-world-folder"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-world-folder" TO CL-GAME-DIR
     MOVE 30 TO CL-GAME-DIR-LENGTH
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "SYSTEM" USING "mkdir -p build/client-test-world-folder/saves/valley "
         & "build/client-test-world-folder/saves/broken"
     CALL "SYSTEM" USING "touch build/client-test-world-folder/saves/stray.txt"

*>   level.dat of 07 §9.2 (gzip NBT, unnamed root).
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN
     MOVE 11 TO WL
     MOVE 5023 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "LevelName" TO WN
     MOVE 9 TO WL
     MOVE "Shared Valley" TO WS-TEXT
     MOVE 13 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     MOVE "GameMode" TO WN
     MOVE 8 TO WL
     MOVE 1 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "Time" TO WN
     MOVE 4 TO WL
     MOVE 6000 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     MOVE "Spawn" TO WN
     MOVE 5 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Dimension" TO WN
     MOVE 9 TO WL
     MOVE "cobolcraft:main" TO WS-TEXT
     MOVE 15 TO WS-TEXT-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     MOVE 1 TO WL
     MOVE 0.5 TO WS-DOUBLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-AXES(WS-I:1) TO WN
         CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL WS-DOUBLE
     END-PERFORM
     MOVE "Yaw" TO WN
     MOVE 3 TO WL
     MOVE 0 TO WS-FLOAT
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "Weather" TO WN
     MOVE 7 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-FILE-WRITE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME

     CALL "WORLDS-LIST" USING CLIENT-STATE
     MOVE "contract client world folder a level.dat of 07 §9.2 gives the world list its LevelName "
         & "and GameMode; an unreadable one shows the folder name; a file is not a world" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "written 0 worlds 2 | broken broken 0 | valley Shared Valley 1" TO TL-EXPECTED
     MOVE WS-OUTCOME TO WS-E1
     MOVE WL-COUNT TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "written " FUNCTION TRIM(WS-E1) " worlds " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WL-COUNT
         MOVE WL-MODE(WS-I) TO WS-E1
         MOVE WL-FOLDER-LENGTH(WS-I) TO WS-F
         MOVE WL-NAME-LENGTH(WS-I) TO WS-N
         STRING FUNCTION TRIM(TL-OBSERVED) " | " WL-FOLDER(WS-I)(1:WS-F) " "
             WL-NAME(WS-I)(1:WS-N) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CL-CONTRACT-WORLD-FOLDER.
 COPY CLTEST.
