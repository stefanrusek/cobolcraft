*> Implementation test (wrap I3 r5, T2814/T2815; docs/protocol/20-mobs-overworld-hostile.md section 4.5): the drowned's equipment draw and its approach.
*> Equipment (populateDefaultEquipmentSlots, replacing the zombie one): nextFloat > 0.9 gives a weapon, then nextInt(16) < 10 a trident, else a fishing rod. The held item is EN-HAND
*> 1000 + the item id. The approach (RangedAttackGoal, 18 section 4, radius 10): a drowned that holds a trident and has a target counts seeTime (EN-SWELL) with a line of sight and
*> stands still (stop 1) when the target is within 10 blocks and seeTime is at least 5; otherwise it keeps walking to the target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-DROWNED-GIFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY XORO REPLACING LEADING ==XR-== BY ==XS-==.
 COPY XORO REPLACING LEADING ==XR-== BY ==XB-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-DROWNED             BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-K48                 PIC X(48).
 01 WS-TRIDENT             BINARY-LONG.
 01 WS-ROD                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-D                   FLOAT-LONG.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-PICK                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG.
 01 WS-TRIDENTS            BINARY-LONG.
 01 WS-RODS                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-STOP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STOPS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 3 TO BW-DIFFICULTY
     MOVE 18000 TO CW-TIME
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "trident" TO WS-K48
     CALL "RL-ITEM-ID-OF" USING WS-K48 WS-TRIDENT
     MOVE SPACES TO WS-K48
     MOVE "fishing_rod" TO WS-K48
     CALL "RL-ITEM-ID-OF" USING WS-K48 WS-ROD
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:drowned" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-DROWNED
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE "acceptance US15 20§4.5 both items exist in the item table" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TRIDENT >= 0 AND WS-ROD >= 0 AND WS-TRIDENT NOT = WS-ROD
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Equipment draw: for every seed the hand is what nextFloat > 0.9, then nextInt(16) < 10, say (drawn on a second state seeded alike).
     MOVE 0 TO WS-BAD WS-NONE WS-TRIDENTS WS-RODS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE WS-I TO WS-SEED
         MOVE 0 TO EN-HAND(WS-DROWNED)
         CALL "XORO-SEED" USING WS-SEED XS-STATE
         CALL "STDMOB-FINALIZE" USING XS-STATE WS-DROWNED
         CALL "XORO-SEED" USING WS-SEED XB-STATE
         CALL "XORO-NEXT-DOUBLE" USING XB-STATE WS-D
         MOVE 0 TO WS-WANT
         IF WS-D > 0.9
             CALL "XORO-NEXT-INT" USING XB-STATE WS-SIXTEEN WS-PICK
             IF WS-PICK < 10
                 COMPUTE WS-WANT = 1000 + WS-TRIDENT
                 ADD 1 TO WS-TRIDENTS
             ELSE
                 COMPUTE WS-WANT = 1000 + WS-ROD
                 ADD 1 TO WS-RODS
             END-IF
         ELSE
             ADD 1 TO WS-NONE
         END-IF
         IF EN-HAND(WS-DROWNED) NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.5 the finalized drowned's hand follows the documented draw for 120 seeds" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§4.5 the seeds cover no weapon, a trident and a fishing rod" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NONE > 0 AND WS-TRIDENTS > 0 AND WS-RODS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie keeps its own draw: no trident or fishing rod comes from it.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE WS-I TO WS-SEED
         MOVE 0 TO EN-HAND(WS-ZOMBIE)
         CALL "XORO-SEED" USING WS-SEED XS-STATE
         CALL "STDMOB-FINALIZE" USING XS-STATE WS-ZOMBIE
         IF EN-HAND(WS-ZOMBIE) >= 1000
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.5 a zombie is never given a trident or a fishing rod" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Approach: the drowned holds a trident, the player is 6 blocks away in the open.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-DROWNED)
     COMPUTE EN-Y(WS-DROWNED) = WS-FY + 1
     COMPUTE EN-Z(WS-DROWNED) = PL-Z(WS-PLAYER) + 6
     COMPUTE EN-HAND(WS-DROWNED) = 1000 + WS-TRIDENT
     MOVE WS-PLAYER TO EN-TARGET(WS-DROWNED)
     MOVE 0 TO EN-SWELL(WS-DROWNED)
     MOVE 0 TO WS-STOPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-STOP
         CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
         ADD WS-STOP TO WS-STOPS
     END-PERFORM
     MOVE "acceptance US15 18§4 RangedAttackGoal: it keeps walking while seeTime is below 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STOPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STOP
     CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
     MOVE "acceptance US15 18§4 RangedAttackGoal: at seeTime 5 within 10 blocks it stands still" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4 seeTime counts the ticks of sight" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-DROWNED) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Beyond 10 blocks it walks on, however long it has seen the target.
     COMPUTE EN-Z(WS-DROWNED) = PL-Z(WS-PLAYER) + 12
     MOVE 20 TO EN-SWELL(WS-DROWNED)
     MOVE 0 TO WS-STOP
     CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
     MOVE "acceptance US15 18§4 beyond the radius 10 it walks on" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-Z(WS-DROWNED) = PL-Z(WS-PLAYER) + 6
*>   Without a line of sight the seeTime resets and it walks on.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     COMPUTE WS-BY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 20 TO EN-SWELL(WS-DROWNED)
     MOVE 0 TO WS-STOP
     CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
     MOVE "acceptance US15 18§4 a lost line of sight resets seeTime (then counts down to -1) and it walks on" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STOP + EN-SWELL(WS-DROWNED)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   Without a trident, or without a target, it never stands for the goal.
     MOVE 0 TO EN-HAND(WS-DROWNED)
     MOVE 9 TO EN-SWELL(WS-DROWNED)
     MOVE 0 TO WS-STOP
     CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
     MOVE "acceptance US15 18§4 without a trident it walks on and keeps no seeTime" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STOP + EN-SWELL(WS-DROWNED)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-HAND(WS-DROWNED) = 1000 + WS-TRIDENT
     MOVE 0 TO EN-TARGET(WS-DROWNED)
     MOVE 9 TO EN-SWELL(WS-DROWNED)
     MOVE 0 TO WS-STOP
     CALL "DROWNED-TRIDENT-STAND" USING WS-DROWNED WS-STOP
     MOVE "acceptance US15 18§4 without a target it walks on and keeps no seeTime" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STOP + EN-SWELL(WS-DROWNED)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-DROWNED-GIFT.
 COPY CORETEST.
 COPY MOBSPTEST.
