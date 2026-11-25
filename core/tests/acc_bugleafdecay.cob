*> Acceptance test, lane bugleafdecay (operator report of try18: "leaves break over time after their logs are gone"; docs/protocol/29b part 3 section 5 (leaves: distance, persistent, decay, drops),
*> 29 sections 3 and 4 (shape updates and scheduled ticks), 33 section 2.4 (random ticks)): a superflat world (the standard content set; CC_GENERATED_DIR, skipped as a pass without it) with leaf canopies
*> built high above the ground. Before this lane the leaf programs of 29b-3 were helpers nothing called: leaves never recomputed their distance and never decayed. Here: a log pillar in a canopy of oak
*> leaves gives the leaves their distance from the logs through the scheduled ticks (a leaf next to a log 1, the corner of a 5 x 5 x 3 canopy 5); leaves with a log within reach never decay under a
*> random tick speed of 1000; when the logs are removed every leaf of the canopy decays and drops saplings, sticks or apples only; a canopy with a second pillar keeps all its leaves when one pillar is
*> removed; in a line of leaves from a log (the worked example of 29b-3 section 6) the leaves at distance 7 decay and the ones at 1 to 6 stay; a persistent leaf at distance 7 stays; a leaf placed
*> through Use Item On is persistent and has its distance (1 next to a log, 7 alone) and never decays; the viewers receive the block changes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGLEAFDECAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-GROUND-Y            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-LEAF                BINARY-LONG.
 01 WS-LEAF-BLOCK          BINARY-LONG.
 01 WS-LEAF-PERSISTENT     BINARY-LONG.
 01 WS-LOG                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "random_tick_speed".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HITS                BINARY-LONG.
 01 WS-SEEN                BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-PROP                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-LINE1               BINARY-LONG.
 01 WS-LINE2               BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-TALLY               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-DISTS               PIC X(64).
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-PLACED1             BINARY-LONG.
 01 WS-PLACED2             BINARY-LONG.
 01 WS-T2-BEFORE           BINARY-LONG.
 01 WS-OX1                 BINARY-LONG.
 01 WS-OZ7                 BINARY-LONG.
 01 WS-Y02                 BINARY-LONG.
 01 WS-FULL-KEY            PIC X(60).
 01 WS-RULES-BEFORE        BINARY-LONG.
 01 WS-LEAF-BLOCKS         BINARY-LONG.
 01 WS-LEAF-MARKED         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-WATERLOGGED         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance leaf decay no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Leaves" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 0 TO WS-SEED
     CALL "LEVEL-RANDOM-SEED" USING WS-SEED

     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE
     MOVE "oak_leaves" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-LEAF
     MOVE CB-S-BLOCK(WS-LEAF + 1) TO WS-LEAF-BLOCK
     MOVE "oak_log" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-LOG
*>   The persistent state of the same leaves (distance 7).
     MOVE WS-LEAF TO WS-LEAF-PERSISTENT
     MOVE "persistent" TO WS-PROP
     MOVE "true" TO WS-TEXT
     CALL "PS-PUT" USING WS-LEAF-PERSISTENT WS-PROP WS-TEXT

