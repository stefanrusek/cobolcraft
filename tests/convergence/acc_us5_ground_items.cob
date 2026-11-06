*> Convergence acceptance test of US5-1 to US5-4 and SC-011 through two clients (spec.md US5;
*> standin-content §9): the host of a single-player world (Alice, survival, an operator) and a
*> second survival client on a further memory connection of the same core (Bobby). Alice throws one
*> greystone (Q) and then the rest of the stack (Control+Q) while facing +Z: both clients show each
*> item at the same position in every frame, falling until it rests on the turf. Bobby walks over
*> them and both leave the ground into his inventory; he throws one toward Alice, who picks it up;
*> greystone is conserved over the sequence. An item Bobby throws away from both lies until a
*> player has been near it for the despawn time (4800 ticks) and then disappears for both.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-GROUND-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us5-ground-items".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Items".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-KEY                 BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 01 WS-LIST-A              PIC X(1024).
 01 WS-LIST-B              PIC X(1024).
 01 WS-COUNT-A             BINARY-LONG.
 01 WS-COUNT-B             BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG.
 01 WS-FIRST-Y             FLOAT-LONG.
 01 WS-LAST-Y              FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 WS-F1                  PIC -(4)9.99.
 01 WS-F2                  PIC -(4)9.99.
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
     MOVE "/relocate Bobby at 4.5 54 30.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   US5-3 and US5-1: Alice, facing +Z, throws one greystone (hotbar slot 0).
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 0 TO WS-MODS
     CALL "THROW" USING CONVH WS-ALICE WS-MODS
     PERFORM WATCH-FALL
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-SLOT-COUNT(1) TO WS-HELD
     MOVE "acceptance US5-3 given the Player holds an item when they use the throw control then "
         & "one item leaves their inventory and lands on the ground in front of them" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "slot 63 ground 1x2 ahead 1" TO TL-EXPECTED
     MOVE WS-HELD TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "slot " FUNCTION TRIM(WS-E1) " ground " DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "ITEM-SUMMARY" USING TL-OBSERVED WS-LIST-A WS-LAST-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US5-1 given an item dropped on the ground when two Players in view look at "
         & "it then both see it at the same position in every frame, falling until it rests on "
         & "the turf" TO TL-CASE
     PERFORM OBSERVE-FALL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US5-3 whole stack: Control+Q throws the 63 left.
     MOVE CC-MOD-CONTROL TO WS-MODS
     CALL "THROW" USING CONVH WS-ALICE WS-MODS
     PERFORM WATCH-FALL
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-SLOT-COUNT(1) TO WS-HELD
     MOVE "acceptance US5-3 with the whole-stack modifier the whole held stack leaves the "
         & "inventory and lands on the ground as one item" TO TL-CASE
     MOVE "slot 0 items 2 same 1 last 63x2" TO TL-EXPECTED
     MOVE WS-HELD TO WS-E1
     MOVE WS-COUNT-A TO WS-E2
     MOVE 0 TO WS-E3
     IF WS-LIST-A = WS-LIST-B
         MOVE 1 TO WS-E3
     END-IF
     MOVE 0 TO WS-I
     INSPECT WS-LIST-A TALLYING WS-I FOR ALL " 63x2 "
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "slot " FUNCTION TRIM(WS-E1) " items " FUNCTION TRIM(WS-E2) " same "
         FUNCTION TRIM(WS-E3) " last " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF WS-I = 1
         STRING "63x2" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING FUNCTION TRIM(WS-LIST-A) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US5-2: Bobby, facing -Z, walks until both items have left the ground.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 180 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE CC-KEY-W TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-N
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-N
     MOVE 0 TO WS-STEP
     MOVE 2 TO WS-COUNT-B
     PERFORM UNTIL WS-STEP > 150 OR WS-COUNT-B = 0
         CALL "CV-STEP" USING CONVH
         ADD 1 TO WS-STEP
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-B WS-COUNT-B WS-Y
     END-PERFORM
     MOVE CC-EV-KEY-UP TO WS-N
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-N
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-A WS-COUNT-A WS-Y
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-B WS-COUNT-B WS-Y
     MOVE "acceptance US5-2 given items on the ground when a survival Player comes within pickup "
         & "range then they leave the ground for both Players and are added to that Player's "
         & "inventory" TO TL-CASE
     MOVE "ground 0 0 slot 11 64x2" TO TL-EXPECTED
     MOVE WS-COUNT-A TO WS-E1
     MOVE WS-COUNT-B TO WS-E2
     MOVE PL-SLOT-COUNT(11) TO WS-E3
     MOVE PL-SLOT-ITEM(11) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "ground " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " slot 11 "
         FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SC-011: Bobby throws one greystone back toward Alice, who picks it up; every greystone
