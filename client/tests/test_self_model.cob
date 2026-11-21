*> Test US18 (12 §7.3): the Player's own model (the operator's box, 36 vertices) is in the entity mesh in the third-person modes and not in
*> first person; it is at the player's position and the replica rows are left as they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SELF-MODEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WHOLE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
     MOVE 11.6 TO WS-EYE(2)
     MOVE 0 TO CL-CAMERA
     MOVE EN-COUNT TO WS-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "self model: first person draws no model of the Player" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "self model: behind draws the Player's box, 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "self model: in front draws it too" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "self model: the replica still has the rows it had" TO TL-CASE
     MOVE WS-COUNT TO TL-EXPECTED-N
     MOVE EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 256 TO EN-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "self model: with every replica row taken there is no room for it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A world of the standard set: the model is the humanoid of the model library (at least the six cuboids of head, body, arms and
*>   legs, whole cuboids of 36 vertices), not the stand-in box.
     MOVE 0 TO EN-COUNT
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 1 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-WHOLE
     IF RL-EN-COUNT >= 216 AND FUNCTION MOD(RL-EN-COUNT, 36) = 0
         MOVE 1 TO WS-WHOLE
     END-IF
     MOVE "self model: in a standard world the Player is the humanoid model, at least six whole cuboids" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WHOLE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "self model: in a standard world first person still draws none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SELF-MODEL.

 COPY CLTEST.
