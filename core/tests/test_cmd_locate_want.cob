*> Test of the structure matching of /locate structure without the generated packs (core/src/cmd-locate.cob, lane bugsw T10301): on the fixture structure data core/tests/fixtures/struct
*> CXC-STRUCT-WANT answers 1 for the structure itself (kind 1) and for the members of a structure tag, nested tags included (kind 2), and 0 for any other structure.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-WANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ROW                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG.
 01 WS-TWO                 BINARY-LONG.
 01 WS-THREE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "STRUCT-RESET"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:s_one"
             MOVE WS-I TO WS-ONE
         END-IF
         IF SDT-KEY(WS-I) = "minecraft:s_two"
             MOVE WS-I TO WS-TWO
         END-IF
         IF SDT-KEY(WS-I) = "minecraft:s_three"
             MOVE WS-I TO WS-THREE
         END-IF
     END-PERFORM
     MOVE 1 TO WS-KIND
     MOVE "minecraft:s_one" TO WS-ID
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-ONE WS-FLAG
     MOVE "test cmd locate want: a structure matches itself" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-TWO WS-FLAG
     MOVE "test cmd locate want: a structure does not match another" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     MOVE "minecraft:t_pair" TO WS-ID
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-ONE WS-FLAG
     MOVE "test cmd locate want: a tag lists its member" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-TWO WS-FLAG
     MOVE "test cmd locate want: a tag lists the member of a nested tag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-THREE WS-FLAG
     MOVE "test cmd locate want: a tag does not list a structure that is not in it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:t_missing" TO WS-ID
     CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-ONE WS-FLAG
     MOVE "test cmd locate want: an unknown tag lists nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CMD-LOCATE-WANT.
