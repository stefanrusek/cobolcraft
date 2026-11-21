*> The Nether's structure and spawn data and the interface to the portals (docs/protocol/37-nether-6; T1701 to T1720), as far as the data and the placement rules go: the three
*> structure sets (spacing, separation, salt, weighted entries), the candidate chunk of a region (random_spread, 36-1 section 4.3), the weighted choice among the entries of a set
*> with failed starts removed (section 2), the biome tags of the four structures (section 8), the fortress spawn override (9.4) and the numbers of the portal interface (10).
*> The structure engines themselves (fortress pieces, bastion jigsaw pools, ruined portal blocks, fossil templates) are not here: see the open items of the lane report.
*>
*> Entry points (structures: 1 fortress, 2 bastion_remnant, 3 ruined_portal_nether, 4 nether_fossil; sets: 1 nether_complexes, 2 nether_fossils, 3 ruined_portals):
*>   NETHER-STRUCTURE-SET USING set, spacing, separation, salt, entry count out (BINARY-LONG)
*>   NETHER-SET-ENTRY USING set, index (1 up), name out (PIC X(24), no namespace), length out, weight out
*>   NETHER-STRUCTURE-CANDIDATE USING level seed (BINARY-DOUBLE, signed), set, chunk x, chunk z, candidate x out, candidate z out, structure chunk out (1 when the chunk is the candidate)
*>   NETHER-STRUCTURE-PICK USING level seed (signed), set, chunk x, chunk z, valid (PIC X(7): per entry 1 when its start would be valid, else 0), picked out (entry index, 0 when every try fails)
*>   NETHER-STRUCTURE-BIOME USING structure, biome number (1 to 5, the preset order), allowed out (1 or 0)
*>   NETHER-FORTRESS-SPAWN USING index (1 to 5), entity out (PIC X(20)), length out, weight out, min count out, max count out
*>   NETHER-PORTAL-NUMBER USING code, value out: 1 search radius into the Nether (16), 2 into the overworld (128), 3 creation spiral radius (16), 4 destination dimension of a portal used in the
*>     current level given in value in (0 overworld, 1 the Nether, 2 the End: gives 0 in the Nether, else 1), 5 minimum fallback y (70)
*>   NETHER-PORTAL-TOP USING min y, height, logical height, top y out: min(max y, min y + logical height - 1)
*>   NETHER-PORTAL-FALLBACK USING min y, top y, entity y, ok out (0: no portal), y out: lower max(min y + 1, 70), upper top - 9, y clamped between them

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCTURE-SET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SPACING              BINARY-LONG.
 01 L-SEPARATION           BINARY-LONG.
 01 L-SALT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SPACING L-SEPARATION L-SALT L-COUNT.
     EVALUATE L-SET
         WHEN 1
             MOVE 27 TO L-SPACING
             MOVE 4 TO L-SEPARATION
             MOVE 30084232 TO L-SALT
             MOVE 2 TO L-COUNT
         WHEN 2
             MOVE 2 TO L-SPACING
             MOVE 1 TO L-SEPARATION
             MOVE 14357921 TO L-SALT
             MOVE 1 TO L-COUNT
         WHEN OTHER
             MOVE 40 TO L-SPACING
             MOVE 15 TO L-SEPARATION
             MOVE 34222645 TO L-SALT
             MOVE 7 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-STRUCTURE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SET-ENTRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-LENGTH               BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-INDEX L-NAME L-LENGTH L-WEIGHT.
     MOVE SPACES TO L-NAME
     MOVE 1 TO L-WEIGHT
     EVALUATE L-SET
         WHEN 1
             IF L-INDEX = 1
                 MOVE "fortress" TO L-NAME
                 MOVE 2 TO L-WEIGHT
             ELSE
                 MOVE "bastion_remnant" TO L-NAME
                 MOVE 3 TO L-WEIGHT
             END-IF
         WHEN 2
             MOVE "nether_fossil" TO L-NAME
         WHEN OTHER
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "ruined_portal" TO L-NAME
                 WHEN 2
                     MOVE "ruined_portal_desert" TO L-NAME
                 WHEN 3
                     MOVE "ruined_portal_jungle" TO L-NAME
                 WHEN 4
                     MOVE "ruined_portal_swamp" TO L-NAME
                 WHEN 5
                     MOVE "ruined_portal_mountain" TO L-NAME
                 WHEN 6
                     MOVE "ruined_portal_ocean" TO L-NAME
                 WHEN OTHER
                     MOVE "ruined_portal_nether" TO L-NAME
             END-EVALUATE
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME TRAILING)) TO L-LENGTH
     GOBACK.
 END PROGRAM NETHER-SET-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCTURE-CANDIDATE.
