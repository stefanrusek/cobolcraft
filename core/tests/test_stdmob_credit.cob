*> Implementation test (002-lane-mobs; 17 section 4.13.2 and 4.13.3): the death message of a standard world with kill credit, weapon names and the fall
*> distance. A player or mob that hurt the victim in the last 100 ticks is its kill credit; a source with no entity (a fall, starvation, drowning, the
*> command, hail) then takes the `.player` form with the credit as second argument; a fall of more than 5 blocks is death.fell.accident.generic, or
*> death.fell.assist with a credit, and a fall of at most 5 is death.attack.fall (.player with a credit); a kill by a mob or player whose held item has a
*> custom name takes the `.item` form with the name in brackets as third argument. DEATH-TEXT-STD builds it from the player row; the credit, the weapon
*> name and the fall distance are recorded when the hit, the fall or the mob attack happens.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-CREDIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY RULES.
 COPY PROTO.
 COPY BRWORLD.
 COPY CONTENT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ZOMBIE-ROW          BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-WEAPON              PIC X(64).
 01 WS-WEAPON-LENGTH       BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG VALUE 0.
 01 WS-HURT-AMOUNT         BINARY-LONG VALUE 6000.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG VALUE 20.
 01 WS-BY                  BINARY-LONG VALUE 100.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-DIGIT               PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE "Steve" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Alexx" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-A
     MOVE CN-PLAYER(WS-BOB) TO WS-B
     MOVE "N" TO TL-MODE
     MOVE 1000 TO CW-TICKS

