*> Kelp heads and bodies in the world (lane bugkelpplace; docs/protocol/29b-falling-growth-fire-4-growing-plants.md section 3.2 steps 3, 7 and 10 with growth direction UP, section 3.3):
*> a column of kelp is one head ("kelp", property age 0 to 25) on top of bodies ("kelp_plant", no property). The decision programs of the engine (GC4-*) are rules without a world;
*> this file is their world side for kelp:
*>   KELP-IDS     USING kelp block, kelp_plant block (0-based block ids), kelp default state, kelp_plant default state    the ids, found once
*>   PS-KELP      USING PLACE-CONTEXT   getStateForPlacement (step 3): the body when the cell above the clicked position holds a head or a body, else the head with age nextInt(25)
*>   KELP-SHAPE   USING dimension row, x, y, z, state, direction (BU-DIRECTION), neighbour state, state out   updateShape (steps 7 and 10), called by BU-HOOK kind 4

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KELP-IDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-KELP-BLOCK          BINARY-LONG VALUE -1.
 01 WS-PLANT-BLOCK         BINARY-LONG VALUE -1.
 01 WS-KELP-STATE          BINARY-LONG VALUE 0.
 01 WS-PLANT-STATE         BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 01 L-KELP-BLOCK           BINARY-LONG.
 01 L-PLANT-BLOCK          BINARY-LONG.
 01 L-KELP-STATE           BINARY-LONG.
 01 L-PLANT-STATE          BINARY-LONG.
 PROCEDURE DIVISION USING L-KELP-BLOCK L-PLANT-BLOCK L-KELP-STATE L-PLANT-STATE.
     IF WS-READY = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
             CALL "KEY-BARE" USING CB-KEY(WS-I) WS-NAME
             IF WS-NAME = "kelp"
                 COMPUTE WS-KELP-BLOCK = WS-I - 1
                 MOVE CB-DEFAULT-STATE(WS-I) TO WS-KELP-STATE
             END-IF
             IF WS-NAME = "kelp_plant"
                 COMPUTE WS-PLANT-BLOCK = WS-I - 1
                 MOVE CB-DEFAULT-STATE(WS-I) TO WS-PLANT-STATE
             END-IF
         END-PERFORM
         MOVE 1 TO WS-READY
     END-IF
     MOVE WS-KELP-BLOCK TO L-KELP-BLOCK
     MOVE WS-PLANT-BLOCK TO L-PLANT-BLOCK
     MOVE WS-KELP-STATE TO L-KELP-STATE
     MOVE WS-PLANT-STATE TO L-PLANT-STATE
     GOBACK.
 END PROGRAM KELP-IDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KELP-OF-STATE.
*> USING state (BINARY-LONG), the state is a kelp head or a kelp body (BINARY-LONG out 0 or 1): the "head block or body block" test of 3.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KELP-BLOCK          BINARY-LONG.
 01 WS-PLANT-BLOCK         BINARY-LONG.
 01 WS-KELP-STATE          BINARY-LONG.
 01 WS-PLANT-STATE         BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FAMILY.
     MOVE 0 TO L-FAMILY
     CALL "KELP-IDS" USING WS-KELP-BLOCK WS-PLANT-BLOCK WS-KELP-STATE WS-PLANT-STATE
     IF L-STATE >= 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         IF WS-BLOCK = WS-KELP-BLOCK OR WS-BLOCK = WS-PLANT-BLOCK
             MOVE 1 TO L-FAMILY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM KELP-OF-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KELP-HEAD-STATE.
*> USING the head's state out (BINARY-LONG): the kelp head with age nextInt(25), one draw of the level random (GrowingPlantHeadBlock.getStateForPlacement(random), 3.2 step 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KELP-BLOCK          BINARY-LONG.
 01 WS-PLANT-BLOCK         BINARY-LONG.
 01 WS-PLANT-STATE         BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 25.
 01 WS-DRAW                BINARY-LONG.
 01 WS-AGE-NAME            PIC X(24) VALUE "age".
 01 WS-AGE-EDIT            PIC Z9.
 01 WS-AGE-TEXT            PIC X(32).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE.
     CALL "KELP-IDS" USING WS-KELP-BLOCK WS-PLANT-BLOCK L-STATE WS-PLANT-STATE
     CALL "LEVEL-RANDOM-INT" USING WS-BOUND WS-DRAW
     MOVE WS-DRAW TO WS-AGE-EDIT
     MOVE SPACES TO WS-AGE-TEXT
     MOVE FUNCTION TRIM(WS-AGE-EDIT LEADING) TO WS-AGE-TEXT
     CALL "PS-PUT" USING L-STATE WS-AGE-NAME WS-AGE-TEXT
     GOBACK.
 END PROGRAM KELP-HEAD-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-KELP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KELP-BLOCK          BINARY-LONG.
 01 WS-PLANT-BLOCK         BINARY-LONG.
 01 WS-KELP-STATE          BINARY-LONG.
 01 WS-PLANT-STATE         BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     COMPUTE WS-Y = PC-Y + 1
     CALL "WORLD-GET-BLOCK" USING PC-DIM PC-X WS-Y PC-Z WS-ABOVE
     CALL "KELP-OF-STATE" USING WS-ABOVE WS-FAMILY
     IF WS-FAMILY = 1
         CALL "KELP-IDS" USING WS-KELP-BLOCK WS-PLANT-BLOCK WS-KELP-STATE WS-PLANT-STATE
         MOVE WS-PLANT-STATE TO PC-STATE
     ELSE
         CALL "KELP-HEAD-STATE" USING PC-STATE
     END-IF
     GOBACK.
 END PROGRAM PS-KELP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KELP-SHAPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KELP-BLOCK          BINARY-LONG.
 01 WS-PLANT-BLOCK         BINARY-LONG.
 01 WS-KELP-STATE          BINARY-LONG.
 01 WS-PLANT-STATE         BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-NSTATE               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-DIR L-NSTATE L-OUT.
     MOVE L-STATE TO L-OUT
     CALL "KELP-IDS" USING WS-KELP-BLOCK WS-PLANT-BLOCK WS-KELP-STATE WS-PLANT-STATE
     MOVE -1 TO WS-BLOCK
     IF L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     END-IF
     IF WS-BLOCK = WS-KELP-BLOCK OR WS-BLOCK = WS-PLANT-BLOCK
*>       The state in the growth direction: the changed neighbour when the change came from there, else (a change under the head) the cell above.
         MOVE 0 TO WS-SEEN
         IF L-DIR = 1
             CALL "KELP-OF-STATE" USING L-NSTATE WS-SEEN
         END-IF
         IF L-DIR = 0 AND WS-BLOCK = WS-KELP-BLOCK
             COMPUTE WS-Y = L-Y + 1
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-ABOVE
             CALL "KELP-OF-STATE" USING WS-ABOVE WS-SEEN
         END-IF
*>       3.2 step 7: a head with a head or a body in its growth direction becomes a body.
         IF WS-BLOCK = WS-KELP-BLOCK AND WS-SEEN = 1
             MOVE WS-PLANT-STATE TO L-OUT
         END-IF
*>       3.2 step 10: a body whose growth direction holds neither a body nor a head becomes a head with a random age.
         IF WS-BLOCK = WS-PLANT-BLOCK AND L-DIR = 1 AND WS-SEEN = 0
             CALL "KELP-HEAD-STATE" USING L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM KELP-SHAPE.
