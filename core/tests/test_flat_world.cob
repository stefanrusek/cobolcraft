*> Implementation test (superflat lane; docs/design/world-types.md superflat, docs/protocol/56-superflat-world.md sections 2.5, 5.1 and 5.2): the
*> `superflat` world type at the open and the save of a world and in the spawn info of Login and Respawn.
*>   - WORLD-TYPE-DECIDE accepts superflat for a new world; WORLD-CONTENT-OPEN opens the standard content set for it (packs not ok is
*>     refused with the packs status, as for standard); CORE-WORLD-OPEN of a new superflat world with the packs not ok is refused (-1).
*>   - A world saved as superflat records WorldType = superflat in level.dat (LEVEL-PEEK-TYPE reads it back), a reopen of the folder decides
*>     superflat whatever type is requested, and the save writes data/minecraft/world_gen_settings.dat with the flat settings.
*>   - The spawn info (PLAY-SPAWN-INFO-BUILD, also inside Respawn): "is flat" is true and the sea level -63 for the overworld of a
*>     superflat world, false and 63 for a standard and a debug world (56 section 5.1 and 5.2); a negative sea level is a 5-byte VarInt.
*>   - WORLD-GEN-OWN: 1 for debug and superflat (they have their own generators), 0 for standard and cobolcraft.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLAT-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY FLATSET.
 COPY PROTO.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/flat-world-folder".
 01 WS-COMMAND             PIC X(200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TYPE                PIC X(10).
 01 WS-PRESET              PIC X(40).
 01 WS-REQUEST             PIC X(10).
 01 WS-DIR                 PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-MODE                PIC 9 VALUE 1.
 01 WS-KEEP                BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-DEBUG-FLAG          BINARY-LONG.
 01 WS-FLAT-FLAG           BINARY-LONG.
 01 WS-DEATH-FLAG          BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-D1                  PIC 9.
 01 WS-D2                  PIC 9.
 01 WS-D3                  PIC 9.
 01 WS-NUM                 PIC -(9)9.
 01 WS-NUM2                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "rm -rf build/flat-world-folder && mkdir -p build/flat-world-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE "build/no-such-generated-dir" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "test flat world a new superflat world with the packs not ok is refused -1 and is not open" TO TL-CASE
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " CW-OPEN DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-1 N" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "build/no-such-generated-dir" TO WS-DIR
     MOVE "superflat" TO WS-TYPE
     CALL "WORLD-CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test flat world the content set of superflat is the standard set: packs not ok gives the packs status" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE CORE-WO-PACKS-NOT-OK TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "rm -rf build/flat-world-folder && mkdir -p build/flat-world-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "superflat" TO WS-REQUEST
     CALL "WORLD-TYPE-DECIDE" USING WS-REQUEST WS-TYPE WS-STATUS
     MOVE "test flat world WORLD-TYPE-DECIDE accepts superflat for a folder with no world" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 superflat" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a world saved as superflat records it, reopens as superflat and has its flat settings in world_gen_settings.dat
     MOVE "superflat" TO CW-WORLD-TYPE
     MOVE "tunnelers_dream" TO WS-PRESET
     CALL "FLAT-PRESET-SET" USING WS-PRESET WS-STATUS
     CALL "CORE-SAVE"
     CALL "LEVEL-PEEK-TYPE" USING WS-FOUND WS-TEXT
     MOVE "test flat world level.dat of a world saved as superflat holds WorldType = superflat" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 superflat" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO WS-REQUEST
     CALL "WORLD-TYPE-DECIDE" USING WS-REQUEST WS-TYPE WS-STATUS
     MOVE "test flat world a reopen of the folder decides superflat whatever type is requested" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 superflat" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FS-LAYER-COUNT
     MOVE SPACES TO FS-BIOME
     CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
     MOVE "test flat world the save wrote the flat settings: world_gen_settings.dat loads with tunnelers_dream's layers and biome" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-EDIT
     MOVE FS-L-HEIGHT(2) TO WS-NUM
     MOVE FS-LAYER-COUNT TO WS-NUM2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-NUM2) " " FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(FS-BIOME) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 4 230 minecraft:windswept_hills" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the spawn info: Login and Respawn build it with PLAY-SPAWN-INFO-BUILD (dimension type id, key, hashed seed, game mode, previous game mode,
