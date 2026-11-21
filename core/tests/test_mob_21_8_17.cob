*> Ominous item spawner (docs/protocol/21 section 8.17, 44-2 section 4.6, 30-4 section 4.1; lane p49f, T21300): the viewer is sent Add Entity and metadata 8 (the item stack); the spawner lives
*> spawn_item_after_ticks = 60 to 120 ticks; at tickCount >= spawnAfter an ordinary item becomes an item entity at its position, a projectile item is launched downward with its dispense power and
*> uncertainty (owner = the spawner); then level event 3021 with data 1, and the spawner is gone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-17.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY CITEMS.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-SNOWBALL            BINARY-LONG.
 01 WS-BOTTLE              BINARY-LONG.
 01 WS-EGG                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EXPECT              PIC X(300).
 01 WS-ID                  PIC Z(8)9.
 01 WS-IDN                 BINARY-LONG.
 01 WS-SROW                BINARY-LONG.
 01 WS-SAVE-SET            BINARY-LONG.
 01 WS-FILL-ID             BINARY-LONG.
 01 WS-FILL-KIND           BINARY-LONG VALUE 1.
 01 WS-FILL-SLOT           BINARY-LONG.
 01 WS-EGG-ROW             BINARY-LONG.
 01 WS-ITEM-N              PIC Z(8)9.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ITEM-ROW-N          BINARY-LONG.
 01 WS-SPAWN-AFTER         BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIAMOND WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:snowball" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SNOWBALL WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:experience_bottle" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BOTTLE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EGG WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 20
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE 1 TO WS-COUNT
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-COUNT WS-ROW
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the spawner is a tracker row" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-ROW > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE EN-ID(WS-ROW) TO WS-ID WS-IDN
     MOVE WS-DIAMOND TO WS-ITEM-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";8=S" FUNCTION TRIM(WS-ITEM-N) "x1)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 Add Entity then metadata 8 = the item stack" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 spawn_item_after_ticks is at least 60" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PJ-I1(WS-SLOT) >= 60 AND PJ-I1(WS-SLOT) <= 120
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW
*>   nextIntBetween(60, 120) covers the inclusive range over many spawners.
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-COUNT WS-ROW
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
         IF PJ-I1(WS-SLOT) < WS-MIN
             MOVE PJ-I1(WS-SLOT) TO WS-MIN
         END-IF
         IF PJ-I1(WS-SLOT) > WS-MAX
             MOVE PJ-I1(WS-SLOT) TO WS-MAX
         END-IF
         CALL "PJ-DROP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 120 spawners: all lifetimes within 60 to 120" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MIN >= 60 AND WS-MAX <= 120
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 120 spawners: the lifetimes vary (more than 40 values apart)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX - WS-MIN > 40
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   An ordinary item: nothing before tickCount reaches spawnAfter, then an item entity at the spawner's position.
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-COUNT WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 70 TO PJ-I1(WS-SLOT)
     MOVE EN-ID(WS-ROW) TO WS-ID WS-IDN
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 69
         CALL "THROWN-TICK"
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 at tickCount 69 of 70 no item has appeared" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the spawner is still there at tickCount 69" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     CALL "THROWN-TICK"
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 at tickCount 70 the item entity appears" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the item entity is at the spawner's position (x)" TO WS-CASE
     MOVE PL-X(WS-PLAYER) TO WS-E
     COMPUTE WS-O = EN-X(WS-ITEM-ROW-N)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the spawner is killed after spawning" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "PJ-FIND" USING WS-IDN WS-SLOT
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 its state entry is freed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SLOT TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-O
     INSPECT WS-TEXT TALLYING WS-O FOR ALL " 47"
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the viewer gets level event 3021 (Level Event 0x2F)" TO WS-CASE
     MOVE 1 TO WS-E
     IF WS-O > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ITEM-ROW-N
*>   A snowball is a projectile item: it is launched downward at power 1.1 with uncertainty 6.0.
     MOVE 1 TO WS-COUNT
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SNOWBALL WS-COUNT WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID WS-IDN
     CALL "PJ-FIND" USING WS-IDN WS-SLOT
     MOVE 61 TO PJ-I1(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 61
         CALL "THROWN-TICK"
     END-PERFORM
     PERFORM FIND-OWNED
     MOVE WS-FOUND TO WS-SROW
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 a snowball is launched (a projectile of the spawner)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SROW > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 no item entity for a projectile item" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM COUNT-ITEMS
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 launched down: vy within -1.1 x (1 +- 0.1033) of -1.1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VY(WS-SROW) <= -0.98 AND EN-VY(WS-SROW) >= -1.22
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 horizontal speed within 1.1 x 0.1033 (triangle of 0.0172275 x 6)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(EN-VX(WS-SROW)) <= 0.114 AND FUNCTION ABS(EN-VZ(WS-SROW)) <= 0.114
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 the owner is the spawner" TO WS-CASE
     MOVE WS-IDN TO WS-E
     MOVE EN-TARGET-ID(WS-SROW) TO WS-O
     PERFORM CHECK-N
*>   An egg and an experience bottle are launched too (the bottle at 1.375 with uncertainty 3.0).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TARGET-ID(WS-I) = WS-IDN
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-EGG WS-COUNT WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-IDN
     CALL "PJ-FIND" USING WS-IDN WS-SLOT
     MOVE 60 TO PJ-I1(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "OIS-STEP" USING WS-ROW
     END-PERFORM
     PERFORM FIND-OWNED
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 an egg is launched downward (vy within 1.1 x 1.1 of -1.1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-FOUND > 0
         IF EN-VY(WS-FOUND) <= -0.98 AND EN-VY(WS-FOUND) >= -1.22
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     MOVE WS-FOUND TO WS-EGG-ROW
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-BOTTLE WS-COUNT WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-IDN
     CALL "PJ-FIND" USING WS-IDN WS-SLOT
     MOVE 60 TO PJ-I1(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "OIS-STEP" USING WS-ROW
     END-PERFORM
     PERFORM FIND-OWNED
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 an experience bottle is launched: vy within -1.375 x (1 +- 0.0517)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-FOUND > 0
         IF EN-VY(WS-FOUND) <= -1.30 AND EN-VY(WS-FOUND) >= -1.45
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
*>   A row without a state entry is ignored.
     CALL "OIS-STEP" USING PL-ENTITY-ROW(WS-PLAYER)
*>   Another content set has no such entity type: no spawner.
     MOVE CT-SET-TYPE TO WS-SAVE-SET
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-COUNT WS-ROW
     MOVE WS-SAVE-SET TO CT-SET-TYPE
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 without the entity type no spawner is made" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     PERFORM CHECK-N
*>   A full state table: no spawner either.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         COMPUTE WS-FILL-ID = 900000 + WS-I
         CALL "PJ-ALLOC" USING WS-FILL-ID WS-FILL-KIND WS-FILL-SLOT
     END-PERFORM
     CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DIAMOND WS-COUNT WS-ROW
     MOVE "acceptance US15 minecraft:ominous_item_spawner 21§8.17 with the state table full no spawner is made" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD 1 TO WS-FOUND
             MOVE WS-I TO WS-ITEM-ROW-N
         END-IF
     END-PERFORM.

 FIND-OWNED.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TARGET-ID(WS-I) = WS-IDN AND WS-I NOT = WS-ROW
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-17.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
