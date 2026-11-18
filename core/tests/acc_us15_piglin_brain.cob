 *> Acceptance test, the piglin brain remainder (docs/protocol/44-residual-mob-questions-6-nether.md sections 2.3, 2.5, 2.6, 2.9 to 2.10, 3.3, 4.1, 5.3; 21 section 5.5.1; lane 002-lane-mobsb7, T9505 to T9508):
*> the repellent sensor (soul fire family for a piglin, warped fungus family for a hoglin) and the retreat from it, the avoidance of zombified creatures within 6 blocks (5 to 7 seconds), the
*> celebration after a kill (300 ticks, dancing with probability 1/10, metadata 19), walking to a loved item within 9 blocks (and giving up after 200 ticks), anger spreading to adult piglins and
*> brutes, and a baby that avoids its attacker.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PIGLIN-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-PG                  BINARY-LONG.
 01 WS-BR                  BINARY-LONG.
 01 WS-HG                  BINARY-LONG.
 01 WS-ZP                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 24.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DRAW                BINARY-LONG.
 01 WS-WANTED              BINARY-LONG VALUE 101.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEX                 PIC X(8).
 01 WS-BYTE                BINARY-LONG.
 01 WS-CH                  PIC X.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:piglin_brute" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombified_piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 12
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-PG
     CALL "MOB-SPAWN" USING WS-DIM WS-HTYPE WS-X WS-Y WS-Z WS-YAW WS-HG
     CALL "STDMOB-INDEX" USING WS-PTYPE WS-M
*>   The sensor: a soul torch 3 blocks east is a repellent of the piglin, a warped fungus is not; the hoglin's tag is the other way round.
     MOVE "minecraft:soul_torch" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-FX = WS-X0 + 15
     COMPUTE WS-FZ = WS-Z0 + 12
     COMPUTE WS-I = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-I WS-FZ WS-STATE
     MOVE 1 TO WS-KIND
     CALL "PGB-REPEL" USING WS-PG WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§4.1 a soul torch within 8 x 4 blocks is a repellent of the piglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§4.1 at its cell" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-FX * 1000 + WS-I
     COMPUTE TL-OBSERVED-N = WS-RX * 1000 + WS-RY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     CALL "PGB-REPEL" USING WS-HG WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§4.3 a soul torch does not repel a hoglin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:warped_fungus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-FX = WS-X0 + 9
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-I WS-FZ WS-STATE
     CALL "PGB-REPEL" USING WS-HG WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§4.3 a warped fungus repels a hoglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KIND
     CALL "PGB-REPEL" USING WS-PG WS-KIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§4.1 and the piglin still finds the torch only (nearest first)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-X0 + 15
     MOVE WS-RX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The retreat: on the beat of its sensor the piglin walks away from the torch (west), for 20 ticks.
     COMPUTE CW-TIME = 2000 - FUNCTION MOD(EN-ID(WS-PG), 20)
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§5.3 a piglin next to a soul torch walks away from it (west)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO CW-TIME
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§5.3 and keeps walking on the following ticks" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Remove the torch and the fungus.
     MOVE "minecraft:air" TO WS-KEY
     MOVE 0 TO WS-STATE
     COMPUTE WS-FX = WS-X0 + 15
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-I WS-FZ WS-STATE
     COMPUTE WS-FX = WS-X0 + 9
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-I WS-FZ WS-STATE
     MOVE 0 TO WS-I
     PERFORM 25 TIMES
         ADD 1 TO CW-TIME
         IF FUNCTION MOD(CW-TIME + EN-ID(WS-PG), 20) = 0
             ADD 1 TO CW-TIME
         END-IF
         CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44-6§5.3 the torch is gone: after 20 ticks the retreat ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombified piglin 4 blocks west: the piglin drops its target and walks away east (5 to 7 seconds); at 7 blocks it does not mind.
     COMPUTE WS-X = WS-X0 + 8.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZP
     MOVE WS-PLAYER TO EN-TARGET(WS-PG)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-PG)
     COMPUTE CW-TIME = 4000 - FUNCTION MOD(EN-ID(WS-PG), 20)
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     CALL "STDMOB-AGGRO" USING WS-PG WS-M
     MOVE "acceptance US15 44-6§2.2 near a zombified piglin the piglin has no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO CW-TIME
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§5.3 and walks away from it (east)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOID-LEFT" USING WS-PG WS-I
     MOVE "acceptance US15 44-6§2.1 the avoidance lasts 100 to 140 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I >= 98 AND WS-I <= 140
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ZP
     CALL "ENTITY-REMOVE" USING WS-PG
     COMPUTE WS-X = WS-X0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-PG
     COMPUTE WS-X = WS-X0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZP
     COMPUTE CW-TIME = 6000 - FUNCTION MOD(EN-ID(WS-PG), 20)
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     ADD 1 TO CW-TIME
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§2.2 a zombified piglin beyond 6 blocks does not matter" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ZP
*>   The celebration after a kill (draw 0 of 10: it dances), 300 ticks at the place of the kill; it walks there (radius 2 at speed 1.0, dancing radius 4 at 0.6).
     COMPUTE EN-X(WS-HG) = WS-X0 + 4.5
     MOVE 0 TO WS-DRAW
     CALL "PGB-CELEBRATE" USING WS-PG WS-HG WS-DRAW
     CALL "PGB-CELEBRATE-LEFT" USING WS-PG WS-I
     MOVE "acceptance US15 44-6§3.4 the celebration lasts 300 ticks" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-PG) TO WS-BYTE
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-CH
     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-CH)) TO WS-HEX(1:2)
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "130801ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 44-6§2.10 metadata 19 dancing true is sent" TO TL-CASE
     CALL "RC-CHECK-HEX" USING WS-CONN TL-CASE WS-WANTED WS-EXPECTED
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§5.7 the piglin walks to the place of the kill (west)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-PG) = WS-X0 + 4.5
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§5.7 there it stands (within the radius)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HX = 0 AND WS-HZ = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-EXPECTED
     PERFORM 300 TIMES
         CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     END-PERFORM
     CALL "PGB-CELEBRATE-LEFT" USING WS-PG WS-I
     MOVE "acceptance US15 44-6§2.10 the celebration is over after 300 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "130800ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 44-6§2.10 and the dancing flag is cleared" TO TL-CASE
     CALL "RC-CHECK-HEX" USING WS-CONN TL-CASE WS-WANTED WS-EXPECTED
     MOVE 5 TO WS-DRAW
     CALL "PGB-CELEBRATE" USING WS-PG WS-HG WS-DRAW
     CALL "PGB-CELEBRATE-LEFT" USING WS-PG WS-I
     MOVE "acceptance US15 44-6§3.4 a draw of 5 celebrates without dancing (300 ticks)" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-EXPECTED
     MOVE "none" TO WS-EXPECTED
     MOVE "acceptance US15 44-6§3.4 and sends no dancing flag" TO TL-CASE
     CALL "RC-CHECK-HEX" USING WS-CONN TL-CASE WS-WANTED WS-EXPECTED
     CALL "PGB-CELEBRATE-STOP" USING WS-PG
