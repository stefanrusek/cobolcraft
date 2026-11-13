*> Acceptance test of the air supply and drowning (docs/protocol/18 section 2.5 item 4, 17 section 4.12, 29a section 8): a survival player whose eye
*> is in water loses 1 of the air supply a tick (max 300) and is sent Set Entity Data (slot 1, the air); out of water the air refills by 4 a tick;
*> at -20 the air is reset to 0 and the player takes 2 drown damage (damage type 6, `death.attack.drown`); a creative player loses no air. The
*> cobolcraft world has no liquids, so the test adds the water block to the block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-DROWNING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC -(5)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "minecraft:water" TO WS-KEY
     MOVE 0 TO WS-SOLID
     MOVE 16 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-WATER
     MOVE 1 TO WS-SOLID
     MOVE 1 TO WS-COUNT
     MOVE "minecraft:stone" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-STONE
*>   A stone floor at (20, 100, 20), water above it at y 101 and 102, Alice's feet at 101: the eye (feet + 1.6 = 102.6) is in the water.
     MOVE 20 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 20 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 101 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     MOVE 102 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 17 TO PL-FOOD(CN-PLAYER(WS-ALICE))
     MOVE 0 TO PL-SATURATION(CN-PLAYER(WS-ALICE))
     MOVE "T" TO TL-MODE

     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance 18§2.5 given a survival player with the eye in water when 20 ticks pass then the air supply is 300 - 20" TO TL-CASE
     MOVE PL-AIR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "280" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "acceptance 18§2.5 given the air changes when a tick runs then the player is sent Set Entity Data (0x65) with it" TO TL-CASE
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "101x"
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drowning: at -19 the next tick makes -20: the air is 0 and the player takes 2 (health 18) with the drown damage type.
     MOVE -19 TO PL-AIR(CN-PLAYER(WS-ALICE))
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "acceptance 17§4.12 given the air reaches -20 when the tick runs then the air is 0 and the player takes 2 drown damage" TO TL-CASE
     MOVE PL-AIR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 damage 1 type 6 source 0 | hurt 1 | health 18 food 17" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Out of water the air refills by 4 a tick up to 300: Alice walks up to y 103 (eye 104.6, no water).
     MOVE 103 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance 18§2.5 given the eye is out of water when 3 ticks pass then the air refills by 4 a tick" TO TL-CASE
     MOVE PL-AIR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 299 TO PL-AIR(CN-PLAYER(WS-ALICE))
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance 18§2.5 given the air is 299 out of water when a tick runs then it is capped at 300" TO TL-CASE
     MOVE PL-AIR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "300" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A creative player breathes under water.
     MOVE 1 TO PL-MODE(CN-PLAYER(WS-ALICE))
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance 18§2.5 given a creative player with the eye in water when 5 ticks pass then the air supply stays 300" TO TL-CASE
     MOVE PL-AIR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "300" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Falling into water ends the fall (29a 8.3: touching water resets the fall distance): a survival player who drops 10 blocks into the two
*>   cells of water and lands on the stone below takes no damage.
     MOVE 0 TO PL-MODE(CN-PLAYER(WS-ALICE))
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 102 TO WS-FY
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "acceptance 29a§8.3 given a survival player falling 10 blocks into water when they land on the bottom then they take no fall damage"
         TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Adds a block with the key WS-KEY and WS-COUNT states, solid or not (WS-SOLID), after the last block and state of the tables.
 INSTALL.
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE WS-KEY TO CB-KEY(WS-N)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO CB-KEY-LENGTH(WS-N)
     MOVE WS-SOLID TO CB-SOLID(WS-N) CB-OPAQUE(WS-N)
     MOVE 0 TO CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-BASE
     MOVE WS-BASE TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE WS-COUNT TO CB-STATES(WS-N)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         COMPUTE CB-S-BLOCK(WS-BASE + WS-K) = WS-N - 1
         MOVE 0 TO CB-S-LIGHT(WS-BASE + WS-K)
     END-PERFORM
     ADD 1 TO CB-BLOCK-COUNT
     ADD WS-COUNT TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH.
 END PROGRAM ACC-US12-DROWNING.

 COPY CORETEST.
