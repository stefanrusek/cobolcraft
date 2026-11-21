*> Villages, villagers, points of interest and raids (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md; lane 002-lane-p49h, T22000 and on).
*> The scale 10430.378350470453 of Mth.sin and Mth.cos is a double kept as its IEEE bits (WS-SCALE-BITS): a decimal literal of that many digits converts one step lower.
*> Section 1 (the POI type table, claims, the section distance field, the setBlock hook):
*>   Q3-POI-TYPE USING block key (X(32), no namespace), bed head (1 head or not a bed, 0 a foot), type out (-1 none, else 0 to 20), tickets out, range out
*>   Q3-POI-IN-TAG USING type, tag (1 village, 2 acquirable_job_site, 3 bee_home), yes out
*>   Q3-STATE-POI-TYPE USING block state, type out (-1 none)               the type of a block state (a bed only at its head part)
*>   Q3-LEVEL USING dim, section x, y, z, level out                         sectionsToVillage (0 to 6, 7 none) from the index and the claims
*>   Q3-CLOSE-TO-VILLAGE USING dim, x, y, z, n, yes out                     isCloseToVillage (false above 6); isVillage is n = 1
*>   Q3-COUNT-IN-RANGE USING dim, x, y, z, kind (1 home, 2 meeting, 3 job site), range, occupancy (0 any, 1 has space, 2 occupied), count out   getCountInRange
*>   Q3-POI-HOOK USING dim, x, y, z, old state, new state                    Level.setBlock's updatePOIOnBlockStateChange
*>   Q3-MTH-SIN / Q3-MTH-COS USING angle (FLOAT-LONG), result out (FLOAT-LONG)   Mth.sin / Mth.cos (1.7a): the 65536-entry float table
*>   Q3-SIEGE-OFFSET USING angle (FLOAT-SHORT), x offset out, z offset out         floor(cos * 32), floor(sin * 32) as floats (1.7 step 4a)
*>   Q3-COUNT-TYPE-IN-BOX USING dim, type, x, y, z, rx, ry, rz, count out          entities of a type in the block box inflated by (rx, ry, rz)
*>   Q3-CAT-DECIDE USING close to village, homes, cats near (48), hut, cats near (16), action out (0 none, 1 village cat, 2 hut cat)   CatSpawner step 4
*>   Q3-CAT-ATTEMPT USING player row, x amount, x negative, z amount, z negative, result out   CatSpawner steps 3 to 5 (village case)
*>   Q3-CAT-TICK                                                                    CatSpawner.tick (nextTick counter, a random player)
*>   Q3-SIEGE-FIND USING dim, centre x, y, z, x out, y out, z out, found out        VillageSiege.findRandomSpawnPos (4c)
*>   Q3-SIEGE-TRY USING player row, angle (FLOAT-SHORT), ok out                      one setup attempt of 4a
*>   Q3-SIEGE-TICK USING roll draw (nextInt(10) at the marker tick, else -1)         VillageSiege.tick
*>   Q3-SPAWNERS-TICK                                                               the world hook (STDMOB-SPAWN-TICK): both spawners

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-POI-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(32).
 01 L-HEAD                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-TICKETS               BINARY-LONG.
 01 L-RANGE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-HEAD L-TYPE L-TICKETS L-RANGE.
     MOVE -1 TO L-TYPE
     MOVE 1 TO L-TICKETS L-RANGE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY)) TO WS-LEN
     EVALUATE TRUE
         WHEN L-KEY = "blast_furnace"
             MOVE 0 TO L-TYPE
         WHEN L-KEY = "smoker"
             MOVE 1 TO L-TYPE
         WHEN L-KEY = "cartography_table"
             MOVE 2 TO L-TYPE
         WHEN L-KEY = "brewing_stand"
             MOVE 3 TO L-TYPE
         WHEN L-KEY = "composter"
             MOVE 4 TO L-TYPE
         WHEN L-KEY = "barrel"
             MOVE 5 TO L-TYPE
         WHEN L-KEY = "fletching_table"
             MOVE 6 TO L-TYPE
         WHEN L-KEY = "cauldron" OR "lava_cauldron" OR "water_cauldron" OR "powder_snow_cauldron"
             MOVE 7 TO L-TYPE
         WHEN L-KEY = "lectern"
             MOVE 8 TO L-TYPE
         WHEN L-KEY = "stonecutter"
             MOVE 9 TO L-TYPE
         WHEN L-KEY = "loom"
             MOVE 10 TO L-TYPE
         WHEN L-KEY = "smithing_table"
             MOVE 11 TO L-TYPE
         WHEN L-KEY = "grindstone"
             MOVE 12 TO L-TYPE
         WHEN WS-LEN > 4 AND L-KEY(WS-LEN - 3:4) = "_bed"
             IF L-HEAD = 1
                 MOVE 13 TO L-TYPE
             END-IF
         WHEN L-KEY = "bell"
             MOVE 14 TO L-TYPE
             MOVE 32 TO L-TICKETS
             MOVE 6 TO L-RANGE
         WHEN L-KEY = "beehive"
             MOVE 15 TO L-TYPE
             MOVE 0 TO L-TICKETS
         WHEN L-KEY = "bee_nest"
             MOVE 16 TO L-TYPE
             MOVE 0 TO L-TICKETS
         WHEN L-KEY = "nether_portal"
             MOVE 17 TO L-TYPE
             MOVE 0 TO L-TICKETS
         WHEN L-KEY = "lodestone"
             MOVE 18 TO L-TYPE
             MOVE 0 TO L-TICKETS
         WHEN L-KEY = "test_instance_block"
             MOVE 19 TO L-TYPE
             MOVE 0 TO L-TICKETS
         WHEN L-KEY = "lightning_rod" OR "exposed_lightning_rod" OR "weathered_lightning_rod" OR "oxidized_lightning_rod"
                 OR "waxed_lightning_rod" OR "waxed_exposed_lightning_rod" OR "waxed_weathered_lightning_rod"
                 OR "waxed_oxidized_lightning_rod"
             MOVE 20 TO L-TYPE
             MOVE 0 TO L-TICKETS
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-POI-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-POI-IN-TAG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-TAG                   BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-TAG L-YES.
     MOVE 0 TO L-YES
     EVALUATE L-TAG
         WHEN 1
             IF L-TYPE >= 0 AND L-TYPE <= 14
                 MOVE 1 TO L-YES
             END-IF
         WHEN 2
             IF L-TYPE >= 0 AND L-TYPE <= 12
                 MOVE 1 TO L-YES
             END-IF
         WHEN 3
             IF L-TYPE = 15 OR L-TYPE = 16
                 MOVE 1 TO L-YES
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-POI-IN-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-STATE-POI-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY48                PIC X(48).
 01 WS-BARE                 PIC X(48).
 01 WS-KEY32                PIC X(32).
 01 WS-PROPS                PIC X(160).
 01 WS-HEAD                 BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-TICKETS              BINARY-LONG.
 01 WS-RANGE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                 BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-TYPE.
     MOVE -1 TO L-TYPE
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY48
     CALL "KEY-BARE" USING WS-KEY48 WS-BARE
     MOVE WS-BARE TO WS-KEY32
     CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-PROPS
     MOVE 0 TO WS-COUNT
     INSPECT WS-PROPS TALLYING WS-COUNT FOR ALL "part=head"
     MOVE 0 TO WS-HEAD
     IF WS-COUNT > 0
         MOVE 1 TO WS-HEAD
     END-IF
     CALL "Q3-POI-TYPE" USING WS-KEY32 WS-HEAD L-TYPE WS-TICKETS WS-RANGE
     GOBACK.
 END PROGRAM Q3-STATE-POI-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-D                    BINARY-LONG.
 01 WS-TICKETS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-SX                    BINARY-LONG.
 01 L-SY                    BINARY-LONG.
 01 L-SZ                    BINARY-LONG.
 01 L-LEVEL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-LEVEL.
     MOVE 7 TO L-LEVEL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = L-DIM
             COMPUTE WS-DX = FUNCTION ABS(FUNCTION INTEGER(PX-X(WS-I) / 16) - L-SX)
             COMPUTE WS-DY = FUNCTION ABS(FUNCTION INTEGER(PX-Y(WS-I) / 16) - L-SY)
             COMPUTE WS-DZ = FUNCTION ABS(FUNCTION INTEGER(PX-Z(WS-I) / 16) - L-SZ)
             COMPUTE WS-D = FUNCTION MAX(WS-DX, WS-DY, WS-DZ)
             IF WS-D < L-LEVEL