*>   (64 each at the start) is in an inventory or on the ground.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 180 TO PL-YAW
     MOVE 0 TO WS-MODS
     CALL "THROW" USING CONVH WS-BOBBY WS-MODS
     MOVE 60 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 0 TO WS-TOTAL
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-SLOT-COUNT(1) TO WS-HELD
     PERFORM ADD-GREYSTONE
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-A WS-COUNT-A WS-Y
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     PERFORM ADD-GREYSTONE
     MOVE "SC-011 given a sequence of throws and pickups by two players then every item is "
         & "conserved: 128 greystone in inventories and on the ground" TO TL-CASE
     MOVE "alice slot 1 ground 0 total 128" TO TL-EXPECTED
     MOVE WS-HELD TO WS-E1
     MOVE WS-COUNT-A TO WS-E2
     MOVE WS-TOTAL TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "alice slot " FUNCTION TRIM(WS-E1) " ground " FUNCTION TRIM(WS-E2) " total "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US5-4: Bobby, facing +Z, throws one greystone out of everyone's pickup range; 4600 ticks
*>   later it still lies there, 4800 after it was thrown it has gone for both. Frames of 10 s
*>   (200 ticks, inside the keep-alive deadline) make the time pass.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 0 TO PL-YAW
     MOVE 0 TO WS-MODS
     CALL "THROW" USING CONVH WS-BOBBY WS-MODS
     PERFORM 23 TIMES
         ADD 9950 TO CV-NOW
         CALL "CV-STEP" USING CONVH
         CALL "CV-STEP" USING CONVH
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-A WS-COUNT-A WS-Y
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-B WS-COUNT-B WS-Y
     MOVE WS-COUNT-A TO WS-E1
     MOVE WS-COUNT-B TO WS-E2
     PERFORM 2 TIMES
         ADD 9950 TO CV-NOW
         CALL "CV-STEP" USING CONVH
         CALL "CV-STEP" USING CONVH
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-A WS-COUNT-A WS-Y
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-B WS-COUNT-B WS-Y
     MOVE "acceptance US5-4 given an item on the ground near a player when the despawn time "
         & "passes then it disappears for everyone" TO TL-CASE
     MOVE "at 4600 ticks 1 1 after 4800 0 0" TO TL-EXPECTED
     MOVE WS-COUNT-A TO WS-E3
     MOVE WS-COUNT-B TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "at 4600 ticks " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " after 4800 "
         FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   40 frames after a throw: the item lists of both clients compared in every frame in which
*>   Alice's shows the newest item; its y in Alice's replica first and last.
 WATCH-FALL.
     MOVE 0 TO WS-SEEN WS-DIFFER
     PERFORM 40 TIMES
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-A WS-COUNT-A WS-Y
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         CALL "ITEM-LIST" USING CLIENT-STATE WS-LIST-B WS-COUNT-B WS-LAST-Y
         IF WS-COUNT-A > 0
             IF WS-SEEN = 0
                 MOVE WS-Y TO WS-FIRST-Y
             END-IF
             ADD 1 TO WS-SEEN
             MOVE WS-Y TO WS-LAST-Y
             IF WS-LIST-A NOT = WS-LIST-B
                 ADD 1 TO WS-DIFFER
             END-IF
         END-IF
     END-PERFORM.

 OBSERVE-FALL.
     MOVE WS-SEEN TO WS-E1
     MOVE WS-DIFFER TO WS-E2
     MOVE 0 TO WS-E3
     IF WS-FIRST-Y > WS-LAST-Y
         MOVE 1 TO WS-E3
     END-IF
     COMPUTE WS-F1 ROUNDED = WS-LAST-Y
     MOVE "frames seen 40 differing 0 fell 1 rests at y 54.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "frames seen " FUNCTION TRIM(WS-E1) " differing " FUNCTION TRIM(WS-E2) " fell "
         FUNCTION TRIM(WS-E3) " rests at y " FUNCTION TRIM(WS-F1) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 ADD-GREYSTONE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-I) = 2
             ADD PL-SLOT-COUNT(WS-I) TO WS-TOTAL
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US5-GROUND-ITEMS.

