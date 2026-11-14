*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 9 (The per-entity record): the 19 field names in order, the
*> four baby rules and the validity check of a record.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-ID3                PIC 999.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FIELD               PIC X(24).
 01 WS-RULE                PIC X(24).
 01 WS-CODE                BINARY-LONG.
 01 WS-TYPE                PIC X(40).
 01 WS-OK                  BINARY-LONG.
 01 WS-LAYER               PIC X(60).
 PROCEDURE DIVISION.
     CALL "EM9-FIELD-COUNT" USING WS-N
     MOVE "19 record fields" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I
     PERFORM CHECK-FIELD-1
     MOVE 2 TO WS-I
     MOVE "numeric_id" TO TL-EXPECTED
     PERFORM CHECK-FIELD
     MOVE 3 TO WS-I
     MOVE "renderer" TO TL-EXPECTED
     PERFORM CHECK-FIELD
     MOVE 11 TO WS-I
     MOVE "baby_rule" TO TL-EXPECTED
     PERFORM CHECK-FIELD
     MOVE 19 TO WS-I
     MOVE "ids" TO TL-EXPECTED
     PERFORM CHECK-FIELD
     MOVE 20 TO WS-I
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-FIELD
     MOVE "none" TO WS-RULE
     PERFORM CHECK-RULE-CODE
     MOVE "separate_model" TO WS-RULE
     PERFORM CHECK-RULE-CODE
     MOVE "transform" TO WS-RULE
     PERFORM CHECK-RULE-CODE
     MOVE "shared_model_scaled" TO WS-RULE
     PERFORM CHECK-RULE-CODE
     MOVE "baby_bouncy" TO WS-RULE
     PERFORM CHECK-RULE-CODE
*>   a record is valid when its numeric id is 0..160, its baby rule is one of the four and every model layer id is a registered layer (4.2).
     MOVE "minecraft:cow" TO WS-TYPE
     MOVE 30 TO WS-CODE
     MOVE "separate_model" TO WS-RULE
     MOVE "minecraft:cow#main" TO WS-LAYER
     CALL "EM9-RECORD-CHECK" USING WS-TYPE WS-CODE WS-RULE WS-LAYER WS-OK
     MOVE "a valid record" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE 161 TO WS-CODE
     CALL "EM9-RECORD-CHECK" USING WS-TYPE WS-CODE WS-RULE WS-LAYER WS-OK
     MOVE "numeric id 161 is out of range" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE 30 TO WS-CODE
     MOVE "baby_bouncy" TO WS-RULE
     CALL "EM9-RECORD-CHECK" USING WS-TYPE WS-CODE WS-RULE WS-LAYER WS-OK
     MOVE "an unknown baby rule is invalid" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "none" TO WS-RULE
     MOVE "minecraft:cow#nope" TO WS-LAYER
     CALL "EM9-RECORD-CHECK" USING WS-TYPE WS-CODE WS-RULE WS-LAYER WS-OK
     MOVE "an unregistered layer id is invalid" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecraft:cow#main" TO WS-LAYER
     MOVE "cow" TO WS-TYPE
     CALL "EM9-RECORD-CHECK" USING WS-TYPE WS-CODE WS-RULE WS-LAYER WS-OK
     MOVE "a registry name must carry the namespace" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-FIELD-1.
     MOVE "registry_name" TO TL-EXPECTED
     PERFORM CHECK-FIELD.

 CHECK-FIELD.
     CALL "EM9-FIELD-NAME" USING WS-I WS-FIELD
     MOVE SPACES TO TL-CASE
     MOVE WS-I TO WS-ID3
     STRING "acceptance US15 34-1§9 The per-entity record: field " WS-ID3 DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-FIELD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-RULE-CODE.
     CALL "EM9-BABY-RULE" USING WS-RULE WS-CODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§9 The per-entity record: baby rule " FUNCTION TRIM(WS-RULE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     EVALUATE FUNCTION TRIM(WS-RULE)
         WHEN "none" MOVE 1 TO TL-EXPECTED-N
         WHEN "separate_model" MOVE 2 TO TL-EXPECTED-N
         WHEN "transform" MOVE 3 TO TL-EXPECTED-N
         WHEN "shared_model_scaled" MOVE 4 TO TL-EXPECTED-N
         WHEN OTHER MOVE 0 TO TL-EXPECTED-N
     END-EVALUATE
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§9 The per-entity record: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-9.