*>               A village centre holds an occupied record: a claimed bed, a held workstation, a bell with a ticket taken (1.4 step 1).
                 CALL "PXI-TICKETS" USING PX-DIM(WS-I) PX-X(WS-I) PX-Y(WS-I) PX-Z(WS-I) PX-KIND(WS-I) WS-TICKETS
                 IF WS-TICKETS > 0
                     MOVE WS-D TO L-LEVEL
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF L-LEVEL > 6
         MOVE 7 TO L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM Q3-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CLOSE-TO-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 01 WS-LEVEL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-N                     BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-N L-YES.
     MOVE 0 TO L-YES
     IF L-N > 6
         GOBACK
     END-IF
     COMPUTE WS-SX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(L-Y / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(L-Z / 16)
     CALL "Q3-LEVEL" USING L-DIM WS-SX WS-SY WS-SZ WS-LEVEL
     IF WS-LEVEL <= L-N
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-CLOSE-TO-VILLAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-COUNT-IN-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-D2                   BINARY-DOUBLE.
 01 WS-R2                   BINARY-DOUBLE.
 01 WS-TICKETS              BINARY-LONG.
 01 WS-CAP                  BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-RANGE                 BINARY-LONG.
 01 L-OCC                   BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-RANGE L-OCC L-COUNT.
     MOVE 0 TO L-COUNT
     COMPUTE WS-R2 = L-RANGE * L-RANGE
     MOVE 1 TO WS-CAP
     IF L-KIND = 2
         MOVE 32 TO WS-CAP
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) = L-KIND AND PX-DIM(WS-I) = L-DIM
*>           getInSquare keeps |dx| <= r and |dz| <= r, getInRange then distSqr <= r * r (1.3).
             COMPUTE WS-DX = PX-X(WS-I) - L-X
             COMPUTE WS-DY = PX-Y(WS-I) - L-Y
             COMPUTE WS-DZ = PX-Z(WS-I) - L-Z
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= WS-R2
                 CALL "PXI-TICKETS" USING PX-DIM(WS-I) PX-X(WS-I) PX-Y(WS-I) PX-Z(WS-I) PX-KIND(WS-I) WS-TICKETS
                 MOVE 1 TO WS-OK
                 EVALUATE L-OCC
                     WHEN 1
                         IF WS-TICKETS >= WS-CAP
                             MOVE 0 TO WS-OK
                         END-IF
                     WHEN 2
                         IF WS-TICKETS = 0
                             MOVE 0 TO WS-OK
                         END-IF
                 END-EVALUATE
                 IF WS-OK = 1
                     ADD 1 TO L-COUNT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-COUNT-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-POI-HOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 COPY VILPOI.
 01 WS-OLD-TYPE             BINARY-LONG.
 01 WS-NEW-TYPE             BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-OLD                   BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OLD L-NEW.
     CALL "Q3-STATE-POI-TYPE" USING L-OLD WS-OLD-TYPE
     CALL "Q3-STATE-POI-TYPE" USING L-NEW WS-NEW-TYPE
