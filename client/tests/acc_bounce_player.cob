*> Acceptance test (lane bugbounce, T61210; operator report "beds and slime blocks are not bouncy"; docs/protocol/44-residual-mob-questions-5 section 4.3, 24-5 slime_block, 24-2
*> beds): a survival player of a single-player world (the client with its hosted core, the generated vanilla content, a default superflat world) falls 10 blocks onto
*> stone (control: never rises again), onto slime (restitution 1.0: rises again by most of the fall, takes no damage, the core accepts the moves), onto slime
*> while holding the sneak key (suppresses the bounce: rests) and onto a bed (restitution 0.75: rises again, lower than on slime). Without CC_GENERATED_DIR the world
*> cannot open and the test fails.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BOUNCE-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-bounce-player".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-FOLDER              PIC X(80) VALUE "Bounce".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-NAME                PIC X(64) VALUE "Bounce".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-GEN                 PIC X(1024).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(128).
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-SNEAK-KEY           BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-GROUND              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-DROP                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-LANDED              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-UPS                 BINARY-LONG.
 01 WS-RISE                BINARY-LONG.
 01 WS-RISE-SLIME          BINARY-LONG.
 01 WS-HEALTH0             FLOAT-SHORT.
 01 WS-TELEPORTS           BINARY-LONG.
 01 WS-LAST-Y              FLOAT-LONG.
 01 WS-JUMP                FLOAT-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-X                   BINARY-LONG.
 01 WS-BLOCKS.
    05 FILLER              PIC X(24) VALUE "stone".
    05 FILLER              PIC X(24) VALUE "slime_block".
    05 FILLER              PIC X(24) VALUE "slime_block".
    05 FILLER              PIC X(24) VALUE "white_bed".
 01 WS-BLOCK-TABLE REDEFINES WS-BLOCKS.
    05 WS-BLOCK-KEY        PIC X(24) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "bounce player: the superflat survival world joins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-JOINED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE PL-Y TO WS-GROUND
     MOVE KB-CODE(KB-SNEAK) TO WS-SNEAK-KEY
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         PERFORM DROP-ONTO
         EVALUATE WS-K
             WHEN 1
                 MOVE "bounce player: stone, the player lands and never rises again (ticks with upward speed)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-UPS TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN 2
                 MOVE WS-RISE TO WS-RISE-SLIME
                 MOVE "bounce player: slime, a fall of 10 blocks rises again by more than 6 blocks (thousandths)" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 MOVE 0 TO TL-OBSERVED-N
                 IF WS-RISE > 6000
                     MOVE 1 TO TL-OBSERVED-N
                 END-IF
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                 MOVE "bounce player: slime, no fall damage (health unchanged)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = FUNCTION MAX(0, WS-HEALTH0 - PL-HEALTH)
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                 MOVE "bounce player: slime, the core accepted every move (no teleport back, one landing)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-TELEPORTS TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN 3
                 MOVE "bounce player: slime while sneaking suppresses the bounce (ticks with upward speed)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-UPS TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN OTHER
                 MOVE "bounce player: a bed rises again (more than 3 blocks), lower than slime (thousandths)" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 MOVE 0 TO TL-OBSERVED-N
                 IF WS-RISE > 3000 AND WS-RISE < WS-RISE-SLIME
                     MOVE 1 TO TL-OBSERVED-N
                 END-IF
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-EVALUATE
     END-PERFORM
     STOP RUN.

*> Block k of the table under a fresh column, the player 10 blocks above it falling (the sneak key held for k = 3); WS-UPS, WS-RISE, WS-HEALTH0, WS-TELEPORTS out.
 DROP-ONTO.
     COMPUTE WS-X = 4 + WS-K * 4
     COMPUTE WS-E3 = WS-X
     COMPUTE WS-E1 = WS-GROUND - 1
     MOVE SPACES TO WS-LINE
     STRING "setblock " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E1) " 8 " FUNCTION TRIM(WS-BLOCK-KEY(WS-K)) X"00"
         DELIMITED BY SIZE INTO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE WS-GROUND TO WS-TOP
     IF WS-K = 4
         COMPUTE WS-TOP = WS-GROUND - 0.4375
     END-IF
     COMPUTE WS-E2 = WS-GROUND + 10
     MOVE SPACES TO WS-LINE
     STRING "tp Alice " FUNCTION TRIM(WS-E3) ".5 " FUNCTION TRIM(WS-E2) " 8.5 0 0" X"00" DELIMITED BY SIZE INTO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 3 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     IF WS-K = 3
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SNEAK-KEY WS-DOWN
     END-IF
     MOVE PL-HEALTH TO WS-HEALTH0
     MOVE 0 TO WS-LANDED WS-AIR WS-UPS WS-TELEPORTS
     MOVE WS-TOP TO WS-MAXY
     MOVE PL-Y TO WS-LAST-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 90
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
         COMPUTE WS-JUMP = FUNCTION ABS(PL-Y - WS-LAST-Y)
         IF WS-JUMP > 3
             ADD 1 TO WS-TELEPORTS
         END-IF
         MOVE PL-Y TO WS-LAST-Y
         IF PL-ON-GROUND = 0
             MOVE 1 TO WS-AIR
         END-IF
         IF WS-AIR = 1 AND PL-ON-GROUND = 1
             MOVE 1 TO WS-LANDED
         END-IF
         IF WS-LANDED = 1 AND PL-VY > 0.05
             ADD 1 TO WS-UPS
         END-IF
         IF WS-LANDED = 1 AND PL-Y > WS-MAXY
             MOVE PL-Y TO WS-MAXY
         END-IF
     END-PERFORM
     IF WS-K = 3
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SNEAK-KEY WS-UP
     END-IF
     COMPUTE WS-RISE = (WS-MAXY - WS-TOP) * 1000
     MOVE 40 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N.
 END PROGRAM ACC-BOUNCE-PLAYER.
 COPY CLTEST.
