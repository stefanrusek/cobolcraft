*> Blocks that hold water without being the water block (lane kelpfix; docs/protocol/29a section 5): kelp, kelp plant, seagrass, tall seagrass and the bubble column are always full of water
*> (their fluid state is the water source, fluid never flows into them: 5.2); a block with the waterlogged property (5.1: slabs, fences, ladders, signs, chests, corals, sea pickles ...) holds a
*> water source while the property is true, and flowing water is never accepted into it (canPlaceLiquid is true for the source fluid only, so spreading water stops at it).
*>
*> Entry points:
*>   FLUID-CONTAINER USING block state, class out (0 none, 1 water plant, 2 waterlogged-capable block), full out (1 when the state holds a water source)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-CONTAINER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-CLASSES.
    05 WS-CLASS            BINARY-LONG OCCURS 2048 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FULL                PIC X(48).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CLASS L-FULL.
     MOVE 0 TO L-CLASS L-FULL
     IF CB-EPOCH NOT = WS-EPOCH
         MOVE CB-EPOCH TO WS-EPOCH
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
             MOVE 0 TO WS-CLASS(WS-I)
             CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
             EVALUATE FUNCTION TRIM(WS-FULL)
                 WHEN "minecraft:kelp"
                 WHEN "minecraft:kelp_plant"
                 WHEN "minecraft:seagrass"
                 WHEN "minecraft:tall_seagrass"
                 WHEN "minecraft:bubble_column"
                     MOVE 1 TO WS-CLASS(WS-I)
                 WHEN OTHER
                     CALL "BLOCK-STATE-PROP" USING WS-MODE CB-DEFAULT-STATE(WS-I) WS-NAME WS-TEXT WS-FOUND
                     IF WS-FOUND = 1
                         MOVE 2 TO WS-CLASS(WS-I)
                     END-IF
             END-EVALUATE
         END-PERFORM
     END-IF
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     MOVE WS-CLASS(CB-S-BLOCK(L-STATE + 1) + 1) TO L-CLASS
     IF L-CLASS = 1
         MOVE 1 TO L-FULL
     END-IF
     IF L-CLASS = 2
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = "true"
             MOVE 1 TO L-FULL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FLUID-CONTAINER.
