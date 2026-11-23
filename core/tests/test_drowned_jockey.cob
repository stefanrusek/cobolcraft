*> Implementation test (wrap I2 round 6, T24090; docs/protocol/20-mobs-overworld-hostile.md section 4.5 "Equipment" and "finalizeSpawn", 20 section 18.3, 44-7 10.1): a naturally spawned drowned
*> gets its default equipment (nextFloat > 0.9: a weapon, nextInt(16) < 10 a trident, else a fishing rod), and a drowned with a trident in the main hand (nextFloat < 0.5, not a baby, the biome not in
*> more_frequent_drowned_spawns) rides a zombie_nautilus created at its position (the drowned jockey). The pure rules are checked with given draws; the whole rule runs over 600 drowned spawned with a
*> fixed seed: every jockey holds a trident, rides a zombie nautilus at its own position and sits at the seat y 1.1375 less the 0.7 riding offset of the zombie family.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DROWNED-JOCKEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 11.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE-D              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VEH                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TRIDENT-KEY         PIC X(24) VALUE "trident".
 01 WS-ROD-KEY             PIC X(24) VALUE "fishing_rod".
 01 WS-TRIDENT             BINARY-LONG.
 01 WS-ROD                 BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-WEAPON              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NO-BABY             BINARY-LONG VALUE 0.
 01 WS-NO-FREQ             BINARY-LONG VALUE 0.
 01 WS-BABY1               BINARY-LONG VALUE 1.
 01 WS-FREQ1               BINARY-LONG VALUE 1.
 01 WS-TRIDENTS            BINARY-LONG.
 01 WS-RODS                BINARY-LONG.
 01 WS-JOCKEYS             BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-VKEY                PIC X(24).
 01 WS-SEAT-KEY-V          PIC X(24) VALUE "zombie_nautilus".
 01 WS-SEAT-KEY-R          PIC X(24) VALUE "drowned".
 01 WS-SEAT-Y              FLOAT-LONG.
 01 WS-SEAT-Z              FLOAT-LONG.
 01 WS-SEAT                BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:drowned" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE-D WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE-N WS-ENTITY-ROW WS-STATUS
     CALL "MOB-ITEM-ID" USING WS-TRIDENT-KEY WS-TRIDENT
     CALL "MOB-ITEM-ID" USING WS-ROD-KEY WS-ROD

*>   The seat of a mob rider on a zombie nautilus: the attachment y 1.1375 less the zombie family's riding offset 0.7.
     CALL "MOB-MOUNT-SEAT" USING WS-SEAT-KEY-V WS-SEAT-KEY-R WS-SEAT-Y WS-SEAT-Z WS-SEAT
     MOVE "implementation 20 4.5 a zombie nautilus takes a mob rider" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-SEAT TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 18 1.1.1 the drowned's seat is y 1.1375 - 0.7 = 0.4375" TO WS-CASE
     MOVE 4375 TO WS-EXPECT
     COMPUTE WS-OBSERVE ROUNDED = WS-SEAT-Y * 10000
     PERFORM CHECK

*>   The default weapon (populateDefaultEquipmentSlots): nextFloat > 0.9, then nextInt(16) < 10 a trident, else a fishing rod.
     MOVE 0.95 TO WS-DRAW
     MOVE 9 TO WS-PICK
     CALL "DROWNED-WEAPON" USING WS-DRAW WS-PICK WS-WEAPON
     MOVE "implementation 20 4.5 draw above 0.9 and pick 9 of 16: a trident" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-WEAPON TO WS-OBSERVE
     PERFORM CHECK
     MOVE 10 TO WS-PICK
     CALL "DROWNED-WEAPON" USING WS-DRAW WS-PICK WS-WEAPON
     MOVE "implementation 20 4.5 pick 10 of 16: a fishing rod" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-WEAPON TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0.9 TO WS-DRAW
     CALL "DROWNED-WEAPON" USING WS-DRAW WS-PICK WS-WEAPON
     MOVE "implementation 20 4.5 the draw 0.9 is not above 0.9: no weapon" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WEAPON TO WS-OBSERVE
     PERFORM CHECK