*> THROW USING CONVH, client, modifier bits (0 or CC-MOD-CONTROL): one frame with Q pressed and
*> released carrying those modifiers (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-Q.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-X                   FLOAT-SHORT VALUE 0.
 01 WS-Y                   FLOAT-SHORT VALUE 0.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-MODS                 BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-MODS.
     CALL "CV-QUEUE" USING CONVH L-INDEX WS-DOWN WS-KEY WS-X WS-Y
     MOVE CV-EVENT-COUNT(L-INDEX) TO WS-N
     MOVE L-MODS TO CV-EV-B(L-INDEX, WS-N)
     CALL "CV-QUEUE" USING CONVH L-INDEX WS-UP WS-KEY WS-X WS-Y
     MOVE CV-EVENT-COUNT(L-INDEX) TO WS-N
     MOVE L-MODS TO CV-EV-B(L-INDEX, WS-N)
     CALL "CV-STEP" USING CONVH
     GOBACK.
 END PROGRAM THROW.

*> ITEM-LIST USING CLIENT-STATE, text out (PIC X(1024)), count out, y out (FLOAT-LONG): the
*> client's ground items (entity type 1) in ascending entity id order as " <id> <count>x<item>
*> <x>/<y>/<z>" (2 decimals), their number, and the y of the one with the highest id.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-F1                  PIC -(5)9.99.
 01 WS-F2                  PIC -(5)9.99.
 01 WS-F3                  PIC -(5)9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 01 L-COUNT                BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-COUNT L-Y.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO L-COUNT L-Y
     MOVE -1 TO WS-LAST
     MOVE 1 TO WS-ROW
     PERFORM UNTIL WS-ROW = 0
         MOVE 0 TO WS-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1 AND EN-ID(WS-I) > WS-LAST
                 IF WS-ROW = 0
                     MOVE WS-I TO WS-ROW
                 ELSE
                     IF EN-ID(WS-I) < EN-ID(WS-ROW)
                         MOVE WS-I TO WS-ROW
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-ROW > 0
             ADD 1 TO L-COUNT
             MOVE EN-ID(WS-ROW) TO WS-LAST WS-E1
             MOVE EN-STACK-COUNT(WS-ROW) TO WS-E2
             MOVE EN-STACK-ITEM(WS-ROW) TO WS-E3
             COMPUTE WS-F1 ROUNDED = EN-X(WS-ROW)
             COMPUTE WS-F2 ROUNDED = EN-Y(WS-ROW)
             COMPUTE WS-F3 ROUNDED = EN-Z(WS-ROW)
             MOVE EN-Y(WS-ROW) TO L-Y
             STRING " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 " " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
                 DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEM-LIST.

*> ITEM-SUMMARY USING text (PIC X(1024), appended after its last non-space), item list: appends
*> "<count>x<item> ahead <1 when the item lies at z > 9.6, out of the thrower's pickup range>" of
*> the list's first item; y unused.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-SUMMARY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ID                  PIC X(16).
 01 WS-STACK               PIC X(16).
 01 WS-POS                 PIC X(64).
 01 WS-X                   PIC X(16).
 01 WS-Y                   PIC X(16).
 01 WS-Z                   PIC X(16).
 01 WS-AHEAD               PIC 9.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-LIST                 PIC X(1024).
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LIST L-Y.
     MOVE SPACES TO WS-ID WS-STACK WS-POS WS-X WS-Y WS-Z
     UNSTRING L-LIST(2:1023) DELIMITED BY " " INTO WS-ID WS-STACK WS-POS
     UNSTRING WS-POS DELIMITED BY "/" INTO WS-X WS-Y WS-Z
     MOVE 0 TO WS-AHEAD
     IF FUNCTION NUMVAL(WS-Z) > 9.6
         MOVE 1 TO WS-AHEAD
     END-IF
     COMPUTE WS-PTR = FUNCTION LENGTH(FUNCTION TRIM(L-TEXT, TRAILING)) + 1
     STRING " " FUNCTION TRIM(WS-STACK) " ahead " WS-AHEAD DELIMITED BY SIZE
         INTO L-TEXT WITH POINTER WS-PTR
     GOBACK.
 END PROGRAM ITEM-SUMMARY.

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

