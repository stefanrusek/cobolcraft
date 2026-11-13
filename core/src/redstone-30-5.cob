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

