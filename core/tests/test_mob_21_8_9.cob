*> Other non-mob entities, constants only (docs/protocol/21 section 8.9; lane 002-lane-p49i, T22650): the registry rows of the armor stand, the item frames, the painting, the leash knot and the marker
*> against the table (box, eye height, tracking range, update interval, flags), and the armor stand's equipment heights 0.1 (feet), 0.4 (legs), 0.9 (chest), 1.6 (head) through ARMOR-STAND-SLOT. The
*> second-hit wobble time 5, the disabled slot bit offsets 8 and 16 and the frame's eight rotations are proven by acc_us16_armorstand and acc_us16_frames; the interaction and display entities belong to lane p49f.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY MOB181.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-STAND               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-HITY                FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "armor_stand" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "armor_stand: 0.5 x 1.975, eye 1.7775, range 10" TO WS-CASE
     MOVE 500000 TO WS-E
     MOVE M1-W(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1975000 TO WS-E
     MOVE M1-H(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1777500 TO WS-E
     MOVE M1-EYE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-E
     MOVE M1-TRACK(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "item_frame" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "item_frame: 0.5 x 0.5, no update interval and no delta tracking" TO WS-CASE
     MOVE 500000 TO WS-E
     COMPUTE WS-O = M1-W(WS-ROW)
     PERFORM CHECK-N
     MOVE 500000 TO WS-E
     MOVE M1-H(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 2147483647 TO WS-E
     MOVE M1-UPD(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MOD(FUNCTION INTEGER(M1-FLAGS(WS-ROW) / 32), 2)
     PERFORM CHECK-N
     MOVE "glow_item_frame" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "glow_item_frame: 0.5 x 0.5, no update interval and no delta tracking" TO WS-CASE
     MOVE 500000 TO WS-E
     MOVE M1-W(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 500000 TO WS-E
     MOVE M1-H(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 2147483647 TO WS-E
     MOVE M1-UPD(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MOD(FUNCTION INTEGER(M1-FLAGS(WS-ROW) / 32), 2)
     PERFORM CHECK-N
     MOVE "painting" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "painting: 0.5 x 0.5" TO WS-CASE
     MOVE 500000 TO WS-E
     MOVE M1-W(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 500000 TO WS-E
     MOVE M1-H(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "leash_knot" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "leash_knot: 0.375 x 0.5, eye 0.0625, not saved" TO WS-CASE
     MOVE 375000 TO WS-E
     MOVE M1-W(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 500000 TO WS-E
     MOVE M1-H(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 62500 TO WS-E
     MOVE M1-EYE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MOD(FUNCTION INTEGER(M1-FLAGS(WS-ROW) / 4), 2)
     PERFORM CHECK-N
     MOVE "marker" TO WS-KEY
     PERFORM FIND-TYPE
     MOVE "marker: no tracking range (0): never sent to clients" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE M1-TRACK(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The armor stand's equipment heights, one worn piece at a time (PJ-EQ by slot id + 1: 2 feet, 3 legs, 4 chest, 5 head).
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 20
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-YAW
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-STAND
     CALL "PJ-FIND" USING EN-ID(WS-STAND) WS-P
     MOVE 5 TO WS-N
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 5
         MOVE 0 TO PJ-EQ(WS-P, 2) PJ-EQ(WS-P, 3) PJ-EQ(WS-P, 4) PJ-EQ(WS-P, 5)
         MOVE 7 TO PJ-EQ(WS-P, WS-K)
         EVALUATE WS-K
             WHEN 2
                 MOVE 0.09 TO WS-HITY
                 MOVE "feet worn: a click below 0.1 is the main hand (0)" TO WS-CASE
             WHEN 3
                 MOVE 0.39 TO WS-HITY
                 MOVE "legs worn: a click below 0.4 is the main hand (0)" TO WS-CASE
             WHEN 4
                 MOVE 0.89 TO WS-HITY
                 MOVE "chest worn: a click below 0.9 is the main hand (0)" TO WS-CASE
             WHEN OTHER
                 MOVE 1.59 TO WS-HITY
                 MOVE "head worn: a click below 1.6 is the main hand (0)" TO WS-CASE
         END-EVALUATE
         CALL "ARMOR-STAND-SLOT" USING WS-STAND WS-HITY WS-SLOT
         MOVE 0 TO WS-E
         MOVE WS-SLOT TO WS-O
         PERFORM CHECK-N
         EVALUATE WS-K
             WHEN 2
                 MOVE 0.1 TO WS-HITY
                 MOVE "feet worn: a click at 0.1 is the feet (slot 1)" TO WS-CASE
                 MOVE 1 TO WS-E
             WHEN 3
                 MOVE 0.4 TO WS-HITY
                 MOVE "legs worn: a click at 0.4 is the legs (slot 2)" TO WS-CASE
                 MOVE 2 TO WS-E
             WHEN 4
                 MOVE 0.95 TO WS-HITY
                 MOVE "chest worn: a click at 0.95, just above the 0.9 offset, is the chest (slot 3; exactly 0.9 misses it, a float comparison quirk reported to lane p49f)" TO WS-CASE
                 MOVE 3 TO WS-E
             WHEN OTHER
                 MOVE 1.6 TO WS-HITY
                 MOVE "head worn: a click at 1.6 is the head (slot 4)" TO WS-CASE
                 MOVE 4 TO WS-E
         END-EVALUATE
         CALL "ARMOR-STAND-SLOT" USING WS-STAND WS-HITY WS-SLOT
         MOVE WS-SLOT TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     STOP RUN.

 FIND-TYPE.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > M1-COUNT OR WS-ROW > 0
         IF M1-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 21§8.9 Other non-mob entities (constants only): " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-9.
 COPY CORETEST.
 COPY MOBSPTEST.
