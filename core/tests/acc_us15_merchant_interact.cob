*> Acceptance test, the right click on a merchant through the real Interact packet (docs/protocol/40-menus-5 section 2.1, 19 sections 22.4 and 23; lane 002-lane-villagers, T12101): the
*> serverbound Interact (0x1A, main hand) on a villager with a profession and on a wandering trader opens the merchant menu (Open Screen 0x3C, menu type 19) and sends Merchant Offers (0x35)
*> with the offers; on an unemployed villager and on a nitwit nothing opens. The profession is taken the way the game takes it (a workstation next to the villager, CORE-TICK), not set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-MERCHANT-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
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
 01 WS-TTYPE               BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-SPACED              PIC X(1030).
 01 WS-N60                 PIC 9.
 01 WS-N53                 PIC 9.
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
     MOVE "wandering_trader" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     COMPUTE WS-X = WS-PX + 0.5
     MOVE WS-PY TO WS-Y
     COMPUTE WS-Z = WS-PZ + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   An unemployed villager: nothing opens.
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 19§22.4 Interact on a villager without a profession opens no window" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
*>   A nitwit: nothing opens either.
     MOVE "nitwit" TO VL-PROF(WS-S1)
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 19§22.4 Interact on a nitwit opens no window" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     MOVE "none" TO VL-PROF(WS-S1)
*>   The villager takes a profession as in the game: a composter beside it, the world ticks.
     COMPUTE WS-BX = WS-PX + 1
     MOVE "minecraft:composter" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 3000 TO CW-TIME
         MOVE 20 TO WS-N
         CALL "TEST-TICKS" USING WS-N
     END-PERFORM
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 44§2.6 the villager became a farmer first" TO TL-CASE
     MOVE "farmer" TO TL-EXPECTED
     MOVE VL-PROF(WS-S1) TO TL-OBSERVED
     PERFORM CHECK
*>   Right click on the farmer: Open Screen (60), Merchant Offers (53).
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 40§2.1 Interact on a farmer sends Open Screen then Merchant Offers" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     MOVE "acceptance US15 40§2.1 the menu is type 19 with 3 own slots" TO TL-CASE
     MOVE "19 3" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-TYPE(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 19§22.4 the farmer has offers (level 1 set)" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF VL-O-N(WS-S1) > 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   A wandering trader.
     COMPUTE WS-X = WS-PX - 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TTYPE WS-X WS-Y WS-Z WS-YAW WS-V2
     CALL "VL-FIND" USING EN-ID(WS-V2) WS-NO WS-S2
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V2) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 40§2.1 Interact on a wandering trader sends Open Screen then Merchant Offers" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     STOP RUN.

*> COUNT-OPEN: TL-OBSERVED = "<Open Screen packets> <Merchant Offers packets>" (0 or 1 each) of the packet ids listed in WS-IDS
 COUNT-OPEN.
     MOVE SPACES TO WS-SPACED
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N60 WS-N53
     INSPECT WS-SPACED TALLYING WS-N60 FOR ALL " 60 " ALL " 60x"
     INSPECT WS-SPACED TALLYING WS-N53 FOR ALL " 53 " ALL " 53x"
     IF WS-N60 > 1
         MOVE 1 TO WS-N60
     END-IF
     IF WS-N53 > 1
         MOVE 1 TO WS-N53
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING WS-N60 " " WS-N53 DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-MERCHANT-INTERACT.
 COPY CORETEST.
 COPY BETEST.
