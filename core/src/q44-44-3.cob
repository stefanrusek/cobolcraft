*> Villages, villagers, points of interest and raids (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md; lane 002-lane-p49h, T22000 and on).
*> Section 1 (the POI type table, claims, the section distance field, the setBlock hook):
*>   Q3-POI-TYPE USING block key (X(32), no namespace), bed head (1 head or not a bed, 0 a foot), type out (-1 none, else 0 to 20), tickets out, range out
*>   Q3-POI-IN-TAG USING type, tag (1 village, 2 acquirable_job_site, 3 bee_home), yes out
*>   Q3-STATE-POI-TYPE USING block state, type out (-1 none)               the type of a block state (a bed only at its head part)
*>   Q3-LEVEL USING dim, section x, y, z, level out                         sectionsToVillage (0 to 6, 7 none) from the index and the claims
*>   Q3-CLOSE-TO-VILLAGE USING dim, x, y, z, n, yes out                     isCloseToVillage (false above 6); isVillage is n = 1
*>   Q3-COUNT-IN-RANGE USING dim, x, y, z, kind (1 home, 2 meeting, 3 job site), range, occupancy (0 any, 1 has space, 2 occupied), count out   getCountInRange
*>   Q3-POI-HOOK USING dim, x, y, z, old state, new state                    Level.setBlock's updatePOIOnBlockStateChange

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
     MOVE SPACES TO WS-KEY32
     IF WS-KEY48(1:10) = "minecraft:"
         MOVE WS-KEY48(11:32) TO WS-KEY32
     ELSE
         MOVE WS-KEY48(1:32) TO WS-KEY32
     END-IF
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
