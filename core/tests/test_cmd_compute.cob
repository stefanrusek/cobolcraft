*> Acceptance test of docs/protocol/16-commands-catalog.md §10.9 and 54 §13 `compute` (permission level 2): the provider is a number, a named provider of the
*> data registries context_float_provider and context_int_provider (the fixture tree core/tests/fixtures/loot, ids test:...) or an inline definition; the result and the
*> exact, rounded and invalid messages; the context sources default, block and entity. Opal holds operator status; Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-COMPUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD

     MOVE "acceptance US13 /compute integer of a named provider prints its id and value (54 s13.4)" TO TL-CASE
     MOVE "compute integer test:i_add" TO WS-LINE
     MOVE "command.compute.result.named.exact(test:i_add,6)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute integer the result is the value" TO TL-CASE
     MOVE 6 TO WS-EXPECTED-N
     PERFORM RUN-RESULT
     MOVE "acceptance US13 /compute integer of a plain provider name gets minecraft: (a missing one is argument.resource_or_id.no_such_element)" TO TL-CASE
     MOVE "compute integer i_add" TO WS-LINE
     MOVE "argument.resource_or_id.no_such_element(minecraft:i_add,minecraft:context_int_provider)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute integer of a number is an unnamed constant" TO TL-CASE
     MOVE "compute integer 7" TO WS-LINE
     MOVE "command.compute.result.unnamed.exact(7)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute integer a division by zero is the named invalid message and no result" TO TL-CASE
     MOVE "compute integer test:i_div0" TO WS-LINE
     MOVE "command.compute.result.named.invalid(test:i_div0,/ by zero)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float of a whole number prints the exact message with the int" TO TL-CASE
     MOVE "compute float 3" TO WS-LINE
     MOVE "command.compute.result.unnamed.exact(3)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float 2.5 is rounded to 2" TO TL-CASE
     MOVE "compute float 2.5" TO WS-LINE
     MOVE "command.compute.result.unnamed.rounded(2.5,2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float 2.5 returns 2" TO TL-CASE
     MOVE 2 TO WS-EXPECTED-N
     PERFORM RUN-RESULT
     MOVE "acceptance US13 /compute float the scale multiplies before the floor: 0.5 x 2 is rounded to 1" TO TL-CASE
     MOVE "compute float 0.5 2" TO WS-LINE
     MOVE "command.compute.result.unnamed.rounded(0.5,1)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float of a named provider (test:f_const is 0.5)" TO TL-CASE
     MOVE "compute float test:f_const" TO WS-LINE
     MOVE "command.compute.result.named.rounded(test:f_const,0.5,0)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float a non-finite value is the invalid message" TO TL-CASE
     MOVE "compute float test:f_div0" TO WS-LINE
     MOVE "command.compute.result.named.invalid(test:f_div0,Infinity)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute float a missing named provider" TO TL-CASE
     MOVE "compute float test:nothing" TO WS-LINE
     MOVE "argument.resource_or_id.no_such_element(test:nothing,minecraft:context_float_provider)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute default is the same context as none" TO TL-CASE
     MOVE "compute default integer test:i_add" TO WS-LINE
     MOVE "command.compute.result.named.exact(test:i_add,6)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute block takes a position and then the provider" TO TL-CASE
     MOVE "compute block ~ ~ ~ integer test:i_add" TO WS-LINE
     MOVE "command.compute.result.named.exact(test:i_add,6)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute entity takes one entity and then the provider" TO TL-CASE
     MOVE "compute entity Opal integer test:i_add" TO WS-LINE
     MOVE "command.compute.result.named.exact(test:i_add,6)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute entity with no such entity is No entity was found" TO TL-CASE
     MOVE "compute entity Nobody integer 1" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute an inline definition is refused with the parse failure (the inline codec is not available)" TO TL-CASE
     MOVE "compute integer {type:constant,value:4}" TO WS-LINE
     MOVE "argument.resource_or_id.failed_to_parse(inline definitions are not supported)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /compute a player below level 2 does not know the command" TO TL-CASE
     MOVE "compute integer 1" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The result of the line last run.
 RUN-RESULT.
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD.
 END PROGRAM TEST-CMD-COMPUTE.

 COPY CORETEST.
 COPY CMDTEST.
