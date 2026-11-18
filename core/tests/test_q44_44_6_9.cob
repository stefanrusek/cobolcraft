*> Blaze, ghast, magma cube, wither skeleton: details (docs/protocol/44-residual-mob-questions-6-nether.md section 9.4 and V15; lane 002-lane-p49c, T15540): the wither skeleton
*> holds a stone sword (no bow) and is immune to the Wither effect while other effects and other mobs are not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO REPLACING LEADING ==XR-== BY ==XS-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7.
 01 WS-K40                 PIC X(40).
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 200.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z2                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:wither_skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z2
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X WS-Y WS-Z2 WS-YAW WS-W
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z2 WS-YAW WS-Z
*>   Default equipment: a stone sword in the main hand.
     CALL "XORO-SEED" USING WS-SEED XS-STATE
     CALL "STDMOB-FINALIZE" USING XS-STATE WS-W
     CALL "STDMOB-HAND-KEY" USING EN-HAND(WS-W) WS-K40
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 44-6§9.4 the wither skeleton holds a stone sword" TO TL-CASE
     MOVE "minecraft:stone_sword" TO TL-EXPECTED
     MOVE WS-K40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Immune to the Wither effect (canBeAffected), not to poison; a zombie takes both.
     CALL "MEF-ADD" USING EN-ID(WS-W) WS-WITHER WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-LEVEL" USING EN-ID(WS-W) WS-WITHER WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-6§9.4 V15 the wither skeleton does not take the Wither effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-ADD" USING EN-ID(WS-W) WS-POISON WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-LEVEL" USING EN-ID(WS-W) WS-POISON WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-6§9.4 but takes poison" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-ADD" USING EN-ID(WS-Z) WS-WITHER WS-AMP WS-DUR WS-FLAGS
     CALL "MEF-LEVEL" USING EN-ID(WS-Z) WS-WITHER WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-6§9.4 a zombie takes the Wither effect" TO TL-CASE
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-9.
 COPY CORETEST.
 COPY MOBSPTEST.
