*> Acceptance test (002-lane-p49b; docs/protocol/20 section 20.5, validation item 12): phantom insomnia. A player with time_since_rest 144000 at night on Hard: the rest
*> check nextInt(144000) >= 72000 passes for exactly half of the draws; with a rest of 72000 or less it never passes; a group of 1 + nextInt(4) phantoms (Hard) appears
*> 20 to 34 blocks above within +-10 blocks horizontally.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-20-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-FY                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EFF                 BINARY-LONG VALUE 3000.
 01 WS-D3                  BINARY-LONG VALUE 0.
 01 WS-REST                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PASSES              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE 99.
 01 WS-MAX                 BINARY-LONG VALUE 0.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
*>   The rest check over every draw of nextInt(144000): exactly the 72000 draws from 72000 up pass.
     MOVE 144000 TO WS-REST
     MOVE 0 TO WS-PASSES
     PERFORM VARYING WS-DRAW FROM 0 BY 1 UNTIL WS-DRAW >= 144000
         CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
         ADD WS-OK TO WS-PASSES
     END-PERFORM
     MOVE "acceptance US15 20§20.5 rest 144000: half of the draws pass the rest check" TO TL-CASE
     MOVE 72000 TO TL-EXPECTED-N
     MOVE WS-PASSES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rest 72000: nextInt(72000) is below 72000, never passes.
     MOVE 72000 TO WS-REST
     MOVE 0 TO WS-PASSES
     PERFORM VARYING WS-DRAW FROM 0 BY 1 UNTIL WS-DRAW >= 72000
         CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
         ADD WS-OK TO WS-PASSES
     END-PERFORM
     MOVE "acceptance US15 20§20.5 rest 72000: the check never passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASSES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hard: the group is 1 + nextInt(4) phantoms, 20 to 34 blocks up, within 10 blocks east-west and north-south.
     MOVE 3 TO BW-DIFFICULTY
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X0 = WS-PX - 4
     COMPUTE WS-Z0 = WS-PZ - 4
     COMPUTE WS-FY = WS-PY + 60
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FY + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-PZ + 0.5
     MOVE 144000 TO PL-REST(WS-PLAYER)
     MOVE 18000 TO CW-TIME
     MOVE "minecraft:phantom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-PREV
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE 144000 TO PL-REST(WS-PLAYER)
         CALL "STDMOB-PHANTOM-ROUND"
         MOVE 0 TO WS-N
         PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > EN-COUNT
             IF EN-USED(WS-V) = 1 AND EN-TYPE(WS-V) = WS-TYPE
                 ADD 1 TO WS-N
                 IF EN-Y(WS-V) < WS-FY + 1 + 19 OR EN-Y(WS-V) > WS-FY + 1 + 35
                         OR FUNCTION ABS(EN-X(WS-V) - PL-X(WS-PLAYER)) > 10.6
                         OR FUNCTION ABS(EN-Z(WS-V) - PL-Z(WS-PLAYER)) > 10.6
                     ADD 1 TO WS-BAD
                 END-IF
                 CALL "ENTITY-REMOVE" USING WS-V
             END-IF
         END-PERFORM
         IF WS-N > 0
             IF WS-N < WS-MIN
                 MOVE WS-N TO WS-MIN
             END-IF
             IF WS-N > WS-MAX
                 MOVE WS-N TO WS-MAX
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§20.5 Hard: groups are 1 to 4 phantoms, 4 occurs" TO TL-CASE
     MOVE 104 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 100 * (WS-MAX - WS-MIN + 1 - 3 + WS-MIN) + WS-MAX
     IF WS-MIN = 1 AND WS-MAX = 4
         MOVE 104 TO TL-OBSERVED-N
     ELSE
         COMPUTE TL-OBSERVED-N = WS-MIN * 100 + WS-MAX
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§20.5 Hard: every phantom 20 to 34 blocks up within 10 horizontally" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-20-5.
 COPY CORETEST.
 COPY MOBSPTEST.
