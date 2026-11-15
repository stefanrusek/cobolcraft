*> Acceptance test of the ruined portal (docs/protocol/36-structures-4 section 8; core/src/struct-portal.cob): the setups of the structure files (8.1), the start (8.2 and 8.3: the
*> setup draw, the air pocket, the template, the rotation and mirror, the box, the suitable height of every placement) against core/tests/fixtures/gen_portal.py (an independent
*> Java LCG model, world seed 12345, the synthetic surface of JIG-TEST-SURFACE), the piece's processor lists (8.4) and the piece through the chunk window: the write box rule, the
*> spread of netherrack (8.5), the drip columns, the vines and the leaves (8.6). Runs over the standard content set of the generated packs (skipped as a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PORTAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 COPY STRUCTPORTAL.
 COPY STRUCTJIG.
 COPY JSONDOC.
 COPY FEATDATA.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ED1                 PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-ID                  PIC X(96).
 01 WS-LABEL               PIC X(100).
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG.
 01 WS-WCZ                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-OK                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-COUNTS.
    05 WN-NETHERRACK       BINARY-LONG.
    05 WN-MAGMA            BINARY-LONG.
    05 WN-OBSIDIAN         BINARY-LONG.
    05 WN-LEAVES           BINARY-LONG.
    05 WN-VINE             BINARY-LONG.
 01 WS-FIRST-COUNTS        PIC X(20).
 01 WS-WINDOW-OPEN         BINARY-LONG VALUE 0.
 01 WS-DUMMY               PIC X.
 01 WS-SAVE-DIR            PIC X(1100).
 01 WS-TEMP-DIR            PIC X(1100) VALUE "core/tests/fixtures/jigpool".
 01 WS-BIOME               PIC X(40).
 01 WS-T                   FLOAT-LONG.
 01 WS-COLD-N              BINARY-LONG.
 01 WS-WARM-N              BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-NAME-PORTAL         PIC X(40) VALUE "ruined_portal".
 01 WS-PORTAL-ID           BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-LAST-ROW            BINARY-LONG.
 01 WS-AIRS                BINARY-LONG.
 01 WS-NOAIRS              BINARY-LONG.
 01 WS-SAVE-DIR2           PIC X(1100).
 01 WS-BAD-DIR             PIC X(1100) VALUE "/nonexistent/folder".
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
*> the model's starts
 01 WS-START-DATA.
    05 FILLER PIC X(130) VALUE "ruined_portal           +00000+0000001portal_2        32+0055+000000+000000+000000+000008+000008+0000161                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           +00005+0000501portal_2        32+0033+000080+000080+000080+000088+000088+0000961                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           -00007+0000310portal_7        00+0068-000112+000048-000112+000048-000104+0000561                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           +00011-0000410portal_10       10+0067+000176-000064+000178-000065+000187-0000541                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           +00002+0000901giant_portal_1  00+0048+000032+000144+000032+000144+000042+0001591                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           -00003-0000801portal_10       32+0004-000048-000128-000047-000117-000038-0001061                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_desert    +00003+0000300portal_7        10+0063+000048+000048+000048+000048+000056+0000561                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_desert    -00006+0000100portal_4        22+0066-000096+000016-000088+000016-000081+0000241                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_jungle    +00004-0000200portal_8        30+0067+000064-000032+000067-000034+000075-0000211                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_swamp     -00001+0000600portal_1        30+0068-000016+000096-000016+000097-000011+0001021                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  +00008+0000810giant_portal_2  32+0068+000128+000128+000125+000141+000140+0001511                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  -00005-0000501portal_9        22+0063-000080-000080-000070-000080-000061-0000721                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  +00001+0001201portal_6        30+0062+000016+000192+000015+000193+000021+0001971                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_ocean     +00007-0000300portal_2        30+0068+000112-000048+000112-000048+000120-0000401                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_nether    +00002+0000200portal_2        32+0029+000032+000032+000032+000040+000040+0000481                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_nether    -00009+0000400giant_portal_1  22+0029-000144+000064-000134+000065-000124+0000801                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           +00005+0000501portal_2        32-0053+000080+000080+000080+000088+000088+0000962                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal           -00007+0000310portal_7        00-0041-000112+000048-000112+000048-000104+0000562                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  +00008+0000810giant_portal_2  32+0199+000128+000128+000125+000141+000140+0001513                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  +00001+0001201portal_6        30+0142+000016+000192+000015+000193+000021+0001973                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_mountain  -00005-0000501portal_9        22-0049-000080-000080-000070-000080-000061-0000722                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_desert    +00003+0000300portal_7        10+0194+000048+000048+000048+000048+000056+0000563                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_swamp     -00001+0000600portal_1        30+0199-000016+000096-000016+000097-000011+0001023                          ".
    05 FILLER PIC X(130) VALUE "ruined_portal_swamp     -00001+0000600portal_1        30-0041-000016+000096-000016+000097-000011+0001022                          ".
 01 WS-START-T REDEFINES WS-START-DATA.
    05 WS-ST OCCURS 24 TIMES.
       10 ST-NAME          PIC X(24).
       10 ST-CX            PIC S9(5) SIGN LEADING SEPARATE.
       10 ST-CZ            PIC S9(5) SIGN LEADING SEPARATE.
       10 ST-SETUP         PIC 9.
       10 ST-AIR           PIC 9.
       10 ST-TPL           PIC X(16).
       10 ST-ROT           PIC 9.
       10 ST-MIRROR        PIC 9.
       10 ST-Y             PIC S9(4) SIGN LEADING SEPARATE.
       10 ST-PX            PIC S9(6) SIGN LEADING SEPARATE.
       10 ST-PZ            PIC S9(6) SIGN LEADING SEPARATE.
       10 ST-B             PIC S9(6) SIGN LEADING SEPARATE OCCURS 4 TIMES.
       10 ST-MODE           PIC 9.
       10 FILLER           PIC X(26).
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
         MOVE "test struct portal no generated packs here, skipped" TO TL-CASE
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
     PERFORM DATA-CASES
     PERFORM TEMP-CASES
     PERFORM START-CASES
     PERFORM EDGE-CASES
     PERFORM WINDOW-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 FIND-STRUCT.
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM.

*> 8.1 the setups of the seven files
 DATA-CASES.
     MOVE "minecraft:ruined_portal" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the ruined_portal file when its setups are read then there are two: underground (air pocket 1.0, mossiness 0.2, can be cold) and on land surface (0.0)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-RP-N(WS-STRUCT) = 2 AND RP-PLACEMENT(WS-ROW) = 4 AND RP-AIR(WS-ROW) = 1 AND RP-MOSS(WS-ROW) = 2 AND RP-COLD(WS-ROW) = 1 AND RP-OVERGROWN(WS-ROW) = 0
        AND RP-VINES(WS-ROW) = 0 AND RP-BLACK(WS-ROW) = 0 AND RP-PLACEMENT(WS-ROW + 1) = 0 AND RP-AIR(WS-ROW + 1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_jungle" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the jungle file when its setup is read then it is on land surface, mossiness 0.8, overgrown, with vines, not cold" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-RP-N(WS-STRUCT) = 1 AND RP-PLACEMENT(WS-ROW) = 0 AND RP-MOSS(WS-ROW) = 8 AND RP-OVERGROWN(WS-ROW) = 1 AND RP-VINES(WS-ROW) = 1 AND RP-COLD(WS-ROW) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_nether" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the nether file when its setup is read then it is in the nether with blackstone" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF RP-PLACEMENT(WS-ROW) = 5 AND RP-BLACK(WS-ROW) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_swamp" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the swamp file when its setup is read then it is on the ocean floor" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF RP-PLACEMENT(WS-ROW) = 2
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_desert" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the desert file when its setup is read then it is partly buried" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF RP-PLACEMENT(WS-ROW) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_mountain" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-ROW
     MOVE "test struct portal given the mountain file when its setups are read then the first is in the mountain" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF RP-PLACEMENT(WS-ROW) = 3
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:igloo" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE "test struct portal given a structure of another type when its file is read then it has no setup" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-RP-N(WS-STRUCT) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 33 4.5: the base temperature of a biome from its file (the fixtures), and the cold test over the real biomes
 TEMP-CASES.
     MOVE FD-DIR TO WS-SAVE-DIR
     MOVE WS-TEMP-DIR TO FD-DIR
     MOVE "t_warm" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     MOVE "test struct portal given a biome file with temperature 0.8 when it is read then the temperature is 0.8" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-OK = 1 AND WS-T > 0.79 AND WS-T < 0.81
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "t_frozen" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     MOVE "test struct portal given a biome file with temperature 0 when it is read then the temperature is 0" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-OK = 1 AND WS-T = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO WS-FLAG
     MOVE 0 TO WS-I
     MOVE "t_badjson" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     ADD WS-OK TO WS-I
     MOVE "t_notemp" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     ADD WS-OK TO WS-I
     MOVE "t_missing" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     ADD WS-OK TO WS-I
     MOVE "minecraft:t_missing" TO WS-BIOME
     CALL "STRUCT-PORTAL-TEMP" USING WS-BIOME WS-T WS-OK
     ADD WS-OK TO WS-I
     MOVE "test struct portal given a biome file that is not JSON, has no temperature or is absent when it is read then there is no temperature" TO TL-CASE
     IF WS-I = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE WS-SAVE-DIR TO FD-DIR
     MOVE 0 TO WS-COLD-N WS-WARM-N
     PERFORM VARYING WS-I FROM -6 BY 1 UNTIL WS-I > 6
         PERFORM VARYING WS-J FROM -6 BY 1 UNTIL WS-J > 6
             COMPUTE WS-X = WS-I * 300
             COMPUTE WS-Z = WS-J * 300
             MOVE 70 TO WS-Y
             CALL "STRUCT-PORTAL-COLD" USING WS-X WS-Y WS-Z WS-COLD
             IF WS-COLD = 1
                 ADD 1 TO WS-COLD-N
             ELSE
                 ADD 1 TO WS-WARM-N
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test struct portal given real biomes over 169 columns when the cold test is made then some are cold and some are not" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-COLD-N > 0 AND WS-WARM-N > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 200 TO WS-Y
     CALL "STRUCT-PORTAL-COLD" USING WS-X WS-Y WS-Z WS-COLD
     MOVE 1 TO JIG-TEST-SURFACE
     MOVE 70 TO WS-Y
     CALL "STRUCT-PORTAL-COLD" USING WS-X WS-Y WS-Z WS-COLD
     MOVE "test struct portal given the test aid when the cold test is made then it is not cold" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-COLD = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO JIG-TEST-SURFACE.

*> 8.2 and 8.3: the starts of the model
 START-CASES.
     MOVE 1 TO JIG-TEST-SURFACE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 24
         MOVE ST-MODE(WS-K) TO JIG-TEST-SURFACE
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(ST-NAME(WS-K)) DELIMITED BY SIZE INTO WS-KEY
         PERFORM FIND-STRUCT
         MOVE ST-CX(WS-K) TO WS-CX
         MOVE ST-CZ(WS-K) TO WS-CZ
         MOVE WS-CX TO WS-ED1
         MOVE WS-CZ TO WS-ED2
         MOVE SPACES TO WS-LABEL
         STRING FUNCTION TRIM(ST-NAME(WS-K)) " chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO WS-LABEL
         CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE SPACES TO TL-CASE
         STRING "test struct portal given " FUNCTION TRIM(WS-LABEL) " when the start is built then it is valid with one piece at (chunk corner, the model's y), the stub there" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-VALID = 1 AND SP-COUNT = 1 AND SP-T-X(1) = ST-PX(WS-K) AND SP-T-Y(1) = ST-Y(WS-K) AND SP-T-Z(1) = ST-PZ(WS-K)
            AND WS-X = ST-PX(WS-K) AND WS-Y = ST-Y(WS-K) AND WS-Z = ST-PZ(WS-K)
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         MOVE SPACES TO TL-CASE
         STRING "test struct portal given " FUNCTION TRIM(WS-LABEL) " when the start is built then the template, rotation and mirror are the model's" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         MOVE SPACES TO WS-ID
         STRING "minecraft:ruined_portal/" FUNCTION TRIM(ST-TPL(WS-K)) DELIMITED BY SIZE INTO WS-ID
         MOVE SP-T-ROW(1) TO WS-ROW
         IF TP-KEY(WS-ROW) = WS-ID AND SP-T-ROT(1) = ST-ROT(WS-K) AND SP-T-MIR(1) = ST-MIRROR(WS-K) AND SP-T-KIND(1) = 4
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         MOVE SPACES TO TL-CASE
         STRING "test struct portal given " FUNCTION TRIM(WS-LABEL) " when the start is built then the box is the model's (x, z) and the air pocket and setup are the piece's" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF SP-X0(1) = ST-B(WS-K, 1) AND SP-Z0(1) = ST-B(WS-K, 2) AND SP-X1(1) = ST-B(WS-K, 3) AND SP-Z1(1) = ST-B(WS-K, 4)
            AND FUNCTION MOD(SP-T-AUX(1), 2) = ST-AIR(WS-K)
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
     END-PERFORM
     MOVE 0 TO JIG-TEST-SURFACE.
*> the processor lists of 8.4 for every flag, the files without setups, the starts that cannot be made, a fractional air pocket and the nether air pocket
 EDGE-CASES.
     MOVE "cobolcraft:inline/portal/0010/2" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct portal given the cold list when it is loaded then it has the ignore (air and structure block), a rule of two rules, the age, the protected set and the lava processor" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 5 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 9 AND SPP-N(SPL-FIRST(WS-LIST)) = 2 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 1
            AND SPP-N(SPL-FIRST(WS-LIST) + 1) = 2 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 2) = 11 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 3) = 2
            AND SPP-TYPE(SPL-FIRST(WS-LIST) + 4) = 7
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "cobolcraft:inline/portal/1101/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct portal given the air pocket, ocean floor, not cold, blackstone list when it is loaded then the ignore has one block, three rules and blackstone ends it" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 6 AND SPP-N(SPL-FIRST(WS-LIST)) = 1 AND SPP-N(SPL-FIRST(WS-LIST) + 1) = 3 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 5) = 10
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "cobolcraft:inline/portal/00x0/2" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct portal given a key that is not a portal list when it is loaded then there is none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a ruined_portal file without setups has none
     MOVE "minecraft:ruined_portal" TO WS-KEY
     PERFORM FIND-STRUCT
     CALL "STRUCT-ENUM-ID" USING WS-KIND-TYPE WS-NAME-PORTAL WS-PORTAL-ID
     COMPUTE WS-NEXT = SD-ST-COUNT + 1
     MOVE WS-PORTAL-ID TO SDT-TYPE(WS-NEXT)
     MOVE '{"type":"minecraft:ruined_portal"}' TO WS-TEXT
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING))
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "STRUCT-PORTAL-READ" USING JSON-DOC WS-NEXT
     MOVE "test struct portal given a ruined_portal file with no setups list when it is read then it has no setup" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-RP-N(WS-NEXT) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO JIG-TEST-SURFACE
     MOVE "minecraft:igloo" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE 3 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "test struct portal given a structure with no setup when a start is asked then there is none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   templates that are absent, and a full cache
     MOVE "minecraft:ruined_portal" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SD-DIR TO WS-SAVE-DIR2
     CALL "STRUCT-TPL-RESET"
     MOVE WS-BAD-DIR TO SD-DIR
     CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "test struct portal given no template files when a start is asked then the start is not valid and has no piece" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE WS-SAVE-DIR2 TO SD-DIR
     CALL "STRUCT-TPL-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-MAX-TEMPLATES
         MOVE SPACES TO TP-KEY(WS-I)
     END-PERFORM
     MOVE TP-MAX-TEMPLATES TO TP-COUNT
     CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "test struct portal given a full template cache when a start is asked then the start is not valid" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "STRUCT-TPL-RESET"
