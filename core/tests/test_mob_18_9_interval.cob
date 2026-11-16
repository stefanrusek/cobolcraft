*> Implementation test (US15; docs/protocol/18-mob-framework.md section 9.2): a mob row sends movement only on its update interval, the delta is against the last sent position, and an absolute sync follows after 400 sends.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-9-INTERVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-TEXT               PIC X(1024).
 01 WS-UPD                BINARY-LONG.
 01 WS-TRACK              BINARY-LONG.
 01 WS-NX                 FLOAT-LONG.
 01 WS-ON                 BINARY-LONG VALUE 1.
 01 WS-P1                 FLOAT-SHORT VALUE 0.
 01 WS-TIME               BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     COMPUTE WS-FZ = PL-Z(WS-PLAYER) + 3
     MOVE "minecraft:cow" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "M189-TRACK" USING WS-TYPE WS-TRACK WS-UPD
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
*>   A tick that is not a multiple of the interval: the row moves in the simulation, nothing is sent.
     COMPUTE WS-TIME = (FUNCTION INTEGER(CW-TIME / WS-UPD) + 10) * WS-UPD + 1
     MOVE WS-TIME TO CW-TIME
     COMPUTE WS-NX = WS-FX + 0.5
     CALL "ENTITY-MOVE" USING WS-ROW WS-NX WS-FY WS-FZ WS-YAW WS-P1 WS-ON
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 18§9.2 Update interval: a tick off the interval sends no movement" TO WS-CASE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-O
     IF WS-TEXT = SPACES
         MOVE 0 TO WS-O
     END-IF
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18§9.2 Update interval: the simulation position is the new one (x + 0.5)" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-X(WS-ROW) - WS-FX) * 1000
     MOVE 500 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18§9.2 Update interval: the last sent position is still the old one" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-SENT-X(WS-ROW) - WS-FX) * 1000
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   On the interval tick the delta is against the last sent position (1.0 here, two sends of 0.5 are not lost).
     ADD 2 TO CW-TIME
     COMPUTE WS-TIME = FUNCTION INTEGER(CW-TIME / WS-UPD) * WS-UPD + WS-UPD
     MOVE WS-TIME TO CW-TIME
     COMPUTE WS-NX = WS-FX + 1.0
     CALL "ENTITY-MOVE" USING WS-ROW WS-NX WS-FY WS-FZ WS-YAW WS-P1 WS-ON
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 18§9.2 Update interval: on the interval tick one Move Entity Pos (id 54 of the drain) goes out" TO WS-CASE
     MOVE WS-TEXT(1:2) TO WS-O
     MOVE 54 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18§9.2 Update interval: afterwards the last sent position is x + 1.0" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-SENT-X(WS-ROW) - WS-FX) * 1000
     MOVE 1000 TO WS-E
     PERFORM CHECK-N
*>   After 400 sends without an absolute position the next send is a Teleport Entity (id 128 in the drain).
     MOVE 400 TO EN-SENT-AGE(WS-ROW)
     ADD WS-UPD TO CW-TIME
     COMPUTE WS-NX = WS-FX + 1.01
     CALL "ENTITY-MOVE" USING WS-ROW WS-NX WS-FY WS-FZ WS-YAW WS-P1 WS-ON
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 18§9.2 Update interval: after 400 sends the next one is an absolute Teleport Entity (128)" TO WS-CASE
     MOVE WS-TEXT(1:3) TO WS-O
     MOVE 128 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18§9.2 Update interval: the send counter starts again at 1" TO WS-CASE
     MOVE EN-SENT-AGE(WS-ROW) TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-9-INTERVAL.
 COPY CORETEST.
 COPY MOBSPTEST.
