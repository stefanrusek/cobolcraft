*> Acceptance test, lane bugbed (operator report of try16: "I can't sleep in beds"; 33 sections 5.1 to 5.3, 53 pose 2 SLEEPING, 05a Animate action 0 wake up, 05c
*> Player Command 0 STOP_SLEEPING, 18 section 1.4 entry 14 the sleeping position): a standard world opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, skipped as a pass without it). A whole bed beside Alice, used with an empty hand through Use Item On: by night on either half she sleeps (the
*> player's entity gets pose SLEEPING and the bed position in Set Entity Data); by day she does not, the respawn point is set and the player is told
*> block.minecraft.bed.no_sleep as an overlay line; a foot whose head half is missing is consumed with no effect (no spawn point, no sleep); Player Command STOP_SLEEPING and the morning
*> wake her (Animate action 0 and the standing pose); using the bed with an item in hand sleeps too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BED-SLEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY WSIM2.
 COPY BRWORLD.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BED-ITEM            BINARY-LONG.
 01 WS-BED-STATE           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-PROP-FACING         PIC X(24) VALUE "facing".
 01 WS-PROP-PART           PIC X(24) VALUE "part".
 01 WS-PROP-OCCUPIED       PIC X(24) VALUE "occupied".
 01 WS-FOUND               BINARY-LONG.
 01 WS-SAVED-X             FLOAT-LONG.
 01 WS-PROP-TEXT           PIC X(32).
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-TICK-COUNT          BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SEEN-POSE           BINARY-LONG.
 01 WS-SEEN-POS            PIC X(24).
 01 WS-SEEN-WAKE           BINARY-LONG.
 01 WS-SEEN-ENTITY         BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-EXPECT-POS          PIC X(24).
 01 WS-KEY2                PIC X(112).
 01 WS-BID2                BINARY-LONG.
 01 WS-BROW2               PIC X(819).
 01 WS-STONE               BINARY-LONG.
 01 WS-FLOOR-Y             BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 PROCEDURE DIVISION.
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
         MOVE "acceptance bed sleep no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Sleep" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "BR-WORLD-READY"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "red_bed" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-BED-STATE
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BED-ITEM WS-IROW WS-STATUS
*>   The bed beside her at her own height: the foot one block east, the head one block south of it, air above both.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(PL-ENTITY-ROW(WS-ROW))) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(PL-ENTITY-ROW(WS-ROW)))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(PL-ENTITY-ROW(WS-ROW)))
     COMPUTE WS-HZ = WS-BZ + 1
     COMPUTE WS-AY = WS-BY + 1
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE 0 TO PL-MODE(WS-ROW)
*>   A clear sky (a thunderstorm makes the sky dark by day, and then a bed can be slept in by day).
     MOVE 0 TO CW-RAINING CW-THUNDERING
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM) CW-RAIN-LEVEL-OLD(WS-DIM) CW-THUNDER-LEVEL(WS-DIM) CW-THUNDER-LEVEL-OLD(WS-DIM)
     MOVE 1000000 TO CW-CLEAR-TIME

     PERFORM SET-WHOLE-BED
     MOVE 18000 TO CW-TIME
     PERFORM USE-BED-FOOT
     MOVE "acceptance bed sleep: a click on the foot of a whole bed by night puts Alice to sleep" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bed sleep: the clients are sent the SLEEPING pose of her entity" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: the clients are sent the head half of the bed as her sleeping position" TO TL-CASE
     MOVE WS-BX TO WS-E1
     MOVE WS-BY TO WS-E2
     MOVE WS-HZ TO WS-E3
     MOVE SPACES TO WS-EXPECT-POS
     STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-EXPECT-POS
     MOVE WS-EXPECT-POS TO TL-EXPECTED
     MOVE WS-SEEN-POS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bed sleep: Player Command STOP_SLEEPING wakes her" TO TL-CASE
     MOVE 0 TO WS-COMMAND
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-COMMAND
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bed sleep: waking sends the wake up Animate of her entity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SEEN-WAKE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: waking sends the standing pose" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The head half works too, and an item in hand does not stop the use.
     MOVE WS-BED-ITEM TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-BED-HEAD
     MOVE "acceptance bed sleep: a click on the head half with a bed in hand sleeps too" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     MOVE "acceptance bed sleep: the bed in hand was not used up" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)

