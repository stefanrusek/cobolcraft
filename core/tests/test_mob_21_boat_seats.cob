*> Implementation test (wrap C round 4; 44 part 8 section 3.1 and 3.6): a boat or raft takes two passengers and a chest boat one (canAddPassenger, getMaxPassengers), the seats of two
*> passengers are zOffset + 0.2 and zOffset - 0.6 turned by the boat's yaw, a player passenger's yaw is clamped to 105 degrees either side of the boat's, the second passenger does not
*> steer (Move Vehicle) and destroying the boat sets both free.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-BOAT-SEATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CMENU.
 COPY PROTO.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alex".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-X0                  FLOAT-LONG.
 01 WS-MV-ID               BINARY-LONG VALUE 34.
 01 WS-MV-X                FLOAT-LONG.
 01 WS-MV-Y                FLOAT-LONG.
 01 WS-MV-Z                FLOAT-LONG.
 01 WS-MV-ANGLE            FLOAT-SHORT VALUE 0.
 01 WS-MV-FLAGS            BINARY-LONG VALUE 1.
 01 WS-AMOUNT              BINARY-LONG VALUE 5.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-P1
     MOVE PL-DIM(WS-P1) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-P1)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-P1)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-P1)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FKIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-P1
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-P2
     MOVE 0 TO PL-MODE(WS-P2)
     MOVE "N" TO TL-MODE
     COMPUTE PL-X(WS-P2) = PL-X(WS-P1) + 1
     MOVE PL-Y(WS-P1) TO PL-Y(WS-P2)
     MOVE PL-Z(WS-P1) TO PL-Z(WS-P2)
     MOVE 0 TO PL-SNEAKING(WS-P1) PL-SNEAKING(WS-P2)
     MOVE 0 TO PL-YAW(WS-P1) PL-YAW(WS-P2)

*>   A boat takes two players; the seats are +0.2 (first) and -0.6 (second) along the boat's facing (z at yaw 0).
     MOVE "minecraft:oak_boat" TO WS-KEY
     COMPUTE WS-PX = PL-X(WS-P1) + 1.5
     COMPUTE WS-PY = WS-FY + 1
     MOVE PL-Z(WS-P1) TO WS-PZ
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-P1 WS-ROW WS-USED
     MOVE "acceptance US15 44-8§3.6 a lone rider sits at zOffset 0 of a boat" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = (PL-Z(WS-P1) - EN-Z(WS-ROW)) * 1000
     PERFORM CHECK-N
     CALL "BOAT-USE" USING WS-P2 WS-ROW WS-USED
     MOVE "acceptance US15 44-8§3.1 a boat takes a second passenger (EN-RIDER2 and the vehicle)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND EN-RIDER(WS-ROW) = WS-P1 AND EN-RIDER2(WS-ROW) = WS-P2 AND EN-VEHICLE(PL-ENTITY-ROW(WS-P2)) = WS-ROW
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§3.6 with two passengers the first sits at +0.2" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O ROUNDED = (PL-Z(WS-P1) - EN-Z(WS-ROW)) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§3.6 with two passengers the second sits at -0.6" TO WS-CASE
     MOVE -600 TO WS-E
     COMPUTE WS-O ROUNDED = (PL-Z(WS-P2) - EN-Z(WS-ROW)) * 1000
     PERFORM CHECK-N
     MOVE 90 TO EN-YAW(WS-ROW)
     CALL "BOAT-SYNC" USING WS-ROW
     MOVE "acceptance US15 44-8§3.6 the seats turn with the boat: at yaw 90 the first is 0.2 toward -x, the second 0.6 toward +x" TO WS-CASE
     COMPUTE WS-O ROUNDED = (PL-X(WS-P1) - EN-X(WS-ROW)) * 1000 * 1000 + (PL-X(WS-P2) - EN-X(WS-ROW)) * 1000
     COMPUTE WS-E = -200 * 1000 + 600
     PERFORM CHECK-N
     MOVE 0 TO EN-YAW(WS-ROW)
*>   The second passenger does not steer: its Move Vehicle report moves nothing.
     MOVE EN-X(WS-ROW) TO WS-X0
     COMPUTE WS-MV-X = EN-X(WS-ROW) + 1.5
     MOVE EN-Y(WS-ROW) TO WS-MV-Y
     MOVE EN-Z(WS-ROW) TO WS-MV-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MV-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-MV-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-ANGLE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-MV-ANGLE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-MV-FLAGS
     CALL "TEST-FEED-BUFFER" USING WS-CONN2 PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "acceptance US15 44-8§3.6 Move Vehicle of the second passenger moves nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = (EN-X(WS-ROW) - WS-X0) * 1000
     PERFORM CHECK-N
*>   Rotation: a player passenger's yaw is kept within 105 degrees of the boat's.
     MOVE 170 TO PL-YAW(WS-P1)
     MOVE 190 TO PL-YAW(WS-P2)
     CALL "BOAT-SYNC" USING WS-ROW
     MOVE "acceptance US15 44-8§3.6 a passenger turned 170 degrees from the boat is clamped to 105" TO WS-CASE
     MOVE 105 TO WS-E
     COMPUTE WS-O ROUNDED = PL-YAW(WS-P1)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§3.6 yaw 190 is -170 from the boat: clamped to -105 (keeps its own turn count: 255)" TO WS-CASE
     MOVE 255 TO WS-E
     COMPUTE WS-O ROUNDED = PL-YAW(WS-P2)
     PERFORM CHECK-N
     MOVE 100 TO PL-YAW(WS-P1)
     CALL "BOAT-SYNC" USING WS-ROW
     MOVE "acceptance US15 44-8§3.6 a passenger within 105 degrees is left alone" TO WS-CASE
     MOVE 100 TO WS-E
     COMPUTE WS-O ROUNDED = PL-YAW(WS-P1)
     PERFORM CHECK-N
*>   The first passenger leaves: the second becomes the first (MOB-RIDE-STOP).
     CALL "MOB-RIDE-STOP" USING WS-ROW
     MOVE "acceptance US15 44-8§3.1 when the first passenger leaves the second takes the front seat" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-RIDER(WS-ROW) = WS-P2 AND EN-RIDER2(WS-ROW) = 0 AND EN-VEHICLE(PL-ENTITY-ROW(WS-P1)) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Destroying a boat with two passengers sets both free.
     CALL "BOAT-USE" USING WS-P1 WS-ROW WS-USED
     CALL "BOAT-HURT" USING WS-ROW WS-AMOUNT WS-P1
     MOVE "acceptance US15 44-8§3.9 a destroyed boat sets both passengers free" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-VEHICLE(PL-ENTITY-ROW(WS-P1)) + EN-VEHICLE(PL-ENTITY-ROW(WS-P2))
     PERFORM CHECK-N
*>   A chest boat takes one passenger only (getMaxPassengers 1): the second player's click opens its menu instead (44-8 3.9).
     MOVE "minecraft:oak_chest_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-USE" USING WS-P1 WS-ROW WS-USED
     CALL "BOAT-USE" USING WS-P2 WS-ROW WS-USED
     MOVE "acceptance US15 44-8§3.1 a chest boat takes one passenger" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND MN-CFAMILY(WS-P2) = 14 AND EN-RIDER(WS-ROW) = WS-P1 AND EN-RIDER2(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-BOAT-SEATS.
 COPY CORETEST.
 COPY MOBSPTEST.