*>   The hook rows: every leaves block has the randomly ticking marker, the random tick, the scheduled tick and the shape update; registering twice adds nothing; the table has room left.
     MOVE 0 TO WS-LEAF-BLOCKS WS-LEAF-MARKED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         COMPUTE WS-E = WS-I - 1
         CALL "LEAF-CLASS" USING WS-E WS-ALL
         IF WS-ALL = 2
             ADD 1 TO WS-LEAF-BLOCKS
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
             MOVE 1 TO WS-ALL
             MOVE 11 TO WS-KIND
             CALL "BU-MARKED" USING WS-KIND WS-STATE WS-MARK
             IF WS-MARK = 0
                 MOVE 0 TO WS-ALL
             END-IF
             MOVE 8 TO WS-KIND
             CALL "BU-MARKED" USING WS-KIND WS-STATE WS-MARK
             IF WS-MARK = 0
                 MOVE 0 TO WS-ALL
             END-IF
             MOVE 7 TO WS-KIND
             CALL "BU-MARKED" USING WS-KIND WS-STATE WS-MARK
             IF WS-MARK = 0
                 MOVE 0 TO WS-ALL
             END-IF
             MOVE 4 TO WS-KIND
             CALL "BU-MARKED" USING WS-KIND WS-STATE WS-MARK
             IF WS-MARK = 0
                 MOVE 0 TO WS-ALL
             END-IF
             ADD WS-ALL TO WS-LEAF-MARKED
         END-IF
     END-PERFORM
     MOVE "acceptance leaf decay 29b-3 5.3: the world has leaves blocks and every one of them has its four hook rows" TO WS-CASE
     MOVE WS-LEAF-BLOCKS TO WS-EXPECT
     MOVE WS-LEAF-MARKED TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 5.3: a world with leaves blocks has more than 10 of them (13 standard families and the mangrove)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LEAF-BLOCKS > 10
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE BU-RULE-COUNT TO WS-RULES-BEFORE
     CALL "LEAF-RULES-OPEN"
     MOVE "acceptance leaf decay 29b-3 5.3: registering the leaves rows again adds no row and the rule table is not full" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF BU-RULE-COUNT = WS-RULES-BEFORE AND BU-RULE-COUNT < BU-MAX-RULES
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   The build area: the chunk of the player, 20 blocks above the ground, with a floor of stone under it that catches the drops (and keeps them from the player).
     COMPUTE WS-OX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-OX = WS-OX * 16
     IF PL-X(WS-PLAYER) < 0 AND FUNCTION MOD(FUNCTION INTEGER(PL-X(WS-PLAYER)), 16) NOT = 0
         SUBTRACT 16 FROM WS-OX
     END-IF
     COMPUTE WS-OZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     COMPUTE WS-OZ = WS-OZ * 16
     IF PL-Z(WS-PLAYER) < 0 AND FUNCTION MOD(FUNCTION INTEGER(PL-Z(WS-PLAYER)), 16) NOT = 0
         SUBTRACT 16 FROM WS-OZ
     END-IF
     ADD 1 TO WS-OX
     ADD 1 TO WS-OZ
     COMPUTE WS-GROUND-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Y0 = WS-GROUND-Y + 20
     COMPUTE WS-OX1 = WS-OX + 1
     COMPUTE WS-OZ7 = WS-OZ + 7
     COMPUTE WS-Y02 = WS-Y0 + 2
     COMPUTE WS-Y = WS-Y0 - 1
     PERFORM VARYING WS-X FROM WS-OX BY 1 UNTIL WS-X > WS-OX + 13
         PERFORM VARYING WS-Z FROM WS-OZ BY 1 UNTIL WS-Z > WS-OZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
         END-PERFORM
     END-PERFORM

*>   Tree 1: a pillar of four logs at (2, 2) in a 5 x 5 x 3 canopy (the leaves are set with the default distance 7; the logs go in last, with neighbour updates).
     PERFORM VARYING WS-X FROM WS-OX BY 1 UNTIL WS-X > WS-OX + 4
         PERFORM VARYING WS-Z FROM WS-OZ BY 1 UNTIL WS-Z > WS-OZ + 4
             COMPUTE WS-Y = WS-Y0 + 2
             PERFORM 3 TIMES
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LEAF
                 ADD 1 TO WS-Y
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   Tree 2: the same canopy at z + 7 with two pillars, at (1, 2) and (3, 2).
     PERFORM VARYING WS-X FROM WS-OX BY 1 UNTIL WS-X > WS-OX + 4
         PERFORM VARYING WS-Z FROM WS-OZ7 BY 1 UNTIL WS-Z > WS-OZ + 11
             COMPUTE WS-Y = WS-Y0 + 2
             PERFORM 3 TIMES
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LEAF
                 ADD 1 TO WS-Y
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   Line 1: a log with eight leaves east of it; line 2: the same one level up with a persistent leaf at the end (z + 13, y + 6 and + 9).
     COMPUTE WS-Y = WS-Y0 + 6
     COMPUTE WS-Z = WS-OZ + 13
     PERFORM VARYING WS-X FROM WS-OX1 BY 1 UNTIL WS-X > WS-OX + 8
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LEAF
     END-PERFORM
     COMPUTE WS-Y = WS-Y0 + 9
     PERFORM VARYING WS-X FROM WS-OX1 BY 1 UNTIL WS-X > WS-OX + 7
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LEAF
     END-PERFORM
     COMPUTE WS-X = WS-OX + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LEAF-PERSISTENT