*>   is debug, is flat, has death location, portal cooldown, sea level)
     MOVE "superflat" TO CW-WORLD-TYPE
     PERFORM SPAWN-INFO-OF-OVERWORLD
     MOVE "test flat world the overworld of a superflat world sends is flat true and sea level -63" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "debug " WS-D1 " flat " WS-D2 " death " WS-D3 " sea " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "debug 0 flat 1 death 0 sea -63" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO CW-WORLD-TYPE
     PERFORM SPAWN-INFO-OF-OVERWORLD
     MOVE "test flat world the overworld of a standard world sends is flat false and sea level 63 (unchanged)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "debug " WS-D1 " flat " WS-D2 " death " WS-D3 " sea " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "debug 0 flat 0 death 0 sea 63" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "debug" TO CW-WORLD-TYPE
     PERFORM SPAWN-INFO-OF-OVERWORLD
     MOVE "test flat world the overworld of a debug world sends is flat false and sea level 63 (unchanged)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "debug " WS-D1 " flat " WS-D2 " death " WS-D3 " sea " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "debug 0 flat 0 death 0 sea 63" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Respawn: the packet id 84, the spawn info of the destination dimension, the data to keep
     MOVE "superflat" TO CW-WORLD-TYPE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-BUILD" USING WS-DIM WS-MODE WS-KEEP PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PID
     PERFORM READ-SPAWN-INFO
     MOVE WS-PID TO WS-NUM2
     MOVE "test flat world Respawn into the overworld of a superflat world carries is flat true and sea level -63" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "id " FUNCTION TRIM(WS-NUM2) " flat " WS-D2 " sea " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "id 84 flat 1 sea -63" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the own-generator flag
     MOVE "N" TO TL-MODE
     MOVE "superflat" TO CW-WORLD-TYPE
     CALL "WORLD-GEN-OWN" USING WS-OWN
     MOVE "test flat world WORLD-GEN-OWN is 1 for superflat" TO TL-CASE
     MOVE WS-OWN TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "debug" TO CW-WORLD-TYPE
     CALL "WORLD-GEN-OWN" USING WS-OWN
     MOVE "test flat world WORLD-GEN-OWN is 1 for debug" TO TL-CASE
     MOVE WS-OWN TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO CW-WORLD-TYPE
     CALL "WORLD-GEN-OWN" USING WS-OWN
     MOVE "test flat world WORLD-GEN-OWN is 0 for standard" TO TL-CASE
     MOVE WS-OWN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft" TO CW-WORLD-TYPE
     CALL "WORLD-GEN-OWN" USING WS-OWN
     MOVE "test flat world WORLD-GEN-OWN is 0 for cobolcraft" TO TL-CASE
     MOVE WS-OWN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SPAWN-INFO-OF-OVERWORLD.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-SPAWN-INFO-BUILD" USING WS-DIM WS-MODE PB-BUFFER
     MOVE 0 TO PB-POS
     PERFORM READ-SPAWN-INFO.

 READ-SPAWN-INFO.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-KEY WS-CAPACITY WS-LENGTH
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-DEBUG-FLAG
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAT-FLAG
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-DEATH-FLAG
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SEA
     MOVE WS-SEA TO WS-EDIT
     MOVE WS-DEBUG-FLAG TO WS-D1
     MOVE WS-FLAT-FLAG TO WS-D2
     MOVE WS-DEATH-FLAG TO WS-D3.
 END PROGRAM TEST-FLAT-WORLD.

 COPY CORETEST.
