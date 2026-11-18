*> Acceptance test of the operator report "clouds, sun and moon don't render" in its own setting (try13 play, a superflat world; bug lane bugsky; 12 section 3.4c, 3.6;
*> 56-superflat-world.md): a new superflat world made from the create-world screen (SP-OPEN, the standard content set of the generated vanilla packs, CC_GENERATED_DIR)
*> joins through the real core, and the client's render list draws the sun, the moon and the clouds. The sun and the moon are the real sprites of the generated vanilla
*> pack's celestials atlas definition (texture 0, not the flat fallback of the UI atlas), the clouds come from its clouds.png (256 x 256 cells), the dimension is the
*> overworld with sky light and the world is flat. Without the generated packs SP-OPEN refuses the world and the test fails.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SKY-SUPERFLAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-sky-superflat".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-FOLDER              PIC X(80) VALUE "SkyFlat".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 7.
 01 WS-NAME                PIC X(64) VALUE "SkyFlat".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 7.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-REASON              PIC X(40) VALUE Z"cobolcraft.disconnect.host_closed".
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-GEN                 PIC X(1024).
 01 WS-TICKS               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   PIC 9 OCCURS 4 TIMES.
 01 WS-SOLID               BINARY-LONG.
 01 WS-J                   PIC 9.
 01 WS-F                   PIC 9.
 01 WS-S                   PIC 9.
 01 WS-A                   PIC 9.
 01 WS-B                   PIC 9.
 01 WS-EW                  PIC Z(5)9.
 01 WS-ES                  PIC Z(5)9.
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
*>   The packs are stacked again with the generated vanilla pack in (TEST-SP-START started before the directory was set).
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-N(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         EVALUATE RL-D-SLOT(WS-I)
             WHEN MESH-SLOT-SUN
                 ADD 1 TO WS-N(1)
             WHEN MESH-SLOT-MOON
                 ADD 1 TO WS-N(2)
             WHEN MESH-SLOT-STARS
                 ADD 1 TO WS-N(3)
             WHEN MESH-SLOT-CLOUDS
                 ADD 1 TO WS-N(4)
         END-EVALUATE
     END-PERFORM
     MOVE WS-JOINED TO WS-J
     MOVE PL-FLAT TO WS-F
     MOVE PL-HAS-SKY TO WS-S
     MOVE "acceptance sky: given a new superflat world of the generated vanilla packs when the Player is in it then the render list draws the sun, the moon and the "
         & "clouds and the dimension is flat with sky light" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 flat 1 sky 1 sun 1 moon 1 clouds 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " WS-J " flat " WS-F " sky " WS-S " sun " WS-N(1) " moon " WS-N(2) " clouds " WS-N(4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sprites of the vanilla pack are in the block atlas (texture 0); the clouds image is the pack's 256 x 256, not the procedural one's.
     MOVE SK-SUN-TEX TO WS-A
     MOVE SK-MOON-TEX TO WS-B
     MOVE 0 TO WS-SOLID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65536
         IF SK-CI-CELLS(WS-I:1) = "1"
             ADD 1 TO WS-SOLID
         END-IF
     END-PERFORM
     MOVE "acceptance sky: given the generated vanilla pack in the stack then the sun and the moon are its sprites on the block atlas (texture 0) and the clouds its "
         & "256 x 256 image" TO TL-CASE
     MOVE "sun tex 0 moon tex 0 clouds 256 x 256 solid cells" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-A = 0 AND WS-B = 0 AND SK-CI-W = 256 AND SK-CI-H = 256 AND WS-SOLID > 0
         MOVE "sun tex 0 moon tex 0 clouds 256 x 256 solid cells" TO TL-OBSERVED
     ELSE
         MOVE SK-CI-W TO WS-EW
         MOVE WS-SOLID TO WS-ES
         STRING "sun tex " WS-A " moon tex " WS-B " clouds " WS-EW " solid " WS-ES DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-STOP" USING WS-REASON
     STOP RUN.
 END PROGRAM ACC-SKY-SUPERFLAT.
 COPY CLTEST.
