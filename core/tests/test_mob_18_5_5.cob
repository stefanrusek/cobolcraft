*> Implementation test (002-lane-mobsfull-h2, T2244; docs/protocol/18 section 5.5 Following a path): next entity position, reaching and advancing nodes, shortcuts, stuck detection, timeouts and recomputation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-5-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBPATH.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 3 TO PS-PX(1)
     MOVE 1 TO PS-PY(1)
     MOVE 4 TO PS-PZ(1)
     MOVE 1 TO WS-A
     MOVE 0.6 TO WS-F1
     CALL "PATH-NEXT-ENTITY-POS" USING PF-SEARCH WS-A WS-F1 WS-G1 WS-G2 WS-G3
     MOVE "acceptance US15 18§5.5 Following a path a narrow mob aims at the node centre (x + 0.5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 35 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path a narrow mob aims at z + 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 45 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G3 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path the aimed y is the node y" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.8 TO WS-F1
     CALL "PATH-NEXT-ENTITY-POS" USING PF-SEARCH WS-A WS-F1 WS-G1 WS-G2 WS-G3
     MOVE "acceptance US15 18§5.5 Following a path a wide mob (1.8) aims at the centre of its footprint (+ 1.0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.5 TO WS-F1
     MOVE 1 TO WS-F2
     MOVE 4.5 TO WS-F3
     MOVE 3 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 4 TO WS-F6
     MOVE 0.6 TO WS-F7
     CALL "FOLLOW-REACHED" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path reached: a mob at the node centre has reached the node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4.0 TO WS-F1
     MOVE 1 TO WS-F2
     MOVE 4.5 TO WS-F3
     MOVE 3 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 4 TO WS-F6
     MOVE 0.6 TO WS-F7
     CALL "FOLLOW-REACHED" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path reached: a narrow mob 0.5 from the centre is not within 0.45" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.9 TO WS-F1
     MOVE 1 TO WS-F2
     MOVE 4.5 TO WS-F3
     MOVE 3 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 4 TO WS-F6
     MOVE 1.0 TO WS-F7
     CALL "FOLLOW-REACHED" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path reached: a mob of width 1.0 uses half its width (0.5) as the limit" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.5 TO WS-F1
     MOVE 2.0 TO WS-F2
     MOVE 4.5 TO WS-F3
     MOVE 3 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 4 TO WS-F6
     MOVE 0.6 TO WS-F7
     CALL "FOLLOW-REACHED" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path reached: the vertical distance must be below 1.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.5 TO WS-F1
     MOVE 1.99 TO WS-F2
     MOVE 4.5 TO WS-F3
     MOVE 3 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 4 TO WS-F6
     MOVE 0.6 TO WS-F7
     CALL "FOLLOW-REACHED" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path reached: a vertical distance of 0.99 counts" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 1 TO WS-B
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: never when the next node is the last" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 2.0 TO WS-F1
     MOVE 1 TO WS-B
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: never when the mob is 2 or more blocks from the next node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 1 TO WS-B
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: true when the mob can move directly" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 0 TO WS-B
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: opposite vectors of equal length do not qualify (|B| not < |A|, |A| not < 0.5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 0 TO WS-B
     MOVE 0.5 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: a close mob (|A|^2 < 0.5) with the next-next node behind qualifies" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 0 TO WS-B
     MOVE 0.5 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE 1 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: a close mob with the next-next node ahead does not" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1.0 TO WS-F1
     MOVE 0 TO WS-B
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     MOVE -0.5 TO WS-F5
     MOVE 0 TO WS-F6
     MOVE 0 TO WS-F7
     CALL "FOLLOW-SHORTCUT" USING WS-A WS-F1 WS-B WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shortcut: a shorter B behind A qualifies" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "FOLLOW-ADVANCE" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path a reached node advances the path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "FOLLOW-ADVANCE" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path an unreached node advances when corners can be cut and the shortcut holds" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     CALL "FOLLOW-ADVANCE" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path no advance without the corner rule" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "FOLLOW-ADVANCE" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path no advance without the shortcut rule" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 4 TO WS-B
     MOVE 5 TO WS-C
     MOVE 3 TO WS-D
     MOVE 4 TO WS-E
     MOVE 5 TO WS-H
     CALL "FLY-REACHED" USING WS-A WS-B WS-C WS-D WS-E WS-H WS-O1
     MOVE "acceptance US15 18§5.5 Following a path flying: the mob reached the node when the block positions are equal" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-H
     CALL "FLY-REACHED" USING WS-A WS-B WS-C WS-D WS-E WS-H WS-O1
     MOVE "acceptance US15 18§5.5 Following a path flying: another block is not the node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PV-LAST-CHECK
     MOVE 0 TO PV-LAST-X
     MOVE 0 TO PV-LAST-Y
     MOVE 0 TO PV-LAST-Z
     MOVE 5 TO PV-COUNT
     MOVE 0.2 TO WS-F1
     MOVE 101 TO WS-A
     MOVE 0.7 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-F4
     CALL "STUCK-CHECK" USING PF-NAV WS-F1 WS-A WS-F2 WS-F3 WS-F4 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path stuck: after 100 ticks the mob moved less than speed^2 x 25 (1 block): stuck" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path stuck: the path is dropped" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path stuck: the reference time is reset" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 101 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-LAST-CHECK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PV-LAST-CHECK
     MOVE 0 TO PV-LAST-X
     MOVE 101 TO WS-A
     MOVE 2 TO WS-F2
     CALL "STUCK-CHECK" USING PF-NAV WS-F1 WS-A WS-F2 WS-F3 WS-F4 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path stuck: moving far enough clears the flag" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PV-LAST-CHECK
     MOVE 101 TO WS-A
     MOVE 1 TO PV-STUCK
     CALL "STUCK-CHECK" USING PF-NAV WS-F1 WS-A WS-F2 WS-F3 WS-F4 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path stuck: no check within 100 ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PV-LAST-CHECK
     MOVE 1.5 TO WS-F1
     MOVE 30 TO WS-F2
     MOVE 101 TO WS-A
     CALL "STUCK-CHECK" USING PF-NAV WS-F1 WS-A WS-F2 WS-F3 WS-F4 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path stuck: a speed of 1.5 or more uses speed itself (37.5 blocks)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO PV-CACHED
     MOVE 0 TO PV-TIMER
     MOVE 0 TO PV-LAST-TIMEOUT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0.2 TO WS-F1
     MOVE 4 TO WS-F2
     CALL "TIMEOUT-CHECK" USING PF-NAV WS-A WS-B WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path timeout: a new node caches itself" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-CACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path timeout: the limit is distance / speed x 20" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-LIMIT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-B
     CALL "TIMEOUT-CHECK" USING PF-NAV WS-A WS-B WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path timeout: a same node adds the elapsed ticks to the timer" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-TIMER
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path timeout: not timed out yet" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1201 TO WS-B
     CALL "TIMEOUT-CHECK" USING PF-NAV WS-A WS-B WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path timeout: the timer above 3 x the limit times the path out" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path timeout: the timeout clears the cached node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-CACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 5000 TO WS-B
     MOVE 0 TO WS-F1
     CALL "TIMEOUT-CHECK" USING PF-NAV WS-A WS-B WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.5 Following a path timeout: with speed 0 the limit is 0 and it never times out" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PV-LAST-RECOMPUTE
     MOVE 30 TO WS-A
     CALL "RECOMPUTE-GATE" USING PF-NAV WS-A WS-O1
     MOVE "acceptance US15 18§5.5 Following a path recomputePath runs when more than 20 ticks passed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path recomputePath records the time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 30 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-LAST-RECOMPUTE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-A
     CALL "RECOMPUTE-GATE" USING PF-NAV WS-A WS-O1
     MOVE "acceptance US15 18§5.5 Following a path recomputePath within 20 ticks is delayed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path a delayed recomputation is flagged" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PV-DELAYED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-F1
     MOVE 6 TO WS-B
     CALL "SHOULD-RECOMPUTE" USING WS-A WS-F1 WS-B WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shouldRecomputePath is true for a finished path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 3.5 TO WS-F1
     CALL "SHOULD-RECOMPUTE" USING WS-A WS-F1 WS-B WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shouldRecomputePath is true when the target is not within remaining / 2 blocks of the end" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.9 TO WS-F1
     CALL "SHOULD-RECOMPUTE" USING WS-A WS-F1 WS-B WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shouldRecomputePath is false when the target is closer than remaining / 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-F1
     CALL "SHOULD-RECOMPUTE" USING WS-A WS-F1 WS-B WS-O1
     MOVE "acceptance US15 18§5.5 Following a path shouldRecomputePath at exactly remaining / 2 recomputes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "NAV-TICK-PLAN" USING WS-A WS-B WS-C WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§5.5 Following a path a tick follows the path and aims the move control for an unfinished path that can update" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path the move control is aimed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path no recomputation is pending" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-C
     CALL "NAV-TICK-PLAN" USING WS-A WS-B WS-C WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§5.5 Following a path a pending recomputation runs first" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "NAV-TICK-PLAN" USING WS-A WS-B WS-C WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§5.5 Following a path an unfinished path that cannot update is not followed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.5 Following a path but the move control still aims at the next node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "NAV-TICK-PLAN" USING WS-A WS-B WS-C WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§5.5 Following a path a finished path does nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 5 TO WS-C
     CALL "NAV-MOVE-TO" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path moveTo with a null path fails" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "NAV-MOVE-TO" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path moveTo keeps a path that is the same as the current one" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "NAV-MOVE-TO" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path moveTo fails for a path of 0 nodes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-C
     CALL "NAV-MOVE-TO" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.5 Following a path moveTo accepts a new path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 4 TO WS-F1
     MOVE 2.5 TO WS-F2
     CALL "GROUND-Y" USING WS-A WS-F1 WS-F2 WS-G1
     MOVE "acceptance US15 18§5.5 Following a path the ground y is the node y when the block below is air" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "GROUND-Y" USING WS-A WS-F1 WS-F2 WS-G1
     MOVE "acceptance US15 18§5.5 Following a path otherwise the floor level of the block" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 25 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-5-5.
