*> The ender pearl and the thrown egg of lane 002-lane-mobsb6 (17 section 3.15, 44 part 8 sections 6.5, 10 and 10.4), kinds 4 and 6 of PROJSTATE.cpy. Both fly as THROWN-FLY with
*> gravity 0.03. A pearl that hits anything teleports its owner (a living player of the pearl's dimension; the pearl keeps no other check) to the impact point, resets the fall
*> distance (CMD-MOVE-PLAYER), costs 5.0 (HEALTH-HURT, CAUSE-FALL: a fall type source that bypasses armor) and on a roll under 50 of 1000 spawns an endermite there when the level
*> spawns monsters. An egg hatches 1 baby chicken (age -24000) on nextInt(8) = 0 and 4 on nextInt(32) = 0 as well, then Entity Event 3 goes to the viewers.
*> Gaps: pearl vanishing when the owner dies offline and the chunk ticket, the End to Overworld portal rule, the End gateway, 32 portal particles and the teleport sound, a pearl
*> hitting an entity hurts it for 0, the chicken variant of the egg stack, the break particles, the throw cooldown of 20 ticks (no item cooldown store exists).
*>
*>   PEARL-ARRIVE USING owner player row (0 none), dim, x, y, z (FLOAT-LONG), roll 0 to 999
*>   PEARL-STEP USING tracker row
*>   EGG-HATCH USING dim, x, y, z (FLOAT-LONG), roll 8 (nextInt(8)), roll 32 (nextInt(32))
*>   EGG-STEP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PEARL-ARRIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:endermite".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MONSTERS            BINARY-LONG.
 01 WS-TELEPORTS           BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ENDERMITE           BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-FALL.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-OWNER                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROLL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-DIM L-X L-Y L-Z L-ROLL.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO WS-VALID WS-MONSTERS
     IF L-OWNER > 0
         IF PL-USED(L-OWNER) = 1 AND PL-STATE(L-OWNER) = PS-ALIVE AND PL-DIM(L-OWNER) = L-DIM
             MOVE 1 TO WS-VALID
         END-IF
     END-IF
     IF BW-DIFFICULTY > 0 AND CS-HOSTILE-MOBS = 1
         MOVE 1 TO WS-MONSTERS
     END-IF
     CALL "TOOL-PEARL-LAND" USING WS-VALID L-ROLL WS-MONSTERS WS-TELEPORTS WS-DAMAGE WS-ENDERMITE
     IF WS-TELEPORTS = 1
         CALL "CMD-MOVE-PLAYER" USING L-OWNER L-DIM L-X L-Y L-Z
         CALL "HEALTH-HURT" USING L-OWNER WS-DAMAGE WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
     END-IF
     IF WS-ENDERMITE = 1
         CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
         IF WS-TYPE > 0
             CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW WS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PEARL-ARRIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PEARL-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9004.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     MOVE 0 TO WS-OWNER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = PJ-OWNER(WS-SLOT)
             MOVE WS-P TO WS-OWNER
         END-IF
     END-PERFORM
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-ROLL
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PJ-DROP" USING L-ROW
     CALL "PEARL-ARRIVE" USING WS-OWNER WS-DIM WS-X WS-Y WS-Z WS-ROLL
     GOBACK.
 END PROGRAM PEARL-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-HATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:chicken".
 01 WS-TYPE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R8                   BINARY-LONG.
 01 L-R32                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-R8 L-R32.
     CALL "TOOL-EGG-HATCH" USING L-R8 L-R32 WS-COUNT
     IF WS-COUNT = 0
         GOBACK
     END-IF
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW WS-NEW
         MOVE 1 TO EN-VARIANT(WS-NEW)
         MOVE -24000 TO EN-MOBAGE(WS-NEW)
     END-PERFORM
     GOBACK.
 END PROGRAM EGG-HATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-R8                  BINARY-LONG.
 01 WS-R32                 BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9006.
 01 WS-SALT2               BINARY-LONG VALUE 9007.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-THIRTY-TWO          BINARY-LONG VALUE 32.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-EIGHT WS-R8
     CALL "XP-RANDOM" USING WS-SALT2 WS-THIRTY-TWO WS-R32
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PJ-DROP" USING L-ROW
     CALL "EGG-HATCH" USING WS-DIM WS-X WS-Y WS-Z WS-R8 WS-R32
     GOBACK.
 END PROGRAM EGG-STEP.
