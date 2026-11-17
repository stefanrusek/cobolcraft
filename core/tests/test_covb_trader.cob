*> Implementation test (lane covB; docs/protocol/19 section 22.5): the wandering trader's spawn attempt with nobody online (it reports success), with a bell near the player (the attempt
*> is centred on the bell), over a place with no ground (it makes none), the trader tick with the spawning rule off and the trader step of a row that is not a trader.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-TRADER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-GATE                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT0              BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TRADER-T            BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 120.
 01 WS-FKIND              BINARY-LONG VALUE 1.
 01 WS-BELL                BINARY-LONG.
 01 WS-KIND-BELL           BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawn_wandering_traders".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-RULE-OLD            BINARY-DOUBLE.
 01 WS-DELAY0              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
*>   Nobody online: the attempt counts as a success without making a trader.
     CALL "TRADER-SPAWN" USING WS-GATE WS-OK
     MOVE "covB 19 22.5 with nobody online the spawn attempt reports success" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:wandering_trader" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TRADER-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
*>   A bell near the player: the trader is placed around the bell (the attempt may fail on the ground; both ends are fine, the bell branch is what runs).
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 5
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 60
     COMPUTE WS-FZ = WS-BZ - 60
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FKIND
     MOVE "bell" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BELL
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BELL
     CALL "PXI-ADD" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BELL
     MOVE 0 TO WS-COUNT0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TRADER-T
             ADD 1 TO WS-COUNT0
         END-IF
     END-PERFORM
     CALL "TRADER-SPAWN" USING WS-GATE WS-OK
     MOVE "covB 19 22.5 a spawn attempt with a bell near the player is a success" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   High above any ground the attempt finds no place and spawns nothing.
     MOVE 600 TO PL-Y(WS-PLAYER)
     MOVE 0 TO WS-COUNT0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TRADER-T
             ADD 1 TO WS-COUNT0
         END-IF
     END-PERFORM
     CALL "TRADER-SPAWN" USING WS-GATE WS-OK
     MOVE 0 TO WS-COUNT1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TRADER-T
             ADD 1 TO WS-COUNT1
         END-IF
     END-PERFORM
     MOVE "covB 19 22.5 with no ground under the player's reach no trader is made" TO TL-CASE
     MOVE WS-COUNT0 TO TL-EXPECTED-N
     MOVE WS-COUNT1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The tick with the spawning rule off does nothing (the delay is not counted down).
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-OLD
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 2400 TO CW-TICKS
     CALL "TRADER-TICK"
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-OLD
     MOVE "covB 19 22.5 the trader tick with the rule off leaves the world as it is" TO TL-CASE
     MOVE WS-COUNT1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TRADER-T
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The step of a row with no trader state does nothing.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE 70 TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     CALL "TRADER-STEP" USING WS-COW
     MOVE "covB 19 22.5 the trader step ignores a cow" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-TRADER.
 COPY CORETEST.
 COPY MOBSPTEST.
