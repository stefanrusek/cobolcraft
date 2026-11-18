*> Hand-operated switches and openings (002-lane-play2 defect 2; docs/protocol/30 part 5 sections 2 and 3 for the lever and the buttons, 30 part 7 for the
*> doors, trapdoors and fence gates, 29 section 9 for the Use Item On rules): a Use Item On on one of these blocks with the main hand, not sneaking with an
*> item held (29 section 9.2: the item is used on the block instead), changes the block and takes the click.
*>   lever           powered toggles (30-5 section 2.2: the lever never schedules a tick)
*>   *_button        powered becomes true and a block tick is scheduled for the release: 20 ticks for stone and polished blackstone, 30 for the wooden
*>                   types (30-5 section 3.3); a button that is already powered ignores the click (the click is still taken)
*>   *_door          open toggles in both halves; iron_door is operated by signal only
*>   *_trapdoor      open toggles; iron_trapdoor is operated by signal only
*>   *_fence_gate    open toggles
*> The signal side (the neighbours' power, sounds, the doors' hinge sound, redstone wire) is not part of this: only the block states change.
*> A property is read and written through the property text of the state (BLOCKS-STATE-PROPS) and the state search BLOCKS-STATE-OF; the keys are compared
*> in their bare form (core/src/keys.cob), so the standard and the cobolcraft set both work.
*> Entry points:
*>   SW-BLOCK-KIND USING block id, kind out (0 none, 1 lever, 2 button, 3 door, 4 trapdoor, 5 fence gate), delay out (button release ticks)
*>   SW-SET-PROP USING state, name (PIC X(16)), value (PIC X(16), "toggle" flips true and false, "keep" reads only), state out, old value out (PIC X(16), spaces when the
*>     state has no such property: then the state out is the state given)
*>   SW-USE USING connection id, PLAY-SERVERBOUND, handled out (1 when the block took the click)
*>   SW-BUTTON-RELEASE USING dimension row, x, y, z: the scheduled tick of a button (hook effect 9)
*>   SW-RULES-OPEN: the scheduled-tick rule of every button block of the open block tables (called after GB-RULES-OPEN)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SW-BLOCK-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-S7                  BINARY-LONG.
 01 WS-S5                  BINARY-LONG.
 01 WS-S10                 BINARY-LONG.
 01 WS-S11                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-KIND L-DELAY.
     MOVE 0 TO L-KIND L-DELAY
     MOVE CB-KEY(L-BLOCK + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-BARE))
     COMPUTE WS-S5 = WS-LEN - 4
     COMPUTE WS-S7 = WS-LEN - 6
     COMPUTE WS-S10 = WS-LEN - 8
     COMPUTE WS-S11 = WS-LEN - 10
     EVALUATE TRUE
         WHEN WS-BARE = "lever"
             MOVE 1 TO L-KIND
         WHEN WS-LEN >= 10 AND WS-BARE(WS-S7:7) = "_button"
             MOVE 2 TO L-KIND
             MOVE 30 TO L-DELAY
             IF WS-BARE(1:5) = "stone" OR WS-BARE(1:19) = "polished_blackstone"
                 MOVE 20 TO L-DELAY
             END-IF
         WHEN WS-LEN >= 11 AND WS-BARE(WS-S11:11) = "_fence_gate"
             MOVE 5 TO L-KIND
         WHEN WS-LEN >= 10 AND WS-BARE(WS-S10:9) = "_trapdoor"
             MOVE 4 TO L-KIND
             IF WS-BARE(1:4) = "iron"
                 MOVE 0 TO L-KIND
             END-IF
         WHEN WS-LEN >= 8 AND WS-BARE(WS-S5:5) = "_door"
             MOVE 3 TO L-KIND
             IF WS-BARE(1:4) = "iron"
                 MOVE 0 TO L-KIND
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SW-BLOCK-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SW-SET-PROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-TEXT                PIC X(160).
 01 WS-OUT                 PIC X(160).
 01 WS-PAIR                PIC X(160).
 01 WS-NAME                PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-KEY                 PIC X(112).
 01 WS-POS                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-VALUE                PIC X(16).
 01 L-RESULT               BINARY-LONG.
 01 L-OLD                  PIC X(16).
 PROCEDURE DIVISION USING L-STATE L-NAME L-VALUE L-RESULT L-OLD.
     MOVE L-STATE TO L-RESULT
     MOVE SPACES TO L-OLD
     CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-TEXT
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-POS WS-PTR
     PERFORM UNTIL WS-POS > 160
         MOVE SPACES TO WS-PAIR WS-NAME WS-VALUE
         UNSTRING WS-TEXT DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POS
         UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-NAME WS-VALUE
         IF WS-NAME = L-NAME
             MOVE WS-VALUE TO L-OLD
             IF L-VALUE NOT = "keep"
                 MOVE L-VALUE TO WS-VALUE
             END-IF
             IF L-VALUE = "toggle"
                 MOVE "true" TO WS-VALUE
                 IF L-OLD = "true"
                     MOVE "false" TO WS-VALUE
                 END-IF
             END-IF
         END-IF
         IF WS-PTR > 1
             STRING "," DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-NAME) "=" FUNCTION TRIM(WS-VALUE) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     END-PERFORM
     IF L-OLD NOT = SPACES
         MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-OUT L-RESULT
     END-IF
     GOBACK.
 END PROGRAM SW-SET-PROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SW-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NAME-POWERED        PIC X(16) VALUE "powered".
 01 WS-NAME-OPEN           PIC X(16) VALUE "open".
 01 WS-NAME-HALF           PIC X(16) VALUE "half".
 01 WS-TOGGLE              PIC X(16) VALUE "toggle".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-OLD                 PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-OTHER-Y             BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-OTHER-NEW           BINARY-LONG.
 01 WS-HALF                PIC X(16).
 01 WS-DUMMY               PIC X(16).
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-NORMAL              BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-HANDLED.
     MOVE 0 TO L-HANDLED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