*>   Equal lookups (both none, or one type): the record and its tickets stay (1.4a step 2).
     IF WS-OLD-TYPE = WS-NEW-TYPE
         GOBACK
     END-IF
*>   The old type's record goes with its tickets, then the new type's record is added with every ticket free (step 3).
     IF WS-OLD-TYPE >= 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
             IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = L-DIM AND PX-X(WS-I) = L-X AND PX-Y(WS-I) = L-Y AND PX-Z(WS-I) = L-Z
                 INITIALIZE PX-ENTRY(WS-I)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
             IF PO-OWNER(WS-I) > 0 AND PO-DIM(WS-I) = L-DIM AND PO-X(WS-I) = L-X AND PO-Y(WS-I) = L-Y AND PO-Z(WS-I) = L-Z
                 INITIALIZE PO-ENTRY(WS-I)
             END-IF
         END-PERFORM
     END-IF
     IF WS-NEW-TYPE >= 0
         CALL "PXI-NOTE" USING L-DIM L-X L-Y L-Z L-NEW
     END-IF
     GOBACK.
 END PROGRAM Q3-POI-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-MTH-SIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE-BITS           BINARY-DOUBLE UNSIGNED VALUE 4666959775467686019.
 01 WS-SCALE REDEFINES WS-SCALE-BITS FLOAT-LONG.
 01 WS-PRODUCT              FLOAT-LONG.
 01 WS-INDEX                BINARY-DOUBLE.
 01 WS-INDEX-F              FLOAT-LONG.
 01 WS-ARG                  FLOAT-LONG.
 01 WS-NARROW               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                     FLOAT-LONG.
 01 L-RESULT                FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-RESULT.
     COMPUTE WS-PRODUCT = L-X * WS-SCALE
     COMPUTE WS-INDEX = FUNCTION INTEGER-PART(WS-PRODUCT)
     COMPUTE WS-INDEX = FUNCTION MOD(WS-INDEX, 65536)
     MOVE WS-INDEX TO WS-INDEX-F
     COMPUTE WS-ARG = WS-INDEX-F / WS-SCALE
     COMPUTE L-RESULT = FUNCTION SIN(WS-ARG)
     MOVE L-RESULT TO WS-NARROW
     MOVE WS-NARROW TO L-RESULT
     GOBACK.
 END PROGRAM Q3-MTH-SIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-MTH-COS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE-BITS           BINARY-DOUBLE UNSIGNED VALUE 4666959775467686019.
 01 WS-SCALE REDEFINES WS-SCALE-BITS FLOAT-LONG.
 01 WS-PRODUCT              FLOAT-LONG.
 01 WS-INDEX                BINARY-DOUBLE.
 01 WS-INDEX-F              FLOAT-LONG.
 01 WS-ARG                  FLOAT-LONG.
 01 WS-NARROW               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                     FLOAT-LONG.
 01 L-RESULT                FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-RESULT.
     COMPUTE WS-PRODUCT = L-X * WS-SCALE + 16384.0
     COMPUTE WS-INDEX = FUNCTION INTEGER-PART(WS-PRODUCT)
     COMPUTE WS-INDEX = FUNCTION MOD(WS-INDEX, 65536)
     MOVE WS-INDEX TO WS-INDEX-F
     COMPUTE WS-ARG = WS-INDEX-F / WS-SCALE
     COMPUTE L-RESULT = FUNCTION SIN(WS-ARG)
     MOVE L-RESULT TO WS-NARROW
     MOVE WS-NARROW TO L-RESULT
     GOBACK.
 END PROGRAM Q3-MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SIEGE-OFFSET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE                FLOAT-LONG.
 01 WS-S                    FLOAT-LONG.
 01 WS-C                    FLOAT-LONG.
 01 WS-FS                   FLOAT-SHORT.
 01 WS-FC                   FLOAT-SHORT.
 01 WS-32                   FLOAT-SHORT VALUE 32.
 01 WS-PS                   FLOAT-SHORT.
 01 WS-PC                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ANGLE                 FLOAT-SHORT.
 01 L-OX                    BINARY-LONG.
 01 L-OZ                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ANGLE L-OX L-OZ.
     MOVE L-ANGLE TO WS-ANGLE
     CALL "Q3-MTH-COS" USING WS-ANGLE WS-C
     CALL "Q3-MTH-SIN" USING WS-ANGLE WS-S
     MOVE WS-C TO WS-FC
     MOVE WS-S TO WS-FS
     COMPUTE WS-PC = WS-FC * WS-32
     COMPUTE WS-PS = WS-FS * WS-32
     COMPUTE L-OX = FUNCTION INTEGER(WS-PC)
     COMPUTE L-OZ = FUNCTION INTEGER(WS-PS)
     GOBACK.
 END PROGRAM Q3-SIEGE-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-COUNT-TYPE-IN-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-LO-X                 BINARY-LONG.
 01 WS-HI-X                 BINARY-LONG.
 01 WS-LO-Y                 BINARY-LONG.
 01 WS-HI-Y                 BINARY-LONG.
 01 WS-LO-Z                 BINARY-LONG.
 01 WS-HI-Z                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-RX                    BINARY-LONG.
 01 L-RY                    BINARY-LONG.
 01 L-RZ                    BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-RX L-RY L-RZ L-COUNT.
     MOVE 0 TO L-COUNT
     COMPUTE WS-LO-X = L-X - L-RX
     COMPUTE WS-HI-X = L-X + 1 + L-RX
     COMPUTE WS-LO-Y = L-Y - L-RY
     COMPUTE WS-HI-Y = L-Y + 1 + L-RY
     COMPUTE WS-LO-Z = L-Z - L-RZ
     COMPUTE WS-HI-Z = L-Z + 1 + L-RZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = L-TYPE AND EN-DIM(WS-I) = L-DIM
             IF EN-X(WS-I) >= WS-LO-X AND EN-X(WS-I) <= WS-HI-X AND EN-Y(WS-I) >= WS-LO-Y AND EN-Y(WS-I) <= WS-HI-Y
                     AND EN-Z(WS-I) >= WS-LO-Z AND EN-Z(WS-I) <= WS-HI-Z
                 ADD 1 TO L-COUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-COUNT-TYPE-IN-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CAT-DECIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLOSE                 BINARY-LONG.
 01 L-HOMES                 BINARY-LONG.
 01 L-CATS48                BINARY-LONG.
 01 L-HUT                   BINARY-LONG.
 01 L-CATS16                BINARY-LONG.
 01 L-ACTION                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLOSE L-HOMES L-CATS48 L-HUT L-CATS16 L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE TRUE
         WHEN L-CLOSE = 1
