*> Implementation test (lane 002-lane-p49s, T38540 to T38545; docs/protocol/44-residual-mob-questions-6-nether.md section 2.7 detection range, 44-3 section 4.7, 18 section 4.3): the visibility of
*> a player to a mob (crouching, Invisibility with the armour cover, mob_visibility heads), the squared range max(R x v, 2) squared, and the targets a piglin brute (R 12) and a piglin (R 16) take
*> by it: a brute sees a standing player within 12 blocks, a crouching one within 9.6, and an invisible one without armour only within 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-VIS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CMENU.
 COPY EFFECTS.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-K24                 PIC X(24).
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-ZH                  BINARY-LONG.
 01 WS-PH                  BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 01 WS-INV                 BINARY-LONG VALUE 13.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-NP                  BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1000 TO CW-TICKS
     MOVE 0 TO PL-POSE(WS-PLAYER)
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-B
     MOVE "zombie" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-ZH
     MOVE WS-B TO WS-PH
     MOVE WS-A TO WS-CH

*>   The visibility factor.
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 18§4.3 a standing player has visibility 1.0" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-POSE(WS-PLAYER)
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 18§4.3 a crouching player has visibility 0.8" TO TL-CASE
     MOVE 800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-POSE(WS-PLAYER)
     MOVE 1 TO EF-ON(WS-PLAYER, 14)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EF-OWNER(WS-PLAYER, 14)
     MOVE 0 TO EF-AMPLIFIER(WS-PLAYER, 14)
     MOVE 1000 TO EF-DURATION(WS-PLAYER, 14)
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 18§4.3 invisible without armour: x max(0, 0.1) x 0.7 = 0.07" TO TL-CASE
     MOVE 70 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 1) MN-EQUIP-COUNT(WS-PLAYER, 3)
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 18§4.3 invisible with two armour slots: x 0.5 x 0.7 = 0.35" TO TL-CASE
     MOVE 350 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-POSE(WS-PLAYER)
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 18§4.3 crouching and invisible with two armour slots: 0.28" TO TL-CASE
     MOVE 280 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-POSE(WS-PLAYER) EF-ON(WS-PLAYER, 14) MN-EQUIP-COUNT(WS-PLAYER, 1) MN-EQUIP-COUNT(WS-PLAYER, 3)
*>   A head item with mob_visibility: a piglin head for a piglin and a brute, a zombie head for a zombie, no effect on another mob.
     MOVE "piglin_head" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
     CALL "MOB-PLAYER-VIS" USING WS-A WS-PLAYER WS-V
     MOVE "acceptance US15 25 a piglin head halves the visibility to a brute" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-PLAYER-VIS" USING WS-B WS-PLAYER WS-V
     MOVE "acceptance US15 25 a piglin head halves the visibility to a piglin" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-PLAYER-VIS" USING WS-ZH WS-PLAYER WS-V
     MOVE "acceptance US15 25 a piglin head does not change what a zombie sees" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie_head" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 4)
     CALL "MOB-PLAYER-VIS" USING WS-ZH WS-PLAYER WS-V
     MOVE "acceptance US15 25 a zombie head halves the visibility to a zombie" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "skeleton_skull" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE "skeleton" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-M
     CALL "MOB-PLAYER-VIS" USING WS-M WS-PLAYER WS-V
     MOVE "acceptance US15 25 a skeleton skull halves the visibility to a skeleton" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "creeper_head" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE "creeper" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-M
     CALL "MOB-PLAYER-VIS" USING WS-M WS-PLAYER WS-V
     MOVE "acceptance US15 25 a creeper head halves the visibility to a creeper" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
