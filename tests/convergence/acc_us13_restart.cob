*> Convergence acceptance test of US13-4 and SC-003 (spec.md US13; world-folder.md; standin §9, §10,
*> §11, §15, §16): the server program runs on loopback in process. Alice, a first-time survival
*> Player, builds (places a greystone through the place control), throws one item (it rests on the
*> ground), is hurt and gets hungry (the vitality and ration commands at the console), travels to
*> cobolcraft:subroutine (relocate at the console) and leaves (pause menu, Disconnect). The server is
*> stopped (shutdown at the console) and started again on the same folder (CORE-WORLD-OPEN empties
*> every table, so everything comes from disk). Alice rejoins: she is in the same dimension at the
*> same spot with the same inventory, health, food and game mode; taken back to cobolcraft:main she
*> sees the block she placed and the item she threw, where they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-RESTART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us13-restart".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|default-game-mode=survival|weather-changes=false".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-REJOINED            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG VALUE CC-BUTTON-RIGHT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-KEY-Q               BINARY-LONG VALUE CC-KEY-Q.
 01 WS-KEY-ESC             BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PLACED-BEFORE       BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-BEFORE              PIC X(1024).
 01 WS-AFTER               PIC X(1024).
 01 WS-ITEM-BEFORE         PIC X(256).
 01 WS-ITEM-AFTER          PIC X(256).
 01 WS-DIM                 PIC X(64).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Build: look down to the west and place the held greystone on the face aimed at.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 90 TO PL-YAW
     MOVE 60 TO PL-PITCH
     MOVE 2 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE TG-HIT TO WS-HIT
     MOVE TG-X TO WS-PX
     MOVE TG-Y TO WS-PY
     MOVE TG-Z TO WS-PZ
     EVALUATE TG-FACE
         WHEN 0 SUBTRACT 1 FROM WS-PY
         WHEN 1 ADD 1 TO WS-PY
         WHEN 2 SUBTRACT 1 FROM WS-PZ
         WHEN 3 ADD 1 TO WS-PZ
         WHEN 4 SUBTRACT 1 FROM WS-PX
         WHEN 5 ADD 1 TO WS-PX
     END-EVALUATE
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-RIGHT WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-RIGHT WS-UP
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-PLACED-BEFORE WS-SKY WS-BLOCK

*>   Throw one item east (level look); it flies about two blocks and rests on the ground.
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     CALL "CV-STEP" USING CONVH
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY-Q
     MOVE 60 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "RS-GROUND-ITEM" USING CONVH WS-ALICE WS-ITEM-BEFORE

*>   Hurt and hungry, then off to the subroutine (standing on its slag floor: h = 35 at (10, 10)).
     MOVE "vitality Alice 17" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE "ration Alice 9" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE "relocate Alice at 10.5 36 10.5 subroutine" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE "cobolcraft:subroutine" TO WS-DIM
     CALL "RS-UNTIL-DIM" USING CONVH WS-ALICE WS-DIM
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "RS-SNAPSHOT" USING CONVH WS-ALICE WS-BEFORE

