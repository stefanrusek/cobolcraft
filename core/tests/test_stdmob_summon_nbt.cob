*> Acceptance test (lane p49a; 16 section 5.8 `summon` with an NBT, 45-2 section 4): the NBT is loaded into the new standard mob (NoAI, LeftHanded, Health) and no
*> mob initialisation runs; without a Health the mob has its full health; an NBT for a mob of another kind is refused as before.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-SUMMON-NBT.
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
 01 WS-VARIANT             BINARY-LONG.
 01 WS-NOAI                BINARY-LONG.
 01 WS-LEFTY               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD

     MOVE "acceptance US15 /summon with an NBT: a pig with NoAI, LeftHanded and Health 4" TO TL-CASE
     MOVE "summon minecraft:pig 5.0 64.0 5.0 {NoAI:1b,LeftHanded:1b,Health:4f}" TO WS-LINE
     MOVE "commands.summon.success(minecraft:pig)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "pig" TO WS-KEY-TEXT
     MOVE 5.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 /summon with an NBT: one pig at x 5" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US15 /summon with an NBT: its Health is 4" TO TL-CASE
     MOVE 4 TO WS-EXPECTED-N
     MOVE WS-HEALTH TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US15 /summon with an NBT: NoAI 1 and LeftHanded 1" TO TL-CASE
     MOVE 11 TO WS-EXPECTED-N
     COMPUTE WS-NUM = WS-NOAI * 10 + WS-LEFTY
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM

     MOVE "acceptance US15 /summon with an NBT without Health: a cow with the full 10" TO TL-CASE
     MOVE "summon cow 6.0 64.0 5.0 {NoAI:1b}" TO WS-LINE
     MOVE "commands.summon.success(minecraft:cow)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "cow" TO WS-KEY-TEXT
     MOVE 6.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE "acceptance US15 /summon with an NBT: the cow's health is the row's 10" TO TL-CASE
     MOVE 10 TO WS-EXPECTED-N
     MOVE WS-HEALTH TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US15 /summon with an NBT: NoAI 1, LeftHanded 0" TO TL-CASE
     MOVE 10 TO WS-EXPECTED-N
     COMPUTE WS-NUM = WS-NOAI * 10 + WS-LEFTY
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM

     MOVE "acceptance US15 /summon with an NBT: a mob that is not a table mob still has no NBT support" TO TL-CASE
     MOVE "summon minecraft:wither 8.0 64.0 5.0 {NoAI:1b}" TO WS-LINE
     MOVE "entity.not_summonable(minecraft:wither)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     STOP RUN.

 COUNT-MOBS.
     MOVE 0 TO WS-NUM WS-HEALTH WS-VARIANT WS-NOAI WS-LEFTY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = WS-FIND-X
             COMPUTE WS-KEEP = EN-TYPE(WS-I) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-NUM
                 MOVE EN-HEALTH(WS-I) TO WS-HEALTH
                 MOVE EN-NO-AI(WS-I) TO WS-NOAI
                 MOVE EN-LEFTY(WS-I) TO WS-LEFTY
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STDMOB-SUMMON-NBT.

 COPY CORETEST.
 COPY CMDTEST.
