*> Acceptance test of the ocean ruins (docs/protocol/36-structures-6 section 3; core/src/struct-ruin.cob) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without it):
*> the structure data (biome_temp, large_probability, cluster_probability, 3.1/3.3), the start (3.2 to 3.6: rotation, large draw, template choice, the three pieces of a cold ruin, the cluster
*> with its skipped candidates) against core/tests/fixtures/gen_oceanruin.py (an independent Java LCG model, world seed 12345), the code-defined processor lists (rot, block_ignore, the capped
*> archaeology rule, 2.4 and 3.5), the blocks that one piece keeps and the suspicious blocks it makes (3.7) against the same model over the NBT of the templates, the adapted height of a piece
*> (3.5 steps 1 to 3 over the base heights, plain loops written from the document), the data markers (3.5: chest and drowned) and a piece placed through the chunk window with its
*> brushable block entities requested from the block entity channel.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-RUIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 COPY STRUCTPLACE.
 COPY GENENT.
 COPY STRUCTCUR.
 COPY STRUCTSET.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-WARM                BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-LABEL               PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ED1                 PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-D                   FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-DIGIT               PIC 9.
 01 WS-TEMP                PIC X.
 01 WS-LOOT                PIC X(48).
 01 WS-SIGNED              PIC S9(6) SIGN LEADING SEPARATE.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PIECE               BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-SEED-WANT           BINARY-DOUBLE.
 01 WS-SEED-STATE          BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-GOT            BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-SIGNED         BINARY-DOUBLE.
*> the adapted height model
 01 WS-HX                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-HROT                BINARY-LONG.
 01 WS-HSX                 BINARY-LONG.
 01 WS-HSZ                 BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-LOWEST              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-XX                  BINARY-LONG.
 01 WS-ZZ                  BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-WANT-Y              BINARY-LONG.
 01 WS-GOT-Y               BINARY-LONG.
 01 WS-LOWERED             BINARY-LONG VALUE 0.
 01 WS-HIGH                BINARY-LONG VALUE 0.