*>   Alice leaves; the server stops and starts again on the same world folder.
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY-ESC
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-SERVER-STOP" USING CONVH
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-REJOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "RS-SNAPSHOT" USING CONVH WS-ALICE WS-AFTER

     MOVE "acceptance US13-4 SC-003 given a Player who built, was hurt, got hungry, threw an item, "
         & "changed dimension and left when the server restarts and they rejoin then dimension, "
         & "spot, inventory, health, food and mode are as left" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     STRING "rejoined 1 " FUNCTION TRIM(WS-BEFORE) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-REJOINED TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "rejoined " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-AFTER) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US13-4 the state before the stop is the one the Player made: subroutine, "
         & "health 17, food 9, survival, one greystone placed and one thrown" TO TL-CASE
     MOVE "cobolcraft:subroutine mode 0 health 17.0 food 9 inv 1:62x2" TO TL-EXPECTED
     MOVE 0 TO WS-I
     INSPECT WS-BEFORE TALLYING WS-I FOR ALL " mode 0 health 17.0 food 9 inv 1:62x2 "
     MOVE WS-BEFORE TO TL-OBSERVED
     IF WS-I = 1 AND WS-BEFORE(1:22) = "cobolcraft:subroutine "
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Back to the main dimension, a dozen blocks south of the spawn (out of pickup range).
     MOVE "relocate Alice at 4.5 54 20.5 main" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE "cobolcraft:main" TO WS-DIM
     CALL "RS-UNTIL-DIM" USING CONVH WS-ALICE WS-DIM
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-STATE NOT = 0
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-STATE WS-SKY WS-BLOCK
     END-PERFORM
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "RS-GROUND-ITEM" USING CONVH WS-ALICE WS-ITEM-AFTER
     MOVE "acceptance US13-4 given the block placed and the item thrown before the stop when the "
         & "Player is back in that dimension then the block is there and the item lies where it was"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-PLACED-BEFORE TO WS-E1
     STRING "aimed 1 placed " FUNCTION TRIM(WS-E1) " item "
         FUNCTION TRIM(WS-ITEM-BEFORE) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-HIT TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "aimed " FUNCTION TRIM(WS-E1) " placed " FUNCTION TRIM(WS-E2) " item "
         FUNCTION TRIM(WS-ITEM-AFTER) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US13-4 the placed block is the held greystone and the thrown item one "
         & "greystone" TO TL-CASE
     MOVE "placed 2 item 1x2" TO TL-EXPECTED
     MOVE WS-PLACED-BEFORE TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "placed " FUNCTION TRIM(WS-E1) " item " WS-ITEM-BEFORE(1:3) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-SERVER-STOP" USING CONVH
     STOP RUN.
 END PROGRAM ACC-US13-RESTART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-UNTIL-DIM.
*> USING CONVH, client, dimension name (PIC X(64)): frames (at most 300) until the client's
*> dimension is that one and its player is loaded and positioned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-DIM.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR WS-DONE = 1
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
         IF PL-DIM-NAME = L-DIM AND PL-LOADED = 1
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS-UNTIL-DIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-SNAPSHOT.
*> USING CONVH, client, text out (PIC X(1024)): "<dimension> at <x>/<y>/<z> mode <m> health <h>
*> food <f> inv <slot>:<count>x<item> ..." of the client's player (2 decimals, 1 for health),
*> non-empty slots only, slot numbers 1-based.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-F1                  PIC -(7)9.99.
 01 WS-F2                  PIC -(7)9.99.
 01 WS-F3                  PIC -(7)9.99.
 01 WS-H                   PIC -(4)9.9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     COMPUTE WS-H ROUNDED = PL-HEALTH
     MOVE PL-MODE TO WS-E1
     MOVE PL-FOOD TO WS-E2
     STRING FUNCTION TRIM(PL-DIM-NAME) " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/"
         FUNCTION TRIM(WS-F3) " mode " FUNCTION TRIM(WS-E1) " health " FUNCTION TRIM(WS-H)
         " food " FUNCTION TRIM(WS-E2) " inv" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             MOVE WS-I TO WS-E1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E3
             STRING " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     GOBACK.
 END PROGRAM RS-SNAPSHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-GROUND-ITEM.
*> USING CONVH, client, text out (PIC X(256)): "<count>x<item> at <x>/<y>/<z>" (2 decimals) of the
*> first loose_item (entity type 1) in the client's entity replica, or "none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-F1                  PIC -(7)9.99.
 01 WS-F2                  PIC -(7)9.99.
 01 WS-F3                  PIC -(7)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE "none" TO L-TEXT
     MOVE 0 TO WS-R
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR WS-R > 0
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1
             MOVE WS-I TO WS-R
         END-IF
     END-PERFORM
     IF WS-R > 0
         COMPUTE WS-F1 ROUNDED = EN-X(WS-R)
         COMPUTE WS-F2 ROUNDED = EN-Y(WS-R)
         COMPUTE WS-F3 ROUNDED = EN-Z(WS-R)
         MOVE EN-STACK-COUNT(WS-R) TO WS-E1
         MOVE EN-STACK-ITEM(WS-R) TO WS-E2
         MOVE SPACES TO L-TEXT
         STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " at " FUNCTION TRIM(WS-F1) "/"
             FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3) DELIMITED BY SIZE INTO L-TEXT
     END-IF
     GOBACK.
 END PROGRAM RS-GROUND-ITEM.
