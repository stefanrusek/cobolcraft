*> Acceptance test US7 (spec 002 FR-016, FR-017; SC-004; P-client-5, the first run's survival climb): in survival,
*> double Space in the air and Space held in the air never raise the Player above one jump height (1.25 blocks)
*> over the ground and never start flying. The ground is y 10 (the flat test world).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US7-SURVIVAL-CLIMB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-FLEW                PIC 9.
 01 WS-TOO-HIGH            PIC 9.
 01 WS-HEIGHT              PIC -(4)9.9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-survival.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO WS-FLEW
     MOVE PL-Y TO WS-MAX
*>   Jump, then press Space twice more in the air within 0.3 s, then hold it for three seconds.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         PERFORM OBSERVE
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     END-PERFORM
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM OBSERVE
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     END-PERFORM
     COMPUTE WS-HEIGHT ROUNDED = WS-MAX - 10
     MOVE "acceptance US7 given survival when Space is pressed twice in the air and then held then the "
         & "Player never rises above one jump height and never flies" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-TOO-HIGH
     IF WS-MAX - 10 > 1.26
         MOVE 1 TO WS-TOO-HIGH
     END-IF
     STRING "fly " WS-FLEW " too-high " WS-TOO-HIGH DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "fly 0 too-high 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 OBSERVE.
     IF PL-Y > WS-MAX
         MOVE PL-Y TO WS-MAX
     END-IF
     IF PL-FLYING = 1
         MOVE 1 TO WS-FLEW
     END-IF.
 END PROGRAM ACC-F2US7-SURVIVAL-CLIMB.
 COPY CLTEST.