*> the window
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-WCZ                 BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-SUSP                BINARY-LONG.
*> the start cases: H rows (cx, cz, rotation, warm, large, piece count) each followed by its P rows (template, x, z, rotation, integrity tenths, large)
 01 WS-START-DATA.
    05 FILLER PIC X(41) VALUE "H                -000012+000002010+000001".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000192+000032080+000000".
    05 FILLER PIC X(41) VALUE "H                -000011+000003011+000001".
    05 FILLER PIC X(41) VALUE "Pbig_warm_6      -000176+000048091+000000".
    05 FILLER PIC X(41) VALUE "H                -000008+000000111+000008".
    05 FILLER PIC X(41) VALUE "Pbig_warm_5      -000128+000000191+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_2          -000126+000021180+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_8          -000157-000011380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_4          -000140-000011080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_7          -000126+000005080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_2          -000155+000007080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_6          -000158+000017280+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_2          -000121-000010380+000000".
    05 FILLER PIC X(41) VALUE "H                -000012-000012111+000007".
    05 FILLER PIC X(41) VALUE "Pbig_warm_7      -000192-000192191+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000206-000202080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_3          -000190-000170280+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_1          -000189-000200380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_3          -000186-000186280+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_6          -000217-000170380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_8          -000216-000203080+000000".
    05 FILLER PIC X(41) VALUE "H                -000010-000010211+000008".
    05 FILLER PIC X(41) VALUE "Pbig_warm_4      -000160-000160291+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_3          -000188-000173180+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_1          -000156-000171380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_1          -000185-000186380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000169-000185180+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_3          -000186-000157380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_7          -000157-000154080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000157-000183180+000000".
    05 FILLER PIC X(41) VALUE "H                -000012-000007311+000004".
    05 FILLER PIC X(41) VALUE "Pbig_warm_4      -000192-000112391+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_4          -000174-000121080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_7          -000189-000139380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000169-000137380+000000".
    05 FILLER PIC X(41) VALUE "H                -000011+000012011+000009".
    05 FILLER PIC X(41) VALUE "Pbig_warm_4      -000176+000192091+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_2          -000154+000215180+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_8          -000171+000213080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_7          -000184+000182080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_1          -000172+000181080+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_5          -000158+000194380+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_4          -000158+000183180+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_1          -000187+000213280+000000".
    05 FILLER PIC X(41) VALUE "Pwarm_3          -000190+000193180+000000".
    05 FILLER PIC X(41) VALUE "H                -000012-000011310+000001".
    05 FILLER PIC X(41) VALUE "Pwarm_4          -000192-000176380+000000".
    05 FILLER PIC X(41) VALUE "H                -000012+000002000+000003".
    05 FILLER PIC X(41) VALUE "Pbrick_5         -000192+000032080+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_5       -000192+000032070+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_5         -000192+000032050+000000".
    05 FILLER PIC X(41) VALUE "H                -000011+000003001+000003".
    05 FILLER PIC X(41) VALUE "Pbig_brick_3     -000176+000048091+000000".
    05 FILLER PIC X(41) VALUE "Pbig_cracked_3   -000176+000048071+000000".
    05 FILLER PIC X(41) VALUE "Pbig_mossy_3     -000176+000048051+000000".
    05 FILLER PIC X(41) VALUE "H                -000012-000012101+000021".
    05 FILLER PIC X(41) VALUE "Pbig_brick_8     -000192-000192191+000000".
    05 FILLER PIC X(41) VALUE "Pbig_cracked_8   -000192-000192171+000000".
    05 FILLER PIC X(41) VALUE "Pbig_mossy_8     -000192-000192151+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_5         -000206-000202080+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_5       -000206-000202070+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_5         -000206-000202050+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_3         -000190-000170280+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_3       -000190-000170270+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_3         -000190-000170250+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_1         -000189-000200380+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_1       -000189-000200370+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_1         -000189-000200350+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_3         -000186-000186280+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_3       -000186-000186270+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_3         -000186-000186250+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_6         -000217-000170380+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_6       -000217-000170370+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_6         -000217-000170350+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_8         -000216-000203080+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_8       -000216-000203070+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_8         -000216-000203050+000000".
    05 FILLER PIC X(41) VALUE "H                -000011-000003301+000024".
    05 FILLER PIC X(41) VALUE "Pbig_brick_1     -000176-000048391+000000".
    05 FILLER PIC X(41) VALUE "Pbig_cracked_1   -000176-000048371+000000".
    05 FILLER PIC X(41) VALUE "Pbig_mossy_1     -000176-000048351+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_4         -000191-000072280+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_4       -000191-000072270+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_4         -000191-000072250+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_4         -000170-000074080+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_4       -000170-000074070+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_4         -000170-000074050+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_5         -000154-000062380+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_5       -000154-000062370+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_5         -000154-000062350+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_8         -000190-000046280+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_8       -000190-000046270+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_8         -000190-000046250+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_8         -000170-000043180+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_8       -000170-000043170+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_8         -000170-000043150+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_2         -000191-000061080+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_2       -000191-000061070+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_2         -000191-000061050+000000".
    05 FILLER PIC X(41) VALUE "Pbrick_3         -000159-000071380+000000".
    05 FILLER PIC X(41) VALUE "Pcracked_3       -000159-000071370+000000".
    05 FILLER PIC X(41) VALUE "Pmossy_3         -000159-000071350+000000".
 01 WS-START-T REDEFINES WS-START-DATA.
    05 WS-SR OCCURS 102 TIMES.
       10 SR-TAG           PIC X.
       10 SR-NAME          PIC X(16).
       10 SR-A             PIC S9(6) SIGN LEADING SEPARATE.
       10 SR-B             PIC S9(6) SIGN LEADING SEPARATE.
       10 SR-C             PIC 9.
       10 SR-D             PIC 9.
       10 SR-E             PIC 9.
       10 SR-F             PIC S9(6) SIGN LEADING SEPARATE.
