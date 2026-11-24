*> Acceptance test, a villager takes a profession through the whole running chain (docs/protocol/44 sections 1.3, 2.1, 2.5 and 2.6, 19 sections 22.3 and 22.7, 46 section 6.2; lane
*> 002-lane-villagers, T12100): CORE-TICK only, no direct call of the brain. A villager lives for a while with nothing around it; a composter is then placed (WORLD-SET-BLOCK, the place every
*> placement ends in) next to it and the villager becomes a farmer; a second composter 4 blocks away is found through the POI index, walked to (potential job site, in the idle activity at day tick 11500) and taken by a
*> second villager; the profession reaches Set Entity Data (index 19 VILLAGER_DATA: type, profession id, level) for the player that sees the villager and again as a change when it is taken.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-JOB-CHAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ROWKEY              BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-F3                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-OUT                 PIC X(40).
 01 WS-IDS                 PIC X(1024).
 01 WS-SAW                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CLOCK               BINARY-LONG VALUE 3000.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 3000 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-STONE
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
*>   A corridor along x: stone floor under the villagers, air at the feet and head height.
     PERFORM VARYING WS-I FROM -6 BY 1 UNTIL WS-I > 6
         COMPUTE WS-BX = WS-PX + WS-I
         COMPUTE WS-BY = WS-PY - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-PZ WS-STONE
         MOVE WS-PY TO WS-BY
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-PZ WS-AIR
         COMPUTE WS-BY = WS-PY + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-PZ WS-AIR
     END-PERFORM
     COMPUTE WS-X = WS-PX + 0.5
     MOVE WS-PY TO WS-Y
     COMPUTE WS-Z = WS-PZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     MOVE "T" TO TL-MODE
*>   A while with no workstation anywhere near: the villagers' scans and brains run on.
     MOVE 400 TO WS-T
     PERFORM TICK-DAY
     MOVE "acceptance US15 44§2.1 with no job site near the villager stays without a profession" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     MOVE VL-PROF(WS-S1) TO TL-OBSERVED
     PERFORM CHECK
*>   The player's view of it before the profession: no VillagerData of the default needed (or none profession).
     PERFORM FIND-DATA-1
*>   A composter next to the villager.
     COMPUTE WS-BX = WS-PX + 1
     MOVE "minecraft:composter" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STATE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 120 TO WS-T
     PERFORM TICK-DAY
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 44§2.6 a composter placed next to an unemployed villager makes it a farmer" TO TL-CASE
     MOVE "farmer" TO TL-EXPECTED
     MOVE VL-PROF(WS-S1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 19§22.2 the new farmer is level 1" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE VL-LEVEL(WS-S1) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   The change reached the player's client as Set Entity Data.
     MOVE "acceptance US15 19§22 the player was sent Set Entity Data (101) when the profession was taken" TO TL-CASE
     MOVE 0 TO WS-SAW
     INSPECT WS-IDS TALLYING WS-SAW FOR ALL "101"
     MOVE "1" TO TL-EXPECTED
     IF WS-SAW > 0
         MOVE "1" TO TL-OBSERVED
     ELSE
         MOVE "0" TO TL-OBSERVED
     END-IF
     PERFORM CHECK
*>   The metadata the client reads: index 19 = type 2 (plains), profession 5 (farmer), level 1.
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance US15 46§6.2 Set Entity Data index 19: type, profession id (farmer 5), level" TO TL-CASE
     MOVE "2 5 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     PERFORM FORMAT-3
     MOVE WS-OUT(1:5) TO TL-OBSERVED
     PERFORM CHECK
*>   A second villager 3 blocks west, a second composter 4 blocks west of the first spot: found by the index and walked to.
     COMPUTE WS-X = WS-PX - 2 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V2
     CALL "VL-FIND" USING EN-ID(WS-V2) WS-NO WS-S2
     COMPUTE WS-BX = WS-PX - 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STATE
     MOVE 600 TO WS-T
     MOVE 11500 TO WS-CLOCK
     PERFORM TICK-DAY
     MOVE "acceptance US15 44§2.5 the second villager walks to the second composter and becomes a farmer too" TO TL-CASE
     MOVE "farmer" TO TL-EXPECTED
     MOVE VL-PROF(WS-S2) TO TL-OBSERVED
     PERFORM CHECK
     MOVE WS-V2 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance US15 46§6.2 the second villager's index 19 says farmer too" TO TL-CASE
     MOVE "2 5 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     PERFORM FORMAT-3
     MOVE WS-OUT(1:5) TO TL-OBSERVED
     PERFORM CHECK
*>   The farmer is fully formed: its trade set exists (the window of the merchant opens, see acc_us15_merchant_interact).
     STOP RUN.

 TICK-DAY.
     PERFORM VARYING WS-I FROM 1 BY 20 UNTIL WS-I > WS-T
         MOVE WS-CLOCK TO CW-TIME
         MOVE 20 TO WS-F1
         CALL "TEST-TICKS" USING WS-F1
     END-PERFORM.

 FIND-DATA-1.
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA.

*> FIND-DATA: Set Entity Data as MOB-DATA-BUILD makes it for entity row WS-ROWKEY: entry 19 (type, profession, level) into WS-F1 to WS-F3, 0 0 0 when absent
 FIND-DATA.
     MOVE 0 TO WS-F1 WS-F2 WS-F3
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROWKEY MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = 19
                 MOVE MQ-MX-INT TO WS-F1
                 MOVE MQ-MX-INT-2 TO WS-F2
                 MOVE MQ-MX-INT-3 TO WS-F3
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING MQ-BUFFER.

 FORMAT-3.
     MOVE WS-F1 TO WS-E1
     MOVE WS-F2 TO WS-E2
     MOVE WS-F3 TO WS-E3
     MOVE SPACES TO WS-OUT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-OUT.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-VILLAGER-JOB-CHAIN.
 COPY CORETEST.
 COPY BETEST.