*>   The squared range: max(R x v, 2) squared.
     MOVE 12 TO WS-R
     MOVE 1 TO WS-V
     CALL "MOB-SEE-RANGE2" USING WS-R WS-V WS-R2
     MOVE "acceptance US15 44-3§4.7 a brute (R 12) sees a standing player within 144" TO TL-CASE
     MOVE 144 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-R2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.8 TO WS-V
     CALL "MOB-SEE-RANGE2" USING WS-R WS-V WS-R2
     MOVE "acceptance US15 44-6§2.7 a brute sees a crouching player within 9.6 (squared 92.16)" TO TL-CASE
     MOVE 9216 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-R2 * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.07 TO WS-V
     CALL "MOB-SEE-RANGE2" USING WS-R WS-V WS-R2
     MOVE "acceptance US15 44-3§4.7 the range never falls below 2 blocks (squared 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-R2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The brute's target (STDMOB-TARGET) by distance: standing 11.5 yes, 12.5 no, crouching 9 yes and 10 no, invisible without armour 1.5 yes and 3 no.
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-CH) WS-M
     MOVE 11.5 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-6§2.7 a standing player 11.5 blocks from a brute is its target" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     IF TL-OBSERVED-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12.5 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-6§2.7 a standing player 12.5 blocks away is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-POSE(WS-PLAYER)
     MOVE 9 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-6§2.7 a crouching player 9 blocks away is a target" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     IF TL-OBSERVED-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-6§2.7 a crouching player 10 blocks away is not (radius 9.6)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-POSE(WS-PLAYER)
     MOVE 1 TO EF-ON(WS-PLAYER, 14)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EF-OWNER(WS-PLAYER, 14)
     MOVE 1000 TO EF-DURATION(WS-PLAYER, 14)
     MOVE 1.5 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-3§4.7 an invisible player 1.5 blocks away is still seen (minimum range 2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     IF TL-OBSERVED-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-DISTANCE
     PERFORM TRY-BRUTE
     MOVE "acceptance US15 44-3§4.7 an invisible player 3 blocks away is not seen" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-CH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EF-ON(WS-PLAYER, 14)

*>   The piglin (R 16) takes a crouching player 12 blocks away, not 13.5 (radius 12.8 is 163.84 squared: 13 yes, 13.5 no).
     MOVE 5 TO PL-POSE(WS-PLAYER)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-PH) WS-M
     MOVE 12.5 TO WS-DISTANCE
     PERFORM TRY-PIGLIN
     MOVE "acceptance US15 44-6§2.2 a calm piglin takes a crouching player 12.5 blocks away" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-PH) TO TL-OBSERVED-N
     IF TL-OBSERVED-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13.5 TO WS-DISTANCE
     PERFORM TRY-PIGLIN
     MOVE "acceptance US15 44-6§2.2 but not one 13.5 blocks away (radius 12.8)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-PH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-POSE(WS-PLAYER)
     MOVE 15.5 TO WS-DISTANCE
     PERFORM TRY-PIGLIN
     MOVE "acceptance US15 44-6§2.2 a standing player 15.5 blocks away is taken" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-PH) TO TL-OBSERVED-N
     IF TL-OBSERVED-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The sensors' visibility predicate (44-3 section 4.7): the candidates are the follow-range cube but the test is the sphere (R 16): a piglin at (11, 11) is 15.6 away and counts, at (14, 14) it
*>   is in the cube and 19.8 away and does not.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-DISTANCE = WS-X0 + 11
     COMPUTE WS-R = WS-Z0 + 11
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-DISTANCE WS-Y WS-R WS-B
     CALL "PGAI-SENSE" USING WS-A WS-YES WS-NP WS-NH WS-HUNT WS-NEAR
     MOVE "acceptance US15 44-3§4.7 an adult piglin 15.6 blocks away (diagonal) is visible" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B
     COMPUTE WS-DISTANCE = WS-X0 + 14
     COMPUTE WS-R = WS-Z0 + 14
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-DISTANCE WS-Y WS-R WS-B
     CALL "PGAI-SENSE" USING WS-A WS-YES WS-NP WS-NH WS-HUNT WS-NEAR
     MOVE "acceptance US15 44-3§4.7 one at the corner of the cube (19.8 blocks) is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 TRY-BRUTE.
     MOVE 0 TO EN-TARGET(WS-CH) EN-TARGET-ID(WS-CH)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CH) + WS-DISTANCE
     MOVE EN-Z(WS-CH) TO PL-Z(WS-PLAYER)
     MOVE EN-Y(WS-CH) TO PL-Y(WS-PLAYER)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-CH) WS-M
     CALL "STDMOB-TARGET" USING WS-CH WS-M.
 TRY-PIGLIN.
     MOVE 0 TO EN-TARGET(WS-PH) EN-TARGET-ID(WS-PH) EN-ANGER(WS-PH)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-PH) + WS-DISTANCE
     MOVE EN-Z(WS-PH) TO PL-Z(WS-PLAYER)
     MOVE EN-Y(WS-PH) TO PL-Y(WS-PLAYER)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-PH) WS-M
     CALL "NETHER-AGGRO" USING WS-PH WS-M.
 END PROGRAM TEST-Q44-44-6-VIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM T-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM T-SPAWN.

 COPY CORETEST.
 COPY MOBSPTEST.
 COPY BETEST.
