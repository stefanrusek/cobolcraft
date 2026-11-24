*> The dried ghast block and the hatching of a happy ghast (docs/protocol/44-9 section 9.1; lane p49f, T21210): a random tick of a block that is waterlogged or has hydration_level > 0 schedules a block tick in
*> 5000 ticks (once); the block tick of a dry block with hydration lowers it by 1, of a waterlogged block raises it by 1 up to 3, and at 3 hatches: the block is gone and a baby happy ghast (age -24000, the
*> block's facing as yaw) stands at its bottom centre.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-11B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROJSTATE.
 COPY BLOCKTICK.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KIND-TICK           BINARY-LONG VALUE 7.
 01 WS-KIND-RANDOM         BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-OUT                 BINARY-LONG.
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME-HYD            PIC X(16) VALUE "hydration".
 01 WS-NAME-WET            PIC X(16) VALUE "waterlogged".
 01 WS-NAME-FACING         PIC X(16) VALUE "facing".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-OLD                 PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-RESULT              BINARY-LONG.
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-GHAST-TYPE          BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-GHASTS              BINARY-LONG.
 01 WS-GROW                BINARY-LONG.
 01 WS-TRIG                BINARY-DOUBLE.
 01 WS-SAVE-SET            BINARY-LONG.
 01 WS-FACINGS             PIC X(27) VALUE "west     north    east     ".
 01 WS-YAWS.
    05 FILLER              BINARY-LONG VALUE 90.
    05 FILLER              BINARY-LONG VALUE 180.
    05 FILLER              BINARY-LONG VALUE 270.
 01 WS-YAW-R REDEFINES WS-YAWS.
    05 WS-YAW-OF           BINARY-LONG OCCURS 3 TIMES.
 01 WS-F                   BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-FACE16              PIC X(16).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "DG-RULES-OPEN"
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 20
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE "minecraft:happy_ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GHAST-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:dried_ghast" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
*>   A dry block without hydration: a random tick schedules nothing.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BU-HOOK" USING WS-KIND-RANDOM WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     CALL "BT-HAS" USING WS-DIM WS-TYPE-BLOCK WS-ID WS-BX WS-BY WS-BZ WS-FOUND
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 a dry block with hydration 0 schedules no tick" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
*>   Waterlogged: a random tick schedules the tick, once.
     MOVE "true" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-WET WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BU-HOOK" USING WS-KIND-RANDOM WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     CALL "BT-HAS" USING WS-DIM WS-TYPE-BLOCK WS-ID WS-BX WS-BY WS-BZ WS-FOUND
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 a waterlogged block schedules a block tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     CALL "BU-HOOK" USING WS-KIND-RANDOM WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     MOVE 0 TO WS-I
     PERFORM VARYING WS-FOUND FROM 1 BY 1 UNTIL WS-FOUND > BT-COUNT
         IF BT-T-X(WS-FOUND) = WS-BX AND BT-T-Y(WS-FOUND) = WS-BY AND BT-T-Z(WS-FOUND) = WS-BZ
             ADD 1 TO WS-I
             MOVE BT-T-TRIG(WS-FOUND) TO WS-TRIG
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 a second random tick adds no second tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-I TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 the tick is due in 5000 ticks" TO WS-CASE
     COMPUTE WS-E = CW-TICKS + 5000
     MOVE WS-TRIG TO WS-O
     PERFORM CHECK-N
*>   The block ticks: hydration 0 to 3, then the hatch.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         CALL "BU-HOOK" USING WS-KIND-TICK WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ID WS-ZERO2 WS-OUT
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HYD WS-KEEP WS-RESULT WS-VALUE
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 three block ticks of a waterlogged block raise hydration to 3" TO WS-CASE
     MOVE "3" TO TL-EXPECTED
     MOVE "A" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "south" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-FACING WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM COUNT-GHASTS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 before the hatching tick there is no ghast" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-GHASTS TO WS-O
     PERFORM CHECK-N
     CALL "BU-HOOK" USING WS-KIND-TICK WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ID WS-ZERO2 WS-OUT
     PERFORM COUNT-GHASTS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 the fourth tick hatches one happy ghast" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-GHASTS TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-NEW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 the block is removed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 the ghast is a baby of age -24000" TO WS-CASE
     MOVE -24000 TO WS-E
     MOVE EN-MOBAGE(WS-GROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 the baby flag is set" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-VARIANT(WS-GROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 it stands at the block's bottom centre (x)" TO WS-CASE
     COMPUTE WS-E = WS-BX * 1000 + 500
     COMPUTE WS-O ROUNDED = EN-X(WS-GROW) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 and at its bottom (y)" TO WS-CASE
     COMPUTE WS-E = WS-BY * 1000
     COMPUTE WS-O ROUNDED = EN-Y(WS-GROW) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 facing south the yaw is 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = EN-YAW(WS-GROW)
     PERFORM CHECK-N
*>   The other facings give the other yaws: west 90, north 180, east 270.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 3
         MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
         MOVE "true" TO WS-VALUE
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-WET WS-VALUE WS-RESULT WS-OLD
         MOVE WS-RESULT TO WS-STATE
         MOVE "3" TO WS-VALUE
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HYD WS-VALUE WS-RESULT WS-OLD
         MOVE WS-RESULT TO WS-STATE
         MOVE WS-FACINGS(WS-F * 9 - 8:9) TO WS-FACE16
         MOVE WS-FACE16 TO WS-VALUE
         CALL "SW-SET-PROP" USING WS-STATE WS-NAME-FACING WS-VALUE WS-RESULT WS-OLD
         MOVE WS-RESULT TO WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         CALL "BU-HOOK" USING WS-KIND-TICK WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ID WS-ZERO2 WS-OUT
         PERFORM COUNT-GHASTS
         MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 hatching with the facing of the block gives its yaw" TO WS-CASE
         MOVE WS-YAW-OF(WS-F) TO WS-E
         COMPUTE WS-O ROUNDED = EN-YAW(WS-GROW)
         PERFORM CHECK-N
     END-PERFORM
*>   The rules are made once however often a world opens.
     CALL "DG-RULES-OPEN"
*>   Another content set has neither the block nor the entity: no rule, no ghast.
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     MOVE "true" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-WET WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     MOVE "3" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HYD WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM COUNT-GHASTS
     MOVE WS-GHASTS TO WS-BEFORE
     MOVE CT-SET-TYPE TO WS-SAVE-SET
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "DG-RULES-OPEN"
     MOVE "north" TO WS-FACE16
     CALL "DG-HATCH" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE16
     MOVE WS-SAVE-SET TO CT-SET-TYPE
     PERFORM COUNT-GHASTS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 without the entity type the block hatches nothing" TO WS-CASE
     MOVE WS-BEFORE TO WS-E
     MOVE WS-GHASTS TO WS-O
     PERFORM CHECK-N
*>   A dry block with hydration lowers it by 1 on its tick and schedules again on a random tick.
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     MOVE "2" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HYD WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     MOVE "west" TO WS-VALUE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-FACING WS-VALUE WS-RESULT WS-OLD
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BU-HOOK" USING WS-KIND-TICK WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ID WS-ZERO2 WS-OUT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-HYD WS-KEEP WS-RESULT WS-VALUE
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 a dry block with hydration 2 dries to 1" TO WS-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE "A" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BU-HOOK" USING WS-KIND-RANDOM WS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     CALL "BT-HAS" USING WS-DIM WS-TYPE-BLOCK WS-ID WS-BX WS-BY WS-BZ WS-FOUND
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.1 a dry block with hydration 1 schedules a tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 COUNT-GHASTS.
     MOVE 0 TO WS-GHASTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-GHAST-TYPE
             ADD 1 TO WS-GHASTS
             MOVE WS-I TO WS-GROW
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-11B.
 COPY CORETEST.
 COPY MOBSPTEST.
