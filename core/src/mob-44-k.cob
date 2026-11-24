*> Bee flowers, pollination, hive trips and the hive release (002-lane-mobsa4; docs/protocol/44-residual-mob-questions-4-land-animals.md section 15, 19 section 16, 31 part 4 section 8).
*> - M44-BEE-FLOWER-FIND USING row, found out, x, y, z out: the nearest block of the tag bee_attractive in the box of radius 5 around the bee's block (GC4-BEE-ATTRACTS; waterlogged and the
*>   upper half of a sunflower are read from the state).
*> - M44-BEE-BRAIN USING row (called by BEE-TICK): a bee with no target that has not stung. Counters: the flower retry cooldown EN-BEE-CD, the stay-out countdown EN-BEE-STAY, the hive search
*>   cooldown EN-BEE-LOC, ticks since pollination EN-BEE-NONECT (counted while it has no nectar), the validation timer EN-BEE-VAL (every U(20, 40) ticks a remembered flower that is no longer
*>   attractive, a remembered hive that is no longer a hive block entity or is farther than 48 is forgotten). Priorities: enter the hive (within 2.0 of its centre with wantsToEnterHive: no
*>   stay-out countdown, not pollinating, not stung, no target, and nectar, or more than 3600 ticks without pollination, or the day timeline's stay-in-hive span 12542 to 23460; no fire in the 3 x 3 x 3
*>   box; the hive takes it with BE4-HIVE-ENTER and the mob is removed; a full hive is forgotten); pollinate (no nectar: find a flower and start (M44-BEE-POLL-START), hover 0.6 above its centre
*>   with the horizontal offsets of +-1/3 re-rolled with chance 1 in 25 a tick at modifier 0.35; M44-BEE-POLL-TICK ends it); locate a hive (a hive block entity with room within 20 blocks, else
*>   the cooldown 200); go to the hive (modifier 1.0, given up after 2400 ticks of travel); go to the known flower (no nectar, more than 600 ticks since pollination, modifier 1.0).
*>   Gaps (not in the docs or not modelled): the locate start delay of 200, the speed of the known flower trip, the unreachable-flower cache, BeeGrowCrop, the sounds and nectar particles, the
*>   persistence of the hive and flower memory in the mob NBT, the age and love time passing of a bee in a hive, rain in wantsToEnterHive.
*> - BEE-HIVES-TICK (no parameters; end of MOBS-TICK): every beehive or bee nest block entity ticks its stored bees (BE4-HIVE-BEE-TICK). One whose counter exceeds its minimum leaves when the
*>   facing cell is free (any block there blocks it: stand-in for the collision shape) and it is not the stay-in-hive span: a bee (0.55 x 0.5) appears at BE4-HIVE-POS, knows the hive, and, when it
*>   carried nectar, loses it and the honey level rises (BE4-HIVE-HONEY: 1, or 2 with chance 1 in 100, never above 5); a hive with a flower position gives it to a bee without one with chance 0.9.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-ATTRACTS-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-NAME-W              PIC X(24) VALUE "waterlogged".
 01 WS-NAME-H              PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ATTRACTS             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ATTRACTS.
     MOVE 0 TO L-ATTRACTS WS-WET
     MOVE 1 TO WS-HALF
     CALL "IP-BLOCK-KEY" USING L-DIM L-X L-Y L-Z WS-KEY WS-LENGTH
     IF WS-LENGTH > 0
         CALL "GC4-BEE-ATTRACTS" USING WS-KEY WS-WET WS-HALF L-ATTRACTS
     END-IF
     IF L-ATTRACTS = 1
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-W WS-TEXT WS-RESULT
         IF WS-RESULT = 1 AND WS-TEXT(1:4) = "true"
             MOVE 1 TO WS-WET
         END-IF
         MOVE 0 TO WS-HALF
         CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-H WS-TEXT WS-RESULT
         IF WS-RESULT = 0 OR WS-TEXT(1:5) = "upper"
             MOVE 1 TO WS-HALF
         END-IF
         CALL "GC4-BEE-ATTRACTS" USING WS-KEY WS-WET WS-HALF L-ATTRACTS
     END-IF
     GOBACK.
 END PROGRAM M44-BEE-ATTRACTS-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-FLOWER-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-FX                   BINARY-LONG.
 01 L-FY                   BINARY-LONG.
 01 L-FZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND L-FX L-FY L-FZ.
     MOVE 0 TO L-FOUND
     MOVE 1000 TO WS-BEST
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-LX = WS-BX - 5
     COMPUTE WS-LY = WS-BY - 5
     COMPUTE WS-LZ = WS-BZ - 5
     PERFORM VARYING WS-X FROM WS-LX BY 1 UNTIL WS-X > WS-BX + 5
         PERFORM VARYING WS-Y FROM WS-LY BY 1 UNTIL WS-Y > WS-BY + 5
             PERFORM VARYING WS-Z FROM WS-LZ BY 1 UNTIL WS-Z > WS-BZ + 5
                 COMPUTE WS-D2 = (WS-X - WS-BX) ** 2 + (WS-Y - WS-BY) ** 2 + (WS-Z - WS-BZ) ** 2
                 IF WS-D2 < WS-BEST
                     CALL "M44-BEE-ATTRACTS-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AT
                     IF WS-AT = 1
                         MOVE WS-D2 TO WS-BEST
                         MOVE 1 TO L-FOUND
                         MOVE WS-X TO L-FX
                         MOVE WS-Y TO L-FY
                         MOVE WS-Z TO L-FZ
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM M44-BEE-FLOWER-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-HIVE-AT.
*> USING dim, x, y, z, block entity index out (0 none): the beehive block entity (type 33) at the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-INDEX.
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z L-INDEX
     IF L-INDEX > 0
         IF BE-TYPE(L-INDEX) NOT = 33
             MOVE 0 TO L-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-BEE-HIVE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-SALT-V              BINARY-LONG VALUE 120.
 01 WS-BOUND-V             BINARY-LONG VALUE 21.
 01 WS-SALT-P              BINARY-LONG VALUE 121.
 01 WS-BOUND-P             BINARY-LONG VALUE 41.
 01 WS-SALT-O              BINARY-LONG VALUE 122.
 01 WS-BOUND-O             BINARY-LONG VALUE 25.
 01 WS-SALT-H              BINARY-LONG VALUE 123.
 01 WS-BOUND-H             BINARY-LONG VALUE 2.
 01 WS-SALT-F              BINARY-LONG VALUE 124.
 01 WS-BOUND-F             BINARY-LONG VALUE 1000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW-X              BINARY-LONG.
 01 WS-DRAW-Z              BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-WANTS               BINARY-LONG.
 01 WS-DAYTICK             BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-ENDED               BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-ADOPTED             BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM TICK-COUNTERS
     IF EN-TARGET(L-ROW) > 0 OR EN-BEE-STUNG(L-ROW) = 1
         GOBACK
     END-IF
     IF EN-BEE-VAL(L-ROW) > 0
         SUBTRACT 1 FROM EN-BEE-VAL(L-ROW)
     ELSE
         PERFORM CHECK-MEMORY
     END-IF
     PERFORM WANTS-HIVE
     IF EN-BEE-HV-ON(L-ROW) = 1 AND WS-WANTS = 1
         COMPUTE WS-D2 = (EN-X(L-ROW) - EN-BEE-HV-X(L-ROW) - 0.5) ** 2 + (EN-Y(L-ROW) - EN-BEE-HV-Y(L-ROW) - 0.5) ** 2
             + (EN-Z(L-ROW) - EN-BEE-HV-Z(L-ROW) - 0.5) ** 2
         IF WS-D2 < 4
             PERFORM ENTER-HIVE
             IF EN-USED(L-ROW) = 0
                 GOBACK
             END-IF
         END-IF
     END-IF
     PERFORM POLLINATE
     IF EN-BEE-POLL(L-ROW) > 0
         GOBACK
     END-IF
     PERFORM LOCATE-HIVE
     IF EN-BEE-HV-ON(L-ROW) = 1 AND WS-WANTS = 1
         PERFORM GO-TO-HIVE
         GOBACK
     END-IF
     IF EN-BEE-NECTAR(L-ROW) = 0 AND EN-BEE-FL-ON(L-ROW) = 1 AND EN-BEE-NONECT(L-ROW) > 600
         COMPUTE EN-FLY-X(L-ROW) = EN-BEE-FL-X(L-ROW) + 0.5
         COMPUTE EN-FLY-Y(L-ROW) = EN-BEE-FL-Y(L-ROW) + 0.6
         COMPUTE EN-FLY-Z(L-ROW) = EN-BEE-FL-Z(L-ROW) + 0.5
         MOVE 1.0 TO EN-FLY-MOD(L-ROW)
         MOVE 1 TO EN-FLY-ON(L-ROW)
     END-IF
     GO TO MAIN-EXIT.

 TICK-COUNTERS.
     IF EN-BEE-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-BEE-CD(L-ROW)
     END-IF
     IF EN-BEE-STAY(L-ROW) > 0
         SUBTRACT 1 FROM EN-BEE-STAY(L-ROW)
     END-IF
     IF EN-BEE-LOC(L-ROW) > 0
         SUBTRACT 1 FROM EN-BEE-LOC(L-ROW)
     END-IF
     IF EN-BEE-NECTAR(L-ROW) = 0
         ADD 1 TO EN-BEE-NONECT(L-ROW)
     END-IF.

 CHECK-MEMORY.
     CALL "XP-RANDOM" USING WS-SALT-V WS-BOUND-V WS-DRAW
     COMPUTE EN-BEE-VAL(L-ROW) = 20 + WS-DRAW
     IF EN-BEE-FL-ON(L-ROW) = 1
         CALL "M44-BEE-ATTRACTS-AT" USING EN-DIM(L-ROW) EN-BEE-FL-X(L-ROW) EN-BEE-FL-Y(L-ROW) EN-BEE-FL-Z(L-ROW) WS-AT
         IF WS-AT = 0
             MOVE 0 TO EN-BEE-FL-ON(L-ROW)
         END-IF
     END-IF
     IF EN-BEE-HV-ON(L-ROW) = 1
         CALL "M44-BEE-HIVE-AT" USING EN-DIM(L-ROW) EN-BEE-HV-X(L-ROW) EN-BEE-HV-Y(L-ROW) EN-BEE-HV-Z(L-ROW) WS-INDEX
         COMPUTE WS-D2 = (EN-X(L-ROW) - EN-BEE-HV-X(L-ROW)) ** 2 + (EN-Y(L-ROW) - EN-BEE-HV-Y(L-ROW)) ** 2
             + (EN-Z(L-ROW) - EN-BEE-HV-Z(L-ROW)) ** 2
         IF WS-INDEX = 0 OR WS-D2 > 2304
             MOVE 0 TO EN-BEE-HV-ON(L-ROW)
         END-IF
     END-IF.

 WANTS-HIVE.
     MOVE 0 TO WS-WANTS
     COMPUTE WS-DAYTICK = FUNCTION MOD(CW-TIME, 24000)
     IF EN-BEE-STAY(L-ROW) = 0 AND EN-BEE-POLL(L-ROW) = 0 AND EN-BEE-STUNG(L-ROW) = 0 AND EN-TARGET(L-ROW) = 0
         IF EN-BEE-NECTAR(L-ROW) = 1 OR EN-BEE-NONECT(L-ROW) > 3600 OR (WS-DAYTICK >= 12542 AND WS-DAYTICK < 23460)
             MOVE 1 TO WS-WANTS
         END-IF
     END-IF.

 ENTER-HIVE.
     CALL "M44-BEE-HIVE-AT" USING EN-DIM(L-ROW) EN-BEE-HV-X(L-ROW) EN-BEE-HV-Y(L-ROW) EN-BEE-HV-Z(L-ROW) WS-INDEX
     IF WS-INDEX = 0
         MOVE 0 TO EN-BEE-HV-ON(L-ROW)
         EXIT PARAGRAPH
     END-IF
     IF BE-XI(WS-INDEX, 5) >= 3
         MOVE 0 TO EN-BEE-HV-ON(L-ROW)
         EXIT PARAGRAPH
     END-IF
     PERFORM FIRE-NEAR
     IF WS-FIRE = 1
         EXIT PARAGRAPH
     END-IF
     CALL "XP-RANDOM" USING WS-SALT-H WS-BOUND-H WS-DRAW
     CALL "BE4-HIVE-ENTER" USING WS-INDEX EN-BEE-NECTAR(L-ROW) EN-BEE-FL-ON(L-ROW) WS-DRAW WS-ADDED WS-ADOPTED
     IF WS-ADOPTED = 1
         MOVE 1 TO BE-XI(WS-INDEX, 1)
         MOVE EN-BEE-FL-X(L-ROW) TO BE-XI(WS-INDEX, 2)
         MOVE EN-BEE-FL-Y(L-ROW) TO BE-XI(WS-INDEX, 3)
         MOVE EN-BEE-FL-Z(L-ROW) TO BE-XI(WS-INDEX, 4)
     END-IF
     IF WS-ADDED = 1
         CALL "ENTITY-REMOVE" USING L-ROW
     END-IF.

 FIRE-NEAR.
     MOVE 0 TO WS-FIRE
     COMPUTE WS-LX = EN-BEE-HV-X(L-ROW) - 1
     COMPUTE WS-LY = EN-BEE-HV-Y(L-ROW) - 1
     COMPUTE WS-LZ = EN-BEE-HV-Z(L-ROW) - 1
     PERFORM VARYING WS-X FROM WS-LX BY 1 UNTIL WS-X > EN-BEE-HV-X(L-ROW) + 1
         PERFORM VARYING WS-Y FROM WS-LY BY 1 UNTIL WS-Y > EN-BEE-HV-Y(L-ROW) + 1
             PERFORM VARYING WS-Z FROM WS-LZ BY 1 UNTIL WS-Z > EN-BEE-HV-Z(L-ROW) + 1
                 CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KEY WS-LENGTH
                 IF WS-KEY = "minecraft:fire"
                     MOVE 1 TO WS-FIRE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 POLLINATE.
     IF EN-BEE-POLL(L-ROW) = 0
         IF EN-BEE-NECTAR(L-ROW) = 0 AND EN-BEE-CD(L-ROW) = 0
             CALL "M44-BEE-FLOWER-FIND" USING L-ROW WS-FOUND WS-FX WS-FY WS-FZ
             IF WS-FOUND = 1
                 MOVE 1 TO EN-BEE-FL-ON(L-ROW)
                 MOVE WS-FX TO EN-BEE-FL-X(L-ROW)
                 MOVE WS-FY TO EN-BEE-FL-Y(L-ROW)
                 MOVE WS-FZ TO EN-BEE-FL-Z(L-ROW)
                 PERFORM NEW-HOVER
             END-IF
             CALL "XP-RANDOM" USING WS-SALT-P WS-BOUND-P WS-DRAW
             CALL "M44-BEE-POLL-START" USING L-ROW WS-FOUND WS-DRAW WS-STARTED
         END-IF
     END-IF
     IF EN-BEE-POLL(L-ROW) > 0
         MOVE 0 TO WS-VALID
         IF EN-BEE-FL-ON(L-ROW) = 1
             CALL "M44-BEE-ATTRACTS-AT" USING EN-DIM(L-ROW) EN-BEE-FL-X(L-ROW) EN-BEE-FL-Y(L-ROW) EN-BEE-FL-Z(L-ROW) WS-VALID
         END-IF
         CALL "M44-BEE-POLL-TICK" USING L-ROW WS-VALID WS-ENDED
         IF WS-ENDED = 1
             IF EN-BEE-NECTAR(L-ROW) = 1
                 MOVE 0 TO EN-BEE-NONECT(L-ROW)
             END-IF
         ELSE
             CALL "XP-RANDOM" USING WS-SALT-O WS-BOUND-O WS-DRAW
             IF WS-DRAW = 0
                 PERFORM NEW-HOVER
             END-IF
             COMPUTE EN-FLY-X(L-ROW) = EN-BEE-FL-X(L-ROW) + 0.5 + EN-BEE-HOX(L-ROW)
             COMPUTE EN-FLY-Y(L-ROW) = EN-BEE-FL-Y(L-ROW) + 0.6
             COMPUTE EN-FLY-Z(L-ROW) = EN-BEE-FL-Z(L-ROW) + 0.5 + EN-BEE-HOZ(L-ROW)
             MOVE 0.35 TO EN-FLY-MOD(L-ROW)
             MOVE 1 TO EN-FLY-ON(L-ROW)
         END-IF
     END-IF.

 NEW-HOVER.
     CALL "XP-RANDOM" USING WS-SALT-F WS-BOUND-F WS-DRAW-X
     CALL "XP-RANDOM" USING WS-SALT-F WS-BOUND-F WS-DRAW-Z
     COMPUTE EN-BEE-HOX(L-ROW) = (WS-DRAW-X / 1000 * 2 - 1) * 0.33333334
     COMPUTE EN-BEE-HOZ(L-ROW) = (WS-DRAW-Z / 1000 * 2 - 1) * 0.33333334.

 LOCATE-HIVE.
     IF EN-BEE-HV-ON(L-ROW) = 0 AND EN-BEE-LOC(L-ROW) = 0
         MOVE 401 TO WS-BEST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
             IF BE-USED(WS-I) = 1 AND BE-TYPE(WS-I) = 33 AND BE-DIM(WS-I) = EN-DIM(L-ROW) AND BE-XI(WS-I, 5) < 3
                 COMPUTE WS-D2 = (EN-X(L-ROW) - BE-X(WS-I) - 0.5) ** 2 + (EN-Y(L-ROW) - BE-Y(WS-I) - 0.5) ** 2
                     + (EN-Z(L-ROW) - BE-Z(WS-I) - 0.5) ** 2
                 IF WS-D2 <= 400 AND WS-D2 < WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE 1 TO EN-BEE-HV-ON(L-ROW)
                     MOVE BE-X(WS-I) TO EN-BEE-HV-X(L-ROW)
                     MOVE BE-Y(WS-I) TO EN-BEE-HV-Y(L-ROW)
                     MOVE BE-Z(WS-I) TO EN-BEE-HV-Z(L-ROW)
                     MOVE 0 TO WS-D2
                 END-IF
             END-IF
         END-PERFORM
         IF EN-BEE-HV-ON(L-ROW) = 0
             MOVE 200 TO EN-BEE-LOC(L-ROW)
         END-IF
     END-IF.

 GO-TO-HIVE.
     ADD 1 TO EN-BEE-TRIP(L-ROW)
     IF EN-BEE-TRIP(L-ROW) > 2400
         MOVE 0 TO EN-BEE-HV-ON(L-ROW) EN-BEE-TRIP(L-ROW)
     ELSE
         COMPUTE EN-FLY-X(L-ROW) = EN-BEE-HV-X(L-ROW) + 0.5
         COMPUTE EN-FLY-Y(L-ROW) = EN-BEE-HV-Y(L-ROW) + 0.5
         COMPUTE EN-FLY-Z(L-ROW) = EN-BEE-HV-Z(L-ROW) + 0.5
         MOVE 1.0 TO EN-FLY-MOD(L-ROW)
         MOVE 1 TO EN-FLY-ON(L-ROW)
     END-IF.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM M44-BEE-BRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEE-HIVES-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CONTENT.
 01 WS-IDX                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DAYTICK             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-NAME-F              PIC X(24) VALUE "facing".
 01 WS-NAME-H              PIC X(24) VALUE "honey_level".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-YROT                BINARY-LONG.
 01 WS-CW                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-OUT-X               BINARY-LONG.
 01 WS-OUT-Y               BINARY-LONG.
 01 WS-OUT-Z               BINARY-LONG.
 01 WS-OUT-STATE           BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-WIDTH               FLOAT-LONG VALUE 0.55.
 01 WS-HEIGHT              FLOAT-LONG VALUE 0.5.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-CSTATUS             BINARY-LONG.
 01 WS-BEE                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-NEW-LEVEL           BINARY-LONG.
 01 WS-SALT-D              BINARY-LONG VALUE 125.
 01 WS-BOUND-D             BINARY-LONG VALUE 100.
 01 WS-SALT-F              BINARY-LONG VALUE 126.
 01 WS-BOUND-F             BINARY-LONG VALUE 1000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-NECTAR              BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 PROCEDURE DIVISION.
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-CSTATUS
     COMPUTE WS-DAYTICK = FUNCTION MOD(CW-TIME, 24000)
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > BE-MAX
         IF BE-USED(WS-IDX) = 1 AND BE-TYPE(WS-IDX) = 33 AND BE-DIM(WS-IDX) > 0 AND BE-XI(WS-IDX, 5) > 0
             PERFORM TICK-HIVE
         END-IF
     END-PERFORM
     GO TO MAIN-EXIT.

 TICK-HIVE.
     MOVE BE-XI(WS-IDX, 5) TO WS-B
     PERFORM VARYING WS-B FROM WS-B BY -1 UNTIL WS-B < 1
         CALL "BE4-HIVE-BEE-TICK" USING WS-IDX WS-B WS-STATUS
         IF WS-STATUS >= 0
             PERFORM RELEASE-BEE
         END-IF
     END-PERFORM.

 RELEASE-BEE.
     IF WS-DAYTICK >= 12542 AND WS-DAYTICK < 23460
         EXIT PARAGRAPH
     END-IF
     CALL "WORLD-GET-BLOCK" USING BE-DIM(WS-IDX) BE-X(WS-IDX) BE-Y(WS-IDX) BE-Z(WS-IDX) WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-F WS-TEXT WS-RESULT
     MOVE 2 TO WS-DIR
     IF WS-RESULT = 1
         EVALUATE WS-TEXT(1:5)
             WHEN "south" MOVE 3 TO WS-DIR
             WHEN "west " MOVE 4 TO WS-DIR
             WHEN "east " MOVE 5 TO WS-DIR
         END-EVALUATE
     END-IF
     CALL "BE4-DIR-INFO" USING WS-DIR WS-DATA WS-YROT WS-CW WS-SX WS-SY WS-SZ
     COMPUTE WS-OUT-X = BE-X(WS-IDX) + WS-SX
     COMPUTE WS-OUT-Y = BE-Y(WS-IDX) + WS-SY
     COMPUTE WS-OUT-Z = BE-Z(WS-IDX) + WS-SZ
     CALL "WORLD-GET-BLOCK" USING BE-DIM(WS-IDX) WS-OUT-X WS-OUT-Y WS-OUT-Z WS-OUT-STATE
     MOVE 0 TO WS-BLOCKED
     IF WS-OUT-STATE NOT = 0
         MOVE 1 TO WS-BLOCKED
         EXIT PARAGRAPH
     END-IF
     COMPUTE WS-BASE = 6 + 4 * (WS-B - 1)
     MOVE BE-XI(WS-IDX, WS-BASE + 2) TO WS-NECTAR
     CALL "BE4-HIVE-POS" USING WS-DIR WS-BLOCKED WS-WIDTH WS-HEIGHT BE-X(WS-IDX) BE-Y(WS-IDX) BE-Z(WS-IDX) WS-PX WS-PY WS-PZ
     CALL "MOB-SPAWN" USING BE-DIM(WS-IDX) WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-BEE
     MOVE 1 TO EN-BEE-HV-ON(WS-BEE)
     MOVE BE-X(WS-IDX) TO EN-BEE-HV-X(WS-BEE)
     MOVE BE-Y(WS-IDX) TO EN-BEE-HV-Y(WS-BEE)
     MOVE BE-Z(WS-IDX) TO EN-BEE-HV-Z(WS-BEE)
     IF BE-XI(WS-IDX, 1) = 1
         CALL "XP-RANDOM" USING WS-SALT-F WS-BOUND-F WS-DRAW
         IF WS-DRAW < 900
             MOVE 1 TO EN-BEE-FL-ON(WS-BEE)
             MOVE BE-XI(WS-IDX, 2) TO EN-BEE-FL-X(WS-BEE)
             MOVE BE-XI(WS-IDX, 3) TO EN-BEE-FL-Y(WS-BEE)
             MOVE BE-XI(WS-IDX, 4) TO EN-BEE-FL-Z(WS-BEE)
         END-IF
     END-IF
     IF WS-STATUS = 0
         MOVE 0 TO EN-BEE-NECTAR(WS-BEE)
         PERFORM RAISE-HONEY
     END-IF
     CALL "BE4-HIVE-REMOVE" USING WS-IDX WS-B.

 RAISE-HONEY.
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-H WS-TEXT WS-RESULT
     IF WS-RESULT = 1
         COMPUTE WS-LEVEL = FUNCTION NUMVAL(WS-TEXT)
         MOVE 1 TO WS-DRAW
         IF WS-LEVEL < 5
             CALL "XP-RANDOM" USING WS-SALT-D WS-BOUND-D WS-DRAW
         END-IF
         CALL "BE4-HIVE-HONEY" USING WS-LEVEL WS-DRAW WS-NEW-LEVEL
         IF WS-NEW-LEVEL NOT = WS-LEVEL
             MOVE SPACES TO WS-TEXT
             MOVE WS-NEW-LEVEL TO WS-DIGIT
             MOVE WS-DIGIT TO WS-TEXT(1:1)
             CALL "BLOCK-STATE-PROP" USING WS-TWO WS-STATE WS-NAME-H WS-TEXT WS-NEW-STATE
             CALL "WORLD-SET-BLOCK" USING BE-DIM(WS-IDX) BE-X(WS-IDX) BE-Y(WS-IDX) BE-Z(WS-IDX) WS-NEW-STATE
         END-IF
     END-IF.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM BEE-HIVES-TICK.