*>   The logs (with neighbour updates).
     COMPUTE WS-X = WS-OX + 2
     COMPUTE WS-Z = WS-OZ + 2
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 3
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 3
         COMPUTE WS-X = WS-OX + 1
         COMPUTE WS-Z = WS-OZ + 9
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG WS-FLAGS WS-BUDGET WS-RESULT
         COMPUTE WS-X = WS-OX + 3
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     COMPUTE WS-X = WS-OX
     COMPUTE WS-Z = WS-OZ + 13
     COMPUTE WS-Y = WS-Y0 + 6
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE WS-Y = WS-Y0 + 9
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG WS-FLAGS WS-BUDGET WS-RESULT
*>   The distances settle through scheduled ticks, one leaf further each tick.
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS

     MOVE "acceptance leaf decay 29b-3 5.3: a leaf next to a log pillar has distance 1 after the scheduled ticks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-X = WS-OX + 3
     COMPUTE WS-Y = WS-Y0 + 2
     COMPUTE WS-Z = WS-OZ + 2
     PERFORM DISTANCE-AT
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 5.2: the corner leaf of the top layer of the canopy is 2 + 1 + 2 = 5 from the nearest log" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE WS-OX TO WS-X
     COMPUTE WS-Y = WS-Y0 + 4
     MOVE WS-OZ TO WS-Z
     PERFORM DISTANCE-AT
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 5.2: the leaves of a line from a log have the distances 1 to 7 and 7" TO WS-CASE
     MOVE SPACES TO WS-DISTS
     MOVE 1 TO WS-I
     COMPUTE WS-Y = WS-Y0 + 6
     COMPUTE WS-Z = WS-OZ + 13
     PERFORM VARYING WS-X FROM WS-OX1 BY 1 UNTIL WS-X > WS-OX + 8
         PERFORM DISTANCE-AT
         MOVE FUNCTION CHAR(WS-OBSERVE + 49) TO WS-DISTS(WS-I:1)
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "12345677" TO TL-EXPECTED
     MOVE WS-DISTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Under a high random tick speed nothing with a log in reach decays (the whole canopy of tree 1 is within 5), but the leaves at 7 of the lines do.
     PERFORM COUNT-TREES
     MOVE "acceptance leaf decay 29b-3 5.4: the 73 leaves of a canopy around a log pillar are all there" TO WS-CASE
     MOVE 73 TO WS-EXPECT
     MOVE WS-T1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1000 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 5 TO WS-TICKS
     PERFORM RUN-AND-DRAIN
     PERFORM COUNT-TREES
     MOVE "acceptance leaf decay 29b-3 5.4: after random ticks at speed 1000 the canopy around the logs has all its 73 leaves, only the leaves of the lines at distance 7 are gone" TO WS-CASE
     MOVE 73 TO WS-EXPECT
     MOVE WS-T1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   Remove the pillar of tree 1 and one of the two pillars of tree 2.
     COMPUTE WS-X = WS-OX + 2
     COMPUTE WS-Z = WS-OZ + 2
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 3
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     COMPUTE WS-X = WS-OX + 1
     COMPUTE WS-Z = WS-OZ + 9
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 3
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     PERFORM COUNT-TREES
     MOVE WS-T2 TO WS-T2-BEFORE
*>   The distances rise through the scheduled ticks (no random ticks yet); what the viewers were sent so far is not counted.
     MOVE 1 TO WS-TICKS
     PERFORM RUN-AND-DRAIN
     MOVE 0 TO WS-SEEN
     MOVE 1000 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 5 TO WS-TICKS
     PERFORM RUN-AND-DRAIN
     PERFORM COUNT-TREES
     MOVE "acceptance leaf decay 29b-3 5.4: with the logs gone every leaf of the canopy decays under random ticks (distance 7, not persistent)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-T1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 5.2: a canopy with a second log pillar keeps every leaf when one pillar is removed (all within 6 of the other)" TO WS-CASE
     MOVE WS-T2-BEFORE TO WS-EXPECT
     MOVE WS-T2 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 6.4: in a line of leaves from a log the leaves at 7 decay and those at 1 to 6 stay" TO WS-CASE
     COMPUTE WS-Y = WS-Y0 + 6
     COMPUTE WS-Z = WS-OZ + 13
     PERFORM LINE-STATUS
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "11111100" TO TL-EXPECTED
     MOVE WS-DISTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance leaf decay 29b-3 5.3: a persistent leaf at distance 7 at the end of a line stays while the leaf before it decays" TO WS-CASE
     COMPUTE WS-Y = WS-Y0 + 9
     PERFORM LINE-STATUS
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "11111101" TO TL-EXPECTED
     MOVE WS-DISTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance leaf decay 29b-3 5.4: the viewers receive the block changes of the decayed leaves" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-SEEN TO WS-OBSERVE
     PERFORM CHECK-N