*> the placement cases: C rows (template, x, z, rotation, integrity tenths, warm, kept blocks, suspicious count) each followed by its S rows (x, y, z, loot seed)
 01 WS-PLACE-DATA.
    05 FILLER PIC X(58) VALUE "Cwarm_3          +000016-000032181+000057+000005          ".
    05 FILLER PIC X(58) VALUE "S                +000011-000032+000040+5832571538614208982".
    05 FILLER PIC X(58) VALUE "S                +000013-000031+000040+7897921271217589804".
    05 FILLER PIC X(58) VALUE "S                +000010-000030+000040-5485852456029989473".
    05 FILLER PIC X(58) VALUE "S                +000013-000029+000040+3890480190903683713".
    05 FILLER PIC X(58) VALUE "S                +000011-000028+000040-6817625110949790157".
    05 FILLER PIC X(58) VALUE "Cmossy_2         -000048+000080250+000032+000005          ".
    05 FILLER PIC X(58) VALUE "S                -000048+000078+000040+2166544801410927500".
    05 FILLER PIC X(58) VALUE "S                -000049+000077+000040+1342326639808869352".
    05 FILLER PIC X(58) VALUE "S                -000049+000074+000040+7827528751112600036".
    05 FILLER PIC X(58) VALUE "S                -000050+000080+000040+4272187318204596127".
    05 FILLER PIC X(58) VALUE "S                -000053+000079+000040+2697317716605604201".
    05 FILLER PIC X(58) VALUE "Cbig_warm_5      +000000+000000391+000264+000005          ".
    05 FILLER PIC X(58) VALUE "S                +000007-000002+000040-4653078262286184252".
    05 FILLER PIC X(58) VALUE "S                +000006-000003+000040+8585753552238366162".
    05 FILLER PIC X(58) VALUE "S                +000012-000006+000040+4832725299187873232".
    05 FILLER PIC X(58) VALUE "S                +000004-000008+000040+6456535347894443004".
    05 FILLER PIC X(58) VALUE "S                +000001-000011+000040+2002290439598161165".
    05 FILLER PIC X(58) VALUE "Cbig_brick_1     +000032+000016090+000328+000005          ".
    05 FILLER PIC X(58) VALUE "S                +000035+000023+000040+8042006169409915794".
    05 FILLER PIC X(58) VALUE "S                +000042+000026+000040+4553125298193946818".
    05 FILLER PIC X(58) VALUE "S                +000043+000030+000040+0356087740337434876".
    05 FILLER PIC X(58) VALUE "S                +000045+000016+000040+7396130966412433277".
    05 FILLER PIC X(58) VALUE "S                +000033+000019+000041+0294876596140016328".
    05 FILLER PIC X(58) VALUE "Ccracked_7       +000005+000005070+000066+000005          ".
    05 FILLER PIC X(58) VALUE "S                +000005+000010+000040+7412800346219515423".
    05 FILLER PIC X(58) VALUE "S                +000010+000007+000040+4678703920765777925".
    05 FILLER PIC X(58) VALUE "S                +000010+000010+000040+2052904947537121812".
    05 FILLER PIC X(58) VALUE "S                +000006+000009+000041-5673486299114577035".
    05 FILLER PIC X(58) VALUE "S                +000008+000007+000041+5848191813105203033".
    05 FILLER PIC X(58) VALUE "Cwarm_8          -000003+000007281+000073+000005          ".
    05 FILLER PIC X(58) VALUE "S                -000005+000004+000040+6776225269030750229".
    05 FILLER PIC X(58) VALUE "S                -000006+000007+000040-6256375042273190390".
    05 FILLER PIC X(58) VALUE "S                -000007+000007+000040-3908687877355711976".
    05 FILLER PIC X(58) VALUE "S                -000008+000005+000040+4211376992206411011".
    05 FILLER PIC X(58) VALUE "S                -000008+000002+000041+7152998453125795617".
 01 WS-PLACE-T REDEFINES WS-PLACE-DATA.
    05 WS-PR OCCURS 36 TIMES.
       10 PR-TAG           PIC X.
       10 PR-NAME          PIC X(16).
       10 PR-A             PIC S9(6) SIGN LEADING SEPARATE.
       10 PR-B             PIC S9(6) SIGN LEADING SEPARATE.
       10 PR-REST          PIC X(27).
       10 PR-CV REDEFINES PR-REST.
          15 PR-ROT        PIC 9.
          15 PR-INT        PIC 9.
          15 PR-WARM       PIC 9.
          15 PR-KEPT       PIC S9(6) SIGN LEADING SEPARATE.
          15 PR-N          PIC S9(6) SIGN LEADING SEPARATE.
          15 FILLER        PIC X(10).
       10 PR-SV REDEFINES PR-REST.
          15 PR-Y          PIC S9(6) SIGN LEADING SEPARATE.
          15 PR-SEED       PIC S9(19) SIGN LEADING SEPARATE.
*> the height cases: x, z, rotation, size x, size z (a small template is 6 x 7, a big one 16 x 16)
 01 WS-HCASES.
    05 FILLER PIC X(19) VALUE "+000000+00000000607".
    05 FILLER PIC X(19) VALUE "+000100-00004010607".
    05 FILLER PIC X(19) VALUE "-000200+00012020607".
    05 FILLER PIC X(19) VALUE "+000300+00030030607".
    05 FILLER PIC X(19) VALUE "+000040+00004001616".
    05 FILLER PIC X(19) VALUE "-000500-00048220607".
    05 FILLER PIC X(19) VALUE "-000500-00047330607".
    05 FILLER PIC X(19) VALUE "-000500-00042800607".
    05 FILLER PIC X(19) VALUE "-000500-00041911616".
    05 FILLER PIC X(19) VALUE "-000500-00048221616".
 01 WS-HCASE-T REDEFINES WS-HCASES.
    05 WS-HC OCCURS 10 TIMES.
       10 HC-X             PIC S9(6) SIGN LEADING SEPARATE.
       10 HC-Z             PIC S9(6) SIGN LEADING SEPARATE.
       10 HC-ROT           PIC 9.
       10 HC-SX            PIC 99.
       10 HC-SZ            PIC 99.
 01 WS-META                PIC X(96).
 01 WS-U64                 PIC 9(20).
 01 WS-WANT-LOOT           PIC X(48).
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-SAVE-DIR            PIC X(1100).
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-PI-D                PIC 9(3).
 01 WS-HR-D                PIC 9.
 01 WS-SX-D                PIC 99.
 01 WS-SZ-D                PIC 99.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 01 WS-Z6                  BINARY-LONG VALUE 0.
 01 WS-PROP                PIC X(24).
 01 WS-TEXT                PIC X(32).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct ruin no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:ocean_ruin_warm"
                 MOVE WS-I TO WS-WARM
             WHEN "minecraft:ocean_ruin_cold"
                 MOVE WS-I TO WS-COLD
         END-EVALUATE
     END-PERFORM
     PERFORM DATA-CASES
     PERFORM START-CASES
     PERFORM LIST-CASES
     PERFORM PLACE-CASES
     PERFORM HEIGHT-CASES
     PERFORM MARKER-CASES
     PERFORM WINDOW-CASE
     PERFORM ABSENT-CASE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 3.1 the data: the warm structure is variant 1, both read the probabilities of the data as float32 (0.3 and 0.9)
 DATA-CASES.
     MOVE "test struct ruin given the data when the structures are read then both are present" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-WARM > 0 AND WS-COLD > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given the data when ocean_ruin_warm is read then it is the warm variant, cold is not" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-VARIANT(WS-WARM) = 1 AND SDT-VARIANT(WS-COLD) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given the data when the probabilities are read then they are 0.3f and 0.9f for both" TO TL-CASE
     MOVE 0.3 TO WS-F32
     MOVE WS-F32 TO WS-D
     MOVE 0 TO WS-FLAG
     IF SDT-LARGE(WS-WARM) = WS-D AND SDT-LARGE(WS-COLD) = WS-D
         MOVE 0.9 TO WS-F32
         MOVE WS-F32 TO WS-D
         IF SDT-CLUSTER(WS-WARM) = WS-D AND SDT-CLUSTER(WS-COLD) = WS-D
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK.

