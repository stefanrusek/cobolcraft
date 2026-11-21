*> Acceptance test of the entity records of a template (docs/protocol/36-structures-2 sections 1.4 and 5.6; the worldgen entity channel, core/src/gen-ent.cob): the records are read from the file
*> (pos, blockPos, the yaw of the stored Rotation, the nbt compound; a record without nbt is dropped), and placing the template asks the channel for each one (the position and the block
*> transformed by mirror, rotation and pivot, a record whose block is outside the box skipped, the yaw turned, entities ignored on request, the list bounded). Over the standard content set of the
*> generated packs (skipped as a pass without them), on the template test:ents of core/tests/fixtures/gen_tpl.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-ENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CELLS.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 COPY GENENT.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2               BINARY-LONG.
 01 WS-SAVED-USED         BINARY-LONG.
 01 WS-ED3                PIC -(8)9.
 01 WS-OX                  BINARY-LONG VALUE 4.
 01 WS-OY                  BINARY-LONG VALUE 10.
 01 WS-OZ                  BINARY-LONG VALUE 4.
 01 WS-AX                 BINARY-LONG VALUE 4.
 01 WS-AY                 BINARY-LONG VALUE 10.
 01 WS-AZ                 BINARY-LONG VALUE 4.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-RESULT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                PIC -(8)9.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 01 WS-F4                  PIC -(4)9.9.
 01 WS-LABEL               PIC X(150).
 01 WS-POINTER             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-2§5.6 Entities: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA

*>   The records of the file (1.4).
     MOVE "test:ents" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE "the file's three records: two with nbt are counted and kept, the one without nbt is dropped" TO WS-LABEL
     MOVE TP-ENTITIES(WS-ROW) TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     MOVE TP-ENT-N(WS-ROW) TO WS-ED2
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the first record keeps its position, block position and the yaw of its Rotation list" TO WS-LABEL
     COMPUTE WS-I = TP-ENT-BASE(WS-ROW) + 1
     MOVE TE-PX(WS-I) TO WS-F1
     MOVE TE-PZ(WS-I) TO WS-F2
     MOVE TE-BZ(WS-I) TO WS-ED
     MOVE TE-YAW(WS-I) TO WS-F3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-F3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1.5 2.5 2 90.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the compound is kept as stored: its first tag is the String id (type 8, name length 2)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF TE-DATA(WS-I)(1:5) = X"080002" & "id"
         MOVE "id first" TO TL-OBSERVED
     ELSE
         MOVE "other" TO TL-OBSERVED
     END-IF
     MOVE "id first" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the second record has no Rotation: yaw 0" TO WS-LABEL
     COMPUTE WS-I = TP-ENT-BASE(WS-ROW) + 2
     MOVE TE-YAW(WS-I) TO WS-F1
     MOVE FUNCTION TRIM(WS-F1) TO TL-OBSERVED
     MOVE "0.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   A compound over the 1344 bytes is counted but not kept; a full table keeps none either.
     MOVE "test:bigent" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW2
     MOVE "a record whose compound is 1400+ bytes is counted (1), not kept (0 records), and TE-LOST rises" TO WS-LABEL
     MOVE TP-ENTITIES(WS-ROW2) TO WS-ED
     MOVE TP-ENT-N(WS-ROW2) TO WS-ED2
     MOVE TE-LOST TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TE-USED TO WS-SAVED-USED
     MOVE TE-MAX TO TE-USED
     MOVE "test:onlyent1" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW2
     MOVE "with the entity table full the record is counted (1), not kept (0) and TE-LOST is 2" TO WS-LABEL
     MOVE TP-ENTITIES(WS-ROW2) TO WS-ED
     MOVE TP-ENT-N(WS-ROW2) TO WS-ED2
     MOVE TE-LOST TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE WS-SAVED-USED TO TE-USED