*>   The morning wakes the sleeper (the clock past the dark hours).
     MOVE 1000 TO CW-TIME
     CALL "WORLDSIM-DARKEN" USING WS-DIM WS-DARKEN
     MOVE "acceptance bed sleep: the sky is bright at tick 1000 of a clear day (skyDarken below 4)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DARKEN < 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: she is in the first dimension of the world (row 3 in a standard world), where the sleep tick looks" TO TL-CASE
     MOVE CW-DIM(1) TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-TICK-COUNT
     CALL "TEST-TICKS" USING WS-TICK-COUNT
     MOVE "acceptance bed sleep: the morning wakes her" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bed sleep: the morning wake up sends the Animate and the standing pose" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SEEN-WAKE * 10 + WS-SEEN-POSE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   STOP_SLEEPING from a player who is not in bed does nothing.
     MOVE 0 TO WS-COMMAND
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-COMMAND
     MOVE "acceptance bed sleep: STOP_SLEEPING while awake changes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sleeping through the night: after 100 ticks in bed the clock moves to the morning and she is awake (the sleep tick looks at the dimension of the world, row 3 here).
     MOVE 18000 TO CW-TIME
     PERFORM SET-WHOLE-BED
     PERFORM USE-BED-FOOT
     MOVE 105 TO WS-TICK-COUNT
     CALL "TEST-TICKS" USING WS-TICK-COUNT
     MOVE "acceptance bed sleep: sleeping 100 ticks skips the night, the clock is at the morning" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CW-TIME < 1000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: and she is awake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   By day: no sleep, the respawn point is set, the player is told why.
     MOVE 6000 TO CW-TIME
     MOVE 0 TO BW-SPAWN-SET(WS-ROW)
     PERFORM USE-BED-FOOT
     MOVE "acceptance bed sleep: by day she does not sleep" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: by day the respawn point is set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BW-SPAWN-SET(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     MOVE "acceptance bed sleep: by day she is told she can sleep only at night, as an overlay line" TO TL-CASE
     MOVE "Respawn point set | block.minecraft.bed.no_sleep()[overlay]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A foot with no head half: the use is consumed with no effect.
     MOVE 18000 TO CW-TIME
     MOVE 0 TO BW-SPAWN-SET(WS-ROW)
     PERFORM SET-WHOLE-BED
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-VOID
     PERFORM USE-BED-FOOT
     MOVE "acceptance bed sleep: a foot without its head half does not put her to sleep" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: a foot without its head half does not set the respawn point" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BW-SPAWN-SET(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An obstructed bed (a block over the head): the player is told so and does not sleep.
     PERFORM SET-WHOLE-BED
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-AY WS-HZ CB-DEFAULT-STATE(WS-BID + 1)
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     PERFORM USE-BED-FOOT
     MOVE "acceptance bed sleep: a block over the head half obstructs the bed, she does not sleep" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     MOVE "acceptance bed sleep: an obstructed bed tells her so as an overlay line" TO TL-CASE
     MOVE "block.minecraft.bed.obstructed()[overlay]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Too far from the bed (more than 3 blocks away): she is told so, no respawn point, no sleep.
     PERFORM SET-WHOLE-BED
     MOVE 0 TO BW-SPAWN-SET(WS-ROW)
     MOVE EN-X(PL-ENTITY-ROW(WS-ROW)) TO WS-SAVED-X
     COMPUTE EN-X(PL-ENTITY-ROW(WS-ROW)) = WS-SAVED-X - 10
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     PERFORM USE-BED-FOOT
     MOVE WS-SAVED-X TO EN-X(PL-ENTITY-ROW(WS-ROW))
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     MOVE "acceptance bed sleep: too far from the bed she is told so as an overlay line" TO TL-CASE
     MOVE "block.minecraft.bed.too_far_away()[overlay]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: too far from the bed she does not sleep" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An occupied bed (the head half has occupied = true): she is told so.
     PERFORM SET-WHOLE-BED
     MOVE WS-BED-STATE TO WS-STATE
     MOVE "south" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-FACING WS-PROP-TEXT
     MOVE "head" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-PART WS-PROP-TEXT
     MOVE "true" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-STATE
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     PERFORM USE-BED-HEAD
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-TEXT
     MOVE "acceptance bed sleep: an occupied bed tells her so as an overlay line" TO TL-CASE
     MOVE "block.minecraft.bed.occupied()[overlay]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: an occupied bed does not take her" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Asleep, she is in the bed: both halves are occupied; leaving the world asleep frees the bed and the row.
     PERFORM SET-WHOLE-BED
     PERFORM USE-BED-FOOT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND
     MOVE "acceptance bed sleep: asleep, the foot half of the bed is occupied" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PLAYER-LEAVE" USING WS-ROW
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND
     MOVE "acceptance bed sleep: a player who leaves asleep frees the bed" TO TL-CASE
     MOVE "false" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bed sleep: and the row is not asleep for the next player" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> A whole bed facing south: foot at (x, y, z), head at (x, y, z + 1); air above both; no block over them.
 SET-WHOLE-BED.
     MOVE WS-BED-STATE TO WS-STATE
     MOVE "south" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-FACING WS-PROP-TEXT
     MOVE "head" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-PART WS-PROP-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-STATE
     MOVE "foot" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-PART WS-PROP-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-AY WS-BZ WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-AY WS-HZ WS-VOID
*>   Room to stand beside the bed (the spawn is on a hillside): air at the feet and the head of the cells round it, stone under them (she stands up there, lane bugsleep).
     MOVE "stone" TO WS-KEY2
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY2 WS-BID2 WS-BROW2 WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID2 + 1) TO WS-STONE
     COMPUTE WS-FLOOR-Y = WS-BY - 1
     PERFORM VARYING WS-RX FROM -1 BY 1 UNTIL WS-RX > 1
         PERFORM VARYING WS-RZ FROM -1 BY 1 UNTIL WS-RZ > 2
             COMPUTE WS-NX = WS-BX + WS-RX
             COMPUTE WS-NZ = WS-BZ + WS-RZ
             IF WS-RX NOT = 0 OR WS-RZ < 0 OR WS-RZ > 1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-BY WS-NZ WS-VOID
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-AY WS-NZ WS-VOID
             END-IF
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-FLOOR-Y WS-NZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO W2-SLEEPING(WS-ROW)
     MOVE 0 TO W2-SLEEP-COUNTER(WS-ROW).

 USE-BED-FOOT.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-SEQ.

 USE-BED-HEAD.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-HZ WS-FACE WS-SEQ.

