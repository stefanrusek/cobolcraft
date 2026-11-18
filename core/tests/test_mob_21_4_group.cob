*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 4.4 to 4.6 with doc 44 part 7 sections 2.1, 6.3 and 4.2): the spawn group data of the water mobs. The first member of a pack is never
*> a baby; later squid and glow squid are babies with chance 0.05 and dolphins with 0.1 (nextFloat <= chance, age -24000); a baby counts its age up and grows up after 24000 ticks; the baby flag
*> (metadata 16) goes to the viewers when it is set and when it is cleared; the glow squid's dark ticks (metadata 18) go to the viewers while they count; tropical fish of a pack share the variant
*> of the first school member (a fish with the 0.9 pick; the 0.1 random-pattern fish are no school and keep their own look until a school member sets the group variant).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-GROUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-LONE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-SQUID               BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-DOLPHIN             BINARY-LONG.
 01 WS-TROPICAL            BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-BABIES              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-GROUP               BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-ONE-MEMBER          BINARY-LONG VALUE 1.
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:glow_squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GLOW WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:dolphin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DOLPHIN WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:tropical_fish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TROPICAL WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-FIRST
*>   The first member is never a baby; later squid with chance 0.05 (4000 members: 150 to 260), later dolphins with 0.1 (4000: 330 to 480).
     MOVE 1 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE 0 TO WS-BAD
     MOVE WS-FIRST TO WS-SAME
     CALL "AQUA-PACK" USING XR-STATE WS-FIRST WS-SAME WS-BAD WS-DONE
     MOVE "acceptance US15 44-7§6.3 the first member of a pack is never a baby (squid, age 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-FIRST) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "AQUA-PACK" USING XR-STATE WS-FIRST WS-ROW WS-ONE-MEMBER WS-DONE
         IF EN-MOBAGE(WS-ROW) = -24000
             ADD 1 TO WS-BABIES
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-7§6.3 later squid of a pack are babies with chance 0.05 (4000: 150 to 260)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BABIES >= 150 AND WS-BABIES <= 260
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "AQUA-PACK" USING XR-STATE WS-FIRST WS-ROW WS-ONE-MEMBER WS-DONE
         IF EN-MOBAGE(WS-ROW) = -24000
             ADD 1 TO WS-BABIES
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-7§6.3 later dolphins of a pack are babies with chance 0.1 (4000: 330 to 480)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BABIES >= 330 AND WS-BABIES <= 480
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   A baby squid counts up and grows up; the baby flag (Set Entity Data) is sent when it is set and when it grows up.
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE -3 TO EN-MOBAGE(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-7§6.3 a baby's age counts up each tick (-3 to -1 after 2 ticks)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL " 101 " ALL " 101x"
     MOVE "acceptance US15 44-7§6.3 while it is a baby nothing is re-sent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§6.3 at age 0 it is an adult" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL " 101 " ALL " 101x"
     MOVE "acceptance US15 44-7§6.3 growing up sends the baby flag (Set Entity Data) to the viewers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   An age-locked baby does not count up.
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -5 TO EN-MOBAGE(WS-ROW)
     MOVE 1 TO EN-LOCKED(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§2.2 an age-locked baby does not grow" TO TL-CASE
     MOVE -5 TO TL-EXPECTED-N
     MOVE EN-MOBAGE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The glow squid's dark ticks (metadata 18) go to the viewers when it is hit.
     CALL "MOB-SPAWN" USING WS-DIM WS-GLOW WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL " 101 " ALL " 101x"
     MOVE "acceptance US15 21§4.5 a hit glow squid sends its dark ticks (metadata 18, Set Entity Data)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Tropical fish in a pack: 150 packs of 6 (finalize each, then the group): every member after the first school member (EN-WOOL 1) shares that member's variant.
     MOVE 0 TO WS-BAD WS-LONE
     MOVE 0 TO WS-GROUP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 0 TO WS-NOW
         MOVE 0 TO WS-GROUP
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             CALL "MOB-SPAWN" USING WS-DIM WS-TROPICAL WS-X WS-Y WS-Z WS-YAW WS-ROW
             MOVE WS-ROW TO WS-MEMBER(WS-J)
             CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
             IF WS-J = 1
                 MOVE WS-ROW TO WS-FIRST
             END-IF
             COMPUTE WS-NOW = WS-J - 1
             CALL "AQUA-PACK" USING XR-STATE WS-FIRST WS-ROW WS-NOW WS-DONE
             IF WS-GROUP > 0 AND EN-VARIANT(WS-ROW) NOT = WS-GROUP
                 ADD 1 TO WS-BAD
             END-IF
             IF (EN-WOOL(WS-ROW) = 0 AND WS-DONE NOT = 1) OR (EN-WOOL(WS-ROW) = 1 AND WS-DONE NOT = 0)
                 ADD 1 TO WS-LONE
             END-IF
             IF WS-GROUP = 0 AND EN-WOOL(WS-ROW) = 1
                 MOVE EN-VARIANT(WS-ROW) TO WS-GROUP
             END-IF
         END-PERFORM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             CALL "ENTITY-REMOVE" USING WS-MEMBER(WS-J)
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 21§4.4 the members of a pack after the first school member share its variant (150 packs of 6)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-1 RQ-1.14 a tropical fish that is no school member ends its pack (done), a school member does not" TO TL-CASE
     MOVE WS-LONE TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-GROUP.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