*>   The jockey test: a trident, nextFloat < 0.5, not a baby, the biome not in more_frequent_drowned_spawns.
     MOVE 0.49 TO WS-DRAW
     CALL "DROWNED-JOCKEY-OK" USING WS-ONE WS-DRAW WS-NO-BABY WS-NO-FREQ WS-OK
     MOVE "implementation 20 4.5 trident, draw 0.49, adult, ordinary biome: a jockey" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0.5 TO WS-DRAW
     CALL "DROWNED-JOCKEY-OK" USING WS-ONE WS-DRAW WS-NO-BABY WS-NO-FREQ WS-OK
     MOVE "implementation 20 4.5 the draw 0.5 is not below 0.5: no jockey" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0.1 TO WS-DRAW
     CALL "DROWNED-JOCKEY-OK" USING WS-ZERO WS-DRAW WS-NO-BABY WS-NO-FREQ WS-OK
     MOVE "implementation 20 4.5 without a trident (a fishing rod or nothing) no jockey" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     CALL "DROWNED-JOCKEY-OK" USING WS-ONE WS-DRAW WS-BABY1 WS-NO-FREQ WS-OK
     MOVE "implementation 20 4.5 a baby drowned carries no nautilus" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     CALL "DROWNED-JOCKEY-OK" USING WS-ONE WS-DRAW WS-NO-BABY WS-FREQ1 WS-OK
     MOVE "implementation 20 4.5 in a more_frequent_drowned_spawns biome (rivers) no jockey" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK

*>   The whole rule: 600 drowned of a natural spawn with a fixed seed (MS6-PACK-EXTRA is the natural spawn's hook, DROWNED-FINALIZE the rule).
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-TRIDENTS WS-RODS WS-JOCKEYS WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE-D WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "MS6-PACK-EXTRA" USING XR-STATE WS-ROW WS-ZERO
         IF EN-HAND(WS-ROW) = 1000 + WS-TRIDENT
             ADD 1 TO WS-TRIDENTS
         END-IF
         IF EN-HAND(WS-ROW) = 1000 + WS-ROD
             ADD 1 TO WS-RODS
         END-IF
         IF EN-MOUNT(WS-ROW) > 0
             ADD 1 TO WS-JOCKEYS
             MOVE EN-MOUNT(WS-ROW) TO WS-VEH
             CALL "MOB-SPECIES-KEY" USING WS-VEH WS-VKEY
             IF EN-HAND(WS-ROW) NOT = 1000 + WS-TRIDENT OR WS-VKEY NOT = "zombie_nautilus" OR EN-PASS(WS-VEH) NOT = WS-ROW
                     OR EN-X(WS-VEH) NOT = EN-X(WS-ROW) OR EN-Z(WS-VEH) NOT = EN-Z(WS-ROW)
                 ADD 1 TO WS-BAD
             END-IF
             CALL "ENTITY-REMOVE" USING WS-VEH
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "implementation 20 4.5 about 6 percent of 600 drowned hold a trident (between 20 and 60)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-TRIDENTS >= 20 AND WS-TRIDENTS <= 60
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 20 4.5 about 3.75 percent hold a fishing rod (between 8 and 40)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-RODS >= 8 AND WS-RODS <= 40
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 20 4.5 about half of the trident holders ride a zombie nautilus (between 3 and 40)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-JOCKEYS >= 3 AND WS-JOCKEYS <= 40
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 20 4.5 every jockey holds a trident and rides a zombie nautilus at its own position" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-BAD TO WS-OBSERVE
     PERFORM CHECK
     STOP RUN.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-DROWNED-JOCKEY.
 COPY CORETEST.
 COPY MOBSPTEST.
