*> Implementation test of local packs (US18-1, US18-2; 08 §1.1, §1.3, §1.4; client-surface §2;
*> client/src/packs/local.cob, source.cob, stack.cob, game-dir.cob OPTIONS-LOAD and
*> OPTIONS-SAVE): resourcepacks/ zips and folders are listed with id file/<name> (a folder only with
*> pack.mcmeta, other files not at all); folder and zip sources serve their files under assets/
*> (invalid paths skipped); options.dat EnabledPacks round-trips.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOCAL-PACKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-NBT-CAP             BINARY-LONG VALUE 4096.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-INT-TYPE            BINARY-LONG VALUE 3.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-OPT-PATH            PIC X(1100).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-local-packs".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAMES               PIC X(256).
 01 WS-IDS                 PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-PACK                BINARY-LONG.
 01 WS-PACK-NO             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-AREA                PIC X(65536).
 01 WS-CAP                 BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FILE                PIC X(65536).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-SPRITE              PIC X(80).
 01 WS-SPRITE-LENGTH       BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-TEXT                PIC X(1024).
 01 WS-INFO                PIC X(16).
 PROCEDURE DIVISION.
     MOVE "alpha beta.zip notapack readme.txt broken.zip nometa.zip badmeta old.zip bigicon"
         TO WS-NAMES
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES

*>   Listing: byte order; a folder without pack.mcmeta and a plain file are not packs.
     MOVE "local packs resourcepacks/ zips and folders are listed with id file/<name>, kind and "
         & "validity" TO TL-CASE
     MOVE "file/alpha 1 1|file/badmeta 1 0|file/beta.zip 2 1|file/bigicon 1 1|file/broken.zip 2 "
         & "0|file/nometa.zip 2 0|file/old.zip 2 1|cobolcraft_faithful_skin 3 1|" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LP-COUNT
         MOVE LP-KIND(WS-I) TO WS-E1
         MOVE LP-VALID(WS-I) TO WS-E2
         STRING LP-ID(WS-I)(1:LP-ID-LENGTH(WS-I)) " " FUNCTION TRIM(WS-E1) " "
             FUNCTION TRIM(WS-E2) "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "local packs a pack's name is its file or folder name" TO TL-CASE
     MOVE "alpha|beta.zip" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING LP-NAME(1)(1:LP-NAME-LENGTH(1)) "|" LP-NAME(3)(1:LP-NAME-LENGTH(3))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A folder source: alpha on top of the built-in pack.
     MOVE "file/alpha" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "local packs an enabled pack is above the built-in pack in the stack" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     MOVE PK-KIND(2) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " PK-ID(2)(1:PK-ID-LENGTH(2))
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 1 file/alpha" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/block/greystone.png" TO WS-PATH
     MOVE 46 TO WS-PATH-LENGTH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
     CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP WS-LENGTH
         WS-FOUND
     MOVE SPACES TO WS-TEXT
     STRING "client/tests/fixtures/packs/alpha/" WS-PATH(1:WS-PATH-LENGTH) DELIMITED BY SIZE
         INTO WS-TEXT
     CALL "TEST-READ-FILE" USING WS-TEXT WS-FILE WS-CAP WS-FILE-LENGTH
     MOVE "local packs a folder source serves its file's bytes" TO TL-CASE
     MOVE "2 1 same" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-PACK TO WS-E1
     MOVE WS-FOUND TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-LENGTH = WS-FILE-LENGTH AND WS-LENGTH > 0
         IF WS-AREA(1:WS-LENGTH) = WS-FILE(1:WS-LENGTH)
             STRING TL-OBSERVED(1:3) " same" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP WS-W WS-H
         WS-FOUND
     MOVE "local packs a folder source decodes its texture" TO TL-CASE
     MOVE "16 16 1 10,200,10,255" TO TL-EXPECTED
     PERFORM SHOW-IMAGE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft:block/greystone" TO WS-SPRITE
     MOVE 26 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL
     MOVE "local packs the reload puts the folder's texture in the atlas" TO TL-CASE
     MOVE "10,200,10,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The folder's file list: only valid paths under assets/ (not pack.mcmeta, pack.png or