*>   The drops: items of the leaf loot table only (sapling, stick, apple), and some of them (about 7 percent of the 150 leaves).
     MOVE 0 TO WS-DROPS WS-OTHER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             MOVE IT-KEY(EN-ITEM(WS-I) + 1) TO WS-ITEM-KEY
             MOVE 0 TO WS-TALLY
             INSPECT WS-ITEM-KEY TALLYING WS-TALLY FOR ALL "sapling" ALL "stick" ALL "apple"
             IF WS-TALLY > 0
                 ADD EN-ITEM-COUNT(WS-I) TO WS-DROPS
             ELSE
                 ADD EN-ITEM-COUNT(WS-I) TO WS-OTHER
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance leaf decay 29b-3 5.4: the decayed leaves dropped saplings, sticks or apples (at least one item)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-DROPS > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance leaf decay 29b-3 5.4: nothing but the loot table items dropped (no leaves item, no other item)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OTHER TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   Placement through Use Item On: the leaf is persistent, with its distance. A log stands at (10, 12) of the floor, the player on the stone floor next to it.
     COMPUTE WS-X = WS-OX + 10
     MOVE WS-Y0 TO WS-Y
     COMPUTE WS-Z = WS-OZ + 12
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOG
     COMPUTE PL-X(WS-PLAYER) = WS-OX + 10.5
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0
     COMPUTE PL-Z(WS-PLAYER) = WS-OZ + 11.5
     MOVE "oak_leaves" TO WS-KEY112
     PERFORM HOLD-ITEM
*>   Beside the log: the east face of the log.
     MOVE 5 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
*>   Alone: the top of the stone floor at (10, 10).
     COMPUTE WS-SX = WS-OX + 10
     COMPUTE WS-SY = WS-Y0 - 1
     COMPUTE WS-SZ = WS-OZ + 10
     MOVE 1 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     MOVE 2 TO WS-COUNT
     CALL "TEST-TICKS-ANSWERED" USING WS-COUNT
     COMPUTE WS-X = WS-OX + 11
     MOVE WS-Y0 TO WS-Y
     COMPUTE WS-Z = WS-OZ + 12
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PLACED1
     COMPUTE WS-X = WS-OX + 10
     COMPUTE WS-Z = WS-OZ + 10
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PLACED2
     MOVE "acceptance leaf decay 29b-3 5.3 PL: a leaf placed beside a log through Use Item On is persistent with distance 1" TO WS-CASE
     MOVE WS-PLACED1 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "persistent=true distance=1" TO TL-EXPECTED
     MOVE WS-DISTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance leaf decay 29b-3 5.3 PL: a leaf placed alone through Use Item On is persistent with distance 7" TO WS-CASE
     MOVE WS-PLACED2 TO WS-STATE
     PERFORM PROPS-OF
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "persistent=true distance=7" TO TL-EXPECTED
     MOVE WS-DISTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 5 TO WS-TICKS
     PERFORM RUN-AND-DRAIN
     MOVE 0 TO WS-COUNT
     COMPUTE WS-X = WS-OX + 11
     COMPUTE WS-Z = WS-OZ + 12
     PERFORM CELL-IS-LEAF
     ADD WS-E TO WS-COUNT
     COMPUTE WS-X = WS-OX + 10
     COMPUTE WS-Z = WS-OZ + 10
     PERFORM CELL-IS-LEAF
     ADD WS-E TO WS-COUNT
     MOVE "acceptance leaf decay 29b-3 5.3: the two placed leaves are still there after 100 ticks at random tick speed 1000" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N

