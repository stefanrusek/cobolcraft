*> Implementation test (lane 002-lane-mobsb; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 22 to 24, 44-residual-mob-questions-3-villagers-poi-raids.md): the trade data
*> (397 trades, 68 sets), selection without replacement with the villager type restriction, levels, demand, special price, gossip, restock, schedule, biome type, food, offspring, workstations.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-22.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ROWS.
    05 WS-R               BINARY-LONG OCCURS 5 TIMES.
 01 WS-NAME               PIC X(90).
 01 WS-E                  BINARY-LONG.
 01 WS-O                  BINARY-LONG.
 01 WS-PROF               PIC X(16).
 01 WS-KEY                PIC X(32).
 01 WS-KEY24              PIC X(24).
 01 WS-FIRST              BINARY-LONG.
 01 WS-N                  BINARY-LONG.
 01 WS-PICK               BINARY-LONG.
 01 WS-LEVEL              BINARY-LONG.
 01 WS-TYPE               BINARY-LONG.
 01 WS-SALT               BINARY-LONG.
 COPY TRADES.
 01 WS-TR REDEFINES TRADE-DATA.
    05 WS-ROW OCCURS 397 TIMES.
       10 FILLER          PIC X(16).
       10 FILLER          BINARY-LONG.
       10 FILLER          PIC X(32).
       10 FILLER          BINARY-LONG.
       10 FILLER          PIC X(32).
       10 FILLER          BINARY-LONG.
       10 FILLER          PIC X(32).
       10 FILLER          BINARY-LONG OCCURS 4 TIMES.
       10 WS-MASK         BINARY-LONG.
       10 FILLER          BINARY-LONG.
 COPY TRADESETS.
 01 WS-VALUES.
    05 WS-V               BINARY-LONG OCCURS 5 TIMES.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-C                  BINARY-LONG.
 01 WS-DISTINCT           BINARY-LONG.
 01 WS-BAD                BINARY-LONG.
 01 WS-BIT                BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-PROFOUT            PIC X(16).
 01 WS-D1                 PIC 9(6).
 01 WS-D2                 PIC 9.
 01 WS-D3                 PIC 9.
 01 WS-F8                 BINARY-LONG VALUE 8.
 01 WS-F4                 BINARY-LONG VALUE 4.
 01 WS-F3                 BINARY-LONG VALUE 3.
 01 WS-F0                 BINARY-LONG VALUE 0.
 01 WS-F0B                BINARY-LONG VALUE 0.
 01 WS-F5                 BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     MOVE 397 TO WS-E
     MOVE TR-COUNT TO WS-O
     MOVE "acceptance US15 19§24 397 trades" TO WS-NAME
     PERFORM CHECK-N
     MOVE 68 TO WS-E
     MOVE TR-SET-COUNT TO WS-O
     MOVE "acceptance US15 19§24 68 trade sets" TO WS-NAME
     PERFORM CHECK-N
     MOVE "armorer" TO WS-PROF
     MOVE 1 TO WS-LEVEL
     CALL "VIL-TRADE-SET" USING WS-PROF WS-LEVEL WS-FIRST WS-N WS-PICK
     MOVE 5 TO WS-E
     MOVE WS-N TO WS-O
     MOVE "acceptance US15 19§24 armorer level 1 has 5 trades" TO WS-NAME
     PERFORM CHECK-N
     MOVE 2 TO WS-E
     MOVE WS-PICK TO WS-O
     MOVE "acceptance US15 19§24 armorer level 1 picks 2" TO WS-NAME
     PERFORM CHECK-N
     MOVE "librarian" TO WS-PROF
     MOVE 5 TO WS-LEVEL
     CALL "VIL-TRADE-SET" USING WS-PROF WS-LEVEL WS-FIRST WS-N WS-PICK
     MOVE 3 TO WS-E
     MOVE WS-PICK TO WS-O
     MOVE "acceptance US15 19§24 librarian level 5 picks 3" TO WS-NAME
     PERFORM CHECK-N
     MOVE "nitwit" TO WS-PROF
     CALL "VIL-TRADE-SET" USING WS-PROF WS-LEVEL WS-FIRST WS-N WS-PICK
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     MOVE "acceptance US15 19§22.4 a nitwit has no trade set" TO WS-NAME
     PERFORM CHECK-N
