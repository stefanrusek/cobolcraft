*> Panda (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 8; 44-residual-mob-questions-4-land-animals.md section 7).
*> - Genes: two (EN-GENE-MAIN, EN-GENE-HIDDEN; 0 normal, 1 lazy, 2 worried, 3 playful, 4 brown, 5 weak, 6 aggressive), random at birth (nextInt(16): 0 lazy, 1 worried, 2 playful, 4 aggressive, 3 and
*>   5 to 8 weak, 9 and 10 brown, 11 to 15 normal). The trait is the main gene when it is dominant (not brown, not weak) and, for a recessive one, only when the hidden gene is the same, else normal. The
*>   weak trait sets max health 10 (the health of a new panda; the lazy trait's speed 0.07 is an open item: no per-mob speed exists). Offspring (PANDA-CHILD-GENES): the first boolean decides the pairing,
*>   oneOf(parent) is the main gene for true and the hidden gene for false (the docs leave the mapping open), then each gene is replaced by a random one with chance 1 in 32.
*> - Sneeze: an adult starts it with nextInt(500) = 0 a tick when weak, nextInt(6000) = 0 otherwise; the counter (metadata 19) counts 1 to 20 and at 21 the panda sneezes: the table gameplay/panda_sneeze
*>   (1 in 700 a slime ball) drops while mob_drops is true. The jump of the pandas nearby is an open item (no strength in the docs).
*> - An aggressive panda that a player hits targets the attacker and attacks it (attack damage 6, STDMOB-STEP's chase); the other pandas do not retaliate. The target is dropped when the player is gone, dead,
*>   not in survival, in another dimension or beyond the follow range.
*> Open items: the traits' goals (lying on the back, rolling, sitting, worry in a thunderstorm), eating, feeding genes into the baby's age, pickup, the flags byte (23) beyond sneezing, panda avoidance.
*>
*> Entry points:
*>   PANDA-GENE-RANDOM USING draw, gene out                    PANDA-TRAIT USING main, hidden, trait out
*>   PANDA-CHILD-GENES USING a-main, a-hidden, b-present, b-main, b-hidden, draws (8), main out, hidden out
*>   PANDA-ATTRS USING row                                     PANDA-BRED USING parent a, parent b, baby    PANDA-BORN USING row
*>   PANDA-SNEEZE-BOUND USING trait, bound out                 PANDA-SNEEZE-DONE USING row
*>   PANDA-HURT USING row, attacker player row                 PANDA-TICK USING row, hx out, hz out, walk out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-GENE-RANDOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-GENE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-GENE.
     EVALUATE TRUE
         WHEN L-DRAW = 0
             MOVE 1 TO L-GENE
         WHEN L-DRAW = 1
             MOVE 2 TO L-GENE
         WHEN L-DRAW = 2
             MOVE 3 TO L-GENE
         WHEN L-DRAW = 4
             MOVE 6 TO L-GENE
         WHEN L-DRAW < 9
             MOVE 5 TO L-GENE
         WHEN L-DRAW < 11
             MOVE 4 TO L-GENE
         WHEN OTHER
             MOVE 0 TO L-GENE
     END-EVALUATE
     GOBACK.
 END PROGRAM PANDA-GENE-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-TRAIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-MAIN                 BINARY-LONG.
 01 L-HIDDEN               BINARY-LONG.
 01 L-TRAIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAIN L-HIDDEN L-TRAIT.
     MOVE L-MAIN TO L-TRAIT
     IF (L-MAIN = 4 OR L-MAIN = 5) AND L-HIDDEN NOT = L-MAIN
         MOVE 0 TO L-TRAIT
     END-IF
     GOBACK.
 END PROGRAM PANDA-TRAIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-CHILD-GENES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE-A               BINARY-LONG.
 01 WS-ONE-B               BINARY-LONG.
 01 WS-RANDOM              BINARY-LONG.
 LINKAGE SECTION.
 01 L-AM                   BINARY-LONG.
 01 L-AH                   BINARY-LONG.
 01 L-BP                   BINARY-LONG.
 01 L-BM                   BINARY-LONG.
 01 L-BH                   BINARY-LONG.
 01 L-DRAWS.
    05 L-D                 BINARY-LONG OCCURS 8 TIMES.
 01 L-MAIN                 BINARY-LONG.
 01 L-HIDDEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-AM L-AH L-BP L-BM L-BH L-DRAWS L-MAIN L-HIDDEN.
     MOVE L-AH TO WS-ONE-A
     IF L-D(2) = 1
         MOVE L-AM TO WS-ONE-A
     END-IF
     MOVE L-BH TO WS-ONE-B
     IF L-D(3) = 1
         MOVE L-BM TO WS-ONE-B
     END-IF
     CALL "PANDA-GENE-RANDOM" USING L-D(4) WS-RANDOM
     EVALUATE TRUE
         WHEN L-BP = 1 AND L-D(1) = 1
             MOVE WS-ONE-A TO L-MAIN
             MOVE WS-ONE-B TO L-HIDDEN
         WHEN L-BP = 1
             MOVE WS-ONE-B TO L-MAIN
             MOVE WS-ONE-A TO L-HIDDEN
         WHEN L-D(1) = 1
             MOVE WS-ONE-A TO L-MAIN
             MOVE WS-RANDOM TO L-HIDDEN
         WHEN OTHER
             MOVE WS-RANDOM TO L-MAIN
             MOVE WS-ONE-A TO L-HIDDEN
     END-EVALUATE
     IF L-D(5) = 0
         CALL "PANDA-GENE-RANDOM" USING L-D(6) L-MAIN
     END-IF
     IF L-D(7) = 0
         CALL "PANDA-GENE-RANDOM" USING L-D(8) L-HIDDEN
     END-IF
     GOBACK.
 END PROGRAM PANDA-CHILD-GENES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-ATTRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-TRAIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     CALL "PANDA-TRAIT" USING EN-GENE-MAIN(L-ROW) EN-GENE-HIDDEN(L-ROW) WS-TRAIT
     MOVE SM-HEALTH(WS-M) TO EN-HEALTH(L-ROW)
     IF WS-TRAIT = 5
         MOVE 10 TO EN-HEALTH(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM PANDA-ATTRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-BORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-A              BINARY-LONG VALUE 61.
 01 WS-SALT-B              BINARY-LONG VALUE 62.
 01 WS-BOUND               BINARY-LONG VALUE 16.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT-A WS-BOUND WS-DRAW
     CALL "PANDA-GENE-RANDOM" USING WS-DRAW EN-GENE-MAIN(L-ROW)
     CALL "XP-RANDOM" USING WS-SALT-B WS-BOUND WS-DRAW
     CALL "PANDA-GENE-RANDOM" USING WS-DRAW EN-GENE-HIDDEN(L-ROW)
     CALL "PANDA-ATTRS" USING L-ROW
     GOBACK.
 END PROGRAM PANDA-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-BRED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 63.
 01 WS-BOUNDS.
    05 WS-B                BINARY-LONG OCCURS 8 TIMES.
 01 WS-DRAWS.
    05 WS-D                BINARY-LONG OCCURS 8 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG VALUE 1.
 01 WS-AM                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-BM                  BINARY-LONG.
 01 WS-BH                  BINARY-LONG.
 01 WS-MAIN                BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY.
*>   Draws: three booleans, nextInt(16), nextInt(32), nextInt(16), nextInt(32), nextInt(16).
     MOVE 2 TO WS-B(1) WS-B(2) WS-B(3)
     MOVE 16 TO WS-B(4) WS-B(6) WS-B(8)
     MOVE 32 TO WS-B(5) WS-B(7)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "XP-RANDOM" USING WS-SALT WS-B(WS-I) WS-D(WS-I)
     END-PERFORM
     MOVE EN-GENE-MAIN(L-A) TO WS-AM
     MOVE EN-GENE-HIDDEN(L-A) TO WS-AH
     MOVE EN-GENE-MAIN(L-B) TO WS-BM
     MOVE EN-GENE-HIDDEN(L-B) TO WS-BH
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-PRESENT WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE WS-MAIN TO EN-GENE-MAIN(L-BABY)
     MOVE WS-HIDDEN TO EN-GENE-HIDDEN(L-BABY)
     CALL "PANDA-ATTRS" USING L-BABY
     GOBACK.
 END PROGRAM PANDA-BRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-SNEEZE-BOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TRAIT                BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRAIT L-BOUND.
     MOVE 6000 TO L-BOUND
     IF L-TRAIT = 5
         MOVE 500 TO L-BOUND
     END-IF
     GOBACK.
 END PROGRAM PANDA-SNEEZE-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-SNEEZE-DONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY LOOTCTX.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-TABLE               PIC X(112) VALUE "minecraft:gameplay/panda_sneeze".
 01 WS-SALT                BINARY-LONG VALUE 64.
 01 WS-BOUND               BINARY-LONG VALUE 1000000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EN-PANDA-SNEEZE(L-ROW)
     CALL "MOB-DATA-SEND" USING L-ROW
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 1
         INITIALIZE LOOT-CONTEXT
         MOVE 1 TO LC-ORIGIN-SET LC-THIS-SET
         MOVE EN-X(L-ROW) TO LC-X
         MOVE EN-Y(L-ROW) TO LC-Y
         MOVE EN-Z(L-ROW) TO LC-Z
         MOVE "minecraft:panda" TO LC-THIS-TYPE
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE LC-SEED = WS-DRAW + 1
         CALL "LOOT-ROLL" USING WS-TABLE LOOT-CONTEXT LOOT-RESULT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET LR-ITEM(WS-I)
                 LR-AMOUNT(WS-I) LR-HANDLE(WS-I) WS-ITEM-ENTITY
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PANDA-SNEEZE-DONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-TRAIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "panda" AND L-ATTACKER > 0
         CALL "PANDA-TRAIT" USING EN-GENE-MAIN(L-ROW) EN-GENE-HIDDEN(L-ROW) WS-TRAIT
         IF WS-TRAIT = 6
             MOVE L-ATTACKER TO EN-TARGET(L-ROW)
             MOVE PL-ENTITY-ID(L-ATTACKER) TO EN-TARGET-ID(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PANDA-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-TRAIT               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
*>   The roll, lie-on-back and sit goals and handleRoll (44 part 4 sections 7.1 to 7.3, mob-44-panda.cob): the walk of this tick (to food, or standing) is theirs.
     CALL "PANDA-GOALS" USING L-ROW L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
*>   The target of a hit: kept while the player is there, in survival and within the follow range.
     IF EN-TARGET(L-ROW) > 0
         MOVE EN-TARGET(L-ROW) TO WS-P
         COMPUTE WS-LIMIT = SM-FOLLOW(WS-M) * SM-FOLLOW(WS-M)
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ROW) OR PL-STATE(WS-P) NOT = PS-ALIVE
                 OR PL-MODE(WS-P) NOT = 0 OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW) OR WS-D2 > WS-LIMIT
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
         END-IF
     END-IF
*>   Eating (44 part 4 section 7): a sitting panda with an item starts on nextInt(80) = 1; the counter runs on and ends on nextInt(20) = 1 past 100.
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 66 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DRAW = FUNCTION MOD(WS-R, 80)
     CALL "M44-PANDA-EAT-START" USING L-ROW WS-DRAW WS-DONE
     MOVE 67 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DRAW = FUNCTION MOD(WS-R, 20)
     CALL "M44-PANDA-EAT-TICK" USING L-ROW WS-DRAW WS-DONE
*>   The sneeze: the counter counts up and at 21 the panda sneezes; an adult starts one by a roll.
     IF EN-PANDA-SNEEZE(L-ROW) > 0
         ADD 1 TO EN-PANDA-SNEEZE(L-ROW)
         IF EN-PANDA-SNEEZE(L-ROW) > 20
             CALL "PANDA-SNEEZE-DONE" USING L-ROW
         ELSE
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
     IF EN-VARIANT(L-ROW) = 0
         CALL "PANDA-TRAIT" USING EN-GENE-MAIN(L-ROW) EN-GENE-HIDDEN(L-ROW) WS-TRAIT
         CALL "PANDA-SNEEZE-BOUND" USING WS-TRAIT WS-BOUND
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 65 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         IF FUNCTION MOD(WS-R, WS-BOUND) = 0
             MOVE 1 TO EN-PANDA-SNEEZE(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PANDA-TICK.
