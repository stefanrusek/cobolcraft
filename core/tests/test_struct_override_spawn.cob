*> Acceptance test of the natural spawner's use of the structure spawn overrides (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8.1 step 2b; core/src/mob-18-6.cob
*> MS6-PACK and core/src/struct-override.cob): on a dark stone floor at night where the biome list gives zombies, spiders and skeletons, a pack started inside a registered fortress piece box
*> is drawn from the fortress list only, and one inside an ancient city's box (every category emptied) makes no mob at all.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-OVERRIDE-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO.
 COPY MOBSPAWN.
 COPY BRWORLD.
 COPY STRUCTOVR.
 01 WS-CASE               PIC X(240).
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-QX                 BINARY-LONG.
 01 WS-QZ                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-CAT                BINARY-LONG VALUE 1.
 01 WS-BIOME              BINARY-LONG.
 01 WS-BIOME-KEY          PIC X(48) VALUE "minecraft:plains".
 01 WS-SPAWNED            BINARY-LONG.
 01 WS-TOTAL              BINARY-LONG.
 01 WS-OTHER              BINARY-LONG.
 01 WS-FLOOR-SIZE         BINARY-LONG VALUE 20.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-BKIND              BINARY-LONG.
 01 WS-X0                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-X1                 BINARY-LONG.
 01 WS-Z1                 BINARY-LONG.
 01 WS-Y0                 BINARY-LONG.
 01 WS-Y1                 BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-T-SKELETON         BINARY-LONG.
 01 WS-T-OTHER1           BINARY-LONG.
 01 WS-T-OTHER2           BINARY-LONG.
 01 WS-T-OTHER3           BINARY-LONG.
 01 WS-T-OTHER4           BINARY-LONG.
 01 WS-DX                BINARY-LONG.
 01 WS-DZ                BINARY-LONG.
 01 WS-RX                BINARY-LONG.
 01 WS-RZ                BINARY-LONG.
 01 WS-E                  BINARY-LONG.
 01 WS-O                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 18000 TO CW-TIME
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-BIOME
     COMPUTE WS-QX = WS-PX + 18
     COMPUTE WS-QZ = WS-PZ - 10
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 28
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     IF WS-QX < 0
         COMPUTE WS-CX = (WS-QX - 15) / 16
     END-IF
     IF WS-QZ < 0
         COMPUTE WS-CZ = (WS-QZ - 15) / 16
     END-IF
     COMPUTE WS-PY = WS-FY + 1
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T-SKELETON WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:magma_cube" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T-OTHER1 WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombified_piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T-OTHER2 WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:wither_skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T-OTHER3 WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:blaze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T-OTHER4 WS-ENTITY-ROW WS-STATUS

*>   control: with no registered box the night packs hold monsters of the biome list (more than skeletons and fortress mobs)
     PERFORM RUN-PACKS
     MOVE "acceptance US15 44-2§8.1 the biome list at night on a stone floor makes monsters, some of them not on the fortress list" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TOTAL > 0 AND WS-OTHER < WS-TOTAL
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   a fortress piece box (kind 1) over the chunk of the floor: only the fortress list's species spawn
     MOVE 1 TO WS-BKIND
     PERFORM REGISTER-AROUND
     PERFORM CLEAR-MOBS
     PERFORM RUN-PACKS
     MOVE "acceptance US15 44-2§8.1 inside a fortress piece box the packs are drawn from the fortress list: some spawn" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TOTAL > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§8.1 and every one of them is of the fortress list (no zombie, spider or creeper of the biome list)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OTHER TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO SO-COUNT SO-NEXT

*>   an ancient city box (kind 5) empties every category
     MOVE 5 TO WS-BKIND
     PERFORM REGISTER-AROUND
     PERFORM CLEAR-MOBS
     PERFORM RUN-PACKS
     MOVE "acceptance US15 44-2§8.1 inside an ancient city's box the monster list is empty: nothing spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-TOTAL TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 REGISTER-AROUND.
*>   the box of kind WS-BKIND over each of the nine chunks around the floor's chunk (a pack's cursor wanders over the borders)
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
             COMPUTE WS-RX = WS-CX + WS-DX
             COMPUTE WS-RZ = WS-CZ + WS-DZ
             COMPUTE WS-X0 = WS-RX * 16
             COMPUTE WS-Z0 = WS-RZ * 16
             COMPUTE WS-X1 = WS-X0 + 15
             COMPUTE WS-Z1 = WS-Z0 + 15
             COMPUTE WS-Y0 = WS-FY - 10
             COMPUTE WS-Y1 = WS-FY + 10
             CALL "SO-REGISTER" USING WS-DIM WS-RX WS-RZ WS-BKIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
         END-PERFORM
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CLEAR-MOBS.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 RUN-PACKS.
     MOVE 0 TO WS-TOTAL WS-OTHER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-BIOME WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-TOTAL
     END-PERFORM
     MOVE 0 TO WS-OTHER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             IF EN-TYPE(WS-ROW) NOT = WS-T-SKELETON AND EN-TYPE(WS-ROW) NOT = WS-T-OTHER1 AND EN-TYPE(WS-ROW) NOT = WS-T-OTHER2
                     AND EN-TYPE(WS-ROW) NOT = WS-T-OTHER3 AND EN-TYPE(WS-ROW) NOT = WS-T-OTHER4
                 ADD 1 TO WS-OTHER
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STRUCT-OVERRIDE-SPAWN.
 COPY CORETEST.
 COPY MOBSPTEST.
