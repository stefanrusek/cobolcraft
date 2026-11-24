*> Acceptance test (wrap agent B round 4, T29574; docs/protocol/30-redstone-4 sections 4.3 and 4.17): a dispenser with glowstone charges the respawn anchor in front of it (one charge per item, nothing at 4
*> charges: the item stays) and drops it in front of any other block; a dispenser with a chest puts it on the tamed donkey that stands in the front cell and has no chest, else drops it. The standard world of
*> the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY WCSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-blocks-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-OBS                 PIC X(160).
 01 WS-BE                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM-ED              PIC -(9)9.
 01 WS-A-ED                PIC -(9)9.
 01 WS-B-ED                PIC -(9)9.
 01 WS-C-ED                PIC -(9)9.
 01 WS-BELOW               BINARY-LONG VALUE 0.
 01 WS-HITS                BINARY-LONG.
 01 WS-HITS2               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(1040).
 01 WS-TYPE-KEY            PIC X(112) VALUE "minecraft:donkey".
 01 WS-DONKEY              BINARY-LONG.
 01 WS-DROW                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TAMED               BINARY-LONG.
 01 WS-HAS-CHEST           BINARY-LONG.
 01 WS-OFF-X               FLOAT-LONG.
 01 WS-OFF-Y               FLOAT-LONG.
 01 WS-OFF-Z               FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense blocks: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 40
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-BLOCK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 60.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "glowstone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-GLOW
     MOVE "chest" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-CHEST
     CALL "THROWN-TYPE" USING WS-TYPE-KEY WS-DONKEY

*>   A. glowstone into an anchor with no charge: one charge, one glowstone spent, nothing dropped, the click and the smoke (two Level Events)
     MOVE 0 TO WS-Z
     MOVE WS-GLOW TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "respawn_anchor" TO WS-K MOVE "charges=0" TO WS-PR PERFORM PUT-BLOCK
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-ANCHOR
     MOVE "acceptance wrapb dispense 30-4 4.17 glowstone charges an empty respawn anchor: charges 1, one glowstone left, none dropped, events 1000 and 2000" TO WS-CASE
     MOVE "charges=1 1 0 2" TO WS-EXP
     PERFORM ASSERT-OBS

*>   B. an anchor with 3 charges takes the fourth
     MOVE 2 TO WS-Z
     MOVE WS-GLOW TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "respawn_anchor" TO WS-K MOVE "charges=3" TO WS-PR PERFORM PUT-BLOCK
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-HITS
     PERFORM OBS-ANCHOR
     MOVE "acceptance wrapb dispense 30-4 4.17 an anchor with 3 charges takes the fourth" TO WS-CASE
     MOVE "charges=4 1 0 0" TO WS-EXP
     PERFORM ASSERT-OBS

*>   C. a full anchor refuses: the glowstone stays in the dispenser and is not dropped
     MOVE 4 TO WS-Z
     MOVE WS-GLOW TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "respawn_anchor" TO WS-K MOVE "charges=4" TO WS-PR PERFORM PUT-BLOCK
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-HITS
     PERFORM OBS-ANCHOR
     MOVE "acceptance wrapb dispense 30-4 4.17 an anchor with 4 charges refuses: the glowstone stays, nothing is dropped" TO WS-CASE
     MOVE "charges=4 2 0 0" TO WS-EXP
     PERFORM ASSERT-OBS

*>   D. glowstone in front of any other block is dropped
     MOVE 6 TO WS-Z
     MOVE WS-GLOW TO WS-ITEM
     PERFORM MAKE-DISPENSER
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE WS-GLOW TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     MOVE "acceptance wrapb dispense 30-4 4.17 glowstone with air in front is dropped as one item entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   E to I. the chest: a tamed donkey with no chest in the front cell takes it; an untamed one, one with a chest and ones outside the cell do not (the chest is dropped)
     MOVE 8 TO WS-Z MOVE 1 TO WS-TAMED MOVE 0 TO WS-HAS-CHEST MOVE 0 TO WS-OFF-X MOVE 0 TO WS-OFF-Y MOVE 0 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 a tamed donkey without a chest takes the chest: flag set, one chest left, none dropped" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 10 TO WS-Z MOVE 0 TO WS-TAMED MOVE 0 TO WS-HAS-CHEST MOVE 0 TO WS-OFF-X MOVE 0 TO WS-OFF-Y MOVE 0 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 an untamed donkey is skipped: no flag, the chest is dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 12 TO WS-Z MOVE 1 TO WS-TAMED MOVE 1 TO WS-HAS-CHEST MOVE 0 TO WS-OFF-X MOVE 0 TO WS-OFF-Y MOVE 0 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 a tamed donkey that has a chest is skipped: the chest is dropped" TO WS-CASE
     MOVE "1 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 14 TO WS-Z MOVE 1 TO WS-TAMED MOVE 0 TO WS-HAS-CHEST MOVE 3 TO WS-OFF-X MOVE 0 TO WS-OFF-Y MOVE 0 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 a tamed donkey 3 blocks east of the front cell is not in the front box: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 16 TO WS-Z MOVE 1 TO WS-TAMED MOVE 0 TO WS-HAS-CHEST MOVE 0 TO WS-OFF-X MOVE 0 TO WS-OFF-Y MOVE 3 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 a tamed donkey 3 blocks south of the front cell is not in the front box: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 18 TO WS-Z MOVE 1 TO WS-TAMED MOVE 0 TO WS-HAS-CHEST MOVE 0 TO WS-OFF-X MOVE 3 TO WS-OFF-Y MOVE 0 TO WS-OFF-Z
     PERFORM CHEST-CASE
     MOVE "acceptance wrapb dispense 30-4 4.3 a tamed donkey 3 blocks above the front cell (on a stone block) is not in the front box: no flag, one chest left, the chest dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
     STOP RUN.

 MAKE-DISPENSER.
