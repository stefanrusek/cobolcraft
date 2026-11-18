*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 9.3 Metadata, attributes and equipment: when sent, with 1.4): the health slot (index 9 FLOAT) is a
*> synced slot of every living entity: the first pairing sends it unless it is the default 1.0, afterwards a changed health sends it (a hit of 4 on a cow of 10 sends 6.0; an
*> armour-reduced hit sends the carried fraction), a health that did not change sends nothing; Set Equipment follows an equipment change (the helmet breaking is in
*> test_stdmob_burn_helmet; the pairing send is in test_mob_20_3_6).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-9-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY           BINARY-LONG VALUE 64.
 01 WS-AMOUNT             BINARY-LONG.
 01 WS-CAUSE              BINARY-LONG VALUE 7.
 01 WS-ZERO               BINARY-LONG VALUE 0.
 01 WS-FZ                 FLOAT-LONG VALUE 0.
 01 WS-BASE               BINARY-LONG VALUE 2000.
 01 WS-ARROW              BINARY-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 6 TO WS-E
     MOVE "N" TO TL-MODE
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
     MOVE 10 TO EN-HEALTH(WS-ROW)

*>   The pairing packet: index 9, FLOAT, 10.0 (not the default 1.0).
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-HP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 18§9.3 Metadata: the pairing sends index 9 FLOAT 10.0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PB-LENGTH >= 9 AND WS-BYTE(1) = X"65" AND WS-BYTE(3) = X"09" AND WS-BYTE(5) = X"41" AND WS-BYTE(6) = X"20"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
*>   The default 1.0 is not sent.
     MOVE 1 TO EN-HEALTH(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-HP-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 18§9.3 Metadata: a health of 1.0 is the default and builds nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE PB-LENGTH TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 10 TO EN-HEALTH(WS-ROW)
*>   A hit of 4 changes the health to 6: the remembered sent value follows; the same health again sends nothing.
     CALL "STDMOB-HP-PAIR" USING WS-ROW
     MOVE "acceptance US15 18§9.3 Metadata: pairing remembers the sent health (10000 thousandths)" TO WS-CASE
     MOVE 10000 TO WS-E
     MOVE EN-HP-SENT(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§9.3 Metadata: after a hit of 4 the sent health is 6000 thousandths" TO WS-CASE
     MOVE 6000 TO WS-E
     MOVE EN-HP-SENT(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A hit inside the window that is not stronger changes nothing and sends nothing (the sent value is the same).
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§9.3 Metadata: a hit that changed nothing leaves the sent health" TO WS-CASE
     MOVE 6000 TO WS-E
     MOVE EN-HP-SENT(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-HP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 18§9.3 Metadata: the packet after the hit carries 6.0 (0x40C00000)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PB-LENGTH >= 9 AND WS-BYTE(5) = X"40" AND FUNCTION ORD(WS-BYTE(6)) = 193
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
*>   A row that is no standard mob (an arrow) has no health slot to pair: nothing is remembered.
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-FZ WS-FZ WS-FZ WS-BASE WS-ZERO WS-ARROW
     CALL "STDMOB-HP-PAIR" USING WS-ARROW
     MOVE "acceptance US15 18§9.3 Metadata: a row that is no standard mob has no health slot to pair" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-HP-SENT(WS-ARROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-9-3.
 COPY CORETEST.
 COPY MOBSPTEST.