*>           Village case: more than 4 occupied homes within 48 and fewer than 5 cats in the (48, 8, 48) box (1.6 step 4).
             IF L-HOMES > 4 AND L-CATS48 < 5
                 MOVE 1 TO L-ACTION
             END-IF
         WHEN L-HUT = 1
*>           Hut case: no cat in the (16, 8, 16) box.
             IF L-CATS16 = 0
                 MOVE 2 TO L-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-CAT-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CAT-ATTEMPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                  PIC X(112) VALUE "minecraft:cat".
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-OX                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-READY                BINARY-LONG.
 01 WS-PLACE                BINARY-LONG VALUE 1.
 01 WS-OK                   BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 01 WS-TWO                  BINARY-LONG VALUE 2.
 01 WS-KIND-HOME            BINARY-LONG VALUE 1.
 01 WS-RANGE48              BINARY-LONG VALUE 48.
 01 WS-OCC                  BINARY-LONG VALUE 2.
 01 WS-HOMES                BINARY-LONG.
 01 WS-CATS48               BINARY-LONG.
 01 WS-CATS16               BINARY-LONG.
 01 WS-R48                  BINARY-LONG VALUE 48.
 01 WS-R48-Z                BINARY-LONG VALUE 48.
 01 WS-R16                  BINARY-LONG VALUE 16.
 01 WS-R8                   BINARY-LONG VALUE 8.
 01 WS-HUT                  BINARY-LONG VALUE 0.
 01 WS-ACTION               BINARY-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-ROW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-XAMOUNT               BINARY-LONG.
 01 L-XNEG                  BINARY-LONG.
 01 L-ZAMOUNT               BINARY-LONG.
 01 L-ZNEG                  BINARY-LONG.
 01 L-RESULT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-XAMOUNT L-XNEG L-ZAMOUNT L-ZNEG L-RESULT.
