*> Scope and corals of docs/protocol/29b part 7 (sections 1 and 2) as programs of plain numbers (GC7- prefix), helpers like those of growth-29b-6.cob.
*> Facing codes: 1 north, 2 east, 3 south, 4 west, 5 up, 6 down. Shapes are boxes in pixels (x0 y0 z0 x1 y1 z1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-OWNER.
*> USING the row (1 to 16) of the owner table of 1.1 in its order (BINARY-LONG), the owner document PIC X(64) out (blank for a row outside the table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "24" TO L-DOC
         WHEN 2
             MOVE "24 p1 s6" TO L-DOC
         WHEN 3
             MOVE "31-4" TO L-DOC
         WHEN 4
             MOVE "33 s4" TO L-DOC
         WHEN 5
             MOVE "29a; 25-5" TO L-DOC
         WHEN 6
             MOVE "29a; 44-1 s4.3" TO L-DOC
         WHEN 7
             MOVE "44-1 RQ-1.9; 13" TO L-DOC
         WHEN 8
             MOVE "44-x1 s2.1" TO L-DOC
         WHEN 9
             MOVE "44-4; 19" TO L-DOC
         WHEN 10
             MOVE "44-x1 s2.3" TO L-DOC
         WHEN 11
             MOVE "17 s3.3" TO L-DOC
         WHEN 12
             MOVE "29b-3 s10.3, s9.2" TO L-DOC
         WHEN 13
             MOVE "29b-6 s7, s8" TO L-DOC
         WHEN 14
             MOVE "29b-5" TO L-DOC
         WHEN 15
             MOVE "42; 21" TO L-DOC
         WHEN 16
             MOVE "advancement round" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BLOCK-SECTION.
*> USING the row (1 to 22) of the block table of 1.3 in its order (BINARY-LONG), the section that holds the block PIC X(64) out (blank for a row outside the table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SECTIONS.
    05 FILLER              PIC X(4) VALUE "2.3".
    05 FILLER              PIC X(4) VALUE "2.4".
    05 FILLER              PIC X(4) VALUE "2.5".
    05 FILLER              PIC X(4) VALUE "2.6".
    05 FILLER              PIC X(4) VALUE "2.2".
    05 FILLER              PIC X(4) VALUE "2.4".
    05 FILLER              PIC X(4) VALUE "2.5".
    05 FILLER              PIC X(4) VALUE "2.6".
    05 FILLER              PIC X(4) VALUE "3".
    05 FILLER              PIC X(4) VALUE "4".
    05 FILLER              PIC X(4) VALUE "5".
    05 FILLER              PIC X(4) VALUE "6".
    05 FILLER              PIC X(4) VALUE "7".
    05 FILLER              PIC X(4) VALUE "8.2".
    05 FILLER              PIC X(4) VALUE "8.3".
    05 FILLER              PIC X(4) VALUE "8.4".
    05 FILLER              PIC X(4) VALUE "9.2".
    05 FILLER              PIC X(4) VALUE "9.3".
    05 FILLER              PIC X(4) VALUE "9.4".
    05 FILLER              PIC X(4) VALUE "10.1".
    05 FILLER              PIC X(4) VALUE "10.2".
    05 FILLER              PIC X(4) VALUE "10.3".
 01 WS-SECTION-T REDEFINES WS-SECTIONS.
    05 WS-SECTION          PIC X(4) OCCURS 22 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     IF L-ROW >= 1 AND L-ROW <= 22
         MOVE WS-SECTION(L-ROW) TO L-DOC
     END-IF
     GOBACK.
 END PROGRAM GC7-BLOCK-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FLAGS.
*> USING the selector (BINARY-LONG), the value out (1.2): 1 setBlock flags 2, 2 setBlockAndUpdate flags 3, 3 setLit flags 11, 4 scheduled fluid tick delay 5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 5.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-COUNT.
*> USING species, forms, states, registry blocks out (1): 5 species times 4 forms times 2 states.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECIES              BINARY-LONG.
 01 L-FORMS                BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-FORMS L-STATES L-TOTAL.
     MOVE 5 TO L-SPECIES
     MOVE 4 TO L-FORMS
     MOVE 2 TO L-STATES
     COMPUTE L-TOTAL = L-SPECIES * L-FORMS * L-STATES
     GOBACK.
 END PROGRAM GC7-CORAL-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-DELAY.
*> USING the draw nextInt(40) (BINARY-LONG), the die tick delay out (2.1): 60 + draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-DELAY.
     COMPUTE L-DELAY = 60 + L-DRAW
     GOBACK.
 END PROGRAM GC7-CORAL-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-WET.
*> USING the kind (1 coral block, 2 plant type), waterlogged, the neighbours (of 6) that hold water, the water test out (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-WATERLOGGED L-NEIGHBOURS L-WET.
     MOVE 0 TO L-WET
     IF L-NEIGHBOURS > 0
         MOVE 1 TO L-WET
     END-IF
     IF L-KIND = 2 AND L-WATERLOGGED = 1
         MOVE 1 TO L-WET
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-WET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-BLOCK.
*> USING the trigger (1 placement query, 2 updateShape, 3 block tick), the water test, the die tick scheduled, the dead block written, the flags out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-WET L-SCHEDULE L-DEAD L-FLAGS.
     MOVE 0 TO L-SCHEDULE L-DEAD L-FLAGS
     IF L-WET = 0
         IF L-TRIGGER = 3
             MOVE 1 TO L-DEAD
             MOVE 2 TO L-FLAGS
         ELSE
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-DIE.
*> USING the water test, the dead state written, its waterlogged, the flags out (2.4 to 2.6: a dry plant, fan or wall fan becomes the dead one, not waterlogged, flags 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WET                  BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WET L-DEAD L-WATERLOGGED L-FLAGS.
     MOVE 0 TO L-DEAD L-WATERLOGGED L-FLAGS
     IF L-WET = 0
         MOVE 1 TO L-DEAD
         MOVE 2 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-DIE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-ST.
*> USING alive, the update comes from the support side, canSurvive, the water test, waterlogged, air returned, die tick scheduled, fluid tick scheduled out (2.4, 2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-SUPPORT-SIDE         BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-DIE                  BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-SUPPORT-SIDE L-SURVIVE L-WET L-WATERLOGGED L-AIR L-DIE L-FLUID.
     MOVE 0 TO L-AIR L-DIE L-FLUID
     IF L-WATERLOGGED = 1
         MOVE 1 TO L-FLUID
     END-IF
     IF L-ALIVE = 1
         IF L-SUPPORT-SIDE = 1 AND L-SURVIVE = 0
             MOVE 1 TO L-AIR
             MOVE 0 TO L-FLUID
         ELSE
             IF L-WET = 0
                 MOVE 1 TO L-DIE
             END-IF
         END-IF
     ELSE
         IF L-SUPPORT-SIDE = 1 AND L-SURVIVE = 0
             MOVE 1 TO L-AIR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-ST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-PLACE.
*> USING the clicked fluid is water, it is a full block, waterlogged, the fluid state is the water source out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-FULL L-WATERLOGGED L-SOURCE.
     MOVE 0 TO L-WATERLOGGED
     IF L-WATER = 1 AND L-FULL = 1
         MOVE 1 TO L-WATERLOGGED
     END-IF
     MOVE L-WATERLOGGED TO L-SOURCE
     GOBACK.
 END PROGRAM GC7-CORAL-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-SHAPE.
*> USING the form (1 plant, 2 fan, 3 wall fan), the facing (1 to 4), the box x0 y0 z0 x1 y1 z1 in pixels out (2.4 to 2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FORM                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FORM L-FACING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 2 TO L-X0 L-Z0
     MOVE 14 TO L-X1 L-Z1
     MOVE 0 TO L-Y0
     MOVE 15 TO L-Y1
     IF L-FORM = 2
         MOVE 4 TO L-Y1
     END-IF
     IF L-FORM = 3
         MOVE 0 TO L-X0 L-Z0
         MOVE 16 TO L-X1 L-Z1
         MOVE 4 TO L-Y0
         MOVE 12 TO L-Y1
         EVALUATE L-FACING
             WHEN 1
                 MOVE 5 TO L-Z0
             WHEN 2
                 MOVE 11 TO L-X1
             WHEN 3
                 MOVE 11 TO L-Z1
             WHEN 4
                 MOVE 5 TO L-X0
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-OPPOSITE.
*> USING a direction (1 north, 2 east, 3 south, 4 west, 5 up, 6 down), its opposite out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-OPPOSITE             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OPPOSITE.
     EVALUATE L-DIR
         WHEN 1 THRU 4
             COMPUTE L-OPPOSITE = FUNCTION MOD(L-DIR + 1, 4) + 1
         WHEN 5
             MOVE 6 TO L-OPPOSITE
         WHEN OTHER
             MOVE 5 TO L-OPPOSITE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-OPPOSITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-ROTATE.
*> USING a facing (1 to 6), the clockwise quarter turns (0 to 3), the rotated facing out: up and down never change.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-TURNS                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-TURNS L-RESULT.
     MOVE L-FACING TO L-RESULT
     IF L-FACING <= 4
         COMPUTE L-RESULT = FUNCTION MOD(L-FACING - 1 + L-TURNS, 4) + 1
     END-IF
     GOBACK.
 END PROGRAM GC7-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-MIRROR.
*> USING a facing (1 to 6), the mirror (0 none, 1 left-right, 2 front-back), the mirrored facing out: the rotation of the mirror's rotation of the facing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-MIRROR L-RESULT.
     MOVE L-FACING TO L-RESULT
     IF L-MIRROR = 1 AND (L-FACING = 1 OR L-FACING = 3)
         COMPUTE L-RESULT = FUNCTION MOD(L-FACING + 1, 4) + 1
     END-IF
     IF L-MIRROR = 2 AND (L-FACING = 2 OR L-FACING = 4)
         COMPUTE L-RESULT = FUNCTION MOD(L-FACING + 1, 4) + 1
     END-IF
     GOBACK.
 END PROGRAM GC7-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-WALLFAN-PLACE.
*> USING the nearest looking directions in order (6), then canSurvive per facing 1 to 4 (4) (BINARY-LONG items in one group), the facing out (0 when no state) (2.6 Placement).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-DIR               BINARY-LONG OCCURS 6 TIMES.
    05 L-SURVIVE           BINARY-LONG OCCURS 4 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-RESULT.
     MOVE 0 TO L-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR L-RESULT > 0
         IF L-DIR(WS-I) <= 4
             COMPUTE WS-FACING = FUNCTION MOD(L-DIR(WS-I) + 1, 4) + 1
             IF L-SURVIVE(WS-FACING) = 1
                 MOVE WS-FACING TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC7-WALLFAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-BLOCK-DATA.
*> USING the selector (BINARY-LONG), the value out (2.2): 1 hardness x 10, 2 resistance x 10, 3 dead block forceSolidOn, 4 alive block forceSolidOn, 5 dead block ticks, 6 requires the correct tool.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 15.
    05 FILLER              BINARY-LONG VALUE 60.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-CORAL-BLOCK-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CORAL-COLOUR.
*> USING the species (1 tube, 2 brain, 3 bubble, 4 fire, 5 horn), dead (0 alive, 1 dead), the map colour PIC X(64) out (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECIES              BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-COLOUR               PIC X(64).
 PROCEDURE DIVISION USING L-SPECIES L-DEAD L-COLOUR.
     MOVE SPACES TO L-COLOUR
     IF L-DEAD = 1
         MOVE "gray" TO L-COLOUR
     ELSE
         EVALUATE L-SPECIES
             WHEN 1
                 MOVE "blue" TO L-COLOUR
             WHEN 2
                 MOVE "pink" TO L-COLOUR
             WHEN 3
                 MOVE "purple" TO L-COLOUR
             WHEN 4
                 MOVE "red" TO L-COLOUR
             WHEN 5
                 MOVE "yellow" TO L-COLOUR
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC7-CORAL-COLOUR.
