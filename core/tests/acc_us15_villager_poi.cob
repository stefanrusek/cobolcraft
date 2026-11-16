*> Acceptance test, villagers claiming a workstation (docs/protocol/44 section 1.3, 2.1, 2.6; 54 section 4.4; 19 section 22.7; lane 002-lane-mobsb2, T7102): a villager without a
*> profession scans for a workstation of the 13 job site types, claims the nearest one that has a free ticket (one ticket each) and takes its profession when it is within 2 blocks;
*> a second villager does not get a claimed workstation until the first villager is gone; a workstation out of reach is not found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-POI.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:blast_furnace" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 1
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-STATE
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V2
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     CALL "VL-FIND" USING EN-ID(WS-V2) WS-NO WS-S2
     MOVE "T" TO TL-MODE
     MOVE 100 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V1
     MOVE "acceptance US15 44§2.1 the first evaluation only sets the scan timer: still no profession" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     MOVE VL-PROF(WS-S1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE 200 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V1
     MOVE "acceptance US15 44§2.6 the villager next to a blast furnace becomes an armorer" TO TL-CASE
     MOVE "armorer" TO TL-EXPECTED
     MOVE VL-PROF(WS-S1) TO TL-OBSERVED
     PERFORM CHECK
     CALL "VP-OWNER" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-OWNER
     MOVE "acceptance US15 44§1.3 the workstation is claimed by that villager" TO TL-CASE
     MOVE EN-ID(WS-V1) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-EXPECTED
     MOVE WS-OWNER TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE 300 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V2
     MOVE 400 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V2
     MOVE "acceptance US15 44§1.3 a claimed workstation is not given to a second villager" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     MOVE VL-PROF(WS-S2) TO TL-OBSERVED
     PERFORM CHECK
     CALL "VL-REMOVE" USING EN-ID(WS-V1)
     MOVE 500 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V2
     MOVE 600 TO CW-TICKS
     CALL "VL-SCAN" USING WS-V2
     MOVE "acceptance US15 22.5 the claim is released with the first villager: the second takes the job" TO TL-CASE
     MOVE "armorer" TO TL-EXPECTED
     MOVE VL-PROF(WS-S2) TO TL-OBSERVED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-VILLAGER-POI.
 COPY CORETEST.