*> 3.2 to 3.6 the start of the model's cases
 START-CASES.
     MOVE 0 TO WS-HEAD
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 102
         IF SR-TAG(WS-R) = "H"
             MOVE WS-R TO WS-HEAD
             MOVE 0 TO WS-PI
             IF SR-D(WS-R) = 1
                 MOVE WS-WARM TO WS-STRUCT
             ELSE
                 MOVE WS-COLD TO WS-STRUCT
             END-IF
             MOVE SR-A(WS-R) TO WS-CX
             MOVE SR-B(WS-R) TO WS-CZ
             CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
             MOVE WS-CX TO WS-ED1
             MOVE WS-CZ TO WS-ED2
             MOVE SPACES TO WS-LABEL
             STRING "warm " SR-D(WS-R) " chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO WS-LABEL
             MOVE SPACES TO TL-CASE
             STRING "test struct ruin given " FUNCTION TRIM(WS-LABEL) " when the start is built then it is valid on top of the chunk centre" DELIMITED BY SIZE INTO TL-CASE
             COMPUTE WS-X = WS-CX * 16 + 8
             COMPUTE WS-Z = WS-CZ * 16 + 8
             CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-ONE WS-H0
             MOVE 0 TO WS-FLAG
             IF WS-VALID = 1
                 COMPUTE WS-TOP = WS-H0 - 1
                 CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
                 IF WS-Y = WS-TOP AND WS-X = WS-CX * 16 + 8 AND WS-Z = WS-CZ * 16 + 8
                     MOVE 1 TO WS-FLAG
                 END-IF
             END-IF
             PERFORM CHECK
             MOVE SPACES TO TL-CASE
             STRING "test struct ruin given " FUNCTION TRIM(WS-LABEL) " when the start is built then the piece count is the model's" DELIMITED BY SIZE INTO TL-CASE
             MOVE SR-F(WS-R) TO TL-EXPECTED-N
             MOVE SP-COUNT TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         ELSE
             ADD 1 TO WS-PI
             MOVE WS-PI TO WS-PI-D
             MOVE SPACES TO TL-CASE
             STRING "test struct ruin given " FUNCTION TRIM(WS-LABEL) " when the start is built then piece " WS-PI-D " is the model's (template, x, z, rotation, integrity list, large, y 90, kind)" DELIMITED BY SIZE INTO TL-CASE
             MOVE 0 TO WS-FLAG
             IF WS-PI <= SP-COUNT
                 PERFORM START-PIECE-FLAG
             END-IF
             PERFORM CHECK
         END-IF
     END-PERFORM.

 START-PIECE-FLAG.
     MOVE SP-T-ROW(WS-PI) TO WS-ROW
     MOVE SPACES TO WS-ID
     STRING "minecraft:underwater_ruin/" FUNCTION TRIM(SR-NAME(WS-R)) DELIMITED BY SIZE INTO WS-ID
     IF SR-D(WS-HEAD) = 1
         MOVE "w" TO WS-TEMP
     ELSE
         MOVE "c" TO WS-TEMP
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "cobolcraft:inline/ruin/" WS-TEMP "/" SR-D(WS-R) DELIMITED BY SIZE INTO WS-KEY
     IF TP-KEY(WS-ROW) = WS-ID AND SP-T-X(WS-PI) = SR-A(WS-R) AND SP-T-Z(WS-PI) = SR-B(WS-R) AND SP-T-ROT(WS-PI) = SR-C(WS-R)
        AND SP-T-Y(WS-PI) = 90 AND SP-T-AUX(WS-PI) = SR-E(WS-R) AND SP-T-KIND(WS-PI) = 3 AND SPL-KEY(SP-T-PROC(WS-PI)) = WS-KEY
         MOVE 1 TO WS-FLAG
     END-IF.

