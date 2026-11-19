*> Implementation test, lane bugsleep: the villager-in-bed programs of core/src/sleep-vil.cob. VSLEEP-HEAD names the head half of a claimed bed (a foot claim goes one step along the facing, a
*> lone half is its own bed) and refuses an occupied one; VSLEEP-KICK wakes only the villagers asleep in that very bed (none: 0); a villager removed while it sleeps frees its bed (VSLEEP-GONE);
*> a villager whose bed is occupied does not go to sleep in it (22.8), and does once it is free. A bed facing south: foot at (x, y, z - 1), head at (x, y, z).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VSLEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY VILSTATE.
 COPY CONTENT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STONE               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-HEAD-BUSY           BINARY-LONG.
 01 WS-FOOT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KICKED              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PROP-OCCUPIED       PIC X(24) VALUE "occupied".
 01 WS-PROP-TEXT           PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-VKEY                PIC X(112).
 01 WS-VTYPE               BINARY-LONG.
 01 WS-VROW                PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FAKE-ID             BINARY-LONG VALUE 9999.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZF                 FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=south,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEAD
     MOVE "facing=south,occupied=true,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEAD-BUSY
     MOVE "facing=south,occupied=false,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FOOT
     COMPUTE WS-HX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-HY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-HZ = FUNCTION INTEGER(PL-Z(WS-ROW)) + 4
     COMPUTE WS-FZ = WS-HZ - 1
     COMPUTE WS-UP = WS-HY + 1
     COMPUTE WS-DOWN = WS-HY - 1
     MOVE "N" TO TL-MODE
     PERFORM BUILD-AREA

*>   The head half of a claim.
     CALL "VSLEEP-HEAD" USING WS-DIM WS-HX WS-HY WS-FZ WS-OX WS-OY WS-OZ WS-OK
     MOVE "vsleep: the claim of the foot half names the head half (z + 1)" TO TL-CASE
     MOVE WS-HZ TO TL-EXPECTED-N
     MOVE WS-OZ TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "vsleep: a free bed is ok" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "VSLEEP-HEAD" USING WS-DIM WS-HX WS-HY WS-HZ WS-OX WS-OY WS-OZ WS-OK
     MOVE "vsleep: the claim of the head half is the head half" TO TL-CASE
     MOVE WS-HZ TO TL-EXPECTED-N
     MOVE WS-OZ TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-AIR
     CALL "VSLEEP-HEAD" USING WS-DIM WS-HX WS-HY WS-FZ WS-OX WS-OY WS-OZ WS-OK
     MOVE "vsleep: a lone foot half (the head half is gone) is its own bed" TO TL-CASE
     MOVE WS-FZ TO TL-EXPECTED-N
     MOVE WS-OZ TO TL-OBSERVED-N
     PERFORM CHECK
     PERFORM BUILD-AREA
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEAD-BUSY
     CALL "VSLEEP-HEAD" USING WS-DIM WS-HX WS-HY WS-FZ WS-OX WS-OY WS-OZ WS-OK
     MOVE "vsleep: a bed whose head half is occupied is refused (ok 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK

*>   Kicking: nobody sleeps there: 0; a stale entry (a sleeper whose entity is gone) is not kicked either.
     PERFORM BUILD-AREA
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: nobody sleeps in the bed, nobody is kicked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "VL-FIND" USING WS-FAKE-ID WS-ONE WS-S2
     MOVE 1 TO VL-SLEEP(WS-S2)
     MOVE WS-HX TO VL-BED-X(WS-S2)
     MOVE WS-HY TO VL-BED-Y(WS-S2)
     MOVE WS-HZ TO VL-BED-Z(WS-S2)
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: a sleeper whose entity is gone is not kicked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     INITIALIZE VL-ENTRY(WS-S2)

*>   A villager removed while it sleeps frees its bed.
     MOVE "villager" TO WS-VKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-VKEY WS-VTYPE WS-VROW WS-STATUS
     COMPUTE WS-FX = WS-HX + 0.5
     MOVE WS-HY TO WS-FY
     COMPUTE WS-FZF = WS-HZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-FX WS-FY WS-FZF WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     MOVE 1 TO VL-SLEEP(WS-S1)
     CALL "VSLEEP-START" USING WS-V1 WS-HX WS-HY WS-HZ
     PERFORM READ-OCCUPIED
     MOVE "vsleep: a villager lying down occupies the bed" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-V1
     PERFORM READ-OCCUPIED
     MOVE "vsleep: removing the sleeping villager frees the bed" TO TL-CASE
     MOVE "false" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     STOP RUN.

 READ-OCCUPIED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-STATE
     CALL "PS-GET" USING WS-STATE WS-PROP-OCCUPIED WS-PROP-TEXT WS-FOUND.

*> The area x - 2 to x + 2, z - 3 to z + 2: stone floor, air at the feet and the head, the whole bed (foot at z - 1, head at z) in the middle.
 BUILD-AREA.
     PERFORM VARYING WS-X FROM -2 BY 1 UNTIL WS-X > 2
         PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 2
             COMPUTE WS-GX = WS-HX + WS-X
             COMPUTE WS-GZ = WS-HZ + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GX WS-DOWN WS-GZ WS-STONE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GX WS-HY WS-GZ WS-AIR
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GX WS-UP WS-GZ WS-AIR
         END-PERFORM
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEAD
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-FZ WS-FOOT.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-VSLEEP.
 COPY CORETEST.
 COPY BETEST.
