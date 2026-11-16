*> Convergence acceptance test of US8-1 to US8-6 through the client (spec.md US8; docs/protocol 18
*> hunger, 17 health): two survival Players, the host of a single-player world (Alice, an operator)
*> and a second client on a further memory connection of the same core (Bobby). The HUD shows the
*> food meter beside the hearts (20 each); standing and walking 150 ticks cost no food while the
*> saturation of a new player absorbs the exhaustion of running; the hunger effect (typed by Alice)
*> drains the food; holding the use control with a grazer flank for the eating time eats it (food
*> rises by 3, one flank leaves); with full food nothing is eaten; at food 0 starvation
*> costs health; in creative the food level neither changes nor shows. Standard commands only.
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
 01 WS-MOVED               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-HEARTS              BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-FOOD-2              BINARY-LONG.
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

*>   US8-1: the food meter beside the hearts on the survival HUD.
     CALL "METER-SHOWN" USING CONVH WS-ALICE WS-ONE WS-HEARTS
     CALL "METER-SHOWN" USING CONVH WS-ALICE WS-TWO WS-FOOD
     MOVE 0 TO WS-FOUND
     IF WS-HEARTS = 20 AND WS-FOOD = 20
         MOVE 1 TO WS-FOUND
     END-IF
     MOVE "acceptance US8-1 given a survival Player in the world then their food level is shown "
         & "on screen beside their health" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-JOINED-A * 100 + WS-JOINED-B * 10 + WS-FOUND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-2: Bobby faces +Z; 150 ticks standing, 150 walking, 150 running: the food stays 20 (a new
*>   player's saturation absorbs the exhaustion of running).
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
     COMPUTE WS-MOVED = PL-Z - WS-Z0
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
     MOVE "acceptance US8-2 given a survival Player when time passes and they stand, walk, then "
         & "run then the food level stays 20 (saturation absorbs the exhaustion) and they moved"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "standing 20 walking 20 running 20 moved 1" TO TL-EXPECTED
     MOVE WS-F0 TO WS-E1
     MOVE WS-F1 TO WS-E2
     MOVE WS-F2 TO WS-E3
     MOVE 0 TO WS-E5
     IF WS-MOVED > 20
         MOVE 1 TO WS-E5
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "standing " FUNCTION TRIM(WS-E1) " walking " FUNCTION TRIM(WS-E2) " running "
         FUNCTION TRIM(WS-E3) " moved " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-4: full food: with a grazer flank held (4 of them) nothing is eaten.
     MOVE "/clear Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/give Bobby cobolcraft:grazer_flank 4" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE -90 TO PL-PITCH
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     CALL "EAT" USING CONVH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US8-4 given a survival Player whose food level is full when they try to eat "
         & "then nothing is eaten" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "food 20 slot 4" TO TL-EXPECTED
     MOVE PL-FOOD TO WS-E1
     MOVE PL-SLOT-COUNT(1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "food " FUNCTION TRIM(WS-E1) " slot " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-3: the hunger effect drains the food (the level before below 20 after), then a grazer flank in the held
*>   slot is eaten by holding the use control for the eating time, looking up (no block aimed at).
     MOVE "/effect give Bobby minecraft:hunger 3 255" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 80 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/effect clear Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F0
     CALL "EAT" USING CONVH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F1
     MOVE "acceptance US8-3 given a survival Player holding a food item below full food when they "
         & "use the eat control for the eating time then one item leaves and food rises by its "
         & "value" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "drained 1 food rose 3 slot 3" TO TL-EXPECTED
     MOVE 0 TO WS-E1
     IF WS-F0 < 20
         MOVE 1 TO WS-E1
     END-IF
     COMPUTE WS-E2 = WS-F1 - WS-F0
     MOVE PL-SLOT-COUNT(1) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "drained " FUNCTION TRIM(WS-E1) " food rose " FUNCTION TRIM(WS-E2) " slot "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-5: the hunger effect again until food 0, regeneration off; starvation then costs health.
     MOVE "/gamerule natural_health_regeneration false" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/effect give Bobby minecraft:hunger 20 255" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 120 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-FOOD TO WS-F0
     COMPUTE WS-H0 = PL-HEALTH
     MOVE 250 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US8-5 given a survival Player whose food level is zero when time passes then "
         & "they take starvation damage" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "food 0 health fell 1" TO TL-EXPECTED
     MOVE WS-F0 TO WS-E1
     MOVE 0 TO WS-E2
     IF PL-HEALTH < WS-H0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "food " FUNCTION TRIM(WS-E1) " health fell " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-6: in creative the food meter is not shown; back in survival it shows again.
     MOVE "/effect clear Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/gamemode creative Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "METER-SHOWN" USING CONVH WS-BOBBY WS-TWO WS-FOOD
     MOVE "/gamemode survival Bobby" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     CALL "METER-SHOWN" USING CONVH WS-BOBBY WS-TWO WS-FOOD-2
     MOVE "acceptance US8-6 given a creative Player then their food level is not shown, and it "
         & "shows again in survival" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "creative shown -1 survival shown 1" TO TL-EXPECTED
     MOVE WS-FOOD TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-FOOD-2 >= 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "creative shown " FUNCTION TRIM(WS-E1) " survival shown " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
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


*> METER-SHOWN USING CONVH, client, kind (1 hearts, 2 food), shown out: the state of the HUD's meter
*> widget of that kind (12 5.4), -1 when the screen holds none (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-SHOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-KIND L-SHOWN.
     MOVE -1 TO L-SHOWN
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-METER AND SM-W-ARG(WS-I) = L-KIND
             MOVE SM-W-STATE(WS-I) TO L-SHOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM METER-SHOWN.
