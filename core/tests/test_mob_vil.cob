*> Implementation test (lane 002-lane-mobsb; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 22 and 23): the live state of a villager and a wandering trader: lazy offers
*> by profession and level, workstation claiming, trade xp and level-ups, uses and restock with demand, the price with demand and special price, the villager species row.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-VIL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY VILSTATE.
 COPY STDMOBS.
 01 WS-NAME               PIC X(90).
 01 WS-E                  BINARY-LONG.
 01 WS-O                  BINARY-LONG.
 01 WS-ID                 BINARY-LONG.
 01 WS-SLOT               BINARY-LONG.
 01 WS-S2                 BINARY-LONG.
 01 WS-X                  BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-KEY                PIC X(32).
 01 WS-KEY24              PIC X(24).
 01 WS-ITEM               PIC X(32).
 01 WS-A1                 BINARY-LONG.
 01 WS-A2                 BINARY-LONG.
 01 WS-A3                 BINARY-LONG.
 01 WS-A4                 BINARY-LONG.
 01 WS-A5                 BINARY-LONG.
 01 WS-ITEM2              PIC X(32).
 01 WS-ITEM3              PIC X(32).
 01 WS-ZERO               BINARY-LONG VALUE 0.
 01 WS-ONE                BINARY-LONG VALUE 1.
 01 WS-TWO                BINARY-LONG VALUE 2.
 01 WS-DID                BINARY-LONG.
 01 WS-TIME               BINARY-LONG.
 01 WS-MID                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SM-HEALTH(SM-COUNT - 2) TO WS-O
     MOVE 20 TO WS-E
     MOVE "acceptance US15 19§22.1 the villager row (third from last since T8802) has 20 health" TO WS-NAME
     PERFORM CHECK-N
*>   A villager with no profession has no offers; a workstation gives it one.
     MOVE 501 TO WS-ID
     CALL "VL-SETUP" USING WS-ID WS-ONE WS-TWO WS-SLOT
     CALL "VL-ENSURE" USING WS-SLOT
     MOVE 0 TO WS-E
     MOVE VL-O-N(WS-SLOT) TO WS-O
     MOVE "acceptance US15 19§22.4 a villager without a profession has no offers" TO WS-NAME
     PERFORM CHECK-N
     MOVE "stone" TO WS-KEY
     CALL "VL-CLAIM" USING WS-SLOT WS-KEY WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.7 stone is no workstation" TO WS-NAME
     PERFORM CHECK-N
     MOVE "lectern" TO WS-KEY
     CALL "VL-CLAIM" USING WS-SLOT WS-KEY WS-O
     MOVE 1 TO WS-E
     MOVE "acceptance US15 19§22.7 a lectern makes a librarian" TO WS-NAME
     PERFORM CHECK-N
     MOVE "loom" TO WS-KEY
     CALL "VL-CLAIM" USING WS-SLOT WS-KEY WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.7 a villager with a profession keeps it" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-ENSURE" USING WS-SLOT
     MOVE 2 TO WS-E
     MOVE VL-O-N(WS-SLOT) TO WS-O
     MOVE "acceptance US15 19§22.4 a novice librarian has 2 offers" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-ENSURE" USING WS-SLOT
     MOVE "acceptance US15 19§22.4 the offers are built once" TO WS-NAME
     PERFORM CHECK-N
*>   Trading: max uses, xp, level-up at 10 xp (a librarian trade of level 1 gives 1 or 2 xp).
     MOVE VL-O-USES(WS-SLOT, 1) TO WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.4 a new offer is unused" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "VL-TRADE" USING WS-SLOT WS-ONE WS-Y
         ADD WS-Y TO WS-OK
     END-PERFORM
     CALL "VIL-TRADE-ROW" USING VL-O-ROW(WS-SLOT, 1) WS-ITEM WS-X WS-ITEM2 WS-Y WS-ITEM3 WS-A1 WS-E WS-A2 WS-A3 WS-A4 WS-A5
     MOVE WS-OK TO WS-O
     MOVE "acceptance US15 19§22.4 an offer can be used up to its max uses" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-TRADE" USING WS-SLOT WS-ZERO WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.4 offer 0 does not exist" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-E
     IF VL-LEVEL(WS-SLOT) >= 2
         MOVE 1 TO WS-O
     ELSE
         MOVE 0 TO WS-O
     END-IF
     MOVE "acceptance US15 19§22.2 enough xp makes an apprentice" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-XP" USING WS-SLOT WS-ZERO WS-O
