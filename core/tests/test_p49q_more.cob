*> Remaining branches of the p49q programs (lane 002-lane-p49q): a bell hit with the wrong block or a sneaking player holding an item, bells facing south, west and east; the bed occupied property
*> on beds facing south, west and east, with no claim and with a claim on a block that is no bed; a sleeping villager removed in its bed frees it; PoiCompetitorScan and YieldJobSite with no claim, on
*> a block that is no workstation, and with a rival holding the very site; baby villager behaviours: wrong activity, a stale visible list, a baby chased by another (the fewest-chasers pick), JumpOnBed
*> ending (the bed gone, the walking budget used) and the idle activity's draw.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49Q-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOI.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SD                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-JOB                 BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-BABY                BINARY-LONG VALUE 1.
 01 WS-NOT-BABY            BINARY-LONG VALUE 0.
 01 WS-ACT                 BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 COPY PROTO REPLACING LEADING ==PB-== BY ==BD-==.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 6
     COMPUTE WS-Y = WS-FY + 1
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-A WS-SA
     COMPUTE WS-X = WS-X0 + 2
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-B WS-SB
     COMPUTE WS-X = WS-X0 - 2
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-C WS-SC
     COMPUTE WS-X = WS-X0 + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-D WS-SD
*>   ----- the bell: not a bell, a sneaking player with an item, bells facing south, west, east.
     COMPUTE WS-X = WS-X0 + 10
     COMPUTE WS-Z = WS-Z0 + 6
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     MOVE 2 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE "minecraft:bell" TO WS-KEY
     MOVE "attachment=floor,facing=south,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 3 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-SA MT-HEARD-BELL-TIME WS-HAS
     MOVE "test p49q a sneaking player holding an item does not ring the bell (the item is used)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-SA MT-HEARD-BELL-TIME WS-HAS
     MOVE "test p49q a bell facing south rings from its south face" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-ERASE" USING WS-SA MT-HEARD-BELL-TIME
     MOVE "attachment=floor,facing=west,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     MOVE 4 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-SA MT-HEARD-BELL-TIME WS-HAS
     MOVE "test p49q a bell facing west rings from its west face" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-ERASE" USING WS-SA MT-HEARD-BELL-TIME
     MOVE "attachment=floor,facing=east,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     MOVE 5 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-SA MT-HEARD-BELL-TIME WS-HAS
     MOVE "test p49q a bell facing east rings from its east face" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   ----- beds facing south, west, east: the occupied property on both halves.
     MOVE "minecraft:red_bed" TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = WS-X0 + 4 * WS-I
         COMPUTE WS-Z = WS-Z0 - 8
         EVALUATE WS-I
             WHEN 1
                 MOVE "facing=south,occupied=false,part=head" TO WS-PAIRS
                 COMPUTE WS-Z2 = WS-Z - 1
                 MOVE WS-X TO WS-X2
             WHEN 2
                 MOVE "facing=west,occupied=false,part=head" TO WS-PAIRS
                 COMPUTE WS-X2 = WS-X + 1
                 MOVE WS-Z TO WS-Z2
             WHEN OTHER
                 MOVE "facing=east,occupied=false,part=head" TO WS-PAIRS
                 COMPUTE WS-X2 = WS-X - 1
                 MOVE WS-Z TO WS-Z2
         END-EVALUATE
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
         EVALUATE WS-I
             WHEN 1
                 MOVE "facing=south,occupied=false,part=foot" TO WS-PAIRS
             WHEN 2
                 MOVE "facing=west,occupied=false,part=foot" TO WS-PAIRS
             WHEN OTHER
                 MOVE "facing=east,occupied=false,part=foot" TO WS-PAIRS
         END-EVALUATE
         CALL "VT-PLACE" USING WS-DIM WS-X2 WS-Y WS-Z2 WS-KEY WS-PAIRS
         CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-HOME
         CALL "VPX-CLAIM" USING EN-ID(WS-A) WS-HOME WS-DIM WS-X WS-Y WS-Z
         CALL "VL-BED-OCCUPY" USING EN-ID(WS-A) WS-ONE
         CALL "VL-BED-IS-OCCUPIED" USING WS-DIM WS-X2 WS-Y WS-Z2 WS-HAS
         MOVE "test p49q the foot of a bed facing south, west or east is occupied too" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE WS-HAS TO WS-O
         CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   no claim: nothing; a claim on a block that is no bed: nothing.
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-HOME
     CALL "VL-BED-OCCUPY" USING EN-ID(WS-A) WS-ONE
     MOVE 1 TO VL-SLEEP(WS-SA)
     CALL "PB-INIT" USING BD-BUFFER WS-CAPACITY
     CALL "VL-SLEEP-DATA" USING WS-A BD-BUFFER
     MOVE "test p49q a sleeper with no bed claim sends no sleeping entries" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BD-LENGTH TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "PB-FREE" USING BD-BUFFER
     MOVE 0 TO VL-SLEEP(WS-SA)
     COMPUTE WS-X = WS-X0 + 10
     COMPUTE WS-Z = WS-Z0 + 8
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     CALL "VPX-CLAIM" USING EN-ID(WS-A) WS-HOME WS-DIM WS-X WS-Y WS-Z
     CALL "VL-BED-OCCUPY" USING EN-ID(WS-A) WS-ONE
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "test p49q a home claim on a block that is no bed leaves the block alone" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-HOME
*>   a sleeping villager that is removed frees its bed.
     COMPUTE WS-X = WS-X0 + 4
     COMPUTE WS-Z = WS-Z0 - 8
     CALL "VPX-CLAIM" USING EN-ID(WS-D) WS-HOME WS-DIM WS-X WS-Y WS-Z
     CALL "VL-BED-OCCUPY" USING EN-ID(WS-D) WS-ONE
     MOVE 1 TO VL-SLEEP(WS-SD)
     CALL "VL-REMOVE" USING EN-ID(WS-D)
     CALL "VL-BED-IS-OCCUPIED" USING WS-DIM WS-X WS-Y WS-Z WS-HAS
     MOVE "test p49q a villager removed in its bed leaves the bed free" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   ----- PoiCompetitorScan and YieldJobSite: no claim, a claim on a block that is no workstation, a rival holding the site.
     CALL "VL-COMPETE" USING WS-A WS-SA
     CALL "VL-YIELD" USING WS-A WS-SA
     MOVE 1 TO VL-POT(WS-SA)
     MOVE "none" TO VL-PROF(WS-SA)
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VP-CLAIM" USING WS-DIM WS-X WS-Y WS-Z EN-ID(WS-A)
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     CALL "VL-COMPETE" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "test p49q a claim on a block that is no workstation is kept (no profession takes it)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-JOB
     COMPUTE WS-X = WS-X0 + 10
     COMPUTE WS-Z = WS-Z0 + 8
     MOVE "minecraft:lectern" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     CALL "VP-CLAIM" USING WS-DIM WS-X WS-Y WS-Z EN-ID(WS-A)
     CALL "VP-CLAIM" USING WS-DIM WS-X WS-Y WS-Z EN-ID(WS-C)
     MOVE 1 TO VL-POT(WS-SA)
     MOVE 0 TO VL-POT(WS-SC)
     MOVE "librarian" TO VL-PROF(WS-SC)
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "test p49q a rival that holds the very site takes it: this villager's claim goes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-C) WS-JOB
*>   ----- the baby villager behaviours.
     MOVE -24000 TO EN-MOBAGE(WS-A) EN-MOBAGE(WS-B) EN-MOBAGE(WS-C)
     MOVE 3 TO WS-ACT
