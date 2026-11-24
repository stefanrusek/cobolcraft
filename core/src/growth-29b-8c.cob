*> Campfire, the other blocks, budding amethyst, the residual sweep and the coverage matrix (sections 3 to 7) of docs/protocol/29b part 8 as programs of plain numbers (GC8- prefix).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-CONST.
*> USING the kind (1 campfire, 2 soul campfire), then spawnParticles and fireDamage out (3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PARTICLES L-DAMAGE.
     MOVE 1 TO L-PARTICLES L-DAMAGE
     IF L-KIND = 2
         MOVE 0 TO L-PARTICLES
         MOVE 2 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GC8-CAMP-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-UPDATE.
*> USING waterlogged, the changed direction is DOWN, the block below is a hay_block, then a water tick scheduled, signal_fire set, its value, the base method called out (3 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-DOWN                 BINARY-LONG.
 01 L-HAY                  BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-DOWN L-HAY L-TICK L-SET L-SIGNAL L-BASE.
     MOVE L-WATERLOGGED TO L-TICK
     MOVE 0 TO L-SET L-SIGNAL L-BASE
     IF L-DOWN = 1
         MOVE 1 TO L-SET
         MOVE L-HAY TO L-SIGNAL
     ELSE
         MOVE 1 TO L-BASE
     END-IF
     GOBACK.
 END PROGRAM GC8-CAMP-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-CANLIGHT.
*> USING the state is in the block tag campfires, waterlogged, lit, canLight out (3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-WATERLOGGED L-LIT L-CAN.
     MOVE 0 TO L-CAN
     IF L-TAG = 1 AND L-WATERLOGGED = 0 AND L-LIT = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC8-CAMP-CANLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-CONTACT.
*> USING lit, the entity is a LivingEntity, then it is hurt, it is set alight (never) out (3 entityInside).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-IGNITES              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-LIVING L-HURT L-IGNITES.
     MOVE 0 TO L-HURT L-IGNITES
     IF L-LIT = 1 AND L-LIVING = 1
         MOVE 1 TO L-HURT
     END-IF
     GOBACK.
 END PROGRAM GC8-CAMP-CONTACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-HOOKS.
*> USING the hook (1 scheduled tick, 2 random tick, 3 neighbour hook, 4 spreads fire), the campfire has it (always 0) out (3 Block tick).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC8-CAMP-HOOKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CAMP-SMOKEY.
*> USING the cells 1 to 6 below the position (6 BINARY-LONG items in one group: 0 lets smoke through, 1 a lit campfire, 2 blocks the post), smoky, the cells scanned out (3 isSmokeyPos).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-CELL              BINARY-LONG OCCURS 6 TIMES.
 01 L-SMOKY                BINARY-LONG.
 01 L-SCANNED              BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-SMOKY L-SCANNED.
     MOVE 0 TO L-SMOKY L-SCANNED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR L-SCANNED > 0
         EVALUATE L-CELL(WS-I)
             WHEN 1
                 MOVE 1 TO L-SMOKY
                 MOVE WS-I TO L-SCANNED
             WHEN 2
                 IF L-CELL(WS-I + 1) = 1
                     MOVE 1 TO L-SMOKY
                 END-IF
                 MOVE WS-I TO L-SCANNED
         END-EVALUATE
     END-PERFORM
     IF L-SCANNED = 0
         MOVE 5 TO L-SCANNED
     END-IF
     GOBACK.
 END PROGRAM GC8-CAMP-SMOKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-OTHER-OWNER.
*> USING the row (1 to 11) of the table of 4 in its order (BINARY-LONG), the owner document PIC X(64) out (blank for another row).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "30 p7 s8" TO L-DOC
         WHEN 2 THRU 4
             MOVE "31 p7" TO L-DOC
         WHEN 5
             MOVE "24 p8 (row 626); 31-8" TO L-DOC
         WHEN 6
             MOVE "30 p5 s6" TO L-DOC
         WHEN 7
             MOVE "30 p5 s8" TO L-DOC
         WHEN 8
             MOVE "31 p4 s2; 30 p5 s9" TO L-DOC
         WHEN 9
             MOVE "31 p4 s3.7" TO L-DOC
         WHEN 10
             MOVE "31 p4 s4.5; 30 p8" TO L-DOC
         WHEN 11
             MOVE "30 p5 s5" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-OTHER-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-OTHER-HOOKS.
*> USING the row (1 to 11) of the table of 4, the class declares tick, randomTick or neighborChanged out (4, 6): TntBlock, TargetBlock, NoteBlock, LecternBlock and BellBlock do.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HOOK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HOOK.
     MOVE 0 TO L-HOOK
     IF L-ROW = 1 OR L-ROW = 6 OR L-ROW = 7 OR L-ROW = 9 OR L-ROW = 10
         MOVE 1 TO L-HOOK
     END-IF
     GOBACK.
 END PROGRAM GC8-OTHER-HOOKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-TARGET-TICK.
*> USING power, the new power, power was changed out (4 TargetBlock.tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-NEW L-CHANGED.
     MOVE 0 TO L-NEW L-CHANGED
     IF L-POWER NOT = 0
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM GC8-TARGET-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-LECTERN-TICK.
*> USING powered, the new powered, powered was changed out (4 LecternBlock.tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-NEW L-CHANGED.
     MOVE 0 TO L-NEW
     MOVE L-POWERED TO L-CHANGED
     GOBACK.
 END PROGRAM GC8-LECTERN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-CONDUIT-ST.
*> USING waterlogged, a water tick is scheduled out (4 ConduitBlock.updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-TICK.
     MOVE L-WATERLOGGED TO L-TICK
     GOBACK.
 END PROGRAM GC8-CONDUIT-ST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-BUDDING-CONST.
*> USING the selector (1 GROWTH_CHANCE, 2 the face draw bound, 3 one over the growth probability of one face per random tick, 4 the stages), the value out (5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 30.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC8-BUDDING-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-BUDDING-OWNER.
*> USING a placeholder (BINARY-LONG), the owner of the budding amethyst rules PIC X(64) out (5): 29b part 6 section 3.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ANY                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ANY L-DOC.
     MOVE "29b-6 s3.3" TO L-DOC
     GOBACK.
 END PROGRAM GC8-BUDDING-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-SWEEP-NUM.
*> USING the selector (1 top-level classes, 2 class files, 3 inner classes, 4 classes that declare a hook, 5 hook names matched), the value out (6, 9 validation 11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 330.
    05 FILLER              BINARY-LONG VALUE 410.
    05 FILLER              BINARY-LONG VALUE 80.
    05 FILLER              BINARY-LONG VALUE 105.
    05 FILLER              BINARY-LONG VALUE 3.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC8-SWEEP-NUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-HOOK-NAME.
*> USING the hook (1 to 3) (BINARY-LONG), its method name PIC X(64) out (6 step 1; blank for another number).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-NAME                 PIC X(64).
 PROCEDURE DIVISION USING L-HOOK L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-HOOK
         WHEN 1
             MOVE "tick" TO L-NAME
         WHEN 2
             MOVE "randomTick" TO L-NAME
         WHEN 3
             MOVE "neighborChanged" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-HOOK-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-STATUS-NAME.
*> USING the status code (1 Covered, 2 Partial, 3 Unclaimed, 4 Covered / Partial) (BINARY-LONG), its name PIC X(64) out (6 step 3, 7; blank for another number).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-NAME                 PIC X(64).
 PROCEDURE DIVISION USING L-STATUS L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-STATUS
         WHEN 1
             MOVE "Covered" TO L-NAME
         WHEN 2
             MOVE "Partial" TO L-NAME
         WHEN 3
             MOVE "Unclaimed" TO L-NAME
         WHEN 4
             MOVE "Covered / Partial" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-STATUS-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-MATRIX.
*> USING the row (1 to 34) of the matrix of 7 in its order (BINARY-LONG), the document that specifies the class group PIC X(64) out (blank for a row outside the matrix).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DOCS.
    05 FILLER              PIC X(64) VALUE "17 s3.3a; 29b-8 s2".
    05 FILLER              PIC X(64) VALUE "29b-1 s3".
    05 FILLER              PIC X(64) VALUE "29b-1 s3.7, s3.5; 31-4".
    05 FILLER              PIC X(64) VALUE "29b-1 s7".
    05 FILLER              PIC X(64) VALUE "29b-1 s6; 29b-2".
    05 FILLER              PIC X(64) VALUE "29b-3".
    05 FILLER              PIC X(64) VALUE "29b-5".
    05 FILLER              PIC X(64) VALUE "30 p5 s7; 29b-3".
    05 FILLER              PIC X(64) VALUE "29b-7 s2 to s9; 24 p6, p8".
    05 FILLER              PIC X(64) VALUE "29a; 29b-4 s3".
    05 FILLER              PIC X(64) VALUE "30 p1, p7".
    05 FILLER              PIC X(64) VALUE "30 p2".
    05 FILLER              PIC X(64) VALUE "30 p3".
    05 FILLER              PIC X(64) VALUE "30 p4".
    05 FILLER              PIC X(64) VALUE "30 p5".
    05 FILLER              PIC X(64) VALUE "30 p6; 29".
    05 FILLER              PIC X(64) VALUE "30 p7".
    05 FILLER              PIC X(64) VALUE "30 p8; 31 p8; 31-4".
    05 FILLER              PIC X(64) VALUE "31 p8".
    05 FILLER              PIC X(64) VALUE "31 p1".
    05 FILLER              PIC X(64) VALUE "31 p6".
    05 FILLER              PIC X(64) VALUE "31 p3; 30 p1".
    05 FILLER              PIC X(64) VALUE "31 p4".
    05 FILLER              PIC X(64) VALUE "24 p3, p6, p7, p2".
    05 FILLER              PIC X(64) VALUE "29b-6 s3.3".
    05 FILLER              PIC X(64) VALUE "29b-4 s10.3".
    05 FILLER              PIC X(64) VALUE "29b-8 s7.1".
    05 FILLER              PIC X(64) VALUE "29b-4 s7".
    05 FILLER              PIC X(64) VALUE "29b-4 s6".
    05 FILLER              PIC X(64) VALUE "29b-4 s3".
    05 FILLER              PIC X(64) VALUE "29b-4 s12, s13.3".
    05 FILLER              PIC X(64) VALUE "29b-6 s4 to s9; 29b-7 s8.6".
    05 FILLER              PIC X(64) VALUE "24 p6".
    05 FILLER              PIC X(64) VALUE "29b-1".
 01 WS-DOC-T REDEFINES WS-DOCS.
    05 WS-DOC              PIC X(64) OCCURS 34 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     IF L-ROW >= 1 AND L-ROW <= 34
         MOVE WS-DOC(L-ROW) TO L-DOC
     END-IF
     GOBACK.
 END PROGRAM GC8-MATRIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-MATRIX-STATUS.
*> USING the row (1 to 34) of the matrix of 7, its status out (1 Covered, 2 Partial, 4 Covered / Partial; 0 for a row outside the matrix: no row is Unclaimed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATUSES.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-STATUS-T REDEFINES WS-STATUSES.
    05 WS-STATUS           BINARY-LONG OCCURS 34 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATUS.
     MOVE 0 TO L-STATUS
     IF L-ROW >= 1 AND L-ROW <= 34
         MOVE WS-STATUS(L-ROW) TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM GC8-MATRIX-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-POT-TICK.
*> USING the pot (0 other, 1 potted_open_eyeblossom, 2 potted_closed_eyeblossom), the wanted state of gameplay/eyeblossom_open (0 unset, 1 open, 2 closed), then the pot is random-ticking, it changed,
*> the pot after, the type of the switch sound, the transform particle, the inherited randomTick ran out (7.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPEN                BINARY-LONG.
 01 WS-WANT-OPEN           BINARY-LONG.
 LINKAGE SECTION.
 01 L-POT                  BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-PARTICLE             BINARY-LONG.
 01 L-INHERITED            BINARY-LONG.
 PROCEDURE DIVISION USING L-POT L-WANT L-TICKING L-CHANGED L-NEW L-SOUND L-PARTICLE L-INHERITED.
     MOVE 0 TO L-TICKING L-CHANGED L-SOUND L-PARTICLE L-INHERITED
     MOVE L-POT TO L-NEW
     IF L-POT = 1 OR L-POT = 2
         MOVE 1 TO L-TICKING L-INHERITED
         MOVE 0 TO WS-OPEN
         IF L-POT = 1
             MOVE 1 TO WS-OPEN
         END-IF
         MOVE WS-OPEN TO WS-WANT-OPEN
         IF L-WANT = 1
             MOVE 1 TO WS-WANT-OPEN
         END-IF
         IF L-WANT = 2
             MOVE 0 TO WS-WANT-OPEN
         END-IF
         IF WS-WANT-OPEN NOT = WS-OPEN
             MOVE 1 TO L-CHANGED L-PARTICLE
             COMPUTE L-NEW = 3 - L-POT
             MOVE L-NEW TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-POT-TICK.
