*> Acceptance test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.8, 44-residual-mob-questions-8 sections 10 and 12.8): a camel is mounted with an empty hand and
*> carries two riders: the first at the front seat (0, 2.0, 0.5), the second at the rear seat z -0.7, both rotated by -yaw (less the player's attachment 0.6 in y); a third player
*> is refused; shift ends the ride of its player, the second rider moves up to the front seat; an untamed camel does not buck its riders. The world has a stone floor of 19 x 19.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-CAMEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY BRWORLD.
 COPY PLAYPKT.
 COPY XORO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-NAME2              PIC X(16) VALUE "Alex".
 01 WS-NAME3              PIC X(16) VALUE "Casey".
 01 WS-LEN4               BINARY-LONG VALUE 4.
 01 WS-LEN5               BINARY-LONG VALUE 5.
 01 WS-CONN2              BINARY-LONG.
 01 WS-CONN3              BINARY-LONG.
 01 WS-P2                 BINARY-LONG.
 01 WS-P3                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                BINARY-LONG.
 01 WS-XHI                BINARY-LONG.
 01 WS-ZLO                BINARY-LONG.
 01 WS-ZHI                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-NEEDLE              PIC X(40).
 01 WS-HITS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-WANT-KEY            PIC X(112).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-COUNT-TOTAL         BINARY-LONG.
 01 WS-ID-A                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SLOT-ITEM           BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-V-BABY              BINARY-LONG.
 01 WS-V-WOOL              BINARY-LONG.
 01 WS-V-NEEDED            BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-MOVING             BINARY-LONG.
 01 WS-ACTION             BINARY-LONG.
 01 WS-COD                BINARY-LONG.
 01 WS-STICK              BINARY-LONG.
 01 WS-CAT                BINARY-LONG.
 01 WS-OCELOT             BINARY-LONG.
 01 WS-DIST               FLOAT-LONG.
 01 WS-NEAR-HX            FLOAT-LONG.
 01 WS-HELD              PIC X(24).
 01 WS-HANDLED           BINARY-LONG.
 01 WS-CAMEL             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-JOIN" USING WS-NAME2 WS-LEN4 WS-CONN2
     CALL "TEST-JOIN" USING WS-NAME3 WS-LEN5 WS-CONN3
     MOVE CN-PLAYER(WS-CONN2) TO WS-P2
     MOVE CN-PLAYER(WS-CONN3) TO WS-P3
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 9
     COMPUTE WS-XHI = WS-CX + 9
     COMPUTE WS-ZLO = WS-CZ - 9
     COMPUTE WS-ZHI = WS-CZ + 9
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5

     MOVE 0 TO PL-MODE(WS-P2) PL-MODE(WS-P3)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-TEXT
     CALL "TEST-DRAIN-IDS" USING WS-CONN3 WS-TEXT
     MOVE SPACES TO WS-HELD
     MOVE "camel" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-CAMEL
     MOVE 32 TO EN-HEALTH(WS-CAMEL)
     COMPUTE EN-Y(WS-CAMEL) = WS-FLOOR + 1
     MOVE 0 TO PL-SNEAKING(WS-PLAYER) PL-SNEAKING(WS-P2) PL-SNEAKING(WS-P3)

*> The first player mounts the front seat: (0, 2.0, 0.5) rotated by -yaw, less the player's attachment 0.6
     CALL "MOB-RIDE-USE" USING WS-PLAYER WS-CAMEL WS-HELD WS-HANDLED
     MOVE "acceptance US15 44-8§12.8 Camel: an empty hand mounts an unsaddled camel (no saddle needed)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: the first rider is the camel's first passenger" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-RIDER(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: the front seat is 1.4 above the camel (2.0 less 0.6)" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-Y(WS-CAMEL) + 1.4) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-Y(WS-PLAYER) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: one passenger sits at z 0.5 (yaw 0: 0.5 ahead on z)" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-Z(WS-CAMEL) + 0.5) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-Z(WS-PLAYER) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: and exactly on the camel's x" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER(EN-X(WS-CAMEL) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-X(WS-PLAYER) * 1000 + 0.5)
     PERFORM CHECK-N

*> The second player takes the rear seat at z -0.7; the first stays at 0.5
     CALL "MOB-RIDE-USE" USING WS-P2 WS-CAMEL WS-HELD WS-HANDLED
     MOVE "acceptance US15 19§3.8 Camel: a second player mounts the camel (fewer than 2 passengers)" TO WS-CASE
     MOVE WS-P2 TO WS-EXPECT
     MOVE EN-RIDER2(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: the rear seat is at z -0.7" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-Z(WS-CAMEL) - 0.7) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-Z(WS-P2) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 19§3.8 Camel: the first rider keeps the front seat" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-Z(WS-CAMEL) + 0.5) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-Z(WS-PLAYER) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 19§3.8 Camel: the rider is the vehicle's passenger on the player entity" TO WS-CASE
     MOVE WS-CAMEL TO WS-EXPECT
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-P2)) TO WS-OBSERVE
     PERFORM CHECK-N

*> A third player is refused: the camel holds 2 riders
     CALL "MOB-RIDE-USE" USING WS-P3 WS-CAMEL WS-HELD WS-HANDLED
     MOVE "acceptance US15 19§3.8 Camel: a third player cannot mount" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK-N

*> Turned to yaw 90 the seats turn with it (the seat is rotated by -yaw: +z becomes -x)
     MOVE 90 TO EN-YAW(WS-CAMEL)
     CALL "MOB-RIDE-SYNC" USING WS-CAMEL
     MOVE "acceptance US15 44-8§12.8 Camel: at yaw 90 the front seat is 0.5 toward -x" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-X(WS-CAMEL) - 0.5) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-X(WS-PLAYER) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§12.8 Camel: and the rear seat 0.7 toward +x" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER((EN-X(WS-CAMEL) + 0.7) * 1000 + 0.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(PL-X(WS-P2) * 1000 + 0.5)
     PERFORM CHECK-N

*> A tick of the ridden camel: it is not bucked off (an untamed camel does not run around like crazy)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         CALL "STDMOB-STEP" USING WS-CAMEL
     END-PERFORM
     MOVE "acceptance US15 19§3.8 Camel: 300 ticks later both riders are still on the camel" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-RIDER(WS-CAMEL) = WS-PLAYER AND EN-RIDER2(WS-CAMEL) = WS-P2
         MOVE 2 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*> Shift ends the ride of the rear rider only; then the front rider's shift leaves the camel empty
     INITIALIZE PLAY-SERVERBOUND
     MOVE 32 TO PSB-FLAGS
     CALL "MOB-RIDE-INPUT" USING WS-CONN2 PLAY-SERVERBOUND
     MOVE "acceptance US15 19§3.8 Camel: the rear rider dismounts with shift, the front rider stays" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-RIDER(WS-CAMEL) + EN-RIDER2(WS-CAMEL) + EN-VEHICLE(PL-ENTITY-ROW(WS-P2))
     PERFORM CHECK-N
     CALL "MOB-RIDE-USE" USING WS-P2 WS-CAMEL WS-HELD WS-HANDLED
     CALL "MOB-RIDE-INPUT" USING WS-CONN PLAY-SERVERBOUND
     MOVE "acceptance US15 19§3.8 Camel: the front rider dismounts, the second one takes the front seat" TO WS-CASE
     MOVE WS-P2 TO WS-EXPECT
     MOVE EN-RIDER(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§3.8 Camel: and the rear seat is empty" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-RIDER2(WS-CAMEL) TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-CAMEL.
 COPY CORETEST.