*>   a fractional air pocket probability draws: with 0.5 over eight chunks both outcomes occur
     MOVE "minecraft:ruined_portal_desert" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-LAST-ROW
     MOVE 0.5 TO RP-AIR(WS-LAST-ROW)
     MOVE 0 TO WS-AIRS WS-NOAIRS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         MOVE WS-K TO WS-CX
         MOVE 1 TO WS-CZ
         CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF FUNCTION MOD(SP-T-AUX(1), 2) = 1
             ADD 1 TO WS-AIRS
         ELSE
             ADD 1 TO WS-NOAIRS
         END-IF
     END-PERFORM
     MOVE 0 TO RP-AIR(WS-LAST-ROW)
     MOVE "test struct portal given an air pocket probability of one half when twelve starts are made then some have the pocket and some have not" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-AIRS > 0 AND WS-NOAIRS > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the nether portal with an air pocket (y 32 to 100) and without (27 to 29 or 29 to 100): all above the nether's limit of 15
     MOVE "minecraft:ruined_portal_nether" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-LAST-ROW
     MOVE 1 TO RP-AIR(WS-LAST-ROW)
     MOVE 0 TO WS-AIRS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-K TO WS-CX
         MOVE 2 TO WS-CZ
         CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID = 1 AND WS-Y >= 15
             ADD 1 TO WS-AIRS
         END-IF
     END-PERFORM
     MOVE 0 TO RP-AIR(WS-LAST-ROW)
     MOVE 0 TO WS-NOAIRS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE WS-K TO WS-CX
         MOVE 3 TO WS-CZ
         CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID = 1 AND WS-Y >= 15
             ADD 1 TO WS-NOAIRS
         END-IF
     END-PERFORM
     MOVE "test struct portal given the nether portal when starts are made with and without the air pocket then all are valid and above the limit" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-AIRS = 6 AND WS-NOAIRS = 16
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO JIG-TEST-SURFACE.

