*> Convergence acceptance test of US7-1 to US7-6 through the client (spec.md US7; standin-content
*> §10): two survival Players, the host of a single-player world (Alice, an operator) and a second
*> client on a further memory connection of the same core (Bobby). The host sets up states with
*> commands typed in chat (ration, vitality, relocate, mode). Bobby falls ten blocks from a pillar
*> top (12 damage, the hurt indication), is hit by Alice's pry bar through her attack control
*> (4 damage), recovers with food at the maximum (1 health per 50 ticks), dies from a fall (the
*> death screen with the cause, the death message in Alice's chat, his items on the ground),
*> respawns at the world spawn with full health and food, and in creative takes no damage and shows
*> no health.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-HEALTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us7-health".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 21.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Health".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-TEXTS               PIC X(1024).
 01 WS-LOG                 PIC X(4096).
 01 WS-NEEDLE              PIC X(64).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUND-2             BINARY-LONG.
 01 WS-HURT                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-KEY                  BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
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

*>   US7-1: the survival HUD shows current and maximum health.
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXTS
     MOVE "Health 30/30" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US7-1 given a survival Player in the world then their current and maximum "
         & "health are shown on screen" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-JOINED-A * 100 + WS-JOINED-B * 10 + WS-FOUND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US7-2 falling: food below 20 keeps recovery out of the way; a fall of 10 blocks (from 67 to the
*>   turf top at 57 in column (20, 8)) is 2 x (10 - 4) = 12 damage.
     MOVE "/ration Bobby 19" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/relocate Bobby at 20.5 67 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 0 TO WS-HURT
     PERFORM 50 TIMES
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         IF PL-HURT-UNTIL > CL-NOW-MS AND SM-WIDGET-COUNT > 0
             IF SM-W-KIND(1) = WK-OVERLAY
                 MOVE 1 TO WS-HURT
             END-IF
         END-IF
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Health 18/30" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US7-2 given a survival Player when they fall 10 blocks from a pillar top then "
         & "they lose 12 health and see that they were hurt" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "health 18 shown 1 hurt 1" TO TL-EXPECTED
     COMPUTE WS-E1 = PL-HEALTH
     MOVE WS-FOUND TO WS-E2
     MOVE WS-HURT TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "health " FUNCTION TRIM(WS-E1) " shown " FUNCTION TRIM(WS-E2) " hurt "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US7-5 and US7-2 hit by a player: Bobby stands 1.5 blocks east of Alice, who faces east, holds
*>   the pry bar (key 9: hotbar slot 8) and attacks: 4 damage.
     MOVE "/relocate Bobby at 6.0 54 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     COMPUTE WS-H0 = PL-HEALTH
     CALL "ATTACK" USING CONVH WS-ALICE
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US7-5 given player combat on when the Player attacks another player within "
         & "reach holding the pry bar then the target loses 4 health and sees that they were hurt"
         TO TL-CASE
     MOVE "before 18 after 14 hurt 1" TO TL-EXPECTED
     MOVE WS-H0 TO WS-E1
     COMPUTE WS-E2 = PL-HEALTH
     MOVE 0 TO WS-E3
     IF PL-HURT-UNTIL > CL-NOW-MS
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "before " FUNCTION TRIM(WS-E1) " after " FUNCTION TRIM(WS-E2) " hurt "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US7-3: with food at the maximum, 1 health per 50 ticks: 2 in 105 ticks.
     MOVE "/ration Bobby full" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     COMPUTE WS-H0 = PL-HEALTH
     MOVE 105 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     COMPUTE WS-H1 = PL-HEALTH
     MOVE "acceptance US7-3 given a survival Player with less than full health and full food when "
         & "time passes without damage then health recovers 1 per 50 ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1416 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 * 100 + WS-H1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US7-4: health 4, then the 10-block fall kills: the death screen with the cause, the death
*>   message in the other Player's chat, the inventory (slots 0 to 9) dropped as 10 ground items.
     MOVE "/vitality Bobby 4" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/relocate Bobby at 20.5 67 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE SCR-DEATH TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-BOBBY WS-SCREEN WS-REACHED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-LOG
     MOVE "Bobby misjudged the drop" TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-LOG WS-NEEDLE WS-FOUND
     MOVE "acceptance US7-4 given a survival Player whose health reaches zero when they die then a "
         & "death screen shows the cause and other players see the death message in chat"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "screen 1 Run Terminated|Bobby misjudged the drop|Return to Spawn chat 1" TO TL-EXPECTED
     MOVE WS-REACHED TO WS-E1
     MOVE WS-FOUND TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-TEXTS) " chat "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-RESPAWN TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-BOBBY WS-ACTION WS-ARG WS-FOUND
     MOVE SCR-WORLD TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-BOBBY WS-SCREEN WS-REACHED
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD PL-SLOT-COUNT(WS-I) TO WS-ITEMS
     END-PERFORM
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     COMPUTE WS-E1 = PL-HEALTH
     MOVE PL-FOOD TO WS-E2
     MOVE WS-ITEMS TO WS-E3
*>   The ten ground items of the death drop, as the other Player's client shows them.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-DROPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1 AND EN-X(WS-I) > 18
             ADD 1 TO WS-DROPS
         END-IF
     END-PERFORM
     MOVE WS-DROPS TO WS-E4
     MOVE "acceptance US7-4 when the dead Player chooses to respawn then they reappear at the world "
         & "spawn point in the main dimension with full health and food, their inventory dropped "
         & "on the ground" TO TL-CASE
     MOVE "cobolcraft:main 4.5/54.0/8.5 health 30 food 24 items 0 drops 10" TO TL-EXPECTED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(PL-DIM-NAME) " " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/"
         FUNCTION TRIM(WS-F3) " health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2)
         " items " FUNCTION TRIM(WS-E3) " drops " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US7-6: in creative the same 10-block fall does nothing and no health is shown.
     MOVE "/mode Bobby creative" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/relocate Bobby at 20.5 67 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 50 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "CV-TEXTS" USING CONVH WS-BOBBY WS-TEXTS
     MOVE "Health " TO WS-NEEDLE
     CALL "TEXT-HAS" USING WS-TEXTS WS-NEEDLE WS-FOUND
     MOVE "acceptance US7-6 given a creative Player when they fall 10 blocks then they take no "
         & "damage and no health is shown" TO TL-CASE
     MOVE "mode 1 y 57.0 health 30 shown 0" TO TL-EXPECTED
     COMPUTE WS-F2 ROUNDED = PL-Y
     MOVE PL-MODE TO WS-E1
     COMPUTE WS-E2 = PL-HEALTH
     MOVE WS-FOUND TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "mode " FUNCTION TRIM(WS-E1) " y " FUNCTION TRIM(WS-F2) " health "
         FUNCTION TRIM(WS-E2) " shown " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US7-HEALTH.

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

*> ATTACK USING CONVH, client: the left mouse button pressed (one frame) and released (the next).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX.
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-UP
     GOBACK.
 END PROGRAM ATTACK.