*>   An adult has no baby behaviours: the call returns at once and the activity stays.
     CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-NOT-BABY WS-ACT
     MOVE "test p49q an adult villager runs no baby behaviour (the activity stays)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-ACT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     MOVE 4 TO WS-ACT
     MOVE 1000 TO WS-NOW
     CALL "VM-NOTE" USING WS-SA MT-VISIBLE-BABIES WS-ONE
     CALL "VM-ERASE" USING WS-SA MT-NEAREST-BED
*>   A stale visible list with nobody near: nothing happens (the gate passes now and then).
     COMPUTE EN-X(WS-B) = WS-X0 + 25
     COMPUTE EN-X(WS-C) = WS-X0 + 25
     COMPUTE EN-Z(WS-B) = WS-Z0 + 25
     COMPUTE EN-Z(WS-C) = WS-Z0 + 25
     PERFORM 60 TIMES
         ADD 1 TO CW-TICKS
         CALL "VM-NOTE" USING WS-SA MT-VISIBLE-BABIES WS-ONE
         CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     END-PERFORM
     CALL "VM-HAS" USING WS-SA MT-WALK-TARGET WS-HAS
     MOVE "test p49q with no baby in range the stale list starts nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A is chased by nobody, C chases B: A picks B (chased by 1).
     COMPUTE EN-X(WS-B) = WS-X0 + 2
     COMPUTE EN-Z(WS-B) = WS-Z0
     COMPUTE EN-X(WS-C) = WS-X0 - 2
     COMPUTE EN-Z(WS-C) = WS-Z0
     CALL "VM-NOTE" USING WS-SC MT-INTERACTION-TARGET EN-ID(WS-B)
     CALL "VM-ERASE" USING WS-SA MT-INTERACTION-TARGET
     CALL "VL-WALK-STOP" USING WS-A WS-SA
     PERFORM 200 TIMES
         ADD 1 TO CW-TICKS
         CALL "VM-NOTE" USING WS-SA MT-VISIBLE-BABIES WS-ONE
         CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     END-PERFORM
     CALL "VM-GET" USING WS-SA MT-INTERACTION-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "test p49q a baby chases the baby that one other is chasing" TO WS-CASE
     MOVE EN-ID(WS-B) TO WS-E
     MOVE WS-N1 TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   JumpOnBed ends when the bed is gone and when the walking budget is used.
     COMPUTE WS-X = WS-X0 + 10
     COMPUTE WS-Z = WS-Z0 + 8
     CALL "VM-AT" USING WS-SA MT-NEAREST-BED WS-DIM WS-X WS-Y WS-Z
     MOVE 1 TO VM-T(WS-SA, TM-JUMP-ON)
     MOVE 50 TO VM-T(WS-SA, TM-JUMP-BUDGET)
     CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     MOVE "test p49q JumpOnBed ends when the bed block is no bed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-SA, TM-JUMP-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     MOVE 1 TO VM-T(WS-SA, TM-JUMP-ON)
     MOVE 0 TO VM-T(WS-SA, TM-JUMP-BUDGET)
     CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     MOVE "test p49q JumpOnBed ends when the baby is not on a bed and the walking budget is used" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-SA, TM-JUMP-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Idle activity: the 1 in 8 draw (a few evaluations pass it, most stop at the draw).
     MOVE 0 TO WS-ACT
     CALL "VL-WALK-STOP" USING WS-A WS-SA
     MOVE 0 TO VM-T(WS-SA, TM-JUMP-ON)
     PERFORM 40 TIMES
         ADD 1 TO CW-TICKS
         CALL "VL-WALK-STOP" USING WS-A WS-SA
         MOVE 0 TO VM-T(WS-SA, TM-JUMP-ON)
         CALL "VL-KIDS-TICK" USING WS-A WS-SA WS-BABY WS-ACT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-P49Q-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