*>   A main-hand click only; sneaking with an item in hand uses the item (29 section 9.2).
     IF PSB-HAND NOT = 0 OR (PL-SNEAKING(WS-ROW) = 1 AND PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0)
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "SW-BLOCK-KIND" USING WS-BLOCK WS-KIND WS-DELAY
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE WS-TOGGLE TO WS-VALUE
     IF WS-KIND = 2
         MOVE WS-TRUE TO WS-VALUE
     END-IF
     IF WS-KIND <= 2
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-POWERED WS-VALUE WS-NEW WS-OLD
     ELSE
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-OPEN WS-VALUE WS-NEW WS-OLD
     END-IF
     IF WS-NEW = WS-STATE
         GOBACK
     END-IF
     CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-NEW
     IF WS-KIND = 2
         CALL "BT-SCHEDULE" USING WS-DIM WS-TYPE-BLOCK WS-BLOCK PSB-BX PSB-BY PSB-BZ WS-DELAY WS-NORMAL WS-RESULT
     END-IF
*>   The other half of a door follows (30 part 7: both halves hold the same open).
     IF WS-KIND = 3
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HALF WS-KEEP WS-OTHER-NEW WS-HALF
         COMPUTE WS-OTHER-Y = PSB-BY + 1
         IF WS-HALF = "upper"
             COMPUTE WS-OTHER-Y = PSB-BY - 1
         END-IF
         CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX WS-OTHER-Y PSB-BZ WS-OTHER
         IF CB-S-BLOCK(WS-OTHER + 1) = WS-BLOCK
             CALL "SW-SET-PROP" USING WS-OTHER WS-NAME-OPEN WS-TOGGLE WS-OTHER-NEW WS-DUMMY
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX WS-OTHER-Y PSB-BZ WS-OTHER-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SW-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SW-BUTTON-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "powered".
 01 WS-FALSE               PIC X(16) VALUE "false".
 01 WS-OLD                 PIC X(16).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME WS-FALSE WS-NEW WS-OLD
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
     GOBACK.
 END PROGRAM SW-BUTTON-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SW-RULES-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RULE-KIND           BINARY-LONG VALUE 7.
 01 WS-ROD                 BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 9.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BU-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         COMPUTE WS-BLOCK = WS-I - 1
         CALL "SW-BLOCK-KIND" USING WS-BLOCK WS-KIND WS-DELAY
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
             IF BU-R-KIND(WS-R) = 7 AND BU-R-BLOCK(WS-R) = WS-BLOCK AND BU-R-EFFECT(WS-R) = 9
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
*>       A lightning rod (29b-3 9.2 ST) is unpowered by its scheduled tick like a button.
         MOVE 0 TO WS-ROD
         INSPECT CB-KEY(WS-I) TALLYING WS-ROD FOR ALL "lightning_rod"
         IF (WS-KIND = 2 OR WS-ROD > 0) AND WS-FOUND = 0
             CALL "BU-RULE-ADD" USING WS-RULE-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SW-RULES-OPEN.
