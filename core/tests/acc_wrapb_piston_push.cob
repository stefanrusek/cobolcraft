*> Acceptance test (wrap agent B, T29571; docs/protocol/30-redstone-3-pistons.md sections 7.2 and 8): the pushing of entities by moving blocks. An extending head pushes a ground item in its way
*> (8.1: the overlap depth of the movement area, plus 0.01, at most 0.51 a block per tick), the world stops a push (8.3, the entity collides with blocks), a retracting sticky piston pushes an entity in its
*> cell back out (8.4), a slime block sets the motion of the entity along the axis of the movement (8.1 step 5.2) and an entity of a kind the piston ignores (area_effect_cloud, 5.2) stays where it is.
*> Expected positions are worked out from the head shape of 9.2 and the steps of 8.1: head EAST platform x 12..16 and arm x -4..12 (sixteenths), item box 0.25 square.
*> Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-PISTON-PUSH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-piston-push-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CLOUD               BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-CODE                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-FLAG-N              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-IX                  FLOAT-LONG.
 01 WS-IY                  FLOAT-LONG.
 01 WS-IZ                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-IROW                BINARY-LONG.
 01 WS-PUSH-ROW             BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 32767.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb piston push: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 14
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 108
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 110.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "stone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STONE
     MOVE 0 TO WS-CLOUD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
         CALL "KEY-BARE" USING ET-KEY(WS-I) WS-BARE
         IF WS-BARE = "area_effect_cloud"
             COMPUTE WS-CLOUD = WS-I - 1
         END-IF
     END-PERFORM
     MOVE 0 TO WS-OBS-N
     IF WS-CLOUD > 0
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 5.2 the entity type area_effect_cloud exists" TO WS-CASE
     PERFORM ASSERT-N

*>   A. an extending head (piston x 1, head cell x 2) meets an item at x 2.3 (box 2.175 to 2.425): tick 1 the platform's area reaches x 2.5, overlap 0.325, push 0.335; tick 2 the platform
*>   (x 2.25 to 2.5) has the area 2.5 to 3.0, overlap 0.49, push 0.5: the item ends at x 3.135. An item far away is not touched.
     MOVE 1 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 2.3 TO WS-IX MOVE 101.0 TO WS-IY MOVE 1.5 TO WS-IZ
     PERFORM SPAWN-ITEM
     MOVE WS-IROW TO WS-PUSH-ROW
     MOVE 9.5 TO WS-IX MOVE 101.0 TO WS-IY MOVE 1.5 TO WS-IZ
     PERFORM SPAWN-ITEM
     PERFORM RUN-12
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-PUSH-ROW) * 1000 + 0.5)
     MOVE 3135 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.1 the extending head pushes the item in its way by 0.335 and then 0.5" TO WS-CASE
     PERFORM ASSERT-N
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-IROW) * 1000 + 0.5)
     MOVE 9500 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.1 an item that the head does not meet stays" TO WS-CASE
     PERFORM ASSERT-N

*>   B. the same push with a stone block at x 3: the second push of 0.5 would put the item box (3.01 to 3.26) into it, so the item stops at its west face, x 2.875 (8.3: it collides with the world)
     MOVE 4 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 2.3 TO WS-IX MOVE 101.0 TO WS-IY MOVE 4.5 TO WS-IZ
     PERFORM SPAWN-ITEM
*>   two ticks: the pushes of 0.335 (to 2.635) and 0.5 (stopped at 2.875); later the finished head and the stone squeeze the item and the item physics shoves it out (not the subject here)
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-IROW) * 1000 + 0.5)
     MOVE 2875 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.3 a push into a block stops at the block's face" TO WS-CASE
     PERFORM ASSERT-N

*>   C. a sticky piston (x 1) extended with its head at x 2 and no power retracts: an item at x 2.4 is in the head cell; tick 1 the head (platform 2.75 to 3.0) has the west area 2.25 to 2.75, overlap
*>   2.525 - 2.25 = 0.275, push 0.285 west to 2.115, whose box (1.99 to 2.24) is inside the piston cell by 0.01, so the base fix pushes it east by 0.03 to 2.145; tick 2 pushes it 0.51 west and the
*>   fix 0.51 back: the item ends at x 2.145, out of the piston cell.
     MOVE 7 TO WS-Z
     MOVE 1 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 1 TO WS-FLAG-N MOVE 1 TO WS-TYPE-N
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 3 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 1 TO WS-TYPE-N
     MOVE 2 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2.4 TO WS-IX MOVE 101.0 TO WS-IY MOVE 7.5 TO WS-IZ
     PERFORM SPAWN-ITEM
     PERFORM RUN-12
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-IROW) * 1000 + 0.5)
     MOVE 2145 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.4 a retracting sticky piston pushes an item out of its cell" TO WS-CASE
     PERFORM ASSERT-N