*> the piece through the window of its own chunk (stone up to y 70) and of the next one: the write box rule, the spread, the drips, the leaves and the vines of 8.4 to 8.6
 WINDOW-CASES.
     MOVE "minecraft:stone" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-STONE
     MOVE 1 TO JIG-TEST-SURFACE
*>   the jungle portal (on land surface, overgrown, vines) of chunk (4, -2)
     MOVE "minecraft:ruined_portal_jungle" TO WS-KEY
     MOVE 4 TO WS-CX
     MOVE -2 TO WS-CZ
     MOVE WS-CX TO WS-WCX
     MOVE WS-CZ TO WS-WCZ
     PERFORM PLACE-IN-WINDOW
     MOVE WS-COUNTS TO WS-FIRST-COUNTS
     MOVE "test struct portal given the jungle portal when it is placed in the window of its chunk then its obsidian is there and netherrack was spread" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN > 0 AND WN-NETHERRACK > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct portal given the jungle portal when it is placed then leaves and vines were added (overgrown, vines)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-LEAVES > 0 OR WN-VINE > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct portal given the jungle portal when it is placed then the write box of the chunk is back" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SW-X0 = WS-CX * 16 AND SW-X1 = WS-CX * 16 + 15 AND SW-Z0 = WS-CZ * 16 AND SW-Z1 = WS-CZ * 16 + 15
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the same portal and the same random when it is placed again then the result is the same" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-COUNTS = WS-FIRST-COUNTS
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the window of the next chunk does not hold the centre: nothing is written
     COMPUTE WS-WCX = WS-CX + 1
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the window of the next chunk when the portal is placed then its centre is not in the write box and nothing is made" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN = 0 AND WN-NETHERRACK = 0 AND WN-LEAVES = 0 AND WN-VINE = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   an underground portal with an air pocket (chunk (5, 5): the model's y -49) and the other placements and the nether one, for the spread of each
     MOVE "minecraft:ruined_portal" TO WS-KEY
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     MOVE WS-CX TO WS-WCX
     MOVE WS-CZ TO WS-WCZ
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the underground portal when it is placed in stone then its obsidian is there and netherrack was spread around" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN > 0 AND WN-NETHERRACK > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_desert" TO WS-KEY
     MOVE 3 TO WS-CX
     MOVE 3 TO WS-CZ
     MOVE WS-CX TO WS-WCX
     MOVE WS-CZ TO WS-WCZ
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the desert portal (partly buried) when it is placed then its obsidian is there" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_swamp" TO WS-KEY
     MOVE -1 TO WS-CX
     MOVE 6 TO WS-CZ
     MOVE WS-CX TO WS-WCX
     MOVE WS-CZ TO WS-WCZ
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the swamp portal (ocean floor, vines) when it is placed then its obsidian is there" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:ruined_portal_nether" TO WS-KEY
     MOVE 2 TO WS-CX
     MOVE 2 TO WS-CZ
     MOVE WS-CX TO WS-WCX
     MOVE WS-CZ TO WS-WCZ
     PERFORM PLACE-IN-WINDOW
     MOVE "test struct portal given the nether portal when it is placed then its obsidian is there" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WN-OBSIDIAN > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO JIG-TEST-SURFACE.