*>   Result: 0 a cat was spawned, 1 a chunk near the position is not loaded, 2 the spawn position is not ok for the cat, 3 no cat is spawned (counts or no village).
     MOVE 0 TO L-RESULT
     COMPUTE WS-OX = 8 + L-XAMOUNT
     IF L-XNEG = 1
         COMPUTE WS-OX = - WS-OX
     END-IF
     COMPUTE WS-OZ = 8 + L-ZAMOUNT
     IF L-ZNEG = 1
         COMPUTE WS-OZ = - WS-OZ
     END-IF
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-PLAYER)) + WS-OX
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-PLAYER)) + WS-OZ
*>   The chunks within +-10 blocks of the position must be loaded (step 3): the four corners.
     MOVE 1 TO WS-READY
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-CX = FUNCTION INTEGER((WS-X - 10 + 20 * FUNCTION MOD(FUNCTION INTEGER(WS-K / 2), 2)) / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER((WS-Z - 10 + 20 * FUNCTION INTEGER((WS-K - 1) / 2)) / 16)
         CALL "Q3-CHUNK-READY" USING PL-DIM(L-PLAYER) WS-CX WS-CZ WS-OK
         IF WS-OK = 0
             MOVE 0 TO WS-READY
         END-IF
     END-PERFORM
     IF WS-READY = 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     CALL "MS6-PLACEMENT-OK" USING WS-PLACE PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-OK
     IF WS-OK = 0
         MOVE 2 TO L-RESULT
         GOBACK
     END-IF
     CALL "Q3-CLOSE-TO-VILLAGE" USING PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-TWO WS-CLOSE
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-HOMES WS-CATS48
     IF WS-CLOSE = 1
         CALL "Q3-COUNT-IN-RANGE" USING PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-KIND-HOME WS-RANGE48 WS-OCC WS-HOMES
         CALL "Q3-COUNT-TYPE-IN-BOX" USING PL-DIM(L-PLAYER) WS-TYPE WS-X WS-Y WS-Z WS-R48 WS-R8 WS-R48-Z WS-CATS48
     END-IF
     MOVE 0 TO WS-CATS16
     CALL "Q3-CAT-DECIDE" USING WS-CLOSE WS-HOMES WS-CATS48 WS-HUT WS-CATS16 WS-ACTION
     IF WS-ACTION NOT = 1
         MOVE 3 TO L-RESULT
         GOBACK
     END-IF
     COMPUTE WS-FX = WS-X + 0.5
     MOVE WS-Y TO WS-FY
     COMPUTE WS-FZ = WS-Z + 0.5
     CALL "MOB-SPAWN" USING PL-DIM(L-PLAYER) WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     GOBACK.
 END PROGRAM Q3-CAT-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CHUNK-READY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-CX                    BINARY-LONG.
 01 L-CZ                    BINARY-LONG.
 01 L-READY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-READY.
     CALL "STDMOB-READY" USING L-DIM L-CX L-CZ L-READY
     GOBACK.
 END PROGRAM Q3-CHUNK-READY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CAT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY Q3STATE.
 01 WS-SALT                 BINARY-LONG VALUE 91.
 01 WS-B24                  BINARY-LONG VALUE 24.
 01 WS-B2                   BINARY-LONG VALUE 2.
 01 WS-N                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-XA                   BINARY-LONG.
 01 WS-XS                   BINARY-LONG.
 01 WS-ZA                   BINARY-LONG.
 01 WS-ZS                   BINARY-LONG.
 01 WS-RESULT               BINARY-LONG.
 PROCEDURE DIVISION.
*>   nextTick is decremented on every call; above 0 the spawner returns, else it is set to 1200 (1.6 step 1).
     SUBTRACT 1 FROM Q3-CAT-NEXT
     IF Q3-CAT-NEXT > 0
         GOBACK
     END-IF
     MOVE 1200 TO Q3-CAT-NEXT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-N WS-PICK
     ADD 1 TO WS-PICK
     MOVE 0 TO WS-K WS-N
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             ADD 1 TO WS-K
             IF WS-K = WS-PICK
                 MOVE WS-P TO WS-N
             END-IF
         END-IF
     END-PERFORM
*>   Draw order: x amount, x sign, z amount, z sign (step 3); a sign is negative when nextBoolean is true.
     CALL "XP-RANDOM" USING WS-SALT WS-B24 WS-XA
     CALL "XP-RANDOM" USING WS-SALT WS-B2 WS-XS
     CALL "XP-RANDOM" USING WS-SALT WS-B24 WS-ZA
     CALL "XP-RANDOM" USING WS-SALT WS-B2 WS-ZS
     CALL "Q3-CAT-ATTEMPT" USING WS-N WS-XA WS-XS WS-ZA WS-ZS WS-RESULT
     GOBACK.
 END PROGRAM Q3-CAT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SIEGE-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SALT                 BINARY-LONG VALUE 92.
 01 WS-B16                  BINARY-LONG VALUE 16.
 01 WS-I                    BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-GROUND               BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-KEY                  PIC X(48) VALUE "zombie".
 01 WS-ROW                  BINARY-LONG.
 01 WS-SEED                 BINARY-DOUBLE UNSIGNED.
 01 WS-REASON               BINARY-LONG VALUE 0.
 01 WS-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-CX                    BINARY-LONG.
 01 L-CY                    BINARY-LONG.
 01 L-CZ                    BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CY L-CZ L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "MS6-SPECIES" USING WS-KEY WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR L-FOUND = 1
         CALL "XP-RANDOM" USING WS-SALT WS-B16 WS-DX
         CALL "XP-RANDOM" USING WS-SALT WS-B16 WS-DZ
         COMPUTE WS-X = L-CX + WS-DX - 8
         COMPUTE WS-Z = L-CZ + WS-DZ - 8
         CALL "TRADER-GROUND" USING L-DIM WS-X WS-Z L-CY WS-GROUND WS-Y
         IF WS-GROUND = 1
             CALL "Q3-CLOSE-TO-VILLAGE" USING L-DIM WS-X WS-Y WS-Z WS-ONE WS-YES
             IF WS-YES = 1 AND WS-ROW > 0
                 COMPUTE WS-SEED = CW-TICKS * 64 + WS-I
                 CALL "XORO-SEED" USING WS-SEED WS-STATE
                 CALL "MS6-VALID-SPOT" USING WS-STATE L-DIM WS-ROW WS-X WS-Y WS-Z WS-REASON WS-OK
                 IF WS-OK = 1
                     MOVE WS-X TO L-X
                     MOVE WS-Y TO L-Y
                     MOVE WS-Z TO L-Z
                     MOVE 1 TO L-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-SIEGE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SIEGE-TRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY Q3STATE.
 01 WS-OX                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-ANGLE                 FLOAT-SHORT.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ANGLE L-OK.
     MOVE 0 TO L-OK
     CALL "Q3-SIEGE-OFFSET" USING L-ANGLE WS-OX WS-OZ
     COMPUTE WS-CX = WS-OX + FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-CY = FUNCTION INTEGER(PL-Y(L-PLAYER))
     COMPUTE WS-CZ = WS-OZ + FUNCTION INTEGER(PL-Z(L-PLAYER))
     CALL "Q3-SIEGE-FIND" USING PL-DIM(L-PLAYER) WS-CX WS-CY WS-CZ WS-X WS-Y WS-Z WS-FOUND
     IF WS-FOUND = 1
         MOVE 0 TO Q3-SG-NEXT
         MOVE 20 TO Q3-SG-ZOMBIES
         MOVE PL-DIM(L-PLAYER) TO Q3-SG-DIM
         MOVE WS-CX TO Q3-SG-X
         MOVE WS-CY TO Q3-SG-Y
         MOVE WS-CZ TO Q3-SG-Z
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q3-SIEGE-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SIEGE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRWORLD.
 COPY Q3STATE.
 01 WS-SALT                 BINARY-LONG VALUE 93.
 01 WS-B8M                  BINARY-LONG VALUE 8388608.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-DARKEN               BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-A                    BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-OK                   BINARY-LONG.
 01 WS-ANGLE                FLOAT-SHORT.
 01 WS-TWO-PI               FLOAT-SHORT VALUE 6.2831855.
 01 WS-UNIT                 FLOAT-SHORT.
 01 WS-KEY                  PIC X(112) VALUE "minecraft:zombie".
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT.
 01 WS-ROW                  BINARY-LONG.
 01 WS-B360                 BINARY-LONG VALUE 360.
 01 WS-DEG                  BINARY-LONG.
 01 WS-DAYTICK              BINARY-LONG.
 01 WS-ENEMIES              BINARY-LONG.
 01 WS-RULE-NAME            PIC X(40) VALUE "spawn_monsters".
 01 WS-RULE                 BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ROLL                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
*>   The spawn-enemies flag: hostile mobs on, the spawn_monsters rule and not Peaceful.
     MOVE 1 TO WS-ENEMIES
     IF CS-HOSTILE-MOBS NOT = 1 OR BW-DIFFICULTY = 0 OR WS-RULE = 0
         MOVE 0 TO WS-ENEMIES
     END-IF
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
*>   Step 1: bright outside, or no enemies: the siege is over and not set up.
     IF WS-DARKEN < 4 OR WS-ENEMIES = 0
         MOVE 0 TO Q3-SG-STATE Q3-SG-SETUP
         GOBACK
     END-IF
*>   Step 2: at day tick 18000 the roll: SIEGE_TONIGHT with probability 1/10.
     COMPUTE WS-DAYTICK = FUNCTION MOD(CW-TIME, 24000)
     IF WS-DAYTICK = 18000
         IF L-ROLL = 0
             MOVE 1 TO Q3-SG-STATE
         ELSE
             MOVE 0 TO Q3-SG-STATE
         END-IF
     END-IF
     IF Q3-SG-STATE = 0
         GOBACK
     END-IF
*>   Step 4: set up (the first player in a village, up to 10 attempts), else fail.
     IF Q3-SG-SETUP = 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR Q3-SG-SETUP = 1
             IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-MODE(WS-P) NOT = 3
                     AND PL-DIM(WS-P) NOT = DIM-STANDARD-NETHER AND PL-DIM(WS-P) NOT = DIM-STANDARD-END
                 COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-P))
                 COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-P))
                 COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-P))
                 CALL "RAID-IS-VILLAGE" USING PL-DIM(WS-P) WS-PX WS-PY WS-PZ WS-YES
                 IF WS-YES = 1
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 10 OR Q3-SG-SETUP = 1
                         CALL "XP-RANDOM" USING WS-SALT WS-B8M WS-DRAW
                         COMPUTE WS-UNIT = WS-DRAW / 8388608
                         COMPUTE WS-ANGLE = WS-UNIT * WS-TWO-PI
                         CALL "Q3-SIEGE-TRY" USING WS-P WS-ANGLE WS-OK
                         IF WS-OK = 1
                             MOVE 1 TO Q3-SG-SETUP
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
         IF Q3-SG-SETUP = 0
             GOBACK
         END-IF
     END-IF
