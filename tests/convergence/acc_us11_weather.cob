*> Convergence acceptance test of US11-1, US11-2 and US11-4 (spec.md US11; standin-content §14
*> weather kinds, changes, wire and drawing; FR-009 weather-changes): two Players in one single-player
*> world (the host's in-process core, a second client over a further memory connection). The weather
*> is forced by the weather command (skies) from the host's chat line; both clients' weather kind
*> (PL-WEATHER, from the Game Events), precipitation quads (RL-WX-COUNT) and sky colour are read.
*> A timed weather ends after its time while weather changes are on; with the setting off (the world
*> reopened with it off) it stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us11-weather".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Weather".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 7.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-A                   PIC X(64).
 01 WS-B                   PIC X(64).
 01 WS-CLEAR-SKY           PIC X(64).
 01 WS-SKY                 PIC X(64).
 01 WS-SAME                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE "/clock 6000" TO WS-LINE
     MOVE 11 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     CALL "U11-SKY" USING CONVH WS-ALICE WS-CLEAR-SKY

*>   US11-2 and US11-1: a hailstorm, then drizzle, forced by the weather command.
     MOVE "/skies main hailstorm" TO WS-LINE
     MOVE 21 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE "acceptance US11-2 given two Players in the main dimension when the weather becomes a "
         & "hailstorm (weather command) then both see the hailstorm" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Alice kind 2 quads 1 | Bobby kind 2 quads 1" TO TL-EXPECTED
     PERFORM BOTH-KINDS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/skies main drizzle" TO WS-LINE
     MOVE 19 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE "acceptance US11-2 given two Players in the main dimension when the weather becomes "
         & "drizzle then both see drizzle" TO TL-CASE
     MOVE "Alice kind 1 quads 1 | Bobby kind 1 quads 1" TO TL-EXPECTED
     PERFORM BOTH-KINDS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "U11-SKY" USING CONVH WS-ALICE WS-SKY
     MOVE "acceptance US11-1 given the Player in the main dimension when the weather changes to "
         & "drizzle then the world shows precipitation quads and the sky colour changes" TO TL-CASE
     MOVE "sky changed" TO TL-EXPECTED
     MOVE "sky unchanged" TO TL-OBSERVED
     IF WS-SKY NOT = WS-CLEAR-SKY
         MOVE "sky changed" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/skies main clear" TO WS-LINE
     MOVE 17 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     CALL "U11-SKY" USING CONVH WS-ALICE WS-SKY
     MOVE "acceptance US11-1 when the weather turns clear then neither client draws "
         & "precipitation and the sky is the clear sky again" TO TL-CASE
     MOVE "Alice kind 0 quads 0 | Bobby kind 0 quads 0 sky clear" TO TL-EXPECTED
     PERFORM BOTH-KINDS
     IF WS-SKY = WS-CLEAR-SKY
         MOVE SPACES TO TL-OBSERVED
         STRING "Alice " FUNCTION TRIM(WS-A) " | Bobby " FUNCTION TRIM(WS-B) " sky clear"
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With weather changes on, a clear sky timed for 1 second (20 ticks) ends on its own; both
*>   clients see the new kind in the same frame.
     MOVE "/skies main clear 1" TO WS-LINE
     MOVE 19 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 1 TO WS-SAME
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "CV-STEP" USING CONVH
         PERFORM BOTH-KINDS
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE PL-WEATHER TO WS-KIND
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         IF PL-WEATHER NOT = WS-KIND
             MOVE 0 TO WS-SAME
         END-IF
         IF WS-KIND NOT = WX-CLEAR
             MOVE 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     MOVE "acceptance US11-2 given weather changes on when a timed clear sky runs out then the "
         & "weather changes and both Players see the same kind in every frame" TO TL-CASE
     MOVE "changed 1 same in every frame 1" TO TL-EXPECTED
     MOVE WS-CHANGED TO WS-E1
     MOVE WS-SAME TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "changed " FUNCTION TRIM(WS-E1) " same in every frame " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US11-4: the host quits, the world is reopened with weather changes off.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO CS-WEATHER-CHANGES
     MOVE CORE-SETTINGS TO SP-SETTINGS
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE "/skies main drizzle 1" TO WS-LINE
     MOVE 21 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 80 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US11-4 given the weather-change setting off when time passes (80 ticks, "
         & "past the 20 ticks a timed drizzle would last) then the weather stays as it is"
         TO TL-CASE
     MOVE "joined 1 kind 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE PL-WEATHER TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " kind " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SAY-AND-WAIT.
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     .

 BOTH-KINDS.
     CALL "U11-KIND" USING CONVH WS-ALICE WS-A
     CALL "U11-KIND" USING CONVH WS-BOBBY WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-A) " | Bobby " FUNCTION TRIM(WS-B) DELIMITED BY SIZE
         INTO TL-OBSERVED
     .
 END PROGRAM ACC-US11-WEATHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U11-KIND.
*> USING CONVH, client index, text out (PIC X(64)): "kind <PL-WEATHER> quads <1 if the last render
*> list holds precipitation vertices, else 0>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E1                  PIC -(9)9.
 01 WS-QUADS               PIC 9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE PL-WEATHER TO WS-E1
     MOVE 0 TO WS-QUADS
     IF RL-WX-COUNT > 0
         MOVE 1 TO WS-QUADS
     END-IF
     MOVE SPACES TO L-TEXT
     STRING "kind " FUNCTION TRIM(WS-E1) " quads " WS-QUADS DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM U11-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U11-SKY.
*> USING CONVH, client index, text out (PIC X(64)): the clear colour of the client's sky
*> (SK-R, SK-G, SK-B in thousandths).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     COMPUTE WS-E1 ROUNDED = SK-R * 1000
     COMPUTE WS-E2 ROUNDED = SK-G * 1000
     COMPUTE WS-E3 ROUNDED = SK-B * 1000
     MOVE SPACES TO L-TEXT
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM U11-SKY.
