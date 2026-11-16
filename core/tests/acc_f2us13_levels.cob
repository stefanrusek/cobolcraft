*> Acceptance test of US13-3 and US13-4 (FR-034; SC-008; docs/protocol/15 requirement filtering, 16 section 2): a level-0 Player is refused a
*> level-2 command with the standard unknown-command message and nothing happens, a level-0 command (msg) still works for them, the operator
*> (level 4) runs the same command, a bare name means cobolcraft: in a cobolcraft world and commands run against the cobolcraft registries.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US13-LEVELS.
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

     MOVE "acceptance US13 levels a level-0 Player running give (level 2) is refused with the standard unknown-command message" TO TL-CASE
     MOVE "give Alice pry_bar" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US13 levels a level-0 Player running a level-0 command (msg) is answered" TO TL-CASE
     MOVE "msg Opal hello" TO WS-LINE
     MOVE "commands.message.display.outgoing(Opal,hello)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 levels the operator (level 4) runs give with a bare name: it means cobolcraft: in a cobolcraft world" TO TL-CASE
     MOVE "give Alice pry_bar" TO WS-LINE
     MOVE "commands.give.success.single(1,cobolcraft:pry_bar,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US13 levels the operator's command runs against the cobolcraft registries: a minecraft: item is invalid" TO TL-CASE
     MOVE "give Alice minecraft:stone" TO WS-LINE
     MOVE "argument.item.id.invalid(minecraft:stone) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM ACC-F2US13-LEVELS.

 COPY CORETEST.
 COPY CMDTEST.
