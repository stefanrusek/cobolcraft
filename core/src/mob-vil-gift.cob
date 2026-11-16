*> The gifts of villagers to a Hero of the Village (docs/protocol/19 section 22.9; lane 002-lane-mobsb3, T8104). Gaps: the fletcher's tipped arrows (weight 1 each, 13 potion types of
*> 26 + 13 weight, count uniform 0 to 1) are not given because tipped arrows carry no potion contents here: the fletcher gives arrows only; the villager does not walk to the hero (the
*> hero must come within 5 blocks of it), "visible" is within 16 blocks in the same dimension.
*>
*>   VIL-GIFT-COUNT USING profession (X(16)), baby (0/1), count out        the entries of the gift table
*>   VIL-GIFT-KEY USING profession, baby, index (0 based), item key out    the item key of an entry (spaces past the end)
*>   VL-GIFT-TICK USING entity row                                         one evaluation of GiveGiftToHero (VL-STEP)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GIFT-TABLE.
*> USING profession, baby, index (0 based, -1 for none), key out, count out: the size of the table of the profession (the unemployed table for a profession without one) and the key at the index.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER PIC X(16) VALUE "armorer".
    05 FILLER PIC X(32) VALUE "chainmail_helmet".
    05 FILLER PIC X(16) VALUE "armorer".
    05 FILLER PIC X(32) VALUE "chainmail_chestplate".
    05 FILLER PIC X(16) VALUE "armorer".
    05 FILLER PIC X(32) VALUE "chainmail_leggings".
    05 FILLER PIC X(16) VALUE "armorer".
    05 FILLER PIC X(32) VALUE "chainmail_boots".
    05 FILLER PIC X(16) VALUE "baby".
    05 FILLER PIC X(32) VALUE "poppy".
    05 FILLER PIC X(16) VALUE "butcher".
    05 FILLER PIC X(32) VALUE "cooked_rabbit".
    05 FILLER PIC X(16) VALUE "butcher".
    05 FILLER PIC X(32) VALUE "cooked_chicken".
    05 FILLER PIC X(16) VALUE "butcher".
    05 FILLER PIC X(32) VALUE "cooked_porkchop".
    05 FILLER PIC X(16) VALUE "butcher".
    05 FILLER PIC X(32) VALUE "cooked_beef".
    05 FILLER PIC X(16) VALUE "butcher".
    05 FILLER PIC X(32) VALUE "cooked_mutton".
    05 FILLER PIC X(16) VALUE "cartographer".
    05 FILLER PIC X(32) VALUE "map".
    05 FILLER PIC X(16) VALUE "cartographer".
    05 FILLER PIC X(32) VALUE "paper".
    05 FILLER PIC X(16) VALUE "cleric".
    05 FILLER PIC X(32) VALUE "redstone".
    05 FILLER PIC X(16) VALUE "cleric".
    05 FILLER PIC X(32) VALUE "lapis_lazuli".
    05 FILLER PIC X(16) VALUE "farmer".
    05 FILLER PIC X(32) VALUE "bread".
    05 FILLER PIC X(16) VALUE "farmer".
    05 FILLER PIC X(32) VALUE "pumpkin_pie".
    05 FILLER PIC X(16) VALUE "farmer".
    05 FILLER PIC X(32) VALUE "cookie".
    05 FILLER PIC X(16) VALUE "fisherman".
    05 FILLER PIC X(32) VALUE "cod".
    05 FILLER PIC X(16) VALUE "fisherman".
    05 FILLER PIC X(32) VALUE "salmon".
    05 FILLER PIC X(16) VALUE "fletcher".
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC X(16) VALUE "leatherworker".
    05 FILLER PIC X(32) VALUE "leather".
    05 FILLER PIC X(16) VALUE "librarian".
    05 FILLER PIC X(32) VALUE "book".
    05 FILLER PIC X(16) VALUE "mason".
    05 FILLER PIC X(32) VALUE "clay_ball".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "white_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "orange_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "magenta_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "light_blue_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "yellow_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "lime_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "pink_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "gray_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "light_gray_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "cyan_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "purple_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "blue_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "brown_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "green_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "red_wool".
    05 FILLER PIC X(16) VALUE "shepherd".
    05 FILLER PIC X(32) VALUE "black_wool".
    05 FILLER PIC X(16) VALUE "toolsmith".
    05 FILLER PIC X(32) VALUE "stone_pickaxe".
    05 FILLER PIC X(16) VALUE "toolsmith".
    05 FILLER PIC X(32) VALUE "stone_axe".
    05 FILLER PIC X(16) VALUE "toolsmith".
    05 FILLER PIC X(32) VALUE "stone_hoe".
    05 FILLER PIC X(16) VALUE "toolsmith".
    05 FILLER PIC X(32) VALUE "stone_shovel".
    05 FILLER PIC X(16) VALUE "unemployed".
    05 FILLER PIC X(32) VALUE "wheat_seeds".
    05 FILLER PIC X(16) VALUE "weaponsmith".
    05 FILLER PIC X(32) VALUE "stone_axe".
    05 FILLER PIC X(16) VALUE "weaponsmith".
    05 FILLER PIC X(32) VALUE "golden_axe".
    05 FILLER PIC X(16) VALUE "weaponsmith".
    05 FILLER PIC X(32) VALUE "iron_axe".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-ROWS OCCURS 47 TIMES.
       10 WS-PROF             PIC X(16).
       10 WS-KEY              PIC X(32).
 01 WS-I                    BINARY-LONG.
 01 WS-WANT                 PIC X(16).
 01 WS-FIRST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-BABY                  BINARY-LONG.
 01 L-INDEX                 BINARY-LONG.
 01 L-KEY                   PIC X(32).
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PROF L-BABY L-INDEX L-KEY L-COUNT.
     MOVE SPACES TO L-KEY
     MOVE L-PROF TO WS-WANT
     IF L-BABY = 1
         MOVE "baby" TO WS-WANT
     END-IF
     PERFORM FIND-ROWS
     IF L-COUNT = 0
         MOVE "unemployed" TO WS-WANT
         PERFORM FIND-ROWS
     END-IF
     IF L-INDEX >= 0 AND L-INDEX < L-COUNT
         COMPUTE WS-I = WS-FIRST + L-INDEX
         MOVE WS-KEY(WS-I) TO L-KEY
     END-IF
     GOBACK.

 FIND-ROWS.
     MOVE 0 TO WS-FIRST L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 47
         IF WS-PROF(WS-I) = WS-WANT
             IF L-COUNT = 0
                 MOVE WS-I TO WS-FIRST
             END-IF
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM VIL-GIFT-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GIFT-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                 BINARY-LONG VALUE -1.
 01 WS-KEY                  PIC X(32).
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-BABY                  BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PROF L-BABY L-COUNT.
     CALL "VIL-GIFT-TABLE" USING L-PROF L-BABY WS-NONE WS-KEY L-COUNT
     GOBACK.
 END PROGRAM VIL-GIFT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-GIFT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-BABY                  BINARY-LONG.
 01 L-INDEX                 BINARY-LONG.
 01 L-KEY                   PIC X(32).
 PROCEDURE DIVISION USING L-PROF L-BABY L-INDEX L-KEY.
     CALL "VIL-GIFT-TABLE" USING L-PROF L-BABY L-INDEX L-KEY WS-COUNT
     GOBACK.
 END PROGRAM VIL-GIFT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GIFT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-HERO-ID              BINARY-LONG VALUE 31.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-TICKS                BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-BEST                 BINARY-LONG.
 01 WS-BEST-D2              FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-BABY                 BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-IDX                  BINARY-LONG.
 01 WS-SALT-PICK            BINARY-LONG VALUE 151.
 01 WS-SALT-CD              BINARY-LONG VALUE 152.
 01 WS-SPAN                 BINARY-LONG VALUE 6001.
 01 WS-R                    BINARY-LONG.
 01 WS-ITEM                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-DELAY                BINARY-LONG VALUE 10.
 01 WS-DROP                 BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-VX                   FLOAT-LONG.
 01 WS-VY                   FLOAT-LONG.
 01 WS-VZ                   FLOAT-LONG.
 01 WS-LEN                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR VL-KIND(WS-SLOT) NOT = 1
         GOBACK
     END-IF
