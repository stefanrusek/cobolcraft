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
*> Gaps: the wololo spell (no sheep colour is kept), the fang column scan for the highest suitable block (the lower of the two feet is used), the fang as a visible entity and its
*> life counter (a fang is removed at its bite), the spell id metadata 17, the vex movement and contact attack, an owner-less magic bite.
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
                                 MOVE PL-Y(WS-P) TO WS-FY
                             ELSE
                                 MOVE EN-Y(L-ROW) TO WS-FY
                             END-IF
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EV-PLAN-COUNT
                                 COMPUTE WS-FX = EN-X(L-ROW) + EV-PLAN-DX(WS-I)
                                 COMPUTE WS-FZ = EN-Z(L-ROW) + EV-PLAN-DZ(WS-I)
                                 CALL "EVK-FANG-ADD" USING EN-DIM(L-ROW) WS-FX WS-FY WS-FZ EV-PLAN-WARM(WS-I) EN-ID(L-ROW)
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
     GOBACK.
 END PROGRAM VEX-STEP.

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
