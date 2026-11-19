*> Acceptance test, lane bugsleep (operator report of try19: "beds make it day, but no getting into the bed or getting out. Villagers get into beds; when I try to get in to the bed it
*> says it's occupied, but normally we kick the entity out of the bed instead. Villagers are invisible in beds."; docs/protocol/33 sections 5.2 and 5.3, 19 section 22.8, 18 section 1.4
*> entry 14, 53 pose SLEEPING, 12 section 7.2). A standard world (CC_GENERATED_DIR, skipped as a pass without it), a whole red bed beside Alice, a villager that claims it by day and
*> sleeps in it at night (VL-BRAIN): the clients are sent its pose SLEEPING and the head half of the bed as its sleeping position, and the bed is occupied. Alice uses the bed by night
*> through Use Item On: the villager is kicked out (awake, standing pose and no sleeping position sent, standing beside the bed, not in it), no "occupied" line is sent, she sleeps, lies
*> on the bed (Player Position to the bed) and the bed is occupied by her; a second player is refused with "occupied" (the occupant is not a villager); leaving the bed with STOP_SLEEPING
*> stands her up beside the bed with a Player Position, and a player who joins while the villager sleeps is sent the villager's pose and sleeping position with it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSLEEP-CORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY WSIM2.
 COPY VILSTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-BOB                 PIC X(16) VALUE "Bob".
 01 WS-BOB-LENGTH          BINARY-LONG VALUE 3.
 01 WS-CAROL               PIC X(16) VALUE "Carol".
 01 WS-CAROL-LENGTH        BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BED-STATE           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-PROP-FACING         PIC X(24) VALUE "facing".
 01 WS-PROP-PART           PIC X(24) VALUE "part".
 01 WS-PROP-OCCUPIED       PIC X(24) VALUE "occupied".
 01 WS-FOUND               BINARY-LONG.
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
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SEEN-POSE           BINARY-LONG.
 01 WS-SEEN-POS            PIC X(24).
 01 WS-SEEN-ENTITY         BINARY-LONG.
 01 WS-SEEN-TELEPORTS      BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-EXPECT-POS          PIC X(24).
 01 WS-VKEY                PIC X(112).
 01 WS-VTYPE               BINARY-LONG.
 01 WS-VROW                PIC X(66).
 01 WS-V1                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-TICK-COUNT          BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-FLOOR-Y             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
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
         MOVE "acceptance bugsleep no generated packs here, skipped" TO TL-CASE
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
     MOVE "SleepVil" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "BR-WORLD-READY"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "red_bed" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-BED-STATE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(PL-ENTITY-ROW(WS-ROW))) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(PL-ENTITY-ROW(WS-ROW)))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(PL-ENTITY-ROW(WS-ROW)))
     COMPUTE WS-HZ = WS-BZ + 1
     COMPUTE WS-AY = WS-BY + 1
     COMPUTE WS-FLOOR-Y = WS-BY - 1
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STONE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 0 TO CW-RAINING CW-THUNDERING
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM) CW-RAIN-LEVEL-OLD(WS-DIM) CW-THUNDER-LEVEL(WS-DIM) CW-THUNDER-LEVEL-OLD(WS-DIM)
     MOVE 1000000 TO CW-CLEAR-TIME
     PERFORM SET-WHOLE-BED

*>   A villager standing on the foot half's cell column, by day: it claims the bed as its home.
     MOVE "villager" TO WS-VKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-VKEY WS-VTYPE WS-VROW WS-STATUS
     COMPUTE WS-FX = WS-BX + 0.5
     MOVE WS-BY TO WS-FY
     COMPUTE WS-FZ = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-FX WS-FY WS-FZ WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     MOVE "farmer" TO VL-PROF(WS-S1)
     MOVE 1 TO VL-XP(WS-S1)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     CALL "VPX-OF" USING EN-ID(WS-V1) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "N" TO TL-MODE
     MOVE "acceptance bugsleep: the villager has claimed the bed as its home" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE EN-ID(WS-V1) TO WS-TARGET
     MOVE WS-CONN TO WS-CONN2
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE 14000 TO CW-TIME
     MOVE 1200 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     MOVE "acceptance bugsleep: at night next to its bed the villager sleeps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bugsleep: the clients are sent the SLEEPING pose of the villager (the client draws it lying)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: the clients are sent the head half of the bed as the villager's sleeping position" TO TL-CASE
     PERFORM EXPECT-HEAD-POS
     MOVE WS-EXPECT-POS TO TL-EXPECTED
     MOVE WS-SEEN-POS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     MOVE "N" TO TL-MODE