*>   A waterlogged leaf that decays leaves its water (removeBlock: the fluid's block).
     MOVE WS-LEAF TO WS-WATERLOGGED
     MOVE "waterlogged" TO WS-PROP
     MOVE "true" TO WS-TEXT
     CALL "PS-PUT" USING WS-WATERLOGGED WS-PROP WS-TEXT
     COMPUTE WS-X = WS-OX + 12
     COMPUTE WS-Y = WS-Y0 + 8
     COMPUTE WS-Z = WS-OZ + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATERLOGGED
     MOVE 1 TO WS-TICKS
     PERFORM RUN-AND-DRAIN
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-ITEM-KEY
     MOVE 0 TO WS-TALLY
     INSPECT WS-ITEM-KEY TALLYING WS-TALLY FOR ALL "water"
     MOVE "acceptance leaf decay 29b-3 5.4: a waterlogged leaf at distance 7 decays into water" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-TALLY > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     STOP RUN.

*> Puts five of the item WS-KEY112 in the first hotbar slot and selects it.
 HOLD-ITEM.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

*> WS-DISTS: for the eight cells east of WS-OX at WS-Y, WS-Z one character each, 1 for a leaf and 0 for anything else.
 LINE-STATUS.
     MOVE SPACES TO WS-DISTS
     MOVE 1 TO WS-I
     PERFORM VARYING WS-X FROM WS-OX1 BY 1 UNTIL WS-X > WS-OX + 8
         PERFORM CELL-IS-LEAF
         MOVE FUNCTION CHAR(WS-E + 49) TO WS-DISTS(WS-I:1)
         ADD 1 TO WS-I
     END-PERFORM.

*> WS-DISTS: "persistent=<text> distance=<text>" of the state WS-STATE.
 PROPS-OF.
     MOVE SPACES TO WS-DISTS
     MOVE "persistent" TO WS-PROP
     CALL "PS-GET" USING WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE WS-TEXT TO WS-ITEM-KEY
     MOVE "distance" TO WS-PROP
     CALL "PS-GET" USING WS-STATE WS-PROP WS-TEXT WS-FOUND
     STRING "persistent=" FUNCTION TRIM(WS-ITEM-KEY) " distance=" FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-DISTS.

*> Runs WS-TICKS ticks at the current random tick speed in steps of 20 and drains the connection of Alice each time: WS-SEEN becomes 1 when a Block Update (8) or Section Blocks Update (86) came.
 RUN-AND-DRAIN.
     PERFORM WS-TICKS TIMES
         MOVE 20 TO WS-COUNT
         CALL "TEST-TICKS-ANSWERED" USING WS-COUNT
         CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
         MOVE SPACES TO WS-PADDED
         STRING " " WS-IDS " " DELIMITED BY SIZE INTO WS-PADDED
         MOVE 0 TO WS-HITS
         INSPECT WS-PADDED TALLYING WS-HITS FOR ALL " 8 " ALL " 86 " ALL " 8x" ALL " 86x"
         IF WS-HITS > 0
             MOVE 1 TO WS-SEEN
         END-IF
     END-PERFORM.

*> WS-T1 and WS-T2: the leaf blocks (any state) in the canopy boxes of trees 1 and 2; WS-LINE1 and WS-LINE2: the leaves of the two lines.
 COUNT-TREES.
     MOVE 0 TO WS-T1 WS-T2 WS-LINE1 WS-LINE2
     PERFORM VARYING WS-X FROM WS-OX BY 1 UNTIL WS-X > WS-OX + 4
         PERFORM VARYING WS-Z FROM WS-OZ BY 1 UNTIL WS-Z > WS-OZ + 4
             PERFORM VARYING WS-Y FROM WS-Y02 BY 1 UNTIL WS-Y > WS-Y0 + 4
                 PERFORM CELL-IS-LEAF
                 ADD WS-E TO WS-T1
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-Z FROM WS-OZ7 BY 1 UNTIL WS-Z > WS-OZ + 11
             PERFORM VARYING WS-Y FROM WS-Y02 BY 1 UNTIL WS-Y > WS-Y0 + 4
                 PERFORM CELL-IS-LEAF
                 ADD WS-E TO WS-T2
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> WS-E: 1 when the cell WS-X, WS-Y, WS-Z holds a block of the oak leaves.
 CELL-IS-LEAF.
     MOVE 0 TO WS-E
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     IF CB-S-BLOCK(WS-STATE + 1) = WS-LEAF-BLOCK
         MOVE 1 TO WS-E
     END-IF.

*> WS-OBSERVE: the distance property of the leaf at WS-X, WS-Y, WS-Z, 0 when it holds no leaf.
 DISTANCE-AT.
     MOVE 0 TO WS-OBSERVE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     IF CB-S-BLOCK(WS-STATE + 1) = WS-LEAF-BLOCK
         MOVE "distance" TO WS-PROP
         CALL "PS-GET" USING WS-STATE WS-PROP WS-TEXT WS-FOUND
         IF WS-FOUND = 1
             COMPUTE WS-OBSERVE = FUNCTION ORD(WS-TEXT(1:1)) - 49
         END-IF
     END-IF.

*> WS-STATE: the default state of the block WS-KEY (a key without namespace in the generated set, or with), 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     MOVE SPACES TO WS-FULL-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-FULL-KEY
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY) OR FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-FULL-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-STATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGLEAFDECAY.
 COPY CORETEST.