*> setLargeFeatureWithSalt(seed, rx, rz, salt) = setSeed(rx * 341873128712 + rz * 132897987541 + seed + salt), 64-bit wrap; then nextInt(spacing - separation) twice (x, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SPACING             BINARY-LONG.
 01 WS-SEPARATION          BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-OFF-X               BINARY-LONG.
 01 WS-OFF-Z               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SET                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CAND-X               BINARY-LONG.
 01 L-CAND-Z               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-SET L-CX L-CZ L-CAND-X L-CAND-Z L-FLAG.
     CALL "NETHER-STRUCTURE-SET" USING L-SET WS-SPACING WS-SEPARATION WS-SALT WS-COUNT
     COMPUTE WS-RX = FUNCTION INTEGER(L-CX / WS-SPACING)
     COMPUTE WS-RZ = FUNCTION INTEGER(L-CZ / WS-SPACING)
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     COMPUTE WS-S = FUNCTION MOD(WS-RX * 341873128712 + WS-RZ * 132897987541 + WS-U + WS-SALT, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-S
     COMPUTE WS-LIMIT = WS-SPACING - WS-SEPARATION
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-OFF-X
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-OFF-Z
     COMPUTE L-CAND-X = WS-RX * WS-SPACING + WS-OFF-X
     COMPUTE L-CAND-Z = WS-RZ * WS-SPACING + WS-OFF-Z
     MOVE 0 TO L-FLAG
     IF L-CAND-X = L-CX AND L-CAND-Z = L-CZ
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM NETHER-STRUCTURE-CANDIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCTURE-PICK.
*> A set with one entry tries it without a draw. With several: setLargeFeatureSeed(levelSeed, cx, cz), then roll = nextInt(total), walk the list subtracting weights, stop where the
*> running value falls below zero; a failed entry is removed (its weight leaves the total) and the loop repeats with the rest (2, steps 3 to 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPACING             BINARY-LONG.
 01 WS-SEPARATION          BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-LIVE                PIC X(7).
 01 WS-TOTAL               BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-LEN                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-WEIGHTS.
    05 WS-WEIGHT           BINARY-LONG OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SET                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-VALID                PIC X(7).
 01 L-PICKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-SET L-CX L-CZ L-VALID L-PICKED.
     MOVE 0 TO L-PICKED
     CALL "NETHER-STRUCTURE-SET" USING L-SET WS-SPACING WS-SEPARATION WS-SALT WS-COUNT
     MOVE ALL "0" TO WS-LIVE
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "NETHER-SET-ENTRY" USING L-SET WS-I WS-NAME WS-LEN WS-W
         MOVE WS-W TO WS-WEIGHT(WS-I)
         MOVE "1" TO WS-LIVE(WS-I:1)
         ADD WS-W TO WS-TOTAL
     END-PERFORM
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     IF WS-COUNT = 1
         IF L-VALID(1:1) = "1"
             MOVE 1 TO L-PICKED
         END-IF
         GOBACK
     END-IF
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-U L-CX L-CZ
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-TOTAL = 0 OR WS-DONE = 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-TOTAL WS-ROLL
         MOVE 0 TO WS-CHOSEN
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-CHOSEN > 0
             IF WS-LIVE(WS-I:1) = "1"
                 SUBTRACT WS-WEIGHT(WS-I) FROM WS-ROLL
                 IF WS-ROLL < 0
                     MOVE WS-I TO WS-CHOSEN
                 END-IF
             END-IF
         END-PERFORM
         IF L-VALID(WS-CHOSEN:1) = "1"
             MOVE WS-CHOSEN TO L-PICKED
             MOVE 1 TO WS-DONE
         ELSE
             MOVE "0" TO WS-LIVE(WS-CHOSEN:1)
             SUBTRACT WS-WEIGHT(WS-CHOSEN) FROM WS-TOTAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-STRUCTURE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCTURE-BIOME.
*> 8: fortress and ruined_portal_nether in every Nether biome; bastion_remnant in nether_wastes, soul_sand_valley, crimson_forest, warped_forest; nether_fossil in soul_sand_valley.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRUCTURE            BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCTURE L-BIOME L-ALLOWED.
     MOVE 0 TO L-ALLOWED
     IF L-BIOME >= 1 AND L-BIOME <= 5
         EVALUATE L-STRUCTURE
             WHEN 1
             WHEN 3
                 MOVE 1 TO L-ALLOWED
             WHEN 2
                 IF L-BIOME NOT = 5
                     MOVE 1 TO L-ALLOWED
                 END-IF
             WHEN 4
                 IF L-BIOME = 2
                     MOVE 1 TO L-ALLOWED
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM NETHER-STRUCTURE-BIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FORTRESS-SPAWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ENTITY               PIC X(20).
 01 L-LENGTH               BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ENTITY L-LENGTH L-WEIGHT L-MIN L-MAX.
     MOVE SPACES TO L-ENTITY
     EVALUATE L-INDEX
         WHEN 1
             MOVE "blaze" TO L-ENTITY
             MOVE 10 TO L-WEIGHT
             MOVE 2 TO L-MIN
             MOVE 3 TO L-MAX
         WHEN 2
             MOVE "zombified_piglin" TO L-ENTITY
             MOVE 5 TO L-WEIGHT
             MOVE 4 TO L-MIN
             MOVE 4 TO L-MAX
         WHEN 3
             MOVE "wither_skeleton" TO L-ENTITY
             MOVE 8 TO L-WEIGHT
             MOVE 5 TO L-MIN
             MOVE 5 TO L-MAX
         WHEN 4
             MOVE "skeleton" TO L-ENTITY
             MOVE 2 TO L-WEIGHT
             MOVE 5 TO L-MIN
             MOVE 5 TO L-MAX
         WHEN OTHER
             MOVE "magma_cube" TO L-ENTITY
             MOVE 3 TO L-WEIGHT
             MOVE 4 TO L-MIN
             MOVE 4 TO L-MAX
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ENTITY TRAILING)) TO L-LENGTH
     GOBACK.
 END PROGRAM NETHER-FORTRESS-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PORTAL-NUMBER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-VALUE.
     EVALUATE L-CODE
         WHEN 1
             MOVE 16 TO L-VALUE
         WHEN 2
             MOVE 128 TO L-VALUE
         WHEN 3
             MOVE 16 TO L-VALUE
         WHEN 4
             IF L-VALUE = 1
                 MOVE 0 TO L-VALUE
             ELSE
                 MOVE 1 TO L-VALUE
             END-IF
         WHEN 5
             MOVE 70 TO L-VALUE
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-PORTAL-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PORTAL-TOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-LOGICAL-TOP         BINARY-LONG.
 LINKAGE SECTION.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-LOGICAL              BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN-Y L-HEIGHT L-LOGICAL L-TOP.
     COMPUTE WS-MAX-Y = L-MIN-Y + L-HEIGHT - 1
     COMPUTE WS-LOGICAL-TOP = L-MIN-Y + L-LOGICAL - 1
     COMPUTE L-TOP = FUNCTION MIN(WS-MAX-Y, WS-LOGICAL-TOP)
     GOBACK.
 END PROGRAM NETHER-PORTAL-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PORTAL-FALLBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MIN-Y                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-YOUT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN-Y L-TOP L-Y L-OK L-YOUT.
     COMPUTE WS-FLOOR = L-MIN-Y + 1
     COMPUTE WS-LOW = FUNCTION MAX(WS-FLOOR, 70)
     COMPUTE WS-HIGH = L-TOP - 9
     MOVE 0 TO L-OK L-YOUT
     IF WS-HIGH >= WS-LOW
         MOVE 1 TO L-OK
         COMPUTE L-YOUT = FUNCTION MAX(WS-LOW, FUNCTION MIN(WS-HIGH, L-Y))
     END-IF
     GOBACK.
 END PROGRAM NETHER-PORTAL-FALLBACK.