*> the window of chunk (WS-WCX, WS-WCZ) filled with stone up to y 70, the start of structure WS-KEY at chunk (WS-CX, WS-CZ) placed through it with the decoration random of seed 777,
*> and WS-COUNTS the netherrack, magma, obsidian, leaves and vine blocks of the window afterwards
 PLACE-IN-WINDOW.
     IF WS-WINDOW-OPEN = 0
         ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
         MOVE 1 TO WS-WINDOW-OPEN
     END-IF
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-STATES
     COMPUTE WS-X0 = WS-WCX * 16
     COMPUTE WS-Z0 = WS-WCZ * 16
     COMPUTE WS-X1 = WS-X0 + 15
     COMPUTE WS-Z1 = WS-Z0 + 15
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STONE WS-ONE WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM FIND-STRUCT
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE 777 TO SP-SEED
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 0 TO WN-NETHERRACK WN-MAGMA WN-OBSIDIAN WN-LEAVES WN-VINE
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 120
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                 MOVE CB-KEY(WS-BLOCK + 1) TO WS-NAME
                 EVALUATE WS-NAME
                     WHEN "netherrack"
                         ADD 1 TO WN-NETHERRACK
                     WHEN "magma_block"
                         ADD 1 TO WN-MAGMA
                     WHEN "obsidian"
                         ADD 1 TO WN-OBSIDIAN
                     WHEN "jungle_leaves"
                         ADD 1 TO WN-LEAVES
                     WHEN "vine"
                         ADD 1 TO WN-VINE
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-STRUCT-PORTAL.

 COPY CORETEST.