*>   The wandering trader: buying 6 trades pick 2, uncommon, common 78 pick 5.
     MOVE "wandering_trader" TO WS-PROF
     MOVE 3 TO WS-LEVEL
     CALL "VIL-TRADE-SET" USING WS-PROF WS-LEVEL WS-FIRST WS-N WS-PICK
     MOVE 5 TO WS-E
     MOVE WS-PICK TO WS-O
     MOVE "acceptance US15 19§23 wandering trader common picks 5" TO WS-NAME
     PERFORM CHECK-N
     MOVE 78 TO WS-E
     MOVE WS-N TO WS-O
     MOVE "acceptance US15 19§24 wandering trader common has 78 trades" TO WS-NAME
     PERFORM CHECK-N
*>   Selection: distinct rows, inside the set, and the type restriction holds for every villager type.
     MOVE 0 TO WS-BAD
     MOVE "cartographer" TO WS-PROF
     MOVE 4 TO WS-LEVEL
     CALL "VIL-TRADE-SET" USING WS-PROF WS-LEVEL WS-FIRST WS-N WS-PICK
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 6
         PERFORM VARYING WS-SALT FROM 1 BY 7 UNTIL WS-SALT > 300
             CALL "VIL-OFFER-PICK" USING WS-PROF WS-LEVEL WS-TYPE WS-SALT WS-ROWS WS-A
             IF WS-A NOT = 2 OR WS-R(1) = WS-R(2)
                 ADD 1 TO WS-BAD
             END-IF
             PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > WS-A
                 COMPUTE WS-BIT = 2 ** WS-TYPE
                 COMPUTE WS-OK = FUNCTION MOD(WS-MASK(WS-R(WS-B)) / WS-BIT, 2)
                 IF WS-R(WS-B) < WS-FIRST OR WS-R(WS-B) >= WS-FIRST + WS-N
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-MASK(WS-R(WS-B)) NOT = 0 AND WS-OK = 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     MOVE "acceptance US15 19§22.4 picks are distinct, in the set and respect the villager type" TO WS-NAME
     PERFORM CHECK-N
*>   A set smaller than its amount gives what exists (armorer level 4 has 2 trades, pick 2; mason level 1 has fewer than 3).
     MOVE "armorer" TO WS-PROF
     MOVE 4 TO WS-LEVEL
     MOVE 5 TO WS-TYPE
     CALL "VIL-OFFER-PICK" USING WS-PROF WS-LEVEL WS-TYPE WS-SALT WS-ROWS WS-A
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.4 armorer level 4 gives both of its trades" TO WS-NAME
     PERFORM CHECK-N
     MOVE "librarian" TO WS-PROF
     MOVE 5 TO WS-LEVEL
     CALL "VIL-OFFER-PICK" USING WS-PROF WS-LEVEL WS-TYPE WS-SALT WS-ROWS WS-A
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.4 a set with fewer trades than its amount gives them all" TO WS-NAME
     PERFORM CHECK-N
*>   Levels: thresholds 0, 10, 70, 150, 250.
     MOVE 1 TO WS-LEVEL
     CALL "VIL-XP-THRESHOLD" USING WS-LEVEL WS-A
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 level 1 threshold 0" TO WS-NAME
     PERFORM CHECK-N
     MOVE 5 TO WS-LEVEL
     CALL "VIL-XP-THRESHOLD" USING WS-LEVEL WS-A
     MOVE 250 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 level 5 threshold 250" TO WS-NAME
     PERFORM CHECK-N
     MOVE 6 TO WS-LEVEL
     CALL "VIL-XP-THRESHOLD" USING WS-LEVEL WS-A
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 no level 6 threshold" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-LEVEL
     MOVE 10 TO WS-B
     CALL "VIL-LEVEL-UP" USING WS-LEVEL WS-B WS-A
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 10 xp levels a novice up" TO WS-NAME
     PERFORM CHECK-N
     MOVE 9 TO WS-B
     CALL "VIL-LEVEL-UP" USING WS-LEVEL WS-B WS-A
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 9 xp does not" TO WS-NAME
     PERFORM CHECK-N
     MOVE 5 TO WS-LEVEL
     MOVE 9999 TO WS-B
     CALL "VIL-LEVEL-UP" USING WS-LEVEL WS-B WS-A
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     MOVE "acceptance US15 19§22.2 a master never levels up" TO WS-NAME
     PERFORM CHECK-N