*>   It lies in the middle of the head half, on the mattress.
     COMPUTE WS-DX = WS-BX + 0.5 - EN-X(WS-V1)
     COMPUTE WS-DZ = WS-HZ + 0.5 - EN-Z(WS-V1)
     MOVE "acceptance bugsleep: the sleeping villager lies in the middle of the head half" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-DX) < 0.01 AND FUNCTION ABS(WS-DZ) < 0.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND
     MOVE "acceptance bugsleep: a bed with a sleeping villager is occupied (head half)" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK

*>   Alice uses the bed by night: the villager is kicked out and she takes the bed (33 section 5.2 step 4).
     MOVE "N" TO TL-MODE
     PERFORM USE-BED-FOOT
     MOVE "acceptance bugsleep: Alice sleeps in the bed the villager left" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: the villager is awake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: the villager woke now (last woken is the tick)" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE VL-LAST-WOKEN(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE EN-ID(WS-V1) TO WS-TARGET
     MOVE WS-CONN TO WS-CONN2
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bugsleep: Alice is sent a Player Position (she is put on the bed)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SEEN-TELEPORTS TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: the clients are sent the standing pose of the villager" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: and no sleeping position for the villager" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     MOVE WS-SEEN-POS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     COMPUTE WS-VX = FUNCTION INTEGER(EN-X(WS-V1))
     COMPUTE WS-VZ = FUNCTION INTEGER(EN-Z(WS-V1))
     MOVE "acceptance bugsleep: the kicked villager stands outside both halves of the bed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF WS-VX = WS-BX AND (WS-VZ = WS-BZ OR WS-VZ = WS-HZ)
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     MOVE "acceptance bugsleep: the kicked villager stands on the floor, not on the mattress" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Y(WS-V1) < WS-BY + 0.25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     MOVE "acceptance bugsleep: the kicked villager is within two blocks of the bed" TO TL-CASE
     COMPUTE WS-DX = WS-BX + 0.5 - EN-X(WS-V1)
     COMPUTE WS-DZ = WS-HZ + 0.5 - EN-Z(WS-V1)
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DX * WS-DX + WS-DZ * WS-DZ < 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND
     MOVE "acceptance bugsleep: the bed is occupied by Alice (head half)" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK

*>   Alice lies on the bed: Player Position to the middle of the head half at mattress height, her own entity sleeps there.
     MOVE "N" TO TL-MODE
     COMPUTE WS-DX = WS-BX + 0.5 - PL-X(WS-ROW)
     COMPUTE WS-DY = WS-BY + 0.5625 - PL-Y(WS-ROW)
     COMPUTE WS-DZ = WS-HZ + 0.5 - PL-Z(WS-ROW)
     MOVE "acceptance bugsleep: Alice is moved onto the bed (x, z the middle of the head half, y the mattress)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-DX) < 0.01 AND FUNCTION ABS(WS-DY) < 0.01 AND FUNCTION ABS(WS-DZ) < 0.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK

