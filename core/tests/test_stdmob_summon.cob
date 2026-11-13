*> Acceptance test (002-lane-mobs; 16 section 5.8 `summon`): in a standard world /summon makes the standard mobs of core/copy/STDMOBS.cpy (pig, cow,
*> sheep, chicken, mooshroom, zombie): the key is taken with or without minecraft:, the mob appears at the position with its full health, and
*> commands.summon.success carries the namespaced key. A type with no row (skeleton, or a cobolcraft key) is entity.not_summonable; a monster in
*> Peaceful is commands.summon.failed.peaceful.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-SUMMON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-FIND-X              FLOAT-LONG.
 01 WS-HEALTH              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD

     MOVE "acceptance US15 /summon in a standard world: a pig by its namespaced key" TO TL-CASE
     MOVE "summon minecraft:pig 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(minecraft:pig)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon one pig stands at x 5 with 10 health" TO TL-CASE
     MOVE "pig" TO WS-KEY-TEXT
     MOVE 5.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US15 /summon the pig's health is the row's 10" TO TL-CASE
     MOVE 10 TO WS-EXPECTED-N
     MOVE WS-HEALTH TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM

     MOVE "acceptance US15 /summon a cow without the namespace" TO TL-CASE
     MOVE "summon cow 6.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(minecraft:cow)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon one cow stands at x 6" TO TL-CASE
     MOVE "cow" TO WS-KEY-TEXT
     MOVE 6.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM

     MOVE "acceptance US15 /summon a zombie (Normal difficulty)" TO TL-CASE
     MOVE "summon zombie 7.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(minecraft:zombie)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US15 /summon a type with no row is not summonable" TO TL-CASE
     MOVE "summon minecraft:skeleton 8.0 64.0 5.0" TO WS-LINE
     MOVE "entity.not_summonable(minecraft:skeleton)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon a cobolcraft key in a standard world is no entity type" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 8.0 64.0 5.0" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:sodgrazer,minecraft:entity_type) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE 0 TO BW-DIFFICULTY
     MOVE "acceptance US15 /summon a zombie in Peaceful is refused" TO TL-CASE
     MOVE "summon zombie 9.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.failed.peaceful()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon a pig in Peaceful is fine" TO TL-CASE
     MOVE "summon pig 10.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(minecraft:pig)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     STOP RUN.
 COUNT-MOBS.
     MOVE 0 TO WS-NUM WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = WS-FIND-X
             COMPUTE WS-KEEP = EN-TYPE(WS-I) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-NUM
                 MOVE EN-HEALTH(WS-I) TO WS-HEALTH
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STDMOB-SUMMON.

 COPY CORETEST.
 COPY CMDTEST.
