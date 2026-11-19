*> Creaking hearts and the creakings bound to them (lane 002-lane-p49r; docs/protocol/20 section 17 and 17.4, 31 section 6, 44-5 section 8, 44-x2 section 2.4). State: HT-ENTRY of HEARTSTATE.cpy and the
*> home fields of CRK-ENTRY. The world side of a heart (the block entity table, the pale oak log test with its axis, the block state written back, the comparator output, particles, the resin spread) is
*> not here: HEART-TICK takes the facts that need it (the logs flag).
*>   HEART-FIND USING dim, x, y, z, create, slot out
*>   CREAKING-BIND USING creaking row, heart x, y, z: setTransient(home): the home position, entity event 60.
*>   CREAKING-TEAR-DOWN USING creaking row: tearDown: IS_TEARING_DOWN (metadata 18) and the 45-tick countdown after which the creaking is removed; it cannot move meanwhile.
*>   HEART-SPAWN-PROTECTOR USING heart slot, creaking row out: SpawnUtil.trySpawnMob (reason SPAWNER, 5 attempts, 16 horizontal, 8 vertical, ON_TOP_OF_COLLIDER_NO_LEAVES, the spawn box checked): the first
*>     attempt whose floor is a full solid block that is not leaves with an empty block above it and room for the creaking (three free cells) gets the creaking, bound to the heart; 0 when none.
*>   HEART-TICK USING heart slot, logs (1 when both neighbours along the axis are pale oak logs of that axis), day time, persistent (the protector's isPersistenceRequired): one tick of the block entity.
*> Not built: the particles, sounds and the hurt callback (creakingHurt: the resin spread), the comparator output (BE5-HEART-COMPARATOR has the formula), the path restriction to 32 blocks of the home, "cannot
*> use portals", "a player is stuck in it", and the heart's save and load of the link.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY HEARTSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX OR L-SLOT > 0
         IF HT-USED(WS-I) = 1 AND HT-DIM(WS-I) = L-DIM AND HT-X(WS-I) = L-X AND HT-Y(WS-I) = L-Y AND HT-Z(WS-I) = L-Z
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX OR L-SLOT > 0
             IF HT-USED(WS-I) = 0
                 INITIALIZE HT-ENTRY(WS-I)
                 MOVE 1 TO HT-USED(WS-I)
                 MOVE L-DIM TO HT-DIM(WS-I)
                 MOVE L-X TO HT-X(WS-I)
                 MOVE L-Y TO HT-Y(WS-I)
                 MOVE L-Z TO HT-Z(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HEART-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-BIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 60.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         MOVE 1 TO CRK-HOME(WS-SLOT)
         MOVE L-X TO CRK-HX(WS-SLOT)
         MOVE L-Y TO CRK-HY(WS-SLOT)
         MOVE L-Z TO CRK-HZ(WS-SLOT)
     END-IF
     CALL "WARDEN-EVENT" USING L-ROW WS-EVENT
     GOBACK.
 END PROGRAM CREAKING-BIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-TEAR-DOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG VALUE 18.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0 AND CRK-TEAR(WS-SLOT) = 0
         MOVE 45 TO CRK-TEAR(WS-SLOT)
         CALL "CREAKING-SEND" USING L-ROW WS-FLAG WS-ONE
     END-IF
     GOBACK.
 END PROGRAM CREAKING-TEAR-DOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRK-STATE-SOLID.
*> USING block state, solid out (0/1), leaves out (0/1): whether the state has a collision shape (every such shape is taken as a full cube) and whether its block is leaves.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-LEAVES               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SOLID L-LEAVES.
     MOVE 0 TO L-SOLID L-LEAVES
     IF L-STATE > 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
         IF CB-SOLID(WS-BLOCK) = 1
             MOVE 1 TO L-SOLID
         END-IF
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "leaves"
         IF WS-N > 0
             MOVE 1 TO L-LEAVES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CRK-STATE-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-SPAWN-PROTECTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY HEARTSTATE.
 01 WS-SALT                BINARY-LONG VALUE 97.
 01 WS-B33                 BINARY-LONG VALUE 33.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW.
     MOVE 0 TO L-ROW
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 5 OR L-ROW > 0
         CALL "XP-RANDOM" USING WS-SALT WS-B33 WS-DRAW
         COMPUTE WS-DX = WS-DRAW - 16
         CALL "XP-RANDOM" USING WS-SALT WS-B33 WS-DRAW
         COMPUTE WS-DZ = WS-DRAW - 16
         COMPUTE WS-CX = HT-X(L-SLOT) + WS-DX
         COMPUTE WS-CZ = HT-Z(L-SLOT) + WS-DZ
*>       The floor search: from 8 above the heart, the cursor goes down one block a step for 17 steps; the cell above the cursor must be empty and the cursor's block a solid cube that is not leaves.
         COMPUTE WS-CY = HT-Y(L-SLOT) + 8
         CALL "WORLD-GET-BLOCK" USING HT-DIM(L-SLOT) WS-CX WS-CY WS-CZ WS-STATE
         CALL "CRK-STATE-SOLID" USING WS-STATE WS-ABOVE WS-LEAVES
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-K FROM 8 BY -1 UNTIL WS-K < -8 OR WS-FOUND = 1
             COMPUTE WS-CY = WS-CY - 1
             CALL "WORLD-GET-BLOCK" USING HT-DIM(L-SLOT) WS-CX WS-CY WS-CZ WS-STATE
             CALL "CRK-STATE-SOLID" USING WS-STATE WS-SOLID WS-LEAVES
             IF WS-ABOVE = 0 AND WS-SOLID = 1 AND WS-LEAVES = 0
                 MOVE 1 TO WS-FOUND
             ELSE
                 MOVE WS-SOLID TO WS-ABOVE
             END-IF
         END-PERFORM
         IF WS-FOUND = 1
*>           The candidate is the block above the cursor; the creaking (0.9 x 2.7) needs that cell and the two above it free.
             MOVE 1 TO WS-ROOM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-Y1 = WS-CY + WS-I
                 CALL "WORLD-GET-BLOCK" USING HT-DIM(L-SLOT) WS-CX WS-Y1 WS-CZ WS-STATE
                 CALL "CRK-STATE-SOLID" USING WS-STATE WS-SOLID WS-LEAVES
                 IF WS-SOLID = 1
                     MOVE 0 TO WS-ROOM
                 END-IF
             END-PERFORM
             IF WS-ROOM = 1
                 COMPUTE WS-X = WS-CX + 0.5
                 COMPUTE WS-Y = WS-CY + 1
                 COMPUTE WS-Z = WS-CZ + 0.5
                 CALL "MOB-SPAWN" USING HT-DIM(L-SLOT) WS-TYPE WS-X WS-Y WS-Z WS-YAW L-ROW
                 IF L-ROW > 0
                     CALL "CREAKING-BIND" USING L-ROW HT-X(L-SLOT) HT-Y(L-SLOT) HT-Z(L-SLOT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HEART-SPAWN-PROTECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HEARTSTATE.
 COPY CREAKSTATE.
 COPY BRWORLD.
 01 WS-SALT                BINARY-LONG VALUE 98.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-LINK                BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-STUCK               BINARY-LONG VALUE 0.
 01 WS-P                   BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-SPAWNED             BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-SLOT                 BINARY-LONG.
 01 L-LOGS                 BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-PERSISTENT           BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-LOGS L-TIME L-PERSISTENT.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     ADD 1 TO HT-AGE(L-SLOT)
*>   The ticker: the body runs when its value before the decrement was below 0 (then it is reset to 20 + nextInt(5)): R + 2 ticks apart.
     MOVE HT-TICKER(L-SLOT) TO WS-PREV
     SUBTRACT 1 FROM HT-TICKER(L-SLOT)
     IF WS-PREV >= 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-DRAW
     COMPUTE HT-TICKER(L-SLOT) = 20 + WS-DRAW
     CALL "CREAKING-ACTIVE-ATTR" USING HT-DIM(L-SLOT) L-TIME WS-ACTIVE
*>   The link: the protector is the creaking of that entity id while it exists; a link whose creaking is gone is cleared after the grace period of 30 ticks.
     MOVE 0 TO WS-CROW
     IF HT-LINK(L-SLOT) > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = HT-LINK(L-SLOT)
                 MOVE WS-E TO WS-CROW
             END-IF
         END-PERFORM
         IF WS-CROW = 0 AND HT-AGE(L-SLOT) >= 30
             MOVE 0 TO HT-LINK(L-SLOT)
         END-IF
     END-IF
     MOVE 0 TO WS-LINK
     IF HT-LINK(L-SLOT) > 0
         MOVE 1 TO WS-LINK
     END-IF
     CALL "BE5-HEART-ENTITY-STATE" USING L-LOGS WS-LINK WS-ACTIVE WS-NEW
     MOVE WS-NEW TO HT-STATE(L-SLOT)
     IF WS-NEW = 0
         GOBACK
     END-IF
     IF WS-LINK = 1
         IF WS-CROW > 0
             COMPUTE WS-HX = HT-X(L-SLOT) + 0.5
             COMPUTE WS-HZ = HT-Z(L-SLOT) + 0.5
             COMPUTE WS-DIST = FUNCTION SQRT((EN-X(WS-CROW) - WS-HX) ** 2 + (EN-Y(WS-CROW) - HT-Y(L-SLOT)) ** 2 + (EN-Z(WS-CROW) - WS-HZ) ** 2)
             CALL "BE5-HEART-DROP" USING WS-ACTIVE L-PERSISTENT WS-DIST WS-STUCK WS-DROP
             IF WS-DROP = 1
                 CALL "CREAKING-TEAR-DOWN" USING WS-CROW
                 MOVE 0 TO HT-LINK(L-SLOT)
             END-IF
         END-IF
         GOBACK
     END-IF
     IF HT-STATE(L-SLOT) NOT = 2
         GOBACK
     END-IF
*>   No link, AWAKE: monsters allowed, not Peaceful, a player (a creative one counts, a spectator does not) within 32 blocks.
     CALL "BR-WORLD-READY"
     MOVE 0 TO WS-NEAR
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = HT-DIM(L-SLOT) AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-D2 = (PL-X(WS-P) - HT-X(L-SLOT) - 0.5) ** 2 + (PL-Y(WS-P) - HT-Y(L-SLOT)) ** 2 + (PL-Z(WS-P) - HT-Z(L-SLOT) - 0.5) ** 2
             IF WS-D2 < 1024
                 MOVE 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM
     IF CS-HOSTILE-MOBS = 1 AND BW-DIFFICULTY NOT = 0 AND WS-NEAR = 1
         CALL "HEART-SPAWN-PROTECTOR" USING L-SLOT WS-SPAWNED
         IF WS-SPAWNED > 0
             MOVE EN-ID(WS-SPAWNED) TO HT-LINK(L-SLOT)
             MOVE 0 TO HT-AGE(L-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HEART-TICK.
