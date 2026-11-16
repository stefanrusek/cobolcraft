*> Evokers, evoker fangs and vexes (docs/protocol/20 sections 13.3 and 13.4; lane 002-lane-mobsb5, T8900). State: core/copy/EVKSTATE.cpy.
*>
*>   EVK-FIND USING entity id, create, slot out        the spell state of an evoker
*>   EVK-FANGS-PLAN USING distance squared, yaw (radians)   fills EV-PLAN: 13 fangs in two rings within 3 blocks, else a line of 16
*>   EVK-SPELL-TIMES USING spell, casting time out, interval out, warm-up out
*>   EVK-VEX-ALLOWED USING vex count, draw 0 to 7, yes out     the summon needs fewer vexes than 1 + the draw
*>   EVK-VEX-COUNT USING evoker row, count out         vexes in the box inflated by 16 around the evoker
*>   EVK-BEGIN USING evoker row, spell                 starts a spell: casting counter, warm-up, next start tick
*>   EVK-STEP USING evoker row                         one tick: warm-up, the cast, the casting counter, a new spell when one is due
*>   EVK-IS-CASTING USING evoker row, flag out         1 while a spell is being cast (the evoker stands still)
*>   EVK-SUMMON USING evoker row                       3 vexes near the evoker
*>   EVK-FANG-ADD USING dim, x, y, z, warm-up, owner entity id
*>   EVK-FANG-TICK                                     the world tick of all fangs (STDMOB-SPAWN-TICK)
*>   VEX-STEP USING vex row                            limited life and starvation
*> Wololo (EVK-WOLOLO-PICK, performed in EVK-STEP; the document's start condition is a target, so the fang goal always goes first: only EVK-BEGIN starts it), the fang column
*> (EVK-FANG-COLUMN), the spell id metadata 17 (EVK-SPELL-SEND), the vex charge flag and contact attack (VEX-CHARGE, VEX-CONTACT: lane mobsb7).
*> Gaps: the fang as a visible entity and its life counter (a fang is removed at its bite), the vex flight (no flying speed in the documents), an owner-less magic bite, the height of a
*> partial block in the fang cell.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EV-MAX OR L-SLOT > 0
         IF EV-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EV-MAX OR L-SLOT > 0
             IF EV-ID(WS-I) = 0
                 INITIALIZE EV-ENTRY(WS-I)
                 MOVE L-ID TO EV-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EVK-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-FANGS-PLAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-A                    FLOAT-LONG.
 01 WS-R                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-D2                    FLOAT-LONG.
 01 L-YAW                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-D2 L-YAW.
     IF L-D2 < 9
         MOVE 13 TO EV-PLAN-COUNT
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
             COMPUTE WS-A = L-YAW + WS-I * FUNCTION PI * 0.4
             MOVE 1.5 TO WS-R
             COMPUTE EV-PLAN-DX(WS-I + 1) = FUNCTION COS(WS-A) * WS-R
             COMPUTE EV-PLAN-DZ(WS-I + 1) = FUNCTION SIN(WS-A) * WS-R
             MOVE 0 TO EV-PLAN-WARM(WS-I + 1)
         END-PERFORM
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
             COMPUTE WS-A = L-YAW + WS-I * 2 * FUNCTION PI / 8 + 1.2566371
             MOVE 2.5 TO WS-R
             COMPUTE EV-PLAN-DX(WS-I + 6) = FUNCTION COS(WS-A) * WS-R
             COMPUTE EV-PLAN-DZ(WS-I + 6) = FUNCTION SIN(WS-A) * WS-R
             MOVE 3 TO EV-PLAN-WARM(WS-I + 6)
         END-PERFORM
     ELSE
         MOVE 16 TO EV-PLAN-COUNT
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
             COMPUTE WS-R = 1.25 * (WS-I + 1)
             COMPUTE EV-PLAN-DX(WS-I + 1) = FUNCTION COS(L-YAW) * WS-R
             COMPUTE EV-PLAN-DZ(WS-I + 1) = FUNCTION SIN(L-YAW) * WS-R
             MOVE WS-I TO EV-PLAN-WARM(WS-I + 1)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EVK-FANGS-PLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-SPELL-TIMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SPELL                 BINARY-LONG.
 01 L-CAST                  BINARY-LONG.
 01 L-INTERVAL              BINARY-LONG.
 01 L-WARM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SPELL L-CAST L-INTERVAL L-WARM.
     MOVE 20 TO L-WARM
     EVALUATE L-SPELL
         WHEN 1
             MOVE 100 TO L-CAST
             MOVE 340 TO L-INTERVAL
         WHEN 2
             MOVE 40 TO L-CAST
             MOVE 100 TO L-INTERVAL
         WHEN 3
             MOVE 60 TO L-CAST
             MOVE 140 TO L-INTERVAL
             MOVE 40 TO L-WARM
         WHEN 4
             MOVE 20 TO L-CAST
             MOVE 340 TO L-INTERVAL
         WHEN 5
             MOVE 20 TO L-CAST
             MOVE 180 TO L-INTERVAL
         WHEN OTHER
             MOVE 0 TO L-CAST L-INTERVAL L-WARM
     END-EVALUATE
     GOBACK.
 END PROGRAM EVK-SPELL-TIMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-VEX-ALLOWED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-COUNT                 BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-DRAW L-YES.
     MOVE 0 TO L-YES
     IF L-COUNT < 1 + L-DRAW
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM EVK-VEX-ALLOWED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-VEX-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             IF WS-S > 0
                 IF SM-KEY(WS-S) = "vex"
                     IF FUNCTION ABS(EN-X(WS-N) - EN-X(L-ROW)) <= 16.3 AND FUNCTION ABS(EN-Z(WS-N) - EN-Z(L-ROW)) <= 16.3
                             AND EN-Y(WS-N) >= EN-Y(L-ROW) - 16 AND EN-Y(WS-N) <= EN-Y(L-ROW) + 17.95
                         ADD 1 TO L-COUNT
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-VEX-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-BEGIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-CAST                 BINARY-LONG.
 01 WS-INTERVAL             BINARY-LONG.
 01 WS-WARM                 BINARY-LONG.
 01 WS-SHEEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SPELL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SPELL.
     CALL "EVK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         CALL "EVK-SPELL-TIMES" USING L-SPELL WS-CAST WS-INTERVAL WS-WARM
         MOVE L-SPELL TO EV-SPELL(WS-SLOT)
         MOVE WS-CAST TO EV-CAST(WS-SLOT)
         MOVE WS-WARM TO EV-WARM(WS-SLOT)
         COMPUTE EV-NEXT(WS-SLOT) = CW-TICKS + WS-INTERVAL
         IF L-SPELL = 3
             CALL "EVK-WOLOLO-PICK" USING L-ROW WS-SHEEP
             IF WS-SHEEP > 0
                 MOVE EN-ID(WS-SHEEP) TO EV-LAST(WS-SLOT)
             ELSE
                 MOVE 0 TO EV-LAST(WS-SLOT)
             END-IF
         END-IF
         CALL "EVK-SPELL-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM EVK-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-IS-CASTING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-FLAG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "EVK-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         IF EV-SPELL(WS-SLOT) > 0
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EVK-IS-CASTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-P                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-SPELL                BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 71.
 01 WS-BOUND                BINARY-LONG VALUE 8.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-MINY                 FLOAT-LONG.
 01 WS-MAXY                 FLOAT-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "EVK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF EV-SPELL(WS-SLOT) > 0
*>       The goal continues while the target lives; the warm-up counts down and at 0 the spell is performed.
         IF EV-WARM(WS-SLOT) > 0
             IF WS-P = 0
                 MOVE 0 TO EV-WARM(WS-SLOT)
             ELSE
                 SUBTRACT 1 FROM EV-WARM(WS-SLOT)
                 IF EV-WARM(WS-SLOT) = 0
                     EVALUATE EV-SPELL(WS-SLOT)
                         WHEN 1
                             CALL "EVK-SUMMON" USING L-ROW
                         WHEN 2
                             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
                             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                             IF WS-DX = 0 AND WS-DZ = 0
                                 MOVE 0 TO WS-YAW
                             ELSE
                                 COMPUTE WS-YAW = FUNCTION ATAN(WS-DZ / WS-DX)
                                 IF WS-DX < 0
                                     COMPUTE WS-YAW = WS-YAW + FUNCTION PI
                                 END-IF
                                 IF WS-DX = 0
                                     IF WS-DZ > 0
                                         COMPUTE WS-YAW = FUNCTION PI / 2
                                     ELSE
                                         COMPUTE WS-YAW = - FUNCTION PI / 2
                                     END-IF
                                 END-IF
                             END-IF
                             CALL "EVK-FANGS-PLAN" USING WS-D2 WS-YAW
                             IF PL-Y(WS-P) < EN-Y(L-ROW)
                                 MOVE PL-Y(WS-P) TO WS-MINY
                                 COMPUTE WS-MAXY = EN-Y(L-ROW) + 1
                             ELSE
                                 MOVE EN-Y(L-ROW) TO WS-MINY
                                 COMPUTE WS-MAXY = PL-Y(WS-P) + 1
                             END-IF
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EV-PLAN-COUNT
                                 COMPUTE WS-FX = EN-X(L-ROW) + EV-PLAN-DX(WS-I)
                                 COMPUTE WS-FZ = EN-Z(L-ROW) + EV-PLAN-DZ(WS-I)
                                 CALL "EVK-FANG-COLUMN" USING EN-DIM(L-ROW) WS-FX WS-FZ WS-MINY WS-MAXY WS-FOUND WS-CY
                                 IF WS-FOUND = 1
                                     MOVE WS-CY TO WS-FY
                                     CALL "EVK-FANG-ADD" USING EN-DIM(L-ROW) WS-FX WS-FY WS-FZ EV-PLAN-WARM(WS-I) EN-ID(L-ROW)
                                 END-IF
                             END-PERFORM
                         WHEN 3
*>                           Wololo: the chosen sheep, if alive, turns red (colour 14; the sheared bit is kept).
                             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
                                 IF EN-USED(WS-N) = 1 AND EN-ID(WS-N) = EV-LAST(WS-SLOT) AND EN-HEALTH(WS-N) > 0 AND EV-LAST(WS-SLOT) > 0
                                     COMPUTE EN-WOOL(WS-N) = EN-WOOL(WS-N) - FUNCTION MOD(EN-WOOL(WS-N), 16) + 14
                                     CALL "MOB-DATA-SEND" USING WS-N
                                 END-IF
                             END-PERFORM
                         WHEN OTHER
                             CONTINUE
                     END-EVALUATE
                 END-IF
             END-IF
         END-IF
         IF EV-CAST(WS-SLOT) > 0
             SUBTRACT 1 FROM EV-CAST(WS-SLOT)
         END-IF
         IF EV-CAST(WS-SLOT) = 0 AND EV-WARM(WS-SLOT) = 0
             MOVE 0 TO EV-SPELL(WS-SLOT)
             CALL "EVK-SPELL-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
*>   No spell running: with a target and the interval over, the summon goal first (when few vexes are about), then the fangs.
     IF WS-P > 0 AND CW-TICKS >= EV-NEXT(WS-SLOT)
         CALL "EVK-VEX-COUNT" USING L-ROW WS-COUNT
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         CALL "EVK-VEX-ALLOWED" USING WS-COUNT WS-DRAW WS-YES
         IF WS-YES = 1
             MOVE 1 TO WS-SPELL
         ELSE
             MOVE 2 TO WS-SPELL
         END-IF
         CALL "EVK-BEGIN" USING L-ROW WS-SPELL
     END-IF
     GOBACK.
 END PROGRAM EVK-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-SUMMON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-VTYPE                BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-V                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 72.
 01 WS-BOUND                BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE "minecraft:vex" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE 5 TO WS-BOUND
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + 0.5 - 2 + WS-DRAW
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + 0.5 - 2 + WS-DRAW
         COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + 1
         CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-VTYPE WS-X WS-Y WS-Z WS-YAW WS-V
         MOVE 90 TO WS-BOUND
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         MOVE 0 TO WS-SLOT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX OR WS-SLOT > 0
             IF VX-ID(WS-I) = 0
                 MOVE WS-I TO WS-SLOT
             END-IF
         END-PERFORM
         IF WS-SLOT > 0
             MOVE EN-ID(WS-V) TO VX-ID(WS-SLOT)
             MOVE EN-ID(L-ROW) TO VX-OWNER(WS-SLOT)
             COMPUTE VX-LIFE(WS-SLOT) = 20 * (30 + WS-DRAW)
             MOVE 0 TO VX-STARVE(WS-SLOT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-SUMMON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-FANG-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     FLOAT-LONG.
 01 L-Y                     FLOAT-LONG.
 01 L-Z                     FLOAT-LONG.
 01 L-WARM                  BINARY-LONG.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-WARM L-OWNER.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FG-MAX OR WS-DONE = 1
         IF FG-USED(WS-I) = 0
             MOVE 1 TO FG-USED(WS-I)
             MOVE L-DIM TO FG-DIM(WS-I)
             MOVE L-X TO FG-X(WS-I)
             MOVE L-Y TO FG-Y(WS-I)
             MOVE L-Z TO FG-Z(WS-I)
             MOVE L-WARM TO FG-WARM(WS-I)
             MOVE L-OWNER TO FG-OWNER(WS-I)
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-FANG-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-FANG-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY STDMOBS.
 COPY RULES.
 01 WS-I                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-O                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-DAMAGE               BINARY-LONG VALUE 6.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-ALLY                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FG-MAX
         IF FG-USED(WS-I) = 1
             SUBTRACT 1 FROM FG-WARM(WS-I)
             IF FG-WARM(WS-I) <= -8
*>               The bite: living entities in the box inflated by 0.2; the owner's family is spared.
                 MOVE 0 TO WS-O
                 PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
                     IF EN-USED(WS-N) = 1 AND EN-ID(WS-N) = FG-OWNER(WS-I)
                         MOVE WS-N TO WS-O
                     END-IF
                 END-PERFORM
                 IF WS-O > 0
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
                         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = FG-DIM(WS-I) AND PL-MODE(WS-P) < 2
                             IF FUNCTION ABS(PL-X(WS-P) - FG-X(WS-I)) <= 0.75 AND FUNCTION ABS(PL-Z(WS-P) - FG-Z(WS-I)) <= 0.75
                                     AND PL-Y(WS-P) <= FG-Y(WS-I) + 0.8 AND PL-Y(WS-P) + 1.8 >= FG-Y(WS-I)
                                 CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE WS-O
                             END-IF
                         END-IF
                     END-PERFORM
                     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
                         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = FG-DIM(WS-I)
                             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                             MOVE 0 TO WS-ALLY
                             IF WS-S > 0
                                 IF SM-KEY(WS-S) = "evoker" OR "vindicator" OR "pillager" OR "illusioner" OR "vex" OR "ravager"
                                     MOVE 1 TO WS-ALLY
                                 END-IF
                                 IF WS-ALLY = 0 AND FUNCTION ABS(EN-X(WS-N) - FG-X(WS-I)) <= 0.75
                                         AND FUNCTION ABS(EN-Z(WS-N) - FG-Z(WS-I)) <= 0.75
                                         AND EN-Y(WS-N) <= FG-Y(WS-I) + 0.8 AND EN-Y(WS-N) + 1 >= FG-Y(WS-I)
                                     CALL "HEALTH-MOB-DAMAGE" USING WS-N WS-DAMAGE CAUSE-MOB WS-NONE
                                 END-IF
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
                 MOVE 0 TO FG-USED(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-FANG-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY RULES.
 01 WS-I                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-D2                   FLOAT-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 74.
 01 WS-SEVEN                BINARY-LONG VALUE 7.
 01 WS-DRAW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX OR WS-SLOT > 0
         IF VX-ID(WS-I) = EN-ID(L-ROW)
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF VX-LIFE(WS-SLOT) > 0
         SUBTRACT 1 FROM VX-LIFE(WS-SLOT)
         IF VX-LIFE(WS-SLOT) = 0
             MOVE 20 TO VX-STARVE(WS-SLOT)
         END-IF
     ELSE
         IF VX-STARVE(WS-SLOT) > 0
             SUBTRACT 1 FROM VX-STARVE(WS-SLOT)
             IF VX-STARVE(WS-SLOT) = 0
                 MOVE 20 TO VX-STARVE(WS-SLOT)
                 CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-ONE CAUSE-MOB WS-NONE
             END-IF
         END-IF
     END-IF
*>   VexChargeAttackGoal: with a living target more than 2 blocks away and a 1 in 7 draw the charge starts; a charging vex that touches its target hurts it.
     IF EN-TARGET(L-ROW) > 0 AND VX-CHARGING(WS-SLOT) = 0
         COMPUTE WS-D2 = (PL-X(EN-TARGET(L-ROW)) - EN-X(L-ROW)) ** 2 + (PL-Y(EN-TARGET(L-ROW)) - EN-Y(L-ROW)) ** 2
             + (PL-Z(EN-TARGET(L-ROW)) - EN-Z(L-ROW)) ** 2
         CALL "XP-RANDOM" USING WS-SALT WS-SEVEN WS-DRAW
         IF WS-D2 > 4 AND WS-DRAW = 0
             CALL "VEX-CHARGE" USING L-ROW
         END-IF
     END-IF
     CALL "VEX-CONTACT" USING L-ROW
     GOBACK.
 END PROGRAM VEX-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-SPELL-SEND.
*> USING caster row: Set Entity Data (0x65) index 17 BYTE of the spell being cast (EV-SPELL: 0 none, 1 to 5), 13.3, to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID            BINARY-LONG VALUE 101.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "EVK-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         CALL "PB-INIT" USING MD-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING MD-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING MD-BUFFER EN-ID(L-ROW)
         INITIALIZE MD-METADATA-ENTRY
         MOVE 17 TO MD-MD-INDEX
         MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
         MOVE EV-SPELL(WS-SLOT) TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW MD-BUFFER
         CALL "PB-FREE" USING MD-BUFFER
     END-IF
     GOBACK.
 END PROGRAM EVK-SPELL-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-FANG-COLUMN.
*> USING dim, x, z (FLOAT-LONG), min y, max y (FLOAT-LONG), found out, y out (BINARY-LONG): the fang column of 13.3: scanning down from the cell of max y while the cell is at or above
*> the cell of min y less 1, the first cell with a solid block under it holds the fang (its y; a full block in the cell itself would add its height: the cells are scanned for air only). None when
*> the scan finds no ground.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-LOW                  BINARY-LONG.
 01 WS-BELOW                BINARY-LONG.
 01 WS-SOLID                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     FLOAT-LONG.
 01 L-Z                     FLOAT-LONG.
 01 L-MINY                  FLOAT-LONG.
 01 L-MAXY                  FLOAT-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-MINY L-MAXY L-FOUND L-Y.
     MOVE 0 TO L-FOUND L-Y
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     COMPUTE WS-Y = FUNCTION INTEGER(L-MAXY)
     COMPUTE WS-LOW = FUNCTION INTEGER(L-MINY) - 1
     PERFORM UNTIL WS-Y < WS-LOW OR L-FOUND = 1
         COMPUTE WS-BELOW = WS-Y - 1
         CALL "GI-SOLID-CELL" USING L-DIM WS-X WS-BELOW WS-Z WS-SOLID
         IF WS-SOLID = 1
             MOVE 1 TO L-FOUND
             MOVE WS-Y TO L-Y
         ELSE
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-FANG-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVK-WOLOLO-PICK.
*> USING evoker row, sheep row out: a sheep of colour blue (11) within the box inflated by (16, 4, 16) around the evoker, chosen at random among them, only with the mob_griefing rule true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-RULE-NAME            PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                 BINARY-DOUBLE.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 73.
 01 WS-DRAW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SHEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SHEEP.
     MOVE 0 TO L-SHEEP WS-COUNT
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     PERFORM 2 TIMES
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                 IF WS-S > 0
                     IF SM-KEY(WS-S) = "sheep" AND FUNCTION MOD(EN-WOOL(WS-N), 16) = 11
                             AND FUNCTION ABS(EN-X(WS-N) - EN-X(L-ROW)) <= 16.3 AND FUNCTION ABS(EN-Z(WS-N) - EN-Z(L-ROW)) <= 16.3
                             AND EN-Y(WS-N) <= EN-Y(L-ROW) + 1.95 + 4 AND EN-Y(WS-N) + 1.3 >= EN-Y(L-ROW) - 4
                         IF WS-PICK = 0
                             ADD 1 TO WS-COUNT
                         ELSE
                             ADD 1 TO WS-K
                             IF WS-K = WS-PICK
                                 MOVE WS-N TO L-SHEEP
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-PICK = 0
             IF WS-COUNT = 0
                 GOBACK
             END-IF
             CALL "XP-RANDOM" USING WS-SALT WS-COUNT WS-DRAW
             COMPUTE WS-PICK = WS-DRAW + 1
             MOVE 0 TO WS-K
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EVK-WOLOLO-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-FLAG-SEND.
*> USING vex row: Set Entity Data index 16 BYTE, the vex flags (bit 0 charging).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID            BINARY-LONG VALUE 101.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 01 WS-I                    BINARY-LONG.
 01 WS-FLAGS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-FLAGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) = EN-ID(L-ROW)
             MOVE VX-CHARGING(WS-I) TO WS-FLAGS
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING MD-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING MD-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING MD-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 16 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE WS-FLAGS TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW MD-BUFFER
     CALL "PB-FREE" USING MD-BUFFER
     GOBACK.
 END PROGRAM VEX-FLAG-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-CHARGE.
*> USING vex row: the charge starts (VexChargeAttackGoal.start): the charging flag is set and sent. The flight to the target's eye (speed 1.0) needs the vex flying speed, which no document gives:
*> the vex does not move yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) = EN-ID(L-ROW)
             MOVE 1 TO VX-CHARGING(WS-I)
             CALL "VEX-FLAG-SEND" USING L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VEX-CHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-CONTACT.
*> USING vex row: while charging, a vex whose box (0.4 x 0.8) meets its target's (a player 0.6 x 1.8) hurts it for 4 (the attack damage) and the charge ends (flag cleared and sent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-DAMAGE               BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX OR WS-SLOT > 0
         IF VX-ID(WS-I) = EN-ID(L-ROW)
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF VX-CHARGING(WS-SLOT) = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         IF FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= 0.5 AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= 0.5
                 AND PL-Y(WS-P) <= EN-Y(L-ROW) + 0.8 AND PL-Y(WS-P) + 1.8 >= EN-Y(L-ROW)
             CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
             MOVE 0 TO VX-CHARGING(WS-SLOT)
             CALL "VEX-FLAG-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VEX-CONTACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ILLUSIONER-IS-CASTING.
*> USING illusioner row, flag out: 1 while a spell is being cast.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-FLAG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     CALL "EVK-IS-CASTING" USING L-ROW L-FLAG
     GOBACK.
 END PROGRAM ILLUSIONER-IS-CASTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ILLUSIONER-STEP.
*> USING illusioner row (20 section 13.5): the spell goals share the evoker's casting machine (EV-ENTRY, EVK-SPELL-TIMES, EVK-BEGIN). With a target and the interval over: the
*> mirror (spell 4, usable when it lacks Invisibility) first, then blindness (spell 5: the target's entity id is not the last one it blinded and the difficulty is above Normal:
*> the document's effective difficulty above 2.0 is approximated by the difficulty id). The mirror gives itself Invisibility 1200, blindness gives the player Blindness 400.
*> Gaps: the effective difficulty is only the difficulty id, the illusion copies are client side, blindness on a mob target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY EVKSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-P                    BINARY-LONG.
 01 WS-SPELL                BINARY-LONG.
 01 WS-INVIS                BINARY-LONG VALUE 13.
 01 WS-BLIND                BINARY-LONG VALUE 14.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-LEFT                 BINARY-LONG.
 01 WS-AMP                  BINARY-LONG VALUE 0.
 01 WS-D-INVIS              BINARY-LONG VALUE 1200.
 01 WS-D-BLIND              BINARY-LONG VALUE 400.
 01 WS-MFLAGS               BINARY-LONG VALUE 2.
 01 WS-PFLAGS               BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "EVK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF EV-SPELL(WS-SLOT) > 0
         IF EV-WARM(WS-SLOT) > 0
             IF WS-P = 0
                 MOVE 0 TO EV-WARM(WS-SLOT)
             ELSE
                 SUBTRACT 1 FROM EV-WARM(WS-SLOT)
                 IF EV-WARM(WS-SLOT) = 0
                     IF EV-SPELL(WS-SLOT) = 4
                         CALL "MEF-ADD" USING EN-ID(L-ROW) WS-INVIS WS-AMP WS-D-INVIS WS-MFLAGS
                     ELSE
                         CALL "EFFECT-ADD" USING WS-P WS-BLIND WS-AMP WS-D-BLIND WS-PFLAGS
                     END-IF
                 END-IF
             END-IF
         END-IF
         IF EV-CAST(WS-SLOT) > 0
             SUBTRACT 1 FROM EV-CAST(WS-SLOT)
         END-IF
         IF EV-CAST(WS-SLOT) = 0 AND EV-WARM(WS-SLOT) = 0
             MOVE 0 TO EV-SPELL(WS-SLOT)
         END-IF
         GOBACK
     END-IF
     IF WS-P > 0 AND CW-TICKS >= EV-NEXT(WS-SLOT)
         CALL "MEF-LEVEL" USING EN-ID(L-ROW) WS-INVIS WS-LEVEL WS-LEFT
         MOVE 0 TO WS-SPELL
         IF WS-LEVEL = 0
             MOVE 4 TO WS-SPELL
         ELSE
             IF PL-ENTITY-ID(WS-P) NOT = EV-LAST(WS-SLOT) AND BW-DIFFICULTY > 2
                 MOVE 5 TO WS-SPELL
                 MOVE PL-ENTITY-ID(WS-P) TO EV-LAST(WS-SLOT)
             END-IF
         END-IF
         IF WS-SPELL > 0
             CALL "EVK-BEGIN" USING L-ROW WS-SPELL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ILLUSIONER-STEP.
