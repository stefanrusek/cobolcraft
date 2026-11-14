*> Implementation test (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 8, 44-residual-mob-questions-4-land-animals.md section 7): the panda. The random gene by nextInt(16)
*> (0 lazy, 1 worried, 2 playful, 4 aggressive, 3 and 5 to 8 weak, 9 and 10 brown, 11 to 15 normal); the trait (a dominant main gene, a recessive one only when the hidden gene is the same); the offspring
*> genes (the pairing draw, oneOf by a boolean, 1 in 32 mutation); weak pandas have 10 health; metadata 21/22 genes and 19/23 sneeze; the sneeze (counter 1 to 20, the sneeze at 21: the table
*> gameplay/panda_sneeze, 1 in 700 a slime ball); a weak panda starts a sneeze 1 in 500 a tick (others 1 in 6000); an aggressive panda that is hit attacks the attacker (attack damage 6), the others do not;
*> the death drop is bamboo.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLIME               BINARY-LONG.
 01 WS-BAMBOO              BINARY-LONG.
 01 WS-GENE                BINARY-LONG.
 01 WS-TRAIT               BINARY-LONG.
 01 WS-MAIN                BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 01 WS-TEXT                PIC X(40).
 01 WS-DRAWS.
    05 WS-D                BINARY-LONG OCCURS 8 TIMES.
 01 WS-AM                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-BP                  BINARY-LONG.
 01 WS-BM                  BINARY-LONG.
 01 WS-BH                  BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-HEALTH0             FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/land-loot".
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:panda" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:bamboo" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BAMBOO WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:slime_ball" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SLIME WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   The random gene: draws 0 to 15.
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         CALL "PANDA-GENE-RANDOM" USING WS-I WS-GENE
         MOVE FUNCTION CHAR(WS-GENE + 49) TO WS-TEXT(WS-I + 1:1)
     END-PERFORM
     MOVE "acceptance US15 44-4§7 the random gene by nextInt(16)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1235655554400000" TO TL-EXPECTED
     MOVE WS-TEXT(1:16) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   The trait.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 0 TO WS-J
         CALL "PANDA-TRAIT" USING WS-I WS-J WS-TRAIT
         COMPUTE WS-N = WS-N * 10 + WS-TRAIT
     END-PERFORM
     MOVE "acceptance US15 19§8 Panda: a dominant main gene is the trait, a recessive one with another hidden gene is normal" TO TL-CASE
     MOVE 123006 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-I
     MOVE 4 TO WS-J
     CALL "PANDA-TRAIT" USING WS-I WS-J WS-TRAIT
     MOVE 5 TO WS-I
     MOVE 5 TO WS-J
     CALL "PANDA-TRAIT" USING WS-I WS-J WS-GENE
     MOVE "acceptance US15 19§8 Panda: a recessive main gene with the same hidden gene is the trait (brown, weak)" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-TRAIT * 10 + WS-GENE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Offspring genes. a = (1 lazy, 2 worried), b = (3 playful, 4 brown). Draws: pairing, oneOf a, oneOf b, random draw, mutation 1, its gene, mutation 2, its gene.
     MOVE 1 TO WS-AM
     MOVE 2 TO WS-AH
     MOVE 3 TO WS-BM
     MOVE 4 TO WS-BH
     MOVE 1 TO WS-BP
     MOVE 1 TO WS-D(1) WS-D(2) WS-D(5) WS-D(7)
     MOVE 0 TO WS-D(3) WS-D(4) WS-D(6) WS-D(8)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 both parents, pairing true: main oneOf(a), hidden oneOf(b)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-D(3)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 oneOf(b) is b's main gene for true" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-D(3)
     MOVE 0 TO WS-D(1)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 both parents, pairing false: main oneOf(b), hidden oneOf(a)" TO TL-CASE
     MOVE 41 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BP
     MOVE 1 TO WS-D(1)
     MOVE 5 TO WS-D(4)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 one parent, true: main oneOf(a), hidden a random gene" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-D(1)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 one parent, false: main a random gene, hidden oneOf(a)" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BP
     MOVE 1 TO WS-D(1)
     MOVE 0 TO WS-D(5)
     MOVE 4 TO WS-D(6)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 a 1 in 32 mutation replaces the main gene by a random one (draw 4: aggressive)" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-D(5)
     MOVE 0 TO WS-D(7)
     MOVE 3 TO WS-D(8)
     CALL "PANDA-CHILD-GENES" USING WS-AM WS-AH WS-BP WS-BM WS-BH WS-DRAWS WS-MAIN WS-HIDDEN
     MOVE "acceptance US15 44-4§7 and independently the hidden gene (draw 3: weak)" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MAIN * 10 + WS-HIDDEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A new panda has two random genes in 0 to 6, health 10 when weak.
     COMPUTE WS-X = WS-PX + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE "acceptance US15 minecraft:panda a new panda has two genes of 0 to 6" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-GENE-MAIN(WS-A) >= 0 AND EN-GENE-MAIN(WS-A) <= 6 AND EN-GENE-HIDDEN(WS-A) >= 0 AND EN-GENE-HIDDEN(WS-A) <= 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     CALL "PANDA-ATTRS" USING WS-A
     MOVE "acceptance US15 19§8 Panda: the weak trait has max health 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-GENE-MAIN(WS-A)
     MOVE 0 TO EN-GENE-HIDDEN(WS-A)
     CALL "PANDA-ATTRS" USING WS-A
     MOVE "acceptance US15 minecraft:panda a recessive weak gene alone leaves max health 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§8 Panda: the genes are entity data (21, 22)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§8 Panda: two normal genes send nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-GENE-HIDDEN(WS-A)
     CALL "MOB-DATA-SEND" USING WS-A

