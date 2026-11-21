*> The dried ghast block and the hatching of a happy ghast (docs/protocol/44-9 section 9.1), lane p49f. DG-RULES-OPEN (called when a world opens, after SW-RULES-OPEN) gives the block the hook rules of kind 8 (random
*> tick) and kind 7 (scheduled tick) with effect 11 of BU-HOOK, which calls DG-HOOK. Random tick: a block that is waterlogged or has hydration_level > 0 schedules a block tick in 5000 ticks (BT-SCHEDULE keeps one).
*> Block tick: a dry block with hydration > 0 loses 1; a waterlogged block with hydration below 3 gains 1; at 3 it hatches: the block is removed (no drop) and a baby happy ghast (age -24000) appears at the block's
*> bottom centre with the block's facing as yaw (south 0, west 90, north 180, east 270).
*> Not done: the sounds (place, transition, ghastling spawn), the BLOCK_CHANGE game events, the placement and waterlogging of the block by items, the head yaw, the client ambience, the recipe and the piglin barter.
*>
*>   DG-RULES-OPEN                                  the hook rules of the open block tables
*>   DG-HOOK USING kind (7 or 8), dim, x, y, z, state
*>   DG-HATCH USING dim, x, y, z, facing text (PIC X(16))   the baby ghast of the hatching
*>   HG-BABY USING row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DG-RULES-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:dried_ghast".
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 11.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BU-ENSURE"
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
         IF BU-R-BLOCK(WS-R) = WS-ID AND BU-R-EFFECT(WS-R) = 11
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE 7 TO WS-KIND
         CALL "BU-RULE-ADD" USING WS-KIND WS-ID WS-EFFECT WS-ZERO WS-ZERO2
         MOVE 8 TO WS-KIND
         CALL "BU-RULE-ADD" USING WS-KIND WS-ID WS-EFFECT WS-ZERO WS-ZERO2
     END-IF
     GOBACK.
 END PROGRAM DG-RULES-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DG-HATCH.
*> USING dim, x, y, z (the block), facing text (PIC X(16)): the baby happy ghast at the block's bottom centre with the facing's yaw (nothing in a content set without the entity type).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:happy_ghast".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               PIC X(16).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING.
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     EVALUATE L-FACING
         WHEN "west"
             MOVE 90 TO WS-YAW
         WHEN "north"
             MOVE 180 TO WS-YAW
         WHEN "east"
             MOVE 270 TO WS-YAW
         WHEN OTHER
             MOVE 0 TO WS-YAW
     END-EVALUATE
     COMPUTE WS-X = L-X + 0.5
     MOVE L-Y TO WS-Y
     COMPUTE WS-Z = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "HG-BABY" USING WS-ROW
     GOBACK.
 END PROGRAM DG-HATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DG-HOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-NAME-HYD            PIC X(16) VALUE "hydration".
 01 WS-NAME-WET            PIC X(16) VALUE "waterlogged".
 01 WS-NAME-FACING         PIC X(16) VALUE "facing".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-HYD-TEXT            PIC X(16).
 01 WS-WET-TEXT            PIC X(16).
 01 WS-FACING-TEXT         PIC X(16).
 01 WS-NEW-TEXT            PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-DIGIT               PIC 9.
 01 WS-HYD                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 5000.
 01 WS-PRIO                BINARY-LONG VALUE 0.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "SW-SET-PROP" USING L-STATE WS-NAME-HYD WS-KEEP WS-RESULT WS-HYD-TEXT
     CALL "SW-SET-PROP" USING L-STATE WS-NAME-WET WS-KEEP WS-RESULT WS-WET-TEXT
     COMPUTE WS-HYD = FUNCTION NUMVAL(WS-HYD-TEXT)
     IF L-KIND = 8
         IF WS-WET-TEXT = "true" OR WS-HYD > 0
             CALL "BT-SCHEDULE" USING L-DIM WS-TYPE-BLOCK WS-BLOCK L-X L-Y L-Z WS-DELAY WS-PRIO WS-RESULT
         END-IF
         GOBACK
     END-IF
*>   The block tick.
     IF WS-WET-TEXT NOT = "true"
         IF WS-HYD > 0
             COMPUTE WS-DIGIT = WS-HYD - 1
             MOVE WS-DIGIT TO WS-NEW-TEXT
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-HYD WS-NEW-TEXT WS-NEW WS-OLD
             CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
         END-IF
         GOBACK
     END-IF
     IF WS-HYD NOT = 3
         COMPUTE WS-DIGIT = WS-HYD + 1
         MOVE WS-DIGIT TO WS-NEW-TEXT
         CALL "SW-SET-PROP" USING L-STATE WS-NAME-HYD WS-NEW-TEXT WS-NEW WS-OLD
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
         GOBACK
     END-IF
*>   The hatch.
     CALL "SW-SET-PROP" USING L-STATE WS-NAME-FACING WS-KEEP WS-RESULT WS-FACING-TEXT
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-AIR
     CALL "DG-HATCH" USING L-DIM L-X L-Y L-Z WS-FACING-TEXT
     GOBACK.
 END PROGRAM DG-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-BABY.
*> USING row: the happy ghast row becomes a baby at the framework's baby age -24000, and the viewers are told.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 1 TO EN-VARIANT(L-ROW)
     MOVE -24000 TO EN-MOBAGE(L-ROW)
     CALL "MOB-DATA-SEND" USING L-ROW
     GOBACK.
 END PROGRAM HG-BABY.