*>   Experience: 5 xp is not enough (level 1), 70 takes it to level 3 and adds the sets of levels 2 and 3.
     MOVE 502 TO WS-ID
     CALL "VL-SETUP" USING WS-ID WS-ONE WS-TWO WS-S2
     MOVE "armorer" TO VL-PROF(WS-S2)
     CALL "VL-ENSURE" USING WS-S2
     MOVE 5 TO WS-X
     CALL "VL-XP" USING WS-S2 WS-X WS-O
     MOVE 0 TO WS-E
     MOVE "acceptance US15 19§22.2 5 xp gives no level" TO WS-NAME
     PERFORM CHECK-N
     MOVE 70 TO WS-X
     CALL "VL-XP" USING WS-S2 WS-X WS-O
     MOVE 2 TO WS-E
     MOVE "acceptance US15 19§22.2 75 xp gives two levels" TO WS-NAME
     PERFORM CHECK-N
     MOVE 3 TO WS-E
     MOVE VL-LEVEL(WS-S2) TO WS-O
     MOVE "acceptance US15 19§22.2 the armorer is a journeyman" TO WS-NAME
     PERFORM CHECK-N
     MOVE 6 TO WS-E
     MOVE VL-O-N(WS-S2) TO WS-O
     MOVE "acceptance US15 19§22.4 three levels of two offers each" TO WS-NAME
     PERFORM CHECK-N
*>   Restock: used offers get their demand updated and their uses reset, twice a day at most.
     MOVE 3000 TO WS-TIME
     CALL "VL-TRADE" USING WS-S2 WS-ONE WS-Y
     CALL "VL-RESTOCK" USING WS-S2 WS-TIME WS-DID
     MOVE 1 TO WS-E
     MOVE WS-DID TO WS-O
     MOVE "acceptance US15 19§22.4 the first restock of the day happens" TO WS-NAME
     PERFORM CHECK-N
     MOVE 0 TO WS-E
     MOVE VL-O-USES(WS-S2, 1) TO WS-O
     MOVE "acceptance US15 19§22.4 a restock resets the uses" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-RESTOCK" USING WS-S2 WS-TIME WS-DID
     MOVE 0 TO WS-E
     MOVE WS-DID TO WS-O
     MOVE "acceptance US15 19§22.4 nothing is used so no restock follows" TO WS-NAME
     PERFORM CHECK-N
*>   Cost: base + demand adjustment + special, at least 1 and at most 64.
     MOVE 0 TO WS-X
     MOVE 1 TO VL-O-DEMAND(WS-S2, 1)
     CALL "VL-OFFER-COST" USING WS-S2 WS-ONE WS-X WS-ITEM WS-O
     MOVE "acceptance US15 19§22.4 the offer cost is positive" TO WS-NAME
     MOVE 1 TO WS-E
     IF WS-O > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   The wandering trader builds its sets at once: 2 buying + 2 uncommon + 5 common = 9 offers.
     MOVE 503 TO WS-ID
     CALL "VL-SETUP" USING WS-ID WS-TWO WS-ZERO WS-S2
     MOVE 9 TO WS-E
     MOVE VL-O-N(WS-S2) TO WS-O
     MOVE "acceptance US15 19§23 the wandering trader has 9 offers" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-FIND" USING WS-ID WS-ZERO WS-MID
     MOVE WS-S2 TO WS-E
     MOVE WS-MID TO WS-O
     MOVE "acceptance US15 19§22 an entity keeps its entry" TO WS-NAME
     PERFORM CHECK-N
     CALL "VL-REMOVE" USING WS-ID
     CALL "VL-FIND" USING WS-ID WS-ZERO WS-MID
     MOVE 0 TO WS-E
     MOVE WS-MID TO WS-O
     MOVE "acceptance US15 19§22 a removed entity has no entry" TO WS-NAME
     PERFORM CHECK-N
     MOVE 1 TO WS-O
     MOVE 777 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-MAX
         ADD 1 TO WS-ID
         CALL "VL-SETUP" USING WS-ID WS-ONE WS-TWO WS-MID
     END-PERFORM
     MOVE 0 TO WS-E
     MOVE WS-MID TO WS-O
     MOVE "acceptance US15 19§22 a full table gives no entry" TO WS-NAME
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-VIL.
