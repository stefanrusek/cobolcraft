*> Admiring and bartering behaviours (docs/protocol/44-residual-mob-questions-6-nether.md section 3; lane 002-lane-p49c, T15520): the predicates of 3.1 (barter
*> currency, the 28 loved keys, canAdmire) and the pick-up rules of 3.2 (mob_griefing, ADMIRING_DISABLED with an attack target, the whole nugget stack, one porkchop eaten
*> with ATE_RECENTLY 200, a loved item admired for 119 ticks).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-K24                 PIC X(24).
 01 WS-K32                 PIC X(32).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-NUGGET              BINARY-LONG.
 01 WS-PORK                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-ADULT               BINARY-LONG.
 01 WS-ADM                 BINARY-LONG.
 01 WS-DIS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RNAME               PIC X(40) VALUE "mob_griefing".
 01 WS-RINDEX              BINARY-LONG.
 01 WS-RVALUE              BINARY-DOUBLE.
 01 WS-LOVED-LIST.
    05 FILLER PIC X(32) VALUE "gold_ore".
    05 FILLER PIC X(32) VALUE "deepslate_gold_ore".
    05 FILLER PIC X(32) VALUE "nether_gold_ore".
    05 FILLER PIC X(32) VALUE "gold_block".
    05 FILLER PIC X(32) VALUE "gilded_blackstone".
    05 FILLER PIC X(32) VALUE "light_weighted_pressure_plate".
    05 FILLER PIC X(32) VALUE "gold_ingot".
    05 FILLER PIC X(32) VALUE "bell".
    05 FILLER PIC X(32) VALUE "clock".
    05 FILLER PIC X(32) VALUE "golden_carrot".
    05 FILLER PIC X(32) VALUE "glistering_melon_slice".
    05 FILLER PIC X(32) VALUE "golden_apple".
    05 FILLER PIC X(32) VALUE "enchanted_golden_apple".
    05 FILLER PIC X(32) VALUE "golden_helmet".
    05 FILLER PIC X(32) VALUE "golden_chestplate".
    05 FILLER PIC X(32) VALUE "golden_leggings".
    05 FILLER PIC X(32) VALUE "golden_boots".
    05 FILLER PIC X(32) VALUE "golden_horse_armor".
    05 FILLER PIC X(32) VALUE "golden_nautilus_armor".
    05 FILLER PIC X(32) VALUE "golden_sword".
    05 FILLER PIC X(32) VALUE "golden_spear".
    05 FILLER PIC X(32) VALUE "golden_pickaxe".
    05 FILLER PIC X(32) VALUE "golden_shovel".
    05 FILLER PIC X(32) VALUE "golden_axe".
    05 FILLER PIC X(32) VALUE "golden_hoe".
    05 FILLER PIC X(32) VALUE "raw_gold".
    05 FILLER PIC X(32) VALUE "raw_gold_block".
    05 FILLER PIC X(32) VALUE "golden_dandelion".
 01 WS-LOVED REDEFINES WS-LOVED-LIST.
    05 WS-L                PIC X(32) OCCURS 28 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "N" TO TL-MODE
*>   3.1 predicates: every one of the 28 loved keys; a stick and a gold nugget are not loved.
     MOVE 0 TO WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         CALL "PIGLIN-LOVED" USING WS-L(WS-I) WS-YES
         ADD WS-YES TO WS-STATUS
     END-PERFORM
     MOVE "acceptance US15 44-6§3.1 all 28 keys of piglin_loved are loved" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stick" TO WS-K32
     CALL "PIGLIN-LOVED" USING WS-K32 WS-YES
     MOVE "acceptance US15 44-6§3.1 a stick is not loved" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gold_nugget" TO WS-K32
     CALL "PIGLIN-LOVED" USING WS-K32 WS-YES
     MOVE "acceptance US15 44-6§3.1 a gold nugget is not loved" TO TL-CASE
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gold_ingot" TO WS-K24
     CALL "PIGLIN-CURRENCY" USING WS-K24 WS-YES
     MOVE "acceptance US15 44-6§3.1 a gold ingot is barter currency" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gold_block" TO WS-K24
     CALL "PIGLIN-CURRENCY" USING WS-K24 WS-YES
     MOVE "acceptance US15 44-6§3.1 a gold block is not barter currency" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   canAdmire: adult, not admiring, not disabled.
     MOVE 1 TO WS-ADULT
     MOVE 0 TO WS-ADM WS-DIS
     CALL "PIGLIN-ADMIRE" USING WS-ADULT WS-ADM WS-DIS WS-YES
     MOVE "acceptance US15 44-6§3.1 canAdmire: an adult with nothing set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ADULT
     CALL "PIGLIN-ADMIRE" USING WS-ADULT WS-ADM WS-DIS WS-YES
     MOVE "acceptance US15 44-6§3.1 canAdmire: not a baby" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3.2 pick-up.
     MOVE "piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "gold_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
     MOVE "gold_nugget" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-NUGGET
     MOVE "porkchop" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PORK
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PROW
*>   mob_griefing false: nothing is taken.
     CALL "BR-RULE-FIND" USING WS-RNAME WS-RINDEX
     MOVE 0 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-INGOT WS-ONE WS-ZERO WS-ZERO WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 mob_griefing false: the ingot stays and nothing is admired" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-USED(WS-DROP) + EN-ADMIRE(WS-PROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
*>   ADMIRING_DISABLED with an attack target: nothing; without a target: the ingot is taken.
     MOVE 400 TO EN-ADMIRE-OFF(WS-PROW)
     MOVE WS-ROW TO EN-TARGET(WS-PROW)
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 admiring disabled with an attack target: not taken" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-USED(WS-DROP) + EN-ADMIRE(WS-PROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-PROW)
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 admiring disabled without a target: the ingot is taken, admiring 119" TO TL-CASE
     MOVE 119 TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-PROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-ADMIRE(WS-PROW) EN-ADMIRE-OFF(WS-PROW) EN-ADMIRE-CUR(WS-PROW)
*>   A stack of 5 gold nuggets: taken whole, nothing admired.
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-NUGGET WS-FIVE WS-ZERO WS-ZERO WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 a gold nugget stack is taken whole and not admired" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-USED(WS-DROP) + EN-ADMIRE(WS-PROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Food: one of 3 porkchops is eaten, then none while ATE_RECENTLY lasts.
     CALL "GI-SPAWN-RANDOM" USING PL-DIM(WS-ROW) WS-X WS-Y WS-Z WS-PORK WS-THREE WS-ZERO WS-ZERO WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 one porkchop is eaten" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ITEM-COUNT(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 no second porkchop while ATE_RECENTLY lasts" TO TL-CASE
     MOVE EN-ITEM-COUNT(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 200 TIMES
         CALL "PGB-STEP" USING WS-PROW WS-X WS-Y WS-ONE
     END-PERFORM
     CALL "PIGLIN-PICKUP" USING WS-PROW
     MOVE "acceptance US15 44-6§3.2 after 200 ticks it eats again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ITEM-COUNT(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-3.
 COPY CORETEST.
 COPY BETEST.
