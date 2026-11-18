*> Acceptance test (002-lane-p49b; docs/protocol/21 sections 3.1 and 3.2): spawn placement of the mobs of document 21. The natural spawn rule of each species row (SM-SPAWN) is the
*> predicate section 3.1 names: the surface water animal rule (7: cod, salmon, pufferfish, squid, dolphin), the tropical fish rule (8), the glow squid rule (9), the any-light
*> monster rule (10: blaze, zoglin, zombified piglin, magma cube), the ghast rule (12: not Peaceful, nextInt(20) = 0, then the floor test), the piglin and hoglin floor-only rule
*> (11) and the monster rule (2: skeleton, wither skeleton). The strider (IN_LAVA) and the shulker have no natural rule here. Live: a ghast on a stone floor passes about one try in 20
*> and never on Peaceful.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PASSES              BINARY-LONG.
 01 WS-DATA.
    05 FILLER              PIC X(32) VALUE "cod              07".
    05 FILLER              PIC X(32) VALUE "salmon           07".
    05 FILLER              PIC X(32) VALUE "pufferfish       07".
    05 FILLER              PIC X(32) VALUE "squid            07".
    05 FILLER              PIC X(32) VALUE "dolphin          07".
    05 FILLER              PIC X(32) VALUE "tropical_fish    08".
    05 FILLER              PIC X(32) VALUE "glow_squid       09".
    05 FILLER              PIC X(32) VALUE "blaze            10".
    05 FILLER              PIC X(32) VALUE "zoglin           10".
    05 FILLER              PIC X(32) VALUE "zombified_piglin 10".
    05 FILLER              PIC X(32) VALUE "magma_cube       10".
    05 FILLER              PIC X(32) VALUE "ghast            12".
    05 FILLER              PIC X(32) VALUE "piglin           11".
    05 FILLER              PIC X(32) VALUE "hoglin           11".
    05 FILLER              PIC X(32) VALUE "skeleton         02".
    05 FILLER              PIC X(32) VALUE "wither_skeleton  02".
    05 FILLER              PIC X(32) VALUE "strider          00".
    05 FILLER              PIC X(32) VALUE "shulker          00".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-LINE OCCURS 18 TIMES.
       10 WS-L-NAME        PIC X(17).
       10 WS-L-CODE        PIC 99.
       10 FILLER           PIC X(13).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE WS-L-NAME(WS-I) TO WS-NAME
         CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§3.1 " DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " natural spawn rule code" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE WS-L-CODE(WS-I) TO TL-EXPECTED-N
         MOVE -1 TO TL-OBSERVED-N
         IF WS-M > 0
             MOVE SM-SPAWN(WS-M) TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The ghast rule (Ghast.checkGhastSpawnRules): about 1 try in 20 passes on a stone floor, none on Peaceful.
     MOVE "ghast" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 30
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-N1 = WS-BY - 1
     CALL "TEST-FLOOR-HERE" USING WS-DIM WS-BX WS-N1 WS-BZ
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE 1 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE 0 TO WS-PASSES
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-N1 WS-OK
         ADD WS-OK TO WS-PASSES
     END-PERFORM
     MOVE "acceptance US15 21§3.2 ghast: about 1 try in 20 passes (400 tries)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASSES >= 8 AND WS-PASSES <= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BW-DIFFICULTY
     MOVE 0 TO WS-PASSES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-N1 WS-OK
         ADD WS-OK TO WS-PASSES
     END-PERFORM
     MOVE "acceptance US15 21§3.2 ghast: never on Peaceful" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASSES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-3-1.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
