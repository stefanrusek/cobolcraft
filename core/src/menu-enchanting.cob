*> The enchanting table menu (docs/protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md section 2, 17 section 6.5; US12 phase 44, T1041,
*> T1042, T1139, T1140). Programs of plain numbers (ENCH- prefix): the slots, the data slot layout, the option costs drawn from the menu's random (the java.util.Random
*> LCG of JRAND-, rng-java.cob, kept as a BINARY-DOUBLE UNSIGNED state), the offer list rules that follow the selection (a book loses one entry, one clue is
*> picked), the button and the payment, quick-move, the screen rows with their colours and tooltip lines, the galactic names and the book animation.
*> selectEnchantment itself (the weighted pick over the enchantment registry, 17 6.5 "Selection") is not here: the caller supplies the size of its list.
*> The live window of a player (menus.cob) is not changed by this file. Flags are 0 or 1; floats are FLOAT-LONG, scaled results are x 1e6.
*>
*>   ENCH-STATE-SEED USING seed (an int), state out: setSeed(seed), the seed widened to a long
*>   ENCH-SKIP USING state: one nextInt(50) draw; ENCH-LIST-SEED USING seed, slot, list seed out (the int sum, wrapped)
*>   ENCH-COSTS USING seed, shelves, enchantable, cost 0, cost 1, cost 2 out                                                             2.4 steps 3, 4
*>   ENCH-LIST-POST USING state, is a book, list size, removed index out (-1); ENCH-CLUE-DRAW USING state, list size, clue index out (-1)  2.4 step 5, 2.5 step 3
*>   ENCH-SLOT, ENCH-MAYPLACE, ENCH-ENCHANTABLE, ENCH-OFFSET, ENCH-POWER-ADD, ENCH-PROP                                                   2.2, 2.3, 2.4
*>   ENCH-BUTTON, ENCH-EFFECT, ENCH-QUICK                                                                                                 2.6, 2.7
*>   ENCH-SCREEN-ROW, ENCH-CLICK, ENCH-ROW-STATE, ENCH-NAME-WIDTH, ENCH-TIP, ENCH-FULLNAME, ENCH-NAME-DRAW, ENCH-WORD                     2.9
*>   ENCH-BOOK-STEP, ENCH-BOOK-FLIPT, ENCH-BOOK-DRAW, ENCH-BOOK-ANIM, ENCH-BOOK-PART                                                     2.10

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-STATE-SEED.
*> USING seed (an int), random state out (BINARY-DOUBLE UNSIGNED): setSeed(seed) with the seed widened to a long.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX BINARY-DOUBLE UNSIGNED VALUE 18446744073709551615.
 01 WS-U BINARY-DOUBLE UNSIGNED.
 01 WS-T BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-LONG.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-SEED L-ST.
    IF L-SEED < 0
        COMPUTE WS-T = 0 - L-SEED - 1
        COMPUTE WS-U = WS-MAX - WS-T
    ELSE
        MOVE L-SEED TO WS-U
    END-IF
    CALL "JRAND-SET-SEED" USING L-ST WS-U
    GOBACK.
 END PROGRAM ENCH-STATE-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SKIP.
*> USING random state: one nextInt(50) draw (the continuation test of the selection).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B BINARY-LONG VALUE 50.
 01 WS-R BINARY-LONG.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-ST.
    CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-B WS-R
    GOBACK.
 END PROGRAM ENCH-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-LIST-SEED.
*> USING enchantment seed, slot index, list seed out (2.5 step 1): the int sum, wrapped to the int range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-DOUBLE.
 01 WS-M BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-SLOT L-OUT.
    COMPUTE WS-T = L-SEED + L-SLOT
    COMPUTE WS-M = FUNCTION MOD(WS-T, 4294967296)
    IF WS-M >= 2147483648
        SUBTRACT 4294967296 FROM WS-M
    END-IF
    MOVE WS-M TO L-OUT
    GOBACK.
 END PROGRAM ENCH-LIST-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-COSTS.
