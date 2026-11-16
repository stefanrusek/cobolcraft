*> Acceptance test, gossip exchange between villagers (docs/protocol/19 section 22.5; lane 002-lane-mobsb4, T8801): at most once per 1200 ticks per villager, up to 10 entries drawn by
*> weighted value, each copied value is the sender's minus the share decay, values below 2 are skipped, a merge keeps the larger value, and the receiver then asks for a golem (5 needed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-GOSSIP-SWAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILGOSSIP.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-GTYPE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-V                   BINARY-LONG OCCURS 5 TIMES.
 01 WS-S                   BINARY-LONG OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-COPIED              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-TARGET              BINARY-LONG VALUE 9001.
 01 WS-TARGET2             BINARY-LONG VALUE 9002.
 01 WS-GOLEMS              BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-S3                  BINARY-LONG.
 01 WS-S4                  BINARY-LONG.
 01 WS-S5                  BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-SL                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 20
     COMPUTE WS-FZ = WS-Z0 - 20
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:iron_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GTYPE WS-ENTITY-ROW WS-STATUS
     MOVE 5000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE WS-X = WS-X0 + 0.5 + WS-I
         MOVE PL-Y(WS-PLAYER) TO WS-Y
         COMPUTE WS-Z = WS-Z0 + 0.5
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V(WS-I)
         CALL "VL-FIND" USING EN-ID(WS-V(WS-I)) WS-KIND WS-SL
         EVALUATE WS-I
             WHEN 1 MOVE WS-SL TO WS-S1
             WHEN 2 MOVE WS-SL TO WS-S2
             WHEN 3 MOVE WS-SL TO WS-S3
             WHEN 4 MOVE WS-SL TO WS-S4
             WHEN 5 MOVE WS-SL TO WS-S5
         END-EVALUATE
     END-PERFORM
*>   The sender (villager 2) knows a player: major_negative 30, minor_negative 50, trading 21 (21 - 20 = 1 is skipped), minor_positive 10.
     MOVE 1 TO WS-T
     MOVE 30 TO WS-AMOUNT
     CALL "VG-ADD" USING EN-ID(WS-V(2)) WS-TARGET WS-T WS-AMOUNT
     MOVE 2 TO WS-T
     MOVE 50 TO WS-AMOUNT
     CALL "VG-ADD" USING EN-ID(WS-V(2)) WS-TARGET WS-T WS-AMOUNT
     MOVE 5 TO WS-T
     MOVE 21 TO WS-AMOUNT
     CALL "VG-ADD" USING EN-ID(WS-V(2)) WS-TARGET WS-T WS-AMOUNT
     MOVE 3 TO WS-T
     MOVE 10 TO WS-AMOUNT
     CALL "VG-ADD" USING EN-ID(WS-V(2)) WS-TARGET2 WS-T WS-AMOUNT
