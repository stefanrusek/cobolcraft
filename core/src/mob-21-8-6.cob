*> The first tick of a lightning bolt (docs/protocol/21 section 8.6, 29b-3 sections 9.2 to 9.4, 29b-5 section 8), lane p49f: when its life is 2 (LIGHTNING-STEP, before the life falls) the block containing
*> (x, y - 1.0E-6, z) is struck. powerLightningRod: a lightning rod of any variant (family 13 of TOOLFAM.cpy, waxed or not) becomes powered, a block tick of delay 8 is scheduled (SW-RULES-OPEN gives every rod the
*> release rule of the buttons: powered false) and level event 3002 goes out with the axis of its facing (X 0, Y 1, Z 2). clearCopperOnLightningStrike: when the block is waxed or a weathering copper block (any
*> of the 15 families), an unwaxed one is reset to its unaffected variant, then 3 + nextInt(3) walks of 1 + nextInt(8) steps run from the strike position: a step draws up to 10 positions of the cube +- 1 around the
*> cursor (nextInt(3) for x, y, z), takes the first weathering copper block (never a waxed one), scrapes it one oxidation step back when it has one, sends level event 3002 with data -1 and moves the cursor there;
*> a walk ends when a step finds none. All of it runs for a visual-only bolt too (29b-3 9.4).
*> Not done: spawnFire(4) on Normal and Hard (the placement rule of the fire is not in the documents), updateNeighbours of the block the rod is fixed to (the rod's own change goes through BLOCK-CHANGE), the
*> game event lightning_strike, the advancement for players within 15 blocks, the sounds, the random source (the draws are the hash of xp.cob, not the level's random source).
*>
*>   LIGHTNING-CELL USING dim, x, y, z, state out, bare key out (PIC X(48)), waxed out, level out, family out
*>   LIGHTNING-SET-KEY USING dim, x, y, z, bare key (PIC X(48))   the block of that key with the properties of the one there
*>   LIGHTNING-ROD-POWER USING dim, x, y, z
*>   LIGHTNING-COPPER USING dim, x, y, z
*>   LIGHTNING-FIRST USING bolt row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-CELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-LONG                PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-WAXED                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-KEY L-WAXED L-LEVEL L-FAMILY.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG L-KEY
     CALL "TOOL-COPPER-PARSE" USING L-KEY L-WAXED L-LEVEL L-FAMILY
     GOBACK.
 END PROGRAM LIGHTNING-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-SET-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-LONG-KEY            PIC X(112).
 01 WS-NEW-ID              BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE SPACES TO WS-LONG-KEY
     STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-LONG-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-LONG-KEY WS-NEW-ID WS-ROW-TEXT WS-STATUS
*>   The weathering variants of a family have the same properties in the same order, so the state keeps its offset in the block's range.
     COMPUTE WS-NEW-STATE = CB-FIRST-STATE(WS-NEW-ID + 1) + WS-STATE - CB-FIRST-STATE(CB-S-BLOCK(WS-STATE + 1) + 1)
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW-STATE
     GOBACK.
 END PROGRAM LIGHTNING-SET-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-ROD-POWER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-WAXED               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME-FACING         PIC X(24) VALUE "facing".
 01 WS-NAME-POWERED        PIC X(24) VALUE "powered".
 01 WS-FACING              PIC X(32).
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-RESULT              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 8.
 01 WS-PRIO                BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 3002.
 01 WS-DATA                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "LIGHTNING-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-KEY WS-WAXED WS-LEVEL WS-FAMILY
     IF WS-FAMILY NOT = 13
         GOBACK
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-STATE WS-NAME-FACING WS-FACING WS-RESULT
     MOVE 1 TO WS-DATA
     IF WS-FACING = "north" OR "south"
         MOVE 2 TO WS-DATA
     END-IF
     IF WS-FACING = "east" OR "west"
         MOVE 0 TO WS-DATA
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-NAME-POWERED WS-TRUE WS-NEW
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
     MOVE CB-S-BLOCK(WS-NEW + 1) TO WS-BLOCK
     CALL "BT-SCHEDULE" USING L-DIM WS-TYPE WS-BLOCK L-X L-Y L-Z WS-DELAY WS-PRIO WS-RESULT
     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-DATA WS-NONE
     GOBACK.
 END PROGRAM LIGHTNING-ROD-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-COPPER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-NEW-KEY             PIC X(48).
 01 WS-WAXED               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-UNWAXED             BINARY-LONG VALUE 0.
 01 WS-LEVEL-NEW           BINARY-LONG.
 01 WS-WALKS               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SALT-WALKS          BINARY-LONG VALUE 9611.
 01 WS-SALT-STEPS          BINARY-LONG VALUE 9612.
 01 WS-SALT-CELL           BINARY-LONG VALUE 9613.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-DRAW                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3002.
 01 WS-DATA                BINARY-LONG VALUE -1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "LIGHTNING-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-KEY WS-WAXED WS-LEVEL WS-FAMILY
*>   Neither waxed nor weathering copper: nothing (a weathering block is a copper family member that is not waxed).
     IF WS-FAMILY = 0
         GOBACK
     END-IF
     IF WS-WAXED = 0
         MOVE 0 TO WS-LEVEL-NEW
         CALL "TOOL-COPPER-BUILD" USING WS-UNWAXED WS-LEVEL-NEW WS-FAMILY WS-NEW-KEY
         CALL "LIGHTNING-SET-KEY" USING L-DIM L-X L-Y L-Z WS-NEW-KEY
     END-IF
     CALL "XP-RANDOM" USING WS-SALT-WALKS WS-THREE WS-DRAW
     COMPUTE WS-WALKS = 3 + WS-DRAW
     PERFORM VARYING WS-WALK FROM 1 BY 1 UNTIL WS-WALK > WS-WALKS
         CALL "XP-RANDOM" USING WS-SALT-STEPS WS-EIGHT WS-DRAW
         COMPUTE WS-STEPS = 1 + WS-DRAW
         MOVE L-X TO WS-CX
         MOVE L-Y TO WS-CY
         MOVE L-Z TO WS-CZ
         MOVE 1 TO WS-FOUND
         PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > WS-STEPS OR WS-FOUND = 0
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 10 OR WS-FOUND = 1
                 CALL "XP-RANDOM" USING WS-SALT-CELL WS-THREE WS-DRAW
                 COMPUTE WS-PX = WS-CX + WS-DRAW - 1
                 CALL "XP-RANDOM" USING WS-SALT-CELL WS-THREE WS-DRAW
                 COMPUTE WS-PY = WS-CY + WS-DRAW - 1
                 CALL "XP-RANDOM" USING WS-SALT-CELL WS-THREE WS-DRAW
                 COMPUTE WS-PZ = WS-CZ + WS-DRAW - 1
                 CALL "LIGHTNING-CELL" USING L-DIM WS-PX WS-PY WS-PZ WS-STATE WS-KEY WS-WAXED WS-LEVEL WS-FAMILY
                 IF WS-FAMILY > 0 AND WS-WAXED = 0
                     MOVE 1 TO WS-FOUND
                     IF WS-LEVEL > 0
                         COMPUTE WS-LEVEL-NEW = WS-LEVEL - 1
                         CALL "TOOL-COPPER-BUILD" USING WS-UNWAXED WS-LEVEL-NEW WS-FAMILY WS-NEW-KEY
                         CALL "LIGHTNING-SET-KEY" USING L-DIM WS-PX WS-PY WS-PZ WS-NEW-KEY
                     END-IF
                     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-PX WS-PY WS-PZ WS-DATA WS-NONE
                     MOVE WS-PX TO WS-CX
                     MOVE WS-PY TO WS-CY
                     MOVE WS-PZ TO WS-CZ
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHTNING-COPPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-FIRST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW) - 0.000001)
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "LIGHTNING-ROD-POWER" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z
     CALL "LIGHTNING-COPPER" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM LIGHTNING-FIRST.
