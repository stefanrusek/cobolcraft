*> The finalizeSpawn of a drowned of a natural spawn (wrap I2 round 6, T24090; docs/protocol/20-mobs-overworld-hostile.md section 4.5, "Equipment" and the jockey rule, with 44-7 section 10.1): the default
*> equipment (populateDefaultEquipmentSlots: nextFloat > 0.9 gives a weapon, nextInt(16) < 10 a trident, else a fishing rod) and the drowned jockey: with a trident in the main hand, nextFloat < 0.5, not a baby
*> and the biome not in the tag more_frequent_drowned_spawns (the rivers) a zombie_nautilus (spawn reason JOCKEY) is created at the same position and carries the drowned (MOB-MOUNT).
*>   DROWNED-WEAPON USING draw (FLOAT-LONG nextFloat), pick (nextInt(16)), weapon out    0 none, 1 trident, 2 fishing rod
*>   DROWNED-JOCKEY-OK USING weapon, draw (FLOAT-LONG nextFloat), baby, frequent biome, ok out    1 when the drowned carries a zombie nautilus (the weapon must be the trident, 1)
*>   DROWNED-FINALIZE USING xoro state, tracker row   called by MS6-PACK-EXTRA for every natural drowned
*> Not built (recorded on T24090): the nautilus shell of the off hand (nextFloat < 0.03; the mob rows keep no off-hand slot), the baby roll of the zombie finalize (the engine does not roll it for the drowned),
*> the STRUCTURE reason (the drowned of an ocean ruin is made by the entity channel of the generator, not finalized here) and the persistence it requires.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-WEAPON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PICK                 BINARY-LONG.
 01 L-WEAPON               BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PICK L-WEAPON.
     MOVE 0 TO L-WEAPON
     IF L-DRAW > 0.9
         MOVE 2 TO L-WEAPON
         IF L-PICK < 10
             MOVE 1 TO L-WEAPON
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DROWNED-WEAPON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-JOCKEY-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-WEAPON               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-FREQUENT             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WEAPON L-DRAW L-BABY L-FREQUENT L-OK.
     MOVE 0 TO L-OK
     IF L-WEAPON = 1 AND L-DRAW < 0.5 AND L-BABY = 0 AND L-FREQUENT = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM DROWNED-JOCKEY-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-FINALIZE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-D                   FLOAT-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-WEAPON              BINARY-LONG.
 01 WS-TRIDENT-KEY         PIC X(24) VALUE "trident".
 01 WS-ROD-KEY             PIC X(24) VALUE "fishing_rod".
 01 WS-ITEM                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-FREQUENT            BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TREG                PIC X(48) VALUE "worldgen/biome".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:more_frequent_drowned_spawns".
 01 WS-KEY                 PIC X(112) VALUE "minecraft:zombie_nautilus".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
*>   populateDefaultEquipmentSlots: the weapon draw, then the pick only when a weapon is given.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     MOVE 0 TO WS-PICK
     IF WS-D > 0.9
         CALL "XORO-NEXT-INT" USING L-STATE WS-SIXTEEN WS-PICK
     END-IF
     CALL "DROWNED-WEAPON" USING WS-D WS-PICK WS-WEAPON
     IF WS-WEAPON = 0
         GOBACK
     END-IF
     IF WS-WEAPON = 1
         CALL "MOB-ITEM-ID" USING WS-TRIDENT-KEY WS-ITEM
     ELSE
         CALL "MOB-ITEM-ID" USING WS-ROD-KEY WS-ITEM
     END-IF
     COMPUTE EN-HAND(L-ROW) = 1000 + WS-ITEM
     CALL "STDMOB-EQUIP-SEND" USING L-ROW
     IF WS-WEAPON = 2
         GOBACK
     END-IF
*>   The jockey: a trident in the main hand, nextFloat < 0.5, not a baby, the biome not in more_frequent_drowned_spawns.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-FREQUENT
     CALL "MS6-BIOME-ID-AT" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-BIOME
     IF WS-BIOME >= 0
         CALL "CONTENT-TAG-HAS" USING WS-TREG WS-TTAG WS-BIOME WS-FREQUENT
     END-IF
     MOVE EN-VARIANT(L-ROW) TO WS-BABY
     CALL "DROWNED-JOCKEY-OK" USING WS-WEAPON WS-D WS-BABY WS-FREQUENT WS-OK
     IF WS-OK = 1
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE EN-YAW(L-ROW) TO WS-YAW
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NAUTILUS
         CALL "STDMOB-FINALIZE" USING L-STATE WS-NAUTILUS
         CALL "MOB-MOUNT" USING L-ROW WS-NAUTILUS WS-MOUNTED
     END-IF
     GOBACK.
 END PROGRAM DROWNED-FINALIZE.