*>   Demand: uses 0 of 12 lowers it by 12; used up raises it by 12.
     MOVE 0 TO WS-A
     MOVE 12 TO WS-B
     MOVE 0 TO WS-C
     CALL "VIL-DEMAND" USING WS-A WS-B WS-C WS-O
     COMPUTE WS-E = -12
     MOVE "acceptance US15 19§22.4 an unused offer lowers its demand by 12" TO WS-NAME
     PERFORM CHECK-N
     MOVE 12 TO WS-A
     CALL "VIL-DEMAND" USING WS-A WS-B WS-C WS-O
     MOVE 12 TO WS-E
     MOVE "acceptance US15 19§22.4 a sold out offer raises its demand by 12" TO WS-NAME
     PERFORM CHECK-N
*>   Special price: reputation 10, multiplier 0.2 -> -2; negative -3 x 0.2 = floor(-0.6) = -1 -> +1; hero amplifier 0 on base 10 -> floor(3) = 3.
     MOVE 10 TO WS-A
     MOVE 200 TO WS-B
     MOVE 10 TO WS-C
     COMPUTE WS-LEVEL = -1
     CALL "VIL-SPECIAL" USING WS-A WS-B WS-C WS-LEVEL WS-O
     COMPUTE WS-E = -2
     MOVE "acceptance US15 19§22.4 reputation 10 at 0.2 lowers the price by 2" TO WS-NAME
     PERFORM CHECK-N
     COMPUTE WS-A = -3
     CALL "VIL-SPECIAL" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.4 reputation -3 at 0.2 raises the price by 1" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-LEVEL
     CALL "VIL-SPECIAL" USING WS-A WS-B WS-C WS-LEVEL WS-O
     COMPUTE WS-E = -3
     MOVE "acceptance US15 19§22.4 Hero of the Village I on a base of 10 lowers it by 3" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-C
     CALL "VIL-SPECIAL" USING WS-A WS-B WS-C WS-LEVEL WS-O
     COMPUTE WS-E = -1
     MOVE "acceptance US15 19§22.4 the hero discount is at least 1" TO WS-NAME
     PERFORM CHECK-N
*>   Gossip: caps and decay; reputation weights.
     MOVE 3 TO WS-A
     MOVE 20 TO WS-B
     MOVE 10 TO WS-C
     CALL "VIL-GOSSIP-ADD" USING WS-A WS-B WS-C WS-O
     MOVE 25 TO WS-E
     MOVE "acceptance US15 19§22.5 minor_positive is capped at 25" TO WS-NAME
     PERFORM CHECK-N
     MOVE 30 TO WS-B
     CALL "VIL-GOSSIP-ADD" USING WS-A WS-B WS-C WS-O
     MOVE 30 TO WS-E
     MOVE "acceptance US15 19§22.5 an over-cap value is kept" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "VIL-GOSSIP-ADD" USING WS-A WS-B WS-C WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.5 a value below 2 is dropped" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     MOVE 25 TO WS-B
     CALL "VIL-GOSSIP-DECAY" USING WS-A WS-B WS-O
     MOVE 15 TO WS-E
     MOVE "acceptance US15 19§22.5 major_negative 25 decays to 15 a day" TO WS-NAME
     PERFORM CHECK-N
     MOVE 4 TO WS-A
     MOVE 12 TO WS-B
     CALL "VIL-GOSSIP-DECAY" USING WS-A WS-B WS-O
     MOVE 12 TO WS-E
     MOVE "acceptance US15 19§22.5 major_positive does not decay" TO WS-NAME
     PERFORM CHECK-N
     MOVE 5 TO WS-A
     MOVE 3 TO WS-B
     CALL "VIL-GOSSIP-DECAY" USING WS-A WS-B WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.5 a decayed value below 2 is removed" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-V(1)
     MOVE 2 TO WS-V(2)
     MOVE 3 TO WS-V(3)
     MOVE 4 TO WS-V(4)
     MOVE 5 TO WS-V(5)
     CALL "VIL-REPUTATION" USING WS-VALUES WS-O
     COMPUTE WS-E = -5 - 2 + 3 + 20 + 5
     MOVE "acceptance US15 19§22.5 reputation is the weighted sum" TO WS-NAME
     PERFORM CHECK-N
