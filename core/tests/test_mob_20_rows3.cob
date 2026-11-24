*> Implementation test (002-lane-mobsfull-h11; docs/protocol/20 sections 11, 12, 13): the rows 35 to 42 of core/copy/STDMOBS.cpy (MOB20ROWS3.cpy): witch, phantom,
*> vindicator, pillager, evoker, vex, illusioner, ravager: max health, attack damage, follow range, experience (XP of the doc tables), daylight burning (phantom
*> only), the natural spawn rule (the witch has the monster rule 2, the others come from patrols, raids, summons and spawners: 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-ROWS3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(10) VALUE "witch".
    05 FILLER              PIC X(10) VALUE "phantom".
    05 FILLER              PIC X(10) VALUE "vindicator".
    05 FILLER              PIC X(10) VALUE "pillager".
    05 FILLER              PIC X(10) VALUE "evoker".
    05 FILLER              PIC X(10) VALUE "vex".
    05 FILLER              PIC X(10) VALUE "illusioner".
    05 FILLER              PIC X(10) VALUE "ravager".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(10) OCCURS 8 TIMES.
 01 WS-DATA.
    05 FILLER              PIC X(18) VALUE "026 00 16 05 02 00".
    05 FILLER              PIC X(18) VALUE "020 06 64 05 00 01".
    05 FILLER              PIC X(18) VALUE "024 05 12 05 00 00".
    05 FILLER              PIC X(18) VALUE "024 05 32 05 19 00".
    05 FILLER              PIC X(18) VALUE "024 00 12 10 00 00".
    05 FILLER              PIC X(18) VALUE "014 04 16 03 00 00".
    05 FILLER              PIC X(18) VALUE "032 00 18 05 00 00".
    05 FILLER              PIC X(18) VALUE "100 12 32 20 00 00".
 01 WS-DATA-TABLE REDEFINES WS-DATA.
    05 WS-LINE OCCURS 8 TIMES.
       10 WS-HP            PIC 999.
       10 FILLER           PIC X.
       10 WS-ATK           PIC 99.
       10 FILLER           PIC X.
       10 WS-FOL           PIC 99.
       10 FILLER           PIC X.
       10 WS-XP            PIC 99.
       10 FILLER           PIC X.
       10 WS-SPN           PIC 99.
       10 FILLER           PIC X.
       10 WS-BRN           PIC 99.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 20 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " is row" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = 41 + WS-I
         MOVE WS-INDEX TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-INDEX > 0
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 20 " DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
                 " health, attack, follow, xp, spawn, burns, monster kind" DELIMITED BY SIZE INTO TL-CASE
             COMPUTE TL-EXPECTED-N = WS-HP(WS-I) * 100000000 + WS-ATK(WS-I) * 1000000 + WS-FOL(WS-I) * 10000
                 + WS-XP(WS-I) * 100 + WS-SPN(WS-I) * 10 + WS-BRN(WS-I)
             COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-INDEX) * 100000000 + SM-ATTACK(WS-INDEX) * 1000000
                 + SM-FOLLOW(WS-INDEX) * 10000 + SM-XP(WS-INDEX) * 100 + SM-SPAWN(WS-INDEX) * 10 + SM-BURNS(WS-INDEX)
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-ROWS3.
 COPY CORETEST.
 COPY MOBSPTEST.
