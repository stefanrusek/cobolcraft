*> Edge-case test of the namespace rule of command arguments (docs/design/world-types.md section 6.3, WT-13; 16 section 2): in a cobolcraft
*> world a bare item name means cobolcraft: and the registries are the cobolcraft ones, so a minecraft: item (the standard registries are not
*> loaded), an unknown namespace and an unknown name inside the right namespace all fail with argument.item.id.invalid (the bare name in the message is shown as cobolcraft:) and give nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-NAMESPACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ID-OPAL             BINARY-LONG.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /give a bare name inside a cobolcraft world means cobolcraft:" TO TL-CASE
     MOVE "give Opal pry_bar" TO WS-LINE
     MOVE "commands.give.success.single(1,cobolcraft:pry_bar,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give a minecraft: item inside a cobolcraft world fails: the registry does not hold it" TO TL-CASE
     MOVE "give Opal minecraft:stone" TO WS-LINE
     MOVE "argument.item.id.invalid(minecraft:stone) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give an unknown namespace fails the same way" TO TL-CASE
     MOVE "give Opal nope:pry_bar" TO WS-LINE
     MOVE "argument.item.id.invalid(nope:pry_bar) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give a standard name that the cobolcraft registries lack fails by bare name too" TO TL-CASE
     MOVE "give Opal stone" TO WS-LINE
     MOVE "argument.item.id.invalid(cobolcraft:stone) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give cobolcraft: written out in full works" TO TL-CASE
     MOVE "give Opal cobolcraft:greystone 3" TO WS-LINE
     MOVE "commands.give.success.single(3,cobolcraft:greystone,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-NAMESPACES.

 COPY CORETEST.
 COPY CMDTEST.
