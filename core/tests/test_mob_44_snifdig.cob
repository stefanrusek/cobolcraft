*> Implementation test (002-lane-mobsa3; 44 part 4 section 13): the sniffer dig cadence of 44 part 4 section 13: RunOne weights, sniffing to searching to digging (160 to 180 ticks) to rising (40) to feeling happy, the 9600-tick cooldown.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-SNIFDIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-GRASS               BINARY-LONG VALUE 2.
 01 WS-PATCH               BINARY-LONG VALUE 6.
 01 WS-STATE               BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SCUTE               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-BRUSH-ROW           PIC X(270).
 01 WS-SNHX               FLOAT-LONG.
 01 WS-SNHZ               FLOAT-LONG.
 01 WS-SNWALK             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-GRASS
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:sniffer" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:armadillo_scute" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SCUTE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   A stone patch (not diggable) at the north-east corner, 6 x 6.
     COMPUTE WS-SX = WS-X0 + 40
     COMPUTE WS-SZ = WS-Z0 + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-SX WS-SZ WS-PATCH WS-FLOOR WS-STONE
     MOVE 1 TO WS-I
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         CALL "M44-SNIF-PICK" USING WS-I WS-A
         EVALUATE WS-I
             WHEN 2 MOVE 2 TO WS-EXP
             WHEN 3 MOVE 3 TO WS-EXP
             WHEN OTHER MOVE 0 TO WS-EXP
         END-EVALUATE
         MOVE "acceptance US15 44-4§13 Sniffer: the RunOne draw picks scenting (2), sniffing (3) or something else" TO TL-CASE
         MOVE WS-EXP TO TL-EXPECTED-N
         MOVE WS-A TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   On grass: sniffing runs out, searching, digging 160 to 180 ticks, rising 40 ticks, feeling happy.
     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1 TO EN-ON-GROUND(WS-A)
     MOVE 3 TO WS-STATE
     CALL "SNIFFER-SET-STATE" USING WS-A WS-STATE
     MOVE 1 TO EN-SNIF-T(WS-A)
     MOVE 1000 TO CW-TIME
     CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
     CALL "SNIFFER-TICK" USING WS-A
     MOVE "acceptance US15 44-4§13 Sniffer: a sniffing sniffer that can dig goes to searching (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-SNIF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The sniffing target is a block within 18 of the sniffer; the walk target to it is set at the same time.
     MOVE "acceptance US15 44-4§13 Sniffer: the dig position is within 18 blocks and the sniffing target is set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-SX = EN-SNIF-TX(WS-A) - FUNCTION INTEGER(EN-X(WS-A))
     COMPUTE WS-SZ = EN-SNIF-TZ(WS-A) - FUNCTION INTEGER(EN-Z(WS-A))
     IF EN-SNIF-TON(WS-A) = 1 AND FUNCTION ABS(WS-SX) <= 18 AND FUNCTION ABS(WS-SZ) <= 18
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Searching walks (walk 1) toward the target unless the sniffer already stands in its cell; a sniffer that stands in the target cell, facing away from the stone, has arrived and digs.
     ADD 1 TO CW-TIME
     MOVE 0 TO WS-SNWALK
     IF FUNCTION INTEGER(EN-X(WS-A)) = EN-SNIF-TX(WS-A) AND FUNCTION INTEGER(EN-Z(WS-A)) = EN-SNIF-TZ(WS-A)
         MOVE 1 TO WS-SNWALK
     ELSE
         CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
     END-IF
     MOVE "acceptance US15 44-4§13 Sniffer: searching walks toward the target (walk 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SNWALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§13 Sniffer: still searching while it walks" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-SNIF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-A) = EN-SNIF-TX(WS-A) + 0.5
     COMPUTE EN-Z(WS-A) = EN-SNIF-TZ(WS-A) + 0.5
     MOVE 180 TO EN-YAW(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
     CALL "SNIFFER-TICK" USING WS-A
     MOVE "acceptance US15 44-4§13 Sniffer: searching arrives and digs (5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-SNIF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§13 Sniffer: digging lasts 160 to 180 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SNIF-T(WS-A) >= 160 AND EN-SNIF-T(WS-A) <= 180
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM UNTIL EN-SNIF(WS-A) NOT = 5 OR WS-N > 400
         ADD 1 TO CW-TIME
         ADD 1 TO WS-N
         CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
         CALL "SNIFFER-TICK" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§13 Sniffer: the dig ends in rising (6) after 160 to 180 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SNIF(WS-A) = 6 AND WS-N >= 159 AND WS-N <= 180
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§13 Sniffer: the cooldown is 9600 after the dig" TO TL-CASE
     MOVE 9600 TO TL-EXPECTED-N
     MOVE EN-SNIF-CD(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§13 Sniffer: the dug place is explored" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-SNIF-EXP-N(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM UNTIL EN-SNIF(WS-A) NOT = 6 OR WS-N > 100
         ADD 1 TO CW-TIME
         ADD 1 TO WS-N
         CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
         CALL "SNIFFER-TICK" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§13 Sniffer: rising lasts 40 ticks, then feeling happy (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SNIF(WS-A) = 1 AND WS-N >= 39 AND WS-N <= 41
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With the cooldown running no sniffing starts in 300 idle ticks; without it sniffing starts.
     MOVE 0 TO EN-SNIF(WS-A)
     MOVE 0 TO EN-SNIF-T(WS-A)
     MOVE 9000 TO EN-SNIF-CD(WS-A)
     MOVE 0 TO WS-BAD
     PERFORM 300 TIMES
         ADD 1 TO CW-TIME
         CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
         CALL "SNIFFER-TICK" USING WS-A
         IF EN-SNIF(WS-A) = 3 OR EN-SNIF(WS-A) = 4 OR EN-SNIF(WS-A) = 5
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§13 Sniffer: no sniffing while the cooldown runs" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-SNIF(WS-A)
     MOVE 0 TO EN-SNIF-T(WS-A)
     MOVE 0 TO EN-SNIF-CD(WS-A)
     MOVE 0 TO EN-SNIF-EXP-N(WS-A)
     MOVE 0 TO WS-BAD
     PERFORM 600 TIMES
         ADD 1 TO CW-TIME
         CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
         CALL "SNIFFER-TICK" USING WS-A
         IF EN-SNIF(WS-A) = 3
             MOVE 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§13 Sniffer: an idle sniffer without a cooldown starts sniffing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A
*>   On stone it cannot dig (no candidate within 18 blocks has a diggable block below it): sniffing ends in idling.
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-PZ = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1 TO EN-ON-GROUND(WS-A)
     MOVE 3 TO WS-STATE
     CALL "SNIFFER-SET-STATE" USING WS-A WS-STATE
     MOVE 1 TO EN-SNIF-T(WS-A)
     CALL "M44-SNIF-BRAIN" USING WS-A WS-SNHX WS-SNHZ WS-SNWALK
     CALL "SNIFFER-TICK" USING WS-A
     MOVE "acceptance US15 44-4§13 Sniffer: on stone it cannot dig, sniffing ends idle (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SNIF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-SNIFDIG.
 COPY CORETEST.
 COPY MOBSPTEST.
