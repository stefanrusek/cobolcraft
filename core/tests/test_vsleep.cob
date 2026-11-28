*> Implementation test, lane bugsleep: the villager-in-bed programs of core/src/sleep-vil.cob on the villager state of main (the bed is the home claim, VPX-OF kind 2, the head half).
*> VSLEEP-KICK wakes only the villagers asleep in that very bed (none: 0; a sleeper whose entity is gone: 0); VSLEEP-WAKE frees the bed, stands the villager beside it, records the waking
*> tick and holds off the next sleep for 40 ticks, and does nothing for a villager that is awake. A bed facing south: foot at (x, y, z - 1), head at (x, y, z).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VSLEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-OTHER-Z             BINARY-LONG.
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
*>   Kicking: nobody sleeps there: 0; a stale entry (a sleeper whose entity is gone) is not kicked either.
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: nobody sleeps in the bed, nobody is kicked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "VL-FIND" USING WS-FAKE-ID WS-ONE WS-S2
     MOVE 1 TO VL-SLEEP(WS-S2)
     CALL "VPX-CLAIM" USING WS-FAKE-ID WS-HOME WS-DIM WS-HX WS-HY WS-HZ
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: a sleeper whose entity is gone is not kicked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "VL-REMOVE" USING WS-FAKE-ID

*>   A villager asleep in its claimed bed.
     MOVE "villager" TO WS-VKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-VKEY WS-VTYPE WS-VROW WS-STATUS
     COMPUTE WS-FX = WS-HX + 0.5
     MOVE WS-HY TO WS-FY
     COMPUTE WS-FZF = WS-HZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-FX WS-FY WS-FZF WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     CALL "VPX-CLAIM" USING EN-ID(WS-V1) WS-HOME WS-DIM WS-HX WS-HY WS-HZ
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: an awake villager that owns the bed is not kicked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE 1 TO VL-SLEEP(WS-S1)
     CALL "VL-BED-OCCUPY" USING EN-ID(WS-V1) WS-ONE
     PERFORM READ-OCCUPIED
     MOVE "vsleep: the sleeping villager occupies the bed" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     COMPUTE WS-OTHER-Z = WS-HZ + 1
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-OTHER-Z WS-KICKED
     MOVE "vsleep: another bed's kick leaves the sleeper alone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "VSLEEP-KICK" USING WS-DIM WS-HX WS-HY WS-HZ WS-KICKED
     MOVE "vsleep: the sleeper in that bed is kicked out" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-KICKED TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "vsleep: the kicked villager is awake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "vsleep: the waking tick is recorded" TO TL-CASE
     MOVE CW-TICKS TO TL-EXPECTED-N
     MOVE VL-LAST-WOKEN(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "vsleep: no new sleep for 40 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 40
     MOVE VM-T(WS-S1, TM-SLEEP-OK) TO TL-OBSERVED-N
     PERFORM CHECK
     PERFORM READ-OCCUPIED
     MOVE "vsleep: the bed is free again" TO TL-CASE
     MOVE "false" TO TL-EXPECTED
     MOVE WS-PROP-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     PERFORM CHECK
     MOVE "N" TO TL-MODE
*>   SLEEP-STAND-UP's first free cell is the head's +x neighbour: x + 1.5, the bed's height, z + 0.5.
     MOVE "vsleep: the villager stands beside the bed (x)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-HX + 1.5) * 10
     COMPUTE TL-OBSERVED-N = EN-X(WS-V1) * 10
     PERFORM CHECK
     MOVE "vsleep: the villager stands beside the bed (y)" TO TL-CASE
     MOVE WS-HY TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-Y(WS-V1)
     PERFORM CHECK
     MOVE 77 TO VL-LAST-WOKEN(WS-S1)
     CALL "VSLEEP-WAKE" USING WS-V1 WS-S1
     MOVE "vsleep: waking an awake villager changes nothing" TO TL-CASE
     MOVE 77 TO TL-EXPECTED-N
     MOVE VL-LAST-WOKEN(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
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
