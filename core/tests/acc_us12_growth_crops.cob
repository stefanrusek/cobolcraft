*> Acceptance test of crops, saplings and bone meal wired into the play path (specs 002 phase 42; docs/protocol/29b part 1 sections 5 to 7, 32 section 1.2, the level random): the level random is
*> java.util.Random (seed 0 gives nextInt(10) = 0, nextInt(16) = 11, nextFloat 0.7309678), the raw brightness lookup reads the sky and block light the chunk keeps, wheat on hydrated farmland in the light of the
*> sky grows through the random ticks of its chunk and never past its largest age, bone meal used on wheat through Use Item On raises its age by 2 to 5, costs one item, and sends level event 1505, and bone
*> meal on a sapling costs an item per use and advances its stage on the 45 percent success. The cobolcraft world has none of these blocks or the item, so the test adds them to the tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-GROWTH-CROPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY WSIM3.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BASE                BINARY-LONG.
 01 WS-FARM                BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-SAPLING             BINARY-LONG.
 01 WS-BONE                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-GROWN               BINARY-LONG.
 01 WS-OVER                BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-LIT                 BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-BIG                 BINARY-LONG VALUE 1073741825.
 01 WS-STONE               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "T" TO TL-MODE

*>   The level random is java.util.Random.
     MOVE "acceptance US12 33 2.4 given the level random seeded with 0 when nextInt(10), then (reseeded) nextInt(16) and nextFloat are drawn then they are Java's 0, 11 and 0.730968" TO TL-CASE
     CALL "LEVEL-RANDOM-SEED" USING WS-SEED
     MOVE 10 TO WS-BOUND
     CALL "LEVEL-RANDOM-INT" USING WS-BOUND WS-DRAW
     MOVE WS-DRAW TO WS-EDIT
     CALL "LEVEL-RANDOM-SEED" USING WS-SEED
     MOVE 16 TO WS-BOUND
     CALL "LEVEL-RANDOM-INT" USING WS-BOUND WS-DRAW
     MOVE WS-DRAW TO WS-EDIT2
     CALL "LEVEL-RANDOM-SEED" USING WS-SEED
     CALL "LEVEL-RANDOM-FLOAT" USING WS-FLOAT
     COMPUTE WS-N ROUNDED = WS-FLOAT * 1000000
     MOVE WS-N TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 11 730968" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 33 2.4 given an unseeded level random when drawn then it is seeded from the world seed, and a bound above 2^30 redraws on overflow but stays below the bound" TO TL-CASE
     MOVE 0 TO LR-READY
     MOVE 0 TO WS-N
     PERFORM 40 TIMES
         CALL "LEVEL-RANDOM-INT" USING WS-BIG WS-DRAW
         IF WS-DRAW < 0 OR WS-DRAW >= WS-BIG
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE LR-READY TO WS-EDIT
     MOVE WS-N TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Fixtures.
     MOVE "minecraft:farmland" TO WS-KEY
     MOVE 8 TO WS-COUNT
     MOVE 1 TO WS-SOLID
     PERFORM INSTALL
     MOVE WS-BASE TO WS-FARM
     MOVE "minecraft:wheat" TO WS-KEY
     MOVE 0 TO WS-SOLID
     PERFORM INSTALL
     MOVE WS-BASE TO WS-WHEAT
     MOVE "minecraft:oak_sapling" TO WS-KEY
     MOVE 2 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-SAPLING
     MOVE "minecraft:glowfixture" TO WS-KEY
     MOVE 1 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-LIT
     COMPUTE WS-N = CB-BLOCK-COUNT
     MOVE 12 TO CB-LIGHT(WS-N)
     MOVE 12 TO CB-S-LIGHT(WS-LIT + 1)
     COMPUTE WS-N = IT-COUNT + 1
     MOVE "minecraft:bone_meal" TO IT-KEY(WS-N)
     MOVE 19 TO IT-KEY-LENGTH(WS-N)
     MOVE -1 TO IT-PLACES-STATE(WS-N)
     MOVE 64 TO IT-MAX-STACK(WS-N)
     MOVE 0 TO IT-TOOL-CLASS(WS-N) IT-FOOD(WS-N) IT-TOOL-SPEED(WS-N) IT-TOOL-TIER(WS-N)
     MOVE 1 TO IT-ATTACK(WS-N)
     MOVE IT-COUNT TO WS-BONE
     ADD 1 TO IT-COUNT
     CALL "GB-RULES-OPEN"
     CALL "GB-RULES-OPEN"