*> 2.4 and 3.5: the code-defined lists are rot(integrity), block_ignore(air, structure_block) and the capped(5) archaeology rule of the temperature
 LIST-CASES.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 5 BY 1 UNTIL WS-J > 9
             IF WS-J = 5 OR WS-J = 7 OR WS-J = 8 OR WS-J = 9
                 IF WS-I = 1
                     MOVE "w" TO WS-TEMP
                 ELSE
                     MOVE "c" TO WS-TEMP
                 END-IF
                 MOVE WS-J TO WS-DIGIT
                 MOVE SPACES TO WS-KEY
                 STRING "cobolcraft:inline/ruin/" WS-TEMP "/" WS-DIGIT DELIMITED BY SIZE INTO WS-KEY
                 CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
                 MOVE SPACES TO TL-CASE
                 STRING "test struct ruin given the list " FUNCTION TRIM(WS-KEY) " when it is loaded then it is rot, block_ignore and capped with the rule" DELIMITED BY SIZE INTO TL-CASE
                 MOVE 0 TO WS-FLAG
                 IF WS-LIST > 0
                     PERFORM LIST-FLAG
                 END-IF
                 PERFORM CHECK
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "cobolcraft:inline/ruin/x/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct ruin given an inline list of no known temperature when it is loaded then there is none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

 LIST-FLAG.
     COMPUTE WS-D = WS-J / 10
     MOVE WS-D TO WS-F32
     MOVE WS-F32 TO WS-D
     IF SPL-N(WS-LIST) = 3 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 3 AND SPP-F(SPL-FIRST(WS-LIST)) = WS-D
        AND SPP-A(SPL-FIRST(WS-LIST)) = 0 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 9 AND SPP-N(SPL-FIRST(WS-LIST) + 1) = 2
        AND SPP-TYPE(SPL-FIRST(WS-LIST) + 2) = 4 AND SPP-B(SPL-FIRST(WS-LIST) + 2) = 1 AND SPP-C(SPL-FIRST(WS-LIST) + 2) = 5
         MOVE SPP-A(SPL-FIRST(WS-LIST) + 2) TO WS-K
         MOVE SPP-A(WS-K) TO WS-K
         IF SPP-TYPE(SPL-FIRST(WS-LIST) + 2) = 4 AND SPP-N(SPP-A(SPL-FIRST(WS-LIST) + 2)) = 1
             MOVE SPP-A(SPP-A(SPL-FIRST(WS-LIST) + 2)) TO WS-K
             IF WS-TEMP = "w"
                 MOVE "minecraft:archaeology/ocean_ruin_warm" TO WS-LOOT
             ELSE
                 MOVE "minecraft:archaeology/ocean_ruin_cold" TO WS-LOOT
             END-IF
             IF SPR-LOOT(WS-K) = WS-LOOT AND SPR-MOD(WS-K) = 3
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
     END-IF.

