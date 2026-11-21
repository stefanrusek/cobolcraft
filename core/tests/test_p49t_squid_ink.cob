*> Squid ink (docs/protocol/42-particles-7 section 1.4.1; lane p49t, T39090): a squid or glow squid hurt by a player sends 30 Level Particles (0x30) of squid_ink (76) or glow_squid_ink (109) at the ink origin
*> + (0, 0.5, 0) (the origin is the squid's position plus (0, -1, 0) rotated by the previous body angles), count 0, the distance fields the rotated direction (r1 x 0.6 - 0.3, -1, r2 x 0.6 - 0.3) times
*> (0.3 + 2 r3; a baby 0.1 + 2 r3) and speed 0.1; no attacker, no ink. AQUA-ROTATE is the rotateVector helper (x axis by xBodyRotO, then y axis by -yBodyRotO).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-SQUID-INK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SQUID-T             BINARY-LONG.
 01 WS-GLOW-T              BINARY-LONG.
 01 WS-SQUID               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE-PLAYER        BINARY-LONG VALUE 3.
 01 WS-CAUSE-OTHER         BINARY-LONG VALUE 6.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PACKETS             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-DBL-X               FLOAT-LONG.
 01 WS-DBL-Y               FLOAT-LONG.
 01 WS-DBL-Z               FLOAT-LONG.
 01 WS-F                   FLOAT-SHORT OCCURS 6 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RANDOM              BINARY-LONG.
 01 WS-BAD-TYPE            BINARY-LONG.
 01 WS-BAD-POS             BINARY-LONG.
 01 WS-BAD-COUNT           BINARY-LONG.
 01 WS-BAD-SPEED           BINARY-LONG.
 01 WS-BAD-DIR             BINARY-LONG.
 01 WS-MIN-DY              FLOAT-LONG.
 01 WS-MAX-DY              FLOAT-LONG.
 01 WS-LIMIT-LOW           FLOAT-LONG.
 01 WS-LIMIT-HIGH          FLOAT-LONG.
 01 WS-DX-MAX              FLOAT-LONG.
 01 WS-EXPECT-TYPE         BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-ANGLE-X             FLOAT-LONG.
 01 WS-ANGLE-Y             FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:glow_squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GLOW-T WS-ENTITY-ROW WS-STATUS
*>   The rotation helper (the worked example of 1.4.1): yBodyRotO 90 turns (0.2, -1, 0) into (0, -1, 0.2); xBodyRotO 90 turns (0, -1, 0) into (0, 0, 1).
     MOVE 0.2 TO WS-RX
     MOVE -1 TO WS-RY
     MOVE 0 TO WS-RZ WS-ANGLE-X
     MOVE 90 TO WS-ANGLE-Y
     CALL "AQUA-ROTATE" USING WS-RX WS-RY WS-RZ WS-ANGLE-X WS-ANGLE-Y
     MOVE "acceptance US15 42-7§1.4.1 rotateVector with yBodyRotO 90: x becomes 0 (micro)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = WS-RX * 1000000
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 rotateVector with yBodyRotO 90: z becomes 0.2 (micro)" TO WS-CASE
     MOVE 200000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-RZ * 1000000
     PERFORM CHECK-N
     MOVE 0 TO WS-RX
     MOVE -1 TO WS-RY
     MOVE 0 TO WS-RZ
     MOVE 90 TO WS-ANGLE-X
     MOVE 0 TO WS-ANGLE-Y
     CALL "AQUA-ROTATE" USING WS-RX WS-RY WS-RZ WS-ANGLE-X WS-ANGLE-Y
     MOVE "acceptance US15 42-7§1.4.1 rotateVector with xBodyRotO 90: (0, -1, 0) becomes (0, 0, 1): z (micro)" TO WS-CASE
     MOVE 1000000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-RZ * 1000000
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 rotateVector with xBodyRotO 90: y (micro)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = WS-RY * 1000000
     PERFORM CHECK-N
*>   An adult squid hurt by the player: 30 packets.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 3
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID-T WS-X WS-Y WS-Z WS-YAW WS-SQUID
     MOVE WS-SQUID-T TO WS-EXPECT-TYPE
     PERFORM DRAIN-ALL
     CALL "HEALTH-MOB-DAMAGE" USING WS-SQUID WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
     MOVE 76 TO WS-EXPECT-TYPE
     MOVE 0.3 TO WS-LIMIT-LOW
     MOVE 2.3 TO WS-LIMIT-HIGH
     PERFORM DRAIN-INK
     MOVE "acceptance US15 42-7§1.4.1 a squid hurt by a player sends 30 particle packets" TO WS-CASE
     MOVE 30 TO WS-E
     MOVE WS-PACKETS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 every particle is squid_ink (76)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD-TYPE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 every particle is at the origin (squid y - 1) + 0.5 above the squid's feet minus 0.5" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD-POS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 count 0 and speed 0.1 on every particle" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-BAD-COUNT + WS-BAD-SPEED
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 every direction is (r1 x 0.6 - 0.3, -1, r2 x 0.6 - 0.3) x (0.3 to 2.3): y between -2.3 and -0.3, |x| and |z| within 0.3 x its factor" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD-DIR TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 42-7§1.4.1 the speed factors differ from particle to particle (y spread above 0.5)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX-DY - WS-MIN-DY > 0.5
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A hit with no attacker (a command) makes no ink.
     MOVE 0 TO EN-HURT(WS-SQUID)
     PERFORM DRAIN-ALL
     CALL "HEALTH-MOB-DAMAGE" USING WS-SQUID WS-AMOUNT WS-CAUSE-OTHER WS-NO-ATTACKER
     PERFORM DRAIN-INK
     MOVE "acceptance US15 42-7§1.4.1 a squid hurt with no attacker sends no ink" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PACKETS TO WS-O
     PERFORM CHECK-N
*>   A baby squid (age below 0): factors 0.1 to 2.1; a glow squid sends glow_squid_ink (109).
     MOVE -24000 TO EN-AGE(WS-SQUID)
     MOVE 0 TO EN-HURT(WS-SQUID)
     PERFORM DRAIN-ALL
     CALL "HEALTH-MOB-DAMAGE" USING WS-SQUID WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
     MOVE 0.1 TO WS-LIMIT-LOW
     MOVE 2.1 TO WS-LIMIT-HIGH
     PERFORM DRAIN-INK
     MOVE "acceptance US15 42-7§1.4.1 a baby squid sends 30 particles with the factors 0.1 to 2.1" TO WS-CASE
     MOVE 30 TO WS-E
     COMPUTE WS-O = WS-PACKETS - WS-BAD-DIR
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-SQUID
     CALL "MOB-SPAWN" USING WS-DIM WS-GLOW-T WS-X WS-Y WS-Z WS-YAW WS-SQUID
     PERFORM DRAIN-ALL
     CALL "HEALTH-MOB-DAMAGE" USING WS-SQUID WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
     MOVE 109 TO WS-EXPECT-TYPE
     MOVE 0.3 TO WS-LIMIT-LOW
     MOVE 2.3 TO WS-LIMIT-HIGH
     PERFORM DRAIN-INK
     MOVE "acceptance US15 42-7§1.4.1 a glow squid sends 30 glow_squid_ink (109) particles" TO WS-CASE
     MOVE 30 TO WS-E
     COMPUTE WS-O = WS-PACKETS - WS-BAD-TYPE
     PERFORM CHECK-N
     STOP RUN.

 DRAIN-ALL.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER.

*> Reads the packets of the connection: for each Level Particles (0x30) the particle is checked against WS-EXPECT-TYPE, the squid's position and the factor limits.
 DRAIN-INK.
     MOVE 0 TO WS-PACKETS WS-BAD-TYPE WS-BAD-POS WS-BAD-COUNT WS-BAD-SPEED WS-BAD-DIR
     MOVE 100 TO WS-MIN-DY
     MOVE -100 TO WS-MAX-DY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 48
             ADD 1 TO WS-PACKETS
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-TYPE
             CALL "PB-GET-BOOL" USING PK-BUFFER WS-BOOL
             CALL "PB-GET-BOOL" USING PK-BUFFER WS-BOOL
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-DBL-X
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-DBL-Y
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-DBL-Z
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 CALL "PB-GET-FLOAT" USING PK-BUFFER WS-F(WS-I)
             END-PERFORM
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-COUNT
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-RANDOM
             IF WS-TYPE NOT = WS-EXPECT-TYPE
                 ADD 1 TO WS-BAD-TYPE
             END-IF
             IF FUNCTION ABS(WS-DBL-X - EN-X(WS-SQUID)) > 0.0001 OR FUNCTION ABS(WS-DBL-Y - (EN-Y(WS-SQUID) - 0.5)) > 0.0001
                     OR FUNCTION ABS(WS-DBL-Z - EN-Z(WS-SQUID)) > 0.0001
                 ADD 1 TO WS-BAD-POS
             END-IF
             IF WS-COUNT NOT = 0
                 ADD 1 TO WS-BAD-COUNT
             END-IF
             IF FUNCTION ABS(WS-F(4) - 0.1) > 0.0001 OR FUNCTION ABS(WS-F(5) - 0.1) > 0.0001 OR FUNCTION ABS(WS-F(6) - 0.1) > 0.0001
                 ADD 1 TO WS-BAD-SPEED
             END-IF
*>           y in [-limit high, -limit low]; |x| and |z| at most 0.3 x the factor (the factor is -y).
             IF WS-F(2) > 0 - WS-LIMIT-LOW + 0.0001 OR WS-F(2) < 0 - WS-LIMIT-HIGH - 0.0001
                 ADD 1 TO WS-BAD-DIR
             ELSE
                 COMPUTE WS-DX-MAX = 0.3001 * (0 - WS-F(2))
                 IF FUNCTION ABS(WS-F(1)) > WS-DX-MAX OR FUNCTION ABS(WS-F(3)) > WS-DX-MAX
                     ADD 1 TO WS-BAD-DIR
                 END-IF
             END-IF
             IF WS-F(2) < WS-MIN-DY
                 MOVE WS-F(2) TO WS-MIN-DY
             END-IF
             IF WS-F(2) > WS-MAX-DY
                 MOVE WS-F(2) TO WS-MAX-DY
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-P49T-SQUID-INK.
 COPY CORETEST.
 COPY MOBSPTEST.
