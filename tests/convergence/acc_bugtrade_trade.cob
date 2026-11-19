*> Convergence acceptance test of the operator report "can't interact with villagers (farmer)" (try15 play; bug lane bugtrade; docs/protocol/40-menus-5 section 2.1, 19 section 22.4):
*> a standard superflat world made through the client's single-player host from the generated packs (CC_GENERATED_DIR; a pass without them), a farmer villager (level 1) standing 2 blocks
*> in front of the Player, who looks at it and presses the right button. Everything goes through the client and the core: the look ray meets the villager (its registry category is MISC,
*> which once gave it no hit box), the client sends Interact (05c 0x1A), the core opens the merchant window and sends the offers, and the client opens the trading screen holding them.
*> A villager without a profession, 2 blocks to the side, opens nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGTRADE-TRADE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugtrade-trade".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "TradeFlat".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-LINE                PIC X(80).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-FARMER              BINARY-LONG VALUE 1.
 01 WS-N                   BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugtrade: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO PL-YAW PL-PITCH
*>   A villager made by the core 2 blocks ahead (+Z) with a composter beside it: it takes the farmer profession as in the game (a few hundred ticks).
     MOVE PL-X TO WS-X
     MOVE PL-Y TO WS-Y
     COMPUTE WS-Z = PL-Z + 2
     CALL "TRADE-SPAWN" USING WS-X WS-Y WS-Z WS-FARMER
     MOVE 200 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 1 TO IN-CAPTURED
     MOVE "acceptance bugtrade given a villager 2 blocks ahead with a composter beside it when the world has run then it is a farmer in the core and the client shows the world screen" TO TL-CASE
     MOVE "farmer world screen, no offers" TO TL-EXPECTED
     CALL "TRADE-PROFESSION" USING TL-OBSERVED
     IF SM-SCREEN = SCR-WORLD AND MC-COUNT = 0 AND TL-OBSERVED(1:6) = "farmer"
         MOVE "farmer world screen, no offers" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The right button on the villager the Player looks at.
*>   The villager has walked off (to its workstation): she goes to 2 blocks north (-Z) of where the client sees it now (the standard /tp command).
     COMPUTE WS-TX = FUNCTION INTEGER(EN-X(1)) + 0.5
     COMPUTE WS-TZ = FUNCTION INTEGER(EN-Z(1)) - 1.5
     MOVE WS-TX TO WS-F1
     MOVE WS-TZ TO WS-F2
     MOVE SPACES TO WS-LINE
     STRING "/tp Alice " FUNCTION TRIM(WS-F1) " -60 " FUNCTION TRIM(WS-F2) " 0 0" DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO IN-CAPTURED
*>   She looks at the farmer where the client sees it now (yaw 0 faces +Z, 90 faces -X).
     COMPUTE WS-DX = EN-X(1) - PL-X
     COMPUTE WS-DZ = EN-Z(1) - PL-Z
     COMPUTE PL-YAW = FUNCTION ATAN(0 - WS-DX / WS-DZ) * 180 / FUNCTION PI
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE MC-COUNT TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE "acceptance bugtrade given the Player looks at the farmer 2 blocks away when the right button is pressed then the trading screen is open with offers" TO TL-CASE
     MOVE "container screen with offers" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E2) " offers " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     IF SM-SCREEN = SCR-CONTAINER AND MC-COUNT > 0
         MOVE "container screen with offers" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGTRADE-TRADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADE-SPAWN.
*> USING x, y, z (FLOAT-LONG), farmer (1) or no profession (0): a villager of the open core world at that place (in the dimension of the first player), through the core's own spawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BKEY                PIC X(112).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-BSTATE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FARMER               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FARMER.
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             MOVE PL-DIM(WS-P) TO WS-DIM
         END-IF
     END-PERFORM
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE L-X L-Y L-Z WS-YAW WS-ROW
     IF L-FARMER = 1
         COMPUTE WS-BX = FUNCTION INTEGER(L-X) - 1
         COMPUTE WS-BY = FUNCTION INTEGER(L-Y)
         COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
         MOVE "minecraft:composter" TO WS-BKEY
         CALL "BLOCKS-STATE-OF" USING WS-BKEY WS-PAIRS WS-BSTATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BSTATE
     END-IF
     GOBACK.
 END PROGRAM TRADE-SPAWN.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRADE-PROFESSION.
*> USING text out (PIC X(240)): the profession of the first villager of the core world ("farmer"...).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(240).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE VL-PROF(1) TO L-TEXT
     GOBACK.
 END PROGRAM TRADE-PROFESSION.