*>   a dispenser facing east at (3, 101, WS-Z) holding 2 of item WS-ITEM in its first slot, its block entity in WS-BE
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K MOVE "facing=east,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1).

 CHEST-CASE.
*>   MAKE-DISPENSER with 2 chests and a donkey at the front cell centre shifted by WS-OFF-X, -Y and -Z (tamed by WS-TAMED, with a chest by WS-HAS-CHEST), powered;
*>   WS-OBS = "<the donkey's chest flag> <the chests left in the dispenser> <the chests lying in the row>"
     MOVE WS-CHEST TO WS-ITEM
     PERFORM MAKE-DISPENSER
*>   a donkey is 1.4 wide: it stands 0.3 east of the cell centre so that its box stays clear of the dispenser's cell
     IF WS-OFF-Y > 0
         COMPUTE WS-Y = 101 + WS-OFF-Y - 1
         MOVE 4 TO WS-X MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
         MOVE 5 TO WS-X PERFORM PUT-BLOCK
     END-IF
     COMPUTE WS-DX = 4.8 + WS-OFF-X
     COMPUTE WS-DY = 101 + WS-OFF-Y
     COMPUTE WS-DZ = WS-Z + 0.5 + WS-OFF-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-DONKEY WS-DX WS-DY WS-DZ WS-YAW WS-DROW
     MOVE WS-TAMED TO EN-TAMED(WS-DROW)
     CALL "WC-ROW-OPEN" USING WS-DROW
     MOVE WS-HAS-CHEST TO WC-CHEST(WS-DROW)
     PERFORM POWER-ON
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE WS-CHEST TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     MOVE WC-CHEST(WS-DROW) TO WS-A-ED
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS
*>   the donkey goes away: one that stays (a donkey 3 blocks south reaches into the next row's front cell) takes the chest of a later case
     CALL "ENTITY-REMOVE" USING WS-DROW.

 POWER-ON.
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK.

 OBS-ANCHOR.
*>   WS-OBS = "<the anchor's properties> <the dispenser's slot count> <the entities of WS-ITEM in the row> <the Level Event packets WS-HITS>" of the case
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     PERFORM SUM-ENTITIES-OF
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A-ED
     MOVE WS-HITS TO WS-B-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-SUM-ED) " " FUNCTION TRIM(WS-B-ED) DELIMITED BY SIZE INTO WS-OBS.

 ASSERT-OBS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SUM-ENTITIES-OF.
*>   the item entities of item WS-ITEM within the row WS-Z: the count in WS-SUM and WS-SUM-ED
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ITEM
                 AND EN-Z(WS-I) >= WS-Z AND EN-Z(WS-I) < WS-Z + 1
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE WS-SUM TO WS-SUM-ED.

 COUNT-EVENTS.
*>   the Level Event packets (id 47) in the ids drained into WS-TEXT, a run "47x2" counting twice
     MOVE SPACES TO WS-LINE
     STRING " " FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO WS-LINE
     MOVE 0 TO WS-HITS WS-HITS2
     INSPECT WS-LINE TALLYING WS-HITS FOR ALL " 47 "
     INSPECT WS-LINE TALLYING WS-HITS2 FOR ALL " 47x2 "
     COMPUTE WS-HITS = WS-HITS + 2 * WS-HITS2.

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 CLEAR-ROW.
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
             MOVE "air" TO WS-K MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
         END-PERFORM
     END-PERFORM.

 PUT-BLOCK.
*>   the block of key WS-K and property pairs WS-PR at (WS-X, WS-Y, WS-Z), written with flags 3
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-DISPENSE-BLOCKS.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
