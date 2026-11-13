*> Menus, part 5: the merchant, the beacon and the lectern (docs/protocol/40-menus-5-merchant-beacon-lectern.md sections 1 to 4; US12 phase 44).
*> Programs of plain numbers (MN5- prefix): each takes the facts the caller read (counts, flags, positions, effect ids) and returns the decision or the
*> pixel arithmetic of the section. The live window of a player (menus.cob) is not changed by this file. Flags are 0 or 1; an absent effect is -1, a
*> present one its mob effect registry id (speed 0, haste 2, strength 4, jump boost 7, regeneration 9, resistance 10, 46 section 4.1). Menu kinds of
*> section 1: 1 merchant, 2 beacon, 3 lectern. The generic click engine, moveItemStackTo and the container model are 40-1.
*>
*>   MN5-IDENT, -IMAGE, -TITLEKEY, -PACKET, -BUTTON-OK, -OFFER-DECODE, -OFFER-DEFAULT (1)
*>   MN5-M-SLOT, -LIMIT, -REMOVE, -SETUPDATE, -PRICE, -COMPONENT, -MATCH, -SATISFIED, -TAKE, -RECIPE, -OFFERFACTS, -UPDATE, -PICKUP, -TAKEN, -REMCOUNT,
*>   -TRYMOVE, -FILL, -FILLRUN, -QUICK, -SOUNDKEY, -TRADESOUND, -REMOVED, -VALID, -OFFERS-APPLY, -ROWBTN, -BTNPOS, -ROWPOS, -DRAWN, -DECOR, -SCROLLER,
*>   -WHEEL, -PRESS, -DRAG, -CROSS, -CROSSTIP, -LABELS, -LEVELNAME, -XPBAR, -ROWTIP, -SPRITE (2)
*>   MN5-B-SLOT, -PAYITEM, -TAGGED, -ENCODE, -FILTER, -SETDATA, -REQ, -VALIDATE, -UPDATE, -QUICK, -REMOVED, -BUTTON, -BG, -POWER, -UPGRADE, -CONFIRM,
*>   -PRESS, -LABELTEXT, -LABEL, -EFFECTTEXT, -ENDBUTTON (3)
*>   MN5-L-SLOT, -PAGECOUNT, -HASBOOK, -VALID, -CLAMP, -BUTTON, -TAKE, -QUICK, -SIGNAL, -LAYOUT, -LAYOUTY, -LINES, -INDICATOR, -VIS, -SETBOOK, -SETPAGE,
*>   -KEY, -TEXTCLICK, -FORCE, -CONTROLS, -PAGEPRESS, -LISTEN, -TURNSOUND (4)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-IDENT.
*> USING menu kind, type id out, own slots out, total slots out, data slots out (1.1, 1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TYPE L-OWN L-TOTAL L-DATA.
    EVALUATE L-KIND
        WHEN 1
            MOVE 19 TO L-TYPE
            MOVE 3 TO L-OWN
            MOVE 39 TO L-TOTAL
            MOVE 0 TO L-DATA
        WHEN 2
            MOVE 9 TO L-TYPE
            MOVE 1 TO L-OWN
            MOVE 37 TO L-TOTAL
            MOVE 3 TO L-DATA
        WHEN OTHER
            MOVE 17 TO L-TYPE
            MOVE 1 TO L-OWN
            MOVE 1 TO L-TOTAL
            MOVE 1 TO L-DATA
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-IMAGE.
*> USING menu kind, image width out, image height out, texture width out, texture height out (1.2; the lectern has no container image).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-TW                   BINARY-LONG.
 01 L-TH                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-W L-H L-TW L-TH.
    EVALUATE L-KIND
        WHEN 1
            MOVE 276 TO L-W
            MOVE 166 TO L-H
            MOVE 512 TO L-TW
            MOVE 256 TO L-TH
        WHEN 2
            MOVE 230 TO L-W
            MOVE 219 TO L-H
            MOVE 256 TO L-TW
            MOVE 256 TO L-TH
        WHEN OTHER
            MOVE 0 TO L-W
            MOVE 0 TO L-H
            MOVE 256 TO L-TW
            MOVE 256 TO L-TH
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-IMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-TITLEKEY.
*> USING menu kind (2 beacon, 3 lectern), key out, English text out (3.1, 4.1); the merchant's title is given by its caller.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(96).
 01 L-TEXT                 PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-KEY L-TEXT.
    MOVE SPACES TO L-KEY L-TEXT
    EVALUATE L-KIND
        WHEN 2
            MOVE "container.beacon" TO L-KEY
            MOVE "Beacon" TO L-TEXT
        WHEN 3
            MOVE "container.lectern" TO L-KEY
            MOVE "Lectern" TO L-TEXT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-TITLEKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-PACKET.
*> USING packet (1 Open Screen, 2 Merchant Offers, 3 Container Set Data, 4 Container Button Click, 5 Select Trade, 6 Set Beacon), menus using it
*> out (merchant 1, beacon 2, lectern 4), packet id out, serverbound flag out (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PACKET               BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-SERVERBOUND          BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKET L-MASK L-ID L-SERVERBOUND.
    MOVE 0 TO L-SERVERBOUND
    EVALUATE L-PACKET
        WHEN 1
            MOVE 7 TO L-MASK
            MOVE 60 TO L-ID
        WHEN 2
            MOVE 1 TO L-MASK
            MOVE 53 TO L-ID
        WHEN 3
            MOVE 6 TO L-MASK
            MOVE 19 TO L-ID
        WHEN 4
            MOVE 4 TO L-MASK
            MOVE 17 TO L-ID
            MOVE 1 TO L-SERVERBOUND
        WHEN 5
            MOVE 1 TO L-MASK
            MOVE 52 TO L-ID
            MOVE 1 TO L-SERVERBOUND
        WHEN OTHER
            MOVE 2 TO L-MASK
            MOVE 53 TO L-ID
            MOVE 1 TO L-SERVERBOUND
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-BUTTON-OK.
*> USING container id equal, spectator, stillValid, click result, acted out, broadcast out (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EQUAL                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ACTED                BINARY-LONG.
 01 L-BROADCAST            BINARY-LONG.
 PROCEDURE DIVISION USING L-EQUAL L-SPECTATOR L-VALID L-RESULT L-ACTED L-BROADCAST.
    MOVE 0 TO L-ACTED L-BROADCAST
    IF L-EQUAL = 1 AND L-SPECTATOR = 0 AND L-VALID = 1
        MOVE 1 TO L-ACTED
        MOVE L-RESULT TO L-BROADCAST
    END-IF
    GOBACK.
 END PROGRAM MN5-BUTTON-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-OFFER-DECODE.
*> USING uses, maxUses, out-of-stock flag, specialPriceDiff, uses out, special out (1.3: the flag forces uses to maxUses, then the special price applies).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USES                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 01 L-USES-OUT             BINARY-LONG.
 01 L-SPECIAL-OUT          BINARY-LONG.
 PROCEDURE DIVISION USING L-USES L-MAX L-FLAG L-SPECIAL L-USES-OUT L-SPECIAL-OUT.
    MOVE L-USES TO L-USES-OUT
    IF L-FLAG = 1
        MOVE L-MAX TO L-USES-OUT
    END-IF
    MOVE L-SPECIAL TO L-SPECIAL-OUT
    GOBACK.
 END PROGRAM MN5-OFFER-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-OFFER-DEFAULT.
*> USING field (1 uses, 2 maxUses, 3 rewardExp, 4 specialPrice, 5 demand, 6 priceMultiplier, 7 xp, 8 item cost count), default out, -1 otherwise (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELD L-DEFAULT.
    EVALUATE TRUE
        WHEN L-FIELD = 2
            MOVE 4 TO L-DEFAULT
        WHEN L-FIELD = 3 OR L-FIELD = 7 OR L-FIELD = 8
            MOVE 1 TO L-DEFAULT
        WHEN L-FIELD >= 1 AND L-FIELD <= 6
            MOVE 0 TO L-DEFAULT
        WHEN OTHER
            MOVE -1 TO L-DEFAULT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-OFFER-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SLOT.
*> USING menu slot, x out, y out, result slot class out, part out (1 trade slots, 2 main inventory, 3 hotbar, 0 none) (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-J                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-X L-Y L-RESULT L-PART.
    MOVE 0 TO L-X L-Y L-RESULT L-PART
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 136 TO L-X
            MOVE 37 TO L-Y
            MOVE 1 TO L-PART
        WHEN L-SLOT = 1
            MOVE 162 TO L-X
            MOVE 37 TO L-Y
            MOVE 1 TO L-PART
        WHEN L-SLOT = 2
            MOVE 220 TO L-X
            MOVE 37 TO L-Y
            MOVE 1 TO L-RESULT
            MOVE 1 TO L-PART
        WHEN L-SLOT >= 3 AND L-SLOT <= 29
            COMPUTE W-J = L-SLOT - 3
            COMPUTE L-X = 108 + 18 * FUNCTION MOD(W-J, 9)
            DIVIDE W-J BY 9 GIVING W-ROW
            COMPUTE L-Y = 84 + 18 * W-ROW
            MOVE 2 TO L-PART
        WHEN L-SLOT >= 30 AND L-SLOT <= 38
            COMPUTE L-X = 108 + 18 * (L-SLOT - 30)
            MOVE 142 TO L-Y
            MOVE 3 TO L-PART
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-LIMIT.
*> USING count, item maximum stack size, limited count out (2.2: the container default 64, then the item's own limit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-MAX L-OUT.
    MOVE L-COUNT TO L-OUT
    IF L-OUT > 64
        MOVE 64 TO L-OUT
    END-IF
    IF L-OUT > L-MAX
        MOVE L-MAX TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN5-M-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-REMOVE.
*> USING slot, non-empty, n asked, count, removed out, run updateSellItem out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NONEMPTY L-N L-COUNT L-REMOVED L-UPDATE.
    MOVE 0 TO L-REMOVED L-UPDATE
    EVALUATE TRUE
        WHEN L-SLOT = 2 AND L-NONEMPTY = 1
            MOVE L-COUNT TO L-REMOVED
        WHEN L-NONEMPTY = 1
            MOVE L-N TO L-REMOVED
            IF L-REMOVED > L-COUNT
                MOVE L-COUNT TO L-REMOVED
            END-IF
            IF L-REMOVED > 0 AND L-SLOT < 2
                MOVE 1 TO L-UPDATE
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SETUPDATE.
*> USING slot, update out (2.3: setItem on a payment slot runs updateSellItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-UPDATE.
    MOVE 0 TO L-UPDATE
    IF L-SLOT < 2
        MOVE 1 TO L-UPDATE
    END-IF
    GOBACK.
 END PROGRAM MN5-M-SETUPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-PRICE.
*> USING base count, demand, price multiplier (float), special price diff, max stack size, adjustment out, count out (2.4). The product is single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CD                   FLOAT-SHORT.
 01 W-M                    FLOAT-SHORT.
 01 W-P                    FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-M                    FLOAT-LONG.
 01 L-S                    BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ADJ                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-D L-M L-S L-MAX L-ADJ L-COUNT.
    COMPUTE W-CD = L-C * L-D
    MOVE L-M TO W-M
    COMPUTE W-P = W-CD * W-M
    COMPUTE L-ADJ = FUNCTION INTEGER(W-P)
    IF L-ADJ < 0
        MOVE 0 TO L-ADJ
    END-IF
    COMPUTE L-COUNT = L-C + L-ADJ + L-S
    IF L-COUNT < 1
        MOVE 1 TO L-COUNT
    END-IF
    IF L-COUNT > L-MAX
        MOVE L-MAX TO L-COUNT
    END-IF
    GOBACK.
 END PROGRAM MN5-M-PRICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-COMPONENT.
*> USING expected value is null, stack value is null, values equal, ok out (2.4: null-safe equality of one expected component).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENULL                BINARY-LONG.
 01 L-SNULL                BINARY-LONG.
 01 L-EQUAL                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ENULL L-SNULL L-EQUAL L-OK.
    MOVE 0 TO L-OK
    EVALUATE TRUE
        WHEN L-ENULL = 1 AND L-SNULL = 1
            MOVE 1 TO L-OK
        WHEN L-ENULL = 0 AND L-SNULL = 0 AND L-EQUAL = 1
            MOVE 1 TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-MATCH.
*> USING stack is of the cost's item, predicate passes, match out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-PRED                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-PRED L-OK.
    MOVE 0 TO L-OK
    IF L-ITEM = 1 AND L-PRED = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN5-M-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SATISFIED.
*> USING a matches, a count, modified cost A, offer has cost B, b matches, b count, cost B count, b empty, satisfied out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AM                   BINARY-LONG.
 01 L-AC                   BINARY-LONG.
 01 L-CA                   BINARY-LONG.
 01 L-HB                   BINARY-LONG.
 01 L-BM                   BINARY-LONG.
 01 L-BC                   BINARY-LONG.
 01 L-CB                   BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AM L-AC L-CA L-HB L-BM L-BC L-CB L-BE L-OK.
    MOVE 0 TO L-OK
    EVALUATE TRUE
        WHEN L-AM = 0 OR L-AC < L-CA
            MOVE 0 TO L-OK
        WHEN L-HB = 1 AND L-BM = 1 AND L-BC >= L-CB
            MOVE 1 TO L-OK
        WHEN L-HB = 0
            MOVE L-BE TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-SATISFIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-TAKE.
*> USING satisfied, count a, modified cost A, offer has cost B, count b, cost B, ok out, new a out, new b out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAT                  BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-CA                   BINARY-LONG.
 01 L-HB                   BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-CB                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-NA                   BINARY-LONG.
 01 L-NB                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SAT L-A L-CA L-HB L-B L-CB L-OK L-NA L-NB.
    MOVE L-SAT TO L-OK
    MOVE L-A TO L-NA
    MOVE L-B TO L-NB
    IF L-SAT = 1
        SUBTRACT L-CA FROM L-NA
        IF L-HB = 1
            SUBTRACT L-CB FROM L-NB
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN5-M-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-RECIPE.
*> USING hint, offer count, satisfied flags of offers 0 to 7 (8 items), index out or -1 (2.4 getRecipeFor).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-FLAGS.
    05 W-FLAG              BINARY-LONG OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-HINT                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-F3                   BINARY-LONG.
 01 L-F4                   BINARY-LONG.
 01 L-F5                   BINARY-LONG.
 01 L-F6                   BINARY-LONG.
 01 L-F7                   BINARY-LONG.
 01 L-F8                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-HINT L-SIZE L-F1 L-F2 L-F3 L-F4 L-F5 L-F6 L-F7 L-F8 L-INDEX.
    MOVE L-F1 TO W-FLAG(1)
    MOVE L-F2 TO W-FLAG(2)
    MOVE L-F3 TO W-FLAG(3)
    MOVE L-F4 TO W-FLAG(4)
    MOVE L-F5 TO W-FLAG(5)
    MOVE L-F6 TO W-FLAG(6)
    MOVE L-F7 TO W-FLAG(7)
    MOVE L-F8 TO W-FLAG(8)
    MOVE -1 TO L-INDEX
    EVALUATE TRUE
        WHEN L-HINT > 0 AND L-HINT < L-SIZE
            IF W-FLAG(L-HINT + 1) = 1
                MOVE L-HINT TO L-INDEX
            END-IF
        WHEN OTHER
            PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-SIZE OR L-INDEX >= 0
                IF W-FLAG(W-I) = 1
                    COMPUTE L-INDEX = W-I - 1
                END-IF
            END-PERFORM
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-RECIPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-OFFERFACTS.
*> USING uses, maxUses, demand, out of stock out, needs restock out, increased uses out, updated demand out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USES                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DEMAND               BINARY-LONG.
 01 L-OOS                  BINARY-LONG.
 01 L-RESTOCK              BINARY-LONG.
 01 L-NEWUSES              BINARY-LONG.
 01 L-NEWDEMAND            BINARY-LONG.
 PROCEDURE DIVISION USING L-USES L-MAX L-DEMAND L-OOS L-RESTOCK L-NEWUSES L-NEWDEMAND.
    MOVE 0 TO L-OOS L-RESTOCK
    IF L-USES >= L-MAX
        MOVE 1 TO L-OOS
    END-IF
    IF L-USES > 0
        MOVE 1 TO L-RESTOCK
    END-IF
    COMPUTE L-NEWUSES = L-USES + 1
    COMPUTE L-NEWDEMAND = L-DEMAND + L-USES - (L-MAX - L-USES)
    GOBACK.
 END PROGRAM MN5-M-OFFERFACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-UPDATE.
*> USING slot 0 empty, slot 1 empty, offers empty, first lookup (0 none, 1 found, 2 out of stock), swapped lookup, active offer out (0 none, 1 the first
*> lookup's, 2 the swapped one), result out (0 empty, 1 offer, 2 unchanged), xp from the offer out, merchant notified out, swapped lookup made out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S0                   BINARY-LONG.
 01 L-S1                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-SWAPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-S0 L-S1 L-OE L-O1 L-O2 L-ACTIVE L-RESULT L-XP L-NOTIFY L-SWAPPED.
    MOVE 0 TO L-ACTIVE L-RESULT L-XP L-NOTIFY L-SWAPPED
    EVALUATE TRUE
        WHEN L-S0 = 1 AND L-S1 = 1
            MOVE 0 TO L-NOTIFY
        WHEN L-OE = 1
            MOVE 2 TO L-RESULT
            MOVE 1 TO L-NOTIFY
        WHEN L-O1 = 1
            MOVE 1 TO L-ACTIVE
            MOVE 1 TO L-RESULT
            MOVE 1 TO L-XP
            MOVE 1 TO L-NOTIFY
        WHEN L-O2 = 1
            MOVE 2 TO L-ACTIVE
            MOVE 1 TO L-RESULT
            MOVE 1 TO L-XP
            MOVE 1 TO L-NOTIFY
            MOVE 1 TO L-SWAPPED
        WHEN L-O1 = 2
            MOVE 1 TO L-ACTIVE
            MOVE 1 TO L-NOTIFY
            MOVE 1 TO L-SWAPPED
        WHEN OTHER
            MOVE 1 TO L-NOTIFY
            MOVE 1 TO L-SWAPPED
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-PICKUP.
*> USING active offer present, satisfied (slot 0, slot 1), satisfied (slot 1, slot 0), may pickup out (2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-S01                  BINARY-LONG.
 01 L-S10                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-S01 L-S10 L-OK.
    MOVE 0 TO L-OK
    IF L-ACTIVE = 1 AND (L-S01 = 1 OR L-S10 = 1)
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN5-M-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-TAKEN.
*> USING active offer present, take (a, b) ok, take (b, a) ok, took out, order out (1 or 2), trade notified out, statistic out, xp override out (2.5 onTake).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 01 L-TOOK                 BINARY-LONG.
 01 L-ORDER                BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-T1 L-T2 L-TOOK L-ORDER L-NOTIFY L-STAT L-XP.
    MOVE 0 TO L-TOOK L-ORDER L-NOTIFY L-STAT L-XP
    IF L-ACTIVE = 1
        MOVE 1 TO L-XP
        EVALUATE TRUE
            WHEN L-T1 = 1
                MOVE 1 TO L-TOOK L-ORDER L-NOTIFY L-STAT
            WHEN L-T2 = 1
                MOVE 1 TO L-TOOK L-NOTIFY L-STAT
                MOVE 2 TO L-ORDER
        END-EVALUATE
    END-IF
    GOBACK.
 END PROGRAM MN5-M-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-REMCOUNT.
*> USING op (1 remove(n), 2 onQuickCraft(delta n), 3 check achievements), removeCount, n, count, new removeCount out, crafted count out (2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CRAFTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-RC L-N L-COUNT L-NEW L-CRAFTED.
    MOVE 0 TO L-NEW L-CRAFTED
    EVALUATE L-OP
        WHEN 1
            COMPUTE L-NEW = L-RC + FUNCTION MIN(L-N, L-COUNT)
        WHEN 2
            COMPUTE L-CRAFTED = L-RC + L-N
        WHEN OTHER
            MOVE L-RC TO L-CRAFTED
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-REMCOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-TRYMOVE.
*> USING index, offer count, slot 0 count before and after returning it, slot 1 count before and after, state out (0 index out of range, 1 a move failed,
*> 2 a payment slot is not empty, 3 fill the payments from the base cost) (2.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N0                   BINARY-LONG.
 01 W-N1                   BINARY-LONG.
 01 W-FAIL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-B0                   BINARY-LONG.
 01 L-A0                   BINARY-LONG.
 01 L-B1                   BINARY-LONG.
 01 L-A1                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-COUNT L-B0 L-A0 L-B1 L-A1 L-STATE.
    MOVE 0 TO W-N0 W-N1 W-FAIL
    EVALUATE TRUE
        WHEN L-I < 0 OR L-I >= L-COUNT
            MOVE 0 TO L-STATE
        WHEN OTHER
            IF L-B0 > 0
                IF L-A0 = L-B0
                    MOVE 1 TO W-FAIL
                ELSE
                    MOVE L-A0 TO W-N0
                END-IF
            END-IF
            IF W-FAIL = 0 AND L-B1 > 0
                IF L-A1 = L-B1
                    MOVE 1 TO W-FAIL
                ELSE
                    MOVE L-A1 TO W-N1
                END-IF
            END-IF
            EVALUATE TRUE
                WHEN W-FAIL = 1
                    MOVE 1 TO L-STATE
                WHEN W-N0 = 0 AND W-N1 = 0
                    MOVE 3 TO L-STATE
                WHEN OTHER
                    MOVE 2 TO L-STATE
            END-EVALUATE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-TRYMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-FILL.
*> USING stack matches the cost, stack count, current payment count, same item as the payment, max stack size, skipped out, moved out, new payment out,
*> payment full out (2.7 filling one payment slot from one inventory stack).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MATCH                BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MATCH L-STACK L-CUR L-SAME L-MAX L-SKIP L-MOVED L-NEW L-FULL.
    MOVE 0 TO L-SKIP L-MOVED L-FULL
    MOVE L-CUR TO L-NEW
    EVALUATE TRUE
        WHEN L-MATCH = 0
            MOVE 1 TO L-SKIP
        WHEN L-CUR > 0 AND L-SAME = 0
            MOVE 1 TO L-SKIP
        WHEN OTHER
            COMPUTE L-MOVED = FUNCTION MIN(L-MAX - L-CUR, L-STACK)
            COMPUTE L-NEW = L-CUR + L-MOVED
            IF L-NEW >= L-MAX
                MOVE 1 TO L-FULL
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-FILLRUN.
*> USING max stack size, counts of four matching inventory stacks (same item), payment out, remaining counts of the four out (2.7, E5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-N                    BINARY-LONG.
 01 W-STACKS.
    05 W-STACK             BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-C1                   BINARY-LONG.
 01 L-C2                   BINARY-LONG.
 01 L-C3                   BINARY-LONG.
 01 L-C4                   BINARY-LONG.
 01 L-PAYMENT              BINARY-LONG.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-R3                   BINARY-LONG.
 01 L-R4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-C1 L-C2 L-C3 L-C4 L-PAYMENT L-R1 L-R2 L-R3 L-R4.
    MOVE L-C1 TO W-STACK(1)
    MOVE L-C2 TO W-STACK(2)
    MOVE L-C3 TO W-STACK(3)
    MOVE L-C4 TO W-STACK(4)
    MOVE 0 TO L-PAYMENT
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 4 OR L-PAYMENT >= L-MAX
        COMPUTE W-N = FUNCTION MIN(L-MAX - L-PAYMENT, W-STACK(W-I))
        ADD W-N TO L-PAYMENT
        SUBTRACT W-N FROM W-STACK(W-I)
    END-PERFORM
    MOVE W-STACK(1) TO L-R1
    MOVE W-STACK(2) TO L-R2
    MOVE W-STACK(3) TO L-R3
    MOVE W-STACK(4) TO L-R4
    GOBACK.
 END PROGRAM MN5-M-FILLRUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-QUICK.
*> USING source slot, range start out, range end out (exclusive), reverse out, onQuickCraft and sound out, canTakeItemForPickAll out (2.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 01 L-PICKALL              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-START L-END L-REVERSE L-EXTRA L-PICKALL.
    MOVE 0 TO L-START L-END L-REVERSE L-EXTRA L-PICKALL
    EVALUATE TRUE
        WHEN L-SLOT = 2
            MOVE 3 TO L-START
            MOVE 39 TO L-END
            MOVE 1 TO L-REVERSE L-EXTRA
        WHEN L-SLOT = 0 OR L-SLOT = 1
            MOVE 3 TO L-START
            MOVE 39 TO L-END
        WHEN L-SLOT >= 3 AND L-SLOT <= 29
            MOVE 30 TO L-START
            MOVE 39 TO L-END
        WHEN L-SLOT >= 30 AND L-SLOT <= 38
            MOVE 3 TO L-START
            MOVE 30 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SOUNDKEY.
*> USING kind (1 villager, 2 wandering trader), yes flag, sound event out, category out (2.8, 2.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-YES                  BINARY-LONG.
 01 L-SOUND                PIC X(96).
 01 L-CATEGORY             PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-YES L-SOUND L-CATEGORY.
    MOVE SPACES TO L-SOUND L-CATEGORY
    MOVE "neutral" TO L-CATEGORY
    IF L-KIND = 1
        MOVE "villager" TO L-SOUND
    ELSE
        MOVE "wandering_trader" TO L-SOUND
    END-IF
    IF L-YES = 1
        STRING FUNCTION TRIM(L-SOUND) ".yes" DELIMITED BY SIZE INTO L-SOUND
    ELSE
        STRING FUNCTION TRIM(L-SOUND) ".no" DELIMITED BY SIZE INTO L-SOUND
    END-IF
    GOBACK.
 END PROGRAM MN5-M-SOUNDKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-TRADESOUND.
*> USING ambientSoundTime, server side, result empty, play out, new ambientSoundTime out, yes out (2.9 notifyTradeUpdated).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AMBIENT              BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-PLAY                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AMBIENT L-SERVER L-EMPTY L-PLAY L-NEW L-YES.
    MOVE 0 TO L-PLAY L-YES
    MOVE L-AMBIENT TO L-NEW
    IF L-EMPTY = 0
        MOVE 1 TO L-YES
    END-IF
    IF L-SERVER = 1 AND L-AMBIENT > -60
        MOVE 1 TO L-PLAY
        MOVE -80 TO L-NEW
    END-IF
    GOBACK.
 END PROGRAM MN5-M-TRADESOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-REMOVED.
*> USING client side, player alive, is a server player, disconnected, action out (0 none, 1 drop both payments, 2 put them back) (2.9 removed).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-DISCONNECTED         BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-ALIVE L-SERVER L-DISCONNECTED L-ACTION.
    MOVE 0 TO L-ACTION
    EVALUATE TRUE
        WHEN L-CLIENT = 1
            MOVE 0 TO L-ACTION
        WHEN L-ALIVE = 0
            MOVE 1 TO L-ACTION
        WHEN L-SERVER = 1 AND L-DISCONNECTED = 1
            MOVE 1 TO L-ACTION
        WHEN L-SERVER = 1
            MOVE 2 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-VALID.
*> USING trading player is this player, merchant alive, distance, valid out (2.9 stillValid; range 4.0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRADING              BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-DIST                 FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TRADING L-ALIVE L-DIST L-OK.
    MOVE 0 TO L-OK
    IF L-TRADING = 1 AND L-ALIVE = 1 AND L-DIST <= 4.0
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN5-M-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-OFFERS-APPLY.
*> USING packet container id, open menu container id, menu is a merchant menu, applied out (2.9 Merchant Offers handling).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-MERCHANT             BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-OPEN L-MERCHANT L-APPLIED.
    MOVE 0 TO L-APPLIED
    IF L-ID = L-OPEN AND L-MERCHANT = 1
        MOVE 1 TO L-APPLIED
    END-IF
    GOBACK.
 END PROGRAM MN5-M-OFFERS-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-ROWBTN.
*> USING button index, offer count, visible out (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COUNT L-VISIBLE.
    MOVE 0 TO L-VISIBLE
    IF L-COUNT > 0 AND L-K < L-COUNT
        MOVE 1 TO L-VISIBLE
    END-IF
    GOBACK.
 END PROGRAM MN5-M-ROWBTN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-BTNPOS.
*> USING button index, leftPos, topPos, x out, y out, width out, height out (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-LEFT L-TOP L-X L-Y L-W L-H.
    COMPUTE L-X = L-LEFT + 5
    COMPUTE L-Y = L-TOP + 18 + 20 * L-K
    MOVE 88 TO L-W
    MOVE 20 TO L-H
    GOBACK.
 END PROGRAM MN5-M-BTNPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-ROWPOS.
*> USING visible row r, leftPos, topPos, first cost x out, row y out, second cost x out, arrow x out, arrow y out, result x out (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-LEFT L-TOP L-X1 L-Y L-X2 L-AX L-AY L-RX.
    COMPUTE L-X1 = L-LEFT + 10
    COMPUTE L-Y = L-TOP + 19 + 20 * L-R
    COMPUTE L-X2 = L-LEFT + 40
    COMPUTE L-AX = L-LEFT + 60
    COMPUTE L-AY = L-Y + 3
    COMPUTE L-RX = L-LEFT + 73
    GOBACK.
 END PROGRAM MN5-M-ROWPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-DRAWN.
*> USING offer count, scrollOff, first drawn offer out, end (exclusive) out (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-OFF L-FIRST L-END.
    MOVE 0 TO L-FIRST
    MOVE L-COUNT TO L-END
    IF L-COUNT > 7
        MOVE L-OFF TO L-FIRST
        COMPUTE L-END = FUNCTION MIN(L-OFF + 7, L-COUNT)
    END-IF
    GOBACK.
 END PROGRAM MN5-M-DRAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-DECOR.
*> USING base count, modified count, x, y, mode out (0 one count, 1 struck), base text out, base x out, modified text out, modified x out, strike x out,
*> strike y out (2.10 first cost decorations; the text is 1 for a count of 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-MOD                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-BT                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-MT                   BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-MOD L-X L-Y L-MODE L-BT L-BX L-MT L-MX L-SX L-SY.
    MOVE 0 TO L-MODE L-MT L-MX L-SX L-SY
    MOVE L-BASE TO L-BT
    MOVE L-X TO L-BX
    IF L-BASE NOT = L-MOD
        MOVE 1 TO L-MODE
        MOVE L-MOD TO L-MT
        COMPUTE L-MX = L-X + 14
        COMPUTE L-SX = L-X + 7
        COMPUTE L-SY = L-Y + 12
    END-IF
    GOBACK.
 END PROGRAM MN5-M-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SCROLLER.
*> USING offer count, scrollOff, disabled out, n out, h out, step out, thumb offset out (2.10; integer divisions).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-T                    BINARY-LONG.
 01 W-Q1                   BINARY-LONG.
 01 W-Q2                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-DISABLED             BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-THUMB                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-OFF L-DISABLED L-N L-H L-STEP L-THUMB.
    MOVE 0 TO L-DISABLED L-H L-STEP L-THUMB
    COMPUTE L-N = L-COUNT - 6
    IF L-N <= 1
        MOVE 1 TO L-DISABLED
    ELSE
        COMPUTE W-T = (L-N - 1) * 139
        DIVIDE W-T BY L-N GIVING W-Q1
        COMPUTE L-H = 139 - (27 + W-Q1)
        DIVIDE L-H BY L-N GIVING W-Q1
        DIVIDE 139 BY L-N GIVING W-Q2
        COMPUTE L-STEP = 1 + W-Q1 + W-Q2
        COMPUTE L-THUMB = FUNCTION MIN(113, L-OFF * L-STEP)
        IF L-OFF = L-N - 1
            MOVE 113 TO L-THUMB
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN5-M-SCROLLER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-WHEEL.
*> USING offer count, scrollOff, wheel amount (float), new scrollOff out (2.10; the amount is subtracted and truncated toward zero).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-WHEEL                FLOAT-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-OFF L-WHEEL L-NEW.
    MOVE L-OFF TO L-NEW
    IF L-COUNT > 7
        COMPUTE W-V = L-OFF - L-WHEEL
        COMPUTE L-NEW = FUNCTION INTEGER-PART(W-V)
        IF L-NEW < 0
            MOVE 0 TO L-NEW
        END-IF
        IF L-NEW > L-COUNT - 7
            COMPUTE L-NEW = L-COUNT - 7
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN5-M-WHEEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-PRESS.
*> USING pointer x, pointer y, leftPos, topPos, offer count, dragging out (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DRAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PX L-PY L-LEFT L-TOP L-COUNT L-DRAG.
    MOVE 0 TO L-DRAG
    IF L-COUNT > 7 AND L-PX > L-LEFT + 94 AND L-PX < L-LEFT + 100
       AND L-PY > L-TOP + 18 AND L-PY <= L-TOP + 158
        MOVE 1 TO L-DRAG
    END-IF
    GOBACK.
 END PROGRAM MN5-M-PRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-DRAG.
*> USING mouse y, topPos, offer count, scrollOff out (2.10: f = (y - top - 13.5) / (139 - 27) x maxOff + 0.5 with top = topPos + 18).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-F                    FLOAT-LONG.
 01 W-MAX                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MY                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MY L-TOP L-COUNT L-OFF.
    COMPUTE W-MAX = L-COUNT - 7
    COMPUTE W-F = (L-MY - (L-TOP + 18) - 13.5) / 112.0 * W-MAX + 0.5
    COMPUTE L-OFF = FUNCTION INTEGER-PART(W-F)
    IF L-OFF < 0
        MOVE 0 TO L-OFF
    END-IF
    IF L-OFF > W-MAX
        MOVE W-MAX TO L-OFF
    END-IF
    GOBACK.
 END PROGRAM MN5-M-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-CROSS.
*> USING offer count, selected index, selected offer out of stock, drawn out (2.10; the sprite is at (leftPos + 182, topPos + 35)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-OOS                  BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-SEL L-OOS L-DRAWN.
    MOVE 0 TO L-DRAWN
    IF L-COUNT > 0 AND L-SEL >= 0 AND L-SEL < L-COUNT AND L-OOS = 1
        MOVE 1 TO L-DRAWN
    END-IF
    GOBACK.
 END PROGRAM MN5-M-CROSS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-CROSSTIP.
*> USING selected offer out of stock, pointer x and y relative to the image, canRestock, tooltip out (2.10; rectangle x 186 to 208, y 35 to 56).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OOS                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-RESTOCK              BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OOS L-X L-Y L-RESTOCK L-TIP.
    MOVE 0 TO L-TIP
    IF L-OOS = 1 AND L-X >= 186 AND L-X < 208 AND L-Y >= 35 AND L-Y < 56 AND L-RESTOCK = 1
        MOVE 1 TO L-TIP
    END-IF
    GOBACK.
 END PROGRAM MN5-M-CROSSTIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-LABELS.
*> USING level, progress bar shown, title width, trades width, level in title out, title x out, trades x out, inventory x out, inventory y out (2.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-H1                   BINARY-LONG.
 01 W-H2                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 01 L-TW                   BINARY-LONG.
 01 L-RW                   BINARY-LONG.
 01 L-INTITLE              BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-SHOW L-TW L-RW L-INTITLE L-TX L-RX L-IX L-IY.
    MOVE 0 TO L-INTITLE
    IF L-LEVEL >= 1 AND L-LEVEL <= 5 AND L-SHOW = 1
        MOVE 1 TO L-INTITLE
    END-IF
    DIVIDE L-TW BY 2 GIVING W-H1
    DIVIDE L-RW BY 2 GIVING W-H2
    COMPUTE L-TX = 187 - W-H1
    COMPUTE L-RX = 53 - W-H2
    MOVE 107 TO L-IX
    MOVE 72 TO L-IY
    GOBACK.
 END PROGRAM MN5-M-LABELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-LEVELNAME.
*> USING level 1 to 5, English level name out, translation key out (2.10 merchant.level.N).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-KEY                  PIC X(96).
 PROCEDURE DIVISION USING L-LEVEL L-NAME L-KEY.
    MOVE SPACES TO L-NAME L-KEY
    EVALUATE L-LEVEL
        WHEN 1
            MOVE "Novice" TO L-NAME
            MOVE "merchant.level.1" TO L-KEY
        WHEN 2
            MOVE "Apprentice" TO L-NAME
            MOVE "merchant.level.2" TO L-KEY
        WHEN 3
            MOVE "Journeyman" TO L-NAME
            MOVE "merchant.level.3" TO L-KEY
        WHEN 4
            MOVE "Expert" TO L-NAME
            MOVE "merchant.level.4" TO L-KEY
        WHEN 5
            MOVE "Master" TO L-NAME
            MOVE "merchant.level.5" TO L-KEY
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-LEVELNAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-XPBAR.
*> USING merchant level, villager xp, future xp, background drawn out, filled width out (-1 not drawn), preview width out (-1 not drawn) (2.10).
*> Thresholds 0, 10, 70, 150, 250; the scale 102 / (max - min) and the products are single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-MIN                  BINARY-LONG.
 01 W-MAX                  BINARY-LONG.
 01 W-SCALE                FLOAT-SHORT.
 01 W-V                    FLOAT-SHORT.
 01 W-DELTA                BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 01 L-FUTURE               BINARY-LONG.
 01 L-BG                   BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-XP L-FUTURE L-BG L-CUR L-W.
    MOVE 0 TO L-BG
    MOVE -1 TO L-CUR L-W
    EVALUATE TRUE
        WHEN L-LEVEL >= 5
            MOVE 0 TO L-BG
        WHEN L-LEVEL < 1
            MOVE 1 TO L-BG
        WHEN OTHER
            MOVE 1 TO L-BG
            EVALUATE L-LEVEL
                WHEN 1
                    MOVE 0 TO W-MIN
                    MOVE 10 TO W-MAX
                WHEN 2
                    MOVE 10 TO W-MIN
                    MOVE 70 TO W-MAX
                WHEN 3
                    MOVE 70 TO W-MIN
                    MOVE 150 TO W-MAX
                WHEN OTHER
                    MOVE 150 TO W-MIN
                    MOVE 250 TO W-MAX
            END-EVALUATE
            IF L-XP >= W-MIN
                COMPUTE W-DELTA = W-MAX - W-MIN
                COMPUTE W-SCALE = 102.0 / W-DELTA
                COMPUTE W-DELTA = L-XP - W-MIN
                COMPUTE W-V = W-SCALE * W-DELTA
                COMPUTE L-CUR = FUNCTION MIN(FUNCTION INTEGER(W-V), 102)
                IF L-FUTURE > 0
                    COMPUTE W-V = L-FUTURE * W-SCALE
                    COMPUTE L-W = FUNCTION MIN(FUNCTION INTEGER(W-V), 102 - L-CUR)
                END-IF
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-XPBAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-ROWTIP.
*> USING pointer x relative to the row button, second cost not empty, tooltip out (0 none, 1 first cost, 2 second cost, 3 result) (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-SECOND               BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-SECOND L-TIP.
    MOVE 0 TO L-TIP
    EVALUATE TRUE
        WHEN L-DX < 20
            MOVE 1 TO L-TIP
        WHEN L-DX > 30 AND L-DX < 50 AND L-SECOND = 1
            MOVE 2 TO L-TIP
        WHEN L-DX > 65
            MOVE 3 TO L-TIP
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-ROWTIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-M-SPRITE.
*> USING sprite (1 arrow, 2 arrow out of stock, 3 discount strike, 4 scroller, 5 scroller disabled, 6 out of stock cross, 7 xp background, 8 xp current,
*> 9 xp result), name out, size out as WxH (2.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-SIZE                 PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-NAME L-SIZE.
    MOVE SPACES TO L-NAME L-SIZE
    EVALUATE L-KIND
        WHEN 1
            MOVE "container/villager/trade_arrow" TO L-NAME
            MOVE "10x9" TO L-SIZE
        WHEN 2
            MOVE "container/villager/trade_arrow_out_of_stock" TO L-NAME
            MOVE "10x9" TO L-SIZE
        WHEN 3
            MOVE "container/villager/discount_strikethrough" TO L-NAME
            MOVE "9x2" TO L-SIZE
        WHEN 4
            MOVE "container/villager/scroller" TO L-NAME
            MOVE "6x27" TO L-SIZE
        WHEN 5
            MOVE "container/villager/scroller_disabled" TO L-NAME
            MOVE "6x27" TO L-SIZE
        WHEN 6
            MOVE "container/villager/out_of_stock" TO L-NAME
            MOVE "28x21" TO L-SIZE
        WHEN 7
            MOVE "container/villager/experience_bar_background" TO L-NAME
            MOVE "102x5" TO L-SIZE
        WHEN 8
            MOVE "container/villager/experience_bar_current" TO L-NAME
            MOVE "102x5" TO L-SIZE
        WHEN 9
            MOVE "container/villager/experience_bar_result" TO L-NAME
            MOVE "102x5" TO L-SIZE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-M-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-SLOT.
*> USING menu slot, x out, y out, part out (1 payment, 2 main inventory, 3 hotbar, 0 none) (3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-J                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-X L-Y L-PART.
    MOVE 0 TO L-X L-Y L-PART
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 136 TO L-X
            MOVE 110 TO L-Y
            MOVE 1 TO L-PART
        WHEN L-SLOT >= 1 AND L-SLOT <= 27
            COMPUTE W-J = L-SLOT - 1
            COMPUTE L-X = 36 + 18 * FUNCTION MOD(W-J, 9)
            DIVIDE W-J BY 9 GIVING W-ROW
            COMPUTE L-Y = 137 + 18 * W-ROW
            MOVE 2 TO L-PART
        WHEN L-SLOT >= 28 AND L-SLOT <= 36
            COMPUTE L-X = 36 + 18 * (L-SLOT - 28)
            MOVE 195 TO L-Y
            MOVE 3 TO L-PART
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-PAYITEM.
*> USING payment item number 1 to 5, item name out, icon x out as text (3.2, 3.7: the items of beacon_payment_items and where the screen draws them).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-X                    PIC X(96).
 PROCEDURE DIVISION USING L-N L-NAME L-X.
    MOVE SPACES TO L-NAME L-X
    EVALUATE L-N
        WHEN 1
            MOVE "netherite_ingot" TO L-NAME
            MOVE "20" TO L-X
        WHEN 2
            MOVE "emerald" TO L-NAME
            MOVE "41" TO L-X
        WHEN 3
            MOVE "diamond" TO L-NAME
            MOVE "63" TO L-X
        WHEN 4
            MOVE "gold_ingot" TO L-NAME
            MOVE "86" TO L-X
        WHEN 5
            MOVE "iron_ingot" TO L-NAME
            MOVE "108" TO L-X
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-PAYITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-TAGGED.
*> USING item name, in tag beacon_payment_items out (also mayPlace), maximum stack size out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(96).
 01 L-TAGGED               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-TAGGED L-MAX.
    MOVE 0 TO L-TAGGED
    MOVE 1 TO L-MAX
    IF L-NAME = "netherite_ingot" OR L-NAME = "emerald" OR L-NAME = "diamond" OR L-NAME = "gold_ingot"
       OR L-NAME = "iron_ingot"
        MOVE 1 TO L-TAGGED
    END-IF
    GOBACK.
 END PROGRAM MN5-B-TAGGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-ENCODE.
*> USING effect (-1 none), encoded out: 0 for none, else the registry id + 1 (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFFECT               BINARY-LONG.
 01 L-ENC                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EFFECT L-ENC.
    MOVE 0 TO L-ENC
    IF L-EFFECT >= 0
        COMPUTE L-ENC = L-EFFECT + 1
    END-IF
    GOBACK.
 END PROGRAM MN5-B-ENCODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-FILTER.
*> USING effect, filtered effect out: only a valid beacon effect stays, else -1 (3.3 filterEffect; the tiers of 3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFFECT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EFFECT L-OUT.
    MOVE -1 TO L-OUT
    IF L-EFFECT = 0 OR L-EFFECT = 2 OR L-EFFECT = 10 OR L-EFFECT = 7 OR L-EFFECT = 4 OR L-EFFECT = 9
        MOVE L-EFFECT TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN5-B-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-SETDATA.
*> USING data slot index, value, server side, the beacon has a beam, stored value out, power select sound out (3.3 set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-EFFECT               BINARY-LONG.
 01 W-FILTERED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-BEAM                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-VALUE L-SERVER L-BEAM L-STORED L-SOUND.
    MOVE 0 TO L-SOUND
    MOVE L-VALUE TO L-STORED
    IF L-INDEX NOT = 0
        COMPUTE W-EFFECT = L-VALUE - 1
        CALL "MN5-B-FILTER" USING W-EFFECT W-FILTERED
        CALL "MN5-B-ENCODE" USING W-FILTERED L-STORED
        IF L-INDEX = 1 AND L-SERVER = 1 AND L-BEAM = 1
            MOVE 1 TO L-SOUND
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN5-B-SETDATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-REQ.
*> USING effect, required pyramid levels out: 0 for none, the 1-based tier, the int maximum for an effect in no tier (3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFFECT               BINARY-LONG.
 01 L-REQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EFFECT L-REQ.
    EVALUATE TRUE
        WHEN L-EFFECT < 0
            MOVE 0 TO L-REQ
        WHEN L-EFFECT = 0 OR L-EFFECT = 2
            MOVE 1 TO L-REQ
        WHEN L-EFFECT = 10 OR L-EFFECT = 7
            MOVE 2 TO L-REQ
        WHEN L-EFFECT = 4
            MOVE 3 TO L-REQ
        WHEN L-EFFECT = 9
            MOVE 4 TO L-REQ
        WHEN OTHER
            MOVE 2147483647 TO L-REQ
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-REQ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-VALIDATE.
*> USING primary, secondary, pyramid levels, valid out (3.4 validateEffects).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-RP                   BINARY-LONG.
 01 W-RS                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PRIMARY              BINARY-LONG.
 01 L-SECONDARY            BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PRIMARY L-SECONDARY L-LEVELS L-OK.
    MOVE 0 TO L-OK
    CALL "MN5-B-REQ" USING L-PRIMARY W-RP
    CALL "MN5-B-REQ" USING L-SECONDARY W-RS
    EVALUATE TRUE
        WHEN L-SECONDARY >= 0 AND L-LEVELS < 4
            MOVE 0 TO L-OK
        WHEN W-RP > L-LEVELS OR W-RS > L-LEVELS
            MOVE 0 TO L-OK
        WHEN W-RP >= 4
            MOVE 0 TO L-OK
        WHEN W-RS NOT = 0 AND W-RS < 4 AND L-PRIMARY NOT = L-SECONDARY
            MOVE 0 TO L-OK
        WHEN OTHER
            MOVE 1 TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-VALIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-UPDATE.
*> USING has payment, primary, secondary, levels, performed out, data slot 1 out, data slot 2 out, payment used out (3.4 updateEffects).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-PRIMARY              BINARY-LONG.
 01 L-SECONDARY            BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-PRIMARY L-SECONDARY L-LEVELS L-DONE L-D1 L-D2 L-USED.
    MOVE 0 TO L-DONE L-D1 L-D2 L-USED
    CALL "MN5-B-VALIDATE" USING L-PRIMARY L-SECONDARY L-LEVELS W-OK
    IF L-HAS = 1 AND W-OK = 1
        MOVE 1 TO L-DONE
        MOVE 1 TO L-USED
        CALL "MN5-B-ENCODE" USING L-PRIMARY L-D1
        CALL "MN5-B-ENCODE" USING L-SECONDARY L-D2
    END-IF
    GOBACK.
 END PROGRAM MN5-B-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-QUICK.
*> USING source slot, stack count, payment slot empty, mayPlace accepts, range start out, range end out, reverse out, onQuickCraft out, rule out
*> (1 payment out, 2 single item in, 3 main to hotbar, 4 hotbar to main) (3.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-MAYPLACE             BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-COUNT L-EMPTY L-MAYPLACE L-START L-END L-REVERSE L-EXTRA L-RULE.
    MOVE 0 TO L-START L-END L-REVERSE L-EXTRA L-RULE
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 1 TO L-START L-REVERSE L-EXTRA L-RULE
            MOVE 37 TO L-END
        WHEN L-EMPTY = 1 AND L-MAYPLACE = 1 AND L-COUNT = 1
            MOVE 1 TO L-END
            MOVE 2 TO L-RULE
        WHEN L-SLOT >= 1 AND L-SLOT < 28
            MOVE 28 TO L-START
            MOVE 37 TO L-END
            MOVE 3 TO L-RULE
        WHEN L-SLOT >= 28 AND L-SLOT < 37
            MOVE 1 TO L-START
            MOVE 28 TO L-END
            MOVE 4 TO L-RULE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-REMOVED.
*> USING server side, payment stack not empty, drop out (3.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-HAS L-DROP.
    MOVE 0 TO L-DROP
    IF L-SERVER = 1 AND L-HAS = 1
        MOVE 1 TO L-DROP
    END-IF
    GOBACK.
 END PROGRAM MN5-B-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-BUTTON.
*> USING kind (1 primary, 2 secondary, 3 upgrade, 4 confirm, 5 cancel), tier, index in the row, x out, y out (3.7; relative to leftPos and topPos).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 01 W-W                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TIER                 BINARY-LONG.
 01 L-J                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TIER L-J L-X L-Y.
    EVALUATE L-KIND
        WHEN 1
            MOVE 2 TO W-N
            IF L-TIER = 2
                MOVE 1 TO W-N
            END-IF
            COMPUTE W-W = W-N * 22 + (W-N - 1) * 2
            DIVIDE W-W BY 2 GIVING W-H
            COMPUTE L-X = 76 + 24 * L-J - W-H
            COMPUTE L-Y = 22 + 25 * L-TIER
        WHEN 2
            COMPUTE L-X = 167 + 24 * L-J - 23
            MOVE 47 TO L-Y
        WHEN 3
            MOVE 168 TO L-X
            MOVE 47 TO L-Y
        WHEN 4
            MOVE 164 TO L-X
            MOVE 107 TO L-Y
        WHEN OTHER
            MOVE 190 TO L-X
            MOVE 107 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-BG.
*> USING inactive, selected, hovered or focused, sprite out (0 button_disabled, 1 button_selected, 2 button_highlighted, 3 button) (3.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INACTIVE             BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-HOVER                BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING L-INACTIVE L-SELECTED L-HOVER L-SPRITE.
    EVALUATE TRUE
        WHEN L-INACTIVE = 1
            MOVE 0 TO L-SPRITE
        WHEN L-SELECTED = 1
            MOVE 1 TO L-SPRITE
        WHEN L-HOVER = 1
            MOVE 2 TO L-SPRITE
        WHEN OTHER
            MOVE 3 TO L-SPRITE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-BG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-POWER.
*> USING tier, levels, button effect equals the screen's choice, active out, selected out (3.7 updateStatus of a power button).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIER                 BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-EQUAL                BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-TIER L-LEVELS L-EQUAL L-ACTIVE L-SELECTED.
    MOVE 0 TO L-ACTIVE
    MOVE L-EQUAL TO L-SELECTED
    IF L-TIER < L-LEVELS
        MOVE 1 TO L-ACTIVE
    END-IF
    GOBACK.
 END PROGRAM MN5-B-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-UPGRADE.
*> USING primary, levels, secondary equals the primary, visible out, active out, selected out (3.7 updateStatus of the upgrade button, tier 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TIER                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PRIMARY              BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-EQUAL                BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-PRIMARY L-LEVELS L-EQUAL L-VISIBLE L-ACTIVE L-SELECTED.
    MOVE 0 TO L-VISIBLE L-ACTIVE L-SELECTED
    IF L-PRIMARY >= 0
        MOVE 1 TO L-VISIBLE
        MOVE 3 TO W-TIER
        CALL "MN5-B-POWER" USING W-TIER L-LEVELS L-EQUAL L-ACTIVE L-SELECTED
    END-IF
    GOBACK.
 END PROGRAM MN5-B-UPGRADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-CONFIRM.
*> USING has payment, primary effect (-1 none), active out (3.7 updateStatus of the confirm button).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-PRIMARY              BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-PRIMARY L-ACTIVE.
    MOVE 0 TO L-ACTIVE
    IF L-HAS = 1 AND L-PRIMARY >= 0
        MOVE 1 TO L-ACTIVE
    END-IF
    GOBACK.
 END PROGRAM MN5-B-CONFIRM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-PRESS.
*> USING kind (1 primary, 2 secondary, 3 upgrade), already selected, the button's effect, screen primary, screen secondary, new primary out, new
*> secondary out (3.7 presses; the upgrade button's effect is the primary).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-EFFECT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-PRIMARY              BINARY-LONG.
 01 L-SECONDARY            BINARY-LONG.
 01 L-NP                   BINARY-LONG.
 01 L-NS                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SELECTED L-EFFECT L-PRIMARY L-SECONDARY L-NP L-NS.
    MOVE L-PRIMARY TO L-NP
    MOVE L-SECONDARY TO L-NS
    MOVE L-EFFECT TO W-EFFECT
    IF L-KIND = 3
        MOVE L-PRIMARY TO W-EFFECT
    END-IF
    EVALUATE TRUE
        WHEN L-SELECTED = 1
            MOVE L-PRIMARY TO L-NP
        WHEN L-KIND = 1
            MOVE W-EFFECT TO L-NP
            IF L-SECONDARY NOT = W-EFFECT
                MOVE -1 TO L-NS
            END-IF
        WHEN OTHER
            MOVE W-EFFECT TO L-NS
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-B-PRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-LABELTEXT.
*> USING label (1 primary, 2 secondary), translation key out, English text out (3.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-KEY                  PIC X(96).
 01 L-TEXT                 PIC X(96).
 PROCEDURE DIVISION USING L-WHICH L-KEY L-TEXT.
    MOVE SPACES TO L-KEY L-TEXT
    IF L-WHICH = 1
        MOVE "block.minecraft.beacon.primary" TO L-KEY
        MOVE "Primary Power" TO L-TEXT
    ELSE
        MOVE "block.minecraft.beacon.secondary" TO L-KEY
        MOVE "Secondary Power" TO L-TEXT
    END-IF
    GOBACK.
 END PROGRAM MN5-B-LABELTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-LABEL.
*> USING label (1 primary, 2 secondary), text width, x out, y out, colour out, shadow out (3.7; centred on x 62 or 169, colour #e0e0e0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-SHADOW               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-WIDTH L-X L-Y L-COLOUR L-SHADOW.
    DIVIDE L-WIDTH BY 2 GIVING W-H
    IF L-WHICH = 1
        COMPUTE L-X = 62 - W-H
    ELSE
        COMPUTE L-X = 169 - W-H
    END-IF
    MOVE 10 TO L-Y
    MOVE -2039584 TO L-COLOUR
    MOVE 1 TO L-SHADOW
    GOBACK.
 END PROGRAM MN5-B-LABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-EFFECTTEXT.
*> USING effect id, upgrade button, sprite name out, tooltip out (3.7: mob_effect/<name>; the upgrade tooltip adds " II").
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFFECT               BINARY-LONG.
 01 L-UPGRADE              BINARY-LONG.
 01 L-SPRITE               PIC X(96).
 01 L-TIP                  PIC X(96).
 PROCEDURE DIVISION USING L-EFFECT L-UPGRADE L-SPRITE L-TIP.
    MOVE SPACES TO L-SPRITE L-TIP
    EVALUATE L-EFFECT
        WHEN 0
            MOVE "mob_effect/speed" TO L-SPRITE
            MOVE "Speed" TO L-TIP
        WHEN 2
            MOVE "mob_effect/haste" TO L-SPRITE
            MOVE "Haste" TO L-TIP
        WHEN 10
            MOVE "mob_effect/resistance" TO L-SPRITE
            MOVE "Resistance" TO L-TIP
        WHEN 7
            MOVE "mob_effect/jump_boost" TO L-SPRITE
            MOVE "Jump Boost" TO L-TIP
        WHEN 4
            MOVE "mob_effect/strength" TO L-SPRITE
            MOVE "Strength" TO L-TIP
        WHEN 9
            MOVE "mob_effect/regeneration" TO L-SPRITE
            MOVE "Regeneration" TO L-TIP
    END-EVALUATE
    IF L-UPGRADE = 1
        STRING FUNCTION TRIM(L-TIP) " II" DELIMITED BY SIZE INTO L-TIP
    END-IF
    GOBACK.
 END PROGRAM MN5-B-EFFECTTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-B-ENDBUTTON.
*> USING button (1 confirm, 2 cancel), Set Beacon sent out, container closed out (3.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUTTON               BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-BUTTON L-SEND L-CLOSE.
    MOVE 0 TO L-SEND
    MOVE 1 TO L-CLOSE
    IF L-BUTTON = 1
        MOVE 1 TO L-SEND
    END-IF
    GOBACK.
 END PROGRAM MN5-B-ENDBUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-SLOT.
*> USING slot, x out, y out, Slot.mayPlace out, the book container's canPlaceItem out (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MAYPLACE             BINARY-LONG.
 01 L-CANPLACE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-X L-Y L-MAYPLACE L-CANPLACE.
    MOVE 0 TO L-X L-Y L-CANPLACE
    MOVE 1 TO L-MAYPLACE
    GOBACK.
 END PROGRAM MN5-L-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-PAGECOUNT.
*> USING written book present, its pages, writable book present, its pages, page count out (4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WP                   BINARY-LONG.
 01 L-WN                   BINARY-LONG.
 01 L-RP                   BINARY-LONG.
 01 L-RN                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-WP L-WN L-RP L-RN L-COUNT.
    MOVE 0 TO L-COUNT
    EVALUATE TRUE
        WHEN L-WP = 1
            MOVE L-WN TO L-COUNT
        WHEN L-RP = 1
            MOVE L-RN TO L-COUNT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-L-PAGECOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-HASBOOK.
*> USING has written_book_content, has writable_book_content, has book out (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WRITTEN              BINARY-LONG.
 01 L-WRITABLE             BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WRITTEN L-WRITABLE L-HAS.
    MOVE 0 TO L-HAS
    IF L-WRITTEN = 1 OR L-WRITABLE = 1
        MOVE 1 TO L-HAS
    END-IF
    GOBACK.
 END PROGRAM MN5-L-HASBOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-VALID.
*> USING block entity at its position, player in range, the lectern has a book, valid out (4.2 stillValid).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-RANGE L-BOOK L-OK.
    MOVE 0 TO L-OK
    IF L-BLOCK = 1 AND L-RANGE = 1 AND L-BOOK = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN5-L-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-CLAMP.
*> USING value, page count, stored page, clamped page out, changed out (4.3 set on data slot 0: 0 .. page count - 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-PAGE                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-COUNT L-STORED L-PAGE L-CHANGED.
    MOVE L-VALUE TO L-PAGE
    IF L-PAGE < 0
        MOVE 0 TO L-PAGE
    END-IF
    IF L-PAGE > L-COUNT - 1
        COMPUTE L-PAGE = L-COUNT - 1
    END-IF
    MOVE 0 TO L-CHANGED
    IF L-PAGE NOT = L-STORED
        MOVE 1 TO L-CHANGED
    END-IF
    GOBACK.
 END PROGRAM MN5-L-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-BUTTON.
*> USING button id, current page, page count, mayBuild, result out, new page out, take the book out (4.4 clickMenuButton).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-VALUE                BINARY-LONG.
 01 W-CHANGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PAGE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-MAYBUILD             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-TAKE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PAGE L-COUNT L-MAYBUILD L-RESULT L-NEW L-TAKE.
    MOVE 0 TO L-RESULT L-TAKE
    MOVE L-PAGE TO L-NEW
    EVALUATE TRUE
        WHEN L-ID >= 100
            COMPUTE W-VALUE = L-ID - 100
            CALL "MN5-L-CLAMP" USING W-VALUE L-COUNT L-PAGE L-NEW W-CHANGED
            MOVE 1 TO L-RESULT
        WHEN L-ID = 1
            COMPUTE W-VALUE = L-PAGE - 1
            CALL "MN5-L-CLAMP" USING W-VALUE L-COUNT L-PAGE L-NEW W-CHANGED
            MOVE 1 TO L-RESULT
        WHEN L-ID = 2
            COMPUTE W-VALUE = L-PAGE + 1
            CALL "MN5-L-CLAMP" USING W-VALUE L-COUNT L-PAGE L-NEW W-CHANGED
            MOVE 1 TO L-RESULT
        WHEN L-ID = 3
            MOVE L-MAYBUILD TO L-RESULT L-TAKE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-L-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-TAKE.
*> USING the inventory can take the book, added out, dropped out (4.4 take book).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FITS                 BINARY-LONG.
 01 L-ADDED                BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-FITS L-ADDED L-DROPPED.
    MOVE L-FITS TO L-ADDED
    COMPUTE L-DROPPED = 1 - L-FITS
    GOBACK.
 END PROGRAM MN5-L-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-QUICK.
*> USING slot, moved count out: quickMoveStack always returns the empty stack (4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-MOVED.
    MOVE 0 TO L-MOVED
    GOBACK.
 END PROGRAM MN5-L-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-SIGNAL.
*> USING has book, page, page count, comparator signal out (4.6: floor(14 x f) + 1 with f = page / (pages - 1), 1.0 for a single page; single precision).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-F                    FLOAT-SHORT.
 01 W-P                    FLOAT-SHORT.
 01 W-N                    FLOAT-SHORT.
 01 W-V                    FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-PAGE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-PAGE L-COUNT L-SIGNAL.
    MOVE 0 TO L-SIGNAL
    IF L-HAS = 1
        MOVE 1.0 TO W-F
        IF L-COUNT > 1
            MOVE L-PAGE TO W-P
            COMPUTE W-N = L-COUNT - 1
            COMPUTE W-F = W-P / W-N
        END-IF
        COMPUTE W-V = 14 * W-F
        COMPUTE L-SIGNAL = FUNCTION INTEGER(W-V) + 1
    END-IF
    GOBACK.
 END PROGRAM MN5-L-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-LAYOUT.
*> USING window width, backgroundLeft out, page text x out, indicator right x out, forward x out, back x out, 200-wide Done x out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TEXT                 BINARY-LONG.
 01 L-IND                  BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-BACK                 BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-LEFT L-TEXT L-IND L-FWD L-BACK L-DONE.
    COMPUTE L-LEFT = (L-WIDTH - 192) / 2
    COMPUTE L-TEXT = L-LEFT + 36
    COMPUTE L-IND = L-LEFT + 148
    COMPUTE L-FWD = L-LEFT + 116
    COMPUTE L-BACK = L-LEFT + 43
    COMPUTE L-DONE = (L-WIDTH - 200) / 2
    GOBACK.
 END PROGRAM MN5-L-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-LAYOUTY.
*> USING line index, line y out, indicator y out, page button y out, background top out, menu controls top out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LINE                 BINARY-LONG.
 01 L-LY                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-CONTROLS             BINARY-LONG.
 PROCEDURE DIVISION USING L-LINE L-LY L-IY L-BY L-TOP L-CONTROLS.
    COMPUTE L-LY = 32 + 9 * L-LINE
    MOVE 18 TO L-IY
    MOVE 159 TO L-BY
    MOVE 2 TO L-TOP
    COMPUTE L-CONTROLS = L-TOP + 192 + 2
    GOBACK.
 END PROGRAM MN5-L-LAYOUTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-LINES.
*> USING lines of the split page, lines drawn out (4.7: at most 128 / 9 = 14).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LINES                BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-LINES L-SHOWN.
    MOVE L-LINES TO L-SHOWN
    IF L-SHOWN > 14
        MOVE 14 TO L-SHOWN
    END-IF
    GOBACK.
 END PROGRAM MN5-L-LINES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-INDICATOR.
*> USING page, page count, shown page out, shown total out (4.7 Page %1 of %2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGE L-COUNT L-SHOWN L-TOTAL.
    COMPUTE L-SHOWN = L-PAGE + 1
    MOVE L-COUNT TO L-TOTAL
    IF L-TOTAL < 1
        MOVE 1 TO L-TOTAL
    END-IF
    GOBACK.
 END PROGRAM MN5-L-INDICATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-VIS.
*> USING page, page count, forward visible out, back visible out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-BACK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGE L-COUNT L-FWD L-BACK.
    MOVE 0 TO L-FWD L-BACK
    IF L-PAGE < L-COUNT - 1
        MOVE 1 TO L-FWD
    END-IF
    IF L-PAGE > 0
        MOVE 1 TO L-BACK
    END-IF
    GOBACK.
 END PROGRAM MN5-L-VIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-SETBOOK.
*> USING page, page count, clamped page out (4.7 setBookAccess clamps into 0 .. page count).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGE L-COUNT L-OUT.
    MOVE L-PAGE TO L-OUT
    IF L-OUT < 0
        MOVE 0 TO L-OUT
    END-IF
    IF L-OUT > L-COUNT
        MOVE L-COUNT TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN5-L-SETBOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-SETPAGE.
*> USING page, current page, page count, clamped page out, changed out (4.7 setPage clamps into 0 .. page count - 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGE                 BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGE L-CURRENT L-COUNT L-OUT L-CHANGED.
    CALL "MN5-L-CLAMP" USING L-PAGE L-COUNT L-CURRENT L-OUT L-CHANGED
    GOBACK.
 END PROGRAM MN5-L-SETPAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-KEY.
*> USING key code, button pressed out (1 back for 1073741899, 2 forward for 1073741902, else 0) (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-BUTTON.
    MOVE 0 TO L-BUTTON
    EVALUATE L-CODE
        WHEN 1073741899
            MOVE 1 TO L-BUTTON
        WHEN 1073741902
            MOVE 2 TO L-BUTTON
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-L-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-TEXTCLICK.
*> USING mouse button, click event (0 none, 1 change page, 2 run command, 3 other), event page (1-based), handled out, action out (0 none, 1 forcePage,
*> 2 run command after closing the container, 3 default handling), target page out (4.7 text clicks).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUTTON               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-PAGE                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-BUTTON L-EVENT L-PAGE L-HANDLED L-ACTION L-TARGET.
    MOVE 0 TO L-HANDLED L-ACTION L-TARGET
    IF L-BUTTON = 1 AND L-EVENT > 0
        MOVE 1 TO L-HANDLED
        MOVE L-EVENT TO L-ACTION
        IF L-EVENT = 1
            COMPUTE L-TARGET = L-PAGE - 1
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN5-L-TEXTCLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-FORCE.
*> USING page, the menu's page, sent out, button id out (4.7 forcePage on the lectern screen).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGE                 BINARY-LONG.
 01 L-MENU                 BINARY-LONG.
 01 L-SENT                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGE L-MENU L-SENT L-ID.
    MOVE 0 TO L-SENT L-ID
    IF L-PAGE NOT = L-MENU
        MOVE 1 TO L-SENT
        COMPUTE L-ID = 100 + L-PAGE
    END-IF
    GOBACK.
 END PROGRAM MN5-L-FORCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-CONTROLS.
*> USING mayBuild, window width, buttons out, Done x out, Done width out, Take Book x out, Take Book width out (4.7 createMenuControls; y 196).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAYBUILD             BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DW                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MAYBUILD L-WIDTH L-COUNT L-DX L-DW L-TX L-TW.
    DIVIDE L-WIDTH BY 2 GIVING W-H
    IF L-MAYBUILD = 1
        MOVE 2 TO L-COUNT
        COMPUTE L-DX = W-H - 98 - 2
        MOVE 98 TO L-DW
        COMPUTE L-TX = W-H + 2
        MOVE 98 TO L-TW
    ELSE
        MOVE 1 TO L-COUNT
        COMPUTE L-DX = (L-WIDTH - 200) / 2
        MOVE 200 TO L-DW
        MOVE 0 TO L-TX L-TW
    END-IF
    GOBACK.
 END PROGRAM MN5-L-CONTROLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-PAGEPRESS.
*> USING lectern screen, page button (1 back, 2 forward), button id sent out, local page change out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LECTERN              BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LOCAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-LECTERN L-BUTTON L-ID L-LOCAL.
    MOVE 0 TO L-ID L-LOCAL
    IF L-LECTERN = 1
        MOVE L-BUTTON TO L-ID
    ELSE
        MOVE 1 TO L-LOCAL
    END-IF
    GOBACK.
 END PROGRAM MN5-L-PAGEPRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-LISTEN.
*> USING change (1 slot, 2 data), the slot holds a book, action out (1 rebuild the access from the book, 2 the empty access, 3 setPage) (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BOOK L-ACTION.
    EVALUATE TRUE
        WHEN L-KIND = 1 AND L-BOOK = 1
            MOVE 1 TO L-ACTION
        WHEN L-KIND = 1
            MOVE 2 TO L-ACTION
        WHEN OTHER
            MOVE 3 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN5-L-LISTEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN5-L-TURNSOUND.
*> USING lectern screen, page turn sound out (4.7: only the plain book screen plays it).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LECTERN              BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-LECTERN L-SOUND.
    MOVE 1 TO L-SOUND
    IF L-LECTERN = 1
        MOVE 0 TO L-SOUND
    END-IF
    GOBACK.
 END PROGRAM MN5-L-TURNSOUND.
