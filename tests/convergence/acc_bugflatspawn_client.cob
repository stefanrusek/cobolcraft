*> Convergence acceptance test (002-lane-bugflatspawn; operator report on try16: "hostile mobs aren't spawning in my super flat world at night"), on the operator's own path: a
*> new superflat world made through the create-world screen's SP-OPEN with the single-player defaults of CL-INIT (survival, hostile mobs on, view distance 8, extra dimensions on),
*> joined through the real core and run by the client's frames (CL-STEP, SP-PUMP) with the world time set to night, from the generated vanilla packs (CC_GENERATED_DIR; a pass
*> without them). Expected (18 section 6): the natural spawner makes several hostile mobs (zombie, skeleton, spider, creeper, ...).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFLATSPAWN-CLIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugflatspawn".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "FlatSpawn".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-FRAMES              BINARY-LONG VALUE 20.
 01 WS-ROUND               BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-WHAT                PIC X(40).
 01 WS-TITLE               BINARY-LONG VALUE SCR-TITLE.
 01 WS-HOSTILE             BINARY-LONG VALUE 0.
 01 WS-TIME                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugflatspawn: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
*>   The harness keeps hostile mobs off and the view at 2; the operator's world has the single-player defaults (hostile mobs on, view distance 8).
     CALL "SP-DEFAULTS" USING CLIENT-STATE
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 2
         PERFORM RUN-PHASE
     END-PERFORM
     STOP RUN.

 RUN-PHASE.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     IF WS-PHASE = 1
         MOVE "a new world" TO WS-WHAT
     ELSE
         MOVE "the saved world reopened from the list" TO WS-WHAT
         CALL "SP-QUIT" USING CLIENT-STATE
         CALL "SP-DEFAULTS" USING CLIENT-STATE
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-TITLE
     END-IF
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 14000 TO WS-TIME
     CALL "FLATSPAWN-NIGHT" USING WS-TIME
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 30
         CALL "CV-STEPS" USING CONVH WS-FRAMES
     END-PERFORM
     CALL "FLATSPAWN-COUNT" USING WS-HOSTILE WS-TIME
     MOVE SPACES TO TL-CASE
     STRING "acceptance bugflatspawn: given " FUNCTION TRIM(WS-WHAT) " of the single-player defaults at night when the client runs 600 frames then several hostile mobs spawn"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HOSTILE >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGFLATSPAWN-CLIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLATSPAWN-NIGHT.
*> USING time: sets the world's time of day.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME.
     MOVE L-TIME TO CW-TIME
     GOBACK.
 END PROGRAM FLATSPAWN-NIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLATSPAWN-COUNT.
*> USING hostile out, time out: the standard hostile mobs in the core's entity table and the time of day.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HOSTILE              BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HOSTILE L-TIME.
     MOVE 0 TO L-HOSTILE
     MOVE CW-TIME TO L-TIME
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 IF SM-KIND(WS-S) = 1
                     ADD 1 TO L-HOSTILE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLATSPAWN-COUNT.