*>   Walking to a loved item within 9 blocks: a gold ingot 6 blocks east; a dirt item is not wanted; after 200 ticks without reaching it the piglin gives up for 200 ticks.
     COMPUTE EN-X(WS-PG) = WS-X0 + 12.5
     COMPUTE EN-Z(WS-PG) = WS-Z0 + 12.5
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 16.5
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "IP-AT-LOCATION" USING WS-DIM WS-X WS-Y WS-Z WS-OFFSET WS-ITEM WS-ONE WS-NONE WS-DROP
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§3.3 a dirt item is not walked to" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-DROP
     MOVE "minecraft:gold_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 18.5
     CALL "IP-AT-LOCATION" USING WS-DIM WS-X WS-Y WS-Z WS-OFFSET WS-ITEM WS-ONE WS-NONE WS-DROP
     MOVE 0 TO EN-DELAY(WS-DROP)
     CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-6§3.3 a gold ingot 6 blocks away is walked to (east)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-I
     PERFORM 205 TIMES
         CALL "PGB-STEP" USING WS-PG WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44-6§3.3 tired of trying for 200 ticks it stops walking to the item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-DROP
     MOVE 5 TO EN-ADMIRE(WS-PG)
     CALL "ENTITY-REMOVE" USING WS-PG
*>   Anger spreads from a hit piglin to the adult piglins and brutes around it, and a baby avoids its attacker instead of getting angry.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-PG
     COMPUTE WS-X = WS-X0 + 17.5
     CALL "MOB-SPAWN" USING WS-DIM WS-BTYPE WS-X WS-Y WS-Z WS-YAW WS-BR
     MOVE 0 TO EN-TARGET(WS-BR)
     CALL "NETHER-HURT" USING WS-PG WS-PLAYER
     MOVE "acceptance US15 44-6§2.5 the hit piglin is angry (600 ticks)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.5 a brute within 16 blocks is angry at the attacker too" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-BR) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-BR
     MOVE -24000 TO EN-MOBAGE(WS-PG)
     MOVE 0 TO EN-ANGER(WS-PG)
     MOVE 0 TO EN-TARGET(WS-PG)
     CALL "NETHER-HURT" USING WS-PG WS-PLAYER
     MOVE "acceptance US15 44-6§2.3 a baby gets no anger of its own" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-AVOID-LEFT" USING WS-PG WS-I
     MOVE "acceptance US15 44-6§2.3 but avoids the attacker for 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-PIGLIN-BRAIN.

 COPY CORETEST.
 COPY MOBSPTEST.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RC-CHECK-HEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-INDEX-BYTE          BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AREA                PIC X(65536) BASED.
 01 WS-COPY                PIC X(512).
 01 WS-HEX                 PIC X(1024).
 01 WS-TEXT                PIC X(4096).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CASE                 PIC X(240).
 01 L-WANTED               BINARY-LONG.
 01 L-EXPECTED             PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-CASE L-WANTED L-EXPECTED.
     MOVE "none" TO WS-HEX
     MOVE 0 TO WS-FOUND WS-OUTCOME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         *>       The health slot (index 9) sent at the pairing (18 section 9.3) is not the packet looked for.
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             MOVE FUNCTION ORD(WS-AREA(PK-POS + 2:1)) TO WS-INDEX-BYTE
             IF WS-INDEX-BYTE = 10
                 MOVE 0 TO WS-FOUND
             ELSE
                 COMPUTE WS-COUNT = PK-LENGTH - PK-POS
                 MOVE SPACES TO WS-COPY
                 MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
                 CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     MOVE WS-HEX TO WS-TEXT
     MOVE L-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE L-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM RC-CHECK-HEX.
