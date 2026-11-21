*> Acceptance test of the end city section generators (docs/protocol/36-structures-8-nether-and-end.md section 10 and the bridge vector of 12.3; core/src/struct-endcity.cob): the order of the
*> tower generator's first draws (x, z, bridge parent, count) and the bridge generator's draws (count, flat or stairs, then the ship or the house) against a reference random, the group id
*> (one id for the whole accepted group, drawn after it), one ship per city at most, the pieces seen over 60 cities, and the bridge chain of 12.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTEC.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-X                   BINARY-LONG VALUE 100.
 01 WS-Y                   BINARY-LONG VALUE 60.
 01 WS-Z                   BINARY-LONG VALUE 200.
 01 WS-ROT                 BINARY-LONG VALUE 0.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ACCEPTED            BINARY-LONG.
 01 WS-CHECKED             BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-WANT-NAME           PIC X(24).
 01 WS-SHIPS               BINARY-LONG.
 01 WS-BAD-SHIP            BINARY-LONG.
 01 WS-BAD-GD              BINARY-LONG.
 01 WS-SEEN-TAB.
    05 WS-SEEN             BINARY-LONG OCCURS 19 TIMES.
 01 WS-NAMES.
    05 FILLER PIC X(20) VALUE "ship".
    05 FILLER PIC X(20) VALUE "fat_tower_top".
    05 FILLER PIC X(20) VALUE "tower_top".
    05 FILLER PIC X(20) VALUE "bridge_gentle_stairs".
    05 FILLER PIC X(20) VALUE "bridge_steep_stairs".
    05 FILLER PIC X(20) VALUE "base_roof".
    05 FILLER PIC X(20) VALUE "second_roof".
    05 FILLER PIC X(20) VALUE "third_floor_2".
    05 FILLER PIC X(20) VALUE "fat_tower_middle".
    05 FILLER PIC X(20) VALUE "bridge_piece".
 01 WS-NT REDEFINES WS-NAMES.
    05 WS-NM               PIC X(20) OCCURS 10 TIMES.
 01 WS-BIT                 BINARY-DOUBLE.
 01 WS-BITS1               BINARY-LONG VALUE 1.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-GEN                 BINARY-LONG VALUE 3.
 01 WS-DEPTH               BINARY-LONG VALUE 4.
 01 WS-NX                  BINARY-LONG VALUE 0.
 01 WS-NY                  BINARY-LONG VALUE 0.
 01 WS-NZ                  BINARY-LONG VALUE 0.
 01 WS-FIRST               BINARY-LONG VALUE 1.
 01 WS-RES                 BINARY-LONG.
 01 WS-OW                  BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEQ                 PIC X(8).
 01 WS-SEQ-LEN             BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-SHIPD               BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the tower generator's first four draws: x, z, bridge parent, count
     MOVE 0 TO WS-BAD WS-ACCEPTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE WS-I TO SP-RNG
         MOVE SP-RNG TO WS-REF
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-TWO WS-DX
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-TWO WS-DZ
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-THREE WS-R3
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-THREE WS-N
         ADD 1 TO WS-N
         MOVE WS-I TO SP-RNG
         CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
         IF EC-COUNT > 4
             ADD 1 TO WS-ACCEPTED
             IF EP-NAME(5) NOT = "tower_base" OR EP-X(5) NOT = EP-X(4) + 3 + WS-DX OR EP-Z(5) NOT = EP-Z(4) + 3 + WS-DZ
                 OR EP-Y(5) NOT = EP-Y(4) - 3
                 ADD 1 TO WS-BAD
             END-IF
             IF EP-NAME(6) NOT = "tower_piece" OR EP-Y(6) NOT = EP-Y(5) + 7 OR EP-NAME(6 + WS-N) NOT = "tower_piece"
                 ADD 1 TO WS-BAD
             END-IF
             IF EP-NAME(7 + WS-N) = "tower_piece" OR EP-Y(6 + WS-N) NOT = EP-Y(6) + 4 * WS-N
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§10 B. The section generators: the tower draws x, z, the bridge parent and the count in that order" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§10 B. The section generators: most first towers are accepted (a failed group is dropped)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ACCEPTED >= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the bridge generator on a free bridge_end: count, flat or stairs, then the ship (a draw of 0 in 10 - depth) or the house
     MOVE 0 TO WS-BAD WS-CHECKED WS-SHIPD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE 0 TO EC-COUNT EC-SHIP
         MOVE "bridge_end" TO WS-NAME
         MOVE 500 TO WS-PX
         MOVE 70 TO WS-PY
         MOVE 500 TO WS-PZ
         CALL "ENDCITY-ADD" USING WS-NAME WS-ZERO WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-PARENT
         MOVE WS-I TO SP-RNG
         MOVE SP-RNG TO WS-REF
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-FOUR WS-N
         ADD 1 TO WS-N
