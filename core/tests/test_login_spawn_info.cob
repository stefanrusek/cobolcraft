*> Test of the Login (play) packet and the CommonPlayerSpawnInfo of a standard world (docs/protocol/57-client-closures-3 sections 7 to 12; T1765): the hashed
*> seed is obfuscateSeed(world seed) with the four vectors of 10 (zero, 1, 12345, -1), the Login of a fresh player in each dimension is the worked
*> packet of 12.2 byte for byte (seed 12345, entity id 1, game mode 0, view distance 8, dimension type ids 0 / 3 / 2, sea level 63 / 32 / 0, previous game
*> mode and last death location absent), a cobolcraft world type still sends 0, and the fixtures play-s2c-32-login-all-dimensions-standard and
*> play-s2c-54-respawn-{main,the-nether,the-end}-standard equal what the core builds for a creative player who came from survival and died in the
*> overworld at (10, 64, -10) (the fixtures' hashed seed 0x1122334455667788 is a stand-in constant: the test writes it over the core's eight seed bytes,
*> and the nether fixture's dimension type id 1 belongs to a three-entry registry: the core's registry has four entries, so its id 3 is replaced by 1 before
*> the comparison, as 57-3 section 9.3 says the id must follow the paired Registry Data). Needs the generated packs (CC_GENERATED_DIR): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOGIN-SPAWN-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-ENV                 PIC X(256).
 01 WS-DIR                 PIC X(256).
 01 WS-FILE                PIC X(300).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SEED-IN             BINARY-DOUBLE.
 01 WS-SEED-OUT            BINARY-DOUBLE.
 01 WS-HEX                 PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                PIC 9.
 01 WS-KEEP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PREFIX              PIC X(400).
 01 WS-NETHER-TAIL         PIC X(400).
 01 WS-END-TAIL            PIC X(400).
 01 WS-SEED-BYTES          PIC X(8).
 01 WS-SEED-TABLE.
    05 FILLER              BINARY-LONG VALUE 17.
    05 FILLER              BINARY-LONG VALUE 34.
    05 FILLER              BINARY-LONG VALUE 51.
    05 FILLER              BINARY-LONG VALUE 68.
    05 FILLER              BINARY-LONG VALUE 85.
    05 FILLER              BINARY-LONG VALUE 102.
    05 FILLER              BINARY-LONG VALUE 119.
    05 FILLER              BINARY-LONG VALUE 136.
 01 WS-SEED-VALUES REDEFINES WS-SEED-TABLE.
    05 WS-SEED-BYTE        BINARY-LONG OCCURS 8 TIMES.
 01 B-VIEW                 PIC X(512) BASED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "test login spawn info no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   obfuscateSeed: the four vectors of 57-3 section 10 (wire bytes of the Long).
     MOVE 0 TO WS-SEED-IN
     MOVE "test login spawn info obfuscateSeed(0) is 7a 0b 81 a1 f5 70 55 af" TO TL-CASE
     MOVE "7a 0b 81 a1 f5 70 55 af" TO TL-EXPECTED
     PERFORM SEED-CASE
     MOVE 1 TO WS-SEED-IN
     MOVE "test login spawn info obfuscateSeed(1) is a6 3f 41 d4 36 a1 9f 7c" TO TL-CASE
     MOVE "a6 3f 41 d4 36 a1 9f 7c" TO TL-EXPECTED
     PERFORM SEED-CASE
     MOVE 12345 TO WS-SEED-IN
     MOVE "test login spawn info obfuscateSeed(12345) is 04 13 91 24 51 35 54 e1" TO TL-CASE
     MOVE "04 13 91 24 51 35 54 e1" TO TL-EXPECTED
     PERFORM SEED-CASE
     MOVE -1 TO WS-SEED-IN
     MOVE "test login spawn info obfuscateSeed(-1) is 5d ce 61 56 44 ae a3 12" TO TL-CASE
     MOVE "5d ce 61 56 44 ae a3 12" TO TL-EXPECTED
     PERFORM SEED-CASE

*>   A standard world with the three dimensions, world seed 12345.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 12345 TO CW-SEED
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     INITIALIZE PL-ENTRY(1)
     MOVE 1 TO PL-ENTITY-ID(1)
     MOVE 0 TO PL-MODE(1)

     MOVE "32 00 00 00 01 00 03 13 6d 69 6e 65 63 72 61 66 74 3a 6f 76 65 72 77 6f 72 6c 64 14 6d 69 6e 65 63 72 61 66 74 3a 74 68 65 5f 6e 65 74 68 65 72 11 6d 69 6e 65 63 72 61 66 74 3a 74 68 65 5f 65 6e 64 14 08 08 00 01 00" TO WS-PREFIX
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(1)
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-PREFIX) " 00 13 6d 69 6e 65 63 72 61 66 74 3a 6f 76 65 72 77 6f 72 6c 64 04 13 91 24 51 35 54 e1 00 00 00 00 00 00 3f 00 00"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "test login spawn info the Login of a fresh player in the overworld is the worked packet of 57-3 12.2 (dimension type 0, sea level 63)" TO TL-CASE
     PERFORM LOGIN-CASE
     MOVE DIM-STANDARD-NETHER TO PL-DIM(1)
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-PREFIX) " 03 14 6d 69 6e 65 63 72 61 66 74 3a 74 68 65 5f 6e 65 74 68 65 72 04 13 91 24 51 35 54 e1 00 00 00 00 00 00 20 00 00"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "test login spawn info the Login of a fresh player in the Nether is the worked packet of 57-3 12.2 (dimension type 3, sea level 32)" TO TL-CASE
     PERFORM LOGIN-CASE
     MOVE DIM-STANDARD-END TO PL-DIM(1)
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-PREFIX) " 02 11 6d 69 6e 65 63 72 61 66 74 3a 74 68 65 5f 65 6e 64 04 13 91 24 51 35 54 e1 00 00 00 00 00 00 00 00 00"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "test login spawn info the Login of a fresh player in the End is the worked packet of 57-3 12.2 (dimension type 2, sea level 0)" TO TL-CASE
     PERFORM LOGIN-CASE