*>   The receiver already has major_negative 50 about the player: the merge keeps 50 over the incoming 20.
     MOVE 1 TO WS-T
     MOVE 50 TO WS-AMOUNT
     CALL "VG-ADD" USING EN-ID(WS-V(1)) WS-TARGET WS-T WS-AMOUNT
     MOVE WS-V(1) TO WS-RA
     MOVE WS-V(2) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE "acceptance US15 19§22.5 an exchange copies entries (at least one of 10 draws)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COPIED > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VG-FIND" USING EN-ID(WS-V(1)) WS-TARGET WS-NO WS-SLOT
     MOVE "acceptance US15 19§22.5 the larger existing major_negative 50 is kept over 20" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE GS-V(WS-SLOT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.5 minor_negative arrives as 50 - 20 = 30 (or not drawn: 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GS-V(WS-SLOT, 2) = 30 OR GS-V(WS-SLOT, 2) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.5 trading 21 - 20 = 1 is below 2 and is skipped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GS-V(WS-SLOT, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.5 both villagers' last gossip time is now" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     MOVE WS-S1 TO WS-SL
     MOVE VL-LAST-GOSSIP(WS-SL) TO TL-OBSERVED-N
     MOVE WS-S2 TO WS-SL
     ADD VL-LAST-GOSSIP(WS-SL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drawing many times copies the minor_positive of the second target (10 - 5 = 5) as well.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE 0 TO VL-LAST-GOSSIP(WS-S1) VL-LAST-GOSSIP(WS-S2)
         ADD 1 TO CW-TICKS
         MOVE WS-V(1) TO WS-RA
         MOVE WS-V(2) TO WS-RB
         CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     END-PERFORM
     CALL "VG-FIND" USING EN-ID(WS-V(1)) WS-TARGET2 WS-NO WS-SLOT
     MOVE "acceptance US15 19§22.5 the second target's minor_positive arrived as 10 - 5 = 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE GS-V(WS-SLOT, 3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The 1200 tick rule.
     MOVE 8000 TO CW-TICKS
     MOVE 6900 TO VL-LAST-GOSSIP(WS-S1)
     MOVE 0 TO VL-LAST-GOSSIP(WS-S2)
     MOVE WS-V(1) TO WS-RA
     MOVE WS-V(2) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE "acceptance US15 19§22.5 the receiver talked 1100 ticks ago: no exchange" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-COPIED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO VL-LAST-GOSSIP(WS-S1)
     MOVE 6900 TO VL-LAST-GOSSIP(WS-S2)
     MOVE WS-V(1) TO WS-RA
     MOVE WS-V(2) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE "acceptance US15 19§22.5 the sender talked 1100 ticks ago: no exchange" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-COPIED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6800 TO VL-LAST-GOSSIP(WS-S1)
     MOVE 6800 TO VL-LAST-GOSSIP(WS-S2)
     MOVE WS-V(1) TO WS-RA
     MOVE WS-V(2) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE "acceptance US15 19§22.5 both talked 1200 ticks ago: exchange runs (copied 0 or more)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COPIED >= 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A sender with no gossip: nothing copied, the time is still taken.
     MOVE 20000 TO CW-TICKS
     MOVE 0 TO VL-LAST-GOSSIP(WS-S4)
     MOVE WS-V(3) TO WS-RA
     MOVE WS-V(4) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE "acceptance US15 19§22.5 a sender with no gossip copies nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COPIED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   After an exchange the receiver asks for a golem with 5 villagers that slept recently.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1 MOVE WS-S1 TO WS-SL
             WHEN 2 MOVE WS-S2 TO WS-SL
             WHEN 3 MOVE WS-S3 TO WS-SL
             WHEN 4 MOVE WS-S4 TO WS-SL
             WHEN 5 MOVE WS-S5 TO WS-SL
         END-EVALUATE
         MOVE 19000 TO VL-LAST-SLEPT(WS-SL)
         MOVE 0 TO VL-LAST-GOSSIP(WS-SL)
         MOVE 0 TO VL-GOLEM-UNTIL(WS-SL)
     END-PERFORM
     MOVE 21000 TO CW-TICKS
     MOVE WS-V(3) TO WS-RA
     MOVE WS-V(4) TO WS-RB
     CALL "VL-GOSSIP-EXCHANGE" USING WS-RA WS-RB WS-COPIED
     MOVE 0 TO WS-GOLEMS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-GTYPE
             ADD 1 TO WS-GOLEMS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§22.10 five rested villagers and a gossip exchange summon a golem" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GOLEMS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The step: two adults within 2 blocks at idle time exchange (the loop finds the beat).
     MOVE 0 TO VL-LAST-GOSSIP(WS-S1) VL-LAST-GOSSIP(WS-S2)
     MOVE 0 TO VL-LAST-SLEPT(WS-S1) VL-LAST-SLEPT(WS-S2) VL-LAST-SLEPT(WS-S3) VL-LAST-SLEPT(WS-S4) VL-LAST-SLEPT(WS-S5)
     MOVE EN-X(WS-V(1)) TO EN-X(WS-V(2))
     COMPUTE EN-X(WS-V(2)) = EN-X(WS-V(1)) + 1
     MOVE 11500 TO CW-TIME
     MOVE 30000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TICKS
         CALL "VL-GOSSIP-STEP" USING WS-V(1)
     END-PERFORM
     MOVE "acceptance US15 19§22.5 an idle adult near another villager exchanges gossip on the 20 tick beat" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF VL-LAST-GOSSIP(WS-S1) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO VL-LAST-GOSSIP(WS-S1) VL-LAST-GOSSIP(WS-S2)
     MOVE 3000 TO CW-TIME
     MOVE 1 TO TL-EXPECTED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TICKS
         CALL "VL-GOSSIP-STEP" USING WS-V(1)
     END-PERFORM
     MOVE "acceptance US15 19§22.3 at work time (neither idle nor meeting) no exchange" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-LAST-GOSSIP(WS-S1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-GOSSIP-SWAP.
 COPY CORETEST.
 COPY MOBSPTEST.
