*> Levers, buttons, pressure plates, the daylight detector, the target block, the lightning rod, the note block and the jukebox signal (docs/protocol/30 part 5) as programs
*> of plain numbers (RS2- prefix, like core/src/redstone-30-4.cob): each takes the facts the caller read from the level and returns the decision, its sounds, game events
*> and scaled results (x 1e6 positions, x 1e7 pitches). Helpers: nothing here is wired into the block-update hooks. Directions: 1 north, 2 east, 3 south, 4 west, 5 up, 6 down.
*> Block set types: 1 stone, 2 oak, 3 spruce, 4 birch, 5 jungle, 6 acacia, 7 cherry, 8 dark_oak, 9 pale_oak, 10 mangrove, 11 poplar, 12 bamboo, 13 crimson, 14 warped, 15 iron,
*> 16 copper, 17 gold, 18 polished_blackstone.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DIR-STEP.
*> USING direction (1 north, 2 east, 3 south, 4 west, 5 up, 6 down), the unit step x, y, z out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-X L-Y L-Z.
     MOVE 0 TO L-X L-Y L-Z
     EVALUATE L-D
         WHEN 1
             MOVE -1 TO L-Z
         WHEN 2
             MOVE 1 TO L-X
         WHEN 3
             MOVE 1 TO L-Z
         WHEN 4
             MOVE -1 TO L-X
         WHEN 5
             MOVE 1 TO L-Y
         WHEN OTHER
             MOVE -1 TO L-Y
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-DIR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SIGNAL-DEFAULT.
*> USING isSignalSource, ownSignal, getDirectSignal out (30-5 0: the BlockBehaviour defaults).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-O L-D.
     MOVE 0 TO L-S L-O L-D
     GOBACK.
 END PROGRAM RS2-SIGNAL-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-GET-SIGNAL.
*> USING ownSignal, direction, getSignal out (30-5 0): ownSignal for every direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-O L-D L-R.
     MOVE L-O TO L-R
     GOBACK.
 END PROGRAM RS2-GET-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-SOUND-DEFAULT.
*> USING volume x 100, pitch x 100 out (30-5 0: playSound without volume and pitch).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-P.
     MOVE 100 TO L-V L-P
     GOBACK.
 END PROGRAM RS2-SOUND-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PUSH-REACTION.
