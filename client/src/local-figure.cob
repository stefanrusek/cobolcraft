*> The figure of the local player as a replica row (12 section 7.3, 47 sections 2.2 and 5.2): the third-person view, the first-person arm and the inventory preview (preview.cob) draw it
*> through the same model row, skin and slot. The player is not a replica entity, so the figure is made on the first free row, EN-COUNT + 1 (never used, so every field the figure does not
*> set is still its initial value); the caller counts the row in (ADD 1 TO EN-COUNT) while it works on it and gives the row back as it was (MOVE the saved EN-ENTITY back).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-FIGURE-SET.
*> USING CLIENT-STATE, row: makes the replica row the local player's figure in a world of the standard set: a "player" of the model table (the humanoid, the slim one with a slim skin) in the pose and
*> walk of the client's player, facing PL-YAW and PL-PITCH, wearing the default skin of its own offline UUID and showing the skin parts of its options. The position is the caller's.
*> EN-MODEL of the row is 0 when the model table has no "player".
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     MOVE 1 TO EN-USED(L-ROW) EN-VANILLA(L-ROW)
     MOVE PL-YAW TO EN-YAW(L-ROW) EN-HEAD-YAW(L-ROW)
     MOVE PL-PITCH TO EN-PITCH(L-ROW)
     MOVE 1 TO EN-ON-GROUND(L-ROW)
     MOVE PL-POSE TO EN-POSE(L-ROW)
*>   A sleeping player lies along its bed (pose SLEEPING with the bed cell, lane bugsleep).
     MOVE 0 TO EN-BED-SET(L-ROW)
     IF PL-SLEEP = 1
         MOVE 2 TO EN-POSE(L-ROW)
         MOVE 1 TO EN-BED-SET(L-ROW)
         MOVE PL-BED-X TO EN-BED-X(L-ROW)
         MOVE PL-BED-Y TO EN-BED-Y(L-ROW)
         MOVE PL-BED-Z TO EN-BED-Z(L-ROW)
     END-IF
     MOVE PL-SWIM-AMOUNT TO EN-SWIM(L-ROW)
     COMPUTE EN-FLAGS(L-ROW) = PL-SWIMMING * 16
     MOVE PL-ANIM-SPEED TO EN-WALK-SPEED(L-ROW)
     MOVE PL-ANIM-POS TO EN-WALK-POS(L-ROW)
     MOVE 1 TO EN-WALK-SCALE(L-ROW)
     MOVE 1 TO EN-ATTR-SCALE(L-ROW)
     MOVE PL-ANIM-AGE TO EN-AGE(L-ROW)
     MOVE 0 TO EN-MOB-FLAGS(L-ROW) EN-SW-ACTIVE(L-ROW)
     MOVE SPACES TO EN-KEY(L-ROW)
     MOVE "player" TO EN-KEY(L-ROW)
*>   The local player wears the default skin of its own offline UUID and shows the parts of its options (47 sections 2.2 and 5.2).
     CALL "CLP-OFFLINE-UUID" USING CL-NAME CL-NAME-LENGTH EN-UUID(L-ROW)
     CALL "PLAYER-PARTS-OPTIONS" USING CLIENT-STATE EN-PARTS(L-ROW)
     CALL "ENTITY-MODEL-FIND" USING EN-KEY(L-ROW) EN-MODEL(L-ROW)
     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE L-ROW EN-MODEL(L-ROW)
     GOBACK.
 END PROGRAM LOCAL-FIGURE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-FIGURE-KEY.
*> USING CLIENT-STATE, model out, texture code out: the model row of CL-MODELS and the texture code (the default skin index plus 1, ENTITY-TEX-CODE) of the local player's figure: the key of its slot in
*> the entity atlas (EA-MT). The model is 0 when there is no free row to make the figure on or the model table has no "player". The row is given back as it was.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-SAVED               PIC X(1024).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MODEL                BINARY-LONG.
 01 L-TEX                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MODEL L-TEX.
     MOVE 0 TO L-MODEL L-TEX
     IF EN-COUNT >= CL-MAX-ENTITIES
         GOBACK
     END-IF
     COMPUTE WS-R = EN-COUNT + 1
     MOVE EN-ENTITY(WS-R) TO WS-SAVED
     CALL "LOCAL-FIGURE-SET" USING CLIENT-STATE WS-R
     MOVE EN-MODEL(WS-R) TO L-MODEL
     IF L-MODEL > 0
         CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-R L-MODEL L-TEX
     END-IF
     MOVE WS-SAVED TO EN-ENTITY(WS-R)
     GOBACK.
 END PROGRAM LOCAL-FIGURE-KEY.
