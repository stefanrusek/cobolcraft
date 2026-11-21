*> Contract test, the core as provider of the world folder (T0332; docs/protocol/07 section 9.1, 9.2, 9.7; core-host-delta.md
*> section 3): after a save the folder holds level.dat with the flat root keys DataVersion, WorldType and Seed (no
*> ContentJar for a cobolcraft world), access.dat, players/ and, for a cobolcraft world with extra dimensions,
*> dimensions/cobolcraft/main and dimensions/cobolcraft/subroutine each with region/ and entities/ (at most three
*> dimension folders; none under minecraft/).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-WORLD-FOLDER-PROVIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FILE                PIC X(256) VALUE "build/core-test-world/level.dat".
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OBSERVED            PIC X(600).
 01 WS-CHECK               PIC X(256).
 01 WS-INFO                PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-LIST.
    05 FILLER PIC X(64) VALUE "access.dat".
    05 FILLER PIC X(64) VALUE "players".
    05 FILLER PIC X(64) VALUE "dimensions/cobolcraft/main/region".
    05 FILLER PIC X(64) VALUE "dimensions/cobolcraft/main/entities".
    05 FILLER PIC X(64) VALUE "dimensions/cobolcraft/subroutine/region".
    05 FILLER PIC X(64) VALUE "dimensions/cobolcraft/subroutine/entities".
    05 FILLER PIC X(64) VALUE "dimensions/minecraft".
 01 WS-TABLE REDEFINES WS-LIST.
    05 WS-ENTRY            PIC X(64) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE "7" TO CS-SEED-TEXT
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CORE-SAVE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "DataVersion" TO WS-PATH
             WHEN 2 MOVE "WorldType" TO WS-PATH
             WHEN 3 MOVE "Seed" TO WS-PATH
             WHEN OTHER MOVE "ContentJar" TO WS-PATH
         END-EVALUATE
         CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
         STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-OBSERVED
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "contract world folder provider level.dat root keys: DataVersion, WorldType, Seed, no ContentJar"
         TO TL-CASE
     MOVE "5023 cobolcraft 7 absent" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-CHECK
         STRING "build/core-test-world/" FUNCTION TRIM(WS-ENTRY(WS-I)) X"00" DELIMITED BY SIZE INTO WS-CHECK
         CALL "CBL_CHECK_FILE_EXIST" USING WS-CHECK WS-INFO
         IF RETURN-CODE = 0
             STRING FUNCTION TRIM(WS-OBSERVED) "Y" DELIMITED BY SIZE INTO WS-OBSERVED
         ELSE
             STRING FUNCTION TRIM(WS-OBSERVED) "n" DELIMITED BY SIZE INTO WS-OBSERVED
         END-IF
         MOVE 0 TO RETURN-CODE
     END-PERFORM
     MOVE "contract world folder provider the folder holds access.dat, players/, the two cobolcraft dimension folders and no minecraft folder"
         TO TL-CASE
     MOVE "YYYYYYn" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-WORLD-FOLDER-PROVIDER.

 COPY CORETEST.