*> USING a kind (1 lever, 2 button, 3 pressure plate, 4 weighted plate, 5 lightning rod, 6 note block, 7 daylight detector, 8 target, 9 jukebox), popped out (30-5 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-R.
     MOVE 0 TO L-R
     IF L-K <= 5
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PUSH-REACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-CONNECTED.
*> USING face (0 floor, 1 wall, 2 ceiling), facing, connected direction C out (30-5 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-F L-C.
     EVALUATE L-A
         WHEN 0
             MOVE 5 TO L-C
         WHEN 2
             MOVE 6 TO L-C
         WHEN OTHER
             MOVE L-F TO L-C
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-FACE-CONNECTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-SUPPORT.
*> USING C, the direction of the support (opposite of C), its offset x, y, z out (30-5 1: the block hangs on pos + opposite(C)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-S L-X L-Y L-Z.
     CALL "RS2-DIR-OPPOSITE" USING L-C L-S
     CALL "RS2-DIR-STEP" USING L-S L-X L-Y L-Z
     GOBACK.
 END PROGRAM RS2-FACE-SUPPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-SHAPE-UPDATE.
*> USING the changed neighbour's direction, C, canSurvive, air out (30-5 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O BINARY-LONG.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-C L-S L-A.
     CALL "RS2-DIR-OPPOSITE" USING L-C WS-O
     MOVE 0 TO L-A
     IF L-H = WS-O AND L-S = 0
         MOVE 1 TO L-A
     END-IF
     GOBACK.
 END PROGRAM RS2-FACE-SHAPE-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-PLACE.
*> USING the six nearest looking directions in order, whether the candidate of each can survive, the player's horizontal direction, index chosen out (0 none), face out (-1 none), facing out (30-5 1 placement).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K BINARY-LONG.
 01 WS-TD.
    05 WS-D BINARY-LONG OCCURS 6 TIMES.
 01 WS-TS.
    05 WS-S BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 01 L-D5                   BINARY-LONG.
 01 L-D6                   BINARY-LONG.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-S5                   BINARY-LONG.
 01 L-S6                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-D4 L-D5 L-D6 L-S1 L-S2 L-S3 L-S4 L-S5 L-S6 L-H L-I L-A L-F.
     MOVE L-D1 TO WS-D(1)
     MOVE L-D2 TO WS-D(2)
     MOVE L-D3 TO WS-D(3)
     MOVE L-D4 TO WS-D(4)
     MOVE L-D5 TO WS-D(5)
     MOVE L-D6 TO WS-D(6)
     MOVE L-S1 TO WS-S(1)
     MOVE L-S2 TO WS-S(2)
     MOVE L-S3 TO WS-S(3)
     MOVE L-S4 TO WS-S(4)
     MOVE L-S5 TO WS-S(5)
     MOVE L-S6 TO WS-S(6)
     MOVE 0 TO L-I L-F
     MOVE -1 TO L-A
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR L-I > 0
         IF WS-S(WS-K) = 1
             MOVE WS-K TO L-I
             IF WS-D(WS-K) >= 5
                 MOVE L-H TO L-F
                 MOVE 0 TO L-A
                 IF WS-D(WS-K) = 5
                     MOVE 2 TO L-A
                 END-IF
             ELSE
                 MOVE 1 TO L-A
                 CALL "RS2-DIR-OPPOSITE" USING WS-D(WS-K) L-F
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-FACE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-DEFAULT.
*> USING facing, face, powered out (30-5 1 default state).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-A L-P.
     MOVE 1 TO L-F L-A
     MOVE 0 TO L-P
     GOBACK.
 END PROGRAM RS2-FACE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-SIGNAL.
*> USING powered, the direction from the asking block, C, ownSignal out, getDirectSignal out (30-5 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-D L-C L-O L-R.
     MOVE 0 TO L-O L-R
     IF L-P = 1
         MOVE 15 TO L-O
         IF L-D = L-C
             MOVE 15 TO L-R
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-LEVER-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-PULL.
*> USING powered, new powered out, volume x 100 out, pitch x 100 out, game event out (1 BLOCK_ACTIVATE, 2 BLOCK_DEACTIVATE), written out, neighbours updated out (30-5 2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-N L-V L-C L-G L-W L-U.
     COMPUTE L-N = 1 - L-P
     MOVE 30 TO L-V
     MOVE 50 TO L-C
     MOVE 2 TO L-G
     IF L-N = 1
         MOVE 60 TO L-C
         MOVE 1 TO L-G
     END-IF
     MOVE 1 TO L-W L-U
     GOBACK.
 END PROGRAM RS2-LEVER-PULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-USE.
*> USING server side, powered, result out (1 SUCCESS), client particle alpha x 10 out, client particle out, the server pulls out (30-5 2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-P L-R L-A L-K L-U.
     MOVE 1 TO L-R
     MOVE 0 TO L-A L-K L-U
     IF L-S = 1
         MOVE 1 TO L-U
     ELSE
         IF L-P = 0
             MOVE 10 TO L-A
             MOVE 1 TO L-K
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-LEVER-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-EXPLOSION.
*> USING the explosion can trigger blocks, pull out (30-5 2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-R.
     MOVE L-C TO L-R
     GOBACK.
 END PROGRAM RS2-LEVER-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-REMOVAL.
*> USING powered, moved by a piston, update out (30-5 2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-M L-U.
     MOVE 0 TO L-U
     IF L-P = 1 AND L-M = 0
         MOVE 1 TO L-U
     END-IF
     GOBACK.
 END PROGRAM RS2-LEVER-REMOVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-FACE-UPDATE-PAIR.
*> USING C, facing, s = opposite(C) out, the orientation's up direction out (UP when s is horizontal, else the facing), the support offset x, y, z out (30-5 2.4, 3.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-F L-S L-U L-X L-Y L-Z.
     CALL "RS2-DIR-OPPOSITE" USING L-C L-S
     MOVE L-F TO L-U
     IF L-S <= 4
         MOVE 5 TO L-U
     END-IF
     CALL "RS2-DIR-STEP" USING L-S L-X L-Y L-Z
     GOBACK.
 END PROGRAM RS2-FACE-UPDATE-PAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-PARTICLE.
*> USING facing, C, the block x, y, z, the draw nextFloat (FLOAT-LONG), powered, spawn out, position x, y, z (x 1e6) out (30-5 2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT FLOAT-LONG VALUE 0.25.
 01 WS-BELOW BINARY-LONG.
 01 WS-OF BINARY-LONG.
 01 WS-OC BINARY-LONG.
 01 WS-AX BINARY-LONG.
 01 WS-AY BINARY-LONG.
 01 WS-AZ BINARY-LONG.
 01 WS-BX BINARY-LONG.
 01 WS-BY BINARY-LONG.
 01 WS-BZ BINARY-LONG.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-C L-X L-Y L-Z L-R L-P L-S L-PX L-PY L-PZ.
     CALL "FCMP-GT" USING WS-LIMIT L-R WS-BELOW
     MOVE 0 TO L-S
     IF L-P = 1 AND WS-BELOW = 1
         MOVE 1 TO L-S
     END-IF
     CALL "RS2-DIR-OPPOSITE" USING L-F WS-OF
     CALL "RS2-DIR-OPPOSITE" USING L-C WS-OC
     CALL "RS2-DIR-STEP" USING WS-OF WS-AX WS-AY WS-AZ
     CALL "RS2-DIR-STEP" USING WS-OC WS-BX WS-BY WS-BZ
     COMPUTE L-PX ROUNDED = (L-X + 0.5 + 0.1 * WS-AX + 0.2 * WS-BX) * 1000000
     COMPUTE L-PY ROUNDED = (L-Y + 0.5 + 0.1 * WS-AY + 0.2 * WS-BY) * 1000000
     COMPUTE L-PZ ROUNDED = (L-Z + 0.5 + 0.1 * WS-AZ + 0.2 * WS-BZ) * 1000000
     GOBACK.
 END PROGRAM RS2-LEVER-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-LEVER-SHAPE.
*> USING face (0 floor, 1 wall, 2 ceiling), facing, the box x0, y0, z0, x1, y1, z1 in sixteenths out (30-5 2.6 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-F L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     IF L-A = 1
         MOVE 4 TO L-Y0
         MOVE 12 TO L-Y1
         EVALUATE L-F
             WHEN 1
                 MOVE 5 TO L-X0
                 MOVE 10 TO L-Z0
                 MOVE 11 TO L-X1
                 MOVE 16 TO L-Z1
             WHEN 2
                 MOVE 0 TO L-X0
                 MOVE 5 TO L-Z0
                 MOVE 6 TO L-X1
                 MOVE 11 TO L-Z1
             WHEN 3
                 MOVE 5 TO L-X0
                 MOVE 0 TO L-Z0
                 MOVE 11 TO L-X1
                 MOVE 6 TO L-Z1
             WHEN OTHER
                 MOVE 10 TO L-X0
                 MOVE 5 TO L-Z0
                 MOVE 16 TO L-X1
                 MOVE 11 TO L-Z1
         END-EVALUATE
     ELSE
         IF L-A = 0
             MOVE 0 TO L-Y0
             MOVE 6 TO L-Y1
         ELSE
             MOVE 10 TO L-Y0
             MOVE 16 TO L-Y1
         END-IF
         IF L-F = 1 OR L-F = 3
             MOVE 5 TO L-X0
             MOVE 4 TO L-Z0
             MOVE 11 TO L-X1
             MOVE 12 TO L-Z1
         ELSE
             MOVE 4 TO L-X0
             MOVE 5 TO L-Z0
             MOVE 12 TO L-X1
             MOVE 11 TO L-Z1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-LEVER-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-INFO.
*> USING the block name (32 characters), ticks to stay pressed out, arrows press it out, block set type out (30-5 3.1 table: 1 stone, 2 oak, 3 spruce, 4 birch, 5 jungle, 6 acacia, 7 cherry, 8 dark_oak, 9 pale_oak, 10 mangrove, 11 poplar, 12 bamboo, 13 crimson, 14 warped; 15 iron, 16 copper, 17 gold, 18 polished_blackstone for the plates).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BT-DATA.
    05 FILLER PIC X(32) VALUE "stone_button".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(32) VALUE "polished_blackstone_button".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(32) VALUE "oak_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "spruce_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "birch_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "jungle_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "acacia_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "cherry_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "dark_oak_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "pale_oak_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "mangrove_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "poplar_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "bamboo_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "crimson_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "warped_button".
    05 FILLER PIC 99 VALUE 30.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 99 VALUE 14.
 01 WS-BT REDEFINES WS-BT-DATA.
    05 WS-ROW OCCURS 15 TIMES.
       10 WS-NAME PIC X(32).
       10 WS-TICKS PIC 99.
       10 WS-ARR PIC 9.
       10 WS-SET PIC 99.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    PIC X(32).
 01 L-T                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-T L-A L-S.
     MOVE 0 TO L-T L-A L-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         IF WS-NAME(WS-I) = L-N
             MOVE WS-TICKS(WS-I) TO L-T
             MOVE WS-ARR(WS-I) TO L-A
             MOVE WS-SET(WS-I) TO L-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-BUTTON-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ARROW-RULE.
*> USING a block set type, arrows can press out (30-5 3.1: the wood types, crimson and warped).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-R.
     MOVE 0 TO L-R
     IF L-T >= 2 AND L-T <= 14
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-ARROW-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-SIGNAL.
*> USING powered, direction, C, ownSignal out, getDirectSignal out (30-5 3.2: as the lever).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-D L-C L-O L-R.
     CALL "RS2-LEVER-SIGNAL" USING L-P L-D L-C L-O L-R
     GOBACK.
 END PROGRAM RS2-BUTTON-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-USE.
*> USING powered, result out (1 SUCCESS, 2 CONSUME), press out (30-5 3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-R L-S.
     IF L-P = 1
         MOVE 2 TO L-R
         MOVE 0 TO L-S
     ELSE
         MOVE 1 TO L-R L-S
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-PRESS.
*> USING ticks to stay pressed, written out, neighbours updated out, tick scheduled out, volume x 100, pitch x 100, the player is excluded, game event BLOCK_ACTIVATE out (30-5 3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-W L-U L-K L-V L-P L-X L-G.
     MOVE 1 TO L-W L-U L-X L-G
     MOVE L-T TO L-K
     MOVE 100 TO L-V L-P
     GOBACK.
 END PROGRAM RS2-BUTTON-PRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-CHECK.
*> USING arrows allowed, an arrow overlaps the outline, powered, ticks to stay pressed, arrowPresent out, written out, new powered out, sound out (1 on, 2 off), game event out (1, 2), neighbours updated out, re-armed ticks out (30-5 3.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-L                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-L L-V L-P L-T L-A L-W L-N L-S L-G L-U L-R.
     MOVE 0 TO L-A L-S L-G L-U L-R
     MOVE 0 TO L-W
     IF L-L = 1 AND L-V = 1
         MOVE 1 TO L-A
         MOVE L-T TO L-R
     END-IF
     MOVE L-P TO L-N
     IF L-A NOT = L-P
         MOVE 1 TO L-W L-U
         MOVE L-A TO L-N
         MOVE 2 TO L-S L-G
         IF L-A = 1
             MOVE 1 TO L-S L-G
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-TICK.
*> USING powered, arrows allowed, an arrow overlaps, ticks to stay pressed, ran out, then the outputs of RS2-BUTTON-CHECK (30-5 3.4): an unpowered button returns at once.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-L L-V L-T L-X L-A L-W L-N L-S L-G L-U L-R.
     MOVE 0 TO L-X L-A L-W L-S L-G L-U L-R
     MOVE L-P TO L-N
     IF L-P = 1
         MOVE 1 TO L-X
         CALL "RS2-BUTTON-CHECK" USING L-L L-V L-P L-T L-A L-W L-N L-S L-G L-U L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-INSIDE.
*> USING server level, arrows allowed, powered, checkPressed runs out (30-5 3.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-A L-P L-R.
     MOVE 0 TO L-R
     IF L-S = 1 AND L-A = 1 AND L-P = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-EXPLOSION.
*> USING the explosion can trigger blocks, powered, press out (30-5 3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-P L-R.
     MOVE 0 TO L-R
     IF L-C = 1 AND L-P = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BUTTON-SHAPE.
*> USING powered, the box x0, y0, z0, x1, y1, z1 in sixteenths out (30-5 3.8, wall north: 2 deep unpowered, 1 deep powered).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 5 TO L-X0
     MOVE 6 TO L-Y0
     MOVE 14 TO L-Z0
     MOVE 11 TO L-X1
     MOVE 10 TO L-Y1
     MOVE 16 TO L-Z1
     IF L-P = 1
         MOVE 15 TO L-Z0
     END-IF
     GOBACK.
 END PROGRAM RS2-BUTTON-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-SHAPE.
*> USING pressed, the outline height x 10 out (1.0 unpressed, 0.5 pressed), the touch box x0, y0, z0, x1, y1, z1 in sixteenths out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-H L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 10 TO L-H
     IF L-P = 1
         MOVE 5 TO L-H
     END-IF
     MOVE 1 TO L-X0 L-Z0
     MOVE 0 TO L-Y0
     MOVE 15 TO L-X1 L-Z1
     MOVE 4 TO L-Y1
     GOBACK.
 END PROGRAM RS2-PLATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-SURVIVE.
*> USING the block below supports a rigid block, supports the centre, a shape update towards down, canSurvive out, air out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-C L-D L-S L-A.
     MOVE 0 TO L-S L-A
     IF L-R = 1 OR L-C = 1
         MOVE 1 TO L-S
     END-IF
     IF L-D = 1 AND L-S = 0
         MOVE 1 TO L-A
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-SIGNAL.
*> USING the state signal, the direction from the asking block, ownSignal out, getDirectSignal out (30-5 4.1: strong power only towards up).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-D L-O L-R.
     MOVE L-S TO L-O
     MOVE 0 TO L-R
     IF L-D = 5
         MOVE L-S TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-INSIDE.
*> USING server level, the old state signal, checkPressed runs out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-O L-R.
     MOVE 0 TO L-R
     IF L-S = 1 AND L-O = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-TICK.
*> USING the old state signal, checkPressed runs out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-O L-R.
     MOVE 0 TO L-R
     IF L-O > 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-CHECK.
*> USING the old signal, the new signal, the pressed time, written out (flags 2), flags out, neighbours updated out, blocks dirty out, sound out (1 on, 2 off), game event out (1 BLOCK_ACTIVATE, 2 BLOCK_DEACTIVATE), re-armed ticks out (30-5 4.1 checkPressed).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-O L-N L-T L-W L-F L-U L-D L-S L-G L-R.
     MOVE 0 TO L-W L-F L-U L-D L-S L-G L-R
     IF L-O NOT = L-N
         MOVE 1 TO L-W L-U L-D
         MOVE 2 TO L-F
     END-IF
     IF L-O > 0 AND L-N = 0
         MOVE 2 TO L-S L-G
     END-IF
     IF L-O = 0 AND L-N > 0
         MOVE 1 TO L-S L-G
     END-IF
     IF L-N > 0
         MOVE L-T TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-COUNTED.
*> USING the entity is a spectator, it ignores block triggers, counted out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-I L-R.
     MOVE 0 TO L-R
     IF L-S = 0 AND L-I = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-COUNTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-IGNORES-TRIGGERS.
*> USING the entity class (1 Display, 2 Interaction, 3 Marker, 4 OminousItemSpawner, 5 ArmorStand, 6 Bat, 0 any other), the armor stand is a marker, isIgnoringBlockTriggers out (30-5 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-M L-R.
     EVALUATE TRUE
         WHEN L-C >= 1 AND L-C <= 4
             MOVE 1 TO L-R
         WHEN L-C = 6
             MOVE 1 TO L-R
         WHEN L-C = 5
             MOVE L-M TO L-R
         WHEN OTHER
             MOVE 0 TO L-R
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-IGNORES-TRIGGERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-STRENGTH.
*> USING the sensitivity (1 EVERYTHING, 2 MOBS), the count of all entities, the count of living entities, strength out (30-5 4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N BINARY-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-A L-L L-R.
     IF L-S = 1
         MOVE L-A TO WS-N
     ELSE
         MOVE L-L TO WS-N
     END-IF
     MOVE 0 TO L-R
     IF WS-N > 0
         MOVE 15 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-PLATE-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PLATE-INFO.
*> USING the block name (32 characters), block set type out, sensitivity out (1 EVERYTHING, 2 MOBS), sound family out (1 stone, 2 wooden, 3 cherry wood, 4 nether wood, 5 bamboo wood), pressed time out (30-5 4.2 table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PT-DATA.
    05 FILLER PIC X(40) VALUE "stone_pressure_plate".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(40) VALUE "polished_blackstone_pressure_plate".
    05 FILLER PIC 99 VALUE 18.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(40) VALUE "oak_pressure_plate".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "spruce_pressure_plate".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "birch_pressure_plate".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "jungle_pressure_plate".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "acacia_pressure_plate".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "cherry_pressure_plate".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(40) VALUE "dark_oak_pressure_plate".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "pale_oak_pressure_plate".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "mangrove_pressure_plate".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "poplar_pressure_plate".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(40) VALUE "bamboo_pressure_plate".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(40) VALUE "crimson_pressure_plate".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(40) VALUE "warped_pressure_plate".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 4.
 01 WS-PT REDEFINES WS-PT-DATA.
    05 WS-ROW OCCURS 15 TIMES.
       10 WS-NAME PIC X(40).
       10 WS-SET PIC 99.
       10 WS-SENS PIC 9.
       10 WS-FAM PIC 9.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    PIC X(40).
 01 L-S                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-S L-V L-F L-T.
     MOVE 0 TO L-S L-V L-F L-T
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         IF WS-NAME(WS-I) = L-N
             MOVE WS-SET(WS-I) TO L-S
             MOVE WS-SENS(WS-I) TO L-V
             MOVE WS-FAM(WS-I) TO L-F
             MOVE 20 TO L-T
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-PLATE-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-WEIGHTED-INFO.
*> USING the block name (32 characters), maxWeight out, block set type out (gold 17, iron 15), pressed time out (10), sound family out (6 metal) (30-5 4.3 table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WT-DATA.
    05 FILLER PIC X(32) VALUE "light_weighted_pressure_plate".
    05 FILLER PIC 999 VALUE 15.
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC X(32) VALUE "heavy_weighted_pressure_plate".
    05 FILLER PIC 999 VALUE 150.
    05 FILLER PIC 99 VALUE 15.
 01 WS-WT REDEFINES WS-WT-DATA.
    05 WS-ROW OCCURS 2 TIMES.
       10 WS-NAME PIC X(32).
       10 WS-MAX PIC 999.
       10 WS-SET PIC 99.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    PIC X(32).
 01 L-M                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-M L-S L-T L-F.
     MOVE 0 TO L-M L-S L-T L-F
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         IF WS-NAME(WS-I) = L-N
             MOVE WS-MAX(WS-I) TO L-M
             MOVE WS-SET(WS-I) TO L-S
             MOVE 10 TO L-T
             MOVE 6 TO L-F
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-WEIGHTED-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-WEIGHTED-STRENGTH.
*> USING the entity count n, maxWeight, power out (30-5 4.3): ceil(float(min(maxWeight, n)) / float(maxWeight) * 15.0f); for maxWeight 15 and 150 the binary32 result equals the exact ceiling of s * 15 / maxWeight (V6), so integer arithmetic gives the table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S BINARY-LONG.
 01 WS-T BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-M L-R.
     COMPUTE WS-S = FUNCTION MIN(L-N, L-M)
     MOVE 0 TO L-R
     IF WS-S > 0
         COMPUTE WS-T = WS-S * 15 + L-M - 1
         DIVIDE WS-T BY L-M GIVING L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-WEIGHTED-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-BLOCKS-DIRTY.
*> USING the level is a client, the render notification is sent out (30-5 4.4: empty on the server).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-N.
     MOVE L-C TO L-N
     GOBACK.
 END PROGRAM RS2-BLOCKS-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DAYLIGHT-TICK.
*> USING server level, the dimension has sky light, game time, updateSignalStrength runs out (30-5 5 ticker).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-K L-T L-R.
     MOVE 0 TO L-R
     IF L-S = 1 AND L-K = 1 AND FUNCTION MOD(L-T, 20) = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-DAYLIGHT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DAYLIGHT-POWER.
*> USING the effective sky brightness, the sun angle in degrees (FLOAT-LONG), inverted, power out (30-5 5 updateSignalStrength). Single precision steps are rounded with cc_f64_f32_round; the cosine is the table cosine of 11 (IP-MTH-COS) rounded to binary32; Math.round(float) is cc_f64_round_f32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S BINARY-LONG.
 01 WS-BELOW BINARY-LONG.
 01 WS-X FLOAT-LONG.
 01 WS-Y FLOAT-LONG.
 01 WS-ANG FLOAT-LONG.
 01 WS-KF FLOAT-LONG.
 01 WS-A FLOAT-LONG.
 01 WS-PI FLOAT-LONG.
 01 WS-TGT FLOAT-LONG.
 01 WS-F2 FLOAT-LONG.
 01 WS-C FLOAT-LONG.
 01 WS-COS FLOAT-LONG.
 01 WS-SF FLOAT-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-V                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-A L-V L-R.
     MOVE L-S TO WS-S
     EVALUATE TRUE
         WHEN L-V = 1
             COMPUTE WS-S = 15 - WS-S
         WHEN WS-S > 0
             MOVE L-A TO WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-ANG
             MOVE 0.017453292 TO WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-KF
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ANG WS-KF WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-A
             MOVE 3.1415927 TO WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-PI
             CALL "FCMP-GT" USING WS-PI WS-A WS-BELOW
             MOVE 0 TO WS-TGT
             IF WS-BELOW = 0
                 MOVE 6.2831855 TO WS-X
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-TGT
             END-IF
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-TGT WS-A WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-Y
             MOVE 0.2 TO WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-F2
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Y WS-F2 WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-Y
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-Y WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-A
             CALL "IP-MTH-COS" USING WS-A WS-C
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-C WS-COS
             MOVE WS-S TO WS-SF
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SF WS-COS WS-X
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-X WS-Y
             CALL STATIC "cc_f64_round_f32" USING BY REFERENCE WS-Y WS-S
         WHEN OTHER
             MOVE 0 TO WS-S
     END-EVALUATE
     COMPUTE L-R = FUNCTION MAX(0, FUNCTION MIN(15, WS-S))
     GOBACK.
 END PROGRAM RS2-DAYLIGHT-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DAYLIGHT-WRITE.
*> USING the new strength, the current power, written out (30-5 5 step 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-P L-W.
     MOVE 0 TO L-W
     IF L-S NOT = L-P
         MOVE 1 TO L-W
     END-IF
     GOBACK.
 END PROGRAM RS2-DAYLIGHT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-DAYLIGHT-USE.
*> USING mayBuild, server side, inverted, handled out (0 default result), new inverted out, flags out, game event BLOCK_CHANGE out, update now out (30-5 5 use).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-S L-V L-H L-N L-F L-G L-U.
     MOVE 0 TO L-H L-F L-G L-U
     MOVE L-V TO L-N
     IF L-M = 1
         MOVE 1 TO L-H
         IF L-S = 1
             COMPUTE L-N = 1 - L-V
             MOVE 2 TO L-F
             MOVE 1 TO L-G L-U
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-DAYLIGHT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TARGET-STRENGTH.
*> USING the hit location x, y, z (FLOAT-LONG), the face hit (1 north .. 6 down), strength out (30-5 6.1): m is the larger deviation from the face centre on the two other axes; strength = max(1, ceil(15 * clamp((0.5 - m) / 0.5, 0, 1))) in double precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FL FLOAT-LONG.
 01 WS-FR FLOAT-LONG.
 01 WS-D FLOAT-LONG.
 01 WS-FX FLOAT-LONG.
 01 WS-FY FLOAT-LONG.
 01 WS-FZ FLOAT-LONG.
 01 WS-M FLOAT-LONG.
 01 WS-T FLOAT-LONG.
 01 WS-HALF FLOAT-LONG VALUE 0.5.
 01 WS-ZERO FLOAT-LONG VALUE 0.
 01 WS-ONE FLOAT-LONG VALUE 1.
 01 WS-FIFTEEN FLOAT-LONG VALUE 15.
 01 WS-N BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-F                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-F L-R.
     CALL STATIC "cc_f64_floor" USING BY REFERENCE L-X WS-FL
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-X WS-FL WS-FR
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FR WS-HALF WS-D
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-D WS-FX
     CALL STATIC "cc_f64_floor" USING BY REFERENCE L-Y WS-FL
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-Y WS-FL WS-FR
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FR WS-HALF WS-D
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-D WS-FY
     CALL STATIC "cc_f64_floor" USING BY REFERENCE L-Z WS-FL
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-Z WS-FL WS-FR
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FR WS-HALF WS-D
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-D WS-FZ
     EVALUATE TRUE
         WHEN L-F = 5 OR L-F = 6
             CALL STATIC "cc_f64_max_j" USING BY REFERENCE WS-FX WS-FZ WS-M
         WHEN L-F = 1 OR L-F = 3
             CALL STATIC "cc_f64_max_j" USING BY REFERENCE WS-FX WS-FY WS-M
         WHEN OTHER
             CALL STATIC "cc_f64_max_j" USING BY REFERENCE WS-FY WS-FZ WS-M
     END-EVALUATE
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-HALF WS-M WS-D
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-D WS-HALF WS-T
     CALL STATIC "cc_f64_clamp_f64" USING BY REFERENCE WS-T WS-ZERO WS-ONE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-FIFTEEN WS-T
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-T WS-D
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D WS-N
     COMPUTE L-R = FUNCTION MAX(1, WS-N)
     GOBACK.
 END PROGRAM RS2-TARGET-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TARGET-HIT.
*> USING the projectile is an arrow, a tick is pending, the strength, the owner is a player, written out, power out, duration out, tick scheduled out, criterion out, criterion strength out (30-5 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-D L-S L-O L-W L-P L-U L-K L-C L-T.
     MOVE 8 TO L-U
     IF L-A = 1
         MOVE 20 TO L-U
     END-IF
     MOVE 0 TO L-W L-P L-K L-C L-T
     IF L-D = 0
         MOVE 1 TO L-W L-K
         MOVE L-S TO L-P
     END-IF
     IF L-O = 1
         MOVE 1 TO L-C
         MOVE L-S TO L-T
     END-IF
     GOBACK.
 END PROGRAM RS2-TARGET-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TARGET-TICK.
*> USING power, write 0 out (30-5 6 release).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-R.
     MOVE 0 TO L-R
     IF L-P NOT = 0
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-TARGET-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-TARGET-PLACE.
*> USING server side, the previous state is this block, power, a tick is pending, written out, flags out (30-5 6 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-M L-P L-D L-W L-F.
     MOVE 0 TO L-W L-F
     IF L-S = 1 AND L-M = 0 AND L-P > 0 AND L-D = 0
         MOVE 1 TO L-W
         MOVE 18 TO L-F
     END-IF
     GOBACK.
 END PROGRAM RS2-TARGET-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-SIGNAL.
*> USING powered, direction, facing, ownSignal out, getDirectSignal out (30-5 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-O                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-D L-F L-O L-R.
     CALL "RS2-LEVER-SIGNAL" USING L-P L-D L-F L-O L-R
     GOBACK.
 END PROGRAM RS2-ROD-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-PLACE.
*> USING the clicked face, the fluid is water, facing out, waterlogged out (30-5 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-W L-F L-L.
     MOVE L-D TO L-F
     MOVE L-W TO L-L
     GOBACK.
 END PROGRAM RS2-ROD-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-STRIKE.
*> USING facing, powered out, the support direction out, ticks out, level event out, event data out (the axis ordinal of the facing: X 0, Y 1, Z 2) (30-5 7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-P L-S L-T L-E L-D.
     MOVE 1 TO L-P
     CALL "RS2-DIR-OPPOSITE" USING L-F L-S
     MOVE 8 TO L-T
     MOVE 3002 TO L-E
     EVALUATE TRUE
         WHEN L-F = 1 OR L-F = 3
             MOVE 2 TO L-D
         WHEN L-F = 2 OR L-F = 4
             MOVE 0 TO L-D
         WHEN OTHER
             MOVE 1 TO L-D
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-ROD-STRIKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-RELEASE.
*> USING facing, powered, powered out, the support direction out, update on removal out (30-5 7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-W L-P L-S L-U.
     MOVE 0 TO L-P
     CALL "RS2-DIR-OPPOSITE" USING L-F L-S
     MOVE L-W TO L-U
     GOBACK.
 END PROGRAM RS2-ROD-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-PLACE-TICK.
*> USING the previous state is this block, powered, a tick is pending, ticks scheduled out (30-5 7.2 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-P L-D L-T.
     MOVE 0 TO L-T
     IF L-M = 0 AND L-P = 1 AND L-D = 0
         MOVE 8 TO L-T
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-PLACE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-SEARCH.
*> USING the number of candidates (0 to 4), then the squared distance to the strike column and the top-of-column flag of each, index out (0 none), found out (30-5 7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K BINARY-LONG.
 01 WS-B BINARY-LONG.
 01 WS-DD.
    05 WS-D BINARY-LONG OCCURS 4 TIMES.
 01 WS-TT.
    05 WS-T BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-D1                   BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-T3                   BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 01 L-T4                   BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-D1 L-T1 L-D2 L-T2 L-D3 L-T3 L-D4 L-T4 L-I L-F.
     MOVE L-D1 TO WS-D(1)
     MOVE L-T1 TO WS-T(1)
     MOVE L-D2 TO WS-D(2)
     MOVE L-T2 TO WS-T(2)
     MOVE L-D3 TO WS-D(3)
     MOVE L-T3 TO WS-T(3)
     MOVE L-D4 TO WS-D(4)
     MOVE L-T4 TO WS-T(4)
     MOVE 0 TO L-I L-F WS-B
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-N
         IF WS-T(WS-K) = 1 AND WS-D(WS-K) <= 16384
             IF L-I = 0 OR WS-D(WS-K) < WS-B
                 MOVE WS-K TO L-I
                 MOVE WS-D(WS-K) TO WS-B
             END-IF
         END-IF
     END-PERFORM
     IF L-I > 0
         MOVE 1 TO L-F
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-SEARCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-TARGET.
*> USING the rod's y, the strike target y out (30-5 7.3 step 4: above(1)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-R.
     COMPUTE L-R = L-Y + 1
     GOBACK.
 END PROGRAM RS2-ROD-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-ANIMATE.
*> USING thundering, the draw nextInt(200), game time mod 200, the rod is at the surface, spawn out (30-5 7.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-D L-G L-S L-R.
     MOVE 0 TO L-R
     IF L-T = 1 AND L-D <= L-G AND L-S = 1
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-ANIMATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-SPARKS.
*> USING the event data, branch out (1 along the axis, 2 on the faces), lowest count out, highest count out (30-5 7.5 event 3002).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-B L-L L-H.
     IF L-D >= 0 AND L-D <= 2
         MOVE 1 TO L-B
         MOVE 10 TO L-L
         MOVE 19 TO L-H
     ELSE
         MOVE 2 TO L-B
         MOVE 3 TO L-L
         MOVE 5 TO L-H
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-SPARKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-CLEAN.
*> USING the strike block (0 other, 1 weathering copper, 2 waxed), reset to the first stage out, the walks run out (30-5 7.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-R L-W.
     MOVE 0 TO L-R L-W
     IF L-K = 1
         MOVE 1 TO L-R
     END-IF
     IF L-K > 0
         MOVE 1 TO L-W
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-CLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-WALKS.
*> USING the draw nextInt(3), the draw nextInt(8), walks out, steps out (30-5 7.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-W L-S.
     COMPUTE L-W = 3 + L-A
     COMPUTE L-S = L-B + 1
     GOBACK.
 END PROGRAM RS2-ROD-WALKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-ROD-WALK-STEP.
*> USING ten flags (the sampled position is weathering copper), index of the first out (0 none), moved out, level event out, its data out (30-5 7.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N BINARY-LONG.
 01 WS-FF.
    05 WS-F BINARY-LONG OCCURS 10 TIMES.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-J                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-D L-E L-F L-G L-H L-J L-K L-I L-M L-V L-X.
     MOVE L-A TO WS-F(1)
     MOVE L-B TO WS-F(2)
     MOVE L-C TO WS-F(3)
     MOVE L-D TO WS-F(4)
     MOVE L-E TO WS-F(5)
     MOVE L-F TO WS-F(6)
     MOVE L-G TO WS-F(7)
     MOVE L-H TO WS-F(8)
     MOVE L-J TO WS-F(9)
     MOVE L-K TO WS-F(10)
     MOVE 0 TO L-I L-M L-V L-X
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 10 OR L-I > 0
         IF WS-F(WS-N) = 1
             MOVE WS-N TO L-I
         END-IF
     END-PERFORM
     IF L-I > 0
         MOVE 1 TO L-M
         MOVE 3002 TO L-V
         MOVE -1 TO L-X
     END-IF
     GOBACK.
 END PROGRAM RS2-ROD-WALK-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-NAME.
*> USING the instrument number (0 to 26), its serialized name (32 characters) out, its sound event (48 characters) out (30-5 8.1 table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IN-DATA.
    05 FILLER PIC X(24) VALUE "harp".
    05 FILLER PIC X(48) VALUE "block.note_block.harp".
    05 FILLER PIC X(24) VALUE "basedrum".
    05 FILLER PIC X(48) VALUE "block.note_block.basedrum".
    05 FILLER PIC X(24) VALUE "snare".
    05 FILLER PIC X(48) VALUE "block.note_block.snare".
    05 FILLER PIC X(24) VALUE "hat".
    05 FILLER PIC X(48) VALUE "block.note_block.hat".
    05 FILLER PIC X(24) VALUE "bass".
    05 FILLER PIC X(48) VALUE "block.note_block.bass".
    05 FILLER PIC X(24) VALUE "flute".
    05 FILLER PIC X(48) VALUE "block.note_block.flute".
    05 FILLER PIC X(24) VALUE "bell".
    05 FILLER PIC X(48) VALUE "block.note_block.bell".
    05 FILLER PIC X(24) VALUE "guitar".
    05 FILLER PIC X(48) VALUE "block.note_block.guitar".
    05 FILLER PIC X(24) VALUE "chime".
    05 FILLER PIC X(48) VALUE "block.note_block.chime".
    05 FILLER PIC X(24) VALUE "xylophone".
    05 FILLER PIC X(48) VALUE "block.note_block.xylophone".
    05 FILLER PIC X(24) VALUE "iron_xylophone".
    05 FILLER PIC X(48) VALUE "block.note_block.iron_xylophone".
    05 FILLER PIC X(24) VALUE "cow_bell".
    05 FILLER PIC X(48) VALUE "block.note_block.cow_bell".
    05 FILLER PIC X(24) VALUE "didgeridoo".
    05 FILLER PIC X(48) VALUE "block.note_block.didgeridoo".
    05 FILLER PIC X(24) VALUE "bit".
    05 FILLER PIC X(48) VALUE "block.note_block.bit".
    05 FILLER PIC X(24) VALUE "banjo".
    05 FILLER PIC X(48) VALUE "block.note_block.banjo".
    05 FILLER PIC X(24) VALUE "pling".
    05 FILLER PIC X(48) VALUE "block.note_block.pling".
    05 FILLER PIC X(24) VALUE "trumpet".
    05 FILLER PIC X(48) VALUE "block.note_block.trumpet".
    05 FILLER PIC X(24) VALUE "trumpet_exposed".
    05 FILLER PIC X(48) VALUE "block.note_block.trumpet_exposed".
    05 FILLER PIC X(24) VALUE "trumpet_oxidized".
    05 FILLER PIC X(48) VALUE "block.note_block.trumpet_oxidized".
    05 FILLER PIC X(24) VALUE "trumpet_weathered".
    05 FILLER PIC X(48) VALUE "block.note_block.trumpet_weathered".
    05 FILLER PIC X(24) VALUE "zombie".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.zombie".
    05 FILLER PIC X(24) VALUE "skeleton".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.skeleton".
    05 FILLER PIC X(24) VALUE "creeper".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.creeper".
    05 FILLER PIC X(24) VALUE "dragon".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.ender_dragon".
    05 FILLER PIC X(24) VALUE "wither_skeleton".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.wither_skeleton".
    05 FILLER PIC X(24) VALUE "piglin".
    05 FILLER PIC X(48) VALUE "block.note_block.imitate.piglin".
    05 FILLER PIC X(24) VALUE "custom_head".
    05 FILLER PIC X(48) VALUE "ui.button.click".
 01 WS-IN REDEFINES WS-IN-DATA.
    05 WS-ROW OCCURS 27 TIMES.
       10 WS-NAME PIC X(24).
       10 WS-SOUND PIC X(48).
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-A                    PIC X(32).
 01 L-S                    PIC X(48).
 PROCEDURE DIVISION USING L-N L-A L-S.
     MOVE SPACES TO L-A L-S
     MOVE WS-NAME(L-N + 1) TO L-A
     MOVE WS-SOUND(L-N + 1) TO L-S
     GOBACK.
 END PROGRAM RS2-NOTE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-TYPE.
*> USING the instrument number, type out (1 base block, 2 mob head, 3 custom), tunable out, has custom sound out, works above a note block out (30-5 8.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TY-DATA.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 3.
 01 WS-TY REDEFINES WS-TY-DATA.
    05 WS-TYPE PIC 9 OCCURS 27 TIMES.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-T L-U L-C L-W.
     MOVE WS-TYPE(L-N + 1) TO L-T
     MOVE 0 TO L-U L-C L-W
     IF L-T = 1
         MOVE 1 TO L-U
     ELSE
         MOVE 1 TO L-W
     END-IF
     IF L-T = 3
         MOVE 1 TO L-C
     END-IF
     GOBACK.
 END PROGRAM RS2-NOTE-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-COUNT.
*> USING a type (0 for all), the number of instruments of it out (30-5 8.1, V10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TY-DATA.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 3.
 01 WS-TY REDEFINES WS-TY-DATA.
    05 WS-TYPE PIC 9 OCCURS 27 TIMES.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-C.
     MOVE 0 TO L-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF L-T = 0 OR WS-TYPE(WS-I) = L-T
             ADD 1 TO L-C
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS2-NOTE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-CHOOSE.
*> USING the instrument of the block above, the instrument of the block below, the instrument out (30-5 8.2): a head above wins; a head below gives harp.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-LONG.
 01 WS-U BINARY-LONG.
 01 WS-C BINARY-LONG.
 01 WS-WA BINARY-LONG.
 01 WS-WB BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-R.
     CALL "RS2-NOTE-TYPE" USING L-A WS-T WS-U WS-C WS-WA
     CALL "RS2-NOTE-TYPE" USING L-B WS-T WS-U WS-C WS-WB
     EVALUATE TRUE
         WHEN WS-WA = 1
             MOVE L-A TO L-R
         WHEN WS-WB = 1
             MOVE 0 TO L-R
         WHEN OTHER
             MOVE L-B TO L-R
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-NOTE-CHOOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-SHAPE-UPDATE.
*> USING the direction of the changed neighbour, recompute the instrument out (30-5 8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-R.
     MOVE 0 TO L-R
     IF L-D >= 5
         MOVE 1 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-NOTE-SHAPE-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-NEIGHBOR.
*> USING power now, powered, play out, written out, new powered out (30-5 8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-L                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-P L-L L-W L-X.
     MOVE 0 TO L-L L-W
     MOVE L-P TO L-X
     IF L-N NOT = L-P
         MOVE 1 TO L-W
         MOVE L-N TO L-X
         IF L-N = 1
             MOVE 1 TO L-L
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS2-NOTE-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-PLAY.
*> USING the instrument works above a note block, the block above is air, block event out, game event NOTE_BLOCK_PLAY out (30-5 8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-A L-E L-G.
     MOVE 0 TO L-E L-G
     IF L-W = 1 OR L-A = 1
         MOVE 1 TO L-E L-G
     END-IF
     GOBACK.
 END PROGRAM RS2-NOTE-PLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-TUNE.
*> USING the note, the new note out, played out, statistic out (1 tune_noteblock) (30-5 8.4 right click).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-M L-P L-S.
     COMPUTE L-M = FUNCTION MOD(L-N + 1, 25)
     MOVE 1 TO L-P L-S
     GOBACK.
 END PROGRAM RS2-NOTE-TUNE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-ATTACK.
*> USING the held item is in note_block_top_instruments, the clicked face is up, pass out (useItemOn), statistic out (2 play_noteblock for the left click) (30-5 8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-U L-P L-S.
     MOVE 0 TO L-P
     IF L-T = 1 AND L-U = 1
         MOVE 1 TO L-P
     END-IF
     MOVE 2 TO L-S
     GOBACK.
 END PROGRAM RS2-NOTE-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-PITCH.
*> USING the note (0 to 24), the pitch x 1e7 out (30-5 8.5: float(2^((n - 12) / 12))).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PT-DATA.
    05 FILLER PIC 9(8) VALUE 5000000.
    05 FILLER PIC 9(8) VALUE 5297316.
    05 FILLER PIC 9(8) VALUE 5612310.
    05 FILLER PIC 9(8) VALUE 5946035.
    05 FILLER PIC 9(8) VALUE 6299605.
    05 FILLER PIC 9(8) VALUE 6674199.
    05 FILLER PIC 9(8) VALUE 7071068.
    05 FILLER PIC 9(8) VALUE 7491536.
    05 FILLER PIC 9(8) VALUE 7937005.
    05 FILLER PIC 9(8) VALUE 8408964.
    05 FILLER PIC 9(8) VALUE 8908987.
    05 FILLER PIC 9(8) VALUE 9438743.
    05 FILLER PIC 9(8) VALUE 10000000.
    05 FILLER PIC 9(8) VALUE 10594631.
    05 FILLER PIC 9(8) VALUE 11224620.
    05 FILLER PIC 9(8) VALUE 11892071.
    05 FILLER PIC 9(8) VALUE 12599211.
    05 FILLER PIC 9(8) VALUE 13348398.
    05 FILLER PIC 9(8) VALUE 14142135.
    05 FILLER PIC 9(8) VALUE 14983071.
    05 FILLER PIC 9(8) VALUE 15874010.
    05 FILLER PIC 9(8) VALUE 16817929.
    05 FILLER PIC 9(8) VALUE 17817974.
    05 FILLER PIC 9(8) VALUE 18877486.
    05 FILLER PIC 9(8) VALUE 20000000.
 01 WS-PTT REDEFINES WS-PT-DATA.
    05 WS-PITCH PIC 9(8) OCCURS 25 TIMES.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-R.
     MOVE WS-PITCH(L-N + 1) TO L-R
     GOBACK.
 END PROGRAM RS2-NOTE-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-PITCH-CLAMP.
*> USING a pitch x 1e7, the clamped pitch out (30-5 8.5: 0.5 to 2.0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-R.
     COMPUTE L-R = FUNCTION MAX(5000000, FUNCTION MIN(20000000, L-P))
     GOBACK.
 END PROGRAM RS2-PITCH-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-EVENT.
*> USING the instrument, the note, the skull above has a sound (custom_head only), result out, sound out (1 the instrument's, 2 the custom one), pitch x 1e7 out, particle out, particle x velocity x 1e7 out, packet sent out (30-5 8.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TY BINARY-LONG.
 01 WS-TU BINARY-LONG.
 01 WS-C BINARY-LONG.
 01 WS-W BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-N L-K L-R L-S L-P L-A L-V L-T.
     MOVE 1 TO L-R L-T
     MOVE 1 TO L-S
     MOVE 10000000 TO L-P
     MOVE 0 TO L-A L-V
     CALL "RS2-NOTE-TYPE" USING L-I WS-TY WS-TU WS-C WS-W
     EVALUATE TRUE
         WHEN WS-TU = 1
             CALL "RS2-NOTE-PITCH" USING L-N L-P
             MOVE 1 TO L-A
             COMPUTE L-V ROUNDED = L-N * 10000000 / 24
         WHEN WS-C = 1 AND L-K = 1
             MOVE 2 TO L-S
         WHEN WS-C = 1
             MOVE 0 TO L-R L-S L-P L-T
     END-EVALUATE
     GOBACK.
 END PROGRAM RS2-NOTE-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-NOTE-POS.
*> USING the block x, y, z, the particle x, y, z (x 1e6) out, the sound x, y, z (x 1e6) out (30-5 8.5, 8.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-A L-B L-C L-D L-E L-F.
     COMPUTE L-A = L-X * 1000000 + 500000
     COMPUTE L-B = L-Y * 1000000 + 1200000
     COMPUTE L-C = L-Z * 1000000 + 500000
     MOVE L-A TO L-D
     COMPUTE L-E = L-Y * 1000000 + 500000
     MOVE L-C TO L-F
     GOBACK.
 END PROGRAM RS2-NOTE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-JUKEBOX-SIGNAL.
*> USING the block entity is a jukebox entity, its song player is playing, ownSignal out (30-5 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-P L-R.
     MOVE 0 TO L-R
     IF L-E = 1 AND L-P = 1
         MOVE 15 TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-JUKEBOX-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-JUKEBOX-ANALOG.
*> USING the disc stack names a song, its comparator_output, the analog signal out (30-5 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-C L-R.
     MOVE 0 TO L-R
     IF L-S = 1
         MOVE L-C TO L-R
     END-IF
     GOBACK.
 END PROGRAM RS2-JUKEBOX-ANALOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS2-JUKEBOX-FLAGS.
*> USING signal source, has an analog output, neighbour update from the block class out (30-5 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-A L-U.
     MOVE 1 TO L-S L-A
     MOVE 0 TO L-U
     GOBACK.
 END PROGRAM RS2-JUKEBOX-FLAGS.

