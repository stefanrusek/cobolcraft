*> Implementation test (coverage lane A; docs/protocol/18, 20, 21; core/src/stdmobs.cob): the standard tick of the mobs that have their own step (zombie villager, bee, villager, hoglin,
*> strider, evoker, vex, illusioner, ravager, wandering trader, witch): each is spawned on a floor and ticked, and stays in the world; a zombie beside a villager walks to it; a witch in sight of
*> a player throws a potion.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-STDMOBS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY EVKSTATE.
 COPY ZVCURE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "minecraft:zombie_villager".
    05 FILLER              PIC X(32) VALUE "minecraft:bee".
    05 FILLER              PIC X(32) VALUE "minecraft:villager".
    05 FILLER              PIC X(32) VALUE "minecraft:hoglin".
    05 FILLER              PIC X(32) VALUE "minecraft:strider".
    05 FILLER              PIC X(32) VALUE "minecraft:evoker".
    05 FILLER              PIC X(32) VALUE "minecraft:vex".
    05 FILLER              PIC X(32) VALUE "minecraft:illusioner".
    05 FILLER              PIC X(32) VALUE "minecraft:ravager".
    05 FILLER              PIC X(32) VALUE "minecraft:wandering_trader".
    05 FILLER              PIC X(32) VALUE "minecraft:witch".
 01 WS-NAME-T REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 30
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 30
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ WS-SIZE WS-BY WS-KIND1
     MOVE 6000 TO CW-TIME
*>   Every mob with its own step stays in the world over three ticks (the player stands 8 blocks away, in sight).
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 11
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME(WS-T) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-X = WS-X0 + 8 + WS-T
         MOVE WS-Z0 TO WS-Z
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         MOVE 0 TO WS-N
         PERFORM 3 TIMES
             IF EN-USED(WS-ROW) = 1
                 CALL "MOB-STEP" USING WS-ROW
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "test cova stdmobs " FUNCTION TRIM(WS-NAME(WS-T)) " is a mob row and ticks" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-ROW > 0
             MOVE 1 TO WS-O
         END-IF
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   A zombie villager whose cure runs out on this tick is replaced by a villager: its row is gone after the tick.
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 3
     MOVE WS-Z0 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "ZC-FIND" USING EN-ID(WS-ROW) WS-YES WS-SLOT
     MOVE 1 TO ZC-TIME(WS-SLOT)
     MOVE WS-PLAYER TO ZC-PLAYER(WS-SLOT)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "test cova stdmobs a zombie villager whose cure ends is converted and its row freed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-STDMOBS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
