*> Test of the option bytes the server writes into a Level Particles packet (docs/protocol/57-client-closures-3 sections 4 and 5; 05a 0x30
*> and Particle): every worked option row of 57-3 section 5 (dust, dust colour transition, block, falling dust, item, entity effect, effect, sculk
*> charge, shriek, dragon breath, tinted leaves, flash, vibration by block and by entity, trail, geyser, geyser base, heart), the dust scale clamp of
*> 4.1 (0.01 to 4.0), the complete 62-byte red dust packet of section 5, the two particle fixtures of the wire contract
*> (play-s2c-30-level-particles-dust and play-s2c-30-level-particles: T1765) and the dust packet reaching a player in range.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLE-OPTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PARTOPT.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NO-OPTION           BINARY-LONG VALUE -1.
 01 WS-OPTION              BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-ALWAYS              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RANDOM              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-HEX                 PIC X(1024).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-TEXT                PIC X(4096).
 01 B-VIEW                 PIC X(512) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE

*>   Option bytes after the type id (the first byte of each row of 57-3 section 5 is the type id, built by hand below).
     PERFORM RESET-OPTION
     MOVE 16711680 TO PO-COLOR-1
     MOVE 1.0 TO PO-FLOAT
     MOVE 21 TO WS-TYPE
     MOVE "test particle options dust red scale 1.0 is 15 00 ff 00 00 3f 80 00 00" TO TL-CASE
     MOVE "15 00 ff 00 00 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 3368652 TO PO-COLOR-1
     MOVE 0.5 TO PO-FLOAT
     MOVE "test particle options dust 0x3366cc scale 0.5 is 15 00 33 66 cc 3f 00 00 00" TO TL-CASE
     MOVE "15 00 33 66 cc 3f 00 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 0.001 TO PO-FLOAT
     MOVE "test particle options dust scale 0.001 is clamped to 0.01 (3c 23 d7 0a)" TO TL-CASE
     MOVE "15 00 33 66 cc 3c 23 d7 0a" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 9.0 TO PO-FLOAT
     MOVE "test particle options dust scale 9.0 is clamped to 4.0 (40 80 00 00)" TO TL-CASE
     MOVE "15 00 33 66 cc 40 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 4.0 TO PO-FLOAT
     MOVE "test particle options dust scale 4.0 stays 4.0" TO TL-CASE
     MOVE "15 00 33 66 cc 40 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 3790560 TO PO-COLOR-1
     MOVE 16711680 TO PO-COLOR-2
     MOVE 1.0 TO PO-FLOAT
     MOVE 22 TO WS-TYPE
     MOVE "test particle options dust colour transition sculk to red is 16 00 39 d6 e0 00 ff 00 00 3f 80 00 00" TO TL-CASE
     MOVE "16 00 39 d6 e0 00 ff 00 00 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 0.0 TO PO-FLOAT
     MOVE "test particle options dust colour transition scale 0 is clamped to 0.01" TO TL-CASE
     MOVE "16 00 39 d6 e0 00 ff 00 00 3c 23 d7 0a" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 1 TO PO-VARINT
     MOVE 1 TO WS-TYPE
     MOVE "test particle options block stone (state 1) is 01 01" TO TL-CASE
     MOVE "01 01" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 15 TO PO-VARINT
     MOVE "test particle options block oak_planks (state 15) is 01 0f" TO TL-CASE
     MOVE "01 0f" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 36 TO WS-TYPE
     MOVE "test particle options falling dust oak_planks is 24 0f" TO TL-CASE
     MOVE "24 0f" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 2 TO WS-TYPE
     MOVE "test particle options block_marker is 02 0f" TO TL-CASE
     MOVE "02 0f" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 121 TO WS-TYPE
     MOVE "test particle options dust_pillar is 79 0f" TO TL-CASE
     MOVE "79 0f" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 125 TO WS-TYPE
     MOVE "test particle options block_crumble is 7d 0f" TO TL-CASE
     MOVE "7d 0f" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 1012 TO PO-VARINT
     MOVE 1 TO PO-COUNT
     MOVE 57 TO WS-TYPE
     MOVE "test particle options item diamond (1012) count 1 is 39 f4 07 01 00 00" TO TL-CASE
     MOVE "39 f4 07 01 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 4294901760 TO PO-COLOR-1
     MOVE 28 TO WS-TYPE
     MOVE "test particle options entity effect opaque red is 1c ff ff 00 00" TO TL-CASE
     MOVE "1c ff ff 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 46 TO WS-TYPE
     MOVE 4284124205 TO PO-COLOR-1
     MOVE "test particle options tinted leaves 0xff5a8c2d is 2e ff 5a 8c 2d" TO TL-CASE
     MOVE "2e ff 5a 8c 2d" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 52 TO WS-TYPE
     MOVE 4294967295 TO PO-COLOR-1
     MOVE "test particle options flash 0xffffffff is 34 ff ff ff ff" TO TL-CASE
     MOVE "34 ff ff ff ff" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 16744448 TO PO-COLOR-1
     MOVE 1.0 TO PO-FLOAT
     MOVE 23 TO WS-TYPE
     MOVE "test particle options effect 0x00ff8000 power 1.0 is 17 00 ff 80 00 3f 80 00 00" TO TL-CASE
     MOVE "17 00 ff 80 00 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 56 TO WS-TYPE
     MOVE "test particle options instant effect has the same layout (38 ...)" TO TL-CASE
     MOVE "38 00 ff 80 00 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 1.0 TO PO-FLOAT
     MOVE 48 TO WS-TYPE
     MOVE "test particle options sculk charge roll 1.0 is 30 3f 80 00 00" TO TL-CASE
     MOVE "30 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 15 TO WS-TYPE
     MOVE "test particle options dragon breath power 1.0 is 0f 3f 80 00 00" TO TL-CASE
     MOVE "0f 3f 80 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 5 TO PO-VARINT
     MOVE 115 TO WS-TYPE
     MOVE "test particle options shriek delay 5 is 73 05" TO TL-CASE
     MOVE "73 05" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 0 TO PO-SOURCE
     MOVE 10 TO PO-BX
     MOVE 64 TO PO-BY
     MOVE -3 TO PO-BZ
     MOVE 20 TO PO-VARINT
     MOVE 58 TO WS-TYPE
     MOVE "test particle options vibration block (10, 64, -3) 20 ticks is 3a 00 00 00 02 bf ff ff d0 40 14" TO TL-CASE
     MOVE "3a 00 00 00 02 bf ff ff d0 40 14" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 1 TO PO-SOURCE
     MOVE 7 TO PO-ENTITY
     MOVE 0.5 TO PO-FLOAT
     MOVE "test particle options vibration entity 7 y offset 0.5 20 ticks is 3a 01 07 3f 00 00 00 14" TO TL-CASE
     MOVE "3a 01 07 3f 00 00 00 14" TO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 1.5 TO PO-TX
     MOVE 64.0 TO PO-TY
     MOVE -2.5 TO PO-TZ
     MOVE 3368652 TO PO-COLOR-1
     MOVE 40 TO PO-VARINT
     MOVE 59 TO WS-TYPE
     MOVE "test particle options trail target (1.5, 64, -2.5) colour 0x3366cc duration 40 is 30 bytes" TO TL-CASE
     STRING "3b 3f f8 00 00 00 00 00 00 40 50 00 00 00 00 00 00 c0 04 00 00 00 00 00 00 00 33 66 cc 28"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM OPTION-CASE

     PERFORM RESET-OPTION
     MOVE 6 TO PO-COLOR-1
     MOVE 7 TO WS-TYPE
     MOVE "test particle options geyser water blocks 6 is 07 00 00 00 06" TO TL-CASE
     MOVE "07 00 00 00 06" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 10 TO WS-TYPE
     MOVE "test particle options geyser plume water blocks 6 is 0a 00 00 00 06" TO TL-CASE
     MOVE "0a 00 00 00 06" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 0.5 TO PO-FLOAT
     MOVE 8 TO WS-TYPE
     MOVE "test particle options geyser base water blocks 6 impulse 0.5 is 08 00 00 00 06 3f 00 00 00" TO TL-CASE
     MOVE "08 00 00 00 06 3f 00 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 9 TO WS-TYPE
     MOVE "test particle options geyser poof has the same layout (09 ...)" TO TL-CASE
     MOVE "09 00 00 00 06 3f 00 00 00" TO TL-EXPECTED
     PERFORM OPTION-CASE
     MOVE 55 TO WS-TYPE
     MOVE "test particle options heart (simple type) is 37 with no option bytes" TO TL-CASE
     MOVE "37" TO TL-EXPECTED
     PERFORM OPTION-CASE

