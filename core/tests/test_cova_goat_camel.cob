*> Implementation test (coverage lane A; docs/protocol/44 part 4 section 9, 54 section 6.4; core/src/mob-44-c.cob, mob-44-o.cob): a baby goat's ram hurts the player (damage 1), and a leashed camel
*> never sits down over many ticks of its random sitting brain.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-GOAT-CAMEL.
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
 01 WS-GOAT                BINARY-LONG.
 01 WS-CAMEL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-SAT                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HEALTH0             FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "minecraft:goat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-GZ = WS-Z - 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-GZ WS-YAW WS-GOAT
     MOVE 1 TO EN-VARIANT(WS-GOAT)
     MOVE 1 TO EN-ON-GROUND(WS-GOAT)
     MOVE 0 TO EN-RAM-CD(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     PERFORM 20 TIMES
         CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     END-PERFORM
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     COMPUTE EN-Z(WS-GOAT) = WS-Z - 0.5
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK
     MOVE "test cova goat camel a ramming baby goat hurts the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "minecraft:camel" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-CAMEL
     MOVE 1 TO EN-LEASH(WS-CAMEL)
     MOVE 0 TO WS-SAT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         CALL "M44-CAMEL-BRAIN" USING WS-CAMEL
         IF EN-CAMEL-POSE(WS-CAMEL) NOT = 0
             MOVE 1 TO WS-SAT
         END-IF
     END-PERFORM
     MOVE "test cova goat camel a leashed camel never sits down" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SAT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-GOAT-CAMEL.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
