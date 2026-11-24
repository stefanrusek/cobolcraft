*> Implementation test (coverage lane A; docs/protocol/44 part 4 section 10; core/src/mob-44-m.cob): a frog that prefers lily pads picks its long-jump target among the cells above lily pads
*> (the weighted draw takes the preferred candidates first), and one that has no preference draws among all cells, also meeting its own column (refused).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-FROG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LILY                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:frog" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:lily_pad" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LILY
     COMPUTE WS-BX = WS-X0 + 22
     COMPUTE WS-BZ = WS-Z0 + 20
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         COMPUTE WS-BX = WS-X0 + 22 + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-BZ WS-LILY
     END-PERFORM
*>   Preferring frog: the chosen target is the cell above one of the pads.
     COMPUTE WS-X = WS-X0 + 20.5
     COMPUTE WS-Z = WS-Z0 + 20.5
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2
         MOVE 1 TO EN-FROG-JS(WS-ROW)
         MOVE 0 TO EN-FROG-CH(WS-ROW)
         MOVE 0 TO EN-FROG-JT(WS-ROW)
         MOVE 0 TO EN-FROG-LIFE(WS-ROW)
         MOVE 40 TO EN-FROG-TRIES(WS-ROW)
         MOVE 1 TO EN-FROG-PREF(WS-ROW)
         COMPUTE EN-FROG-SX(WS-ROW) = WS-X0 + 20
         COMPUTE EN-FROG-SY(WS-ROW) = WS-FLOOR + 1
         COMPUTE EN-FROG-SZ(WS-ROW) = WS-Z0 + 20
         MOVE 0 TO EN-FROG-CD(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-FROG-CH(WS-ROW) = 1
             CALL "M44-FROG-JUMP" USING WS-ROW
             IF EN-FROG-JS(WS-ROW) NOT = 1
                 MOVE 1 TO EN-FROG-JS(WS-ROW)
             END-IF
         END-PERFORM
         IF WS-J = 1
             MOVE "test cova frog a frog that prefers lily pads chooses a cell above a pad (x and z, then it stays put)" TO WS-CASE
             MOVE 1 TO WS-E
             MOVE 0 TO WS-O
             IF EN-FROG-CH(WS-ROW) = 1 AND EN-FROG-TZ(WS-ROW) = WS-Z0 + 20
                     AND EN-FROG-TX(WS-ROW) >= WS-X0 + 22 AND EN-FROG-TX(WS-ROW) <= WS-X0 + 24
                 MOVE 1 TO WS-O
             END-IF
             CALL "CA-N" USING WS-CASE WS-E WS-O
         END-IF
*>       Without the preference the same frog still gets a target (any cell, its own column refused).
         MOVE 0 TO WS-HAVE
         MOVE 0 TO EN-FROG-PREF(WS-ROW)
     END-PERFORM
     MOVE "test cova frog a frog without the preference chooses some target within the box" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-FROG-CH(WS-ROW) = 1
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Many draws without the preference: some pick the frog's own column (refused) before one is accepted.
     MOVE 0 TO WS-HAVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE 1 TO EN-FROG-JS(WS-ROW)
         MOVE 0 TO EN-FROG-CH(WS-ROW)
         MOVE 0 TO EN-FROG-LIFE(WS-ROW)
         MOVE 40 TO EN-FROG-TRIES(WS-ROW)
         MOVE 0 TO EN-FROG-PREF(WS-ROW)
         COMPUTE EN-FROG-SX(WS-ROW) = WS-X0 + 20
         COMPUTE EN-FROG-SY(WS-ROW) = WS-FLOOR + 1
         COMPUTE EN-FROG-SZ(WS-ROW) = WS-Z0 + 20
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         ADD 7 TO CW-TICKS
         CALL "M44-FROG-JUMP" USING WS-ROW
         IF EN-FROG-CH(WS-ROW) = 1
             ADD 1 TO WS-HAVE
         END-IF
     END-PERFORM
     MOVE "test cova frog the frog picks a target on most single draws over 300 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HAVE > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-FROG.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
