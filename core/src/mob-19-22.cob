*> The villager (docs/protocol/19-mobs-land-friendly-and-neutral.md sections 22 to 24; lane 002-lane-mobsb). Programs of plain numbers: the caller reads the
*> facts (rows, counts, flags, drawn random numbers) and takes the decision or the arithmetic of the section. The trade data is the copybook TRADES.cpy
*> (generated from section 24 by a script, 397 trades) with the pick counts of TRADESETS.cpy; the biome table is VILBIOME.cpy.
*>
*>   VIL-TRADE-SET USING profession (X(16)), level, first row out, trade count out, pick amount out        24 the rows of a trade set (0 rows: no set)
*>   VIL-OFFER-PICK USING profession, level, villager type (0 to 6), salt, rows out (3 BINARY-LONG), count out   22.4 selection without replacement
*>   VIL-XP-THRESHOLD USING level, threshold out; VIL-LEVEL-UP USING level, xp, levels up out              22.2
*>   VIL-DEMAND USING uses, max uses, demand, new demand out                                               22.4 updateDemand
*>   VIL-SPECIAL USING reputation, multiplier milli, base count, hero amplifier (-1 none), diff out         22.4 updateSpecialPrices
*>   VIL-GOSSIP-ADD USING type (1 to 5), existing, added, new out; VIL-GOSSIP-DECAY USING type, value, new out   22.5
*>   VIL-REPUTATION USING five values (major_negative ... trading), reputation out                          22.5
*>   VIL-RESTOCK USING game time, last restock, restocks today, needs restock, allowed out                   22.4 allowedToRestock
*>   VIL-ACTIVITY USING day tick, baby, activity out (1 idle 2 work 3 meet 4 rest 5 play)                   22.3 schedule
*>   VIL-BIOME-TYPE USING biome key (X(32)), type out                                                      22.1
*>   VIL-FOOD USING item key (X(24)), nutrition out; VIL-CAN-BREED USING food level, food in inventory, sleeping, age, yes out   22.6
*>   VIL-OFFSPRING USING roll x 1000, biome type, own type, other type, type out                           22.6
*>   VIL-PROFESSION USING workstation block key (X(32)), profession key out (X(16))                         22.2
*>   VIL-GOLEM-WANTS USING game time, last slept (-1 none), golem detected, yes out                         22.10
*>   VIL-WANDER-CHANCE USING chance, new chance out                                                        23 the spawn chance after the timer ran out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-TRADE-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TRADES.
 01 WS-TR REDEFINES TRADE-DATA.
    05 WS-ROW OCCURS 397 TIMES.
       10 WS-PROF               PIC X(16).
       10 WS-LEVEL              BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG OCCURS 6 TIMES.
 COPY TRADESETS.
 01 WS-SETS REDEFINES TRADE-SET-DATA.
    05 WS-SET OCCURS 68 TIMES.
       10 WS-SPROF              PIC X(16).
       10 WS-SLEVEL             BINARY-LONG.
       10 WS-SPICK              BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-LEVEL                 BINARY-LONG.
 01 L-FIRST                 BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PROF L-LEVEL L-FIRST L-COUNT L-PICK.
     MOVE 0 TO L-FIRST L-COUNT L-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TR-COUNT
         IF WS-PROF(WS-I) = L-PROF AND WS-LEVEL(WS-I) = L-LEVEL
             IF L-FIRST = 0
                 MOVE WS-I TO L-FIRST
             END-IF
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TR-SET-COUNT
         IF WS-SPROF(WS-I) = L-PROF AND WS-SLEVEL(WS-I) = L-LEVEL
             MOVE WS-SPICK(WS-I) TO L-PICK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VIL-TRADE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-OFFER-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TRADES.
 01 WS-TR REDEFINES TRADE-DATA.
    05 WS-ROW OCCURS 397 TIMES.
       10 FILLER                PIC X(16).
       10 FILLER                BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG.
       10 FILLER                PIC X(32).
       10 FILLER                BINARY-LONG OCCURS 4 TIMES.
       10 WS-MASK               BINARY-LONG.
       10 FILLER                BINARY-LONG.
 01 WS-FIRST                BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-CAND.
    05 WS-C                 BINARY-LONG OCCURS 100 TIMES.
 01 WS-NC                   BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-J                    BINARY-LONG.
 01 WS-BIT                  BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-LEVEL                 BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-SALT                  BINARY-LONG.
 01 L-ROWS.
    05 L-ROW                BINARY-LONG OCCURS 3 TIMES.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PROF L-LEVEL L-TYPE L-SALT L-ROWS L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "VIL-TRADE-SET" USING L-PROF L-LEVEL WS-FIRST WS-N WS-PICK
     COMPUTE WS-BIT = 2 ** L-TYPE
     MOVE 0 TO WS-NC
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-J = WS-FIRST + WS-I
         COMPUTE WS-OK = FUNCTION MOD(WS-MASK(WS-J) / WS-BIT, 2)
         IF WS-MASK(WS-J) = 0 OR WS-OK = 1
             ADD 1 TO WS-NC
             MOVE WS-J TO WS-C(WS-NC)
         END-IF
     END-PERFORM
     MOVE L-SALT TO WS-SALT
     PERFORM UNTIL L-COUNT >= WS-PICK OR WS-NC = 0
         ADD 1 TO WS-SALT
         CALL "XP-RANDOM" USING WS-SALT WS-NC WS-DRAW
         ADD 1 TO WS-DRAW
         ADD 1 TO L-COUNT
         MOVE WS-C(WS-DRAW) TO L-ROW(L-COUNT)
         MOVE WS-C(WS-NC) TO WS-C(WS-DRAW)
         SUBTRACT 1 FROM WS-NC
     END-PERFORM
     GOBACK.
 END PROGRAM VIL-OFFER-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-XP-THRESHOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T.
    05 FILLER               BINARY-LONG VALUE 0.
    05 FILLER               BINARY-LONG VALUE 10.
    05 FILLER               BINARY-LONG VALUE 70.
    05 FILLER               BINARY-LONG VALUE 150.
    05 FILLER               BINARY-LONG VALUE 250.
 01 WS-TV REDEFINES WS-T.
    05 WS-V                 BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-LEVEL                 BINARY-LONG.
 01 L-THRESHOLD             BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-THRESHOLD.
     MOVE 0 TO L-THRESHOLD
     IF L-LEVEL >= 1 AND L-LEVEL <= 5
         MOVE WS-V(L-LEVEL) TO L-THRESHOLD
     END-IF
     GOBACK.
 END PROGRAM VIL-XP-THRESHOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-LEVEL-UP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEXT                 BINARY-LONG.
 01 WS-NEXT-LEVEL           BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                 BINARY-LONG.
 01 L-XP                    BINARY-LONG.
 01 L-UP                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-XP L-UP.
     MOVE 0 TO L-UP
     COMPUTE WS-NEXT-LEVEL = L-LEVEL + 1
     CALL "VIL-XP-THRESHOLD" USING WS-NEXT-LEVEL WS-NEXT
     IF L-LEVEL >= 1 AND L-LEVEL <= 4 AND L-XP >= WS-NEXT
         MOVE 1 TO L-UP
     END-IF
     GOBACK.
 END PROGRAM VIL-LEVEL-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-DEMAND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USES                  BINARY-LONG.
 01 L-MAX                   BINARY-LONG.
 01 L-DEMAND                BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-USES L-MAX L-DEMAND L-NEW.
     COMPUTE L-NEW = L-DEMAND + L-USES - (L-MAX - L-USES)
     GOBACK.
 END PROGRAM VIL-DEMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-SPECIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                    BINARY-LONG.
 01 WS-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-REP                   BINARY-LONG.
 01 L-MULT                  BINARY-LONG.
 01 L-BASE                  BINARY-LONG.
 01 L-HERO                  BINARY-LONG.
 01 L-DIFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REP L-MULT L-BASE L-HERO L-DIFF.
     MOVE 0 TO L-DIFF
     IF L-REP NOT = 0
         COMPUTE WS-A = FUNCTION INTEGER(L-REP * L-MULT / 1000)
         SUBTRACT WS-A FROM L-DIFF
     END-IF
     IF L-HERO >= 0
         COMPUTE WS-H = FUNCTION INTEGER((300 + 62.5 * L-HERO) * L-BASE / 1000)
         IF WS-H < 1
             MOVE 1 TO WS-H
         END-IF
         SUBTRACT WS-H FROM L-DIFF
     END-IF
     GOBACK.
 END PROGRAM VIL-SPECIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GOSSIP-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX.
    05 FILLER               BINARY-LONG VALUE 100.
    05 FILLER               BINARY-LONG VALUE 200.
    05 FILLER               BINARY-LONG VALUE 25.
    05 FILLER               BINARY-LONG VALUE 20.
    05 FILLER               BINARY-LONG VALUE 25.
 01 WS-MV REDEFINES WS-MAX.
    05 WS-M                 BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-EXISTING              BINARY-LONG.
 01 L-ADDED                 BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-EXISTING L-ADDED L-NEW.
     COMPUTE L-NEW = L-EXISTING + L-ADDED
     IF L-NEW > WS-M(L-TYPE)
         MOVE FUNCTION MAX(WS-M(L-TYPE), L-EXISTING) TO L-NEW
     END-IF
     IF L-NEW < 2
         MOVE 0 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM VIL-GOSSIP-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GOSSIP-DECAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEC.
    05 FILLER               BINARY-LONG VALUE 10.
    05 FILLER               BINARY-LONG VALUE 20.
    05 FILLER               BINARY-LONG VALUE 1.
    05 FILLER               BINARY-LONG VALUE 0.
    05 FILLER               BINARY-LONG VALUE 2.
 01 WS-DV REDEFINES WS-DEC.
    05 WS-D                 BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-VALUE                 BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-VALUE L-NEW.
     COMPUTE L-NEW = L-VALUE - WS-D(L-TYPE)
     IF L-NEW < 2
         MOVE 0 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM VIL-GOSSIP-DECAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-REPUTATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W.
    05 FILLER               BINARY-LONG VALUE -5.
    05 FILLER               BINARY-LONG VALUE -1.
    05 FILLER               BINARY-LONG VALUE 1.
    05 FILLER               BINARY-LONG VALUE 5.
    05 FILLER               BINARY-LONG VALUE 1.
 01 WS-WV REDEFINES WS-W.
    05 WS-WT                BINARY-LONG OCCURS 5 TIMES.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUES.
    05 L-VALUE              BINARY-LONG OCCURS 5 TIMES.
 01 L-REP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUES L-REP.
     MOVE 0 TO L-REP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE L-REP = L-REP + L-VALUE(WS-I) * WS-WT(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM VIL-REPUTATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-RESTOCK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                  BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-TODAY                 BINARY-LONG.
 01 L-NEEDS                 BINARY-LONG.
 01 L-ALLOWED               BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-LAST L-TODAY L-NEEDS L-ALLOWED.
     MOVE 0 TO L-ALLOWED
     IF L-NEEDS = 1 AND (L-TODAY = 0 OR (L-TODAY < 2 AND L-TIME > L-LAST + 2400))
         MOVE 1 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM VIL-RESTOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-ACTIVITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICK                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-BABY L-ACT.
     COMPUTE WS-T = FUNCTION MOD(L-TICK, 24000)
     MOVE 4 TO L-ACT
     EVALUATE TRUE
         WHEN WS-T >= 12000 OR WS-T < 10
             MOVE 4 TO L-ACT
         WHEN L-BABY = 1 AND ((WS-T >= 3000 AND WS-T < 6000) OR (WS-T >= 10000 AND WS-T < 12000))
             MOVE 5 TO L-ACT
         WHEN L-BABY = 1
             MOVE 1 TO L-ACT
         WHEN WS-T >= 11000
             MOVE 1 TO L-ACT
         WHEN WS-T >= 9000
             MOVE 3 TO L-ACT
         WHEN WS-T >= 2000
             MOVE 2 TO L-ACT
         WHEN OTHER
             MOVE 1 TO L-ACT
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-ACTIVITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-BIOME-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILBIOME.
 01 WS-VB REDEFINES VILBIOME-DATA.
    05 WS-B OCCURS 29 TIMES.
       10 WS-KEY               PIC X(32).
       10 WS-TYPE              BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(32).
 01 L-TYPE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TYPE.
     MOVE 2 TO L-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VB-COUNT
         IF WS-KEY(WS-I) = L-KEY
             MOVE WS-TYPE(WS-I) TO L-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VIL-BIOME-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-FOOD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(24).
 01 L-NUTRITION             BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NUTRITION.
     EVALUATE L-KEY
         WHEN "bread"
             MOVE 4 TO L-NUTRITION
         WHEN "carrot"
         WHEN "potato"
         WHEN "beetroot"
             MOVE 1 TO L-NUTRITION
         WHEN OTHER
             MOVE 0 TO L-NUTRITION
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-CAN-BREED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOOD                  BINARY-LONG.
 01 L-INV                   BINARY-LONG.
 01 L-SLEEPING              BINARY-LONG.
 01 L-AGE                   BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FOOD L-INV L-SLEEPING L-AGE L-YES.
     MOVE 0 TO L-YES
     IF L-FOOD + L-INV >= 12 AND L-SLEEPING = 0 AND L-AGE = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM VIL-CAN-BREED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-OFFSPRING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL                  BINARY-LONG.
 01 L-BIOME                 BINARY-LONG.
 01 L-OWN                   BINARY-LONG.
 01 L-OTHER                 BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-BIOME L-OWN L-OTHER L-TYPE.
     EVALUATE TRUE
         WHEN L-ROLL < 500
             MOVE L-BIOME TO L-TYPE
         WHEN L-ROLL < 750
             MOVE L-OWN TO L-TYPE
         WHEN OTHER
             MOVE L-OTHER TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-OFFSPRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-PROFESSION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(32).
 01 L-PROF                  PIC X(16).
 PROCEDURE DIVISION USING L-KEY L-PROF.
     EVALUATE L-KEY
         WHEN "blast_furnace"
             MOVE "armorer" TO L-PROF
         WHEN "smoker"
             MOVE "butcher" TO L-PROF
         WHEN "cartography_table"
             MOVE "cartographer" TO L-PROF
         WHEN "brewing_stand"
             MOVE "cleric" TO L-PROF
         WHEN "composter"
             MOVE "farmer" TO L-PROF
         WHEN "barrel"
             MOVE "fisherman" TO L-PROF
         WHEN "fletching_table"
             MOVE "fletcher" TO L-PROF
         WHEN "cauldron"
         WHEN "water_cauldron"
         WHEN "lava_cauldron"
         WHEN "powder_snow_cauldron"
             MOVE "leatherworker" TO L-PROF
         WHEN "lectern"
             MOVE "librarian" TO L-PROF
         WHEN "stonecutter"
             MOVE "mason" TO L-PROF
         WHEN "loom"
             MOVE "shepherd" TO L-PROF
         WHEN "smithing_table"
             MOVE "toolsmith" TO L-PROF
         WHEN "grindstone"
             MOVE "weaponsmith" TO L-PROF
         WHEN OTHER
             MOVE "none" TO L-PROF
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-PROFESSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GOLEM-WANTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                  BINARY-LONG.
 01 L-SLEPT                 BINARY-LONG.
 01 L-DETECTED              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-SLEPT L-DETECTED L-YES.
     MOVE 0 TO L-YES
     IF L-SLEPT >= 0 AND L-TIME - L-SLEPT < 24000 AND L-DETECTED = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM VIL-GOLEM-WANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-WANDER-CHANCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANCE                BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-NEW.
     COMPUTE L-NEW = L-CHANCE + 25
     IF L-NEW < 25
         MOVE 25 TO L-NEW
     END-IF
     IF L-NEW > 75
         MOVE 75 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM VIL-WANDER-CHANCE.
