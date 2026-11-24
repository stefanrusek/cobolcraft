*> Acceptance test of docs/protocol/16-commands-catalog.md §7.5 `place` (permission level 2): feature, jigsaw, structure and template with every argument form. This world has
*> no template, structure, jigsaw pool or placeable configured feature, so feature and structure answer commands.place.<kind>.failed, a jigsaw commands.place.jigsaw.invalid [pool key]
*> (36-3 15: there is no template pool; the success and failed answers with the data are in test_struct_36_3_15) and a template commands.place.template.invalid [template id] (the success
*> messages cannot happen). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PLACE.
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
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
 01 WS-LENGTH              BINARY-LONG.
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
     MOVE "acceptance US13 /place feature: Failed to place feature" TO TL-CASE
     MOVE "place feature minecraft:oak" TO WS-LINE
     MOVE "commands.place.feature.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place feature at a position" TO TL-CASE
     MOVE "place feature minecraft:oak 1 70 1" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place jigsaw: There is no template pool of that key" TO TL-CASE
     MOVE "place jigsaw minecraft:village/plains/town_centers minecraft:empty 5" TO WS-LINE
     MOVE "commands.place.jigsaw.invalid(minecraft:village/plains/town_centers)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place jigsaw at a position" TO TL-CASE
     MOVE "place jigsaw minecraft:pool minecraft:empty 20 ~ ~ ~" TO WS-LINE
     MOVE "commands.place.jigsaw.invalid(minecraft:pool)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place jigsaw the depth is at most 20" TO TL-CASE
     MOVE "place jigsaw minecraft:pool minecraft:empty 21" TO WS-LINE
     MOVE "argument.integer.big(20,21) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place jigsaw the depth is at least 1" TO TL-CASE
     MOVE "place jigsaw minecraft:pool minecraft:empty 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place structure: Failed to place structure" TO TL-CASE
     MOVE "place structure minecraft:village_plains" TO WS-LINE
     MOVE "commands.place.structure.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place structure at a position" TO TL-CASE
     MOVE "place structure minecraft:village_plains ~ ~ ~" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template: There is no template with ID" TO TL-CASE
     MOVE "place template minecraft:igloo/top" TO WS-LINE
     MOVE "commands.place.template.invalid(minecraft:igloo/top)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template the namespace defaults to minecraft:" TO TL-CASE
     MOVE "place template igloo/top 0 70 0" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template with a rotation" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 clockwise_90" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template with a mirror" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 180 left_right" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template with an integrity" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 counterclockwise_90 front_back 0.5" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template with a seed" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 none none 1 -7" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template strict" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 none none 1 7 strict" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template an unknown rotation" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 sideways" TO WS-LINE
     MOVE "argument.enum.invalid(sideways) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place template an integrity above 1" TO TL-CASE
     MOVE "place template minecraft:igloo/top 0 70 0 none none 2" TO WS-LINE
     MOVE "argument.float.big(1.0,2.0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place needs a kind" TO TL-CASE
     MOVE "place" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /place a player below level 2 does not know the command" TO TL-CASE
     MOVE "place feature minecraft:oak" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /place the console prints the English text" TO TL-CASE
     MOVE "place template foo:bar" TO WS-LINE
     MOVE "There is no template with ID ""foo:bar""" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /place completion offers the four kinds" TO TL-CASE
     MOVE "/place " TO WS-LINE
     MOVE 7 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 7 0 [feature,jigsaw,structure,template]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.
 END PROGRAM TEST-CMD-PLACE.

 COPY CORETEST.
 COPY CMDTEST.
