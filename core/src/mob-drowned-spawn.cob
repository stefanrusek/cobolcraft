*> The drowned jockey of a natural spawn (wrap I2 round 6, T24090; docs/protocol/20-mobs-overworld-hostile.md section 4.5, the finalizeSpawn rule, with 44-7 section 10.1): a drowned with a trident in
*> the main hand (its default equipment, rolled by DROWNED-EQUIP-ROLL in STDMOB-FINALIZE: nextFloat > 0.9, then nextInt(16) < 10 a trident, else a fishing rod), nextFloat < 0.5, not a baby and in a biome
*> that is not in the tag more_frequent_drowned_spawns (the rivers) carries a zombie_nautilus (spawn reason JOCKEY) created at the same position (MOB-MOUNT).
*>   DROWNED-JOCKEY-OK USING trident (1 when the main hand holds the trident), draw (FLOAT-LONG nextFloat), baby, frequent biome, ok out    1 when the drowned carries a zombie nautilus
*>   DROWNED-FINALIZE USING xoro state, tracker row   called by MS6-PACK-EXTRA for every natural drowned, after STDMOB-FINALIZE
*> Not built (recorded on T24090): the nautilus shell of the off hand (nextFloat < 0.03; the mob rows keep no off-hand slot), the baby roll of the zombie finalize (the engine does not roll it for the drowned),
*> the STRUCTURE reason (the drowned of an ocean ruin is made by the entity channel of the generator, not finalized here) and the persistence it requires.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DROWNED-JOCKEY-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TRIDENT               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-FREQUENT             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIDENT L-DRAW L-BABY L-FREQUENT L-OK.
     MOVE 0 TO L-OK
     IF L-TRIDENT = 1 AND L-DRAW < 0.5 AND L-BABY = 0 AND L-FREQUENT = 0
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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TRIDENT-KEY         PIC X(24) VALUE "trident".
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
*>   The jockey needs the trident of the default equipment in the main hand.
     CALL "MOB-ITEM-ID" USING WS-TRIDENT-KEY WS-ITEM
     IF EN-HAND(L-ROW) NOT = 1000 + WS-ITEM
         GOBACK
     END-IF
*>   nextFloat < 0.5, not a baby, the biome not in more_frequent_drowned_spawns.
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
     CALL "DROWNED-JOCKEY-OK" USING WS-ONE WS-D WS-BABY WS-FREQUENT WS-OK
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