*> 2.4, 3.5, 3.7: the blocks one piece keeps and converts, against the model (the template placed at (x, 40, z))
 PLACE-CASES.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 36
         IF PR-TAG(WS-R) = "C"
             PERFORM ONE-PLACE
         END-IF
     END-PERFORM.

 ONE-PLACE.
     MOVE SPACES TO WS-ID
     STRING "minecraft:underwater_ruin/" FUNCTION TRIM(PR-NAME(WS-R)) DELIMITED BY SIZE INTO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     IF PR-WARM(WS-R) = 1
         MOVE "w" TO WS-TEMP
         MOVE "minecraft:archaeology/ocean_ruin_warm" TO WS-WANT-LOOT
     ELSE
         MOVE "c" TO WS-TEMP
         MOVE "minecraft:archaeology/ocean_ruin_cold" TO WS-WANT-LOOT
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "cobolcraft:inline/ruin/" WS-TEMP "/" PR-INT(WS-R) DELIMITED BY SIZE INTO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     INITIALIZE STRUCT-SETTINGS
     MOVE PR-ROT(WS-R) TO PS-ROTATION
     MOVE WS-LIST TO PS-PROCESSORS
     MOVE CW-SEED TO PS-SEED
     MOVE PR-A(WS-R) TO WS-OX
     MOVE 40 TO WS-OY
     MOVE PR-B(WS-R) TO WS-OZ
     MOVE WS-OX TO WS-AX
     MOVE WS-OY TO WS-AY
     MOVE WS-OZ TO WS-AZ
     CALL "STRUCT-PROCESS" USING WS-ROW WS-ZERO WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS
     MOVE SPACES TO TL-CASE
     STRING "test struct ruin given " FUNCTION TRIM(PR-NAME(WS-R)) " rotation " PR-ROT(WS-R) " list " FUNCTION TRIM(WS-KEY) " when it is processed then the kept blocks are the model's" DELIMITED BY SIZE INTO TL-CASE
     MOVE PR-KEPT(WS-R) TO TL-EXPECTED-N
     MOVE PW-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CHANGED
     MOVE 0 TO WS-MATCHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-COUNT
         IF PW-LOOT(WS-I) > 0
             ADD 1 TO WS-CHANGED
             COMPUTE WS-K = WS-R + WS-CHANGED
             IF PR-TAG(WS-K) = "S"
                 IF PW-X(WS-I) = PR-A(WS-K) AND PW-Y(WS-I) = PR-Y(WS-K) AND PW-Z(WS-I) = PR-B(WS-K) AND PW-SEED(WS-I) = PR-SEED(WS-K)
                    AND SPR-LOOT(PW-LOOT(WS-I)) = WS-WANT-LOOT
                     ADD 1 TO WS-MATCHED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "test struct ruin given " FUNCTION TRIM(PR-NAME(WS-R)) " rotation " PR-ROT(WS-R) " when it is processed then the suspicious blocks are made in the model's number" DELIMITED BY SIZE INTO TL-CASE
     MOVE PR-N(WS-R) TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "test struct ruin given " FUNCTION TRIM(PR-NAME(WS-R)) " rotation " PR-ROT(WS-R) " when it is processed then their positions, loot seeds and tables are the model's" DELIMITED BY SIZE INTO TL-CASE
     MOVE PR-N(WS-R) TO TL-EXPECTED-N
     MOVE WS-MATCHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 3.5 steps 1 to 3: the adapted height against plain loops over the base heights of the columns (a column is solid up to its top, the first free y minus one)
 HEIGHT-CASES.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 10
         MOVE HC-X(WS-R) TO WS-HX
         MOVE HC-Z(WS-R) TO WS-HZ
         MOVE HC-ROT(WS-R) TO WS-HROT
         MOVE HC-SX(WS-R) TO WS-HSX
         MOVE HC-SZ(WS-R) TO WS-HSZ
         CALL "STRUCT-RUIN-HEIGHT" USING WS-HX WS-HZ WS-HROT WS-HSX WS-HSZ WS-GOT-Y
         PERFORM HEIGHT-MODEL
         MOVE WS-HROT TO WS-HR-D
         MOVE WS-HSX TO WS-SX-D
         MOVE WS-HSZ TO WS-SZ-D
         MOVE WS-HX TO WS-ED1
         MOVE WS-HZ TO WS-ED2
         MOVE SPACES TO TL-CASE
         STRING "test struct ruin given the footprint at " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) " rotation " WS-HR-D " size " WS-SX-D "x" WS-SZ-D
             " when its height is adapted then it is the plain loops' (and the second ask, from the memory, is the same)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-GOT-Y = WS-WANT-Y
             CALL "STRUCT-RUIN-HEIGHT" USING WS-HX WS-HZ WS-HROT WS-HSX WS-HSZ WS-GOT-Y
             IF WS-GOT-Y = WS-WANT-Y
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
         IF WS-WANT-Y = WS-H0
             ADD 1 TO WS-HIGH
         ELSE
             ADD 1 TO WS-LOWERED
         END-IF
     END-PERFORM
     MOVE "test struct ruin given the height cases when they are adapted then some are lowered to one above the lowest floor" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LOWERED > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given the height cases when they are adapted then some stay on the heightmap of the anchor" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-HIGH > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

 HEIGHT-MODEL.
     CALL "STRUCT-BASE-HEIGHT" USING WS-HX WS-HZ WS-ONE WS-H0