*>   Restock.
     MOVE 5000 TO WS-A
     MOVE 1000 TO WS-B
     MOVE 1 TO WS-C
     CALL "VIL-RESTOCK" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.4 no offer needs a restock" TO WS-NAME
     MOVE 0 TO WS-LEVEL
     PERFORM CHECK-N
     MOVE 1 TO WS-LEVEL
     CALL "VIL-RESTOCK" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.4 the second restock of a day after 2400 ticks" TO WS-NAME
     PERFORM CHECK-N
     MOVE 3000 TO WS-A
     CALL "VIL-RESTOCK" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.4 not before 2400 ticks have passed" TO WS-NAME
     PERFORM CHECK-N
     MOVE 2 TO WS-C
     MOVE 9000 TO WS-A
     CALL "VIL-RESTOCK" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE "acceptance US15 19§22.4 at most two restocks a day" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     CALL "VIL-RESTOCK" USING WS-A WS-B WS-C WS-LEVEL WS-O
     MOVE "acceptance US15 19§22.4 the first restock of a day" TO WS-NAME
     PERFORM CHECK-N
*>   Schedule.
     MOVE 0 TO WS-B
     MOVE 5 TO WS-A
     PERFORM CHECK-ACT-4
     MOVE 1 TO WS-E
     MOVE 500 TO WS-A
     PERFORM CHECK-ACT
     MOVE 2 TO WS-E
     MOVE 2000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 3 TO WS-E
     MOVE 9000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 1 TO WS-E
     MOVE 11000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 4 TO WS-E
     MOVE 12000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 4 TO WS-E
     MOVE 36005 TO WS-A
     PERFORM CHECK-ACT
     MOVE 1 TO WS-B
     MOVE 5 TO WS-E
     MOVE 3000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 1 TO WS-E
     MOVE 6000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 5 TO WS-E
     MOVE 10000 TO WS-A
     PERFORM CHECK-ACT
     MOVE 1 TO WS-E
     MOVE 1000 TO WS-A
     PERFORM CHECK-ACT
