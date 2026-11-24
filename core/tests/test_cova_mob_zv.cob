*> Implementation test (coverage lane A; docs/protocol/20 section 4.2; core/src/mob-zv.cob): a full cure table refuses a new cure, the cure of a zombie villager among iron bars is
*> faster than one tick a tick (the 1 in 100 scan of its surroundings, each bar adding with probability 0.3), and a villager killed by a creature that is no zombie is not converted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MOB-ZV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY ZVCURE.
 COPY CBLOCKS.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-ZROW                BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-KROW                BINARY-LONG.
 01 WS-KEY-SAVED           PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HELD                PIC X(24) VALUE "golden_apple".
 01 WS-USED                BINARY-LONG.
 01 WS-WEAK                BINARY-LONG VALUE 17.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 1000.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-BARS                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-START               BINARY-LONG VALUE 1000000.
 01 WS-TICKS               BINARY-LONG VALUE 3000.
 01 WS-CONVERTED           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZROW
*>   Every cure slot is taken: a golden apple on a weakened zombie villager starts nothing.
     CALL "MEF-ADD" USING EN-ID(WS-ZROW) WS-WEAK WS-AMP WS-DUR WS-FLAGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ZC-MAX
         MOVE 900000 TO ZC-ID(WS-I)
         ADD WS-I TO ZC-ID(WS-I)
     END-PERFORM
     CALL "ZV-USE" USING WS-PLAYER WS-ZROW WS-HELD WS-USED
     MOVE "test cova mob zv a full cure table refuses a new cure" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ZC-MAX
         INITIALIZE ZC-ENTRY(WS-I)
     END-PERFORM
*>   Iron bars round the zombie villager: over many ticks the cure runs faster than one a tick.
     MOVE "minecraft:iron_bars" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BARS
     MOVE CB-KEY(CB-S-BLOCK(WS-BARS + 1) + 1) TO WS-KEY-SAVED
     MOVE "minecraft:iron_bars" TO CB-KEY(CB-S-BLOCK(WS-BARS + 1) + 1)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) + 2
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 1 + FUNCTION MOD(WS-I, 4)
         COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z) + 1 + WS-I / 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BARS
     END-PERFORM
     CALL "ZC-FIND" USING EN-ID(WS-ZROW) WS-YES WS-SLOT
     MOVE WS-START TO ZC-TIME(WS-SLOT)
     MOVE WS-PLAYER TO ZC-PLAYER(WS-SLOT)
     PERFORM WS-TICKS TIMES
         CALL "ZV-TICK" USING WS-ZROW
     END-PERFORM
     MOVE WS-KEY-SAVED TO CB-KEY(CB-S-BLOCK(WS-BARS + 1) + 1)
     MOVE "test cova mob zv bars speed the cure beyond one tick a tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-START - ZC-TIME(WS-SLOT) > WS-TICKS
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A villager killed by a villager (no zombie) stays a villager.
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X WS-Y WS-Z WS-YAW WS-KROW
     CALL "ZV-KILLED" USING WS-VROW WS-KROW WS-CONVERTED
     MOVE "test cova mob zv a villager killed by a non-zombie is not converted" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CONVERTED TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MOB-ZV.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