*>   A flat world still hashes the seed; a cobolcraft world sends 0 (09 section 3.2).
     MOVE "superflat" TO CW-WORLD-TYPE
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 0 TO WS-MODE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-SPAWN-INFO-BUILD" USING WS-DIM WS-MODE PB-BUFFER
     PERFORM BUFFER-HEX
     MOVE "test login spawn info the spawn info of a superflat world carries obfuscateSeed(12345), flat true, sea level -63" TO TL-CASE
     MOVE "00 13 6d 69 6e 65 63 72 61 66 74 3a 6f 76 65 72 77 6f 72 6c 64 04 13 91 24 51 35 54 e1 00 00 00 01 00 00 c1 ff ff ff 0f" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft" TO CW-WORLD-TYPE
     MOVE DIM-MAIN TO WS-DIM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-SPAWN-INFO-BUILD" USING WS-DIM WS-MODE PB-BUFFER
     PERFORM BUFFER-HEX
     MOVE "test login spawn info the spawn info of a cobolcraft world carries the hashed seed 0" TO TL-CASE
     MOVE "00 0f 63 6f 62 6f 6c 63 72 61 66 74 3a 6d 61 69 6e 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO CW-WORLD-TYPE

*>   The fixtures: a creative player who came from survival and died in the overworld at (10, 64, -10), view distance 10.
     MOVE 10 TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 1 TO PL-MODE(1)
     MOVE 1 TO PL-PREV-MODE1(1)
     MOVE 1 TO PL-DEATH-HAS(1)
     MOVE DIM-STANDARD-OVERWORLD TO PL-DEATH-DIM(1)
     MOVE 10 TO PL-DEATH-X(1)
     MOVE 64 TO PL-DEATH-Y(1)
     MOVE -10 TO PL-DEATH-Z(1)
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-LOGIN-BUILD" USING WS-ONE PB-BUFFER
     MOVE 94 TO WS-START
     PERFORM PATCH-SEED
     MOVE "contract/fixtures/wire/play-s2c-32-login-all-dimensions-standard.hex" TO WS-PATH
     MOVE "test login spawn info contract wire server play-s2c-32-login-all-dimensions-standard equals the core's Login (seed bytes aside)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 0 TO WS-KEEP
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 1 TO WS-MODE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-ROW" USING WS-ONE WS-DIM WS-MODE WS-KEEP PB-BUFFER
     MOVE 23 TO WS-START
     PERFORM PATCH-SEED
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main-standard.hex" TO WS-PATH
     MOVE "test login spawn info contract wire server play-s2c-54-respawn-main-standard equals the core's Respawn (seed bytes aside)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 1 TO WS-KEEP
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-ROW" USING WS-ONE WS-DIM WS-MODE WS-KEEP PB-BUFFER
     MOVE 24 TO WS-START
     PERFORM PATCH-SEED
     SET ADDRESS OF B-VIEW TO PB-ADDR
     MOVE FUNCTION CHAR(2) TO B-VIEW(2:1)
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-the-nether-standard.hex" TO WS-PATH
     MOVE "test login spawn info contract wire server play-s2c-54-respawn-the-nether-standard equals the core's Respawn (seed bytes and type id 3 as 1 aside)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 3 TO WS-KEEP
     MOVE DIM-STANDARD-END TO WS-DIM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-ROW" USING WS-ONE WS-DIM WS-MODE WS-KEEP PB-BUFFER
     MOVE 21 TO WS-START
     PERFORM PATCH-SEED
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-the-end-standard.hex" TO WS-PATH
     MOVE "test login spawn info contract wire server play-s2c-54-respawn-the-end-standard equals the core's Respawn (seed bytes aside)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     STOP RUN.

 SEED-CASE.
     CALL "OBFUSCATE-SEED" USING WS-SEED-IN WS-SEED-OUT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED-OUT
     PERFORM BUFFER-HEX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 LOGIN-CASE.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-LOGIN-BUILD" USING WS-ONE PB-BUFFER
     PERFORM BUFFER-HEX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BUFFER-HEX.
     SET ADDRESS OF B-VIEW TO PB-ADDR
     CALL "TEST-HEX-OF" USING B-VIEW PB-LENGTH WS-HEX
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-LENGTH
         MOVE WS-HEX(WS-I * 2 - 1:2) TO TL-OBSERVED(WS-I * 3 - 2:2)
     END-PERFORM.

 PATCH-SEED.
     SET ADDRESS OF B-VIEW TO PB-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION CHAR(WS-SEED-BYTE(WS-I) + 1) TO WS-SEED-BYTES(WS-I:1)
     END-PERFORM
     MOVE WS-SEED-BYTES TO B-VIEW(WS-START:8).
 END PROGRAM TEST-LOGIN-SPAWN-INFO.

 COPY CORETEST.