*>   .DS_Store).
     MOVE "local packs a folder source lists the files under assets/" TO TL-CASE
     MOVE 2 TO WS-PACK-NO
     PERFORM LIST-FILES
     MOVE "assets/cobolcraft/textures/block/greystone.png|" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A zip source: beta.zip.
     MOVE "file/beta.zip file/alpha" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "local packs a zip source lists its files under assets/; a path with upper-case "
         & "letters is skipped" TO TL-CASE
     MOVE 3 TO WS-PACK-NO
     PERFORM LIST-FILES
     MOVE "assets/cobolcraft/textures/block/greystone.png|assets/cobolcraft/textures/item/"
         & "trowel.png|" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/item/trowel.png" TO WS-PATH
     MOVE 42 TO WS-PATH-LENGTH
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP WS-W WS-H
         WS-FOUND
     MOVE "local packs a zip source decodes its texture" TO TL-CASE
     MOVE "16 16 1 200,200,10,255" TO TL-EXPECTED
     PERFORM SHOW-IMAGE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/block/greystone.png" TO WS-PATH
     MOVE 46 TO WS-PATH-LENGTH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
     CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP WS-LENGTH
         WS-FOUND
     MOVE "local packs the zip pack, enabled on top, wins over the folder below" TO TL-CASE
     MOVE "3 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-PACK TO WS-E1
     MOVE WS-FOUND TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/Block/Upper.png" TO WS-PATH
     MOVE 42 TO WS-PATH-LENGTH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
     MOVE "local packs a path with upper-case letters is not served" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A file the pack does not have; a capacity too small for it.
     MOVE "assets/cobolcraft/textures/item/trowel.png" TO WS-PATH
     MOVE 42 TO WS-PATH-LENGTH
     MOVE 3 TO WS-PACK-NO
     MOVE 8 TO WS-I
     CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK-NO WS-PATH WS-PATH-LENGTH WS-AREA WS-I
         WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE 2 TO WS-PACK-NO
     CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK-NO WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP
         WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-PACK
     CALL "PACK-SOURCE-IMAGE" USING CLIENT-STATE WS-PACK-NO WS-PATH WS-PATH-LENGTH WS-AREA WS-CAP
         WS-W WS-H WS-FOUND
     COMPUTE WS-E2 = WS-PACK + WS-FOUND
     MOVE 8 TO WS-I
     MOVE "assets/cobolcraft/textures/block/greystone.png" TO WS-PATH
     MOVE 46 TO WS-PATH-LENGTH
     CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK-NO WS-PATH WS-PATH-LENGTH WS-AREA WS-I
         WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E3
     MOVE "local packs reading into a too small area or a file the pack lacks finds nothing"
         TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   options.txt: resourcePacks (lowest first in the file), top first in memory, kept across a load.
     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     MOVE 0 TO OP-COUNT
     MOVE SPACES TO OP-ENABLED(1) OP-ENABLED(2)
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "local packs options.txt resourcePacks round-trips, top first" TO TL-CASE
     MOVE "2 file/beta.zip file/alpha" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE OP-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " OP-ID(1)(1:OP-ID-LENGTH(1)) " " OP-ID(2)(1:OP-ID-LENGTH(2))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-TEXT
     STRING WS-DIR(1:WS-DIR-LENGTH) "/options.txt" DELIMITED BY SIZE INTO WS-TEXT
     CALL "CBL_DELETE_FILE" USING WS-TEXT
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "local packs no options.txt: nothing is enabled" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE OP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Other tags, and a list of anything but strings, are skipped.
     CALL "PB-INIT" USING PB-BUFFER WS-NBT-CAP
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Other" TO WN
     MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-SEVEN
     MOVE "EnabledPacks" TO WN
     MOVE 12 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-INT-TYPE WS-ONE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WS-ELEMENT WS-SEVEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE SPACES TO WS-OPT-PATH
     STRING WS-DIR(1:WS-DIR-LENGTH) "/options.dat" DELIMITED BY SIZE INTO WS-OPT-PATH
     COMPUTE WS-OPT-LENGTH = WS-DIR-LENGTH + 12
     CALL "NBT-FILE-WRITE" USING WS-OPT-PATH WS-OPT-LENGTH PB-BUFFER WS-OUTCOME
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "local packs legacy options.dat (no options.txt): other tags and a list of non-strings are skipped" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE OP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A start-up reads options.txt and builds the stack from it.
     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     MOVE "file/alpha" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE "local packs a start-up builds the stack from options.txt" TO TL-CASE
     MOVE "2 file/alpha" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " PK-ID(2)(1:PK-ID-LENGTH(2)) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-IMAGE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-W TO WS-E1
     MOVE WS-H TO WS-E2
     MOVE WS-FOUND TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-E1 = FUNCTION ORD(WS-AREA(WS-I:1)) - 1
         IF WS-I > 1
             STRING "," DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM.

 LIST-FILES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-FOUND = 0
         CALL "PACK-SOURCE-PATH" USING CLIENT-STATE WS-PACK-NO WS-I WS-PATH WS-PATH-LENGTH
             WS-FOUND
         IF WS-FOUND = 1
             STRING WS-PATH(1:WS-PATH-LENGTH) "|" DELIMITED BY SIZE INTO TL-OBSERVED
                 WITH POINTER WS-PTR
         END-IF
     END-PERFORM.
 END PROGRAM TEST-LOCAL-PACKS.
 COPY CLTEST.
 COPY PACKTEST.