*> USING seed, bookshelf count, item has the enchantable component, cost 0 out, cost 1 out, cost 2 out (2.4 steps 3, 4): base = nextInt(8) + 1 + (b >> 1) + nextInt(b + 1) per option; max(base / 3, 1), base x 2 / 3 + 1, max(base, 2 b); below i + 1 is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ST BINARY-DOUBLE UNSIGNED.
 01 WS-EIGHT BINARY-LONG VALUE 8.
 01 WS-B BINARY-LONG.
 01 WS-HALF BINARY-LONG.
 01 WS-BP BINARY-LONG.
 01 WS-I BINARY-LONG.
 01 WS-D1 BINARY-LONG.
 01 WS-D2 BINARY-LONG.
 01 WS-BASE BINARY-LONG.
 01 WS-V BINARY-LONG.
 01 WS-COS.
    05 WS-CO BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-C0                   BINARY-LONG.
 01 L-C1                   BINARY-LONG.
 01 L-C2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-B L-N L-C0 L-C1 L-C2.
    MOVE 0 TO L-C0 L-C1 L-C2
    IF L-N NOT = 0
        CALL "ENCH-STATE-SEED" USING L-SEED WS-ST
        COMPUTE WS-B = FUNCTION MIN(L-B, 15)
        COMPUTE WS-HALF = WS-B / 2
        COMPUTE WS-BP = WS-B + 1
        PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
            CALL "JRAND-NEXT-INT-BOUND" USING WS-ST WS-EIGHT WS-D1
            CALL "JRAND-NEXT-INT-BOUND" USING WS-ST WS-BP WS-D2
            COMPUTE WS-BASE = WS-D1 + 1 + WS-HALF + WS-D2
            EVALUATE WS-I
                WHEN 0
                    COMPUTE WS-V = FUNCTION MAX(WS-BASE / 3, 1)
                WHEN 1
                    COMPUTE WS-V = WS-BASE * 2 / 3 + 1
                WHEN 2
                    COMPUTE WS-V = FUNCTION MAX(WS-BASE, WS-B * 2)
            END-EVALUATE
            IF WS-V < WS-I + 1
                MOVE 0 TO WS-V
            END-IF
            MOVE WS-V TO WS-CO(WS-I + 1)
        END-PERFORM
        MOVE WS-CO(1) TO L-C0
        MOVE WS-CO(2) TO L-C1
        MOVE WS-CO(3) TO L-C2
    END-IF
    GOBACK.
 END PROGRAM ENCH-COSTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-LIST-POST.
*> USING random state, the item is a book, list size, removed index out (-1 for none) (2.5 step 3): a book with more than one entry loses the entry at nextInt(size).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-BOOK                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ST L-BOOK L-SIZE L-IDX.
    MOVE -1 TO L-IDX
    IF L-BOOK = 1 AND L-SIZE > 1
        CALL "JRAND-NEXT-INT-BOUND" USING L-ST L-SIZE L-IDX
    END-IF
    GOBACK.
 END PROGRAM ENCH-LIST-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-CLUE-DRAW.
*> USING random state, list size, clue index out (-1 for an empty list) (2.4 step 5): list[nextInt(size)].
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-SIZE                 BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ST L-SIZE L-IDX.
    MOVE -1 TO L-IDX
    IF L-SIZE > 0
        CALL "JRAND-NEXT-INT-BOUND" USING L-ST L-SIZE L-IDX
    END-IF
    GOBACK.
 END PROGRAM ENCH-CLUE-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SLOT.
