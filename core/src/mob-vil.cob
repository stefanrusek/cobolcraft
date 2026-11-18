*> The live state of villagers and wandering traders (docs/protocol/19-mobs-land-friendly-and-neutral.md sections 22 and 23; lane 002-lane-mobsb). The side table is VILSTATE.cpy
*> (one entry per entity id); the rules are the VIL- programs of mob-19-22.cob.
*>
*>   VL-FIND USING entity id, create (0/1), slot out (0 none)      the entry of an entity (a new one is zeroed: plains, no profession, level 1)
*>   VL-SETUP USING entity id, kind (1 villager, 2 wandering trader), villager type, slot out    a new villager or trader (the trader builds its three sets at once)
*>   VL-ENSURE USING slot                                          the offers of the current level exist (lazy, 22.4)
*>   VL-CLAIM USING slot, workstation block key (X(32)), changed out   22.2 / 22.7: a villager without profession takes the one of the workstation
*>   VL-XP USING slot, xp gained, levels gained out                22.2 experience and level-ups (each adds the trade set of the new level)
*>   VL-TRADE USING slot, offer (1 based), ok out                  22.4 take: out of stock refuses, else uses + 1 and the xp of the offer (levelling follows)
*>   VL-RESTOCK USING slot, game time, did out                     22.4 restock: demand updated, uses reset, at most twice a day
*>   VL-OFFER-COST USING slot, offer, special, price item out (X(32)), count out    the first price of an offer with the demand and special price
*>   VL-REMOVE USING entity id                                     the entity is gone
*>   VIL-PROF-ID USING profession key (X(16)), registry id out     the villager_profession id (46 section 6.2), the VillagerData of Set Entity Data

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-MAX OR L-SLOT > 0
         IF VL-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-MAX OR L-SLOT > 0
             IF VL-ID(WS-I) = 0
                 MOVE WS-I TO L-SLOT
                 INITIALIZE VL-ENTRY(WS-I)
                 MOVE L-ID TO VL-ID(WS-I)
                 MOVE 1 TO VL-KIND(WS-I) VL-LEVEL(WS-I)
                 MOVE 2 TO VL-TYPE(WS-I)
                 MOVE "none" TO VL-PROF(WS-I)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM VL-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "VL-FIND" USING L-ID WS-NO WS-SLOT
     CALL "VG-FORGET" USING L-ID
     CALL "VP-RELEASE" USING L-ID
     IF WS-SLOT > 0
         INITIALIZE VL-ENTRY(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM VL-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-ADD-SET.
*> USING slot, set level: the offers of the trade set of the villager's profession at that level are appended (VIL-OFFER-PICK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-ROWS.
    05 WS-R                 BINARY-LONG OCCURS 5 TIMES.
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SALT                 BINARY-LONG.
 01 WS-SALT2                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-LEVEL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-LEVEL.
     COMPUTE WS-SALT = VL-ID(L-SLOT) * 31 + L-LEVEL * 7 + VL-O-N(L-SLOT)
     CALL "VIL-OFFER-PICK" USING VL-PROF(L-SLOT) L-LEVEL VL-TYPE(L-SLOT) WS-SALT WS-ROWS WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR VL-O-N(L-SLOT) >= 16
         ADD 1 TO VL-O-N(L-SLOT)
         MOVE WS-R(WS-I) TO VL-O-ROW(L-SLOT, VL-O-N(L-SLOT))
         MOVE 0 TO VL-O-USES(L-SLOT, VL-O-N(L-SLOT)) VL-O-DEMAND(L-SLOT, VL-O-N(L-SLOT))
         MOVE 0 TO VL-O-SPECIAL(L-SLOT, VL-O-N(L-SLOT))
         COMPUTE WS-SALT2 = WS-SALT * 7 + WS-I
         CALL "VIL-ROW-STACK" USING WS-R(WS-I) WS-SALT2 VL-O-EXTRA(L-SLOT, VL-O-N(L-SLOT)) VL-O-VAR(L-SLOT, VL-O-N(L-SLOT))
     END-PERFORM
     GOBACK.
 END PROGRAM VL-ADD-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-L                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-KIND L-TYPE L-SLOT.
     CALL "VL-FIND" USING L-ID WS-YES L-SLOT
     IF L-SLOT > 0
         MOVE L-KIND TO VL-KIND(L-SLOT)
         MOVE L-TYPE TO VL-TYPE(L-SLOT)
         IF L-KIND = 2
             MOVE "wandering_trader" TO VL-PROF(L-SLOT)
             PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 3
                 CALL "VL-ADD-SET" USING L-SLOT WS-L
             END-PERFORM
             MOVE 1 TO VL-BUILT(L-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-ENSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-L                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     IF VL-KIND(L-SLOT) = 1 AND VL-PROF(L-SLOT) NOT = "none" AND VL-PROF(L-SLOT) NOT = "nitwit"
         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > VL-LEVEL(L-SLOT)
             IF VL-BUILT(L-SLOT) < WS-L
                 CALL "VL-ADD-SET" USING L-SLOT WS-L
                 MOVE WS-L TO VL-BUILT(L-SLOT)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM VL-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CLAIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-PROF                 PIC X(16).
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-KEY                   PIC X(32).
 01 L-CHANGED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-KEY L-CHANGED.
     MOVE 0 TO L-CHANGED
     CALL "VIL-PROFESSION" USING L-KEY WS-PROF
     IF VL-KIND(L-SLOT) = 1 AND VL-PROF(L-SLOT) = "none" AND WS-PROF NOT = "none"
         MOVE WS-PROF TO VL-PROF(L-SLOT)
         MOVE 1 TO VL-LEVEL(L-SLOT) L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM VL-CLAIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-XP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-UP                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-XP                    BINARY-LONG.
 01 L-LEVELS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-XP L-LEVELS.
     MOVE 0 TO L-LEVELS
     ADD L-XP TO VL-XP(L-SLOT)
     CALL "VL-ENSURE" USING L-SLOT
     CALL "VIL-LEVEL-UP" USING VL-LEVEL(L-SLOT) VL-XP(L-SLOT) WS-UP
     PERFORM UNTIL WS-UP = 0
         ADD 1 TO VL-LEVEL(L-SLOT) L-LEVELS
         CALL "VL-ENSURE" USING L-SLOT
         CALL "VIL-LEVEL-UP" USING VL-LEVEL(L-SLOT) VL-XP(L-SLOT) WS-UP
     END-PERFORM
     GOBACK.
 END PROGRAM VL-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRADE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-WANT                 PIC X(32).
 01 WS-EXTRA                PIC X(32).
 01 WS-GIVE                 PIC X(32).
 01 WS-WC                   BINARY-LONG.
 01 WS-EC                   BINARY-LONG.
 01 WS-GC                   BINARY-LONG.
 01 WS-MU                   BINARY-LONG.
 01 WS-XPV                  BINARY-LONG.
 01 WS-MULT                 BINARY-LONG.
 01 WS-MASK                 BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-LV                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-OFFER                 BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-OFFER L-OK.
     MOVE 0 TO L-OK
     IF L-OFFER < 1 OR L-OFFER > VL-O-N(L-SLOT)
         GOBACK
     END-IF
     CALL "VIL-TRADE-ROW" USING VL-O-ROW(L-SLOT, L-OFFER) WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
     IF VL-O-USES(L-SLOT, L-OFFER) < WS-MU
         ADD 1 TO VL-O-USES(L-SLOT, L-OFFER)
         MOVE 1 TO L-OK
         IF VL-KIND(L-SLOT) = 1
             CALL "VL-XP" USING L-SLOT WS-XPV WS-LV
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-TRADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-RESTOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-WANT                 PIC X(32).
 01 WS-EXTRA                PIC X(32).
 01 WS-GIVE                 PIC X(32).
 01 WS-WC                   BINARY-LONG.
 01 WS-EC                   BINARY-LONG.
 01 WS-GC                   BINARY-LONG.
 01 WS-MU                   BINARY-LONG.
 01 WS-XPV                  BINARY-LONG.
 01 WS-MULT                 BINARY-LONG.
 01 WS-MASK                 BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-NEEDS                BINARY-LONG.
 01 WS-ALLOWED              BINARY-LONG.
 01 WS-NEWD                 BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TIME                  BINARY-LONG.
 01 L-DID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TIME L-DID.
     MOVE 0 TO L-DID WS-NEEDS
     IF L-TIME > VL-LAST-RESTOCK(L-SLOT) + 12000
         MOVE L-TIME TO VL-LAST-RESTOCK(L-SLOT)
         MOVE 0 TO VL-RESTOCKS(L-SLOT)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-O-N(L-SLOT)
         IF VL-O-USES(L-SLOT, WS-I) > 0
             MOVE 1 TO WS-NEEDS
         END-IF
     END-PERFORM
     CALL "VIL-RESTOCK" USING L-TIME VL-LAST-RESTOCK(L-SLOT) VL-RESTOCKS(L-SLOT) WS-NEEDS WS-ALLOWED
     IF WS-ALLOWED = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-O-N(L-SLOT)
             CALL "VIL-TRADE-ROW" USING VL-O-ROW(L-SLOT, WS-I) WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
             CALL "VIL-DEMAND" USING VL-O-USES(L-SLOT, WS-I) WS-MU VL-O-DEMAND(L-SLOT, WS-I) WS-NEWD
             MOVE WS-NEWD TO VL-O-DEMAND(L-SLOT, WS-I)
             MOVE 0 TO VL-O-USES(L-SLOT, WS-I)
         END-PERFORM
         MOVE L-TIME TO VL-LAST-RESTOCK(L-SLOT)
         ADD 1 TO VL-RESTOCKS(L-SLOT)
         MOVE 1 TO L-DID
     END-IF
     GOBACK.
 END PROGRAM VL-RESTOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-OFFER-COST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-EXTRA                PIC X(32).
 01 WS-GIVE                 PIC X(32).
 01 WS-WC                   BINARY-LONG.
 01 WS-EC                   BINARY-LONG.
 01 WS-GC                   BINARY-LONG.
 01 WS-MU                   BINARY-LONG.
 01 WS-XPV                  BINARY-LONG.
 01 WS-MULT                 BINARY-LONG.
 01 WS-MASK                 BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-BASE                 BINARY-LONG.
 01 WS-STACK                BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-OFFER                 BINARY-LONG.
 01 L-SPECIAL               BINARY-LONG.
 01 L-ITEM                  PIC X(32).
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-OFFER L-SPECIAL L-ITEM L-COUNT.
     CALL "VIL-TRADE-ROW" USING VL-O-ROW(L-SLOT, L-OFFER) L-ITEM WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
     COMPUTE WS-BASE = WS-WC + VL-O-EXTRA(L-SLOT, L-OFFER)
     CALL "VIL-PRICE" USING WS-BASE VL-O-DEMAND(L-SLOT, L-OFFER) WS-MULT L-SPECIAL WS-STACK L-COUNT
     GOBACK.
 END PROGRAM VL-OFFER-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRADE-ORB.
*> USING villager entity id, levelled up (0/1): rewardTradeXp (19 section 22.2): an experience orb of 3 + nextInt(4) (+5 when the villager levelled up) at the villager, y + 0.5.
*> Every offer is taken to reward experience (the rewardExp default true; no document names a trade with the flag off).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                 BINARY-LONG VALUE 71.
 01 WS-FOUR                 BINARY-LONG VALUE 4.
 01 WS-R                    BINARY-LONG.
 01 WS-VALUE                BINARY-LONG.
 01 WS-ROW                  BINARY-LONG.
 01 WS-ORB                  BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-LEVELLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-LEVELLED.
     CALL "MERCHANT-ENTITY" USING L-ID WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-FOUR WS-R
     COMPUTE WS-VALUE = 3 + WS-R
     IF L-LEVELLED = 1
         ADD 5 TO WS-VALUE
     END-IF
     MOVE EN-X(WS-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(WS-ROW) + 0.5
     MOVE EN-Z(WS-ROW) TO WS-Z
     CALL "XP-ORB-SPAWN" USING EN-DIM(WS-ROW) WS-X WS-Y WS-Z WS-VALUE WS-ORB
     GOBACK.
 END PROGRAM VL-TRADE-ORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BIOME-TYPE-AT.
*> USING entity row, villager type out: VillagerType.byBiome (19 section 22.1) of the biome cell of the entity's position; a chunk that is not loaded gives plains.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBSPAWN.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-BIOME                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TYPE.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "MS6-BIOME-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-BIOME
     MOVE SPB-NAME(WS-BIOME) TO WS-KEY
     CALL "VIL-BIOME-TYPE" USING WS-KEY L-TYPE
     GOBACK.
 END PROGRAM VL-BIOME-TYPE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-PROF-ID.
*> USING profession key (X(16)), registry id out: the villager_profession registry id of a profession (docs/protocol/46 section 6.2); 0 for none and for any key that is not listed.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROF                  PIC X(16).
 01 L-ID                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PROF L-ID.
     EVALUATE L-PROF
         WHEN "armorer"
             MOVE 1 TO L-ID
         WHEN "butcher"
             MOVE 2 TO L-ID
         WHEN "cartographer"
             MOVE 3 TO L-ID
         WHEN "cleric"
             MOVE 4 TO L-ID
         WHEN "farmer"
             MOVE 5 TO L-ID
         WHEN "fisherman"
             MOVE 6 TO L-ID
         WHEN "fletcher"
             MOVE 7 TO L-ID
         WHEN "leatherworker"
             MOVE 8 TO L-ID
         WHEN "librarian"
             MOVE 9 TO L-ID
         WHEN "mason"
             MOVE 10 TO L-ID
         WHEN "nitwit"
             MOVE 11 TO L-ID
         WHEN "shepherd"
             MOVE 12 TO L-ID
         WHEN "toolsmith"
             MOVE 13 TO L-ID
         WHEN "weaponsmith"
             MOVE 14 TO L-ID
         WHEN OTHER
             MOVE 0 TO L-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-PROF-ID.
