*> Implementation test (002-lane-p49n; docs/protocol/18 sections 3.2 and 3.3, 20 sections 7.1 and 13.6): the horizontal-collision flag of a moving mob and its two users.
*> MOB-PHYSICS records whether the horizontal move was blocked (a step-up that succeeds is not a collision). A spider's climbing flag (metadata 16 BYTE bit 0, sent as Set Entity
*> Data on a change) follows that flag each tick, and a mob with the flag set that collides horizontally gets the vertical velocity 0.2 (so it climbs a wall; a cow does not).
*> A ravager that collided destroys every leaves block in its box inflated by 0.2 with its drops when mob griefing is on, and jumps (0.42) when it stands on the ground.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-CLIMB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY P49NSTATE.
 COPY CBLOCKS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-RAVAGER             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HCOLL               BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CASE240             PIC X(240).
 01 WS-WANTED              BINARY-LONG VALUE 101.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEX                 PIC X(1024).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-ROW            BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-AREA512             PIC X(512).
 01 WS-ZF1                 FLOAT-LONG VALUE 0.
 01 WS-ZF2                 FLOAT-LONG VALUE 0.
 01 WS-MILLI               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:oak_leaves" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LEAVES
*>   A wall of stone, 4 high, in the column x = bx + 1.
     COMPUTE WS-CX = WS-BX + 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-CY = WS-BY + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-STONE
     END-PERFORM
     MOVE 0.5 TO WS-HX
     MOVE 0 TO WS-HZ

*>   A spider standing next to the wall: its first move into the wall is blocked.
     COMPUTE WS-X0 = WS-BX + 0.1
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE "minecraft:spider" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z WS-SPIDER
     MOVE "minecraft:cow" TO WS-KEY
     COMPUTE WS-Z = WS-BZ + 4.5
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z WS-COW
     MOVE 0 TO WS-HCOLL
     CALL "MOB-PHYSICS" USING WS-SPIDER WS-ZF1 WS-ZF2 WS-YAW
     CALL "PN-HCOLL-GET" USING WS-SPIDER WS-HCOLL
     MOVE "acceptance US15 18§3.3 A move along no obstacle is not a horizontal collision" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-HCOLL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-PHYSICS" USING WS-SPIDER WS-HX WS-HZ WS-YAW
     CALL "PN-HCOLL-GET" USING WS-SPIDER WS-HCOLL
     MOVE "acceptance US15 18§3.3 A move into a wall 4 blocks high is a horizontal collision" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-HCOLL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Spider.tick: the climbing flag follows the collision and is sent as metadata 16 (index 16, serializer BYTE 0, value 1, end).
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "SPIDER-CLIMB-TICK" USING WS-SPIDER
     MOVE "acceptance US15 20§7.1 The spider's climbing flag is set after a collision" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PN-CLIMB(WS-SPIDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE SPACES TO WS-AREA512
     MOVE FUNCTION CHAR(EN-ID(WS-SPIDER) + 1) TO WS-AREA512(1:1)
     CALL "TEST-HEX-OF" USING WS-AREA512 WS-ONE WS-HEX
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100001ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 20§7.1 The climbing flag is sent as Set Entity Data index 16 BYTE 1" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED

*>   The next move into the wall: vertical velocity 0.2 after the collision, then gravity (0.2 - 0.08) x 0.98 = 0.1176.
     MOVE 0 TO EN-VY(WS-SPIDER)
     CALL "MOB-PHYSICS" USING WS-SPIDER WS-HX WS-HZ WS-YAW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-SPIDER) * 10000
     MOVE "acceptance US15 18§3.2 A climbing mob that collides gets vy 0.2 (0.1176 after gravity)" TO WS-CASE
     MOVE 1176 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Ten more ticks up the wall: the spider is far above the floor (a wall climber rises above its starting y + 1).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "SPIDER-CLIMB-TICK" USING WS-SPIDER
         CALL "MOB-PHYSICS" USING WS-SPIDER WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "acceptance US15 20§7.1 A spider pushing into a wall climbs it (above y + 1 in 10 ticks)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-SPIDER) > WS-BY + 1.0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Away from the wall the flag goes out again (a move along the floor has no collision).
     MOVE -0.5 TO WS-HX
     CALL "MOB-PHYSICS" USING WS-SPIDER WS-HX WS-HZ WS-YAW
     CALL "SPIDER-CLIMB-TICK" USING WS-SPIDER
     MOVE "acceptance US15 20§7.1 The flag clears when the spider no longer collides" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PN-CLIMB(WS-SPIDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   A cow (no climbing flag) pushing into the same wall collides but never rises.
     MOVE 0.5 TO WS-HX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "MOB-PHYSICS" USING WS-COW WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "acceptance US15 18§3.2 A mob that is not a climber does not rise against a wall" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-COW) <= WS-BY + 0.001
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The ravager (13.6): leaves in its box (inflated by 0.2) are destroyed after a collision; stone is not; it jumps (0.42) from the ground.
     COMPUTE WS-Z = WS-BZ + 8.5
     MOVE "minecraft:ravager" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z WS-RAVAGER
     COMPUTE WS-CZ = WS-BZ + 8
     COMPUTE WS-CX = WS-BX + 1
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-LEAVES
     COMPUTE WS-CY = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-LEAVES
     COMPUTE WS-CY = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
     COMPUTE WS-CX = WS-BX - 5
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-LEAVES
*>   Without a collision flag nothing is destroyed.
     CALL "RAVAGER-LEAVES" USING WS-RAVAGER
     COMPUTE WS-CX = WS-BX + 1
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 Without a horizontal collision a ravager keeps the leaves in reach" TO WS-CASE
     MOVE WS-LEAVES TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Collision with mob griefing off: nothing either.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-ROW
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
     MOVE EN-ID(WS-RAVAGER) TO PN-ID(WS-RAVAGER)
     MOVE 1 TO PN-HCOLL(WS-RAVAGER)
     CALL "RAVAGER-LEAVES" USING WS-RAVAGER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 With mob griefing off a ravager destroys nothing" TO WS-CASE
     MOVE WS-LEAVES TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
*>   Collision with mob griefing on, on the ground: the two leaves in reach are gone, the stone stays, the far leaves stay, the ravager jumps.
     MOVE 1 TO EN-ON-GROUND(WS-RAVAGER)
     MOVE 0 TO EN-VY(WS-RAVAGER)
     CALL "RAVAGER-LEAVES" USING WS-RAVAGER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 After a collision the leaves in reach are destroyed" TO WS-CASE
     MOVE WS-AIR TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-CY = WS-BY + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 Every leaves block of the box goes, also the one above" TO WS-CASE
     MOVE WS-AIR TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-CY = WS-BY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 A block that is not leaves stays" TO WS-CASE
     MOVE WS-STONE TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-CX = WS-BX - 5
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US15 20§13.6 Leaves beyond the inflated box stay" TO WS-CASE
     MOVE WS-LEAVES TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-RAVAGER) * 1000
     MOVE "acceptance US15 20§13.6 The ravager jumps (0.42) after destroying leaves on the ground" TO WS-CASE
     MOVE 420 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-P49N-CLIMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM PN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-CHECK-HEX.
*> USING connection id, case (X(240)), wanted packet id, expected hex of the body: the body of the first packet of that id drained from the connection.
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
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             COMPUTE WS-COUNT = PK-LENGTH - PK-POS
             MOVE SPACES TO WS-COPY
             MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
             CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
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
 END PROGRAM PN-CHECK-HEX.
 COPY CORETEST.
 COPY MOBSPTEST.