*>   The complete red dust packet of 57-3 section 5: (1.5, 64.0, -2.5), no spread, no speed, one particle, default randomisation, 62 bytes.
     PERFORM RESET-OPTION
     MOVE 16711680 TO PO-COLOR-1
     MOVE 1.0 TO PO-FLOAT
     MOVE 21 TO WS-TYPE
     MOVE 0 TO WS-OVERRIDE WS-ALWAYS WS-RANDOM
     MOVE 1.5 TO WS-X
     MOVE 64.0 TO WS-Y
     MOVE -2.5 TO WS-Z
     MOVE 1 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 6
         MOVE 0 TO WS-SPREAD(WS-ROW)
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PARTICLE-BUILD-OPT" USING PB-BUFFER WS-TYPE PARTICLE-OPTION WS-OVERRIDE WS-ALWAYS WS-X WS-Y WS-Z
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     PERFORM BUFFER-HEX
     MOVE "test particle options the complete red dust packet is 62 bytes with the bytes of 57-3 section 5" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "30 15 00 ff 00 00 3f 80 00 00 00 00 3f f8 00 00 00 00 00 00 40 50 00 00 00 00 00 00 c0 04 00 00 00 00 00 00"
         " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "test particle options the complete red dust packet is 62 bytes long" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 62 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The wire contract fixtures (T1765): the dust fixture and the block fixture equal what the core builds from their stated inputs.
     MOVE 16711680 TO PO-COLOR-1
     MOVE 2.0 TO PO-FLOAT
     MOVE 0 TO WS-OVERRIDE
     MOVE 1 TO WS-ALWAYS
     MOVE 0.5 TO WS-X
     MOVE 65.0 TO WS-Y
     MOVE 0.5 TO WS-Z
     MOVE 0.25 TO WS-SPREAD(1) WS-SPREAD(3)
     MOVE 0.5 TO WS-SPREAD(2)
     MOVE 0 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     MOVE 7 TO WS-COUNT
     MOVE 1 TO WS-RANDOM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PARTICLE-BUILD-OPT" USING PB-BUFFER WS-TYPE PARTICLE-OPTION WS-OVERRIDE WS-ALWAYS WS-X WS-Y WS-Z
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     MOVE "contract/fixtures/wire/play-s2c-30-level-particles-dust.hex" TO WS-PATH
     MOVE "test particle options contract wire server play-s2c-30-level-particles-dust equals the core's dust packet" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 1 TO WS-TYPE
     MOVE 35722 TO WS-OPTION
     MOVE 1 TO WS-OVERRIDE
     MOVE 0 TO WS-ALWAYS
     MOVE -1.5 TO WS-X
     MOVE 3.0 TO WS-Y
     MOVE 8.25 TO WS-Z
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 6
         MOVE 0 TO WS-SPREAD(WS-ROW)
     END-PERFORM
     MOVE 0 TO WS-COUNT WS-RANDOM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PARTICLE-BUILD" USING PB-BUFFER WS-TYPE WS-OPTION WS-OVERRIDE WS-ALWAYS WS-X WS-Y WS-Z
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     MOVE "contract/fixtures/wire/play-s2c-30-level-particles.hex" TO WS-PATH
     MOVE "test particle options contract wire server play-s2c-30-level-particles equals the core's block packet" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   A dust packet sent to a player 4 blocks away reaches her with its option bytes (the drain shows the type and the fields).
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     PERFORM RESET-OPTION
     MOVE 16711680 TO PO-COLOR-1
     MOVE 1.0 TO PO-FLOAT
     MOVE 21 TO WS-TYPE
     MOVE 0 TO WS-OVERRIDE WS-ALWAYS WS-RANDOM
     MOVE PL-X(CN-PLAYER(WS-ALICE)) TO WS-X
     MOVE PL-Y(CN-PLAYER(WS-ALICE)) TO WS-Y
     MOVE PL-Z(CN-PLAYER(WS-ALICE)) TO WS-Z
     MOVE 1 TO WS-COUNT
     MOVE 0 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3) WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "PARTICLE-SEND-OPT" USING WS-DIM WS-TYPE PARTICLE-OPTION WS-OVERRIDE WS-ALWAYS WS-X WS-Y WS-Z
         WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "test particle options PARTICLE-SEND-OPT of a dust particle reaches the player in range as one packet 48" TO TL-CASE
     MOVE WS-TEXT(1:5) TO TL-OBSERVED
     MOVE "48" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 RESET-OPTION.
     INITIALIZE PARTICLE-OPTION.

 OPTION-CASE.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     CALL "PARTICLE-OPTION-BUILD" USING PB-BUFFER WS-TYPE PARTICLE-OPTION
     PERFORM BUFFER-HEX
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BUFFER-HEX.
     SET ADDRESS OF B-VIEW TO PB-ADDR
     CALL "TEST-HEX-OF" USING B-VIEW PB-LENGTH WS-HEX
     PERFORM SPACE-HEX.

 SPACE-HEX.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > PB-LENGTH
         MOVE WS-HEX(WS-ROW * 2 - 1:2) TO TL-OBSERVED(WS-ROW * 3 - 2:2)
     END-PERFORM
     MOVE TL-OBSERVED TO WS-HEX.

 CHECK-TEXT.
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLE-OPTIONS.

 COPY CORETEST.