*>   Step 5: nextSpawnTime counts down; then 2 and one zombie while any are left, else the siege is done.
     IF Q3-SG-NEXT > 0
         SUBTRACT 1 FROM Q3-SG-NEXT
         GOBACK
     END-IF
     MOVE 2 TO Q3-SG-NEXT
     IF Q3-SG-ZOMBIES = 0
         MOVE 0 TO Q3-SG-STATE
         GOBACK
     END-IF
     SUBTRACT 1 FROM Q3-SG-ZOMBIES
     CALL "Q3-SIEGE-FIND" USING Q3-SG-DIM Q3-SG-X Q3-SG-Y Q3-SG-Z WS-X WS-Y WS-Z WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-X + 0.5
     MOVE WS-Y TO WS-FY
     COMPUTE WS-FZ = WS-Z + 0.5
     CALL "XP-RANDOM" USING WS-SALT WS-B360 WS-DEG
     MOVE WS-DEG TO WS-YAW
     CALL "MOB-SPAWN" USING Q3-SG-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     GOBACK.
 END PROGRAM Q3-SIEGE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SPAWNERS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                 BINARY-LONG VALUE 94.
 01 WS-B10                  BINARY-LONG VALUE 10.
 01 WS-ROLL                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "Q3-CAT-TICK"
     MOVE -1 TO WS-ROLL
     IF FUNCTION MOD(CW-TIME, 24000) = 18000
         CALL "XP-RANDOM" USING WS-SALT WS-B10 WS-ROLL
     END-IF
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     GOBACK.
 END PROGRAM Q3-SPAWNERS-TICK.
