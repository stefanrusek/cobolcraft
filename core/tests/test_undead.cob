*> Implementation test (002-lane-undead, T11000; docs/protocol/18 sections 2.5 and 3.2, 20 sections 3.5 and 4, 21 section 3.6): the undead of a standard world.
*> The tag minecraft:undead (or, without loaded tags, the fixed list of 21 section 3.6) marks them; a undead land mob without a float goal (zombie, zombie villager, husk,
*> skeleton, stray, bogged, parched, wither skeleton, zombified piglin) sinks in water instead of rising; the animals with a float goal still float; the baby zombie
*> burns in daylight like the adult and is put out by water; the undead ignore poison and regeneration. Table-driven over every row of the standard mob table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-UNDEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 1 TIMES.
 01 WS-TAG-CAP             BINARY-LONG VALUE 1.
 01 WS-TAG-REG             PIC X(48) VALUE "entity_type".
 01 WS-TAG-KEY             PIC X(112) VALUE "minecraft:undead".
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-CHICKEN-TYPE        BINARY-LONG.
 01 WS-SHEEP-TYPE          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-UNDEAD              BINARY-LONG.
 01 WS-SINKS               BINARY-LONG.
 01 WS-WANT-UNDEAD         BINARY-LONG.
 01 WS-WANT-SINKS          BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-EFFECT              BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG.
 01 WS-MISSING             BINARY-LONG VALUE 0.
 01 WS-MAX                BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-LIST.
    05 WS-LIST-KEY         PIC X(24) OCCURS 20 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CHICKEN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:sheep" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SHEEP-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
*>   A pool of 3 x 3 columns, 3 deep (y BY to BY+2), beside the player's column.
     PERFORM VARYING WS-CX FROM WS-BX BY 1 UNTIL WS-CX > WS-BX + 2
         PERFORM VARYING WS-CZ FROM WS-BZ BY 1 UNTIL WS-CZ > WS-BZ + 2
             PERFORM VARYING WS-CY FROM WS-BY BY 1 UNTIL WS-CY > WS-BY + 2
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 18000 TO CW-TIME

*>   A zombie dropped into the pool sinks to the bottom; the animals float.
     COMPUTE WS-X = WS-BX + 1.5
     COMPUTE WS-Y = WS-BY + 2
     COMPUTE WS-Z = WS-BZ + 1.5
     MOVE WS-ZOMBIE-TYPE TO WS-TYPE
     PERFORM SINK-RUN
     MOVE "acceptance undead 18-3.2: a zombie dropped into a 3-deep pool sinks (it does not float)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-ROW) < WS-BY + 0.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-COW-TYPE TO WS-TYPE
     PERFORM SINK-RUN
     MOVE "acceptance undead 18-3.2: a cow in the pool still floats" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-ROW) >= WS-BY + 1.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-PIG-TYPE TO WS-TYPE
     PERFORM SINK-RUN
     MOVE "acceptance undead 18-3.2: a pig in the pool still floats" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-ROW) >= WS-BY + 1.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-CHICKEN-TYPE TO WS-TYPE
     PERFORM SINK-RUN
     MOVE "acceptance undead 18-3.2: a chicken in the pool still floats" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-ROW) >= WS-BY + 1.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-SHEEP-TYPE TO WS-TYPE
     PERFORM SINK-RUN
     MOVE "acceptance undead 18-3.2: a sheep in the pool still floats" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF EN-Y(WS-ROW) >= WS-BY + 1.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Drowning of a land mob is unchanged: the zombie breathes under water (undead), the cow's air runs out only after 300 ticks (checked in test_mob_18_2_5).

