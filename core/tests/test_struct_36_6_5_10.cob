*> Acceptance test of the spawning in and around the ocean monument (docs/protocol/36-structures-6-ocean.md section 5.10 and the vectors of 6.1; core/src/struct-mon-geo.cob MONP-ELDER, struct-override.cob): the elder guardians
*> of the monument of world seed 0, start chunk (0, 0), direction south (6.2) are asked of the entity channel at the doc's cells (penthouse (-1, 53, -1), left wing design 1 (-17, 45, -15), right wing design 0
*> (16, 42, -12), each in the one pass whose write box holds it, none in the other passes), and the box of the monument is registered with the spawn lists of its kind (the whole building box, not inflated, only for the
*> chunks it meets): monster = guardian, weight 1, group 2 to 4; axolotls and underground water creature empty.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY STRUCTOVR.
 COPY MTDATA.
 COPY GENENT.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG VALUE 0.
 01 WS-X0                  BINARY-LONG VALUE -29.
 01 WS-Z0                  BINARY-LONG VALUE -29.
 01 WS-X1                  BINARY-LONG VALUE 28.
 01 WS-Z1                  BINARY-LONG VALUE 28.
 01 WS-Y0                  BINARY-LONG VALUE 39.
 01 WS-Y1                  BINARY-LONG VALUE 61.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 38.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-KEY                 PIC X(80).
 01 WS-FLAG                BINARY-LONG.
 01 WS-NAME                PIC X(160).
 01 WS-CS                  PIC -999.
 01 WS-CS2                 PIC -999.
 01 WS-LIST                BINARY-LONG.
 01 WS-CASES.
    05 FILLER              PIC X(20) VALUE "-002-001-017+045-015".
    05 FILLER              PIC X(20) VALUE "-001-001-001+053-001".
    05 FILLER              PIC X(20) VALUE "+001-001+016+042-012".
 01 WS-CASE-TAB REDEFINES WS-CASES.
    05 WS-C OCCURS 3 TIMES.
       10 WS-C-CX          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-CZ          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-X           PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-Y           PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-Z           PIC S999 SIGN LEADING SEPARATE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-K
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
*>   the building of 6.2: south (data value 0), world seed 0
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-RESET"
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     MOVE 0 TO SP-SEED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-C-CX(WS-I) TO WS-WX
         MOVE WS-C-CZ(WS-I) TO WS-WZ
         MOVE WS-WX TO WS-CS
         MOVE WS-WZ TO WS-CS2
         COMPUTE WS-SEED = 1200 + WS-I
         CALL "MT-WINDOW" USING WS-WX WS-WZ
         CALL "MT-SEED" USING WS-SEED
         MOVE 0 TO GEL-COUNT GEL-LOST
         CALL "MON-POST" USING WS-ROW
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.10 Spawning in and around the monument: the pass of chunk " WS-CS "," WS-CS2 " asks for exactly one elder guardian" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE GEL-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.10 Spawning in and around the monument: the pass of chunk " WS-CS "," WS-CS2 " places it at the doc's cell (6.1)" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO WS-FLAG
         IF GEL-COUNT >= 1
             IF GEL-X(1) = WS-C-X(WS-I) + 0.5 AND GEL-Y(1) = WS-C-Y(WS-I) AND GEL-Z(1) = WS-C-Z(WS-I) + 0.5
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FLAG TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   a pass elsewhere in the box has none: chunk (0, 0) holds no elder cell
     MOVE 0 TO WS-WX WS-WZ
     CALL "MT-WINDOW" USING WS-WX WS-WZ
     CALL "MT-SEED" USING WS-SEED
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "MON-POST" USING WS-ROW
     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: a pass whose write box holds no elder cell asks for none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GEL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the registration of the box of kind 2 (the monument): the whole building box for each chunk it meets, none for a chunk it misses
     MOVE "minecraft:monument" TO WS-KEY
     MOVE 1 TO WS-WX
     MOVE 1 TO WS-WZ
     MOVE 0 TO GEL-BOX-COUNT GEL-BOX-LOST
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-WX WS-WZ WS-BOX
     MOVE 0 TO WS-FLAG
     IF GEL-BOX-COUNT = 1 AND GEL-B-KIND(1) = 2 AND GEL-B-MIN-X(1) = -29 AND GEL-B-MIN-Y(1) = 39 AND GEL-B-MIN-Z(1) = -29
        AND GEL-B-MAX-X(1) = 28 AND GEL-B-MAX-Y(1) = 61 AND GEL-B-MAX-Z(1) = 28
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: a chunk the building meets registers its whole box (x -29 to 28, y 39 to 61) as kind 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-WX
     MOVE 0 TO GEL-BOX-COUNT
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-WX WS-WZ WS-BOX
     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: a chunk the box does not reach registers nothing (the box is not inflated)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GEL-BOX-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the lists of kind 2: monster = guardian 1 (2 to 4), axolotls and underground water creature empty, the other categories keep the biome's
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-LISTS
         IF SO-L-KIND(WS-I) = 2
             EVALUATE SO-L-CAT(WS-I)
                 WHEN 1
                     MOVE 0 TO WS-FLAG
                     COMPUTE WS-J = SO-L-FIRST(WS-I) + 1
                     IF SO-L-COUNT(WS-I) = 1 AND SO-E-KEY(WS-J) = "guardian" AND SO-E-WEIGHT(WS-J) = 1 AND SO-E-MIN(WS-J) = 2 AND SO-E-MAX(WS-J) = 4
                         MOVE 1 TO WS-FLAG
                     END-IF
                     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: the monster list is the one guardian, weight 1, group 2 to 4" TO TL-CASE
                     MOVE 1 TO TL-EXPECTED-N
                     MOVE WS-FLAG TO TL-OBSERVED-N
                     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                 WHEN 4
                     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: the axolotls list is empty" TO TL-CASE
                     MOVE 0 TO TL-EXPECTED-N
                     MOVE SO-L-COUNT(WS-I) TO TL-OBSERVED-N
                     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                 WHEN 5
                     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: the underground water creature list is empty" TO TL-CASE
                     MOVE 0 TO TL-EXPECTED-N
                     MOVE SO-L-COUNT(WS-I) TO TL-OBSERVED-N
                     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             END-EVALUATE
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§5.10 Spawning in and around the monument: exactly three lists belong to the monument (no others override a category)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 END PROGRAM TEST-STRUCT-36-6-5-10.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