*>   The nearest hero within 16 blocks of the same dimension is the visible one.
     MOVE 0 TO WS-BEST
     MOVE 256 TO WS-BEST-D2
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= WS-BEST-D2
                 CALL "EFFECT-LEVEL" USING WS-P WS-HERO-ID WS-LEVEL WS-TICKS
                 IF WS-LEVEL > 0
                     MOVE WS-P TO WS-BEST
                     MOVE WS-D2 TO WS-BEST-D2
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST = 0
         MOVE 0 TO VL-GIFT-ACT(WS-SLOT)
         GOBACK
     END-IF
*>   VL-GIFT-CD holds the cooldown + 1 so that 0 means "never started".
     IF VL-GIFT-CD(WS-SLOT) = 0
         MOVE 601 TO VL-GIFT-CD(WS-SLOT)
     END-IF
     IF VL-GIFT-ACT(WS-SLOT) = 0
         IF VL-GIFT-CD(WS-SLOT) > 1
             SUBTRACT 1 FROM VL-GIFT-CD(WS-SLOT)
             GOBACK
         END-IF
         MOVE 1 TO VL-GIFT-ACT(WS-SLOT)
         MOVE 0 TO VL-GIFT-AGE(WS-SLOT)
     END-IF
     MOVE WS-BEST TO VL-GIFT-PL(WS-SLOT)
     ADD 1 TO VL-GIFT-AGE(WS-SLOT)
     IF VL-GIFT-AGE(WS-SLOT) >= 20 AND WS-BEST-D2 <= 25
         MOVE 0 TO WS-BABY
         IF EN-MOBAGE(L-ROW) < 0
             MOVE 1 TO WS-BABY
         END-IF
         CALL "VIL-GIFT-COUNT" USING VL-PROF(WS-SLOT) WS-BABY WS-N
         CALL "XP-RANDOM" USING WS-SALT-PICK WS-N WS-IDX
         CALL "VIL-GIFT-KEY" USING VL-PROF(WS-SLOT) WS-BABY WS-IDX WS-KEY
         CALL "MERCHANT-ITEM-ID" USING WS-KEY WS-ITEM
         IF WS-ITEM >= 0
             COMPUTE WS-DX = PL-X(WS-BEST) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-BEST) + 1 - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-BEST) - EN-Z(L-ROW)
             COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
             MOVE 0 TO WS-VX WS-VY WS-VZ
             IF WS-LEN >= 0.0001
                 COMPUTE WS-VX = 0.3 * WS-DX / WS-LEN
                 COMPUTE WS-VY = 0.3 * WS-DY / WS-LEN
                 COMPUTE WS-VZ = 0.3 * WS-DZ / WS-LEN
             END-IF
             MOVE EN-X(L-ROW) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ROW) + 1.49
             MOVE EN-Z(L-ROW) TO WS-Z
             CALL "GI-SPAWN-X" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-DELAY WS-DROP WS-ZERO
         END-IF
         CALL "XP-RANDOM" USING WS-SALT-CD WS-SPAN WS-R
         COMPUTE VL-GIFT-CD(WS-SLOT) = 601 + WS-R
         MOVE 0 TO VL-GIFT-ACT(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM VL-GIFT-TICK.
