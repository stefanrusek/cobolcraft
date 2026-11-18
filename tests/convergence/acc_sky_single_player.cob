*> Convergence acceptance test of the operator report "clouds, sun and moon don't render" (try13 play; bug lane bugsky; 12 section 3.4c, 3.6;
*> standin-content section 4.6 the surface dimension has sky light): one single-player world of the cobolcraft world type (the host's in-process core: the
*> Login, the dimension_type registry the core sends as network NBT and the Set Time packets are the real ones). By day the client's render list
*> holds the draws of the sun, the moon and the clouds and none of the stars; by night (the time command) the stars too; and the client's replica knows
*> the dimension has sky light (PL-HAS-SKY, from the dimension type's has_skylight), which is what lets the sky be drawn at all.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SKY-SINGLE-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-sky-single-player".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 28.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Sky".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 3.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-J                   PIC 9.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED

*>   By day.
     MOVE "/time set 6000" TO WS-LINE
     MOVE 14 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "SKY-CONV-DRAWS" USING CONVH WS-ALICE WS-TEXT
     MOVE "acceptance sky: given a single-player world when the Player is in the world by day then the render list draws the sun, the moon and the "
         & "clouds, no stars, and the dimension has sky light" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 sky 1 sun 1 moon 1 stars 0 clouds 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED TO WS-J
     STRING "joined " WS-J " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   By night.
     MOVE "/time set midnight" TO WS-LINE
     MOVE 18 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "SKY-CONV-DRAWS" USING CONVH WS-ALICE WS-TEXT
     MOVE "acceptance sky: given a single-player world when it is midnight (time command) then the render list also draws the stars"
         TO TL-CASE
     MOVE "sky 1 sun 1 moon 1 stars 1 clouds 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-SKY-SINGLE-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-CONV-DRAWS.
*> USING CONVH, client index, text out (PIC X(256)): "sky <PL-HAS-SKY> sun <n> moon <n> stars <n> clouds <n>", the draws of each slot in the client's last render list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
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
     MOVE SPACES TO L-TEXT
     STRING "sky " PL-HAS-SKY " sun " WS-N(1) " moon " WS-N(2) " stars " WS-N(3) " clouds " WS-N(4)
         DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM SKY-CONV-DRAWS.