*>   D. a slime block pushed east (x 2 to x 3) with an item at x 3.3: the push (0.335 then 0.5, to x 4.135) and a motion of +1 along x, so the item goes on past 4.5
     MOVE 10 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 100 TO WS-Y MOVE 2 TO WS-X MOVE "obsidian" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     MOVE 2 TO WS-X MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3.3 TO WS-IX MOVE 101.0 TO WS-IY MOVE 10.5 TO WS-IZ
     PERFORM SPAWN-ITEM
     PERFORM RUN-12
     MOVE 0 TO WS-OBS-N
     IF EN-X(WS-IROW) > 4.5
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.1 a slime block sets the item's motion along x" TO WS-CASE
     PERFORM ASSERT-N

*>   E. the same with a piston facing south at x 10 (slime z 2 to z 3, item at z 3.3): the motion along z
     MOVE 1 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 3 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 10 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 100 TO WS-Y MOVE 2 TO WS-Z MOVE "obsidian" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-Z PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     MOVE 2 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-Z MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 10.5 TO WS-IX MOVE 101.0 TO WS-IY MOVE 3.3 TO WS-IZ
     PERFORM SPAWN-ITEM
     PERFORM RUN-12
     MOVE 0 TO WS-OBS-N
     IF EN-Z(WS-IROW) > 4.5
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.1 a slime block sets the item's motion along z" TO WS-CASE
     PERFORM ASSERT-N

*>   F. a piston facing up at x 13 pushes slime from y 102 to y 103 under an item at y 103.0: it goes up by 0.51 and 0.5 and flies on with a motion of +1 along y
     MOVE 1 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 1 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 13 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     MOVE 102 TO WS-Y MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 100 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 13.5 TO WS-IX MOVE 103.0 TO WS-IY MOVE 1.5 TO WS-IZ
     PERFORM SPAWN-ITEM
     MOVE 0 TO WS-OBS-N
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     IF EN-Y(WS-IROW) > 105
         MOVE 1 TO WS-OBS-N
     END-IF
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 8.1 a slime block sets the item's motion along y" TO WS-CASE
     PERFORM ASSERT-N

*>   G. an area effect cloud (a kind the piston ignores) in the way of the head of case A stays at x 2.3
     MOVE 13 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM PUT-PISTON
     CALL "ENTITY-ALLOC" USING WS-IROW
     MOVE WS-CLOUD TO EN-TYPE(WS-IROW)
     MOVE WS-DIM TO EN-DIM(WS-IROW)
     MOVE 2.3 TO EN-X(WS-IROW)
     MOVE 101.0 TO EN-Y(WS-IROW)
     MOVE 13.5 TO EN-Z(WS-IROW)
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     PERFORM RUN-12
     COMPUTE WS-OBS-N = FUNCTION INTEGER(EN-X(WS-IROW) * 1000 + 0.5)
     MOVE 2300 TO WS-EXP-N
     MOVE "acceptance wrapb pistons 30-3 5.2 an area effect cloud is skipped by the piston" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 0 TO EN-USED(WS-IROW)
     STOP RUN.

 RUN-12.
     MOVE 12 TO WS-TICKS
     PERFORM RUN-TICKS.

 PUT-PISTON.
*>   the piston state of code WS-CODE, facing WS-FACE-N, flag WS-FLAG-N, type WS-TYPE-N at (WS-X, WS-Y, WS-Z)
     CALL "PST-STATE-OF" USING WS-CODE WS-FACE-N WS-FLAG-N WS-TYPE-N WS-ST
     PERFORM PUT-ST.

 SPAWN-ITEM.
*>   a stone item (pickup delay 32767) at (WS-IX, WS-IY, WS-IZ) with no motion; its row in WS-IROW
     CALL "GI-SPAWN" USING WS-DIM WS-IX WS-IY WS-IZ WS-ZERO WS-ZERO2 WS-ZERO3 WS-STONE WS-ONE WS-DELAY WS-IROW.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP-N TO TL-EXPECTED-N
     MOVE WS-OBS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-PISTON-PUSH.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