*>       the names the repetitions make: P flat, S steep, G gentle
         MOVE SPACES TO WS-SEQ
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
             CALL "JRAND-NEXT" USING WS-REF WS-BITS1 WS-BIT
             IF WS-BIT NOT = 0
                 MOVE "P" TO WS-SEQ(WS-J:1)
             ELSE
                 CALL "JRAND-NEXT" USING WS-REF WS-BITS1 WS-BIT
                 IF WS-BIT NOT = 0
                     MOVE "S" TO WS-SEQ(WS-J:1)
                 ELSE
                     MOVE "G" TO WS-SEQ(WS-J:1)
                 END-IF
             END-IF
         END-PERFORM
         MOVE 6 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-BOUND WS-DRAW
         CALL "ENDCITY-RECURSE" USING WS-GEN WS-DEPTH WS-PARENT WS-NX WS-NY WS-NZ WS-FIRST WS-RES
         IF WS-RES = 1
             ADD 1 TO WS-CHECKED
             IF EP-NAME(2) NOT = "bridge_piece"
                 ADD 1 TO WS-BAD
             END-IF
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
                 COMPUTE WS-POS = 2 + WS-J
                 EVALUATE WS-SEQ(WS-J:1)
                     WHEN "P"
                         MOVE "bridge_piece" TO WS-WANT-NAME
                     WHEN "S"
                         MOVE "bridge_steep_stairs" TO WS-WANT-NAME
                     WHEN OTHER
                         MOVE "bridge_gentle_stairs" TO WS-WANT-NAME
                 END-EVALUATE
                 IF EP-NAME(WS-POS) NOT = WS-WANT-NAME
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
             COMPUTE WS-POS = 3 + WS-N
             IF WS-DRAW = 0
                 ADD 1 TO WS-SHIPD
                 IF EP-NAME(WS-POS) NOT = "ship"
                     ADD 1 TO WS-BAD
                 END-IF
             ELSE
                 IF EP-NAME(WS-POS) NOT = "base_floor"
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
             IF EP-NAME(EC-COUNT) NOT = "bridge_end" OR EP-ROT(EC-COUNT) NOT = 2
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§10 B. The section generators: the bridge draws its length, each flat or stairs, then the ship or the house" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§10 B. The section generators: bridges with a ship and with a house were both checked" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SHIPD >= 3 AND WS-CHECKED - WS-SHIPD >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   whole cities: the group id, one ship, the pieces seen
     MOVE 0 TO WS-BAD-SHIP WS-BAD-GD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 19
         MOVE 0 TO WS-SEEN(WS-K)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO SP-RNG
         CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
         MOVE 0 TO WS-SHIPS
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EC-COUNT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 10
                 IF EP-NAME(WS-J) = WS-NM(WS-K)
                     ADD 1 TO WS-SEEN(WS-K)
                 END-IF
             END-PERFORM
             IF EP-NAME(WS-J) = "ship"
                 ADD 1 TO WS-SHIPS
             END-IF
         END-PERFORM
         IF WS-SHIPS > 1
             ADD 1 TO WS-BAD-SHIP
         END-IF
         IF EC-COUNT > 4
             PERFORM VARYING WS-J FROM 6 BY 1 UNTIL WS-J > EC-COUNT
                 IF EP-GD(WS-J) NOT = EP-GD(5)
                     ADD 1 TO WS-BAD-GD
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§10 B. The section generators: at most one ship in a city" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-SHIP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§10 B. The section generators: an accepted tower group holds one group id" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-GD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 10
         IF WS-SEEN(WS-K) = 0
             ADD 1 TO WS-BAD
             DISPLAY "PROBE never seen: " WS-NM(WS-K)
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§10 B. The section generators: ship, fat tower, stairs, roofs and tops all occur in 60 cities" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   12.3: the bridge chain from the second tower piece of 12.2 (rotation none), by addPiece
     MOVE 0 TO EC-COUNT
     MOVE "tower_piece" TO WS-NAME
     MOVE 100 TO WS-PX
     MOVE 80 TO WS-PY
     MOVE 200 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-ZERO WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-P1
     MOVE "bridge_end" TO WS-NAME
     MOVE 6 TO WS-PX
     MOVE -1 TO WS-PY
     MOVE 1 TO WS-PZ
     MOVE 1 TO WS-T1
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-P2
     MOVE 0 TO WS-BAD
     IF EP-X(WS-P2) NOT = 106 OR EP-Y(WS-P2) NOT = 79 OR EP-Z(WS-P2) NOT = 201 OR EP-X0(WS-P2) NOT = 105 OR EP-X1(WS-P2) NOT = 106
         OR EP-Y1(WS-P2) NOT = 84 OR EP-Z0(WS-P2) NOT = 201 OR EP-Z1(WS-P2) NOT = 205
         ADD 1 TO WS-BAD
     END-IF
     MOVE "bridge_piece" TO WS-NAME
     MOVE 0 TO WS-PX WS-PY
     MOVE -4 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-P2 WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-ROW
     IF EP-X(WS-ROW) NOT = 110 OR EP-Z(WS-ROW) NOT = 201 OR EP-X0(WS-ROW) NOT = 107 OR EP-X1(WS-ROW) NOT = 110
         ADD 1 TO WS-BAD
     END-IF
     MOVE "bridge_steep_stairs" TO WS-NAME
     CALL "ENDCITY-ADD" USING WS-NAME WS-ROW WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-P1
     IF EP-X(WS-P1) NOT = 114 OR EP-Z(WS-P1) NOT = 201 OR EP-X0(WS-P1) NOT = 111 OR EP-X1(WS-P1) NOT = 114 OR EP-Y1(WS-P1) NOT = 85
         ADD 1 TO WS-BAD
     END-IF
