*> Contract test of the client surface (specs/002-client-polish/contracts/client-surface-delta.md; 13 §7.3): the default key
*> to action table of the client (every key mapping of 13 §7.3 with its GLFW key code, mouse buttons as 1000 + the button), a
*> rebinding read from contract/fixtures/client/options-full.txt, and the options.txt round trip (read the full fixture, write it,
*> read the written file: every key unchanged).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-CLIENT-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-DEFAULTS.
    05 FILLER PIC X(36) VALUE "key.forward                     0087".
    05 FILLER PIC X(36) VALUE "key.left                        0065".
    05 FILLER PIC X(36) VALUE "key.back                        0083".
    05 FILLER PIC X(36) VALUE "key.right                       0068".
    05 FILLER PIC X(36) VALUE "key.jump                        0032".
    05 FILLER PIC X(36) VALUE "key.sneak                       0340".
    05 FILLER PIC X(36) VALUE "key.sprint                      0341".
    05 FILLER PIC X(36) VALUE "key.inventory                   0069".
    05 FILLER PIC X(36) VALUE "key.swapOffhand                 0070".
    05 FILLER PIC X(36) VALUE "key.drop                        0081".
    05 FILLER PIC X(36) VALUE "key.hotbar.1                    0049".
    05 FILLER PIC X(36) VALUE "key.hotbar.2                    0050".
    05 FILLER PIC X(36) VALUE "key.hotbar.3                    0051".
    05 FILLER PIC X(36) VALUE "key.hotbar.4                    0052".
    05 FILLER PIC X(36) VALUE "key.hotbar.5                    0053".
    05 FILLER PIC X(36) VALUE "key.hotbar.6                    0054".
    05 FILLER PIC X(36) VALUE "key.hotbar.7                    0055".
    05 FILLER PIC X(36) VALUE "key.hotbar.8                    0056".
    05 FILLER PIC X(36) VALUE "key.hotbar.9                    0057".
    05 FILLER PIC X(36) VALUE "key.saveToolbarActivator        0067".
    05 FILLER PIC X(36) VALUE "key.loadToolbarActivator        0088".
    05 FILLER PIC X(36) VALUE "key.use                         1001".
    05 FILLER PIC X(36) VALUE "key.attack                      1000".
    05 FILLER PIC X(36) VALUE "key.pickItem                    1002".
    05 FILLER PIC X(36) VALUE "key.chat                        0084".
    05 FILLER PIC X(36) VALUE "key.playerlist                  0258".
    05 FILLER PIC X(36) VALUE "key.command                     0047".
    05 FILLER PIC X(36) VALUE "key.socialInteractions          0080".
    05 FILLER PIC X(36) VALUE "key.screenshot                  0291".
    05 FILLER PIC X(36) VALUE "key.togglePerspective           0294".
    05 FILLER PIC X(36) VALUE "key.smoothCamera                0000".
    05 FILLER PIC X(36) VALUE "key.fullscreen                  0300".
    05 FILLER PIC X(36) VALUE "key.advancements                0076".
    05 FILLER PIC X(36) VALUE "key.quickActions                0071".
    05 FILLER PIC X(36) VALUE "key.toggleGui                   0290".
    05 FILLER PIC X(36) VALUE "key.toggleSpectatorShaderEffects0293".
    05 FILLER PIC X(36) VALUE "key.spectatorOutlines           0000".
 01 WS-TABLE REDEFINES WS-DEFAULTS.
    05 WS-ROW OCCURS 37 TIMES.
       10 WS-ACTION        PIC X(32).
       10 WS-CODE          PIC 9(4).
 01 WS-I                   BINARY-LONG.
 01 WS-ACTION-NAME         PIC X(40).
 01 WS-KEY-CODE            BINARY-LONG.
 01 WS-FULL-PATH           PIC X(1100) VALUE "contract/fixtures/client/options-full.txt".
 01 WS-FULL-LENGTH         BINARY-LONG VALUE 42.
 01 WS-OUT-PATH            PIC X(1100) VALUE "build/client-test-surface/out.txt".
 01 WS-OUT-LENGTH          BINARY-LONG VALUE 33.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-A                   PIC X(256) VALUE "contract/fixtures/client/options-full.txt".
 01 WS-B                   PIC X(256) VALUE "build/client-test-surface/out.txt".
 01 WS-SAME                BINARY-LONG.
 01 WS-D                   PIC 9(4).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-surface && mkdir -p build/client-test-surface"
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         MOVE WS-ACTION(WS-I) TO WS-ACTION-NAME
         CALL "OPTIONS-KEY-CODE" USING CLIENT-STATE WS-ACTION-NAME WS-KEY-CODE
         MOVE SPACES TO TL-CASE
         STRING "client surface default key of " FUNCTION TRIM(WS-ACTION-NAME) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-CODE(WS-I) TO TL-EXPECTED
         MOVE WS-KEY-CODE TO WS-D
         MOVE WS-D TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     CALL "OPTIONS-READ" USING CLIENT-STATE WS-FULL-PATH WS-FULL-LENGTH WS-FOUND
     MOVE "key.forward" TO WS-ACTION-NAME
     CALL "OPTIONS-KEY-CODE" USING CLIENT-STATE WS-ACTION-NAME WS-KEY-CODE
     MOVE "client surface rebinding: the full fixture binds key.forward to the up arrow (265)" TO TL-CASE
     MOVE "0265" TO TL-EXPECTED
     MOVE WS-KEY-CODE TO WS-D
     MOVE WS-D TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "key.hotbar.9" TO WS-ACTION-NAME
     CALL "OPTIONS-KEY-CODE" USING CLIENT-STATE WS-ACTION-NAME WS-KEY-CODE
     MOVE "client surface rebinding: the full fixture binds key.hotbar.9 to keypad 9 (329)" TO TL-CASE
     MOVE "0329" TO TL-EXPECTED
     MOVE WS-KEY-CODE TO WS-D
     MOVE WS-D TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "OPTIONS-WRITE" USING CLIENT-STATE WS-OUT-PATH WS-OUT-LENGTH WS-OK
     CALL "TEST-OPT-SAME" USING WS-A WS-B WS-SAME
     MOVE "client surface options.txt round trip: the full fixture is written back byte for byte" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SAME * WS-OK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-CLIENT-SURFACE.

 COPY OPTTEST.
 COPY CLTEST.
