*> Convergence acceptance test of US8-1 to US8-6 through the client (spec.md US8; standin-content
*> §11): two survival Players, the host of a single-player world (Alice, an operator) and a second
*> client on a further memory connection of the same core (Bobby). The HUD shows food beside
*> health; standing and walking 150 ticks cost no food point while running (Left Control with W)
*> 150 ticks does; holding the eat control with a grazer flank (value 3) for the eating time eats
*> one; with full food nothing is eaten; at food 0 starvation costs 1 health per 60 ticks; in
*> creative the food level neither changes nor shows. The host sets up states with commands typed
*> in chat (ration, empty, supply, mode).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-HUNGER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us8-hunger".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 21.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Hunger".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-TEXTS               PIC X(1024).
 01 WS-NEEDLE              PIC X(64).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUND-2             BINARY-LONG.
 01 WS-F0                  BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KEY-2               BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-RIGHT.
 01 WS-BDOWN               BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-BUP                 BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 WS-E5                  PIC -(5)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED-A
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED-B
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   US8-1: food beside health on the survival HUD.
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXTS
     MOVE "Health 30/30|Food 24/24" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US8-1 given a survival Player in the world then their food level is shown "
         & "on screen beside their health" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-JOINED-A * 100 + WS-JOINED-B * 10 + WS-FOUND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-2: Bobby faces +Z (flat turf); 150 ticks standing, 150 walking, 150 running.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 150 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F0
     MOVE PL-Z TO WS-Z0
     MOVE CC-KEY-W TO WS-KEY
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-DOWN
     MOVE 149 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F1
     COMPUTE WS-E4 = PL-Z - WS-Z0
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY-2
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY-2 WS-DOWN
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-DOWN
     MOVE 149 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-UP
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY-2 WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F2
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Food 23/24" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US8-2 given a survival Player when time passes and they stand, walk 29 "
         & "blocks, then run 42 then the food level falls by one only once running adds its "
         & "exhaustion" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "standing 24 walking 24 walked 29 running 23 shown 1" TO TL-EXPECTED
     MOVE WS-F0 TO WS-E1
     MOVE WS-F1 TO WS-E2
     MOVE WS-F2 TO WS-E3
     MOVE WS-FOUND TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "standing " FUNCTION TRIM(WS-E1) " walking " FUNCTION TRIM(WS-E2) " walked "
         FUNCTION TRIM(WS-E4) " running " FUNCTION TRIM(WS-E3) " shown " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-3: a grazer flank (food value 3) in the held slot, food 10, the eat control held for longer
*>   than the eating time (30 ticks), looking up (no block aimed at).
     MOVE "/empty Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/supply Bobby grazer_flank 3" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/ration Bobby 10" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE -90 TO PL-PITCH
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     CALL "EAT" USING CONVH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US8-3 given a survival Player holding a food item below full food when they "
         & "use the eat control for the eating time then one item leaves and food rises by its "
         & "value" TO TL-CASE
     MOVE "food 13 slot 2x12" TO TL-EXPECTED
     PERFORM OBSERVE-EATING
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-4: full food: nothing is eaten.
     MOVE "/ration Bobby full" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     CALL "EAT" USING CONVH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US8-4 given a survival Player whose food level is full when they try to eat "
         & "then nothing is eaten" TO TL-CASE
     MOVE "food 24 slot 2x12" TO TL-EXPECTED
     PERFORM OBSERVE-EATING
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-5: food 0: 1 starvation damage per 60 ticks, 2 in 125 ticks.
     MOVE "/ration Bobby zero" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     COMPUTE WS-H0 = PL-HEALTH
     MOVE 125 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Health 28/30|Food 0/24" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US8-5 given a survival Player whose food level is zero when time passes then "
         & "they take starvation damage, 1 per 60 ticks" TO TL-CASE
     MOVE "before 30 after 28 shown 1" TO TL-EXPECTED
     MOVE WS-H0 TO WS-E1
     COMPUTE WS-E2 = PL-HEALTH
     MOVE WS-FOUND TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "before " FUNCTION TRIM(WS-E1) " after " FUNCTION TRIM(WS-E2) " shown "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-6: in creative, running 150 ticks leaves food unchanged and it is not shown; back in
*>   survival it shows the same value.
     MOVE "/ration Bobby 15" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/mode Bobby creative" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 0 TO PL-PITCH
     MOVE CC-KEY-W TO WS-KEY
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY-2 WS-DOWN
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-DOWN
     MOVE 149 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-UP
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY-2 WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F1
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Food " TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "/mode Bobby survival" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Food 15/24" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND-2
     MOVE "acceptance US8-6 given a creative Player when time passes and they run then their food "
         & "level does not change and is not shown" TO TL-CASE
     MOVE "food 15 shown 0 survival again shows 1" TO TL-EXPECTED
     MOVE WS-F1 TO WS-E1
     MOVE WS-FOUND TO WS-E2
     MOVE WS-FOUND-2 TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "food " FUNCTION TRIM(WS-E1) " shown " FUNCTION TRIM(WS-E2)
         " survival again shows " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 OBSERVE-EATING.
     MOVE PL-FOOD TO WS-E1
     MOVE PL-SLOT-COUNT(1) TO WS-E2
     MOVE PL-SLOT-ITEM(1) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "food " FUNCTION TRIM(WS-E1) " slot " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM ACC-US8-HUNGER.

*> EAT USING CONVH, client: the right mouse button held for 40 frames (2 s, longer than the eating
*> time), released, then five frames (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-RIGHT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX.
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-DOWN
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     GOBACK.
 END PROGRAM EAT.

*> SAY-LINE USING CONVH, client, line (PIC X(64), trailing spaces dropped): the line sent through
*> the chat control, then five frames (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SAY-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-LINE                 PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-LINE.
     MOVE 64 TO WS-LENGTH
     PERFORM UNTIL WS-LENGTH = 0 OR L-LINE(WS-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-LENGTH
     END-PERFORM
     CALL "CV-SAY" USING CONVH L-INDEX L-LINE WS-LENGTH
     CALL "CV-STEPS" USING CONVH WS-FIVE
     GOBACK.
 END PROGRAM SAY-LINE.

*> TEXT-HAS USING text (PIC X(1024) or longer), needle (PIC X(64), trailing spaces dropped), found
*> out: 1 when the text contains the needle.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEXT-HAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-NEEDLE               PIC X(64).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-NEEDLE L-FOUND.
     MOVE 64 TO WS-LENGTH
     PERFORM UNTIL WS-LENGTH = 0 OR L-NEEDLE(WS-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-LENGTH
     END-PERFORM
     MOVE 0 TO WS-COUNT
     INSPECT L-TEXT TALLYING WS-COUNT FOR ALL L-NEEDLE(1:WS-LENGTH)
     MOVE 0 TO L-FOUND
     IF WS-COUNT > 0
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM TEXT-HAS.

