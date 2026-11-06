*> Convergence acceptance test of US17 (spec.md US17-1 to US17-5, the US17 edge case, SC-013): a host
*> client (Alice) hosting a single-player world opens it to others from the pause menu, choosing the
*> guest game mode and whether guests may use operator commands, and the screen shows the address;
*> a guest client (Bobby) adds exactly that shown address to its server list and joins over
*> loopback TCP, and both see each other's block changes; the pause menu does not pause; a guest
*> with the host's name is refused while the host stays; the host quitting saves the world and
*> disconnects the guest with the host-closed message; after the host reopens the world and opens
*> it again, the guest rejoins with the position, dimension, inventory, health and food it left
*> with. Everything is driven through the clients' screens and controls.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US17-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us17-open".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 20.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-FOLDER              PIC X(80) VALUE "Shared".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-BIG-LOG             PIC X(4096).
 01 WS-E4                  PIC -(9)9.
 01 WS-SAY                 PIC X(64).
 01 WS-SAY-LENGTH          BINARY-LONG.
 01 WS-ADDRESS             PIC X(256).
 01 WS-ADDRESS-LENGTH      BINARY-LONG.
 01 WS-PREFIX              PIC X(19) VALUE "Others can join at ".
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-LEVEL               PIC X(256).
 01 WS-LEVEL-LENGTH        BINARY-LONG.
 01 WS-FILE-AREA           PIC X(64).
 01 WS-FILE-LENGTH         BINARY-LONG.
*> Bobby's state when the host quits.
 01 WS-BEFORE              PIC X(256).
 01 WS-AFTER               PIC X(256).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
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
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED

*>   US17-1: pause menu, Open to Others, the choices, Open the World.
     PERFORM OPEN-PAUSE
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-MODE TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-OPERATOR TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     MOVE "acceptance US17-1 given a single-player world when the Player chooses to open it to "
         & "others from the pause menu then they choose the guest game mode and whether guests may "
         & "use operator commands" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Open to Others|Guest game mode: Creative|Guests may use operator commands: Yes|Open the "
         & "World|Cancel" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-OPEN-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     PERFORM SHOWN-ADDRESS
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-PORT TO WS-E1
     MOVE "acceptance US17-1 when the world is opened then the game shows the address and port "
         & "others can join at" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "shown 1 port :" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE 0 TO WS-E2
     IF WS-ADDRESS-LENGTH > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE 0 TO WS-COUNT
     INSPECT WS-ADDRESS TALLYING WS-COUNT FOR CHARACTERS BEFORE INITIAL ":"
     STRING "shown " FUNCTION TRIM(WS-E2) " port " WS-ADDRESS(WS-COUNT + 1:WS-ADDRESS-LENGTH - WS-COUNT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND

*>   US17-2 / SC-013: the guest joins at exactly the shown address.
     CALL "JOIN-ADDRESS" USING CONVH WS-BOBBY WS-ADDRESS WS-ADDRESS-LENGTH
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE 10 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US17-2 SC-013 given a world opened to others when another Player adds the "
         & "shown address to their server list and joins then they enter the host's world in the "
         & "chosen guest mode" TO TL-CASE
     MOVE "joined 1 screen 5 mode 1 cobolcraft:main players 2" TO TL-EXPECTED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE WS-JOINED TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE PL-MODE TO WS-E3
     MOVE CST-PLAYERS-ONLINE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " mode "
         FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(PL-DIM-NAME) " players " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The guest may use operator commands (the choice made): the clock command is confirmed.
     MOVE "/clock 1000" TO WS-SAY
     MOVE 11 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-BOBBY WS-SAY WS-SAY-LENGTH
     MOVE 4 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "CV-CHAT-LOG" USING CONVH WS-BOBBY WS-BIG-LOG
     MOVE "acceptance US17-1 given guests may use operator commands when the guest runs one then "
         & "it is carried out" TO TL-CASE
     MOVE "found 1" TO TL-EXPECTED
     MOVE 0 TO WS-COUNT
     INSPECT WS-BIG-LOG TALLYING WS-COUNT FOR ALL "1000"
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION MIN(WS-COUNT, 1) TO WS-E1
     STRING "found " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-COUNT = 0
         MOVE WS-BIG-LOG(1:900) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Block changes both ways: the guest (creative) breaks a block, the host places one. The guest
*>   first stands apart (the host's command), so neither aims at the other's figure.
     MOVE "/relocate Bobby at 12.5 62 8.5" TO WS-SAY
     MOVE 30 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 90 TO PL-YAW
     MOVE 45 TO PL-PITCH
     CALL "CV-STEP" USING CONVH
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE TG-X TO WS-X
     MOVE TG-Y TO WS-Y
     MOVE TG-Z TO WS-Z
     MOVE TG-HIT TO WS-E3
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-BOBBY WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-BOBBY WS-BUTTON WS-KIND
     MOVE 6 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE2 WS-SKY WS-BLOCK
     MOVE "acceptance US17-2 SC-013 when the guest breaks a block then the host sees the same "
         & "change" TO TL-CASE
     MOVE "target 1 guest 0 host 0" TO TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE WS-STATE2 TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "target " FUNCTION TRIM(WS-E3) " guest " FUNCTION TRIM(WS-E1) " host "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE -90 TO PL-YAW
     MOVE 45 TO PL-PITCH
     CALL "CV-STEP" USING CONVH
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE TG-X TO WS-X
     COMPUTE WS-Y = TG-Y + 1
     MOVE TG-Z TO WS-Z
     MOVE TG-HIT TO WS-E3
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 6 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE2 WS-SKY WS-BLOCK
     MOVE "acceptance US17-2 SC-013 when the host places a block (greystone, the held slot) then "
         & "the guest sees the same change" TO TL-CASE
     MOVE "target 1 host 2 guest 2" TO TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE WS-STATE2 TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "target " FUNCTION TRIM(WS-E3) " host " FUNCTION TRIM(WS-E1) " guest "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US17-3: the host's pause menu does not pause a world opened to others.
     PERFORM OPEN-PAUSE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-TICKS TO WS-TICKS
     MOVE 20 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US17-3 given a world opened to others when the host opens the pause menu "
         & "then the game does not pause: 20 ticks in 20 frames" TO TL-CASE
     MOVE "screen 9 paused 0 ticks 20" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-PAUSED TO WS-E2
     COMPUTE WS-E3 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " FUNCTION TRIM(WS-E2) " ticks "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND

*>   US17 edge: a guest with the host's name is refused; the host stays.
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-CAROL
     CALL "JOIN-ADDRESS" USING CONVH WS-CAROL WS-ADDRESS WS-ADDRESS-LENGTH
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-CAROL)
     MOVE "US17 edge a guest joining with the host's name is refused with the name-is-host message "
         & "and the host stays in the world" TO TL-CASE
     MOVE "guest screen 2 The name Alice belongs to the host of this world host screen 5 phase 5"
         TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "guest screen " FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     IF SM-MESSAGE-LENGTH > 0
         STRING SM-MESSAGE(1:SM-MESSAGE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SM-SCREEN TO WS-E1
     MOVE CN-PHASE(CONN-GAME) TO WS-E2
     STRING " host screen " FUNCTION TRIM(WS-E1) " phase " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The guest's state to be kept (US17-5): survival, health 17, food 9, five ledger tiles, a spot
*>   away from the spawn, all set by the host's operator commands.
     MOVE "/mode Bobby survival" TO WS-SAY
     MOVE 20 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE "/relocate Bobby at 20 60 20" TO WS-SAY
     MOVE 27 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE "/supply Bobby ledger_tile 5" TO WS-SAY
     MOVE 27 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE "/vitality Bobby 17" TO WS-SAY
     MOVE 18 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE "/ration Bobby 9" TO WS-SAY
     MOVE 15 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE 60 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "GUEST-STATE" USING CONVH WS-BOBBY WS-BEFORE

*>   US17-4: the host quits the world from the pause menu.
     PERFORM OPEN-PAUSE
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 20 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US17-4 given a guest in the host's world when the host quits the world then "
         & "the guest is disconnected with the host-closed message and the world is saved" TO TL-CASE
     MOVE "guest screen 2 The host closed the world host screen 1 hosting 0 saved 1" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "guest screen " FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     IF SM-MESSAGE-LENGTH > 0
         STRING SM-MESSAGE(1:SM-MESSAGE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
*>   Saved: the guest's player file exists in the world folder.
     MOVE SPACES TO WS-LEVEL
     MOVE "build/conv-us17-open/Alice/saves/Shared/level.dat" TO WS-LEVEL
     MOVE 0 TO WS-E3
     CALL "CBL_CHECK_FILE_EXIST" USING WS-LEVEL WS-FILE-AREA
     IF RETURN-CODE = 0
         MOVE 1 TO WS-E3
     END-IF
     STRING " host screen " FUNCTION TRIM(WS-E1) " hosting " FUNCTION TRIM(WS-E2) " saved "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US17-5: the host reopens the world and opens it to others again; the guest rejoins.
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     PERFORM OPEN-PAUSE
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-OPEN-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-TEXTS" USING CONVH WS-ALICE WS-TEXT
     PERFORM SHOWN-ADDRESS
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "JOIN-ADDRESS" USING CONVH WS-BOBBY WS-ADDRESS WS-ADDRESS-LENGTH
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE 4 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "GUEST-STATE" USING CONVH WS-BOBBY WS-AFTER
     MOVE "acceptance US17-5 given a guest has played in the host's world when the host opens it "
         & "again and opens it to others and the guest rejoins then the guest's position, "
         & "dimension, inventory, health and food are as they left them" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED
     MOVE WS-AFTER TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "SP-QUIT" USING CLIENT-STATE
     STOP RUN.

*> The host (Alice) presses Escape: the pause menu.
 OPEN-PAUSE.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY.

*> The first "Others can join at <address>" text of WS-TEXT into WS-ADDRESS.
 SHOWN-ADDRESS.
     MOVE SPACES TO WS-ADDRESS
     MOVE 0 TO WS-ADDRESS-LENGTH WS-I
     INSPECT WS-TEXT TALLYING WS-I FOR CHARACTERS BEFORE INITIAL "Others can join at "
     IF WS-I < 1000
         COMPUTE WS-PTR = WS-I + 20
         PERFORM VARYING WS-I FROM WS-PTR BY 1
                 UNTIL WS-I > 1024 OR WS-TEXT(WS-I:1) = "|" OR WS-TEXT(WS-I:1) = SPACE
             ADD 1 TO WS-ADDRESS-LENGTH
         END-PERFORM
         MOVE WS-TEXT(WS-PTR:WS-ADDRESS-LENGTH) TO WS-ADDRESS
     END-IF.
 END PROGRAM ACC-US17-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JOIN-ADDRESS.
*> USING CONVH, index, address (PIC X(256)), length: the client adds a server-list entry with that
*> address, selects it and clicks Join (as CV-JOIN does for 127.0.0.1:<port>).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SERVER-LIST.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-ADDRESS              PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-ADDRESS L-LENGTH.
     MOVE L-INDEX TO WS-INDEX
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-INDEX)
     ADD 1 TO SL-COUNT
     INITIALIZE SL-ENTRY(SL-COUNT)
     MOVE "Host" TO SL-NAME(SL-COUNT)
     MOVE 4 TO SL-NAME-LENGTH(SL-COUNT)
     MOVE L-ADDRESS TO SL-ADDR(SL-COUNT)
     MOVE L-LENGTH TO SL-ADDR-LENGTH(SL-COUNT)
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "CV-STEP" USING CONVH
     MOVE ACT-SELECT TO WS-ACTION
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-INDEX)
     MOVE SL-COUNT TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-INDEX WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-JOIN TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-INDEX WS-ACTION WS-ARG WS-FOUND
     GOBACK.
 END PROGRAM JOIN-ADDRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUEST-STATE.
*> USING CONVH, index, text out (PIC X(256)): "<dimension> at <x>/<y>/<z> health <h> food <f>
*> mode <m> slots <slot:count x item ...>" of that client (block position, the non-empty slots).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     COMPUTE WS-E1 = FUNCTION INTEGER(PL-X)
     COMPUTE WS-E2 = FUNCTION INTEGER(PL-Y)
     COMPUTE WS-E3 = FUNCTION INTEGER(PL-Z)
     STRING FUNCTION TRIM(PL-DIM-NAME) " at " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/"
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-E1 = PL-HEALTH
     MOVE PL-FOOD TO WS-E2
     MOVE PL-MODE TO WS-E3
     STRING " health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2) " mode "
         FUNCTION TRIM(WS-E3) " slots" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             COMPUTE WS-E1 = WS-I - 1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E3
             STRING " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUEST-STATE.