*>   the far corner of the footprint: transform((sx - 1, 0, sz - 1)) + the anchor, 2.2 with the pivot (0, 0)
     EVALUATE WS-HROT
         WHEN 0
             COMPUTE WS-CX2 = WS-HX + WS-HSX - 1
             COMPUTE WS-CZ2 = WS-HZ + WS-HSZ - 1
         WHEN 1
             COMPUTE WS-CX2 = WS-HX - (WS-HSZ - 1)
             COMPUTE WS-CZ2 = WS-HZ + WS-HSX - 1
         WHEN 2
             COMPUTE WS-CX2 = WS-HX - (WS-HSX - 1)
             COMPUTE WS-CZ2 = WS-HZ - (WS-HSZ - 1)
         WHEN OTHER
             COMPUTE WS-CX2 = WS-HX + WS-HSZ - 1
             COMPUTE WS-CZ2 = WS-HZ - (WS-HSX - 1)
     END-EVALUATE
     MOVE FUNCTION MIN(WS-HX, WS-CX2) TO WS-X0
     MOVE FUNCTION MAX(WS-HX, WS-CX2) TO WS-X1
     MOVE FUNCTION MIN(WS-HZ, WS-CZ2) TO WS-Z0
     MOVE FUNCTION MAX(WS-HZ, WS-CZ2) TO WS-Z1
     COMPUTE WS-BASE = WS-H0 - 1
     MOVE 512 TO WS-LOWEST
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ZZ FROM WS-Z0 BY 1 UNTIL WS-ZZ > WS-Z1
         PERFORM VARYING WS-XX FROM WS-X0 BY 1 UNTIL WS-XX > WS-X1
             CALL "STRUCT-BASE-HEIGHT" USING WS-XX WS-ZZ WS-ONE WS-TOP
             SUBTRACT 1 FROM WS-TOP
             MOVE WS-BASE TO WS-YY
             PERFORM UNTIL WS-YY <= -63 OR WS-YY <= WS-TOP
                 SUBTRACT 1 FROM WS-YY
             END-PERFORM
             IF WS-YY < WS-LOWEST
                 MOVE WS-YY TO WS-LOWEST
             END-IF
             IF WS-YY < WS-BASE - 2
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-DX = WS-X1 - WS-X0
     MOVE WS-H0 TO WS-WANT-Y
     IF WS-BASE - WS-LOWEST > 2 AND WS-COUNT > WS-DX - 2
         COMPUTE WS-WANT-Y = WS-LOWEST + 1
     END-IF.

*> 3.5 handleDataMarker over a window: chest (the table of the size, a waterlogged chest in water, one seed) and drowned (air above the sea level, water at or below it)
 MARKER-CASES.
     PERFORM WINDOW-OPEN
     MOVE 1 TO SP-COUNT
     MOVE 3 TO SP-T-KIND(1)
     MOVE 1 TO SP-T-AUX(1)
     MOVE "minecraft:water" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE 4 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-TWO WS-FLAG
     PERFORM RESET-RANDOM
     MOVE "chest" TO WS-META
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test struct ruin given a big ruin when the chest marker is in water then a waterlogged chest asks for the big table with the first seed" TO TL-CASE
     PERFORM MARKER-CHEST-FLAG
     IF WS-FLAG = 1 AND GBL-LOOT(1) = "minecraft:chests/underwater_ruin_big"
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given a big ruin when the chest marker is in water then the chest is waterlogged" TO TL-CASE
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     PERFORM STATE-WATERLOGGED
     PERFORM CHECK
     MOVE 0 TO SP-T-AUX(1)
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test struct ruin given a small ruin when the chest marker is in the air then a dry chest asks for the small table with the first seed" TO TL-CASE
     PERFORM MARKER-CHEST-FLAG
     IF WS-FLAG = 1 AND GBL-LOOT(1) = "minecraft:chests/underwater_ruin_small"
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         PERFORM STATE-WATERLOGGED
         IF WS-FLAG = 1
             MOVE 0 TO WS-FLAG
         ELSE
             MOVE 1 TO WS-FLAG
         END-IF
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "drowned" TO WS-META
     MOVE 64 TO WS-Y
     PERFORM RESET-RANDOM
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test struct ruin given a drowned marker when it is handled then one persistent drowned is requested from the entity channel at the block centre" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GEL-COUNT = 1 AND GEL-NBT(1)(8:17) = "minecraft:drowned" AND GEL-Y(1) = 64
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given a drowned marker above the sea level when it is handled then there is air and no draw and no request" TO TL-CASE
     PERFORM MARKER-BLOCK-FLAG
     IF WS-KEY = "air" AND GBL-COUNT = 0
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 63 TO WS-Y
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test struct ruin given a drowned marker at the sea level when it is handled then there is water" TO TL-CASE
     PERFORM MARKER-BLOCK-FLAG
     IF WS-KEY = "water"
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "something" TO WS-META
     MOVE 66 TO WS-Y
     PERFORM RESET-RANDOM
     CALL "STRUCT-DATA-MARKER" USING WS-ONE WS-META WS-X WS-Y WS-Z
     MOVE "test struct ruin given another marker when it is handled then nothing changes and nothing is drawn" TO TL-CASE
     CALL "MSP-RNG-LONG" USING WS-SEED-SIGNED
     MOVE 0 TO WS-FLAG
     IF WS-SEED-SIGNED = WS-S1 AND GBL-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> one chest request with the first draw of the random at its known state, the block there a chest
 MARKER-CHEST-FLAG.
     MOVE 0 TO WS-FLAG
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF GBL-COUNT = 1 AND GBL-KIND(1) = 1 AND GBL-SEED(1) = WS-S1 AND GBL-X(1) = WS-X AND GBL-Y(1) = WS-Y AND GBL-Z(1) = WS-Z
        AND CB-KEY(WS-BLOCK) = "chest"
         MOVE 1 TO WS-FLAG
     END-IF.

 STATE-WATERLOGGED.
     MOVE "waterlogged" TO WS-PROP
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-PROP WS-TEXT WS-FLAG
     IF WS-FLAG = 1 AND WS-TEXT = "true"
         MOVE 1 TO WS-FLAG
     ELSE
         MOVE 0 TO WS-FLAG
     END-IF.

 MARKER-BLOCK-FLAG.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE SPACES TO WS-KEY
     MOVE CB-KEY(WS-BLOCK) TO WS-KEY.