*> What the connection was sent about her entity: the last pose of a Set Entity Data (entry 6; -1 when none), the last sleeping position (entry 14, "x,y,z"
*> or "none"; spaces when none was sent) and whether an Animate with action 0 arrived (id 2).
 DRAIN-SLEEP-PACKETS.
     MOVE -1 TO WS-SEEN-POSE
     MOVE SPACES TO WS-SEEN-POS
     MOVE 0 TO WS-SEEN-WAKE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 101
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-SEEN-ENTITY
                     IF WS-SEEN-ENTITY = PL-ENTITY-ID(WS-ROW)
                         PERFORM READ-METADATA
                     END-IF
                 WHEN 2
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-SEEN-ENTITY
                     CALL "PB-GET-UBYTE" USING PK-BUFFER WS-A
                     IF WS-SEEN-ENTITY = PL-ENTITY-ID(WS-ROW) AND WS-A = 0
                         MOVE 1 TO WS-SEEN-WAKE
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

 READ-METADATA.
     MOVE 0 TO WS-INDEX
     PERFORM UNTIL WS-INDEX = 255 OR PK-ERROR = 1
         CALL "PB-GET-UBYTE" USING PK-BUFFER WS-INDEX
         IF WS-INDEX NOT = 255
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-SER
             EVALUATE WS-SER
                 WHEN 0
                     CALL "PB-GET-BYTE" USING PK-BUFFER WS-A
                 WHEN 20
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     IF WS-INDEX = 6
                         MOVE WS-A TO WS-SEEN-POSE
                     END-IF
                 WHEN 11
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-PRESENT
                     MOVE "none" TO WS-SEEN-POS
                     IF WS-PRESENT = 1
                         CALL "PB-GET-POSITION" USING PK-BUFFER WS-X WS-Y WS-Z
                         MOVE WS-X TO WS-E1
                         MOVE WS-Y TO WS-E2
                         MOVE WS-Z TO WS-E3
                         MOVE SPACES TO WS-SEEN-POS
                         STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-SEEN-POS
                     END-IF
                 WHEN OTHER
                     MOVE 1 TO PK-ERROR
             END-EVALUATE
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BED-SLEEP.

 COPY CORETEST.
