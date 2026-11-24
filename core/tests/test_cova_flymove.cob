*> Implementation test (coverage lane A; docs/protocol/18 FlyingMoveControl; core/src/mob-44-f.cob): a flying mob given a speed modifier of 0 uses 1.0, and one that flies into walls east and
*> south loses that velocity (each axis stops at a solid cell) and stays where it is.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-FLYMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BEE                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 20.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-MOD                 FLOAT-LONG VALUE 0.
 01 WS-TURN                FLOAT-LONG VALUE 90.
 01 WS-YAWF                FLOAT-SHORT VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FLIER               BINARY-LONG.
 01 WS-PARROT              BINARY-LONG.
 01 WS-YAWP                FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-KIND1
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = WS-X0 + 10
     COMPUTE WS-BZ = WS-Z0 + 10
     COMPUTE WS-BY = WS-FLOOR + 2
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BEE
     COMPUTE WS-BX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BX = WS-BX - 1
     COMPUTE WS-BZ = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE WS-X TO EN-X(WS-BEE)
     MOVE WS-Y TO EN-Y(WS-BEE)
     MOVE WS-Z TO EN-Z(WS-BEE)
     MOVE 0.6 TO EN-VX(WS-BEE)
     MOVE 0.6 TO EN-VZ(WS-BEE)
     MOVE 0 TO EN-VY(WS-BEE)
     COMPUTE WS-WX = WS-X + 10
     MOVE WS-Y TO WS-WY
     COMPUTE WS-WZ = WS-Z + 10
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "test cova flymove flying into walls east and south stops both velocities" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = (FUNCTION ABS(EN-VX(WS-BEE)) + FUNCTION ABS(EN-VZ(WS-BEE))) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova flymove and the mob stays in its cell column (x mm)" TO WS-CASE
     COMPUTE WS-E ROUNDED = WS-X * 1000
     COMPUTE WS-O ROUNDED = EN-X(WS-BEE) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A parrot is a flying mob (the max turn 10 is its own).
     MOVE "minecraft:parrot" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 3.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PARROT
     CALL "M44-FLY-TICK" USING WS-PARROT WS-YAWP WS-FLIER
     MOVE "test cova flymove a parrot is moved by the flying control" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLIER TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-FLYMOVE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
