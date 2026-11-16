*> The ender dragon entity (docs/protocol/21 section 6.4, 44 part 9 section 1; lane 002-lane-mobsb8, T9703): the spawn, the tick, the damage rules, the death sequence and the crystal hook.
*>
*>   DRAGON-SPAWN USING dim, x, y, z (FLOAT-LONG), row out (0 when it cannot be made)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:ender_dragon".
 01 WS-KIND                BINARY-LONG VALUE 17.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW > 0
         MOVE 200 TO EN-HEALTH(L-ROW)
         INITIALIZE DG-STATE
         MOVE EN-ID(L-ROW) TO DG-ENT
         MOVE 200 TO DG-HP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE L-Y TO DG-HIST-Y(WS-I)
             MOVE EN-YAW(L-ROW) TO DG-HIST-YAW(WS-I)
         END-PERFORM
         CALL "DRAGON-NODES-INIT" USING L-DIM
     END-IF
     GOBACK.
 END PROGRAM DRAGON-SPAWN.
