*> Acceptance test of the framework translation keys of docs/protocol/15-commands-framework.md §5:
*> the English table (core/copy/BRLANG.cpy, one row for every key of §5.1 to §5.4: 173) and BR-LANG-TEXT,
*> which renders a translate component with its %s and %n$s arguments as the console prints it
*> (a plain or literal component is its text; an unknown key is shown as the key).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRLANG.
 COPY PROTO.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US13 15§5 Framework translation keys the table has a row for every key (173)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 173 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BL-COUNT
         IF BL-KEY(WS-I) = SPACES OR BL-TEXT(WS-I) = SPACES
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
             IF BL-KEY(WS-I) = BL-KEY(WS-J)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US13 15§5 Framework translation keys every key and text is present and no key repeats"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM CHECK-TEXTS
     STOP RUN.

 SET-KEY.
*> WS-TEXT holds the key (space padded); the component has no arguments yet.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO PB-TX-LENGTH
     MOVE WS-TEXT TO PB-TX-VALUE.

 ADD-ARGUMENT.
     ADD 1 TO PB-TX-ARG-COUNT
     MOVE WS-TEXT TO PB-TX-ARG-VALUE(PB-TX-ARG-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO PB-TX-ARG-LENGTH(PB-TX-ARG-COUNT).

 ASSERT-RENDER.
     CALL "BR-LANG-TEXT" USING PB-TEXT WS-TEXT WS-LENGTH
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXTS.
     MOVE "command.unknown.command" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "acceptance US13 15§5 Framework translation keys a key without arguments renders its text"
         TO TL-CASE
     MOVE "Unknown or incomplete command. See below for error" TO TL-EXPECTED
     PERFORM ASSERT-RENDER

     MOVE "argument.integer.big" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "10" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "11" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "acceptance US13 15§5 Framework translation keys %s arguments are taken in order" TO TL-CASE
     MOVE "Integer must not be more than 10: found 11" TO TL-EXPECTED
     PERFORM ASSERT-RENDER

     MOVE "commands.function.success.single.result" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "1" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "demo:f" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "acceptance US13 15§5 Framework translation keys %2$s and %1$s take the numbered argument"
         TO TL-CASE
     MOVE "Function 'demo:f' returned 1" TO TL-EXPECTED
     PERFORM ASSERT-RENDER

     MOVE "chat.type.admin" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "Alice" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "Set own game mode" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     MOVE "acceptance US13 15§5 Framework translation keys the admin broadcast wrapper" TO TL-CASE
     MOVE "[Alice: Set own game mode]" TO TL-EXPECTED
     PERFORM ASSERT-RENDER

     MOVE "multiplayer.confirm_command.parse_errors" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "foo" TO WS-TEXT
     PERFORM ADD-ARGUMENT
     CALL "BR-LANG-TEXT" USING PB-TEXT WS-TEXT WS-LENGTH
     MOVE "acceptance US13 15§5 Framework translation keys a \n in a text is a line feed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH
         IF WS-TEXT(WS-I:1) = X"0A"
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "no.such.key" TO WS-TEXT
     PERFORM SET-KEY
     MOVE "acceptance US13 15§5 Framework translation keys an unknown key is shown as the key" TO TL-CASE
     MOVE "no.such.key" TO TL-EXPECTED
     PERFORM ASSERT-RENDER

     INITIALIZE PB-TEXT
     MOVE PB-TEXT-LITERAL TO PB-TX-KIND
     MOVE "plain words" TO PB-TX-VALUE
     MOVE 11 TO PB-TX-LENGTH
     MOVE "acceptance US13 15§5 Framework translation keys a literal component is its text" TO TL-CASE
     MOVE "plain words" TO TL-EXPECTED
     PERFORM ASSERT-RENDER.
 END PROGRAM TEST-CMD-15-5.