*> the chunk window of chunk (0, 0), empty
 WINDOW-OPEN.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO GBL-COUNT GBL-LOST.

*> the piece random at a known state, its first draw recorded in WS-S1
 RESET-RANDOM.
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-RNG-LONG" USING WS-S1
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI.

*> a cold piece (brick_1, 0.8) placed in the window by STRUCT-PLACE-START: the height of 3.5, then at most five suspicious gravel blocks, each requested with its table and seed
 WINDOW-CASE.
     PERFORM WINDOW-OPEN
     CALL "SPB-RESET"
     MOVE "minecraft:underwater_ruin/brick_1" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE "cobolcraft:inline/ruin/c/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE 3 TO WS-K
     MOVE 4 TO WS-OX
     MOVE 90 TO WS-OY
     MOVE 4 TO WS-OZ
     MOVE 0 TO WS-ROT
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-K WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-Z2 WS-Z3 WS-Z4 WS-LIST WS-Z5 WS-Z6 WS-PIECE
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 6 TO WS-HSX
     MOVE 7 TO WS-HSZ
     CALL "STRUCT-RUIN-HEIGHT" USING WS-OX WS-OZ WS-ROT WS-HSX WS-HSZ WS-WANT-Y
     MOVE "test struct ruin given a piece placed in the window when it is post-processed then it sits at the adapted height" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SP-T-Y(1) = WS-WANT-Y
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO WS-MATCHED
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GBL-COUNT
         CALL "FL-GET-STATE" USING GBL-X(WS-I) GBL-Y(WS-I) GBL-Z(WS-I) WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "STRUCT-POS-RANDOM" USING GBL-X(WS-I) GBL-Y(WS-I) GBL-Z(WS-I) WS-SEED-STATE
         CALL "JRAND-NEXT-LONG" USING WS-SEED-STATE WS-SEED-GOT
         MOVE WS-SEED-GOT TO WS-U64
         IF WS-U64 >= 9223372036854775808
             COMPUTE WS-SEED-SIGNED = WS-U64 - 18446744073709551616
         ELSE
             MOVE WS-U64 TO WS-SEED-SIGNED
         END-IF
         IF GBL-LOOT(WS-I)(1:22) = "minecraft:archaeology/"
             ADD 1 TO WS-CHANGED
             IF CB-KEY(WS-BLOCK) = "suspicious_gravel" AND GBL-KIND(WS-I) = 1 AND GBL-LOOT(WS-I) = "minecraft:archaeology/ocean_ruin_cold"
                AND GBL-SEED(WS-I) = WS-SEED-SIGNED
                 ADD 1 TO WS-MATCHED
             END-IF
         END-IF
     END-PERFORM
     MOVE "test struct ruin given a piece placed in the window when it is post-processed then one to five suspicious gravel blocks are requested" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-CHANGED >= 1 AND WS-CHANGED <= 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct ruin given a piece placed in the window when it is post-processed then every one is a suspicious gravel block with the table of the cold ruin and the seed of its position" TO TL-CASE
     MOVE WS-CHANGED TO TL-EXPECTED-N
     MOVE WS-MATCHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct ruin given a piece placed in the window when it is post-processed then the other request is the chest marker's with the small table" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF GBL-COUNT = WS-CHANGED + 1 AND GBL-LOOT(GBL-COUNT) = "minecraft:chests/underwater_ruin_small"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO WS-SUSP
     PERFORM VARYING WS-Y FROM SP-Y0(1) BY 1 UNTIL WS-Y > SP-Y1(1)
         PERFORM VARYING WS-Z FROM SP-Z0(1) BY 1 UNTIL WS-Z > SP-Z1(1)
             PERFORM VARYING WS-X FROM SP-X0(1) BY 1 UNTIL WS-X > SP-X1(1)
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF CB-KEY(WS-BLOCK) = "suspicious_gravel"
                     ADD 1 TO WS-SUSP
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test struct ruin given a piece placed in the window when it is post-processed then the window holds exactly the requested suspicious blocks" TO TL-CASE
     MOVE WS-CHANGED TO TL-EXPECTED-N
     MOVE WS-SUSP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 *> no template file under the data folder: no piece and an invalid start (the cache forgets what it loaded first)
 ABSENT-CASE.
     MOVE SD-DIR TO WS-SAVE-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "/nonexistent/folder" TO SD-DIR
     MOVE -3 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-WARM CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE WS-SAVE-DIR TO SD-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "test struct ruin given no template files when a ruin is built then the start is invalid and has no piece" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-RUIN.

 COPY CORETEST.