*>   Placing: no rotation, no box.
     PERFORM FRESH-SETTINGS
     PERFORM PLACE
     MOVE "no rotation: villager at (5.5, 10.0, 6.5) yaw 90, witch at (7.5, 10.0, 4.5) yaw 0" TO WS-LABEL
     PERFORM SHOW-BOTH
     MOVE "2 5.5 10.0 6.5 90.0 | 7.5 10.0 4.5 0.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Rotation clockwise 90 turns the position (3.2) and adds 90 degrees to the yaw (180 reads as -180).
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-ROTATION
     PERFORM PLACE
     MOVE "clockwise 90: villager at (2.5, 10.0, 5.5) yaw -180, witch at (4.5, 10.0, 7.5) yaw 90" TO WS-LABEL
     PERFORM SHOW-BOTH
     MOVE "2 2.5 10.0 5.5 -180.0 | 4.5 10.0 7.5 90.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Mirror left-right (z to 1 - z; the yaw becomes 180 - yaw).
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-MIRROR
     PERFORM PLACE
     MOVE "mirror left-right: villager at (5.5, 10.0, 2.5) yaw 90, witch at (7.5, 10.0, 4.5) yaw -180" TO WS-LABEL
     PERFORM SHOW-BOTH
     MOVE "2 5.5 10.0 2.5 90.0 | 7.5 10.0 4.5 -180.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Mirror front-back (x to 1 - x; the yaw is negated).
     PERFORM FRESH-SETTINGS
     MOVE 2 TO PS-MIRROR
     PERFORM PLACE
     MOVE "mirror front-back: villager at (3.5, 10.0, 6.5) yaw -90, witch at (1.5, 10.0, 4.5) yaw 0" TO WS-LABEL
     PERFORM SHOW-BOTH
     MOVE "2 3.5 10.0 6.5 -90.0 | 1.5 10.0 4.5 0.0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The box: only the record whose transformed block is inside asks (the villager's block is (5, 10, 6), the witch's (7, 10, 4)).
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-BOX-SET
     MOVE 0 TO PS-BOX(1)
     MOVE 0 TO PS-BOX(2)
     MOVE 0 TO PS-BOX(3)
     MOVE 6 TO PS-BOX(4)
     MOVE 20 TO PS-BOX(5)
     MOVE 15 TO PS-BOX(6)
     PERFORM PLACE
     MOVE "a box holding only the villager's block: one request" TO WS-LABEL
     MOVE GEL-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Ignored entities ask for nothing.
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-IGNORE-ENTITIES
     PERFORM PLACE
     MOVE "ignoreEntities: no request" TO WS-LABEL
     MOVE GEL-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The list is bounded (16 requests, the rest counted).
     PERFORM FRESH-SETTINGS
     MOVE 0 TO GEL-COUNT GEL-LOST
     PERFORM 9 TIMES
         CALL "STRUCT-PLACE" USING WS-ROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT
     END-PERFORM
     MOVE "nine placements of two records: 16 kept, 2 lost" TO WS-LABEL
     MOVE GEL-COUNT TO WS-ED
     MOVE GEL-LOST TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "16 2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     STOP RUN.

 FRESH-SETTINGS.
     INITIALIZE STRUCT-SETTINGS
     MOVE 3 TO WS-FLAGS.

 PLACE.
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "STRUCT-PLACE" USING WS-ROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT.

 SHOW-BOTH.
*> SHOW-BOTH: TL-OBSERVED is "count x y z yaw | x y z yaw" of the first two requests.
     MOVE GEL-COUNT TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POINTER
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POINTER
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE GEL-X(WS-K) TO WS-F1
         MOVE GEL-Y(WS-K) TO WS-F2
         MOVE GEL-Z(WS-K) TO WS-F3
         MOVE GEL-YAW(WS-K) TO WS-F4
         STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3) " " FUNCTION TRIM(WS-F4) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-POINTER
         IF WS-K = 1
             STRING " | " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POINTER
         END-IF
     END-PERFORM.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-2§5.6 Entities: " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
