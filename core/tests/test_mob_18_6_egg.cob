*> Implementation test (002-lane-mobsfull-h19; docs/protocol/18 section 6.12 spawn eggs, 25-6 spawn egg items): a spawn egg used on a block (TOOLUSE-ON, core/src/mob-egg.cob)
*> creates the standard mob of its species in the free cell beside the clicked face (cell centre, feet at the cell's bottom), is finalized like a spawned mob, uses one egg up
*> unless the player is in creative mode, and does nothing for a species without a mob row.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-EGG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BESTATE.
 COPY PLAYPKT.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-BE                 BINARY-LONG.
 01 WS-SPAWNER-STATE       BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-HELD(WS-PLAYER) TO WS-HELD
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 3
     MOVE WS-FY TO WS-BY
     MOVE FUNCTION INTEGER(WS-Z) TO WS-BZ
     MOVE 0 TO PSB-HAND
     MOVE WS-BX TO PSB-BX
     MOVE WS-BY TO PSB-BY
     MOVE WS-BZ TO PSB-BZ
     MOVE 1 TO PSB-FACE

*>   A cow spawn egg on the top face of the floor: a cow stands in the cell above, at its centre.
     MOVE "minecraft:cow_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-COW
     MOVE "acceptance US15 18§6.12 a cow spawn egg on a block creates a cow" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the egg use is handled" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the mob stands at the cell centre (x, tenths)" TO WS-CASE
     COMPUTE WS-EXP = WS-BX * 10 + 5
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-X(WS-FOUND) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the mob's feet are at the bottom of the cell above the block" TO WS-CASE
     COMPUTE WS-EXP = WS-BY + 1
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-Y(WS-FOUND) + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the mob has full health" TO WS-CASE
     MOVE 10 TO WS-EXP
     MOVE EN-HEALTH(WS-FOUND) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 an egg is used up in survival" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FOUND
*>   Creative mode keeps the egg; a side face puts the mob beside the block.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 3 TO PSB-FACE
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM FIND-COW
     MOVE "acceptance US15 18§6.12 on the south face the mob stands one cell south (z)" TO WS-CASE
     COMPUTE WS-EXP = WS-BZ + 1
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-Z(WS-FOUND))
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 creative mode keeps the egg" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FOUND
*>   The other faces: down (y - 1), north (z - 1), west (x - 1), east (x + 1).
     MOVE "minecraft:cow_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
         EVALUATE WS-J
             WHEN 1
                 MOVE 0 TO PSB-FACE
                 COMPUTE WS-EXP = WS-BY - 1
             WHEN 2
                 MOVE 2 TO PSB-FACE
                 COMPUTE WS-EXP = WS-BZ - 1
             WHEN 3
                 MOVE 4 TO PSB-FACE
                 COMPUTE WS-EXP = WS-BX - 1
             WHEN OTHER
                 MOVE 5 TO PSB-FACE
                 COMPUTE WS-EXP = WS-BX + 1
         END-EVALUATE
         CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
         PERFORM FIND-COW
         MOVE "acceptance US15 18§6.12 the face picks the cell beside the block" TO WS-CASE
         EVALUATE WS-J
             WHEN 1
                 COMPUTE WS-OBS = FUNCTION INTEGER(EN-Y(WS-FOUND) + 0.5)
             WHEN 2
                 COMPUTE WS-OBS = FUNCTION INTEGER(EN-Z(WS-FOUND))
             WHEN OTHER
                 COMPUTE WS-OBS = FUNCTION INTEGER(EN-X(WS-FOUND))
         END-EVALUATE
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         CALL "ENTITY-REMOVE" USING WS-FOUND
     END-PERFORM
*>   A zombie egg makes a zombie (a table mob that is finalized).
     MOVE "minecraft:zombie_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 1 TO PSB-FACE
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ZOMBIE-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.12 a zombie spawn egg creates a zombie" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A species without a mob row (breeze; the villager has a row since T7102) does nothing and the egg stays.
     MOVE "minecraft:breeze_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE EN-COUNT TO WS-COUNT
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US15 18§6.12 a species without a mob row is not spawned" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the egg of such a species stays in the stack" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A cow egg on a mob spawner block sets its species and is used up; no cow appears.
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SPAWNER-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SPAWNER-STATE
     MOVE "minecraft:cow_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "TOOLUSE-ON" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     PERFORM FIND-COW
     MOVE "acceptance US15 18§6.12 a spawn egg on a mob spawner sets its species (cow)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-BE > 0 AND BE-XT(WS-BE, 1) = "minecraft:cow"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 a spawn egg on a mob spawner spawns no mob" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 18§6.12 the egg used on a spawner is used up" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD + 1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 FIND-COW.
     MOVE 0 TO WS-COUNT WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-COW-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-EGG.

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
 COPY CORETEST.
 COPY MOBSPTEST.