*>   the ship branch: offset (-8, 4, -70) from the last bridge piece
     MOVE "ship" TO WS-NAME
     MOVE -8 TO WS-PX
     MOVE 4 TO WS-PY
     MOVE -70 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-ROW
     IF EP-X(WS-ROW) NOT = 184 OR EP-Y(WS-ROW) NOT = 83 OR EP-Z(WS-ROW) NOT = 193 OR EP-X0(WS-ROW) NOT = 156 OR EP-Y1(WS-ROW) NOT = 106
         OR EP-Z1(WS-ROW) NOT = 205
         ADD 1 TO WS-BAD
     END-IF
*>   the house branch: offset (-3, 5, -11)
     MOVE "base_floor" TO WS-NAME
     MOVE -3 TO WS-PX
     MOVE 5 TO WS-PY
     MOVE -11 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-ROW
     IF EP-X(WS-ROW) NOT = 125 OR EP-Y(WS-ROW) NOT = 84 OR EP-Z(WS-ROW) NOT = 198 OR EP-X0(WS-ROW) NOT = 116 OR EP-X1(WS-ROW) NOT = 125
         ADD 1 TO WS-BAD
     END-IF
*>   the closing bridge_end: rotation 1 + 2 = 3, offset (4, 4, 0) turned to (0, 4, 4)
     MOVE "bridge_end" TO WS-NAME
     MOVE 4 TO WS-PX
     MOVE 4 TO WS-PY
     MOVE 0 TO WS-PZ
     MOVE 3 TO WS-T1
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-T1 WS-OW WS-ROW
     IF EP-X(WS-ROW) NOT = 114 OR EP-Y(WS-ROW) NOT = 83 OR EP-Z(WS-ROW) NOT = 205
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§10 B. The section generators: the bridge, ship, house and closing end of 12.3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-10.
