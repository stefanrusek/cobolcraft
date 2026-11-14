*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.6): hoglin and zoglin, basics. Rows (health 40, attack 6, experience 5, rule 11 for the hoglin,
*> rule 10 for the zoglin); an adult's hit deals A / 2 + nextInt(A) = 3 to 8; loot from the table of the key.
*> PARTIAL: knockback, babies, zombification, the brain (repellents, piglin avoidance) are not modelled.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/nether-loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:porkchop".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-PORK                BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(24) VALUE "hoglin".
    05 FILLER              PIC X(24) VALUE "zoglin".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-KEY              PIC X(24) OCCURS 2 TIMES.
 01 WS-RULES.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 10.
 01 WS-RULE-TABLE REDEFINES WS-RULES.
    05 WS-RULE             BINARY-LONG OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-PORK WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE WS-KEY(WS-K) TO WS-NAME
         CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 minecraft:" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " has a species row" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF WS-M > 41 AND SM-KEY(WS-M) = WS-NAME
             MOVE 1 TO WS-OBS
         END-IF
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 21§5.6 minecraft:" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " health 40, attack 6, xp 5" DELIMITED BY SIZE INTO WS-CASE
         MOVE 51 TO WS-EXP
         COMPUTE WS-OBS = SM-HEALTH(WS-M) + SM-ATTACK(WS-M) + SM-XP(WS-M)
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 21§3.2 minecraft:" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " spawn rule" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-RULE(WS-K) TO WS-EXP
         CALL "TEST-CHK" USING WS-CASE WS-EXP SM-SPAWN(WS-M)
*>       The hit: 3 to 8 over many ticks, and both ends are reached.
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
         MOVE 99 TO WS-MIN
         MOVE 0 TO WS-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
             MOVE WS-I TO CW-TIME
             CALL "STDMOB-ATTACK-DAMAGE" USING WS-A WS-M WS-DAMAGE
             MOVE FUNCTION MIN(WS-MIN, WS-DAMAGE) TO WS-MIN
             MOVE FUNCTION MAX(WS-MAX, WS-DAMAGE) TO WS-MAX
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 21§5.6 minecraft:" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " hits for 3 to 8" DELIMITED BY SIZE INTO WS-CASE
         MOVE 38 TO WS-EXP
         COMPUTE WS-OBS = WS-MIN * 10 + WS-MAX
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         CALL "ENTITY-REMOVE" USING WS-A
     END-PERFORM
*>   The hoglin's loot table (porkchop in the fixture) on death.
     MOVE "hoglin" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     MOVE WS-PLAYER TO EN-KILLER(WS-A)
     CALL "STDMOB-DIE" USING WS-A
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-N1 FROM 1 BY 1 UNTIL WS-N1 > EN-COUNT
         IF EN-USED(WS-N1) = 1 AND EN-ITEM(WS-N1) = WS-PORK AND EN-ITEM-COUNT(WS-N1) > 0
             ADD EN-ITEM-COUNT(WS-N1) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.6 a killed hoglin drops its table (porkchop)" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-COUNT
     GOBACK.
 END PROGRAM TEST-MOB-21-5-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY NETHERTEST.