*>   Biome type, food, breeding, offspring, workstation, golem, wandering trader.
     MOVE "desert" TO WS-KEY
     CALL "VIL-BIOME-TYPE" USING WS-KEY WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.1 a desert gives a desert villager" TO WS-NAME
     PERFORM CHECK-N
     MOVE "windswept_forest" TO WS-KEY
     CALL "VIL-BIOME-TYPE" USING WS-KEY WS-O
     MOVE 6 TO WS-E
     MOVE "acceptance US15 19§22.1 windswept forest gives taiga" TO WS-NAME
     PERFORM CHECK-N
     MOVE "plains" TO WS-KEY
     CALL "VIL-BIOME-TYPE" USING WS-KEY WS-O
     MOVE 2 TO WS-E
     MOVE "acceptance US15 19§22.1 every other biome gives plains" TO WS-NAME
     PERFORM CHECK-N
     MOVE "bread" TO WS-KEY24
     CALL "VIL-FOOD" USING WS-KEY24 WS-O
     MOVE 4 TO WS-E
     MOVE "acceptance US15 19§22.6 bread feeds 4" TO WS-NAME
     PERFORM CHECK-N
     MOVE "potato" TO WS-KEY24
     CALL "VIL-FOOD" USING WS-KEY24 WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.6 a potato feeds 1" TO WS-NAME
     PERFORM CHECK-N
     MOVE "stone" TO WS-KEY24
     CALL "VIL-FOOD" USING WS-KEY24 WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.6 stone is no food" TO WS-NAME
     PERFORM CHECK-N
     CALL "VIL-CAN-BREED" USING WS-F8 WS-F4 WS-F0 WS-F0B WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.6 food 8 + 4 and an adult awake can breed" TO WS-NAME
     PERFORM CHECK-N
     CALL "VIL-CAN-BREED" USING WS-F8 WS-F3 WS-F0 WS-F0B WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.6 11 food points are too few" TO WS-NAME
     PERFORM CHECK-N
     MOVE 600 TO WS-A
     CALL "VIL-OFFSPRING" USING WS-A WS-F3 WS-F4 WS-F5 WS-O
     MOVE 4 TO WS-E
     MOVE "acceptance US15 19§22.6 a roll of 0.6 takes this parent's type" TO WS-NAME
     PERFORM CHECK-N
     MOVE 100 TO WS-A
     CALL "VIL-OFFSPRING" USING WS-A WS-F3 WS-F4 WS-F5 WS-O
     MOVE 3 TO WS-E
     MOVE "acceptance US15 19§22.6 a roll of 0.1 takes the biome type" TO WS-NAME
     PERFORM CHECK-N
     MOVE 900 TO WS-A
     CALL "VIL-OFFSPRING" USING WS-A WS-F3 WS-F4 WS-F5 WS-O
     MOVE 5 TO WS-E
     MOVE "acceptance US15 19§22.6 a roll of 0.9 takes the other parent's type" TO WS-NAME
     PERFORM CHECK-N
     MOVE "toolsmith" TO WS-PROF
     MOVE "smithing_table" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "leatherworker" TO WS-PROF
     MOVE "lava_cauldron" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "armorer" TO WS-PROF
     MOVE "blast_furnace" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "butcher" TO WS-PROF
     MOVE "smoker" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "cartographer" TO WS-PROF
     MOVE "cartography_table" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "cleric" TO WS-PROF
     MOVE "brewing_stand" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "farmer" TO WS-PROF
     MOVE "composter" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "fisherman" TO WS-PROF
     MOVE "barrel" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "fletcher" TO WS-PROF
     MOVE "fletching_table" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "librarian" TO WS-PROF
     MOVE "lectern" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "mason" TO WS-PROF
     MOVE "stonecutter" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "shepherd" TO WS-PROF
     MOVE "loom" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "weaponsmith" TO WS-PROF
     MOVE "grindstone" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "leatherworker" TO WS-PROF
     MOVE "water_cauldron" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "leatherworker" TO WS-PROF
     MOVE "cauldron" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "leatherworker" TO WS-PROF
     MOVE "powder_snow_cauldron" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE "none" TO WS-PROF
     MOVE "stone" TO WS-KEY
     PERFORM CHECK-PROF
     MOVE 30000 TO WS-A
     MOVE 10000 TO WS-B
     MOVE 0 TO WS-C
     CALL "VIL-GOLEM-WANTS" USING WS-A WS-B WS-C WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.10 a villager that slept in the last day wants a golem" TO WS-NAME
     PERFORM CHECK-N
     MOVE 40000 TO WS-A
     CALL "VIL-GOLEM-WANTS" USING WS-A WS-B WS-C WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.10 not after 24000 ticks" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-C
     MOVE 30000 TO WS-A
     CALL "VIL-GOLEM-WANTS" USING WS-A WS-B WS-C WS-O
     MOVE "acceptance US15 19§22.10 not with a golem detected" TO WS-NAME
     PERFORM CHECK-N
     COMPUTE WS-B = -1
     MOVE 0 TO WS-C
     CALL "VIL-GOLEM-WANTS" USING WS-A WS-B WS-C WS-O
     MOVE "acceptance US15 19§22.10 not without having slept" TO WS-NAME
     PERFORM CHECK-N
     MOVE 25 TO WS-A
     CALL "VIL-WANDER-CHANCE" USING WS-A WS-O
     MOVE 50 TO WS-E
     MOVE "acceptance US15 19§23 spawn chance 25 becomes 50" TO WS-NAME
     PERFORM CHECK-N
     MOVE 75 TO WS-A
     CALL "VIL-WANDER-CHANCE" USING WS-A WS-O
     MOVE 75 TO WS-E
     MOVE "acceptance US15 19§23 spawn chance is capped at 75" TO WS-NAME
     PERFORM CHECK-N
     COMPUTE WS-A = -40
     CALL "VIL-WANDER-CHANCE" USING WS-A WS-O
     MOVE 25 TO WS-E
     MOVE "acceptance US15 19§23 spawn chance is at least 25" TO WS-NAME
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-ACT-4.
     MOVE 4 TO WS-E
     PERFORM CHECK-ACT.

 CHECK-ACT.
     CALL "VIL-ACTIVITY" USING WS-A WS-B WS-O
     MOVE SPACES TO WS-NAME
     MOVE WS-A TO WS-D1
     MOVE WS-B TO WS-D2
     MOVE WS-E TO WS-D3
     STRING "acceptance US15 19§22.3 tick " WS-D1 " baby " WS-D2 " activity " WS-D3 DELIMITED BY SIZE INTO WS-NAME
     PERFORM CHECK-N.

 CHECK-PROF.
     MOVE SPACES TO WS-NAME
     CALL "VIL-PROFESSION" USING WS-KEY WS-PROFOUT
     STRING "acceptance US15 19§22.2 workstation " WS-KEY DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-PROF TO TL-EXPECTED
     MOVE WS-PROFOUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-22.