*>   Fall distances and messages without credit.
     MOVE CAUSE-FALL TO WS-CAUSE
     MOVE 0 TO PL-CREDIT-TICK(WS-A)
     MOVE 8000 TO PL-FALL-DISTANCE(WS-A)
     PERFORM BUILD
     MOVE "T" TO TL-MODE
     MOVE "test stdmob credit: a fall of 8, no credit" TO TL-CASE
     MOVE "death.fell.accident.generic|1" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4000 TO PL-FALL-DISTANCE(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a fall of 4, no credit" TO TL-CASE
     MOVE "death.attack.fall|1" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a credit of 100 ticks ago (still valid) and 101 ticks ago (expired).
     MOVE "Zombie" TO PL-CREDIT-NAME(WS-A)
     MOVE 6 TO PL-CREDIT-LENGTH(WS-A)
     MOVE 900 TO PL-CREDIT-TICK(WS-A)
     MOVE 8000 TO PL-FALL-DISTANCE(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a fall of 8 after a zombie hit 100 ticks ago is an assist" TO TL-CASE
     MOVE "death.fell.assist|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4000 TO PL-FALL-DISTANCE(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a fall of 4 with the credit is death.attack.fall.player" TO TL-CASE
     MOVE "death.attack.fall.player|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 899 TO PL-CREDIT-TICK(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a hit 101 ticks ago is no credit any more" TO TL-CASE
     MOVE "death.attack.fall|1" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Other causes with a credit.
     MOVE 900 TO PL-CREDIT-TICK(WS-A)
     MOVE CAUSE-STARVATION TO WS-CAUSE
     PERFORM BUILD
     MOVE "test stdmob credit: starvation with a credit" TO TL-CASE
     MOVE "death.attack.starve.player|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-DROWN TO WS-CAUSE
     PERFORM BUILD
     MOVE "test stdmob credit: drowning with a credit" TO TL-CASE
     MOVE "death.attack.drown.player|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-COMMAND TO WS-CAUSE
     PERFORM BUILD
     MOVE "test stdmob credit: the command with a credit" TO TL-CASE
     MOVE "death.attack.genericKill.player|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-HAIL TO WS-CAUSE
     PERFORM BUILD
     MOVE "test stdmob credit: hail with a credit" TO TL-CASE
     MOVE "death.attack.generic.player|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A kill by a player and by a mob; with a named weapon the .item form.
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE "Alexx" TO PL-KILLER-NAME(WS-A)
     MOVE 5 TO PL-KILLER-LENGTH(WS-A)
     MOVE SPACES TO PL-KILLER-ITEM(WS-A)
     MOVE 0 TO PL-KILLER-ITEM-LENGTH(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a player kill with no named weapon" TO TL-CASE
     MOVE "death.attack.player|2|Steve|Alexx" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "Excalibur" TO PL-KILLER-ITEM(WS-A)
     MOVE 9 TO PL-KILLER-ITEM-LENGTH(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a player kill with a named weapon is the .item form" TO TL-CASE
     MOVE "death.attack.player.item|3|Steve|Alexx|[Excalibur]" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-MOB TO WS-CAUSE
     MOVE "Zombie" TO PL-KILLER-NAME(WS-A)
     MOVE 6 TO PL-KILLER-LENGTH(WS-A)
     MOVE 0 TO PL-KILLER-ITEM-LENGTH(WS-A)
     PERFORM BUILD
     MOVE "test stdmob credit: a mob kill" TO TL-CASE
     MOVE "death.attack.mob|2|Steve|Zombie" TO TL-EXPECTED
     PERFORM OBSERVE-ARGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Recording: a mob hit makes the mob the credit with the tick; a player hit makes the attacker the credit with the held item's custom name.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-B) TO WS-X
     MOVE PL-Y(WS-B) TO WS-Y
     MOVE PL-Z(WS-B) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-B) WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE-ROW
     MOVE 0 TO PL-CREDIT-TICK(WS-B) PL-HURT-COOLDOWN(WS-B)
     MOVE SPACES TO PL-CREDIT-NAME(WS-B)
     MOVE 3 TO WS-HURT-AMOUNT
     CALL "HEALTH-MOB-HIT" USING WS-B WS-HURT-AMOUNT WS-ZOMBIE-ROW
     MOVE "T" TO TL-MODE
     MOVE "test stdmob credit: a zombie's hit records Zombie as the credit" TO TL-CASE
     MOVE "Zombie" TO TL-EXPECTED
     MOVE PL-CREDIT-NAME(WS-B) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test stdmob credit: with the tick of the hit" TO TL-CASE
     MOVE CW-TICKS TO TL-EXPECTED-N
     MOVE PL-CREDIT-TICK(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player hit with a named sword in the attacker's hand.
     MOVE "Excalibur" TO WS-WEAPON
     MOVE 9 TO WS-WEAPON-LENGTH
     MOVE 0 TO WS-HANDLE
     CALL "SP-SET-NAME" USING WS-HANDLE WS-WEAPON WS-WEAPON-LENGTH
     MOVE 1 TO PL-SLOT-COUNT(WS-A, PL-HELD(WS-A) + 1)
     MOVE 10 TO PL-SLOT-ITEM(WS-A, PL-HELD(WS-A) + 1)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-A, PL-HELD(WS-A) + 1)
     MOVE 0 TO PL-CREDIT-TICK(WS-B) PL-HURT-COOLDOWN(WS-B)
     MOVE 6000 TO WS-HURT-AMOUNT
     MOVE PL-ENTITY-ID(WS-A) TO WS-SOURCE
     CALL "HEALTH-HURT" USING WS-B WS-HURT-AMOUNT CAUSE-PLAYER WS-SOURCE WS-A WS-RESULT
     MOVE "T" TO TL-MODE
     MOVE "test stdmob credit: a player's hit records the attacker as the credit" TO TL-CASE
     MOVE "Steve" TO TL-EXPECTED
     MOVE PL-CREDIT-NAME(WS-B) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob credit: and the custom name of the held item as the weapon" TO TL-CASE
     MOVE "Excalibur" TO TL-EXPECTED
     MOVE PL-KILLER-ITEM(WS-B) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A fall records its distance: from 111 down to the block at y 100 (feet 101) is 10 blocks.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE "N" TO TL-MODE
     MOVE "test stdmob credit: the landing of a 10 block fall records the distance 10000" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     MOVE PL-FALL-DISTANCE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BUILD.
     CALL "DEATH-TEXT-STD" USING WS-A WS-CAUSE PB-TEXT.
 OBSERVE.
     MOVE SPACES TO TL-OBSERVED
     MOVE PB-TX-ARG-COUNT TO WS-DIGIT
     STRING FUNCTION TRIM(PB-TX-VALUE) "|" WS-DIGIT DELIMITED BY SIZE INTO TL-OBSERVED.
 OBSERVE-ARGS.
     MOVE SPACES TO TL-OBSERVED
     MOVE PB-TX-ARG-COUNT TO WS-DIGIT
     STRING FUNCTION TRIM(PB-TX-VALUE) "|" WS-DIGIT DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-RESULT FROM 1 BY 1 UNTIL WS-RESULT > PB-TX-ARG-COUNT
         STRING FUNCTION TRIM(TL-OBSERVED) "|" PB-TX-ARG-VALUE(WS-RESULT)(1:PB-TX-ARG-LENGTH(WS-RESULT))
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM.
 END PROGRAM TEST-STDMOB-CREDIT.
 COPY CORETEST.
