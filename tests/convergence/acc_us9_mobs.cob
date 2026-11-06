*> Convergence acceptance test of US9-1 to US9-5 (spec.md US9; standin-content §12 mobs, §10.4
*> attacks, §3 entity types): two survival Players in one single-player world (the host's
*> in-process core, the second client over a further memory connection), hostile mobs on. Mobs are
*> brought in with the spawn-mob command (conjure) from the host's chat line; everything else goes
*> through the clients: their entity replicas (type, position), render lists, health, the attack
*> control (left button aimed at the mob, the pry bar held with key 9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-MOBS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us9-mobs".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 19.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Mobs".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-GRAZER              BINARY-LONG.
 01 WS-ABEND               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUND-B             BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-MOVED               FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-FIRST-HURT          FLOAT-SHORT.
 01 WS-A-TEXT              PIC X(64).
 01 WS-B-TEXT              PIC X(64).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-F1                  PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE CORE-SETTINGS TO SP-SETTINGS
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE "/clock 1000" TO WS-LINE
     MOVE 11 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT

*>   US9-1: a sodgrazer brought in 3 blocks above the ground east of the spawn point falls, rests
*>   and is drawn by both clients.
     MOVE "/conjure sodgrazer 10 58 8" TO WS-LINE
     MOVE 26 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 2 TO WS-TYPE
     MOVE 10 TO WS-TX
     MOVE 8 TO WS-TZ
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U9-FIND" USING CLIENT-STATE WS-TYPE WS-TX WS-TZ WS-GRAZER
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-BX WS-BY WS-BZ WS-FOUND-B
     MOVE "acceptance US9-1 given a world when a sodgrazer appears then both Players see it with "
         & "its type where it landed on the ground and it is drawn" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Alice 1 y 55.0 Bobby 1 same 1 drawn 1" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE WS-FOUND-B TO WS-E2
     COMPUTE WS-F1 ROUNDED = WS-Y
     PERFORM SAME-POSITION
     MOVE WS-SAME TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-E1) " y " FUNCTION TRIM(WS-F1) " Bobby "
         FUNCTION TRIM(WS-E2) " same " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     IF RL-EN-COUNT > 0
         STRING TL-OBSERVED DELIMITED BY "  " " drawn 1" DELIMITED BY SIZE INTO WS-LINE
     ELSE
         STRING TL-OBSERVED DELIMITED BY "  " " drawn 0" DELIMITED BY SIZE INTO WS-LINE
     END-IF
     MOVE WS-LINE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-1 and US9-5: it wanders on its own; both clients show the same position every frame.
     MOVE WS-X TO WS-X0
     MOVE WS-Z TO WS-Z0
     MOVE 1 TO WS-SAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-SAME = 0
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-BX WS-BY WS-BZ WS-FOUND-B
         PERFORM SAME-POSITION
     END-PERFORM
     COMPUTE WS-MOVED = FUNCTION SQRT((WS-X - WS-X0) ** 2 + (WS-Z - WS-Z0) ** 2)
     MOVE "acceptance US9-1 and US9-5 given a sodgrazer near two Players when time passes (400 "
         & "ticks) then it moves around on its own and both see the same movement in every frame"
         TO TL-CASE
     MOVE "moved 1 same 1" TO TL-EXPECTED
     MOVE 0 TO WS-E1
     IF WS-MOVED > 0.5
         MOVE 1 TO WS-E1
     END-IF
     MOVE WS-SAME TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "moved " FUNCTION TRIM(WS-E1) " same " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-3: Bobby is moved next to the passive mob and stays there.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
     MOVE SPACES TO WS-LINE
     COMPUTE WS-E1 = FUNCTION INTEGER(WS-X) + 1
     COMPUTE WS-E2 = FUNCTION INTEGER(WS-Y) + 1
     COMPUTE WS-E3 = FUNCTION INTEGER(WS-Z)
     STRING "/relocate Bobby at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 100 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
     MOVE "acceptance US9-3 given a passive mob when the Player approaches it (within 2 blocks for "
         & "100 ticks) then it does not attack: their health stays full" TO TL-CASE
     MOVE "near 1 health 30.0" TO TL-EXPECTED
     MOVE 0 TO WS-E1
     IF FUNCTION ABS(WS-X - PL-X) < 4 AND FUNCTION ABS(WS-Z - PL-Z) < 4
         MOVE 1 TO WS-E1
     END-IF
     COMPUTE WS-F1 ROUNDED = PL-HEALTH
     MOVE SPACES TO TL-OBSERVED
     STRING "near " FUNCTION TRIM(WS-E1) " health " FUNCTION TRIM(WS-F1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-4 and US9-5: Bobby steps away (16 blocks south, where US9-2 needs him); Alice, moved
*>   beside the sodgrazer, holds the pry bar (key 9: hotbar slot 8, 4 damage) and attacks with the
*>   left button, once per hurt cooldown (12 ticks), until it is defeated (8 health).
     MOVE "/relocate Bobby at 4 56 24" TO WS-LINE
     MOVE 26 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
     MOVE SPACES TO WS-LINE
     COMPUTE WS-E1 = FUNCTION INTEGER(WS-X) - 2
     COMPUTE WS-E2 = FUNCTION INTEGER(WS-Y) + 1
     COMPUTE WS-E3 = FUNCTION INTEGER(WS-Z)
     STRING "/relocate Alice at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 1 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20 OR WS-FOUND = 0
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-X TO WS-X0
             MOVE WS-Z TO WS-Z0
             COMPUTE WS-TY = WS-Y + 0.45
             CALL "U9-AIM" USING CLIENT-STATE WS-X WS-TY WS-Z
             CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
             CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-UP
             MOVE 12 TO WS-N
             CALL "CV-STEPS" USING CONVH WS-N
         END-IF
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 1 TO WS-TYPE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-X WS-Y WS-Z WS-FOUND
     CALL "U9-FIND" USING CLIENT-STATE WS-TYPE WS-X0 WS-Z0 WS-ITEM
     CALL "U9-STACK" USING CLIENT-STATE WS-ITEM WS-A-TEXT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "U9-POS" USING CLIENT-STATE WS-GRAZER WS-BX WS-BY WS-BZ WS-FOUND-B
     CALL "U9-STACK" USING CLIENT-STATE WS-ITEM WS-B-TEXT
     MOVE "acceptance US9-4 and US9-5 given the Player attacks a sodgrazer when its health reaches "
         & "zero then it disappears for both Players and its yield (2 grazer_flank) lies on the "
         & "ground where it was defeated for both" TO TL-CASE
     MOVE "Alice mob 0 item 2x12 | Bobby mob 0 item 2x12" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE WS-FOUND-B TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice mob " FUNCTION TRIM(WS-E1) " item " FUNCTION TRIM(WS-A-TEXT) " | Bobby mob "
         FUNCTION TRIM(WS-E2) " item " FUNCTION TRIM(WS-B-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US9-2 and US9-5: Bobby is 16 blocks south; an abend appears 4 blocks from him, notices him
*>   (the nearest survival player), pursues and attacks.
     MOVE "/relocate Alice at 4 56 4" TO WS-LINE
     MOVE 25 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/conjure abend 4 56 28" TO WS-LINE
     MOVE 22 TO WS-LINE-LENGTH
     PERFORM SAY-AND-WAIT
     MOVE 3 TO WS-TYPE
     MOVE 4 TO WS-TX
     MOVE 28 TO WS-TZ
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "U9-FIND" USING CLIENT-STATE WS-TYPE WS-TX WS-TZ WS-ABEND
     MOVE PL-HEALTH TO WS-HEALTH WS-FIRST-HURT
     MOVE 1 TO WS-SAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-SAME = 0
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "U9-POS" USING CLIENT-STATE WS-ABEND WS-X WS-Y WS-Z WS-FOUND
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         CALL "U9-POS" USING CLIENT-STATE WS-ABEND WS-BX WS-BY WS-BZ WS-FOUND-B
         PERFORM SAME-POSITION
         IF PL-HEALTH < WS-FIRST-HURT AND WS-FIRST-HURT = WS-HEALTH
             MOVE PL-HEALTH TO WS-FIRST-HURT
         END-IF
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US9-2 given a hostile abend and a survival Player within its notice range "
         & "when it notices them then it moves toward them and attacks: the first hit takes 3"
         TO TL-CASE
     MOVE "found 1 close 1 hurt 1" TO TL-EXPECTED
     MOVE 0 TO WS-E1 WS-E2
     IF FUNCTION ABS(WS-BX - PL-X) < 2 AND FUNCTION ABS(WS-BZ - PL-Z) < 2
         MOVE 1 TO WS-E1
     END-IF
     IF WS-FIRST-HURT = WS-HEALTH - 3
         MOVE 1 TO WS-E2
     END-IF
     MOVE WS-FOUND-B TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E3) " close " FUNCTION TRIM(WS-E1) " hurt " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-5 given two Players near the same abend when it moves and attacks then "
         & "both see the same movement in every frame" TO TL-CASE
     MOVE "same 1" TO TL-EXPECTED
     MOVE WS-SAME TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "same " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SAY-AND-WAIT.
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     .

*>   WS-SAME 0 when the positions (WS-X/Y/Z on Alice's client, WS-BX/BY/BZ on Bobby's) differ.
 SAME-POSITION.
     IF WS-FOUND NOT = WS-FOUND-B OR FUNCTION ABS(WS-X - WS-BX) > 0.000001
             OR FUNCTION ABS(WS-Y - WS-BY) > 0.000001 OR FUNCTION ABS(WS-Z - WS-BZ) > 0.000001
         MOVE 0 TO WS-SAME
     ELSE
         MOVE 1 TO WS-SAME
     END-IF
     .
 END PROGRAM ACC-US9-MOBS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U9-FIND.
*> USING CLIENT-STATE, entity type, x, z (FLOAT-LONG), id out: the replica's entity of that type
*> nearest to (x, z) horizontally; 0 when there is none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TYPE L-X L-Z L-ID.
     MOVE 0 TO L-ID
     MOVE 1000000 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = L-TYPE
             COMPUTE WS-D = (EN-X(WS-I) - L-X) ** 2 + (EN-Z(WS-I) - L-Z) ** 2
             IF WS-D < WS-BEST
                 MOVE WS-D TO WS-BEST
                 MOVE EN-ID(WS-I) TO L-ID
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM U9-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U9-POS.
*> USING CLIENT-STATE, entity id, x, y, z out (FLOAT-LONG), found out: the replica's position of
*> that entity; found 0 (and zeros) when the replica does not hold it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND L-X L-Y L-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR L-FOUND = 1
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = L-ID AND L-ID > 0
             MOVE 1 TO L-FOUND
             MOVE EN-X(WS-I) TO L-X
             MOVE EN-Y(WS-I) TO L-Y
             MOVE EN-Z(WS-I) TO L-Z
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM U9-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U9-STACK.
*> USING CLIENT-STATE, entity id, text out (PIC X(64)): "<count>x<item>" of that ground item in the
*> replica, or "none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TEXT.
     MOVE "none" TO L-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = L-ID AND L-ID > 0
             MOVE EN-STACK-COUNT(WS-I) TO WS-E1
             MOVE EN-STACK-ITEM(WS-I) TO WS-E2
             MOVE SPACES TO L-TEXT
             STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM U9-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U9-AIM.
*> USING CLIENT-STATE, x, y, z (FLOAT-LONG): turns the local player to look from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X: yaw = atan2(-dx, dz); positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - (PL-Y + 1.6)
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     EVALUATE TRUE
         WHEN WS-DZ > 0
             COMPUTE WS-YAW = FUNCTION ATAN(- WS-DX / WS-DZ)
         WHEN WS-DZ < 0
             COMPUTE WS-YAW = FUNCTION ATAN(- WS-DX / WS-DZ) + FUNCTION PI
         WHEN WS-DX < 0
             COMPUTE WS-YAW = FUNCTION PI / 2
         WHEN OTHER
             COMPUTE WS-YAW = - FUNCTION PI / 2
     END-EVALUATE
     COMPUTE PL-YAW = WS-YAW * 180 / FUNCTION PI
     COMPUTE PL-PITCH = FUNCTION ATAN(- WS-DY / WS-H) * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM U9-AIM.