*>   Breeding two pandas: the baby has genes of 0 to 6 and is a baby.
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 1 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A) EN-GENE-MAIN(WS-B) EN-GENE-HIDDEN(WS-B)
     CALL "MOB-BREED" USING WS-A WS-B
     MOVE 0 TO WS-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A AND WS-I NOT = WS-B
             MOVE WS-I TO WS-C
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§8 Panda: breeding two pandas gives a baby panda with genes of 0 to 6" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-C > 0
         IF EN-VARIANT(WS-C) = 1 AND EN-GENE-MAIN(WS-C) <= 6 AND EN-GENE-HIDDEN(WS-C) <= 6
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-C
     CALL "ENTITY-REMOVE" USING WS-B

*>   Sneeze: counter 1 to 20, the sneeze at 21 resets it.
     MOVE 1 TO EN-PANDA-SNEEZE(WS-A)
     MOVE 0 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     PERFORM 19 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§8 Panda: the sneeze counter counts up a tick at a time (20 after 19 ticks)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-PANDA-SNEEZE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§8 Panda: the sneeze is entity data (19, 23)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§8 Panda: at more than 20 the sneeze happens and the counter is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-SNEEZE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The start odds.
     MOVE 5 TO WS-I
     CALL "PANDA-SNEEZE-BOUND" USING WS-I WS-BOUND
     MOVE 0 TO WS-I
     CALL "PANDA-SNEEZE-BOUND" USING WS-I WS-GENE
     MOVE "acceptance US15 44-4§7 the sneeze roll is nextInt(500) for a weak panda, nextInt(6000) for the others" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 500 * 10000 + 6000
     COMPUTE TL-OBSERVED-N = WS-BOUND * 10000 + WS-GENE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     MOVE 0 TO WS-I
     PERFORM UNTIL EN-PANDA-SNEEZE(WS-A) > 0 OR WS-I > 5000
         ADD 1 TO CW-TIME
         ADD 1 TO WS-I
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§8 Panda: a weak adult panda starts to sneeze at random within 5000 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PANDA-SNEEZE(WS-A) > 0 AND WS-I <= 5000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-PANDA-SNEEZE(WS-A)
*>   The loot: 1 in 700 a slime ball; 3000 sneezes drop some, but few.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000
         CALL "PANDA-SNEEZE-DONE" USING WS-A
     END-PERFORM
     PERFORM COUNT-SLIME
     MOVE "acceptance US15 19§8 Panda: the sneeze loot gameplay/panda_sneeze is about 1 in 700 a slime ball" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1 AND WS-N <= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   An aggressive panda that is hit attacks the attacker; one with normal genes does not.
     COMPUTE WS-X = WS-PX + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 6 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§8 Panda: an aggressive panda that is hit targets the attacker" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-I
     PERFORM UNTIL PL-HEALTH(WS-PLAYER) < WS-HEALTH0 OR WS-I > 120
         CALL "MOB-STEP" USING WS-A
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US15 minecraft:panda the aggressive panda walks to the player and bites" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player who is no longer in survival is dropped as the target.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§8 Panda: the target is dropped when the player is no longer in survival" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-GENE-MAIN(WS-A) EN-GENE-HIDDEN(WS-A)
     MOVE 0 TO EN-HURT(WS-A)
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§8 Panda: a panda without the aggressive trait does not retaliate" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The death drop: bamboo.
     MOVE 0 TO EN-HURT(WS-A)
     MOVE 100 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM COUNT-BAMBOO
     MOVE "acceptance US15 19§8 Panda: it drops one bamboo" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-SLIME.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-SLIME AND EN-ITEM-COUNT(WS-J) > 0
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM.

 COUNT-BAMBOO.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-BAMBOO AND EN-ITEM-COUNT(WS-J) > 0
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-8.
 COPY CORETEST.
 COPY MOBSPTEST.