*> USING menu slot, part out (0 none, 1 own, 2 player), x out, y out, stack cap out (1 for slot 0), lapis slot out (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-CAP                  BINARY-LONG.
 01 L-LAPIS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y L-CAP L-LAPIS.
    MOVE 0 TO L-PART L-X L-Y L-CAP L-LAPIS
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 1 TO L-PART L-CAP
            MOVE 15 TO L-X
            MOVE 47 TO L-Y
        WHEN L-SLOT = 1
            MOVE 1 TO L-PART L-LAPIS
            MOVE 35 TO L-X
            MOVE 47 TO L-Y
        WHEN L-SLOT >= 2 AND L-SLOT <= 37
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 2
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM ENCH-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-MAYPLACE.
*> USING slot, the item is lapis lazuli, ok out (2.2): slot 0 takes any item, slot 1 only lapis lazuli.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-LAPIS                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-LAPIS L-OK.
    MOVE 1 TO L-OK
    IF L-SLOT = 1
        MOVE L-LAPIS TO L-OK
    END-IF
    GOBACK.
 END PROGRAM ENCH-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-ENCHANTABLE.
*> USING has the enchantable component, the enchantments component is present, it is empty, ok out (2.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COMP                 BINARY-LONG.
 01 L-PRES                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-COMP L-PRES L-EMPTY L-OK.
    MOVE 0 TO L-OK
    IF L-COMP = 1 AND L-PRES = 1 AND L-EMPTY = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM ENCH-ENCHANTABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-OFFSET.
*> USING offset index 1 to 32, dx out, dy out, dz out, transmitter x out, y out, z out (2.4 step 2, 17 6.5): the outer ring at dy 0 and 1; the transmitter is at (dx / 2, dy, dz / 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N BINARY-LONG.
 01 WS-M BINARY-LONG.
 01 WS-K BINARY-LONG.
 01 WS-Q BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-DX L-DY L-DZ L-TX L-TY L-TZ.
    COMPUTE WS-N = L-I - 1
    COMPUTE L-DY = WS-N / 16
    COMPUTE WS-M = FUNCTION MOD(WS-N, 16)
    EVALUATE TRUE
        WHEN WS-M <= 4
            MOVE -2 TO L-DX
            COMPUTE L-DZ = WS-M - 2
        WHEN WS-M <= 10
            COMPUTE WS-K = WS-M - 5
            COMPUTE WS-Q = WS-K / 2
            COMPUTE L-DX = WS-Q - 1
            MOVE 2 TO L-DZ
            IF FUNCTION MOD(WS-K, 2) = 0
                MOVE -2 TO L-DZ
            END-IF
        WHEN OTHER
            MOVE 2 TO L-DX
            COMPUTE L-DZ = WS-M - 13
    END-EVALUATE
    COMPUTE L-TX = L-DX / 2
    MOVE L-DY TO L-TY
    COMPUTE L-TZ = L-DZ / 2
    GOBACK.
 END PROGRAM ENCH-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-POWER-ADD.
*> USING power so far, provider block ok, transmitter block ok, power out (2.4 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PREV                 BINARY-LONG.
 01 L-PROV                 BINARY-LONG.
 01 L-TRANS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PREV L-PROV L-TRANS L-OUT.
    MOVE L-PREV TO L-OUT
    IF L-PROV = 1 AND L-TRANS = 1
        ADD 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM ENCH-POWER-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-PROP.
*> USING data property 0 to 9, group out (1 cost, 2 seed, 3 clue enchantment, 4 clue level), index in the group out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-GROUP                BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-GROUP L-IX.
    EVALUATE TRUE
        WHEN L-P < 3
            MOVE 1 TO L-GROUP
            MOVE L-P TO L-IX
        WHEN L-P = 3
            MOVE 2 TO L-GROUP
            MOVE 0 TO L-IX
        WHEN L-P < 7
            MOVE 3 TO L-GROUP
            COMPUTE L-IX = L-P - 4
        WHEN OTHER
            MOVE 4 TO L-GROUP
            COMPUTE L-IX = L-P - 7
    END-EVALUATE
    GOBACK.
 END PROGRAM ENCH-PROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BUTTON.
*> USING button id, lapis count, player level, infinite materials, cost of the option, item slot empty, valid out, lapis needed out (2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-LAP                  BINARY-LONG.
 01 L-LV                   BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-IE                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-NEED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-LAP L-LV L-INF L-COST L-IE L-VALID L-NEED.
    MOVE 0 TO L-VALID L-NEED
    IF L-ID >= 0 AND L-ID < 3
        COMPUTE L-NEED = L-ID + 1
        IF NOT (L-LAP < L-NEED AND L-INF = 0)
            IF L-COST > 0 AND L-IE = 0 AND ((L-LV >= L-NEED AND L-LV >= L-COST) OR L-INF = 1)
                MOVE 1 TO L-VALID
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM ENCH-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-EFFECT.
*> USING player level, need (id + 1), infinite materials, lapis count, the offer list is empty, the item is a book, performed out, new level out, new lapis out, book becomes an enchanted book out, seed renewed out, lapis slot emptied out (2.6 effect).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LV                   BINARY-LONG.
 01 L-NEED                 BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-LAP                  BINARY-LONG.
 01 L-LE                   BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-NLV                  BINARY-LONG.
 01 L-NLAP                 BINARY-LONG.
 01 L-TRANS                BINARY-LONG.
 01 L-RENEW                BINARY-LONG.
 01 L-EMPTIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-LV L-NEED L-INF L-LAP L-LE L-BOOK L-DONE L-NLV L-NLAP L-TRANS L-RENEW L-EMPTIED.
    MOVE 0 TO L-DONE L-TRANS L-RENEW L-EMPTIED
    MOVE L-LV TO L-NLV
    MOVE L-LAP TO L-NLAP
    IF L-LE = 0
        MOVE 1 TO L-DONE L-RENEW
        COMPUTE L-NLV = FUNCTION MAX(L-LV - L-NEED, 0)
        IF L-INF = 0
            COMPUTE L-NLAP = FUNCTION MAX(L-LAP - L-NEED, 0)
        END-IF
        MOVE L-BOOK TO L-TRANS
        IF L-NLAP = 0
            MOVE 1 TO L-EMPTIED
        END-IF
    END-IF
    GOBACK.
 END PROGRAM ENCH-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-QUICK.
*> USING source slot, the stack is lapis lazuli, slot 0 is empty, rule out (0 none, 1 item or lapis slot, 2 lapis into the lapis slot, 3 one copy into slot 0), first out, end out, reverse out, single copy out (2.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-LAPIS                BINARY-LONG.
 01 L-E0                   BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-SINGLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-LAPIS L-E0 L-RULE L-FIRST L-END L-REV L-SINGLE.
    MOVE 0 TO L-RULE L-FIRST L-END L-REV L-SINGLE
    EVALUATE TRUE
        WHEN L-SLOT = 0 OR L-SLOT = 1
            MOVE 1 TO L-RULE L-REV
            MOVE 2 TO L-FIRST
            MOVE 38 TO L-END
        WHEN L-SLOT >= 2 AND L-SLOT <= 37 AND L-LAPIS = 1
            MOVE 2 TO L-RULE
            MOVE 1 TO L-FIRST L-REV
            MOVE 2 TO L-END
        WHEN L-SLOT >= 2 AND L-SLOT <= 37 AND L-E0 = 1
            MOVE 3 TO L-RULE
            MOVE 1 TO L-END L-SINGLE
    END-EVALUATE
    GOBACK.
 END PROGRAM ENCH-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SCREEN-ROW.
*> USING row i, leftPos, topPos, row x out, row y out, width out, height out, icon x out, icon y out, text x out, text y out, cost right x out, cost y out (2.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-LEFT L-TOP L-RX L-RY L-W L-H L-IX L-IY L-TX L-TY L-CX L-CY.
    COMPUTE L-RX = L-LEFT + 60
    COMPUTE L-RY = L-TOP + 14 + 19 * L-I
    MOVE 108 TO L-W
    MOVE 19 TO L-H
    COMPUTE L-IX = L-LEFT + 61
    COMPUTE L-IY = L-TOP + 15 + 19 * L-I
    COMPUTE L-TX = L-LEFT + 80
    COMPUTE L-TY = L-TOP + 16 + 19 * L-I
    COMPUTE L-CX = L-LEFT + 166
    COMPUTE L-CY = L-TOP + 23 + 19 * L-I
    GOBACK.
 END PROGRAM ENCH-SCREEN-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-CLICK.
*> USING row i, mouse x, mouse y, leftPos, topPos, click out (108 x 19), tooltip out (108 x 17) (2.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RX BINARY-LONG.
 01 WS-RY BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-MY                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-CLICK                BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-MX L-MY L-LEFT L-TOP L-CLICK L-TIP.
    COMPUTE WS-RX = L-MX - (L-LEFT + 60)
    COMPUTE WS-RY = L-MY - (L-TOP + 14 + 19 * L-I)
    MOVE 0 TO L-CLICK L-TIP
    IF WS-RX >= 0 AND WS-RX < 108 AND WS-RY >= 0
        IF WS-RY < 19
            MOVE 1 TO L-CLICK
        END-IF
        IF WS-RY < 17
            MOVE 1 TO L-TIP
        END-IF
    END-IF
    GOBACK.
 END PROGRAM ENCH-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-ROW-STATE.
*> USING cost, lapis count, player level, infinite materials, row i, pointer inside, state out (0 cost 0, 1 disabled, 2 enabled, 3 highlighted), name colour out, cost colour out, name x out, name y out, cost y out (2.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEED BINARY-LONG.
 LINKAGE SECTION.
 01 L-COST                 BINARY-LONG.
 01 L-GOLD                 BINARY-LONG.
 01 L-LV                   BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-HOV                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-NAMEC                BINARY-LONG.
 01 L-NUMC                 BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-COST L-GOLD L-LV L-INF L-I L-HOV L-STATE L-NAMEC L-NUMC L-NX L-NY L-CY.
    MOVE 0 TO L-STATE L-NAMEC L-NUMC
    MOVE 80 TO L-NX
    COMPUTE L-NY = 16 + 19 * L-I
    COMPUTE L-CY = 23 + 19 * L-I
    IF L-COST NOT = 0
        COMPUTE WS-NEED = L-I + 1
        IF (L-GOLD >= WS-NEED AND L-LV >= L-COST) OR L-INF = 1
            MOVE 2 TO L-STATE
            MOVE -9937334 TO L-NAMEC
            MOVE -8323296 TO L-NUMC
            IF L-HOV = 1
                MOVE 3 TO L-STATE
                MOVE -128 TO L-NAMEC
            END-IF
        ELSE
            MOVE 1 TO L-STATE
            MOVE -13357275 TO L-NAMEC
            MOVE -12550384 TO L-NUMC
        END-IF
    END-IF
    GOBACK.
 END PROGRAM ENCH-ROW-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-NAME-WIDTH.
*> USING width of the cost string, name width out (2.9): 86 - width.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-OUT.
    COMPUTE L-OUT = 86 - L-W
    GOBACK.
 END PROGRAM ENCH-NAME-WIDTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-TIP.
*> USING cost, clue level, the clue id is valid, pointer in the 17-high rectangle, infinite materials, player level, lapis count, row i, shown out, lines out (0 none, 1 level requirement, 2 lapis and level), lapis line gray out (2.9 tooltip).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEED BINARY-LONG.
 LINKAGE SECTION.
 01 L-COST                 BINARY-LONG.
 01 L-LC                   BINARY-LONG.
 01 L-CV                   BINARY-LONG.
 01 L-INR                  BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-LV                   BINARY-LONG.
 01 L-GOLD                 BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 01 L-LINES                BINARY-LONG.
 01 L-GRAY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COST L-LC L-CV L-INR L-INF L-LV L-GOLD L-I L-SHOW L-LINES L-GRAY.
    MOVE 0 TO L-SHOW L-LINES L-GRAY
    IF L-INR = 1 AND L-COST > 0 AND L-LC >= 0 AND L-CV = 1
        MOVE 1 TO L-SHOW
        IF L-INF = 0
            MOVE 2 TO L-LINES
            IF L-LV < L-COST
                MOVE 1 TO L-LINES
            END-IF
        END-IF
        COMPUTE WS-NEED = L-I + 1
        IF L-LINES = 2 AND L-GOLD >= WS-NEED
            MOVE 1 TO L-GRAY
        END-IF
    END-IF
    GOBACK.
 END PROGRAM ENCH-TIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-FULLNAME.
*> USING is a curse, level, max level, red out (curse) or gray, level suffix shown out (2.9 getFullname).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CURSE                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-RED                  BINARY-LONG.
 01 L-SUFFIX               BINARY-LONG.
 PROCEDURE DIVISION USING L-CURSE L-LEVEL L-MAX L-RED L-SUFFIX.
    MOVE L-CURSE TO L-RED
    MOVE 1 TO L-SUFFIX
    IF L-LEVEL = 1 AND L-MAX = 1
        MOVE 0 TO L-SUFFIX
    END-IF
    GOBACK.
 END PROGRAM ENCH-FULLNAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-NAME-DRAW.
*> USING random state, word count out (3 or 4), word index 1 to 4 out (0 beyond the count) (2.9 galactic name): n = nextInt(2) + 3, each word nextInt(62).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TWO BINARY-LONG VALUE 2.
 01 WS-WORDS-N BINARY-LONG VALUE 62.
 01 WS-X BINARY-LONG.
 01 WS-K BINARY-LONG.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-N                    BINARY-LONG.
 01 L-W1                   BINARY-LONG.
 01 L-W2                   BINARY-LONG.
 01 L-W3                   BINARY-LONG.
 01 L-W4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ST L-N L-W1 L-W2 L-W3 L-W4.
    MOVE 0 TO L-W1 L-W2 L-W3 L-W4
    CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-TWO WS-X
    COMPUTE L-N = WS-X + 3
    PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-N
        CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-WORDS-N WS-X
        EVALUATE WS-K
            WHEN 1
                MOVE WS-X TO L-W1
            WHEN 2
                MOVE WS-X TO L-W2
            WHEN 3
                MOVE WS-X TO L-W3
            WHEN 4
                MOVE WS-X TO L-W4
        END-EVALUATE
    END-PERFORM
    GOBACK.
 END PROGRAM ENCH-NAME-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-WORD.
*> USING word index 0 to 61, word out, the same word out (2.9): the 62 words of the galactic alphabet list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WORDS.
    05 FILLER PIC X(10) VALUE "the       ".
    05 FILLER PIC X(10) VALUE "elder     ".
    05 FILLER PIC X(10) VALUE "scrolls   ".
    05 FILLER PIC X(10) VALUE "klaatu    ".
    05 FILLER PIC X(10) VALUE "berata    ".
    05 FILLER PIC X(10) VALUE "niktu     ".
    05 FILLER PIC X(10) VALUE "xyzzy     ".
    05 FILLER PIC X(10) VALUE "bless     ".
    05 FILLER PIC X(10) VALUE "curse     ".
    05 FILLER PIC X(10) VALUE "light     ".
    05 FILLER PIC X(10) VALUE "darkness  ".
    05 FILLER PIC X(10) VALUE "fire      ".
    05 FILLER PIC X(10) VALUE "air       ".
    05 FILLER PIC X(10) VALUE "earth     ".
    05 FILLER PIC X(10) VALUE "water     ".
    05 FILLER PIC X(10) VALUE "hot       ".
    05 FILLER PIC X(10) VALUE "dry       ".
    05 FILLER PIC X(10) VALUE "cold      ".
    05 FILLER PIC X(10) VALUE "wet       ".
    05 FILLER PIC X(10) VALUE "ignite    ".
    05 FILLER PIC X(10) VALUE "snuff     ".
    05 FILLER PIC X(10) VALUE "embiggen  ".
    05 FILLER PIC X(10) VALUE "twist     ".
    05 FILLER PIC X(10) VALUE "shorten   ".
    05 FILLER PIC X(10) VALUE "stretch   ".
    05 FILLER PIC X(10) VALUE "fiddle    ".
    05 FILLER PIC X(10) VALUE "destroy   ".
    05 FILLER PIC X(10) VALUE "imbue     ".
    05 FILLER PIC X(10) VALUE "galvanize ".
    05 FILLER PIC X(10) VALUE "enchant   ".
    05 FILLER PIC X(10) VALUE "free      ".
    05 FILLER PIC X(10) VALUE "limited   ".
    05 FILLER PIC X(10) VALUE "range     ".
    05 FILLER PIC X(10) VALUE "of        ".
    05 FILLER PIC X(10) VALUE "towards   ".
    05 FILLER PIC X(10) VALUE "inside    ".
    05 FILLER PIC X(10) VALUE "sphere    ".
    05 FILLER PIC X(10) VALUE "cube      ".
    05 FILLER PIC X(10) VALUE "self      ".
    05 FILLER PIC X(10) VALUE "other     ".
    05 FILLER PIC X(10) VALUE "ball      ".
    05 FILLER PIC X(10) VALUE "mental    ".
    05 FILLER PIC X(10) VALUE "physical  ".
    05 FILLER PIC X(10) VALUE "grow      ".
    05 FILLER PIC X(10) VALUE "shrink    ".
    05 FILLER PIC X(10) VALUE "demon     ".
    05 FILLER PIC X(10) VALUE "elemental ".
    05 FILLER PIC X(10) VALUE "spirit    ".
    05 FILLER PIC X(10) VALUE "animal    ".
    05 FILLER PIC X(10) VALUE "creature  ".
    05 FILLER PIC X(10) VALUE "beast     ".
    05 FILLER PIC X(10) VALUE "humanoid  ".
    05 FILLER PIC X(10) VALUE "undead    ".
    05 FILLER PIC X(10) VALUE "fresh     ".
    05 FILLER PIC X(10) VALUE "stale     ".
    05 FILLER PIC X(10) VALUE "phnglui   ".
    05 FILLER PIC X(10) VALUE "mglwnafh  ".
    05 FILLER PIC X(10) VALUE "cthulhu   ".
    05 FILLER PIC X(10) VALUE "rlyeh     ".
    05 FILLER PIC X(10) VALUE "wgahnagl  ".
    05 FILLER PIC X(10) VALUE "fhtagn    ".
    05 FILLER PIC X(10) VALUE "baguette  ".
 01 FILLER REDEFINES WS-WORDS.
    05 WS-WORD PIC X(10) OCCURS 62 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-I L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    MOVE FUNCTION TRIM(WS-WORD(L-I + 1)) TO L-T1
    MOVE FUNCTION TRIM(WS-WORD(L-I + 1)) TO L-T2
    GOBACK.
 END PROGRAM ENCH-WORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BOOK-STEP.
*> USING flip, flipT, flipA, open (floats), any cost is nonzero, open out, flipA out, flip out (all x 1e6) (2.10 tickBook steps 2 to 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP FLOAT-LONG.
 01 WS-D FLOAT-LONG.
 01 WS-FA FLOAT-LONG.
 01 WS-FL FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FLIP                 FLOAT-LONG.
 01 L-FT                   FLOAT-LONG.
 01 L-FA                   FLOAT-LONG.
 01 L-OP                   FLOAT-LONG.
 01 L-ANY                  BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-FA2                  BINARY-LONG.
 01 L-FLIP2                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLIP L-FT L-FA L-OP L-ANY L-OPEN L-FA2 L-FLIP2.
    IF L-ANY = 1
        COMPUTE WS-OP = L-OP + 0.2
    ELSE
        COMPUTE WS-OP = L-OP - 0.2
    END-IF
    COMPUTE WS-OP = FUNCTION MAX(0, FUNCTION MIN(1, WS-OP))
    COMPUTE WS-D = FUNCTION MAX(-0.2, FUNCTION MIN(0.2, (L-FT - L-FLIP) * 0.4))
    COMPUTE WS-FA = L-FA + (WS-D - L-FA) * 0.9
    COMPUTE WS-FL = L-FLIP + WS-FA
    COMPUTE L-OPEN ROUNDED = WS-OP * 1000000
    COMPUTE L-FA2 ROUNDED = WS-FA * 1000000
    COMPUTE L-FLIP2 ROUNDED = WS-FL * 1000000
    GOBACK.
 END PROGRAM ENCH-BOOK-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BOOK-FLIPT.
*> USING random state, flip x 1e6, flipT, new flipT out, draw pairs out (2.10 tickBook step 1): flipT += nextInt(4) - nextInt(4) at least once, while flip is within [flipT - 1, flipT + 1].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUR BINARY-LONG VALUE 4.
 01 WS-T BINARY-DOUBLE.
 01 WS-A BINARY-LONG.
 01 WS-B BINARY-LONG.
 LINKAGE SECTION.
 01 L-ST                   BINARY-DOUBLE UNSIGNED.
 01 L-FLIP                 BINARY-LONG.
 01 L-FT                   BINARY-LONG.
 01 L-NFT                  BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ST L-FLIP L-FT L-NFT L-DRAWS.
    MOVE L-FT TO WS-T
    MOVE 0 TO L-DRAWS
    PERFORM WITH TEST AFTER UNTIL L-FLIP < (WS-T - 1) * 1000000 OR L-FLIP > (WS-T + 1) * 1000000
        CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-FOUR WS-A
        CALL "JRAND-NEXT-INT-BOUND" USING L-ST WS-FOUR WS-B
        COMPUTE WS-T = WS-T + WS-A - WS-B
        ADD 1 TO L-DRAWS
    END-PERFORM
    MOVE WS-T TO L-NFT
    GOBACK.
 END PROGRAM ENCH-BOOK-FLIPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BOOK-DRAW.
*> USING oOpen, open, oFlip, flip, partial tick (floats), then o, f, p1, p2, openness, translate x, y, z and the Y rotation in degrees out (x 1e6) (2.10 drawing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O FLOAT-LONG.
 01 WS-F FLOAT-LONG.
 01 WS-X FLOAT-LONG.
 01 WS-P1 FLOAT-LONG.
 01 WS-P2 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OO                   FLOAT-LONG.
 01 L-OP                   FLOAT-LONG.
 01 L-OF                   FLOAT-LONG.
 01 L-FL                   FLOAT-LONG.
 01 L-PT                   FLOAT-LONG.
 01 L-O                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-P2                   BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OO L-OP L-OF L-FL L-PT L-O L-F L-P1 L-P2 L-OPEN L-TX L-TY L-TZ L-ROT.
    COMPUTE WS-O = L-OO + (L-OP - L-OO) * L-PT
    COMPUTE WS-F = L-OF + (L-FL - L-OF) * L-PT
    COMPUTE WS-X = WS-F + 0.25
    COMPUTE WS-P1 = FUNCTION MAX(0, FUNCTION MIN(1, (WS-X - FUNCTION INTEGER(WS-X)) * 1.6 - 0.3))
    COMPUTE WS-X = WS-F + 0.75
    COMPUTE WS-P2 = FUNCTION MAX(0, FUNCTION MIN(1, (WS-X - FUNCTION INTEGER(WS-X)) * 1.6 - 0.3))
    COMPUTE L-O ROUNDED = WS-O * 1000000
    COMPUTE L-F ROUNDED = WS-F * 1000000
    COMPUTE L-P1 ROUNDED = WS-P1 * 1000000
    COMPUTE L-P2 ROUNDED = WS-P2 * 1000000
    COMPUTE L-OPEN ROUNDED = 1.25 * WS-O * 1000000
    COMPUTE L-TX ROUNDED = (1 - WS-O) * 0.2 * 1000000
    COMPUTE L-TY ROUNDED = (1 - WS-O) * 0.1 * 1000000
    COMPUTE L-TZ ROUNDED = (1 - WS-O) * 0.25 * 1000000
    COMPUTE L-ROT ROUNDED = (0 - (1 - WS-O) * 90 - 90) * 1000000
    GOBACK.
 END PROGRAM ENCH-BOOK-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BOOK-ANIM.
*> USING o2, p1, p2 (floats), left lid yRot, right lid, left pages, right pages, flip page 1, flip page 2, page x out (x 1e6) (2.10 setupAnim).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O2                   FLOAT-LONG.
 01 L-P1                   FLOAT-LONG.
 01 L-P2                   FLOAT-LONG.
 01 L-LL                   BINARY-LONG.
 01 L-RL                   BINARY-LONG.
 01 L-LP                   BINARY-LONG.
 01 L-RP                   BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-O2 L-P1 L-P2 L-LL L-RL L-LP L-RP L-F1 L-F2 L-PX.
    COMPUTE L-LL ROUNDED = (3.1415927 + L-O2) * 1000000
    COMPUTE L-RL ROUNDED = (0 - L-O2) * 1000000
    COMPUTE L-LP ROUNDED = L-O2 * 1000000
    COMPUTE L-RP ROUNDED = (0 - L-O2) * 1000000
    COMPUTE L-F1 ROUNDED = (L-O2 - 2 * L-O2 * L-P1) * 1000000
    COMPUTE L-F2 ROUNDED = (L-O2 - 2 * L-O2 * L-P2) * 1000000
    COMPUTE L-PX ROUNDED = FUNCTION SIN(L-O2) * 1000000
    GOBACK.
 END PROGRAM ENCH-BOOK-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-BOOK-PART.
*> USING cube 1 to 7 (left lid, right lid, seam, left pages, right pages, flip pages 1 and 2), origin x, y, z, size w, h, d (x 1000), texture u, v, part offset z (x 1000), part Y rotation (x 1e6) out (2.10 model geometry).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PARTS.
    05 FILLER BINARY-LONG VALUE -6000.
    05 FILLER BINARY-LONG VALUE -5000.
    05 FILLER BINARY-LONG VALUE -5.
    05 FILLER BINARY-LONG VALUE 6000.
    05 FILLER BINARY-LONG VALUE 10000.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -5000.
    05 FILLER BINARY-LONG VALUE -5.
    05 FILLER BINARY-LONG VALUE 6000.
    05 FILLER BINARY-LONG VALUE 10000.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1000.
    05 FILLER BINARY-LONG VALUE -5000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2000.
    05 FILLER BINARY-LONG VALUE 10000.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1570796.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -4000.
    05 FILLER BINARY-LONG VALUE -990.
    05 FILLER BINARY-LONG VALUE 5000.
    05 FILLER BINARY-LONG VALUE 8000.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -4000.
    05 FILLER BINARY-LONG VALUE -10.
    05 FILLER BINARY-LONG VALUE 5000.
    05 FILLER BINARY-LONG VALUE 8000.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -4000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5000.
    05 FILLER BINARY-LONG VALUE 8000.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 24.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -4000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5000.
    05 FILLER BINARY-LONG VALUE 8000.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 24.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 FILLER REDEFINES WS-PARTS.
    05 WS-PART BINARY-LONG OCCURS 70 TIMES.
 01 WS-BASE BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-OFFZ                 BINARY-LONG.
 01 L-ROTY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-OX L-OY L-OZ L-W L-H L-D L-U L-V L-OFFZ L-ROTY.
    COMPUTE WS-BASE = (L-I - 1) * 10
    MOVE WS-PART(WS-BASE + 1) TO L-OX
    MOVE WS-PART(WS-BASE + 2) TO L-OY
    MOVE WS-PART(WS-BASE + 3) TO L-OZ
    MOVE WS-PART(WS-BASE + 4) TO L-W
    MOVE WS-PART(WS-BASE + 5) TO L-H
    MOVE WS-PART(WS-BASE + 6) TO L-D
    MOVE WS-PART(WS-BASE + 7) TO L-U
    MOVE WS-PART(WS-BASE + 8) TO L-V
    MOVE WS-PART(WS-BASE + 9) TO L-OFFZ
    MOVE WS-PART(WS-BASE + 10) TO L-ROTY
    GOBACK.
 END PROGRAM ENCH-BOOK-PART.
