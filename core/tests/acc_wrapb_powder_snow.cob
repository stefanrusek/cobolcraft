*> Acceptance test (wrap agent B, T43521; docs/protocol/25-item-registry-5 sections 5.3 and 5.7, 29a section 7.5): the powder snow bucket. Use Item On with the filled bucket places a powder snow block
*> (a SolidBucketItem is a block item) and a survival player's bucket becomes an empty bucket; Use Item with an empty bucket aimed at powder snow takes it (the cell becomes air, level event 2001)
*> and the bucket becomes the powder snow bucket. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-POWDER-SNOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-powder-snow-world".
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
 01 WS-BUCKET              BINARY-LONG.
 01 WS-POWDER-BUCKET       BINARY-LONG.
 01 WS-POWDER              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 01 WS-SLOT0               BINARY-LONG VALUE 0.
 01 WS-FACE-UP             BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-ITEM-KEY            PIC X(48).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb powder snow: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 0 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 12
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 106
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   Alice stands at (3.5, 102, 2.5): the eye is at y 103.6 and the ray of Use Item (yaw 0, pitch 0) runs south along z through the cells y 103
     MOVE 3.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 102.0 TO PL-Y(WS-ROW)
     MOVE 2.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-BUCKET
     MOVE "powder_snow_bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-POWDER-BUCKET
     MOVE "powder_snow" TO WS-K PERFORM MAKE-DEF MOVE WS-ST TO WS-POWDER
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT0

*>   A. the item table: the powder snow bucket places the powder snow block (25-5 5.3)
     MOVE IT-PLACES-STATE(WS-POWDER-BUCKET + 1) TO WS-OBS-N
     MOVE WS-POWDER TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.3 the powder snow bucket is a block item for powder_snow" TO WS-CASE
     PERFORM ASSERT-N

*>   B. Use Item On the stone floor (3, 100, 6) from above puts the block at (3, 101, 6) and leaves an empty bucket in survival
     MOVE WS-POWDER-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO WS-X MOVE 100 TO WS-Y MOVE 6 TO WS-Z
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE-UP WS-SEQ
     MOVE 101 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-OBS-N
     MOVE WS-POWDER TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.3 Use Item On with the powder snow bucket places powder snow" TO WS-CASE
     PERFORM ASSERT-N
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-OBS-N
     MOVE WS-BUCKET TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.3 and the survival player holds an empty bucket" TO WS-CASE
     PERFORM ASSERT-N
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-OBS-N
     MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.3 of one" TO WS-CASE
     PERFORM ASSERT-N

*>   C. the empty bucket aimed at powder snow at (3, 103, 5) takes it: air in the cell and the powder snow bucket in the hand. The Use Item of the tick of a Use Item On that a block took
*>   (here B placed the powder snow) is spent with that click (29 section 9, T63303), so the second click comes one tick later, as the client's right button sends it.
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 103 TO WS-Y MOVE 5 TO WS-Z
     MOVE "powder_snow" TO WS-K PERFORM PUT-DEF
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-OBS-N
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.7 an empty bucket takes the powder snow in sight" TO WS-CASE
     PERFORM ASSERT-N
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-OBS-N
     MOVE WS-POWDER-BUCKET TO WS-EXP-N
     MOVE "acceptance wrapb powder snow 25-5 5.7 and the bucket is the powder snow bucket" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

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
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         CALL "KEY-BARE" USING IT-KEY(WS-I) WS-ITEM-KEY
         IF WS-ITEM-KEY = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-POWDER-SNOW.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
