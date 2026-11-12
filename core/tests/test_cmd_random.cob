*> Acceptance test of docs/protocol/16-commands-catalog.md §10.8 `random value` and `random roll` (permission level 0; `random reset` and the sequence store are BLOCKED): a number from min to
*> max inclusive; the max must be above the min (range_too_small) and the span below 2147483647 (range_too_large); value tells the source
*> commands.random.sample.success [value] (Q), roll tells every player commands.random.roll [name, value, min, max]; the result is the number; a missing bound is the int
*> minimum or maximum; a sequence name is accepted. Opal holds operator status; Alice does not (the commands are level 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RANDOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-HIGH                BINARY-DOUBLE.
 01 WS-ONE-RESULT          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE 100 TO WS-LOW
     MOVE -100 TO WS-HIGH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE "random value 1..6" TO WS-LINE
         CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-ONE-RESULT
         IF WS-ONE-RESULT < WS-LOW
             MOVE WS-ONE-RESULT TO WS-LOW
         END-IF
         IF WS-ONE-RESULT > WS-HIGH
             MOVE WS-ONE-RESULT TO WS-HIGH
         END-IF
         CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     END-PERFORM
     MOVE "acceptance US13 /random 200 draws of 1..6 reach 1 and never " & "go below it" TO TL-CASE
     MOVE WS-LOW TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /random 200 draws of 1..6 reach 6 and never " & "go above it" TO TL-CASE
     MOVE WS-HIGH TO WS-NUM
     MOVE 6 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /random a range of one value: the max must b" & "e above the min" TO TL-CASE
     MOVE "random value 1..1" TO WS-LINE
     MOVE "commands.random.error.range_too_small()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /random max below min is refused by the rang" & "e parser" TO TL-CASE
     MOVE "random value 5..3" TO WS-LINE
     MOVE "argument.range.swapped() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /random a span of 2147483647 or more" TO TL-CASE
     MOVE "random value -2147483648..2147483647" TO WS-LINE
     MOVE "commands.random.error.range_too_large()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /random a missing min is the int minimum: th" & "e span is too large" TO TL-CASE
     MOVE "random value ..5" TO WS-LINE
     MOVE "commands.random.error.range_too_large()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "random value 10..11" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-ONE-RESULT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /random the result of 10..11 is 10 or 11" TO TL-CASE
     MOVE 0 TO WS-NUM
     IF WS-ONE-RESULT = 10 OR WS-ONE-RESULT = 11
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "random value 5.." TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-ONE-RESULT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /random a missing max is the int maximum: th" & "e number is at least 5" TO TL-CASE
     MOVE 0 TO WS-NUM
     IF WS-ONE-RESULT >= 5
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "random value 1..6 cobolcraft:dice" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-ONE-RESULT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /random a sequence name is accepted: the num" & "ber is from 1 to 6" TO TL-CASE
     MOVE 0 TO WS-NUM
     IF WS-ONE-RESULT >= 1 AND WS-ONE-RESULT <= 6
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /random a value is told to the source as Ran" & "domized value" TO TL-CASE
     MOVE "random value 1..6" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     MOVE SPACES TO WS-DISCARD
     UNSTRING WS-TEXT DELIMITED BY "(" INTO WS-DISCARD
     MOVE WS-DISCARD TO WS-TEXT
     MOVE "commands.random.sample.success" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /random a value is not sent to the other pla" & "yer" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /random a roll is told to every player with " & "the roller's name, the number and the range" TO TL-CASE
     MOVE "random roll 1..6" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-ONE-RESULT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     MOVE WS-ONE-RESULT TO WS-EDIT
     MOVE SPACES TO WS-DISCARD
     STRING "commands.random.roll(Alice," FUNCTION TRIM(WS-EDIT) ",1,6)" DELIMITED BY SIZE INTO WS-DISCARD
     MOVE "roll wrong" TO WS-EXPECTED
     IF WS-TEXT = WS-DISCARD
         MOVE "roll ok" TO WS-TEXT
     END-IF
     MOVE "roll ok" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /random random reset is not registered (BLOC" & "KED)" TO TL-CASE
     MOVE "random reset *" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-RANDOM.

 COPY CORETEST.
 COPY CMDTEST.