*>   A baby zombie in daylight on the surface catches fire and burns to death.
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX - 3.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ - 3.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE 0 TO WS-DEAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000 OR EN-HEALTH(WS-ROW) = 0
         ADD 1 TO CW-TIME
         MOVE 0 TO EN-HURT(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "MOB-STEP" USING WS-ROW
         IF EN-BURN(WS-ROW) > 0
             MOVE 1 TO WS-DEAD
         END-IF
     END-PERFORM
     MOVE "acceptance undead 20-3.5: a baby zombie in daylight catches fire" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DEAD TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance undead 20-3.5: a baby zombie in daylight burns to death" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A burning baby zombie that steps into water is put out.
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX + 1.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE 100 TO EN-BURN(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance undead 18-2.5: a burning baby zombie in water is put out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The on-fire flag (metadata 0 bit 0): the packet, the sync on a change only, and a viewer that arrives while it burns.
     COMPUTE WS-X = WS-BX - 3.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ - 3.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 50 TO EN-BURN(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-FIRE-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance undead 34-7.4: the on-fire metadata packet is 6 bytes (id, entity, 0, byte, flags, end)" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE PB-LENGTH TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PB-FREE" USING PB-BUFFER
     CALL "STDMOB-FIRE-SYNC" USING WS-ROW
     MOVE "acceptance undead 34-7.4: a burning mob is sent as on fire once" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-FIRE-SENT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "STDMOB-FIRE-SYNC" USING WS-ROW
     MOVE 0 TO EN-BURN(WS-ROW)
     CALL "STDMOB-FIRE-SYNC" USING WS-ROW
     MOVE "acceptance undead 34-7.4: a mob that stops burning is sent as extinguished" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-FIRE-SENT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 40 TO EN-BURN(WS-ROW)
     MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-ROW:1)
     CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The tag minecraft:undead of the loaded data, when there is one, decides the way MOB-UNDEAD answers.
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REG WS-TAG-KEY WS-TAG-COUNT WS-TAG-IDS WS-TAG-CAP WS-STATUS
     DISPLAY "tag minecraft:undead members: " WS-TAG-COUNT
     MOVE "zombie" TO WS-SPECIES
     CALL "MOB-UNDEAD" USING WS-SPECIES WS-ZOMBIE-TYPE WS-UNDEAD
     MOVE "acceptance undead 21-3.6: a zombie is undead with or without the loaded tag" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-UNDEAD TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Table-driven over every row of the standard mob table.
     MOVE "skeleton" TO WS-LIST-KEY(1)
     MOVE "stray" TO WS-LIST-KEY(2)
     MOVE "wither_skeleton" TO WS-LIST-KEY(3)
     MOVE "skeleton_horse" TO WS-LIST-KEY(4)
     MOVE "bogged" TO WS-LIST-KEY(5)
     MOVE "parched" TO WS-LIST-KEY(6)
     MOVE "zombie_horse" TO WS-LIST-KEY(7)
     MOVE "camel_husk" TO WS-LIST-KEY(8)
     MOVE "zombie" TO WS-LIST-KEY(9)
     MOVE "zombie_villager" TO WS-LIST-KEY(10)
     MOVE "zombified_piglin" TO WS-LIST-KEY(11)
     MOVE "zoglin" TO WS-LIST-KEY(12)
     MOVE "drowned" TO WS-LIST-KEY(13)
     MOVE "husk" TO WS-LIST-KEY(14)
     MOVE "zombie_nautilus" TO WS-LIST-KEY(15)
     MOVE "wither" TO WS-LIST-KEY(16)
     MOVE "phantom" TO WS-LIST-KEY(17)
     MOVE "giant" TO WS-LIST-KEY(18)
     MOVE "pig" TO WS-LIST-KEY(19)
     MOVE "creeper" TO WS-LIST-KEY(20)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
         MOVE SM-KEY(WS-I) TO WS-SPECIES
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-UNDEAD" USING WS-SPECIES WS-TYPE WS-UNDEAD
         CALL "MOB-SINKS" USING WS-SPECIES WS-TYPE WS-SINKS
         MOVE 0 TO WS-WANT-UNDEAD WS-WANT-SINKS
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 18
             IF WS-LIST-KEY(WS-T) = WS-SPECIES
                 MOVE 1 TO WS-WANT-UNDEAD
             END-IF
         END-PERFORM
         EVALUATE WS-SPECIES
             WHEN "zombie" WHEN "zombie_villager" WHEN "husk" WHEN "skeleton" WHEN "stray" WHEN "bogged" WHEN "parched"
             WHEN "wither_skeleton" WHEN "zombified_piglin"
                 MOVE 1 TO WS-WANT-SINKS
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         STRING "acceptance undead 21-3.6: " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE
             " is undead as the table says" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-WANT-UNDEAD TO WS-EXP
         MOVE WS-UNDEAD TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         MOVE SPACES TO WS-CASE
         STRING "acceptance undead 18-3.2: " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE
             " sinks as the docs say" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-WANT-SINKS TO WS-EXP
         MOVE WS-SINKS TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>       Poison does not hurt and regeneration does not heal an undead mob; both work on the others.
         COMPUTE WS-X = WS-BX - 3.5
         COMPUTE WS-Y = WS-BY
         COMPUTE WS-Z = WS-BZ - 3.5
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         IF WS-ROW > 0
             MOVE 18 TO WS-EFFECT
             MOVE 25 TO WS-DUR
             MOVE 3 TO EN-HEALTH(WS-ROW)
             CALL "MEF-PERIODIC" USING WS-ROW WS-EFFECT WS-AMP WS-DUR
             MOVE SPACES TO WS-CASE
             STRING "acceptance undead 17-4.9a: poison on " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE INTO WS-CASE
             COMPUTE WS-EXP = 3 - 1 + WS-WANT-UNDEAD
             MOVE EN-HEALTH(WS-ROW) TO WS-OBS
             CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
             MOVE 9 TO WS-EFFECT
             MOVE 50 TO WS-DUR
             MOVE 1 TO EN-HEALTH(WS-ROW)
             CALL "MEF-PERIODIC" USING WS-ROW WS-EFFECT WS-AMP WS-DUR
             MOVE SPACES TO WS-CASE
             STRING "acceptance undead 17-4.9a: regeneration on " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE INTO WS-CASE
             CALL "STDMOB-HEALTH" USING WS-TYPE WS-MAX
             COMPUTE WS-EXP = 1 + FUNCTION MIN(1, WS-MAX - 1) * (1 - WS-WANT-UNDEAD)
             MOVE EN-HEALTH(WS-ROW) TO WS-OBS
             CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM
*>   Undead types of the doc that have no row in the table yet (recorded on the task line).
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 18
         MOVE 0 TO WS-OBS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
             IF SM-KEY(WS-I) = WS-LIST-KEY(WS-T)
                 MOVE 1 TO WS-OBS
             END-IF
         END-PERFORM
         IF WS-OBS = 0
             DISPLAY "undead without a table row: " FUNCTION TRIM(WS-LIST-KEY(WS-T))
             ADD 1 TO WS-MISSING
         END-IF
     END-PERFORM
*>   With the tag in the loaded data the tag decides: a set holding only the pig makes the pig undead and the zombie not.
     MOVE 1 TO CT-OPEN
     MOVE WS-PIG-TYPE TO WS-TAG-ID(1)
     MOVE 1 TO WS-TAG-COUNT
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG-KEY WS-TAG-COUNT WS-TAG-IDS WS-STATUS
     MOVE "pig" TO WS-SPECIES
     CALL "MOB-UNDEAD" USING WS-SPECIES WS-PIG-TYPE WS-UNDEAD
     MOVE "acceptance undead 21-3.6: a type in the loaded tag minecraft:undead is undead" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-UNDEAD TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "zombie" TO WS-SPECIES
     CALL "MOB-UNDEAD" USING WS-SPECIES WS-ZOMBIE-TYPE WS-UNDEAD
     MOVE "acceptance undead 21-3.6: a type outside the loaded tag is not undead" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-UNDEAD TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 SINK-RUN.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM 120 TIMES
         MOVE 0 TO EN-HURT(WS-ROW)
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM.
 END PROGRAM TEST-UNDEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
