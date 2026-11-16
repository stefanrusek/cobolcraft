*> Turtle egg trampling (002-lane-mobsa5; docs/protocol/29b part 7 section 3.1 and 3.3: stepOn, fallOn, destroyEgg, canDestroyEgg, decreaseEggs; the GC7-EGG-* rule programs of growth-29b-7b.cob).
*> - M44-EGG-TRAMPLE USING dim, x, y, z (FLOAT-LONG, the entity's position), kind (1 turtle, 2 bat, 3 player, 4 other living, 5 other), trigger (1 stepOn, 2 fallOn), careful (sneaking), zombie, hit out:
*>   the block under the feet (the cell of y - 0.2) is a turtle egg: the chance is 100 for a step (not when sneaking) and 3 for a landing (not for a zombie); with canDestroyEgg (a turtle or bat never; a
*>   player outside spawn protection, which is not modelled (gap); another living entity with mob_griefing) and the draw nextInt(chance) = 0 one egg goes (eggs - 1, the block when it was the last).
*>   Gaps: the break sound and level event 2001 and the game events are not sent.
*> - M44-EGG-STEP USING mob row, was on ground: the mob's own call (STDMOB-STEP, after its physics, on the ground): a landing is a fallOn, otherwise a stepOn.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-EGG-TRAMPLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CHANCE              BINARY-LONG.
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-GRIEFING            BINARY-LONG.
 01 WS-PROTECTED           BINARY-LONG VALUE 0.
 01 WS-CAN                 BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 170.
 01 WS-DRAW                BINARY-LONG.
 01 WS-EGG                 BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG VALUE 1.
 01 WS-DESTROYED           BINARY-LONG.
 01 WS-DREW                BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "eggs".
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-EGGS                BINARY-LONG.
 01 WS-BREAK               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-GAME                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 01 L-CAREFUL              BINARY-LONG.
 01 L-ZOMBIE               BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-TRIGGER L-CAREFUL L-ZOMBIE L-HIT.
     MOVE 0 TO L-HIT
     COMPUTE WS-BX = FUNCTION INTEGER(L-X)
     COMPUTE WS-BY = FUNCTION INTEGER(L-Y - 0.2)
     COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
     CALL "IP-BLOCK-KEY" USING L-DIM WS-BX WS-BY WS-BZ WS-KEY WS-LENGTH
     IF WS-LENGTH = 20 AND WS-KEY(1:20) = "minecraft:turtle_egg"
         CALL "GC7-EGG-CHANCE" USING L-TRIGGER L-CAREFUL L-ZOMBIE WS-CHANCE
         IF WS-CHANCE > 0
             MOVE 0 TO WS-GRIEFING
             IF L-KIND = 4
                 CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
                 MOVE WS-GRIEF TO WS-GRIEFING
             END-IF
             CALL "GC7-EGG-CAN" USING L-KIND WS-PROTECTED WS-GRIEFING WS-CAN
             CALL "XP-RANDOM" USING WS-SALT WS-CHANCE WS-DRAW
             CALL "GC7-EGG-DESTROY" USING WS-EGG WS-SERVER WS-CAN WS-CHANCE WS-DRAW WS-DESTROYED WS-DREW
             IF WS-DESTROYED = 1
                 MOVE 1 TO L-HIT
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
                 CALL "BLOCK-STATE-PROP" USING WS-MODE-READ WS-STATE WS-PROP WS-TEXT WS-RESULT
                 COMPUTE WS-EGGS = FUNCTION NUMVAL(WS-TEXT)
                 CALL "GC7-EGG-DECREASE" USING WS-EGGS WS-BREAK WS-LEFT WS-EVENT WS-GAME
                 IF WS-BREAK = 1
                     CALL "BLOCK-CHANGE" USING L-DIM WS-BX WS-BY WS-BZ WS-AIR
                 ELSE
                     MOVE SPACES TO WS-TEXT
                     MOVE WS-LEFT TO WS-TEXT
                     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-TEXT WS-NEW
                     CALL "BLOCK-CHANGE" USING L-DIM WS-BX WS-BY WS-BZ WS-NEW
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-EGG-TRAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-EGG-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-KIND                BINARY-LONG.
 01 WS-TRIGGER             BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-CAREFUL             BINARY-LONG VALUE 0.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WAS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WAS.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     MOVE 4 TO WS-KIND
     IF WS-KEY = "turtle"
         MOVE 1 TO WS-KIND
     END-IF
     IF WS-KEY = "bat"
         MOVE 2 TO WS-KIND
     END-IF
     MOVE 0 TO WS-ZOMBIE
     IF WS-KEY = "zombie" OR "husk" OR "drowned" OR "zombie_villager" OR "zombified_piglin"
         MOVE 1 TO WS-ZOMBIE
     END-IF
     MOVE 1 TO WS-TRIGGER
     IF L-WAS = 0
         MOVE 2 TO WS-TRIGGER
     END-IF
     CALL "M44-EGG-TRAMPLE" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-KIND WS-TRIGGER WS-CAREFUL WS-ZOMBIE WS-HIT
     GOBACK.
 END PROGRAM M44-EGG-STEP.