*>   The raw brightness lookup.
     MOVE "acceptance US12 32 1.2 given a block light source in open air when the raw brightness is read then the sky is 15, the source's cell has its light and its neighbour one less, and a cell inside the ground has 0" TO TL-CASE
     MOVE 5 TO WS-X
     MOVE 120 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LIT
     ADD 1 TO WS-X
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE WS-SKY TO WS-EDIT
     MOVE WS-BLOCK-LIGHT TO WS-EDIT2
     MOVE 5 TO WS-X
     MOVE 1 TO WS-Y
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE WS-RAW TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "15 11 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32 1.2 given an opaque block at the top of its column and a height outside the dimension when the raw brightness is read then both are 0" TO TL-CASE
     MOVE 110 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE WS-RAW TO WS-EDIT
     MOVE -5 TO WS-Y
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-Y WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE WS-RAW TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A field of wheat on hydrated farmland over chunk (0, 0).
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             MOVE 100 TO WS-Y
             COMPUTE WS-STATE = WS-FARM + 7
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             MOVE 101 TO WS-Y
             MOVE WS-WHEAT TO WS-STATE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 29b-1 6.2 given 256 wheat plants on hydrated farmland in the sky light when 1500 ticks pass then some have grown and none is past its largest age" TO TL-CASE
     MOVE 1500 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-GROWN WS-OVER
     MOVE 101 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE > WS-WHEAT
                 ADD 1 TO WS-GROWN
             END-IF
             IF WS-STATE > WS-WHEAT + 7
                 ADD 1 TO WS-OVER
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "no growth" TO TL-OBSERVED
     IF WS-GROWN > 0 AND WS-OVER = 0
         MOVE "grown within the maximum" TO TL-OBSERVED
     END-IF
     MOVE "grown within the maximum" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Bone meal through Use Item On.
     MOVE "acceptance US12 29b-1 5.3 given bone meal in the hand when it is used on wheat of age 2 then the age is 4 to 7, one item is gone and a level event 1505 was sent" TO TL-CASE
     MOVE WS-BONE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "TEST-HELD" USING WS-CONN WS-SLOT
     MOVE 8 TO WS-X
     MOVE 101 TO WS-Y
     MOVE 8 TO WS-Z
     COMPUTE WS-STATE = WS-WHEAT + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-N = WS-STATE - WS-WHEAT
     MOVE WS-N TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT2
     MOVE 0 TO WS-K
     INSPECT WS-TEXT TALLYING WS-K FOR ALL "47"
     MOVE SPACES TO TL-OBSERVED
     IF WS-N >= 4 AND WS-N <= 7 AND PL-SLOT-COUNT(WS-ROW, 1) = 4 AND WS-K > 0
         MOVE "age 4-7, 4 items, event" TO TL-OBSERVED
     ELSE
         MOVE WS-K TO WS-EDIT3
         STRING "age " FUNCTION TRIM(WS-EDIT) " items " FUNCTION TRIM(WS-EDIT2) " events " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "age 4-7, 4 items, event" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29b-1 7.1 given bone meal on a stage 0 sapling when it is used repeatedly then every use costs one item and the stage becomes 1 on a success (nextFloat < 0.45)" TO TL-CASE
     MOVE 9 TO WS-X
     MOVE 9 TO WS-Z
     MOVE WS-SAPLING TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 40 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO WS-K
     PERFORM UNTIL WS-STATE NOT = WS-SAPLING OR WS-K >= 40
         ADD 1 TO WS-SEQ
         CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
         ADD 1 TO WS-K
     END-PERFORM
     COMPUTE WS-N = 40 - WS-K
     MOVE SPACES TO TL-OBSERVED
     IF PL-SLOT-COUNT(WS-ROW, 1) = WS-N
         MOVE "one item a use" TO TL-OBSERVED
     ELSE
         MOVE "items off" TO TL-OBSERVED
     END-IF
     MOVE "one item a use" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29b-1 7.1 given a stage 0 sapling in daylight when its random tick runs repeatedly (BR-RANDOM-TICK) then it reaches stage 1 and stays" TO TL-CASE
     MOVE 6000 TO CW-TIME
     MOVE 10 TO WS-X
     MOVE 10 TO WS-Z
     MOVE 101 TO WS-Y
     MOVE WS-SAPLING TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-TRIES
     PERFORM UNTIL WS-STATE NOT = WS-SAPLING OR WS-TRIES >= 300
         CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
         ADD 1 TO WS-TRIES
     END-PERFORM
     PERFORM 30 TIMES
         CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     END-PERFORM
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-N = WS-STATE - WS-SAPLING
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

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
 END PROGRAM ACC-US12-GROWTH-CROPS.

 COPY CORETEST.