*>   Another player is refused: the occupant of the bed is a player, not a villager.
     CALL "TEST-JOIN" USING WS-BOB WS-BOB-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     MOVE EN-X(PL-ENTITY-ROW(WS-ROW)) TO EN-X(PL-ENTITY-ROW(WS-ROW2))
     MOVE EN-Y(PL-ENTITY-ROW(WS-ROW)) TO EN-Y(PL-ENTITY-ROW(WS-ROW2))
     MOVE EN-Z(PL-ENTITY-ROW(WS-ROW)) TO EN-Z(PL-ENTITY-ROW(WS-ROW2))
     MOVE PL-X(WS-ROW) TO PL-X(WS-ROW2)
     MOVE PL-Y(WS-ROW) TO PL-Y(WS-ROW2)
     MOVE PL-Z(WS-ROW) TO PL-Z(WS-ROW2)
     MOVE 0 TO PL-MODE(WS-ROW2)
     CALL "TEST-DRAIN-CHAT" USING WS-CONN2 WS-TEXT
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN2 WS-BX WS-BY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-CHAT" USING WS-CONN2 WS-TEXT
     MOVE "acceptance bugsleep: a player in the bed is not kicked out: the second player is told it is occupied" TO TL-CASE
     MOVE "block.minecraft.bed.occupied()[overlay]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     MOVE "acceptance bugsleep: and Alice still sleeps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE W2-SLEEPING(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK

*>   Leaving the bed: STOP_SLEEPING stands her up beside the bed (Player Position) and frees it.
     MOVE PL-ENTITY-ID(WS-ROW) TO WS-TARGET
     MOVE WS-CONN TO WS-CONN2
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE 0 TO WS-COMMAND
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-COMMAND
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bugsleep: leaving the bed sends Alice a Player Position (she stands up beside the bed)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SEEN-TELEPORTS TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: she stands on the floor, not on the mattress" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y(WS-ROW) < WS-BY + 0.25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     COMPUTE WS-VX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-VZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE "acceptance bugsleep: she stands outside both halves of the bed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF WS-VX = WS-BX AND (WS-VZ = WS-BZ OR WS-VZ = WS-HZ)
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-HZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND
     MOVE "acceptance bugsleep: the bed is free again" TO TL-CASE
     MOVE "false" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK

*>   A villager asleep when a player joins: the join pairs the villager with its pose and sleeping position.
     MOVE "N" TO TL-MODE
     MOVE 0 TO VL-LAST-WOKEN(WS-S1)
     MOVE 0 TO VL-SLEEP(WS-S1)
     COMPUTE WS-FX = WS-BX + 0.5
     MOVE WS-BY TO WS-FY
     COMPUTE WS-FZ = WS-BZ + 0.5
     CALL "ENTITY-MOVE" USING WS-V1 WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-NO
     MOVE 15000 TO CW-TIME
     MOVE 5000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     MOVE "acceptance bugsleep: the villager sleeps again the next night" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE EN-ID(WS-V1) TO WS-TARGET
     CALL "TEST-JOIN-UNDRAINED" USING WS-CAROL WS-CAROL-LENGTH WS-CONN2
     PERFORM DRAIN-SLEEP-PACKETS
     MOVE "acceptance bugsleep: a player who joins is sent the sleeping villager's pose" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SEEN-POSE TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugsleep: a player who joins is sent the sleeping villager's bed position" TO TL-CASE
     PERFORM EXPECT-HEAD-POS
     MOVE WS-EXPECT-POS TO TL-EXPECTED
     MOVE WS-SEEN-POS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A whole bed facing south: foot at (x, y, z), head at (x, y, z + 1); air above both.
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
*>   Open floor all round the bed (the spawn is on a hillside): air at the feet and the head of the cells beside it, stone under them.
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
     END-PERFORM.

 EXPECT-HEAD-POS.
     MOVE WS-BX TO WS-E1
     MOVE WS-BY TO WS-E2
     MOVE WS-HZ TO WS-E3
     MOVE SPACES TO WS-EXPECT-POS
     STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-EXPECT-POS.

 USE-BED-FOOT.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-SEQ.

*> What the connection WS-CONN2 was sent about entity WS-TARGET since the last drain: the last pose of a Set Entity Data (entry 6; -1 when none), the last sleeping position
*> (entry 14, "x,y,z" or "none"; spaces when none was sent) and the number of Player Position packets (id 73).
 DRAIN-SLEEP-PACKETS.
     MOVE -1 TO WS-SEEN-POSE
     MOVE SPACES TO WS-SEEN-POS
     MOVE 0 TO WS-SEEN-TELEPORTS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN2 PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 101
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-SEEN-ENTITY
                     IF WS-SEEN-ENTITY = WS-TARGET
                         PERFORM READ-METADATA
                     END-IF
                 WHEN 73
                     ADD 1 TO WS-SEEN-TELEPORTS
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
 END PROGRAM ACC-BUGSLEEP-CORE.

 COPY CORETEST.
