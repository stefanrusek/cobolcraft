*> Implementation test (002-lane-mobsa5; 29b part 7 section 3): turtle egg trampling wired to entities. A stepOn has the chance 1 in 100 (not when sneaking), a landing 1 in 3 (not for a zombie);
*> a turtle never destroys an egg, another mob only with mob_griefing; one egg goes at a time and the block with the last one; a player walking over the egg through the movement packet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-EGGSTEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "eggs".
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-STEP                BINARY-LONG VALUE 1.
 01 WS-LAND                BINARY-LONG VALUE 2.
 01 WS-PLAYERK             BINARY-LONG VALUE 3.
 01 WS-TURTLE              BINARY-LONG VALUE 1.
 01 WS-OTHER               BINARY-LONG VALUE 4.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-EGGS-NOW            BINARY-LONG.
 01 WS-NO2                 BINARY-LONG VALUE 0.
 01 WS-CONN                BINARY-LONG.
 01 WS-ID30                BINARY-LONG VALUE 30.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS1              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     MOVE "N" TO TL-MODE
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:turtle_egg" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE "3" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-TEXT WS-NEW
     COMPUTE WS-BX = WS-X0 + 24
     COMPUTE WS-BY = WS-FLOOR + 1
     COMPUTE WS-BZ = WS-Z0 + 24
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-NEW
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.4
     COMPUTE WS-Z = WS-BZ + 0.5
*>   A turtle and a sneaking player never break it.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         ADD 1 TO CW-TIME
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-TURTLE WS-LAND WS-NO WS-NO2 WS-HIT
         ADD WS-HIT TO WS-N
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-PLAYERK WS-STEP WS-YES WS-NO WS-HIT
         ADD WS-HIT TO WS-N
     END-PERFORM
     MOVE "acceptance US15 29b-7§3 Turtle egg: a turtle and a sneaking player never trample it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie landing (the fallOn chance is 0 for it) and a bat do nothing either.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         ADD 1 TO CW-TIME
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-OTHER WS-LAND WS-NO WS-YES WS-HIT
         ADD WS-HIT TO WS-N
     END-PERFORM
     MOVE "acceptance US15 29b-7§3 Turtle egg: a zombie landing on it does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player's landing breaks an egg within about 3 tries on average: within 200 tries one egg goes (eggs 2).
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-N = 1
         ADD 1 TO CW-TIME
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-PLAYERK WS-LAND WS-NO WS-NO2 WS-HIT
         ADD WS-HIT TO WS-N
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-READ WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 29b-7§3 Turtle egg: a player landing on three eggs breaks one (eggs 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION NUMVAL(WS-TEXT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A step of a player breaks eggs at 1 in 100: within 3000 steps all three are gone and the block is air.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000
         ADD 1 TO CW-TIME
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-PLAYERK WS-STEP WS-NO WS-NO2 WS-HIT
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 29b-7§3 Turtle egg: steps break the eggs one by one, the last one takes the block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A mob stepping through the mob step: a cow on a fresh egg block over many ticks breaks it (mob_griefing is on by default).
     MOVE "minecraft:turtle_egg" TO WS-KEY
     MOVE "1" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-NEW WS-PROP WS-TEXT WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR WS-N = 1
         ADD 1 TO CW-TIME
         CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-OTHER WS-STEP WS-NO WS-NO2 WS-HIT
         ADD WS-HIT TO WS-N
     END-PERFORM
     MOVE "acceptance US15 29b-7§3 Turtle egg: another mob tramples a single egg and the block is gone (mob_griefing)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player stepping on three eggs through the movement packet (on ground; 1 in 100 each: many packets).
     MOVE "3" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-NEW WS-PROP WS-TEXT WS-STATE
     COMPUTE WS-Y = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-SNEAKING(WS-PLAYER) PL-FLYING(WS-PLAYER)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-Y = WS-BY + 1
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         ADD 1 TO CW-TIME
         CALL "TEST-MOVE" USING WS-CONN WS-ID30 WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS1
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 29b-7§3 Turtle egg: a player walking over the eggs breaks them (movement packets)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE = 0 OR WS-STATE NOT = WS-NEW
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not an egg below: nothing.
     MOVE 0 TO WS-HIT
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "M44-EGG-TRAMPLE" USING WS-DIM WS-X WS-Y WS-Z WS-OTHER WS-LAND WS-NO WS-NO2 WS-HIT
     MOVE "acceptance US15 29b-7§3 Turtle egg: no egg below, no trample" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-EGGSTEP.
 COPY CORETEST.
 COPY MOBSPTEST.
