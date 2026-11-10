*> Implementation test of the world folder of docs/protocol/07 section 9 (T0330; world-types section 2.1, WT-23): level.dat
*> carries WorldType, Seed and ContentJar (absent for a cobolcraft world); a cobolcraft world has its two dimension
*> folders under dimensions/cobolcraft; reopening yields the same type and seed; the hidden type debug is read and
*> kept; a chunk whose palette holds a key of another world type is not loaded (CK-FOREIGN, one console line, never
*> generated over and never rewritten); a standard world writes the minecraft: namespace on keys the content set
*> stores without it (PERSIST-NAMESPACED).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PERSISTENCE-SPLIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CELLS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-FILE                PIC X(256) VALUE "build/core-test-world/level.dat".
 01 WS-FILE-1100           PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-CREATED             BINARY-LONG.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CHECK-PATH          PIC X(256).
 01 WS-INFO                PIC X(16).
 01 WS-EDIT                PIC -(9)9.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-REGION-DIR          PIC X(256).
 01 WS-REGION-LENGTH       BINARY-LONG.
 01 WS-AREA                PIC X(4096).
 01 WS-LENGTH-BEFORE       BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(64).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 B-BYTES                PIC X(262144) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE "12345" TO CS-SEED-TEXT
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CORE-SAVE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "WorldType" TO WS-PATH PERFORM ADD-GET
     MOVE "Seed" TO WS-PATH PERFORM ADD-GET
     MOVE "ContentJar" TO WS-PATH PERFORM ADD-GET
     MOVE "T" TO TL-MODE
     MOVE "test persistence split a new cobolcraft world's level.dat has WorldType and Seed, no ContentJar"
         TO TL-CASE
     MOVE "cobolcraft 12345 absent" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/core-test-world/dimensions/cobolcraft/main/region" TO WS-CHECK-PATH
     PERFORM CHECK-FOLDER
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OBSERVED
     MOVE "build/core-test-world/dimensions/cobolcraft/subroutine/region" TO WS-CHECK-PATH
     PERFORM CHECK-FOLDER
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "build/core-test-world/dimensions/minecraft" TO WS-CHECK-PATH
     PERFORM CHECK-FOLDER
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "test persistence split a cobolcraft world has its two dimension folders and no minecraft folder"
         TO TL-CASE
     MOVE "0 0 35" TO TL-EXPECTED
     PERFORM CHECK

*>   Reopen: the same type and seed.
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE SPACES TO CS-SEED-TEXT
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(CW-WORLD-TYPE) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE CW-SEED TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "test persistence split reopening the folder yields the same type and seed" TO TL-CASE
     MOVE "0 cobolcraft 12345" TO TL-EXPECTED
     PERFORM CHECK

*>   The hidden type debug is read and kept (no content open here: the programs are called directly).
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "WorldType" TO WN MOVE 9 TO WL
     MOVE 5 TO WS-HITS
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL "debug" WS-HITS
     MOVE "Seed" TO WN MOVE 4 TO WL
     MOVE -7 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE SPACES TO WS-FILE-1100
     MOVE "build/core-test-world/level.dat" TO WS-FILE-1100
     MOVE 31 TO WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE-1100 WS-FILE-LENGTH PB-BUFFER
     CALL "LEVEL-DAT-READ"
     MOVE SPACES TO WS-OBSERVED
     MOVE CW-SEED TO WS-EDIT
     STRING FUNCTION TRIM(CW-WORLD-TYPE) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     CALL "LEVEL-DAT-WRITE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "WorldType" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "test persistence split a level.dat of the hidden type debug is read and written back as debug"
         TO TL-CASE
     MOVE "debug -7 debug" TO TL-EXPECTED
     PERFORM CHECK

*>   WT-23: a palette key of another world type fails closed.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-NBT-WRITE" USING WS-ROW PB-BUFFER
     SET ADDRESS OF B-BYTES TO PB-ADDR
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-LENGTH - 19
         IF B-BYTES(WS-I:20) = "cobolcraft:greystone"
             MOVE "foreignmod:greystone" TO B-BYTES(WS-I:20)
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE "N" TO TL-MODE
     MOVE "test persistence split a chunk with a foreign palette key reads as outcome 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The foreign payload in the region file of chunk (6, 6): loading flags it, says so once, and saving leaves the file.
     MOVE 6 TO WS-CX WS-CZ
     MOVE SPACES TO WS-REGION-DIR
     MOVE "build/core-test-world/dimensions/cobolcraft/main/region" TO WS-REGION-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-REGION-DIR)) TO WS-REGION-LENGTH
     CALL "REGION-WRITE" USING WS-REGION-DIR WS-REGION-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE PB-LENGTH TO WS-LENGTH-BEFORE
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE CK-FOREIGN(WS-ROW) TO TL-OBSERVED-N
     MOVE "test persistence split loading the foreign chunk flags it CK-FOREIGN" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-AREA
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE "T" TO TL-MODE
     MOVE "test persistence split the foreign chunk is reported on the console" TO TL-CASE
     MOVE "chunk 6 6 in cobolcraft:main holds content of another world type and was not loaded"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF CB-LENGTH > 1
         MOVE WS-AREA(1:CB-LENGTH - 1) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO CK-CHANGED(WS-ROW)
     CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "REGION-READ" USING WS-REGION-DIR WS-REGION-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE "N" TO TL-MODE
     MOVE "test persistence split saving a foreign chunk leaves its region payload as found" TO TL-CASE
     MOVE WS-LENGTH-BEFORE TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Standard worlds write namespaced keys; the cobolcraft ones are written as stored.
     MOVE "stone" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "PERSIST-NAMESPACED" USING WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-OUT(1:WS-OUT-LENGTH) TO WS-OBSERVED
     MOVE "cobolcraft:turf" TO WS-KEY
     MOVE 15 TO WS-KEY-LENGTH
     CALL "PERSIST-NAMESPACED" USING WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     STRING FUNCTION TRIM(WS-OBSERVED) " " WS-OUT(1:WS-OUT-LENGTH) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE "stone" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     CALL "PERSIST-NAMESPACED" USING WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     STRING FUNCTION TRIM(WS-OBSERVED) " " WS-OUT(1:WS-OUT-LENGTH) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "test persistence split standard keys get minecraft:, keys with a namespace and cobolcraft keys do not"
         TO TL-CASE
     MOVE "minecraft:stone cobolcraft:turf stone" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK-FOLDER.
     MOVE FUNCTION TRIM(WS-CHECK-PATH) TO WS-CHECK-PATH
     INSPECT WS-CHECK-PATH REPLACING TRAILING SPACES BY LOW-VALUES
     CALL "CBL_CHECK_FILE_EXIST" USING WS-CHECK-PATH WS-INFO
     MOVE RETURN-CODE TO WS-EDIT
     MOVE 0 TO RETURN-CODE.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PERSISTENCE-SPLIT.

 COPY CORETEST.
