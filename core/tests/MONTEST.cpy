*> Helpers of the ocean monument tests (core/tests/test_struct_36_6_5_*.cob); COPY it after the test program, like CORETEST.cpy. A window is one chunk column of the feature level (FEATLEVEL.cpy) over
*> memory the test allocates once (MT-PTR); the layers y 30 to 70 hold the pattern of core/tests/fixtures/gen_monument.py (prefill: stone at y 30, a scatter of stone, ice, packed ice and blue ice in y 31 to 61,
*> air above), which is what the model of the document starts from, so a drawn window can be compared with the model by a checksum.
*> MT-CLEAR USING cx cz: sets the layers y 30 to 70 of the opened window to air.
*> MT-SETUP: resolves the block states (MT-ST by code + 1: 0 air, 1 prismarine bricks, 2 prismarine, 3 dark prismarine, 4 sea lantern, 5 gold block, 6 wet sponge, 7 water, 8 stone, 9 ice, 10 packed ice, 11 blue ice)
*>   and allocates the memory; MT-WINDOW USING cx cz: fills the pattern, opens the level and the write box (MSP-OPEN); MT-HASH USING cx cz, hash out (BINARY-DOUBLE): the checksum of the window's layers
*>   (h = (h * 131 + code + 1) mod 1000000007, y outer, then z, then x); MT-SEED USING seed: the placement random at the state of that seed; MT-ELDER-HASH USING hash (BINARY-DOUBLE, accumulated), count (BINARY-LONG,
*>   accumulated): adds the requests of the entity channel (GENT-ADD-MOB, elder guardians) and empties it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MTDATA.
 COPY CELLS.
 COPY STRUCTMON.
 COPY FEATLEVEL.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "minecraft:stone".
    05 FILLER              PIC X(32) VALUE "minecraft:ice".
    05 FILLER              PIC X(32) VALUE "minecraft:packed_ice".
    05 FILLER              PIC X(32) VALUE "minecraft:blue_ice".
 01 WS-NAME-TAB REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     IF MT-READY = 0
         ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING MT-PTR
         MOVE 1 TO MT-READY
     END-IF
     CALL "FL-OPEN" USING MT-PTR WS-ZERO WS-ZERO2 WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     CALL "MONP-BLOCKS"
     MOVE FL-S-AIR TO MT-ST(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE MB-STATE(WS-I) TO MT-ST(WS-I + 1)
     END-PERFORM
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-NAME(WS-I) TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS MT-ST(WS-I + 8)
     END-PERFORM
     GOBACK.
 END PROGRAM MT-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-WINDOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MTDATA.
 COPY CELLS.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     SET ADDRESS OF CE-CHUNK TO MT-PTR
     PERFORM VARYING WS-Y FROM 30 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-WX = L-CX * 16 + WS-X
                 COMPUTE WS-WZ = L-CZ * 16 + WS-Z
                 MOVE 0 TO WS-CODE
                 EVALUATE TRUE
                     WHEN WS-Y = 30
                         MOVE 8 TO WS-CODE
                     WHEN WS-Y >= 62
                         MOVE 0 TO WS-CODE
                     WHEN OTHER
                         COMPUTE WS-T = WS-WX * 7 + WS-WZ * 3 + WS-Y * 5
                         IF FUNCTION MOD(WS-T, 11) = 0
                             MOVE 8 TO WS-CODE
                         ELSE
                             COMPUTE WS-T = WS-WX * 5 + WS-WZ + WS-Y * 3
                             IF FUNCTION MOD(WS-T, 37) = 0
                                 MOVE 9 TO WS-CODE
                             ELSE
                                 COMPUTE WS-T = WS-WX + WS-Y * 7 + WS-WZ * 3
                                 IF FUNCTION MOD(WS-T, 41) = 0
                                     MOVE 10 TO WS-CODE
                                 ELSE
                                     COMPUTE WS-T = WS-WX * 3 + WS-WZ * 11 + WS-Y
                                     IF FUNCTION MOD(WS-T, 43) = 0
                                         MOVE 11 TO WS-CODE
                                     END-IF
                                 END-IF
                             END-IF
                         END-IF
                 END-EVALUATE
                 COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
                 MOVE MT-ST(WS-CODE + 1) TO CE-STATE(WS-IDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "FL-OPEN" USING MT-PTR L-CX L-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     GOBACK.
 END PROGRAM MT-WINDOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-HASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MTDATA.
 COPY CELLS.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-HASH                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CX L-CZ L-HASH.
     SET ADDRESS OF CE-CHUNK TO MT-PTR
     MOVE 0 TO WS-H
     PERFORM VARYING WS-Y FROM 30 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
                 MOVE CE-STATE(WS-IDX) TO WS-STATE
                 MOVE 99 TO WS-CODE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12 OR WS-CODE NOT = 99
                     IF WS-STATE = MT-ST(WS-K)
                         COMPUTE WS-CODE = WS-K - 1
                     END-IF
                 END-PERFORM
                 COMPUTE WS-H = FUNCTION MOD(WS-H * 131 + WS-CODE + 1, 1000000007)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-H TO L-HASH
     GOBACK.
 END PROGRAM MT-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED.
     MOVE L-SEED TO WS-S
     CALL "WGR-SET-SEED" USING WS-XR WS-S
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM MT-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-ELDER-HASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENENT.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HASH                 BINARY-DOUBLE.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-HASH L-COUNT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GEL-COUNT
         COMPUTE WS-F = GEL-X(WS-I) - 0.5
         MOVE WS-F TO WS-X
         MOVE GEL-Y(WS-I) TO WS-F
         MOVE WS-F TO WS-Y
         COMPUTE WS-F = GEL-Z(WS-I) - 0.5
         MOVE WS-F TO WS-Z
         COMPUTE WS-T = WS-X * 73856093 + WS-Y * 19349663 + WS-Z * 83492791
         COMPUTE L-HASH = FUNCTION MOD(L-HASH + WS-T, 1000000007)
         ADD 1 TO L-COUNT
     END-PERFORM
     MOVE 0 TO GEL-COUNT GEL-LOST
     GOBACK.
 END PROGRAM MT-ELDER-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MT-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MTDATA.
 COPY CELLS.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 PROCEDURE DIVISION.
     SET ADDRESS OF CE-CHUNK TO MT-PTR
     COMPUTE WS-FROM = 94 * 256 + 1
     COMPUTE WS-TO = 135 * 256
     PERFORM VARYING WS-I FROM WS-FROM BY 1 UNTIL WS-I > WS-TO
         MOVE MT-ST(1) TO CE-STATE(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM MT-CLEAR.
